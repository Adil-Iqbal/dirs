const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;

const Self = @This();

pub fn userData(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn siteData(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userConfig(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn siteConfig(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userCache(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn siteCache(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userState(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userLog(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userDocuments(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userPictures(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userVideos(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userMusic(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userDesktop(_: *const Self) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn userRuntime(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}

pub fn siteRuntime(_: *const Self, _: *const Options) DirsError![]const u8 {
    return DirsError.UnsupportedOSError;
}


