const std = @import("std");

const CountErrors = error {
    DirOpenFail,
    DirAppendFail,
    DirIteratorFail,
};

// walk the directory parameter and count the files, storing found directories into an array
pub fn countFiles(alloc: std.mem.Allocator, dir: []const u8) CountErrors!u64 {
    const stdout = std.io.getStdOut().writer();    
    var count: u64 = 0;
    var dirs: std.ArrayList([]const u8) = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer dirs.deinit();

    stdout.print("Reading directory: {s}\n", .{dir}) catch {};

    var this_dir = std.fs.openDirAbsolute(dir, .{ .iterate = true }) catch |err| {
        stdout.print("Error Opening directory: {s} error: {any}\n", .{dir, err}) catch {};
        return CountErrors.DirOpenFail;
    };
    defer this_dir.close();

    var walker = this_dir.walk(alloc) catch {
        return CountErrors.DirOpenFail;
    };

    while ((walker.next() catch { 
        return CountErrors.DirOpenFail; 
    })) |entry| {
        if (entry.kind == .Directory) {
            
            dirs.append(alloc.dupe(u8, entry.path) catch { 
                return CountErrors.DirAppendFail; 
            }) catch {
                return CountErrors.DirAppendFail;
            };

        } else {
            count += 1;
        }
    }

    return count;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Starting Zig Scan\n", .{});

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();

    // Get time
    const time = std.time.milliTimestamp();

    // join the build folder to the current working path 
    var built_path = try std.fs.cwd().realpathAlloc(alloc, "../data");
    
    try stdout.print("Root Path: {s}\n", .{built_path});

    // walk data folder counting files
    var count: u64 = countFiles(alloc, built_path) catch |err| {
        try stdout.print("Error Counting files: {}\n", .{err});
        return;
    };

    // get elapsed time
    const elapsed = std.time.milliTimestamp() - time;

    // display elapsed time
    try stdout.print("Total Files: {}\n", .{count});
    try stdout.print("Time Elapsed: {}ms\n", .{elapsed});
}