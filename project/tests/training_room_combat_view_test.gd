extends SceneTree
## Headless check for TrainingRoomCombatView (Practice Room's own animated
## combat area, user-requested "combat area, like Adventure mode"): a known
## CombatResolver.CombatResult drives the view's Damage Dealt readout/labels
## correctly, the headless instant-playback path fires `finished` exactly
## once synchronously (same pattern combat_screen.gd's `instant_playback`
## already relies on for its own tests), and the view never touches the real
## BuildState singleton -- it has no reference to it at all, unlike every
## other Practice Room panel which is explicitly parameterized away from
## BuildState.
## Run with:
##   godot --headless -s res://tests/training_room_combat_view_test.gd


const HUD_ARMOR_ICON := preload("res://assets/combat_ui_icons/enemy_armor.png")
const HUD_RESISTANCE_ICON := preload("res://assets/combat_ui_icons/resistance.png")
const HUD_POISON_ICON := preload("res://assets/combat_ui_icons/poison_stack.png")
const HUD_SHRED_ICON := preload("res://assets/combat_ui_icons/shred.png")
const HUD_DECAY_ICON := preload("res://assets/combat_ui_icons/decay.png")

var _failed := false
var _finished_count := 0


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	var real_gold_before: int = build_state.gold

	var view := TrainingRoomCombatView.new()
	root.add_child(view)
	await process_frame
	view.finished.connect(func(): _finished_count += 1)

	_check_initial_practice_target_sprite(view)
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
	_check_poison_stack_application_tints_enemy_without_popup(view)
	await process_frame
	_check_popup_for_damaging_poison_ticks(view)
	await process_frame
	_check_wyvern_kriss_uses_smaller_poison_tick_text(view)
	await process_frame
	_check_legendary_proc_popup_highlight(view)
	await process_frame
	_check_crit_popup_highlight(view)
	await process_frame
	await _check_realtime_intro_gates_timeline(view)
	await process_frame
	_check_skip_bypasses_realtime_outcome_hold(view)

	print("real BuildState.gold unchanged (expect %d): %d" % [real_gold_before, build_state.gold])
	_require(build_state.gold == real_gold_before, "TrainingRoomCombatView must never touch the real BuildState.")

	if _failed:
		print("Practice Room combat view check: FAILED")
		quit(1)
	else:
		print("Practice Room combat view check: OK")
	quit()


func _check_initial_practice_target_sprite(view: TrainingRoomCombatView) -> void:
	print("-- Initial Practice Room stage shows the Practice Target sprite --")
	_require(view._combat_stage != null, "Expected Practice Room combat view to own a stage layer before playback.")
	_require(view._combat_stage._enemy_name_label.text == "Practice Target", "Expected initial Practice Room stage enemy label to be Practice Target, not the default Enemy card.")
	_require(not view._combat_stage.debug_grid_visible, "Expected Practice Room to hide the combat-stage debug grid now that sprite placement tuning is done.")
	_require(view._combat_stage.enemy_sprite_available(), "Expected initial Practice Room stage to show the imported Practice Target sprite.")
	_require(view._combat_stage._enemy_sprite.size == Vector2(32, 32), "Expected Practice Target sprite rect to stay at one 32px training-dummy frame, not stretch to the actor box.")
	_require(view._combat_stage._enemy_sprite.scale == Vector2(view._combat_stage.PRACTICE_DUMMY_SPRITE_SCALE, view._combat_stage.PRACTICE_DUMMY_SPRITE_SCALE), "Expected Practice Target sprite to use the smaller Practice dummy scale.")
	var dummy_anchor_y: float = view._combat_stage._sprite_anchor_point(view._combat_stage.enemy_actor_anchor, view._combat_stage._enemy_sprite, view._combat_stage.PRACTICE_DUMMY_ANCHOR_POINT).y
	var shadow_center_y: float = view._combat_stage.enemy_actor_anchor.position.y + view._combat_stage._enemy_contact_shadow.position.y + view._combat_stage._enemy_contact_shadow.size.y * 0.5
	_require(dummy_anchor_y > shadow_center_y + 10.0, "Expected Practice Target art to be lowered while its contact shadow stays on the shared floor line.")
	_require(view._damage_label.text == "Damage: 0.0", "Expected initial Practice Room damage readout to be visible before fighting.")
	_require(view._info_label.text == "0", "Expected initial Practice Room armor readout to be visible before fighting.")
	_require(view._resist_label.text == "0%", "Expected initial Practice Room poison resistance readout to be visible before fighting.")
	_require(view._status_row.alignment == BoxContainer.ALIGNMENT_END, "Expected Practice Room status chips to align to the right like Adventure.")
	var initial_chips: PackedStringArray = []
	for child in view._status_row.get_children():
		initial_chips.append(_status_chip_text(child))
	_require(initial_chips == PackedStringArray(["x0", "x0", "x0"]), "Expected initial Practice Room poison/Shred/Decay chips to be visible at x0.")


