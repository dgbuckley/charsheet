const std = @import("std");
const mem = std.mem;

const zzz = @import("zx4");

const List = std.ArrayListUnmanaged;
const String = List(u8);
const Buffer = std.ArrayList(u8);

const Map = std.StringArrayHashMapUnmanaged;

const CharacterConf = struct {
    Name: []u8,
    Level: u16,
    Class: Map(u8),
    Background: []u8,
    AC: u8,
    Speed: u8,
    HP: u8,
    @"Proficient Skills": List([]u8),
    @"Proficient Stats": List([]u8),
    Senses: Map([]u8),
    Languages: List([]u8),
    Weapons: Map([]u8),
    Spells: Map([]u8),

    pub const Spell = struct {
        Name: String,
        @"Casting Time": String,
        Range: u16,
        Components: List(String),
        Duration: List(String),
        Description: ?String,
        Damage: ?String,
        Level: String,
    };

    pub const Weapon = struct {
        Name: String,
        Class: String,
        @"Attack Bonus": String,
        Damage: String,
        Ability: ?String,
    };

    pub const HitPoints = struct {
        current: u8,
        max: u8,
    };

    fn load(ally: mem.Allocator, file: std.fs.File) !CharacterConf {
        var txt = try file.reader().readAllAlloc(ally, std.math.maxInt(usize));
        var diag = zzz.ParserDiagnostics{};
        var tree = zzz.Tree.init(ally);
        _ = tree.addRoot(txt, .{ .diagnostics = &diag }) catch {
            std.log.err("unable to parse character config: {s} at line {}, col {}", .{ @errorName(diag.err.?), diag.line + 1, diag.col });
            return error.InvalidZZZ;
        };
        var returnVal = tree.imprint(CharacterConf, .{ .allocator = ally }) catch unreachable;
        return returnVal;
    }
};

const Character = struct {
    name: []u8,
    level: u8,
    class: Class,
    armor_class: u8,
    speed: u8,
    hit_points: HitPoints,
    stats: Stats,
    skills: std.EnumSet(Skills),
    senses: Senses,
    languages: [][]const u8,
    attacks: std.ArrayList(*Weapon),

    pub const Spell = struct {
        name: []u8,
        casting_time: []u8,
        range: u16,
        components: [][]u8,
        durration: [][]u8,
        description: ?[]u8,
        dammage: ?[]u8,
        level: []u8,
    };

    pub const Weapon = struct {
        name: []u8,
        class: []u8,
        attack_bonus: u8,
        dammage: []u8,
        ability: ?[]u8,
    };

    pub const Senses = struct {
        passive_wisdom: u8,
        others: Map(String),
    };

    pub const Stats = struct {
        str: Stat,
        dex: Stat,
        con: Stat,
        int: Stat,
        wis: Stat,
        cha: Stat,

        pub const Stat = struct { val: u8, proficient: bool };
    };

    pub const Skills = enum {
        acrobatics,
        animal_handling,
        arcana,
        athletics,
        deception,
        history,
        insight,
        intimidation,
        investigation,
        medicine,
        nature,
        perception,
        performance,
        persuasion,
        religion,
        slight_of_hand,
        stealth,
        survival,
    };

    pub const Modifier = struct {
        stats: Stats,
        proficient: bool,
    };

    pub const HitPoints = struct {
        current: u8,
        max: u8,
    };

    pub const Class = struct {
        name: []u8,
        level: u8,
    };
};

fn printObj(comptime T: type, obj: T, out: anytype) !void {
    const is_many = comptime std.meta.trait.isManyItemPtr(T) or std.meta.trait.isSlice(T);
    const is_string = comptime std.meta.trait.isZigString(T);
    if (is_many) {
        const fmt = if (is_string) "{s}" else "{any}";
        try out.print(fmt++"\n", .{obj});
    } else {
        try out.print("{}\n", .{obj});
    }
    return;
}
fn decendObj(tok: *mem.TokenIterator(u8), comptime T: type, obj: T, out: anytype) anyerror!void {
    const type_info = @typeInfo(T);
    const next = tok.next() orelse {
        return try printObj(T,obj, out);
    };
    switch (type_info) {
        .Struct => |struct_info| {
            // TODO index into maps
            inline for (struct_info.fields) |field| {
                if (std.mem.eql(u8, next, field.name)) {
                    return try decendObj(tok, field.field_type, @field(obj, field.name), out);
                }
            }
            return error.FieldDoesNotExist;
        },
        .Pointer => |ptr_info| {
            switch (ptr_info.size) {
                .One => {
                    return try decendObj(tok, T, obj.*, out);
                },
                .Many, .Slice => {
                    // TODO handle indexing slices. Ie languages.[0]
                    return error.CannotIndexIntoSlice;
                },
                .C => @compileError("C pointers are not supported"),
            }
        },
        else => {
            return error.InvalidFieldIndexed;
        },
    }
}

fn getObj(comptime T: type, obj: T, path: []const u8, out: anytype) !void {
    var path_iter = std.mem.tokenize(u8, path, ".");
    try decendObj(&path_iter, T, obj, out);
}

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var ally = arena.allocator();
    defer arena.deinit();

    var opts = std.process.argsAlloc(ally) catch unreachable;
    std.io.getStdErr().writer().print("{s}\n", .{opts}) catch unreachable;
    if (opts.len != 4 or !mem.eql(u8, opts[2], "run")) {
        std.io.getStdErr().writer().writeAll("Usage: dnd [FILE] run <object>") catch unreachable;
        return;
    }

    var char_file = std.fs.cwd().openFile(opts[1], .{}) catch |err| {
        std.log.err("unable to open the character sheet: {s}", .{@errorName(err)});
        return;
    };
    defer char_file.close();

    var character = CharacterConf.load(ally, char_file) catch |err| {
        std.log.err("unable to load the character configuration: {s}", .{@errorName(err)});
        return;
    };

    var stdout = std.io.getStdOut().writer();

    try getObj(CharacterConf, character, opts[3], stdout);
}

test {
    std.testing.refAllDecls(@This());
}
