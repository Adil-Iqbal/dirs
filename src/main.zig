const std = @import("std");
const dirs = @import("dirs");
const builtin = @import("builtin");

pub fn main() !void {
    var buffer: [2048]u8 = undefined;
    var gpa = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = gpa.allocator();
    _ = try dirs.getUserHomeOwned(alloc);
}
