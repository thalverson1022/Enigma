extends SceneTree
## Focused P5M9-T7 regression checks for generated Rogue item icon routing.

const GENERATED_ROOT := "res://assets/Items/Rogue/Generated/"
const FALLBACK_BASIC := "res://assets/ui/icons/gear_drop_helm_basic.png"
const FALLBACK_MASTER := "res://assets/ui/icons/gear_drop_helm_master.png"
const FALLBACK_CURSED := "res://assets/ui/icons/gear_drop_helm_cursed.png"
const FALLBACK_LEGENDARY := "res://assets/ui/icons/gear_drop_helm_legendary.png"


func _initialize() -> void:
	print("-- P5M9 icon regression coverage --")
	_check_generated_rogue_catalog_paths()
	_check_generated_asset_metadata_exists()
	_check_crude_remains_dagger_only()
	_check_named_overrides_stay_first()
	_check_fallback_paths_for_unmapped_gear()
	print("P5M9 icon regression coverage: OK")
	quit(0)


func _check_generated_rogue_catalog_paths() -> void:
	for entry in _generated_icon_expectations():
		var item := _make_item(
			"gear.test.%s.%s" % [String(entry["family"]), String(entry["rarity"])],
			int(entry["slot"]),
			int(entry["tier"]),
			GearItem.ClassFamily.ROGUE
		)
		_require(
			_icon_path(item) == String(entry["path"]),
			"Expected %s %s to resolve to %s." % [
				String(entry["family"]),
				String(entry["rarity"]),
				String(entry["path"]),
			]
		)


func _check_generated_asset_metadata_exists() -> void:
	var png_count := 0
	var import_count := 0
	for entry in _generated_icon_expectations():
		var png_path := String(entry["path"])
		var import_path := "%s.import" % png_path
		_require(FileAccess.file_exists(png_path), "Expected generated sprite file to exist: %s." % png_path)
		_require(FileAccess.file_exists(import_path), "Expected Godot import metadata to exist: %s." % import_path)
		png_count += 1
		import_count += 1
	_require(png_count == 31, "Expected 31 generated Rogue PNG files in the regression catalog.")
	_require(import_count == 31, "Expected 31 generated Rogue PNG import metadata files in the regression catalog.")


func _check_crude_remains_dagger_only() -> void:
	var crude_dagger := _make_item(
		"gear.test.crude_dagger",
		GearItem.SlotType.WEAPON,
		GearItem.Tier.CRUDE,
		GearItem.ClassFamily.ROGUE
	)
	_require(_icon_path(crude_dagger) == GENERATED_ROOT + "rogue_dagger_crude.png", "Expected Crude Rogue Weapon to use Crude Dagger art.")

	for slot in [GearItem.SlotType.HELM, GearItem.SlotType.ARMOR, GearItem.SlotType.TRINKET, GearItem.SlotType.CHARM]:
		var crude_item := _make_item(
			"gear.test.crude_non_weapon_%s" % slot,
			slot,
			GearItem.Tier.CRUDE,
			GearItem.ClassFamily.ROGUE
		)
		_require(_icon_path(crude_item) == FALLBACK_BASIC, "Expected Crude non-Weapon Rogue gear to use the Basic fallback.")
		_require(_icon_path(crude_item) != GENERATED_ROOT + "rogue_dagger_crude.png", "Expected Crude Dagger art to remain Weapon-only.")


func _check_named_overrides_stay_first() -> void:
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(lucky_coin != null, "Expected Lucky Coin to load.")
	_require(_icon_path(lucky_coin) == "res://assets/Items/Rogue/Lucky_Coin.png", "Expected Lucky Coin to keep authored icon override.")

	var legendary_expectations := {
		"gear.legendary.bandit_blade": "res://assets/Items/Rogue/Bandit_Blade.png",
		"gear.legendary.bejeweled_push_dagger": "res://assets/Items/Rogue/Bejeweled_Push_Dagger.png",
		"gear.legendary.mithril_karambit": "res://assets/Items/Rogue/Mithril_Karambit.png",
		"gear.legendary.umbral_stiletto": "res://assets/Items/Rogue/Umbral_Stiletto.png",
		"gear.legendary.wyvern_kriss": "res://assets/Items/Rogue/Wyvern_Kriss.png",
	}
	for item in LegendaryCatalog.all_items():
		_require(legendary_expectations.has(item.id), "Expected retained Legendary in icon regression expectations: %s." % item.id)
		_require(_icon_path(item) == legendary_expectations[item.id], "Expected retained Legendary to keep authored icon override: %s." % item.id)


