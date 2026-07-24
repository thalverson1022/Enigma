extends SceneTree
## Focused checks for the real-time combat playback addition (P2:R7,
## user-requested): the CombatPlayback controller's deterministic timeline
## (events fired by time T, speed scaling, skip, single finished callback,
## HP-remaining bookkeeping, full-window playback on both a win and a loss
## -- no more win truncation, adjustment round 1, 2026-07-19), and
## a live combat_screen.tscn pass with instant_playback disabled proving the
## outcome UI stays hidden mid-playback, state/autosave still mutate
## instantly, and skip reveals the deferred outcome. Follows
## combat_recap_test.gd's direct-call-plus-live-scene pattern and its fixed
## _require()/_failed idiom (single quit at the end so a failure can't be
## masked by an early quit()).


var _failed := false


func _initialize() -> void:
	_check_controller_timeline_and_speed()
	_check_controller_skip_and_single_finish()
	_check_controller_event_ordering()
	_check_controller_win_truncation()
	await _check_live_playback_win()
	await _check_live_playback_loss()
	await _check_playback_speed_persists()
	if _failed:
		print("Combat playback check: FAILED")
		quit(1)
	else:
		print("Combat playback check: OK")
		quit()


## The same known deterministic losing fight combat_recap_test.gd uses:
## Poison Strike + Rending Slash, guaranteed crits, 100000 HP so the fight
## runs the full 8s window and both casts and poison ticks populate the
## timeline.
func _known_loss_result() -> CombatResolver.CombatResult:
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var rending_slash: Skill = load("res://data/skills/rending_slash.tres")
	var rotation: Array[Skill] = [poison_strike, rending_slash]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 1.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 5.0
	var monster := Monster.new()
	monster.display_name = "Playback Dummy"
	monster.hp = 100000
	monster.armor = 200
	monster.poison_resistance = 0.0
	return CombatResolver.resolve(rotation, player, monster, 8000, 3)


## Independently computed expected fired-event count/damage at time T,
## straight off the result arrays (not via the controller under test).
func _expected_fired_at(result: CombatResolver.CombatResult, time_ms: int) -> Dictionary:
	var count := 0
	var damage := 0.0
	for event in result.cast_events:
		if event.time_ms <= time_ms:
			count += 1
			damage += event.physical_damage
	for tick in result.tick_events:
		if tick.time_ms <= time_ms:
			count += 1
			damage += tick.damage
	return {"count": count, "damage": damage}


func _check_controller_timeline_and_speed() -> void:
	print("-- Controller timeline: events fired by time T, at 1x and scaled speeds --")
	var result := _known_loss_result()
	_require(not result.cast_events.is_empty(), "Expected casts in the known fight.")
	_require(not result.tick_events.is_empty(), "Expected poison ticks in the known fight.")
	var total_events := result.cast_events.size() + result.tick_events.size()

	# 1x: advance in uneven chunks and verify the fired set at several Ts.
	var playback := CombatPlayback.new()
	playback.start(result)
	_require(playback.total_events() == total_events, "Expected the merged timeline to hold every cast and tick.")
	_require(playback.window_ms() == 8000 and playback.timeline_end_ms() == 8000, "Expected a loss timeline to span the full window.")
	var checkpoints: Array = [0.75, 1.5, 3.2, 5.0, 8.0]
	var advanced := 0.0
	for checkpoint in checkpoints:
		playback.advance(checkpoint - advanced)
		advanced = checkpoint
		var expected: Dictionary = _expected_fired_at(result, int(checkpoint * 1000.0))
		_require(
			playback.events_fired() == expected["count"],
			"Expected %d events fired by %.2fs at 1x, got %d." % [expected["count"], checkpoint, playback.events_fired()]
		)
		_require(
			is_equal_approx(playback.damage_dealt(), expected["damage"]),
			"Expected damage dealt by %.2fs to match the independent sum." % checkpoint
		)
		# HP remaining at time T = monster HP minus the fired damage.
		var hp_remaining := 100000.0 - playback.damage_dealt()
		_require(is_equal_approx(hp_remaining, 100000.0 - expected["damage"]), "Expected HP-remaining-at-T to match.")
	_require(playback.is_finished(), "Expected the timeline to finish once advanced to the window end.")
	_require(playback.events_fired() == total_events, "Expected every event fired by the window end.")
	_require(100000.0 - playback.damage_dealt() > 0.0, "Expected the loss timeline to end with positive HP remaining.")

	# Scaled speed: 4x for 1 real second == everything through 4000ms.
	var fast := CombatPlayback.new()
	fast.start(result)
	fast.speed = 4.0
	fast.advance(1.0)
	var expected_4s: Dictionary = _expected_fired_at(result, 4000)
	_require(
		fast.events_fired() == expected_4s["count"],
		"Expected 4x speed for 1s to fire exactly the events through 4000ms."
	)
	_require(is_equal_approx(fast.elapsed_ms(), 4000.0), "Expected 4x speed for 1s to land the clock on 4000ms.")


