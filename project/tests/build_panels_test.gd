extends SceneTree
## Focused P2:R7:T4 check for the five build-facing dashboard panels (talent,
## available skills, skill build/rotation, character stats, gear). Drives the
## real combat_screen.tscn scene against BuildState, same pattern as
## dashboard_header_test.gd. Same headless-only caveat as every prior UI
## milestone -- no rendered click-through available in this environment.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var thief: SubclassTree = rogue.trees[1]
	build_state.set_class(rogue)
	build_state.select_tree(thief)
	await process_frame

	var talent_panel = combat_screen.find_child("TalentPanel", true, false)
	var active_talents_panel = combat_screen.find_child("ActiveTalentsPanel", true, false)
	var available_skills_panel = combat_screen.find_child("AvailableSkillsPanel", true, false)
	var skill_build_panel = combat_screen.find_child("SkillBuildPanel", true, false)
	var character_stats_panel = combat_screen.find_child("CharacterStatsPanel", true, false)
	var gear_panel = combat_screen.find_child("GearPanel", true, false)
	_require(talent_panel != null and active_talents_panel != null and available_skills_panel != null and skill_build_panel != null and character_stats_panel != null and gear_panel != null, "Expected all build panels to be found.")

	# -- 1. Talent lock reason: Opportunity Strikes requires Practiced Rhythm,
	# which is unselected at 0 earned points, so its unmet prerequisite
	# should be named explicitly, not just "disabled". --
	var opportunity_strikes: Talent = thief.talents[3]
	_require(opportunity_strikes.display_name == "Opportunity Strikes", "Expected thief.talents[3] to be Opportunity Strikes.")
	var reason: String = talent_panel._talent_lock_reason(opportunity_strikes)
	print("Opportunity Strikes lock reason (expect prereq): %s" % reason)
	_require(reason == "Requires Practiced Rhythm", "Expected an unmet-prerequisite reason, got: %s" % reason)
	var node_buttons := {}
	for node in talent_panel.find_children("*", "Button", true, false):
		if node.has_meta("talent_id"):
			node_buttons[node.get_meta("talent_id")] = node
	_require(node_buttons["talent.opportunity_strikes"].tooltip_text.contains("Locked: Requires Practiced Rhythm"), "Expected the lock reason inside the talent's tooltip, got: %s" % node_buttons["talent.opportunity_strikes"].tooltip_text)
	# P2:R7 playtest feedback (2026-07-18): the lock reason no longer also
	# renders as an always-visible caption Label under the node -- tooltip
	# only. There should be no descendant Label carrying the reason text.
	var found_visible_reason_label := false
	for descendant in node_buttons["talent.opportunity_strikes"].find_children("*", "Label", true, false):
		if descendant.text == reason:
			found_visible_reason_label = true
	_require(not found_visible_reason_label, "Expected no always-visible lock-reason Label under a locked talent node.")

	# A no-prereq talent (Quick Hands) is still locked at 0 earned points, for
	# budget reasons rather than a prerequisite -- confirms the two reason
	# kinds are distinguishable, not just a blanket "locked" string.
	var budget_reason: String = talent_panel._talent_lock_reason(thief.talents[0])
	print("Quick Hands lock reason at 0 points (expect budget): %s" % budget_reason)
	_require(budget_reason.contains("Needs"), "Expected a budget-based reason for a no-prereq talent with no points, got: %s" % budget_reason)

	# -- 2. Points budget display: "Points: spent/earned", kept stable even
	# when points are unspent so the warning state comes from color/button
	# treatment instead of changing sentence structure. --
	_require(talent_panel._points_label.text == "Points: 0/0", "Expected zero-budget points label, got: %s" % talent_panel._points_label.text)
	_require(_talent_panel_text(talent_panel).contains("Second Subclass"), "Expected one-tree Talent panel to explain the future second subclass slot.")
	_require(not _talent_panel_text(talent_panel).contains("Secondary"), "Expected unchosen secondary subclass teaser to omit the tiny Secondary label.")
	_require(active_talents_panel._points_label.text == "Points: 0/0", "Expected active talent summary to show zero points, got: %s" % active_talents_panel._points_label.text)
	_require(_active_talents_text(active_talents_panel).contains("Thief"), "Expected active talent summary to show the selected tree name.")
	_require(active_talents_panel.find_child("Icon", true, false) != null, "Expected active talent summary to show the selected tree icon.")
	_require(_active_talents_text(active_talents_panel).contains("Intrinsic: Unlocks Quick Cut"), "Expected active talent summary to show the selected tree intrinsic.")
	_require(_active_talents_text(active_talents_panel).contains("Thief Talents"), "Expected active talent summary to show tree-specific talent heading.")
	_require(_active_talents_text(active_talents_panel).contains("No Thief talents selected."), "Expected active talent summary to show empty state for the selected tree.")
	build_state.add_talent_points(1)
	await process_frame
	_require(talent_panel._points_label.text == "Points: 0/1", "Expected unspent-but-earned points label, got: %s" % talent_panel._points_label.text)
	_require(active_talents_panel._points_label.text == "Points: 0/1", "Expected active talent summary to show unspent point budget, got: %s" % active_talents_panel._points_label.text)
	_require(active_talents_panel._open_button.text == "Talent Trees", "Expected Active Talents button copy to stay stable when points are unspent.")
	_require(active_talents_panel._open_button.custom_minimum_size == active_talents_panel.OPEN_BUTTON_SIZE, "Expected Talent Trees button to keep a fixed minimum size.")
	_require(active_talents_panel._button_blink_tween != null and active_talents_panel._button_blink_tween.is_running(), "Expected Active Talents button to blink when points are unspent.")
	_require(not active_talents_panel._open_button.has_theme_stylebox_override("normal"), "Expected unspent-points alert to avoid stylebox overrides that can change button layout.")
	var quick_hands: Talent = thief.talents[0]
	_require(quick_hands.display_name == "Quick Hands", "Expected thief.talents[0] to be Quick Hands.")
	_require(build_state.select_talent(quick_hands), "Expected Quick Hands to be selectable with 1 earned point.")
	await process_frame
	_require(talent_panel._points_label.text == "Points: 1/1", "Expected spent count to increase, got: %s" % talent_panel._points_label.text)
	_require(active_talents_panel._points_label.text == "Points: 1/1", "Expected active talent summary to update spent points, got: %s" % active_talents_panel._points_label.text)
	_require(active_talents_panel._open_button.text == "Talent Trees", "Expected Active Talents button to return to neutral copy when all points are spent.")
	_require(active_talents_panel._button_blink_tween == null, "Expected Active Talents button blink to stop when all points are spent.")
	_require(_active_talents_text(active_talents_panel).contains("Quick Hands"), "Expected active talent summary to list Quick Hands.")
	_require(not combat_screen._talent_overlay.visible, "Expected Talent Trees overlay hidden by default.")
	active_talents_panel._open_button.pressed.emit()
	await process_frame
	_require(combat_screen._talent_overlay.visible, "Expected Active Talents button to open the Talent Trees overlay.")
	combat_screen._talent_overlay.visible = false

	# Now that Practiced Rhythm's OR-group (Quick Hands or Piercing Blades) is
	# satisfied, its remaining lock reason should be about the point budget
	# (0 of 1 earned points left), not the prerequisite.
	var practiced_rhythm: Talent = thief.talents[2]
	_require(practiced_rhythm.display_name == "Practiced Rhythm", "Expected thief.talents[2] to be Practiced Rhythm.")
	reason = talent_panel._talent_lock_reason(practiced_rhythm)
	print("Practiced Rhythm lock reason after Quick Hands (expect budget): %s" % reason)
	_require(reason.contains("Needs"), "Expected a budget-based lock reason once prereqs are satisfiable, got: %s" % reason)

	# -- 3. Skill effect summary text is derived from the skill's own
	# SkillEffect resources. P2:R7 playtest feedback (2026-07-18) found T4's
	# always-visible caption redundant with the hover tooltip and removed
	# it -- the summary now lives in the tooltip only; _skill_effect_summary()
	# itself is unchanged and still feeds both the tooltip and this direct
	# check. --
	var stab: Skill = rogue.base_skills[0]
	_require(stab.display_name == "Stab", "Expected rogue.base_skills[0] to be Stab.")
	var summary: String = available_skills_panel._skill_effect_summary(stab)
	print("Stab effect summary (expect '18 physical dmg'): %s" % summary)
	_require(summary == "18 physical dmg", "Expected Stab's summary text to match its PhysicalDamageEffect.amount, got: %s" % summary)
	var stab_button: Button = available_skills_panel._skills_box.get_child(0)
	_require(stab_button is Button, "Expected each available-skills child to be a bare Button (no always-visible caption wrapper).")
	_require(stab_button.tooltip_text.contains(summary), "Expected Stab's tooltip to contain its effect summary, got: %s" % stab_button.tooltip_text)

	# -- 4. Rotation order + explicit remove control --
	for skill in build_state.unlocked_skills():
		available_skills_panel._on_skill_pressed(skill)
	await process_frame
	_require(build_state.rotation.size() == 3, "Expected 3 unlocked skills in rotation (Stab, Heavy Slash, Quick Cut).")
	_require(skill_build_panel._lock_button.text == "", "Expected lock toggle button to be icon-only, got: %s" % skill_build_panel._lock_button.text)
	_require(skill_build_panel._lock_button.custom_minimum_size == skill_build_panel.LOCK_BUTTON_SIZE, "Expected lock toggle to keep a large fixed button size.")
	_require(skill_build_panel._lock_button.icon == null, "Expected Lock Build button to use the custom child icon, not Button.icon.")
	_require(skill_build_panel._lock_button_icon.texture == skill_build_panel.UNLOCK_ICON, "Expected editable Lock Build button to show the open lock icon.")
	_require(skill_build_panel._lock_button_icon.custom_minimum_size == skill_build_panel.LOCK_BUTTON_ICON_SIZE, "Expected Lock Build icon to keep a fixed readable size.")
	_require(skill_build_panel._lock_button_icon.size == skill_build_panel.LOCK_BUTTON_ICON_SIZE, "Expected Lock Build icon rect to obey its fixed size, got: %s" % skill_build_panel._lock_button_icon.size)
	var first_slot: Button = skill_build_panel._slots_box.get_child(0)
	print("first slot tooltip (expect position 1 of 3): %s" % first_slot.tooltip_text)
	_require(first_slot.tooltip_text.contains("cast position 1 of 3"), "Expected the slot tooltip to state its cast order, got: %s" % first_slot.tooltip_text)
	var has_remove_badge := false
	for child in first_slot.get_children():
		if child is Label and child.text == "x":
			has_remove_badge = true
	_require(has_remove_badge, "Expected an explicit 'x' remove badge on an unlocked rotation slot.")
	skill_build_panel.highlight_rotation_index(1)
	var highlighted_slot: Button = skill_build_panel._slots_box.get_child(1)
	var highlighted_style: StyleBoxFlat = highlighted_slot.get_theme_stylebox("normal")
	_require(highlighted_style.border_color == skill_build_panel.ACTIVE_SLOT_COLOR, "Expected combat playback to highlight the active macro slot.")
	skill_build_panel.set_cast_progress(1, 0.5)
	_require(is_equal_approx(skill_build_panel._slot_fills[1].anchor_right, 0.5), "Expected active macro slot fill to show cast progress.")
	_require(is_equal_approx(skill_build_panel._slot_fills[0].anchor_right, 0.0), "Expected inactive macro slots to stay empty.")
	skill_build_panel.set_cast_progress(1, 1.0, true)
	_require(skill_build_panel._slot_fills[1].color == skill_build_panel.PROC_PROGRESS_FILL_COLOR, "Expected proc/min-cast progress to use the purple fill.")
	skill_build_panel.highlight_rotation_index(1, true)
	highlighted_style = highlighted_slot.get_theme_stylebox("normal")
	_require(highlighted_style.border_color == skill_build_panel.PULSE_SLOT_COLOR, "Expected proc/retrigger playback to pulse the active macro slot.")
	skill_build_panel.clear_combat_highlight()
	highlighted_style = highlighted_slot.get_theme_stylebox("normal")
	_require(highlighted_style.border_color == CardStyle.ACCENT_COLOR, "Expected clearing playback to restore the normal slot border.")

	# Locking the build hides the remove badge (clicking does nothing then).
	build_state.set_locked(true)
	await process_frame
	_require(skill_build_panel._lock_button.text == "", "Expected locked macro button to remain icon-only, got: %s" % skill_build_panel._lock_button.text)
	_require(skill_build_panel._lock_button_icon.texture == skill_build_panel.LOCK_ICON, "Expected locked Lock Build button to show the closed lock icon.")
	var locked_button_style: StyleBoxFlat = skill_build_panel._lock_button.get_theme_stylebox("normal")
	_require(locked_button_style.bg_color == UIColors.BUTTON_FILL_PRESSED, "Expected locked Lock Build button to use the pushed-in dark fill.")
	first_slot = skill_build_panel._slots_box.get_child(0)
	has_remove_badge = false
	for child in first_slot.get_children():
		if child is Label and child.text == "x":
			has_remove_badge = true
	_require(not has_remove_badge, "Expected the remove badge to disappear once the build is locked.")
	build_state.set_locked(false)
	await process_frame

	var rotation_before: int = build_state.rotation.size()
	skill_build_panel._on_slot_pressed(0)
	_require(build_state.rotation.size() == rotation_before - 1, "Expected removing a rotation slot to shrink the rotation.")

	# -- 5. Stat delta from base: Piercing Blades applies a x1.08 physical
	# damage multiplier, so the resolved-vs-base delta should show up as an
	# explicit note on the Physical Damage line. --
	var piercing_blades: Talent = thief.talents[1]
	_require(piercing_blades.display_name == "Piercing Blades", "Expected thief.talents[1] to be Piercing Blades.")
	build_state.add_talent_points(1)
	await process_frame
	_require(build_state.select_talent(piercing_blades), "Expected Piercing Blades to be selectable.")
	await process_frame
	var stats_text: String = character_stats_panel._stats_label.text
	print("")
	print("-- Character stats panel raw text (expect a from-gear/talents delta note as a BBCode hint tooltip) --")
	print(stats_text)
	# Physical Damage is a multiplicative modifier (x1.08), not an additive
	# bonus, so no leading "+" -- P2:R7 playtest-feedback fix, 2026-07-19.
	_require(stats_text.contains("Physical Damage: 8%"), "Expected the resolved Physical Damage line, got: %s" % stats_text)
	# P2:R7 playtest feedback (2026-07-18) moved the delta note out of
	# always-visible inline text and into a hover tooltip (a BBCode
	# [hint=...] tag wrapping the whole stat line) since it "is not relevant
	# to gameplay" as constant on-screen text. The raw bbcode source still
	# carries the delta text (inside the hint attribute), but the rendered/
	# visible text must not.
	_require(stats_text.contains("[hint=8% from gear/talents]Physical Damage: 8%[/hint]"), "Expected the Physical Damage delta to be wrapped as a BBCode hint tooltip, got: %s" % stats_text)
	var visible_stats_text: String = character_stats_panel._stats_label.get_parsed_text()
	print("visible (parsed) stats text: %s" % visible_stats_text)
	_require(not visible_stats_text.contains("from gear/talents"), "Expected the delta note to no longer render as always-visible text, got: %s" % visible_stats_text)
	_require(visible_stats_text.contains("Physical Damage: 8%"), "Expected the Physical Damage value itself to remain visible, got: %s" % visible_stats_text)
	var delta: String = character_stats_panel._stat_delta_text(8.0, "%")
	print("stat delta helper output: %s" % delta)
	_require(delta == " (+8% from gear/talents)", "Expected _stat_delta_text() to format a positive delta, got: %s" % delta)
	_require(character_stats_panel._stat_delta_text(0.0, "%") == "", "Expected a ~zero delta to produce no note.")

	# -- 6. Equipped vs inventory gear clarity --
	var dagger: GearItem = load("res://data/gear/placeholder_dagger.tres")
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(build_state.grant_gear(dagger, true), "Expected the dagger to be granted and auto-equipped.")
	_require(build_state.grant_gear(lucky_coin, false), "Expected Lucky Coin to land in inventory.")
	await process_frame

	var equipped_style: StyleBoxFlat = gear_panel._weapon_slot.get_theme_stylebox("panel")
	var empty_style: StyleBoxFlat = gear_panel._helm_slot.get_theme_stylebox("panel")
	print("equipped weapon slot border color (expect CardStyle.ACCENT_COLOR): %s" % equipped_style.border_color)
	_require(equipped_style.border_color == CardStyle.ACCENT_COLOR, "Expected the equipped weapon slot to carry the accent border, got: %s" % equipped_style.border_color)
	_require(equipped_style.border_color != empty_style.border_color, "Expected equipped and empty slots to use different border colors.")
	_require(equipped_style.border_width_top > empty_style.border_width_top, "Expected the equipped slot's border to be thicker than an empty slot's.")

	# P2:R7 gear-art pass: equipped/empty slots show a real icon (over the
	# existing tier-colored background) instead of a blank colored square.
	# Placeholder Dagger has no named icon of its own, so it falls back to
	# the generic Basic Weapon icon.
	var weapon_icon: TextureRect = gear_panel._weapon_slot.get_node("Icon")
	_require(weapon_icon.texture == GearIcons.BASIC_WEAPON_ICON, "Expected the equipped weapon slot to show the generic Basic Weapon icon.")
	var empty_helm_icon: TextureRect = gear_panel._helm_slot.get_node("Icon")
	_require(empty_helm_icon.texture == null, "Expected an empty slot's icon to stay unset.")

	var inventory_slot: Button = gear_panel._inventory_grid.get_child(0)
	var inventory_style: StyleBoxFlat = inventory_slot.get_theme_stylebox("normal")
	_require(inventory_style.border_color != CardStyle.ACCENT_COLOR, "Expected inventory items to keep the plain slot border, distinct from equipped items.")

	# Inventory item boxes carry the same icon as shop item boxes, shared via
	# CardStyle.build_gear_box_content() (P2:R7 gear-art pass). Lucky Coin is
	# a Basic trinket with its own named icon. The caption text this used to
	# carry alongside the icon was dropped as redundant once the icon art +
	# tier-colored background conveyed slot/tier on their own.
	var inventory_icon: TextureRect = inventory_slot.get_node("Icon")
	_require(inventory_icon.texture == GearIcons.LUCKY_COIN_ICON, "Expected the inventory box to show Lucky Coin's own named icon.")
	var empty_inventory_slot: Button = gear_panel._inventory_grid.get_child(2)
	_require(empty_inventory_slot.get_node_or_null("Icon") == null, "Expected empty inventory slots to stay icon-free.")

	_require(gear_panel._weapon_slot.tooltip_text.contains("Equipped -- Unequip to inventory"), "Expected the equipped-slot tooltip to explain the unequip action, got: %s" % gear_panel._weapon_slot.tooltip_text)
	_require(inventory_slot.tooltip_text.contains("In inventory -- Equip"), "Expected the inventory-slot tooltip to explain the equip action, got: %s" % inventory_slot.tooltip_text)

	var bandit_blade: GearItem = load("res://data/gear/bandit_blade.tres")
	build_state.equip(bandit_blade)
	await process_frame
	_require(gear_panel._weapon_slot.tooltip_text.contains("+1 physical damage per 10 gold in stash"), "Expected equipped Bandit Blade tooltip to include Legendary flavor text, got: %s" % gear_panel._weapon_slot.tooltip_text)

	# Clicking the equipped weapon slot outside a shop round now unequips it
	# to inventory (previously a no-op unless swapping in a replacement).
	var click_event := InputEventMouseButton.new()
	click_event.button_index = MOUSE_BUTTON_LEFT
	click_event.pressed = true
	gear_panel._on_equipped_slot_gui_input(click_event, GearItem.SlotType.WEAPON)
	await process_frame
	print("weapon after unequip click (expect null): %s" % build_state.equipped_weapon)
	_require(build_state.equipped_weapon == null, "Expected clicking the equipped weapon slot to unequip it.")
	_require(build_state.has_inventory_item(dagger), "Expected the unequipped dagger to land back in the inventory.")

	build_state.reset()
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[0])
	await process_frame
	var assassin_summary := _active_talents_text(active_talents_panel)
	_require(assassin_summary.contains("Assassin"), "Expected active talent summary to show Assassin.")
	_require(assassin_summary.contains("Intrinsic: None"), "Expected active talent summary to show Assassin's intrinsic.")
	_require(assassin_summary.contains("Assassin Talents"), "Expected active talent summary to show the Assassin talents section.")
	_require(assassin_summary.contains("No Assassin talents selected."), "Expected active talent summary to show Assassin's empty talent state.")

	print("")
	print("P2:R7:T4 build panels test passed.")
	quit()


func _require(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		assert(condition, message)


func _active_talents_text(active_talents_panel) -> String:
	var parts: PackedStringArray = []
	for label in active_talents_panel.find_children("*", "Label", true, false):
		parts.append(label.text)
	return "\n".join(parts)


func _talent_panel_text(talent_panel) -> String:
	var parts: PackedStringArray = []
	for label in talent_panel.find_children("*", "Label", true, false):
		parts.append(label.text)
	return "\n".join(parts)
