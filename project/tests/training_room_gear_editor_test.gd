extends SceneTree
## Headless check for the rarity-first gear editor (reworked post-P2:R10,
## from a UI-feedback pass): choosing a slot's Rarity fixes a real
## GearGenerator-shaped affix count (Basic=1, Master=2, Cursed=2 positive +
## 1 curse=3), picking a stat per slot auto-fills that stat's real tier
## value while staying editable, the weapon slot's Rarity dropdown can swap
## to Legendary (showing a Legendary-name dropdown instead of affix rows)
## and back, and none of it ever touches the real BuildState singleton. Run
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

	# -- Entering Training Room starts with no gear equipped. Rarity-first
	# defaults are applied only after the player chooses Basic/Master/Cursed. --
	print("Training Room starts with no equipped items (expect true): %s" % (
		training_room._state.equipped_gear().is_empty()
	))
	assert(training_room._state.equipped_weapon == null)
	assert(training_room._state.equipped_trinket == null)
	assert(training_room._state.equipped_charm == null)
	assert(training_room._state.equipped_gear().is_empty())
	assert(training_room._state.practice_weapon.affixes.is_empty())
	assert(training_room._state.practice_trinket.affixes.is_empty())
	assert(training_room._state.practice_charm.affixes.is_empty())
	assert(training_room._weapon_rarity_option.get_selected_id() == training_room.NONE_RARITY_ID)
	assert(training_room._trinket_rarity_option.get_selected_id() == training_room.NONE_RARITY_ID)
	assert(training_room._charm_rarity_option.get_selected_id() == training_room.NONE_RARITY_ID)
	assert(not training_room._state.is_weapon_legendary())

	# -- Rarity -> Master resizes to 2 affixes --
	training_room._on_rarity_selected(
		training_room._weapon_rarity_option.get_item_index(GearItem.Tier.MASTER),
		training_room._weapon_rarity_option, training_room._state.practice_weapon, true
	)
	await process_frame
	print("weapon affixes after Master=%d (expect 2)" % training_room._state.practice_weapon.affixes.size())
	assert(training_room._state.equipped_weapon == training_room._state.practice_weapon)
	assert(training_room._state.practice_weapon.affixes.size() == 2)

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
	training_room._on_rarity_selected(
		training_room._weapon_rarity_option.get_item_index(GearItem.Tier.CURSED),
		training_room._weapon_rarity_option, training_room._state.practice_weapon, true
	)
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
	training_room._weapon_legendary_option.select(legendary_index)
	training_room._on_weapon_legendary_selected(legendary_index)
	await process_frame
	assert(training_room._state.is_weapon_legendary())
	assert(training_room._state.equipped_weapon == wyvern)
	print("weapon affix rows hidden while Legendary equipped (expect true): %s" % (not training_room._weapon_affix_column.visible))
	assert(not training_room._weapon_affix_column.visible)
	assert(training_room._weapon_legendary_option.visible)
	# Bug fix: the rarity dropdown must stay enabled even in Legendary mode --
	# it's the only way back to Basic/Master/Cursed since the old separate
	# "Custom Weapon" button was removed.
	assert(not training_room._weapon_rarity_option.disabled)

	# -- Rarity -> Basic switches back out of Legendary mode and re-sizes the
	# practice item fresh --
	training_room._on_rarity_selected(
		training_room._weapon_rarity_option.get_item_index(GearItem.Tier.BASIC),
		training_room._weapon_rarity_option, training_room._state.practice_weapon, true
	)
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
	assert(training_room._trinket_rarity_option.item_count == 4)
	training_room._on_rarity_selected(
		training_room._trinket_rarity_option.get_item_index(GearItem.Tier.MASTER),
		training_room._trinket_rarity_option, training_room._state.practice_trinket, false
	)
	await process_frame
	print("trinket affixes after Master=%d (expect 2)" % training_room._state.practice_trinket.affixes.size())
	assert(training_room._state.equipped_trinket == training_room._state.practice_trinket)
	assert(training_room._state.practice_trinket.affixes.size() == 2)

	# -- Rarity -> None (user-requested) empties the slot entirely and the
	# dropdown reflects "None" selected --
	training_room._on_rarity_selected(
		training_room._trinket_rarity_option.get_item_index(training_room.NONE_RARITY_ID),
		training_room._trinket_rarity_option, training_room._state.practice_trinket, false
	)
	await process_frame
	print("trinket affixes after None=%d (expect 0)" % training_room._state.practice_trinket.affixes.size())
	assert(training_room._state.equipped_trinket == null)
	assert(training_room._state.practice_trinket.affixes.is_empty())
	print("trinket rarity dropdown shows None selected (expect true): %s" % (
		training_room._trinket_rarity_option.get_selected_id() == training_room.NONE_RARITY_ID
	))
	assert(training_room._trinket_rarity_option.get_selected_id() == training_room.NONE_RARITY_ID)

	# -- Isolation: none of this touched the real BuildState's gear --
	print("real equipped weapon unchanged (expect true): %s" % (build_state.equipped_weapon == real_equipped_weapon_before))
	assert(build_state.equipped_weapon == real_equipped_weapon_before)
	assert(build_state.inventory == real_inventory_before)

	print("")
	print("Training Room gear editor check: OK")
	quit()


func _make_stat_option_button(pool: Array[StatModifier.StatType]) -> OptionButton:
	var option := OptionButton.new()
	for stat_type in pool:
		option.add_item(StatModifierFormatter.STAT_NAMES[stat_type], stat_type)
	return option
