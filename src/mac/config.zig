const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const process = std.process;
const fs = std.fs;
const path = std.fs.path;

const lua = @import("../lua.zig");
const settings = @import("./settings.zig");

pub const Config = struct {
    allocator: Allocator,
    lua_state: ?*lua.lua_State,
    mac_settings: *settings.MacSettings,

    const Self = @This();

    pub fn init(allocator: Allocator, lua_state: ?*lua.lua_State) !Self {
        const mac_settings = try allocator.create(settings.MacSettings);
        mac_settings.* = settings.MacSettings.init(allocator);
        
        return Self{
            .allocator = allocator,
            .lua_state = lua_state,
            .mac_settings = mac_settings,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.destroy(self.mac_settings);
    }

    pub fn load(self: *Self) !void {
        // Initialize MacSettings
        self.mac_settings.* = settings.MacSettings.init(self.allocator);
        
        // If no Lua state is provided, skip loading from Lua
        const L = self.lua_state orelse return;
        
        // Load the Lua configuration
        lua.lua_getglobal(L, "mac_settings");
        
        if (lua.lua_isnil(L, -1) == 0) {
            try self.loadSystemPreferences();
            try self.loadDockSettings();
            try self.loadWindowSettings();
            try self.loadKeyboardSettings();
            try self.loadSecuritySettings();
            try self.loadNetworkSettings();
            try self.loadLoginItems();
            try self.loadDevelopmentSettings();
            try self.loadBackupSettings();
        }
        
        lua.lua_pop(L, 1); // Pop the mac_settings table
    }

    fn loadSystemPreferences(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "system_preferences");
        if (lua.lua_istable(L, -1) == 1) {
            
            // Load appearance
            _ = lua.lua_getfield(L, -1, "appearance");
            if (lua.lua_isstring(L, -1) == 1) {
                const appearance_cstr = lua.lua_tolstring(L, -1, null) orelse return error.InvalidAppearance;
                const appearance_str = std.mem.span(appearance_cstr);
                const appearance = std.meta.stringToEnum(
                    settings.MacSettings.SystemPreferences.Appearance, 
                    appearance_str
                ) orelse return error.InvalidAppearance;
                var prefs_appearance = settings.MacSettings.SystemPreferences{ .parent = self.mac_settings };
                try prefs_appearance.setAppearance(appearance);
            }
            _ = lua.lua_pop(L, 1); // Pop appearance
            
            // Night shift
            _ = lua.lua_getfield(L, -1, "night_shift");
            if (lua.lua_istable(L, -1) == 1) {
                _ = lua.lua_getfield(L, -1, "enabled");
                if (lua.lua_isboolean(L, -1) == 1) {
                    const night_shift = lua.lua_toboolean(L, -1) == 1;
                    var prefs_night = settings.MacSettings.SystemPreferences{ .parent = self.mac_settings };
                    try prefs_night.setNightShift(night_shift);
                }
                _ = lua.lua_pop(L, 1); // Pop the enabled value
            }
            _ = lua.lua_pop(L, 1); // Pop the night_shift table
        }
        _ = lua.lua_pop(L, 1); // Pop the system_preferences table
    }

    fn loadDockSettings(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "dock");
        if (lua.lua_istable(L, -1) == 1) {
            var dock = settings.MacSettings.Dock{ .parent = self.mac_settings };
            
            // Auto-hide
            _ = lua.lua_getfield(L, -1, "auto_hide");
            if (lua.lua_isboolean(L, -1) == 1) {
                const auto_hide = lua.lua_toboolean(L, -1) == 1;
                try dock.setAutoHide(auto_hide);
            }
            _ = lua.lua_pop(L, 1); // Pop the auto_hide value
            
            // Position
            _ = lua.lua_getfield(L, -1, "position");
            if (lua.lua_isstring(L, -1) == 1) {
                const position_cstr = lua.lua_tolstring(L, -1, null) orelse return error.InvalidDockPosition;
                const position_str = std.mem.span(position_cstr);
                const position = std.meta.stringToEnum(settings.MacSettings.Position, position_str) orelse return error.InvalidDockPosition;
                try dock.setPosition(position);
            }
            _ = lua.lua_pop(L, 1); // Pop position
            
            // Store the dock settings in the MacSettings struct
            self.mac_settings.dock = dock;
        }
        _ = lua.lua_pop(L, 1); // Pop the dock table
    }

    fn loadWindowSettings(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "window");
        if (lua.lua_istable(L, -1) == 1) {
            var window = settings.MacSettings.Window{ .parent = self.mac_settings };
            
            // Enable window snapping
            _ = lua.lua_getfield(L, -1, "enable_snapping");
            if (lua.lua_isboolean(L, -1) == 1) {
                const enable_snapping = lua.lua_toboolean(L, -1) == 1;
                try window.enableWindowSnapping(enable_snapping);
            }
            _ = lua.lua_pop(L, 1); // Pop the enable_snapping value
            
            // Store the window settings in the MacSettings struct
            self.mac_settings.window = window;
        }
        _ = lua.lua_pop(L, 1); // Pop the window table
    }

    fn loadKeyboardSettings(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "keyboard");
        if (lua.lua_istable(L, -1) == 1) {
            var keyboard = settings.MacSettings.Keyboard{ .parent = self.mac_settings };
            
            // Key repeat rate
            _ = lua.lua_getfield(L, -1, "key_repeat");
            if (lua.lua_istable(L, -1) == 1) {
                _ = lua.lua_getfield(L, -1, "delay");
                if (lua.lua_isnumber(L, -1) == 1) {
                    const delay = @as(u32, @intFromFloat(lua.lua_tonumberx(L, -1, null)));
                    _ = lua.lua_pop(L, 1); // Pop delay
                    
                    _ = lua.lua_getfield(L, -1, "rate");
                    if (lua.lua_isnumber(L, -1) == 1) {
                        const rate = @as(u32, @intFromFloat(lua.lua_tonumberx(L, -1, null)));
                        try keyboard.setKeyRepeat(delay, rate);
                    }
                    _ = lua.lua_pop(L, 1); // Pop rate
                } else {
                    _ = lua.lua_pop(L, 1); // Pop delay
                }
            }
            _ = lua.lua_pop(L, 1); // Pop key_repeat
            
            // Store the keyboard settings in the MacSettings struct
            self.mac_settings.keyboard = keyboard;
        }
        _ = lua.lua_pop(L, 1); // Pop keyboard
    }

    fn loadSecuritySettings(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "security");
        if (lua.lua_istable(L, -1) == 1) {
            var security = settings.MacSettings.Security{ .parent = self.mac_settings };
            
            // Firewall
            _ = lua.lua_getfield(L, -1, "firewall_enabled");
            if (lua.lua_isboolean(L, -1) == 1) {
                try security.setFirewall(lua.lua_toboolean(L, -1) == 1);
            }
            _ = lua.lua_pop(L, 1); // Pop firewall_enabled
            
            // Store the security settings in the MacSettings struct
            self.mac_settings.security = security;
        }
        _ = lua.lua_pop(L, 1); // Pop security
    }

    fn loadNetworkSettings(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "network");
        if (lua.lua_istable(L, -1) == 1) {
            var network = settings.MacSettings.Network{ .parent = self.mac_settings };
            
            // Wi-Fi power
            _ = lua.lua_getfield(L, -1, "wifi_power");
            if (lua.lua_isboolean(L, -1) == 1) {
                const enabled = lua.lua_toboolean(L, -1) == 1;
                try network.setWiFiPower(enabled);
            }
            _ = lua.lua_pop(L, 1); // Pop wifi_power
            
            // Store the network settings in the MacSettings struct
            self.mac_settings.network = network;
            
            // Network locations
            _ = lua.lua_getfield(L, -1, "network_locations");
            if (lua.lua_istable(L, -1) == 1) {
                // Handle network locations
            }
            _ = lua.lua_pop(L, 1); // Pop network_locations
            self.mac_settings.network = network;
        }
        _ = lua.lua_pop(L, 1); // Pop network
    }

    fn loadLoginItems(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "login_items");
        if (lua.lua_istable(L, -1) == 1) {
            var apps = settings.MacSettings.Apps{ .parent = self.mac_settings };
            
            // Add login items
            _ = lua.lua_getfield(L, -1, "add");
            if (lua.lua_istable(L, -1) == 1) {
                var i: usize = 1;
                while (true) {
                    _ = lua.lua_rawgeti(L, -1, @as(i32, @intCast(i)));
                    if (lua.lua_isnil(L, -1) == 1) {
                        _ = lua.lua_pop(L, 1); // Pop nil
                        break;
                    }
                    const app_path_ptr = lua.lua_tolstring(L, -1, null) orelse return error.InvalidAppPath;
                    const app_path = std.mem.span(app_path_ptr);
                    try apps.addLoginItem(app_path);
                    _ = lua.lua_pop(L, 1); // Pop app path
                    i += 1;
                }
            }
            _ = lua.lua_pop(L, 1); // Pop add
            
            // Remove login items
            _ = lua.lua_getfield(L, -1, "remove");
            if (lua.lua_istable(L, -1) == 1) {
                var i: usize = 1;
                while (true) {
                    _ = lua.lua_rawgeti(L, -1, @as(i32, @intCast(i)));
                    if (lua.lua_isnil(L, -1) == 1) {
                        _ = lua.lua_pop(L, 1); // Pop nil
                        break;
                    }
                    const app_name_ptr = lua.lua_tolstring(L, -1, null) orelse return error.InvalidAppName;
                    const app_name = std.mem.span(app_name_ptr);
                    try apps.removeLoginItem(app_name);
                    _ = lua.lua_pop(L, 1); // Pop app name
                    i += 1;
                }
            }
            _ = lua.lua_pop(L, 1); // Pop remove
            
            // Store the apps settings in the MacSettings struct
            self.mac_settings.apps = apps;
        }
        _ = lua.lua_pop(L, 1); // Pop login_items
    }

    fn loadDevelopmentSettings(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "development");
        if (lua.lua_istable(L, -1) == 1) {
            var dev = settings.MacSettings.Development{ .parent = self.mac_settings };
            
            // Install Xcode CLI tools
            _ = lua.lua_getfield(L, -1, "install_xcode_cli");
            if (lua.lua_isboolean(L, -1) == 1) {
                try dev.installXcodeCLI();
            }
            _ = lua.lua_pop(L, 1); // Pop install_xcode_cli
            
            // Install Homebrew
            _ = lua.lua_getfield(L, -1, "install_homebrew");
            if (lua.lua_isboolean(L, -1) == 1) {
                try dev.installHomebrew();
            }
            _ = lua.lua_pop(L, 1); // Pop install_homebrew
            
            // Store the development settings in the MacSettings struct
            self.mac_settings.development = dev;
        }
        _ = lua.lua_pop(L, 1); // Pop development
    }

    fn loadBackupSettings(self: *Self) !void {
        const L = self.lua_state orelse return;
        _ = lua.lua_getfield(L, -1, "backup");
        if (lua.lua_istable(L, -1) == 1) {
            var backup = settings.MacSettings.Backup{ .parent = self.mac_settings };
            
            // Dotfiles backup
            _ = lua.lua_getfield(L, -1, "dotfiles_dir");
            if (lua.lua_isstring(L, -1) == 1) {
                const dotfiles_dir_ptr = lua.lua_tolstring(L, -1, null) orelse return error.InvalidDotfilesDir;
                const dotfiles_dir = std.mem.span(dotfiles_dir_ptr);
                try backup.backupDotfiles(dotfiles_dir);
            }
            _ = lua.lua_pop(L, 1); // Pop dotfiles_dir
        }
        _ = lua.lua_pop(L, 1); // Pop backup
    }
};
