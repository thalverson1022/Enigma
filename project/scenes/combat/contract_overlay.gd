extends Control
## Ghit Gudd's Contract Window: a multi-step conversation that introduces and
## commits The Gilded Serpent contract. Extracted from combat_screen.gd's
## inline overlay builder (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md
## Phase 3) -- gates a real decision with no defined "cancel" behavior, so it
## stays locked (no dismiss on outside click), matching its behavior before
## extraction.
##
## Visually mirrors the shop overlay's layout (a portrait box beside the
## text/action content) since this is explicitly meant to grow into the same
## kind of hub the shop already is, just for choosing contracts instead of
## gear, per the user's stated plan.
##
## This scene owns the conversation's step state and advances itself through
## the two purely-narrative transitions (GREETING -> PITCH, CONTRACT_CHOICE ->
## VYRA_DETAIL). It deliberately does NOT own the two steps with cross-cutting
## consequences: `accept_requested` and `route_requested` hand those back to
## combat_screen.gd, which owns BuildState mutation, the secondary-subclass
## overlay, the enemy HUD, the route map, and autosaving.
##
## Two semantic signals rather than one `action_pressed(step)` signal is
## deliberate: the `Step` enum then never has to cross the scene boundary.
## This script can't declare a `class_name` (it references the BuildState
## autoload, and global-class scripts compile during Godot's project scan
## before autoloads register -- "Identifier not found: BuildState"), and
## preloading the *script* from combat_screen.gd to reach the enum forces that
## same premature compile. Preloading the `.tscn` is fine, so the enum simply
## stays private to this file.

## PITCH's action button: the real commit point. combat_screen.gd runs
## BuildState.accept_contract_offer() and only hides this window if it
## succeeds -- on failure the conversation correctly stays on PITCH.
signal accept_requested

## VYRA_DETAIL's action button: the player has accepted; combat_screen.gd
## reveals the route map.
signal route_requested

enum Step { GREETING, PITCH, CONTRACT_CHOICE, VYRA_DETAIL }

const FLOW_TEXT := preload("res://scripts/ui/adventure_flow_text.gd")
const CARD_TITLE_FONT_SIZE := 20
const CONTRACT_CHOICE_CARD_WIDTH := 340
const CONTRACT_CHOICE_PULSE_DURATION_SEC := 0.72
const CONTRACT_PORTRAIT_TEXTURE := preload("res://assets/backgrounds/Ghit_Guud.jpg")
const CONTRACT_ICON := preload("res://assets/ui/icons/contract.png")

## Ghit Gudd's introduction sequence (P2:R7 story pass) -- replaces the old
## single-click "Map"-styled Contract Offer overlay with a multi-step
## conversation, restoring a Phase 1-style narrative beat around accepting The
## Gilded Serpent contract. Verbatim user-authored copy (including its
## typos/inconsistent spelling of the broker's name -- not this codebase's to
## silently correct).
const CONTRACT_GREETING_TEXT := "Calm my friend. My name is Ghit Gudd. I am just a humble local... businessman. You are quite handy. You dispatched one of my best with such ease. I am always looking for useful individuals like yourself. How would you like to make a little coin?"
const CONTRACT_PITCH_TEXT := "I often have need for travelers of your ilk. Some of my rival competition needs to be reminded of the rules of free market capitalism. If you ... take care of them for me, I will pay you handsomely."
## The post-subclass-choice step -- a single option today, but user-stated to
## grow into a real multi-contract hub later, hence a dedicated options row
## rather than a single fixed button.
const CONTRACT_CHOICE_PROMPT_TEXT := "Choose a contract to pursue."
const CONTRACT_VYRA_NAME := "Vyra, the Leader of the Gilded Fang"
const CONTRACT_VYRA_DETAIL_TEXT := "Vyra is the leader of a rival gang. Ghet wants you to take her out so he can expand his business. She is hold up in her hideout at the edge of town. Ghet tells you that there are two ways in: through the front door and through the back door."
## The real route node backing the Vyra contract card -- read for its authored
## gold reward (see _contract_choice_reward_text()).
const VYRA_ROUTE_NODE_ID := "route.gilded_serpent.vyra"

