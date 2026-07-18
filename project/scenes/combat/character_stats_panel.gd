extends PanelContainer
## Combat dashboard panel: displays the resolved PlayerStats live. This
## didn't exist as a visible display anywhere before -- the UI mockups
## surfaced it as a real gap, not just a cosmetic one.
##
## Root is PanelContainer (card look via CardStyle) wrapping an inner
## VBoxContainer for content -- matches the card pattern established on
## title/class_select/subclass_select.

const CARD_TITLE_FONT_SIZE := 20

var _stats_label: Label


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = "Character Stats"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_stats_label = Label.new()
	content.add_child(_stats_label)

	BuildState.build_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	if BuildState.selected_class == null:
		_stats_label.text = ""
		return
	var stats := BuildResolver.resolve_stats(
		BuildState.selected_class, BuildState.selected_trees, BuildState.selected_talents, BuildState.equipped_gear()
	)
	# Physical group first, then a blank line, then the poison group.
	# Physical Damage reads as bonus above baseline (x1.08 -> "+8%", not
	# "108%"); Crit Multiplier as a percentage (2.0x -> "200%").
	var lines: PackedStringArray = []
	lines.append("Physical Damage: %+d%%" % roundi((stats.physical_damage_multiplier - 1.0) * 100.0))
	lines.append("Attack Speed: %.0f%%" % (stats.attack_speed * 100.0))
	lines.append("Crit Chance: %.0f%%" % (stats.crit_chance * 100.0))
	lines.append("Crit Multiplier: %.0f%%" % (stats.crit_multiplier * 100.0))
	lines.append("Bonus Armor Shred: -%d armor" % stats.bonus_armor_reduction)
	lines.append("")
	lines.append("Poison Damage: %.1f/tick" % stats.poison_damage_per_tick)
	lines.append("Bonus Poison Stacks: %+d" % stats.bonus_poison_stacks)
	_stats_label.text = "\n".join(lines)
