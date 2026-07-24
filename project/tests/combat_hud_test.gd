extends SceneTree
## Focused check for the enemy status HUD added to the black Combat panel
## (user-requested combat-HUD addition to the P2:R7 pass, 2026-07-18):
## pre-fight the HUD shows the current Monster at full HP/base armor/base
## poison resist/zero stacks; post-fight it reflects the resolved
## CombatResult (empty bar on a win, remaining HP on a loss, final armor/
## resist after any shred, peak poison stacks); and it resets to the
## pre-fight state at new-fight transitions (retry). Follows
## combat_recap_test.gd's direct-call-plus-live-scene pattern, including its
## fixed _require()/_failed idiom (record failures, quit once at the end,
## await the live checks) so an awaited check can't be masked by an early
## quit().


var _failed := false


func _initialize() -> void:
	_check_post_fight_helpers_against_known_fight()
	await _check_hidden_before_map_choice()
	await _check_live_pre_fight_and_win()
	await _check_live_loss_and_retry_reset()
	if _failed:
		print("Combat HUD check: FAILED")
		quit(1)
	else:
		print("Combat HUD check: OK")
		quit()


## Deterministic CombatResolver.resolve() fight exercising every mechanic
## the HUD derives (armor reduction, poison resistance reduction, poison
## stacks) against a monster too big to kill, so the post-fight helpers'
## outputs can be compared against independently computed values (not by
## re-calling the code under test).
func _check_post_fight_helpers_against_known_fight() -> void:
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var rending_slash: Skill = load("res://data/skills/rending_slash.tres")
	var beguiling_strike: Skill = load("res://data/skills/beguiling_strike.tres")
	var rotation: Array[Skill] = [poison_strike, rending_slash, beguiling_strike]

	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 1.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 5.0

	var monster := Monster.new()
	monster.display_name = "HUD Dummy"
	monster.hp = 100000
	monster.armor = 200
	monster.poison_resistance = 0.4

	var duration_ms := 9000
	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, player, monster, duration_ms, 3)
	_require(not result.cast_events.is_empty(), "Expected at least one cast in the known fight.")
	_require(not result.is_win, "Expected the known fight to be a loss (100000 HP).")

	# -- Independently computed expected values, from the same result. --
	var expected_armor_reduction := 0
	var expected_resist := monster.poison_resistance
	for event in result.cast_events:
		expected_armor_reduction += event.armor_reduction_applied
		if event.poison_resistance_reduction_applied > 0.0:
			expected_resist *= 1.0 - event.poison_resistance_reduction_applied
	var expected_peak_stacks := 0
	for tick in result.tick_events:
		if tick.damage <= 0.0:
			continue
		var stacks_before: int = tick.stacks_remaining + 1
		if stacks_before > expected_peak_stacks:
			expected_peak_stacks = stacks_before
	_require(expected_armor_reduction > 0, "Expected Rending Slash to shred armor at least once in this known fight.")
	_require(expected_resist < monster.poison_resistance, "Expected Beguiling Strike to reduce poison resistance in this known fight.")
	_require(expected_peak_stacks > 0, "Expected Poison Strike to stack poison in this known fight.")

	var combat_screen := _instantiate_combat_screen()
	print("-- Post-fight helper checks (known deterministic fight) --")

	var remaining: float = combat_screen._hud_post_fight_hp(result, monster)
	print("remaining HP: %.1f (total damage %.1f)" % [remaining, result.total_damage])
	_require(
		is_equal_approx(remaining, float(monster.hp) - result.total_damage),
		"Expected post-fight HP to be monster HP minus total damage dealt on a loss."
	)
	_require(remaining > 0.0, "Expected positive remaining HP for a losing fight.")

	var final_armor: int = combat_screen._hud_final_armor(result, monster)
	print("final armor: %d (base %d, reduced %d)" % [final_armor, monster.armor, expected_armor_reduction])
	_require(
		final_armor == monster.armor - expected_armor_reduction,
		"Expected final armor to be base armor minus every applied reduction."
	)

	var final_resist: float = combat_screen._hud_final_poison_resist(result, monster)
	print("final poison resist: %.3f (base %.3f)" % [final_resist, monster.poison_resistance])
	_require(
		is_equal_approx(final_resist, expected_resist),
		"Expected final poison resist to apply each recorded reduction multiplicatively."
	)

	var peak_stacks: int = combat_screen._hud_peak_poison_stacks(result.tick_events)
	print("peak poison stacks: %d" % peak_stacks)
	_require(peak_stacks == expected_peak_stacks, "Expected peak stacks to match the independently computed value.")

	# A winning result must clamp to exactly zero remaining HP.
	var small_monster := Monster.new()
	small_monster.display_name = "Small Fry"
	small_monster.hp = 10
	_require(
		is_equal_approx(combat_screen._hud_post_fight_hp(result, small_monster), 0.0),
		"Expected post-fight HP to clamp to zero when total damage exceeds monster HP."
	)

	combat_screen.queue_free()


