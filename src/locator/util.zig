/// This file is intended for utility methods that may be used across all
/// objects that implement the `Locator` interface as well as `root.zig`. If
/// you have a helper method that is only intended for a specific operating
/// system, please place that method in the same file that contains the locator
/// for that operating system.

const std = @import("std");
const builtin = @import("builtin");
const c = @cImport({
    @cInclude("pwd.h");
});

const path = std.fs.path;
const testing = std.testing;
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;

const expect = testing.expect;
const expectEqualStrings = testing.expectEqualStrings;
const expectError = testing.expectError;

const Options = @import("options.zig");
const DirsError = @import("error.zig");

pub const MultipathIterator = std.mem.SplitIterator(u8, .scalar);

pub const SupportedOS = enum {
    windows,
    linux,
    freebsd,
    macos,
};

comptime {
    for (std.enums.values(SupportedOS)) |f| {
        if (!@hasField(std.Target.Os.Tag, f.name))
            @compileError("SupportedOS contains field not present in Os.Tag: " ++ f.name);
    }
}

/// Returns `SupportedOS` enumeration based on provided `tag`. If the tag
/// signifies an unsupported operating system, this method will return `null`.
pub fn getSupportedOS(tag: std.Target.Os.Tag) ?SupportedOS {
    inline for (std.enums.values(SupportedOS)) |f| {
        if (std.meta.eql(@field(std.Target.Os.Tag, f.name), tag))
            return @field(SupportedOS, f.name);
    }
    return null;
}

test "getSupportedOS is synchronized with SupportedOS" {
    inline for (std.enums.values(SupportedOS)) |f| {
        const tag = @field(std.Target.Os.Tag, f.name);
        const expected = @field(SupportedOS, f.name);
        try expect(getSupportedOS(tag).? == expected);
    }
}

test "getSupportedOS returns null for unsupported OS tags" {
    inline for (@typeInfo(std.Target.Os.Tag).Enum.fields) |f| {
        const tag = @field(std.Target.Os.Tag, f.name);

        if (@hasField(SupportedOS, f.name)) {
            try expect(getSupportedOS(tag) != null);
        } else {
            try expect(getSupportedOS(tag) == null);
        }
    }
}

/// Iterate over a value returned by this library that may have multiple paths.
pub fn multipathIteratorExplicitDelimiter(paths: []const u8, delimiter: u8) MultipathIterator {
    return std.mem.splitScalar(u8, paths, delimiter);
}

test "test iterate over windows paths" {
    var it = multipathIteratorExplicitDelimiter("C:\\Windows;C:\\Program Files", std.fs.path.delimiter_windows);
    try expectEqualStrings("C:\\Windows", it.next().?);
    try expectEqualStrings("C:\\Program Files", it.next().?);
    try expect(it.next() == null);
}

test "iterate over posix paths" {
    var it = multipathIteratorExplicitDelimiter("/etc:/usr/bin", std.fs.path.delimiter_posix);
    try expectEqualStrings("/etc", it.next().?);
    try expectEqualStrings("/usr/bin", it.next().?);
    try expect(it.next() == null);
}

test "iterate over single path" {
    var it = multipathIteratorExplicitDelimiter("/etc", std.fs.path.delimiter_posix);
    try expectEqualStrings("/etc", it.next().?);
    try expect(it.next() == null);
}

test "iterate over empty slice" {
    var it = multipathIteratorExplicitDelimiter("", std.fs.path.delimiter_posix);
    try expectEqualStrings("", it.next().?);
    try expect(it.next() == null);
}

/// Returns true if `slice` contains `delimiter` byte.
fn isMultipathExplicitDelimiter(slice: []const u8, delimiter: u8) bool {
    return std.mem.indexOfScalar(u8, slice, delimiter) != null;
}

test "windows isMultipathExplicitDelimiter" {
    const delim = std.fs.path.delimiter_windows;
    const multipath = "C:\\Users;C:\\Program Files";
    const single_path = "C:\\Program Files";
    try expect(isMultipathExplicitDelimiter(multipath, delim));
    try expect(isMultipathExplicitDelimiter(single_path, delim));
}

test "posix isMultipathExplicitDelimiter" {
    const delim = std.fs.path.delimiter_posix;
    const multipath = "/usr:/etc";
    const single_path = "/usr";
    try expect(isMultipathExplicitDelimiter(multipath, delim));
    try expect(isMultipathExplicitDelimiter(single_path, delim));
}

/// Returns true if `slice` contains path delimiter byte. OS agnostic.
pub fn isMultipath(slice: []const u8) bool {
    return isMultipathExplicitDelimiter(slice, std.fs.path.delimiter);
}

test "test isMultipath" {
    const contains_delim = "abc" ++ [_]u8{std.fs.path.delimiter} ++ "def";
    const no_delim = "abcdef";
    const empty = "";
    const only_delim = [_]u8{std.fs.path.delimiter};

    try expect(isMultipath(contains_delim));
    try expect(isMultipath(only_delim));
    try expect(!isMultipath(no_delim));
    try expect(!isMultipath(empty));
}

/// Return true if path exists (even if we cannot access the path from this
/// program). Does not validate or handle case where `path` represents multiple
/// paths. Must not be exposed to library user to avoid race condition between
/// time-of-check and time-of-use.
pub fn singlePathExists(spath: []const u8) bool {
    std.fs.cwd().access(spath, .{}) catch |err| switch (err) {
        error.NotDir, error.FileNotFound => return false,
        else => return true,
    };
    return true;
}

