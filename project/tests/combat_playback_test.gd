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
const CombatPlaybackScenarios := preload("res://tests/helpers/combat_playback_scenarios.gd")
const CombatStageScript := preload("res://scripts/ui/combat_stage.gd")


func _initialize() -> void:
	_check_controller_timeline_and_speed()
	_check_controller_skip_and_single_finish()
	_check_controller_event_ordering()
	_check_controller_cast_start_callback()
	_check_controller_win_truncation()
	_check_m1_t1_controlled_playback_scenarios()
	await _check_m1_t4_combat_stage_animation_mapping()
	await _check_live_playback_win()
	await _check_natural_playback_win_reveal_timing()
	await _check_live_playback_loss()
	await _check_natural_playback_loss_reveal_timing()
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


func _check_controller_cast_start_callback() -> void:
	print("-- Controller cast-start callback: macro highlight timing precedes damage events --")
	var result := _known_loss_result()
	_require(result.cast_events.size() >= 2, "Expected at least two casts in the known fight.")
	_require(result.cast_events[0].cast_start_ms == 0, "Expected the first cast to begin at combat time zero.")
	_require(result.cast_events[0].time_ms == result.cast_events[1].cast_start_ms, "Expected the next macro slot to start when the previous cast completes.")

	var starts: Array[CombatResolver.CastEvent] = []
	var events: Array = []
	var callback_order: PackedStringArray = []
	var playback := CombatPlayback.new()
	playback.cast_start_callback = func(cast):
		starts.append(cast)
		callback_order.append("start:%d" % cast.rotation_index)
	playback.event_callback = func(event):
		events.append(event)
		if not event.is_tick:
			callback_order.append("end:%d" % event.cast.rotation_index)
	playback.start(result)
	playback.advance(0.01)
	_require(starts.size() == 1, "Expected the first macro slot to highlight at cast start before its damage event.")
	_require(events.is_empty(), "Expected no damage event when only the first cast start has fired.")
	_require(playback.active_cast() == result.cast_events[0], "Expected the first cast to be the active macro cast during its windup.")
	_require(playback.active_cast_progress() > 0.0 and playback.active_cast_progress() < 1.0, "Expected active cast progress to report partial windup.")
	playback.advance(float(result.cast_events[0].time_ms) / 1000.0 - 0.01)
	_require(starts.size() >= 2, "Expected the second macro slot to highlight at the first cast's end/start boundary.")
	_require(not events.is_empty(), "Expected the first cast-end event to fire at that same boundary.")
	_require(playback.active_cast() == result.cast_events[1], "Expected the next cast to become active at the shared cast-end/start boundary.")
	_require(is_equal_approx(playback.active_cast_progress(), 0.0), "Expected the next cast's progress fill to start empty.")
	var first_cast_event = null
	for event in events:
		if not event.is_tick:
			first_cast_event = event
			break
	_require(first_cast_event != null and first_cast_event.cast == result.cast_events[0], "Expected the first cast-end event to remain the first cast.")
	var first_end_index := callback_order.find("end:%d" % result.cast_events[0].rotation_index)
	var second_start_index := callback_order.find("start:%d" % result.cast_events[1].rotation_index)
	_require(first_end_index >= 0 and second_start_index > first_end_index, "Expected same-timestamp cast-end/proc presentation to resolve before the next macro slot highlight wins.")


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


func _check_m1_t1_controlled_playback_scenarios() -> void:
	print("-- M1:T1 controlled playback scenarios cover major presentation event types --")
	var ids := CombatPlaybackScenarios.ids()
	_require(ids.size() == 12, "Expected M1:T1 to define every approved controlled playback scenario.")
	var seen := {}
	for id in ids:
		_require(not seen.has(id), "Expected scenario ids to be unique: %s." % id)
		seen[id] = true
		var scenario: Dictionary = CombatPlaybackScenarios.build(id)
		_require(not scenario.is_empty(), "Expected scenario %s to build." % id)
		var result: CombatResolver.CombatResult = scenario["result"]
		var monster: Monster = scenario["monster"]
		var tags: PackedStringArray = scenario["tags"]
		_require(result.duration_ms == scenario["duration_ms"], "Expected %s duration to match its fixture." % id)
		_require(result.cast_events.size() + result.tick_events.size() > 0, "Expected %s to produce playback events." % id)
		_require(_scenario_has_tags(result, monster, tags), "Expected %s to satisfy its presentation tags: %s." % [id, tags])

		var delivered: Array = []
		var playback := CombatPlayback.new()
		playback.event_callback = func(event): delivered.append(event)
		playback.start(result)
		playback.skip()
		_require(delivered.size() == result.cast_events.size() + result.tick_events.size(), "Expected %s playback to deliver every event." % id)
		_require(is_equal_approx(playback.damage_dealt(), result.total_damage), "Expected %s playback damage to match resolved total damage." % id)
		for i in range(1, delivered.size()):
			_require(delivered[i - 1].time_ms <= delivered[i].time_ms, "Expected %s playback events to stay time-ordered." % id)
		var rotation_size: int = scenario["rotation"].size()
		for event in delivered:
			if event.is_tick:
				continue
			_require(event.cast.rotation_index >= 0 and event.cast.rotation_index < rotation_size, "Expected %s cast rotation index to point at the source macro slot." % id)