var _contract_step: Step = Step.GREETING
var _contract_body_label: Label
var _contract_options_box: VBoxContainer
var _contract_footer_spacer: Control
var _contract_action_button: Button
var _selected_contract_id := ""


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var panel := CardStyle.build_modal_panel(self, false)
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := HBoxContainer.new()
	content.custom_minimum_size = Vector2(700, 420)
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)

	var portrait := PanelContainer.new()
	portrait.custom_minimum_size = Vector2(260, 0)
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var portrait_style := CardStyle.make_stylebox(8)
	portrait_style.bg_color = UIColors.PANEL_DEEP
	portrait.add_theme_stylebox_override("panel", portrait_style)
	content.add_child(portrait)

	var portrait_image := TextureRect.new()
	portrait_image.texture = CONTRACT_PORTRAIT_TEXTURE
	portrait_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.add_child(portrait_image)

	var contract_content := VBoxContainer.new()
	contract_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_content.add_theme_constant_override("separation", 14)
	content.add_child(contract_content)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	contract_content.add_child(title_row)

	title_row.add_child(CardStyle.make_pixel_icon(CONTRACT_ICON, CardStyle.UI_ICON_SIZE))

	var title := Label.new()
	title.text = "Contract"
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	title_row.add_child(title)

	_contract_body_label = Label.new()
	_contract_body_label.name = "ContractBodyLabel"
	_contract_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	contract_content.add_child(_contract_body_label)

	# Empty/hidden except during Step.CONTRACT_CHOICE -- one option today
	# (Vyra), stacked vertically so future contracts naturally form a list.
	_contract_options_box = VBoxContainer.new()
	_contract_options_box.name = "ContractOptionsBox"
	_contract_options_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	_contract_options_box.add_theme_constant_override("separation", 12)
	contract_content.add_child(_contract_options_box)

	_contract_footer_spacer = Control.new()
	_contract_footer_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contract_content.add_child(_contract_footer_spacer)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	contract_content.add_child(button_row)

	_contract_action_button = Button.new()
	_contract_action_button.name = "ContractActionButton"
	_contract_action_button.pressed.connect(_on_action_button_pressed)
	button_row.add_child(_contract_action_button)


## Opens the window at Ghit Gudd's greeting -- the start of the conversation.
func show_greeting() -> void:
	_show_step(Step.GREETING)


## Opens the window at the post-subclass-choice contract picker. Reached after
## the secondary-tree choice, not by advancing from PITCH.
func show_contract_choice() -> void:
	_selected_contract_id = ""
	_show_step(Step.CONTRACT_CHOICE)


func _show_step(step: Step) -> void:
	_contract_step = step
	refresh()
	visible = true


## Drives the Contract Window through Ghit Gudd's introduction -- see the
## CONTRACT_* text constants above for the exact copy at each step.
func refresh() -> void:
	for child in _contract_options_box.get_children():
		child.queue_free()
	_contract_options_box.visible = false
	_contract_action_button.visible = true
	_contract_action_button.disabled = false
	match _contract_step:
		Step.GREETING:
			_contract_body_label.text = CONTRACT_GREETING_TEXT
			_contract_action_button.text = "Hear Him Out"
			CardStyle.configure_icon_button(_contract_action_button, CONTRACT_ICON)
		Step.PITCH:
			_contract_body_label.text = CONTRACT_PITCH_TEXT
			_contract_action_button.text = "Accept Contract Work"
			CardStyle.configure_icon_button(_contract_action_button, CONTRACT_ICON)
		Step.CONTRACT_CHOICE:
			_contract_body_label.text = CONTRACT_CHOICE_PROMPT_TEXT
			_contract_action_button.text = FLOW_TEXT.ACTION_PROCEED
			CardStyle.configure_icon_button(_contract_action_button, CONTRACT_ICON)
			_contract_action_button.disabled = _selected_contract_id == ""
			_contract_options_box.visible = true
			var vyra_node: ContractRouteNode = null
			if BuildState.active_contract != null:
				vyra_node = ContractRouteNode.find_by_id(BuildState.active_contract.offer_node, VYRA_ROUTE_NODE_ID)
			_contract_options_box.add_child(_build_contract_choice_card(VYRA_ROUTE_NODE_ID, CONTRACT_VYRA_NAME, vyra_node))
		Step.VYRA_DETAIL:
			_contract_body_label.text = CONTRACT_VYRA_DETAIL_TEXT
			_contract_action_button.text = "Accept"
			CardStyle.configure_icon_button(_contract_action_button, CONTRACT_ICON)


