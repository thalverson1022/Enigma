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


const HUD_ARMOR_ICON := preload("res://assets/combat_ui_icons/enemy_armor.png")
const HUD_RESISTANCE_ICON := preload("res://assets/combat_ui_icons/resistance.png")
const HUD_POISON_ICON := preload("res://assets/combat_ui_icons/poison_stack.png")
const HUD_SHRED_ICON := preload("res://assets/combat_ui_icons/shred.png")
const HUD_DECAY_ICON := preload("res://assets/combat_ui_icons/decay.png")

var _failed := false


func _initialize() -> void:
	await _check_post_fight_helpers_against_known_fight()
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
	var expected_shred_stacks := 0
	var expected_decay_stacks := 0
	var expected_resist := monster.poison_resistance
	for event in result.cast_events:
		expected_armor_reduction += event.armor_reduction_applied
		if event.armor_reduction_applied > 0:
			expected_shred_stacks += 1
		if event.poison_resistance_reduction_applied > 0.0:
			expected_decay_stacks += 1
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
	await process_frame
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

	combat_screen._show_enemy_hud_post_fight(result, monster)
	var has_poison_icon := false
	var has_shred_icon := false
	var has_decay_icon := false
	for child in combat_screen._hud_status_row.get_children():
		var icon := child.get_node_or_null("Icon") as TextureRect
		var text := _status_chip_text(child)
		if icon != null and icon.texture == HUD_POISON_ICON and text == "x%d" % peak_stacks:
			has_poison_icon = true
		if icon != null and icon.texture == HUD_SHRED_ICON and text == "x%d" % expected_shred_stacks:
			has_shred_icon = true
		if icon != null and icon.texture == HUD_DECAY_ICON and text == "x%d" % expected_decay_stacks:
			has_decay_icon = true
	_require(has_poison_icon, "Expected the post-fight poison stack chip to use the selected skull icon.")
	_require(has_shred_icon, "Expected the post-fight Shred chip to use the selected rogue icon and count applications.")
	_require(has_decay_icon, "Expected the post-fight Decay chip to use the selected mage icon and count applications.")
	_require(combat_screen._hud_info_label.text == "%d" % final_armor, "Expected post-fight armor value to show current armor after Shred.")
	_require(combat_screen._hud_resist_label.text == "%.0f%%" % (final_resist * 100.0), "Expected post-fight resistance value to show current resistance after Decay.")

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
	_require(combat_screen._hud_hp_text_label.text == "%d/%d" % [monster.hp, monster.hp], "Expected icon-labeled full HP value pre-fight.")
	_require(combat_screen._hud_hp_text_label.get_parent().get_node_or_null("HealthIcon") != null, "Expected the HP text to include the selected heart icon.")
	_require(combat_screen._hud_hp_text_label.get_parent().name == "CombatValuesRow", "Expected HP, armor, and resistance values grouped in the top-right combat HUD row.")
	_require(is_equal_approx(combat_screen._hud_health_bar.value, float(monster.hp)), "Expected a full health bar pre-fight.")
	_require(is_equal_approx(combat_screen._hud_health_bar.max_value, float(monster.hp)), "Expected the health bar max to be monster HP.")
	_require(combat_screen._hud_health_bar.custom_minimum_size.y >= 18.0, "Expected the combat HP bar to use the deeper beveled height.")
	_require(combat_screen._hud_health_bar.get_theme_stylebox("background").border_color == UIColors.HEALTH_BAR_TRACK_BORDER, "Expected the combat HP bar track to use the shared gold-edged treatment.")
	_require(combat_screen._hud_health_bar.get_node_or_null("HealthBarDepthOverlay") != null, "Expected the combat HP bar to include its drawn bevel overlay.")
	_require(
		combat_screen._hud_info_label.text == "%d" % monster.armor,
		"Expected the shield-labeled pre-fight armor value to show base armor."
	)
	_require(combat_screen._hud_info_label.get_parent().get_node_or_null("ArmorIcon") != null, "Expected the armor readout to include the selected shield icon.")
	_require(combat_screen._hud_resist_label.text == "%.0f%%" % (monster.poison_resistance * 100.0), "Expected the skull-labeled pre-fight poison resistance value.")
	var resist_icon := combat_screen._hud_resist_label.get_parent().get_node_or_null("PoisonResistIcon") as TextureRect
	_require(resist_icon != null and resist_icon.texture == HUD_RESISTANCE_ICON, "Expected the poison resistance readout to include the selected resistance icon.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_POISON_ICON, "x0"), "Expected Poison stack chip to stay visible at x0 pre-fight.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_SHRED_ICON, "x0"), "Expected Shred stack chip to stay visible at x0 pre-fight.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_DECAY_ICON, "x0"), "Expected Decay stack chip to stay visible at x0 pre-fight.")
	_require(combat_screen._hud_status_row.alignment == BoxContainer.ALIGNMENT_END, "Expected debuff stack chips to sit right-aligned below the health bar.")
	_require(_status_chip_font_size(combat_screen._hud_status_row, HUD_POISON_ICON) == 24, "Expected combat status values to use the larger number font.")
	_require(combat_screen._fight_timer_badge != null and combat_screen._fight_timer_badge.visible, "Expected a raised fight-window timer badge once a target is selected.")
	_require(combat_screen._fight_timer_badge.get_parent().name == "FightTimerCell", "Expected the fight-window timer badge to sit in the HUD top row above the health bar.")
	_require(combat_screen._fight_timer_badge.find_child("ClockIcon", true, false) != null, "Expected the fight-window timer badge to include the clock icon.")
	_require(combat_screen._fight_timer_label.text == "%ds" % ceili(float(fight_enemy_panel.duration_ms()) / 1000.0), "Expected the fight-window timer badge to show the current target duration before combat.")
	var playback_label := combat_screen._playback_controls.find_child("PlaybackLabel", true, false) as Label
	_require(playback_label != null, "Expected the combat playback controls to include a descriptive label.")
	_require(playback_label.text == "playback:", "Expected the combat playback controls label to read playback:.")
	_require(
		playback_label.get_theme_font_size("font_size") == combat_screen._hud_name_label.get_theme_font_size("font_size"),
		"Expected the playback label to match the enemy-name font size."
	)
	_require(combat_screen._playback_controls._speed_buttons[0].disabled, "Expected 1x to be auto-selected as the default playback speed.")
	_require(combat_screen._combat_stage != null, "Expected the combat window to own a stage layer.")
	_require(combat_screen._combat_stage.player_actor_anchor != null, "Expected a player actor anchor on the combat stage.")
	_require(combat_screen._combat_stage.enemy_actor_anchor != null, "Expected an enemy actor anchor on the combat stage.")
	_require(combat_screen._combat_stage.contact_effect_anchor != null, "Expected a contact effect anchor on the combat stage.")
	_require(combat_screen._combat_stage.floating_text_anchor != null, "Expected a floating text anchor on the combat stage.")
	_require(not combat_screen._combat_stage.debug_grid_visible, "Expected Adventure combat to keep the sprite-placement debug grid hidden.")
	_require(combat_screen._combat_stage._enemy_name_label.text == monster.display_name, "Expected the combat stage enemy actor label data to track the current target.")
	_require(not combat_screen._combat_stage._enemy_name_label.visible, "Expected Adventure combat to hide the enemy name inside the combat window.")
	_require(combat_screen._combat_stage.player_actor_anchor.get_node_or_null("PlayerSprite") != null, "Expected the combat stage to expose a configured player sprite slot.")
	_require(combat_screen._combat_stage.enemy_actor_anchor.get_node_or_null("EnemySprite") != null, "Expected the combat stage to expose a configured enemy sprite slot.")
	var expected_player_paths: PackedStringArray = combat_screen._combat_stage.expected_player_sprite_paths()
	var expected_enemy_paths: PackedStringArray = combat_screen._combat_stage.expected_enemy_sprite_paths(monster.display_name)
	_require(expected_player_paths.has("res://assets/placeholder_combat_sprites/rogue_bandit/animations/idle/frames/frame_001.png"), "Expected normalized Rogue idle frame import path configured.")
	_require(expected_player_paths.has("res://assets/placeholder_combat_sprites/rogue_bandit/animations/attack1/frames/frame_001.png"), "Expected normalized Rogue physical attack frame import path configured.")
	_require(expected_player_paths.has("res://assets/placeholder_combat_sprites/rogue_bandit/animations/attack2/frames/frame_001.png"), "Expected normalized Rogue poison attack frame import path configured.")
	_require(expected_enemy_paths.has("res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png"), "Expected Mouthy Drunk peasant sprite sheet import path configured.")
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region(monster.display_name, "idle") == Rect2(Vector2(0, 0), Vector2(32, 32)),
		"Expected Mouthy Drunk idle to use the top-left peasant standing frame."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region(monster.display_name, "hurt") == Rect2(Vector2(0, 64), Vector2(32, 32)),
		"Expected Mouthy Drunk hurt to use the first arms-up recoil frame."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region(monster.display_name, "defeat") == Rect2(Vector2(0, 96), Vector2(32, 32)),
		"Expected Mouthy Drunk defeat to use the first prone frame."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_paths("Drunk Buddy").has("res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png"),
		"Expected Drunk Buddy peasant sprite sheet import path configured."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Drunk Buddy", "idle") == Rect2(Vector2(0, 256), Vector2(32, 32)),
		"Expected Drunk Buddy idle to use the first frame from peasant sheet row 9."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Drunk Buddy", "hurt") == Rect2(Vector2(0, 320), Vector2(32, 32)),
		"Expected Drunk Buddy hurt to use the first recoil frame from peasant sheet row 11."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Drunk Buddy", "defeat") == Rect2(Vector2(0, 352), Vector2(32, 32)),
		"Expected Drunk Buddy defeat to use the first prone frame from peasant sheet row 12."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_paths("Tavern Bouncer").has("res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_sprite_sheet.png"),
		"Expected Tavern Bouncer medieval townsfolk sprite sheet import path configured."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Tavern Bouncer", "idle") == Rect2(Vector2(0, 320), Vector2(32, 32)),
		"Expected Tavern Bouncer idle to use the first frame from medieval townsfolk sheet row 11."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Tavern Bouncer", "hurt") == Rect2(Vector2(0, 384), Vector2(32, 32)),
		"Expected Tavern Bouncer hurt to use the first recoil frame from medieval townsfolk sheet row 13."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Tavern Bouncer", "defeat") == Rect2(Vector2(0, 448), Vector2(32, 32)),
		"Expected Tavern Bouncer defeat to use the first prone frame from medieval townsfolk sheet row 15."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_paths("Hired Goon").has("res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_2_sprite_sheet.png"),
		"Expected Hired Goon medieval townsfolk 2 sprite sheet import path configured."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Hired Goon", "idle") == Rect2(Vector2(0, 320), Vector2(32, 32)),
		"Expected Hired Goon idle to use the first frame from medieval townsfolk 2 sheet row 11."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Hired Goon", "hurt") == Rect2(Vector2(0, 384), Vector2(32, 32)),
		"Expected Hired Goon hurt to use the first recoil frame from medieval townsfolk 2 sheet row 13."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Hired Goon", "defeat") == Rect2(Vector2(0, 448), Vector2(32, 32)),
		"Expected Hired Goon defeat to use the first prone frame from medieval townsfolk 2 sheet row 15."
	)
	var hired_goon_visual_reuse := [
		"Door Guard",
		"Cloaked Watchmen",
		"Armored Guard",
		"Sleeping Henchman",
		"Portly Cook",
		"Patrolling Guard",
		"Lazy Henchman",
		"Venom-Resistant Slime",
		"Training Dummy",
		"Placeholder Dummy",
	]
	for reused_enemy_name in hired_goon_visual_reuse:
		_require(
			combat_screen._combat_stage.expected_enemy_sprite_paths(reused_enemy_name).has("res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_2_sprite_sheet.png"),
			"Expected %s to reuse the Hired Goon medieval townsfolk 2 sprite sheet." % reused_enemy_name
		)
		_require(
			combat_screen._combat_stage.expected_enemy_sprite_region(reused_enemy_name, "idle") == Rect2(Vector2(0, 320), Vector2(32, 32)),
			"Expected %s to reuse the Hired Goon idle frame." % reused_enemy_name
		)
		_require(
			combat_screen._combat_stage.expected_enemy_sprite_region(reused_enemy_name, "hurt") == Rect2(Vector2(0, 384), Vector2(32, 32)),
			"Expected %s to reuse the Hired Goon hurt frame." % reused_enemy_name
		)
		_require(
			combat_screen._combat_stage.expected_enemy_sprite_region(reused_enemy_name, "defeat") == Rect2(Vector2(0, 448), Vector2(32, 32)),
			"Expected %s to reuse the Hired Goon defeat frame." % reused_enemy_name
		)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_paths("Vyra").has("res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_3_sprite_sheet.png"),
		"Expected Vyra medieval townsfolk 3 sprite sheet import path configured."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Vyra", "idle") == Rect2(Vector2(0, 320), Vector2(32, 32)),
		"Expected Vyra idle to use the first frame from medieval townsfolk 3 sheet row 11."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Vyra", "hurt") == Rect2(Vector2(0, 384), Vector2(32, 32)),
		"Expected Vyra hurt to use the first recoil frame from medieval townsfolk 3 sheet row 13."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Vyra", "defeat") == Rect2(Vector2(0, 448), Vector2(32, 32)),
		"Expected Vyra defeat to use the first prone frame from medieval townsfolk 3 sheet row 15."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_paths("Knives").has("res://assets/placeholder_combat_sprites/townsfolk/medieval_thief_sprite_sheet.png"),
		"Expected Knives medieval thief sprite sheet import path configured."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Knives", "idle") == Rect2(Vector2(0, 0), Vector2(32, 32)),
		"Expected Knives idle to use the first frame from medieval thief sheet row 1."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Knives", "hurt") == Rect2(Vector2(0, 160), Vector2(32, 32)),
		"Expected Knives hurt to use the first recoil frame from medieval thief sheet row 6."
	)
	_require(
		combat_screen._combat_stage.expected_enemy_sprite_region("Knives", "defeat") == Rect2(Vector2(0, 224), Vector2(32, 32)),
		"Expected Knives defeat to use the first prone frame from medieval thief sheet row 8."
	)
	_require(
		combat_screen._combat_stage.player_sprite_available() == ResourceLoader.exists("res://assets/placeholder_combat_sprites/rogue_bandit/animations/idle/frames/frame_001.png"),
		"Expected Rogue sprite availability to match whether the imported normalized idle frame exists."
	)
	_require(
		combat_screen._combat_stage.enemy_sprite_available() == ResourceLoader.exists("res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png"),
		"Expected Mouthy Drunk sprite availability to match whether the imported peasant sheet exists."
	)

	print("-- Live win HUD --")
	combat_screen.instant_playback = false
	build_state.set_locked(true)
	fight_enemy_panel.fight_pressed.emit()
	await process_frame
	_require(combat_screen._playback_active, "Expected the live win check to enter real-time playback when instant playback is disabled.")
	var timer_at_start: String = combat_screen._fight_timer_label.text
	combat_screen._process(1.0)
	await process_frame
	_require(combat_screen._fight_timer_label.text != timer_at_start, "Expected the fight-window timer badge to count down during playback.")
	_require(combat_screen._fight_timer_label.text.ends_with("s"), "Expected the live timer to continue displaying seconds.")
	combat_screen._skip_playback()
	await process_frame
	_require(not combat_screen._victory_overlay.visible, "Expected skipped wins to keep the result overlay hidden during the victory pose beat.")
	_require(combat_screen._combat_stage.outcome_pose == "victory", "Expected skipped wins to enter the enemy defeat pose before the overlay.")
	var defeated_enemy_position: Vector2 = combat_screen._combat_stage.enemy_actor_anchor.position
	combat_screen._combat_stage._layout_stage()
	_require(
		combat_screen._combat_stage.enemy_actor_anchor.position == defeated_enemy_position,
		"Expected combat-stage relayout during the reveal hold to preserve the enemy defeat pose position."
	)
	await create_timer(combat_screen.PLAYBACK_OUTCOME_REVEAL_DELAY_SEC + 0.05).timeout
	_require(build_state.last_fight_won, "Expected the Quick Cut Mouthy Drunk fight to be a win.")
	print("post-win: %s | bar %.1f/%.1f" % [combat_screen._hud_hp_text_label.text, combat_screen._hud_health_bar.value, combat_screen._hud_health_bar.max_value])
	_require(combat_screen._enemy_hud.visible, "Expected the HUD to stay visible with the victory banner up.")
	_require(combat_screen._victory_overlay.visible, "Expected skipped wins to reveal the victory overlay after the pose beat.")
	_require(combat_screen._hud_result != null, "Expected the HUD to hold the resolved fight after a win.")
	_require(is_equal_approx(combat_screen._hud_health_bar.value, 0.0), "Expected an empty health bar after a win.")
	_require(combat_screen._hud_hp_text_label.text == "0/%d" % monster.hp, "Expected icon-labeled zero HP value after a win.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_POISON_ICON, "x0"), "Expected Poison stack chip to stay visible at x0 for a pure-physical rotation.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_SHRED_ICON, "x0"), "Expected Shred stack chip to stay visible at x0 for a pure-physical rotation.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_DECAY_ICON, "x0"), "Expected Decay stack chip to stay visible at x0 for a pure-physical rotation.")

	combat_screen.queue_free()


