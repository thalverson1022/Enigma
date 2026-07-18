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
