const std = @import("std");
const util = @import("util");
const Options = @import("options.zig");
const DirsError = @import("error.zig").DirsError;
const Allocator = std.mem.Allocator;

const Self = @This();

const AllocError = std.mem.Error;
const SelfExePathError = std.fs.SelfExePathError | AllocError;
const GetEnvVarOwnedError = std.process.GetEnvVarOwnedError;

getEnvVarOwned: *fn (Allocator, []const u8) GetEnvVarOwnedError![]const u8 = std.process.getEnvVarOwned,
selfExePathAlloc: *fn (Allocator) SelfExePathError!u8 = std.fs.selfExePathAlloc,
unixUserHomeOwned: *fn (Allocator) DirsError![]const u8 = util.unixUserHomeOwned,


