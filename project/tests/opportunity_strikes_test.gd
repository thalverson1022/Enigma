extends SceneTree
## Focused P2:R5:T3 check for Bladedancer's Opportunity Strikes proc.

const CombatLogInspectorDataScript := preload("res://scripts/systems/combat_log_inspector_data.gd")

var _failed := false


func _initialize() -> void:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var bladedancer: SubclassTree = load("res://data/subclass_trees/bladedancer.tres")
	var quick_cut: Skill = load("res://data/skills/quick_cut.tres")
	var stab: Skill = load("res://data/skills/stab.tres")
	var opportunity: Talent = load("res://data/talents/bladedancer/opportunity_strikes.tres")
	_require("fixture loads Rogue class", rogue != null, {"path": "res://data/classes/rogue.tres"})
	_require("fixture loads Bladedancer tree", bladedancer != null, {"path": "res://data/subclass_trees/bladedancer.tres"})
	_require("fixture loads Quick Cut", quick_cut != null, {"path": "res://data/skills/quick_cut.tres"})
	_require("fixture loads Stab", stab != null, {"path": "res://data/skills/stab.tres"})
	_require("fixture loads Opportunity Strikes", opportunity != null, {"path": "res://data/talents/bladedancer/opportunity_strikes.tres"})
	_require_equal("opportunity_strikes trigger count", opportunity.triggered_skill_effects.size(), 1, {
		"talent": opportunity.id,
	})

	var trigger := opportunity.triggered_skill_effects[0]
	_require("opportunity_strikes trigger skill exists", trigger.skill != null, {"talent": opportunity.id})
	_require_equal("opportunity_strikes trigger skill", trigger.skill.display_name, "Rending Slash", {
		"talent": opportunity.id,
	})
	_require_approx("opportunity_strikes proc chance", trigger.chance, 0.2, 0.001, {
		"talent": opportunity.id,
	})
	_require_equal("opportunity_strikes source count", trigger.source_skill_ids.size(), 1, {
		"source_skill_ids": trigger.source_skill_ids,
	})
	_require_equal("opportunity_strikes source skill id", trigger.source_skill_ids[0], "skill.quick_cut", {
		"source_skill_ids": trigger.source_skill_ids,
	})

	var stats := BuildResolver.resolve_stats(rogue, [bladedancer], [opportunity])
	_require_equal("resolved Opportunity Strikes trigger count", stats.triggered_skill_effects.size(), 1, {
		"class": rogue.display_name,
		"tree": bladedancer.display_name,
		"talent": opportunity.display_name,
	})
	_require_equal("resolved Opportunity Strikes trigger skill", stats.triggered_skill_effects[0].skill.display_name, "Rending Slash", {
		"trigger": _trigger_summary(stats.triggered_skill_effects[0]),
	})
	_require("resolved Opportunity Strikes keeps source filter", stats.triggered_skill_effects[0].source_skill_ids.has("skill.quick_cut"), {
		"trigger": _trigger_summary(stats.triggered_skill_effects[0]),
	})

	# Force the proc to trigger so the test verifies source filtering and the
	# immediate no-cast-time resolution path without depending on a lucky roll.
	stats.triggered_skill_effects[0].chance = 1.0
	stats.crit_chance = 0.0
	var monster := Monster.new()
	monster.display_name = "Opportunity Dummy"
	monster.hp = 1000000
	monster.armor = 0
	monster.poison_resistance = 0.0

	var quick_rotation: Array[Skill] = [quick_cut]
	var quick_result: CombatResolver.CombatResult = CombatResolver.resolve(quick_rotation, stats, monster, 850)
	_require_equal("opportunity_quick_cut cast count", quick_result.cast_events.size(), 2, {
		"seed": "default",
		"rotation": _skill_names(quick_rotation),
		"monster": _monster_summary(monster),
	})
	var quick_source := quick_result.cast_events[0]
	var quick_proc := quick_result.cast_events[1]
	_require_equal("opportunity_quick_cut source cast", quick_source.skill.id, "skill.quick_cut", {
		"event": _cast_summary(quick_source),
	})
	_require_equal("opportunity_quick_cut proc cast", quick_proc.skill.id, "skill.rending_thrust", {
		"event": _cast_summary(quick_proc),
	})
	_require_equal("opportunity_quick_cut proc kind", quick_proc.cast_kind, "proc", {
		"event": _cast_summary(quick_proc),
	})
	_require("opportunity_quick_cut triggers Rending Slash", quick_source.triggered_skill_names.has("Rending Slash"), {
		"event": _cast_summary(quick_source),
	})
	_require_equal("opportunity_quick_cut applies Shred stacks", quick_proc.shred_stacks_applied, 2, {
		"event": _cast_summary(quick_proc),
	})
	_require_equal("opportunity_quick_cut applies armor reduction", quick_proc.armor_reduction_applied, 20, {
		"event": _cast_summary(quick_proc),
	})
	_require_approx("opportunity_quick_cut total physical damage", quick_result.total_damage, 2.0, 0.001, {
		"events": _cast_summaries(quick_result.cast_events),
	})
	_require_equal("opportunity_quick_cut source contribution count", quick_source.damage_contributions.size(), 1, {
		"contributions": quick_source.damage_contributions,
	})
	_require_equal("opportunity_quick_cut proc contribution count", quick_proc.damage_contributions.size(), 1, {
		"contributions": quick_proc.damage_contributions,
	})
	_require_approx("opportunity_quick_cut base contribution damage", _contribution_damage(quick_source, "Quick Cut"), 1.0, 0.001, {
		"contributions": quick_source.damage_contributions,
	})
	_require_approx("opportunity_quick_cut proc contribution damage", _contribution_damage(quick_proc, "Rending Slash"), 1.0, 0.001, {
		"contributions": quick_proc.damage_contributions,
	})
	_require_equal("opportunity_quick_cut base contribution kind", _contribution_kind(quick_source, "Quick Cut"), "cast", {
		"contributions": quick_source.damage_contributions,
	})
	_require_equal("opportunity_quick_cut proc contribution kind", _contribution_kind(quick_proc, "Rending Slash"), "proc", {
		"contributions": quick_proc.damage_contributions,
	})
	_require_equal("opportunity_quick_cut proc contribution armor", _contribution_armor(quick_proc, "Rending Slash"), 20, {
		"contributions": quick_proc.damage_contributions,
	})

	var inspector := CombatLogInspectorDataScript.build(quick_result, monster)
	_require_approx("opportunity_quick_cut inspector base row", float(_damage_row(inspector["damage_rows"], "Quick Cut").get("damage", -1.0)), 1.0, 0.001, {
		"damage_rows": inspector["damage_rows"],
	})
	_require_approx("opportunity_quick_cut inspector proc row", float(_damage_row(inspector["damage_rows"], "Rending Slash").get("damage", -1.0)), 1.0, 0.001, {
		"damage_rows": inspector["damage_rows"],
	})
	var log_text := CombatResultFormatter.format(quick_result, monster)
	_require("opportunity_quick_cut log has source hit", log_text.contains("Quick Cut hits for 1.0"), {
		"log_text": log_text,
	})
	_require("opportunity_quick_cut source line is labeled Opportunity Strike", log_text.contains("Opportunity Strike Quick Cut"), {
		"log_text": log_text,
	})
	_require("opportunity_quick_cut proc line is labeled Opportunity Strike", log_text.contains("Opportunity Strike Rending Slash"), {
		"log_text": log_text,
	})
	_require("opportunity_quick_cut log no longer calls talent proc Legendary", not log_text.contains("LEGENDARY"), {
		"log_text": log_text,
	})
	_require("opportunity_quick_cut log has proc line", log_text.contains("Rending Slash hits for 1.0"), {
		"log_text": log_text,
	})
	_require("opportunity_quick_cut log has Shred line", log_text.contains("applies 2 Shred"), {
		"log_text": log_text,
	})

	var stab_rotation: Array[Skill] = [stab]
	var stab_result: CombatResolver.CombatResult = CombatResolver.resolve(stab_rotation, stats, monster, 1500)
	_require_equal("opportunity_stab cast count", stab_result.cast_events.size(), 1, {
		"seed": "default",
		"rotation": _skill_names(stab_rotation),
		"monster": _monster_summary(monster),
	})
	_require_equal("opportunity_stab source cast", stab_result.cast_events[0].skill.id, "skill.stab", {
		"event": _cast_summary(stab_result.cast_events[0]),
	})
	_require("opportunity_stab does not trigger filtered proc", stab_result.cast_events[0].triggered_skill_names.is_empty(), {
		"event": _cast_summary(stab_result.cast_events[0]),
		"expected_source_skill_ids": ["skill.quick_cut"],
	})
	_require_equal("opportunity_stab applies no proc armor reduction", stab_result.cast_events[0].armor_reduction_applied, 0, {
		"event": _cast_summary(stab_result.cast_events[0]),
	})

	if _failed:
		print("Opportunity Strikes proc check: FAILED")
		quit(1)
	print("Opportunity Strikes proc check: OK")
	quit()


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


