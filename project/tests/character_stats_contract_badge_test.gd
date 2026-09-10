extends SceneTree
## Focused check for the Character Stats contract badge: the badge lives in
## the upper-right title row, starts at 0, and tracks completed contracts.


const CONTRACT_ICON := preload("res://assets/ui/icons/contract.png")


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[0])
	await process_frame

	var character_stats_panel = combat_screen.find_child("CharacterStatsPanel", true, false)
	_require(character_stats_panel != null, "Expected to find CharacterStatsPanel.")

	var title_row: HBoxContainer = character_stats_panel.find_child("CharacterStatsTitleRow", true, false)
	var badge: PanelContainer = character_stats_panel.find_child("ContractNumberBadge", true, false)
	var icon: TextureRect = character_stats_panel.find_child("ContractNumberIcon", true, false)
	var label: Label = character_stats_panel.find_child("ContractNumberLabel", true, false)
	_require(title_row != null, "Expected Character Stats title row.")
	_require(badge != null, "Expected Character Stats contract badge.")
	_require(icon != null, "Expected Character Stats contract badge icon.")
	_require(label != null, "Expected Character Stats contract badge label.")
	_require(badge.get_parent() == title_row, "Expected contract badge to live in the Character Stats title row.")
	_require(character_stats_panel._title_label.get_parent() == title_row, "Expected Character Stats title label to live in the title row.")
	_require(badge.get_index() > character_stats_panel._title_label.get_index(), "Expected contract badge to sit at the upper right of the Character Stats window.")
	_require(character_stats_panel._title_label.size_flags_horizontal == Control.SIZE_EXPAND_FILL, "Expected Character Stats title to reserve right-side space for the badge.")
	_require(character_stats_panel._title_label.clip_text, "Expected Character Stats title to clip before pushing the badge.")
	_require(icon.texture == CONTRACT_ICON, "Expected contract badge to use the contract icon asset.")
	_require(label.text == "0", "Expected Tavern phase contract badge to start at 0, got: %s" % label.text)
	_require(badge.tooltip_text == "Contract Number: 0", "Expected initial contract badge tooltip, got: %s" % badge.tooltip_text)

	build_state.run_phase = BuildState.RunPhase.CONTRACT_OFFER
	build_state.run_state_changed.emit()
	await process_frame
	_require(label.text == "0", "Expected contract offer before boss completion to keep badge at 0, got: %s" % label.text)

	build_state.completed_contract_count = 1
	build_state.run_state_changed.emit()
	await process_frame
	_require(label.text == "1", "Expected contract badge to update from run_state_changed, got: %s" % label.text)
	_require(badge.tooltip_text == "Contract Number: 1", "Expected updated contract badge tooltip, got: %s" % badge.tooltip_text)

	build_state.completed_contract_count = 2
	build_state.build_changed.emit()
	await process_frame
	_require(label.text == "2", "Expected contract badge to update from build_changed, got: %s" % label.text)

	print("")
	print("Character Stats contract badge check: OK")
	quit()


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
