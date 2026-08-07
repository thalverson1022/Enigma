extends Control
## The Map overlay: the Tavern encounter ladder, the Contract Offer node, and
## the Gilded Serpent route schematic all share this one window, switching
## which of the three it renders off BuildState. Extracted from
## combat_screen.gd's inline overlay builder
## (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md Phase 3) -- gates a
## real decision with no defined "cancel" behavior, so it stays locked (no
## dismiss on outside click), matching its behavior before extraction.
##
## Like the other extracted overlays, this scene owns its own construction,
## refresh, and node/story presentation, but NOT the consequences of a
## choice: `tavern_proceed_pressed`, `contract_offer_pressed`, and
## `route_node_pressed(node)` hand those to combat_screen.gd, which owns
## BuildState mutation, the dashboard chrome, and autosaving.
##
## No `class_name` -- this script references the BuildState autoload; see
## contract_overlay.gd's header for why that rules out a global class.
##
## NOTE (carried over unchanged from combat_screen.gd): the Gilded Serpent
## route schematic below is hardcoded to one contract's node ids and
## hand-tuned pixel positions. That is finding 1.4 in the tech-debt doc,
## deliberately deferred until a second contract exists rather than
## generalized speculatively during this extraction.

## The player picked a Tavern encounter and pressed Proceed.
signal tavern_proceed_pressed
## The player clicked the single Contract Offer node.
signal contract_offer_pressed
## The player clicked a selectable contract-route node.
signal route_node_pressed(node: ContractRouteNode)

const MAP_NODE_SIZE := Vector2(190, 150)
const CONTRACT_MAP_SIZE := Vector2(840, 470)
const CONTRACT_NODE_SIZE := Vector2(164, 108)
const MAP_ACTOR_MARKER_SIZE := Vector2(76, 76)
const MAP_ACTOR_MARKER_OFFSET := Vector2(10, -4)
const MAP_REWARD_ICON_SIZE := Vector2(24, 24)
const MAP_TEXT_BLOCK_LEFT := 76.0
const MAP_TEXT_BLOCK_TOP := 26.0
const MAP_TEXT_BLOCK_BOTTOM := 34.0
## Tavern map's art box -- the exterior shot shown while choosing a Tavern
## encounter, replacing the earlier plain black placeholder.
const TAVERN_MAP_ART_TEXTURE := preload("res://assets/backgrounds/Tavern__Exterior.jpg")
## Smaller than MAP_NODE_SIZE -- the Tavern map (P2:R7 story pass) makes room
## for TAVERN_ART_BOX_SIZE above it and sits lower in the panel, so its own
## node buttons shrink to match rather than crowding the reduced space.
const TAVERN_MAP_NODE_SIZE := Vector2(170, 108)
## Placeholder for future scene art above the Tavern's node row -- same
## "solid near-black fill, art to come later" convention as the combat
## window's own UIColors.PANEL_DEEP background.
const TAVERN_ART_BOX_SIZE := Vector2(760, 200)
const FLOW_TEXT := preload("res://scripts/ui/adventure_flow_text.gd")

## The Tavern map's default flavor line, shown until a node is clicked to
## preview it (see _tavern_story_text()).
const TAVERN_INTRO_TEXT := "You find a nice respite from the rain in the dim light of a warm tavern. You do your best to mind your own business, but fate does not always abide."

## Per-encounter flavor line shown once its node is clicked (preview state,
## before Proceed commits the choice) -- keyed by Monster.display_name, the
## same key _tavern_story_text() already reads off BuildState.current_encounter().
const TAVERN_ENCOUNTER_FLAVOR_TEXT := {
	"Mouthy Drunk": "A red-faced patron decides your quiet corner is somehow his business.",
	"Drunk Buddy": "Leaping to his fallen companion's aid, another drunk patron wants to try his hand.",
	"Tavern Bouncer": "The burley bouncer grabs you to politely show you the door.",
	"Hired Goon": "A mysterious and sinister figure in the corner takes notice. His large bodyguard steps over to have a word with you.",
}

## Shown on the map when returning to it after winning that encounter --
## i.e. while choosing the *next* encounter, before its own node is previewed
## (see _tavern_pre_choice_story_text()). Keyed the same way as
## TAVERN_ENCOUNTER_FLAVOR_TEXT. Reflects the new state of the story rather
## than replaying TAVERN_INTRO_TEXT a second time.
const TAVERN_VICTORY_TEXT := {
	"Mouthy Drunk": "You easily dispatch him with a few well-placed strikes. He falls into a heap on the floor. However, this has caused quite the commotion.",
	"Drunk Buddy": "He lands with a thud atop the fallen body of his companion, but now the tavern is abuzz with action. You have made your pressence known; however you are not sure that was the best idea.",
	"Tavern Bouncer": "The night is cold and the fire warm, so you not-so politely decline his invitation. The rest of the patrons have scattered. Now you might get some peace and quite.",
	"Hired Goon": "Being in no mood for this, you \"pursuede\" the large gentlemen to joins the gorwing pile of bodies.",
}

