const std = @import("std");

const c = @cImport({
    @cInclude("inkview.h");
});

const font_size: c_int = 40;

var font: [*c]c.ifont = null;

fn mainHandler(event_type: c_int, _: c_int, _: c_int) callconv(.c) c_int {
    switch (event_type) {
        c.EVT_INIT => {
            font = c.OpenFont("LiberationSans", font_size, 1);
            c.SetFont(font, c.BLACK);
        },
        c.EVT_SHOW => {
            c.ClearScreen();
            _ = c.DrawTextRect(0, 0, c.ScreenWidth(), c.ScreenHeight(), "Hello, world!", c.ALIGN_CENTER | c.VALIGN_MIDDLE);
            c.FullUpdate();
        },
        c.EVT_KEYPRESS => {
            c.CloseFont(font);
            c.CloseApp();
        },
        else => {},
    }

    return 0;
}

pub fn main() !void {
    c.SetCurrentApplicationAttribute(c.APPLICATION_READER, 1); // hide context menu
    c.InkViewMain(mainHandler);
}
