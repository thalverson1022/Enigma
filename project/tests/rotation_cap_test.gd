extends SceneTree
## Headless check for the user-requested rotation/macro cap (10 skills,
## shared between Adventure and Training Room via BuildResolver.
## resolve_rotation(), the one chokepoint both BuildState.set_rotation() and
## TrainingRoomState.set_rotation() already route through). Run with:
##   godot --headless -s res://tests/rotation_cap_test.gd


func _initialize() -> void:
	_check_pure_resolver_cap()
	await _check_training_room_ui_cap()
	print("")
	print("Rotation cap check: OK")
	quit()


func _check_pure_resolver_cap() -> void:
	print("-- BuildResolver.resolve_rotation() caps at MAX_ROTATION_SIZE --")
	var stab: Skill = load("res://data/skills/stab.tres")
	var requested: Array[Skill] = []
	for i in 15:
		requested.append(stab)
	var unlocked: Array[Skill] = [stab]
	var resolved := BuildResolver.resolve_rotation(requested, unlocked)
	print("resolved size for 15 requested (expect %d): %d" % [BuildResolver.MAX_ROTATION_SIZE, resolved.size()])
	assert(resolved.size() == BuildResolver.MAX_ROTATION_SIZE)


func _check_training_room_ui_cap() -> void:
	print("-- Training Room: available-skill buttons disable once the macro is full --")
	var game_root_scene: PackedScene = load("res://scenes/game_root.tscn")
	var game_root = game_root_scene.instantiate()
	root.add_child(game_root)
	await process_frame

	var title = game_root._current_screen
	title.training_room_pressed.emit()
	await process_frame
	var training_room = game_root._current_screen

	var stab: Skill = null
	for skill in training_room._state.unlocked_skills():
		if skill.id == "skill.stab":
			stab = skill
	assert(stab != null)

	var available_skills_panel = training_room.find_child("AvailableSkillsPanel", true, false)
	for i in BuildResolver.MAX_ROTATION_SIZE:
		available_skills_panel._on_skill_pressed(stab)
	await process_frame
	print("rotation size after %d presses (expect %d): %d" % [
		BuildResolver.MAX_ROTATION_SIZE, BuildResolver.MAX_ROTATION_SIZE, training_room._state.rotation.size()
	])
	assert(training_room._state.rotation.size() == BuildResolver.MAX_ROTATION_SIZE)

	# One more press past the cap must not grow the rotation, and the
	# button itself should now be disabled (clear UX signal, not just a
	# silent no-op).
	available_skills_panel._on_skill_pressed(stab)
	await process_frame
	print("rotation size after one more press past cap (expect still %d): %d" % [
		BuildResolver.MAX_ROTATION_SIZE, training_room._state.rotation.size()
	])
	assert(training_room._state.rotation.size() == BuildResolver.MAX_ROTATION_SIZE)
	for child in available_skills_panel._skills_box.get_children():
		if child is Button:
			assert(child.disabled)
