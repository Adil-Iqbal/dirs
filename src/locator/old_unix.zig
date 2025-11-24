const std = @import("std");
const c = @cImport({
    @cInclude("pwd.h");
});

const util = @import("util.zig");
const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;
const ArrayList = std.ArrayList;
const path = std.fs.path;
const Allocator = std.mem.Allocator;
const Self = @This();

/// Takes ownership of argument used for parameter `base_path` and will return
/// the base_path joined with `o.version` if it exists. The caller is
/// responsible for freeing the returned value.
fn takeAppendVersionOwned(alloc: Allocator, base_path: *const []u8, o: *const Options) []const u8 {
    if (isNullOrBlank(o.version))
        return base_path.*;

    const path_with_version = path.join(alloc, &.{ base_path.*, o.version.?.* }) catch {
        return base_path.*;
    };

    alloc.free(base_path);
    return path_with_version;
}

/// Takes ownership of argument used for parameter `base_path` and will return
/// the base_path joined with `o.app_name` and `o.version` if they exist. The
/// caller is responsible for freeing the returned value.
fn takeAppendNameAndVersionOwned(alloc: Allocator, base_path: *const []u8, o: *const Options) []const u8 {
    if (isNullOrBlank(o.app_name))
        return base_path.*;

    const path_with_name: []u8 = path.join(alloc, &.{ base_path.*, o.app_name.?.* }) catch {
        return base_path.*;
    };

    alloc.free(base_path);
    return takeAppendVersionOwned(alloc, &path_with_name, o);
}

/// Returns `base_path` joined with `o.app_name` and `o.version` if they exist.
/// The caller is responsible for freeing returned value and `base_path`.
fn appendNameAndVersionOwned(alloc: Allocator, base_path: *const []u8, o: *const Options) []const u8 {
    if (isNullOrBlank(o.app_name))
        return base_path.*;

    const path_with_name = path.join(alloc, &.{ base_path.*, o.app_name.?.* }) catch {
        return base_path.*;
    };

    return takeAppendVersionOwned(alloc, &path_with_name, o);
}

/// Returns true if slice is null, empty, or whitespace only.
fn isNullOrBlank(s: ?*const []u8) bool {
    return s == null or isBlank(s.?);
}

/// Returns true if slice is empty or whitespace only.
fn isBlank(s: *const []u8) bool {
    if (s.len == 0)
        return true;
    const _s = std.mem.trim(u8, s.*, &std.ascii.whitespace);
    return std.mem.eql(u8, _s, "");
}

/// Returns true if `paths` contains `pathsep` byte.
fn isMultiPath(paths: *[]const u8, pathsep: u8) bool {
    return std.mem.indexOfScalar(u8, paths, pathsep) != null;
}

/// Transform the components of a multipath based on some transformation
/// function. Caller is responsible for freeing the returned memory.
fn transformMultiPathOwned(alloc: Allocator, path_str: *[]const u8, pathsep: u8, o: *const Options) DirsError![]const u8 {
    var result: ArrayList = .empty;
    errdefer result.deinit(alloc);

    var first = true;
    var it = std.mem.splitScalar(u8, path_str, pathsep);

    while (it.next()) |dir| {
        if (dir.len == 0) continue;

        if (!first)
            try result.append(alloc, pathsep);

        first = false;
        const full_path = appendNameAndVersionOwned(alloc, &dir, o);
        defer alloc.free(full_path);

        try result.appendSlice(alloc, full_path);
    }

    if (result.items.len == 0) {
        result.deinit(alloc);
        return DirsError.OperationFailed;
    }

    return result.toOwnedSlice(alloc);
}

/// Transform and return the first component of a multipath based on some
/// transformation function. Caller is responsible for freeing the returned
/// memory.
fn getFirstPathOwned(alloc: Allocator, path_str: *[]const u8, pathsep: u8, o: *const Options) DirsError![]const u8 {
    var it = std.mem.splitScalar(u8, path_str, pathsep);

    while (it.next()) |dir| {
        if (isBlank(&dir)) continue;
        return appendNameAndVersionOwned(alloc, &dir, o);
    }

    return DirsError.OperationFailed;
}

/// Attempts to determine user's $HOME directory. Caller is responsible for
/// freeing the returned value.
pub fn getUserHomeOwned(_: *const Self, alloc: Allocator) DirsError![]const u8 {
    if (std.process.getEnvVarOwned(alloc, "HOME") catch null) |user_home| {
        if (!isBlank(&user_home))
            return user_home;
    }

    const pid = std.posix.getuid();
    const passwd = c.getpwuid(pid);
    if (passwd == null)
        return DirsError.OperationFailed;

    const pw_dir = passwd.*.pw_dir;
    if (pw_dir == null)
        return DirsError.OperationFailed;

    const user_home = std.mem.span(pw_dir);
    if (isBlank(&user_home))
        return DirsError.OperationFailed;

    return try alloc.dupe(u8, user_home);
}

/// Returns: `$XDG_DATA_HOME/$app_name/$version`
pub fn getUserDataOwned(self: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_HOME") catch null) |xdg_data_home|
        if (!isBlank(&xdg_data_home))
            return takeAppendNameAndVersionOwned(alloc, &xdg_data_home, o);

    if (self.getUserHomeOwned(alloc) catch null) |user_home| {
        defer alloc.free(user_home);
        const user_data_dir = path.join(alloc, &.{ user_home, ".local", "share" });
        return takeAppendNameAndVersionOwned(alloc, &user_data_dir, o);
    }

    return DirsError.OperationFailed;
}

pub fn pathSeperator(_: *const Self) u8 {
    return ':';
}

const default_site_data: []const u8 = "/usr/local/share:/user/share";

pub fn getSiteDataOwned(self: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    const pathsep = self.pathSeperator();
    const wants_multipath = if (o.multipath) |mp| mp else false;
    var xdg_data_dirs = std.process.getEnvVarOwned(alloc, "XDG_DATA_DIRS") catch null;
    defer if (xdg_data_dirs != null) alloc.free(xdg_data_dirs);

    if (isBlank(&xdg_data_dirs))
        xdg_data_dirs = alloc.dupe(u8, default_site_data);

    if (!isMultiPath(&xdg_data_dirs, pathsep))
        return appendNameAndVersionOwned(alloc, &xdg_data_dirs, o);

    if (!wants_multipath)
        return getFirstPathOwned(alloc, &xdg_data_dirs, pathsep);

    return try transformMultiPathOwned(alloc, &xdg_data_dirs, pathsep, o);
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
