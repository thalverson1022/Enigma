extends SceneTree
## Headless check for P2:R6:T4's save/load UI hooks. Drives the real
## title/game_root scene tree the same way real clicks would:
##   - No save: Continue is visible but disabled (grayed out, not hidden --
##     P2:R7 second playtest-feedback pass, item 1), and Adventure Mode
##     starts a fresh run with no confirmation. The menu lists Training Room
##     (P2:R10 practice mode, enabled), then Adventure Mode, then Continue.
##   - Save & Quit persists the run and returns to Title, where Continue is
##     now enabled.
##   - Continue loads the save and jumps straight to the combat dashboard
##     (skipping class/subclass select), restoring the saved build.
##   - Adventure Mode with a save present asks for discard confirmation
##     before starting a new run, and clears the old save.
##   - Abandon Run (the renamed former "Return to Main Menu" button) deletes
##     any save on confirmation.
## Run with:
##   godot --headless -s res://tests/save_load_ui_test.gd
## Same headless-only caveat as every prior UI milestone -- no rendered
## click-through available in this environment.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	SaveSystem.delete_save()

	var game_root_scene: PackedScene = load("res://scenes/game_root.tscn")
	var game_root = game_root_scene.instantiate()
	root.add_child(game_root)
	await process_frame

	# -- Fresh start: Continue is present but disabled (not hidden), Adventure
	# Mode has no save to warn about --
	var title = game_root._current_screen
	var continue_button := _find_button(title, "Continue Adventure")
	assert(continue_button != null)
	print("continue button visible with no save (expect true): %s" % continue_button.visible)
	assert(continue_button.visible)
	print("continue button disabled with no save (expect true): %s" % continue_button.disabled)
	assert(continue_button.disabled)

	var adventure_button := _find_button(title, "Adventure Mode")
	assert(adventure_button != null)
	assert(title.selected_seed() == BuildState.DEFAULT_ADVENTURE_SEED)
	title._seed_spin_box.value = 314159
	assert(title.selected_seed() == 314159)
	assert(_nearest_panel(title._seed_spin_box) != null)
	assert(_nearest_panel(title._seed_spin_box) != _nearest_panel(adventure_button))

	# -- Menu order: Training Room (P2:R10, enabled), Adventure Mode,
	# Continue/Resume (P2:R7 second playtest-feedback pass, item 1) --
	var training_button := _find_button(title, "Training Room")
	assert(training_button != null)
	assert(not training_button.disabled)
	assert(not training_button.tooltip_text.is_empty())
	assert(training_button.get_index() < adventure_button.get_index())
	assert(adventure_button.get_index() < continue_button.get_index())
	adventure_button.pressed.emit()
	await process_frame
	# No save existed, so pressing Adventure Mode should proceed straight to
	# class select rather than popping a confirmation dialog.
	assert(game_root._current_screen != title)
	assert(build_state.adventure_seed == 314159)

	var class_select = game_root._current_screen
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	class_select._on_class_selected(rogue)
	class_select.advanced.emit()
	await process_frame

	var subclass_select = game_root._current_screen
	var thief: SubclassTree = rogue.trees[1]
	subclass_select._on_tree_selected(thief)
	subclass_select.advanced.emit()
	await process_frame

	var combat_screen = game_root._current_screen
	build_state.add_gold(35)
	# Fresh run: the intro story overlay gates the map on the very first
	# Tavern choice (see combat_screen.gd's _show_initial_map_if_needed()).
	assert(combat_screen._story_overlay.visible)
	var story_proceed_button: Button = combat_screen._story_overlay.find_child("StoryProceedButton", true, false)
	story_proceed_button.pressed.emit()
	await process_frame
	assert(combat_screen._map_overlay.visible)
	combat_screen._map_node_buttons[0].pressed.emit()
	await process_frame
	combat_screen._map_proceed_button.pressed.emit()
	await process_frame
	print("pre-save gold/seed: %d / %d" % [build_state.gold, build_state.adventure_seed])

	# -- Save & Quit persists the run and returns to Title --
	var save_quit_button := _find_button(combat_screen, "Save & Quit")
	assert(save_quit_button != null)
	save_quit_button.pressed.emit()
	await process_frame
	print("has_save after Save & Quit (expect true): %s" % SaveSystem.has_save())
	assert(SaveSystem.has_save())
	assert(game_root._current_screen != combat_screen)

	var title_after_save = game_root._current_screen
	var continue_button_2 := _find_button(title_after_save, "Continue Adventure")
	assert(continue_button_2 != null)
	print("continue button enabled after save (expect true): %s" % (not continue_button_2.disabled))
	assert(continue_button_2.visible)
	assert(not continue_button_2.disabled)

	# -- Adventure Mode now warns before discarding the save --
	var adventure_button_2 := _find_button(title_after_save, "Adventure Mode")
	adventure_button_2.pressed.emit()
	await process_frame
	print("new-game confirm dialog visible (expect true): %s" % title_after_save._new_game_confirm_dialog.visible)
	assert(title_after_save._new_game_confirm_dialog.visible)
	assert(game_root._current_screen == title_after_save)
	# Cancel out without confirming -- the save must survive.
	title_after_save._new_game_confirm_dialog.hide()
	assert(SaveSystem.has_save())

	# -- Continue loads the save and jumps straight to the dashboard --
	var continue_button_3 := _find_button(title_after_save, "Continue Adventure")
	continue_button_3.pressed.emit()
	await process_frame
	print("current screen after Continue is combat screen (expect true): %s" % (game_root._current_screen != title_after_save))
	assert(game_root._current_screen != title_after_save)
	var resumed_screen = game_root._current_screen
	assert(resumed_screen.has_method("_on_fight_pressed"))
	print("restored gold/seed (expect 35 / 314159): %d / %d" % [build_state.gold, build_state.adventure_seed])
	assert(build_state.gold == 35)
	assert(build_state.adventure_seed == 314159)
	assert(build_state.selected_class == rogue)
	assert(build_state.selected_trees.size() == 1)
	assert(build_state.selected_trees[0].display_name == "Thief")

	# -- Abandon Run deletes the save --
	var abandon_button := _find_button(resumed_screen, "Abandon Run")
	assert(abandon_button != null)
	abandon_button.pressed.emit()
	await process_frame
	assert(resumed_screen._confirm_dialog.visible)
	resumed_screen._confirm_dialog.confirmed.emit()
	await process_frame
	print("has_save after Abandon Run (expect false): %s" % SaveSystem.has_save())
	assert(not SaveSystem.has_save())
	assert(game_root._current_screen != resumed_screen)

	var final_title = game_root._current_screen
	var continue_button_4 := _find_button(final_title, "Continue Adventure")
	assert(continue_button_4 != null)
	print("continue button disabled after abandon (expect true): %s" % continue_button_4.disabled)
	assert(continue_button_4.visible)
	assert(continue_button_4.disabled)

	# -- P2:R7:T8: Restart Adventure/Start New Adventure from a terminal
	# RUN_ENDED state must clear the stale save that was autosaved at that
	# terminal state, the same as Adventure Mode/New Game already does --
	# otherwise Continue would later offer to resume the run the player just
	# explicitly left behind. Build a second fresh run, drive it to a
	# contract-failed terminal state, autosave (mirroring the real
	# _on_fight_pressed()/_advance_after_reward_or_shop() call sites), press
	# Restart Adventure, and confirm no save survives.
	var adventure_button_3 := _find_button(final_title, "Adventure Mode")
	adventure_button_3.pressed.emit()
	await process_frame
	assert(game_root._current_screen != final_title)

	var class_select_2 = game_root._current_screen
	var rogue_2: ClassDef = load("res://data/classes/rogue.tres")
	class_select_2._on_class_selected(rogue_2)
	class_select_2.advanced.emit()
	await process_frame

	var subclass_select_2 = game_root._current_screen
	var thief_2: SubclassTree = rogue_2.trees[1]
	subclass_select_2._on_tree_selected(thief_2)
	subclass_select_2.advanced.emit()
	await process_frame

	var combat_screen_2 = game_root._current_screen
	build_state.run_outcome = BuildState.RunOutcome.CONTRACT_FAILED
	combat_screen_2._apply_outcome_presentation(build_state.run_outcome)
	combat_screen_2._autosave()
	await process_frame
	print("has_save before Restart Adventure (expect true): %s" % SaveSystem.has_save())
	assert(SaveSystem.has_save())

	var restart_button := _find_button(combat_screen_2, "Restart Adventure")
	assert(restart_button != null)
	assert(restart_button.visible and not restart_button.disabled)
	restart_button.pressed.emit()
	await process_frame
	print("has_save after Restart Adventure (expect false): %s" % SaveSystem.has_save())
	assert(not SaveSystem.has_save())
	assert(game_root._current_screen != combat_screen_2)

	print("")
	print("P2:R6:T4 save/load UI hooks check: OK")
	quit()


func _find_button(root_node: Node, text: String) -> Button:
	for child in root_node.find_children("*", "Button", true, false):
		if child.text == text:
			return child
	return null


func _nearest_panel(node: Node) -> PanelContainer:
	var current := node.get_parent()
	while current != null:
		if current is PanelContainer:
			return current
		current = current.get_parent()
	return null
