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

const CARD_TITLE_FONT_SIZE := 20
const GOLD_ICON := preload("res://assets/ui/icons/gold.png")

var _options: HBoxContainer


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


func options_container() -> HBoxContainer:
	return _options
