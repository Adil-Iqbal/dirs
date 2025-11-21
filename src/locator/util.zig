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


