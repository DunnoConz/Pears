const std = @import("std");
const deps = @import("deps");

pub fn main() !void {
    // Initialize the allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create a new dependency manager
    var dm = try deps.DependencyManager.init(allocator);
    defer dm.deinit();

    // Enable verbose output and dry-run mode
    dm.verbose = true;
    dm.dry_run = true;

    // Load and process the configuration
    std.debug.print("Starting Pears package installation (dry run)...\n\n", .{});
    
    // Load the configuration
    try dm.loadEnvironment("pears_config.lua");
    
    std.debug.print("\nDry run completed successfully!\n", .{});
    
    // Print installation summary
    std.debug.print("\nWould install {} packages:\n", .{dm.installation_order.items.len});
    for (dm.installation_order.items) |pkg| {
        std.debug.print("- {s}", .{pkg.name});
        if (pkg.version) |ver| {
            std.debug.print("@{s}", .{ver});
        }
        std.debug.print(" (via {s})\n", .{@tagName(pkg.manager)});
    }
}
