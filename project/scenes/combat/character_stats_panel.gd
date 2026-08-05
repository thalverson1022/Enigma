extends PanelContainer
## Combat dashboard panel: displays the resolved PlayerStats live. This
## didn't exist as a visible display anywhere before -- the UI mockups
## surfaced it as a real gap, not just a cosmetic one.
##
## Root is PanelContainer (card look via CardStyle) wrapping an inner
## VBoxContainer for content -- matches the card pattern established on
## title/class_select/subclass_select.

const CARD_TITLE_FONT_SIZE := 20

## P2:R10: see talent_panel.gd's `state` comment -- same pattern, same
## default, same untyped declaration reason.
var state = BuildState

var _stats_label: RichTextLabel


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = "Character Stats"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	# RichTextLabel (not Label) so the poison-damage lines can carry the
	# semantic poison-text color (P2:R7:T2) without a second label node.
	_stats_label = RichTextLabel.new()
	_stats_label.bbcode_enabled = true
	_stats_label.fit_content = true
	_stats_label.scroll_active = false
	content.add_child(_stats_label)

	state.build_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	if state.selected_class == null:
		_stats_label.text = ""
		return
	var stats := BuildResolver.resolve_stats(
		state.selected_class, state.selected_trees, state.selected_talents, state.equipped_gear(), state.gold
	)
	# Class-only baseline (no trees/talents/gear) -- the reference point for
	# the "from gear/talents" delta notes below. Cheap: BuildResolver.
	# resolve_stats() is a pure function over data already loaded, so calling
	# it a second time with empty arrays is presentation-only, not new game
	# math (per docs/Conventions.md's UI architecture principle).
	var base_stats := BuildResolver.resolve_stats(state.selected_class, [], [], [])
	# Physical group first, then a blank line, then the poison group.
	# Physical Damage reads as bonus above baseline (x1.08 -> "8%", not
	# "108%" and not "+8%" -- it's a multiplicative modifier, not an additive
	# bonus, so no leading "+" (2026-07-19 fix); Crit Multiplier as a
	# percentage (2.0x -> "200%").
	var lines: PackedStringArray = []
	lines.append(_stat_line(
		"Physical Damage", "%d%%" % roundi((stats.physical_damage_multiplier - 1.0) * 100.0),
		(stats.physical_damage_multiplier - base_stats.physical_damage_multiplier) * 100.0, "%",
		false, null, false
	))
	lines.append(_stat_line(
		"Attack Speed", "%.0f%%" % (stats.attack_speed * 100.0),
		(stats.attack_speed - base_stats.attack_speed) * 100.0, "%"
	))
	lines.append(_stat_line(
		"Crit Chance", "%.0f%%" % (stats.crit_chance * 100.0),
		(stats.crit_chance - base_stats.crit_chance) * 100.0, "%"
	))
	lines.append(_stat_line(
		"Crit Multiplier", "%.0f%%" % (stats.crit_multiplier * 100.0),
		(stats.crit_multiplier - base_stats.crit_multiplier) * 100.0, "%"
	))
	lines.append(_stat_line(
		"Bonus Armor Shred", "-%d armor" % stats.bonus_armor_reduction,
		stats.bonus_armor_reduction - base_stats.bonus_armor_reduction, ""
	))
	# Bonus Physical Damage (P2:R9:T2, Bandit Blade's gold-scaling) and
	# Min-Cast Proc Chance (P2:R9:T3, Bejeweled Push Dagger) were added to
	# PlayerStats in P2:R9 but never surfaced here until this panel was
	# reused for P2:R10 Practice Room's practice-gold control, which needs
	# to show its effect live.
	lines.append(_stat_line(
		"Bonus Physical Damage", "%+.0f" % stats.bonus_physical_damage,
		stats.bonus_physical_damage - base_stats.bonus_physical_damage, ""
	))
	lines.append(_stat_line(
		"Min-Cast Proc Chance", "%.0f%%" % (stats.min_cast_time_proc_chance * 100.0),
		(stats.min_cast_time_proc_chance - base_stats.min_cast_time_proc_chance) * 100.0, "%"
	))
	lines.append("")
	# Poison lines are wrapped whole (not partial-line), so any test
	# checking `.text.contains("Poison Damage: X/tick")` still finds that
	# exact contiguous substring inside the bbcode tags.
	lines.append(_stat_line(
		"Poison Damage", "%.1f/tick" % stats.poison_damage_per_tick,
		stats.poison_damage_per_tick - base_stats.poison_damage_per_tick, "", true, UIColors.TEXT_POISON
	))
	lines.append(_stat_line(
		"Bonus Poison Stacks", "%+d" % stats.bonus_poison_stacks,
		stats.bonus_poison_stacks - base_stats.bonus_poison_stacks, "", false, UIColors.TEXT_POISON
	))
	_stats_label.text = "\n".join(lines)


## Renders one "Label: value" stat line, optionally color-wrapped (poison
## lines), and -- when the resolved value differs from the class-only
## baseline -- wraps the whole line in a BBCode [hint=...] tag so the
## "from gear/talents" delta note shows as a hover tooltip instead of always
## -visible inline text (P2:R7 playtest-feedback pass, 2026-07-18, revises
## T4: the delta note "is not relevant to gameplay" as constant on-screen
## text per that feedback). _stat_delta_text() itself is unchanged and still
## computes the same delta string; only where it's placed changed.
func _stat_line(label: String, value_text: String, delta: float, suffix: String, one_decimal: bool = false, color: Variant = null, show_plus_sign: bool = true) -> String:
	var text := "%s: %s" % [label, value_text]
	if color != null:
		text = "[color=#%s]%s[/color]" % [color.to_html(false), text]
	var delta_text := _stat_delta_text(delta, suffix, one_decimal, show_plus_sign)
	if delta_text == "":
		return text
	var hint := delta_text.strip_edges().trim_prefix("(").trim_suffix(")")
	return "[hint=%s]%s[/hint]" % [hint, text]


## " (+N from gear/talents)" delta description for a stat, without duplicating
## any combat math -- `delta` is always computed by the caller from two
## already-resolved PlayerStats (BuildResolver.resolve_stats() with vs.
## without trees/talents/gear), never re-derived here. Empty string when
## there's nothing to explain (delta is ~0, i.e. class base already accounts
## for it). Consumed by _stat_line() as the content of a hover-tooltip hint,
## not as always-visible text (see _stat_line()'s comment).
func _stat_delta_text(delta: float, suffix: String, one_decimal: bool = false, show_plus_sign: bool = true) -> String:
	if absf(delta) < 0.05:
		return ""
	var sign := "+" if (delta > 0 and show_plus_sign) else ""
	if one_decimal:
		return " (%s%.1f%s from gear/talents)" % [sign, delta, suffix]
	return " (%s%d%s from gear/talents)" % [sign, roundi(delta), suffix]
