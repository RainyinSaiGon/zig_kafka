const std = @import("std");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    // In order to do I/O operations need an `Io` instance. (Threaded)
    const io = init.io;

    if (args.len > 1 and std.mem.eql(u8, args[1], "server")) {
        try startServer(io);
    } else {
        try clientConnect(io);
    }
}

pub fn startServer(io: Io) !void {
    const address = try Io.net.IpAddress.parse("127.0.0.1", 1234);
    var server = try address.listen(io, .{ .mode = .stream, .protocol = .tcp, .reuse_address = true });

    const stream = try server.accept(io);

    // Read from client
    var read_buf: [1024]u8 = undefined;
    var rd = stream.reader(io, &read_buf);

    const header = try rd.interface.takeByte();
    const data = try rd.interface.take(header);

    std.debug.print("Receive from client: {s}\n", .{data});

    // Write to client
    var write_buf: [1024]u8 = undefined;
    var wt = stream.writer(io, &write_buf);
    try wt.interface.writeByte(@as(u8, @intCast(data.len)));
    try wt.interface.writeAll(data);
    try wt.interface.flush();

    stream.close(io);
}

pub fn clientConnect(io: Io) !void {
    const address = try Io.net.IpAddress.parse("127.0.0.1", 1234);
    const connection = try address.connect(io, .{ .mode = .stream, .protocol = .tcp });

    // Read from stdin
    var stdin_buf: [1024]u8 = undefined;
    var std_reader: Io.File.Reader = .init(.stdin(), io, &stdin_buf);

    const line = try std_reader.interface.takeSentinel('\n');
    std.debug.print("Send to server: {s}\n", .{line});

    // Write to server
    var write_buf: [1024]u8 = undefined;
    var wt = connection.writer(io, &write_buf);

    try wt.interface.writeByte(@as(u8, @intCast(line.len)));
    try wt.interface.writeAll(line);
    try wt.interface.flush();

    // Read from server
    var read_buf: [1024]u8 = undefined;
    var rd = connection.reader(io, &read_buf);

    const header = try rd.interface.takeByte();
    const data = try rd.interface.take(header);

    std.debug.print("Receive from server: {s}\n", .{data});

    connection.close(io);
}
