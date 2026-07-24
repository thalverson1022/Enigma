extends SceneTree
## Focused P2:R5:T2 check for Shadow tree parity: data presence, primary and
## secondary selection, innate poison skill augments, and Shadow-specific
## skills/effects resolving through the normal build/combat path.


func _find_skill(skills: Array[Skill], skill_id: String) -> Skill:
	for skill in skills:
		if skill.id == skill_id:
			return skill
	return null


func _poison_effect_count(skill: Skill) -> int:
	var count := 0
	for effect in skill.effects:
		if effect is PoisonDamageEffect:
			count += 1
	return count


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var assassin: SubclassTree = load("res://data/subclass_trees/assassin.tres")
	var thief: SubclassTree = load("res://data/subclass_trees/thief.tres")
	var shadow: SubclassTree = load("res://data/subclass_trees/shadow.tres")
	assert(rogue.trees.has(shadow))
	assert(shadow.talents.size() == 5)
	assert(shadow.skill_augments.size() == 2)
	assert(shadow.intrinsic_text.contains("ticks for poison damage"))

	build_state.set_class(rogue)
	build_state.select_tree(shadow)
	assert(build_state.selected_trees == [shadow])

	var shadow_skills: Array[Skill] = build_state.unlocked_skills()
	var shadow_stab := _find_skill(shadow_skills, "skill.stab")
	var shadow_heavy := _find_skill(shadow_skills, "skill.heavy_slash")
	assert(shadow_stab != null)
	assert(shadow_heavy != null)
	print("Shadow Stab poison effect count (expect 1): %d" % _poison_effect_count(shadow_stab))
	assert(_poison_effect_count(shadow_stab) == 1)
	assert(_poison_effect_count(shadow_heavy) == 1)
	assert(shadow_stab.poison_stacks_applied == 1)
	assert(shadow_heavy.poison_stacks_applied == 1)

	var early_dummy := Monster.new()
	early_dummy.display_name = "Shadow Intrinsic Dummy"
	early_dummy.hp = 1000000
	early_dummy.armor = 0
	early_dummy.poison_resistance = 0.0
	var shadow_stats := BuildResolver.resolve_stats(rogue, [shadow], [])
	var shadow_stab_result := CombatResolver.resolve([shadow_stab], shadow_stats, early_dummy, 5000, 1)
	var damaging_ticks := shadow_stab_result.tick_events.filter(func(tick): return tick.damage > 0.0)
	print("Shadow Stab poison tick count (expect > 0): %d" % damaging_ticks.size())
	assert(not damaging_ticks.is_empty())
	assert(shadow_stab_result.total_damage > 18.0)

	var stale_base_rotation: Array[Skill] = [rogue.base_skills[0]]
	var resolved_shadow_rotation := BuildResolver.resolve_rotation(stale_base_rotation, build_state.unlocked_skills())
	var mouthy: Monster = load("res://data/monsters/mouthy_drunk.tres")
	var mouthy_result := CombatResolver.resolve(resolved_shadow_rotation, shadow_stats, mouthy, 10000, 1)
	var mouthy_log := CombatResultFormatter.format(mouthy_result, mouthy)
	print("Shadow Stab vs Mouthy Drunk log:")
	print(mouthy_log)
	assert(mouthy_result.cast_events[0].poison_stacks_applied == 1)
	assert(mouthy_result.tick_events.any(func(tick): return tick.damage > 0.0))
	assert(mouthy_log.contains("Stab hits for"))
	assert(mouthy_log.contains("applies 1 poison stack"))
	assert(mouthy_log.contains("Poison ticks for"))

	build_state.select_tree(assassin)
	var assassin_stab := _find_skill(build_state.unlocked_skills(), "skill.stab")
	assert(assassin_stab != null)
	print("Non-Shadow Stab poison effect count (expect 0): %d" % _poison_effect_count(assassin_stab))
	assert(_poison_effect_count(assassin_stab) == 0)

	build_state.select_tree(thief)
	build_state.active_contract = load("res://data/contracts/the_gilded_serpent.tres")
	build_state.current_route_node = load("res://data/contract_routes/gilded_serpent/secondary_rogue_tree.tres")
	build_state.run_phase = BuildState.RunPhase.CONTRACT_ROUTE
	assert(build_state.needs_secondary_subclass_choice())
	assert(build_state.choose_secondary_tree(shadow))
	assert(build_state.selected_trees.has(thief))
	assert(build_state.selected_trees.has(shadow))

	build_state.earned_talent_points = 7
	var exposed: Talent = load("res://data/talents/shadow/exposed_weakness.tres")
	var black_lotus: Talent = load("res://data/talents/shadow/black_lotus.tres")
	var nightblade: Talent = load("res://data/talents/shadow/nightblade_rhythm.tres")
	var umbral: Talent = load("res://data/talents/shadow/umbral_pressure.tres")
	assert(build_state.select_talent(exposed))
	assert(build_state.select_talent(black_lotus))
	assert(build_state.select_talent(nightblade))
	assert(build_state.select_talent(umbral))

	var unlocked: Array[Skill] = build_state.unlocked_skills()
	assert(_find_skill(unlocked, "skill.toxic_flurry") != null)
	assert(_find_skill(unlocked, "skill.killers_mark") != null)

	var stats := BuildResolver.resolve_stats(rogue, build_state.selected_trees, build_state.selected_talents)
	assert(is_equal_approx(stats.poison_damage_per_tick, 8.0))
	assert(is_equal_approx(stats.crit_chance, 0.20))
	assert(is_equal_approx(stats.physical_damage_multiplier, 1.1))
	assert(stats.bonus_poison_stacks == 2)

	var rotation: Array[Skill] = [
		_find_skill(unlocked, "skill.stab"),
		_find_skill(unlocked, "skill.toxic_flurry"),
		_find_skill(unlocked, "skill.killers_mark"),
	]
	var resolved_rotation := BuildResolver.resolve_rotation(rotation, unlocked)
	var monster := Monster.new()
	monster.display_name = "Shadow Test Dummy"
	monster.hp = 1000000
	monster.armor = 0
	monster.poison_resistance = 0.65
	var result := CombatResolver.resolve(resolved_rotation, stats, monster, 6000, 1)
	assert(result.cast_events[0].poison_stacks_applied == 3)
	assert(result.cast_events[1].poison_resistance_reduction_applied > 0.0)
	assert(result.cast_events[2].skill.display_name == "Death Strike")
	assert(result.cast_events[2].physical_damage > 20.0)

	build_state.reset()
	build_state.set_class(rogue)
	build_state.select_tree(shadow)
	var visible_stab: Skill = _find_skill(build_state.unlocked_skills(), "skill.stab")
	assert(visible_stab != null)
	assert(_poison_effect_count(visible_stab) == 1)
	assert(build_state.rotation.is_empty())
	var base_stab_rotation: Array[Skill] = [rogue.base_skills[0]]
	build_state.set_rotation(base_stab_rotation)
	assert(build_state.rotation.size() == 1)
	assert(_poison_effect_count(build_state.rotation[0]) == 1)
	assert(build_state.rotation[0].poison_stacks_applied == 1)
	var stored_shadow_result: CombatResolver.CombatResult = CombatResolver.resolve(build_state.rotation, shadow_stats, mouthy, 12000, 1)
	var stored_shadow_log := CombatResultFormatter.format(stored_shadow_result, mouthy)
	print("Stored Shadow Stab vs Mouthy Drunk log:")
	print(stored_shadow_log)
	assert(stored_shadow_log.contains("applies 1 poison stack"))
	assert(stored_shadow_log.contains("Poison ticks for 8.0"))

	build_state.reset()
	build_state.set_class(rogue)
	build_state.select_tree(thief)
	var pre_shadow_unlocked: Array[Skill] = build_state.unlocked_skills()
	var pre_shadow_rotation: Array[Skill] = [_find_skill(pre_shadow_unlocked, "skill.stab")]
	build_state.set_rotation(pre_shadow_rotation)
	build_state.active_contract = load("res://data/contracts/the_gilded_serpent.tres")
	build_state.current_route_node = load("res://data/contract_routes/gilded_serpent/secondary_rogue_tree.tres")
	build_state.run_phase = BuildState.RunPhase.CONTRACT_ROUTE
	assert(build_state.choose_secondary_tree(shadow))
	var secondary_shadow_rotation: Array[Skill] = BuildResolver.resolve_rotation(build_state.rotation, build_state.unlocked_skills())
	assert(secondary_shadow_rotation.size() == 1)
	assert(_poison_effect_count(secondary_shadow_rotation[0]) == 1)
	var secondary_shadow_stats: PlayerStats = BuildResolver.resolve_stats(rogue, build_state.selected_trees, build_state.selected_talents)
	var secondary_shadow_result: CombatResolver.CombatResult = CombatResolver.resolve(secondary_shadow_rotation, secondary_shadow_stats, mouthy, 12000, 1)
	var secondary_shadow_log := CombatResultFormatter.format(secondary_shadow_result, mouthy)
	print("Secondary Shadow stale Stab vs Mouthy Drunk log:")
	print(secondary_shadow_log)
	assert(secondary_shadow_log.contains("applies 1 poison stack"))
	assert(secondary_shadow_log.contains("Poison ticks for 8.0"))

	print("")
	print("P2:R5:T2 Shadow parity check: OK")
	quit()
