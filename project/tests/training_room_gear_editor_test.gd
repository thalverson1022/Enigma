extends SceneTree
## Headless check for the Practice Room paper-doll gear editor: clicking an
## equipment slot opens that slot's focused Rarity/stat popup, choosing a
## slot's Rarity fixes a real GearGenerator-shaped affix count (Basic=1,
## Master=2, Cursed=2 positive + 1 curse=3), picking a stat per slot
## auto-fills that stat's real tier value while staying editable, the weapon
## slot can swap to Legendary (showing a Legendary-name dropdown instead of
## affix rows) and back, and none of it ever touches the real BuildState
## singleton. Run
## with:
##   godot --headless -s res://tests/training_room_gear_editor_test.gd


func _initialize() -> void:
	var build_state = root.get_node("BuildState")

	var game_root_scene: PackedScene = load("res://scenes/game_root.tscn")
	var game_root = game_root_scene.instantiate()
	root.add_child(game_root)
	await process_frame

	# Real Adventure gear, set after game_root's own startup reset (see
	# training_room_entry_test.gd for why this must happen after, not
	# before).
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	var real_equipped_weapon_before: GearItem = build_state.equipped_weapon
	var real_inventory_before: Array[GearItem] = build_state.inventory.duplicate()

	var title = game_root._current_screen
	title.training_room_pressed.emit()
	await process_frame
	var training_room = game_root._current_screen

	var character_stats_panel = training_room.find_child("CharacterStatsPanel", true, false)
	assert(character_stats_panel != null)

	# -- Entering Practice Room starts with no gear equipped. Rarity-first
	# defaults are applied only after the player chooses Basic/Master/Cursed. --
	print("Practice Room starts with no equipped items (expect true): %s" % (
		training_room._state.equipped_gear().is_empty()
	))
	assert(training_room._state.equipped_weapon == null)
	assert(training_room._state.equipped_trinket == null)
	assert(training_room._state.equipped_charm == null)
	assert(training_room._state.equipped_gear().is_empty())
	assert(training_room._state.practice_weapon.affixes.is_empty())
	assert(training_room._state.practice_trinket.affixes.is_empty())
	assert(training_room._state.practice_charm.affixes.is_empty())
	assert(training_room._weapon_slot_button.tooltip_text == "Weapon: Empty")
	assert(training_room._trinket_slot_button.tooltip_text == "Trinket: Empty")
	assert(training_room._charm_slot_button.tooltip_text == "Charm: Empty")
	assert(not training_room._state.is_weapon_legendary())

	training_room._show_gear_slot_editor("Weapon", training_room._state.practice_weapon, true)
	await process_frame
	assert(training_room._gear_editor_overlay.visible)
	assert(training_room._gear_editor_title.text == "Weapon Gear")
	assert(training_room._gear_rarity_option.get_selected_id() == training_room.NONE_RARITY_ID)

	# -- Rarity -> Master resizes to 2 affixes --
	_select_rarity(training_room, GearItem.Tier.MASTER)
	await process_frame
	print("weapon affixes after Master=%d (expect 2)" % training_room._state.practice_weapon.affixes.size())
	assert(training_room._state.equipped_weapon == training_room._state.practice_weapon)
	assert(training_room._state.practice_weapon.affixes.size() == 2)
	assert(training_room._weapon_slot_button.get_node("Icon").texture == GearIcons.MASTER_WEAPON_ICON)
	assert(training_room._weapon_slot_button.tooltip_text.contains("Custom Weapon"))

	# -- Picking a stat auto-fills the real Master value for that stat --
	var modifier: StatModifier = training_room._state.practice_weapon.affixes[0]
	var stats_text_before_edit: String = character_stats_panel._stats_label.text
	var stat_option := _make_stat_option_button(GearGenerator.AFFIX_POOL)
	stat_option.select(stat_option.get_item_index(StatModifier.StatType.PHYSICAL_DAMAGE))
	training_room._on_affix_stat_selected(stat_option.get_selected(), training_room._state.practice_weapon, 0, stat_option)
	await process_frame
	print("auto-filled stat=%d op=%d value=%.2f (expect %d, %d, %.2f)" % [
		modifier.stat, modifier.operation, modifier.value,
		StatModifier.StatType.PHYSICAL_DAMAGE, StatModifier.OperationType.MULTIPLY,
		GearGenerator.MASTER_VALUE[StatModifier.StatType.PHYSICAL_DAMAGE],
	])
	assert(modifier.stat == StatModifier.StatType.PHYSICAL_DAMAGE)
	assert(modifier.operation == StatModifier.OperationType.MULTIPLY)
	assert(is_equal_approx(modifier.value, GearGenerator.MASTER_VALUE[StatModifier.StatType.PHYSICAL_DAMAGE]))
	assert(character_stats_panel._stats_label.text != stats_text_before_edit)

	# -- The auto-filled value stays freely editable afterward (the raw
	# editor's original magnitude-testing power, preserved on top of the new
	# rarity-first defaults) --
	training_room._on_affix_value_changed(1.5, modifier)
	await process_frame
	var resolved := BuildResolver.resolve_stats(
		training_room._state.selected_class, training_room._state.selected_trees,
		training_room._state.selected_talents, training_room._state.equipped_gear()
	)
	print("resolved physical_damage_multiplier after hand-edit=%.2f (expect 1.50)" % resolved.physical_damage_multiplier)
	assert(is_equal_approx(resolved.physical_damage_multiplier, 1.5))

	# -- Rarity -> Cursed resizes to 3 affixes, last one restricted to the
	# downside pool --
	_select_rarity(training_room, GearItem.Tier.CURSED)
	await process_frame
	print("weapon affixes after Cursed=%d (expect 3)" % training_room._state.practice_weapon.affixes.size())
	assert(training_room._state.practice_weapon.affixes.size() == 3)
	var downside_modifier: StatModifier = training_room._state.practice_weapon.affixes[2]
	print("cursed downside stat in DOWNSIDE_POOL (expect true): %s" % GearGenerator.DOWNSIDE_POOL.has(downside_modifier.stat))
	assert(GearGenerator.DOWNSIDE_POOL.has(downside_modifier.stat))
	assert(is_equal_approx(downside_modifier.value, GearGenerator.CURSED_DOWNSIDE_VALUE[downside_modifier.stat]))

	# -- Rarity -> Legendary: affix rows disappear, Legendary dropdown shows,
	# equipping picks a real catalog item --
	var wyvern: GearItem = load("res://data/gear/wyvern_kriss.tres")
	var legendary_index := LegendaryCatalog.all_items().find(wyvern)
	assert(legendary_index >= 0)
	_select_rarity(training_room, GearItem.Tier.LEGENDARY)
	await process_frame
	training_room._gear_legendary_option.select(legendary_index)
	training_room._on_weapon_legendary_selected(legendary_index)
	await process_frame
	assert(training_room._state.is_weapon_legendary())
	assert(training_room._state.equipped_weapon == wyvern)
	print("weapon affix rows hidden while Legendary equipped (expect true): %s" % (not training_room._gear_affix_column.visible))
	assert(not training_room._gear_affix_column.visible)
	assert(training_room._gear_legendary_option.visible)
	assert(training_room._weapon_slot_button.get_node("Icon").texture == GearIcons.WYVERN_KRISS_ICON)
	# Bug fix: the rarity dropdown must stay enabled even in Legendary mode --
	# it's the only way back to Basic/Master/Cursed since the old separate
	# "Custom Weapon" button was removed.
	assert(not training_room._gear_rarity_option.disabled)

	# -- Rarity -> Basic switches back out of Legendary mode and re-sizes the
	# practice item fresh --
	_select_rarity(training_room, GearItem.Tier.BASIC)
	await process_frame
	assert(not training_room._state.is_weapon_legendary())
	print("weapon back to Basic with 1 affix (expect true): %s" % (
		training_room._state.practice_weapon.tier == GearItem.Tier.BASIC
		and training_room._state.practice_weapon.affixes.size() == 1
	))
	assert(training_room._state.equipped_weapon == training_room._state.practice_weapon)
	assert(training_room._state.practice_weapon.tier == GearItem.Tier.BASIC)
	assert(training_room._state.practice_weapon.affixes.size() == 1)

	# -- Trinket/charm slots have no Legendary option (None/Basic/Master/
	# Cursed only) and are always the rarity-driven editor, independent of
	# the weapon slot --
	training_room._show_gear_slot_editor("Trinket", training_room._state.practice_trinket, false)
	await process_frame
	assert(training_room._gear_rarity_option.item_count == 4)
	_select_rarity(training_room, GearItem.Tier.MASTER)
	await process_frame
	print("trinket affixes after Master=%d (expect 2)" % training_room._state.practice_trinket.affixes.size())
	assert(training_room._state.equipped_trinket == training_room._state.practice_trinket)
	assert(training_room._state.practice_trinket.affixes.size() == 2)
	assert(training_room._trinket_slot_button.get_node("Icon").texture == GearIcons.MASTER_TRINKET_ICON)

	# -- Rarity -> None (user-requested) empties the slot entirely and the
	# dropdown reflects "None" selected --
	_select_rarity(training_room, training_room.NONE_RARITY_ID)
	await process_frame
	print("trinket affixes after None=%d (expect 0)" % training_room._state.practice_trinket.affixes.size())
	assert(training_room._state.equipped_trinket == null)
	assert(training_room._state.practice_trinket.affixes.is_empty())
	print("trinket rarity dropdown shows None selected (expect true): %s" % (
		training_room._gear_rarity_option.get_selected_id() == training_room.NONE_RARITY_ID
	))
	assert(training_room._gear_rarity_option.get_selected_id() == training_room.NONE_RARITY_ID)

	# -- Original overflow case: every current slot can be Cursed with three
	# affixes, but the right-panel gear card stays compact because only the
	# selected slot's controls live in the popup. --
	training_room._show_gear_slot_editor("Weapon", training_room._state.practice_weapon, true)
	_select_rarity(training_room, GearItem.Tier.CURSED)
	await process_frame
	training_room._show_gear_slot_editor("Trinket", training_room._state.practice_trinket, false)
	_select_rarity(training_room, GearItem.Tier.CURSED)
	await process_frame
	training_room._show_gear_slot_editor("Charm", training_room._state.practice_charm, false)
	_select_rarity(training_room, GearItem.Tier.CURSED)
	await process_frame
	assert(training_room._state.equipped_gear().size() == 3)
	assert(training_room._state.practice_weapon.affixes.size() == 3)
	assert(training_room._state.practice_trinket.affixes.size() == 3)
	assert(training_room._state.practice_charm.affixes.size() == 3)
	assert(training_room._gear_affix_column.get_child_count() == 3)
	var gear_panel: Control = training_room.find_child("PracticeGearPanel", true, false)
	var viewport_rect := Rect2(Vector2.ZERO, training_room.get_viewport().get_visible_rect().size)
	assert(_rect_contains(viewport_rect, gear_panel.get_global_rect()))
	assert(_rect_contains(viewport_rect, training_room._gear_affix_column.get_global_rect()))

	# -- Isolation: none of this touched the real BuildState's gear --
	print("real equipped weapon unchanged (expect true): %s" % (build_state.equipped_weapon == real_equipped_weapon_before))
	assert(build_state.equipped_weapon == real_equipped_weapon_before)
	assert(build_state.inventory == real_inventory_before)

	print("")
	print("Practice Room gear editor check: OK")
	quit()


func _make_stat_option_button(pool: Array[StatModifier.StatType]) -> OptionButton:
	var option := OptionButton.new()
	for stat_type in pool:
		option.add_item(StatModifierFormatter.STAT_NAMES[stat_type], stat_type)
	return option


func _select_rarity(training_room: Control, tier_id: int) -> void:
	var index: int = training_room._gear_rarity_option.get_item_index(tier_id)
	training_room._gear_rarity_option.select(index)
	training_room._on_editor_rarity_selected(index)


func _rect_contains(outer: Rect2, inner: Rect2) -> bool:
	return (
		inner.position.x >= outer.position.x
		and inner.position.y >= outer.position.y
		and inner.end.x <= outer.end.x
		and inner.end.y <= outer.end.y
	)
