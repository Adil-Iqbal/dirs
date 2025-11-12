const std = @import("std");

pub const Env = enum {
    XDG_DATA_HOME,

    pub fn get(self: Env) []const u8 {
        return std.os.getenv(@tagName(self));
    }
};

