extends SceneTree
## Focused P2:R7:T7 check for the combat recap helpers in combat_screen.gd:
## required-DPS-vs-actual, biggest hit (with crit flag), physical/poison
## split, crit count, armor-reduction summary (omitted when unused), and
## poison tick/stack summary (omitted when unused). Follows the same
## direct-call-plus-live-scene pattern as enemy_panel_test.gd (P2:R7:T5) and
## deterministic_replay_test.gd (P2:R5:T10): a known deterministic
## CombatResolver.resolve() call feeds the pure recap helpers, and the
## expected values are computed independently in this test (not by calling
## the same aggregation code under test) so the assertions are a real check,
## not a tautology.


var _failed := false


func _initialize() -> void:
	_check_direct_helpers_with_poison_and_armor_reduction()
	_check_direct_helpers_with_no_poison_or_armor_reduction()
	await _check_live_win_recap()
	await _check_live_loss_recap()
	if _failed:
		print("Combat recap check: FAILED")
		quit(1)
	else:
		print("Combat recap check: OK")
		quit()


## A rotation of Poison Strike (poison) + Rending Slash (armor reduction),
## guaranteed crits (crit_chance = 1.0) so biggest-hit's crit flag and the
## crit count are both unambiguous, against a monster with enough HP that
## the fight runs the full window (armor reduction and poison stacking both
## need multiple casts to be interesting).
func _check_direct_helpers_with_poison_and_armor_reduction() -> void:
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var rending_slash: Skill = load("res://data/skills/rending_slash.tres")
	var rotation: Array[Skill] = [poison_strike, rending_slash]

	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 1.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 5.0

	var monster := Monster.new()
	monster.display_name = "Recap Dummy"
	monster.hp = 100000
	monster.armor = 200
	monster.poison_resistance = 0.0

	var duration_ms := 8000
	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, player, monster, duration_ms, 3)
	_require(not result.cast_events.is_empty(), "Expected at least one cast in the known fight.")

	var combat_screen := _instantiate_combat_screen()

	# -- Independently computed expected values, from the same result. --
	var expected_biggest := 0.0
	var expected_biggest_skill := ""
	var expected_biggest_crit := false
	var expected_crit_count := 0
	var expected_physical := 0.0
	var expected_armor_total := 0
	var expected_armor_casts := 0
	for event in result.cast_events:
		expected_physical += event.physical_damage
		if event.physical_damage > expected_biggest:
			expected_biggest = event.physical_damage
			expected_biggest_skill = event.skill.display_name
			expected_biggest_crit = event.is_crit
		if event.is_crit:
			expected_crit_count += 1
		if event.armor_reduction_applied > 0:
			expected_armor_total += event.armor_reduction_applied
			expected_armor_casts += 1
	var expected_poison := 0.0
	var expected_ticks := 0
	var expected_peak_stacks := 0
	for tick in result.tick_events:
		if tick.damage <= 0.0:
			continue
		expected_ticks += 1
		expected_poison += tick.damage
		var stacks_before: int = tick.stacks_remaining + 1
		if stacks_before > expected_peak_stacks:
			expected_peak_stacks = stacks_before
	_require(expected_armor_casts > 0, "Expected Rending Slash to apply armor reduction at least once in this known fight.")
	_require(expected_ticks > 0, "Expected Poison Strike to produce at least one poison tick in this known fight.")

	print("-- Direct helper checks (poison + armor reduction present) --")
	var biggest_text: String = combat_screen._biggest_hit_text(result.cast_events)
	print(biggest_text)
	var expected_crit_note := " (crit)" if expected_biggest_crit else ""
	_require(
		biggest_text == "Biggest Hit: %s for %.1f%s" % [expected_biggest_skill, expected_biggest, expected_crit_note],
		"Expected biggest-hit text to match the independently computed largest cast."
	)
	_require(expected_biggest_crit, "Expected the biggest hit to be a crit with crit_chance = 1.0.")

	var crit_text: String = combat_screen._crit_count_text(result.cast_events)
	print(crit_text)
	_require(crit_text == "Crits: %d" % expected_crit_count, "Expected crit count text to match.")
	_require(expected_crit_count == result.cast_events.size(), "Expected every cast to crit with crit_chance = 1.0.")

	var split_text: String = combat_screen._damage_split_text(result.cast_events, result.tick_events)
	print(split_text)
	var expected_total := expected_physical + expected_poison
	var expected_physical_pct := expected_physical / expected_total * 100.0
	var expected_poison_pct := expected_poison / expected_total * 100.0
	_require(
		split_text == "Physical: %.0f (%.0f%%) / Poison: %.0f (%.0f%%)" % [
			expected_physical, expected_physical_pct, expected_poison, expected_poison_pct
		],
		"Expected damage split text to match the independently computed physical/poison totals."
	)

	var armor_text: String = combat_screen._armor_reduction_summary(result.cast_events)
	print(armor_text)
	_require(
		armor_text == "Armor reduced by %d (%d cast%s)" % [
			expected_armor_total, expected_armor_casts, "" if expected_armor_casts == 1 else "s"
		],
		"Expected armor reduction summary to match the independently computed total."
	)

	var poison_text: String = combat_screen._poison_summary_text(result.tick_events)
	print(poison_text)
	_require(
		poison_text == "Poison: %d ticks, peak %d stacks, %.1f tick damage" % [
			expected_ticks, expected_peak_stacks, expected_poison
		],
		"Expected poison summary to match the independently computed tick/stack totals."
	)

	var required_dps: float = combat_screen._recap_required_dps(monster, duration_ms)
	var expected_required_dps := float(monster.hp) / (float(duration_ms) / 1000.0)
	_require(is_equal_approx(required_dps, expected_required_dps), "Expected required-DPS to be HP / window seconds.")

	var lines: PackedStringArray = combat_screen._build_recap_lines(result, monster)
	var joined := "\n".join(lines)
	print(joined)
	_require(joined.contains("(needed %d)" % monster.hp), "Expected required damage restated next to the actual total.")
	_require(joined.contains("(needed %.1f)" % expected_required_dps), "Expected required DPS restated next to the actual DPS.")
	_require(joined.contains(armor_text), "Expected the recap lines to include the armor reduction summary when it occurred.")
	_require(joined.contains(poison_text), "Expected the recap lines to include the poison summary when it occurred.")

	combat_screen.queue_free()