func _check_m1_t4_combat_stage_animation_mapping() -> void:
	print("-- M1:T4 combat stage maps casts, ticks, and outcomes to presentation states --")
	var stage = CombatStageScript.new()
	root.add_child(stage)
	await process_frame
	stage.size = Vector2(640, 360)
	stage.configure("Rogue", "Mouthy Drunk")
	stage.reset_state()
	_require(is_equal_approx(stage._player_animation_frame_sec, 0.15), "Expected Rogue idle animation to use the slower 150ms frame cadence.")
	_require(stage.PEASANT_ANCHOR_POINT == Vector2(16, 16), "Expected enemy sprite pivot to sit at the center of its 32x32 frame.")
	_require(stage.ENEMY_STAGE_GRID == Vector2(1, 1), "Expected enemy sprite to target grid point (1, 1).")
	var enemy_target_point: Vector2 = stage._stage_point_for_grid(stage.ENEMY_STAGE_GRID) + stage.ACTOR_GROUP_STAGE_OFFSET_PX
	var enemy_sprite_anchor: Vector2 = stage._sprite_anchor_point(stage.enemy_actor_anchor, stage._enemy_sprite, stage.PEASANT_ANCHOR_POINT)
	_require(enemy_sprite_anchor.distance_to(enemy_target_point) < 0.01, "Expected the enemy sprite anchor to land on its right-shifted grid target.")
	var intro_duration := stage.play_fight_intro(false)
	_require(stage.fight_intro_count == 1, "Expected the stage to record a start-of-fight intro beat.")
	_require(is_equal_approx(intro_duration, 0.0), "Expected non-animated intro calls to finish instantly for headless checks.")
	_require(is_equal_approx(stage.last_fight_intro_duration_sec, CombatStageScript.FIGHT_INTRO_SEC), "Expected the intro beat to expose its authored duration.")

	var physical_cast := CombatResolver.CastEvent.new()
	physical_cast.skill = load("res://data/skills/stab.tres")
	physical_cast.physical_damage = 12.0
	physical_cast.cast_start_ms = 0
	physical_cast.time_ms = 700
	stage.play_cast_windup(physical_cast, 1.0, false)
	_require(stage.cast_animation_count == 1, "Expected a physical cast to record one stage animation.")
	_require(stage.cast_windup_count == 1, "Expected a physical cast to record one windup animation.")
	_require(stage.last_cast_animation_kind == CombatStageScript.ANIMATION_PHYSICAL, "Expected Stab to map to the physical Rogue attack language.")
	_require(stage.last_player_animation_key == "attack_physical", "Expected a physical cast to select Rogue attack1 frame animation.")
	_require(stage.last_player_animation_frame_count == 6, "Expected Rogue attack1 to expose its 6 fixed-size frames.")
	_require(is_equal_approx(stage._player_animation_duration_sec("attack_physical"), 0.6), "Expected Rogue attack1 to last 0.6s at its manifest cadence.")
	_require(stage._presentation_duration_for_cast(physical_cast, 1.0, "attack_physical") >= 0.6, "Expected physical cast presentation to last long enough for attack1 to finish.")
	_require(is_equal_approx(stage._player_animation_contact_sec("attack_physical"), 0.4), "Expected attack1 contact timing to land on its second-to-last frame.")
	_require(is_equal_approx(stage.last_cast_windup_duration_sec, 0.7), "Expected physical windup to track the cast-start-to-cast-end duration.")
	_require(is_equal_approx(stage.last_cast_contact_delay_sec, 0.7), "Expected physical contact to align with cast completion.")
	_require(is_equal_approx(stage.last_cast_animation_start_delay_sec, 0.3), "Expected attack1 to start late enough that contact lands as the slot fills.")

	var poison_cast := CombatResolver.CastEvent.new()
	poison_cast.skill = load("res://data/skills/poison_strike.tres")
	poison_cast.physical_damage = 15.0
	poison_cast.poison_stacks_applied = 1
	poison_cast.cast_start_ms = 0
	poison_cast.time_ms = 1200
	stage.play_cast_windup(poison_cast, 1.0, false)
	_require(stage.cast_animation_count == 2, "Expected a poison cast to record another stage animation.")
	_require(stage.last_cast_animation_kind == CombatStageScript.ANIMATION_POISON, "Expected Poison Strike to map to the poison Rogue attack language.")
	_require(stage.last_player_animation_key == "attack_poison", "Expected a poison cast to select Rogue attack2 frame animation.")
	_require(stage.last_player_animation_frame_count == 12, "Expected Rogue attack2 to expose its 12 normalized frames.")
	_require(is_equal_approx(stage._player_animation_duration_sec("attack_poison"), 1.2), "Expected Rogue attack2 to last 1.2s at its manifest cadence.")
	_require(stage._presentation_duration_for_cast(poison_cast, 1.0, "attack_poison") >= 1.2, "Expected poison cast presentation to last long enough for attack2 to finish.")
	_require(is_equal_approx(stage._player_animation_contact_sec("attack_poison"), 1.0), "Expected attack2 contact timing to land on its second-to-last frame.")
	_require(is_equal_approx(stage.last_cast_windup_duration_sec, 1.2), "Expected poison windup to track the cast-start-to-cast-end duration.")
	_require(is_equal_approx(stage.last_cast_contact_delay_sec, 1.2), "Expected poison contact to align with cast completion.")
	_require(is_equal_approx(stage.last_cast_animation_start_delay_sec, 0.2), "Expected attack2 to start late enough that contact lands as the slot fills.")

	var poison_theme_cast := CombatResolver.CastEvent.new()
	poison_theme_cast.skill = load("res://data/skills/beguiling_strike.tres")
	poison_theme_cast.physical_damage = 4.0
	poison_theme_cast.time_ms = 700
	stage.play_cast_windup(poison_theme_cast, 1.0, false)
	_require(stage.cast_animation_count == 3, "Expected a poison-themed utility cast to record one source-cast animation.")
	_require(stage.last_cast_animation_kind == CombatStageScript.ANIMATION_POISON, "Expected poison-resist skills to use the poison Rogue attack language even when no stack is applied.")

	var poison_damage_effect := PoisonDamageEffect.new()
	poison_damage_effect.stacks_applied = 1
	var neutral_poison_skill := Skill.new()
	neutral_poison_skill.id = "skill.neutral_dot"
	neutral_poison_skill.display_name = "Needle Jab"
	neutral_poison_skill.effects.append(poison_damage_effect)
	var poison_damage_cast := CombatResolver.CastEvent.new()
	poison_damage_cast.skill = neutral_poison_skill
	poison_damage_cast.physical_damage = 3.0
	poison_damage_cast.time_ms = 700
	stage.play_cast_windup(poison_damage_cast, 1.0, false)
	_require(stage.cast_animation_count == 4, "Expected a poison-damage attack to record one source-cast animation.")
	_require(stage.last_cast_animation_kind == CombatStageScript.ANIMATION_POISON, "Expected any attack with poison damage to use the poison Rogue attack language.")
	_require(stage.last_player_animation_key == "attack_poison", "Expected any attack with poison damage to select Rogue attack2.")

	var min_cast_proc := CombatResolver.CastEvent.new()
	min_cast_proc.skill = load("res://data/skills/stab.tres")
	min_cast_proc.physical_damage = 12.0
	min_cast_proc.min_cast_time_proc_applied = true
	min_cast_proc.cast_start_ms = 0
	min_cast_proc.time_ms = 180
	stage.play_cast_windup(min_cast_proc, 1.0, false)
	_require(stage.cast_animation_count == 5, "Expected a minimum-cast proc to stay attached to its source cast, not spawn an extra attack.")
	_require(stage.last_cast_animation_kind == CombatStageScript.ANIMATION_PHYSICAL, "Expected a physical minimum-cast proc source to keep the physical Rogue attack language.")
	_require(stage.last_cast_min_cast_proc_was_timing_event, "Expected minimum-cast procs to be recorded as timing events on the source cast.")
	_require(is_equal_approx(stage._presentation_duration_for_cast(min_cast_proc, 1.0, "attack_physical"), CombatStageScript.MIN_CAST_ANIMATION_SEC), "Expected minimum-cast procs to compress the source attack animation to max speed.")
	_require(is_equal_approx(stage.last_cast_contact_delay_sec, 0.18), "Expected minimum-cast proc contact to align with the short slot fill.")

	var triggered_cast := CombatResolver.CastEvent.new()
	triggered_cast.skill = load("res://data/skills/stab.tres")
	triggered_cast.physical_damage = 42.0
	triggered_cast.triggered_skill_names = PackedStringArray(["Stab"])
	triggered_cast.cast_start_ms = 0
	triggered_cast.time_ms = 700
	stage.play_cast_windup(triggered_cast, 1.0, false)
	var triggered_contact_delay := stage.play_cast_impact(triggered_cast, true)
	_require(stage.last_cast_triggered_followup_count == 1, "Expected triggered skill casts to request one fast follow-up attack.")
	_require(triggered_contact_delay > 0.0 and triggered_contact_delay < stage.TRIGGERED_FOLLOWUP_ANIMATION_SEC, "Expected triggered-skill damage text timing to wait for the fast follow-up hit beat.")
	stage.reset_state()

	stage.play_cast_windup(physical_cast, 1.0, true)
	_require(stage.contact_feedback_count == 0, "Expected cast windup to animate the Rogue without triggering enemy contact feedback early.")
	stage.play_cast_impact(physical_cast, true)
	_require(is_equal_approx(stage.last_enemy_recoil_delay_sec, 0.0), "Expected physical hit recoil to start exactly when the cast event fires.")
	_require(stage.contact_feedback_count == 1, "Expected a physical impact to schedule one enemy contact reaction.")
	_require(not stage.last_contact_feedback_was_crit, "Expected a regular physical hit to use non-crit enemy recoil.")
	_require(stage.bandit_coin_spray_count == 0, "Expected ordinary physical hits to skip Bandit Blade coin particles when the Legendary is not active.")
	stage.set_bandit_blade_effect_active(true)
	stage.play_cast_windup(physical_cast, 1.0, true)
	var early_coin_particles := 0
	for child in stage.get_children():
		if String(child.name).begins_with("BanditCoinParticle"):
			early_coin_particles += 1
	_require(early_coin_particles == 0, "Expected Bandit Blade coins to wait for cast impact instead of appearing during windup.")
	stage.play_cast_impact(physical_cast, true)
	_require(stage.bandit_coin_spray_count == 1, "Expected Bandit Blade to add one subtle coin spray to a physical hit.")
	_require(stage.last_bandit_coin_count == stage.BANDIT_COIN_NORMAL_COUNT, "Expected normal Bandit Blade hits to use the restrained coin count.")
	stage.play_cast_windup(poison_cast, 1.0, true)
	stage.play_cast_impact(poison_cast, true)
	_require(is_equal_approx(stage.last_enemy_recoil_delay_sec, 0.0), "Expected poison hit recoil to start exactly when the cast event fires.")
	_require(stage.contact_feedback_count == 3, "Expected the poison hit to schedule another enemy contact reaction.")
	stage.set_poison_stacks(poison_cast.poison_stacks_applied, false)
	_require(stage.poison_stack_tint_updates == 1, "Expected poison stack application to update the shared enemy tint.")
	_require(stage.last_poison_stack_tint_stacks == 1, "Expected poison stack tint to record the active stack count.")
	_require(stage.enemy_actor_anchor.modulate != Color.WHITE, "Expected active poison stacks to tint the enemy green.")
	stage.configure("Rogue", "Tavern Bouncer")
	_require(stage.last_poison_stack_tint_stacks == 0, "Expected configuring a new target to clear stale poison tint stacks.")
	_require(stage.enemy_actor_anchor.modulate == Color.WHITE, "Expected a newly configured target to start without the previous enemy's poison tint.")

	var crit_cast := CombatResolver.CastEvent.new()
	crit_cast.skill = load("res://data/skills/stab.tres")
	crit_cast.physical_damage = 24.0
	crit_cast.is_crit = true
	crit_cast.time_ms = 700
	stage.play_cast_windup(crit_cast, 1.0, true)
	stage.play_cast_impact(crit_cast, true)
	_require(stage.contact_feedback_count == 4, "Expected a crit to schedule enemy contact feedback.")
	_require(stage.last_contact_feedback_was_crit, "Expected crit enemy recoil to be marked distinctly.")
	_require(stage.bandit_coin_spray_count == 3, "Expected Bandit Blade to add coin particles to each physical-damage hit while active.")
	_require(stage.last_bandit_coin_count == stage.BANDIT_COIN_CRIT_COUNT, "Expected Bandit Blade crits to get a slightly richer coin spray.")
	stage.reset_state()
	_require(stage.bandit_coin_spray_count == 0, "Expected reset_state() to clear Bandit Blade coin spray counters.")

	stage.play_poison_tick_pulse(false)
	_require(stage.poison_tick_pulse_count == 1, "Expected poison ticks to use a status pulse instead of a Rogue attack animation.")

	stage.play_outcome_pose(true, false)
	_require(stage.outcome_pose == CombatStageScript.OUTCOME_VICTORY, "Expected a won fight to record the enemy defeat pose.")
	_require(stage.outcome_flash_count == 1, "Expected victory to record one outcome flash beat.")
	_require(stage.last_outcome_flash_was_victory, "Expected the outcome flash to know this was a victory.")

	stage.play_outcome_pose(false, false)
	_require(stage.outcome_pose == CombatStageScript.OUTCOME_DEFEAT, "Expected a lost fight to record the player defeat pose.")
	_require(stage.outcome_flash_count == 2, "Expected defeat to record another outcome flash beat.")
	_require(not stage.last_outcome_flash_was_victory, "Expected the outcome flash to know this was a defeat.")
	_require(stage.last_player_animation_key == "defeat", "Expected a lost fight to select the Rogue death animation.")
	_require(stage.last_player_animation_frame_count == 5, "Expected the Rogue death animation to expose its five authored frames.")
	_require(is_equal_approx(stage.player_defeat_animation_duration_sec(), 0.5), "Expected the Rogue death animation to play out over 0.5s before the hold.")
	_require(stage.last_player_animation_frame_path.contains("/death/frames/"), "Expected the displayed defeat frame to come from the Rogue death animation folder.")

	stage.reset_state()
	_require(stage.cast_animation_count == 0, "Expected reset_state() to clear cast animation counters for the next fight.")
	_require(stage.poison_tick_pulse_count == 0, "Expected reset_state() to clear poison tick counters for the next fight.")
	_require(stage.poison_stack_tint_updates == 0, "Expected reset_state() to clear poison stack tint counters for the next fight.")
	_require(stage.last_poison_stack_tint_stacks == 0, "Expected reset_state() to clear the active poison stack tint.")
	_require(stage.outcome_pose == "", "Expected reset_state() to clear the previous outcome pose.")
	_require(stage.outcome_flash_count == 0, "Expected reset_state() to clear outcome flash counters.")

	stage.queue_free()
	await process_frame


