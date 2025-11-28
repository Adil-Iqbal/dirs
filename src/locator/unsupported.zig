const std = @import("std");

const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;
const Allocator = std.mem.Allocator;

const Self = @This();

pub fn getUserHomeOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserDataOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getSiteDataOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserConfigOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getSiteConfigOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserCacheOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getSiteCacheOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserStateOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserLogOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserDocumentsOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserPicturesOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserVideosOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserMusicOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserDesktopOwned(_: *const Self, _: Allocator) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getUserRuntimeOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn getSiteRuntimeOwned(_: *const Self, _: Allocator, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

