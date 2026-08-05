extends Control
## Reward choice modal: presents pending gear/Legendary reward options for
## the player to pick one from. Extracted from combat_screen.gd's inline
## overlay builder (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md
## Phase 3) -- gates a real decision (choose one reward) with no defined
## "cancel" behavior, so it stays locked (no dismiss on outside click),
## matching its behavior before extraction.
##
## Populating the actual reward option buttons still happens in
## combat_screen.gd, since building them depends on tooltip/style helpers
## still shared with the not-yet-extracted shop overlay
## (_build_gear_compare_tooltip(), _style_shop_item_box()) -- this scene only
## owns the modal shell and exposes its options container publicly via
## options_container(), the same "public accessor instead of a private
## reach-in" pattern used elsewhere in this refactor (see enemy_panel.gd's
## fight_button()).

signal skip_pressed

const FLOW_TEXT := preload("res://scripts/ui/adventure_flow_text.gd")
const CARD_TITLE_FONT_SIZE := 20
const GOLD_ICON := preload("res://assets/ui/icons/gold.png")

var _options: HBoxContainer
var _status_label: Label
var _skip_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var panel := CardStyle.build_modal_panel(self, false)
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(520, 240)
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 8)
	content.add_child(title_row)

	title_row.add_child(CardStyle.make_pixel_icon(GOLD_ICON, CardStyle.UI_ICON_SIZE))

	var title := Label.new()
	title.text = "Choose Reward"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	title_row.add_child(title)

	_options = HBoxContainer.new()
	_options.alignment = BoxContainer.ALIGNMENT_CENTER
	_options.add_theme_constant_override("separation", 12)
	content.add_child(_options)

	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", UIColors.TEXT_WARNING)
	_status_label.visible = false
	content.add_child(_status_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(button_row)

	_skip_button = Button.new()
	_skip_button.text = FLOW_TEXT.ACTION_SKIP_REWARD
	_skip_button.tooltip_text = FLOW_TEXT.TOOLTIP_SKIP_REWARD
	_skip_button.pressed.connect(func(): skip_pressed.emit())
	button_row.add_child(_skip_button)


func options_container() -> HBoxContainer:
	return _options


func set_status_text(text: String) -> void:
	_status_label.text = text
	_status_label.visible = text != ""
