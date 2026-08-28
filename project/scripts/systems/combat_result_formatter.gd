class_name CombatResultFormatter
extends RefCounted
## Renders a CombatResolver.CombatResult as a human-readable fight
## narrative: a header describing the matchup, a single chronological
## timeline (casts and poison ticks merged, in seconds), and a summary
## verdict. Zero-damage poison ticks (cadence beats with no stacks active)
## are noise and get skipped.


static func format(result: CombatResolver.CombatResult, monster: Monster) -> String:
	var lines: PackedStringArray = []
	lines.append("Target:")
	lines.append("  %s -- %d HP, %d Armor, %.0f%% Resist" % [
		monster.display_name, monster.hp, monster.armor, monster.poison_resistance * 100.0
	])
	lines.append("  Combat window: %.0fs" % (result.duration_ms / 1000.0))
	lines.append("")
	lines.append("Timeline:")

	var timeline := _timeline(result)
	if timeline.is_empty():
		lines.append("  Nothing happened -- no skills were cast.")
	else:
		for line in timeline:
			lines.append("  %s" % line)

	lines.append("")
	lines.append("Summary:")
	lines.append("  Damage: %.1f in %.0fs -- %.1f DPS." % [
		result.total_damage, result.duration_ms / 1000.0, result.dps
	])
	if result.is_win:
		lines.append("  Result: VICTORY! %s is defeated (needed %d damage)." % [monster.display_name, monster.hp])
	else:
		lines.append("  Result: DEFEAT -- fell %.1f damage short of the %d needed." % [
			float(monster.hp) - result.total_damage, monster.hp
		])
	return "\n".join(lines)


