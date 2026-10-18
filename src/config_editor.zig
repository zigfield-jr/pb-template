const std = @import("std");
const iv = @import("inkview");

var ce: []iv.iconfigedit = undefined;
var cfg: ?*iv.iconfig = null;

var title_height: c_int = 0;

var home: ?*iv.ibitmap = null;
var home_inv: ?*iv.ibitmap = null;
const home_rect = iv.irect{ .x = 33, .y = 6, .w = 110, .h = 110 };

fn mainHandler(event_type: c_int, param_one: c_int, param_two: c_int) callconv(.c) c_int {
    switch (event_type) {
        iv.EVT_INIT => {
            const properties = iv.LoadApplicationCaptionProperties();
            if (properties != null and properties.*.is_active > 0) {
                title_height = @intCast(properties.*.title_height);
                home = iv.GetResource("home", null);
                home_inv = iv.GetResource("home_inv", null);
            }

            const ce_array = [_]iv.iconfigedit{
                iv.iconfigedit{
                    .type = iv.CFG_FONTFACE,
                    .icon = iv.GetResource("font_settings", null),
                    .text = std.heap.c_allocator.dupeSentinel(u8, "font settings", 0) catch undefined,
                    .name = std.heap.c_allocator.dupeSentinel(u8, "font_settings", 0) catch undefined,
                    .deflt = std.heap.c_allocator.dupeSentinel(u8, "DejaVuSans.ttf", 0) catch undefined,
                },
                iv.iconfigedit{
                    .type = iv.CFG_NUMBER,
                    .icon = iv.GetResource("font_size", null),
                    .text = std.heap.c_allocator.dupeSentinel(u8, "font size", 0) catch undefined,
                    .name = std.heap.c_allocator.dupeSentinel(u8, "font_size", 0) catch undefined,
                    .deflt = std.heap.c_allocator.dupeSentinel(u8, "42", 0) catch undefined,
                },
            };

            ce = std.heap.page_allocator.dupe(iv.iconfigedit, ce_array[0..]) catch undefined; // FIXME use c_allocator

            const path = std.fs.path.join(std.heap.c_allocator, &[_][]const u8{ iv.CONFIGPATH, "template.cfg" }) catch undefined;
            defer std.heap.c_allocator.free(path);

            const path_cstring = std.heap.c_allocator.dupeSentinel(u8, path[0..], 0) catch undefined;
            defer std.heap.c_allocator.free(path_cstring);

            cfg = iv.OpenConfig(path_cstring, ce.ptr);
        },
        iv.EVT_SHOW, iv.EVT_CONFIGCHANGED => {
            iv.ClearScreen();
            if( title_height > 0) {
                iv.DrawBitmap(home_rect.x, home_rect.y, home);
                _ = iv.DrawHorizontalSeparator(0, title_height - 1, iv.ScreenWidth(), iv.HORIZONTAL_SEPARATOR_SOLID);
            }
            iv.FullUpdate();
        },
        iv.EVT_POINTERDOWN => {
            if (title_height > 0 and iv.IsInRect(param_one, param_two, &home_rect) > 0) {
                iv.DrawBitmap(home_rect.x, home_rect.y, home_inv);
                iv.PartialUpdate(home_rect.x, home_rect.y, home_rect.w, home_rect.h);
                iv.CloseApp();
                return 0;
            }
            iv.OpenConfigEditor("config editor", cfg, ce.ptr, @ptrCast(&configHandler), &itemChangeHandler);
        },
        iv.EVT_KEYPRESS => {
            switch (param_one) {
                iv.IV_KEY_MENU => {
                    iv.CloseConfig(cfg);
                    iv.CloseApp();
                },
                iv.IV_KEY_NEXT => {},
                iv.IV_KEY_PREV => {},
                else => {},
            }
        },
        else => {},
    }

    return 0;
}

fn configHandler() callconv(.c) void {
    iv.NotifyConfigChanged();
}

fn itemChangeHandler(_: [*c]u8) callconv(.c) void {}

pub fn main() !void {
    iv.SetCurrentApplicationAttribute(iv.APPLICATION_READER, 1); // hide context menu
    iv.InkViewMain(mainHandler);
}
