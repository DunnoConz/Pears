const std = @import("std");
const builtin = @import("builtin");
const Allocator = std.mem.Allocator;
const Thread = std.Thread;
const Mutex = Thread.Mutex;
const Condition = Thread.Condition;
const PackageManager = @import("deps.zig").PackageManager;

/// A simple task that can be executed by the thread pool
pub const Task = struct {
    runFn: *const fn (*Task) void,
    userdata: ?*anyopaque = null,

    pub fn run(self: *Task) void {
        self.runFn(self);
    }
};

/// A thread pool for parallel task execution
pub const ThreadPool = struct {
    const Self = @This();
    
    // Define a custom node type that contains the task directly
    const TaskNode = struct {
        task: Task,
        next: ?*TaskNode = null,
        
        fn create(allocator: Allocator, runFn: *const fn (*Task) void, userdata: ?*anyopaque) !*TaskNode {
            const node = try allocator.create(TaskNode);
            node.* = .{
                .task = .{
                    .runFn = runFn,
                    .userdata = userdata,
                },
            };
            return node;
        }
    };

    allocator: Allocator,
    threads: []Thread,
    task_head: ?*TaskNode = null,
    task_tail: ?*TaskNode = null,
    running: bool = true,
    mutex: Mutex = .{},
    cond: Condition = .{},

    pub fn init(allocator: Allocator, num_threads: usize) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        self.* = .{
            .allocator = allocator,
            .threads = try allocator.alloc(Thread, num_threads),
        };

        for (self.threads) |*thread| {
            thread.* = try Thread.spawn(.{}, worker, .{self});
        }

        return self;
    }

    pub fn deinit(self: *Self) void {
        self.mutex.lock();
        self.running = false;
        self.cond.broadcast();
        self.mutex.unlock();

        // Wait for all worker threads to finish
        for (self.threads) |thread| {
            thread.join();
        }

        self.allocator.free(self.threads);
    }

    pub fn submit(self: *Self, runFn: *const fn (*Task) void, userdata: ?*anyopaque) !void {
        const node = try TaskNode.create(self.allocator, runFn, userdata);
        
        self.mutex.lock();
        defer self.mutex.unlock();
        
        if (self.task_tail) |tail| {
            tail.next = node;
            self.task_tail = node;
        } else {
            self.task_head = node;
            self.task_tail = node;
        }
        
        self.cond.signal();
    }

    fn worker(self: *Self) void {
        while (true) {
            self.mutex.lock();
            
            // Wait for tasks or shutdown
            while (self.task_head == null) {
                if (!self.running) {
                    self.mutex.unlock();
                    return;
                }
                self.cond.wait(&self.mutex);
            }
            
            // Get the next task
            const node = self.task_head orelse {
                self.mutex.unlock();
                continue;
            };
            
            // Remove the task from the queue
            self.task_head = node.next;
            if (self.task_head == null) {
                self.task_tail = null;
            }
            
            self.mutex.unlock();
            
            // Execute the task
            node.task.run();
            
            // Clean up the node
            self.allocator.destroy(node);
        }
    }
};

/// A task for installing packages in parallel
pub const InstallTask = struct {
    allocator: Allocator,
    manager: PackageManager,
    name: []const u8,
    version: ?[]const u8 = null,
    options: ?[]const []const u8 = null,
    on_complete: *const fn ([]const u8, anyerror!void) void,
    user_data: ?*anyopaque = null,
    verbose: bool = false,

    pub fn run(self: *InstallTask) void {
        const result = self.install();
        self.on_complete(self.name, result);
        self.allocator.destroy(self);
    }

    fn install(self: *const InstallTask) !void {
        // In a real implementation, this would execute the package manager commands
        // For now, we'll just simulate the installation with a delay
        if (self.verbose) {
            std.debug.print("Installing {} package: {s}", .{self.manager, self.name});
            if (self.version) |ver| {
                std.debug.print("@{s}", .{ver});
            }
            std.debug.print("\n", .{});
        }
        
        // Simulate installation time
        std.time.sleep(100 * std.time.ns_per_ms);
        
        if (self.verbose) {
            std.debug.print("✅ Successfully installed: {s}\n", .{self.name});
        }
    }
};
