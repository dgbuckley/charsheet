# Blockers

- handeling missing fields

# TODO

- (weapon and spell) attack interface for allowing attack objects to know when an attack was successful or not etc... (dynamic effects: scaling attacks, buffs)
- Long term character obj should clean up memory to run long term.
- allow "complex" weapons/spells:
  - Example:
```yaml
    Twin Blade Azharul (Time) complex:
      attacks:
        Collapsed:
          attack bonus: {proficiency_bonus(5)}+{dexterity(3)}+2
          damage: 2d8+2 (fire or cold damage)
        Extended:
          attack bonus: {proficiency_bonus(5)}+{dexterity(3)}+{strength.mod 3}+3
          damage: 3d10 (time damage)
```

# Goal 1: Accessing data
- dnd get <obj>
- dnd get farok.weapons

# Steps:
deserialization  : 
creating the CLI : 


# Goal 2: Rolling
- dnd roll <obj>
- dnd roll farok.attack.saber.damage
- dnd roll farok.saving_throws.str
- dnd roll farok.skills.acrobatics

# Goal 3: Setting data
- dnd set <obj> val



# Future Goals:

# methods
dnd call <method> [params...]
dnd call farok.weapons.Twin Blade Azharul (Time).collapse
dnd call farok.inventory.super_boost.use

