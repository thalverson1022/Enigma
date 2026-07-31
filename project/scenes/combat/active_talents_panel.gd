extends PanelContainer
## Compact Adventure dashboard summary of the currently selected talents.
## The full talent tree still exists, but it opens in combat_screen.gd's
## Talent Trees overlay so the left column reads as "what is active now"
## instead of inviting constant per-fight tree tweaking.

signal open_talents_pressed

const CARD_TITLE_FONT_SIZE := 20
const POINTS_FONT_SIZE := 18
const OPEN_BUTTON_SIZE := Vector2(176, 36)

## Same pattern as talent_panel.gd: defaults to Adventure's BuildState but
## stays untyped so a future practice state can reuse this panel.
var state = BuildState

var _points_label: Label
var _talents_box: VBoxContainer
var _open_button: Button
var _button_blink_tween: Tween


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = "Active Talents"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_points_label = Label.new()
	_points_label.add_theme_font_size_override("font_size", POINTS_FONT_SIZE)
	content.add_child(_points_label)

	_talents_box = VBoxContainer.new()
	_talents_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_talents_box.add_theme_constant_override("separation", 6)
	content.add_child(_talents_box)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	_open_button = Button.new()
	_open_button.custom_minimum_size = OPEN_BUTTON_SIZE
	_open_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_open_button.pressed.connect(func(): open_talents_pressed.emit())
	content.add_child(_open_button)

	state.build_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var spent: int = PassiveAllocator.points_spent(state.selected_talents)
	var earned: int = state.earned_talent_points
	var remaining: int = earned - spent
	_points_label.text = "Points: %d/%d" % [spent, earned]
	_points_label.add_theme_color_override(
		"font_color", UIColors.TEXT_GOLD if remaining > 0 else UIColors.TEXT_NORMAL
	)
	_open_button.text = "Talent Trees"
	_open_button.tooltip_text = "Open Talent Trees to spend earned points" if remaining > 0 else "Open Talent Trees"
	_set_open_button_attention(remaining > 0)

	for child in _talents_box.get_children():
		child.queue_free()

	if state.selected_trees.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No subclass selected."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.add_theme_color_override("font_color", UIColors.TEXT_DISABLED)
		_talents_box.add_child(empty_label)
		return

	for tree in state.selected_trees:
		_talents_box.add_child(_build_tree_section(tree))


func _build_tree_section(tree: SubclassTree) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 4)

	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_BEGIN
	header.add_theme_constant_override("separation", 8)
	section.add_child(header)

	if tree.icon != null:
		header.add_child(CardStyle.make_pixel_icon(tree.icon, Vector2(32, 32)))

	var tree_label := Label.new()
	tree_label.text = tree.display_name
	tree_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tree_label.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	header.add_child(tree_label)

	var intrinsic_label := Label.new()
	intrinsic_label.text = "Intrinsic: %s" % _intrinsic_description(tree)
	intrinsic_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intrinsic_label.add_theme_font_size_override("font_size", 13)
	section.add_child(intrinsic_label)

	var talents_label := Label.new()
	talents_label.text = "%s Talents" % tree.display_name
	talents_label.add_theme_font_size_override("font_size", 13)
	talents_label.add_theme_color_override("font_color", UIColors.TEXT_GOLD)
	section.add_child(talents_label)

	var selected_for_tree: Array[Talent] = []
	for talent in state.selected_talents:
		if tree.talents.has(talent):
			selected_for_tree.append(talent)
	if selected_for_tree.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No %s talents selected." % tree.display_name
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.add_theme_font_size_override("font_size", 13)
		empty_label.add_theme_color_override("font_color", UIColors.TEXT_DISABLED)
		section.add_child(empty_label)
	else:
		for talent in selected_for_tree:
			section.add_child(_build_talent_row(talent))

	return section


func _build_talent_row(talent: Talent) -> VBoxContainer:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 1)

	var name_label := Label.new()
	name_label.text = talent.display_name
	name_label.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	row.add_child(name_label)

	var detail_label := Label.new()
	detail_label.text = _talent_summary(talent)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_label.add_theme_font_size_override("font_size", 13)
	row.add_child(detail_label)
	return row


func _intrinsic_description(tree: SubclassTree) -> String:
	if tree.intrinsic_text != "":
		return tree.intrinsic_text
	var lines: PackedStringArray = []
	for skill in tree.unlocked_skills:
		lines.append("Unlocks %s" % skill.display_name)
	for modifier in tree.innate_modifiers:
		lines.append(StatModifierFormatter.format(modifier))
	for augment in tree.skill_augments:
		lines.append(_skill_augment_description(augment))
	if lines.is_empty():
		return "None"
	return ", ".join(lines)


func _set_open_button_attention(enabled: bool) -> void:
	if _open_button == null:
		return
	if not enabled:
		if _button_blink_tween != null:
			_button_blink_tween.kill()
			_button_blink_tween = null
		_open_button.modulate = Color.WHITE
		return
	if _button_blink_tween != null and _button_blink_tween.is_running():
		return
	_open_button.modulate = Color.WHITE
	_button_blink_tween = create_tween()
	_button_blink_tween.set_loops()
	_button_blink_tween.tween_property(_open_button, "modulate", Color(1.0, 0.42, 0.28, 1.0), 0.25)
	_button_blink_tween.tween_property(_open_button, "modulate", Color.WHITE, 0.25)


func _skill_augment_description(augment: SkillAugment) -> String:
	var target_names: PackedStringArray = []
	for target_id in augment.target_skill_ids:
		target_names.append(_skill_name_for_id(target_id))
	var effect_names: PackedStringArray = []
	for effect in augment.extra_effects:
		if effect is PoisonDamageEffect:
			var poison_effect: PoisonDamageEffect = effect
			effect_names.append("+%d poison stack%s" % [poison_effect.stacks_applied, "" if poison_effect.stacks_applied == 1 else "s"])
		elif effect is PoisonResistanceReductionEffect:
			var resist_effect: PoisonResistanceReductionEffect = effect
			effect_names.append("-%d%% poison resistance" % roundi(resist_effect.reduction_fraction * 100.0))
		elif effect is StackScalingPhysicalDamageEffect:
			var stack_effect: StackScalingPhysicalDamageEffect = effect
			effect_names.append("+%.0f damage per poison stack" % stack_effect.damage_per_stack)
	if target_names.is_empty() or effect_names.is_empty():
		return "Enhances selected skills"
	return "%s gain %s" % [", ".join(target_names), ", ".join(effect_names)]


func _skill_name_for_id(skill_id: String) -> String:
	if state.selected_class != null:
		for skill in state.selected_class.base_skills:
			if skill.id == skill_id:
				return skill.display_name
		for tree in state.selected_class.trees:
			for skill in tree.unlocked_skills:
				if skill.id == skill_id:
					return skill.display_name
			for talent in tree.talents:
				for skill in talent.unlocked_skills:
					if skill.id == skill_id:
						return skill.display_name
	return skill_id


func _talent_summary(talent: Talent) -> String:
	var lines: PackedStringArray = []
	for modifier in talent.stat_modifiers:
		lines.append(StatModifierFormatter.format(modifier))
	for skill in talent.unlocked_skills:
		lines.append("Unlocks %s" % skill.display_name)
	for trigger in talent.triggered_skill_effects:
		if trigger != null and trigger.skill != null:
			lines.append("%d%% chance: %s" % [roundi(trigger.chance * 100.0), trigger.skill.display_name])
	if lines.is_empty():
		return "No effect yet"
	return ", ".join(lines)
