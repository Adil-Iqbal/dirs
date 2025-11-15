const Locator = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;


const VTable = struct {
    v_getUserHomeOwned: *const fn(*const anyopaque, Allocator) DirsError![]const u8,
    v_getUserDataOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8,
    v_getSiteDataOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8,
    v_getUserConfigOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8, 
    v_getSiteConfigOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8, 
    v_getUserCacheOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8, 
    v_getSiteCacheOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8, 
    v_getUserStateOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8, 
    v_getUserLogOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8, 
    v_getUserDocumentsOwned: *const fn(*const anyopaque, Allocator) DirsError![]const u8,
    v_getUserPicturesOwned: *const fn(*const anyopaque, Allocator) DirsError![]const u8, 
    v_getUserVideosOwned: *const fn(*const anyopaque, Allocator) DirsError![]const u8, 
    v_getUserMusicOwned: *const fn(*const anyopaque, Allocator) DirsError![]const u8, 
    v_getUserDesktopOwned: *const fn(*const anyopaque, Allocator) DirsError![]const u8, 
    v_getUserRuntimeOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8, 
    v_getSiteRuntimeOwned: *const fn(*const anyopaque, Allocator, *const Options) DirsError![]const u8,
    v_pathSeperator: *const fn(*const anyopaque) u8,
};

impl: *const anyopaque,
vtable: *const VTable,

inline fn LocatorDelegate(impl_obj: anytype) type {
    const ImplType = @TypeOf(impl_obj);
    return struct {
        fn getUserHomeOwned(impl: *const anyopaque, alloc: Allocator) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserHomeOwned(alloc);
        }

        fn getUserDataOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserDataOwned(alloc, o);
        }

        fn getSiteDataOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getSiteDataOwned(alloc, o);
        }

        fn getUserConfigOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserConfigOwned(alloc, o);
        }

        fn siteConfig(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).siteConfig(o);
        }

        fn userCache(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).userCache(o);
        }

        fn siteCache(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).siteCache(o);
        }

        fn userState(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).userState(o);
        }

        fn userLog(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).userLog(o);
        }

        fn userDocuments(impl: *const anyopaque) DirsError![]const u8 {
            return TPtr(ImplType, impl).userDocuments();
        }

        fn userPictures(impl: *const anyopaque) DirsError![]const u8 {
            return TPtr(ImplType, impl).userPictures();
        }

        fn userVideos(impl: *const anyopaque) DirsError![]const u8 {
            return TPtr(ImplType, impl).userVideos();
        }

        fn userMusic(impl: *const anyopaque) DirsError![]const u8 {
            return TPtr(ImplType, impl).userMusic();
        }

        fn userDesktop(impl: *const anyopaque) DirsError![]const u8 {
            return TPtr(ImplType, impl).userDesktop();
        }

        fn userRuntime(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).userRuntime(o);
        }

        fn siteRuntime(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).siteRuntime(o);
        }

        fn pathSeperator(impl: *const anyopaque) u8 {
            return TPtr(ImplType, impl).pathSeperator();
        }
    };
}


fn TPtr(T: type, opaque_ptr: *const anyopaque) T {
    return @as(T, @ptrCast(@alignCast(opaque_ptr)));
}

pub fn implBy(impl_obj: anytype) Locator {
    const delegate = LocatorDelegate(impl_obj);
    const vtable: VTable = .{
        .v_getUserHomeOwned = delegate.getUserHomeOwned,
        .v_getUserDataOwned = delegate.getUserDataOwned,
        .v_getSiteDataOwned = delegate.getSiteDataOwned,
        .v_getUserConfigOwned = delegate.getUserConfigOwned, 
        .v_getSiteConfigOwned = delegate.getSiteConfigOwned, 
        .v_getUserCacheOwned = delegate.getUserCacheOwned, 
        .v_getSiteCacheOwned = delegate.getSiteCacheOwned, 
        .v_getUserStateOwned = delegate.getUserStateOwned, 
        .v_getUserLogOwned = delegate.getUserLogOwned, 
        .v_getUserDocumentsOwned = delegate.getUserDocumentsOwned, 
        .v_getUserPicturesOwned = delegate.getUserPicturesOwned, 
        .v_getUserVideosOwned = delegate.getUserVideosOwned, 
        .v_getUserMusicOwned = delegate.getUserMusicOwned, 
        .v_getUserDesktopOwned = delegate.getUserDesktopOwned, 
        .v_getUserRuntimeOwned = delegate.getUserRuntimeOwned, 
        .v_getSiteRuntimeOwned = delegate.getSiteRuntimeOwned,
        .v_pathSeperator = delegate.pathSeperator,
    };
    return .{
        .impl = impl_obj,
        .vtable = &vtable,
    };
}


pub fn userData(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_userData(self.impl, o);
}

pub fn siteData(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_siteData(self.impl, o);
}

pub fn userConfig(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_userConfig(self.impl, o);
}

pub fn siteConfig(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_siteConfig(self.impl, o);
}

pub fn userCache(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_userCache(self.impl, o);
}

pub fn siteCache(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_siteCache(self.impl, o);
}

pub fn userState(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_userState(self.impl, o);
}

pub fn userLog(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_userLog(self.impl, o);
}

pub fn userDocuments(self: Locator) DirsError![]const u8 {
    return self.vtable.v_userDocuments(self.impl);
}

pub fn userPictures(self: Locator) DirsError![]const u8 {
    return self.vtable.v_userPictures(self.impl);
}

pub fn userVideos(self: Locator) DirsError![]const u8 {
    return self.vtable.v_userVideos(self.impl);
}

pub fn userMusic(self: Locator) DirsError![]const u8 {
    return self.vtable.v_userMusic(self.impl);
}

pub fn userDesktop(self: Locator) DirsError![]const u8 {
    return self.vtable.v_userDesktop(self.impl);
}

pub fn userRuntime(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_userRuntime(self.impl, o);
}

pub fn siteRuntime(self: Locator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_siteRuntime(self.impl, o);
}


