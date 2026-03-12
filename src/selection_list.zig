const std = @import("std");

const c = @cImport({
    @cInclude("selection_list.h");
});

var cb = c.SelectionListCallbacks{
    .Draw = draw,
    .SelectedItemChanged = selectedItemChanged,
    .ItemClicked = itemClicked,
    .DrawStaticElements = drawStaticElements,
    .ItemLongClicked = itemLongClicked,
    .ScrollPositionChanged = scrollPositionChanged,
};
var selection_list: ?*c.SelectionList = null;

fn mainHandler(event_type: c_int, param_one: c_int, param_two: c_int) callconv(.c) c_int {
    switch (event_type) {
        c.EVT_INIT => {
            const screen_rect = c.irect{
                .w = c.ScreenWidth(),
                .h = c.ScreenHeight(),
            };
            selection_list = c.SelectionList_Init(screen_rect, @ptrCast(&cb), null, 100);
            _ = c.SelectionList_SetItemcount(selection_list, 20);
            _ = c.SelectionList_UseDraggableScroller(selection_list, 1);
        },
        c.EVT_SHOW => {
            _ = c.SelectionList_Draw(selection_list);
            _ = c.SelectionList_Update(selection_list);
        },
        c.EVT_POINTERUP, c.EVT_POINTERDOWN, c.EVT_POINTERMOVE, c.EVT_POINTERLONG, c.EVT_POINTERHOLD, c.EVT_POINTERDRAG, c.EVT_POINTERCANCEL, c.EVT_POINTERCHANGED => {
            _ = c.SelectionList_HandleEvent(selection_list, event_type, param_one, param_two);
        },
        c.EVT_KEYPRESS => {
            c.SelectionList_Destroy(selection_list);
            c.CloseApp();
        },
        else => {},
    }

    return 0;
}

fn draw(_: ?*anyopaque, _: c_int, item_rect: c.irect, _: c_int, is_touched: c_int) callconv(.c) void {
    _ = c.FillArea(item_rect.x + 20, item_rect.y + 10, item_rect.w - 40, item_rect.h - 20, if (is_touched != 0) c.DGRAY else c.LGRAY);
}

fn selectedItemChanged(_: ?*anyopaque, _: c_int) callconv(.c) void {}

fn itemClicked(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn drawStaticElements(_: ?*anyopaque, _: c.irect) callconv(.c) void {}

fn itemLongClicked(_: ?*anyopaque, _: c_int, _: c_int, _: c_int) callconv(.c) void {}

fn scrollPositionChanged(_: ?*anyopaque, _: c_int, _: c_int) callconv(.c) void {}

pub fn main() !void {
    c.SetCurrentApplicationAttribute(c.APPLICATION_READER, 1); // hide context menu
    c.InkViewMain(mainHandler);
}
