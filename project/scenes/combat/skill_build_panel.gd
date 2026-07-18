extends PanelContainer
## Combat dashboard strip (center column, bottom): the skill macro as a
## horizontal row of letter boxes in left-to-right cast order (S=Stab,
## Q=Quick Cut, etc. -- Skill.icon_letter, a stand-in until skills get real
## icons). Clicking a box removes that slot from the macro; the full skill
## name is on the tooltip. Adding happens in available_skills_panel.gd;
## both strips sync purely through BuildState.rotation.

const CARD_TITLE_FONT_SIZE := 20
const SLOT_SIZE := Vector2(48, 48)
const SLOT_FONT_SIZE := 22
const PANEL_MIN_HEIGHT := 132

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

	BuildState.build_changed.connect(_refresh)
	BuildState.lock_changed.connect(_refresh)
	_refresh()


func _on_lock_pressed() -> void:
	BuildState.set_locked(not BuildState.build_locked)


func _update_lock_button() -> void:
	_lock_button.text = "UNLOCK" if BuildState.build_locked else "LOCK"
	# Can't ready an empty macro -- fighting with no skills is a guaranteed
	# zero-damage loss.
	_lock_button.disabled = BuildState.rotation.is_empty() and not BuildState.build_locked


func _refresh() -> void:
	_update_lock_button()
	for child in _slots_box.get_children():
		if child is Button:
			child.disabled = BuildState.build_locked
		child.queue_free()

	if BuildState.rotation.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No skills slotted -- click a skill above to add it."
		_slots_box.add_child(empty_label)
		return

	for i in BuildState.rotation.size():
		var skill: Skill = BuildState.rotation[i]
		var slot := Button.new()
		slot.text = _glyph_for(skill)
		slot.custom_minimum_size = SLOT_SIZE
		slot.add_theme_font_size_override("font_size", SLOT_FONT_SIZE)
		slot.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
		slot.disabled = BuildState.build_locked
		slot.tooltip_text = "%s (%s)" % [
			skill.display_name,
			"unlock to edit" if BuildState.build_locked else "click to remove",
		]
		slot.pressed.connect(_on_slot_pressed.bind(i))
		_slots_box.add_child(slot)


func _glyph_for(skill: Skill) -> String:
	if skill.icon_letter != "":
		return skill.icon_letter
	# Fallback for any skill data that hasn't been assigned a letter yet.
	return skill.display_name.left(1).to_upper()


func _on_slot_pressed(index: int) -> void:
	if BuildState.build_locked:
		return
	var rotation: Array[Skill] = BuildState.rotation.duplicate()
	rotation.remove_at(index)
	BuildState.set_rotation(rotation)
