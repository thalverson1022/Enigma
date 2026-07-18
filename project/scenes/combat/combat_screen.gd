extends Control
## The persistent combat HUD, laid out per the user's mockups: a dominant
## central combat window (future home of animated combat) flanked by side
## columns -- left: Character Stats over Talent Trees; right: Enemy Stats
## (with FIGHT!) over Gear -- with the Available Skills and Skill Build
## strips under the combat window. Each panel reads BuildState directly and
## refreshes on BuildState.build_changed -- no cross-panel coupling, per
## docs/Conventions.md's UI architecture principle. This script itself only
## owns the combat window, the log overlay, the top bar, and the Fight
## action.
##
## The combat log lives in a dismissible overlay rather than inline in the
## combat window -- once real combat animation exists, the window needs
## that space for the fight itself, not a wall of text. The log remains
## fully available on demand via "View Combat Log," since reading exactly
## what happened is core to the game (see docs/DPS_Engine_Phase2_Context.md's
## design philosophy), it just doesn't have to compete with animation for
## screen space.

signal main_menu_pressed
signal adventure_restart_pressed
signal save_and_quit_pressed

const CHARACTER_STATS_SCENE := preload("res://scenes/combat/character_stats_panel.tscn")
const ENEMY_SCENE := preload("res://scenes/combat/enemy_panel.tscn")
const TALENT_SCENE := preload("res://scenes/combat/talent_panel.tscn")
const AVAILABLE_SKILLS_SCENE := preload("res://scenes/combat/available_skills_panel.tscn")
const SKILL_BUILD_SCENE := preload("res://scenes/combat/skill_build_panel.tscn")
const GEAR_SCENE := preload("res://scenes/combat/gear_panel.tscn")

const SIDE_COLUMN_WIDTH := 300
const SCREEN_MARGIN := 16
const PANEL_SEPARATION := 16
const CARD_TITLE_FONT_SIZE := 20
const VICTORY_TITLE_FONT_SIZE := 36
const OUTCOME_TITLE_FONT_SIZE := 24
const OUTCOME_LOSS_COLOR := Color(0.85, 0.35, 0.3)
const BACKDROP_COLOR := Color(0, 0, 0, 0.6)
const MAP_NODE_SIZE := Vector2(190, 150)
const CONTRACT_MAP_SIZE := Vector2(840, 470)
const CONTRACT_NODE_SIZE := Vector2(140, 96)
const CONTRACT_LINE_COLOR := Color(0.05, 0.05, 0.06)
const CONTRACT_LINE_THICKNESS := 5.0

var _status_label: Label
var _outcome_title_label: Label
var _seed_label: Label
var _view_log_button: Button
var _log_button_row: HBoxContainer
var _map_button: Button
var _retry_button: Button
var _restart_adventure_button: Button
var _combat_content: VBoxContainer
var _log_overlay: Control
var _log_label: RichTextLabel
var _map_overlay: Control
var _map_phase_label: Label
var _map_story_label: Label
var _map_nodes_box: HBoxContainer
var _map_node_buttons: Array[Button] = []
var _map_close_button: Button
var _map_manual_open: bool = false
var _victory_overlay: Control
var _victory_recap_label: Label
var _reward_label: Label
var _continue_button: Button
var _shop_overlay: PanelContainer
var _shop_gold_label: Label
var _shop_status_label: Label
var _shop_offers_box: GridContainer
var _shop_reroll_button: Button
var _shop_leave_button: Button
var _reward_choice_overlay: PanelContainer
var _reward_choice_title: Label
var _reward_choice_options: HBoxContainer
var _secondary_subclass_overlay: Control
var _secondary_subclass_title: Label
var _secondary_subclass_body: Label
var _secondary_subclass_options: HBoxContainer
var _enemy_panel
var _confirm_dialog: ConfirmationDialog


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, SCREEN_MARGIN)
	add_child(margin)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", PANEL_SEPARATION)
	margin.add_child(root_vbox)

	# -- Top bar: menu button in the upper right --
	var top_bar := HBoxContainer.new()
	var top_spacer := Control.new()
	top_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(top_spacer)
	_seed_label = Label.new()
	_seed_label.text = _seed_label_text()
	top_bar.add_child(_seed_label)
	_map_button = Button.new()
	_map_button.text = "Map"
	_map_button.pressed.connect(_on_map_button_pressed)
	top_bar.add_child(_map_button)
	var save_quit_button := Button.new()
	save_quit_button.text = "Save & Quit"
	save_quit_button.pressed.connect(_on_save_and_quit_pressed)
	top_bar.add_child(save_quit_button)
	var menu_button := Button.new()
	menu_button.text = "Abandon Run"
	menu_button.pressed.connect(func(): _confirm_dialog.popup_centered())
	top_bar.add_child(menu_button)
	root_vbox.add_child(top_bar)

	# -- Three-column HUD body --
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", PANEL_SEPARATION)
	root_vbox.add_child(columns)

	# Left column: Character Stats over Talent Trees.
	var left_column := VBoxContainer.new()
	left_column.custom_minimum_size = Vector2(SIDE_COLUMN_WIDTH, 0)
	left_column.add_theme_constant_override("separation", PANEL_SEPARATION)
	columns.add_child(left_column)

	# Character Stats shrinks to its content; Subclass absorbs the leftover
	# column height (room for a second tree row once that's added).
	var character_stats_panel = CHARACTER_STATS_SCENE.instantiate()
	left_column.add_child(character_stats_panel)

	var talent_panel = TALENT_SCENE.instantiate()
	talent_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_column.add_child(talent_panel)

	# Center column: the combat window, then the two skill strips.
	var center_column := VBoxContainer.new()
	center_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_column.add_theme_constant_override("separation", PANEL_SEPARATION)
	columns.add_child(center_column)

	center_column.add_child(_build_combat_window())
	center_column.add_child(AVAILABLE_SKILLS_SCENE.instantiate())
	center_column.add_child(SKILL_BUILD_SCENE.instantiate())

	# Right column: Enemy Stats (with FIGHT!) over Gear.
	var right_column := VBoxContainer.new()
	right_column.custom_minimum_size = Vector2(SIDE_COLUMN_WIDTH, 0)
	right_column.add_theme_constant_override("separation", PANEL_SEPARATION)
	columns.add_child(right_column)

	# Enemy Stats shrinks to its content; Gear absorbs the leftover column
	# height.
	_enemy_panel = ENEMY_SCENE.instantiate()
	_enemy_panel.fight_pressed.connect(_on_fight_pressed)
	right_column.add_child(_enemy_panel)

	var gear_panel = GEAR_SCENE.instantiate()
	gear_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_column.add_child(gear_panel)

	_build_confirm_dialog()
	_build_victory_overlay()
	_build_shop_overlay()
	_build_reward_choice_overlay()
	_build_map_overlay()
	_build_secondary_subclass_overlay()
	_keep_log_button_row_last()
	_build_log_overlay()
	BuildState.build_changed.connect(_on_build_state_changed)
	BuildState.run_state_changed.connect(_on_run_state_changed)
	# A loaded save can resume directly into a terminal outcome (e.g. a
	# do-over still pending, or a contract already failed/won at save time).
	# _apply_outcome_presentation() no-ops for RunOutcome.NONE, so this is
	# safe for the normal fresh-run case too.
	_apply_outcome_presentation(BuildState.run_outcome)
	call_deferred("_show_initial_map_if_needed")