func _scenario_has_tags(result: CombatResolver.CombatResult, monster: Monster, tags: PackedStringArray) -> bool:
	for tag in tags:
		match tag:
			"cast":
				if result.cast_events.is_empty():
					return false
			"physical_hit":
				if not _has_cast_matching(result, func(cast): return cast.physical_damage > 0.0):
					return false
			"crit":
				if not _has_cast_matching(result, func(cast): return cast.is_crit):
					return false
			"poison_stack":
				if not _has_cast_matching(result, func(cast): return cast.poison_stacks_applied > 0):
					return false
			"poison_tick":
				if not _has_tick_matching(result, func(tick): return tick.damage > 0.0):
					return false
			"armor_reduction":
				if not _has_cast_matching(result, func(cast): return cast.armor_reduction_applied > 0):
					return false
			"poison_resist_reduction":
				if not _has_cast_matching(result, func(cast): return cast.poison_resistance_reduction_applied > 0.0):
					return false
			"triggered_skill":
				if not _has_cast_matching(result, func(cast): return not cast.triggered_skill_names.is_empty()):
					return false
			"min_cast_proc":
				if not _has_cast_matching(result, func(cast): return cast.min_cast_time_proc_applied):
					return false
			"slow_cast":
				if not _has_cast_matching(result, func(cast): return cast.skill != null and cast.skill.display_name == "Heavy Slash" and cast.time_ms >= 2000):
					return false
			"fast_cast":
				if not _has_cast_matching(result, func(cast): return cast.time_ms <= 900):
					return false
			"poison_cast":
				if not _has_cast_matching(result, func(cast): return cast.skill != null and cast.skill.display_name == "Poison Strike" and cast.poison_stacks_applied > 0):
					return false
			"victory":
				if not result.is_win:
					return false
			"defeat":
				if result.is_win or result.total_damage >= float(monster.hp):
					return false
	return true


