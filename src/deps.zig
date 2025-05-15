const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const process = std.process;
const Thread = std.Thread;
const Mutex = Thread.Mutex;
const Condition = Thread.Condition;
const parallel = @import("parallel.zig");

// Maximum number of parallel package installations
const MAX_PARALLEL_INSTALLS = 4;

/// Git reference type (branch, tag, commit)
pub const GitRefType = enum {
    branch,
    tag,
    commit,
};

/// Git repository source
pub const GitSource = enum {
    github,
    gitlab,
    other,
};

/// Git reference information
pub const GitRef = struct {
    type: GitRefType,
    name: []const u8,
};

/// Represents a package manager
pub const PackageManager = enum {
    // System package managers
    brew,
    apt,
    dnf,
    pacman,
    
    // Language package managers
    cargo,
    npm,
    yarn,
    pip,
    pip3,
    go,
    gem,
    
    // Special sources
    app_store,
    custom,
    
    // Git-based sources
    git,
};

/// Git repository information
pub const GitRepo = struct {
    source: GitSource,
    owner: []const u8,
    repo: []const u8,
    ref: ?GitRef = null,
    subdir: ?[]const u8 = null,  // Subdirectory within the repository
};

/// Represents a dependency
pub const DependencyInfo = struct {
    name: []const u8,
    version: ?[]const u8 = null,
    manager: PackageManager,
    url: ?[]const u8 = null,
    options: ?[]const []const u8 = null,
    git: ?GitRepo = null,  // Git repository details (if manager is .git)
};

