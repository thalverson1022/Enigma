extends PanelContainer
## Combat dashboard strip (center column, below the combat window): the
## currently unlocked skills as a horizontal row of buttons -- clicking one
## appends it to the macro (state.rotation). Split out of the old
## combined skill_macro_panel to match the mockup's two separate
## "Available Skills" / "Skill Build" strips.
##
## Each button shows assigned skill art when available, then the skill name.
## Skills without assigned art still color the first letter
## (CardStyle.ACCENT_COLOR) to match the fallback glyph shown on that skill's
## slot in skill_build_panel.gd. Hover shows a tooltip with the skill's flavor
## speed label and effects (the exact cast-time number is intentionally not
## shown, see SkillTooltipFormatter.SPEED_LABEL_BY_SKILL_ID).
##
## P2:R7 playtest-feedback pass (2026-07-18, revises T4): T4 originally also
## rendered the skill's effect summary as an always-visible caption Label
## under each button. Playtesting found that redundant with the hover
## tooltip (which already shows the same text via _skill_effect_summary())
## and it added vertical bulk to this strip that the dashboard didn't have
## to spare -- see the overflow-bug notes in
## docs/Phase_2_R7_Game_Like_UI_Pass.md. The caption is removed; the summary
## helper itself is unchanged and still feeds the tooltip.

const CARD_TITLE_FONT_SIZE := 20
const SKILL_ICON_SIZE := Vector2(28, 28)
const BUTTON_MIN_SIZE := Vector2(112, 46)
const BUTTON_CONTENT_PADDING := Vector2(12, 7)
const BUTTON_CORNER_RADIUS := 6
const SkillTooltipFormatterScript := preload("res://scripts/ui/skill_tooltip_formatter.gd")

## P2:R10: see talent_panel.gd's `state` comment -- same pattern, same
## default, same untyped declaration reason.
var state = BuildState

var _skills_box: HBoxContainer


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = "Available Skills"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_skills_box = HBoxContainer.new()
	_skills_box.add_theme_constant_override("separation", 8)
	content.add_child(_skills_box)

	state.build_changed.connect(_refresh)
	state.lock_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	# Multiple build_changed/lock_changed emissions can land in the same
	# frame with no intervening idle frame (e.g. several rapid skill presses,
	# then a lock toggle) -- a queue_free()'d child from an earlier _refresh
	# this frame is still present in get_children() until the next idle
	# frame, so force its disabled state to match the CURRENT lock state
	# before freeing, or a caller inspecting children immediately after this
	# call sees a stale value.
	var at_cap: bool = state.rotation.size() >= BuildResolver.MAX_ROTATION_SIZE
	for child in _skills_box.get_children():
		if child is Button:
			child.disabled = state.build_locked or at_cap
		child.queue_free()
	for skill in state.unlocked_skills():
		_skills_box.add_child(_build_button(skill, at_cap))


