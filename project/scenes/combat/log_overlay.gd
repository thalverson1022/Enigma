extends Control
## Combat log overlay: shows the full formatted result text for the last
## resolved fight. Extracted from combat_screen.gd's inline overlay builder
## (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md Phase 3) -- a pure
## informational view, so it stays dismissable on an outside click, matching
## its behavior before extraction.

const CARD_TITLE_FONT_SIZE := 20

var _log_label: RichTextLabel


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var panel := CardStyle.build_modal_panel(self, true)
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	var header := HBoxContainer.new()
	var header_title := Label.new()
	header_title.text = "Combat Log"
	header_title.theme_type_variation = &"PanelHeader"
	header_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	header.add_child(header_title)
	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): visible = false)
	header.add_child(close_button)
	content.add_child(header)

	_log_label = RichTextLabel.new()
	_log_label.custom_minimum_size = Vector2(600, 400)
	content.add_child(_log_label)


## Public setter so combat_screen.gd never touches this overlay's internal
## RichTextLabel directly.
func set_result_text(text: String) -> void:
	_log_label.text = text
