extends SceneTree


func _initialize() -> void:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var thief: SubclassTree = load("res://data/subclass_trees/thief.tres")
	var bladedancer: SubclassTree = load("res://data/subclass_trees/bladedancer.tres")
	var steal: Skill = load("res://data/skills/steal.tres")
	_require(rogue != null, "Expected Rogue class data.")
	_require(thief != null, "Expected Thief tree data.")
	_require(bladedancer != null, "Expected Bladedancer tree data.")
	_require(steal != null, "Expected Steal skill data.")
	_require(thief.id == "tree.thief", "Expected new Thief tree id.")
	_require(thief.display_name == "Thief", "Expected Thief display name.")
	_require(thief.icon != null, "Expected Thief to keep the old icon.")
	_require(bladedancer.id == "tree.bladedancer", "Expected Bladedancer to remain separate.")
	_require(rogue.trees.has(thief), "Expected Rogue to offer Thief.")
	_require(rogue.trees.has(bladedancer), "Expected Rogue to keep Bladedancer.")
	_require(steal.base_execution_ms == 1300, "Expected Steal cast time to be 1.3s.")

	var stats := BuildResolver.resolve_stats(rogue, [thief], [], [], 0)
	_require(is_equal_approx(stats.gold_reward_multiplier, 1.0), "Expected Thief intrinsic not to grant bonus gold rewards.")

	var unlocked_without_talent := BuildResolver.resolve_unlocked_skills(rogue, [thief], [], [])
	_require(_find_skill(unlocked_without_talent, "skill.steal") != null, "Expected Thief intrinsic to unlock Steal.")

	var sticky_fingers := _find_talent(thief, "talent.sticky_fingers")
	_require(sticky_fingers != null, "Expected Sticky Fingers talent.")
	var sticky_stats := BuildResolver.resolve_stats(rogue, [thief], [sticky_fingers], [], 0)
	_require(is_equal_approx(sticky_stats.gold_reward_multiplier, 1.3), "Expected Sticky Fingers to grant 30% gold rewards.")
	var keen_eye := _find_talent(thief, "talent.keen_eye")
	_require(keen_eye != null, "Expected Keen Eye talent.")
	var keen_stats := BuildResolver.resolve_stats(rogue, [thief], [keen_eye], [], 0)
	_require(is_equal_approx(keen_stats.physical_damage_multiplier, 1.1), "Expected Keen Eye to grant 10% Physical Damage.")
	_require(is_equal_approx(keen_stats.crit_chance, rogue.base_stats.crit_chance), "Expected Keen Eye not to grant Crit Chance anymore.")
	_require(StatModifierFormatter.format(keen_eye.stat_modifiers[0]) == "x10% Physical Damage", "Expected Keen Eye to format as percent Physical Damage.")

	var monster := Monster.new()
	monster.display_name = "Coin Dummy"
	monster.hp = 100000
	monster.armor = 0
	var steal_stats := BuildResolver.resolve_stats(rogue, [thief], [], [], 0)
	steal_stats.crit_chance = 1.0
	var steal_result := CombatResolver.resolve([steal], steal_stats, monster, 1400, 1)
	_require(steal_result.cast_events.size() == 1, "Expected one Steal cast.")
	_require(steal_result.cast_events[0].is_crit, "Expected forced Steal crit.")
	_require(is_equal_approx(steal_result.cast_events[0].physical_damage, 38.0), "Expected Steal to deal 19 base damage before crit scaling.")
	_require(steal_result.cast_events[0].gold_stolen == 5, "Expected baseline Steal crit to steal 5g.")
	_require(steal_result.gold_stolen == 5, "Expected result to aggregate stolen gold.")

	var sticky_steal_stats := BuildResolver.resolve_stats(rogue, [thief], [sticky_fingers], [], 0)
	sticky_steal_stats.crit_chance = 1.0
	var sticky_steal_result := CombatResolver.resolve([steal], sticky_steal_stats, monster, 1400, 1)
	_require(sticky_steal_result.gold_stolen == 6, "Expected Sticky Fingers to floor 5g steal with 30% bonus to 6g.")

	var big_score := _find_talent(thief, "talent.big_score")
	var silvered := _find_talent(thief, "talent.silvered_blade")
	var gilded := _find_talent(thief, "talent.gilded_blade")
	_require(big_score != null and silvered != null and gilded != null, "Expected higher-tier Thief talents.")
	_require(big_score.cost == 2, "Expected level 3 Thief talent to cost 2 points.")
	_require(gilded.cost == 3, "Expected level 4 Thief talent to cost 3 points.")
	var snowball_stats := BuildResolver.resolve_stats(rogue, [thief], [sticky_fingers, silvered, big_score], [], 0)
	snowball_stats.crit_chance = 0.0
	snowball_stats.gold_reward_multiplier = 1.0
	var snowball_result := CombatResolver.resolve([steal], snowball_stats, monster, 4200, 1)
	_require(snowball_result.gold_stolen == 0, "Expected stolen-gold crit chance to reset at fight start.")
	snowball_stats.crit_chance = 1.0
	var seeded_result := CombatResolver.resolve([steal], snowball_stats, monster, 4200, 1)
	_require(seeded_result.gold_stolen >= 5, "Expected a forced opening crit to start the stolen-gold snowball.")

	var rich_stats := BuildResolver.resolve_stats(rogue, [thief], [sticky_fingers, silvered, big_score, gilded], [], 100)
	rich_stats.crit_chance = 1.0
	var rich_result := CombatResolver.resolve([steal], rich_stats, monster, 1400, 1)
	_require(is_equal_approx(rich_result.cast_events[0].physical_damage, 74.1), "Expected current-gold crit damage scaling to affect Steal.")

	var practice_class := ClassDef.new()
	practice_class.id = "class.test_thief"
	practice_class.display_name = "Test Thief"
	practice_class.base_stats = PlayerStats.new()
	practice_class.base_stats.crit_chance = 1.0
	practice_class.base_stats.crit_multiplier = 2.0
	practice_class.trees = [thief]
	var practice_state := TrainingRoomState.new()
	practice_state.selected_class = practice_class
	practice_state.selected_trees = [thief]
	practice_state.selected_talents = [sticky_fingers]
	practice_state.rotation = [steal]
	practice_state.build_locked = true
	practice_state.duration_ms = 1300
	practice_state.run_fight()
	_require(practice_state.last_result != null, "Expected Practice Room state to resolve the Steal fight.")
	_require(practice_state.last_result.gold_stolen == 6, "Expected Practice Room Steal fight to record stolen gold.")
	_require(practice_state.gold == 0, "Expected Practice Room stolen gold to wait for playback before changing practice gold.")
	practice_state.add_practice_combat_gold(practice_state.last_result.gold_stolen)
	_require(practice_state.gold == 6, "Expected Practice Room stolen gold to add to practice gold.")
	_require(practice_state.combat_stolen_gold == 6, "Expected Practice Room stolen gold to feed live Big Score display.")

	var stat_state := TrainingRoomState.new()
	stat_state.selected_class = practice_class
	stat_state.selected_trees = [thief]
	stat_state.gold = 100
	var panel_script := load("res://scenes/combat/character_stats_panel.gd")
	var stats_panel = panel_script.new()
	stats_panel.state = stat_state
	root.add_child(stats_panel)
	await process_frame

	stat_state.selected_talents = [sticky_fingers]
	stats_panel._refresh()
	var stats_text: String = stats_panel._stats_label.text
	_require(not stats_text.contains("Crit Chance: 100% [color=#"), "Expected Sticky Fingers not to show the Big Score crit chance bonus.")
	_require(not stats_text.contains("Crit Multiplier: 200% [color=#"), "Expected Sticky Fingers not to show the Gilded Blade crit damage bonus.")

	stat_state.selected_talents = [big_score]
	stats_panel._refresh()
	stats_text = stats_panel._stats_label.text
	_require(stats_text.contains("Crit Chance: 100%% [color=#%s]+0%%[/color]" % UIColors.TEXT_GOLD.to_html(false)), "Expected Big Score bonus to show as gold-colored current stolen-gold crit chance text.")
	_require(not stats_text.contains("Crit Multiplier: 200% [color=#"), "Expected Big Score not to show the Gilded Blade crit damage bonus.")

	stat_state.selected_talents = [gilded]
	stats_panel._refresh()
	stats_text = stats_panel._stats_label.text
	_require(not stats_text.contains("Crit Chance: 100% [color=#"), "Expected Gilded Blade not to show the Big Score crit chance bonus.")
	_require(stats_text.contains("Crit Multiplier: 200%% [color=#%s]+100%%[/color]" % UIColors.TEXT_GOLD.to_html(false)), "Expected Gilded Blade bonus to show as gold-colored current-gold crit damage text.")

	stat_state.selected_talents = [sticky_fingers, silvered, big_score, gilded]
	stats_panel._refresh()
	stats_text = stats_panel._stats_label.text
	_require(stats_text.contains("Crit Chance: 100%% [color=#%s]+0%%[/color]" % UIColors.TEXT_GOLD.to_html(false)), "Expected Big Score bonus to show as gold-colored current stolen-gold crit text.")
	_require(stats_text.contains("Crit Multiplier: 200%% [color=#%s]+100%%[/color]" % UIColors.TEXT_GOLD.to_html(false)), "Expected Gilded Blade bonus to show as gold-colored current-gold crit damage text.")
	stat_state.add_practice_combat_gold(6)
	await process_frame
	stats_text = stats_panel._stats_label.text
	_require(stats_text.contains("Crit Chance: 100%% [color=#%s]+6%%[/color]" % UIColors.TEXT_GOLD.to_html(false)), "Expected Big Score display to increase from stolen gold.")
	_require(stats_text.contains("Crit Multiplier: 200%% [color=#%s]+106%%[/color]" % UIColors.TEXT_GOLD.to_html(false)), "Expected Gilded Blade display to follow increased practice gold.")
	stats_panel.queue_free()

	var build_state = root.get_node("BuildState")
	build_state.reset()
	build_state.set_class(rogue)
	build_state.select_tree(thief)
	_require(build_state.modified_gold_reward(12) == 12, "Expected Thief intrinsic not to change standard reward gold.")
	build_state.record_combat_stolen_gold(6)
	_require(build_state.gold == 6, "Expected Adventure Steal gold to enter the player's stash.")
	_require(build_state.combat_stolen_gold == 6, "Expected stolen gold to feed the in-fight Big Score display.")
	build_state.finish_fight(true)
	_require(build_state.combat_stolen_gold == 0, "Expected stolen-gold crit chance display to reset when the fight ends.")
	build_state.reset()
	build_state.set_class(rogue)
	build_state.select_tree(thief)
	build_state.add_talent_points(1)
	build_state.select_talent(sticky_fingers)
	_require(build_state.modified_gold_reward(12) == 15, "Expected Sticky Fingers reward gold to floor 12g * 1.3 to 15g.")
	build_state.choose_current_tavern_encounter()
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	_require(build_state.claim_current_reward(), "Expected monster kill reward claim to succeed with Sticky Fingers.")
	_require(build_state.gold == 15, "Expected Sticky Fingers to apply to actual monster kill reward gold, not only the preview helper.")
	build_state.reset()

	print("Thief subclass check: OK")
	quit()


func _find_talent(tree: SubclassTree, talent_id: String) -> Talent:
	for talent in tree.talents:
		if talent.id == talent_id:
			return talent
	return null


func _find_skill(skills: Array[Skill], skill_id: String) -> Skill:
	for skill in skills:
		if skill.id == skill_id:
			return skill
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
