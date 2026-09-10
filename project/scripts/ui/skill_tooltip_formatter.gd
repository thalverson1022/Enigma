class_name SkillTooltipFormatter
extends RefCounted

const SPEED_LABEL_BY_SKILL_ID := {
	"skill.stab": "Speed: Normal",
	"skill.heavy_slash": "Speed: Slow",
	"skill.hold": "Speed: Brief",
	"skill.quick_cut": "Speed: Fast",
	"skill.rending_thrust": "Speed: Normal",
	"skill.venom_jab": "Speed: Fast",
	"skill.poison_strike": "Speed: Fast",
	"skill.steal": "Speed: Normal",
	"skill.toxic_flurry": "Speed: Normal",
	"skill.killers_mark": "Speed: Normal",
}


static func tooltip_for(skill: Skill, state) -> String:
	var lines: PackedStringArray = []
	lines.append(speed_label_for(skill))
	lines.append(effect_summary(skill, state))
	return "\n".join(lines)


static func speed_label_for(skill: Skill) -> String:
	if skill == null:
		return "Speed: Normal"
	return SPEED_LABEL_BY_SKILL_ID.get(skill.id, "Speed: Normal")


static func effect_summary(skill: Skill, state = null) -> String:
	if skill == null:
		return "No effect"
	if skill.id == "skill.hold":
		return "Holds for 1.0s"
	var parts: PackedStringArray = []
	var has_poison_effect := false
	var stats := resolved_stats(state)
	for effect in skill.effects:
		if effect is PhysicalDamageEffect:
			parts.append(_physical_damage_summary(skill, stats, effect.amount))
		elif effect is PoisonDamageEffect:
			has_poison_effect = true
			parts.append(_poison_stack_summary(effect.stacks_applied, stats))
		elif effect is ArmorReductionEffect:
			parts.append(_shred_stack_summary(effect.amount, stats))
		elif effect is PoisonResistanceReductionEffect:
			parts.append(_decay_stack_summary(1, stats))
		elif effect is StackScalingPhysicalDamageEffect:
			parts.append("+%d dmg/poison stack" % roundi(effect.damage_per_stack))
		elif effect is StealGoldOnCritEffect:
			parts.append("crits steal %dg" % _stolen_gold_amount(effect.amount, stats))
	if skill.poison_stacks_applied > 0 and not has_poison_effect:
		parts.append(_poison_stack_summary(skill.poison_stacks_applied, stats))
	if parts.is_empty():
		return "No effect"
	return ", ".join(parts)


static func resolved_stats(state = null) -> PlayerStats:
	if state == null or state.selected_class == null:
		var fallback := PlayerStats.new()
		fallback.base_poison_damage = fallback.poison_damage_per_tick
		return fallback
	return BuildResolver.resolve_stats(
		state.selected_class,
		state.selected_trees,
		state.selected_talents,
		state.equipped_gear(),
		state.gold
	)


static func _physical_damage_summary(skill: Skill, stats: PlayerStats, fallback_amount: float) -> String:
	var scaling := CombatResolver.weapon_scaling_for_skill(skill)
	if scaling <= 0.0:
		return "%d physical dmg" % roundi(maxf(PlayerStats.MIN_DAMAGE_BASE, fallback_amount + stats.bonus_physical_damage) * stats.physical_damage_multiplier)
	var min_base := maxf(PlayerStats.MIN_DAMAGE_BASE, float(stats.weapon_damage_min) + stats.bonus_physical_damage)
	var max_base := maxf(PlayerStats.MIN_DAMAGE_BASE, float(stats.weapon_damage_max) + stats.bonus_physical_damage)
	if skill != null and skill.id == CombatResolver.DEATH_STRIKE_SKILL_ID:
		return "%s physical dmg +%d/poison stack" % [
			_damage_range_text(min_base * scaling * stats.physical_damage_multiplier, max_base * scaling * stats.physical_damage_multiplier),
			roundi(CombatResolver.DEATH_STRIKE_DAMAGE_PER_POISON_STACK * scaling * stats.physical_damage_multiplier),
		]
	var min_damage := min_base * scaling * stats.gear_physical_damage_multiplier * stats.talent_physical_damage_multiplier
	var max_damage := max_base * scaling * stats.gear_physical_damage_multiplier * stats.talent_physical_damage_multiplier
	return "%s physical dmg" % _damage_range_text(min_damage, max_damage)


static func _poison_stack_summary(base_stacks: int, stats: PlayerStats) -> String:
	var total := _effective_stack_total(base_stacks, stats.bonus_poison_stacks, stats)
	return "+%d poison stack%s" % [total, "" if total == 1 else "s"]


static func _shred_stack_summary(base_stacks: int, stats: PlayerStats) -> String:
	var total := _effective_stack_total(base_stacks, stats.bonus_shred_stacks, stats)
	return "Applies %d Stack%s of Shred" % [total, "" if total == 1 else "s"]


static func _decay_stack_summary(base_stacks: int, stats: PlayerStats) -> String:
	var total := _effective_stack_total(base_stacks, stats.bonus_decay_stacks, stats)
	return "Applies %d Stack%s of Decay (-%d%% resist each)" % [
		total,
		"" if total == 1 else "s",
		roundi(stats.decay_value * 100.0),
	]


static func _effective_stack_total(base_stacks: int, bonus_stacks: int, stats: PlayerStats) -> int:
	var total := maxi(0, base_stacks + bonus_stacks)
	if stats != null and bool(stats.special_effects.get("double_applied_stacks", false)):
		total *= 2
	return total


static func _stolen_gold_amount(base_amount: int, stats: PlayerStats) -> int:
	if stats == null:
		return maxi(0, base_amount)
	return maxi(0, int(floor(float(base_amount) * stats.gold_reward_multiplier)))


static func _damage_range_text(min_damage: float, max_damage: float) -> String:
	var low := roundi(minf(min_damage, max_damage))
	var high := roundi(maxf(min_damage, max_damage))
	return "%d-%d" % [low, high]
