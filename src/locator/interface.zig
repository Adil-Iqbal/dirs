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

        fn getSiteConfigOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getSiteConfigOwned(alloc, o);
        }

        fn getUserCacheOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserCacheOwned(alloc, o);
        }

        fn getSiteCacheOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getSiteCacheOwned(alloc, o);
        }

        fn getUserStateOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserStateOwned(alloc, o);
        }

        fn getUserLogOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserLogOwned(alloc, o);
        }

        fn getUserDocumentsOwned(impl: *const anyopaque, alloc: Allocator) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserDocumentsOwned(alloc);
        }

        fn getUserPicturesOwned(impl: *const anyopaque, alloc: Allocator) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserPicturesOwned(alloc);
        }

        fn getUserVideosOwned(impl: *const anyopaque, alloc: Allocator) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserVideosOwned(alloc);
        }

        fn getUserMusicOwned(impl: *const anyopaque, alloc: Allocator) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserMusicOwned(alloc);
        }

        fn getUserDesktopOwned(impl: *const anyopaque, alloc: Allocator) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserDesktopOwned(alloc);
        }

        fn getUserRuntimeOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getUserRuntimeOwned(alloc, o);
        }

        fn getSiteRuntimeOwned(impl: *const anyopaque, alloc: Allocator, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).getSiteRuntimeOwned(alloc, o);
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
    };
    return .{
        .impl = impl_obj,
        .vtable = &vtable,
    };
}


pub fn getUserHomeOwned(self: Locator, alloc: Allocator) DirsError![]const u8 {
    return self.vtable.v_getUserHomeOwned(self.impl, alloc);
}

pub fn getUserDataOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getUserDataOwned(self.impl, alloc, o);
}

pub fn getSiteDataOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getSiteDataOwned(self.impl, alloc, o);
}

pub fn getUserConfigOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getUserConfigOwned(self.impl, alloc, o);
}

pub fn getSiteConfigOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getSiteConfigOwned(self.impl, alloc, o);
}

pub fn getUserCacheOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getUserCacheOwned(self.impl, alloc, o);
}

pub fn getSiteCacheOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getSiteCacheOwned(self.impl, alloc, o);
}

pub fn getUserStateOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getUserStateOwned(self.impl, alloc, o);
}

pub fn getUserLogOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getUserLogOwned(self.impl, alloc, o);
}

pub fn getUserDocumentsOwned(self: Locator, alloc: Allocator) DirsError![]const u8 {
    return self.vtable.v_getUserDocumentsOwned(self.impl, alloc);
}

pub fn getUserPicturesOwned(self: Locator, alloc: Allocator) DirsError![]const u8 {
    return self.vtable.v_getUserPicturesOwned(self.impl, alloc);
}

pub fn getUserVideosOwned(self: Locator, alloc: Allocator) DirsError![]const u8 {
    return self.vtable.v_getUserVideosOwned(self.impl, alloc);
}

pub fn getUserMusicOwned(self: Locator, alloc: Allocator) DirsError![]const u8 {
    return self.vtable.v_getUserMusicOwned(self.impl, alloc);
}

pub fn getUserDesktopOwned(self: Locator, alloc: Allocator) DirsError![]const u8 {
    return self.vtable.v_getUserDesktopOwned(self.impl, alloc);
}

pub fn getUserRuntimeOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getUserRuntimeOwned(self.impl, alloc, o);
}

pub fn getSiteRuntimeOwned(self: Locator, alloc: Allocator, o: *const Options) DirsError![]const u8 {
    return self.vtable.v_getSiteRuntimeOwned(self.impl, alloc, o);
}