/// Manages system dependencies and packages
pub const DependencyManager = struct {
    const Self = @This();

    allocator: Allocator,
    env_name: ?[]const u8 = null,
    verbose: bool = false,
    dry_run: bool = false,
    max_parallel: usize = 4, // Default to 4 parallel tasks
    installing: std.StringHashMap(void),
    installed_packages: std.StringHashMap(void),
    installation_order: std.ArrayList(DependencyInfo),
    thread_pool: ?*parallel.ThreadPool = null,

    /// Initialize a new DependencyManager
    pub fn init(allocator: Allocator) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        self.* = .{
            .allocator = allocator,
            .installing = std.StringHashMap(void).init(allocator),
            .installed_packages = std.StringHashMap(void).init(allocator),
            .installation_order = std.ArrayList(DependencyInfo).init(allocator),
        };

        return self;
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        // Clean up thread pool if it exists
        if (self.thread_pool) |pool| {
            pool.deinit();
        }
        
        self.installing.deinit();
        self.installed_packages.deinit();
        self.installation_order.deinit();
        
        self.allocator.destroy(self);
    }

    /// Set verbose mode
    pub fn setVerbose(self: *Self, verbose: bool) void {
        self.verbose = verbose;
    }

    /// Set dry run mode
    pub fn setDryRun(self: *Self, dry_run: bool) void {
        self.dry_run = dry_run;
    }

    /// Install all dependencies in parallel
    pub fn installAll(self: *Self) !void {
        if (self.verbose) {
            std.debug.print("Installing all dependencies...\n", .{});
        }

        // Initialize thread pool if not already done
        if (self.thread_pool == null) {
            self.thread_pool = try parallel.ThreadPool.init(self.allocator, self.max_parallel);
        }
        const pool = self.thread_pool.?;

        // Create a task for each package
        for (self.installation_order.items) |dep| {
            // Create a task for this package
            const task = try self.allocator.create(parallel.Task);
            const name = try self.allocator.dupe(u8, dep.name);
            const version = if (dep.version) |v| try self.allocator.dupe(u8, v) else null;
            
            task.* = .{
                .runFn = struct {
                    fn run(task_ptr: *parallel.Task) void {
                        _ = task_ptr; // Unused
                        // Install the package
                        self.installPackage(dep.manager, name, version, dep.options) catch |err| {
                            std.debug.print("Failed to install {s}: {s}\n", .{ name, @errorName(err) });
                        };
                        // Free the allocated memory
                        self.allocator.free(name);
                        if (version) |v| self.allocator.free(v);
                    }
                }.run,
                .userdata = null,
            };
            
            try pool.submit(task);
        }
    }

    /// Run a shell command with the given arguments
    fn runCommand(self: *Self, comptime args: anytype) !void {
        // Convert the arguments to a slice of slices
        const argv: []const []const u8 = switch (@typeInfo(@TypeOf(args))) {
            .Struct => |info| if (info.is_tuple) blk: {
                const fields = info.fields;
                var argv_list: [fields.len][]const u8 = undefined;
                inline for (fields, 0..) |field, i| {
                    argv_list[i] = @field(args, field.name);
                }
                break :blk &argv_list;
            } else {
                @compileError("Expected a tuple type");
            },
            else => @compileError("Expected a tuple type"),
        };

        if (self.verbose) {
            const cmd_str = std.mem.join(self.allocator, " ", argv) catch |err| {
                std.debug.print("Failed to format command: {s}\n", .{@errorName(err)});
                return err;
            };
            defer self.allocator.free(cmd_str);
            std.debug.print("Running: {s}\n", .{cmd_str});
        }

        if (self.dry_run) return;

        var child = std.process.Child.init(argv, self.allocator);
        child.stdout_behavior = .Inherit;
        child.stderr_behavior = .Inherit;

        const term = try child.spawnAndWait();
        switch (term) {
            .Exited => |code| {
                if (code != 0) {
                    return error.CommandFailed;
                }
            },
            else => return error.CommandFailed,
        }
    }

    /// Install a package using the specified package manager
    fn installPackage(self: *Self, manager: PackageManager, name: []const u8, version: ?[]const u8, options: ?[]const []const u8) !void {
        // Skip if already installed
        if (self.installing.contains(name) or self.installed_packages.contains(name)) {
            if (self.verbose) {
                std.debug.print("Skipping already installed package: {s}\n", .{name});
            }
            return;
        }

        // Mark as installing to prevent circular dependencies
        try self.installing.put(name, {});
        defer _ = self.installing.remove(name);

        if (self.verbose) {
            std.debug.print("Installing package: {s}", .{name});
            if (version) |v| std.debug.print("@{s}", .{v});
            std.debug.print("\n", .{});
        }

        if (self.dry_run) return;

        // Create a temporary dependency info for the installation
        var dep = DependencyInfo{
            .name = name,
            .version = version,
            .manager = manager,
            .options = options,
        };

        // Install based on the package manager
        switch (manager) {
            .git => try self.installGitPackage(&dep),
            .brew => try self.installBrewPackage(name, version, options),
            .apt => try self.installAptPackage(name, version, options),
            .dnf => try self.installDnfPackage(name, version, options),
            .pacman => try self.installPacmanPackage(name, version, options),
            .cargo => try self.installCargoPackage(name, version, options),
            .npm, .yarn => try self.installNpmPackage(manager, name, version, options),
            .pip, .pip3 => try self.installPipPackage(manager, name, version, options),
            .go => try self.installGoPackage(name, version, options),
            .gem => try self.installGemPackage(name, version, options),
            .app_store => try self.installAppStorePackage(name, version, options),
            .custom => try self.installCustomPackage(name, version, options),
        }

        // Mark as installed
        try self.installed_packages.put(name, {});
        
        // Add to installation order
        try self.installation_order.append(.{
            .name = try self.allocator.dupe(u8, name),
            .version = if (version) |v| try self.allocator.dupe(u8, v) else null,
            .manager = manager,
        });
    }

    /// Install a package using Homebrew
    fn installBrewPackage(self: *Self, name: []const u8, version: ?[]const u8, options: ?[]const []const u8) !void {
        var args = std.ArrayList([]const u8).init(self.allocator);
        defer args.deinit();
        
        try args.append("brew");
        try args.append("install");
        
        // Add version if specified
        if (version) |ver| {
            const full_name = try std.fmt.allocPrint(self.allocator, "{s}@{s}", .{name, ver});
            defer self.allocator.free(full_name);
            try args.append(full_name);
        } else {
            try args.append(name);
        }
        
        // Add any additional options
        if (options) |opts| {
            for (opts) |opt| {
                try args.append(opt);
            }
        }
        
        try self.runCommand(args.items);
        
        if (self.verbose) {
            std.debug.print("Successfully installed {s}\n", .{name});
        }
    }

    /// Install a package using Cargo
    fn installCargoPackage(self: *Self, name: []const u8, version: ?[]const u8, options: ?[]const []const u8) !void {
        var args = std.ArrayList([]const u8).init(self.allocator);
        defer args.deinit();
        
        try args.append("cargo");
        try args.append("install");
        
        // Add package name with version if specified
        if (version) |ver| {
            const full_name = try std.fmt.allocPrint(self.allocator, "{s}@{s}", .{name, ver});
            defer self.allocator.free(full_name);
            try args.append(full_name);
        } else {
            try args.append(name);
        }
        
        // Add any additional options
        if (options) |opts| {
            for (opts) |opt| {
                try args.append(opt);
            }
        }
        
        // Add --quiet flag if not in verbose mode
        if (!self.verbose) {
            try args.append("--quiet");
        }
        
        try self.runCommand(args.items);
        
        if (self.verbose) {
            std.debug.print("Successfully installed {s} with cargo\n", .{name});
        }
    }

    /// Install a package using npm or yarn
    fn installNpmPackage(self: *Self, manager: PackageManager, name: []const u8, version: ?[]const u8, options: ?[]const []const u8) !void {
        var args = std.ArrayList([]const u8).init(self.allocator);
        defer args.deinit();
        
        const cmd = @tagName(manager);
        try args.append(cmd);
        
        // Determine if we're using npm or yarn
        const is_npm = std.mem.eql(u8, cmd, "npm");
        
        // Add install command
        if (is_npm) {
            try args.append("install");
            try args.append("--global");
        } else {
            try args.append("global");
            try args.append("add");
        }
        
        // Add package name with version if specified
        if (version) |ver| {
            const full_name = try std.fmt.allocPrint(self.allocator, "{s}@{s}", .{name, ver});
            defer self.allocator.free(full_name);
            try args.append(full_name);
        } else {
            try args.append(name);
        }
        
        // Add any additional options
        if (options) |opts| {
            for (opts) |opt| {
                // Skip global flag for yarn as it's already set
                if (!is_npm and std.mem.eql(u8, opt, "--global")) {
                    continue;
                }
                try args.append(opt);
            }
        }
        
        // Add --no-fund and --no-audit for npm to reduce noise
        if (is_npm) {
            try args.append("--no-fund");
            try args.append("--no-audit");
        }
        
        try self.runCommand(args.items);
        
        if (self.verbose) {
            std.debug.print("Successfully installed {s} with {s}\n", .{name, cmd});
        }
    }

    // Package information structure for configuration
    const PackageInfo = struct {
        name: []const u8,
        version: ?[]const u8 = null,
        options: ?[]const []const u8 = null,
        git: ?GitRepo = null,
    };
    
    // Environment configuration structure
    const EnvConfig = struct {
        type: PackageManager,
        packages: []const PackageInfo,
    };
    
    // Custom script type
    const CustomScript = struct {
        name: []const u8,
        type: []const u8,
        script: []const u8,
    };
    
    /// Load and process the configuration file
    pub fn loadEnvironment(self: *Self, path: []const u8) !void {
        if (self.verbose) {
            std.debug.print("Loading environment from {s}...\n", .{path});
        }
        
        // Read the configuration file
        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();
        
        const file_size = (try file.stat()).size;
        const file_content = try self.allocator.alloc(u8, file_size);
        defer self.allocator.free(file_content);
        _ = try file.readAll(file_content);
        
        // Check for Git-based packages
        if (std.mem.indexOf(u8, file_content, "git:") != null) {
            // This is a simplified example - in a real implementation, you would use a proper parser
            // For now, we'll just add an example Git package
            const git_repo = GitRepo{
                .source = .github,
                .owner = "example",
                .repo = "example-repo",
                .ref = GitRef{
                    .type = .branch,
                    .name = "main",
                },
                .subdir = null,
            };
            
            try self.installation_order.append(.{
                .name = "example/example-repo",
                .manager = .git,
                .git = git_repo,
            });
        }
        
        // Create environments map (simulating the Lua config)
        var environments = std.StringHashMap(EnvConfig).init(self.allocator);
        defer environments.deinit();
        
        // System packages (Homebrew)
        const system_packages = [_]PackageInfo{
            .{ .name = "ripgrep" },
            .{ .name = "fd" },
            .{ .name = "fzf" },
            .{ .name = "bat" },
            .{ .name = "eza" },
            .{ .name = "zoxide" },
            .{ .name = "jq" },
            .{ .name = "yq" },
            .{ .name = "htop" },
            .{ .name = "tldr" },
            .{ .name = "neofetch" },
            .{ .name = "node" },
            .{ .name = "pnpm" },
            .{ .name = "vercel-cli" },
            .{ .name = "supabase/tap/supabase" },
            .{ .name = "railway" },
            .{ .name = "zig" },
            .{ .name = "zls" },
            .{ .name = "rustup" },
            .{ .name = "gh" },
            .{ .name = "lazygit" },
            .{ .name = "kitty" },
            .{ .name = "asdf" },
        };
        
        try environments.put("system", EnvConfig{
            .type = .brew,
            .packages = &system_packages,
        });
        
        // Node.js packages
        const node_packages = [_]PackageInfo{
            .{ .name = "typescript" },
            .{ .name = "prettier" },
            .{ .name = "eslint" },
            .{ .name = "@biomejs/biome" },
        };
        
        try environments.put("node", EnvConfig{
            .type = .npm,
            .packages = &node_packages,
        });
        
        // Python packages
        const python_packages = [_]PackageInfo{
            .{ .name = "black" },
            .{ .name = "isort" },
            .{ .name = "pylint" },
        };
        
        try environments.put("python", EnvConfig{
            .type = .pip,
            .packages = &python_packages,
        });
        
        // Rust tools
        const rust_packages = [_]PackageInfo{
            .{ .name = "cargo-edit" },
            .{ .name = "cargo-watch" },
            .{ .name = "cargo-expand" },
        };
        
        try environments.put("rust", EnvConfig{
            .type = .cargo,
            .packages = &rust_packages,
        });
        
        // Custom scripts
        const custom_scripts = &[_]CustomScript{
            .{
                .name = "jetzig-cli",
                .type = "script",
                .script = 
                \\if ! command -v jetzig &> /dev/null; then
                \\  echo "Installing Jetzig CLI..."
                \\  git clone https://github.com/jetzig-framework/jetzig.git /tmp/jetzig
                \\  cd /tmp/jetzig
                \\  zig build -Doptimize=ReleaseSafe
                \\  mkdir -p ~/bin
                \\  cp zig-out/bin/jetzig ~/bin/
                \\  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
                \\  echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
                \\  echo "Jetzig CLI installed to ~/bin/jetzig"
                \\  echo "Please restart your shell or run 'source ~/.zshrc'"
                \\else
                \\  echo "Jetzig CLI is already installed"
                \\fi
                ,
            },
            .{
                .name = "shell-config",
                .type = "script",
                .script = 
                \\# Add zoxide to shell
                \\if ! grep -q 'eval "$(zoxide init' ~/.zshrc 2>/dev/null; then
                \\  echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
                \\fi
                \\
                \\# Add eza aliases
                \\if ! grep -q 'alias ls=' ~/.zshrc 2>/dev/null; then
                \\  echo 'alias ls="eza --icons --group-directories-first"' >> ~/.zshrc
                \\  echo 'alias ll="eza -l --icons --group-directories-first"' >> ~/.zshrc
                \\  echo 'alias la="eza -la --icons --group-directories-first"' >> ~/.zshrc
                \\fi
                \\
                \\# Add bat to shell
                \\if ! grep -q 'alias cat=' ~/.zshrc 2>/dev/null; then
                \\  echo 'alias cat="bat --theme=TwoDark"' >> ~/.zshrc
                \\fi
                ,
            },
        };
        
        if (self.verbose) {
            std.debug.print("Configuration loaded successfully\n", .{});
        }
        
        // Install packages for each environment
        var env_it = environments.iterator();
        while (env_it.next()) |entry| {
            const env_name = entry.key_ptr.*;
            const env = entry.value_ptr.*;
            
            if (self.verbose) {
                // Print the environment name directly
                std.debug.print("Installing packages for environment ", .{});
                std.debug.print("'{s}'...\n", .{env_name});
            }
            
            for (env.packages) |pkg| {
                std.debug.print("Installing {s} with {s}...\n", .{ pkg.name, @tagName(env.type) });
                try self.installPackage(env.type, pkg.name, null, pkg.options);
            }
        }
        
        // Run custom scripts
        if (self.verbose) {
            std.debug.print("Running custom scripts...\n", .{});
        }
        
        for (custom_scripts) |script| {
            std.debug.print("Running custom script: {s}\n", .{script.name});
            
            // Create a temporary shell script
            const temp_script_path = "/tmp/pears_script.sh";
            const temp_script = try std.fs.cwd().createFile(temp_script_path, .{});
            defer temp_script.close();
            
            // Write the shebang and script content
            try temp_script.writeAll("#!/bin/bash\n");
            try temp_script.writeAll(script.script);
            
            // Make the script executable
            const script_args = [_][]const u8{ "chmod", "+x", temp_script_path };
            try self.runCommand(&script_args);
            
            // Execute the script
            const exec_args = [_][]const u8{ "/bin/bash", temp_script_path };
            self.runCommand(&exec_args) catch |err| {
                std.debug.print("Error running script {s}: {s}\n", .{ script.name, @errorName(err) });
                return err;
            };
        }
    }

    /// Install a package from a Git repository
    fn installGitPackage(self: *Self, dep: *const DependencyInfo) !void {
        const git = dep.git orelse return error.MissingGitInfo;
        
        if (self.verbose) {
            std.debug.print("Installing from Git: {s}/{s}", .{git.owner, git.repo});
            if (git.ref) |ref| {
                std.debug.print(" @ {s}: {s}", .{@tagName(ref.type), ref.name});
            }
            std.debug.print("\n", .{});
        }
        
        if (self.dry_run) return;
        
        // Create a temporary directory for the clone
        var tmp_dir = std.fs.cwd().makeOpenPath(".pears/tmp", .{}) catch |err| {
            std.debug.print("Failed to create temporary directory: {s}\n", .{@errorName(err)});
            return err;
        };
        defer tmp_dir.close();
        
        // Build the repository URL based on the source
        const repo_url = switch (git.source) {
            .github => try std.fmt.allocPrint(self.allocator, "https://github.com/{s}/{s}.git", .{git.owner, git.repo}),
            .gitlab => try std.fmt.allocPrint(self.allocator, "https://gitlab.com/{s}/{s}.git", .{git.owner, git.repo}),
            .other => dep.url orelse return error.MissingGitUrl,
        };
        defer self.allocator.free(repo_url);
        
        // Clone the repository
        if (git.ref) |ref| {
            try self.runCommand(.{
                "git",
                "clone",
                "--depth",
                "1",
                "--branch",
                ref.name,
                repo_url,
                dep.name
            });
        } else {
            try self.runCommand(.{
                "git",
                "clone",
                "--depth",
                "1",
                repo_url,
                dep.name
            });
        }
        
        // If there's a subdirectory, move into it
        if (git.subdir) |subdir| {
            const subdir_path = try std.fs.path.join(self.allocator, &[_][]const u8{ dep.name, subdir });
            defer self.allocator.free(subdir_path);
            
            // Move the subdirectory contents to the package directory
            try self.runCommand(.{ "mv", subdir_path, "_temp" });
            try self.runCommand(.{ "rm", "-rf", dep.name });
            try self.runCommand(.{ "mv", "_temp", dep.name });
        }
    }
    
    /// Install a Python package using pip or pip3
    fn installPipPackage(self: *Self, _: PackageManager, name: []const u8, version: ?[]const u8, options: ?[]const []const u8) !void {
        // The manager parameter is not used since we always use python3 -m pip
        // but it's kept for consistency with other install functions
        var args = std.ArrayList([]const u8).init(self.allocator);
        defer args.deinit();
        
        try args.append("python3");
        try args.append("-m");
        try args.append("pip");
        try args.append("install");
        try args.append("--upgrade");
        
        // Add package name with version if specified
        if (version) |ver| {
            const full_name = try std.fmt.allocPrint(self.allocator, "{s}=={s}", .{name, ver});
            defer self.allocator.free(full_name);
            try args.append(full_name);
        } else {
            try args.append(name);
        }
        
        // Add any additional options
        if (options) |opts| {
            for (opts) |opt| {
                // Skip upgrade flag if already set
                const upgrade_flag = std.mem.eql(u8, opt, "--upgrade");
                const short_upgrade_flag = std.mem.eql(u8, opt, "-U");
                if (upgrade_flag or short_upgrade_flag) {
                    continue;
                }
                try args.append(opt);
            }
        }
        
        // Add --no-cache-dir to reduce disk usage
        try args.append("--no-cache-dir");
        
        // Add --quiet if not in verbose mode
        if (!self.verbose) {
            try args.append("--quiet");
        }
        
        try self.runCommand(args.items);
        
        if (self.verbose) {
            std.debug.print("Successfully installed {s} with pip\n", .{name});
        }
    }
};
