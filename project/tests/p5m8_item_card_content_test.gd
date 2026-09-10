extends SceneTree
## Focused P5M8-T4 check: shared gear card/tooltip text exposes player-facing
## item identity, rarity, slot, family, weapon damage, stats, drawbacks, and
## Specials while hiding generator metadata.

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")


func _initialize() -> void:
	print("-- P5M8 item card content --")
	_check_generated_weapon_card()
	_check_cursed_drawback_grouping()
	_check_unique_special_grouping()
	_check_legendary_card_shape()
	print("P5M8 item card content check: OK")
	quit(0)


func _check_generated_weapon_card() -> void:
	var item := _generated_item(GearItem.Tier.MASTER, GearItem.SlotType.WEAPON, 8401, "gear.test.p5m8.card.weapon")
	var text := "\n".join(CardStyle.gear_tooltip_lines(item))
	_require(text.begins_with(item.display_name), "Expected item name to start generated weapon card, got: %s" % text)
	_require(text.contains("Master Weapon / Dagger"), "Expected rarity, slot, and Rogue family in generated weapon card, got: %s" % text)
	_require(text.contains("Weapon Damage: 17-21"), "Expected generated weapon damage range, got: %s" % text)
	_require(text.contains("Stats:"), "Expected generated weapon stats heading, got: %s" % text)
	_require(_contains_any_formatted_affix(text, item.affixes), "Expected generated weapon formatted stat lines, got: %s" % text)
	_require(_hides_metadata(text, item), "Expected generated weapon card to hide metadata, got: %s" % text)


func _check_cursed_drawback_grouping() -> void:
	var item := _generated_item(GearItem.Tier.CURSED, GearItem.SlotType.CHARM, 8402, "gear.test.p5m8.card.cursed")
	var text := "\n".join(CardStyle.gear_tooltip_lines(item))
	_require(text.contains("Cursed Charm / Necklace"), "Expected Cursed Charm family line, got: %s" % text)
	_require(text.contains("Stats:"), "Expected Cursed positive stats heading, got: %s" % text)
	_require(text.contains("Drawbacks:"), "Expected Cursed drawback heading, got: %s" % text)
	_require(item.affixes.any(func(affix): return affix.is_drawback), "Expected generated Cursed item to have a drawback.")
	_require(_hides_metadata(text, item), "Expected Cursed card to hide metadata, got: %s" % text)


func _check_unique_special_grouping() -> void:
	var item := _generated_item(GearItem.Tier.UNIQUE, GearItem.SlotType.ARMOR, 8403, "gear.test.p5m8.card.unique")
	var text := "\n".join(CardStyle.gear_tooltip_lines(item))
	_require(text.contains("Unique Armor / Doublet"), "Expected Unique Armor family line, got: %s" % text)
	_require(text.contains("Stats:"), "Expected Unique positive stats heading, got: %s" % text)
	_require(text.contains("Special:"), "Expected Unique Special heading, got: %s" % text)
	_require(item.affixes.any(func(affix): return StatCatalog.is_special(StatCatalog.canonical_id_for_modifier(affix))), "Expected generated Unique item to have a Special.")
	_require(_hides_metadata(text, item), "Expected Unique card to hide metadata, got: %s" % text)


func _check_legendary_card_shape() -> void:
	var item: GearItem = load("res://data/gear/wyvern_kriss.tres")
	var text := "\n".join(CardStyle.gear_tooltip_lines(item))
	_require(text.begins_with("Wyvern Kriss"), "Expected Legendary card to start with item name, got: %s" % text)
	_require(text.contains("Legendary Weapon / Dagger"), "Expected Legendary tier/slot/family line, got: %s" % text)
	_require(text.contains("Weapon Damage: 21-27"), "Expected Legendary weapon damage range, got: %s" % text)
	_require(text.contains("Stats:"), "Expected Legendary stats heading, got: %s" % text)
	_require(text.contains("Legendary:"), "Expected Legendary effect heading, got: %s" % text)
	_require(text.contains("Poison ticks twice as fast"), "Expected Legendary effect text, got: %s" % text)
	_require(not text.contains("Poison Tick Interval"), "Expected hidden implementation affix for Wyvern tick rate, got: %s" % text)


func _generated_item(tier: GearItem.Tier, slot: GearItem.SlotType, seed: int, item_id: String) -> GearItem:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var result := GearGenerator.generate_from_request({
		"tier": tier,
		"slot": slot,
		"rng": rng,
		"id": item_id,
		"deterministic_key": "%s:key" % item_id,
		"source_context": "p5m8_item_card_test",
		"source_seed": seed,
	})
	_require(bool(result.get("ok", false)), "Expected item generation to succeed: %s" % result.get("errors", []))
	return result["item"]


func _contains_any_formatted_affix(text: String, affixes: Array[StatModifier]) -> bool:
	for affix in affixes:
		if text.contains(StatModifierFormatter.format(affix)):
			return true
	return false


func _hides_metadata(text: String, item: GearItem) -> bool:
	return (
		not text.contains(item.id)
		and not text.contains(item.deterministic_key)
		and not text.contains(item.source_context)
		and not text.contains(str(item.source_seed))
		and not text.contains("source_seed")
		and not text.contains("deterministic_key")
		and not text.contains("source_context")
	)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
