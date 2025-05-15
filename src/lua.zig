const std = @import("std");

pub const luaL_Reg = extern struct {
    name: [*:0]const u8,
    func: ?*const fn (L: ?*lua_State) callconv(.C) c_int,
};

pub const lua_State = opaque {};

pub extern fn luaL_loadbufferx(L: ?*lua_State, buff: [*]const u8, sz: usize, name: [*:0]const u8, mode: ?[*:0]const u8) c_int;
pub extern fn luaL_newstate() ?*lua_State;
pub extern fn luaL_openlibs(L: ?*lua_State) void;
pub extern fn luaL_requiref(L: ?*lua_State, modname: [*:0]const u8, openf: ?*const fn (L: ?*lua_State) callconv(.C) c_int, glb: c_int) void;
pub extern fn luaL_setfuncs(L: ?*lua_State, l: [*]const luaL_Reg, nup: c_int) void;
pub extern fn lua_createtable(L: ?*lua_State, narr: c_int, nrec: c_int) void;

pub extern fn lua_settop(L: ?*lua_State, idx: c_int) void;
pub extern fn lua_pushcfunction(L: ?*lua_State, f: ?*const fn (L: ?*lua_State) callconv(.C) c_int) void;
pub extern fn lua_setfield(L: ?*lua_State, idx: c_int, k: [*:0]const u8) void;
pub extern fn lua_pushvalue(L: ?*lua_State, idx: c_int) void;

pub extern fn luaL_loadfilex(L: ?*lua_State, filename: [*:0]const u8, mode: ?[*:0]const u8) c_int;
pub extern fn lua_pcallk(L: ?*lua_State, nargs: c_int, nresults: c_int, msgh: c_int, ctx: c_int, k: ?*const fn (L: ?*lua_State, status: c_int, ctx: c_int) callconv(.C) c_int) c_int;

pub extern fn lua_tolstring(L: ?*lua_State, idx: c_int, len: ?*usize) ?[*:0]const u8;

pub extern fn lua_getglobal(L: ?*lua_State, name: [*:0]const u8) void;
pub extern fn lua_pcall(L: ?*lua_State, nargs: c_int, nresults: c_int, errfunc: c_int) c_int;
pub extern fn lua_pop(L: ?*lua_State, n: c_int) void;
pub extern fn lua_close(L: ?*lua_State) void;
pub extern fn lua_isnil(L: ?*lua_State, idx: c_int) c_int;
pub extern fn lua_istable(L: ?*lua_State, idx: c_int) c_int;
pub extern fn lua_isboolean(L: ?*lua_State, idx: c_int) c_int;
pub extern fn lua_isstring(L: ?*lua_State, idx: c_int) c_int;
pub extern fn lua_isnumber(L: ?*lua_State, idx: c_int) c_int;
pub extern fn lua_rawgeti(L: ?*lua_State, idx: c_int, n: c_int) c_int;
pub extern fn lua_getfield(L: ?*lua_State, idx: c_int, k: [*:0]const u8) c_int;
pub extern fn lua_toboolean(L: ?*lua_State, idx: c_int) c_int;
pub extern fn lua_tonumberx(L: ?*lua_State, idx: c_int, isnum: ?*c_int) f64;

pub export fn luaopen_pears(L: ?*lua_State) c_int {
    const l = L orelse return 0;
    
    // Create a table for our module
    lua_createtable(l, 0, 0);
    
    // Register our functions
    const funcs = [_]luaL_Reg{
        .{ .name = "hello", .func = hello },
        .{ .name = @as([*:0]const u8, @ptrCast("\x00")), .func = null },
    };
    luaL_setfuncs(l, &funcs, 0);
    
    // Set the module name
    lua_pushvalue(l, -1);
    lua_setfield(l, -10002, "pears");
    
    return 1;
}

export fn hello(L: ?*lua_State) callconv(.C) c_int {
    _ = L orelse return 0;
    const stdout = std.io.getStdOut().writer();
    stdout.print("Hello from Zig!\n", .{}) catch {};
    return 0;
}
