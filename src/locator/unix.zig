const std = @import("std");
const c = @cImport({
    @cInclude("pwd.h");
});

const util = @import("util.zig");
const Options = @import("options.zig");
const DirsError = @import("error.zig");

const path = std.fs.path;
const Allocator = std.mem.Allocator;
const Self = @This();

/// Takes ownership of argument used for parameter `base_path` and will return
/// the base_path joined with `o.verion` if it exists. The caller is
/// responsible for freeing the returned value.
fn takeAppendVersionOwned(alloc: Allocator, base_path: *[]const u8, o: *const Options) []const u8 {
    if (isBlank(&o.version))
        return base_path;
    defer alloc.free(base_path);
    return path.join(alloc, .{base_path.*, o.version});
}

/// Takes ownership of argument used for parameter `base_path` and will return
/// the base_path joined with `o.app_name` and `o.version` if they exist. The
/// caller is responsible for freeing the returned value.
fn takeAppendNameAndVersionOwned(alloc: Allocator, base_path: *[]const u8, o: *const Options) []const u8 {
    if (isBlank(&o.app_name))
        return base_path;
    defer alloc.free(base_path);
    const path_with_name = path.join(alloc, .{base_path.*, o.app_name});
    return takeAppendVersionOwned(alloc, &path_with_name, o);
}

/// Returns base_path joined with `o.app_name` and `o.version` if they exist.
/// The caller is responsible for freeing returned value and `base_path`.
fn appendNameAndVersionOwned(alloc: Allocator, base_path: *[]const u8, o: *const Options) []const u8 {
    if (isBlank(&o.app_name))
        return base_path;
    const path_with_name = path.join(alloc, .{base_path.*, o.app_name});
    return takeAppendVersionOwned(alloc, &path_with_name, o);
}

/// Returns true if slice is null, empty, or whitespace only.
fn isBlank(s: *[]const u8) bool {
    if (s == null or s.len == 0)
        return true;
    const _s = std.mem.trim(u8, s, std.ascii.whitespace);
    return std.mem.eql(u8, _s, "");
}

/// Attempts to determine user's $HOME directory. Caller is responsible for
/// freeing the returned value.
fn getUserHomeOwned(alloc: Allocator) ![]const u8 {
    if (std.process.getEnvVarOwned(alloc, "HOME")) |user_home| {
        if (!isBlank(&user_home))
            return user_home;
    }

    const pid = std.posix.getuid();
    const passwd = c.getpwuid(pid);
    if (passwd != null and passwd.pw_dir != null) {
        const user_home = std.mem.span(passwd.pw_dir);
        if (!isBlank(&user_home))
            return try alloc.dupe(u8, user_home);
    }

    return DirsError.OperationFailed;
}


/// Returns: `$XDG_DATA_HOME/$app_name/$version`
pub fn getUserDataOwned(_: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_HOME") catch null) |xdg_data_home| 
        if (!isBlank(&xdg_data_home))
            return takeAppendNameAndVersionOwned(alloc, &xdg_data_home, o);

    if (getUserHomeOwned(alloc) catch null) |user_home| {
        defer alloc.free(user_home);
        const user_data_dir = path.join(alloc, .{user_home, ".local", "share"});
        return takeAppendNameAndVersionOwned(alloc, &user_data_dir, o);
    }

    return DirsError.OperationFailed;
}

pub fn pathSeperator(_: *const Self) u8 {
    return ':';
}

const user_local_share: []const u8 = "/usr/local/share";
const default_site_data: []const u8 = "/usr/local/share:/user/share";

pub fn getSiteDataOwned(self: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    var site_data_dirs: ?[]const u8 = null;

    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_DIRS") catch null) |xdg_data_dirs| {
        defer alloc.free(xdg_data_dirs);
        if (!isBlank(&xdg_data_dirs)) {
            site_data_dirs = xdg_data_dirs;
        }
    }

    const pathsep = self.pathSeperator();
    const is_multipath_requested: bool = if (o.multipath) |mp| mp else false;
    const is_multipath_value: bool = std.mem.findScalar(u8, site_data_dirs, pathsep);

    if (site_data_dirs == null) {
        site_data_dirs = alloc.dupe(u8, default_site_data);
        defer alloc.free(site_data_dirs);
    }
    
    if (!is_multipath_value)
        return takeAppendNameAndVersionOwned(alloc, &site_data_dirs, o);

    var num_paths: usize = 0;
    var it = std.mem.splitScalar(u8, site_data_dirs, pathsep);
    while(it.next()) |site_data_dir| {
        if (!is_multipath_requested)
            return takeAppendNameAndVersionOwned(alloc, &site_data_dir, o);
        num_paths += 1;
    }

    const size = 2 * num_paths - 1;
    var paths: [size][]const u8 = undefined;

    var idx = 0;
    var it2 = std.mem.splitScalar(u8, site_data_dirs, pathsep);
    while(it2.next()) |dir| {
        paths[idx] = appendNameAndVersionOwned(alloc, &dir, o);
        defer alloc.free(paths[idx]);
        if (idx + 1 < paths.len)
            paths[idx + 1] = [_]u8{pathsep};
        idx += 1;
    }

    return std.mem.concat(alloc, u8, paths);
}

pub fn getUserConfigOwned(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn siteConfig(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userCache(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn siteCache(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userState(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userLog(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userDocuments(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userPictures(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userVideos(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userMusic(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userDesktop(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn userRuntime(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}

pub fn siteRuntime(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
}
