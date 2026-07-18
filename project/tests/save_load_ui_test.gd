extends SceneTree
## Headless check for P2:R6:T4's save/load UI hooks. Drives the real
## title/game_root scene tree the same way real clicks would:
##   - No save: Continue is hidden, Adventure Mode starts a fresh run with
##     no confirmation.
##   - Save & Quit persists the run and returns to Title, where Continue is
##     now visible.
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

	# -- Fresh start: Continue is hidden, Adventure Mode has no save to warn
	# about --
	var title = game_root._current_screen
	var continue_button := _find_button(title, "Continue Adventure")
	assert(continue_button != null)
	print("continue button visible with no save (expect false): %s" % continue_button.visible)
	assert(not continue_button.visible)

	var adventure_button := _find_button(title, "Adventure Mode")
	assert(adventure_button != null)
	adventure_button.pressed.emit()
	await process_frame
	# No save existed, so pressing Adventure Mode should proceed straight to
	# class select rather than popping a confirmation dialog.
	assert(game_root._current_screen != title)

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
	build_state.set_adventure_seed(77)
	build_state.add_gold(35)
	assert(combat_screen._map_overlay.visible)
	combat_screen._map_node_buttons[0].pressed.emit()
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
	print("continue button visible after save (expect true): %s" % continue_button_2.visible)
	assert(continue_button_2.visible)

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
	print("restored gold/seed (expect 35 / 77): %d / %d" % [build_state.gold, build_state.adventure_seed])
	assert(build_state.gold == 35)
	assert(build_state.adventure_seed == 77)
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
	print("continue button visible after abandon (expect false): %s" % continue_button_4.visible)
	assert(not continue_button_4.visible)

	print("")
	print("P2:R6:T4 save/load UI hooks check: OK")
	quit()


func _find_button(root_node: Node, text: String) -> Button:
	for child in root_node.find_children("*", "Button", true, false):
		if child.text == text:
			return child
	return null
