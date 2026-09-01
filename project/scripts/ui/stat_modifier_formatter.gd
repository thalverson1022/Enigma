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
	StatModifier.StatType.CRIT_CHANCE_PER_STOLEN_GOLD: "Crit Chance per Stolen Gold",
	StatModifier.StatType.CRIT_MULTIPLIER_PER_CURRENT_GOLD: "Crit Damage per Current Gold",
}


static func format(modifier: StatModifier) -> String:
	var stat_name: String = STAT_NAMES.get(modifier.stat, "?")
	if modifier.operation == StatModifier.OperationType.MULTIPLY:
		return _format_multiplier_percent(modifier.value, stat_name)
	match modifier.stat:
		StatModifier.StatType.ATTACK_SPEED, StatModifier.StatType.CRIT_CHANCE:
			return "%+d%% %s" % [roundi(modifier.value * 100.0), stat_name]
		StatModifier.StatType.CRIT_CHANCE_PER_STOLEN_GOLD:
			return "%+d%% Crit Chance per gold stolen this fight" % roundi(modifier.value * 100.0)
		StatModifier.StatType.CRIT_MULTIPLIER_PER_CURRENT_GOLD:
			return "%+d%% Crit Damage per current gold" % roundi(modifier.value * 100.0)
		StatModifier.StatType.CRIT_MULTIPLIER:
			return "%+d%% Crit Damage" % roundi(modifier.value * 100.0)
		StatModifier.StatType.GOLD_REWARDS:
			return "%+d%% %s" % [roundi(modifier.value * 100.0), stat_name]
		StatModifier.StatType.ARMOR_REDUCTION:
			return "-%d armor" % roundi(absf(modifier.value))
		StatModifier.StatType.POISON_TICK_INTERVAL:
			return "x%.2f %s" % [modifier.value, stat_name]
		_:
			return "%+d %s" % [roundi(modifier.value), stat_name]


static func _format_multiplier_percent(value: float, stat_name: String) -> String:
	var delta_percent := roundi((value - 1.0) * 100.0)
	return "x%d%% %s" % [delta_percent, stat_name]
