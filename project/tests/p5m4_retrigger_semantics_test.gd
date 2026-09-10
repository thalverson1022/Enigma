extends SceneTree
## Focused P5M4-T9 checks for retriggers resolving as full new casts.

var _failed := false


func _initialize() -> void:
	_check_proc_is_separate_cast_with_fresh_rng()
	_check_recursive_retrigger_cap()
	_check_source_filtering()
	if _failed:
		print("P5M4 retrigger semantics check: FAILED")
		quit(1)
	print("P5M4 retrigger semantics check: OK")
	quit()


func _check_proc_is_separate_cast_with_fresh_rng() -> void:
	var source := _make_physical_skill("skill.test_source", "Source Hit", 5.0)
	var proc := _make_physical_skill("skill.test_proc", "Proc Hit", 7.0)
	var stats := _make_stats()
	stats.crit_chance = 0.5
	stats.triggered_skill_effects = [_make_trigger(proc, 1.0, PackedStringArray(["skill.test_source"]))]
	var monster := _make_monster()
	var result := CombatResolver.resolve([source], stats, monster, 1000, 11)

	_require_equal("separate proc event count", result.cast_events.size(), 2, {
		"events": _cast_summaries(result.cast_events),
	})
	var source_event := result.cast_events[0]
	var proc_event := result.cast_events[1]
	_require_equal("source cast kind", source_event.cast_kind, "cast", {"event": _cast_summary(source_event)})
	_require_equal("proc cast kind", proc_event.cast_kind, "proc", {"event": _cast_summary(proc_event)})
	_require_equal("proc source id", proc_event.trigger_source_skill_id, source.id, {"event": _cast_summary(proc_event)})
	_require_equal("proc depth", proc_event.retrigger_depth, 1, {"event": _cast_summary(proc_event)})
	_require_equal("proc timing", proc_event.time_ms, source_event.time_ms, {"events": _cast_summaries(result.cast_events)})
	_require("source records triggered name", source_event.triggered_skill_names.has("Proc Hit"), {
		"event": _cast_summary(source_event),
	})
	_require_equal("source contribution stays source-only", source_event.damage_contributions.size(), 1, {
		"event": _cast_summary(source_event),
	})
	_require_equal("proc contribution is proc kind", String(proc_event.damage_contributions[0].get("kind", "")), "proc", {
		"event": _cast_summary(proc_event),
	})

	var expected := _expected_source_then_proc_rng(11, stats.weapon_damage_min, stats.weapon_damage_max, stats.crit_chance)
	_require_equal("source weapon roll uses first cast RNG", source_event.weapon_damage_roll, int(expected["source_roll"]), expected)
	_require_equal("proc weapon roll uses fresh proc RNG", proc_event.weapon_damage_roll, int(expected["proc_roll"]), expected)
	_require_equal("source crit uses source crit RNG", source_event.is_crit, bool(expected["source_crit"]), expected)
	_require_equal("proc crit uses proc crit RNG", proc_event.is_crit, bool(expected["proc_crit"]), expected)
	_require_approx("total damage sums separate events", result.total_damage, source_event.physical_damage + proc_event.physical_damage, 0.001, {
		"events": _cast_summaries(result.cast_events),
	})


func _check_recursive_retrigger_cap() -> void:
	var skill := _make_physical_skill("skill.self_proc", "Self Proc", 1.0)
	var stats := _make_stats()
	stats.triggered_skill_effects = [_make_trigger(skill, 1.0, PackedStringArray(["skill.self_proc"]))]
	var result := CombatResolver.resolve([skill], stats, _make_monster(), 1000, 3)
	var expected_count := CombatResolver.MAX_RETRIGGER_CHAIN_DEPTH + 1
	_require_equal("recursive proc cap event count", result.cast_events.size(), expected_count, {
		"cap": CombatResolver.MAX_RETRIGGER_CHAIN_DEPTH,
		"events": _cast_summaries(result.cast_events),
	})
	_require("last proc records cap reached", result.cast_events[result.cast_events.size() - 1].retrigger_cap_reached, {
		"event": _cast_summary(result.cast_events[result.cast_events.size() - 1]),
	})
	_require_equal("last proc depth equals cap", result.cast_events[result.cast_events.size() - 1].retrigger_depth, CombatResolver.MAX_RETRIGGER_CHAIN_DEPTH, {
		"event": _cast_summary(result.cast_events[result.cast_events.size() - 1]),
	})