func _contribution_damage(event: CombatResolver.CastEvent, name: String) -> float:
	return float(_contribution(event, name).get("damage", 0.0))


func _contribution_kind(event: CombatResolver.CastEvent, name: String) -> String:
	return String(_contribution(event, name).get("kind", ""))


func _contribution_armor(event: CombatResolver.CastEvent, name: String) -> int:
	return int(_contribution(event, name).get("armor_reduction_applied", 0))


func _contribution(event: CombatResolver.CastEvent, name: String) -> Dictionary:
	for contribution in event.damage_contributions:
		if String(contribution.get("name", "")) == name:
			return contribution
	return {}


func _damage_row(rows: Array, name: String) -> Dictionary:
	for row in rows:
		if String(row.get("name", "")) == name:
			return row
	return {}


func _trigger_summary(trigger: TriggeredSkillEffect) -> Dictionary:
	return {
		"skill": trigger.skill.display_name if trigger.skill != null else "<null>",
		"chance": trigger.chance,
		"source_skill_ids": trigger.source_skill_ids,
	}


func _skill_names(skills: Array[Skill]) -> PackedStringArray:
	var names: PackedStringArray = []
	for skill in skills:
		names.append("%s(%s)" % [skill.display_name, skill.id])
	return names


func _monster_summary(monster: Monster) -> Dictionary:
	return {
		"name": monster.display_name,
		"hp": monster.hp,
		"armor": monster.armor,
		"poison_resistance": monster.poison_resistance,
	}


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
		"physical_damage": event.physical_damage,
		"armor_reduction_applied": event.armor_reduction_applied,
		"triggered_skill_names": event.triggered_skill_names,
		"damage_contributions": event.damage_contributions,
	}