## The central combat window -- the future home of animated combat. For now
## it just shows a status line and a button to review the last fight's log.
func _build_combat_window() -> PanelContainer:
	var window := PanelContainer.new()
	window.size_flags_vertical = Control.SIZE_EXPAND_FILL
	window.add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	window.add_child(content)
	_combat_content = content

	var title := Label.new()
	title.text = "Combat"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_outcome_title_label = Label.new()
	_outcome_title_label.visible = false
	_outcome_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outcome_title_label.add_theme_font_size_override("font_size", OUTCOME_TITLE_FONT_SIZE)
	content.add_child(_outcome_title_label)

	_status_label = Label.new()
	_status_label.text = "Assemble your build and press FIGHT!"
	_status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(_status_label)

	_view_log_button = Button.new()
	_view_log_button.text = "View Combat Log"
	_view_log_button.disabled = true
	_view_log_button.pressed.connect(func(): _log_overlay.visible = true)

	var log_row := HBoxContainer.new()
	_log_button_row = log_row
	var log_spacer := Control.new()
	log_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_row.add_child(log_spacer)
	_view_log_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	log_row.add_child(_view_log_button)
	content.add_child(log_row)

	_retry_button = Button.new()
	_retry_button.text = "Retry Encounter"
	_retry_button.visible = false
	_retry_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_retry_button.pressed.connect(_on_retry_pressed)
	content.add_child(_retry_button)

	_restart_adventure_button = Button.new()
	_restart_adventure_button.text = "Restart Adventure"
	_restart_adventure_button.visible = false
	_restart_adventure_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_restart_adventure_button.pressed.connect(func(): adventure_restart_pressed.emit())
	content.add_child(_restart_adventure_button)

	return window


## Victory banner: shown automatically after a winning fight, with a short
## recap (total damage, DPS, biggest hit, physical/poison damage split from
## CombatRecap).
func _build_victory_overlay() -> void:
	_victory_overlay = CenterContainer.new()
	_victory_overlay.visible = false
	_victory_overlay.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_combat_content.add_child(_victory_overlay)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	_victory_overlay.add_child(stack)

	var victory_panel := PanelContainer.new()
	victory_panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox(24))
	stack.add_child(victory_panel)

	var victory_content := VBoxContainer.new()
	victory_content.add_theme_constant_override("separation", 12)
	victory_panel.add_child(victory_content)

	var banner_title := Label.new()
	banner_title.text = "VICTORY!"
	banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_title.add_theme_font_size_override("font_size", VICTORY_TITLE_FONT_SIZE)
	banner_title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	victory_content.add_child(banner_title)

	_victory_recap_label = Label.new()
	victory_content.add_child(_victory_recap_label)

	var reward_panel := PanelContainer.new()
	reward_panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox(16))
	stack.add_child(reward_panel)

	var reward_content := VBoxContainer.new()
	reward_content.add_theme_constant_override("separation", 10)
	reward_panel.add_child(reward_content)

	var reward_title := Label.new()
	reward_title.text = "Rewards"
	reward_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	reward_content.add_child(reward_title)

	_reward_label = Label.new()
	_reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_content.add_child(_reward_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)

	var continue_button := Button.new()
	continue_button.text = "Claim Rewards"
	continue_button.pressed.connect(_on_continue_pressed)
	_continue_button = continue_button
	button_row.add_child(_continue_button)

	reward_content.add_child(button_row)


func _show_victory_banner(result: CombatResolver.CombatResult) -> void:
	_status_label.visible = false
	_view_log_button.visible = true
	_retry_button.visible = false
	_restart_adventure_button.visible = false
	_keep_log_button_row_last()
	var recap: Dictionary = CombatRecap.summarize(result)
	var lines: PackedStringArray = []
	lines.append("Total Damage: %.1f" % recap.total_damage)
	lines.append("DPS: %.1f" % recap.dps)
	lines.append("Biggest Hit: %.1f (%s)" % [recap.biggest_hit, recap.biggest_hit_skill])
	lines.append("Physical Damage: %.0f%%" % recap.physical_pct)
	lines.append("Poison Damage: %.0f%%" % recap.poison_pct)
	_victory_recap_label.text = "\n".join(lines)
	_reward_label.text = _reward_text()
	_continue_button.disabled = BuildState.has_claimed_current_reward()
	_victory_overlay.visible = true


func _keep_log_button_row_last() -> void:
	if _combat_content != null and _log_button_row != null:
		_combat_content.move_child(_log_button_row, _combat_content.get_child_count() - 1)


func _reward_text() -> String:
	var reward := BuildState.current_reward()
	if reward == null:
		return "Rewards: none."
	var parts: PackedStringArray = []
	if reward.gold_amount > 0:
		parts.append("%dg" % reward.gold_amount)
	if reward.talent_points > 0:
		parts.append("%d talent point%s" % [
			reward.talent_points,
			"" if reward.talent_points == 1 else "s",
		])
	for gear in reward.fixed_gear_rewards:
		if gear != null:
			parts.append(gear.display_name)
	if reward.unlocks_shop:
		parts.append("shop access")
	if reward.gear_choice_rewards.size() > 0:
		var gear_names: PackedStringArray = []
		for gear in reward.gear_choice_rewards:
			if gear != null:
				gear_names.append(gear.display_name)
		if not gear_names.is_empty():
			parts.append("choose %s" % " or ".join(gear_names))
	if BuildState.is_contract_fight_active() and BuildState.current_route_node != null and BuildState.current_route_node.reward_summary != "":
		parts.append(BuildState.current_route_node.reward_summary)
	if parts.is_empty():
		return "Rewards: none."
	return "Rewards: %s." % ", ".join(parts)