## Live end-to-end: a guaranteed loss (real rotation against an impossible
## HP target) leaves remaining HP consistent with monster HP minus the
## result's total damage, and pressing the real Retry button resets the HUD
## back to the pre-fight display.
func _check_live_loss_and_retry_reset() -> void:
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
	build_state.set_locked(true)

	var fight_enemy_panel = combat_screen._enemy_panel
	var monster: Monster = fight_enemy_panel.monster()
	monster.hp = 100000

	print("-- Live loss HUD --")
	fight_enemy_panel.fight_pressed.emit()
	await process_frame
	_require(not build_state.last_fight_won, "Expected the impossible-HP target to guarantee a loss.")
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
	_require(combat_screen._victory_overlay.visible, "Expected the defeat overlay after a first Tavern loss.")
	_require(combat_screen._view_log_button.visible, "Expected the row Combat Log button to remain visible during defeat.")
	combat_screen._view_log_button.pressed.emit()
	_require(combat_screen._log_overlay.visible, "Expected the row Combat Log button to open the log during defeat.")
	combat_screen._log_overlay.visible = false
	_require(combat_screen._outcome_retry_button.visible, "Expected the retry button after a first Tavern loss.")
	combat_screen._outcome_retry_button.pressed.emit()
	await process_frame
	_require(not combat_screen._victory_overlay.visible, "Expected retry to dismiss the defeat overlay.")
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
	_require(combat_screen._hud_hp_text_label.text == "%d/%d" % [monster.hp, monster.hp], "Expected icon-labeled full HP value again after retry.")
	_require(is_equal_approx(combat_screen._hud_health_bar.value, float(monster.hp)), "Expected a full health bar again after retry.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_POISON_ICON, "x0"), "Expected Poison stack chip to reset to visible x0.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_SHRED_ICON, "x0"), "Expected Shred stack chip to reset to visible x0.")
	_require(_has_status_chip(combat_screen._hud_status_row, HUD_DECAY_ICON, "x0"), "Expected Decay stack chip to reset to visible x0.")

	combat_screen.queue_free()


func _instantiate_combat_screen() -> Node:
	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	return combat_screen


func _status_chip_text(chip: Node) -> String:
	if chip is Label:
		return chip.text
	var label := chip.get_node_or_null("Text") as Label
	if label != null:
		return label.text
	return ""


func _has_status_chip(row: HBoxContainer, icon_texture: Texture2D, text: String) -> bool:
	for child in row.get_children():
		var icon := child.get_node_or_null("Icon") as TextureRect
		if icon != null and icon.texture == icon_texture and _status_chip_text(child) == text:
			return true
	return false


func _status_chip_font_size(row: HBoxContainer, icon_texture: Texture2D) -> int:
	for child in row.get_children():
		var icon := child.get_node_or_null("Icon") as TextureRect
		var label := child.get_node_or_null("Text") as Label
		if icon != null and icon.texture == icon_texture and label != null:
			return label.get_theme_font_size("font_size")
	return 0


## Same fixed idiom as combat_recap_test.gd: record failures instead of
## quitting immediately, since several checks run after an awaited frame and
## an early quit(1) would be overwritten by _initialize()'s final quit().
func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failed = true