func _check_controller_skip_and_single_finish() -> void:
	print("-- Controller skip fires everything; finished fires exactly once --")
	var result := _known_loss_result()
	var finish_count := [0]
	var playback := CombatPlayback.new()
	playback.finished_callback = func(): finish_count[0] += 1
	playback.start(result)
	playback.advance(1.0)
	_require(finish_count[0] == 0, "Expected no finish mid-timeline.")
	playback.skip()
	_require(playback.is_finished(), "Expected skip to finish the playback.")
	_require(playback.events_fired() == playback.total_events(), "Expected skip to fire every remaining event.")
	_require(is_equal_approx(playback.elapsed_ms(), float(playback.timeline_end_ms())), "Expected skip to jump the clock to the timeline end.")
	_require(finish_count[0] == 1, "Expected the finished callback to fire exactly once.")
	# Neither further advancing nor a second skip may re-finish.
	playback.advance(1.0)
	playback.skip()
	_require(finish_count[0] == 1, "Expected no second finished callback after extra advance/skip calls.")


func _check_controller_event_ordering() -> void:
	print("-- Controller event ordering: time-sorted, ticks before casts on ties --")
	var result := _known_loss_result()
	var fired: Array = []
	var playback := CombatPlayback.new()
	playback.event_callback = func(event): fired.append(event)
	playback.start(result)
	playback.skip()
	_require(fired.size() == result.cast_events.size() + result.tick_events.size(), "Expected every event delivered through the callback.")
	for i in range(1, fired.size()):
		_require(fired[i - 1].time_ms <= fired[i].time_ms, "Expected non-decreasing event timestamps.")
		if fired[i - 1].time_ms == fired[i].time_ms and fired[i - 1].is_tick != fired[i].is_tick:
			_require(fired[i - 1].is_tick, "Expected a tick to fire before a cast sharing its timestamp (resolver order).")
	var cast_count := 0
	var tick_count := 0
	for event in fired:
		if event.is_tick:
			tick_count += 1
			_require(event.tick != null and event.cast == null, "Expected tick events to carry only their TickEvent.")
		else:
			cast_count += 1
			_require(event.cast != null and event.tick == null, "Expected cast events to carry only their CastEvent.")
	_require(cast_count == result.cast_events.size() and tick_count == result.tick_events.size(), "Expected cast/tick counts to match the result.")


func _check_controller_win_truncation() -> void:
	print("-- Controller full-window playback: a win plays out the entire window, not just to the kill --")
	# Renamed from "win truncation" (adjustment round 1, 2026-07-19): the
	# user asked for the full window's worth of casts/ticks to play even
	# after the kill, for an "overkill" feel, rather than stopping playback
	# the instant the recorded kill event lands. This now asserts the
	# OPPOSITE of the old behavior -- the full timeline plays on a win, same
	# as a loss.
	var stab: Skill = load("res://data/skills/stab.tres")
	var rotation: Array[Skill] = [stab]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	var monster := Monster.new()
	monster.display_name = "Fragile Dummy"
	monster.hp = 30
	monster.armor = 0
	monster.poison_resistance = 0.0
	var result := CombatResolver.resolve(rotation, player, monster, 12000, 1)
	_require(result.is_win, "Expected Stab to kill the 30 HP dummy inside 12s.")

	# Independently locate the kill event (first merged-timeline event whose
	# cumulative damage reaches HP) purely to prove more events fire after it.
	var cumulative := 0.0
	var kill_time := -1
	var kill_index := -1
	for i in result.cast_events.size():
		cumulative += result.cast_events[i].physical_damage
		if cumulative >= float(monster.hp):
			kill_time = result.cast_events[i].time_ms
			kill_index = i
			break
	_require(kill_time > 0, "Expected the kill to land mid-window.")
	_require(kill_index < result.cast_events.size() - 1, "Expected more casts to land after the kill event in this fixture (so full-window playback is actually exercised).")

	var total_events := result.cast_events.size() + result.tick_events.size()
	var playback := CombatPlayback.new()
	playback.start(result)
	_require(playback.timeline_end_ms() == 12000, "Expected a win's timeline to span the full window, not truncate at the kill.")
	_require(playback.window_ms() == 12000, "Expected window_ms to report the full window for the countdown readout.")
	playback.skip()
	_require(playback.damage_dealt() >= float(monster.hp), "Expected cumulative damage to still reach/exceed the kill HP.")
	_require(playback.events_fired() == total_events, "Expected every event in the result -- including every one after the kill -- to fire on a win.")
	_require(playback.is_finished(), "Expected the full-window timeline to finish.")