## Dimmed backdrop (click to dismiss) + a centered card holding the actual
## log. Hidden until the first fight resolves.
func _build_log_overlay() -> void:
	_log_overlay = Control.new()
	_log_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_log_overlay.visible = false
	add_child(_log_overlay)

	var backdrop := Button.new()
	backdrop.flat = true
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop_style := StyleBoxFlat.new()
	backdrop_style.bg_color = BACKDROP_COLOR
	for state in ["normal", "hover", "pressed", "focus"]:
		backdrop.add_theme_stylebox_override(state, backdrop_style)
	backdrop.pressed.connect(func(): _log_overlay.visible = false)
	_log_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_log_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	var header := HBoxContainer.new()
	var header_title := Label.new()
	header_title.text = "Combat Log"
	header_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	header.add_child(header_title)
	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): _log_overlay.visible = false)
	header.add_child(close_button)
	content.add_child(header)

	_log_label = RichTextLabel.new()
	_log_label.custom_minimum_size = Vector2(600, 400)
	content.add_child(_log_label)


func _build_map_overlay() -> void:
	_map_overlay = Control.new()
	_map_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_overlay.visible = false
	add_child(_map_overlay)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = BACKDROP_COLOR
	_map_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_overlay.add_child(center)

	var panel := PanelContainer.new()
	var style := CardStyle.make_stylebox(18)
	style.bg_color = Color(0.16, 0.16, 0.18)
	style.border_color = Color(0.4, 0.4, 0.45)
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(940, 560)
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Map"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	content.add_child(title)

	_map_phase_label = Label.new()
	_map_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_map_phase_label.add_theme_font_size_override("font_size", 24)
	content.add_child(_map_phase_label)

	_map_story_label = Label.new()
	_map_story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_map_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_map_story_label.custom_minimum_size = Vector2(760, 0)
	content.add_child(_map_story_label)

	var center_row := CenterContainer.new()
	center_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center_row)

	_map_nodes_box = HBoxContainer.new()
	_map_nodes_box.add_theme_constant_override("separation", 0)
	center_row.add_child(_map_nodes_box)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	content.add_child(button_row)

	_map_close_button = Button.new()
	_map_close_button.text = "Close Map"
	_map_close_button.pressed.connect(func(): _map_overlay.visible = false)
	button_row.add_child(_map_close_button)
	_refresh_map_overlay()


func _refresh_map_overlay() -> void:
	if _map_nodes_box == null:
		return
	if _map_close_button != null:
		_map_close_button.visible = _map_manual_open or not _map_requires_choice()
	for child in _map_nodes_box.get_children():
		child.queue_free()
	_map_node_buttons = []
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_refresh_contract_offer_map()
	elif BuildState.active_contract != null:
		_refresh_contract_route_map()
	else:
		_refresh_tavern_map()


func _refresh_tavern_map() -> void:
	_map_phase_label.text = "Tavern"
	_map_story_label.text = _tavern_story_text()
	for i in RunFlow.tavern_encounter_count():
		var button := _make_tavern_map_node_button(i)
		_map_node_buttons.append(button)
		_map_nodes_box.add_child(button)
		if i < RunFlow.tavern_encounter_count() - 1:
			_map_nodes_box.add_child(_make_map_connector())


func _refresh_contract_offer_map() -> void:
	var contract := BuildState.active_contract
	_map_phase_label.text = "Contract"
	_map_story_label.text = contract.offer_text if contract != null else "The trail out of the Tavern has gone cold."
	var button := Button.new()
	button.custom_minimum_size = MAP_NODE_SIZE
	button.text = contract.display_name if contract != null else "Unknown Contract"
	button.disabled = contract == null
	button.pressed.connect(_on_contract_map_pressed)
	_style_map_node(button, true)
	_map_node_buttons.append(button)
	_map_nodes_box.add_child(button)


func _refresh_contract_route_map() -> void:
	_map_phase_label.text = BuildState.active_contract.display_name if BuildState.active_contract != null else "Contract Route"
	_map_story_label.text = _contract_route_story_text()
	var schematic := _make_contract_route_schematic()
	if schematic != null:
		_map_nodes_box.add_child(schematic)
		return
	var node := BuildState.current_route_node
	var choices: Array[ContractRouteNode] = []
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE and node != null:
		choices = node.next_nodes
	if choices.is_empty():
		var button := Button.new()
		button.custom_minimum_size = MAP_NODE_SIZE
		button.text = _route_node_button_text(node) if node != null else "Route Pending"
		button.disabled = true
		_style_map_node(button, false)
		_map_node_buttons.append(button)
		_map_nodes_box.add_child(button)
		return
	for i in choices.size():
		var choice := choices[i]
		var button := Button.new()
		button.custom_minimum_size = MAP_NODE_SIZE
		button.text = _route_node_button_text(choice)
		button.tooltip_text = _route_node_tooltip(choice)
		button.disabled = BuildState.needs_secondary_subclass_choice()
		button.pressed.connect(_on_contract_route_node_pressed.bind(choice))
		_style_map_node(button, not button.disabled)
		_map_node_buttons.append(button)
		_map_nodes_box.add_child(button)
		if i < choices.size() - 1:
			_map_nodes_box.add_child(_make_map_connector())


