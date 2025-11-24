const std = @import("std");
const testing = std.testing;

pub const MultiPathIterator = std.mem.SplitIterator(u8, .scalar);

/// Iterate over a value returned by this library that may have multiple paths.
pub fn multiPathIteratorExplicitDelimiter(paths: []const u8, delimiter: u8) MultiPathIterator {
    return std.mem.splitScalar(u8, paths, delimiter);
}

test "test iterate over windows paths" {
    var it = multiPathIteratorExplicitDelimiter("C:\\Windows;C:\\Program Files", std.fs.path.delimiter_windows);
    try testing.expectEqualStrings("C:\\Windows", it.next().?);
    try testing.expectEqualStrings("C:\\Program Files", it.next().?);
    try testing.expect(it.next() == null);
}

test "iterate over posix paths" {
    var it = multiPathIteratorExplicitDelimiter("/etc:/usr/bin", std.fs.path.delimiter_posix);
    try testing.expectEqualStrings("/etc", it.next().?);
    try testing.expectEqualStrings("/usr/bin", it.next().?);
    try testing.expect(it.next() == null);
}

test "iterate over single path" {
    var it = multiPathIteratorExplicitDelimiter("/etc", std.fs.path.delimiter_posix);
    try testing.expectEqualStrings("/etc", it.next().?);
    try testing.expect(it.next() == null);
}

test "iterate over empty slice" {
    var it = multiPathIteratorExplicitDelimiter("", std.fs.path.delimiter_posix);
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
    const multipath = "/usr;/etc";
    const single_path = "/usr";
    try testing.expect(isMultipathExplicitDelimiter(multipath, delim));
    try testing.expect(isMultipathExplicitDelimiter(single_path, delim));
}

/// Returns true if `slice` contains path delimiter. OS agnostic.
pub fn isMultiPath(slice: []const u8) bool {
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




