const std = @import("std");
const builtin = @import("builtin");
const deps = @import("deps.zig");
const lua_module = @import("lua.zig");
const mac = if (builtin.os.tag == .macos) @import("mac/config.zig") else struct {
    pub const Config = struct {
        pub fn init(allocator: std.mem.Allocator, lua_state: anytype) !@This() {
            _ = allocator;
            _ = lua_state;
            return @This();
        }
        pub fn deinit(self: *@This()) void { _ = self; }
        pub fn load(self: *@This()) !void { _ = self; }
    };
};

const Command = enum {
    help,
    install,
    activate,
    list,
    update,
    remove,
    unknown,

    pub fn fromString(str: []const u8) Command {
        if (std.mem.eql(u8, str, "help")) return .help;
        if (std.mem.eql(u8, str, "install")) return .install;
        if (std.mem.eql(u8, str, "activate")) return .activate;
        if (std.mem.eql(u8, str, "list")) return .list;
        if (std.mem.eql(u8, str, "update")) return .update;
        if (std.mem.eql(u8, str, "remove")) return .remove;
        return .unknown;
    }
};

fn printInstallHelp() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll(
        \\Usage: pears install [environment] [options]
        \\
        \\Install packages for the specified environment.
        \\
        \\Options:
        \\  -c, --config <path>    Path to the configuration file (default: pears.lua)
        \\  -v, --verbose         Show verbose output
        \\  -n, --dry-run         Show what would be installed without making changes
        \\  -h, --help            Show this help message
        \\
        \\If no environment is specified, all environments will be installed.
        \\
    );
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    
    // Initialize Lua
    const L = lua_module.luaL_newstate() orelse return error.LuaInitFailed;
    defer lua_module.lua_close(L);
    lua_module.luaL_openlibs(L);
    
    // Load our module
    const result = lua_module.luaopen_pears(L);
    if (result != 1) {
        std.debug.print("Failed to load pears module\n", .{});
        return error.LuaModuleError;
    }
    lua_module.lua_settop(L, 0);  // Clear the stack
    
    // Test Lua integration
    const test_code = "require('pears').hello()\nprint(\"Lua code executed successfully\")";
    
    // Execute test code
    if (lua_module.luaL_loadbufferx(L, test_code, test_code.len, "test", null) != 0) {
        const err = lua_module.lua_tolstring(L, -1, null) orelse "Unknown error";
        std.debug.print("Error loading Lua code: {s}\n", .{err});
        return error.LuaError;
    }
    
    if (lua_module.lua_pcallk(L, 0, 0, 0, 0, null) != 0) {
        const err = lua_module.lua_tolstring(L, -1, null) orelse "Unknown error";
        std.debug.print("Error executing Lua code: {s}\n", .{err});
        return error.LuaError;
    }
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Lua state is already initialized above
    
    // Load and execute the configuration file
    const config_file_path = "pears_config.lua";
    if (lua_module.luaL_loadfilex(L, config_file_path.ptr, null) != 0) {
        const err = lua_module.lua_tolstring(L, -1, null) orelse "Unknown error";
        std.debug.print("Error loading config file: {s}\n", .{err});
        return error.ConfigError;
    }
    
    if (lua_module.lua_pcallk(L, 0, 0, 0, 0, null) != 0) {
        const err = lua_module.lua_tolstring(L, -1, null) orelse "Unknown error";
        std.debug.print("Error executing config file: {s}\n", .{err});
        return error.ConfigError;
    }
    
    // Initialize Mac settings if on macOS
    var mac_config = try mac.Config.init(allocator, L);
    defer mac_config.deinit();
    
    // Load Mac settings
    try mac_config.load();

    if (args.len == 1) {
        // No arguments, show help
        try printHelp();
        return;
    }

    const command = if (args.len > 1) Command.fromString(args[1]) else .help;

    // Initialize dependency manager
    var dep_manager = try deps.DependencyManager.init(allocator);
    defer dep_manager.deinit();

    // Process command
    switch (command) {
        .help => {
            try printHelp();
        },
        .install => {
            var env_name: ?[]const u8 = null;
            var config_path: ?[]const u8 = "pears.lua";
            var verbose = false;
            var dry_run = false;
            
            // Parse options
            var i: usize = 2; // Skip program name and command
            while (i < args.len) : (i += 1) {
                const arg = args[i];
                if (std.mem.eql(u8, arg, "-c") or std.mem.eql(u8, arg, "--config")) {
                    i += 1;
                    if (i >= args.len) {
                        std.debug.print("Error: Missing argument for {s}\n", .{arg});
                        return error.MissingArgument;
                    }
                    config_path = args[i];
                } else if (std.mem.eql(u8, arg, "-v") or std.mem.eql(u8, arg, "--verbose")) {
                    verbose = true;
                    dep_manager.verbose = true;
                } else if (std.mem.eql(u8, arg, "-n") or std.mem.eql(u8, arg, "--dry-run")) {
                    dry_run = true;
                    dep_manager.dry_run = true;
                } else if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
                    try printInstallHelp();
                    lua_module.lua_getglobal(L, "_VERSION");
                    const version = lua_module.lua_tolstring(L, -1, null) orelse "unknown";
                    std.debug.print("Lua version: {s}\n", .{version});
                    lua_module.lua_pop(L, 1);  // Remove the version string from the stack
                    return;
                } else if (env_name == null) {
                    env_name = arg;
                } else {
                    std.debug.print("Unexpected argument: {s}\n", .{arg});
                    return error.InvalidArgument;
                }
            }
            
            if (env_name) |env| {
                dep_manager.env_name = env;
            }
            
            if (verbose) {
                // Handle optional config_path
                const config_file = config_path orelse "pears.lua";
                try stdout.print("Using config file: {s}\n", .{config_file});
                if (env_name) |env| {
                    try stdout.print("Installing environment: {s}\n", .{env});
                } else {
                    try stdout.print("Installing all environments\n", .{});
                }
            }
            
            try dep_manager.loadEnvironment(config_path orelse "pears.lua");
            
            if (verbose) {
                try stdout.print("\nInstallation completed successfully!\n", .{});
                
                // Print installation summary
                try stdout.print("\nInstalled {} packages:\n", .{dep_manager.installation_order.items.len});
                for (dep_manager.installation_order.items) |pkg| {
                    try stdout.print("- {s}", .{pkg.name});
                    if (pkg.version) |ver| {
                        try stdout.print("@{s}", .{ver});
                    }
                    try stdout.print(" (via {s})\n", .{@tagName(pkg.manager)});
                }
            } else {
                try stdout.print("Done. Installed {} packages.\n", .{dep_manager.installation_order.items.len});
            }
        },
        .activate => {
            if (args.len < 3) {
                try stdout.print("Error: Missing environment name\n", .{});
                try stdout.print("Usage: pears activate [environment_name]\n", .{});
                return;
            }
            try stdout.print("Activating environment '{s}'...\n", .{args[2]});
            // TODO: Implement environment activation
            try stdout.print("Environment activation not yet implemented.\n", .{});
        },
        .list => {
            try stdout.print("Available environments:\n", .{});
            // TODO: Implement environment listing
            try stdout.print("Environment listing not yet implemented.\n", .{});
        },
        .update => {
            if (args.len < 3) {
                try stdout.print("Error: Missing environment name\n", .{});
                try stdout.print("Usage: pears update [environment_name]\n", .{});
                return;
            }
            try stdout.print("Updating environment '{s}'...\n", .{args[2]});
            // TODO: Implement environment update
            try stdout.print("Environment updating not yet implemented.\n", .{});
        },
        .remove => {
            if (args.len < 3) {
                try stdout.print("Error: Missing environment name\n", .{});
                try stdout.print("Usage: pears remove [environment_name]\n", .{});
                return;
            }
            try stdout.print("Removing environment '{s}'...\n", .{args[2]});
            // TODO: Implement environment removal
            try stdout.print("Environment removal not yet implemented.\n", .{});
        },
        .unknown => {
            try stdout.print("Unknown command: {s}\n", .{args[1]});
            try printHelp();
        },
    }
}

fn printHelp() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.writeAll(
        \\Pears - Package Manager for Development Environments
        \\
        \\Usage: pears [command] [options]
        \\
        \\Commands:
        \\  install [env]    Install packages for an environment
        \\  activate [env]   Activate an environment
        \\  list            List available environments
        \\  update [env]    Update packages in an environment
        \\  remove [env]    Remove an environment
        \\  help            Show this help message
        \\
        \\Options:
        \\  -v, --verbose   Show verbose output
        \\  -n, --dry-run   Show what would be done without making changes
        \\  -h, --help      Show help for a command
        \\
        \\Run 'pears help <command>' for more information on a command.
        \\
        \\Examples:
        \\  pears install dev      # Install development environment
        \\  pears activate dev     # Activate the dev environment
        \\  pears list            # List all environments
        \\
    );
}

test "basic test" {
    const allocator = std.testing.allocator;
    _ = allocator;
    try std.testing.expect(true);
}