/// Joins `base_path` with `app_name` and `version` from options if they are present.
/// Allocates memory for the result. Caller owns the returned slice.
fn appendNameAndVersion(alloc: Allocator, base_path: []const u8, o: *const Options) ![]const u8 {
    var parts: ArrayList([]const u8) = .empty;
    defer parts.deinit(alloc);

    try parts.append(alloc, base_path);
    if (!isNullOrBlank(o.app_name)) {
        try parts.append(alloc, o.app_name.?);
        if (!isNullOrBlank(o.version)) {
            try parts.append(alloc, o.version.?);
        }
    }

    return try path.join(alloc, parts.items);
}

test "appendNameAndVersion name and version are appended" {
    const alloc = std.testing.allocator;
    const base = "/base";
    const o: Options = .{
        .app_name = "app",
        .version = "1.0.3",
    };
    const expected = "/base/app/1.0.3";
    const actual = appendNameAndVersion(alloc, base, o);
    defer alloc.free(actual);
    try expectEqualStrings(expected, actual);
}

test "appendNameAndVersion if name only, name is appended" {
    const alloc = std.testing.allocator;
    const base = "/base";
    const o: Options = .{
        .app_name = "app",
        .version = null,
    };
    const expected = "/base/app";
    const actual = appendNameAndVersion(alloc, base, o);
    defer alloc.free(actual);
    try expectEqualStrings(expected, actual);
}

test "appendNameAndVersion if ver only, neither is appended" {
    const alloc = std.testing.allocator;
    const base = "/base";
    const o: Options = .{
        .app_name = null,
        .version = "1.0.3",
    };
    const expected = base;
    const actual = appendNameAndVersion(alloc, base, o);
    defer alloc.free(actual);
    try expectEqualStrings(expected, actual);
}

test "appendNameAndVersion if neither, neither is appended" {
    const alloc = std.testing.allocator;
    const base = "/base";
    const o: Options = .{
        .app_name = null,
        .version = null,
    };
    const expected = base;
    const actual = appendNameAndVersion(alloc, base, o);
    defer alloc.free(actual);
    try expectEqualStrings(expected, actual);
}

test "appendNameAndVersion returns error correctly" {
    const alloc = std.testing.failing_allocator;
    const base = "/base";
    const o: Options = .{
        .app_name = "app",
        .version = "1.0.3",
    };
    try expectError(error.OutOfMemory, appendNameAndVersion(alloc, base, o));
}

/// Returns true if slice is null, empty, or whitespace only.
pub fn isNullOrBlank(s: ?[]const u8) bool {
    return s == null or isBlank(s.?);
}

test "isNullOrBlank" {
    try expect(isNullOrBlank(null));
    try expect(isNullOrBlank(""));
    try expect(isNullOrBlank("\t "));
    try expect(!isNullOrBlank("abc"));
}

/// Returns true if slice is empty or whitespace only.
pub fn isBlank(s: []const u8) bool {
    if (s.len == 0) return true;
    const trimmed = std.mem.trim(u8, s, &std.ascii.whitespace);
    return trimmed.len == 0;
}

test "isBlank" {
    try expect(isBlank(""));
    try expect(isBlank("\t "));
    try expect(!isBlank("abc"));
}

/// Retrieves the current user's home directory from /etc/passwd
/// Allocates memory for the result. Caller owns the returned slice.
pub fn unixUserHomeOwned(alloc: Allocator) DirsError![]const u8 {
    const uid = std.posix.getuid();
    if (c.getpwuid(uid)) |passwd| {
        if (passwd.*.pw_dir) |dir_ptr| {
            const dir_span = std.mem.span(dir_ptr);
            if (!isBlank(dir_span)) {
                return try alloc.dupe(u8, dir_span);
            }
        }
    }

    return DirsError.OperationFailed;
}

/// Splits a multipath string by delimiter, appends name/version to each part, and rejoins them.
/// Allocates memory for the result. Caller owns the returned slice.
fn transformMultipath(alloc: Allocator, path_str: []const u8, o: *const Options) DirsError![]const u8 {
    var result_parts: ArrayList(u8) = .empty;
    defer result_parts.deinit(alloc);

    var it = multipathIteratorExplicitDelimiter(path_str, std.fs.path.delimiter);
    var first = true;

    while (it.next()) |dir| {
        if (isBlank(dir)) continue;
        if (!first) try result_parts.append(alloc, std.fs.path.delimiter);
        first = false;

        const full_path = try appendNameAndVersion(alloc, dir, o);
        defer alloc.free(full_path);
        try result_parts.appendSlice(alloc, full_path);
    }

    if (result_parts.items.len == 0)
        return DirsError.OperationFailed;
    
    return result_parts.toOwnedSlice(alloc);
}

/// Returns the first valid component of a multipath string, with name/version appended.
/// Allocates memory for the result. Caller owns the returned slice.
fn getFirstPath(alloc: Allocator, path_str: []const u8, o: *const Options) DirsError![]const u8 {
    var it = multipathIteratorExplicitDelimiter(path_str, std.fs.path.delimiter);

    while (it.next()) |dir| {
        if (isBlank(dir)) continue;
        return appendNameAndVersion(alloc, dir, o) catch continue;
    }

    return DirsError.OperationFailed;
}