const CONTRACT_LINE_COLOR := UIColors.STRUCTURE_LINE
const CONTRACT_LINE_HIGHLIGHT_COLOR := Color(0.79, 0.64, 0.35, 0.42)
const CONTRACT_LINE_THICKNESS := 5.0
## Map/contract-route/secondary-tree buttons carry dense multi-line data
## text (stats, difficulty, reward tags) rather than a short action label,
## so they stay on the VT323 body/data font instead of the theme's default
## Press Start 2P button font -- Press Start 2P's width would clip or
## badly overflow these fixed-size, multi-line buttons (P2:R7:T2 Phase 2
## legibility pass).
const DATA_BUTTON_FONT := preload("res://assets/fonts/VT323-Regular.ttf")
const MAP_ICON := preload("res://assets/ui/icons/map.png")
const CONTRACT_ICON := preload("res://assets/ui/icons/contract.png")
const FIGHT_ICON := preload("res://assets/ui/icons/fight.png")
const GOLD_ICON := preload("res://assets/ui/icons/gold.png")
const GEAR_DROP_ICON_PATHS := {
	GearItem.Tier.BASIC: "res://assets/ui/icons/gear_drop_helm_basic.png",
	GearItem.Tier.MASTER: "res://assets/ui/icons/gear_drop_helm_master.png",
	GearItem.Tier.CURSED: "res://assets/ui/icons/gear_drop_helm_cursed.png",
	GearItem.Tier.LEGENDARY: "res://assets/ui/icons/gear_drop_helm_legendary.png",
}

enum TavernNodeState { DEFEATED, AVAILABLE, PREVIEWED, LOCKED }
const AVAILABLE_PULSE_DURATION_SEC := 0.72

var _map_phase_label: Label
var _map_story_label: Label
var _map_art_box: Control
var _map_nodes_box: HBoxContainer
var _map_node_buttons: Array[Button] = []
var _map_close_button: Button
var _map_proceed_button: Button
var _map_manual_open: bool = false
var _pending_contract_route_node: ContractRouteNode = null
var _gear_drop_icon_cache: Dictionary = {}
## Which Tavern node the player has clicked to preview but not yet committed
## via Proceed; -1 when nothing is previewed.
var _tavern_preview_index: int = -1


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var panel := CardStyle.build_modal_panel(self, false)
	var style := CardStyle.make_stylebox(18)
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(940, 560)
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	content.add_child(title_row)

	title_row.add_child(CardStyle.make_pixel_icon(MAP_ICON, CardStyle.UI_ICON_SIZE))

	var title := Label.new()
	title.text = "Map"
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	title_row.add_child(title)

	_map_phase_label = Label.new()
	_map_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_map_phase_label.add_theme_font_size_override("font_size", 24)
	content.add_child(_map_phase_label)

	_map_story_label = Label.new()
	_map_story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_map_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_map_story_label.custom_minimum_size = Vector2(760, 0)
	content.add_child(_map_story_label)

	# Tavern-only scene art (hidden for Contract Offer/Route, which never set
	# it visible) -- sized/positioned so the node row below reads as smaller
	# and pushed toward the bottom of the panel, per the story pass's mockup.
	_map_art_box = PanelContainer.new()
	_map_art_box.custom_minimum_size = TAVERN_ART_BOX_SIZE
	_map_art_box.visible = false
	var art_box_style := CardStyle.make_stylebox(8)
	art_box_style.bg_color = UIColors.PANEL_DEEP
	_map_art_box.add_theme_stylebox_override("panel", art_box_style)
	content.add_child(_map_art_box)

	var map_art_image := TextureRect.new()
	map_art_image.texture = TAVERN_MAP_ART_TEXTURE
	map_art_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_art_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	map_art_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_art_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_art_box.add_child(map_art_image)

	var center_row := CenterContainer.new()
	center_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center_row)

	_map_nodes_box = HBoxContainer.new()
	_map_nodes_box.add_theme_constant_override("separation", 0)
	center_row.add_child(_map_nodes_box)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	button_row.add_theme_constant_override("separation", 8)
	content.add_child(button_row)

	# Tavern and Contract Route both use select-then-Proceed: node clicks
	# preview/select, while this button is the actual commit step.
	_map_proceed_button = Button.new()
	_map_proceed_button.text = FLOW_TEXT.ACTION_PROCEED
	CardStyle.configure_icon_button(_map_proceed_button, FIGHT_ICON)
	_map_proceed_button.visible = false
	_map_proceed_button.disabled = true
	_map_proceed_button.pressed.connect(_on_map_proceed_pressed)
	button_row.add_child(_map_proceed_button)

	_map_close_button = Button.new()
	_map_close_button.text = FLOW_TEXT.ACTION_CLOSE_MAP
	_map_close_button.pressed.connect(func(): visible = false)
	button_row.add_child(_map_close_button)
	refresh()


