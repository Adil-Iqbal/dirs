const std = @import("std");
const builtin = @import("builtin");
const util = @import("util.zig");
const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;

const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const path = std.fs.path;
const Self = @This();

/// Retrieves the current user's home directory.
/// Allocates memory for the result. Caller owns the returned slice.
pub fn getUserHomeOwned(_: *const Self, alloc: Allocator) DirsError![]const u8 {
    return try util.unixUserHomeOwned(alloc);
}

/// Returns the user data directory (e.g., $XDG_DATA_HOME or ~/.local/share).
/// Allocates memory for the result. Caller owns the returned slice.
pub fn getUserDataOwned(self: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_HOME")) |xdg_home| {
        defer alloc.free(xdg_home);
        if (!util.isBlank(xdg_home))
            return util.appendNameAndVersion(alloc, xdg_home, o) catch DirsError.OperationFailed;
    } else |_| {}

    const user_home = try self.getUserHomeOwned(alloc);
    defer alloc.free(user_home);

    const default_base = path.join(alloc, &.{ user_home, ".local", "share" }) catch return DirsError.OperationFailed;
    defer alloc.free(default_base);

    return util.appendNameAndVersion(alloc, default_base, o) catch DirsError.OperationFailed;
}

const default_site_data = "/usr/local/share:/usr/share";

/// Returns the site data directory (e.g. XDG_DATA_DIRS).
/// Allocates memory for the result. Caller owns the returned slice.
pub fn getSiteDataOwned(_: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    var raw_path: []const u8 = undefined;
    var must_free_raw = false;

    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_DIRS")) |env_val| {
        if (util.isBlank(env_val)) {
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

    if (!util.isMultipath(raw_path)) 
        return util.appendNameAndVersion(alloc, raw_path, o) catch DirsError.OperationFailed;
    
    if (!o.multipath) 
        return util.getFirstPath(alloc, raw_path, o);

    return util.transformMultiPath(alloc, raw_path, o);
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