func _make_contract_route_schematic() -> Control:
	var secondary := _gilded_serpent_secondary_node()
	if secondary == null or secondary.next_nodes.size() < 2:
		return null
	var door_guard := _find_route_node(secondary, "route.gilded_serpent.door_guard")
	var portly_cook := _find_route_node(secondary, "route.gilded_serpent.portly_cook")
	var sleeping := _find_route_node(secondary, "route.gilded_serpent.sleeping_henchman")
	var cloaked := _find_route_node(secondary, "route.gilded_serpent.cloaked_watchmen")
	var lazy := _find_route_node(secondary, "route.gilded_serpent.lazy_henchman")
	var patrol := _find_route_node(secondary, "route.gilded_serpent.patrolling_guard")
	var knives := _find_route_node(secondary, "route.gilded_serpent.knives")
	var vyra := _find_route_node(secondary, "route.gilded_serpent.vyra")
	if door_guard == null or portly_cook == null or sleeping == null or cloaked == null or lazy == null or patrol == null or knives == null or vyra == null:
		return null

	var canvas := Control.new()
	canvas.custom_minimum_size = CONTRACT_MAP_SIZE

	var positions := {
		door_guard: Vector2(20, 95),
		portly_cook: Vector2(20, 320),
		sleeping: Vector2(235, 20),
		cloaked: Vector2(235, 135),
		lazy: Vector2(235, 250),
		patrol: Vector2(235, 365),
		knives: Vector2(515, 190),
		vyra: Vector2(690, 190),
	}
	_add_contract_route_lines(canvas, positions, door_guard, portly_cook, sleeping, cloaked, lazy, patrol, knives, vyra)
	_add_contract_route_button(canvas, door_guard, positions[door_guard])
	_add_contract_route_button(canvas, portly_cook, positions[portly_cook])
	_add_contract_route_button(canvas, sleeping, positions[sleeping])
	_add_contract_route_button(canvas, cloaked, positions[cloaked])
	_add_contract_route_button(canvas, lazy, positions[lazy])
	_add_contract_route_button(canvas, patrol, positions[patrol])
	_add_contract_route_button(canvas, knives, positions[knives])
	_add_contract_route_button(canvas, vyra, positions[vyra])
	return canvas


func _add_contract_route_lines(canvas: Control, positions: Dictionary, door_guard: ContractRouteNode, portly_cook: ContractRouteNode, sleeping: ContractRouteNode, cloaked: ContractRouteNode, lazy: ContractRouteNode, patrol: ContractRouteNode, knives: ContractRouteNode, vyra: ContractRouteNode) -> void:
	var door_center := _contract_node_center(positions[door_guard])
	var cook_center := _contract_node_center(positions[portly_cook])
	var sleeping_center := _contract_node_center(positions[sleeping])
	var cloaked_center := _contract_node_center(positions[cloaked])
	var lazy_center := _contract_node_center(positions[lazy])
	var patrol_center := _contract_node_center(positions[patrol])
	var knives_center := _contract_node_center(positions[knives])
	var vyra_center := _contract_node_center(positions[vyra])
	var opener_branch_x := 195.0
	var convergence_x := 465.0

	_add_map_line(canvas, Vector2(door_center.x + CONTRACT_NODE_SIZE.x * 0.5, door_center.y), Vector2(opener_branch_x, door_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, sleeping_center.y), Vector2(opener_branch_x, cloaked_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, sleeping_center.y), Vector2(sleeping_center.x - CONTRACT_NODE_SIZE.x * 0.5, sleeping_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, cloaked_center.y), Vector2(cloaked_center.x - CONTRACT_NODE_SIZE.x * 0.5, cloaked_center.y))

	_add_map_line(canvas, Vector2(cook_center.x + CONTRACT_NODE_SIZE.x * 0.5, cook_center.y), Vector2(opener_branch_x, cook_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, lazy_center.y), Vector2(opener_branch_x, patrol_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, lazy_center.y), Vector2(lazy_center.x - CONTRACT_NODE_SIZE.x * 0.5, lazy_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, patrol_center.y), Vector2(patrol_center.x - CONTRACT_NODE_SIZE.x * 0.5, patrol_center.y))

	for center in [sleeping_center, cloaked_center, lazy_center, patrol_center]:
		_add_map_line(canvas, Vector2(center.x + CONTRACT_NODE_SIZE.x * 0.5, center.y), Vector2(convergence_x, center.y))
	_add_map_line(canvas, Vector2(convergence_x, sleeping_center.y), Vector2(convergence_x, patrol_center.y))
	_add_map_line(canvas, Vector2(convergence_x, knives_center.y), Vector2(knives_center.x - CONTRACT_NODE_SIZE.x * 0.5, knives_center.y))
	_add_map_line(canvas, Vector2(knives_center.x + CONTRACT_NODE_SIZE.x * 0.5, knives_center.y), Vector2(vyra_center.x - CONTRACT_NODE_SIZE.x * 0.5, vyra_center.y))


func _contract_node_center(top_left: Vector2) -> Vector2:
	return top_left + CONTRACT_NODE_SIZE * 0.5


func _add_map_line(canvas: Control, start: Vector2, end: Vector2) -> void:
	var line := ColorRect.new()
	line.color = CONTRACT_LINE_COLOR
	if absf(end.x - start.x) >= absf(end.y - start.y):
		line.position = Vector2(minf(start.x, end.x), start.y - CONTRACT_LINE_THICKNESS * 0.5)
		line.custom_minimum_size = Vector2(absf(end.x - start.x), CONTRACT_LINE_THICKNESS)
		line.size = line.custom_minimum_size
	else:
		line.position = Vector2(start.x - CONTRACT_LINE_THICKNESS * 0.5, minf(start.y, end.y))
		line.custom_minimum_size = Vector2(CONTRACT_LINE_THICKNESS, absf(end.y - start.y))
		line.size = line.custom_minimum_size
	canvas.add_child(line)


func _add_contract_route_button(canvas: Control, node: ContractRouteNode, position: Vector2) -> void:
	var button := Button.new()
	button.position = position
	button.custom_minimum_size = CONTRACT_NODE_SIZE
	button.size = CONTRACT_NODE_SIZE
	button.text = _contract_schematic_node_text(node)
	button.tooltip_text = _route_node_tooltip(node)
	var selectable := _route_node_is_selectable(node)
	button.disabled = not selectable
	if selectable:
		button.pressed.connect(_on_contract_route_node_pressed.bind(node))
	_style_map_node(button, selectable or BuildState.current_route_node == node)
	_map_node_buttons.append(button)
	canvas.add_child(button)


func _contract_schematic_node_text(node: ContractRouteNode) -> String:
	var lines: PackedStringArray = []
	lines.append(node.display_name)
	for reward_line in _contract_schematic_reward_lines(node):
		lines.append(reward_line)
	return "\n".join(lines)


func _contract_schematic_reward_lines(node: ContractRouteNode) -> PackedStringArray:
	var lines: PackedStringArray = []
	if node == null or node.reward == null:
		return lines
	var reward_label := _contract_reward_display(node)
	if reward_label != "":
		lines.append(reward_label)
	return lines


