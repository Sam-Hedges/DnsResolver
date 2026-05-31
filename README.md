# DNS resolver in Zig

I've created this project to help me learn more about networking, whilst learning a new language for fun.

## Goals

### Phase 1 - Send a raw query

- [ ] Open a UDP socket with std.posix.socket and connect to 8.8.8.8:53
- [ ] Manually write a minimal query for example.com A into a fixed buffer
- [ ] Receive the response and std.debug.print raw bytes in hex
- [ ] Zig concepts: std.posix, fixed-size arrays, @intCast, error union basics

This phase deliberately skips abstraction — wire bytes by hand so you understand what you're later parsing.

### Phase 2 - Parse the header

- [ ] Define a Header struct with all 12 bytes: ID, flags, QDCOUNT, ANCOUNT, NSCOUNT, ARCOUNT
- [ ] Use std.mem.readInt with .big endian to decode each field
- [ ] Parse the flags word into bitfields: QR, opcode, AA, TC, RD, RA, RCODE
- [ ] Zig concepts: packed structs, std.mem, @bitCast, comptime-known sizes
- [ ] RFC 1035 §4.1.1 defines this exactly. Read the spec directly — it's more precise than any tutorial.

### Phase 3 - Parse labels and the question section

- [ ] Write a parseName function that walks length-prefixed labels and assembles a dotted name
- [ ] Handle pointer compression: if the top 2 bits of a label byte are 11, it's an offset into the original packet — follow it
- [ ] Parse QTYPE and QCLASS from the question section
- [ ] Zig concepts: slices, pointer arithmetic, sentinel loops, ArenaAllocator for name buffers
- [ ] Pointer compression is the hardest part. Add a loop depth counter to prevent infinite cycles on malformed packets.

### Phase 4 - Parse answer records

- [ ] Define a tagged union RData with variants: A (IPv4), AAAA (IPv6), CNAME, MX, TXT, Unknown
- [ ] Parse each answer's NAME, TYPE, CLASS, TTL, RDLENGTH, RDATA fields in sequence
- [ ] Use std.net.Address.parseIp4 / parseIp6 to format IPv4/IPv6 for printing
- [ ] Follow CNAME chains automatically by re-querying the resolved name
- [ ] Zig concepts: tagged unions, switch on enum, allocator-passed parsing functions

### Phase 5 - Iterative resolution + polish

- [ ] Read /etc/resolv.conf to find the system nameserver instead of hardcoding 8.8.8.8
- [ ] Add TCP fallback when the TC (truncated) flag is set in the response
- [ ] Build a TTL-aware in-memory cache using std.StringHashMap
- [ ] Add a simple CLI: accept a name and record type, print results
- [ ] Write unit tests for your parser using std.testing.expect with known captured packets
- [ ] Zig concepts: std.HashMap, std.process.args, std.testing, build system basics

### Resources

RFC 1035 — the DNS spec itself. §4 covers the wire format precisely. Read §4.1 (header), §4.1.2 (labels), §4.1.3 (resource records). rfc-editor.org
Zig standard library docs — search for std.mem, std.posix, std.net, std.testing. ziglang.org/std
ziglearn.org — chapter-by-chapter intro covering allocators, error unions, and testing. Essential companion. ziglearn.org
Julia Evans' DNS posts — excellent visual explainers of the wire format. Her "implement DNS in a weekend" post (Python, but maps directly) is a good sanity check. jvns.ca
Wireshark — capture your own DNS queries, inspect the hex, verify your parser against real traffic. Filter with dns.

## Tips

**`ArenaAllocator`** Create one per query, pass it into all your parsing functions, and free everything at once when you're done. You won't have to think about individual allocations at all until phase 5's cache.
