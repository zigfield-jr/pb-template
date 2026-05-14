const std = @import("std");
const iv = @import("inkview");

const side_length: c_int = 200;

var content_handler = iv.ScrollView_Content{
    .Draw = draw,
    .ProcessEvent = processEvent,
    .DrawStaticElements = drawStaticElements,
};
var scroll_view: ?*iv.ScrollView = null;

fn mainHandler(event_type: c_int, param_one: c_int, param_two: c_int) callconv(.c) c_int {
    switch (event_type) {
        iv.EVT_INIT => {
            const screen_rect = iv.irect{
                .w = iv.ScreenWidth(),
                .h = iv.ScreenHeight(),
            };
            scroll_view = iv.ScrollView_Init(screen_rect, @ptrCast(&content_handler), null, 0);
            _ = iv.ScrollView_SetContentSize(scroll_view, iv.ScreenWidth() * 2 - side_length, iv.ScreenHeight() * 2 - side_length);
            _ = iv.ScrollView_SetViewport(scroll_view, @divTrunc(iv.ScreenWidth() - side_length, 2), @divTrunc(iv.ScreenHeight() - side_length, 2));
        },
        iv.EVT_SHOW => {
            _ = iv.ScrollView_Draw(scroll_view);
            _ = iv.ScrollView_Update(scroll_view);
        },
        iv.EVT_POINTERUP, iv.EVT_POINTERDOWN, iv.EVT_POINTERMOVE, iv.EVT_POINTERLONG, iv.EVT_POINTERHOLD, iv.EVT_POINTERDRAG, iv.EVT_POINTERCANCEL, iv.EVT_POINTERCHANGED => {
            _ = iv.ScrollView_HandleEvent(scroll_view, event_type, param_one, param_two);
        },
        iv.EVT_KEYPRESS => {
            iv.ScrollView_Destroy(scroll_view);
            iv.CloseApp();
        },
        else => {},
    }

    return 0;
}

fn draw(_: ?*anyopaque, content_rect: iv.irect, to_x: c_int, to_y: c_int) callconv(.c) void {
    const x = to_x - content_rect.x - side_length + iv.ScreenWidth();
    const y = to_y - content_rect.y - side_length + iv.ScreenHeight();
    iv.FillArea(x, y, side_length, side_length, iv.LGRAY);
}

fn processEvent(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn drawStaticElements(_: ?*anyopaque, _: iv.irect) callconv(.c) void {}

pub fn main() !void {
    iv.SetCurrentApplicationAttribute(iv.APPLICATION_READER, 1); // hide context menu
    iv.InkViewMain(mainHandler);
}
