const dirs = @import("dirs");
const builtin = @import ("builtin");

pub fn main() !void {
    _ = dirs.init(builtin.target.os.tag);
    _ = dirs.WinLocator{};
}