func _has_cast_matching(result: CombatResolver.CombatResult, predicate: Callable) -> bool:
	for cast in result.cast_events:
		if predicate.call(cast):
			return true
	return false


func _has_tick_matching(result: CombatResolver.CombatResult, predicate: Callable) -> bool:
	for tick in result.tick_events:
		if predicate.call(tick):
			return true
	return false


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
	_require(combat_screen._combat_stage != null, "Expected playback to have a combat stage behind the HUD.")
	_require(combat_screen._combat_stage._enemy_name_label.text == monster.display_name, "Expected the combat stage enemy label data to track the current target mid-playback.")
	_require(not combat_screen._combat_stage._enemy_name_label.visible, "Expected Adventure playback to hide the enemy name inside the combat window.")
	_require(combat_screen._combat_stage.fight_intro_count == 1, "Expected the combat stage to play one start-of-fight intro.")
	_require(combat_screen._playback_presenter._intro_remaining_sec > 0.0, "Expected playback to begin with a visual intro before the combat clock advances.")
	_require(combat_screen._playback_presenter._playback.events_fired() == 0, "Expected no timeline events to fire during the fight intro setup.")
	_require(
		combat_screen._hud_hp_text_label.text == "%d/%d" % [monster.hp, monster.hp],
		"Expected the HUD to open at full HP for playback."
	)

	# Drive half of the intro first: the combat clock should still be
	# truthful at 0, with no damage or events leaking in early.
	combat_screen._process(combat_screen._playback_presenter._intro_duration_sec * 0.5)
	_require(combat_screen._playback_presenter._playback.events_fired() == 0, "Expected no events to fire before the intro finishes.")
	_require(is_equal_approx(combat_screen._playback_presenter._playback.elapsed_ms(), 0.0), "Expected the combat timeline clock to stay at 0 during the intro.")

	# Drive through the rest of the intro plus 2 simulated combat seconds:
	# some hits land, HP text drops in step with the controller's damage
	# bookkeeping, and the outcome stays hidden.
	combat_screen._process(combat_screen._playback_presenter._intro_remaining_sec + 2.0)
	_require(combat_screen._playback_presenter._playback.events_fired() > 0, "Expected events to have fired 2s in.")
	var expected_hp: float = float(monster.hp) - combat_screen._playback_presenter._playback.damage_dealt()
	_require(
		combat_screen._hud_hp_text_label.text == "%d/%d" % [ceili(expected_hp), monster.hp],
		"Expected the HUD HP text to track fired damage mid-playback."
	)
	_require(not combat_screen._victory_overlay.visible, "Expected the outcome still hidden after partial playback.")
	_require(combat_screen._playback_active, "Expected playback still active after partial advance.")

	# Skip to the result: the deferred reveal runs exactly as instant mode
	# would have shown it, after the victory pose beat has time to read.
	combat_screen._playback_controls._skip_button.pressed.emit()
	_require(not combat_screen._playback_active, "Expected playback finished after Skip.")
	_require(not combat_screen._victory_overlay.visible, "Expected skipped wins to wait for the victory pose beat before revealing the overlay.")
	_require(combat_screen._playback_controls.visible, "Expected the playback controls to stay visible after the reveal.")
	_require(combat_screen._hud_hp_text_label.text == "0/%d" % monster.hp, "Expected the HUD snapped to the exact post-fight state (dead enemy).")
	_require(combat_screen._combat_stage.outcome_pose == CombatStageScript.OUTCOME_VICTORY, "Expected skip to still snap the enemy into the victory pose.")
	_require(combat_screen._combat_stage.outcome_flash_count == 1, "Expected skip to record the victory outcome beat without waiting.")
	await create_timer(combat_screen.PLAYBACK_OUTCOME_REVEAL_DELAY_SEC + 0.05).timeout
	_require(combat_screen._victory_overlay.visible, "Expected the victory banner revealed after the skipped-win pose hold.")
	_require(not combat_screen._view_log_button.disabled, "Expected the combat log unlocked after the reveal.")
	_require(not combat_screen._map_button.disabled, "Expected the Map button unlocked after the reveal.")
	_require(combat_screen._victory_recap_label.text.contains("Total Damage:"), "Expected the win recap populated at the reveal.")
	_require(combat_screen._phase_label.text != "Phase: Fighting", "Expected the header unfrozen after the reveal.")

	combat_screen.queue_free()
	await process_frame


