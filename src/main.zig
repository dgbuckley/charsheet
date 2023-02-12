const std = @import("std");

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
        others: [][]u8,
    };

    pub const Stats = struct {
        str: Stat,
        dex: Stat,
        con: Stat,
        int: Stat,
        wis: Stat,
        cha: Stat,
        
        pub const Stat = struct {val: u8, proficient: bool};
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

pub fn main() anyerror!void {
    std.log.info("All your codebase are belong to us.", .{});
}

test {
    std.testing.refAllDecls(@This());
}
