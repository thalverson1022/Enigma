extends SceneTree
## Focused check for the read-only Monster Manual boss catalog in the combat HUD.

const ROUTE_GENERATOR := preload("res://scripts/systems/contract_route_generator/contract_route_generator.gd")

var _failed := false


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var manual_button: Button = combat_screen.find_child("MonsterManualButton", true, false)
	_require(manual_button != null, "Expected top bar to include MonsterManualButton.")
	_require(manual_button.tooltip_text == "Monster Manual", "Expected manual button tooltip.")
	_require(manual_button.icon != null, "Expected manual button to use an icon.")

	var manual_overlay = combat_screen.find_child("MonsterManualOverlay", true, false)
	_require(manual_overlay != null, "Expected MonsterManualOverlay instance.")
	_require(not manual_overlay.visible, "Expected manual overlay to start hidden.")

	manual_button.pressed.emit()
	await process_frame
	_require(manual_overlay.visible, "Expected manual overlay to open from top-bar button.")

	var grid: GridContainer = manual_overlay.find_child("MonsterManualBossGrid", true, false)
	_require(grid != null, "Expected manual overlay boss grid.")
	_require(grid.columns == 2, "Expected manual overlay to use a compact two-column biome grid.")
	_require(grid.get_child_count() == ROUTE_GENERATOR.DEFAULT_ALLOWED_BIOMES.size(), "Expected one section per generated biome.")
	var scroll: ScrollContainer = manual_overlay.find_child("MonsterManualScroll", true, false)
	_require(scroll != null, "Expected manual overlay scroll container.")
	_require(scroll.custom_minimum_size == manual_overlay.MANUAL_SCROLL_SIZE, "Expected Monster Manual scroll area to stay tall enough for the full boss catalog.")

	var expected_boss_count := 0
	for biome in ROUTE_GENERATOR.DEFAULT_ALLOWED_BIOMES:
		var biome_name := String(biome)
		var section := _section_for_biome(grid, biome_name)
		_require(section != null, "Expected manual section for %s." % biome_name)
		if section == null:
			continue
		var table: Dictionary = ROUTE_GENERATOR.BIOME_PRESENTATION[biome_name]
		var bosses: Array = table.get("boss", []) as Array
		expected_boss_count += bosses.size()
		for boss_name in bosses:
			var row := _row_for_boss(section, String(boss_name))
			_require(row != null, "Expected manual row for %s / %s." % [biome_name, String(boss_name)])
			var check_label: Label = row.find_child("BossCheckBox", true, false)
			var name_label: Label = row.find_child("BossNameLabel", true, false)
			_require(check_label != null and check_label.text == "[ ]", "Expected boss row to start unchecked.")
			_require(name_label != null and name_label.text == String(boss_name), "Expected boss row to show boss name.")

	_require(_manual_boss_row_count(grid) == expected_boss_count, "Expected manual to list every generated boss exactly once.")
	_require(expected_boss_count == 30, "Expected current generated boss catalog to contain 30 bosses.")

	var defeated_boss_id := "Swamp::Swamp Hydra"
	var defeated_ids: Array[String] = [defeated_boss_id]
	build_state.defeated_generated_boss_ids = defeated_ids
	manual_overlay.show_manual()
	await process_frame
	var defeated_section := _section_for_biome(grid, "Swamp")
	var defeated_row := _row_for_boss(defeated_section, "Swamp Hydra")
	_require(defeated_row != null, "Expected defeated Swamp Hydra row.")
	if defeated_row == null or defeated_section == null:
		quit(1)
	_require(defeated_row.find_child("BossCheckBox", true, false).text == "[x]", "Expected defeated boss row to show checked box.")
	_require(defeated_row.find_child("BossClosedLabel", true, false) != null, "Expected defeated boss row to show CLOSED label.")
	_require(defeated_section.find_child("BiomeTitle", true, false).text == "Swamp  1/5", "Expected biome title to show defeated progress.")

	var close_button: Button = manual_overlay.find_child("MonsterManualCloseButton", true, false)
	_require(close_button != null, "Expected manual close button.")
	close_button.pressed.emit()
	await process_frame
	_require(not manual_overlay.visible, "Expected manual overlay to close.")

	print("")
	if _failed:
		print("Monster Manual overlay check: FAILED")
		quit(1)
	else:
		print("Monster Manual overlay check: OK")
		quit()


func _manual_boss_row_count(grid: GridContainer) -> int:
	var count := 0
	for section in grid.get_children():
		for row in section.find_children("BossRow_*", "HBoxContainer", true, false):
			count += 1
	return count


func _section_for_biome(grid: GridContainer, biome: String) -> Node:
	for section in grid.get_children():
		var title: Label = section.find_child("BiomeTitle", true, false)
		if title != null and title.text.begins_with(biome):
			return section
	return null


func _row_for_boss(section: Node, boss_name: String) -> Node:
	if section == null:
		return null
	for row in section.find_children("BossRow_*", "HBoxContainer", true, false):
		var label: Label = row.find_child("BossNameLabel", true, false)
		if label != null and label.text == boss_name:
			return row
	return null


func _node_safe_name(value: String) -> String:
	var safe := value.strip_edges().to_lower()
	for ch in [" ", "-", "'", ",", ".", ":"]:
		safe = safe.replace(ch, "_")
	return safe


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
