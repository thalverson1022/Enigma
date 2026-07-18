class_name StatModifierFormatter
extends RefCounted
## Shared human-readable formatting for a StatModifier -- used anywhere a
## talent/tree/gear affix needs to show up as text (gear slot listings,
## talent tooltips, subclass level-0 bonus tooltips). Centralized so all
## three read the same way instead of drifting.

const STAT_NAMES := {
	StatModifier.StatType.ATTACK_SPEED: "Attack Speed",
	StatModifier.StatType.CRIT_CHANCE: "Crit Chance",
	StatModifier.StatType.CRIT_MULTIPLIER: "Crit Multiplier",
	StatModifier.StatType.POISON_DAMAGE: "Poison Damage",
	StatModifier.StatType.PHYSICAL_DAMAGE: "Physical Damage",
	StatModifier.StatType.POISON_STACKS_APPLIED: "Poison Stacks",
	StatModifier.StatType.ARMOR_REDUCTION: "Armor Reduction",
	StatModifier.StatType.GOLD_REWARDS: "Gold Rewards",
	StatModifier.StatType.POISON_TICK_INTERVAL: "Poison Tick Interval",
}


static func format(modifier: StatModifier) -> String:
	var stat_name: String = STAT_NAMES.get(modifier.stat, "?")
	if modifier.operation == StatModifier.OperationType.MULTIPLY:
		return "x%.2f %s" % [modifier.value, stat_name]
	match modifier.stat:
		StatModifier.StatType.ATTACK_SPEED, StatModifier.StatType.CRIT_CHANCE:
			return "%+d%% %s" % [roundi(modifier.value * 100.0), stat_name]
		StatModifier.StatType.CRIT_MULTIPLIER:
			return "%+.2f %s" % [modifier.value, stat_name]
		StatModifier.StatType.ARMOR_REDUCTION:
			return "-%d armor" % roundi(absf(modifier.value))
		StatModifier.StatType.POISON_TICK_INTERVAL:
			return "x%.2f %s" % [modifier.value, stat_name]
		_:
			return "%+d %s" % [roundi(modifier.value), stat_name]