func _check_fallback_paths_for_unmapped_gear() -> void:
	_require(GearIcons.icon_for(null) == null, "Expected null gear to return no icon.")

	var non_rogue_basic := _make_item("gear.test.non_rogue_basic", GearItem.SlotType.HELM, GearItem.Tier.BASIC, GearItem.ClassFamily.NONE)
	var non_rogue_master := _make_item("gear.test.non_rogue_master", GearItem.SlotType.HELM, GearItem.Tier.MASTER, GearItem.ClassFamily.NONE)
	var non_rogue_epic := _make_item("gear.test.non_rogue_epic", GearItem.SlotType.HELM, GearItem.Tier.EPIC, GearItem.ClassFamily.NONE)
	var non_rogue_cursed := _make_item("gear.test.non_rogue_cursed", GearItem.SlotType.HELM, GearItem.Tier.CURSED, GearItem.ClassFamily.NONE)
	var non_rogue_chaos := _make_item("gear.test.non_rogue_chaos", GearItem.SlotType.HELM, GearItem.Tier.CHAOS, GearItem.ClassFamily.NONE)
	var non_rogue_unique := _make_item("gear.test.non_rogue_unique", GearItem.SlotType.HELM, GearItem.Tier.UNIQUE, GearItem.ClassFamily.NONE)
	var generated_legendary := _make_item("gear.test.generated_legendary", GearItem.SlotType.WEAPON, GearItem.Tier.LEGENDARY, GearItem.ClassFamily.ROGUE)

	_require(_icon_path(non_rogue_basic) == FALLBACK_BASIC, "Expected non-Rogue Basic gear to use Basic fallback.")
	_require(_icon_path(non_rogue_master) == FALLBACK_MASTER, "Expected non-Rogue Master gear to use Master fallback.")
	_require(_icon_path(non_rogue_epic) == FALLBACK_MASTER, "Expected non-Rogue Epic gear to use Master fallback art.")
	_require(_icon_path(non_rogue_cursed) == FALLBACK_CURSED, "Expected non-Rogue Cursed gear to use Cursed fallback.")
	_require(_icon_path(non_rogue_chaos) == FALLBACK_CURSED, "Expected non-Rogue Chaos gear to use Cursed fallback art.")
	_require(_icon_path(non_rogue_unique) == FALLBACK_LEGENDARY, "Expected non-Rogue Unique gear to use Legendary fallback art.")
	_require(_icon_path(generated_legendary) == FALLBACK_LEGENDARY, "Expected generated Legendary-like gear to use Legendary fallback art.")
	_require(_icon_path(generated_legendary) != GENERATED_ROOT + "rogue_dagger_unique.png", "Expected generated Legendary-like gear not to reuse Unique Dagger art.")