func _contract_reward_display(node: ContractRouteNode) -> String:
	if node == null or node.reward == null:
		return ""
	if node.reward.gear_choice_rewards.size() > 0:
		return "%s Gear" % _tier_name_for_reward_gear(node.reward.gear_choice_rewards[0])
	if node.reward.generated_gear_choice_count > 0:
		return "%s Gear" % GearGenerator.TIER_NAMES[node.reward.generated_gear_tier]
	if node.reward_quality_label == "Contract Victory":
		return node.reward_quality_label
	return ""


func _tier_name_for_reward_gear(gear: GearItem) -> String:
	if gear == null:
		return "Gear"
	return GearGenerator.TIER_NAMES[gear.tier]


func _route_node_is_selectable(node: ContractRouteNode) -> bool:
	return (
		BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE
		and not BuildState.needs_secondary_subclass_choice()
		and BuildState.current_route_node != null
		and BuildState.current_route_node.next_nodes.has(node)
	)


func _gilded_serpent_secondary_node() -> ContractRouteNode:
	if BuildState.active_contract == null or BuildState.active_contract.offer_node == null:
		return null
	if BuildState.active_contract.offer_node.next_nodes.is_empty():
		return null
	return BuildState.active_contract.offer_node.next_nodes[0]


func _find_route_node(root_node: ContractRouteNode, id: String, visited: Array[String] = []) -> ContractRouteNode:
	if root_node == null or visited.has(root_node.id):
		return null
	if root_node.id == id:
		return root_node
	visited.append(root_node.id)
	for child in root_node.next_nodes:
		var found := _find_route_node(child, id, visited)
		if found != null:
			return found
	return null


func _make_tavern_map_node_button(index: int) -> Button:
	var current_index := BuildState.current_encounter_index
	var is_current := BuildState.is_tavern_planning() and index == current_index
	var is_selectable := is_current and BuildState.needs_tavern_map_choice()
	var is_revealed := index <= current_index
	var encounter := RunFlow.load_encounter(index)
	var button := Button.new()
	button.custom_minimum_size = MAP_NODE_SIZE
	button.text = encounter.monster.display_name if is_revealed and encounter != null else "Unknown"
	button.disabled = not is_selectable
	button.pressed.connect(_on_map_node_pressed.bind(index))
	_style_map_node(button, is_current)
	return button


func _make_map_connector() -> Control:
	var connector := ColorRect.new()
	connector.custom_minimum_size = Vector2(80, 6)
	connector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	connector.color = Color(0.4, 0.4, 0.45)
	return connector


func _style_map_node(button: Button, is_current: bool) -> void:
	var color := Color(0.28, 0.43, 0.48) if is_current else Color(0.24, 0.24, 0.27)
	var border_color := CardStyle.ACCENT_COLOR if is_current else Color(0.4, 0.4, 0.45)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = color
		style.border_color = border_color
		style.set_border_width_all(3)
		style.set_corner_radius_all(8)
		button.add_theme_stylebox_override(state, style)
		button.add_theme_color_override("font_color", Color(0.92, 0.92, 0.94))
		button.add_theme_color_override("font_disabled_color", Color(0.62, 0.62, 0.66))


func _tavern_story_text() -> String:
	var encounter := BuildState.current_encounter()
	if encounter == null:
		return "The Tavern is quiet for the moment."
	if BuildState.needs_tavern_map_choice():
		return "The Tavern trail is still unfolding. Pick the only lead you can read right now: %s." % encounter.monster.display_name
	return "%s is marked. Tune the build, lock in, and start the fight when ready." % encounter.monster.display_name


func _contract_route_story_text() -> String:
	var node := BuildState.current_route_node
	if node == null:
		return "The route has not been charted yet."
	if BuildState.needs_secondary_subclass_choice():
		return node.summary_text
	if BuildState.is_contract_fight_active():
		return "%s is marked. Tune the build, lock in, and start the fight when ready." % node.display_name
	return "Choose the first route into The Gilded Serpent. Enemy pressure and reward quality matter from here."


func _route_node_button_text(node: ContractRouteNode) -> String:
	if node == null:
		return "Route Pending"
	var lines: PackedStringArray = []
	lines.append(node.display_name)
	if node.monster != null:
		lines.append("HP %d | Armor %d" % [node.monster.hp, node.monster.armor])
		lines.append("Poison %.0f%% | %.0fs" % [node.monster.poison_resistance * 100.0, node.duration_ms / 1000.0])
	if node.difficulty_label != "":
		lines.append(node.difficulty_label)
	if node.reward_quality_label != "":
		lines.append(node.reward_quality_label)
	return "\n".join(lines)


func _route_node_tooltip(node: ContractRouteNode) -> String:
	var parts: PackedStringArray = []
	parts.append(node.summary_text)
	if node.difficulty_label != "":
		parts.append("Difficulty: %s" % node.difficulty_label)
	var reward_label := _contract_reward_display(node)
	if reward_label != "":
		parts.append("Reward: %s" % reward_label)
	return "\n".join(parts)


func _show_initial_map_if_needed() -> void:
	if BuildState.needs_tavern_map_choice():
		_show_map_overlay(false)


func _on_map_button_pressed() -> void:
	_show_map_overlay(true)


func _show_map_overlay(manual_open: bool = false) -> void:
	_map_manual_open = manual_open
	_refresh_map_overlay()
	_map_overlay.visible = true


func _map_requires_choice() -> bool:
	return (
		BuildState.needs_tavern_map_choice()
		or BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER
		or BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE
	)


func _on_map_node_pressed(index: int) -> void:
	if index != BuildState.current_encounter_index:
		return
	if BuildState.choose_current_tavern_encounter():
		_map_overlay.visible = false
		_map_manual_open = false
		_status_label.visible = true
		var encounter := BuildState.current_encounter()
		if encounter != null:
			_status_label.text = "Selected: %s. Adjust your build, lock in, then fight." % encounter.monster.display_name
		_autosave()


func _on_contract_map_pressed() -> void:
	if BuildState.accept_contract_offer():
		_map_overlay.visible = false
		_map_manual_open = false
		_show_secondary_subclass_overlay()
		_autosave()


func _on_contract_route_node_pressed(node: ContractRouteNode) -> void:
	if node == null or BuildState.needs_secondary_subclass_choice():
		return
	if BuildState.choose_contract_route_node(node):
		_map_overlay.visible = false
		_map_manual_open = false
		_status_label.visible = true
		_status_label.text = "Selected route: %s. Adjust your build, lock in, then fight." % node.display_name
		_autosave()


