extends SceneTree


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	SaveSystem.delete_save()

	var game_root_scene: PackedScene = load("res://scenes/game_root.tscn")
	var game_root = game_root_scene.instantiate()
	root.add_child(game_root)
	await process_frame

	var title = game_root._current_screen
	title.adventure_pressed.emit()
	await process_frame

	var class_select = game_root._current_screen
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	class_select._on_class_selected(rogue)
	class_select.advanced.emit()
	await process_frame

	var subclass_select = game_root._current_screen
	var shadow: SubclassTree = load("res://data/subclass_trees/shadow.tres")
	subclass_select._on_tree_selected(shadow)
	subclass_select.advanced.emit()
	await process_frame

	var combat_screen = game_root._current_screen
	assert(combat_screen._tavern_background != null)
	assert(combat_screen._tavern_background.texture != null)
	assert(combat_screen._tavern_background.visible)
	var story_proceed_button: Button = combat_screen._story_overlay.find_child("StoryProceedButton", true, false)
	story_proceed_button.pressed.emit()
	await process_frame
	combat_screen._map_node_buttons[0].pressed.emit()
	await process_frame
	combat_screen._map_proceed_button.pressed.emit()
	await process_frame

	var available_skills_panel = combat_screen.find_child("AvailableSkillsPanel", true, false)
	var skill_build_panel = combat_screen.find_child("SkillBuildPanel", true, false)
	var enemy_panel = combat_screen.find_child("EnemyPanel", true, false)
	assert(available_skills_panel != null)
	assert(skill_build_panel != null)
	assert(enemy_panel != null)

	var stab: Skill = null
	for skill in build_state.unlocked_skills():
		if skill.id == "skill.stab":
			stab = skill
			break
	assert(stab != null)
	available_skills_panel._on_skill_pressed(stab)
	assert(build_state.rotation.size() == 1)
	skill_build_panel._on_lock_pressed()
	assert(build_state.build_locked)

	enemy_panel.fight_pressed.emit()
	await process_frame

	var log_text: String = combat_screen._log_label.text
	print(log_text)
	assert(not log_text.contains("[DIAG"))
	assert(log_text.contains("Poison ticks for 8.0"))

	print("")
	print("Shadow combat-screen path: OK")
	quit()
