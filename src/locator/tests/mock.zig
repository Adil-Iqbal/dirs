const std = @import("std");
const DirsError = @import("../error.zig").DirsError;
const Allocator = std.mem.Allocator;
const GetEnvVarOwnedError = std.process.GetEnvVarOwnedError;
const Self = @This();

pub const unix_usr_home = "/usr/jdoe";
pub const unix_usr_home2 = "/usr/jdoe/fallback";

pub fn getEnvVarOwned_success_home(_: Allocator, _: []const u8) GetEnvVarOwnedError![]u8 {
    return unix_usr_home;   
}

pub fn getEnvVarOwned_failure(_: Allocator, _:[]const u8) GetEnvVarOwnedError![]u8 {
    return GetEnvVarOwnedError.EnvironmentVariableNotFound;
}

pub fn unixGetUserHomeOwned_success(_: Allocator) DirsError![]const u8 {
    return Self.mock_usr_home;
}

pub fn unixGetUserHomeOwned_failure(_: Allocator) DirsError![]const u8 {
    return DirsError.OutOfMemory;
}