func _build_shop_overlay() -> void:
	_shop_overlay = PanelContainer.new()
	_shop_overlay.visible = false
	_shop_overlay.add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	_combat_content.add_child(_shop_overlay)

	var content := HBoxContainer.new()
	content.custom_minimum_size = Vector2(620, 360)
	content.add_theme_constant_override("separation", 12)
	_shop_overlay.add_child(content)

	var shopkeeper := PanelContainer.new()
	shopkeeper.custom_minimum_size = Vector2(260, 0)
	shopkeeper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var keeper_style := CardStyle.make_stylebox(8)
	keeper_style.bg_color = Color(0.1, 0.1, 0.12)
	shopkeeper.add_theme_stylebox_override("panel", keeper_style)
	content.add_child(shopkeeper)

	var keeper_label := Label.new()
	keeper_label.text = "Shopkeeper"
	keeper_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keeper_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shopkeeper.add_child(keeper_label)

	var shop_content := VBoxContainer.new()
	shop_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_content.add_theme_constant_override("separation", 12)
	content.add_child(shop_content)

	var header := HBoxContainer.new()
	shop_content.add_child(header)

	var title := Label.new()
	title.text = "Tavern Shop"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	header.add_child(title)

	_shop_reroll_button = Button.new()
	_shop_reroll_button.pressed.connect(_on_shop_reroll_pressed)
	header.add_child(_shop_reroll_button)

	_shop_gold_label = Label.new()
	_shop_gold_label.visible = false
	shop_content.add_child(_shop_gold_label)

	_shop_status_label = Label.new()
	_shop_status_label.visible = false
	shop_content.add_child(_shop_status_label)

	_shop_offers_box = GridContainer.new()
	_shop_offers_box.columns = 2
	_shop_offers_box.add_theme_constant_override("h_separation", 10)
	_shop_offers_box.add_theme_constant_override("v_separation", 10)
	shop_content.add_child(_shop_offers_box)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_content.add_child(spacer)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	button_row.add_theme_constant_override("separation", 12)
	shop_content.add_child(button_row)

	_shop_leave_button = Button.new()
	_shop_leave_button.text = "Leave Shop"
	_shop_leave_button.pressed.connect(_on_shop_continue_pressed)
	button_row.add_child(_shop_leave_button)


func _build_reward_choice_overlay() -> void:
	_reward_choice_overlay = PanelContainer.new()
	_reward_choice_overlay.visible = false
	_reward_choice_overlay.add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	_combat_content.add_child(_reward_choice_overlay)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(520, 240)
	content.add_theme_constant_override("separation", 12)
	_reward_choice_overlay.add_child(content)

	_reward_choice_title = Label.new()
	_reward_choice_title.text = "Choose Reward"
	_reward_choice_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reward_choice_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	_reward_choice_title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	content.add_child(_reward_choice_title)

	_reward_choice_options = HBoxContainer.new()
	_reward_choice_options.alignment = BoxContainer.ALIGNMENT_CENTER
	_reward_choice_options.add_theme_constant_override("separation", 12)
	content.add_child(_reward_choice_options)


func _build_secondary_subclass_overlay() -> void:
	_secondary_subclass_overlay = Control.new()
	_secondary_subclass_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_secondary_subclass_overlay.visible = false
	add_child(_secondary_subclass_overlay)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = BACKDROP_COLOR
	_secondary_subclass_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_secondary_subclass_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox(18))
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(640, 300)
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)

	_secondary_subclass_title = Label.new()
	_secondary_subclass_title.text = "Choose a Second Rogue Tree"
	_secondary_subclass_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_secondary_subclass_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	_secondary_subclass_title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	content.add_child(_secondary_subclass_title)

	_secondary_subclass_body = Label.new()
	_secondary_subclass_body.text = "The contract is bigger than one style. Pick the second tree that will carry you through Vyra's route."
	_secondary_subclass_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_secondary_subclass_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_secondary_subclass_body)

	_secondary_subclass_options = HBoxContainer.new()
	_secondary_subclass_options.alignment = BoxContainer.ALIGNMENT_CENTER
	_secondary_subclass_options.add_theme_constant_override("separation", 12)
	content.add_child(_secondary_subclass_options)


func _show_secondary_subclass_overlay() -> void:
	_refresh_secondary_subclass_options()
	_secondary_subclass_overlay.visible = true


func _refresh_secondary_subclass_options() -> void:
	for child in _secondary_subclass_options.get_children():
		child.queue_free()
	if BuildState.selected_class == null:
		return
	for tree in BuildState.selected_class.trees:
		if BuildState.selected_trees.has(tree):
			continue
		_secondary_subclass_options.add_child(_make_secondary_tree_button(tree))


func _make_secondary_tree_button(tree: SubclassTree) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(220, 130)
	button.text = "%s\n\nIntrinsic: %s" % [tree.display_name, _intrinsic_description_for_tree(tree)]
	button.pressed.connect(_on_secondary_tree_pressed.bind(tree))
	var style := CardStyle.make_stylebox(12)
	style.bg_color = Color(0.22, 0.22, 0.25)
	style.border_color = CardStyle.ACCENT_COLOR
	for state in ["normal", "hover", "pressed", "focus"]:
		button.add_theme_stylebox_override(state, style)
	return button


func _intrinsic_description_for_tree(tree: SubclassTree) -> String:
	if tree.intrinsic_text != "":
		return tree.intrinsic_text
	var parts: PackedStringArray = []
	for skill in tree.unlocked_skills:
		parts.append("Unlocks %s" % skill.display_name)
	for modifier in tree.innate_modifiers:
		parts.append(StatModifierFormatter.format(modifier))
	for augment in tree.skill_augments:
		parts.append(_skill_augment_description_for_tree(augment))
	if parts.is_empty():
		return "None"
	return ", ".join(parts)


func _skill_augment_description_for_tree(augment: SkillAugment) -> String:
	if augment == null:
		return ""
	var target_names: PackedStringArray = []
	for target_id in augment.target_skill_ids:
		target_names.append(_skill_name_for_id(target_id))
	var effect_names: PackedStringArray = []
	for effect in augment.extra_effects:
		if effect is PoisonDamageEffect:
			var poison_effect: PoisonDamageEffect = effect
			effect_names.append("+%d poison stack%s" % [poison_effect.stacks_applied, "" if poison_effect.stacks_applied == 1 else "s"])
	if target_names.is_empty() or effect_names.is_empty():
		return "Enhances selected skills"
	return "%s gain %s" % [", ".join(target_names), ", ".join(effect_names)]