func _generated_icon_expectations() -> Array[Dictionary]:
	return [
		{"slot": GearItem.SlotType.WEAPON, "tier": GearItem.Tier.CRUDE, "family": "dagger", "rarity": "crude", "path": GENERATED_ROOT + "rogue_dagger_crude.png"},
		{"slot": GearItem.SlotType.WEAPON, "tier": GearItem.Tier.BASIC, "family": "dagger", "rarity": "basic", "path": GENERATED_ROOT + "rogue_dagger_basic.png"},
		{"slot": GearItem.SlotType.WEAPON, "tier": GearItem.Tier.MASTER, "family": "dagger", "rarity": "master", "path": GENERATED_ROOT + "rogue_dagger_master.png"},
		{"slot": GearItem.SlotType.WEAPON, "tier": GearItem.Tier.EPIC, "family": "dagger", "rarity": "epic", "path": GENERATED_ROOT + "rogue_dagger_epic.png"},
		{"slot": GearItem.SlotType.WEAPON, "tier": GearItem.Tier.CURSED, "family": "dagger", "rarity": "cursed", "path": GENERATED_ROOT + "rogue_dagger_cursed.png"},
		{"slot": GearItem.SlotType.WEAPON, "tier": GearItem.Tier.CHAOS, "family": "dagger", "rarity": "chaos", "path": GENERATED_ROOT + "rogue_dagger_chaos.png"},
		{"slot": GearItem.SlotType.WEAPON, "tier": GearItem.Tier.UNIQUE, "family": "dagger", "rarity": "unique", "path": GENERATED_ROOT + "rogue_dagger_unique.png"},
		{"slot": GearItem.SlotType.HELM, "tier": GearItem.Tier.BASIC, "family": "hood", "rarity": "basic", "path": GENERATED_ROOT + "rogue_hood_basic.png"},
		{"slot": GearItem.SlotType.HELM, "tier": GearItem.Tier.MASTER, "family": "hood", "rarity": "master", "path": GENERATED_ROOT + "rogue_hood_master.png"},
		{"slot": GearItem.SlotType.HELM, "tier": GearItem.Tier.EPIC, "family": "hood", "rarity": "epic", "path": GENERATED_ROOT + "rogue_hood_epic.png"},
		{"slot": GearItem.SlotType.HELM, "tier": GearItem.Tier.CURSED, "family": "hood", "rarity": "cursed", "path": GENERATED_ROOT + "rogue_hood_cursed.png"},
		{"slot": GearItem.SlotType.HELM, "tier": GearItem.Tier.CHAOS, "family": "hood", "rarity": "chaos", "path": GENERATED_ROOT + "rogue_hood_chaos.png"},
		{"slot": GearItem.SlotType.HELM, "tier": GearItem.Tier.UNIQUE, "family": "hood", "rarity": "unique", "path": GENERATED_ROOT + "rogue_hood_unique.png"},
		{"slot": GearItem.SlotType.ARMOR, "tier": GearItem.Tier.BASIC, "family": "doublet", "rarity": "basic", "path": GENERATED_ROOT + "rogue_doublet_basic.png"},
		{"slot": GearItem.SlotType.ARMOR, "tier": GearItem.Tier.MASTER, "family": "doublet", "rarity": "master", "path": GENERATED_ROOT + "rogue_doublet_master.png"},
		{"slot": GearItem.SlotType.ARMOR, "tier": GearItem.Tier.EPIC, "family": "doublet", "rarity": "epic", "path": GENERATED_ROOT + "rogue_doublet_epic.png"},
		{"slot": GearItem.SlotType.ARMOR, "tier": GearItem.Tier.CURSED, "family": "doublet", "rarity": "cursed", "path": GENERATED_ROOT + "rogue_doublet_cursed.png"},
		{"slot": GearItem.SlotType.ARMOR, "tier": GearItem.Tier.CHAOS, "family": "doublet", "rarity": "chaos", "path": GENERATED_ROOT + "rogue_doublet_chaos.png"},
		{"slot": GearItem.SlotType.ARMOR, "tier": GearItem.Tier.UNIQUE, "family": "doublet", "rarity": "unique", "path": GENERATED_ROOT + "rogue_doublet_unique.png"},
		{"slot": GearItem.SlotType.TRINKET, "tier": GearItem.Tier.BASIC, "family": "ring", "rarity": "basic", "path": GENERATED_ROOT + "rogue_ring_basic.png"},
		{"slot": GearItem.SlotType.TRINKET, "tier": GearItem.Tier.MASTER, "family": "ring", "rarity": "master", "path": GENERATED_ROOT + "rogue_ring_master.png"},
		{"slot": GearItem.SlotType.TRINKET, "tier": GearItem.Tier.EPIC, "family": "ring", "rarity": "epic", "path": GENERATED_ROOT + "rogue_ring_epic.png"},
		{"slot": GearItem.SlotType.TRINKET, "tier": GearItem.Tier.CURSED, "family": "ring", "rarity": "cursed", "path": GENERATED_ROOT + "rogue_ring_cursed.png"},
		{"slot": GearItem.SlotType.TRINKET, "tier": GearItem.Tier.CHAOS, "family": "ring", "rarity": "chaos", "path": GENERATED_ROOT + "rogue_ring_chaos.png"},
		{"slot": GearItem.SlotType.TRINKET, "tier": GearItem.Tier.UNIQUE, "family": "ring", "rarity": "unique", "path": GENERATED_ROOT + "rogue_ring_unique.png"},
		{"slot": GearItem.SlotType.CHARM, "tier": GearItem.Tier.BASIC, "family": "necklace", "rarity": "basic", "path": GENERATED_ROOT + "rogue_necklace_basic.png"},
		{"slot": GearItem.SlotType.CHARM, "tier": GearItem.Tier.MASTER, "family": "necklace", "rarity": "master", "path": GENERATED_ROOT + "rogue_necklace_master.png"},
		{"slot": GearItem.SlotType.CHARM, "tier": GearItem.Tier.EPIC, "family": "necklace", "rarity": "epic", "path": GENERATED_ROOT + "rogue_necklace_epic.png"},
		{"slot": GearItem.SlotType.CHARM, "tier": GearItem.Tier.CURSED, "family": "necklace", "rarity": "cursed", "path": GENERATED_ROOT + "rogue_necklace_cursed.png"},
		{"slot": GearItem.SlotType.CHARM, "tier": GearItem.Tier.CHAOS, "family": "necklace", "rarity": "chaos", "path": GENERATED_ROOT + "rogue_necklace_chaos.png"},
		{"slot": GearItem.SlotType.CHARM, "tier": GearItem.Tier.UNIQUE, "family": "necklace", "rarity": "unique", "path": GENERATED_ROOT + "rogue_necklace_unique.png"},
	]


func _make_item(id: String, slot: int, tier: int, class_family: int) -> GearItem:
	var item := GearItem.new()
	item.id = id
	item.display_name = id
	item.slot = slot
	item.tier = tier
	item.item_family = GearGenerator.rogue_item_family_for_slot(slot)
	item.class_family = class_family
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
