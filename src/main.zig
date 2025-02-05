const std = @import("std");
const Token = @import("token.zig");
const Lexer = @import("lexer.zig");

pub fn main() void {
    // Test cases
    const test_cases = [_][]const u8{
        "myVar: i32", // Valid with type
        "myVar: i32", // Valid with type and whitespace
        "myVar:i32", // Valid with type and no whitespace
        "myVar", // Valid with no type
        "123Invalid", // Invalid identifier
    };
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //const allocator = gpa.allocator();

    for (test_cases) |test_case| {
        const result = Lexer.match_identifier(test_case) catch |err| {
            std.debug.print("Error: {}\n", .{err});
            continue;
        };

        Token.printToken(result);
    }
}