func _skill_name_for_id(skill_id: String) -> String:
	if BuildState.selected_class != null:
		for skill in BuildState.selected_class.base_skills:
			if skill.id == skill_id:
				return skill.display_name
		for tree in BuildState.selected_class.trees:
			for skill in tree.unlocked_skills:
				if skill.id == skill_id:
					return skill.display_name
			for talent in tree.talents:
				for skill in talent.unlocked_skills:
					if skill.id == skill_id:
						return skill.display_name
	return skill_id


func _show_shop_overlay() -> void:
	if _map_overlay != null:
		_map_overlay.visible = false
	_status_label.visible = false
	_view_log_button.visible = false
	_retry_button.visible = false
	_restart_adventure_button.visible = false
	_refresh_shop_overlay()
	_shop_overlay.visible = true


func _show_reward_choice_overlay() -> void:
	if _map_overlay != null:
		_map_overlay.visible = false
	_status_label.visible = false
	_view_log_button.visible = false
	_retry_button.visible = false
	_restart_adventure_button.visible = false
	for child in _reward_choice_options.get_children():
		child.queue_free()
	for gear in BuildState.pending_reward_choices:
		_reward_choice_options.add_child(_make_reward_choice_button(gear))
	_reward_choice_overlay.visible = true


func _make_reward_choice_button(gear: GearItem) -> Button:
	var item_box := Button.new()
	item_box.custom_minimum_size = Vector2(112, 112)
	item_box.text = ""
	item_box.tooltip_text = _reward_choice_text(gear)
	item_box.pressed.connect(_on_reward_choice_pressed.bind(gear))
	_style_shop_item_box(item_box, gear)
	return item_box


func _reward_choice_text(gear: GearItem) -> String:
	var lines: PackedStringArray = []
	lines.append("%s - %s" % [GearGenerator.SLOT_TAGS[gear.slot], gear.display_name])
	lines.append(GearGenerator.TIER_NAMES[gear.tier])
	for affix in gear.affixes:
		lines.append(StatModifierFormatter.format(affix))
	for trigger in gear.triggered_skill_effects:
		if trigger != null and trigger.skill != null:
			lines.append("%d%% chance to trigger %s" % [roundi(trigger.chance * 100.0), trigger.skill.display_name])
	return "\n".join(lines)


func _on_build_state_changed() -> void:
	if _shop_overlay != null and _shop_overlay.visible:
		_refresh_shop_overlay()


func _on_run_state_changed() -> void:
	if _map_overlay != null:
		_refresh_map_overlay()
	if _seed_label != null:
		_seed_label.text = _seed_label_text()


func _refresh_shop_overlay() -> void:
	_shop_gold_label.text = ""
	_shop_status_label.text = ""
	_shop_reroll_button.text = "Reroll (%d)" % (0 if BuildState.shop_reroll_used else 1)
	_shop_reroll_button.disabled = BuildState.shop_reroll_used
	for child in _shop_offers_box.get_children():
		child.queue_free()
	for offer in BuildState.shop_offers:
		_shop_offers_box.add_child(_make_shop_offer_row(offer))


func _make_shop_offer_row(offer: GearItem) -> Control:
	var item_box := Button.new()
	item_box.custom_minimum_size = Vector2(88, 88)
	item_box.text = ""
	item_box.tooltip_text = _shop_offer_text(offer)
	item_box.disabled = GearGenerator.price_for_tier(offer.tier) > BuildState.gold or not BuildState.can_store_shop_offer(offer)
	item_box.pressed.connect(_on_shop_buy_pressed.bind(offer))
	_style_shop_item_box(item_box, offer)
	return item_box


func _style_shop_item_box(button: Button, offer: GearItem) -> void:
	var color := Color(0.35, 0.75, 0.35)
	match offer.tier:
		GearItem.Tier.MASTER:
			color = Color(0.3, 0.55, 0.9)
		GearItem.Tier.CURSED:
			color = Color(0.65, 0.4, 0.85)
		GearItem.Tier.LEGENDARY:
			color = Color(0.95, 0.55, 0.18)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = color
		style.border_color = Color(0.15, 0.15, 0.17)
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		button.add_theme_stylebox_override(state, style)


func _shop_offer_title(offer: GearItem) -> String:
	return "%s - %s" % [
		GearGenerator.SLOT_TAGS[offer.slot],
		offer.display_name,
	]


func _shop_offer_text(offer: GearItem) -> String:
	var lines: PackedStringArray = []
	lines.append(_shop_offer_title(offer))
	for affix in offer.affixes:
		lines.append(StatModifierFormatter.format(affix))
	lines.append("Price: %dg" % GearGenerator.price_for_tier(offer.tier))
	return "\n".join(lines)


func _build_confirm_dialog() -> void:
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "Abandon Run"
	_confirm_dialog.dialog_text = "Are you sure you want to abandon this run? Any saved progress will be deleted."
	_confirm_dialog.confirmed.connect(_on_abandon_confirmed)
	add_child(_confirm_dialog)


func _on_abandon_confirmed() -> void:
	SaveSystem.delete_save()
	main_menu_pressed.emit()


func _on_save_and_quit_pressed() -> void:
	SaveSystem.save_run(BuildState)
	save_and_quit_pressed.emit()


## Autosave point (P2:R6:T6): called after each meaningful state
## transition (encounter/route choice, fight result, reward claim, shop
## action, retry) so a crash or unexpected quit loses at most the current
## in-progress build edit, not the whole run. Never called while
## BuildState.run_phase == FIGHTING -- BuildState.finish_fight() always
## resolves the fight synchronously before any of these handlers reach
## their autosave call, so there's no mid-fight state to snapshot.
func _autosave() -> void:
	SaveSystem.save_run(BuildState)


