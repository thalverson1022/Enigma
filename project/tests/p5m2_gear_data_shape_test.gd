extends SceneTree
## Focused P5M2-T2 data-shape check. This verifies the Phase 5 gear vocabulary
## and metadata can exist before five-slot equipment behavior is wired in.


func _init() -> void:
	print("-- P5M2 gear data shape --")
	_check_slot_and_rarity_vocabulary()
	_check_generated_item_metadata()
	_check_authored_item_metadata()
	_check_runtime_save_shape()
	print("P5M2 gear data shape check: OK")
	quit(0)


func _check_slot_and_rarity_vocabulary() -> void:
	_require(
		GearItem.universal_slot_order() == [
			GearItem.SlotType.WEAPON,
			GearItem.SlotType.HELM,
			GearItem.SlotType.ARMOR,
			GearItem.SlotType.TRINKET,
			GearItem.SlotType.CHARM,
		],
		"Expected Phase 5 universal slot order."
	)
	_require(GearGenerator.rogue_item_family_for_slot(GearItem.SlotType.WEAPON) == "Dagger", "Expected Rogue Weapon family.")
	_require(GearGenerator.rogue_item_family_for_slot(GearItem.SlotType.HELM) == "Hood", "Expected Rogue Helm family.")
	_require(GearGenerator.rogue_item_family_for_slot(GearItem.SlotType.ARMOR) == "Doublet", "Expected Rogue Armor family.")
	_require(GearGenerator.rogue_item_family_for_slot(GearItem.SlotType.TRINKET) == "Ring", "Expected Rogue Trinket family.")
	_require(GearGenerator.rogue_item_family_for_slot(GearItem.SlotType.CHARM) == "Necklace", "Expected Rogue Charm family.")
	_require(
		GearItem.rarity_order() == [
			GearItem.Tier.CRUDE,
			GearItem.Tier.BASIC,
			GearItem.Tier.MASTER,
			GearItem.Tier.EPIC,
			GearItem.Tier.CURSED,
			GearItem.Tier.CHAOS,
			GearItem.Tier.UNIQUE,
			GearItem.Tier.LEGENDARY,
		],
		"Expected Phase 5 rarity order."
	)
	for tier in GearItem.rarity_order():
		_require(GearGenerator.TIER_NAMES.has(tier), "Expected display name for tier %s." % tier)
		_require(GearGenerator.PRICE_BY_TIER.has(tier), "Expected placeholder price for tier %s." % tier)


func _check_generated_item_metadata() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var hood := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.HELM, rng, "gear.test.generated_hood")
	_require(hood.id == "gear.test.generated_hood", "Expected stable generated id.")
	_require(hood.slot == GearItem.SlotType.HELM, "Expected generated Hood to keep Helm slot.")
	_require(hood.item_family == "Hood", "Expected generated Hood family metadata.")
	_require(hood.class_family == GearItem.ClassFamily.ROGUE, "Expected generated Rogue class family.")
	_require(hood.source_kind == GearItem.SourceKind.GENERATED, "Expected generated source kind.")
	_require(hood.deterministic_key == "gear.test.generated_hood", "Expected deterministic key.")
	_require(hood.display_name.contains("Hood"), "Expected generated display name to use Rogue family.")
	_require(hood.affixes.size() == 1, "Expected Basic generated gear to keep one stat entry.")
	_require(hood.affixes[0].stat_id != "", "Expected generated stat entry id.")
	_require(hood.affixes[0].category == StatModifier.StatCategory.BASIC, "Expected generated Basic stat category.")


func _check_authored_item_metadata() -> void:
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(lucky_coin != null, "Expected Lucky Coin to load.")
	_require(lucky_coin.slot == GearItem.SlotType.TRINKET, "Expected Lucky Coin to use Phase 5 Trinket slot.")
	_require(lucky_coin.tier == GearItem.Tier.BASIC, "Expected Lucky Coin to remain Basic.")
	_require(lucky_coin.source_kind == GearItem.SourceKind.FIXED, "Expected Lucky Coin fixed source kind.")
	_require(lucky_coin.item_family == "Ring", "Expected Lucky Coin Phase 5 Trinket family metadata.")
	_require(lucky_coin.affixes.size() == 1, "Expected Lucky Coin to retain one fixed stat.")
	_require(lucky_coin.affixes[0].stat_id == "crit_chance", "Expected Lucky Coin stat id.")
	_require(lucky_coin.affixes[0].stat == StatModifier.StatType.CRIT_CHANCE, "Expected Lucky Coin crit chance stat.")
	_require(is_equal_approx(lucky_coin.affixes[0].value, 0.05), "Expected Lucky Coin +5% crit chance.")
	var wyvern: GearItem = load("res://data/gear/wyvern_kriss.tres")
	_require(wyvern != null, "Expected Wyvern Kriss to load.")
	_require(wyvern.slot == GearItem.SlotType.WEAPON, "Expected retained Legendary to remain Weapon-slot.")
	_require(wyvern.source_kind == GearItem.SourceKind.LEGENDARY, "Expected Legendary source kind.")
	_require(wyvern.item_family == "Dagger", "Expected retained Legendary Dagger family.")


func _check_runtime_save_shape() -> void:
	var item := GearItem.new()
	item.id = "gear.test.runtime"
	item.display_name = "Runtime Hood"
	item.slot = GearItem.SlotType.HELM
	item.tier = GearItem.Tier.EPIC
	item.item_family = "Hood"
	item.class_family = GearItem.ClassFamily.ROGUE
	item.source_kind = GearItem.SourceKind.GENERATED
	item.source_context = "test_context"
	item.source_seed = 77
	item.deterministic_key = "runtime_key"
	var modifier := StatModifier.new()
	modifier.stat_id = "crit_chance"
	modifier.stat = StatModifier.StatType.CRIT_CHANCE
	modifier.category = StatModifier.StatCategory.BASIC
	modifier.operation = StatModifier.OperationType.ADD
	modifier.value = 0.05
	modifier.display_label = "Crit Chance"
	item.affixes = [modifier]

	var data = SaveSystem._gear_entry_to_data(item)
	var restored: GearItem = SaveSystem._gear_from_entry(data)
	_require(restored != null, "Expected runtime gear to restore from save data.")
	_require(restored.slot == GearItem.SlotType.HELM, "Expected restored slot metadata.")
	_require(restored.tier == GearItem.Tier.EPIC, "Expected restored tier metadata.")
	_require(restored.item_family == "Hood", "Expected restored item family.")
	_require(restored.source_kind == GearItem.SourceKind.GENERATED, "Expected restored source kind.")
	_require(restored.source_context == "test_context", "Expected restored source context.")
	_require(restored.source_seed == 77, "Expected restored source seed.")
	_require(restored.deterministic_key == "runtime_key", "Expected restored deterministic key.")
	_require(restored.affixes.size() == 1, "Expected restored stat entry.")
	_require(restored.affixes[0].stat_id == "crit_chance", "Expected restored stat id.")
	_require(restored.affixes[0].category == StatModifier.StatCategory.BASIC, "Expected restored stat category.")
	_require(restored.affixes[0].display_label == "Crit Chance", "Expected restored display label.")


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
