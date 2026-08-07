extends Control
## One-time story beat shown before the Tavern map ever appears on a fresh
## run. Extracted from combat_screen.gd's inline overlay builder
## (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md Phase 3) -- gates the
## only allowed next action (Proceed) with no defined "cancel" behavior, so
## it stays locked (no dismiss on outside click), matching its behavior
## before extraction.

signal proceed_pressed

const FLOW_TEXT := preload("res://scripts/ui/adventure_flow_text.gd")
const INTRO_STORY_TEXT := "You find yourself in the shadow of the Dahm Henge Mountain. The highest peak, Peak Deeps is shrouded in darkness. You have heard tail of the secrets that lie there but know of none who had tried their hand at uncovering those hidden treasures and returned to tell the tale."
const TAVERN_BACKGROUND_TINT := UIColors.SCRIM_SOFT
const STORY_BACKGROUND_TEXTURE := preload("res://assets/backgrounds/Ponesville.jpg")

var _story_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var panel := CardStyle.build_modal_panel(self, false)
	var style := CardStyle.make_stylebox(24)
	style.bg_color = UIColors.PANEL_DEEP
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)

	var background := TextureRect.new()
	background.texture = STORY_BACKGROUND_TEXTURE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(background)

	var background_tint := ColorRect.new()
	background_tint.color = TAVERN_BACKGROUND_TINT
	background_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(background_tint)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(900, 420)
	content.add_theme_constant_override("separation", 24)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(content)

	_story_label = Label.new()
	_story_label.name = "StoryLabel"
	_story_label.text = INTRO_STORY_TEXT
	_story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_story_label.custom_minimum_size = Vector2(820, 0)
	content.add_child(_story_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(button_row)

	var proceed_button := Button.new()
	proceed_button.name = "StoryProceedButton"
	proceed_button.text = FLOW_TEXT.ACTION_PROCEED
	proceed_button.pressed.connect(_on_proceed_pressed)
	button_row.add_child(proceed_button)


func _on_proceed_pressed() -> void:
	visible = false
	proceed_pressed.emit()
