extends PanelContainer
## Combat dashboard panel: the subclass talent tree, drawn as a tree per the
## user's mockup rather than a flat list of toggles. Tiers are derived from
## the talent data itself (prerequisite depth: no-prereq talents form the
## base row, each deeper talent sits below the deepest of its prerequisite
## options), so the layout works for any seeded tree without code changes.
## Each node shows one circle per talent-point cost; circles fill green when
## the talent is selected. Clicking a node toggles it; validation stays in
## PassiveAllocator via BuildState.select_talent/deselect_talent -- a
## rejected toggle simply changes nothing. Unavailable nodes (prereqs unmet
## or budget exceeded) render dimmed and disabled.
##
## Root is PanelContainer -- see character_stats_panel.gd's comment for why.

const CARD_TITLE_FONT_SIZE := 20
const SUBCLASS_LABEL_FONT_SIZE := 15
const INTRINSIC_LABEL_FONT_SIZE := 13
const NODE_ROW_SEPARATION := 20
const COMPACT_NODE_ROW_SEPARATION := 4
const CONNECTOR_COLOR := Color(0.4, 0.4, 0.45)
const UNAVAILABLE_ALPHA := 0.45

var _talent_box: VBoxContainer
var _points_label: Label


## One circle per point of cost; filled green when selected, outline when
## not. Custom-drawn -- unicode circle glyphs render too inconsistently
## across fonts to trust for a game UI element.
class TalentCircles:
	extends Control

	const RADIUS := 7.0
	const GAP := 5.0
	const FILL_COLOR := Color(0.35, 0.8, 0.35)
	const OUTLINE_COLOR := Color(0.75, 0.78, 0.82)

	var count: int = 1
	var filled: bool = false

	func _init(circle_count: int, is_filled: bool) -> void:
		count = circle_count
		filled = is_filled
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(count * (RADIUS * 2.0 + GAP) - GAP, RADIUS * 2.0 + 2.0)

	func _draw() -> void:
		for i in count:
			var center := Vector2(RADIUS + i * (RADIUS * 2.0 + GAP), size.y / 2.0)
			if filled:
				draw_circle(center, RADIUS, FILL_COLOR)
			else:
				draw_arc(center, RADIUS - 1.0, 0.0, TAU, 24, OUTLINE_COLOR, 2.0)


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 4)
	add_child(content)

	var title := Label.new()
	title.text = "Talents"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_talent_box = VBoxContainer.new()
	_talent_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_talent_box.add_theme_constant_override("separation", 2)
	content.add_child(_talent_box)

	var footer := HBoxContainer.new()
	var footer_spacer := Control.new()
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	_points_label = Label.new()
	footer.add_child(_points_label)
	content.add_child(footer)

	BuildState.build_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	for child in _talent_box.get_children():
		child.queue_free()
	_talent_box.alignment = BoxContainer.ALIGNMENT_CENTER if BuildState.selected_trees.size() > 1 else BoxContainer.ALIGNMENT_BEGIN
	_talent_box.add_theme_constant_override("separation", 14 if BuildState.selected_trees.size() > 1 else 2)
	for tree in BuildState.selected_trees:
		_build_tree(tree)
	_refresh_points_label()


func _build_tree(tree: SubclassTree) -> void:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 3 if BuildState.selected_trees.size() > 1 else 3)
	section.size_flags_vertical = Control.SIZE_SHRINK_CENTER if BuildState.selected_trees.size() > 1 else Control.SIZE_EXPAND_FILL
	_talent_box.add_child(section)

	var tree_name := Label.new()
	tree_name.text = tree.display_name
	tree_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tree_name.add_theme_font_size_override("font_size", 14 if BuildState.selected_trees.size() > 1 else SUBCLASS_LABEL_FONT_SIZE)
	tree_name.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	section.add_child(tree_name)

	var intrinsic := Label.new()
	intrinsic.text = "Intrinsic: %s" % _intrinsic_description(tree)
	intrinsic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intrinsic.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intrinsic.add_theme_font_size_override("font_size", 11 if BuildState.selected_trees.size() > 1 else INTRINSIC_LABEL_FONT_SIZE)
	section.add_child(intrinsic)

	var memo := {}
	var tiers := {}
	var max_tier := 0
	for talent in tree.talents:
		var tier := _tier_of(talent, memo)
		if not tiers.has(tier):
			tiers[tier] = []
		tiers[tier].append(talent)
		max_tier = maxi(max_tier, tier)

	for tier in range(max_tier + 1):
		if not tiers.has(tier):
			continue
		if tier > 0:
			section.add_child(_build_connector())
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 8 if BuildState.selected_trees.size() > 1 else NODE_ROW_SEPARATION)
		for talent in tiers[tier]:
			row.add_child(_build_node(talent))
		section.add_child(row)


