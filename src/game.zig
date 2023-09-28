const raylib = @import("raylib");
const std = @import("std");

const string = std.ArrayList(u8);

pub const Game = struct {
    counter: usize = 0,
    label: *const [6]u8 = "Word: ",
    indicator: *const [1]u8 = "_",
    allocator: std.mem.Allocator,
    historyList: [5][11]u8 = undefined,
    historyListWordLen: [5]u8 = undefined,
    historyListLen: u8 = 0,
    name: [10]u8 = undefined,
    letterCount: u8 = 0,

    pub fn tick(self: *Game) void {
        setVars(self) catch {
            std.log.warn("Umm this shouldn't happen\n", .{});
        };

        raylib.beginDrawing();
        draw(self);
        raylib.endDrawing();
    }

    fn setVars(self: *Game) !void {
        self.counter += 1;

        if (self.counter % 100 < 50) {
            self.indicator = "_";
        } else if (self.counter % 100 <= 100) {
            self.indicator = " ";
        }

        raylib.setMouseCursor(@intFromEnum(raylib.MouseCursor.mouse_cursor_ibeam));
        var key: u32 = @intCast(raylib.getCharPressed());
        while (key > 0) {
            if ((key >= 32) and (key <= 125) and (self.letterCount < self.name.len) and self.letterCount < 9) {
                self.name[self.letterCount] = @intCast(key);
                self.name[self.letterCount + 1] = 0;
                self.letterCount += 1;
            }
            key = @intCast(raylib.getCharPressed());
        }

        if (raylib.isKeyPressed(.key_backspace) and self.letterCount != 0) {
            self.name[self.letterCount] = 0;
            self.letterCount -= 1;
            self.name[self.letterCount] = 0;

            if (self.letterCount <= 0) {
                self.letterCount = 0;
            }
        } else if (raylib.isKeyPressed(.key_enter) and self.letterCount >= 3) {
            for (self.name, 0..) |_, idx| {
                self.historyList[self.historyListLen][idx] = self.name[idx];
            }
            self.historyList[self.historyListLen][self.letterCount + 1] = 0;
            self.historyListWordLen[self.historyListLen] = self.letterCount + 1;
            self.historyListLen += 1;
            self.name[0] = 0;
            self.letterCount = 0;
        }

        return;
    }

    fn draw(self: *Game) void {
        raylib.clearBackground(raylib.Color.white);

        if (self.historyListLen > 0) {
            for (self.historyList, 0..) |_, i| {
                if (i >= self.historyListLen) {
                    break;
                }
                // std.log.info("historyList[{d}] = {d}", .{ i, self.historyList[i] });
                raylib.drawText(self.historyList[i][0 .. self.historyListWordLen[i] + 0 :0], 100, @intCast(50 + (50 * i)), 20, raylib.Color.light_gray);
            }
        }
        if (self.letterCount != 0) {
            raylib.drawText(self.name[0..self.letterCount :0], 300, 200, 20, raylib.Color.light_gray);
        }
    }

    pub fn destroy(self: *Game) void {
        _ = self;
    }
};

pub fn init(allocator: std.mem.Allocator) Game {
    var historyList = .{string.init(allocator)} ** 5;
    _ = historyList;
    var game = Game{ .allocator = allocator };
    return game;
}
