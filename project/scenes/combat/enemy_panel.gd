extends PanelContainer
## Combat dashboard panel: shows the current run encounter's stats and owns
## the Fight button's disabled/tooltip state machine, though the button
## itself is displayed elsewhere (see _fight_button below).
##
## Root is PanelContainer -- see character_stats_panel.gd's comment for why.

signal fight_pressed

const CARD_TITLE_FONT_SIZE := 20
const PANEL_MIN_HEIGHT := 190

## Data-derived thresholds for the "why this target pressures certain
## builds" line (P2:R7:T5). Not authored per-monster flavor text -- these
## compare real Monster.armor/poison_resistance values against thresholds
## chosen from the current roster/mechanics reference so new monsters are
## flagged automatically without further authoring. Armor 100 sits above the
## roster's common 0/20 baseline (~35%+ physical damage reduction per
## Current_Mechanics_Reference.md's `armorReduction = 0.75*armor/(armor+100)`
## curve); poison resistance 0.25 matches Balance_Baseline_Report.md's noted
## "25% to 40%" band used to deliberately pressure poison-heavy builds.
const ARMOR_HIGH_THRESHOLD := 100
const POISON_RESIST_HIGH_THRESHOLD := 0.25

var _info_label: RichTextLabel
var _fight_button: Button
var _title_label: Label


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	custom_minimum_size = Vector2(0, PANEL_MIN_HEIGHT)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	_title_label = Label.new()
	_title_label.text = "No Target"
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_title_label.theme_type_variation = &"PanelHeader"
	_title_label.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(_title_label)

	# RichTextLabel (not Label) so the Poison Resist line can carry the
	# semantic poison-text color (P2:R7:T2) without a second label node.
	_info_label = RichTextLabel.new()
	_info_label.bbcode_enabled = true
	_info_label.fit_content = true
	_info_label.scroll_active = false
	content.add_child(_info_label)

	# Not added to `content` -- combat_screen.gd parents this into the
	# centered Fight/Combat-Log row under the combat window instead (P2:R7
	# playtest feedback), matching the Training Room's layout. This panel
	# still owns the button's disabled/tooltip state machine below.
	_fight_button = Button.new()
	_fight_button.text = "FIGHT!"
	_fight_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_fight_button.pressed.connect(func(): fight_pressed.emit())

	BuildState.lock_changed.connect(_update_fight_button)
	BuildState.build_changed.connect(_refresh)
	BuildState.run_state_changed.connect(_on_run_state_changed)
	_update_fight_button()
	_refresh()


func _update_fight_button() -> void:
	var can_fight := BuildState.can_start_current_fight()
	_fight_button.disabled = not can_fight
	if can_fight:
		_fight_button.tooltip_text = ""
	elif BuildState.needs_tavern_map_choice():
		_fight_button.tooltip_text = "Choose the current encounter on the map"
	elif BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_fight_button.tooltip_text = "Accept the contract to continue"
	elif BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE:
		_fight_button.tooltip_text = "Choose the next route step"
	elif BuildState.run_phase != BuildState.RunPhase.PLANNING:
		_fight_button.tooltip_text = "Continue from the current fight result"
	else:
		_fight_button.tooltip_text = "Lock your build to fight"


func _on_run_state_changed() -> void:
	_update_fight_button()
	_refresh()


func monster() -> Monster:
	return BuildState.current_target_monster()


func duration_ms() -> int:
	return BuildState.current_target_duration_ms()


