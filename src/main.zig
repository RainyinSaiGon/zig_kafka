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

    if (args.len > 1 and std.mem.eql(u8, args[1],"server"))
    {
        std.debug.print("Hello {s}. \n", .{"world"});
    }
    else
    {
        std.debug.print("Ping {s}. \n", .{"Pong"});
    }
    

    // In order to do I/O operations need an `Io` instance. (Threaded)
    const io = init.io;

    try startServer(io);
}

pub fn startServer(io: Io) !void {

    // First, we wind defined an IPaddress "127.0.0.1" with the port 1234 to our variable
    const address = try Io.net.IpAddress.parse("127.0.0.1", 1234);

    // Create a socket server with TCP protocol
    // reuse_address help us use the port immediately without waiting TIME_OUT from OS
    var server = try address.listen(io, .{ .mode = .stream, .protocol = .tcp, .reuse_address = true });

    // This line will block our program until some clients connect to our server
    const stream = try server.accept(io);

    // TODO: Read + Write
    stream.close(io);
}
