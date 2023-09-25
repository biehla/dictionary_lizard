const raylib = @import("raylib");
const std = @import("std");

const string = std.ArrayList(u8);

pub const Game = struct {
    counter: usize = 0,
    label: *const [6]u8 = "Word: ",
    indicator: *const [1]u8 = "_",
    allocator: std.mem.Allocator,
    historyList: [5]string,
    name: [9:0]u8 = undefined,
    letterCount: usize = 0,

    pub fn tick(self: *Game) void {
        setVars(self) catch {
            std.log.warn("Umm this shouldn't happen\n", .{});
        };

        raylib.beginDrawing();
        draw(self);
        raylib.endDrawing();
    }

    fn setVars(self: *Game) !void {
        while (self.fullLabel.popOrNull() != null) continue;

        self.counter += 1;

        if (self.counter % 100 < 50) {
            self.indicator = "_";
        } else if (self.counter % 100 <= 100) {
            self.indicator = " ";
        }

        raylib.setMouseCursor(@intFromEnum(raylib.MouseCursor.mouse_cursor_ibeam));
        var key: u32 = @intCast(raylib.getCharPressed());
        while (key > 0) {
            if ((key >= 32) and (key <= 125) and (self.letterCount < self.name.len)) {
                self.name[self.letterCount] = @intCast(key);
                self.name[self.letterCount+1] = 0;
                self.letterCount += 1;
            }
            key = @intCast(raylib.getCharPressed());
        }
        
        if (raylib.isKeyPressed(.key_backspace) and self.letterCount != 0) {
            self.letterCount -= 1;
            self.name[self.letterCount] = 0;
            
            if (self.letterCount <= 0) {
                self.letterCount = 0;
            }
        }

        return;
    }

    fn draw(self: *Game) void {
        raylib.clearBackground(raylib.Color.white);

        var thing: [50]u8 = undefined;
        var counter: usize = 0;
        for (self.fullLabel.items, 0..) |i, idx| {
            if (i == 0 or i == undefined) break;
            thing[idx] = i;
            counter += 1;
        }
        thing[counter] = 0;

        raylib.drawText(self.name[0..self.letterCount-1 :0], 190, 200, 20, raylib.Color.light_gray);
    }

    pub fn destroy(self: *Game) void {
        for (self.historyList) |i| {
            i.deinit();
        }
        self.fullLabel.deinit();
        self.currentWord.deinit();
    }
};

pub fn init(allocator: std.mem.Allocator) Game {
    // var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    // const allocator = alloc.allocator();

    var historyList = .{string.init(allocator)} ** 5;
    var fullLabel = string.init(allocator);
    var currentWord = string.init(allocator);
    var game = Game{ .historyList = historyList, .fullLabel = fullLabel, .currentWord = currentWord, .allocator = allocator };
    return game;
}
