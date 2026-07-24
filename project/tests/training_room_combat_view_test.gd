extends SceneTree
## Headless check for TrainingRoomCombatView (Training Room's own animated
## combat area, user-requested "combat area, like Adventure mode"): a known
## CombatResolver.CombatResult drives the view's Damage Dealt readout/labels
## correctly, the headless instant-playback path fires `finished` exactly
## once synchronously (same pattern combat_screen.gd's `instant_playback`
## already relies on for its own tests), and the view never touches the real
## BuildState singleton -- it has no reference to it at all, unlike every
## other Training Room panel which is explicitly parameterized away from
## BuildState.
## Run with:
##   godot --headless -s res://tests/training_room_combat_view_test.gd


var _failed := false
var _finished_count := 0


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	var real_gold_before: int = build_state.gold

	var view := TrainingRoomCombatView.new()
	root.add_child(view)
	await process_frame
	view.finished.connect(func(): _finished_count += 1)

	_check_damage_readout(view)
	_check_realtime_status_readout(view)
	# A frame between checks that spawn/free popups: play() only
	# queue_free()s the previous fight's popups, which stay in
	# get_children() until the next idle frame (same well-known Godot quirk
	# available_skills_panel.gd's own _refresh() documents) -- without this,
	# the next check's popup count would include stale ones from this fight.
	await process_frame
	_check_no_popup_for_zero_stack_ticks(view)
	await process_frame
	_check_legendary_proc_popup_highlight(view)

	print("real BuildState.gold unchanged (expect %d): %d" % [real_gold_before, build_state.gold])
	_require(build_state.gold == real_gold_before, "TrainingRoomCombatView must never touch the real BuildState.")

	if _failed:
		print("Training Room combat view check: FAILED")
		quit(1)
	else:
		print("Training Room combat view check: OK")
		quit()


## Returns [CombatResolver.CombatResult, Monster] -- GDScript has no tuple
## return, so this is a plain 2-element Array the callers index into.
## `monster.hp` is left at its default (0) -- Training Room's own view never
## reads it (post-R10 UI-feedback pass removed the HP concept entirely), it
## only exists on Monster at all for the shared CombatResolver/
## CombatResultFormatter API.
func _known_result() -> Array:
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var rending_slash: Skill = load("res://data/skills/rending_slash.tres")
	var rotation: Array[Skill] = [poison_strike, rending_slash]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 5.0
	var monster := Monster.new()
	monster.display_name = "Playback Dummy"
	monster.armor = 0
	monster.poison_resistance = 0.0
	var result := CombatResolver.resolve(rotation, player, monster, 8000, 3)
	return [result, monster]


func _check_damage_readout(view: TrainingRoomCombatView) -> void:
	print("-- Damage Dealt readout accumulates to the fight's total damage, finished fires once --")
	var result_and_monster: Array = _known_result()
	var result: CombatResolver.CombatResult = result_and_monster[0]
	var monster: Monster = result_and_monster[1]
	var before_count := _finished_count
	view.play(result, monster)
	print("finished signal fired once (expect true): %s" % (_finished_count == before_count + 1))
	_require(_finished_count == before_count + 1, "Expected exactly one finished emission per play() in instant mode.")

	var expected_text := "Damage: %.1f" % result.total_damage
	print("damage label=%s (expect %s)" % [view._damage_label.text, expected_text])
	_require(view._damage_label.text == expected_text, "Damage readout should end at the fight's total damage.")
	_require(view._name_label.text == monster.display_name, "Name label should show the target's display name.")


## User-requested: armor/poison-resist/poison-stacks should be visible and
## change live during the fight, like Adventure mode's HUD
## (combat_screen.gd's _update_playback_hud_readout()). Rending Slash
## reduces armor by 20/cast (persists, so _armor_reduced must end up > 0
## for any multi-cast fight); Poison Strike applies 1 poison stack/cast but
## each poison tick then *consumes* one stack (CombatResolver.resolve()),
## so unlike armor reduction, the final _stacks value isn't simply "> 0" --
## it's whatever an independent replay of the same merged timeline says it
## should be, which _expected_final_stacks() computes separately from the
## view under test so this isn't just restating the same code.
func _check_realtime_status_readout(view: TrainingRoomCombatView) -> void:
	print("-- Real-time armor/resist/poison-stacks readout updates during the fight --")
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var rending_slash: Skill = load("res://data/skills/rending_slash.tres")
	var rotation: Array[Skill] = [poison_strike, rending_slash]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	var monster := Monster.new()
	monster.display_name = "Armored Dummy"
	monster.hp = 100000
	monster.armor = 200
	monster.poison_resistance = 0.3
	var result := CombatResolver.resolve(rotation, player, monster, 8000, 3)
	_require(not result.cast_events.is_empty(), "Expected casts in this known fight.")
	var expected_stacks := _expected_final_stacks(result)

	view.play(result, monster)
	print("armor_reduced=%d (expect > 0), stacks=%d (expect %d, an independent replay)" % [
		view._armor_reduced, view._stacks, expected_stacks
	])
	_require(view._armor_reduced > 0, "Rending Slash should have reduced armor at least once.")
	_require(view._stacks == expected_stacks, "Stacks should reflect ticks consuming them, not just casts accumulating them.")

	print("info label (expect base armor 200, unreduced): %s" % view._info_label.text)
	_require(view._info_label.text.contains("Armor: 200"), "Info label should show base armor, not the reduced value.")

	var chip_texts: PackedStringArray = []
	for child in view._status_row.get_children():
		chip_texts.append(child.text)
	print("status chips: %s" % [chip_texts])
	var has_poison_chip := false
	var has_armor_chip := false
	for chip_text in chip_texts:
		if chip_text.begins_with("Poison x"):
			has_poison_chip = true
		if chip_text.begins_with("Armor -"):
			has_armor_chip = true
	_require(has_poison_chip == (expected_stacks > 0), "Poison chip should be present iff stacks are currently active.")
	_require(has_armor_chip, "Expected an Armor reduction chip.")


