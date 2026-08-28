extends PanelContainer
## Combat dashboard strip (center column, bottom): the skill macro as a
## horizontal row of icon boxes in left-to-right cast order. Skills without
## assigned art still fall back to Skill.icon_letter. Clicking a box removes
## that slot from the macro; the full skill name is on the tooltip. Adding
## happens in available_skills_panel.gd; both strips sync purely through
## state.rotation.

const CARD_TITLE_FONT_SIZE := 28
const SLOT_SIZE := Vector2(72, 72)
const SLOT_FONT_SIZE := 26
const SLOT_ICON_INSET := 7.0
const SLOT_ICON_SIZE := Vector2(58, 58)
const PANEL_MIN_HEIGHT := 184
const ORDER_BADGE_FONT_SIZE := 11
const REMOVE_BADGE_FONT_SIZE := 14
const SLOT_COUNT_FONT_SIZE := 22
const INTERRUPT_LOCK_ICON_SIZE := Vector2(46, 46)
const INTERRUPT_LOCK_ICON_COLOR := Color(1.0, 0.08, 0.06, 0.92)
const INTERRUPT_LOCK_ICON_OUTLINE := Color(0.12, 0.0, 0.0, 0.9)
const ACTIVE_SLOT_COLOR := UIColors.BUILD_ACTIVE
const ACTIVE_SLOT_BG := UIColors.BUILD_ACTIVE_BG
const PULSE_SLOT_COLOR := UIColors.BUILD_PROC
const PULSE_SLOT_BG := UIColors.BUILD_PROC_BG
const PROGRESS_FILL_COLOR := UIColors.BUILD_PROGRESS_FILL
const PROC_PROGRESS_FILL_COLOR := UIColors.BUILD_PROC_PROGRESS_FILL
const SLOW_PROGRESS_FILL_COLOR := Color(0.38, 0.72, 1.0, 0.48)
const LOCK_ICON := preload("res://assets/ui/icons/build_lock.png")
const UNLOCK_ICON := preload("res://assets/ui/icons/build_unlock.png")
const LOCK_BUTTON_SIZE := Vector2(50, 50)
const LOCK_BUTTON_ICON_SIZE := Vector2(32, 32)
const LOCK_BUTTON_CORNER_RADIUS := 25

## P2:R10: see talent_panel.gd's `state` comment -- same pattern, same
## default, same untyped declaration reason.
var state = BuildState

var _content: VBoxContainer
var _title_label: Label
var _macro_row: HBoxContainer
var _slots_box: HBoxContainer
var _slot_count_label: Label
var _lock_button: Button
var _lock_button_icon: TextureRect
var _lock_holder: CenterContainer
var _slot_buttons: Array[Button] = []
var _slot_fills: Array[ColorRect] = []
var _slot_interrupt_overlays: Array[Control] = []
var _interrupt_locked_skill_ids := {}
var _active_index := -1
var _pulse_tween: Tween
var _slow_effect_active := false


class InterruptLockOverlay:
	extends Control

	var icon_color := Color(1.0, 0.08, 0.06, 0.92)
	var outline_color := Color(0.12, 0.0, 0.0, 0.9)

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var center := size * 0.5
		var radius := minf(size.x, size.y) * 0.42
		draw_arc(center, radius, 0.0, TAU, 56, outline_color, 9.0, true)
		draw_arc(center, radius, 0.0, TAU, 56, icon_color, 6.0, true)
		var diagonal := Vector2(radius * 0.62, radius * 0.62)
		draw_line(center - diagonal, center + diagonal, outline_color, 10.0, true)
		draw_line(center - diagonal, center + diagonal, icon_color, 7.0, true)


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	custom_minimum_size = Vector2(0, PANEL_MIN_HEIGHT)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 8)
	add_child(_content)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 16)
	_content.add_child(title_row)

	_title_label = Label.new()
	_title_label.text = "Skill Build"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_title_label.theme_type_variation = &"PanelHeader"
	_title_label.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	title_row.add_child(_title_label)

	var title_spacer := Control.new()
	title_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_spacer)

	_slot_count_label = Label.new()
	_slot_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_slot_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_slot_count_label.add_theme_font_size_override("font_size", SLOT_COUNT_FONT_SIZE)
	_slot_count_label.add_theme_color_override("font_color", UIColors.TEXT_DISABLED)
	title_row.add_child(_slot_count_label)

	_lock_button = Button.new()
	_lock_button.custom_minimum_size = LOCK_BUTTON_SIZE
	_lock_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_lock_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_lock_button.pressed.connect(_on_lock_pressed)

	_lock_button_icon = TextureRect.new()
	_lock_button_icon.name = "LockButtonIcon"
	_lock_button_icon.custom_minimum_size = LOCK_BUTTON_ICON_SIZE
	_lock_button_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_lock_button_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lock_button_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_lock_button_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_lock_button_icon.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_lock_button_icon.anchor_top = 0.5
	_lock_button_icon.anchor_bottom = 0.5
	_lock_button.add_child(_lock_button_icon)

	_macro_row = HBoxContainer.new()
	_macro_row.add_theme_constant_override("separation", 2)
	_content.add_child(_macro_row)

	_slots_box = HBoxContainer.new()
	_slots_box.add_theme_constant_override("separation", 6)
	_slots_box.custom_minimum_size = Vector2(0, SLOT_SIZE.y)
	_macro_row.add_child(_slots_box)

	var lock_spacer := Control.new()
	lock_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_macro_row.add_child(lock_spacer)

	_lock_holder = CenterContainer.new()
	_lock_holder.custom_minimum_size = Vector2(LOCK_BUTTON_SIZE.x, SLOT_SIZE.y)
	_macro_row.add_child(_lock_holder)
	_lock_holder.add_child(_lock_button)

	state.build_changed.connect(_refresh)
	state.lock_changed.connect(_refresh)
	_update_lock_icon_rect()
	_refresh()