## A larger, toggleable rectangle (not a plain button) naming the contract and
## its final-fight gold reward -- selecting one only enables the bottom
## Proceed button rather than committing immediately, since
## CONTRACT_CHOICE_PROMPT_TEXT's step is meant to grow into a real
## multi-contract picker later. `group` keeps future cards mutually
## exclusive; harmless with today's single card.
func _build_contract_choice_card(contract_id: String, display_name: String, node: ContractRouteNode) -> Button:
	var card := Button.new()
	card.name = "VyraContractButton"
	card.custom_minimum_size = Vector2(CONTRACT_CHOICE_CARD_WIDTH, 110)
	CardStyle.configure_icon_button(card, CONTRACT_ICON)
	card.text = "%s\n%s" % [display_name, _contract_choice_reward_text(node)]
	card.pressed.connect(_on_contract_choice_pressed.bind(contract_id))
	if _selected_contract_id == contract_id:
		_style_contract_choice_selected(card)
	else:
		_style_contract_choice_available(card)
		_add_contract_choice_pulse(card)
	return card


func _contract_choice_reward_text(node: ContractRouteNode) -> String:
	if node == null or node.reward == null:
		return "Reward: unknown"
	return "Reward: %dg" % node.reward.gold_amount


func _on_contract_choice_pressed(contract_id: String) -> void:
	_selected_contract_id = "" if _selected_contract_id == contract_id else contract_id
	refresh()


func _style_contract_choice_available(card: Button) -> void:
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := CardStyle.make_stylebox()
		style.bg_color = UIColors.PANEL
		style.border_color = UIColors.STRUCTURE_LINE_LIGHT
		style.set_border_width_all(3)
		card.add_theme_stylebox_override(state_name, style)


func _style_contract_choice_selected(card: Button) -> void:
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := CardStyle.make_stylebox()
		style.bg_color = UIColors.MAP_NODE_CURRENT
		style.border_color = CardStyle.ACCENT_COLOR
		style.set_border_width_all(5)
		card.add_theme_stylebox_override(state_name, style)


func _add_contract_choice_pulse(card: Button) -> void:
	var pulse := PanelContainer.new()
	pulse.name = "ContractChoicePulse"
	pulse.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pulse.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var pulse_style := StyleBoxFlat.new()
	pulse_style.bg_color = UIColors.TRANSPARENT
	pulse_style.border_color = UIColors.TEXT_GOLD
	pulse_style.set_border_width_all(5)
	pulse_style.set_corner_radius_all(8)
	pulse.add_theme_stylebox_override("panel", pulse_style)
	card.add_child(pulse)

	pulse.modulate.a = 0.35
	var tween := pulse.create_tween()
	tween.set_loops()
	tween.tween_property(pulse, "modulate:a", 1.0, CONTRACT_CHOICE_PULSE_DURATION_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(pulse, "modulate:a", 0.35, CONTRACT_CHOICE_PULSE_DURATION_SEC).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## The single action button means something different at each step:
## GREETING/CONTRACT_CHOICE are purely narrative advances handled here;
## PITCH and VYRA_DETAIL hand off to combat_screen.gd (see the signals above).
func _on_action_button_pressed() -> void:
	match _contract_step:
		Step.GREETING:
			_show_step(Step.PITCH)
		Step.PITCH:
			accept_requested.emit()
		Step.CONTRACT_CHOICE:
			if _selected_contract_id != "":
				_show_step(Step.VYRA_DETAIL)
		Step.VYRA_DETAIL:
			route_requested.emit()