## Returns [CombatResolver.CombatResult, Monster] -- GDScript has no tuple
## return, so this is a plain 2-element Array the callers index into.
## `monster.hp` is left at its default (0) -- Practice Room's own view never
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
	monster.display_name = "Practice Target"
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


func _check_realtime_intro_gates_timeline(view: TrainingRoomCombatView) -> void:
	print("-- Realtime Practice Room playback waits for the shared fight intro --")
	var result_and_monster: Array = _known_result()
	var result: CombatResolver.CombatResult = result_and_monster[0]
	var monster: Monster = result_and_monster[1]
	monster.hp = 60
	var before_count := _finished_count
	view._instant_playback = false
	view.play(result, monster)
	_require(_finished_count == before_count, "Expected realtime Practice Room playback not to finish synchronously.")
	_require(view._controls_row.visible, "Expected realtime Practice Room playback controls to stay visible during playback.")
	_require(view._playback_intro_remaining_sec > 0.0, "Expected realtime Practice Room playback to begin with an intro delay.")
	_require(view._combat_stage.fight_intro_count == 1, "Expected Practice Room to request one shared fight intro from the stage.")
	_require(view._playback.events_fired() == 0, "Expected no Practice Room events to fire before the intro advances.")

	view._process(view._playback_intro_duration_sec * 0.5)
	_require(view._playback.events_fired() == 0, "Expected Practice Room events to stay gated during the intro.")
	_require(is_equal_approx(view._playback.elapsed_ms(), 0.0), "Expected Practice Room combat time to stay at zero during the intro.")
	_require(_finished_count == before_count, "Expected Practice Room playback not to finish during the intro.")

	view._process(view._playback_intro_remaining_sec + result.duration_ms / 1000.0 + 0.1)
	_require(_finished_count == before_count, "Expected realtime Practice Room playback to hold briefly before emitting finished.")
	_require(view._playback == null, "Expected Practice Room playback to clear itself before the final hold.")
	_require(view._combat_stage.outcome_pose == "", "Expected Practice Room to return to idle instead of showing a win/loss pose.")
	_require(view._combat_stage.outcome_flash_count == 0, "Expected Practice Room to avoid Adventure-style outcome flashes.")
	_require(not view._controls_row.visible, "Expected controls hidden during the Practice Room final hold.")

	await create_timer(view.OUTCOME_REVEAL_HOLD_SEC + 0.05).timeout
	_require(_finished_count == before_count + 1, "Expected realtime Practice Room playback to emit finished after the outcome hold.")
	view._instant_playback = DisplayServer.get_name() == "headless"
	_require(view._combat_stage != null, "Expected Practice Room combat view to own a stage layer.")
	_require(view._combat_stage.player_actor_anchor != null, "Expected a player actor anchor in Practice Room.")
	_require(view._combat_stage.enemy_actor_anchor != null, "Expected an enemy actor anchor in Practice Room.")
	_require(view._combat_stage.player_actor_anchor.z_index > view._combat_stage.enemy_actor_anchor.z_index, "Expected Rogue to render above the Practice dummy during overlapping swings.")
	_require(view._combat_stage.contact_effect_anchor != null, "Expected a contact effect anchor in Practice Room.")
	_require(view._combat_stage.floating_text_anchor != null, "Expected a floating text anchor in Practice Room.")
	_require(view._combat_stage._enemy_name_label.text == monster.display_name, "Expected the Practice Room stage enemy actor label to track the target.")
	_require(view._combat_stage.player_actor_anchor.get_node_or_null("PlayerSprite") != null, "Expected Practice Room to expose a configured player sprite slot.")
	_require(view._combat_stage.enemy_actor_anchor.get_node_or_null("EnemySprite") != null, "Expected Practice Room to expose a configured enemy sprite slot.")
	_require(view._combat_stage.enemy_sprite_available(), "Expected Practice Room Practice Target to use the imported training dummy sprite.")
	_require(
		view._combat_stage.expected_enemy_sprite_paths("Practice Target").has("res://assets/characters/practice_dummy/dummy_bounce/frames/frame_001.png"),
		"Expected Practice Target idle to use the imported training dummy frame."
	)
	_require(
		view._combat_stage.expected_enemy_sprite_region("Practice Target", "idle") == Rect2(Vector2(0, 0), Vector2(32, 32)),
		"Expected Practice Target idle to use a full 32px training dummy frame in Practice Room."
	)


