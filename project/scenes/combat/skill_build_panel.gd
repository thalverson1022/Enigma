extends PanelContainer
## Combat dashboard strip (center column, bottom): the skill macro as a
## horizontal row of icon boxes in left-to-right cast order. Skills without
## assigned art still fall back to Skill.icon_letter. Clicking a box removes
## that slot from the macro; the full skill name is on the tooltip. Adding
## happens in available_skills_panel.gd; both strips sync purely through
## state.rotation.

const CARD_TITLE_FONT_SIZE := 20
const SLOT_SIZE := Vector2(48, 48)
const SLOT_FONT_SIZE := 22
const SLOT_ICON_SIZE := Vector2(30, 30)
const PANEL_MIN_HEIGHT := 132
const ORDER_BADGE_FONT_SIZE := 10
const REMOVE_BADGE_FONT_SIZE := 13
const ACTIVE_SLOT_COLOR := Color(1.0, 0.86, 0.28, 1.0)
const ACTIVE_SLOT_BG := Color(0.22, 0.17, 0.05, 0.94)
const PULSE_SLOT_COLOR := UIColors.TEXT_MAGIC
const PULSE_SLOT_BG := Color(0.18, 0.08, 0.24, 0.94)
const PROGRESS_FILL_COLOR := Color(1.0, 0.86, 0.28, 0.36)
const PROC_PROGRESS_FILL_COLOR := Color(0.62, 0.45, 0.85, 0.48)

## P2:R10: see talent_panel.gd's `state` comment -- same pattern, same
## default, same untyped declaration reason.
var state = BuildState

var _slots_box: HBoxContainer
var _lock_button: Button
var _slot_buttons: Array[Button] = []
var _slot_fills: Array[ColorRect] = []
var _active_index := -1
var _pulse_tween: Tween


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	custom_minimum_size = Vector2(0, PANEL_MIN_HEIGHT)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = "Skill Build"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_slots_box = HBoxContainer.new()
	_slots_box.add_theme_constant_override("separation", 8)
	_slots_box.custom_minimum_size = Vector2(0, SLOT_SIZE.y)
	content.add_child(_slots_box)

	_lock_button = Button.new()
	_lock_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_lock_button.pressed.connect(_on_lock_pressed)
	content.add_child(_lock_button)

	state.build_changed.connect(_refresh)
	state.lock_changed.connect(_refresh)
	_refresh()


func _on_lock_pressed() -> void:
	state.set_locked(not state.build_locked)


func _update_lock_button() -> void:
	_lock_button.text = "UNLOCK" if state.build_locked else "LOCK"
	# Can't ready an empty macro -- fighting with no skills is a guaranteed
	# zero-damage loss.
	_lock_button.disabled = state.rotation.is_empty() and not state.build_locked


func _refresh() -> void:
	_update_lock_button()
	_slot_buttons = []
	_slot_fills = []
	for child in _slots_box.get_children():
		if child is Button:
			child.disabled = state.build_locked
		child.queue_free()

	if state.rotation.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No skills slotted -- click a skill above to add it."
		_slots_box.add_child(empty_label)
		return

	for i in state.rotation.size():
		var skill: Skill = state.rotation[i]
		var slot := Button.new()
		slot.text = _glyph_for(skill)
		slot.custom_minimum_size = SLOT_SIZE
		slot.add_theme_font_size_override("font_size", SLOT_FONT_SIZE)
		slot.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
		slot.disabled = state.build_locked
		slot.tooltip_text = "%s -- cast position %d of %d (%s)" % [
			skill.display_name,
			i + 1,
			state.rotation.size(),
			"unlock to edit" if state.build_locked else "click the slot or the x to remove",
		]
		slot.pressed.connect(_on_slot_pressed.bind(i))
		_apply_slot_style(slot, i == _active_index, false)
		_add_skill_icon(slot, skill)

		var fill := ColorRect.new()
		fill.name = "CastProgressFill"
		fill.color = PROGRESS_FILL_COLOR
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fill.anchor_left = 0.0
		fill.anchor_top = 0.0
		fill.anchor_right = 0.0
		fill.anchor_bottom = 1.0
		fill.offset_left = 0.0
		fill.offset_top = 0.0
		fill.offset_right = 0.0
		fill.offset_bottom = 0.0
		fill.z_index = 1
		slot.add_child(fill)

		# Cast-order number, top-left corner -- makes the left-to-right
		# rotation order explicit rather than only implied by position.
		# mouse_filter=IGNORE (same overlay pattern as available_skills_panel
		# and talent_panel) so the badge doesn't steal the slot's click.
		var order_badge := Label.new()
		order_badge.text = str(i + 1)
		order_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		order_badge.z_index = 3
		order_badge.add_theme_font_size_override("font_size", ORDER_BADGE_FONT_SIZE)
		order_badge.add_theme_color_override("font_color", UIColors.TEXT_DISABLED)
		order_badge.set_anchors_preset(Control.PRESET_TOP_LEFT)
		order_badge.position = Vector2(3, 1)
		slot.add_child(order_badge)

		# Explicit remove affordance, top-right corner -- the whole slot
		# already removes on click, but the task calls for an obvious,
		# discoverable remove control rather than only implicit behavior.
		# Hidden while locked, since clicking does nothing then.
		if not state.build_locked:
			var remove_badge := Label.new()
			remove_badge.text = "x"
			remove_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			remove_badge.z_index = 3
			remove_badge.add_theme_font_size_override("font_size", REMOVE_BADGE_FONT_SIZE)
			remove_badge.add_theme_color_override("font_color", UIColors.TEXT_WARNING)
			remove_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			remove_badge.position = Vector2(-13, 1)
			slot.add_child(remove_badge)

		_slots_box.add_child(slot)
		_slot_buttons.append(slot)
		_slot_fills.append(fill)