## Natural playback finish: the final stage pose lands before the outcome UI,
## then the short reveal hold expires and the normal victory banner appears.
func _check_natural_playback_win_reveal_timing() -> void:
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

	print("-- Natural playback win reveal timing --")
	combat_screen._enemy_panel.fight_pressed.emit()
	var duration_sec := float(combat_screen._playback_presenter._playback.timeline_end_ms()) / 1000.0
	combat_screen._process(combat_screen._playback_presenter._intro_remaining_sec + duration_sec + 0.1)
	_require(not combat_screen._playback_active, "Expected playback to be finished before the natural reveal hold expires.")
	_require(not combat_screen._victory_overlay.visible, "Expected the victory banner hidden during the natural outcome pose hold.")
	_require(combat_screen._view_log_button.disabled, "Expected the combat log to stay locked during the natural outcome pose hold.")
	_require(combat_screen._map_button.disabled, "Expected the Map button to stay locked during the natural outcome pose hold.")
	_require(combat_screen._combat_stage.outcome_pose == CombatStageScript.OUTCOME_VICTORY, "Expected the enemy defeat pose to land before the victory banner appears.")
	_require(combat_screen._combat_stage.outcome_flash_count == 1, "Expected natural victory to play one outcome flash beat.")

	await create_timer(combat_screen.PLAYBACK_OUTCOME_REVEAL_DELAY_SEC + 0.05).timeout
	_require(combat_screen._victory_overlay.visible, "Expected the victory banner after the natural reveal hold.")
	_require(not combat_screen._view_log_button.disabled, "Expected the combat log unlocked after the natural reveal.")
	_require(not combat_screen._map_button.disabled, "Expected the Map button unlocked after the natural reveal.")

	combat_screen.queue_free()
	await process_frame


