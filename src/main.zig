const raylib = @import("raylib");
const std = @import("std");

var historyList = std.ArrayList([16:0]u8);
var currentWord = std.ArrayList(u8);
var fullLabel = std.ArrayList(u8);

const Game = struct {
    counter: usize = 0,
    label: *const [6:0]u8 = "Word: ",
    indicator: *const [1:0]u8 = "_",
    historyList: *const *const [128:0]u8,
    fullString: *const *const [16:0]u8,

    fn tick(self: *Game) void {
        raylib.beginDrawing();
        defer raylib.endDrawing();

        setVars(self);
        draw(self);
    }

    fn incCounter(self: *Game) void {
        self.counter += 1;
    }

    fn setVars(self: *Game) void {
        const curKeyboardChar: u8 = @intCast(raylib.getCharPressed());
        const curKeyboardChar_string: [1:0]u8 = .{curKeyboardChar};

        if (self.counter % 100 < 50) {
            self.indicator = "_";
        } else if (self.counter % 100 <= 100) {
            self.indicator = " ";
        }

        // 16 = fullString.len;
        // 17 = label.len + indicator.len

        if ((curKeyboardChar >= 65 and curKeyboardChar <= 90) or
            (curKeyboardChar >= 97 and curKeyboardChar <= 122))
        {
            self.fullString = &(self.label ++ curKeyboardChar_string ++ .{0x0} ** (16 - 7));
        }

        self.fullString = &(self.label ++ currentWord[0.. :0] ++ self.indicator ++ .{0x0} ** (16 - 7));
        return;

        // var index: usize = 0;
        // for (string) |char| {
        //     self.fullString.*[index] = char.*;
        //     index += 1;
        // }
    }

    fn draw(self: *Game) void {
        raylib.clearBackground(raylib.Color.white);

        if (self.counter % 250 == 0) {
            std.debug.print("{s}\n", .{self.fullString.*[0.. :0]});
        }

        raylib.drawText(self.fullString.*[0.. :0], 190, 200, 20, raylib.Color.light_gray);
    }
};

fn init() void {
    const screenWidth = 800;
    const screenHeight = 450;
    raylib.initWindow(screenWidth, screenHeight, "Crookworm Declone");
    raylib.setTargetFPS(60);
}

pub fn main() !void {
    init();
    var tempInitializationList: [128:0]u8 = undefined;
    var tempInitializationList2: [16:0]u8 = undefined;

    const historyList: *const [128:0]u8 = listGen: {
        for (tempInitializationList, 0..) |_, idx| {
            tempInitializationList[idx] = undefined;
        }
        break :listGen &tempInitializationList;
    };

    const fullString: *const [16:0]u8 = listGen: {
        for (tempInitializationList2, 0..) |_, idx| {
            tempInitializationList2[idx] = undefined;
        }
        break :listGen &tempInitializationList2;
    };

    defer raylib.closeWindow();

    var game: Game = Game{
        .counter = 0,
        .historyList = &historyList,
        .fullString = &fullString,
    };

    while (!raylib.windowShouldClose()) : (game.incCounter()) {
        game.tick();
    }
}
