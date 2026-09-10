extends SceneTree
## Focused P5M9-T4 check for named icon overrides and generated icon boundaries.


func _initialize() -> void:
	print("-- P5M9 special icon overrides --")
	_check_lucky_coin_keeps_authored_icon()
	_check_legendary_catalog_keeps_authored_icons()
	_check_generated_legendary_uses_fallback_not_generated_mapping()
	_check_crude_icon_is_dagger_only()
	print("P5M9 special icon overrides check: OK")
	quit(0)


func _check_lucky_coin_keeps_authored_icon() -> void:
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(lucky_coin != null, "Expected Lucky Coin to load.")
	_require(lucky_coin.id == "gear.lucky_coin", "Expected Lucky Coin authored ID.")
	_require(_icon_path(lucky_coin) == "res://assets/Items/Rogue/Lucky_Coin.png", "Expected Lucky Coin to keep its authored icon.")

	var generated_necklace := _make_item(
		"gear.test.generated_basic_necklace",
		GearItem.SlotType.CHARM,
		GearItem.Tier.BASIC
	)
	_require(_icon_path(generated_necklace) == "res://assets/Items/Rogue/Generated/rogue_necklace_basic.png", "Expected generated Basic Necklace to use generated Necklace art.")
	_require(_icon_path(generated_necklace) != "res://assets/Items/Rogue/Lucky_Coin.png", "Expected generated Basic Necklace not to reuse Lucky Coin art.")


func _check_legendary_catalog_keeps_authored_icons() -> void:
	var expected_icons := {
		"gear.legendary.bandit_blade": "res://assets/Items/Rogue/Bandit_Blade.png",
		"gear.legendary.bejeweled_push_dagger": "res://assets/Items/Rogue/Bejeweled_Push_Dagger.png",
		"gear.legendary.mithril_karambit": "res://assets/Items/Rogue/Mithril_Karambit.png",
		"gear.legendary.umbral_stiletto": "res://assets/Items/Rogue/Umbral_Stiletto.png",
		"gear.legendary.wyvern_kriss": "res://assets/Items/Rogue/Wyvern_Kriss.png",
	}
	for item in LegendaryCatalog.all_items():
		_require(expected_icons.has(item.id), "Expected retained Rogue Legendary icon expectation for %s." % item.id)
		_require(_icon_path(item) == expected_icons[item.id], "Expected %s to keep its authored icon." % item.display_name)


func _check_generated_legendary_uses_fallback_not_generated_mapping() -> void:
	var generated_legendary := _make_item(
		"gear.test.generated_legendary_dagger",
		GearItem.SlotType.WEAPON,
		GearItem.Tier.LEGENDARY
	)
	_require(_icon_path(generated_legendary) == "res://assets/ui/icons/gear_drop_helm_legendary.png", "Expected generated Legendary-like gear to use the generic Legendary fallback.")
	_require(_icon_path(generated_legendary) != "res://assets/Items/Rogue/Generated/rogue_dagger_unique.png", "Expected generated Legendary-like gear not to reuse generated Unique Dagger art.")


func _check_crude_icon_is_dagger_only() -> void:
	var crude_dagger := _make_item(
		"gear.test.generated_crude_dagger",
		GearItem.SlotType.WEAPON,
		GearItem.Tier.CRUDE
	)
	_require(_icon_path(crude_dagger) == "res://assets/Items/Rogue/Generated/rogue_dagger_crude.png", "Expected Crude Weapon to use the Crude Dagger icon.")

	for slot in [GearItem.SlotType.HELM, GearItem.SlotType.ARMOR, GearItem.SlotType.TRINKET, GearItem.SlotType.CHARM]:
		var item := _make_item("gear.test.generated_crude_%s" % slot, slot, GearItem.Tier.CRUDE)
		_require(_icon_path(item) == "res://assets/ui/icons/gear_drop_helm_basic.png", "Expected non-Weapon Crude item to use fallback icon.")
		_require(_icon_path(item) != "res://assets/Items/Rogue/Generated/rogue_dagger_crude.png", "Expected Crude generated mapping only for Weapon/Dagger.")


func _make_item(id: String, slot: int, tier: int) -> GearItem:
	var item := GearItem.new()
	item.id = id
	item.display_name = id
	item.slot = slot
	item.tier = tier
	item.item_family = GearGenerator.rogue_item_family_for_slot(slot)
	item.class_family = GearItem.ClassFamily.ROGUE
	item.source_kind = GearItem.SourceKind.GENERATED
	return item


func _icon_path(item: GearItem) -> String:
	var texture := GearIcons.icon_for(item)
	_require(texture != null, "Expected icon texture for %s." % item.id)
	return texture.resource_path


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