## Live check: a real losing fight with playback enabled -- the timeline spans
## the full window (the timer visibly runs out), and the reveal shows the loss
## outcome with the enemy alive.
func _check_live_playback_loss() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()
	var stab: Skill = load("res://data/skills/stab.tres")
	var loss_rotation: Array[Skill] = [stab]
	build_state.rotation = loss_rotation

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	combat_screen.instant_playback = false
	build_state.set_locked(true)

	var fight_enemy_panel = combat_screen._enemy_panel
	var monster: Monster = fight_enemy_panel.monster()
	monster.hp = 100000
	var duration_ms: int = fight_enemy_panel.duration_ms()

	print("-- Live playback loss --")
	fight_enemy_panel.fight_pressed.emit()
	_require(combat_screen._playback_active, "Expected playback active after a losing Fight press.")
	_require(not build_state.last_fight_won, "Expected the loss to be resolved instantly.")
	_require(fight_enemy_panel._title_label.text == monster.display_name, "Expected enemy panel to keep showing the fought target during playback.")
	_require(fight_enemy_panel._info_label.text.contains("HP:"), "Expected enemy panel to keep showing enemy stats during playback.")
	_require(not fight_enemy_panel._info_label.text.contains("This Adventure has ended."), "Expected enemy panel not to leak run-ended status during playback.")
	_require(not combat_screen._outcome_title_label.visible, "Expected the DEFEATED title hidden mid-playback.")
	_require(not combat_screen._retry_button.visible, "Expected the retry button hidden mid-playback.")
	_require(combat_screen._playback_presenter._playback.timeline_end_ms() == duration_ms, "Expected a loss playback to span the full DPS window.")
	_require(combat_screen._playback_presenter._intro_remaining_sec > 0.0, "Expected the losing fight to start with the shared intro beat.")
	_require(combat_screen._playback_presenter._playback.events_fired() == 0, "Expected skip-during-intro coverage to begin before any events fire.")

	combat_screen._skip_playback()
	_require(not combat_screen._playback_active, "Expected playback finished after skip.")
	_require(not combat_screen._victory_overlay.visible, "Expected a skipped loss to wait for the death beat before revealing the overlay.")
	var expected_remaining: int = maxi(0, roundi(float(monster.hp) - combat_screen._hud_result.total_damage))
	_require(
		combat_screen._hud_hp_text_label.text == "%d/%d" % [expected_remaining, monster.hp],
		"Expected the enemy HP bar to end the loss playback with the resolved damage applied."
	)
	_require(combat_screen._playback_controls._time_label == null or not combat_screen._playback_controls._time_label.visible, "Expected the old playback time readout to stay hidden.")
	_require(combat_screen._fight_timer_label.visible, "Expected the fight-window timer badge to remain the visible combat timer.")
	_require(combat_screen._combat_stage.outcome_pose == CombatStageScript.OUTCOME_DEFEAT, "Expected skip to enter the player defeat pose before the overlay.")
	_require(combat_screen._combat_stage.outcome_flash_count == 1, "Expected skip to record the defeat outcome beat without waiting.")
	_require(combat_screen._combat_stage.last_player_animation_key == "defeat", "Expected skipped losses to use the Rogue death pose.")
	_require(combat_screen._combat_stage.player_actor_anchor.modulate == Color.WHITE, "Expected skipped losses not to tint the Rogue red during death.")
	_require(combat_screen._combat_stage.last_player_animation_frame_path.ends_with("/death/frames/frame_001.png"), "Expected skipped losses to start on the first death frame.")
	await create_timer(0.12).timeout
	_require(combat_screen._combat_stage.last_player_animation_frame_path.ends_with("/death/frames/frame_002.png"), "Expected skipped losses to advance through the death animation frames.")
	await _await_skipped_loss_reveal(combat_screen)
	_require(combat_screen._victory_overlay.visible, "Expected the loss overlay revealed after the skipped-loss death hold.")
	_require(combat_screen._victory_title_label.text == "DEFEATED", "Expected the loss outcome title revealed after the skipped-loss death hold.")
	_require(combat_screen._outcome_retry_button.visible, "Expected the retry do-over revealed after the skipped-loss death hold.")
	_require(combat_screen._victory_recap_label.text.contains("Total Damage:"), "Expected the loss recap revealed after the skipped-loss death hold.")

	combat_screen.queue_free()
	await process_frame