## Before the Tavern map choice is made there is no fightable target, so the
## HUD must stay hidden (mirroring enemy_panel.gd's own empty-state gating).
func _check_hidden_before_map_choice() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	print("-- HUD hidden before Tavern map choice --")
	_require(build_state.needs_tavern_map_choice(), "Expected a fresh run to need the Tavern map choice.")
	_require(not combat_screen._enemy_hud.visible, "Expected the enemy HUD to stay hidden before a target is chosen.")
	combat_screen.queue_free()


## Live end-to-end: pre-fight display shows the chosen Tavern opener at full
## HP/base stats; a real winning fight (Quick Cut vs. Mouthy Drunk, same
## known-win rotation combat_recap_test.gd uses) empties the bar to exactly
## zero and stays chip-free (Quick Cut applies no poison/armor/resist
## effects).
func _check_live_pre_fight_and_win() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()
	var quick_cut: Skill = load("res://data/skills/quick_cut.tres")
	var win_rotation: Array[Skill] = [quick_cut]
	build_state.rotation = win_rotation

	var combat_screen := _instantiate_combat_screen()
	await process_frame

	var fight_enemy_panel = combat_screen._enemy_panel
	var monster: Monster = fight_enemy_panel.monster()

	print("-- Live pre-fight HUD --")
	_require(combat_screen._enemy_hud.visible, "Expected the enemy HUD visible once a target is chosen.")
	print("name: %s | %s" % [combat_screen._hud_name_label.text, combat_screen._hud_hp_text_label.text])
	print(combat_screen._hud_info_label.text)
	_require(combat_screen._hud_name_label.text == monster.display_name, "Expected the HUD to name the current target.")
	_require(combat_screen._hud_hp_text_label.text == "HP %d/%d" % [monster.hp, monster.hp], "Expected full HP text pre-fight.")
	_require(is_equal_approx(combat_screen._hud_health_bar.value, float(monster.hp)), "Expected a full health bar pre-fight.")
	_require(is_equal_approx(combat_screen._hud_health_bar.max_value, float(monster.hp)), "Expected the health bar max to be monster HP.")
	_require(
		combat_screen._hud_info_label.text == "Armor: %d | Resist: %.0f%%" % [monster.armor, monster.poison_resistance * 100.0],
		"Expected the pre-fight info line to show base armor/resist."
	)
	_require(combat_screen._hud_status_row.get_child_count() == 0, "Expected no status chips pre-fight.")

	print("-- Live win HUD --")
	build_state.set_locked(true)
	fight_enemy_panel.fight_pressed.emit()
	await process_frame
	_require(build_state.last_fight_won, "Expected the Quick Cut Mouthy Drunk fight to be a win.")
	print("post-win: %s | bar %.1f/%.1f" % [combat_screen._hud_hp_text_label.text, combat_screen._hud_health_bar.value, combat_screen._hud_health_bar.max_value])
	_require(combat_screen._enemy_hud.visible, "Expected the HUD to stay visible with the victory banner up.")
	_require(combat_screen._hud_result != null, "Expected the HUD to hold the resolved fight after a win.")
	_require(is_equal_approx(combat_screen._hud_health_bar.value, 0.0), "Expected an empty health bar after a win.")
	_require(combat_screen._hud_hp_text_label.text == "HP 0/%d" % monster.hp, "Expected zero HP text after a win.")
	_require(combat_screen._hud_status_row.get_child_count() == 0, "Expected no status chips for a pure-physical rotation.")

	combat_screen.queue_free()