func _check_source_filtering() -> void:
	var source_a := _make_physical_skill("skill.source_a", "Source A", 3.0)
	var source_b := _make_physical_skill("skill.source_b", "Source B", 3.0)
	var proc_a := _make_physical_skill("skill.proc_a", "Proc A", 4.0)
	var proc_b := _make_physical_skill("skill.proc_b", "Proc B", 4.0)
	var stats := _make_stats()
	stats.triggered_skill_effects = [
		_make_trigger(proc_a, 1.0, PackedStringArray(["skill.source_a"])),
		_make_trigger(proc_b, 1.0, PackedStringArray(["skill.source_b"])),
	]
	var result := CombatResolver.resolve([source_a, source_b], stats, _make_monster(), 2000, 5)
	_require_equal("source-filtered event count", result.cast_events.size(), 4, {
		"events": _cast_summaries(result.cast_events),
	})
	_require_equal("source A proc skill", result.cast_events[1].skill.id, "skill.proc_a", {
		"events": _cast_summaries(result.cast_events),
	})
	_require_equal("source B proc skill", result.cast_events[3].skill.id, "skill.proc_b", {
		"events": _cast_summaries(result.cast_events),
	})
	_require("source A does not trigger proc B", not result.cast_events[0].triggered_skill_names.has("Proc B"), {
		"event": _cast_summary(result.cast_events[0]),
	})
	_require("source B does not trigger proc A", not result.cast_events[2].triggered_skill_names.has("Proc A"), {
		"event": _cast_summary(result.cast_events[2]),
	})


func _make_physical_skill(id: String, display_name: String, amount: float) -> Skill:
	var skill := Skill.new()
	skill.id = id
	skill.display_name = display_name
	skill.base_execution_ms = 1000
	skill.min_execution_ms = 500
	var effect := PhysicalDamageEffect.new()
	effect.amount = amount
	skill.effects = [effect]
	return skill


func _make_trigger(skill: Skill, chance: float, source_ids: PackedStringArray) -> TriggeredSkillEffect:
	var trigger := TriggeredSkillEffect.new()
	trigger.skill = skill
	trigger.chance = chance
	trigger.source_skill_ids = source_ids
	return trigger


func _make_stats() -> PlayerStats:
	var stats := PlayerStats.new()
	stats.attack_speed = 0.0
	stats.crit_chance = 0.0
	stats.crit_multiplier = 2.0
	stats.poison_damage_per_tick = 0.0
	stats.weapon_damage_min = 10
	stats.weapon_damage_max = 30
	return stats


func _make_monster() -> Monster:
	var monster := Monster.new()
	monster.display_name = "Retrigger Dummy"
	monster.hp = 1000000
	monster.armor = 0
	monster.poison_resistance = 0.0
	return monster


func _expected_source_then_proc_rng(seed: int, min_roll: int, max_roll: int, crit_chance: float) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	rng.randf() # source dodge
	var source_roll := rng.randi_range(min_roll, max_roll)
	var source_crit := rng.randf() < crit_chance
	rng.randf() # proc chance
	rng.randf() # proc dodge
	var proc_roll := rng.randi_range(min_roll, max_roll)
	var proc_crit := rng.randf() < crit_chance
	return {
		"source_roll": source_roll,
		"source_crit": source_crit,
		"proc_roll": proc_roll,
		"proc_crit": proc_crit,
	}


func _require(label: String, condition: bool, context: Dictionary = {}) -> void:
	if condition:
		return
	_failed = true
	print("FAILED: %s" % label)
	for key in context.keys():
		print("  %s: %s" % [key, str(context[key])])


func _require_equal(label: String, actual: Variant, expected: Variant, context: Dictionary = {}) -> void:
	context["expected"] = expected
	context["actual"] = actual
	_require(label, actual == expected, context)


func _require_approx(label: String, actual: float, expected: float, tolerance: float, context: Dictionary = {}) -> void:
	context["expected"] = expected
	context["actual"] = actual
	context["tolerance"] = tolerance
	_require(label, absf(actual - expected) <= tolerance, context)


func _cast_summaries(events: Array) -> Array:
	var summaries: Array = []
	for event in events:
		summaries.append(_cast_summary(event))
	return summaries


func _cast_summary(event: CombatResolver.CastEvent) -> Dictionary:
	return {
		"time_ms": event.time_ms,
		"skill": "%s(%s)" % [event.skill.display_name, event.skill.id],
		"cast_kind": event.cast_kind,
		"trigger_source_skill_id": event.trigger_source_skill_id,
		"retrigger_depth": event.retrigger_depth,
		"retrigger_cap_reached": event.retrigger_cap_reached,
		"physical_damage": event.physical_damage,
		"is_crit": event.is_crit,
		"triggered_skill_names": event.triggered_skill_names,
		"weapon_damage_roll": event.weapon_damage_roll,
		"weapon_damage_rolls": event.weapon_damage_rolls,
		"damage_contributions": event.damage_contributions,
	}
