extends SceneTree
## P5M10-T6 fixed-regression coverage for retained Rogue Legendaries.

const SaveSystemScript := preload("res://scripts/systems/save_system.gd")
const StatCatalogScript := preload("res://scripts/systems/stat_catalog.gd")
const GearIconsScript := preload("res://scripts/ui/gear_icons.gd")

const TEST_SAVE_PATH := "res://.test_p5m10_legendary_regression_save.json"
const LEGENDARY_SPECS := [
	{
		"id": "gear.legendary.wyvern_kriss",
		"path": "res://data/gear/wyvern_kriss.tres",
		"icon": "res://assets/Items/Rogue/Wyvern_Kriss.png",
		"stats": [
			{"id": StatCatalogScript.BASE_ELEMENTAL_DAMAGE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 8.0, "label": "Base Elemental Damage"},
			{"id": StatCatalogScript.PERCENT_ELEMENTAL_DAMAGE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.4, "label": "Percent Elemental Damage"},
			{"id": StatCatalogScript.CHANCE_TO_DECAY, "category": StatModifier.StatCategory.RARE, "operation": StatModifier.OperationType.ADD, "value": 0.12, "label": "Chance to Decay"},
			{"id": StatCatalogScript.LEGACY_POISON_TICK_INTERVAL, "category": StatModifier.StatCategory.COMPATIBILITY, "operation": StatModifier.OperationType.MULTIPLY, "value": 0.5, "label": "Poison Tick Interval"},
		],
	},
	{
		"id": "gear.legendary.bandit_blade",
		"path": "res://data/gear/bandit_blade.tres",
		"icon": "res://assets/Items/Rogue/Bandit_Blade.png",
		"stats": [
			{"id": StatCatalogScript.PERCENT_PHYSICAL_DAMAGE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.2, "label": "Percent Physical Damage"},
			{"id": StatCatalogScript.CRIT_CHANCE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.12, "label": "Crit Chance"},
			{"id": StatCatalogScript.INCREASED_GOLD, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.3, "label": "Increased Gold"},
		],
	},
	{
		"id": "gear.legendary.umbral_stiletto",
		"path": "res://data/gear/umbral_stiletto.tres",
		"icon": "res://assets/Items/Rogue/Umbral_Stiletto.png",
		"stats": [
			{"id": StatCatalogScript.CRIT_CHANCE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.1, "label": "Crit Chance"},
			{"id": StatCatalogScript.CRIT_DAMAGE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 1.0, "label": "Crit Damage"},
			{"id": StatCatalogScript.CRIT_APPLIES_ELEMENT, "category": StatModifier.StatCategory.RARE, "operation": StatModifier.OperationType.ADD, "value": 1.0, "label": "Chance for Crits to Apply Poison"},
		],
	},
	{
		"id": "gear.legendary.mithril_karambit",
		"path": "res://data/gear/mithril_karambit.tres",
		"icon": "res://assets/Items/Rogue/Mithril_Karambit.png",
		"stats": [
			{"id": StatCatalogScript.INCREASED_ATTACK_SPEED, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.15, "label": "Increased Attack Speed"},
			{"id": StatCatalogScript.CRIT_CHANCE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.15, "label": "Crit Chance"},
			{"id": StatCatalogScript.CHANCE_TO_SHRED, "category": StatModifier.StatCategory.RARE, "operation": StatModifier.OperationType.ADD, "value": 0.2, "label": "Chance to Shred"},
		],
	},
	{
		"id": "gear.legendary.bejeweled_push_dagger",
		"path": "res://data/gear/bejeweled_push_dagger.tres",
		"icon": "res://assets/Items/Rogue/Bejeweled_Push_Dagger.png",
		"stats": [
			{"id": StatCatalogScript.BASE_DAMAGE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 8.0, "label": "Base Damage"},
			{"id": StatCatalogScript.PERCENT_PHYSICAL_DAMAGE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.2, "label": "Percent Physical Damage"},
			{"id": StatCatalogScript.CRIT_CHANCE, "category": StatModifier.StatCategory.BASIC, "operation": StatModifier.OperationType.ADD, "value": 0.1, "label": "Crit Chance"},
		],
	},
]

var _failed := false


func _initialize() -> void:
	print("-- P5M10 Legendary regression --")
	var build_state = root.get_node("BuildState")
	var original_save_path := SaveSystemScript.save_path
	SaveSystemScript.save_path = TEST_SAVE_PATH
	SaveSystemScript.delete_save()
	build_state.reset(true)

	_check_authored_resources()
	_check_save_load_roundtrip(build_state)
	_check_legacy_id_only_save_entries()
	_check_catalog_generator_and_icon_boundaries()

	SaveSystemScript.delete_save()
	SaveSystemScript.save_path = original_save_path
	build_state.reset(true)
	if _failed:
		print("P5M10 Legendary regression: FAILED")
		quit(1)
		return
	print("P5M10 Legendary regression: OK")
	quit(0)


