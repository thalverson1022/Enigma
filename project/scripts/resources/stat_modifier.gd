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
}

enum OperationType {
	ADD,
	MULTIPLY,
}

@export var stat: StatType = StatType.ATTACK_SPEED
@export var operation: OperationType = OperationType.ADD
@export var value: float = 0.0
