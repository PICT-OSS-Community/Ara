const std = @import("std");
const Token = @import("token.zig");

const LexerError = error{
    InvalidIdentifier,
    InvalidType,
};

pub const Lexer = struct {
    source: []const []const u8,
    line: usize,
    col: usize,

    pub fn init(source: []const []const u8) Lexer {
        return Lexer{ .source = source, .line = 0, .col = 0 };
    }
};

fn skip_whitespace(line: []const u8, idx: *usize) void {
    while (idx.* < line.len and std.ascii.isWhitespace(line[idx.*])) {
        idx.* += 1;
    }
}

fn isAllWhitespace(s: []const u8) bool {
    for (s) |c| {
        if (!std.ascii.isWhitespace(c)) {
            return false;
        }
    }
    return true;
}

pub fn match_variable(line: []const u8) !struct { Token.Token, ?[]const u8 } {
    var idx: usize = 0;

    // Skip leading whitespace
    skip_whitespace(line, &idx);

    // Check if the first character is valid for an identifier
    if (idx >= line.len or (!std.ascii.isAlphabetic(line[idx]) and line[idx] != '_')) {
        return LexerError.InvalidIdentifier;
    }

    // Find the end of the identifier
    const identifier_start = idx;
    while (idx < line.len and (std.ascii.isAlphanumeric(line[idx]) or line[idx] == '_')) {
        idx += 1;
    }
    const identifier = line[identifier_start..idx];

    // Skip whitespace after the identifier
    skip_whitespace(line, &idx);

    // Check if there's a colon
    if (idx >= line.len or line[idx] != ':') {
        return LexerError.InvalidIdentifier;
    }

    // Skip the colon and any whitespace after it
    idx += 1;
    skip_whitespace(line, &idx);

    // Match the type
    const typ_info: Token.Type = blk: {
        // Extract the type string (until '=' or end of line)
        const type_str = type_str_blk: {
            var end: usize = idx;
            while (end < line.len and line[end] != '=' and !std.ascii.isWhitespace(line[end])) {
                end += 1;
            }
            break :type_str_blk std.mem.trim(u8, line[idx..end], &std.ascii.whitespace);
        };

        if (Token.type_map.get(type_str)) |typ| {
            // Update the index by the length of the type string
            idx += type_str.len;
            break :blk typ;
        }
        return LexerError.InvalidType;
    };

    // Skip any whitespace after the type
    skip_whitespace(line, &idx);

    // Check if there's a value assignment
    var value: ?[]const u8 = null;
    if (idx < line.len and line[idx] == '=') {
        idx += 1;
        skip_whitespace(line, &idx);

        // Extract the value
        const value_start = idx;
        while (idx < line.len) {
            idx += 1;
        }

        if (isAllWhitespace(line[value_start..idx])) {
            return LexerError.InvalidIdentifier;
        }
        value = line[value_start..idx];
    } else {
        return LexerError.InvalidIdentifier;
    }

    return .{ Token.Token.new(Token.TokenType.identifier, identifier, typ_info), value };
}
