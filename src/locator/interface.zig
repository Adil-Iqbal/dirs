const Locator = @This();

const std = @import("std");
const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;

const VTable = struct {
    v_userData: *const fn(*const anyopaque, *const Options) DirsError![]const u8,
    v_siteData: *const fn(*const anyopaque, *const Options) DirsError![]const u8,
    v_userConfig: *const fn(*const anyopaque, *const Options) DirsError![]const u8, 
    v_siteConfig: *const fn(*const anyopaque, *const Options) DirsError![]const u8, 
    v_userCache: *const fn(*const anyopaque, *const Options) DirsError![]const u8, 
    v_siteCache: *const fn(*const anyopaque, *const Options) DirsError![]const u8, 
    v_userState: *const fn(*const anyopaque, *const Options) DirsError![]const u8, 
    v_userLog: *const fn(*const anyopaque, *const Options) DirsError![]const u8, 
    v_userDocuments: *const fn(*const anyopaque) DirsError![]const u8, 
    v_userPictures: *const fn(*const anyopaque) DirsError![]const u8, 
    v_userVideos: *const fn(*const anyopaque) DirsError![]const u8, 
    v_userMusic: *const fn(*const anyopaque) DirsError![]const u8, 
    v_userDesktop: *const fn(*const anyopaque) DirsError![]const u8, 
    v_userRuntime: *const fn(*const anyopaque, *const Options) DirsError![]const u8, 
    v_siteRuntime: *const fn(*const anyopaque, *const Options) DirsError![]const u8,
};

impl: *const anyopaque,
vtable: *const VTable,

inline fn LocatorDelegate(impl_obj: anytype) type {
    const ImplType = @TypeOf(impl_obj);
    return struct {
        fn userData(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).userData(o);
        }

        fn siteData(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).siteData(o);
        }

        fn userConfig(impl: *const anyopaque, o: *const Options) DirsError![]const u8 {
            return TPtr(ImplType, impl).userConfig(o);
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
    };
}


fn TPtr(T: type, opaque_ptr: *const anyopaque) T {
    return @as(T, @ptrCast(@alignCast(opaque_ptr)));
}

pub fn implBy(impl_obj: anytype) Locator {
    const delegate = LocatorDelegate(impl_obj);
    const vtable: VTable = .{
        .v_userData = delegate.userData,
        .v_siteData = delegate.siteData,
        .v_userConfig = delegate.userConfig, 
        .v_siteConfig = delegate.siteConfig, 
        .v_userCache = delegate.userCache, 
        .v_siteCache = delegate.siteCache, 
        .v_userState = delegate.userState, 
        .v_userLog = delegate.userLog, 
        .v_userDocuments = delegate.userDocuments, 
        .v_userPictures = delegate.userPictures, 
        .v_userVideos = delegate.userVideos, 
        .v_userMusic = delegate.userMusic, 
        .v_userDesktop = delegate.userDesktop, 
        .v_userRuntime = delegate.userRuntime, 
        .v_siteRuntime = delegate.siteRuntime,
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


