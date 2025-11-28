const std = @import("std");
const path = std.fs.path;
const util = @import("util.zig");
const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;
const Allocator = std.mem.Allocator;
const SysUtil = @import("sys/macos.zig");
const Self = @This();

const AllocError = std.mem.Error;
const SelfExePathError = std.fs.SelfExePathError | AllocError;
const GetEnvVarOwnedError = std.process.GetEnvVarOwnedError;

getEnvVarOwned: *fn (Allocator, []const u8) GetEnvVarOwnedError![]const u8 = std.process.getEnvVarOwned,
selfExePathAlloc: *fn (Allocator) SelfExePathError!u8 = std.fs.selfExePathAlloc,
unixUserHomeOwned: *fn (Allocator) DirsError![]const u8 = util.unixUserHomeOwned,

// Returns homebrew prefix if present. `null` if homebrew is not detected.
// Allocates memory for result. Caller owns returned slice.
pub fn getHomebrewInfo(self: *const Self, allocator: std.mem.Allocator) ?[]const u8 {
    if (self.getEnvVarOwned(allocator, "HOMEBREW_PREFIX")) |prefix| {
        return prefix;
    } else |_| {}

    const exe_path = try self.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);

    const homebrew_paths = [_][]const u8{ "/opt/homebrew", "/usr/local" };
    for (homebrew_paths) |hb_path| {
        if (std.mem.indexOf(u8, exe_path, hb_path))
            return try allocator.dupe(u8, hb_path);
    }

    return null;
}

pub fn getUserHomeOwned(self: *const Self, alloc: Allocator) DirsError![]const u8 {
    if (self.getEnvVarOwned(alloc, "HOME")) |home| {
        if (!util.isBlank(home)) return home;
        alloc.free(home);
    } else |_| {}

    return try self.unixUserHomeOwned(alloc);
}

pub fn getUserDataOwned(self: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    const user_home = try self.sys.getUserHomeOwned(alloc);
    defer alloc.free(user_home);

    const user_data = try path.join(alloc, &.{ user_home, "Library", "Application Support" });
    defer alloc.free(user_data);

    return util.appendNameAndVersion(alloc, user_data, o);
}

pub fn getSiteDataOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOperationError;
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