## A Button with no native text of its own -- the label content is an
## overlay HBoxContainer (mouse_filter=IGNORE on every child, so clicks
## still reach the underlying Button) so the first letter can be colored,
## which a Button's own `text` property can't do.
##
## Unlike a real Container, Button doesn't propagate an added child's
## minimum size into its own -- left alone, every button here reports ~0
## width to the parent HBoxContainer and all the skills render stacked on
## top of each other. Measuring label_row's own minimum size (Label/
## HBoxContainer both compute that from font metrics immediately, no layout
## pass needed) and applying it as the button's custom_minimum_size fixes
## that; anchoring label_row to fill the button then centers the content
## within the padding.
func _build_button(skill: Skill, at_cap: bool = false) -> Button:
	var content_disabled: bool = state.build_locked or at_cap
	var content := MarginContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("margin_left", int(BUTTON_CONTENT_PADDING.x))
	content.add_theme_constant_override("margin_top", int(BUTTON_CONTENT_PADDING.y))
	content.add_theme_constant_override("margin_right", int(BUTTON_CONTENT_PADDING.x))
	content.add_theme_constant_override("margin_bottom", int(BUTTON_CONTENT_PADDING.y))

	var label_row := HBoxContainer.new()
	label_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_row.alignment = BoxContainer.ALIGNMENT_CENTER
	label_row.add_theme_constant_override("separation", 8)
	content.add_child(label_row)

	if skill.icon != null:
		var icon := TextureRect.new()
		icon.name = "SkillIcon"
		icon.texture = skill.icon
		icon.custom_minimum_size = SKILL_ICON_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.modulate = UIColors.ICON_DISABLED if content_disabled else Color.WHITE
		label_row.add_child(icon)
	else:
		var first_letter := Label.new()
		first_letter.text = skill.display_name.substr(0, 1)
		first_letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		first_letter.add_theme_color_override("font_color", UIColors.TEXT_DISABLED if content_disabled else CardStyle.ACCENT_COLOR)
		label_row.add_child(first_letter)

	var rest := Label.new()
	rest.text = skill.display_name if skill.icon != null else skill.display_name.substr(1)
	rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rest.add_theme_color_override("font_color", UIColors.TEXT_DISABLED if content_disabled else UIColors.TEXT_NORMAL)
	label_row.add_child(rest)

	var button := Button.new()
	button.pressed.connect(_on_skill_pressed.bind(skill))
	button.tooltip_text = ("Macro is full (%d max)" % BuildResolver.MAX_ROTATION_SIZE) if at_cap else _tooltip_for(skill)
	button.disabled = content_disabled
	button.add_child(content)
	_apply_button_style(button)

	var content_min: Vector2 = label_row.get_combined_minimum_size()
	button.custom_minimum_size = Vector2(
		maxf(BUTTON_MIN_SIZE.x, content_min.x + BUTTON_CONTENT_PADDING.x * 2.0),
		maxf(BUTTON_MIN_SIZE.y, content_min.y + BUTTON_CONTENT_PADDING.y * 2.0)
	)
	content.set_anchors_preset(Control.PRESET_FULL_RECT)

	return button


## Shows a flavor speed label (SkillTooltipFormatter.SPEED_LABEL_BY_SKILL_ID)
## instead of the
## exact base_execution_ms/min_execution_ms numbers (P2:R7 playtest-feedback,
## 2026-07-19) -- working out real cast timing is meant to be part of the
## game's discovery loop, gleaned from the combat log's real timestamps, not
## read straight off the tooltip. Falls back to a generic label for any
## skill without an authored mapping entry (e.g. the placeholder skills).
func _tooltip_for(skill: Skill) -> String:
	return SkillTooltipFormatterScript.tooltip_for(skill, state)


## Short, comma-joined effect summary derived straight from the skill's own
## SkillEffect resources -- shown in the hover tooltip (see _tooltip_for())
## only, not as an always-visible caption (removed in the P2:R7
## playtest-feedback pass, see this file's header comment). Never hardcodes
## numbers -- every value is read off `effect`.
func _skill_effect_summary(skill: Skill) -> String:
	return SkillTooltipFormatterScript.effect_summary(skill, state)


func _on_skill_pressed(skill: Skill) -> void:
	if state.build_locked:
		return
	var rotation: Array[Skill] = state.rotation.duplicate()
	rotation.append(skill)
	state.set_rotation(rotation)


func _apply_button_style(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _make_button_style(UIColors.PANEL_DEEP, UIColors.STRUCTURE_LINE_LIGHT, 1, "normal"))
	button.add_theme_stylebox_override("hover", _make_button_style(UIColors.PANEL, UIColors.ACCENT, 2, "hover"))
	button.add_theme_stylebox_override("pressed", _make_button_style(UIColors.BUTTON_FILL_PRESSED, UIColors.ACCENT, 2, "pressed"))
	button.add_theme_stylebox_override("focus", _make_button_style(UIColors.PANEL, UIColors.ACCENT, 2, "focus"))
	button.add_theme_stylebox_override("disabled", _make_button_style(UIColors.PANEL_DISABLED, UIColors.STRUCTURE_LINE, 1, "disabled"))


func _make_button_style(bg_color: Color, border_color: Color, border_width: int, state_name: String) -> StyleBoxFlat:
	return CardStyle.make_slot_stylebox(bg_color, border_color, border_width, state_name)
