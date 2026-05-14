const std = @import("std");
const iv = @import("inkview");

var font: [*c]iv.ifont = null;

fn mainHandler(event_type: c_int, _: c_int, _: c_int) callconv(.c) c_int {
    switch (event_type) {
        iv.EVT_INIT => {
            font = iv.OpenFont("LiberationSans", 40, 1);
            iv.SetFont(font, iv.BLACK);
        },
        iv.EVT_SHOW => {
            iv.ClearScreen();
            _ = iv.DrawTextRect(0, 0, iv.ScreenWidth(), iv.ScreenHeight(), "Hello, world!", iv.ALIGN_CENTER | iv.VALIGN_MIDDLE);
            iv.FullUpdate();
        },
        iv.EVT_KEYPRESS => {
            iv.CloseFont(font);
            iv.CloseApp();
        },
        else => {},
    }

    return 0;
}

pub fn main() !void {
    iv.SetCurrentApplicationAttribute(iv.APPLICATION_READER, 1); // hide context menu
    iv.InkViewMain(mainHandler);
}
