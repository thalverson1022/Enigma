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
## shown, see SPEED_LABEL_BY_SKILL_ID below).
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

## Flavor speed labels shown in the skill tooltip instead of the exact
## base_execution_ms/min_execution_ms numbers (P2:R7 playtest-feedback,
## 2026-07-19) -- exact cast-time figures are meant to be discovered from the
## combat log's real timestamps, not read off the tooltip. Fixed content, not
## derived from a formula, so it would ideally live as a field on the Skill
## resource per docs/Conventions.md's data-driven-content preference -- kept
## as a lookup table here instead because this task's working agreement
## scopes items 1-3 away from project/scripts/resources/ (schema changes),
## which a new Skill.speed_label export would have touched. Keyed by
## skill.id (data/skills/*.tres's own id, e.g. "skill.stab") rather than
## display_name so a future rename doesn't silently break the mapping.
const SPEED_LABEL_BY_SKILL_ID := {
	"skill.stab": "Speed: Normal",
	"skill.heavy_slash": "Speed: Slow",
	"skill.quick_cut": "Speed: Fast",
	"skill.rending_thrust": "Speed: Normal", # display_name "Rending Slash"
	"skill.venom_jab": "Speed: Fast",
	"skill.poison_strike": "Speed: Normal",
	"skill.toxic_flurry": "Speed: Normal", # display_name "Beguiling Strike"
	"skill.killers_mark": "Speed: Normal", # display_name "Death Strike"
}

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
	var label_row := HBoxContainer.new()
	label_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_row.alignment = BoxContainer.ALIGNMENT_CENTER
	label_row.add_theme_constant_override("separation", 6)

	if skill.icon != null:
		var icon := TextureRect.new()
		icon.name = "SkillIcon"
		icon.texture = skill.icon
		icon.custom_minimum_size = SKILL_ICON_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		label_row.add_child(icon)
	else:
		var first_letter := Label.new()
		first_letter.text = skill.display_name.substr(0, 1)
		first_letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		first_letter.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
		label_row.add_child(first_letter)

	var rest := Label.new()
	rest.text = skill.display_name if skill.icon != null else skill.display_name.substr(1)
	rest.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_row.add_child(rest)

	var button := Button.new()
	button.pressed.connect(_on_skill_pressed.bind(skill))
	button.tooltip_text = ("Macro is full (%d max)" % BuildResolver.MAX_ROTATION_SIZE) if at_cap else _tooltip_for(skill)
	button.disabled = state.build_locked or at_cap
	button.add_child(label_row)

	var content_min: Vector2 = label_row.get_combined_minimum_size()
	button.custom_minimum_size = content_min + Vector2(24, 12)
	label_row.set_anchors_preset(Control.PRESET_FULL_RECT)

	return button


## Shows a flavor speed label (SPEED_LABEL_BY_SKILL_ID above) instead of the
## exact base_execution_ms/min_execution_ms numbers (P2:R7 playtest-feedback,
## 2026-07-19) -- working out real cast timing is meant to be part of the
## game's discovery loop, gleaned from the combat log's real timestamps, not
## read straight off the tooltip. Falls back to a generic label for any
## skill without an authored mapping entry (e.g. the placeholder skills).
func _tooltip_for(skill: Skill) -> String:
	var lines: PackedStringArray = []
	var speed_text: String = SPEED_LABEL_BY_SKILL_ID.get(skill.id, "Speed: Normal")
	lines.append(speed_text)
	lines.append(_skill_effect_summary(skill))
	return "\n".join(lines)


## Short, comma-joined effect summary derived straight from the skill's own
## SkillEffect resources -- shown in the hover tooltip (see _tooltip_for())
## only, not as an always-visible caption (removed in the P2:R7
## playtest-feedback pass, see this file's header comment). Never hardcodes
## numbers -- every value is read off `effect`.
func _skill_effect_summary(skill: Skill) -> String:
	var parts: PackedStringArray = []
	var has_poison_effect := false
	for effect in skill.effects:
		if effect is PhysicalDamageEffect:
			parts.append("%.0f physical dmg" % effect.amount)
		elif effect is PoisonDamageEffect:
			has_poison_effect = true
			parts.append("+%d poison stack%s" % [effect.stacks_applied, "" if effect.stacks_applied == 1 else "s"])
		elif effect is ArmorReductionEffect:
			parts.append("-%d armor" % effect.amount)
		elif effect is PoisonResistanceReductionEffect:
			parts.append("-%d%% poison resist" % roundi(effect.reduction_fraction * 100.0))
		elif effect is StackScalingPhysicalDamageEffect:
			parts.append("+%.0f dmg/poison stack" % effect.damage_per_stack)
	if skill.poison_stacks_applied > 0 and not has_poison_effect:
		parts.append("+%d poison stack%s" % [
			skill.poison_stacks_applied,
			"" if skill.poison_stacks_applied == 1 else "s",
		])
	if parts.is_empty():
		return "No effect"
	return ", ".join(parts)


func _on_skill_pressed(skill: Skill) -> void:
	if state.build_locked:
		return
	var rotation: Array[Skill] = state.rotation.duplicate()
	rotation.append(skill)
	state.set_rotation(rotation)
