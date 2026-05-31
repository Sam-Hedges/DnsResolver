const std = @import("std");
const Io = std.Io;
const net = std.Io.net;

const dns = @import("dns.zig");

pub fn main() !void {
    var io_init = Io.Threaded.init_single_threaded;
    defer io_init.deinit();
    const io = io_init.io();

    // Bind a UDP socket to Google Public DNS
    const local_addr = try net.IpAddress.parse("8.8.8.8", 8080);
    const bind_opts: Io.net.IpAddress.BindOptions = .{
        .ip6_only = false,
        .mode = .dgram,
        .protocol = .udp,
    };
    var sock = try net.IpAddress.bind(&local_addr, io, bind_opts);
    defer sock.close(io);

    var buf: [1024]u8 = undefined;

    // Receive a datagram (blocks until one arrives)
    const msg = try sock.receive(io, &buf);
    std.debug.print("Received {} bytes from {f}\n", .{ msg.data.len, msg.from });

    // Send a reply back to sender
    try sock.send(io, &msg.from, msg.data);
}