## Practice Room's own result narrative -- same timeline/summary shape as
## format() above, but with no HP/win-loss framing at all: Practice Room only
## measures damage dealt against a target's Armor/Resist in a fixed
## window, it never checks whether the target is "defeated" (post-R10
## UI-feedback pass removed the HP concept from Practice Room entirely).
static func format_practice(result: CombatResolver.CombatResult, monster: Monster) -> String:
	var lines: PackedStringArray = []
	lines.append("Practice Target:")
	lines.append("  %s -- %d Armor, %.0f%% Resist" % [
		monster.display_name, monster.armor, monster.poison_resistance * 100.0
	])
	lines.append("  Combat window: %.0fs" % (result.duration_ms / 1000.0))
	lines.append("")
	lines.append("Timeline:")

	var timeline := _timeline(result)
	if timeline.is_empty():
		lines.append("  Nothing happened -- no skills were cast.")
	else:
		for line in timeline:
			lines.append("  %s" % line)

	lines.append("")
	lines.append("Summary:")
	lines.append("  Damage: %.1f in %.0fs -- %.1f DPS." % [
		result.total_damage, result.duration_ms / 1000.0, result.dps
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
			if tick.damage > 0.0 or tick.absorbed_amount > 0.0:
				lines.append(_tick_line(tick))
	return lines


## `>>> ` prefixes any line where a Legendary effect actually fired
## (Bejeweled Push Dagger's minimum-cast-time proc, or a triggered skill
## like Mithril Karambit's) -- user-requested, so these are easy to spot
## while scanning the log instead of reading identically to an ordinary hit.
static func _cast_line(event: CombatResolver.CastEvent) -> String:
	if event.was_interrupted:
		var interrupt_note := "skipped" if event.interrupt_skipped else "interrupted"
		var skill_name := event.skill.display_name if event.skill != null else "Attack"
		var skip_note := ""
		if event.interrupt_triggered and event.interrupt_skip_count_applied > 0:
			skip_note = " (%d future skip%s)" % [
				event.interrupt_skip_count_applied,
				"" if event.interrupt_skip_count_applied == 1 else "s",
			]
		return "[%.1fs] INTERRUPT %s %s%s" % [event.time_ms / 1000.0, skill_name, interrupt_note, skip_note]
	var clauses: PackedStringArray = []
	var source_damage := _contribution_damage(event, "cast")
	var source_crit := _contribution_crit(event, "cast")
	if source_damage <= 0.0 and event.damage_contributions.is_empty():
		source_damage = event.physical_damage
		source_crit = event.is_crit
	if source_damage > 0.0:
		clauses.append(("CRITS for %.1f" if source_crit else "hits for %.1f") % source_damage)
	elif event.blocked_amount > 0.0:
		clauses.append("hits for 0.0 (blocked %.1f)" % event.blocked_amount)
	if event.poison_stacks_applied > 0:
		clauses.append("applies %d poison stack%s" % [
			event.poison_stacks_applied, "" if event.poison_stacks_applied == 1 else "s"
		])
	if event.armor_reduction_applied > 0:
		clauses.append("shreds %d armor" % event.armor_reduction_applied)
	if event.poison_resistance_reduction_applied > 0.0:
		clauses.append("reduces resistance by %d%%" % roundi(event.poison_resistance_reduction_applied * 100.0))
	if event.min_cast_time_proc_applied:
		clauses.append("procs at minimum cast speed")
	if event.stun_duration_ms > 0:
		clauses.append("triggers stun for %s" % _format_stun_duration(event.stun_duration_ms))
	var trigger_clauses := _triggered_contribution_clauses(event)
	if not trigger_clauses.is_empty():
		clauses.append_array(trigger_clauses)
	elif not event.triggered_skill_names.is_empty():
		clauses.append("triggers %s" % ", ".join(event.triggered_skill_names))
	if clauses.is_empty():
		clauses.append("connects, to no effect")
	var ending := "!" if event.is_crit else ""
	var is_legendary_proc := event.min_cast_time_proc_applied or not event.triggered_skill_names.is_empty()
	var event_type := "LEGENDARY" if is_legendary_proc else "CAST"
	var marker := ">>> " if is_legendary_proc else ""
	return "%s[%.1fs] %-9s %s %s%s" % [marker, event.time_ms / 1000.0, event_type, event.skill.display_name, _join_clauses(clauses), ending]


static func _contribution_damage(event: CombatResolver.CastEvent, kind: String) -> float:
	var total := 0.0
	for contribution in event.damage_contributions:
		if String(contribution.get("kind", "")) == kind:
			total += float(contribution.get("damage", 0.0))
	return total


static func _contribution_crit(event: CombatResolver.CastEvent, kind: String) -> bool:
	for contribution in event.damage_contributions:
		if String(contribution.get("kind", "")) == kind and bool(contribution.get("is_crit", false)):
			return true
	return false


static func _triggered_contribution_clauses(event: CombatResolver.CastEvent) -> PackedStringArray:
	var clauses: PackedStringArray = []
	for contribution in event.damage_contributions:
		if String(contribution.get("kind", "")) != "proc":
			continue
		var name := String(contribution.get("name", "Triggered Skill"))
		var damage := float(contribution.get("damage", 0.0))
		var text := "triggers %s" % name
		if damage > 0.0:
			text += (" for %.1f" if not bool(contribution.get("is_crit", false)) else " for %.1f (crit)") % damage
		clauses.append(text)
	return clauses


static func _format_stun_duration(duration_ms: int) -> String:
	var seconds := float(duration_ms) / 1000.0
	if is_equal_approx(seconds, roundf(seconds)):
		return "%ds" % int(roundf(seconds))
	return "%.1fs" % seconds


## "a" / "a and b" / "a, b and c" -- reads as prose instead of a
## comma-separated field list.
static func _join_clauses(clauses: PackedStringArray) -> String:
	if clauses.size() == 1:
		return clauses[0]
	var head := ", ".join(clauses.slice(0, clauses.size() - 1))
	return "%s and %s" % [head, clauses[clauses.size() - 1]]


static func _tick_line(tick: CombatResolver.TickEvent) -> String:
	var stacks_note := "1 stack remains" if tick.stacks_remaining == 1 else "%d stacks remain" % tick.stacks_remaining
	var absorb_note := " (absorbed %.1f)" % tick.absorbed_amount if tick.absorbed_amount > 0.0 else ""
	return "[%.1fs] DOT       Poison ticks for %.1f%s -- %s" % [tick.time_ms / 1000.0, tick.damage, absorb_note, stacks_note]
