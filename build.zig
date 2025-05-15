const std = @import("std");

fn addLuaIncludes(exe: *std.Build.Step.Compile) void {
    // Add C flags for include paths
    exe.addCSourceFiles(.{
        .files = &[_][]const u8{},
        .flags = &[_][]const u8{
            "-I/opt/homebrew/opt/lua/include",
        },
    });
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the executable
    const exe = b.addExecutable(.{
        .name = "pears",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Link against system Lua
    exe.linkSystemLibrary("lua5.4");
    exe.linkLibC();
    
    // Add Lua includes
    addLuaIncludes(exe);

    // Add deps.zig module
    const deps_module = b.createModule(.{
        .root_source_file = .{ .cwd_relative = "src/deps.zig" },
    });
    exe.root_module.addImport("deps", deps_module);

    // Link system libraries
    exe.linkLibC();
    
    // For macOS, link against required frameworks
    if (target.result.os.tag == .macos) {
        exe.linkFramework("Foundation");
        exe.linkFramework("AppKit");
        exe.linkFramework("SystemConfiguration");
    }
    
    // Install the executable
    b.installArtifact(exe);

    // Create run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    
    // Allow running with `zig build run -- <args>`
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
    
    // Add test step
    const test_step = b.step("test", "Run unit tests");
    const tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    // Link against system Lua for tests
    tests.linkSystemLibrary("lua5.4");
    tests.linkLibC();
    
    // Add Lua includes for tests
    addLuaIncludes(tests);
    
    const run_tests = b.addRunArtifact(tests);
    test_step.dependOn(&run_tests.step);
    
    // Add test config step
    const test_config = b.addExecutable(.{
        .name = "test_config",
        .root_source_file = .{ .cwd_relative = "test_config.zig" },
        .target = target,
        .optimize = optimize,
    });
    test_config.root_module.addImport("deps", deps_module);
    
    const run_test_config = b.addRunArtifact(test_config);
    run_test_config.step.dependOn(b.getInstallStep());
    
    const test_config_step = b.step("test-config", "Test the configuration loading");
    test_config_step.dependOn(&run_test_config.step);
    
    // Add test_pears step
    const test_pears = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "test_pears.zig" },
        .target = target,
        .optimize = optimize,
    });
    test_pears.root_module.addImport("deps", deps_module);
    
    const run_test_pears = b.addRunArtifact(test_pears);
    const test_pears_step = b.step("test-pears", "Run the pears tests");
    test_pears_step.dependOn(&run_test_pears.step);
    
    // Add test-all step
    const test_all = b.step("test-all", "Run all tests");
    test_all.dependOn(test_step);
    test_all.dependOn(test_pears_step);
    
    // Add run step for test_pears
    const run_test_pears_cmd = b.addRunArtifact(test_pears);
    run_test_pears_cmd.step.dependOn(b.getInstallStep());
    
    const run_test_pears_step = b.step("run-test-pears", "Run the pears test executable");
    run_test_pears_step.dependOn(&run_test_pears_cmd.step);
}
