extends SceneTree
## M3:T1 geometry guardrail: the 10-slot macro plus fixed lock button must
## fit inside the shared SkillBuildPanel in both Adventure and Practice Room.
## This catches the layout regression screenshots exposed: slot 10 or the
## lock button pushing out of the panel/host at the target 1600x900 viewport.

const TARGET_VIEWPORT := Vector2i(1600, 900)
const EDGE_EPSILON := 1.0


func _initialize() -> void:
	root.size = TARGET_VIEWPORT
	await _check_adventure_macro_geometry()
	await _check_training_room_macro_geometry()
	print("")
	print("Skill Build geometry check: OK")
	quit()


func _check_adventure_macro_geometry() -> void:
	print("-- Adventure Skill Build: 10-slot macro geometry --")
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen: Control = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[0])
	_fill_rotation_with_stab(build_state)
	await _settle_layout()

	var skill_build_panel = combat_screen.find_child("SkillBuildPanel", true, false)
	_require(skill_build_panel != null, "Expected Adventure SkillBuildPanel.")
	_assert_full_macro_fits("Adventure", combat_screen, skill_build_panel)
	combat_screen.queue_free()
	await process_frame


func _check_training_room_macro_geometry() -> void:
	print("-- Practice Room Skill Build: 10-slot macro geometry --")
	var training_scene: PackedScene = load("res://scenes/training_room/training_room.tscn")
	var training_room: Control = training_scene.instantiate()
	root.add_child(training_room)
	await process_frame

	_fill_rotation_with_stab(training_room._state)
	await _settle_layout()

	var skill_build_panel = training_room.find_child("SkillBuildPanel", true, false)
	_require(skill_build_panel != null, "Expected Practice Room SkillBuildPanel.")
	_assert_full_macro_fits("Practice Room", training_room, skill_build_panel)
	training_room.queue_free()
	await process_frame


func _fill_rotation_with_stab(state) -> void:
	var stab: Skill = null
	for skill in state.unlocked_skills():
		if skill.id == "skill.stab":
			stab = skill
			break
	_require(stab != null, "Expected Stab to be unlocked for geometry setup.")
	var rotation: Array[Skill] = []
	for i in BuildResolver.MAX_ROTATION_SIZE:
		rotation.append(stab)
	state.set_rotation(rotation)


func _settle_layout() -> void:
	await process_frame
	await process_frame


func _assert_full_macro_fits(label: String, host: Control, skill_build_panel) -> void:
	var panel_rect: Rect2 = skill_build_panel.get_global_rect()
	var host_rect: Rect2 = host.get_global_rect()
	var slots_box: HBoxContainer = skill_build_panel._slots_box
	var lock_button: Button = skill_build_panel._lock_button
	var lock_holder: CenterContainer = skill_build_panel._lock_holder
	_require(slots_box.get_child_count() == BuildResolver.MAX_ROTATION_SIZE, "%s expected %d macro slots, got %d." % [
		label,
		BuildResolver.MAX_ROTATION_SIZE,
		slots_box.get_child_count(),
	])

	var first_slot: Button = slots_box.get_child(0)
	var tenth_slot: Button = slots_box.get_child(BuildResolver.MAX_ROTATION_SIZE - 1)
	var first_rect: Rect2 = first_slot.get_global_rect()
	var tenth_rect: Rect2 = tenth_slot.get_global_rect()
	var lock_rect: Rect2 = lock_button.get_global_rect()
	var lock_holder_rect: Rect2 = lock_holder.get_global_rect()

	print("%s host=%s panel=%s first=%s tenth=%s lock_holder=%s lock=%s" % [
		label,
		host_rect,
		panel_rect,
		first_rect,
		tenth_rect,
		lock_holder_rect,
		lock_rect,
	])

	_require(_rect_contains(panel_rect, first_rect), "%s first macro slot is outside SkillBuildPanel." % label)
	_require(_rect_contains(panel_rect, tenth_rect), "%s tenth macro slot is outside SkillBuildPanel." % label)
	_require(_rect_contains(panel_rect, lock_holder_rect), "%s lock lane is outside SkillBuildPanel." % label)
	_require(_rect_contains(panel_rect, lock_rect), "%s lock button is outside SkillBuildPanel." % label)
	_require(_rect_contains(host_rect, panel_rect), "%s SkillBuildPanel bleeds outside its host screen." % label)
	_require(tenth_rect.end.x + EDGE_EPSILON <= lock_rect.position.x, "%s tenth slot overlaps or crowds the lock button." % label)
	_require(lock_rect.size.x > 0.0 and lock_rect.size.x == lock_rect.size.y, "%s lock button should be square before circular styling." % label)


func _rect_contains(outer: Rect2, inner: Rect2) -> bool:
	return (
		inner.position.x + EDGE_EPSILON >= outer.position.x
		and inner.position.y + EDGE_EPSILON >= outer.position.y
		and inner.end.x <= outer.end.x + EDGE_EPSILON
		and inner.end.y <= outer.end.y + EDGE_EPSILON
	)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false)
