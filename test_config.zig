const std = @import("std");
const deps = @import("src/deps.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    std.debug.print("Testing configuration loading...\n", .{});
    
    // Initialize the dependency manager
    var dm = try deps.DependencyManager.init(allocator);
    defer dm.deinit();
    
    // Enable verbose output
    dm.setVerbose(true);
    
    // Try to load the test configuration
    dm.loadEnvironment("test_config.lua") catch |err| {
        std.debug.print("Error loading configuration: {any}\n", .{err});
        return err;
    };
    
    std.debug.print("Configuration loaded successfully!\n", .{});
}