## Independently replays the same merged cast/tick timeline
## TrainingRoomCombatView itself plays, using CombatPlayback's own
## time-ordered merge (CombatPlayback._merge_events()) so this is a real
## cross-check of the view's bookkeeping, not a restatement of its code.
func _expected_final_stacks(result: CombatResolver.CombatResult) -> int:
	var events: Array = CombatPlayback._merge_events(result)
	var stacks := 0
	for event in events:
		if event.is_tick:
			stacks = event.tick.stacks_remaining
		else:
			stacks = mini(stacks + event.cast.poison_stacks_applied, CombatResolver.MAX_POISON_STACKS)
	return stacks


## User-reported: the poison cadence beat still fires every 1000ms even with
## zero active stacks (CombatResolver.resolve()'s documented "fixed cadence
## independent of cast timing" behavior), always at 0 damage --
## CombatResultFormatter already treats these as noise and skips them in the
## text log; the popup must too, instead of showing a "Poison 0.0" popup
## with nothing actually happening. Stab has no poison effect at all, so
## every tick in this fight is a guaranteed zero-stack cadence beat.
func _check_no_popup_for_zero_stack_ticks(view: TrainingRoomCombatView) -> void:
	print("-- No popup for a poison tick with zero active stacks --")
	var stab: Skill = load("res://data/skills/stab.tres")
	var rotation: Array[Skill] = [stab]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	var monster := Monster.new()
	monster.display_name = "Unpoisoned Dummy"
	monster.hp = 100000
	var result := CombatResolver.resolve(rotation, player, monster, 8000, 5)
	_require(not result.tick_events.is_empty(), "Expected cadence ticks to fire even with no poison skill.")
	var any_nonzero_tick := false
	for tick in result.tick_events:
		if tick.damage > 0.0:
			any_nonzero_tick = true
	_require(not any_nonzero_tick, "Test setup error: expected every tick to be a zero-stack cadence beat.")

	view.play(result, monster)
	var poison_popups := 0
	for child in view._popup_layer.get_children():
		# Exclude nodes already queue_free()'d by a *previous* check's
		# play() -- they linger in get_children() until the next idle frame
		# (is_queued_for_deletion() is the robust check, not frame timing).
		if child.is_queued_for_deletion():
			continue
		if child is Label and child.text.begins_with("Poison"):
			poison_popups += 1
	print("poison popups spawned for an all-zero-stack fight (expect 0): %d" % poison_popups)
	_require(poison_popups == 0, "A zero-damage poison tick must not spawn a popup.")


## User-requested: a Legendary effect actually firing (Bejeweled Push
## Dagger's minimum-cast-time proc here) should be visually distinct in the
## combat animation, not read identically to an ordinary hit. Forces the
## proc chance to 1.0 so every cast is guaranteed to trigger it.
func _check_legendary_proc_popup_highlight(view: TrainingRoomCombatView) -> void:
	print("-- Legendary proc (minimum-cast-time) gets a highlighted popup --")
	var stab: Skill = load("res://data/skills/stab.tres")
	var rotation: Array[Skill] = [stab]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.min_cast_time_proc_chance = 1.0
	var monster := Monster.new()
	monster.display_name = "Proc Dummy"
	monster.hp = 100000
	var result := CombatResolver.resolve(rotation, player, monster, 4000, 1)
	_require(not result.cast_events.is_empty(), "Expected casts in this known fight.")
	for cast in result.cast_events:
		_require(cast.min_cast_time_proc_applied, "Test setup error: expected every cast to proc at 100% chance.")

	view.play(result, monster)
	var found_magic_proc_popup := false
	for child in view._popup_layer.get_children():
		if child is Label and child.text.ends_with("PROC!"):
			var color: Color = child.get_theme_color("font_color")
			if color == UIColors.TEXT_MAGIC:
				found_magic_proc_popup = true
	print("found a magic-colored PROC! popup (expect true): %s" % found_magic_proc_popup)
	_require(found_magic_proc_popup, "Expected at least one magic-colored 'PROC!' popup for the guaranteed proc.")

	var log_text := CombatResultFormatter.format(result, monster)
	print("combat log marks the proc line (expect true): %s" % log_text.contains(">>> "))
	_require(log_text.contains(">>> "), "Expected the '>>> ' legendary-proc marker in the text log.")
	_require(log_text.contains("procs at minimum cast speed"), "Expected the proc clause in the text log.")


func _require(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		print("FAILED: %s" % message)