## Prerequisite depth: 0 for no-prereq (base row) talents, otherwise one
## below the deepest prerequisite option.
func _tier_of(talent: Talent, memo: Dictionary) -> int:
	if memo.has(talent):
		return memo[talent]
	var tier := 0
	for group in talent.prerequisites:
		for option in group.options:
			tier = maxi(tier, _tier_of(option, memo) + 1)
	memo[talent] = tier
	return tier


func _build_connector() -> ColorRect:
	var connector := ColorRect.new()
	connector.color = CONNECTOR_COLOR
	connector.custom_minimum_size = Vector2(2, 10 if BuildState.selected_trees.size() > 1 else 14)
	connector.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return connector


## Flat clickable node: cost circles + name. Same Button-with-child-content
## pattern (and the same measured-minimum-size requirement) as
## available_skills_panel.gd's _build_skill_button.
func _build_node(talent: Talent) -> Button:
	var selected: bool = BuildState.selected_talents.has(talent)
	var selectable: bool = PassiveAllocator.can_select_talent(
		BuildState.selected_trees, BuildState.selected_talents, talent, BuildState.earned_talent_points
	)

	var node_row := HBoxContainer.new()
	node_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node_row.alignment = BoxContainer.ALIGNMENT_CENTER
	node_row.add_theme_constant_override("separation", 5 if BuildState.selected_trees.size() > 1 else 8)

	node_row.add_child(TalentCircles.new(talent.cost, selected))

	var name_label := Label.new()
	name_label.text = talent.display_name
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.add_theme_font_size_override("font_size", 10 if BuildState.selected_trees.size() > 1 else 13)
	node_row.add_child(name_label)

	var button := Button.new()
	button.flat = true
	button.set_meta("talent_id", talent.id)
	button.tooltip_text = _talent_tooltip(talent)
	button.pressed.connect(_on_node_pressed.bind(talent))
	button.add_child(node_row)

	var content_min: Vector2 = node_row.get_combined_minimum_size()
	button.custom_minimum_size = content_min + (Vector2(10, 5) if BuildState.selected_trees.size() > 1 else Vector2(16, 8))
	node_row.set_anchors_preset(Control.PRESET_FULL_RECT)

	if not selected and not selectable:
		button.disabled = true
		button.modulate.a = UNAVAILABLE_ALPHA

	return button


func _on_node_pressed(talent: Talent) -> void:
	# Rejected selects/deselects (budget, prereqs, dependents) return false
	# and change nothing; build_changed only fires -- and the tree only
	# redraws -- on success.
	if BuildState.selected_talents.has(talent):
		BuildState.deselect_talent(talent)
	else:
		BuildState.select_talent(talent)


## Everything the tree grants just for being selected, with no talent
## points spent -- the tree's own unlocked_skills plus any innate stat
## modifiers and skill augments.
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
	if BuildState.selected_class != null:
		for skill in BuildState.selected_class.base_skills:
			if skill.id == skill_id:
				return skill.display_name
		for tree in BuildState.selected_class.trees:
			for skill in tree.unlocked_skills:
				if skill.id == skill_id:
					return skill.display_name
			for talent in tree.talents:
				for skill in talent.unlocked_skills:
					if skill.id == skill_id:
						return skill.display_name
	return skill_id


func _talent_tooltip(talent: Talent) -> String:
	var lines: PackedStringArray = []
	lines.append("Cost: %d" % talent.cost)
	for modifier in talent.stat_modifiers:
		lines.append(StatModifierFormatter.format(modifier))
	for skill in talent.unlocked_skills:
		lines.append("Unlocks: %s" % skill.display_name)
	for trigger in talent.triggered_skill_effects:
		var trigger_text := _trigger_description(trigger)
		if trigger_text != "":
			lines.append(trigger_text)
	if lines.size() == 1:
		lines.append("No effect yet")
	return "\n".join(lines)


func _trigger_description(trigger: TriggeredSkillEffect) -> String:
	if trigger == null or trigger.skill == null:
		return ""
	var chance_text := "%d%% chance to trigger %s" % [roundi(trigger.chance * 100.0), trigger.skill.display_name]
	if trigger.source_skill_ids.is_empty():
		return chance_text
	var source_names: PackedStringArray = []
	for source_id in trigger.source_skill_ids:
		source_names.append(_skill_name_for_id(source_id))
	return "%s: %s" % [" & ".join(source_names), chance_text]


## Counts down remaining earned points as talents are taken.
func _refresh_points_label() -> void:
	var remaining: int = BuildState.earned_talent_points - PassiveAllocator.points_spent(BuildState.selected_talents)
	_points_label.text = "%d/%d" % [remaining, BuildState.earned_talent_points]