## Live end-to-end: a guaranteed loss (empty rotation, zero damage) leaves
## remaining HP consistent with monster HP minus the result's total damage,
## and pressing the real Retry button resets the HUD back to the pre-fight
## display.
func _check_live_loss_and_retry_reset() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	build_state.rotation.clear()
	build_state.set_locked(true)

	var fight_enemy_panel = combat_screen._enemy_panel
	var monster: Monster = fight_enemy_panel.monster()

	print("-- Live loss HUD --")
	fight_enemy_panel.fight_pressed.emit()
	await process_frame
	_require(not build_state.last_fight_won, "Expected an empty rotation to guarantee a loss.")
	_require(combat_screen._enemy_hud.visible, "Expected the HUD visible after a loss.")
	_require(combat_screen._hud_result != null, "Expected the HUD to hold the resolved fight after a loss.")
	var expected_remaining: float = float(monster.hp) - combat_screen._hud_result.total_damage
	print("post-loss: %s | bar %.1f/%.1f" % [combat_screen._hud_hp_text_label.text, combat_screen._hud_health_bar.value, combat_screen._hud_health_bar.max_value])
	_require(expected_remaining > 0.0, "Expected positive remaining HP on the loss.")
	_require(
		is_equal_approx(combat_screen._hud_health_bar.value, expected_remaining),
		"Expected the post-loss bar to read monster HP minus total damage dealt."
	)

	print("-- Retry resets the HUD --")
	_require(combat_screen._retry_button.visible, "Expected the retry button after a first Tavern loss.")
	combat_screen._retry_button.pressed.emit()
	await process_frame
	_require(combat_screen._hud_result == null, "Expected the stored fight result cleared on retry.")
	# RETRY BUG FIX (combat-playback adjustment round 2 + retry bug,
	# 2026-07-19): retry_current_encounter() now restores
	# tavern_map_choice_made directly, since retrying is fighting the exact
	# same target, not making a new map choice -- previously start_fight()'s
	# earlier clear of that flag was never undone, so needs_tavern_map_
	# choice() incorrectly stayed true after a retry and the player had to
	# rediscover that they needed to reopen the Map overlay and re-click the
	# same already-only encounter before the HUD/FIGHT! button worked again.
	# This block used to assert that stale (buggy) gating; it now asserts the
	# fixed, immediately-fightable-again behavior.
	_require(not build_state.needs_tavern_map_choice(), "Expected retry to make the same Tavern encounter immediately available again, with no map re-choice required.")
	_require(combat_screen._enemy_hud.visible, "Expected the HUD visible again immediately after retry, with no map re-choice required.")
	_require(combat_screen._hud_hp_text_label.text == "HP %d/%d" % [monster.hp, monster.hp], "Expected full HP text again after retry.")
	_require(is_equal_approx(combat_screen._hud_health_bar.value, float(monster.hp)), "Expected a full health bar again after retry.")
	_require(combat_screen._hud_status_row.get_child_count() == 0, "Expected no status chips after the retry reset.")

	combat_screen.queue_free()


func _instantiate_combat_screen() -> Node:
	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	return combat_screen


## Same fixed idiom as combat_recap_test.gd: record failures instead of
## quitting immediately, since several checks run after an awaited frame and
## an early quit(1) would be overwritten by _initialize()'s final quit().
func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failed = true
