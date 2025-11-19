const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const Tag = std.Target.Os.Tag;
const Locator = @import("locator/interface.zig");
const UnsupportedOSLocator = @import("locator/unsupported.zig");

/// Consider using `init` method instead!
///
/// If your app will only run on Windows OS and is severely memory constrained,
/// use `WinLocator` directly to maximally reduce the memory footprint of this
/// library.
///
/// const dirs = @import("dirs").WinLocator {};
pub const WinLocator = @import("./locator/win.zig");

/// Consider using `init` method instead.
///
/// If your app will only run on Macintosh OS and is severely memory constrained,
/// use `MacOSLocator` directly to maximally reduce the memory footprint of this
/// library.
///
/// const dirs = @import("dirs").MacOSLocator {};
pub const MacOSLocator = @import("locator/macos.zig");

/// Consider using `init` method instead.
///
/// If your app will only run on Linux or FreeBSD OS and is severely memory 
/// constrained, use `UnixLocator` directly to maximally reduce the memory 
/// footprint of this library.
///
/// const dirs = @import("dirs").UnixLocator {};
pub const UnixLocator = @import("locator/unix.zig");

pub const Options = @import("locator/options.zig");
pub const DirsError = @import("locator/error.zig").DirsError;

const Dirs = @This();

var locator: ?Locator = null;

/// Called at runtime to determine which locator to use for the current OS.
/// No-op if `init` method has already been called.
fn runtimeInitIfNeeded() void {
    if (Dirs.locator == null) {
        Dirs.init(builtin.target.os.tag);
    }
}

/// If your app has only one target operating system, call this method first to
/// safely reduce the memory footprint of this library.
/// 
/// dirs.init(builtin.target.os.tag);
pub fn init(tag: Tag) void {
    Dirs.locator = switch(tag) {
        .windows => Locator.implBy(&WinLocator {}),
        .macos =>  Locator.implBy(&MacOSLocator {}),
        .freebsd, .linux => Locator.implBy(&UnixLocator {}),
        else => Locator.implBy(&UnsupportedOSLocator {}),
    };
}

/// Non-standard directory for application storage. Consider only for bespoke
/// solutions. Caller is responsible for freeing the returned value.
pub fn getUserHomeOwned(alloc: Allocator) ![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.getUserHomeOwned(alloc);
}

/// Standard directory for storage of user-owned and application-specific files
/// that the user wouldn't modify but uould reasonably keep or back-up. Caller
/// is responsible for freeing the returned value.
pub fn getUserDataOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.getUserDataOwned(o, alloc);
}

/// Standard directory for storage of user-owned and application-specific files
/// that the users wouldn't modify but would reasonably keep or back-up.
/// Available to all users.
pub fn getSiteDataOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.getSiteDataOwned(o, alloc);
}

/// Standard directory for storage of user-specific configuration files.
/// Consider for editable files that customize the behavior of the application.
pub fn getUserConfigOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserConfig(o, alloc);
}

/// Standard directory for storage of configuration files needed by all users.
/// Consider for editable files that customize the behavior of the application.
pub fn getSiteConfigOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedSiteConfig(o, alloc);
}

/// Standard directory for storage of user specific cached data that can be 
/// deleted at any time without loss of application functionality. 
/// Consider for downloaded assets or compiled templates.
pub fn getUserCacheOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserCache(o, alloc);
}

/// Standard directory for storage of cached data for all users that can be 
/// deleted at any time without loss of application functionality. 
/// Consider for downloaded assets or compiled templates.
pub fn getSiteCacheOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedSiteCache(o, alloc);
}

/// Standard directory for storage of user specific files that represent
/// persistent state that must survive application restart.
/// Consider for files that represent the data layer of the application.
pub fn getUserStateOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserState(o, alloc);
}

/// Standard directory for storage of user specific log files.
/// Consider for files that can be used to audit application behavior.
pub fn getUserLogOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserLog(o, alloc);
}

/// Standard directory for storage of user-owned files that are
/// application-agnostic. Consider for files that the user would reasonably be
/// expcted to use outside the context of your application, such as exports.
pub fn getUserDocumentsOwned(alloc: Allocator) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserDocuments(alloc);
}

/// Standard directory for storage of user-specific image files.
/// Consider for file formats: .jpg, .gif, .png, .tiff
pub fn getUserPicturesOwned(alloc: Allocator) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserPictures(alloc);
}

/// Standard directory for storage of user-specific video files.
/// Consider for file formats: .mp4, .mov, .wmv
pub fn getUserVideosOwned(alloc: Allocator) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserVideos(alloc);
}

/// Standard directory for storage of user-specific audio files. 
/// Consider for file formats: .wav, .mp3, .midi
pub fn getUserMusicOwned(alloc: Allocator) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserMusic(alloc);
}

/// Standard directory that renders file contents on the user's 
/// Desktop. Consider for shortcuts and symlinks to your application.
pub fn getUserDesktopOwned(alloc: Allocator) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserDesktop(alloc);
}

/// Standard directory for storage of user specific temporary files that
/// support application runtime.
pub fn getUserRuntimeOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedUserRuntime(o, alloc);
}

/// Standard directory for storage of temporary files that support application
/// runtime for all users.
pub fn getSiteRuntimeOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    runtimeInitIfNeeded();
    return Dirs.locator.ownedSiteRuntime(o, alloc);
}

pub const Iterator = struct {
    items: [3]?DirsError![]const u8,
    index: usize,

    pub fn next(self: *Iterator) ?DirsError![]const u8 {
        if (self.index >= self.items.len)
            return null;
        const item = self.items[self.index];
        self.index += 1;
        return item;
    }
};