func _on_fight_pressed() -> void:
	if not BuildState.start_fight():
		return
	if _map_overlay != null:
		_map_overlay.visible = false
	var stats := BuildResolver.resolve_stats(
		BuildState.selected_class, BuildState.selected_trees, BuildState.selected_talents, BuildState.equipped_gear()
	)
	var rotation := BuildResolver.resolve_rotation(BuildState.rotation, BuildState.unlocked_skills())
	var monster: Monster = _enemy_panel.monster()
	var duration_ms: int = _enemy_panel.duration_ms()
	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, stats, monster, duration_ms, BuildState.current_combat_rng_seed())
	_log_label.text = CombatResultFormatter.format(result, monster)
	_status_label.text = "Fight complete: %s" % ("WIN" if result.is_win else "LOSS")
	_view_log_button.disabled = false
	BuildState.finish_fight(result.is_win)
	if result.is_win:
		_outcome_title_label.visible = false
		_retry_button.visible = false
		_restart_adventure_button.visible = false
		_show_victory_banner(result)
	else:
		_apply_outcome_presentation(BuildState.run_outcome)
	_autosave()


func _on_continue_pressed() -> void:
	var claimed := BuildState.claim_current_reward()
	_victory_overlay.visible = false
	if claimed:
		_autosave()
	if claimed and BuildState.has_pending_reward_choice():
		_show_reward_choice_overlay()
		return
	if claimed and BuildState.open_shop_round():
		_status_label.text = "Spend gold or keep saving, then leave the shop."
		_show_shop_overlay()
		return
	_advance_after_reward_or_shop()


func _on_shop_buy_pressed(offer: GearItem) -> void:
	if BuildState.buy_shop_offer(offer):
		_shop_status_label.text = ""
		_autosave()
	elif not BuildState.can_store_shop_offer(offer):
		_shop_status_label.text = ""
	else:
		_shop_status_label.text = ""
	_refresh_shop_overlay()


func _on_shop_reroll_pressed() -> void:
	if BuildState.reroll_shop_offers():
		_shop_status_label.text = "New offers."
		_autosave()
	_refresh_shop_overlay()


func _on_shop_continue_pressed() -> void:
	BuildState.close_shop_round()
	_shop_overlay.visible = false
	_status_label.visible = true
	_view_log_button.visible = true
	_advance_after_reward_or_shop()


func _on_secondary_tree_pressed(tree: SubclassTree) -> void:
	if BuildState.choose_secondary_tree(tree):
		_secondary_subclass_overlay.visible = false
		_status_label.visible = true
		_status_label.text = "Second tree chosen: %s. Choose the contract route." % tree.display_name
		_show_map_overlay(false)
		_autosave()


func _on_reward_choice_pressed(gear: GearItem) -> void:
	if BuildState.choose_pending_reward_gear(gear):
		_reward_choice_overlay.visible = false
		_autosave()
		if BuildState.open_shop_round():
			_status_label.text = "Spend gold or keep saving, then leave the shop."
			_show_shop_overlay()
			return
		_status_label.visible = true
		_view_log_button.visible = true
		_advance_after_reward_or_shop()


func _on_retry_pressed() -> void:
	if BuildState.retry_current_encounter():
		_outcome_title_label.visible = false
		_retry_button.visible = false
		_restart_adventure_button.visible = false
		_status_label.text = "Retry ready. Adjust your build, lock in, then fight again."
		_autosave()


func _advance_after_reward_or_shop() -> void:
	var advanced := BuildState.continue_after_win()
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_status_label.text = "Choose the contract on the map."
		_show_map_overlay(false)
	elif BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE:
		_status_label.text = "Choose the next route step."
		_show_map_overlay(false)
	elif advanced:
		_status_label.text = "Choose the next opponent on the map."
		_show_map_overlay(false)
	else:
		_apply_outcome_presentation(BuildState.run_outcome)
	_autosave()


func _seed_label_text() -> String:
	return "Seed: %d" % BuildState.adventure_seed


## Central mapping from BuildState.RunOutcome to a headline, body text, and
## available actions, so every loss/do-over/restart/victory state is
## explicit instead of scattered inline status text (P2:R5:T8). Called both
## right after a losing fight and after claiming the final contract/Tavern
## reward, since a terminal win outcome is only known post-claim.
func _apply_outcome_presentation(outcome: int) -> void:
	_status_label.visible = true
	_restart_adventure_button.text = "Restart Adventure"
	match outcome:
		BuildState.RunOutcome.FIGHT_LOSS_RETRY:
			_set_outcome_title("DEFEATED", OUTCOME_LOSS_COLOR)
			_status_label.text = "One retry available: adjust your build, then retry this encounter."
			_retry_button.visible = true
			_retry_button.disabled = false
			_restart_adventure_button.visible = false
		BuildState.RunOutcome.CONTRACT_FAILED:
			_set_outcome_title("CONTRACT FAILED", OUTCOME_LOSS_COLOR)
			_status_label.text = "The route collapses here. Restart preserves Seed %d." % BuildState.adventure_seed
			_retry_button.visible = false
			_restart_adventure_button.visible = true
			_restart_adventure_button.disabled = false
		BuildState.RunOutcome.ADVENTURE_RESTART_REQUIRED:
			_set_outcome_title("ADVENTURE OVER", OUTCOME_LOSS_COLOR)
			_status_label.text = "No retries remain for this encounter. Restart preserves Seed %d." % BuildState.adventure_seed
			_retry_button.visible = false
			_restart_adventure_button.visible = true
			_restart_adventure_button.disabled = false
		BuildState.RunOutcome.CONTRACT_VICTORY:
			_set_outcome_title("CONTRACT COMPLETE", CardStyle.ACCENT_COLOR)
			_status_label.text = "Vyra is defeated. Seed %d is preserved if you start a new Adventure." % BuildState.adventure_seed
			_retry_button.visible = false
			_restart_adventure_button.visible = true
			_restart_adventure_button.disabled = false
			_restart_adventure_button.text = "Start New Adventure"
		BuildState.RunOutcome.FIGHT_WIN:
			# Only reached if the Tavern ladder ends without an active contract.
			_set_outcome_title("RUN COMPLETE", CardStyle.ACCENT_COLOR)
			_status_label.text = "Tavern sequence cleared. Seed %d is preserved if you start a new Adventure." % BuildState.adventure_seed
			_retry_button.visible = false
			_restart_adventure_button.visible = true
			_restart_adventure_button.disabled = false
			_restart_adventure_button.text = "Start New Adventure"
		_:
			_outcome_title_label.visible = false
			_retry_button.visible = false
			_restart_adventure_button.visible = false


func _set_outcome_title(text: String, color: Color) -> void:
	_outcome_title_label.text = text
	_outcome_title_label.add_theme_color_override("font_color", color)
	_outcome_title_label.visible = true