func highlight_rotation_index(index: int, pulse: bool = false) -> void:
	if state.rotation.is_empty():
		clear_combat_highlight()
		return
	_active_index = posmod(index, state.rotation.size())
	for i in _slot_buttons.size():
		_apply_slot_style(_slot_buttons[i], i == _active_index, false)
	if pulse and _active_index >= 0 and _active_index < _slot_buttons.size():
		_pulse_slot(_slot_buttons[_active_index])


func set_cast_progress(index: int, progress: float, proc: bool = false) -> void:
	if state.rotation.is_empty():
		clear_combat_highlight()
		return
	_active_index = posmod(index, state.rotation.size())
	for i in _slot_buttons.size():
		_apply_slot_style(_slot_buttons[i], i == _active_index, false)
		var fill: ColorRect = _slot_fills[i]
		var clamped := clampf(progress if i == _active_index else 0.0, 0.0, 1.0)
		fill.anchor_right = clamped
		fill.color = PROC_PROGRESS_FILL_COLOR if proc and i == _active_index else PROGRESS_FILL_COLOR


func clear_combat_highlight() -> void:
	_active_index = -1
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	for i in _slot_buttons.size():
		_apply_slot_style(_slot_buttons[i], false, false)
		if i < _slot_fills.size():
			_slot_fills[i].anchor_right = 0.0


func _glyph_for(skill: Skill) -> String:
	if skill.icon != null:
		return ""
	if skill.icon_letter != "":
		return skill.icon_letter
	# Fallback for any skill data that hasn't been assigned a letter yet.
	return skill.display_name.left(1).to_upper()


func _add_skill_icon(slot: Button, skill: Skill) -> void:
	if skill.icon == null:
		return
	var icon := TextureRect.new()
	icon.name = "SkillIcon"
	icon.texture = skill.icon
	icon.custom_minimum_size = SLOT_ICON_SIZE
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 8.0
	icon.offset_top = 8.0
	icon.offset_right = -8.0
	icon.offset_bottom = -8.0
	icon.z_index = 2
	slot.add_child(icon)


func _on_slot_pressed(index: int) -> void:
	if state.build_locked:
		return
	var rotation: Array[Skill] = state.rotation.duplicate()
	rotation.remove_at(index)
	state.set_rotation(rotation)


func _apply_slot_style(slot: Button, active: bool, pulse: bool) -> void:
	var border_color := PULSE_SLOT_COLOR if pulse else (ACTIVE_SLOT_COLOR if active else CardStyle.ACCENT_COLOR)
	var bg_color := PULSE_SLOT_BG if pulse else (ACTIVE_SLOT_BG if active else UIColors.PANEL_DEEP)
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.set_border_width_all(3 if active or pulse else 1)
	style.set_corner_radius_all(6)
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		slot.add_theme_stylebox_override(state_name, style)
	slot.add_theme_color_override("font_color", border_color)


func _pulse_slot(slot: Button) -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_apply_slot_style(slot, true, true)
	_pulse_tween = create_tween()
	_pulse_tween.tween_interval(0.16)
	_pulse_tween.tween_callback(func(): _apply_slot_style(slot, true, false))
