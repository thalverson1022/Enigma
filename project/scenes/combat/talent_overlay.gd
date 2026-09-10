extends Control
## Talent Trees modal: the full talent tree lives here, opened on demand from
## the Active Talents dashboard summary. Extracted from combat_screen.gd's
## inline overlay builder (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md
## Phase 3) -- a pure informational/allocation view, so it stays dismissable
## on an outside click, matching its behavior before extraction.

signal secondary_tree_chosen(tree: SubclassTree)

const TALENT_SCENE := preload("res://scenes/combat/talent_panel.tscn")
const CONTENT_BASE_SIZE := Vector2(900, 660)
const SCROLL_BASE_SIZE := Vector2(860, 580)
const VIEWPORT_PADDING := Vector2(96, 96)
const CONTENT_MIN_SIZE := Vector2(560, 360)
const SCROLL_CHROME_SIZE := Vector2(40, 80)

var _talent_panel
var _content: VBoxContainer
var _scroll: ScrollContainer


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

	var panel := CardStyle.build_modal_panel(self, true)
	var style := CardStyle.make_stylebox(18)
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)

	_content = VBoxContainer.new()
	_content.custom_minimum_size = CONTENT_BASE_SIZE
	_content.add_theme_constant_override("separation", 10)
	panel.add_child(_content)

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
	_content.add_child(header)

	_scroll = ScrollContainer.new()
	_scroll.name = "TalentTreeScroll"
	_scroll.custom_minimum_size = SCROLL_BASE_SIZE
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_child(_scroll)

	_talent_panel = TALENT_SCENE.instantiate()
	_talent_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_talent_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_talent_panel.secondary_tree_chosen.connect(func(tree): secondary_tree_chosen.emit(tree))
	_scroll.add_child(_talent_panel)
	if get_viewport() != null:
		get_viewport().size_changed.connect(_resize_to_viewport)
	_resize_to_viewport()


func show_overlay() -> void:
	if _talent_panel != null and _talent_panel.has_method("refresh_panel"):
		_talent_panel.refresh_panel()
	_resize_to_viewport()
	visible = true


func _resize_to_viewport() -> void:
	if _content == null or _scroll == null:
		return
	var available := get_viewport_rect().size - VIEWPORT_PADDING
	var content_size := Vector2(
		minf(CONTENT_BASE_SIZE.x, maxf(CONTENT_MIN_SIZE.x, available.x)),
		minf(CONTENT_BASE_SIZE.y, maxf(CONTENT_MIN_SIZE.y, available.y))
	)
	_content.custom_minimum_size = content_size
	_scroll.custom_minimum_size = Vector2(
		minf(SCROLL_BASE_SIZE.x, maxf(CONTENT_MIN_SIZE.x - SCROLL_CHROME_SIZE.x, content_size.x - SCROLL_CHROME_SIZE.x)),
		minf(SCROLL_BASE_SIZE.y, maxf(180.0, content_size.y - SCROLL_CHROME_SIZE.y))
	)
