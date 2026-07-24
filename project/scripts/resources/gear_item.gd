class_name GearItem
extends Resource

enum SlotType {
	WEAPON,
	TRINKET,
	CHARM,
}

enum Tier {
	BASIC,
	MASTER,
	CURSED,
	LEGENDARY,
}

@export var id: String = ""
@export var display_name: String = ""
@export var slot: SlotType = SlotType.WEAPON
@export var tier: Tier = Tier.BASIC
@export var affixes: Array[StatModifier] = []
@export var triggered_skill_effects: Array[TriggeredSkillEffect] = []
@export var unlocked_skills: Array[Skill] = []
@export var physical_damage_per_gold: float = 0.0
@export var min_cast_time_proc_chance: float = 0.0