func refresh() -> void:
	if _map_nodes_box == null:
		return
	_sync_pending_contract_route_node()
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
	_map_phase_label.text = "The Nooby Tavern"
	_map_story_label.text = _tavern_story_text()
	_map_art_box.visible = true
	_map_proceed_button.text = FLOW_TEXT.ACTION_PROCEED
	# Always visible while a choice is pending (not just once previewed),
	# just disabled until then -- same "always there, grayed out until you
	# act" pattern as the Contract Window's own Proceed button, deliberately,
	# so this teaches the player what to expect there.
	_map_proceed_button.visible = BuildState.needs_tavern_map_choice()
	_map_proceed_button.disabled = _tavern_preview_index != BuildState.current_encounter_index
	_map_proceed_button.tooltip_text = (
		"Click the available Tavern fight first."
		if _map_proceed_button.disabled
		else "Commit this Tavern fight."
	)
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
	_map_art_box.visible = false
	_map_proceed_button.visible = false
	_map_proceed_button.tooltip_text = ""
	var button := Button.new()
	button.custom_minimum_size = MAP_NODE_SIZE
	button.text = contract.display_name if contract != null else "Unknown Contract"
	CardStyle.configure_icon_button(button, CONTRACT_ICON)
	button.disabled = contract == null
	button.pressed.connect(func(): contract_offer_pressed.emit())
	_style_map_node(button, true)
	_map_node_buttons.append(button)
	_map_nodes_box.add_child(button)


func _refresh_contract_route_map() -> void:
	_map_phase_label.text = BuildState.active_contract.display_name if BuildState.active_contract != null else "Contract Route"
	_map_story_label.text = _contract_route_story_text()
	_map_art_box.visible = false
	_refresh_contract_route_proceed_button()
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
		_disable_map_entry_tooltip(button)
		var selectable := _route_node_is_selectable(choice)
		button.disabled = not selectable
		if selectable:
			button.pressed.connect(_on_contract_route_node_previewed.bind(choice))
		_style_contract_route_node(button, choice, selectable)
		_map_node_buttons.append(button)
		_map_nodes_box.add_child(button)
		if i < choices.size() - 1:
			_map_nodes_box.add_child(_make_map_connector())


func _make_contract_route_schematic() -> Control:
	var secondary := _gilded_serpent_secondary_node()
	if secondary == null or secondary.next_nodes.size() < 2:
		return null
	var door_guard := ContractRouteNode.find_by_id(secondary, "route.gilded_serpent.door_guard")
	var portly_cook := ContractRouteNode.find_by_id(secondary, "route.gilded_serpent.portly_cook")
	var sleeping := ContractRouteNode.find_by_id(secondary, "route.gilded_serpent.sleeping_henchman")
	var cloaked := ContractRouteNode.find_by_id(secondary, "route.gilded_serpent.cloaked_watchmen")
	var lazy := ContractRouteNode.find_by_id(secondary, "route.gilded_serpent.lazy_henchman")
	var patrol := ContractRouteNode.find_by_id(secondary, "route.gilded_serpent.patrolling_guard")
	var knives := ContractRouteNode.find_by_id(secondary, "route.gilded_serpent.knives")
	var vyra := ContractRouteNode.find_by_id(secondary, "route.gilded_serpent.vyra")
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
	var rail := Control.new()
	rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if absf(end.x - start.x) >= absf(end.y - start.y):
		rail.position = Vector2(minf(start.x, end.x), start.y - CONTRACT_LINE_THICKNESS * 0.5)
		rail.custom_minimum_size = Vector2(absf(end.x - start.x), CONTRACT_LINE_THICKNESS + 2.0)
	else:
		rail.position = Vector2(start.x - CONTRACT_LINE_THICKNESS * 0.5, minf(start.y, end.y))
		rail.custom_minimum_size = Vector2(CONTRACT_LINE_THICKNESS + 2.0, absf(end.y - start.y))
	rail.size = rail.custom_minimum_size
	canvas.add_child(rail)

	var core := ColorRect.new()
	core.color = CONTRACT_LINE_COLOR
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	core.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rail.add_child(core)

	var highlight := ColorRect.new()
	highlight.color = CONTRACT_LINE_HIGHLIGHT_COLOR
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if rail.size.x >= rail.size.y:
		highlight.size = Vector2(rail.size.x, 1)
	else:
		highlight.size = Vector2(1, rail.size.y)
	rail.add_child(highlight)


func _add_contract_route_button(canvas: Control, node: ContractRouteNode, position: Vector2) -> void:
	var button := Button.new()
	button.position = position
	button.custom_minimum_size = CONTRACT_NODE_SIZE
	button.size = CONTRACT_NODE_SIZE
	button.clip_contents = false
	button.text = _contract_schematic_node_text(node)
	_disable_map_entry_tooltip(button)
	var selectable := _route_node_is_selectable(node)
	button.disabled = not selectable
	if selectable:
		button.pressed.connect(_on_contract_route_node_previewed.bind(node))
	_style_contract_route_node(button, node, selectable)
	_add_map_text_block(button, node.display_name, not button.disabled)
	_add_map_actor_marker(button, node.monster, not button.disabled)
	_add_reward_icon_row(button, node.reward, not button.disabled)
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
		lines.append("Reward: %s" % reward_label)
	return lines