## A rotation of Stab (pure physical, no poison/armor effects) so the recap
## must omit the armor-reduction and poison-summary lines entirely rather
## than showing a zero/N-A line, per the task's explicit "keep it scannable"
## requirement.
func _check_direct_helpers_with_no_poison_or_armor_reduction() -> void:
	var stab: Skill = load("res://data/skills/stab.tres")
	var rotation: Array[Skill] = [stab]

	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0

	var monster := Monster.new()
	monster.display_name = "No Frills Dummy"
	monster.hp = 100000
	monster.armor = 0
	monster.poison_resistance = 0.0

	var duration_ms := 4000
	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, player, monster, duration_ms, 1)
	_require(not result.cast_events.is_empty(), "Expected at least one cast in the no-frills fight.")

	var combat_screen := _instantiate_combat_screen()
	print("-- Direct helper checks (no poison, no armor reduction) --")
	var armor_text: String = combat_screen._armor_reduction_summary(result.cast_events)
	var poison_text: String = combat_screen._poison_summary_text(result.tick_events)
	print("armor_text: '%s'" % armor_text)
	print("poison_text: '%s'" % poison_text)
	_require(armor_text == "", "Expected an empty armor reduction summary when no cast applied armor reduction.")
	_require(poison_text == "", "Expected an empty poison summary when no poison ticked.")

	var lines: PackedStringArray = combat_screen._build_recap_lines(result, monster)
	var joined := "\n".join(lines)
	print(joined)
	_require(not joined.contains("Armor reduced"), "Expected the recap to omit the armor reduction line entirely, not show a zero line.")
	_require(not joined.contains("ticks"), "Expected the recap to omit the poison summary line entirely, not show a zero line.")
	_require(joined.contains("Crits: 0"), "Expected a crit count line even at zero crits (that line is always shown).")

	combat_screen.queue_free()


