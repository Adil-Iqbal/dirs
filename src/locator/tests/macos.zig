const std = @import("std");

const mock = @import("mock.zig");
const Loc = @import("../macos.zig");
const DirsError = @import("../error.zig").DirsError;
const Options = @import("../options.zig");
const testing = std.testing;
const Allocator = std.mem.Allocator;

const expect = std.testing.expect;
const expectEqualString = std.testing.expectEqualString;
const expectError = std.testing.expectError;

test "getUserHomeOwned success" {
    const alloc = std.testing.allocator;
    const loc: Loc = .{
        .getEnvVarOwned = mock.getEnvVarOwned_success_home,
    };
    const actual = try loc.getUserHomeOwned(alloc);
    try expectEqualString(mock.unix_usr_home, actual);
}

test "getUserHomeOwned fallback" {
    const alloc: Allocator = std.testing.allocator;
    const loc: Loc = .{
        .getEnvVarOwned = mock.getEnvVarOwned_failure,
        .unixGetUserHomeOwned = mock.unixGetUserHomeOwned_success,
    };
    const actual = try loc.getUserHomeOwned(alloc);
    try expectEqualString(mock.unix_usr_home2, actual);
}

test "getUserHomeOwned failure" {
    const alloc: Allocator = std.testing.allocator;
    const loc: Loc = .{
        .getEnvVarOwned = mock.getEnvVarOwned_failure,
        .unixGetUserHomeOwned = mock.unixGetUserHomeOwned_failure,
    };
    _ = loc.getUserHomeOwned(alloc) catch |err| {
        expectError(DirsError.OutOfMemory, err);
    };
}




