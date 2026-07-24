extends PanelContainer
## Combat dashboard strip (center column, bottom): the skill macro as a
## horizontal row of letter boxes in left-to-right cast order (S=Stab,
## Q=Quick Cut, etc. -- Skill.icon_letter, a stand-in until skills get real
## icons). Clicking a box removes that slot from the macro; the full skill
## name is on the tooltip. Adding happens in available_skills_panel.gd;
## both strips sync purely through state.rotation.

const CARD_TITLE_FONT_SIZE := 20
const SLOT_SIZE := Vector2(48, 48)
const SLOT_FONT_SIZE := 22
const PANEL_MIN_HEIGHT := 132
const ORDER_BADGE_FONT_SIZE := 10
const REMOVE_BADGE_FONT_SIZE := 13

## P2:R10: see talent_panel.gd's `state` comment -- same pattern, same
## default, same untyped declaration reason.
var state = BuildState

var _slots_box: HBoxContainer
var _lock_button: Button


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

		# Cast-order number, top-left corner -- makes the left-to-right
		# rotation order explicit rather than only implied by position.
		# mouse_filter=IGNORE (same overlay pattern as available_skills_panel
		# and talent_panel) so the badge doesn't steal the slot's click.
		var order_badge := Label.new()
		order_badge.text = str(i + 1)
		order_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
			remove_badge.add_theme_font_size_override("font_size", REMOVE_BADGE_FONT_SIZE)
			remove_badge.add_theme_color_override("font_color", UIColors.TEXT_WARNING)
			remove_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			remove_badge.position = Vector2(-13, 1)
			slot.add_child(remove_badge)

		_slots_box.add_child(slot)


func _glyph_for(skill: Skill) -> String:
	if skill.icon_letter != "":
		return skill.icon_letter
	# Fallback for any skill data that hasn't been assigned a letter yet.
	return skill.display_name.left(1).to_upper()


func _on_slot_pressed(index: int) -> void:
	if state.build_locked:
		return
	var rotation: Array[Skill] = state.rotation.duplicate()
	rotation.remove_at(index)
	state.set_rotation(rotation)
