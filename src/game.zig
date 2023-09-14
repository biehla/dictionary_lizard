const raylib = @import("raylib");
const std = @import("std");

const string = std.ArrayList(u8);

pub const Game = struct {
    counter: usize = 0,
    label: *const [6]u8 = "Word: ",
    indicator: *const [1]u8 = "_",
    allocator: std.mem.Allocator,
    historyList: [5]string,
    fullLabel: string,
    currentWord: string,

    pub fn tick(self: *Game) void {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        setVars(self) catch {
            std.log.warn("Umm this shouldn't happen\n", .{});
        };
        draw(self);
    }

    fn setVars(self: *Game) !void {
        while (self.fullLabel.popOrNull() != null) continue;

        const curKeyboardChar: u8 = @intCast(raylib.getCharPressed());
        _ = curKeyboardChar;
        self.counter += 1;

        if (self.counter % 100 < 50) {
            self.indicator = "_";
        } else if (self.counter % 100 <= 100) {
            self.indicator = " ";
        }

        try self.fullLabel.appendSlice(self.label ++ self.indicator ++ .{0}); //catch |err| std.debug.print("Error: {!}\n", .{err});
        return;
    }

    fn draw(self: *Game) void {
        raylib.clearBackground(raylib.Color.white);

        var thing: [50]u8 = undefined;
        var counter: usize = 0;
        for (self.fullLabel.items, 0..) |i, idx| {
            if (i == undefined) break;
            thing[idx] = i;
            counter += 1;
        }
        thing[counter] = 0;

        raylib.drawText(thing[0..counter :0], 190, 200, 20, raylib.Color.light_gray);
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
