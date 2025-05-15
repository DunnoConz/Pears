const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const process = std.process;
const fmt = std.fmt;
const Child = std.process.Child;
const fs = std.fs;
const os = std.os;

pub const MacSettings = struct {
    allocator: Allocator,
    verbose: bool = false,
    dock: ?Dock = null,
    window: ?Window = null,
    keyboard: ?Keyboard = null,
    security: ?Security = null,
    network: ?Network = null,
    apps: ?Apps = null,
    development: ?Development = null,
    backup: ?Backup = null,

    const Self = @This();

    /// Initialize a new MacSettings instance
    pub fn init(allocator: Allocator) Self {
        return .{
            .allocator = allocator,
        };
    }

    /// Run an AppleScript command
    fn runAppleScript(self: *const Self, script: []const u8) !void {
        var args = [_][]const u8{ "osascript", "-e", script };
        try self.runCommand(&args);
    }

    /// Run a shell command
    fn runCommand(self: *const Self, argv: []const []const u8) !void {
        if (self.verbose) {
            std.debug.print("Running: {s}\n", .{std.mem.join(self.allocator, " ", argv) catch return});
        }

        var child = Child.init(argv, self.allocator);
        child.stdout_behavior = .Inherit;
        child.stderr_behavior = .Inherit;

        const term = try child.spawnAndWait();
        switch (term) {
            .Exited => |code| if (code != 0) return error.CommandFailed,
            else => return error.CommandFailed,
        }
    }

    // System Preferences
    pub const SystemPreferences = struct {
        parent: *const Self,

        pub const Appearance = enum {
            light,
            dark,
            auto,
        };

        pub fn setAppearance(self: *@This(), appearance: Appearance) !void {
            const script = switch (appearance) {
                .light => "tell app \"System Events\" to tell appearance preferences to set dark mode to false",
                .dark => "tell app \"System Events\" to tell appearance preferences to set dark mode to true",
                .auto => "tell app \"System Events\" to tell appearance preferences to set dark mode to not dark mode",
            };
            try self.parent.runAppleScript(script);
        }

        pub fn setNightShift(self: *@This(), enabled: bool) !void {
            const value = if (enabled) "true" else "false";
            try self.parent.runCommand(&[_][]const u8{ "defaults", "write", "com.apple.controlcenter", "NSStatusItem Visible NightShift", "-bool", value });
        }
    };

    // Dock Settings
    pub const Position = enum { left, bottom, right };

    pub const Dock = struct {
        parent: *const Self,

        pub fn setAutoHide(self: *@This(), enabled: bool) !void {
            const value = if (enabled) "true" else "false";
            try self.parent.runCommand(&[_][]const u8{ "defaults", "write", "com.apple.dock", "autohide", "-bool", value });
            try self.parent.runCommand(&[_][]const u8{ "killall", "Dock" });
        }

        pub fn setPosition(self: *@This(), position: Position) !void {
            const pos = switch (position) {
                .left => "left",
                .bottom => "bottom",
                .right => "right",
            };
            try self.parent.runCommand(&[_][]const u8{ "defaults", "write", "com.apple.dock", "orientation", "-string", pos });
            try self.parent.runCommand(&[_][]const u8{ "killall", "Dock" });
        }
    };

    // Window Management
    pub const Window = struct {
        parent: *const Self,

        pub fn enableWindowSnapping(self: *@This(), enabled: bool) !void {
            const value = if (enabled) "1" else "0";
            try self.parent.runCommand(&[_][]const u8{ "defaults", "write", "com.apple.dock", "mru-spaces", "-bool", value });
            try self.parent.runCommand(&[_][]const u8{ "killall", "Dock" });
        }
    };

    // Keyboard Settings
    pub const Keyboard = struct {
        parent: *const Self,

        pub fn setKeyRepeat(self: *@This(), delay: u32, rate: u32) !void {
            try self.parent.runCommand(&[_][]const u8{ 
                "defaults", "write", "NSGlobalDomain", "InitialKeyRepeat", "-int", 
                std.fmt.allocPrint(self.parent.allocator, "{}", .{delay}) catch return 
            });
            try self.parent.runCommand(&[_][]const u8{ 
                "defaults", "write", "NSGlobalDomain", "KeyRepeat", "-int", 
                std.fmt.allocPrint(self.parent.allocator, "{}", .{rate}) catch return 
            });
        }
    };

    // Security & Privacy
    pub const Security = struct {
        parent: *const Self,

        pub fn setFirewall(self: *@This(), enabled: bool) !void {
            const value = if (enabled) "on" else "off";
            try self.parent.runCommand(&[_][]const u8{ "sudo", "/usr/libexec/ApplicationFirewall/socketfilterfw", "--setglobalstate", value });
        }
    };

    // Network Settings
    pub const Network = struct {
        parent: *const Self,

        pub fn setWiFiPower(self: *@This(), on: bool) !void {
            const state = if (on) "on" else "off";
            try self.parent.runCommand(&[_][]const u8{ "networksetup", "-setairportpower", "airport", state });
        }
    };

    // App Management
    pub const Apps = struct {
        parent: *const Self,

        pub fn addLoginItem(self: *@This(), appPath: []const u8) !void {
            const script = try std.fmt.allocPrint(
                self.parent.allocator,
                "tell application \"System Events\" to make login item at end with properties {{path:\"{s}\", hidden:false}}",
                .{appPath}
            );
            defer self.parent.allocator.free(script);
            try self.parent.runCommand(&[_][]const u8{ "osascript", "-e", script });
        }

        pub fn removeLoginItem(self: *@This(), appName: []const u8) !void {
            const script = try std.fmt.allocPrint(
                self.parent.allocator,
                "tell application \"System Events\" to delete login item \"{s}\"",
                .{appName}
            );
            defer self.parent.allocator.free(script);
            try self.parent.runCommand(&[_][]const u8{ "osascript", "-e", script });
        }
    };

    // Development Tools
    pub const Development = struct {
        parent: *const Self,

        pub fn installXcodeCLI(self: *@This()) !void {
            try self.parent.runCommand(&[_][]const u8{ "xcode-select", "--install" });
        }

        pub fn installHomebrew(self: *@This()) !void {
            try self.parent.runCommand(&[_][]const u8{ 
                "/bin/bash", "-c", 
                "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 
            });
        }
    };

    // Backup & Sync
    pub const Backup = struct {
        parent: *const Self,

        pub fn backupDotfiles(self: *@This(), destDir: []const u8) !void {
            const dotfiles = [_][:0]const u8{ 
                ".zshrc", ".gitconfig", ".vimrc", ".config/nvim/init.vim" 
            };
            
            try fs.cwd().makePath(destDir);
            const home = std.process.getEnvVarOwned(self.parent.allocator, "HOME") catch return error.HomeNotSet;
            defer self.parent.allocator.free(home);
            
            for (dotfiles) |file| {
                const src_path = try fs.path.join(self.parent.allocator, &[_][]const u8{home, file});
                defer self.parent.allocator.free(src_path);
                
                const dest_path = try fs.path.join(self.parent.allocator, &[_][]const u8{destDir, file});
                defer self.parent.allocator.free(dest_path);
                
                // Ensure destination directory exists
                if (std.mem.lastIndexOfScalar(u8, file, '/')) |last_slash| {
                    const dir = file[0..last_slash];
                    const full_dir = try fs.path.join(self.parent.allocator, &[_][]const u8{destDir, dir});
                    try fs.cwd().makePath(full_dir);
                }
                
                // Copy file if it exists
                fs.cwd().access(src_path, .{}) catch |err| {
                    if (err != error.FileNotFound) return err;
                    continue;
                };
                
                try fs.cwd().copyFile(src_path, fs.cwd(), dest_path, .{});
            }
        }
    };
};
