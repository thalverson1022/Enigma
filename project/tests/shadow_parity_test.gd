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

	print("")
	print("P2:R5:T2 Shadow parity check: OK")
	quit()
