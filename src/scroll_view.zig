const std = @import("std");

const c = @cImport({
    @cInclude("scrollview.h");
});

const side_length: c_int = 200;

var content_handler = c.ScrollView_Content{
    .Draw = draw,
    .ProcessEvent = processEvent,
    .DrawStaticElements = drawStaticElements,
};
var scroll_view: ?*c.ScrollView = null;

fn mainHandler(event_type: c_int, param_one: c_int, param_two: c_int) callconv(.c) c_int {
    switch (event_type) {
        c.EVT_INIT => {
            const screen_rect = c.irect{
                .w = c.ScreenWidth(),
                .h = c.ScreenHeight(),
            };
            scroll_view = c.ScrollView_Init(screen_rect, @ptrCast(&content_handler), null, 0);
            _ = c.ScrollView_SetContentSize(scroll_view, c.ScreenWidth() * 2 - side_length, c.ScreenHeight() * 2 - side_length);
            _ = c.ScrollView_SetViewport(scroll_view, @divTrunc(c.ScreenWidth() - side_length, 2), @divTrunc(c.ScreenHeight() - side_length, 2));
        },
        c.EVT_SHOW => {
            _ = c.ScrollView_Draw(scroll_view);
            _ = c.ScrollView_Update(scroll_view);
        },
        c.EVT_POINTERUP, c.EVT_POINTERDOWN, c.EVT_POINTERMOVE, c.EVT_POINTERLONG, c.EVT_POINTERHOLD, c.EVT_POINTERDRAG, c.EVT_POINTERCANCEL, c.EVT_POINTERCHANGED => {
            _ = c.ScrollView_HandleEvent(scroll_view, event_type, param_one, param_two);
        },
        c.EVT_KEYPRESS => {
            c.ScrollView_Destroy(scroll_view);
            c.CloseApp();
        },
        else => {},
    }

    return 0;
}

fn draw(_: ?*anyopaque, content_rect: c.irect, to_x: c_int, to_y: c_int) callconv(.c) void {
    const x = to_x - content_rect.x - side_length + c.ScreenWidth();
    const y = to_y - content_rect.y - side_length + c.ScreenHeight();
    c.FillArea(x, y, side_length, side_length, c.LGRAY);
}

fn processEvent(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn drawStaticElements(_: ?*anyopaque, _: c.irect) callconv(.c) void {}

pub fn main() !void {
    c.SetCurrentApplicationAttribute(c.APPLICATION_READER, 1); // hide context menu
    c.InkViewMain(mainHandler);
}
