extends PanelContainer
## Combat dashboard panel: shows the current run encounter's stats and owns
## the Fight button's disabled/tooltip state machine, though the button
## itself is displayed elsewhere (see _fight_button below).
##
## Root is PanelContainer -- see character_stats_panel.gd's comment for why.

signal fight_pressed

const CARD_TITLE_FONT_SIZE := 20
const PANEL_MIN_HEIGHT := 230
const FIGHT_ICON := preload("res://assets/ui/icons/fight.png")

## Data-derived thresholds for the "why this target pressures certain
## builds" line (P2:R7:T5). Not authored per-monster flavor text -- these
## compare real Monster.armor/poison_resistance values against thresholds
## chosen from the current roster/mechanics reference so new monsters are
## flagged automatically without further authoring. Armor 100 sits above the
## roster's common 0/20 baseline (~35%+ physical damage reduction per
## Current_Mechanics_Reference.md's `armorReduction = 0.75*armor/(armor+100)`
## curve); resistance 0.25 matches Balance_Baseline_Report.md's noted
## "25% to 40%" band used to deliberately pressure magical builds.
const ARMOR_HIGH_THRESHOLD := 100
const POISON_RESIST_HIGH_THRESHOLD := 0.25

var _info_label: RichTextLabel
var _fight_button: Button
var _title_label: Label
var _presented_monster_override: Monster = null
var _presented_duration_override_ms := 0


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

	# RichTextLabel (not Label) so the Resist line can carry semantic color
	# without a second label node.
	_info_label = RichTextLabel.new()
	_info_label.bbcode_enabled = true
	_info_label.fit_content = true
	_info_label.scroll_active = false
	_info_label.add_theme_font_size_override("normal_font_size", 17)
	content.add_child(_info_label)

	# Not added to `content` -- combat_screen.gd parents this into the
	# centered Fight/Combat-Log row under the combat window instead (P2:R7
	# playtest feedback), matching the Practice Room's layout. This panel
	# still owns the button's disabled/tooltip state machine below.
	_fight_button = Button.new()
	_fight_button.text = "FIGHT!"
	CardStyle.configure_icon_button(_fight_button, FIGHT_ICON)
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


## Public accessor so combat_screen.gd can reparent the button into its
## centered Fight/Combat-Log row without reaching into the private
## `_fight_button` field directly. This panel still owns the button's
## disabled/tooltip state machine (see _update_fight_button()).
func fight_button() -> Button:
	return _fight_button


func show_presented_target(monster: Monster, duration_ms: int) -> void:
	_presented_monster_override = monster
	_presented_duration_override_ms = duration_ms
	_refresh()


func clear_presented_target() -> void:
	_presented_monster_override = null
	_presented_duration_override_ms = 0
	_refresh()


func _refresh() -> void:
	if _presented_monster_override != null:
		_set_enemy_state(_presented_monster_override, _presented_duration_override_ms)
		_update_fight_button()
		return
	if BuildState.run_phase == BuildState.RunPhase.RUN_ENDED:
		var ended_enemy: Monster = _terminal_target_monster()
		if ended_enemy != null:
			_set_enemy_state(ended_enemy, _terminal_target_duration_ms())
		else:
			_set_empty_state("No Target", "No enemy target is available.")
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
	_set_enemy_state(enemy, duration)
	_update_fight_button()


func _terminal_target_monster() -> Monster:
	if BuildState.active_contract != null and BuildState.current_route_node != null and BuildState.current_route_node.monster != null:
		return BuildState.current_route_node.monster
	return BuildState.current_target_monster()


func _terminal_target_duration_ms() -> int:
	if BuildState.active_contract != null and BuildState.current_route_node != null and BuildState.current_route_node.monster != null:
		return BuildState.current_route_node.duration_ms
	return BuildState.current_target_duration_ms()


func _set_enemy_state(enemy: Monster, duration: int) -> void:
	_title_label.text = enemy.display_name
	_info_label.text = _enemy_combat_info_text(enemy, duration)


func _enemy_combat_info_text(enemy: Monster, duration: int) -> String:
	var lines: PackedStringArray = []
	lines.append("HP: %d" % enemy.hp)
	lines.append("Fight Window: %.0fs" % (duration / 1000.0))
	lines.append("")
	lines.append("Armor: %d" % enemy.armor)
	var physical_rows := _physical_defense_rows(enemy)
	if not physical_rows.is_empty():
		lines.append_array(physical_rows)
	lines.append("")
	lines.append("[color=#%s]Resistance: %.0f%%[/color]" % [UIColors.TEXT_MAGIC.to_html(false), enemy.poison_resistance * 100.0])
	var magical_rows := _magical_defense_rows(enemy)
	if not magical_rows.is_empty():
		lines.append_array(magical_rows)
	var control_rows := _control_mechanic_rows(enemy)
	if not control_rows.is_empty():
		lines.append("")
		lines.append_array(control_rows)
	return "\n".join(lines)


func _physical_defense_rows(enemy: Monster) -> PackedStringArray:
	var lines := PackedStringArray()
	if not is_zero_approx(enemy.block):
		lines.append("Block: %s" % _stat_number(enemy.block))
	if not is_zero_approx(enemy.dodge_chance):
		lines.append("Dodge: %.0f%%" % (enemy.dodge_chance * 100.0))
	if not is_zero_approx(enemy.crit_negation):
		lines.append("Crit Negation: %.0f%%" % (enemy.crit_negation * 100.0))
	if not is_zero_approx(enemy.slow):
		lines.append("Slow: %.0f%%" % (enemy.slow * 100.0))
	return lines


func _magical_defense_rows(enemy: Monster) -> PackedStringArray:
	var lines := PackedStringArray()
	if not is_zero_approx(enemy.absorb):
		lines.append("Absorb: %s" % _stat_number(enemy.absorb))
	if not is_zero_approx(enemy.suppress):
		lines.append("Suppress: %.0f%%" % (enemy.suppress * 100.0))
	return lines


func _control_mechanic_rows(enemy: Monster) -> PackedStringArray:
	var lines := PackedStringArray()
	if enemy.cleanse_threshold > 0:
		lines.append("Cleanse: %d hits" % enemy.cleanse_threshold)
	if enemy.stun_duration_ms > 0:
		lines.append("Stun: %.0f%%/%ss" % [
			CombatResolver.STUN_TRIGGER_HIT_PERCENT * 100.0,
			_seconds_number(enemy.stun_duration_ms),
		])
	if enemy.interrupt_skip_count > 0:
		lines.append("Interrupt: %d / %d" % [
			CombatResolver.INTERRUPT_REPEAT_THRESHOLD,
			enemy.interrupt_skip_count,
		])
	return lines


func _stat_number(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))
	return "%.1f" % value


func _seconds_number(duration_ms: int) -> String:
	var seconds := float(duration_ms) / 1000.0
	if is_equal_approx(seconds, roundf(seconds)):
		return str(int(roundf(seconds)))
	return "%.1f" % seconds


func _set_empty_state(title: String, body: String) -> void:
	_title_label.text = title
	_info_label.text = body


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
		return "Pressure: Heavy armor and resistance -- physical and magical builds both struggle."
	elif high_armor:
		return "Pressure: Heavy armor -- physical builds struggle here."
	elif high_poison_resist:
		return "Pressure: High resistance -- magical builds struggle here."
	return "Pressure: No notable defensive pressure."
