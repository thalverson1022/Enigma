extends Control
## Talent Trees modal: the full talent tree lives here, opened on demand from
## the Active Talents dashboard summary. Extracted from combat_screen.gd's
## inline overlay builder (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md
## Phase 3) -- a pure informational/allocation view, so it stays dismissable
## on an outside click, matching its behavior before extraction.

signal secondary_tree_chosen(tree: SubclassTree)

const TALENT_SCENE := preload("res://scenes/combat/talent_panel.tscn")

var _talent_panel


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var panel := CardStyle.build_modal_panel(self, true)
	var style := CardStyle.make_stylebox(18)
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(900, 660)
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)

	var header := HBoxContainer.new()
	var title := Label.new()
	title.text = "Talent Trees"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	header.add_child(title)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): visible = false)
	header.add_child(close_button)
	content.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(860, 580)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	_talent_panel = TALENT_SCENE.instantiate()
	_talent_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_talent_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_talent_panel.secondary_tree_chosen.connect(func(tree): secondary_tree_chosen.emit(tree))
	scroll.add_child(_talent_panel)


func show_overlay() -> void:
	if _talent_panel != null and _talent_panel.has_method("refresh_panel"):
		_talent_panel.refresh_panel()
	visible = true