func _contract_reward_display(node: ContractRouteNode) -> String:
	if node == null or node.reward == null:
		return ""
	if node.reward.gear_choice_rewards.size() > 0:
		return _tier_name_for_reward_gear(node.reward.gear_choice_rewards[0])
	if node.reward.generated_gear_choice_count > 0:
		return GearGenerator.TIER_NAMES[node.reward.generated_gear_tier]
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
		and BuildState.current_route_node != null
		and BuildState.current_route_node.next_nodes.has(node)
	)


func _route_node_is_selected(node: ContractRouteNode) -> bool:
	return _pending_contract_route_node == node or BuildState.current_route_node == node


func _gilded_serpent_secondary_node() -> ContractRouteNode:
	if BuildState.active_contract == null or BuildState.active_contract.offer_node == null:
		return null
	if BuildState.active_contract.offer_node.next_nodes.is_empty():
		return null
	return BuildState.active_contract.offer_node.next_nodes[0]


func _make_tavern_map_node_button(index: int) -> Button:
	var state := _tavern_node_state(index)
	var encounter := RunFlow.load_encounter(index)
	var button := Button.new()
	button.name = "TavernNode%d" % index
	button.custom_minimum_size = TAVERN_MAP_NODE_SIZE
	button.clip_contents = false
	button.text = encounter.monster.display_name if state != TavernNodeState.LOCKED and encounter != null else "Unknown"
	button.disabled = not _tavern_node_is_clickable(state)
	_disable_map_entry_tooltip(button)
	button.pressed.connect(_on_tavern_node_previewed.bind(index))
	_style_tavern_map_node(button, state)
	_add_map_text_block(button, button.text, state != TavernNodeState.LOCKED)
	if state != TavernNodeState.LOCKED and encounter != null:
		_add_map_actor_marker(button, encounter.monster, not button.disabled)
		_add_reward_icon_row(button, encounter.reward, not button.disabled)
	if state == TavernNodeState.DEFEATED:
		_add_tavern_defeated_marker(button)
	elif state == TavernNodeState.AVAILABLE:
		_add_tavern_available_pulse(button)
	return button


func _tavern_node_state(index: int) -> int:
	var current_index := BuildState.current_encounter_index
	if index < current_index:
		return TavernNodeState.DEFEATED
	if not BuildState.is_tavern_planning() or index > current_index:
		return TavernNodeState.LOCKED
	if _tavern_preview_index == index or not BuildState.needs_tavern_map_choice():
		return TavernNodeState.PREVIEWED
	return TavernNodeState.AVAILABLE


func _tavern_node_is_clickable(state: int) -> bool:
	return BuildState.needs_tavern_map_choice() and (state == TavernNodeState.AVAILABLE or state == TavernNodeState.PREVIEWED)


func _tavern_node_tooltip(state: int, encounter) -> String:
	match state:
		TavernNodeState.DEFEATED:
			if encounter != null and encounter.monster != null:
				return "%s defeated." % encounter.monster.display_name
			return "Defeated."
		TavernNodeState.AVAILABLE:
			return "Click to preview this fight, then press Proceed."
		TavernNodeState.PREVIEWED:
			return "Ready. Press Proceed to commit this fight."
	return "Defeat the previous fight to reveal this one."


func _disable_map_entry_tooltip(button: Button) -> void:
	# Keep the tooltip builder functions nearby; map-entry tooltips are only
	# disabled for the current cleaner card treatment.
	button.tooltip_text = ""


func _make_map_connector() -> Control:
	var connector := Control.new()
	connector.custom_minimum_size = Vector2(80, 6)
	connector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	connector.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var core := ColorRect.new()
	core.color = CONTRACT_LINE_COLOR
	core.custom_minimum_size = Vector2(80, 6)
	core.size = core.custom_minimum_size
	core.mouse_filter = Control.MOUSE_FILTER_IGNORE
	connector.add_child(core)

	var highlight := ColorRect.new()
	highlight.color = CONTRACT_LINE_HIGHLIGHT_COLOR
	highlight.custom_minimum_size = Vector2(80, 1)
	highlight.size = highlight.custom_minimum_size
	highlight.mouse_filter = Control.MOUSE_FILTER_IGNORE
	connector.add_child(highlight)
	return connector


func _style_map_node(button: Button, is_current: bool) -> void:
	var fill := UIColors.MAP_NODE_CURRENT if is_current else UIColors.MAP_NODE_INACTIVE
	var border := CardStyle.ACCENT_COLOR if is_current else UIColors.STRUCTURE_LINE_LIGHT
	_apply_map_node_styles(button, fill, border, 5 if is_current else 2, is_current, not is_current)


