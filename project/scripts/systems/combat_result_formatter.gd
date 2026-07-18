class_name CombatResultFormatter
extends RefCounted
## Renders a CombatResolver.CombatResult as a human-readable fight
## narrative: a header describing the matchup, a single chronological
## timeline (casts and poison ticks merged, in seconds), and a summary
## verdict. Zero-damage poison ticks (cadence beats with no stacks active)
## are noise and get skipped.


static func format(result: CombatResolver.CombatResult, monster: Monster) -> String:
	var lines: PackedStringArray = []
	lines.append("%s  --  %d HP, %d Armor, %.0f%% Poison Resist" % [
		monster.display_name, monster.hp, monster.armor, monster.poison_resistance * 100.0
	])
	lines.append("Combat window: %.0fs" % (result.duration_ms / 1000.0))
	lines.append("")

	var timeline := _timeline(result)
	if timeline.is_empty():
		lines.append("Nothing happened -- no skills were cast.")
	else:
		lines.append_array(timeline)

	lines.append("")
	lines.append("Dealt %.1f damage in %.0fs -- %.1f DPS." % [
		result.total_damage, result.duration_ms / 1000.0, result.dps
	])
	if result.is_win:
		lines.append("VICTORY! %s is defeated (needed %d damage)." % [monster.display_name, monster.hp])
	else:
		lines.append("DEFEAT -- fell %.1f damage short of the %d needed." % [
			float(monster.hp) - result.total_damage, monster.hp
		])
	return "\n".join(lines)


## Merges cast and tick events into one time-ordered list of prose lines.
## Both source arrays are already time-sorted (the resolver appends
## chronologically); ties go to the tick, matching how the resolver processes
## cadence beats already due before a cast lands at the same timestamp.
static func _timeline(result: CombatResolver.CombatResult) -> PackedStringArray:
	var lines: PackedStringArray = []
	var cast_index := 0
	var tick_index := 0
	while cast_index < result.cast_events.size() or tick_index < result.tick_events.size():
		var next_cast_time := result.cast_events[cast_index].time_ms if cast_index < result.cast_events.size() else -1
		var next_tick_time := result.tick_events[tick_index].time_ms if tick_index < result.tick_events.size() else -1
		if next_cast_time >= 0 and (next_tick_time < 0 or next_cast_time < next_tick_time):
			lines.append(_cast_line(result.cast_events[cast_index]))
			cast_index += 1
		else:
			var tick := result.tick_events[tick_index]
			tick_index += 1
			if tick.damage > 0.0:
				lines.append(_tick_line(tick))
	return lines


static func _cast_line(event: CombatResolver.CastEvent) -> String:
	var clauses: PackedStringArray = []
	if event.physical_damage > 0.0:
		clauses.append(("CRITS for %.1f" if event.is_crit else "hits for %.1f") % event.physical_damage)
	if event.poison_stacks_applied > 0:
		clauses.append("applies %d poison stack%s" % [
			event.poison_stacks_applied, "" if event.poison_stacks_applied == 1 else "s"
		])
	if event.armor_reduction_applied > 0:
		clauses.append("shreds %d armor" % event.armor_reduction_applied)
	if event.poison_resistance_reduction_applied > 0.0:
		clauses.append("reduces poison resistance by %d%%" % roundi(event.poison_resistance_reduction_applied * 100.0))
	if not event.triggered_skill_names.is_empty():
		clauses.append("triggers %s" % ", ".join(event.triggered_skill_names))
	if clauses.is_empty():
		clauses.append("connects, to no effect")
	var ending := "!" if event.is_crit else ""
	return "[%.1fs] %s %s%s" % [event.time_ms / 1000.0, event.skill.display_name, _join_clauses(clauses), ending]


## "a" / "a and b" / "a, b and c" -- reads as prose instead of a
## comma-separated field list.
static func _join_clauses(clauses: PackedStringArray) -> String:
	if clauses.size() == 1:
		return clauses[0]
	var head := ", ".join(clauses.slice(0, clauses.size() - 1))
	return "%s and %s" % [head, clauses[clauses.size() - 1]]


static func _tick_line(tick: CombatResolver.TickEvent) -> String:
	var stacks_note := "1 stack remains" if tick.stacks_remaining == 1 else "%d stacks remain" % tick.stacks_remaining
	return "[%.1fs] Poison ticks for %.1f -- %s" % [tick.time_ms / 1000.0, tick.damage, stacks_note]
