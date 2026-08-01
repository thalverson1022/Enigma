class_name CombatRecap
extends RefCounted
## Derives end-of-fight recap numbers from a CombatResolver.CombatResult
## for post-fight recap surfaces -- kept out of the UI scripts per
## docs/Conventions.md's UI architecture principle (panels format, systems
## compute).


## Returns a structured dictionary of recap facts. `monster` is optional for
## legacy/system callers that only need damage mix, but Adventure and Training
## Room recap surfaces should pass it so required damage, required DPS, and
## mitigation values are populated.
##
## Keys:
## total_damage, actual_dps, dps, damage_required, damage_shortfall, overkill,
## damage_delta, required_dps, biggest_hit, biggest_hit_skill,
## biggest_hit_was_crit, crit_count, cast_count, physical_damage,
## poison_damage, physical_pct, poison_pct, armor_reduction_total,
## armor_reduction_casts, base_armor, final_armor,
## poison_resistance_reduction_casts, base_poison_resistance,
## final_poison_resistance, poison_tick_count, peak_poison_stacks,
## poison_tick_damage.
##
## "Biggest hit" means the largest single direct cast -- poison ticks are
## damage-over-time, not hits.
static func summarize(result: CombatResolver.CombatResult, monster: Monster = null) -> Dictionary:
	var physical := 0.0
	var biggest_hit := 0.0
	var biggest_hit_skill := ""
	var biggest_hit_was_crit := false
	var crit_count := 0
	var armor_reduction_total := 0
	var armor_reduction_casts := 0
	var poison_resistance_reduction_casts := 0
	var final_poison_resistance := monster.poison_resistance if monster != null else 0.0
	for event in result.cast_events:
		physical += event.physical_damage
		if event.physical_damage > biggest_hit:
			biggest_hit = event.physical_damage
			biggest_hit_skill = event.skill.display_name if event.skill != null else "Unknown"
			biggest_hit_was_crit = event.is_crit
		if event.is_crit:
			crit_count += 1
		if event.armor_reduction_applied > 0:
			armor_reduction_total += event.armor_reduction_applied
			armor_reduction_casts += 1
		if event.poison_resistance_reduction_applied > 0.0:
			final_poison_resistance *= 1.0 - clampf(event.poison_resistance_reduction_applied, 0.0, 1.0)
			poison_resistance_reduction_casts += 1

	var poison := 0.0
	var poison_tick_count := 0
	var peak_poison_stacks := 0
	for tick in result.tick_events:
		if tick.damage <= 0.0:
			continue
		poison += tick.damage
		poison_tick_count += 1
		var stacks_before_tick: int = tick.stacks_remaining + 1
		if stacks_before_tick > peak_poison_stacks:
			peak_poison_stacks = stacks_before_tick

	var physical_pct := 0.0
	var poison_pct := 0.0
	if result.total_damage > 0.0:
		physical_pct = physical / result.total_damage * 100.0
		poison_pct = poison / result.total_damage * 100.0

	var damage_required := monster.hp if monster != null else 0
	var damage_delta := result.total_damage - float(damage_required)
	var required_dps := 0.0
	if monster != null and result.duration_ms > 0:
		required_dps = float(monster.hp) / (float(result.duration_ms) / 1000.0)

	return {
		"total_damage": result.total_damage,
		"actual_dps": result.dps,
		"dps": result.dps,
		"damage_required": damage_required,
		"damage_shortfall": maxf(0.0, -damage_delta),
		"overkill": maxf(0.0, damage_delta),
		"damage_delta": damage_delta,
		"required_dps": required_dps,
		"biggest_hit": biggest_hit,
		"biggest_hit_skill": biggest_hit_skill,
		"biggest_hit_was_crit": biggest_hit_was_crit,
		"crit_count": crit_count,
		"cast_count": result.cast_events.size(),
		"physical_damage": physical,
		"poison_damage": poison,
		"physical_pct": physical_pct,
		"poison_pct": poison_pct,
		"armor_reduction_total": armor_reduction_total,
		"armor_reduction_casts": armor_reduction_casts,
		"base_armor": monster.armor if monster != null else 0,
		"final_armor": (monster.armor - armor_reduction_total) if monster != null else 0,
		"poison_resistance_reduction_casts": poison_resistance_reduction_casts,
		"base_poison_resistance": monster.poison_resistance if monster != null else 0.0,
		"final_poison_resistance": final_poison_resistance,
		"poison_tick_count": poison_tick_count,
		"peak_poison_stacks": peak_poison_stacks,
		"poison_tick_damage": poison,
	}