func _style_tavern_map_node(button: Button, state: int) -> void:
	var color := UIColors.MAP_NODE_INACTIVE
	var border_color := UIColors.STRUCTURE_LINE_LIGHT
	var border_width := 3
	match state:
		TavernNodeState.DEFEATED:
			color = UIColors.PANEL_DISABLED
			border_color = UIColors.TEXT_WARNING
			border_width = 2
		TavernNodeState.AVAILABLE:
			color = UIColors.PANEL
			border_color = UIColors.STRUCTURE_LINE_LIGHT
			border_width = 4
		TavernNodeState.PREVIEWED:
			color = UIColors.MAP_NODE_CURRENT
			border_color = CardStyle.ACCENT_COLOR
			border_width = 5
		TavernNodeState.LOCKED:
			color = UIColors.MAP_NODE_INACTIVE
			border_color = UIColors.STRUCTURE_LINE_LIGHT
			border_width = 2
	_apply_map_node_styles(button, color, border_color, border_width, state == TavernNodeState.PREVIEWED, state == TavernNodeState.LOCKED)


func _style_contract_route_node(button: Button, node: ContractRouteNode, selectable: bool) -> void:
	var is_selected := _route_node_is_selected(node)
	if selectable and not is_selected:
		_style_available_choice_node(button)
		_add_available_pulse(button, "ContractAvailablePulse")
	elif is_selected:
		_style_selected_choice_node(button)
	else:
		_style_map_node(button, false)


func _style_available_choice_node(button: Button) -> void:
	_apply_map_node_styles(button, UIColors.PANEL, UIColors.STRUCTURE_LINE_LIGHT, 4, false, false)


func _style_selected_choice_node(button: Button) -> void:
	_apply_map_node_styles(button, UIColors.MAP_NODE_CURRENT, CardStyle.ACCENT_COLOR, 5, true, false)


func _apply_map_node_styles(button: Button, fill: Color, border: Color, border_width: int, selected: bool, recessed: bool) -> void:
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var state_fill := fill
		var state_border := border
		var state_width := border_width
		if not button.disabled and (state_name == "hover" or state_name == "focus"):
			state_border = UIColors.PANEL_EDGE_LIGHT
			state_width = maxi(border_width, 5)
		elif not button.disabled and state_name == "pressed":
			state_fill = fill.darkened(0.14)
		var style := CardStyle.make_slot_stylebox(state_fill, state_border, state_width, state_name)
		style.set_corner_radius_all(8)
		style.content_margin_top = 12
		if selected:
			style.shadow_color = UIColors.BUTTON_INNER_GLOW
			style.shadow_size = 7
		elif recessed:
			style.shadow_size = 1
			style.shadow_offset = Vector2(0, 1)
		button.add_theme_stylebox_override(state_name, style)
	button.add_theme_color_override("font_color", UIColors.TEXT_NORMAL)
	button.add_theme_color_override("font_disabled_color", UIColors.TEXT_DISABLED)
	button.add_theme_font_override("font", DATA_BUTTON_FONT)
	button.add_theme_font_size_override("font_size", 18)


func _add_map_text_block(button: Button, text: String, enabled: bool) -> void:
	_hide_button_text_for_composed_map_node(button)
	var label := Label.new()
	label.name = "MapTextBlock"
	label.z_index = 7
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", DATA_BUTTON_FONT)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", UIColors.TEXT_NORMAL if enabled else UIColors.TEXT_DISABLED)
	label.add_theme_color_override("font_outline_color", UIColors.TEXT_OUTLINE_STRONG)
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(MAP_TEXT_BLOCK_LEFT, MAP_TEXT_BLOCK_TOP)
	label.size = Vector2(
		maxf(button.custom_minimum_size.x - MAP_TEXT_BLOCK_LEFT - 8.0, 1.0),
		maxf(button.custom_minimum_size.y - MAP_TEXT_BLOCK_TOP - MAP_TEXT_BLOCK_BOTTOM, 1.0)
	)
	button.add_child(label)


func _hide_button_text_for_composed_map_node(button: Button) -> void:
	for color_name in [
		"font_color",
		"font_hover_color",
		"font_pressed_color",
		"font_focus_color",
		"font_hover_pressed_color",
		"font_disabled_color",
		"font_outline_color",
	]:
		button.add_theme_color_override(color_name, UIColors.TRANSPARENT)


func _add_reward_icon_row(button: Button, reward: EncounterReward, enabled: bool) -> void:
	if reward == null:
		return
	var gear_tier := _map_reward_gear_tier(reward)
	if reward.gold_amount <= 0 and reward.talent_points <= 0 and gear_tier < 0:
		return
	var row := HBoxContainer.new()
	row.name = "MapRewardIconRow"
	row.z_index = 9
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 4)
	row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	var reward_piece_count := _map_reward_piece_count(reward, gear_tier)
	row.offset_left = -12 if reward_piece_count >= 3 else 10
	row.offset_top = -28
	row.offset_right = -10
	row.offset_bottom = -2
	row.modulate.a = 1.0 if enabled else 0.58
	if reward.talent_points > 0:
		_add_map_reward_piece(row, CardStyle.talent_point_icon(), "x%d" % reward.talent_points)
	if gear_tier >= 0:
		_add_map_reward_piece(
			row,
			_gear_drop_icon_for_tier(gear_tier),
			"x1",
			"MapGearRewardIcon",
			gear_tier
		)
	if reward.gold_amount > 0:
		_add_map_reward_piece(row, GOLD_ICON, "%dg" % reward.gold_amount)
	button.add_child(row)
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := button.get_theme_stylebox(state_name)
		if style is StyleBoxFlat:
			style.content_margin_bottom = 42