## Live check: a real winning fight with playback enabled. State and
## autosave mutate the instant Fight is pressed (the state-vs-presentation
## invariant), the outcome UI stays hidden mid-playback, manual advance
## drains HP without revealing anything, and Skip reveals the victory
## banner. No awaits between the fight press and the final assertions, so
## the engine's own _process never advances the playback under the test.
func _check_live_playback_win() -> void:
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
	combat_screen.instant_playback = false
	build_state.set_locked(true)

	var fight_enemy_panel = combat_screen._enemy_panel
	var monster: Monster = fight_enemy_panel.monster()
	# Cleared so the has_save() assertion below proves the FIGHT's autosave
	# specifically fired before playback started.
	SaveSystem.delete_save()

	print("-- Live playback win --")
	fight_enemy_panel.fight_pressed.emit()
	# State mutated and autosaved instantly; presentation deferred.
	_require(combat_screen._playback_active, "Expected playback to be active right after Fight.")
	_require(build_state.last_fight_won, "Expected the fight result to be resolved (and won) instantly.")
	_require(build_state.run_phase != build_state.RunPhase.FIGHTING, "Expected the run state machine to have already advanced past FIGHTING.")
	_require(SaveSystem.has_save(), "Expected the autosave to have fired before playback started.")
	_require(not combat_screen._victory_overlay.visible, "Expected the victory banner to stay hidden mid-playback.")
	_require(not combat_screen._outcome_title_label.visible, "Expected no outcome title mid-playback.")
	_require(not combat_screen._recap_label.visible, "Expected no recap mid-playback.")
	_require(not combat_screen._status_label.visible, "Expected the status line hidden mid-playback.")
	_require(combat_screen._playback_controls.visible, "Expected the playback controls visible mid-playback.")
	_require(combat_screen._view_log_button.disabled, "Expected the combat log locked mid-playback.")
	_require(combat_screen._map_button.disabled, "Expected the Map button locked mid-playback.")
	_require(combat_screen._phase_label.text == "Phase: Fighting", "Expected the header frozen on Fighting mid-playback.")
	_require(
		combat_screen._hud_hp_text_label.text == "HP %d/%d" % [monster.hp, monster.hp],
		"Expected the HUD to open at full HP for playback."
	)

	# Drive partway manually (2 simulated seconds at 1x): some hits land,
	# HP text drops in step with the controller's damage bookkeeping, and
	# the outcome stays hidden.
	combat_screen._playback.advance(2.0)
	_require(combat_screen._playback.events_fired() > 0, "Expected events to have fired 2s in.")
	var expected_hp: float = float(monster.hp) - combat_screen._playback.damage_dealt()
	_require(
		combat_screen._hud_hp_text_label.text == "HP %d/%d" % [ceili(expected_hp), monster.hp],
		"Expected the HUD HP text to track fired damage mid-playback."
	)
	_require(not combat_screen._victory_overlay.visible, "Expected the outcome still hidden after partial playback.")
	_require(combat_screen._playback_active, "Expected playback still active after partial advance.")

	# Skip to the result: the deferred reveal runs exactly as instant mode
	# would have shown it.
	combat_screen._playback_skip_button.pressed.emit()
	_require(not combat_screen._playback_active, "Expected playback finished after Skip.")
	_require(combat_screen._victory_overlay.visible, "Expected the victory banner revealed after Skip.")
	_require(not combat_screen._playback_controls.visible, "Expected the playback controls hidden after the reveal.")
	_require(not combat_screen._view_log_button.disabled, "Expected the combat log unlocked after the reveal.")
	_require(not combat_screen._map_button.disabled, "Expected the Map button unlocked after the reveal.")
	_require(combat_screen._victory_recap_label.text.contains("Total Damage:"), "Expected the win recap populated at the reveal.")
	_require(combat_screen._hud_hp_text_label.text == "HP 0/%d" % monster.hp, "Expected the HUD snapped to the exact post-fight state (dead enemy).")
	_require(combat_screen._phase_label.text != "Phase: Fighting", "Expected the header unfrozen after the reveal.")

	combat_screen.queue_free()
	await process_frame


