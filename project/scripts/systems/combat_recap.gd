class_name CombatRecap
extends RefCounted
## Derives end-of-fight recap numbers from a CombatResolver.CombatResult
## for the victory banner -- kept out of the UI scripts per
## docs/Conventions.md's UI architecture principle (panels format, systems
## compute).


## Returns {"total_damage", "dps", "biggest_hit", "biggest_hit_skill",
## "physical_damage", "poison_damage", "physical_pct", "poison_pct"}.
## "Biggest hit" means the largest single direct cast -- poison ticks are
## damage-over-time, not hits.
static func summarize(result: CombatResolver.CombatResult) -> Dictionary:
	var physical := 0.0
	var biggest_hit := 0.0
	var biggest_hit_skill := ""
	for event in result.cast_events:
		physical += event.physical_damage
		if event.physical_damage > biggest_hit:
			biggest_hit = event.physical_damage
			biggest_hit_skill = event.skill.display_name

	var poison := 0.0
	for tick in result.tick_events:
		poison += tick.damage

	var physical_pct := 0.0
	var poison_pct := 0.0
	if result.total_damage > 0.0:
		physical_pct = physical / result.total_damage * 100.0
		poison_pct = poison / result.total_damage * 100.0

	return {
		"total_damage": result.total_damage,
		"dps": result.dps,
		"biggest_hit": biggest_hit,
		"biggest_hit_skill": biggest_hit_skill,
		"physical_damage": physical,
		"poison_damage": poison,
		"physical_pct": physical_pct,
		"poison_pct": poison_pct,
	}
