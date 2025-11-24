/// This file is intended for utility methods that may be used across all
/// objects that implement the `Locator` interface as well as `root.zig`. If
/// you have a helper method that is only intended for a specific operating
/// system, please place that method in the same file that contains the locator
/// for that operating system.

const std = @import("std");
const builtin = @import("builtin");
const testing = std.testing;

pub const MultipathIterator = std.mem.SplitIterator(u8, .scalar);

pub const SupportedOS = enum {
    windows,
    linux,
    freebsd,
    macos,
};

comptime {
    for (@typeInfo(SupportedOS).Enum.fields) |f| {
        if (!@hasField(std.Target.Os.Tag, f.name))
            @compileError("SupportedOS contains field not present in Os.Tag: " ++ f.name);
    }
}

/// Returns `SupportedOS` enumeration based on provided `tag`. If the tag
/// signifies an unsupported operating system, this method will return `null`.
pub fn getSupportedOS(tag: std.Target.Os.Tag) ?SupportedOS {
    inline for (@typeInfo(SupportedOS).Enum.fields) |f| {
        if (std.meta.eql(@field(std.Target.Os.Tag, f.name), tag))
            return @field(SupportedOS, f.name);
    }
    return null;
}

test "getSupportedOS is synchronized with SupportedOS" {
    inline for (@typeInfo(SupportedOS).Enum.fields) |f| {
        const tag = @field(std.Target.Os.Tag, f.name);
        const expected = @field(SupportedOS, f.name);
        try testing.expect(getSupportedOS(tag).? == expected);
    }
}

test "getSupportedOS returns null for unsupported OS tags" {
    inline for (@typeInfo(std.Target.Os.Tag).Enum.fields) |f| {
        const tag = @field(std.Target.Os.Tag, f.name);

        if (@hasField(SupportedOS, f.name)) {
            try testing.expect(getSupportedOS(tag) != null);
        } else {
            try testing.expect(getSupportedOS(tag) == null);
        }
    }
}

/// Iterate over a value returned by this library that may have multiple paths.
pub fn multipathIteratorExplicitDelimiter(paths: []const u8, delimiter: u8) MultipathIterator {
    return std.mem.splitScalar(u8, paths, delimiter);
}

test "test iterate over windows paths" {
    var it = multipathIteratorExplicitDelimiter("C:\\Windows;C:\\Program Files", std.fs.path.delimiter_windows);
    try testing.expectEqualStrings("C:\\Windows", it.next().?);
    try testing.expectEqualStrings("C:\\Program Files", it.next().?);
    try testing.expect(it.next() == null);
}

test "iterate over posix paths" {
    var it = multipathIteratorExplicitDelimiter("/etc:/usr/bin", std.fs.path.delimiter_posix);
    try testing.expectEqualStrings("/etc", it.next().?);
    try testing.expectEqualStrings("/usr/bin", it.next().?);
    try testing.expect(it.next() == null);
}

test "iterate over single path" {
    var it = multipathIteratorExplicitDelimiter("/etc", std.fs.path.delimiter_posix);
    try testing.expectEqualStrings("/etc", it.next().?);
    try testing.expect(it.next() == null);
}

test "iterate over empty slice" {
    var it = multipathIteratorExplicitDelimiter("", std.fs.path.delimiter_posix);
    try testing.expectEqualStrings("", it.next().?);
    try testing.expect(it.next() == null);
}

/// Returns true if `slice` contains `delimiter` byte.
fn isMultipathExplicitDelimiter(slice: []const u8, delimiter: u8) bool {
    return std.mem.indexOfScalar(u8, slice, delimiter) != null;
}

test "windows isMultipathExplicitDelimiter" {
    const delim = std.fs.path.delimiter_windows;
    const multipath = "C:\\Users;C:\\Program Files";
    const single_path = "C:\\Program Files";
    try testing.expect(isMultipathExplicitDelimiter(multipath, delim));
    try testing.expect(isMultipathExplicitDelimiter(single_path, delim));
}

test "posix isMultipathExplicitDelimiter" {
    const delim = std.fs.path.delimiter_posix;
    const multipath = "/usr:/etc";
    const single_path = "/usr";
    try testing.expect(isMultipathExplicitDelimiter(multipath, delim));
    try testing.expect(isMultipathExplicitDelimiter(single_path, delim));
}

/// Returns true if `slice` contains path delimiter byte. OS agnostic.
pub fn isMultipath(slice: []const u8) bool {
    return isMultipathExplicitDelimiter(slice, std.fs.path.delimiter);
}

/// Return true if path exists (even if we cannot access the path from this
/// program). Does not validate or handle case where `path` represents multiple
/// paths. Must not be exposed to library user to avoid race condition between
/// time-of-check and time-of-use.
pub fn singlePathExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch |err| switch (err) {
        error.NotDir, error.FileNotFound => return false,
        else => return true,
    };
    return true;
}

    


