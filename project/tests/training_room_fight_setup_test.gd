extends SceneTree
## Headless P2:R10:T5 check: the target/duration/seed/practice-gold controls
## actually set TrainingRoomState's fight-setup fields, practice gold feeds
## resolved stats live (Bandit Blade's gold-scaling damage becomes testable
## here), and none of it ever touches the real BuildState singleton. The
## target is an adjustable Armor/Poison Resist pair (post-R10 UI-feedback
## pass replaced the earlier 3-preset-monster dropdown), never a killable
## HP target. Run with:
##   godot --headless -s res://tests/training_room_fight_setup_test.gd


func _initialize() -> void:
	var build_state = root.get_node("BuildState")

	var game_root_scene: PackedScene = load("res://scenes/game_root.tscn")
	var game_root = game_root_scene.instantiate()
	root.add_child(game_root)
	await process_frame

	# Real Adventure gold, set after game_root's own startup reset (see
	# training_room_entry_test.gd for why this must happen after, not
	# before).
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.gold = 888
	var real_gold_before: int = build_state.gold

	var title = game_root._current_screen
	title.training_room_pressed.emit()
	await process_frame
	var training_room = game_root._current_screen

	var character_stats_panel = training_room.find_child("CharacterStatsPanel", true, false)
	assert(character_stats_panel != null)

	# -- Defaults: 0 armor, 0% poison resist, 20s, seed 1, 0 practice gold --
	print("default armor=%d (expect 0), poison_resist=%.2f (expect 0.0), duration=%d (expect 20000), seed=%d (expect 1), gold=%d (expect 0)" % [
		training_room._state.selected_target.armor,
		training_room._state.selected_target.poison_resistance,
		training_room._state.duration_ms,
		training_room._state.fight_seed,
		training_room._state.gold,
	])
	assert(training_room._state.selected_target.armor == 0)
	assert(is_equal_approx(training_room._state.selected_target.poison_resistance, 0.0))
	assert(training_room._state.duration_ms == 20000)
	assert(training_room._state.fight_seed == 1)
	assert(training_room._state.gold == 0)

	# -- Target Armor/Poison Resist adjustment --
	training_room._on_target_armor_changed(160)
	training_room._on_target_poison_resist_changed(0.35)
	await process_frame
	print("target after adjustment (expect armor=160, poison_resist=0.35): armor=%d, poison_resist=%.2f" % [
		training_room._state.selected_target.armor, training_room._state.selected_target.poison_resistance
	])
	assert(training_room._state.selected_target.armor == 160)
	assert(is_equal_approx(training_room._state.selected_target.poison_resistance, 0.35))

	# -- Duration --
	training_room._on_duration_changed(35.0)
	await process_frame
	print("duration_ms after setting 35s (expect 35000): %d" % training_room._state.duration_ms)
	assert(training_room._state.duration_ms == 35000)

	# -- Seed, independent of the real Adventure seed --
	build_state.set_adventure_seed(999)
	training_room._on_fight_seed_changed(777.0)
	await process_frame
	print("practice fight_seed=%d (expect 777), real adventure_seed=%d (expect 999, unchanged by the above)" % [
		training_room._state.fight_seed, build_state.adventure_seed
	])
	assert(training_room._state.fight_seed == 777)
	assert(build_state.adventure_seed == 999)

	# -- Practice gold feeds resolved stats live (Bandit Blade gold-scaling,
	# P2:R9:T2), without touching the real BuildState.gold --
	var bandit_blade: GearItem = load("res://data/gear/bandit_blade.tres")
	training_room._state.equip_legendary(bandit_blade)
	await process_frame
	var stats_text_before_gold: String = character_stats_panel._stats_label.text

	training_room._on_practice_gold_changed(200.0)
	await process_frame
	print("practice gold=%d (expect 200), real gold=%d (expect %d, unchanged)" % [
		training_room._state.gold, build_state.gold, real_gold_before
	])
	assert(training_room._state.gold == 200)
	assert(build_state.gold == real_gold_before)
	assert(character_stats_panel._stats_label.text != stats_text_before_gold)

	var resolved := BuildResolver.resolve_stats(
		training_room._state.selected_class, training_room._state.selected_trees,
		training_room._state.selected_talents, training_room._state.equipped_gear(),
		training_room._state.gold
	)
	print("resolved bonus_physical_damage at 200 practice gold (expect 20.0): %.2f" % resolved.bonus_physical_damage)
	assert(is_equal_approx(resolved.bonus_physical_damage, 20.0))

	print("")
	print("Training Room fight setup check: OK")
	quit()
