extends SceneTree
## Headless check for the new UI restructure. Drives the real scene tree the
## same way real clicks would: title -> Adventure Mode -> class select
## (Rogue) -> subclass select (Thief) -> spend real talent points in
## talent_panel -> add real skills to the macro in skill_macro_panel ->
## press FIGHT -> confirm the combat log renders and character_stats_panel
## reflects the selected talents. Run with:
##   godot --headless -s res://tests/combat_screen_test.gd
## Same headless-only caveat as every prior UI milestone -- no rendered
## click-through available in this environment.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")

	var game_root_scene: PackedScene = load("res://scenes/game_root.tscn")
	var game_root = game_root_scene.instantiate()
	root.add_child(game_root)
	await process_frame

	# -- Title -> Adventure Mode --
	var title = game_root._current_screen
	title.adventure_pressed.emit()
	await process_frame

	# -- Class select: only Rogue is real; Mage/Crusader must be disabled --
	var class_select = game_root._current_screen
	var disabled_count := 0
	for child in class_select.find_children("*", "Button", true, false):
		if child.disabled:
			disabled_count += 1
	print("class select disabled buttons (expect 2, Mage+Crusader): %d" % disabled_count)
	assert(disabled_count == 2)

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	class_select._on_class_selected(rogue)
	print("selected class=%s" % build_state.selected_class.display_name)
	assert(build_state.selected_class == rogue)
	class_select.advanced.emit()
	await process_frame

	# -- Subclass select: Assassin, Thief, and Shadow are real Rogue trees. --
	var subclass_select = game_root._current_screen
	disabled_count = 0
	for child in subclass_select.find_children("*", "Button", true, false):
		if child.disabled:
			disabled_count += 1
	print("subclass select disabled buttons (expect 0): %d" % disabled_count)
	assert(disabled_count == 0)

	var thief: SubclassTree = rogue.trees[1]
	assert(thief.display_name == "Thief")
	subclass_select._on_tree_selected(thief)
	print("selected trees=%d (%s)" % [build_state.selected_trees.size(), build_state.selected_trees[0].display_name])
	assert(build_state.selected_trees.size() == 1)
	assert(build_state.selected_trees[0] == thief)
	subclass_select.advanced.emit()
	await process_frame

	# -- Story pass: the intro story overlay gates the very first Tavern
	# choice, before the map ever appears. --
	var combat_screen = game_root._current_screen
	print("story overlay visible right after subclass select (expect true): %s" % combat_screen._story_overlay.visible)
	assert(combat_screen._story_overlay.visible)
	assert(not combat_screen._map_overlay.visible)
	assert(combat_screen._story_label.text == combat_screen.INTRO_STORY_TEXT)
	var story_proceed_button: Button = combat_screen._story_overlay.find_child("StoryProceedButton", true, false)
	assert(story_proceed_button != null)
	story_proceed_button.pressed.emit()
	await process_frame
	assert(not combat_screen._story_overlay.visible)
	assert(combat_screen._map_overlay.visible)

	# -- Combat dashboard: Adventure starts with 0 talent points. --
	var talent_panel = combat_screen.find_child("TalentPanel", true, false)
	var available_skills_panel = combat_screen.find_child("AvailableSkillsPanel", true, false)
	var skill_build_panel = combat_screen.find_child("SkillBuildPanel", true, false)
	var character_stats_panel = combat_screen.find_child("CharacterStatsPanel", true, false)
	var gear_panel = combat_screen.find_child("GearPanel", true, false)
	assert(talent_panel != null and available_skills_panel != null and skill_build_panel != null and character_stats_panel != null and gear_panel != null)
	await process_frame
	assert(build_state.adventure_seed == build_state.DEFAULT_ADVENTURE_SEED)
	assert(combat_screen._seed_label.text == "Seed: 1")
	build_state.set_adventure_seed(37)
	await process_frame
	assert(combat_screen._seed_label.text == "Seed: 37")
	assert(combat_screen._map_overlay.visible)
	assert(combat_screen._map_node_buttons.size() == RunFlow.tavern_encounter_count())
	assert(combat_screen._map_node_buttons[0].text == "Mouthy Drunk")
	assert(not combat_screen._map_node_buttons[0].disabled)
	assert(combat_screen._map_node_buttons[1].text == "Unknown")
	assert(combat_screen._map_node_buttons[1].disabled)
	assert(not combat_screen._map_close_button.visible)

	# -- Clicking a node only previews its flavor text; Proceed commits it.
	# The current node isn't highlighted until clicked, and Proceed is
	# always visible while a choice is pending, just disabled until then --
	# both deliberately mirror the Contract Window's own
	# select-then-Proceed pattern, to teach the player that structure early. --
	assert(combat_screen._map_proceed_button.visible)
	assert(combat_screen._map_proceed_button.disabled)
	var mouthy_drunk_style_before: StyleBoxFlat = combat_screen._map_node_buttons[0].get_theme_stylebox("normal")
	assert(mouthy_drunk_style_before.border_color != CardStyle.ACCENT_COLOR)
	combat_screen._map_node_buttons[0].pressed.emit()
	await process_frame
	assert(combat_screen._map_overlay.visible)
	assert(not build_state.tavern_map_choice_made)
	assert(combat_screen._map_proceed_button.visible)
	assert(not combat_screen._map_proceed_button.disabled)
	var mouthy_drunk_style_after: StyleBoxFlat = combat_screen._map_node_buttons[0].get_theme_stylebox("normal")
	assert(mouthy_drunk_style_after.border_color == CardStyle.ACCENT_COLOR)
	print("previewed flavor text (expect Mouthy Drunk's): %s" % combat_screen._map_story_label.text)
	assert(combat_screen._map_story_label.text == "A red-faced patron decides your quiet corner is somehow his business.")
	combat_screen._map_proceed_button.pressed.emit()
	await process_frame
	assert(not combat_screen._map_overlay.visible)
	assert(build_state.tavern_map_choice_made)

	# -- Sizing: Character Stats/Enemy Stats shrink to content; Subclass/Gear
	# absorb the leftover column height instead. --
	print("character stats size_flags_vertical (expect not expand-fill): %d" % character_stats_panel.size_flags_vertical)
	assert(character_stats_panel.size_flags_vertical != Control.SIZE_EXPAND_FILL)
	assert(talent_panel.size_flags_vertical == Control.SIZE_EXPAND_FILL)
	var enemy_panel_node = combat_screen.find_child("EnemyPanel", true, false)
	print("enemy stats size_flags_vertical (expect not expand-fill): %d" % enemy_panel_node.size_flags_vertical)
	assert(enemy_panel_node.size_flags_vertical != Control.SIZE_EXPAND_FILL)
	assert(gear_panel.size_flags_vertical == Control.SIZE_EXPAND_FILL)

	# -- Gear: Adventure gear starts empty. Rewards and shop purchases are
	# now the only player-facing way to acquire equipment. --
	print("equipped gear on entry (expect 0): %d" % build_state.equipped_gear().size())
	assert(build_state.equipped_gear().size() == 0)
	print("weapon slot tooltip (expect Dagger: Empty): %s" % gear_panel._weapon_slot.tooltip_text)
	assert(gear_panel._weapon_slot.tooltip_text == "Dagger: Empty")
	print("hood slot tooltip (expect Hood: Empty): %s" % gear_panel._helm_slot.tooltip_text)
	assert(gear_panel._helm_slot.tooltip_text == "Hood: Empty")
	assert(gear_panel._armor_slot.tooltip_text == "Doublet: Empty")
	assert(build_state.inventory.is_empty())
	assert(gear_panel._inventory_grid.get_child_count() == build_state.INVENTORY_CAPACITY)
	assert(gear_panel._inventory_grid.get_child(0).disabled)
	assert(gear_panel._inventory_grid.get_child(0).custom_minimum_size == Vector2(88, 88))
	for child in gear_panel.find_children("*", "Button", true, false):
		assert(child.text != "Reroll Gear")

	# -- Talents panel: no redundant top subclass summary; each tree carries
	# its own name and intrinsic in the tree section. --
	var talents_title_found := false
	var thief_section_found := false
	var thief_intrinsic_found := false
	for label in talent_panel.find_children("*", "Label", true, false):
		if label.text == "Talents":
			talents_title_found = true
		elif label.text == "Thief":
			thief_section_found = true
		elif label.text.contains("Intrinsic: Unlocks Quick Cut"):
			thief_intrinsic_found = true
	assert(talents_title_found)
	assert(thief_section_found)
	assert(thief_intrinsic_found)
	print("assassin intrinsic (expect None): %s" % talent_panel._intrinsic_description(rogue.trees[0]))
	assert(talent_panel._intrinsic_description(rogue.trees[0]) == "None")

	# -- Points footer: "Points Spent: spent/earned" budget readout (P2:R7:T4)
	# -- counts UP as talents are taken, against the earned total. --
	print("points label (expect Points Spent: 0/0): %s" % talent_panel._points_label.text)
	assert(talent_panel._points_label.text == "Points Spent: 0/0")

	# -- Tree structure: base tier has the two no-prereq talents side by
	# side; deeper talents (Sunder) start disabled/dimmed until their
	# prerequisite chain is satisfied. --
	await process_frame
	var node_buttons := {}
	for node in talent_panel.find_children("*", "Button", true, false):
		if node.has_meta("talent_id"):
			node_buttons[node.get_meta("talent_id")] = node
	print("talent nodes rendered (expect 5): %d" % node_buttons.size())
	assert(node_buttons.size() == 5)
	assert(node_buttons["talent.quick_hands"].get_parent() == node_buttons["talent.piercing_blades"].get_parent())
	print("sunder disabled before prereqs (expect true): %s" % node_buttons["talent.sunder"].disabled)
	assert(node_buttons["talent.sunder"].disabled)
	assert(node_buttons["talent.opportunity_strikes"].tooltip_text.contains("Quick Cut"))
	assert(node_buttons["talent.opportunity_strikes"].tooltip_text.contains("20% chance to trigger Rending Slash"))

	var piercing_blades: Talent = thief.talents[1]
	assert(piercing_blades.display_name == "Piercing Blades")
	talent_panel._on_node_pressed(piercing_blades)
	print("selected talents with 0 points (expect 0): %d" % build_state.selected_talents.size())
	assert(build_state.selected_talents.size() == 0)

	# -- Talent tooltip reflects the actual cost and stat modifier --
	await process_frame
	for node in talent_panel.find_children("*", "Button", true, false):
		if node.has_meta("talent_id") and node.get_meta("talent_id") == "talent.piercing_blades":
			print("Piercing Blades tooltip: %s" % node.tooltip_text)
			assert(node.tooltip_text.contains("Cost: 1"))
			assert(node.tooltip_text.contains("Physical Damage"))

	# 2 base skills (Stab, Heavy Slash) + Quick Cut (granted by the Thief
	# tree itself). Rending Slash arrives after the first earned talent point.
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	print("unlocked skills=%d: %s" % [unlocked.size(), unlocked.map(func(s): return s.display_name)])
	assert(unlocked.size() == 3)
	assert(unlocked.any(func(skill: Skill) -> bool: return skill.id == "skill.quick_cut"))

	for skill in unlocked:
		available_skills_panel._on_skill_pressed(skill)
	print("rotation size=%d" % build_state.rotation.size())
	assert(build_state.rotation.size() == 3)

	# -- Available Skills buttons must report a real minimum width, or the
	# parent HBoxContainer collapses them all to ~0 width and every skill's
	# label renders stacked on top of the others. Yield first so the
	# deferred queue_free()s from the rapid-fire build_changed emissions
	# above (3 skill adds, no awaits between them) actually
	# flush -- same benign artifact seen with talent_panel's checkboxes
	# earlier, not a real duplication bug. --
	await process_frame
	var skills_box: HBoxContainer = available_skills_panel._skills_box
	print("available skill buttons=%d" % skills_box.get_child_count())
	assert(skills_box.get_child_count() == unlocked.size())
	for button in skills_box.get_children():
		var min_width: float = button.get_combined_minimum_size().x
		print("skill button min width: %.1f (expect > 20)" % min_width)
		assert(min_width > 20.0)

	# -- Skill Build strip: assigned skills render icons; clicking one
	# removes it. The text glyph stays empty for icon-backed slots so the
	# compact macro doesn't double-render icon + letter, while iconless skills
	# still fall back to their authored letter. --
	await process_frame
	var icon_slot_texts: Array = []
	var icon_slots := 0
	for child in skill_build_panel._slots_box.get_children():
		if child is Button:
			icon_slot_texts.append(child.text)
			if child.get_node_or_null("SkillIcon") != null:
				icon_slots += 1
	print("icon-backed slot texts (expect empty strings): %s" % str(icon_slot_texts))
	print("icon-backed slot count (expect 3): %d" % icon_slots)
	assert(icon_slot_texts == ["", "", ""])
	assert(icon_slots == 3)
	var iconless_skill := Skill.new()
	iconless_skill.display_name = "Fallback Test"
	iconless_skill.icon_letter = "Z"
	assert(skill_build_panel._glyph_for(iconless_skill) == "Z")

	var first_before: Skill = build_state.rotation[0]
	skill_build_panel._on_slot_pressed(0)
	print("rotation size after slot click (expect 2): %d" % build_state.rotation.size())
	assert(build_state.rotation.size() == 2)
	assert(not build_state.rotation.has(first_before))
	available_skills_panel._on_skill_pressed(first_before)
	assert(build_state.rotation.size() == 3)

	# -- Character stats panel should reflect Piercing Blades' physical
	# damage multiplier, displayed as bonus above a 0% baseline (x1.08 ->
	# "8%", no leading "+" since it's a multiplicative modifier, not an
	# additive bonus -- P2:R7 playtest-feedback fix, 2026-07-19), with crit
	# multiplier as a percentage. --
	var stats_text: String = character_stats_panel._stats_label.text
	print("")
	print("-- Character stats panel text --")
	print(stats_text)
	assert(stats_text.contains("Physical Damage: 0%"))
	assert(stats_text.contains("Crit Multiplier: 200%"))
	assert(stats_text.contains("Bonus Poison Stacks: +0"))
	assert(stats_text.contains("Poison Damage: 8.0/tick"))

	# -- Lock/ready flow: FIGHT is gated on locking the build --
	var enemy_panel = combat_screen.find_child("EnemyPanel", true, false)
	print("-- Initial enemy panel --")
	print(enemy_panel._info_label.text)
	assert(enemy_panel._title_label.text == "Mouthy Drunk")
	assert(not enemy_panel._info_label.text.contains("Encounter:"))
	assert(not enemy_panel._info_label.text.contains("Target:"))
	# P2:R7:T5: 150 HP over a 12s window is a 12.5 required DPS, and Mouthy
	# Drunk's authored reward (12g, 1 talent point) is visible before the
	# fight, not only after via the post-fight claim UI.
	assert(enemy_panel._info_label.text.contains("Required DPS: 12.5"))
	assert(enemy_panel._info_label.text.contains("Reward: 12g, 1 talent point"))
	assert(enemy_panel._info_label.text.contains("Pressure: No notable defensive pressure."))
	print("fight button disabled before lock (expect true): %s" % enemy_panel._fight_button.disabled)
	assert(enemy_panel._fight_button.disabled)

	# Fight attempt without lock must be a no-op (guard in combat_screen).
	enemy_panel.fight_pressed.emit()
	assert(not combat_screen._log_label.text.contains("VICTORY"))
	assert(not combat_screen._log_label.text.contains("DEFEAT"))

	skill_build_panel._on_lock_pressed()
	print("build locked (expect true): %s" % build_state.build_locked)
	assert(build_state.build_locked)
	assert(not enemy_panel._fight_button.disabled)
	# Each available-skills child is a bare Button again (P2:R7 playtest-
	# feedback pass removed T4's always-visible effect-summary caption, so
	# there's no longer a wrapping VBoxContainer around it).
	for child in available_skills_panel._skills_box.get_children():
		assert(child.disabled)
	for child in skill_build_panel._slots_box.get_children():
		assert(child.disabled)
	var locked_rotation_size: int = build_state.rotation.size()
	available_skills_panel._on_skill_pressed(build_state.unlocked_skills()[0])
	skill_build_panel._on_slot_pressed(0)
	assert(build_state.rotation.size() == locked_rotation_size)

	# -- Log overlay: hidden and gated until a fight has actually happened --
	print("log overlay hidden before any fight (expect true): %s" % (not combat_screen._log_overlay.visible))
	assert(not combat_screen._log_overlay.visible)
	print("view log button disabled before any fight (expect true): %s" % combat_screen._view_log_button.disabled)
	assert(combat_screen._view_log_button.disabled)

	# -- Fight --
	var expected_stats := BuildResolver.resolve_stats(
		build_state.selected_class, build_state.selected_trees, build_state.selected_talents, build_state.equipped_gear()
	)
	var expected_rotation := BuildResolver.resolve_rotation(build_state.rotation, build_state.unlocked_skills())
	var expected_monster: Monster = enemy_panel.monster()
	var expected_duration_ms: int = enemy_panel.duration_ms()
	var expected_result: CombatResolver.CombatResult = CombatResolver.resolve(
		expected_rotation, expected_stats, expected_monster, expected_duration_ms, build_state.current_combat_rng_seed()
	)
	var expected_log := CombatResultFormatter.format(expected_result, expected_monster)
	enemy_panel.fight_pressed.emit()
	await process_frame

	print("")
	print("-- Combat log text --")
	print(combat_screen._log_label.text)
	assert(not combat_screen._log_label.text.contains("[DIAG"))
	assert(combat_screen._log_label.text == expected_log)
	assert(combat_screen._log_label.text.contains("VICTORY!"))
	assert(combat_screen._log_label.text.contains("DPS"))
	print("status label: %s" % combat_screen._status_label.text)
	assert(combat_screen._status_label.text.begins_with("Fight complete:"))
	assert(not combat_screen._view_log_button.disabled)

	# -- Victory banner: auto-shown on win, with recap numbers. This fight
	# is all direct casts (no poison skills in the rotation), so the damage
	# split is exactly 100/0. --
	print("victory overlay visible after win (expect true): %s" % combat_screen._victory_overlay.visible)
	assert(combat_screen._victory_overlay.visible)
	# Victory now resolves inside the combat window: a transparent full-screen
	# click blocker preserves modal behavior, while the visible dim/content
	# are constrained to the combat window so the defeated stage remains
	# visible behind the recap.
	var victory_stack = combat_screen._victory_overlay.find_child("VictoryStack", true, false)
	assert(victory_stack != null)
	assert(victory_stack.get_child_count() == 5)
	var click_blocker = combat_screen._victory_overlay.find_child("VictoryClickBlocker", true, false)
	assert(click_blocker != null)
	assert(click_blocker.color.a == 0.0)
	var combat_dim = combat_screen._victory_overlay.find_child("VictoryCombatDim", true, false)
	assert(combat_dim != null)
	assert(combat_dim.get_parent() == combat_screen._victory_center)
	assert(combat_screen._victory_center.get_global_rect().position.distance_to(combat_screen._combat_window.get_global_rect().position) < 1.0)
	assert(combat_screen._victory_center.size.distance_to(combat_screen._combat_window.size) < 1.0)
	assert(combat_screen._combat_stage.visible)
	assert(combat_screen._combat_stage.outcome_pose == "victory")
	assert(combat_screen._view_log_button.visible)
	assert(build_state.run_phase == BuildState.RunPhase.RESULT)
	assert(build_state.last_fight_won)
	var recap_text: String = combat_screen._victory_recap_label.text
	print("-- Victory recap --")
	print(recap_text)
	var expected_required_dps := float(expected_monster.hp) / (float(expected_duration_ms) / 1000.0)
	assert(recap_text.contains("Total Damage:"))
	assert(recap_text.contains("(needed %d)" % expected_monster.hp))
	assert(recap_text.contains("DPS:"))
	assert(recap_text.contains("(needed %.1f)" % expected_required_dps))
	assert(recap_text.contains("Biggest Hit:"))
	assert(recap_text.contains("(100%) / Poison: 0 (0%)"))
	assert(recap_text.contains("Crits:"))
	print("reward after first win: %s" % combat_screen._reward_label.text)
	assert(combat_screen._reward_label.text.contains("Rewards: 12g"))
	assert(combat_screen._reward_label.text.contains("1 talent point"))
	var reward_title_found := false
	for node in combat_screen._victory_overlay.find_children("*", "Label", true, false):
		if node.text == "Rewards":
			reward_title_found = true
	assert(not reward_title_found)
	assert(build_state.gold == 0)
	assert(build_state.earned_talent_points == 0)

	var banner_claim = null
	for node in combat_screen._victory_overlay.find_children("*", "Button", true, false):
		if node.text == "Claim Rewards":
			banner_claim = node
	assert(banner_claim != null)
	for node in combat_screen._victory_overlay.find_children("*", "Button", true, false):
		assert(node.text != "View Combat Log")

	# -- Log overlay: View Combat Log opens it, Close and backdrop-click both dismiss it --
	combat_screen._view_log_button.pressed.emit()
	print("log overlay visible after View Combat Log (expect true): %s" % combat_screen._log_overlay.visible)
	assert(combat_screen._log_overlay.visible)

	var close_button = null
	for node in combat_screen._log_overlay.find_children("*", "Button", true, false):
		if node.text == "Close":
			close_button = node
	assert(close_button != null)
	close_button.pressed.emit()
	print("log overlay visible after Close (expect false): %s" % combat_screen._log_overlay.visible)
	assert(not combat_screen._log_overlay.visible)
	assert(combat_screen._victory_overlay.visible)

	combat_screen._view_log_button.pressed.emit()
	assert(combat_screen._log_overlay.visible)
	var backdrop = null
	for node in combat_screen._log_overlay.find_children("*", "Button", true, false):
		if node.text == "":
			backdrop = node
	assert(backdrop != null)
	backdrop.pressed.emit()
	print("log overlay visible after backdrop click (expect false): %s" % combat_screen._log_overlay.visible)
	assert(not combat_screen._log_overlay.visible)

	# -- Victory banner Claim Rewards grants authored rewards, advances to
	# the next Tavern encounter, and clears the build lock so the player
	# returns to planning. --
	banner_claim.pressed.emit()
	await process_frame
	print("victory overlay visible after Claim Rewards (expect false): %s" % combat_screen._victory_overlay.visible)
	assert(not combat_screen._victory_overlay.visible)
	assert(build_state.gold == 12)
	assert(build_state.earned_talent_points == 1)
	assert(build_state.claimed_reward_encounter_indices == [0])
	assert(not build_state.claim_current_reward())
	assert(build_state.gold == 12)
	print("current encounter after Continue (expect 1): %d" % build_state.current_encounter_index)
	assert(build_state.current_encounter_index == 1)
	assert(build_state.run_phase == BuildState.RunPhase.PLANNING)
	assert(not build_state.build_locked)
	assert(not build_state.tavern_map_choice_made)
	assert(combat_screen._map_overlay.visible)
	assert(combat_screen._map_node_buttons[0].disabled)
	assert(combat_screen._map_node_buttons[1].text == "Drunk Buddy")
	assert(not combat_screen._map_node_buttons[1].disabled)
	print("-- Enemy panel after Continue --")
	print(enemy_panel._info_label.text)
	assert(enemy_panel._title_label.text == "Choose Encounter")
	assert(enemy_panel._info_label.text.contains("Choose the current Tavern encounter on the map."))
	assert(enemy_panel._fight_button.disabled)
	# -- Returning to the map after a win shows that encounter's Victory
	# Text, not the intro line again, until the next node is previewed. --
	print("map story text after Mouthy Drunk win (expect his Victory Text): %s" % combat_screen._map_story_label.text)
	assert(combat_screen._map_story_label.text == "You easily dispatch him with a few well-placed strikes. He falls into a heap on the floor. However, this has caused quite the commotion.")
	combat_screen._map_node_buttons[1].pressed.emit()
	await process_frame
	print("previewed flavor text (expect Drunk Buddy's): %s" % combat_screen._map_story_label.text)
	assert(combat_screen._map_story_label.text == "Leaping to his fallen companion's aid, another drunk patron wants to try his hand.")
	combat_screen._map_proceed_button.pressed.emit()
	await process_frame
	assert(not combat_screen._map_overlay.visible)
	assert(build_state.tavern_map_choice_made)
	assert(enemy_panel._title_label.text == "Drunk Buddy")
	assert(not enemy_panel._info_label.text.contains("Encounter:"))
	assert(not enemy_panel._info_label.text.contains("Target:"))
	var planning_map_button = null
	for child in combat_screen.find_children("*", "Button", true, false):
		if child.text == "Map":
			planning_map_button = child
	assert(planning_map_button != null)
	planning_map_button.pressed.emit()
	await process_frame
	assert(combat_screen._map_overlay.visible)
	assert(combat_screen._map_close_button.visible)
	assert(combat_screen._map_node_buttons[1].disabled)
	var current_map_style: StyleBoxFlat = combat_screen._map_node_buttons[1].get_theme_stylebox("normal")
	assert(current_map_style.border_color == CardStyle.ACCENT_COLOR)
	combat_screen._map_close_button.pressed.emit()
	await process_frame
	assert(not combat_screen._map_overlay.visible)

	# Spend the first earned Tavern talent point before the second fight.
	talent_panel._on_node_pressed(piercing_blades)
	await process_frame
	assert(build_state.selected_talents.size() == 1)
	assert(talent_panel._points_label.text == "Points Spent: 1/1")
	unlocked = build_state.unlocked_skills()
	assert(unlocked.size() == 4)
	for skill in unlocked:
		if not build_state.rotation.any(func(existing: Skill) -> bool: return existing.id == skill.id):
			available_skills_panel._on_skill_pressed(skill)
	assert(build_state.rotation.size() == 4)
	assert(build_state.rotation.any(func(skill: Skill) -> bool: return skill.display_name == "Rending Slash"))
	talent_panel._on_node_pressed(piercing_blades)
	await process_frame
	assert(not build_state.selected_talents.has(piercing_blades))
	assert(not build_state.unlocked_skills().any(func(skill: Skill) -> bool: return skill.display_name == "Rending Slash"))
	assert(not build_state.rotation.any(func(skill: Skill) -> bool: return skill.display_name == "Rending Slash"))
	talent_panel._on_node_pressed(piercing_blades)
	await process_frame
	unlocked = build_state.unlocked_skills()
	for skill in unlocked:
		if not build_state.rotation.any(func(existing: Skill) -> bool: return existing.id == skill.id):
			available_skills_panel._on_skill_pressed(skill)
	assert(build_state.rotation.size() == 4)
	stats_text = character_stats_panel._stats_label.text
	# No leading "+" -- Physical Damage is multiplicative (x1.08), not
	# additive (P2:R7 playtest-feedback fix, 2026-07-19).
	assert(stats_text.contains("Physical Damage: 8%"))

	# Relock and resolve a second, different encounter from the same active
	# dashboard. This is the core P2:R2 reconnection contract.
	skill_build_panel._on_lock_pressed()
	assert(build_state.build_locked)
	assert(not enemy_panel._fight_button.disabled)
	enemy_panel.fight_pressed.emit()
	await process_frame
	assert(combat_screen._victory_overlay.visible)
	assert(combat_screen._log_label.text.contains("Drunk Buddy"))
	assert(combat_screen._reward_label.text.contains("18g"))
	assert(combat_screen._reward_label.text.contains("Lucky Coin"))
	assert(combat_screen._reward_label.text.contains("shop access"))
	assert(build_state.gold == 12)
	assert(build_state.current_encounter_index == 1)
	assert(build_state.run_phase == BuildState.RunPhase.RESULT)
	var inventory_count_before_buddy_claim: int = build_state.inventory.size()
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	banner_claim.pressed.emit()
	await process_frame
	print("victory overlay visible after second Claim Rewards (expect false): %s" % combat_screen._victory_overlay.visible)
	assert(not combat_screen._victory_overlay.visible)
	assert(build_state.gold == 30)
	assert(build_state.earned_talent_points == 1)
	assert(build_state.inventory.size() == inventory_count_before_buddy_claim + 1)
	assert(build_state.has_inventory_item(lucky_coin))
	await process_frame
	assert(gear_panel._inventory_grid.get_child_count() == build_state.INVENTORY_CAPACITY)
	assert(not gear_panel._inventory_grid.get_child(0).disabled)
	assert(gear_panel._inventory_grid.get_child(0).tooltip_text.contains("Sell for"))
	assert(build_state.shop_unlocked)
	assert(build_state.claimed_reward_encounter_indices == [0, 1])
	assert(build_state.current_encounter_index == 1)
	assert(build_state.run_phase == BuildState.RunPhase.RESULT)
	assert(build_state.shop_round_pending)
	assert(combat_screen._shop_overlay.visible)
	assert(not combat_screen._status_label.visible)
	assert(not combat_screen._view_log_button.visible)
	assert(build_state.shop_offers.size() == 6)
	for offer in build_state.shop_offers:
		assert(offer.tier == GearItem.Tier.BASIC)
	assert(combat_screen._shop_offers_box.columns == 2)
	assert(combat_screen._shop_offers_box.get_child_count() == 6)

	var first_offer: GearItem = build_state.shop_offers[0]
	var first_offer_id := first_offer.id
	print("first shop offer: %s" % combat_screen._shop_offer_text(first_offer))
	assert(GearGenerator.price_for_tier(first_offer.tier) == 18)
	assert(combat_screen._shop_offer_text(first_offer).contains("Price: 18g"))
	assert(combat_screen._shop_offer_text(first_offer).begins_with("%s - " % GearGenerator.SLOT_TAGS[first_offer.slot]))
	assert(combat_screen._shop_reroll_button.text == "Reroll (1)")

	var offers_before_reroll: Array[String] = []
	for offer in build_state.shop_offers:
		offers_before_reroll.append(offer.id)
	combat_screen._shop_reroll_button.pressed.emit()
	assert(build_state.shop_reroll_used)
	assert(not build_state.reroll_shop_offers())
	var offers_after_reroll: Array[String] = []
	for offer in build_state.shop_offers:
		offers_after_reroll.append(offer.id)
	print("shop offers changed after reroll (expect true): %s" % (offers_before_reroll != offers_after_reroll))
	assert(offers_before_reroll != offers_after_reroll)
	combat_screen._refresh_shop_overlay()
	await process_frame
	assert(combat_screen._shop_reroll_button.disabled)
	assert(combat_screen._shop_reroll_button.text == "Reroll (0)")

	var bought_offer: GearItem = build_state.shop_offers[0]
	var inventory_before_purchase: int = build_state.inventory.size()
	var gold_before_purchase: int = build_state.gold
	var stats_before_purchase := BuildResolver.resolve_stats(
		build_state.selected_class, build_state.selected_trees, build_state.selected_talents, build_state.equipped_gear()
	)
	var first_offer_button: Button = combat_screen._shop_offers_box.get_child(0)
	assert(first_offer_button.custom_minimum_size == Vector2(88, 88))
	assert(first_offer_button.tooltip_text.contains(bought_offer.display_name))
	assert(first_offer_button.tooltip_text.begins_with("%s - " % GearGenerator.SLOT_TAGS[bought_offer.slot]))
	first_offer_button.pressed.emit()
	assert(build_state.gold == gold_before_purchase - 18)
	assert(build_state.inventory.size() == inventory_before_purchase + 1)
	assert(build_state.has_inventory_item(bought_offer))
	assert(not build_state.shop_offers.has(bought_offer))
	assert(first_offer_id != "")
	var stats_after_purchase := BuildResolver.resolve_stats(
		build_state.selected_class, build_state.selected_trees, build_state.selected_talents, build_state.equipped_gear()
	)

	# Fill inventory to prove shop buying is capacity-gated, then sell a
	# stored item during the open shop round to free a slot.
	var fill_rng := RandomNumberGenerator.new()
	fill_rng.seed = 72
	while build_state.inventory.size() < build_state.INVENTORY_CAPACITY:
		assert(build_state.add_inventory_item(GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.CHARM, fill_rng)))
	assert(not build_state.can_add_inventory_item())
	assert(build_state.shop_offers.size() > 0)
	var blocked_offer: GearItem = build_state.shop_offers[0]
	var gold_before_blocked_buy: int = build_state.gold
	assert(not build_state.buy_shop_offer(blocked_offer))
	assert(build_state.gold == gold_before_blocked_buy)
	assert(build_state.shop_offers.has(blocked_offer))
	var sold_during_shop: GearItem = build_state.inventory[build_state.inventory.size() - 1]
	var sale_value: int = build_state.sell_value_for(sold_during_shop)
	gear_panel._on_inventory_slot_pressed(sold_during_shop)
	await process_frame
	assert(gear_panel._sell_dialog.visible)
	gear_panel._on_sell_confirmed()
	await process_frame
	assert(not build_state.has_inventory_item(sold_during_shop))
	assert(build_state.gold == gold_before_blocked_buy + sale_value)
	assert(build_state.can_add_inventory_item())

	var purchased_gear_changed_stats := (
		stats_before_purchase.attack_speed != stats_after_purchase.attack_speed
		or stats_before_purchase.crit_chance != stats_after_purchase.crit_chance
		or stats_before_purchase.crit_multiplier != stats_after_purchase.crit_multiplier
		or stats_before_purchase.poison_damage_per_tick != stats_after_purchase.poison_damage_per_tick
		or stats_before_purchase.physical_damage_multiplier != stats_after_purchase.physical_damage_multiplier
		or stats_before_purchase.bonus_poison_stacks != stats_after_purchase.bonus_poison_stacks
		or stats_before_purchase.bonus_armor_reduction != stats_after_purchase.bonus_armor_reduction
	)
	print("inventory purchase leaves stats unchanged (expect false): %s" % purchased_gear_changed_stats)
	assert(not purchased_gear_changed_stats)

	assert(build_state.equip_from_inventory(bought_offer))
	var equipped_sale_slot: GearItem.SlotType = bought_offer.slot
	var equipped_sale_value: int = build_state.sell_value_for(bought_offer)
	gear_panel._confirm_sell_equipped_item(equipped_sale_slot)
	await process_frame
	assert(gear_panel._sell_dialog.visible)
	var gold_before_equipped_sale: int = build_state.gold
	gear_panel._on_sell_confirmed()
	await process_frame
	assert(build_state.gold == gold_before_equipped_sale + equipped_sale_value)
	assert(build_state.has_open_equipment_slot(equipped_sale_slot))

	combat_screen._on_shop_continue_pressed()
	await process_frame
	assert(not combat_screen._shop_overlay.visible)
	assert(not build_state.shop_round_pending)
	assert(build_state.shop_round_index == 1)
	assert(build_state.current_encounter_index == 2)
	assert(build_state.run_phase == BuildState.RunPhase.PLANNING)
	assert(enemy_panel._title_label.text == "Choose Encounter")
	assert(combat_screen._map_overlay.visible)
	assert(combat_screen._map_node_buttons[2].text == "Tavern Bouncer")
	print("map story text after Drunk Buddy win (expect his Victory Text): %s" % combat_screen._map_story_label.text)
	assert(combat_screen._map_story_label.text == "He lands with a thud atop the fallen body of his companion, but now the tavern is abuzz with action. You have made your pressence known; however you are not sure that was the best idea.")
	combat_screen._map_node_buttons[2].pressed.emit()
	await process_frame
	print("previewed flavor text (expect Tavern Bouncer's): %s" % combat_screen._map_story_label.text)
	assert(combat_screen._map_story_label.text == "The burley bouncer grabs you to politely show you the door.")
	combat_screen._map_proceed_button.pressed.emit()
	await process_frame
	assert(build_state.tavern_map_choice_made)
	assert(enemy_panel._title_label.text == "Tavern Bouncer")

	# -- Earned inventory equip: Lucky Coin came from the Drunk Buddy reward,
	# not a free reroll, and equipping it from the panel is a build change. --
	skill_build_panel._on_lock_pressed()
	assert(build_state.build_locked)
	gear_panel._on_inventory_slot_pressed(lucky_coin)
	await process_frame
	assert(build_state.equipped_trinket == lucky_coin)
	assert(not build_state.has_inventory_item(lucky_coin))
	assert(gear_panel._trinket_slot.tooltip_text.begins_with("Trinket - Lucky Coin"))
	print("build unlocked after earned gear equip (expect false): %s" % build_state.build_locked)
	assert(not build_state.build_locked)
	assert(enemy_panel._fight_button.disabled)

	# -- Contract offer transition: after Hired Goon, the shop is skipped and
	# Ghit Gudd's Contract Window introduces The Gilded Serpent contract
	# instead of the old single-click "Map"-styled offer (P2:R7 story pass).
	build_state.current_encounter_index = RunFlow.tavern_encounter_count() - 1
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	build_state.run_state_changed.emit()
	assert(build_state.claim_current_reward())
	combat_screen._advance_after_reward_or_shop()
	await process_frame
	print("run phase after Hired Goon Continue (expect CONTRACT_OFFER): %d" % build_state.run_phase)
	assert(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER)
	assert(build_state.active_contract != null)
	assert(build_state.active_contract.display_name == "The Gilded Serpent Contract")
	assert(build_state.current_route_node.id == "route.gilded_serpent.offer")
	assert(not combat_screen._shop_overlay.visible)
	assert(combat_screen._contract_overlay.visible)
	assert(combat_screen._contract_body_label.text == combat_screen.CONTRACT_GREETING_TEXT)
	assert(combat_screen._contract_action_button.text == "Hear Him Out")
	assert(enemy_panel._title_label.text == "Contract Offer")

	combat_screen._contract_action_button.pressed.emit()
	await process_frame
	assert(combat_screen._contract_body_label.text == combat_screen.CONTRACT_PITCH_TEXT)
	assert(combat_screen._contract_action_button.text == "Accept Contract Work")

	combat_screen._contract_action_button.pressed.emit()
	await process_frame
	assert(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE)
	assert(build_state.current_route_node.id == "route.gilded_serpent.secondary_rogue_tree")
	assert(not combat_screen._contract_overlay.visible)
	assert(combat_screen._secondary_subclass_overlay.visible)
	assert(combat_screen._secondary_subclass_body.text == combat_screen.CONTRACT_SUBCLASS_PROMPT_TEXT)
	assert(combat_screen._secondary_subclass_options.get_child_count() == 2)
	# Each option is now a selection card matching the primary subclass
	# select screen (P2:R7 second playtest-feedback pass, item 5):
	# card -> vbox -> [title Label, intrinsic Label, Choose Button].
	var secondary_card_0_vbox: VBoxContainer = combat_screen._secondary_subclass_options.get_child(0).get_child(0)
	var secondary_card_1_vbox: VBoxContainer = combat_screen._secondary_subclass_options.get_child(1).get_child(0)
	assert(secondary_card_0_vbox.get_child(0).text.contains("Assassin"))
	assert(secondary_card_1_vbox.get_child(0).text.contains("Shadow"))
	assert(secondary_card_1_vbox.get_child(1).text.contains("ticks for poison damage"))
	assert(secondary_card_0_vbox.get_child(2) is Button)
	assert(secondary_card_0_vbox.get_child(2).text == "Choose")
	secondary_card_0_vbox.get_child(2).pressed.emit()
	await process_frame
	assert(build_state.selected_trees.size() == 2)
	assert(not combat_screen._secondary_subclass_overlay.visible)

	# -- Contract Window reopens as a hub with a single contract card for
	# now (Vyra) -- a larger toggleable rectangle naming the contract and its
	# gold reward, not a plain button. Selecting it only enables Proceed;
	# Proceed then previews her, and her own Accept finally reveals the
	# (unchanged) interactive route schematic. --
	assert(combat_screen._contract_overlay.visible)
	assert(combat_screen._contract_options_box.get_child_count() == 1)
	var vyra_button: Button = combat_screen._contract_options_box.get_child(0)
	assert(vyra_button.text.contains(combat_screen.CONTRACT_VYRA_NAME))
	assert(vyra_button.text.contains("Reward: 120g"))
	assert(combat_screen._contract_action_button.disabled)
	vyra_button.button_pressed = true
	await process_frame
	assert(not combat_screen._contract_action_button.disabled)
	combat_screen._contract_action_button.pressed.emit()
	await process_frame
	assert(combat_screen._contract_body_label.text == combat_screen.CONTRACT_VYRA_DETAIL_TEXT)
	assert(combat_screen._contract_action_button.text == "Accept")
	combat_screen._contract_action_button.pressed.emit()
	await process_frame
	assert(not combat_screen._contract_overlay.visible)
	assert(combat_screen._map_overlay.visible)
	assert(combat_screen._map_node_buttons.size() == 8)
	assert(combat_screen._map_node_buttons[0].text.contains("Door Guard"))
	assert(combat_screen._map_node_buttons[0].text.contains("Master Gear"))
	assert(not combat_screen._map_node_buttons[0].text.contains("Weapon or Ring"))
	assert(not combat_screen._map_node_buttons[0].disabled)
	assert(combat_screen._map_node_buttons[0].tooltip_text.contains("Hard Opener"))
	assert(combat_screen._map_node_buttons[1].text.contains("Portly Cook"))
	assert(combat_screen._map_node_buttons[1].text.contains("Basic Gear"))
	assert(not combat_screen._map_node_buttons[1].text.contains("Weapon or Necklace"))
	assert(not combat_screen._map_node_buttons[1].disabled)
	assert(combat_screen._map_node_buttons[1].tooltip_text.contains("Easy Opener"))
	assert(combat_screen._map_node_buttons[2].text.contains("Sleeping"))
	assert(combat_screen._map_node_buttons[4].text.contains("Lazy"))
	assert(combat_screen._map_node_buttons[6].text.contains("Knives"))
	assert(combat_screen._map_node_buttons[7].text.contains("Vyra"))
	assert(combat_screen._map_node_buttons[2].disabled)
	assert(enemy_panel._title_label.text == "Choose Route")
	assert(enemy_panel._info_label.text.contains("Choose the next contract route on the map."))

	combat_screen._map_node_buttons[1].pressed.emit()
	await process_frame
	assert(build_state.run_phase == BuildState.RunPhase.PLANNING)
	assert(build_state.current_route_node.id == "route.gilded_serpent.portly_cook")
	assert(enemy_panel._title_label.text == "Portly Cook")
	assert(enemy_panel._info_label.text.contains("Window: 20s"))
	assert(not enemy_panel._info_label.text.contains("Contract:"))
	# P2:R7:T5: Portly Cook is a 0-armor/0-poison-resist target, so its
	# preview shows the "no notable pressure" line and its authored Basic
	# Gear reward, both derived from real Monster/EncounterReward data.
	assert(enemy_panel._info_label.text.contains("Required DPS: 18.0"))
	assert(enemy_panel._info_label.text.contains("Pressure: No notable defensive pressure."))
	assert(enemy_panel._info_label.text.contains("Reward: 26g, Basic Gear"))
	assert(enemy_panel._fight_button.disabled)
	build_state.set_locked(true)
	await process_frame
	assert(not enemy_panel._fight_button.disabled)
	enemy_panel._fight_button.pressed.emit()
	await process_frame
	print("route fight phase after Portly Cook: %d" % build_state.run_phase)
	print("route fight log contains Portly Cook (expect true): %s" % combat_screen._log_label.text.contains("Portly Cook"))
	assert(combat_screen._log_label.text.contains("Portly Cook"))
	assert(combat_screen._view_log_button.disabled == false)
	# This regression is about the post-contract-reward shop transition, not
	# route balance for the broad dashboard build assembled above. Contract
	# losses now correctly end as CONTRACT_FAILED, so restore a winning result
	# surface before driving the reward/shop branch.
	if build_state.run_outcome == BuildState.RunOutcome.CONTRACT_FAILED:
		assert(build_state.run_phase == BuildState.RunPhase.RUN_ENDED)
		build_state.run_phase = BuildState.RunPhase.RESULT
		build_state.run_outcome = BuildState.RunOutcome.FIGHT_WIN
	build_state.last_fight_won = true
	combat_screen._on_continue_pressed()
	await process_frame
	assert(combat_screen._reward_choice_overlay.visible)
	assert(build_state.has_pending_reward_choice())
	var contract_reward_button: Button = combat_screen._reward_choice_options.get_child(0)
	contract_reward_button.pressed.emit()
	await process_frame
	assert(combat_screen._shop_overlay.visible)
	assert(build_state.shop_round_pending)
	combat_screen._on_shop_continue_pressed()
	await process_frame
	assert(not combat_screen._shop_overlay.visible)
	assert(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE)

	# -- Abandon Run requires confirmation, doesn't fire immediately --
	# GDScript lambdas capture local variables by value, not by reference, so
	# a bare `bool` wouldn't observe the lambda's mutation -- use a 1-element
	# Array as a mutable box instead.
	var main_menu_fired := [false]
	combat_screen.main_menu_pressed.connect(func(): main_menu_fired[0] = true)
	# The button lives nested inside the top bar -- search the whole tree by
	# text, since find_child by type alone would match panel buttons too.
	var menu_button = null
	for child in combat_screen.find_children("*", "Button", true, false):
		if child.text == "Abandon Run":
			menu_button = child
	assert(menu_button != null)
	var map_button = null
	for child in combat_screen.find_children("*", "Button", true, false):
		if child.text == "Map":
			map_button = child
	assert(map_button != null)
	map_button.pressed.emit()
	await process_frame
	assert(combat_screen._map_overlay.visible)
	assert(combat_screen._map_close_button.visible)
	combat_screen._map_overlay.visible = false
	menu_button.pressed.emit()
	print("main menu fired before confirmation (expect false): %s" % main_menu_fired[0])
	assert(not main_menu_fired[0])
	assert(combat_screen._confirm_dialog.visible)

	combat_screen._confirm_dialog.confirmed.emit()
	print("main menu fired after confirmation (expect true): %s" % main_menu_fired[0])
	assert(main_menu_fired[0])

	print("")
	print("P2 UI restructure end-to-end check: OK")
	quit()
