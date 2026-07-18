extends SceneTree
## Focused P2:R5:T3 check for Thief's Opportunity Strikes proc.


func _initialize() -> void:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var thief: SubclassTree = load("res://data/subclass_trees/thief.tres")
	var quick_cut: Skill = load("res://data/skills/quick_cut.tres")
	var stab: Skill = load("res://data/skills/stab.tres")
	var opportunity: Talent = load("res://data/talents/thief/opportunity_strikes.tres")
	assert(rogue != null)
	assert(thief != null)
	assert(quick_cut != null)
	assert(stab != null)
	assert(opportunity != null)
	assert(opportunity.triggered_skill_effects.size() == 1)

	var trigger := opportunity.triggered_skill_effects[0]
	assert(trigger.skill != null)
	assert(trigger.skill.display_name == "Rending Slash")
	assert(is_equal_approx(trigger.chance, 0.2))
	assert(trigger.source_skill_ids.size() == 1)
	assert(trigger.source_skill_ids[0] == "skill.quick_cut")

	var stats := BuildResolver.resolve_stats(rogue, [thief], [opportunity])
	assert(stats.triggered_skill_effects.size() == 1)
	assert(stats.triggered_skill_effects[0].skill.display_name == "Rending Slash")
	assert(stats.triggered_skill_effects[0].source_skill_ids.has("skill.quick_cut"))

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
	assert(quick_result.cast_events.size() == 1)
	assert(quick_result.cast_events[0].skill.id == "skill.quick_cut")
	assert(quick_result.cast_events[0].triggered_skill_names.has("Rending Slash"))
	assert(quick_result.cast_events[0].armor_reduction_applied == 20)
	assert(absf(quick_result.cast_events[0].physical_damage - 26.0) < 0.001)

	var stab_rotation: Array[Skill] = [stab]
	var stab_result: CombatResolver.CombatResult = CombatResolver.resolve(stab_rotation, stats, monster, 1500)
	assert(stab_result.cast_events.size() == 1)
	assert(stab_result.cast_events[0].skill.id == "skill.stab")
	assert(stab_result.cast_events[0].triggered_skill_names.is_empty())
	assert(stab_result.cast_events[0].armor_reduction_applied == 0)

	print("Opportunity Strikes proc check: OK")
	quit()
