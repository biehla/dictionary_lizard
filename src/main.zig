const raylib = @import("raylib");
const std = @import("std");
const Game = @import("game.zig");

fn init_raylib() void {
    const screenWidth = 800;
    const screenHeight = 450;
    raylib.initWindow(screenWidth, screenHeight, "Crookworm Declone");
    raylib.setTargetFPS(60);
}

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = alloc.allocator();
    defer _ = alloc.deinit();

    var game = Game.init(allocator);
    defer game.destroy();

    init_raylib();
    defer raylib.closeWindow();

    while (!raylib.windowShouldClose()) { //: (game.incCounter()) {
        game.tick();
        // std.debug.print("a", .{});
    }
}