func _check_skip_bypasses_realtime_outcome_hold(view: TrainingRoomCombatView) -> void:
	print("-- Realtime Practice Room skip reveals outcome immediately --")
	var result_and_monster: Array = _known_result()
	var result: CombatResolver.CombatResult = result_and_monster[0]
	var monster: Monster = result_and_monster[1]
	monster.hp = 60
	var before_count := _finished_count
	view._instant_playback = false
	view.play(result, monster)
	_require(_finished_count == before_count, "Expected realtime Practice Room playback to be active before skip.")
	_require(view._controls_row.visible, "Expected controls visible before Practice Room skip.")
	var before_reaction_count: int = view._combat_stage.practice_dummy_reaction_count

	view._skip_button.pressed.emit()
	_require(_finished_count == before_count + 1, "Expected Practice Room skip to emit finished immediately.")
	_require(view._playback == null, "Expected Practice Room skip to clear playback.")
	_require(not view._controls_row.visible, "Expected Practice Room controls hidden after skip.")
	_require(view._combat_stage.outcome_pose == "", "Expected Practice Room skip to return both actors to idle, not a win/loss pose.")
	_require(view._combat_stage.outcome_flash_count == 0, "Expected Practice Room skip to avoid Adventure-style outcome flashes.")
	_require(view._combat_stage.practice_dummy_reaction_count > before_reaction_count, "Expected damaging Practice Room hits to request a random training dummy reaction.")
	_require(view._combat_stage.last_practice_dummy_reaction_frame_count >= 4, "Expected the random training dummy reaction to include multiple animation frames.")
	_require(view._combat_stage.enemy_sprite_available(), "Expected the training dummy to stay visible after reaction frames are flushed.")
	_require(view._combat_stage.enemy_actor_anchor.position == view._combat_stage._enemy_base_position, "Expected training dummy reactions to avoid old humanoid recoil movement.")
	view._instant_playback = DisplayServer.get_name() == "headless"


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
	var beguiling_strike: Skill = load("res://data/skills/beguiling_strike.tres")
	var rotation: Array[Skill] = [poison_strike, rending_slash, beguiling_strike]
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

	var expected_current_armor := monster.armor - view._armor_reduced
	print("armor value label (expect current armor %d): %s" % [expected_current_armor, view._info_label.text])
	_require(view._info_label.text == "%d" % expected_current_armor, "Shield-labeled armor value should show current armor after Shred.")
	_require(view._info_label.get_parent().get_node_or_null("ArmorIcon") != null, "Expected the Practice Room combat window's armor readout to include the shield icon.")
	_require(view._resist_label.text == "%.0f%%" % (view._resist * 100.0), "Resistance value should show current poison resistance after Decay.")
	var resist_icon := view._resist_label.get_parent().get_node_or_null("PoisonResistIcon") as TextureRect
	_require(resist_icon != null and resist_icon.texture == HUD_RESISTANCE_ICON, "Expected the Practice Room combat window's poison resistance readout to include the resistance icon.")

	var chip_texts: PackedStringArray = []
	for child in view._status_row.get_children():
		chip_texts.append(_status_chip_text(child))
	print("status chips: %s" % [chip_texts])
	var has_poison_chip := false
	var has_shred_chip := false
	var has_decay_chip := false
	var has_poison_icon := false
	var has_shred_icon := false
	var has_decay_icon := false
	for child in view._status_row.get_children():
		var icon := child.get_node_or_null("Icon") as TextureRect
		var text := _status_chip_text(child)
		if icon != null and icon.texture == HUD_POISON_ICON and text == "x%d" % view._stacks:
			has_poison_chip = true
			has_poison_icon = true
		if icon != null and icon.texture == HUD_SHRED_ICON and text == "x%d" % view._shred_stacks:
			has_shred_chip = true
			has_shred_icon = true
		if icon != null and icon.texture == HUD_DECAY_ICON and text == "x%d" % view._decay_stacks:
			has_decay_chip = true
			has_decay_icon = true
	_require(has_poison_chip, "Poison chip should stay visible even at x0.")
	_require(has_shred_chip, "Expected a Shred stack chip.")
	_require(has_decay_chip, "Expected a Decay stack chip.")
	_require(has_poison_icon, "Poison stack chip should use the selected skull icon.")
	_require(has_shred_icon, "Shred chip should use the selected rogue icon.")
	_require(has_decay_icon, "Decay chip should use the selected mage icon.")
	_require(_status_chip_font_size(view._status_row, HUD_POISON_ICON) == 24, "Expected Practice Room combat status values to use the larger number font.")


