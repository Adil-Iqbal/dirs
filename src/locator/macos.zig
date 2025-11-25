const std = @import("std");
const path = std.fs.path;
const util = @import("util.zig");
const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;
const Allocator = std.mem.Allocator;

const Self = @This();

// Returns homebrew prefix if present. `null` if homebrew is not detected.
// Allocates memory for result. Caller owns returned slice.
fn getHomebrewInfo(allocator: std.mem.Allocator) ?[]const u8 {
    if (std.process.getEnvVarOwned(allocator, "HOMEBREW_PREFIX")) |prefix| {
        return prefix;
    } else |_| {}
    
    const exe_path = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(exe_path);
    
    const homebrew_paths = [_][]const u8{ "/opt/homebrew", "/usr/local" };
    for (homebrew_paths) |hb_path| {
        if (std.mem.indexOf(u8, exe_path, hb_path)) 
            return try allocator.dupe(u8, hb_path);
    }
    
    return null;
}

pub fn getUserHomeOwned(_: *const Self, alloc: Allocator) DirsError![]const u8 {
    return try util.unixUserHomeOwned(alloc);
}

pub fn getUserDataOwned(self: *const Self, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    const user_home = try self.getUserHomeOwned(alloc);
    defer alloc.free(user_home);

    const user_data = try path.join(alloc, &.{user_home, "Library", "Application Support"});
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
