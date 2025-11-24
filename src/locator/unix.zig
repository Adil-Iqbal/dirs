const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("pwd.h");
});

const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const path = std.fs.path;
const Self = @This();

/// Joins `base_path` with `app_name` and `version` from options if they are present.
/// Allocates memory for the result. Caller owns the returned slice.
fn appendNameAndVersion(alloc: Allocator, base_path: []const u8, o: *const Options) ![]const u8 {
    var parts: ArrayList([]const u8) = .empty;
    defer parts.deinit(alloc);

    try parts.append(alloc, base_path);
    if (!isNullOrBlank(o.app_name)) {
        try parts.append(alloc, o.app_name.?);
        if (!isNullOrBlank(o.version)) {
            try parts.append(alloc, o.version.?);
        }
    }

    return try path.join(alloc, parts.items);
}

/// Returns true if slice is null, empty, or whitespace only.
fn isNullOrBlank(s: ?[]const u8) bool {
    return s == null or isBlank(s.?);
}

/// Returns true if slice is empty or whitespace only.
fn isBlank(s: []const u8) bool {
    if (s.len == 0) return true;
    const trimmed = std.mem.trim(u8, s, &std.ascii.whitespace);
    return trimmed.len == 0;
}

/// Splits a multipath string by `pathsep`, appends name/version to each part, and rejoins them.
/// Allocates memory for the result. Caller owns the returned slice.
fn transformMultiPath(alloc: Allocator, path_str: []const u8, pathsep: u8, o: *const Options) DirsError![]const u8 {
    var result_parts: ArrayList(u8) = .empty;
    defer result_parts.deinit(alloc);

    var it = std.mem.splitScalar(u8, path_str, pathsep);
    var first = true;

    while (it.next()) |dir| {
        if (isBlank(dir)) continue;
        if (!first) try result_parts.append(alloc, pathsep);
        first = false;

        const full_path = appendNameAndVersion(alloc, dir, o) catch return DirsError.OperationFailed;
        defer alloc.free(full_path);
        try result_parts.appendSlice(alloc, full_path);
    }

    if (result_parts.items.len == 0)
        return DirsError.OperationFailed;

    return result_parts.toOwnedSlice(alloc);
}

/// Returns the first valid component of a multipath string, with name/version appended.
/// Allocates memory for the result. Caller owns the returned slice.
fn getFirstPath(alloc: Allocator, path_str: []const u8, pathsep: u8, o: *const Options) DirsError![]const u8 {
    var it = std.mem.splitScalar(u8, path_str, pathsep);

    while (it.next()) |dir| {
        if (isBlank(dir)) continue;
        return appendNameAndVersion(alloc, dir, o) catch continue;
    }

    return DirsError.OperationFailed;
}

/// Retrieves the current user's home directory.
/// Allocates memory for the result. Caller owns the returned slice.
pub fn getUserHomeOwned(_: *const Self, alloc: Allocator) DirsError![]const u8 {
    if (std.process.getEnvVarOwned(alloc, "HOME")) |home| {
        if (!isBlank(home)) return home;
        alloc.free(home);
    } else |_| {}

    const uid = std.posix.getuid();
    if (c.getpwuid(uid)) |passwd| {
        if (passwd.*.pw_dir) |dir_ptr| {
            const dir_span = std.mem.span(dir_ptr);
            if (!isBlank(dir_span)) {
                return alloc.dupe(u8, dir_span) catch DirsError.OperationFailed;
            }
        }
    }

    return DirsError.OperationFailed;
}

/// Returns the user data directory (e.g., $XDG_DATA_HOME or ~/.local/share).
/// Allocates memory for the result. Caller owns the returned slice.
pub fn getUserDataOwned(self: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_HOME")) |xdg_home| {
        defer alloc.free(xdg_home);
        if (!isBlank(xdg_home))
            return appendNameAndVersion(alloc, xdg_home, o) catch DirsError.OperationFailed;
    } else |_| {}

    const user_home = try self.getUserHomeOwned(alloc);
    defer alloc.free(user_home);

    const default_base = path.join(alloc, &.{ user_home, ".local", "share" }) catch return DirsError.OperationFailed;
    defer alloc.free(default_base);

    return appendNameAndVersion(alloc, default_base, o) catch DirsError.OperationFailed;
}

const default_site_data = "/usr/local/share:/usr/share";

/// Returns the site data directory (e.g. XDG_DATA_DIRS).
/// Allocates memory for the result. Caller owns the returned slice.
pub fn getSiteDataOwned(_: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    const pathsep = std.fs.path.delimiter;

    var raw_path: []const u8 = undefined;
    var must_free_raw = false;

    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_DIRS")) |env_val| {
        if (isBlank(env_val)) {
            alloc.free(env_val);
            raw_path = default_site_data;
        } else {
            raw_path = env_val;
            must_free_raw = true;
        }
    } else |_| {
        raw_path = default_site_data;
    }

    defer if (must_free_raw) alloc.free(raw_path);

    if (!isMultiPath(raw_path, pathsep)) {
        return appendNameAndVersion(alloc, raw_path, o) catch DirsError.OperationFailed;
    }

    if (!o.multipath) {
        return getFirstPath(alloc, raw_path, pathsep, o);
    }

    return transformMultiPath(alloc, raw_path, pathsep, o);
}

pub fn getUserConfigOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getSiteConfigOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserCacheOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getSiteCacheOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserStateOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserLogOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserDocumentsOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserPicturesOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserVideosOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserMusicOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserDesktopOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getUserRuntimeOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn getSiteRuntimeOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}