func _check_authored_resources() -> void:
	for spec in LEGENDARY_SPECS:
		var item: GearItem = load(String(spec["path"]))
		_require("%s loads" % spec["id"], item != null)
		if item == null:
			continue
		_check_item_identity(item, spec)
		_check_fixed_stats(item, spec)
		_check_effect_metadata(item)


func _check_save_load_roundtrip(build_state) -> void:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require("Rogue loads for save", rogue != null)
	build_state.reset(true)
	build_state.set_class(rogue)
	build_state.add_gold(100)
	var equipped: GearItem = load("res://data/gear/bandit_blade.tres")
	_require("Bandit loads for save", equipped != null)
	build_state.equip(equipped)
	for spec in LEGENDARY_SPECS:
		if String(spec["id"]) == equipped.id:
			continue
		var item: GearItem = load(String(spec["path"]))
		_require("Inventory Legendary loads for save: %s" % spec["id"], item != null)
		build_state.inventory.append(item)
	_require("Legendary save succeeds", SaveSystemScript.save_run(build_state))

	build_state.reset(true)
	_require("Legendary load succeeds", SaveSystemScript.load_run(build_state))
	_require("Equipped Legendary restores", build_state.equipped_weapon != null)
	if build_state.equipped_weapon != null:
		_require_equal("Equipped Legendary ID restores", build_state.equipped_weapon.id, "gear.legendary.bandit_blade")
		_check_fixed_stats(build_state.equipped_weapon, _spec_for_id(build_state.equipped_weapon.id))
		_check_effect_metadata(build_state.equipped_weapon)
	var restored_ids := {}
	for item in build_state.inventory:
		restored_ids[item.id] = item
	for spec in LEGENDARY_SPECS:
		if String(spec["id"]) == "gear.legendary.bandit_blade":
			continue
		_require("Inventory Legendary restores: %s" % spec["id"], restored_ids.has(String(spec["id"])))
		if restored_ids.has(String(spec["id"])):
			_check_fixed_stats(restored_ids[String(spec["id"])], spec)
			_check_effect_metadata(restored_ids[String(spec["id"])])


func _check_legacy_id_only_save_entries() -> void:
	for spec in LEGENDARY_SPECS:
		var restored: GearItem = SaveSystemScript._gear_from_save_entry({
			"id": String(spec["id"]),
			"display_name": "Pre-P5M10 stale save entry",
			"slot": GearItem.SlotType.WEAPON,
			"tier": GearItem.Tier.LEGENDARY,
			"source_kind": GearItem.SourceKind.LEGENDARY,
			"affixes": [],
		}, "p5m10_legacy_id_only")
		_require("ID-only save restores canonical authored Legendary: %s" % spec["id"], restored != null)
		if restored != null:
			_check_item_identity(restored, spec)
			_check_fixed_stats(restored, spec)
			_check_effect_metadata(restored)


func _check_catalog_generator_and_icon_boundaries() -> void:
	var seen := {}
	for spec in LEGENDARY_SPECS:
		seen[String(spec["id"])] = false
	for item in LegendaryCatalog.all_items():
		_require("Catalog item loads", item != null)
		if item == null:
			continue
		_require("Catalog has expected P5M10 ID: %s" % item.id, seen.has(item.id))
		seen[item.id] = true
		_require_equal("Catalog Legendary source", item.source_kind, GearItem.SourceKind.LEGENDARY)
		_require_equal("Catalog Legendary tier", item.tier, GearItem.Tier.LEGENDARY)
		_check_fixed_stats(item, _spec_for_id(item.id))
	for id in seen.keys():
		_require("Catalog includes retained Legendary: %s" % id, bool(seen[id]))

	var result := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.LEGENDARY,
		"slot": GearItem.SlotType.WEAPON,
		"seed": 610010,
	})
	_require("Procedural Legendary request fails", not bool(result["ok"]))
	_require("Procedural Legendary returns no item", result["item"] == null)
	_require("Procedural Legendary reports fixed-catalog boundary", (result["errors"] as PackedStringArray).has("legendary_requires_fixed_catalog"))

	for seed in range(1, 8):
		for offer in GearGenerator.generate_offers(8, seed):
			_require("Generated offers do not use retained Legendary IDs", not String(offer.id).begins_with("gear.legendary."))

	for spec in LEGENDARY_SPECS:
		var item: GearItem = load(String(spec["path"]))
		_require_equal("Authored Legendary icon override: %s" % spec["id"], _icon_path(item), String(spec["icon"]))
	var generated := GearItem.new()
	generated.id = "gear.test.p5m10.generated_legendary"
	generated.display_name = "Generated Legendary Boundary"
	generated.slot = GearItem.SlotType.WEAPON
	generated.tier = GearItem.Tier.LEGENDARY
	generated.class_family = GearItem.ClassFamily.ROGUE
	generated.item_family = "Dagger"
	generated.source_kind = GearItem.SourceKind.GENERATED
	_require_equal("Generated Legendary-like icon fallback", _icon_path(generated), "res://assets/ui/icons/gear_drop_helm_legendary.png")


