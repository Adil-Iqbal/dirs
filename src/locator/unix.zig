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
/// the base_path joined with `o.app_name` and `o.version` if they exist. The
/// caller is responsible for freeing the returned value.
fn appendNameAndVersionOwned(alloc: Allocator, base_path: *[]const u8, o: *const Options) []const u8 {
    if (isBlank(&o.app_name))
        return base_path;
    defer alloc.free(base_path);
    const path_with_name = path.join(alloc, .{base_path.*, o.app_name});
    if (isBlank(&o.version))
        return path_with_name;
    defer alloc.free(path_with_name);
    return path.join(alloc, .{path_with_name, o.version});
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
    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_HOME") catch null) |user_data_dir| {
        if (!isBlank(&user_data_dir)) {
            return appendNameAndVersionOwned(alloc, &user_data_dir, o);
        }
    }

    if (getUserHomeOwned(alloc) catch null) |user_home| {
        defer alloc.free(user_home);
        const user_data_dir = path.join(alloc, .{user_home, ".local", "share"});
        return appendNameAndVersionOwned(alloc, &user_data_dir, o);
    }

    return DirsError.OperationFailed;
}

pub fn pathSeperator(_: *const Self) u8 {
    return ':';
}


pub fn getSiteDataOwned(self: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    var site_data_dirs: ?[]const u8 = null;

    if (std.process.getEnvVarOwned(alloc, "XDG_DATA_DIRS") catch null) |xdg_data_dirs| {
        defer alloc.free(xdg_data_dirs);
        if (!isBlank(&xdg_data_dirs)) {
            site_data_dirs = xdg_data_dirs;
        }
    }

    if (site_data_dirs == null) {
        const pathsep = self.pathSeperator();
        const user_local_share = path.join(alloc, .{"usr", "local", "share"});
        defer alloc.free(user_local_share);
        const user_share = path.join(alloc, .{"usr", "share"});
        defer alloc.free(user_share);
        site_data_dirs = std.mem.concat(alloc, u8, .{user_local_share, [_]u8{pathsep}, user_share});
    }
    
    const is_multipath: bool = if (o.multipath) |mp| mp else false;
    
    // TODO: count pathsep, if none -> return append as is.
    // else if !is_multipath, split and take first return append as is.
    // else split, append, rejoin, return.
    
    return DirsError.UnsupportedOperationError;
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
