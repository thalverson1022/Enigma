extends SceneTree
## Focused regression for extracted Adventure overlay geometry. The Phase 3
## overlay extraction made popup roots their own scene roots; this test
## catches roots that serialize as top-left controls instead of full-screen
## overlays, plus modal cards whose CenterContainer stops centering them.

const CENTER_TOLERANCE := 1.0
const RECT_TOLERANCE := 1.0


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame
	await process_frame

	var expected_rect: Rect2 = combat_screen.get_global_rect()
	_require(expected_rect.size.x > 0.0 and expected_rect.size.y > 0.0, "Expected CombatScreen to have a non-zero global rect.")

	var overlays := {
		"story": combat_screen._story_overlay,
		"map": combat_screen._map_overlay,
		"contract": combat_screen._contract_overlay,
		"reward choice": combat_screen._reward_choice_overlay,
		"secondary subclass": combat_screen._secondary_subclass_overlay,
		"talent trees": combat_screen._talent_overlay,
		"combat log": combat_screen._log_overlay,
		"shop": combat_screen._shop_overlay,
	}

	for overlay_name in overlays:
		var overlay: Control = overlays[overlay_name]
		_require(overlay != null, "Expected %s overlay to exist." % overlay_name)
		overlay.visible = true
		await process_frame

		var overlay_rect := overlay.get_global_rect()
		print("%s overlay rect=%s expected=%s" % [overlay_name, overlay_rect, expected_rect])
		_require(_rect_close(overlay_rect, expected_rect), "Expected %s overlay root to fill CombatScreen." % overlay_name)

		var panel := _centered_modal_panel(overlay)
		_require(panel != null, "Expected %s overlay to have a PanelContainer inside a CenterContainer." % overlay_name)
		var panel_center := panel.get_global_rect().get_center()
		var expected_center := expected_rect.get_center()
		print("%s panel center=%s expected=%s" % [overlay_name, panel_center, expected_center])
		_require(panel_center.distance_to(expected_center) <= CENTER_TOLERANCE, "Expected %s modal panel to be centered." % overlay_name)

		overlay.visible = false

	print("Overlay centering check: OK")
	quit()


func _centered_modal_panel(root_control: Control) -> PanelContainer:
	for child in root_control.find_children("*", "PanelContainer", true, false):
		if child.get_parent() is CenterContainer:
			return child
	return null


func _rect_close(actual: Rect2, expected: Rect2) -> bool:
	return actual.position.distance_to(expected.position) <= RECT_TOLERANCE and actual.size.distance_to(expected.size) <= RECT_TOLERANCE


func _require(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