func _add_map_reward_piece(row: HBoxContainer, texture: Texture2D, text: String, icon_name: String = "Icon", gear_tier: int = -1) -> void:
	var icon := CardStyle.make_pixel_icon(texture, MAP_REWARD_ICON_SIZE)
	icon.name = icon_name
	if gear_tier >= 0:
		icon.set_meta("gear_tier", gear_tier)
		icon.set_meta("gear_rarity_color", _tier_color_for_map_reward(gear_tier))
	row.add_child(icon)
	var label := Label.new()
	label.name = "MapRewardAmount"
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", DATA_BUTTON_FONT)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", UIColors.TEXT_NORMAL)
	label.add_theme_color_override("font_outline_color", UIColors.TEXT_OUTLINE_STRONG)
	label.add_theme_constant_override("outline_size", 3)
	row.add_child(label)


func _map_reward_gear_tier(reward: EncounterReward) -> int:
	if reward.gear_choice_rewards.size() > 0:
		var best := -1
		for gear in reward.gear_choice_rewards:
			if gear != null:
				best = maxi(best, gear.tier)
		return best
	if reward.legendary_choice_count > 0 and not reward.legendary_choice_pool.is_empty():
		return GearItem.Tier.LEGENDARY
	if reward.generated_gear_choice_count > 0:
		return reward.generated_gear_tier
	if reward.fixed_gear_rewards.size() > 0:
		var best_fixed := -1
		for gear in reward.fixed_gear_rewards:
			if gear != null:
				best_fixed = maxi(best_fixed, gear.tier)
		return best_fixed
	return -1


func _map_reward_piece_count(reward: EncounterReward, gear_tier: int) -> int:
	var count := 0
	if reward.talent_points > 0:
		count += 1
	if gear_tier >= 0:
		count += 1
	if reward.gold_amount > 0:
		count += 1
	return count


func _gear_drop_icon_for_tier(tier: int) -> Texture2D:
	var normalized_tier := tier if GEAR_DROP_ICON_PATHS.has(tier) else GearItem.Tier.BASIC
	if _gear_drop_icon_cache.has(normalized_tier):
		return _gear_drop_icon_cache[normalized_tier]
	var texture := load(GEAR_DROP_ICON_PATHS[normalized_tier]) as Texture2D
	if texture == null:
		return null
	texture.resource_name = GEAR_DROP_ICON_PATHS[normalized_tier]
	_gear_drop_icon_cache[normalized_tier] = texture
	return texture


func _tier_color_for_map_reward(tier: int) -> Color:
	match tier:
		GearItem.Tier.MASTER:
			return UIColors.TIER_MASTER
		GearItem.Tier.CURSED:
			return UIColors.TIER_CURSED
		GearItem.Tier.LEGENDARY:
			return UIColors.TIER_LEGENDARY
	return UIColors.TIER_BASIC


func _add_map_actor_marker(button: Button, monster: Monster, enabled: bool) -> void:
	var texture := _map_actor_texture(monster)
	if texture == null:
		return
	var actor := TextureRect.new()
	actor.name = "MapActorMarker"
	actor.z_index = 8
	actor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	actor.texture = texture
	actor.custom_minimum_size = MAP_ACTOR_MARKER_SIZE
	actor.size = MAP_ACTOR_MARKER_SIZE
	actor.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	actor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	actor.position = MAP_ACTOR_MARKER_OFFSET
	actor.modulate.a = 1.0 if enabled else 0.55
	button.add_child(actor)


func _map_actor_texture(monster: Monster) -> Texture2D:
	if monster == null:
		return null
	var visual_key: String = CombatStage.ENEMY_VISUAL_KEYS_BY_NAME.get(monster.display_name, "")
	if visual_key == "":
		return null
	var animation_paths: Dictionary = CombatStage.ENEMY_ANIMATION_PATHS.get(visual_key, {})
	var animation_regions: Dictionary = CombatStage.ENEMY_ANIMATION_REGIONS.get(visual_key, {})
	var path: String = animation_paths.get("idle", "")
	var region: Rect2 = animation_regions.get("idle", Rect2(Vector2.ZERO, Vector2(CombatStage.PEASANT_FRAME_SIZE)))
	return _atlas_texture_from_path(path, region)


func _atlas_texture_from_path(path: String, region: Rect2) -> Texture2D:
	if path == "":
		return null
	var source := load(path) as Texture2D
	if source == null:
		var image := Image.new()
		if image.load(path) != OK:
			return null
		source = ImageTexture.create_from_image(image)
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = region
	return atlas


func _add_tavern_defeated_marker(button: Button) -> void:
	var marker := Label.new()
	marker.name = "TavernDefeatedMarker"
	marker.text = "X"
	marker.z_index = 20
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.add_theme_font_size_override("font_size", 70)
	marker.add_theme_color_override("font_color", UIColors.TEXT_WARNING)
	marker.add_theme_color_override("font_outline_color", UIColors.TEXT_OUTLINE_STRONG)
	marker.add_theme_constant_override("outline_size", 5)
	marker.position = MAP_ACTOR_MARKER_OFFSET
	marker.size = MAP_ACTOR_MARKER_SIZE
	button.add_child(marker)


