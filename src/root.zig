const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const SplitIterator = std.mem.SplitIterator;
const Tag = std.Target.Os.Tag;
const Locator = @import("locator/interface.zig");
const UnsupportedOSLocator = @import("locator/unsupported.zig");
const util = @import("locator/util.zig");
pub const MultipathIterator = util.MultipathIterator;

/// If your app will only run on Windows OS and is severely memory constrained,
/// use `WinLocator` directly to maximally reduce the memory footprint of this
/// library.
///
/// const dirs = @import("dirs").WinLocator {};
pub const WinLocator = @import("./locator/win.zig");

/// If your app will only run on Macintosh OS and is severely memory constrained,
/// use `MacOSLocator` directly to maximally reduce the memory footprint of this
/// library.
///
/// const dirs = @import("dirs").MacOSLocator {};
pub const MacOSLocator = @import("locator/macos.zig");

/// If your app will only run on Linux or FreeBSD OS and is severely memory
/// constrained, use `UnixLocator` directly to maximally reduce the memory
/// footprint of this library.
///
/// const dirs = @import("dirs").UnixLocator {};
pub const UnixLocator = @import("locator/unix.zig");

pub const Options = @import("locator/options.zig");
pub const DirsError = @import("locator/error.zig").DirsError;
pub const is_supported = util.getSupportedOS(builtin.target.os.tag) != null;

const Self = @This();

var locator: Locator = switch (builtin.target.os.tag) {
    .windows => Locator.implBy(&WinLocator{}),
    .macos => Locator.implby(&MacOSLocator{}),
    .linux, .freebsd => Locator.implBy(&UnixLocator{}),
    else => Locator.implBy(&UnsupportedOSLocator{}),
};

/// Non-standard directory for application storage. Returns the user's home
/// directory. Consider only for bespoke solutions. Caller is responsible for
/// freeing the returned memory.
pub fn getUserHomeOwned(alloc: Allocator) ![]const u8 {
    return try Self.locator.getUserHomeOwned(alloc);
}

/// Standard directory for storage of user-owned and application-specific files
/// that the user wouldn't modify but would reasonably keep or back-up. Caller
/// is responsible for freeing the returned value.
pub fn getUserDataOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getUserDataOwned(alloc, o);
}

/// Standard directory for storage of user-owned and application-specific files
/// that the users wouldn't modify but would reasonably keep or back-up.
/// Available to all users.
pub fn getSiteDataOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getSiteDataOwned(alloc, o);
}

/// Standard directory for storage of user-specific configuration files.
/// Consider for editable files that customize the behavior of the application.
pub fn getUserConfigOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getUserConfigOwned(alloc, o);
}

/// Standard directory for storage of configuration files needed by all users.
/// Consider for editable files that customize the behavior of the application.
pub fn getSiteConfigOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getSiteConfigOwned(alloc, o);
}

/// Standard directory for storage of user specific cached data that can be
/// deleted at any time without loss of application functionality.
/// Consider for downloaded assets or compiled templates.
pub fn getUserCacheOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getUserCacheOwned(alloc, o);
}

/// Standard directory for storage of cached data for all users that can be
/// deleted at any time without loss of application functionality.
/// Consider for downloaded assets or compiled templates.
pub fn getSiteCacheOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getSiteCacheOwned(alloc, o);
}

/// Standard directory for storage of user specific files that represent
/// persistent state that must survive application restart.
/// Consider for files that represent the data layer of the application.
pub fn getUserStateOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getUserStateOwned(alloc, o);
}

/// Standard directory for storage of user specific log files.
/// Consider for files that can be used to audit application behavior.
pub fn getUserLogOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getUserLogOwned(alloc, o);
}

/// Standard directory for storage of user-owned files that are
/// application-agnostic. Consider for files that the user would reasonably be
/// expcted to use outside the context of your application, such as exports.
pub fn getUserDocumentsOwned(alloc: Allocator) DirsError![]const u8 {
    return try Self.locator.getUserDocumentsOwned(alloc);
}

/// Standard directory for storage of user-specific image files.
/// Consider for file formats: .jpg, .gif, .png, .tiff
pub fn getUserPicturesOwned(alloc: Allocator) DirsError![]const u8 {
    return try Self.locator.getUserPicturesOwned(alloc);
}

/// Standard directory for storage of user-specific video files.
/// Consider for file formats: .mp4, .mov, .wmv
pub fn getUserVideosOwned(alloc: Allocator) DirsError![]const u8 {
    return try Self.locator.getUserVideosOwned(alloc);
}

/// Standard directory for storage of user-specific audio files.
/// Consider for file formats: .wav, .mp3, .midi
pub fn getUserMusicOwned(alloc: Allocator) DirsError![]const u8 {
    return try Self.locator.getUserMusicOwned(alloc);
}

/// Standard directory that renders file contents on the user's
/// Desktop. Consider for shortcuts and symlinks to your application.
pub fn getUserDesktopOwned(alloc: Allocator) DirsError![]const u8 {
    return try Self.locator.getUserDesktopOwned(alloc);
}

/// Standard directory for storage of user specific temporary files that
/// support application runtime.
pub fn getUserRuntimeOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getUserRuntimeOwned(alloc, o);
}

/// Standard directory for storage of temporary files that support application
/// runtime for all users.
pub fn getSiteRuntimeOwned(alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return try Self.locator.getSiteRuntimeOwned(alloc, o);
}

pub const isMultipath = util.isMultipath;

/// Returns iterator that iterates over individual file paths in a slice that
/// may contain multiple file paths in a manner that is operating system
/// agnostic.
///
/// On a unix operating system:
/// multipathIterator("/usr/bin:/etc") will return "/usr/bin", "/etc", null.
/// multipathIterator("/etc") will return "/etc", null.
///
/// On a windows operating system:
/// multipathIterator("C:\\Program Files;C:\\User") will return
/// "C:\\Program Files", "C:\\User", null.
/// multipathIterator("C:\\Program Files") will return "C:\\Program Files", null.
///
/// See Also: `std.mem.splitScalar`, `std.fs.path.delimiter`
pub fn multipathIterator(paths: []const u8) MultipathIterator {
    const os_delimiter = std.fs.path.delimiter;
    return util.multipathIteratorExplicitDelimiter(paths, os_delimiter);
}

/// Will attempt to create all directories in the directory paths provided.
pub fn ensureExists(paths: []const u8) !void {
    if (paths.len == 0)
        return;

    const cwd = std.fs.cwd();
    var it = multipathIterator(paths);
    while (it.next()) |path| {
        if (path.len == 0) continue;
        if (util.pathExists(path)) continue;

        const last_char = path[path.len - 1];
        if (last_char == '/' or last_char == std.fs.path.sep) {
            try cwd.makePath(path);
            continue;
        }
    }
}
