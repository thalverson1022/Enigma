extends PanelContainer
## Combat dashboard panel: shows the current run encounter and the Fight
## button, matching the mockup's panel placement.
##
## Root is PanelContainer -- see character_stats_panel.gd's comment for why.

signal fight_pressed

const CARD_TITLE_FONT_SIZE := 20
const PANEL_MIN_HEIGHT := 190

var _info_label: Label
var _fight_button: Button


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	custom_minimum_size = Vector2(0, PANEL_MIN_HEIGHT)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = "Enemy Stats"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_info_label = Label.new()
	content.add_child(_info_label)

	_fight_button = Button.new()
	_fight_button.text = "FIGHT!"
	_fight_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_fight_button.pressed.connect(func(): fight_pressed.emit())
	content.add_child(_fight_button)

	BuildState.lock_changed.connect(_update_fight_button)
	BuildState.build_changed.connect(_refresh)
	BuildState.run_state_changed.connect(_on_run_state_changed)
	_update_fight_button()
	_refresh()


func _update_fight_button() -> void:
	var can_fight := BuildState.can_start_current_fight()
	_fight_button.disabled = not can_fight
	if can_fight:
		_fight_button.tooltip_text = ""
	elif BuildState.needs_tavern_map_choice():
		_fight_button.tooltip_text = "Choose the current encounter on the map"
	elif BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_fight_button.tooltip_text = "Accept the contract to continue"
	elif BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE:
		_fight_button.tooltip_text = "Choose the next route step"
	elif BuildState.run_phase != BuildState.RunPhase.PLANNING:
		_fight_button.tooltip_text = "Continue from the current fight result"
	else:
		_fight_button.tooltip_text = "Lock your build to fight"


func _on_run_state_changed() -> void:
	_update_fight_button()
	_refresh()


func monster() -> Monster:
	return BuildState.current_target_monster()


func duration_ms() -> int:
	return BuildState.current_target_duration_ms()


func _refresh() -> void:
	if BuildState.run_phase == BuildState.RunPhase.RUN_ENDED:
		_info_label.text = _empty_stats_text()
		_update_fight_button()
		return
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_info_label.text = _empty_stats_text()
		_update_fight_button()
		return
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE and not BuildState.is_contract_fight_active():
		_info_label.text = _empty_stats_text()
		_update_fight_button()
		return
	if BuildState.needs_tavern_map_choice():
		_info_label.text = _empty_stats_text()
		_update_fight_button()
		return
	var enemy: Monster = BuildState.current_target_monster()
	var duration := BuildState.current_target_duration_ms()
	if enemy == null:
		_info_label.text = _empty_stats_text()
		_update_fight_button()
		return
	var lines: PackedStringArray = []
	if not BuildState.is_contract_fight_active():
		lines.append("Encounter: %d/%d" % [BuildState.current_encounter_index + 1, RunFlow.tavern_encounter_count()])
	lines.append("Target: %s" % enemy.display_name)
	lines.append("HP: %d" % enemy.hp)
	lines.append("Armor: %d" % enemy.armor)
	lines.append("Poison Resist: %.0f%%" % (enemy.poison_resistance * 100.0))
	lines.append("Window: %.0fs" % (duration / 1000.0))
	_info_label.text = "\n".join(lines)
	_update_fight_button()


func _empty_stats_text() -> String:
	var lines: PackedStringArray = []
	lines.append("Encounter: NONE")
	lines.append("Target: NONE")
	lines.append("HP: NONE")
	lines.append("Armor: NONE")
	lines.append("Poison Resist: NONE")
	lines.append("Window: NONE")
	return "\n".join(lines)
