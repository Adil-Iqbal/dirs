const std = @import("std");
const dirs = @import("dirs");
const builtin = @import ("builtin");

pub fn main() !void {
    const gpa = std.heap.FixedBufferAllocator(.{}){};
    const alloc = gpa.allocator();
    _ = dirs.init(builtin.target.os.tag);
    _ = dirs.getUserHomeOwned(alloc);
}