## Natural loss reveal mirrors the win path: the player defeat pose is visible
## during the short hold, and retry/recap UI unlocks only after the hold.
func _check_natural_playback_loss_reveal_timing() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()
	var stab: Skill = load("res://data/skills/stab.tres")
	var loss_rotation: Array[Skill] = [stab]
	build_state.rotation = loss_rotation

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	combat_screen.instant_playback = false
	build_state.set_locked(true)
	combat_screen._enemy_panel.monster().hp = 100000

	print("-- Natural playback loss reveal timing --")
	combat_screen._enemy_panel.fight_pressed.emit()
	var duration_sec := float(combat_screen._playback_presenter._playback.timeline_end_ms()) / 1000.0
	combat_screen._process(combat_screen._playback_presenter._intro_remaining_sec + duration_sec + 0.1)
	_require(not combat_screen._playback_active, "Expected losing playback to finish before the natural reveal hold expires.")
	_require(not combat_screen._outcome_title_label.visible, "Expected the defeat title hidden during the natural outcome pose hold.")
	_require(not combat_screen._retry_button.visible, "Expected retry hidden during the natural outcome pose hold.")
	_require(combat_screen._view_log_button.disabled, "Expected combat log locked during the natural loss hold.")
	_require(combat_screen._map_button.disabled, "Expected map locked during the natural loss hold.")
	_require(combat_screen._combat_stage.outcome_pose == CombatStageScript.OUTCOME_DEFEAT, "Expected the player defeat pose before the loss UI appears.")
	_require(combat_screen._combat_stage.outcome_flash_count == 1, "Expected natural defeat to play one outcome flash beat.")
	_require(combat_screen._combat_stage.last_player_animation_key == "defeat", "Expected natural losses to play the Rogue death animation before the UI appears.")

	await create_timer(combat_screen.PLAYBACK_OUTCOME_REVEAL_DELAY_SEC + 0.05).timeout
	_require(not combat_screen._victory_overlay.visible, "Expected the old generic reveal hold to be too short for a natural defeat reveal.")
	var defeat_reveal_delay_sec: float = combat_screen._combat_stage.player_defeat_animation_duration_sec() + combat_screen.PLAYER_DEFEAT_POSE_HOLD_SEC
	await create_timer(defeat_reveal_delay_sec - combat_screen.PLAYBACK_OUTCOME_REVEAL_DELAY_SEC + 0.05).timeout
	_require(combat_screen._victory_overlay.visible, "Expected the defeat overlay after the natural reveal hold.")
	_require(combat_screen._victory_title_label.text == "DEFEATED", "Expected the defeat title after the natural reveal hold.")
	_require(combat_screen._outcome_retry_button.visible, "Expected retry after the natural reveal hold.")
	_require(combat_screen._victory_recap_label.text.contains("Total Damage:"), "Expected loss recap after the natural reveal hold.")
	_require(not combat_screen._view_log_button.disabled, "Expected combat log unlocked after the natural loss reveal.")
	_require(not combat_screen._map_button.disabled, "Expected map unlocked after the natural loss reveal.")

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
	var stab: Skill = load("res://data/skills/stab.tres")
	var loss_rotation: Array[Skill] = [stab]
	build_state.rotation = loss_rotation

	var combat_screen := _instantiate_combat_screen()
	await process_frame
	combat_screen.instant_playback = false
	build_state.set_locked(true)
	combat_screen._enemy_panel.monster().hp = 100000

	var fight_enemy_panel = combat_screen._enemy_panel

	print("-- Live playback speed persists across fights --")
	fight_enemy_panel.fight_pressed.emit()
	_require(is_equal_approx(combat_screen._playback_presenter._playback.speed, 1.0), "Expected the first-ever fight of a session to start at the default 1x.")

	# Pick 4x mid-playback via the real speed button (index 2 of
	# PLAYBACK_SPEED_OPTIONS == [1.0, 2.0, 4.0]).
	combat_screen._playback_controls._speed_buttons[2].pressed.emit()
	_require(is_equal_approx(combat_screen._playback_presenter._playback.speed, 4.0), "Expected the 4x speed button press to apply immediately.")
	_require(combat_screen._playback_controls._speed_buttons[2].disabled, "Expected the 4x button to show as the active speed.")

	combat_screen._skip_playback()
	await _await_skipped_loss_reveal(combat_screen)
	_require(combat_screen._outcome_retry_button.visible, "Expected the retry do-over after this Tavern loss.")
	combat_screen._outcome_retry_button.pressed.emit()
	_require(build_state.run_phase == build_state.RunPhase.PLANNING, "Expected retry to return to planning.")
	_require(not build_state.needs_tavern_map_choice(), "Expected the retry-bug fix to make the same encounter immediately fightable again.")
	build_state.set_locked(true)
	combat_screen._enemy_panel.monster().hp = 100000

	fight_enemy_panel.fight_pressed.emit()
	_require(combat_screen._playback_active, "Expected the second fight to also enter playback.")
	_require(
		is_equal_approx(combat_screen._playback_presenter._playback.speed, 4.0),
		"Expected the second fight's playback to start at the previously-chosen 4x speed, not reset to 1x."
	)
	_require(combat_screen._playback_controls._speed_buttons[2].disabled, "Expected the 4x button to already show as active on the second fight.")
	_require(not combat_screen._playback_controls._speed_buttons[0].disabled, "Expected the 1x button to not be shown as active on the second fight.")

	combat_screen._skip_playback()
	await _await_skipped_loss_reveal(combat_screen)
	combat_screen.queue_free()
	await process_frame


func _await_skipped_loss_reveal(combat_screen: Node) -> void:
	var skip_defeat_reveal_delay_sec: float = combat_screen._combat_stage.player_defeat_animation_duration_sec() + combat_screen.PLAYER_DEFEAT_POSE_HOLD_SEC
	await create_timer(skip_defeat_reveal_delay_sec + 0.05).timeout


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
