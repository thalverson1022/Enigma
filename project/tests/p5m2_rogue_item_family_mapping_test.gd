extends SceneTree
## Focused P5M2-T4 check: universal slot labels stay separate from Rogue
## item-family display names, while named Legendaries keep their identities.


func _initialize() -> void:
	print("-- P5M2 Rogue item family mapping --")
	_check_canonical_mapping()
	_check_generated_rogue_names_and_tooltips()
	_check_legendary_identity_boundary()
	_check_practice_room_family_metadata()
	_check_save_load_family_preservation()
	print("P5M2 Rogue item family mapping check: OK")
	quit(0)


func _check_canonical_mapping() -> void:
	var expected_families := {
		GearItem.SlotType.WEAPON: "Dagger",
		GearItem.SlotType.HELM: "Hood",
		GearItem.SlotType.ARMOR: "Doublet",
		GearItem.SlotType.TRINKET: "Ring",
		GearItem.SlotType.CHARM: "Necklace",
	}
	var expected_slots := {
		GearItem.SlotType.WEAPON: "Weapon",
		GearItem.SlotType.HELM: "Helm",
		GearItem.SlotType.ARMOR: "Armor",
		GearItem.SlotType.TRINKET: "Trinket",
		GearItem.SlotType.CHARM: "Charm",
	}
	for slot in GearItem.universal_slot_order():
		_require(GearGenerator.rogue_item_family_for_slot(slot) == expected_families[slot], "Expected Rogue family for slot %s." % slot)
		_require(GearGenerator.universal_slot_label(slot) == expected_slots[slot], "Expected universal label for slot %s." % slot)


func _check_generated_rogue_names_and_tooltips() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 7401
	for slot in GearItem.universal_slot_order():
		var item: GearItem = GearGenerator.generate(GearItem.Tier.BASIC, slot, rng, "gear.test.family_%s" % slot)
		var family: String = GearGenerator.rogue_item_family_for_slot(slot)
		var slot_label: String = GearGenerator.universal_slot_label(slot)
		_require(item.class_family == GearItem.ClassFamily.ROGUE, "Expected generated item to be Rogue family.")
		_require(item.item_family == family, "Expected generated item family %s." % family)
		_require(item.display_name.contains(family), "Expected generated display name to use %s, got %s." % [family, item.display_name])
		var lines: PackedStringArray = CardStyle.gear_tooltip_lines(item)
		_require(lines[0] == item.display_name, "Expected tooltip to start with item name, got %s." % lines[0])
		_require(lines[1] == "Basic %s / %s" % [slot_label, family], "Expected tooltip to show rarity, universal slot, and Rogue family, got %s." % lines[1])


func _check_legendary_identity_boundary() -> void:
	for legendary in LegendaryCatalog.all_items():
		_require(legendary.tier == GearItem.Tier.LEGENDARY, "Expected Legendary tier for %s." % legendary.display_name)
		_require(legendary.slot == GearItem.SlotType.WEAPON, "Expected retained Legendary to remain Weapon-slot.")
		_require(legendary.item_family == "Dagger", "Expected retained Legendary Dagger family metadata.")
		_require(legendary.display_name != legendary.item_family, "Expected Legendary to keep a named identity, got generic %s." % legendary.display_name)
		var lines: PackedStringArray = LegendaryCatalog.tooltip_lines(legendary)
		_require(lines[0] == legendary.display_name, "Expected Legendary tooltip to start with named item identity, got %s." % lines[0])
		_require(lines[1] == "Legendary Weapon / Dagger", "Expected Legendary tooltip to show tier, slot, and family, got %s." % lines[1])


func _check_practice_room_family_metadata() -> void:
	var state: TrainingRoomState = TrainingRoomState.new()
	var practice_items: Array[GearItem] = [
		state.practice_weapon,
		state.practice_helm,
		state.practice_armor,
		state.practice_trinket,
		state.practice_charm,
	]
	for item in practice_items:
		_require(item.item_family == GearGenerator.rogue_item_family_for_slot(item.slot), "Expected Practice Room item family metadata for %s." % item.display_name)


func _check_save_load_family_preservation() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 8802
	var generated: GearItem = GearGenerator.generate(GearItem.Tier.MASTER, GearItem.SlotType.ARMOR, rng, "gear.test.saved_doublet")
	var entry: Dictionary = SaveSystem._gear_entry_to_data(generated)
	var restored: GearItem = SaveSystem._gear_from_entry(entry)
	_require(restored.item_family == "Doublet", "Expected saved runtime item family to roundtrip.")
	_require(restored.display_name.contains("Doublet"), "Expected saved display name to keep Rogue family text.")

	var old_entry: Dictionary = {
		"id": "gear.test.old_runtime_helm",
		"display_name": "Old Saved Hood",
		"slot": GearItem.SlotType.HELM,
		"tier": GearItem.Tier.BASIC,
		"class_family": GearItem.ClassFamily.ROGUE,
		"affixes": [],
	}
	var migrated: GearItem = SaveSystem._gear_from_entry(old_entry)
	_require(migrated.item_family == "Hood", "Expected missing Rogue item_family to load with Hood fallback.")


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