func _status_chip_text(chip: Node) -> String:
	if chip is Label:
		return chip.text
	var label := chip.get_node_or_null("Text") as Label
	if label != null:
		return label.text
	return ""


func _status_chip_font_size(row: HBoxContainer, icon_texture: Texture2D) -> int:
	for child in row.get_children():
		var icon := child.get_node_or_null("Icon") as TextureRect
		var label := child.get_node_or_null("Text") as Label
		if icon != null and icon.texture == icon_texture and label != null:
			return label.get_theme_font_size("font_size")
	return 0


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


func _check_popup_for_damaging_poison_ticks(view: TrainingRoomCombatView) -> void:
	print("-- Damaging poison tick spawns green half-size poison text near the enemy --")
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var rotation: Array[Skill] = [poison_strike]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.poison_damage_per_tick = 5.0
	var monster := Monster.new()
	monster.display_name = "Poisoned Dummy"
	monster.hp = 100000
	monster.poison_resistance = 0.0
	var result := CombatResolver.resolve(rotation, player, monster, 4500, 3)
	_require(result.tick_events.any(func(tick): return tick.damage > 0.0), "Test setup error: expected at least one damaging poison tick.")

	view.play(result, monster)
	var found_poison_popup := false
	var found_enemy_centered_popup := false
	var enemy_local: Vector2 = view._popup_layer.get_global_transform().affine_inverse() * view._combat_stage.enemy_popup_global_position()
	for child in view._popup_layer.get_children():
		if child.is_queued_for_deletion():
			continue
		if child is Label and child.text.begins_with("Poison"):
			var color: Color = child.get_theme_color("font_color")
			var font_size: int = child.get_theme_font_size("font_size")
			if color == UIColors.TEXT_POISON and font_size == view.POPUP_TICK_FONT_SIZE:
				found_poison_popup = true
				var popup_center: Vector2 = child.position + child.size * 0.5
				if popup_center.distance_to(enemy_local) <= 48.0:
					found_enemy_centered_popup = true
	print("found a green half-size poison popup for damaging poison tick (expect true): %s" % found_poison_popup)
	_require(found_poison_popup, "A damaging poison tick should spawn green half-size poison text.")
	_require(found_enemy_centered_popup, "Poison tick text should stay tightly centered on the enemy.")


