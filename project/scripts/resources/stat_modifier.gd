class_name StatModifier
extends Resource

enum StatType {
	ATTACK_SPEED,
	CRIT_CHANCE,
	CRIT_MULTIPLIER,
	POISON_DAMAGE,
	PHYSICAL_DAMAGE,
	POISON_STACKS_APPLIED,
	ARMOR_REDUCTION,
	GOLD_REWARDS,
	POISON_TICK_INTERVAL,
	CRIT_CHANCE_PER_STOLEN_GOLD,
	CRIT_MULTIPLIER_PER_CURRENT_GOLD,
}

enum OperationType {
	ADD,
	MULTIPLY,
}

enum StatCategory {
	BASIC,
	RARE,
	SPECIAL,
	DRAWBACK,
	COMPATIBILITY,
}

@export var stat_id: String = ""
@export var stat: StatType = StatType.ATTACK_SPEED
@export var category: StatCategory = StatCategory.COMPATIBILITY
@export var operation: OperationType = OperationType.ADD
@export var value: float = 0.0
@export var is_drawback: bool = false
@export var display_label: String = ""