## Live end-to-end check: a real winning Tavern fight through the actual
## combat_screen scene shows the full recap (including the new
## required-DPS/crit-count fields) inside the victory banner.
func _check_live_win_recap() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()
	# Quick Cut alone (Thief's tree unlock, no talents needed) casts every
	# 850ms for 12 damage -- roughly 14 casts in the Mouthy Drunk opener's
	# 12s window, ~168 baseline damage before any crits, comfortably above
	# the 150 HP needed regardless of this fight's deterministic crit rolls.
	# Set directly here since this test only needs the resulting fight, not
	# a click-through of the build panels (combat_screen_test.gd already
	# covers that UI path).
	var quick_cut: Skill = load("res://data/skills/quick_cut.tres")
	var win_rotation: Array[Skill] = [quick_cut]
	build_state.rotation = win_rotation

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	build_state.set_locked(true)

	# combat_screen builds its own EnemyPanel instance internally; drive the
	# fight the same way the user does, via the public fight_pressed signal
	# the panel exposes (same pattern combat_screen_test.gd already uses).
	var fight_enemy_panel = combat_screen._enemy_panel
	var monster: Monster = fight_enemy_panel.monster()
	var duration_ms: int = fight_enemy_panel.duration_ms()
	var expected_required_dps := float(monster.hp) / (float(duration_ms) / 1000.0)

	print("-- Live win recap --")
	fight_enemy_panel.fight_pressed.emit()
	await process_frame
	_require(build_state.last_fight_won, "Expected the Mouthy Drunk Tavern fight to be winnable for this recap check.")
	_require(combat_screen._victory_overlay.visible, "Expected the victory overlay to be visible after a win.")
	var recap_text: String = combat_screen._victory_recap_label.text
	print(recap_text)
	_require(recap_text.contains("(needed %d)" % monster.hp), "Expected the live win recap to restate required damage.")
	_require(recap_text.contains("(needed %.1f)" % expected_required_dps), "Expected the live win recap to restate required DPS.")
	_require(recap_text.contains("Crits:"), "Expected the live win recap to include a crit count line.")
	_require(not combat_screen._recap_label.visible, "Expected the loss-path recap label to stay hidden on a win.")

	combat_screen.queue_free()


## Live end-to-end check: a real losing fight (guaranteed by an empty
## rotation, which deals zero damage) shows the recap inline in the main
## combat panel via _recap_label, since the loss path has no overlay of its
## own the way the win path does.
func _check_live_loss_recap() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	# Deliberately leave the rotation empty so the fight is a guaranteed
	# loss (zero damage dealt) without depending on any particular monster
	# HP/window tuning value.
	build_state.rotation.clear()
	build_state.set_locked(true)

	var fight_enemy_panel = combat_screen._enemy_panel
	var monster: Monster = fight_enemy_panel.monster()
	var duration_ms: int = fight_enemy_panel.duration_ms()
	var expected_required_dps := float(monster.hp) / (float(duration_ms) / 1000.0)

	print("-- Live loss recap --")
	fight_enemy_panel.fight_pressed.emit()
	await process_frame
	_require(not build_state.last_fight_won, "Expected an empty rotation to guarantee a loss.")
	_require(combat_screen._recap_label.visible, "Expected the inline recap label to be visible after a loss.")
	var recap_text: String = combat_screen._recap_label.text
	print(recap_text)
	_require(recap_text.contains("Total Damage: 0.0 (needed %d)" % monster.hp), "Expected the loss recap to show zero damage against the required amount.")
	_require(recap_text.contains("(needed %.1f)" % expected_required_dps), "Expected the loss recap to restate required DPS.")
	_require(recap_text.contains("Biggest Hit: none."), "Expected the loss recap to report no hits landed.")
	_require(not recap_text.contains("Armor reduced"), "Expected no armor reduction line for a no-op rotation.")
	_require(not recap_text.contains("ticks"), "Expected no poison summary line for a no-op rotation.")

	combat_screen.queue_free()


func _instantiate_combat_screen() -> Node:
	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	return combat_screen


## Tracks failure via _failed rather than quitting immediately: several
## checks in this file run after an `await process_frame` (the live win/loss
## checks), and an immediate quit(1) here would only request a shutdown that
## the still-in-flight coroutine execution wouldn't actually stop at, while
## _initialize()'s own final bare quit() would then silently overwrite the
## exit code back to 0. Recording the failure and quitting once at the very
## end of _initialize() keeps a real failure from being masked.
func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failed = true