func _refresh() -> void:
	if BuildState.run_phase == BuildState.RunPhase.RUN_ENDED:
		_set_empty_state("Run Complete", "This Adventure has ended.")
		_update_fight_button()
		return
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_set_empty_state("Contract Offer", "Hear out the Contract Window to continue.")
		_update_fight_button()
		return
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE and not BuildState.is_contract_fight_active():
		_set_empty_state("Choose Route", "Choose the next contract route on the map.")
		_update_fight_button()
		return
	if BuildState.needs_tavern_map_choice():
		_set_empty_state("Choose Encounter", "Choose the current Tavern encounter on the map.")
		_update_fight_button()
		return
	var enemy: Monster = BuildState.current_target_monster()
	var duration := BuildState.current_target_duration_ms()
	if enemy == null:
		_set_empty_state("No Target", "Choose the next target to continue.")
		_update_fight_button()
		return
	_title_label.text = enemy.display_name
	var lines: PackedStringArray = []
	lines.append("HP: %d" % enemy.hp)
	lines.append(_required_dps_text(enemy, duration))
	lines.append("Armor: %d" % enemy.armor)
	# Wrapped whole-line, so `.text.contains("Poison Resist: X%")` still
	# finds the exact contiguous substring inside the bbcode tags.
	lines.append("[color=#%s]Poison Resist: %.0f%%[/color]" % [UIColors.TEXT_POISON.to_html(false), enemy.poison_resistance * 100.0])
	lines.append("Window: %.0fs" % (duration / 1000.0))
	lines.append(_reward_preview_text(BuildState.current_reward()))
	lines.append(_build_pressure_text(enemy))
	_info_label.text = "\n".join(lines)
	_update_fight_button()


func _set_empty_state(title: String, body: String) -> void:
	_title_label.text = title
	_info_label.text = body


## HP / fight-window-seconds -- the flat DPS a player needs to sustain to
## kill the target inside its time limit, so it can be eyeballed against the
## resolved DPS shown in character_stats_panel.gd without mental math.
func _required_dps_text(enemy: Monster, window_ms: int) -> String:
	if enemy == null or window_ms <= 0:
		return "Required DPS: NONE"
	var window_s := window_ms / 1000.0
	return "Required DPS: %.1f" % (enemy.hp / window_s)


## Compact known-reward preview, read directly from the encounter/route
## node's authored EncounterReward -- shown before the fight, not only via
## the post-fight reward claim UI. Mirrors the field set combat_screen.gd's
## post-fight `_reward_text()` already reads (gold/talent points/fixed and
## choice gear/generated gear tier/shop unlock), kept as its own compact
## one-line helper here since the pre-fight preview and the post-fight recap
## serve different UI moments.
func _reward_preview_text(reward: EncounterReward) -> String:
	if reward == null:
		return "Reward: none"
	var parts: PackedStringArray = []
	if reward.gold_amount > 0:
		parts.append("%dg" % reward.gold_amount)
	if reward.talent_points > 0:
		parts.append("%d talent point%s" % [
			reward.talent_points,
			"" if reward.talent_points == 1 else "s",
		])
	for gear in reward.fixed_gear_rewards:
		if gear != null:
			parts.append(gear.display_name)
	if reward.gear_choice_rewards.size() > 0:
		var gear_names: PackedStringArray = []
		for gear in reward.gear_choice_rewards:
			if gear != null:
				gear_names.append(gear.display_name)
		if not gear_names.is_empty():
			parts.append("choose %s" % " or ".join(gear_names))
	if reward.generated_gear_choice_count > 0:
		parts.append("%s Gear" % GearGenerator.TIER_NAMES[reward.generated_gear_tier])
	if reward.unlocks_shop:
		parts.append("shop access")
	if parts.is_empty():
		return "Reward: none"
	return "Reward: %s" % ", ".join(parts)


## Short, data-derived "why this target pressures certain builds" line
## (P2:R7:T5) -- compares the monster's real armor/poison_resistance against
## the thresholds above rather than authored per-monster text, so it can't
## drift out of sync with balance data and needs no authoring for new
## monsters. Kept to one line per the task's "avoid walls of text" note.
func _build_pressure_text(enemy: Monster) -> String:
	if enemy == null:
		return "Pressure: NONE"
	var high_armor := enemy.armor >= ARMOR_HIGH_THRESHOLD
	var high_poison_resist := enemy.poison_resistance >= POISON_RESIST_HIGH_THRESHOLD
	if high_armor and high_poison_resist:
		return "Pressure: Heavy armor and poison resistance -- physical and poison builds both struggle."
	elif high_armor:
		return "Pressure: Heavy armor -- physical builds struggle here."
	elif high_poison_resist:
		return "Pressure: High poison resistance -- poison builds struggle here."
	return "Pressure: No notable defensive pressure."