func _on_lock_pressed() -> void:
	state.set_locked(not state.build_locked)


func _update_lock_button() -> void:
	var disabled_empty_lock: bool = state.rotation.is_empty() and not state.build_locked
	_lock_button.text = ""
	_lock_button.icon = null
	_lock_button.add_theme_constant_override("icon_max_width", 0)
	_lock_button.add_theme_constant_override("h_separation", 0)
	_lock_button.add_theme_constant_override("text_outline_size", 0)
	_lock_button.add_theme_constant_override("padding_left", 0)
	_lock_button.add_theme_constant_override("padding_right", 0)
	_lock_button.add_theme_constant_override("padding_top", 0)
	_lock_button.add_theme_constant_override("padding_bottom", 0)
	_lock_button_icon.texture = LOCK_ICON if state.build_locked else UNLOCK_ICON
	_lock_button.tooltip_text = (
		"Unlock your skill macro so you can edit it"
		if state.build_locked
		else "Slot at least one skill before locking your macro"
		if disabled_empty_lock
		else "Lock this skill macro so you can start the fight"
	)
	_lock_button_icon.modulate = UIColors.ICON_DISABLED if disabled_empty_lock else Color.WHITE
	_apply_lock_button_style()
	# Can't lock an empty macro -- fighting with no skills is a guaranteed
	# zero-damage loss.
	_lock_button.disabled = disabled_empty_lock


func _refresh() -> void:
	_update_lock_button()
	_update_slot_count_label()
	_slot_buttons = []
	_slot_fills = []
	_slot_interrupt_overlays = []
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
		fill.color = _progress_fill_color(false)
		fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fill.anchor_left = 0.0
		fill.anchor_top = 0.0
		fill.anchor_right = 0.0
		fill.anchor_bottom = 1.0
		fill.offset_left = 0.0
		fill.offset_top = 0.0
		fill.offset_right = 0.0
		fill.offset_bottom = 0.0
		fill.z_index = 3
		slot.add_child(fill)
		var interrupt_overlay := _make_interrupt_lock_overlay()
		interrupt_overlay.visible = _interrupt_locked_skill_ids.has(_skill_lock_key(skill))
		slot.add_child(interrupt_overlay)

		# Cast-order number, top-left corner -- makes the left-to-right
		# rotation order explicit rather than only implied by position.
		# mouse_filter=IGNORE (same overlay pattern as available_skills_panel
		# and talent_panel) so the badge doesn't steal the slot's click.
		var order_badge := Label.new()
		order_badge.text = str(i + 1)
		order_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		order_badge.z_index = 4
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
			remove_badge.z_index = 4
			remove_badge.add_theme_font_size_override("font_size", REMOVE_BADGE_FONT_SIZE)
			remove_badge.add_theme_color_override("font_color", UIColors.TEXT_WARNING)
			remove_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			remove_badge.position = Vector2(-13, 1)
			slot.add_child(remove_badge)

		_slots_box.add_child(slot)
		_slot_buttons.append(slot)
		_slot_fills.append(fill)
		_slot_interrupt_overlays.append(interrupt_overlay)


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
		fill.color = _progress_fill_color(proc and i == _active_index)


func clear_combat_highlight() -> void:
	_active_index = -1
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	for i in _slot_buttons.size():
		_apply_slot_style(_slot_buttons[i], false, false)
		if i < _slot_fills.size():
			_slot_fills[i].anchor_right = 0.0


func set_interrupt_locked_skill(skill: Skill, locked: bool) -> void:
	var key := _skill_lock_key(skill)
	if key == "":
		return
	if locked:
		_interrupt_locked_skill_ids[key] = true
	else:
		_interrupt_locked_skill_ids.erase(key)
	_apply_interrupt_locks()


func clear_interrupt_locks() -> void:
	_interrupt_locked_skill_ids.clear()
	_apply_interrupt_locks()


func set_slow_effect_active(active: bool) -> void:
	_slow_effect_active = active
	for fill in _slot_fills:
		fill.color = _progress_fill_color(false)


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
	icon.offset_left = SLOT_ICON_INSET
	icon.offset_top = SLOT_ICON_INSET
	icon.offset_right = -SLOT_ICON_INSET
	icon.offset_bottom = -SLOT_ICON_INSET
	icon.z_index = 2
	slot.add_child(icon)


