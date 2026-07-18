extends PanelContainer
## Combat dashboard strip (center column, below the combat window): the
## currently unlocked skills as a horizontal row of buttons -- clicking one
## appends it to the macro (BuildState.rotation). Split out of the old
## combined skill_macro_panel to match the mockup's two separate
## "Available Skills" / "Skill Build" strips.
##
## Each button's first letter is colored (CardStyle.ACCENT_COLOR) to match
## the letter shown on that skill's slot in skill_build_panel.gd, and hover
## shows a tooltip with the skill's cast time and effects.

const CARD_TITLE_FONT_SIZE := 20

var _skills_box: HBoxContainer


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = "Available Skills"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_skills_box = HBoxContainer.new()
	_skills_box.add_theme_constant_override("separation", 8)
	content.add_child(_skills_box)

	BuildState.build_changed.connect(_refresh)
	BuildState.lock_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for child in _skills_box.get_children():
		if child is Button:
			child.disabled = BuildState.build_locked
		child.queue_free()
	for skill in BuildState.unlocked_skills():
		_skills_box.add_child(_build_skill_button(skill))


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
func _build_skill_button(skill: Skill) -> Button:
	var label_row := HBoxContainer.new()
	label_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_row.alignment = BoxContainer.ALIGNMENT_CENTER

	var first_letter := Label.new()
	first_letter.text = skill.display_name.substr(0, 1)
	first_letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	first_letter.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	label_row.add_child(first_letter)

	var rest := Label.new()
	rest.text = skill.display_name.substr(1)
	rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_row.add_child(rest)

	var button := Button.new()
	button.pressed.connect(_on_skill_pressed.bind(skill))
	button.tooltip_text = _tooltip_for(skill)
	button.disabled = BuildState.build_locked
	button.add_child(label_row)

	var content_min: Vector2 = label_row.get_combined_minimum_size()
	button.custom_minimum_size = content_min + Vector2(24, 12)
	label_row.set_anchors_preset(Control.PRESET_FULL_RECT)

	return button


func _tooltip_for(skill: Skill) -> String:
	var lines: PackedStringArray = []
	lines.append("Cast: %dms (min %dms)" % [skill.base_execution_ms, skill.min_execution_ms])
	for effect in skill.effects:
		if effect is PhysicalDamageEffect:
			lines.append("%.0f physical damage" % effect.amount)
		elif effect is PoisonDamageEffect:
			lines.append("Applies %d poison stack(s)" % effect.stacks_applied)
		elif effect is ArmorReductionEffect:
			lines.append("Reduces armor by %d" % effect.amount)
		elif effect is PoisonResistanceReductionEffect:
			lines.append("Reduces poison resistance by %d%%" % roundi(effect.reduction_fraction * 100.0))
		elif effect is StackScalingPhysicalDamageEffect:
			lines.append("+%.0f physical damage per active poison stack" % effect.damage_per_stack)
	return "\n".join(lines)


func _on_skill_pressed(skill: Skill) -> void:
	if BuildState.build_locked:
		return
	var rotation: Array[Skill] = BuildState.rotation.duplicate()
	rotation.append(skill)
	BuildState.set_rotation(rotation)
