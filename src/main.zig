const std = @import("std");

const fs = std.fs;
const os = std.os;
const debug = std.debug;

const MIRU_VERSION = "0.1.0";
const USAGE = "Usage: miru [FILE]...";
const HELP = USAGE ++ "\n --help\t\tPrint help\n --version\tPrint version";

fn printUsage() void {
    debug.print("{s}", .{USAGE});
}
fn printHelp() !void {
    try std.io.getStdOut().writer().print("{s}", .{HELP});
}
fn printVersion() !void {
    try std.io.getStdOut().writer().print("miru {s}", .{MIRU_VERSION});
}
fn printErrorMessage(filename: [:0]u8, err: anyerror) void {
    debug.print("\"{s}\": {any}\n", .{ filename, err });
}

pub fn main() !void {
    const alc = std.heap.page_allocator;
    const args = try std.process.argsAlloc(alc);
    var buf: [std.mem.page_size]u8 = undefined;

    defer std.process.argsFree(alc, args);
    if (args.len < 2) {
        printUsage();
        os.exit(2);
    }

    // Arguments
    for (args[1..args.len]) |filename| {
        if (std.mem.eql(u8, filename, "--help")) {
            try printHelp();
            os.exit(0);
        } else if (std.mem.eql(u8, filename, "--version")) {
            try printVersion();
            os.exit(0);
        }
    }

    for (args[1..args.len]) |filename| {
        const content = fs.cwd().readFile(filename, &buf) catch |err| {
            printErrorMessage(filename, err);
            continue;
        };

        try std.io.getStdOut().writer().print("{s}\n", .{content});
    }
}
