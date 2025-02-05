const std = @import("std");
const Token = @import("token.zig");

const LexerError = error{
    InvalidIdentifier,
};

pub const Lexer = struct {
    source: []const []const u8,
    line: usize,
    col: usize,

    pub fn init(source: []const []const u8) Lexer {
        return Lexer{ .source = source, .line = 0, .col = 0 };
    }
};

pub fn match_identifier(line: []const u8) !Token.Token {
    var idx: usize = 0;

    // Check if the first character is valid for an identifier
    if (!std.ascii.isAlphabetic(line[idx]) and line[idx] != '_') {
        return LexerError.InvalidIdentifier;
    }

    // Find the end of the identifier
    while (idx < line.len and (std.ascii.isAlphanumeric(line[idx]) or line[idx] == '_')) {
        idx += 1;
    }

    // Extract the identifier
    const identifier = line[0..idx];

    // Skip whitespace after the identifier
    while (idx < line.len and std.ascii.isWhitespace(line[idx])) {
        idx += 1;
    }

    // Check if there's a colon
    if (idx >= line.len or line[idx] != ':') {
        return Token.Token.new(Token.TokenType.identifier, identifier, Token.Type.null);
    }

    // Skip the colon and any whitespace after it
    idx += 1;
    while (idx < line.len and std.ascii.isWhitespace(line[idx])) {
        idx += 1;
    }

    // Match the type
    const type_slice = line[idx..];
    const typ_info: Token.Type = blk: {
        if (std.mem.startsWith(u8, type_slice, "i32")) {
            idx += 3;
            break :blk Token.Type.i32;
        } else if (std.mem.startsWith(u8, type_slice, "f32")) {
            idx += 3;
            break :blk Token.Type.f32;
        } else if (std.mem.startsWith(u8, type_slice, "bool")) {
            idx += 4;
            break :blk Token.Type.bool;
        } else {
            break :blk Token.Type.null;
        }
    };

    return Token.Token.new(Token.TokenType.identifier, identifier, typ_info);
}