## Live check: a real losing fight (empty rotation) with playback enabled --
## the timeline spans the full window (the timer visibly runs out), and the
## reveal shows the loss outcome with the enemy's HP intact.
func _check_live_playback_loss() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	combat_screen.instant_playback = false
	build_state.rotation.clear()
	build_state.set_locked(true)

	var fight_enemy_panel = combat_screen._enemy_panel
	var monster: Monster = fight_enemy_panel.monster()
	var duration_ms: int = fight_enemy_panel.duration_ms()

	print("-- Live playback loss --")
	fight_enemy_panel.fight_pressed.emit()
	_require(combat_screen._playback_active, "Expected playback active after a losing Fight press.")
	_require(not build_state.last_fight_won, "Expected the loss to be resolved instantly.")
	_require(not combat_screen._outcome_title_label.visible, "Expected the DEFEATED title hidden mid-playback.")
	_require(not combat_screen._retry_button.visible, "Expected the retry button hidden mid-playback.")
	_require(combat_screen._playback.timeline_end_ms() == duration_ms, "Expected a loss playback to span the full DPS window.")

	combat_screen._skip_playback()
	_require(not combat_screen._playback_active, "Expected playback finished after skip.")
	_require(combat_screen._outcome_title_label.visible, "Expected the loss outcome title revealed after skip.")
	_require(combat_screen._retry_button.visible, "Expected the retry do-over revealed after skip.")
	_require(combat_screen._recap_label.visible, "Expected the loss recap revealed after skip.")
	_require(
		combat_screen._hud_hp_text_label.text == "HP %d/%d" % [monster.hp, monster.hp],
		"Expected the enemy HP bar to end the loss playback still full (window expired, enemy alive)."
	)
	_require(
		combat_screen._playback_time_label.text == "%.1fs / %.0fs" % [duration_ms / 1000.0, duration_ms / 1000.0],
		"Expected the window readout to end at the cap on a loss."
	)

	combat_screen.queue_free()
	await process_frame


## Live check: the player's chosen playback speed carries forward into the
## NEXT fight instead of resetting to 1x (combat-playback adjustment round 2
## + retry bug, 2026-07-19, item 4). Loses once at 1x, picks 4x mid-
## playback, retries the same encounter (the retry-bug fix under test
## elsewhere makes this immediately fightable again with no map re-choice),
## and fights again -- the fresh playback should start already at 4x.
func _check_playback_speed_persists() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	combat_screen.instant_playback = false
	build_state.rotation.clear()
	build_state.set_locked(true)

	var fight_enemy_panel = combat_screen._enemy_panel

	print("-- Live playback speed persists across fights --")
	fight_enemy_panel.fight_pressed.emit()
	_require(is_equal_approx(combat_screen._playback.speed, 1.0), "Expected the first-ever fight of a session to start at the default 1x.")

	# Pick 4x mid-playback via the real speed button (index 2 of
	# PLAYBACK_SPEED_OPTIONS == [1.0, 2.0, 4.0]).
	combat_screen._playback_speed_buttons[2].pressed.emit()
	_require(is_equal_approx(combat_screen._playback.speed, 4.0), "Expected the 4x speed button press to apply immediately.")
	_require(combat_screen._playback_speed_buttons[2].disabled, "Expected the 4x button to show as the active speed.")

	combat_screen._skip_playback()
	_require(combat_screen._retry_button.visible, "Expected the retry do-over after this Tavern loss.")
	combat_screen._retry_button.pressed.emit()
	_require(build_state.run_phase == build_state.RunPhase.PLANNING, "Expected retry to return to planning.")
	_require(not build_state.needs_tavern_map_choice(), "Expected the retry-bug fix to make the same encounter immediately fightable again.")
	build_state.set_locked(true)

	fight_enemy_panel.fight_pressed.emit()
	_require(combat_screen._playback_active, "Expected the second fight to also enter playback.")
	_require(
		is_equal_approx(combat_screen._playback.speed, 4.0),
		"Expected the second fight's playback to start at the previously-chosen 4x speed, not reset to 1x."
	)
	_require(combat_screen._playback_speed_buttons[2].disabled, "Expected the 4x button to already show as active on the second fight.")
	_require(not combat_screen._playback_speed_buttons[0].disabled, "Expected the 1x button to not be shown as active on the second fight.")

	combat_screen._skip_playback()
	combat_screen.queue_free()
	await process_frame


func _instantiate_combat_screen() -> Node:
	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	return combat_screen


## Same fixed idiom as combat_recap_test.gd: record failures and quit once
## at the end of _initialize(), so an awaited check can't have its failure
## exit code silently overwritten by an earlier bare quit().
func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failed = true