func _make_interrupt_lock_overlay() -> Control:
	var overlay := InterruptLockOverlay.new()
	overlay.name = "InterruptLockOverlay"
	overlay.icon_color = INTERRUPT_LOCK_ICON_COLOR
	overlay.outline_color = INTERRUPT_LOCK_ICON_OUTLINE
	overlay.custom_minimum_size = INTERRUPT_LOCK_ICON_SIZE
	overlay.set_anchors_preset(Control.PRESET_CENTER)
	overlay.offset_left = -INTERRUPT_LOCK_ICON_SIZE.x * 0.5
	overlay.offset_right = INTERRUPT_LOCK_ICON_SIZE.x * 0.5
	overlay.offset_top = -INTERRUPT_LOCK_ICON_SIZE.y * 0.5
	overlay.offset_bottom = INTERRUPT_LOCK_ICON_SIZE.y * 0.5
	overlay.z_index = 7
	overlay.visible = false
	return overlay


func _apply_interrupt_locks() -> void:
	for i in _slot_interrupt_overlays.size():
		var overlay := _slot_interrupt_overlays[i]
		if overlay == null:
			continue
		var skill: Skill = state.rotation[i] if i < state.rotation.size() else null
		overlay.visible = _interrupt_locked_skill_ids.has(_skill_lock_key(skill))


func _progress_fill_color(proc: bool) -> Color:
	if proc:
		return PROC_PROGRESS_FILL_COLOR
	return SLOW_PROGRESS_FILL_COLOR if _slow_effect_active else PROGRESS_FILL_COLOR


func _skill_lock_key(skill: Skill) -> String:
	if skill == null:
		return ""
	if skill.id != "":
		return skill.id
	return skill.resource_path if skill.resource_path != "" else skill.display_name


func _on_slot_pressed(index: int) -> void:
	if state.build_locked:
		return
	var rotation: Array[Skill] = state.rotation.duplicate()
	rotation.remove_at(index)
	state.set_rotation(rotation)


func _apply_slot_style(slot: Button, active: bool, pulse: bool) -> void:
	var border_color := PULSE_SLOT_COLOR if pulse else (ACTIVE_SLOT_COLOR if active else CardStyle.ACCENT_COLOR)
	var bg_color := PULSE_SLOT_BG if pulse else (ACTIVE_SLOT_BG if active else UIColors.PANEL_DEEP)
	for state_name in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := CardStyle.make_slot_stylebox(bg_color, border_color, 3 if active or pulse else 1, state_name)
		slot.add_theme_stylebox_override(state_name, style)
	slot.add_theme_color_override("font_color", border_color)


func _apply_lock_button_style() -> void:
	var fill := UIColors.BUTTON_FILL_PRESSED if state.build_locked else UIColors.BUTTON_FILL
	var border := UIColors.TEXT_DISABLED if state.build_locked else UIColors.PANEL_BORDER
	for state_name in ["normal", "hover", "pressed", "focus"]:
		var style := CardStyle.make_action_button_stylebox(fill, border, state_name)
		style.set_corner_radius_all(LOCK_BUTTON_CORNER_RADIUS)
		_lock_button.add_theme_stylebox_override(state_name, style)
	var disabled_style := CardStyle.make_action_button_stylebox(UIColors.PANEL_DISABLED, UIColors.STRUCTURE_LINE_LIGHT, "disabled")
	disabled_style.set_corner_radius_all(LOCK_BUTTON_CORNER_RADIUS)
	_lock_button.add_theme_stylebox_override("disabled", disabled_style)


func _update_slot_count_label() -> void:
	var count: int = state.rotation.size()
	_slot_count_label.text = "Slots: %d/%d" % [count, BuildResolver.MAX_ROTATION_SIZE]
	_slot_count_label.add_theme_color_override("font_color", UIColors.TEXT_GOLD if count >= BuildResolver.MAX_ROTATION_SIZE else UIColors.TEXT_DISABLED)


func _update_lock_icon_rect() -> void:
	_lock_button_icon.custom_minimum_size = LOCK_BUTTON_ICON_SIZE
	_lock_button_icon.offset_left = (LOCK_BUTTON_SIZE.x - LOCK_BUTTON_ICON_SIZE.x) / 2.0
	_lock_button_icon.offset_right = (LOCK_BUTTON_SIZE.x + LOCK_BUTTON_ICON_SIZE.x) / 2.0
	_lock_button_icon.offset_top = -LOCK_BUTTON_ICON_SIZE.y / 2.0
	_lock_button_icon.offset_bottom = LOCK_BUTTON_ICON_SIZE.y / 2.0


func _pulse_slot(slot: Button) -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_apply_slot_style(slot, true, true)
	_pulse_tween = create_tween()
	_pulse_tween.tween_interval(0.16)
	_pulse_tween.tween_callback(func(): _apply_slot_style(slot, true, false))
