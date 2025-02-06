const std = @import("std");

pub const Type = enum {
    i32,
    f32,
    bool,
    null,
};

pub const type_map = std.StaticStringMap(Type).initComptime(.{
    .{ "i32", Type.i32 },
    .{ "f32", Type.f32 },
    .{ "bool", Type.bool },
});

pub const TokenType = enum {
    // Single-character tokens
    left_paren,
    right_paren,
    left_bracket,
    right_bracket,
    left_brace,
    right_brace,
    comma,
    dot,
    colon,
    arrow,
    minus,
    plus,
    slash,
    star,
    percent,
    pipe,

    // One or two-character tokens
    equal,
    equal_equal,
    bang_equal,
    less,
    less_equal,
    greater,
    greater_equal,

    // Literals
    identifier,
    string,
    number,

    // Keywords
    @"fn",
    @"if",
    @"else",
    elif,
    lambda,
    true,
    false,
    @"return",
    import,
    from,
    as,

    // Special tokens
    newline,
    eof,
};

pub const Token = struct {
    typ: TokenType,
    name: ?[]const u8,
    typ_info: ?Type,

    // Constructor to create tokens with value
    pub fn new(typ: TokenType, name: ?[]const u8, typ_info: ?Type) Token {
        return .{ .typ = typ, .name = name, .typ_info = typ_info };
    }

    // String representation of a token for debugging
    pub fn toString(self: Token) ![]u8 {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();

        if (self.typ_info) |typ_info| {
            return std.fmt.allocPrint(allocator, "({s}: {s})", .{ @tagName(self.typ), @tagName(typ_info) });
        }
        return std.fmt.allocPrint(allocator, "({s}: null)", .{@tagName(self.typ)});
    }
};