func _check_wyvern_kriss_uses_smaller_poison_tick_text(view: TrainingRoomCombatView) -> void:
	print("-- Wyvern Kriss uses smaller poison tick text --")
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var wyvern_kriss: GearItem = load("res://data/gear/wyvern_kriss.tres")
	var rotation: Array[Skill] = [poison_strike]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.poison_damage_per_tick = 5.0
	var monster := Monster.new()
	monster.display_name = "Wyvern Poison Dummy"
	monster.hp = 100000
	monster.poison_resistance = 0.0
	var result := CombatResolver.resolve(rotation, player, monster, 4500, 3)
	_require(result.tick_events.any(func(tick): return tick.damage > 0.0), "Test setup error: expected at least one damaging poison tick.")

	var equipped_gear: Array[GearItem] = [wyvern_kriss]
	view.play(result, monster, equipped_gear)
	var found_wyvern_tick_popup := false
	for child in view._popup_layer.get_children():
		if child.is_queued_for_deletion():
			continue
		if child is Label and child.text.begins_with("Poison"):
			var color: Color = child.get_theme_color("font_color")
			var font_size: int = child.get_theme_font_size("font_size")
			if color == UIColors.TEXT_POISON and font_size == view.POPUP_WYVERN_TICK_FONT_SIZE:
				found_wyvern_tick_popup = true
	print("found smaller Wyvern poison tick popup (expect true): %s" % found_wyvern_tick_popup)
	_require(found_wyvern_tick_popup, "Wyvern Kriss should make poison tick text smaller than the default poison tick popup.")


func _check_poison_stack_application_tints_enemy_without_popup(view: TrainingRoomCombatView) -> void:
	print("-- Poison stack application tints the enemy without floating stack text --")
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var rotation: Array[Skill] = [poison_strike]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.poison_damage_per_tick = 5.0
	var monster := Monster.new()
	monster.display_name = "Poison Stack Dummy"
	monster.hp = 100000
	monster.poison_resistance = 0.0
	var result := CombatResolver.resolve(rotation, player, monster, 2200, 3)
	_require(result.cast_events.any(func(cast): return cast.poison_stacks_applied > 0), "Test setup error: expected at least one poison-applying cast.")

	view.play(result, monster)
	_require(view._combat_stage.poison_stack_tint_updates > 0, "Expected poison-applying casts to update the shared poison tint.")
	_require(view._combat_stage.last_poison_stack_tint_stacks >= 0, "Expected shared poison tint to record the active stack count.")
	var found_stack_popup := false
	for child in view._popup_layer.get_children():
		if child.is_queued_for_deletion():
			continue
		if child is Label and child.text.begins_with("Poison x"):
			found_stack_popup = true
	print("found a poison-stack popup (expect false): %s" % found_stack_popup)
	_require(not found_stack_popup, "Poison stack counts should stay in the UI chips, not spawn floating text.")


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


func _check_crit_popup_highlight(view: TrainingRoomCombatView) -> void:
	print("-- Crit gets a gold, larger popup without literal CRIT text in Practice Room playback --")
	var stab: Skill = load("res://data/skills/stab.tres")
	var rotation: Array[Skill] = [stab]
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 1.0
	player.crit_multiplier = 2.0
	var monster := Monster.new()
	monster.display_name = "Crit Dummy"
	monster.hp = 100000
	var result := CombatResolver.resolve(rotation, player, monster, 2200, 1)
	_require(not result.cast_events.is_empty(), "Expected casts in this known crit fight.")
	for cast in result.cast_events:
		_require(cast.is_crit, "Test setup error: expected every cast to crit at 100% chance.")

	view.play(result, monster)
	var found_gold_crit_popup := false
	for child in view._popup_layer.get_children():
		if child is Label and child.text.ends_with("!") and not child.text.contains("CRIT"):
			var color: Color = child.get_theme_color("font_color")
			var font_size: int = child.get_theme_font_size("font_size")
			var font: Font = child.get_theme_font("font")
			if color == UIColors.TEXT_GOLD and font_size == view.POPUP_CRIT_FONT_SIZE and font == view.POPUP_FONT:
				found_gold_crit_popup = true
	print("found a gold larger crit popup without literal CRIT text (expect true): %s" % found_gold_crit_popup)
	_require(found_gold_crit_popup, "Expected at least one gold, larger crit popup using color/size/font instead of literal 'CRIT' text.")


func _require(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		print("FAILED: %s" % message)