func _add_tavern_available_pulse(button: Button) -> void:
	_add_available_pulse(button, "TavernAvailablePulse")


func _add_available_pulse(button: Button, marker_name: String) -> void:
	var pulse := PanelContainer.new()
	pulse.name = marker_name
	pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pulse.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var pulse_style := StyleBoxFlat.new()
	pulse_style.bg_color = UIColors.TRANSPARENT
	pulse_style.border_color = UIColors.TEXT_GOLD
	pulse_style.set_border_width_all(5)
	pulse_style.set_corner_radius_all(8)
	pulse.add_theme_stylebox_override("panel", pulse_style)
	button.add_child(pulse)

	pulse.modulate.a = 0.35
	var tween := pulse.create_tween()
	tween.set_loops()
	tween.tween_property(pulse, "modulate:a", 1.0, AVAILABLE_PULSE_DURATION_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(pulse, "modulate:a", 0.35, AVAILABLE_PULSE_DURATION_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
## Before any node is (re-)previewed, _tavern_pre_choice_story_text() sets
## the scene; clicking the current node previews its
## TAVERN_ENCOUNTER_FLAVOR_TEXT without committing (see
## _on_tavern_node_previewed()); Proceed then commits it, after which this
## falls to the same "marked" line it always has.
func _tavern_story_text() -> String:
	var encounter := BuildState.current_encounter()
	if encounter == null:
		return "The Tavern is quiet for the moment."
	if BuildState.needs_tavern_map_choice():
		if _tavern_preview_index == BuildState.current_encounter_index:
			return TAVERN_ENCOUNTER_FLAVOR_TEXT.get(
				encounter.monster.display_name, "A stranger's business becomes yours."
			)
		return _tavern_pre_choice_story_text()
	return FLOW_TEXT.marked_target_story(encounter.monster.display_name)


## The very first Tavern choice (nothing defeated yet) sets the scene with
## TAVERN_INTRO_TEXT; every later choice instead shows the encounter just
## defeated's TAVERN_VICTORY_TEXT, so returning to the map after a win
## reflects the new state of the story instead of replaying the intro.
func _tavern_pre_choice_story_text() -> String:
	if BuildState.current_encounter_index == 0:
		return TAVERN_INTRO_TEXT
	var previous_encounter := RunFlow.load_encounter(BuildState.current_encounter_index - 1)
	if previous_encounter == null or previous_encounter.monster == null:
		return TAVERN_INTRO_TEXT
	return TAVERN_VICTORY_TEXT.get(previous_encounter.monster.display_name, TAVERN_INTRO_TEXT)


## P2:R7:T6: when the player is choosing between exactly two branches, this
## appends a data-derived tradeoff sentence (see _route_tradeoff_text())
## naming the harder branch and comparing reward tier, so the choice isn't
## blind. Applies at every branch point, not only the opener choice -- the
## base line no longer says "first route" since this story text is reused
## for every later fork too (Door Guard's/Portly Cook's own next-node choice).
func _contract_route_story_text() -> String:
	var node := BuildState.current_route_node
	if node == null:
		return "The route has not been charted yet."
	if BuildState.is_contract_fight_active():
		return FLOW_TEXT.marked_target_story(node.display_name)
	if _pending_contract_route_node != null and _route_node_is_selectable(_pending_contract_route_node):
		return _selected_contract_route_story_text(_pending_contract_route_node)
	var authored_before := _before_selection_contract_route_story_text(node)
	if authored_before != "":
		return authored_before
	var base := "Choose your next route into The Gilded Serpent. Enemy pressure and reward quality matter from here."
	if node.next_nodes.size() == 2:
		var tradeoff := _route_tradeoff_text(node.next_nodes[0], node.next_nodes[1])
		if tradeoff != "":
			return "%s %s" % [base, tradeoff]
	return base


func _selected_contract_route_story_text(node: ContractRouteNode) -> String:
	if node.selected_text != "":
		return node.selected_text
	return FLOW_TEXT.pending_route_status(node.display_name)


func _before_selection_contract_route_story_text(node: ContractRouteNode) -> String:
	if node.next_nodes.size() == 1 and node.next_nodes[0].before_selection_text != "":
		return node.next_nodes[0].before_selection_text
	if node.before_selection_text != "":
		return node.before_selection_text
	return ""


## Relative pressure score for a route branch, used only to rank two
## branches against each other (not shown as an absolute number) --
## higher armor/poison resistance reads as a harder branch, from the same
## real Monster fields enemy_panel.gd's _build_pressure_text() (P2:R7:T5)
## already reads.
func _route_pressure_score(node: ContractRouteNode) -> float:
	if node == null or node.monster == null:
		return 0.0
	return float(node.monster.armor) + node.monster.poison_resistance * 200.0


## Reward tier rank for a route branch's reward, covering both the
## authored gear_choice_rewards path (Knives' Legendary pair) and the
## generated_gear_tier path every other route reward uses. Returns -1 when
## the node has no gear reward to rank (e.g. Vyra's gold-only reward).
func _route_reward_tier_rank(node: ContractRouteNode) -> int:
	if node == null or node.reward == null:
		return -1
	if node.reward.gear_choice_rewards.size() > 0:
		var best := -1
		for gear in node.reward.gear_choice_rewards:
			if gear != null:
				best = maxi(best, gear.tier)
		return best
	if node.reward.generated_gear_choice_count > 0:
		return node.reward.generated_gear_tier
	return -1


## Data-derived tradeoff sentence for a pair of route branches, comparing
## real Monster pressure and reward tier rather than authored per-node
## flavor text -- so a newly authored branch pair reads correctly with zero
## additional authoring, matching the same discipline as T5's
## _build_pressure_text(). Pure ContractRouteNode -> String, no BuildState
## writes.
func _route_tradeoff_text(node_a: ContractRouteNode, node_b: ContractRouteNode) -> String:
	if node_a == null or node_b == null:
		return ""
	var pressure_a := _route_pressure_score(node_a)
	var pressure_b := _route_pressure_score(node_b)
	var pressure_line: String
	if is_equal_approx(pressure_a, pressure_b):
		pressure_line = "%s and %s carry similar pressure" % [node_a.display_name, node_b.display_name]
	elif pressure_a > pressure_b:
		pressure_line = "%s is the harder branch" % node_a.display_name
	else:
		pressure_line = "%s is the harder branch" % node_b.display_name
	var tier_a := _route_reward_tier_rank(node_a)
	var tier_b := _route_reward_tier_rank(node_b)
	var tier_a_name: String = GearGenerator.TIER_NAMES[tier_a] if tier_a >= 0 else "no gear"
	var tier_b_name: String = GearGenerator.TIER_NAMES[tier_b] if tier_b >= 0 else "no gear"
	return "%s. %s reward: %s -- %s reward: %s." % [pressure_line, node_a.display_name, tier_a_name, node_b.display_name, tier_b_name]


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


## Opens the map. `manual_open` marks a player-initiated open via the Map
## button (as opposed to the flow pushing the map up at a decision point) --
## it's what keeps Close Map available even while a choice is still pending.
func show_map(manual_open: bool = false) -> void:
	_map_manual_open = manual_open
	refresh()
	visible = true


## Hides the map and clears the manual-open flag. combat_screen.gd calls this
## after a choice commits, so the next automatic open starts from a clean
## state rather than inheriting the previous manual-open exemption.
func close() -> void:
	visible = false
	_map_manual_open = false
	_pending_contract_route_node = null


## Clears the pending Tavern preview. combat_screen.gd calls this once a
## Tavern choice actually commits, since the preview no longer applies.
func clear_tavern_preview() -> void:
	_tavern_preview_index = -1
	_pending_contract_route_node = null


func _map_requires_choice() -> bool:
	return (
		BuildState.needs_tavern_map_choice()
		or BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER
		or BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE
	)


## Clicking a Tavern node only previews its flavor text (_tavern_story_text())
## and enables the Proceed button -- it never commits the choice itself.
## Proceed is what commits, restoring a two-step "read the flavor, then
## commit" flow. Purely local state, so it stays in this scene.
func _on_tavern_node_previewed(index: int) -> void:
	if index != BuildState.current_encounter_index or not BuildState.needs_tavern_map_choice():
		return
	_tavern_preview_index = -1 if _tavern_preview_index == index else index
	refresh()


func _on_contract_route_node_previewed(node: ContractRouteNode) -> void:
	if not _route_node_is_selectable(node):
		return
	_pending_contract_route_node = null if _pending_contract_route_node == node else node
	refresh()


func _on_map_proceed_pressed() -> void:
	if BuildState.needs_tavern_map_choice() and _tavern_preview_index == BuildState.current_encounter_index:
		tavern_proceed_pressed.emit()
		return
	if _pending_contract_route_node != null and _route_node_is_selectable(_pending_contract_route_node):
		var selected := _pending_contract_route_node
		_pending_contract_route_node = null
		route_node_pressed.emit(selected)
		return
	CardStyle.pulse_blocked_control(_map_proceed_button)


func _refresh_contract_route_proceed_button() -> void:
	var has_pending_choices := (
		BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE
		and BuildState.current_route_node != null
		and not BuildState.current_route_node.next_nodes.is_empty()
	)
	_map_proceed_button.visible = has_pending_choices
	_map_proceed_button.disabled = _pending_contract_route_node == null
	_map_proceed_button.text = FLOW_TEXT.ACTION_PROCEED
	_map_proceed_button.tooltip_text = (
		FLOW_TEXT.TOOLTIP_ROUTE_NEEDS_SELECTION
		if _pending_contract_route_node == null
		else FLOW_TEXT.tooltip_mark_route(_pending_contract_route_node.display_name)
	)


func _sync_pending_contract_route_node() -> void:
	if _pending_contract_route_node == null:
		return
	if not _route_node_is_selectable(_pending_contract_route_node):
		_pending_contract_route_node = null