func _check_item_identity(item: GearItem, spec: Dictionary) -> void:
	_require_equal("Legendary ID", item.id, String(spec["id"]))
	_require_equal("Legendary slot", item.slot, GearItem.SlotType.WEAPON)
	_require_equal("Legendary tier", item.tier, GearItem.Tier.LEGENDARY)
	_require_equal("Legendary class family", item.class_family, GearItem.ClassFamily.ROGUE)
	_require_equal("Legendary item family", item.item_family, "Dagger")
	_require_equal("Legendary source kind", item.source_kind, GearItem.SourceKind.LEGENDARY)
	var damage_range := WeaponDamageCatalog.damage_range_for_weapon(item)
	_require_equal("Legendary min weapon damage: %s" % item.id, int(damage_range["min"]), 21)
	_require_equal("Legendary max weapon damage: %s" % item.id, int(damage_range["max"]), 27)


func _check_fixed_stats(item: GearItem, spec: Dictionary) -> void:
	var expected_stats: Array = spec["stats"]
	_require_equal("Fixed stat count: %s" % item.id, item.affixes.size(), expected_stats.size())
	for expected in expected_stats:
		var affix := _find_affix(item, String(expected["id"]))
		_require("Fixed stat exists: %s %s" % [item.id, expected["id"]], affix != null)
		if affix == null:
			continue
		_require_equal("Fixed stat category: %s %s" % [item.id, expected["id"]], affix.category, int(expected["category"]))
		_require_equal("Fixed stat operation: %s %s" % [item.id, expected["id"]], affix.operation, int(expected["operation"]))
		_require_approx("Fixed stat value: %s %s" % [item.id, expected["id"]], affix.value, float(expected["value"]))
		_require_equal("Fixed stat label: %s %s" % [item.id, expected["id"]], affix.display_label, String(expected["label"]))
		if String(expected["id"]) != StatCatalogScript.LEGACY_POISON_TICK_INTERVAL:
			_require("Fixed stat has explicit canonical ID: %s %s" % [item.id, expected["id"]], affix.stat_id == String(expected["id"]))


func _check_effect_metadata(item: GearItem) -> void:
	match item.id:
		"gear.legendary.wyvern_kriss":
			var tick := _find_affix(item, StatCatalogScript.LEGACY_POISON_TICK_INTERVAL)
			_require("Wyvern keeps poison tick effect affix", tick != null and is_equal_approx(tick.value, 0.5))
		"gear.legendary.bandit_blade":
			_require_approx("Bandit keeps gold damage effect", item.physical_damage_per_gold, 0.1)
		"gear.legendary.umbral_stiletto":
			_require("Umbral keeps Death Strike unlock", item.unlocked_skills.any(func(skill): return skill != null and skill.id == CombatResolver.DEATH_STRIKE_SKILL_ID))
		"gear.legendary.mithril_karambit":
			_require_equal("Mithril keeps trigger count", item.triggered_skill_effects.size(), 2)
			for trigger in item.triggered_skill_effects:
				_require_approx("Mithril keeps trigger chance", trigger.chance, 0.5)
				_require("Mithril keeps source filter", trigger.source_skill_ids.has("skill.stab") or trigger.source_skill_ids.has("skill.heavy_slash"))
		"gear.legendary.bejeweled_push_dagger":
			_require_approx("Bejeweled keeps min-cast effect", item.min_cast_time_proc_chance, 0.2)


func _find_affix(item: GearItem, stat_id: String) -> StatModifier:
	for affix in item.affixes:
		if StatCatalogScript.canonical_id_for_modifier(affix) == stat_id:
			return affix
	return null


func _spec_for_id(id: String) -> Dictionary:
	for spec in LEGENDARY_SPECS:
		if String(spec["id"]) == id:
			return spec
	_require("Spec exists: %s" % id, false)
	return {}


func _icon_path(item: GearItem) -> String:
	var texture := GearIconsScript.icon_for(item)
	if texture == null:
		return ""
	return texture.resource_path


func _require(label: String, condition: bool) -> void:
	if condition:
		return
	_failed = true
	print("FAILED: %s" % label)


func _require_equal(label: String, actual: Variant, expected: Variant) -> void:
	if actual == expected:
		return
	_failed = true
	print("FAILED: %s" % label)
	print("  expected: %s" % str(expected))
	print("  actual:   %s" % str(actual))


func _require_approx(label: String, actual: float, expected: float, tolerance: float = 0.001) -> void:
	if absf(actual - expected) <= tolerance:
		return
	_failed = true
	print("FAILED: %s" % label)
	print("  expected: %.4f" % expected)
	print("  actual:   %.4f" % actual)
