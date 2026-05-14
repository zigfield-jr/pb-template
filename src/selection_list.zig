const std = @import("std");
const iv = @import("inkview");

var cb = iv.SelectionListCallbacks{
    .Draw = draw,
    .SelectedItemChanged = selectedItemChanged,
    .ItemClicked = itemClicked,
    .DrawStaticElements = drawStaticElements,
    .ItemLongClicked = itemLongClicked,
    .ScrollPositionChanged = scrollPositionChanged,
};
var selection_list: ?*iv.SelectionList = null;

fn mainHandler(event_type: c_int, param_one: c_int, param_two: c_int) callconv(.c) c_int {
    switch (event_type) {
        iv.EVT_INIT => {
            const screen_rect = iv.irect{
                .w = iv.ScreenWidth(),
                .h = iv.ScreenHeight(),
            };
            selection_list = iv.SelectionList_Init(screen_rect, @ptrCast(&cb), null, 100);
            _ = iv.SelectionList_SetItemcount(selection_list, 20);
            _ = iv.SelectionList_UseDraggableScroller(selection_list, 1);
        },
        iv.EVT_SHOW => {
            _ = iv.SelectionList_Draw(selection_list);
            _ = iv.SelectionList_Update(selection_list);
        },
        iv.EVT_POINTERUP, iv.EVT_POINTERDOWN, iv.EVT_POINTERMOVE, iv.EVT_POINTERLONG, iv.EVT_POINTERHOLD, iv.EVT_POINTERDRAG, iv.EVT_POINTERCANCEL, iv.EVT_POINTERCHANGED => {
            _ = iv.SelectionList_HandleEvent(selection_list, event_type, param_one, param_two);
        },
        iv.EVT_KEYPRESS => {
            iv.SelectionList_Destroy(selection_list);
            iv.CloseApp();
        },
        else => {},
    }

    return 0;
}

fn draw(_: ?*anyopaque, _: c_int, item_rect: iv.irect, _: c_int, is_touched: c_int) callconv(.c) void {
    _ = iv.FillArea(item_rect.x + 20, item_rect.y + 10, item_rect.w - 40, item_rect.h - 20, if (is_touched != 0) iv.DGRAY else iv.LGRAY);
}

fn selectedItemChanged(_: ?*anyopaque, _: c_int) callconv(.c) void {}

fn itemClicked(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn drawStaticElements(_: ?*anyopaque, _: iv.irect) callconv(.c) void {}

fn itemLongClicked(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn scrollPositionChanged(_: ?*anyopaque, _: c_int, _: c_int) callconv(.c) void {}

pub fn main() !void {
    iv.SetCurrentApplicationAttribute(iv.APPLICATION_READER, 1); // hide context menu
    iv.InkViewMain(mainHandler);
}
