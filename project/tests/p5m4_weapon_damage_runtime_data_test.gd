extends SceneTree

const WeaponDamageCatalog := preload("res://scripts/systems/weapon_damage_catalog.gd")


func _initialize() -> void:
	print("-- P5M4 weapon damage runtime data --")
	_check_dagger_ranges_by_rarity()
	_check_equipped_weapon_lookup()
	_check_safe_fallbacks()
	_check_adventure_starter_dagger()
	_check_retained_legendaries_use_legendary_range()
	print("P5M4 weapon damage runtime data check: OK")
	quit(0)


func _check_dagger_ranges_by_rarity() -> void:
	_assert_range(WeaponDamageCatalog.damage_range_for_tier(GearItem.Tier.CRUDE), 16, 20, GearItem.Tier.CRUDE, false, "", "Crude range")
	_assert_range(WeaponDamageCatalog.damage_range_for_tier(GearItem.Tier.BASIC), 17, 19, GearItem.Tier.BASIC, false, "", "Basic range")
	_assert_range(WeaponDamageCatalog.damage_range_for_tier(GearItem.Tier.MASTER), 17, 21, GearItem.Tier.MASTER, false, "", "Master range")
	_assert_range(WeaponDamageCatalog.damage_range_for_tier(GearItem.Tier.EPIC), 18, 20, GearItem.Tier.EPIC, false, "", "Epic range")
	_assert_range(WeaponDamageCatalog.damage_range_for_tier(GearItem.Tier.CURSED), 17, 23, GearItem.Tier.CURSED, false, "", "Cursed range")
	_assert_range(WeaponDamageCatalog.damage_range_for_tier(GearItem.Tier.CHAOS), 16, 25, GearItem.Tier.CHAOS, false, "", "Chaos range")
	_assert_range(WeaponDamageCatalog.damage_range_for_tier(GearItem.Tier.UNIQUE), 19, 25, GearItem.Tier.UNIQUE, false, "", "Unique range")
	_assert_range(WeaponDamageCatalog.damage_range_for_tier(GearItem.Tier.LEGENDARY), 21, 27, GearItem.Tier.LEGENDARY, false, "", "Legendary range")


func _check_equipped_weapon_lookup() -> void:
	var weapon := _gear(GearItem.SlotType.WEAPON, GearItem.Tier.CURSED, "gear.test.cursed_weapon")
	var helm := _gear(GearItem.SlotType.HELM, GearItem.Tier.UNIQUE, "gear.test.unique_helm")
	var range := BuildResolver.resolve_weapon_damage_range([helm, weapon])
	_assert_range(range, 17, 23, GearItem.Tier.CURSED, false, "", "Equipped Weapon lookup")
	_require(range["weapon_id"] == "gear.test.cursed_weapon", "Expected range to report source weapon id.")

	var stats := BuildResolver.resolve_stats(null, [], [], [helm, weapon])
	_assert_range(stats.weapon_damage_range(), 17, 23, GearItem.Tier.CURSED, false, "", "PlayerStats weapon range bridge")
	_require(stats.weapon_damage_weapon_id == "gear.test.cursed_weapon", "Expected PlayerStats to report source weapon id.")


func _check_safe_fallbacks() -> void:
	_assert_range(
		WeaponDamageCatalog.damage_range_for_weapon(null),
		1,
		1,
		GearItem.Tier.CRUDE,
		true,
		WeaponDamageCatalog.FALLBACK_REASON_MISSING,
		"Missing weapon fallback"
	)

	var charm := _gear(GearItem.SlotType.CHARM, GearItem.Tier.UNIQUE, "gear.test.bad_slot")
	_assert_range(
		WeaponDamageCatalog.damage_range_for_weapon(charm),
		1,
		1,
		GearItem.Tier.CRUDE,
		true,
		WeaponDamageCatalog.FALLBACK_REASON_INVALID_SLOT,
		"Non-weapon fallback"
	)
	_assert_range(
		BuildResolver.resolve_weapon_damage_range([charm]),
		1,
		1,
		GearItem.Tier.CRUDE,
		true,
		WeaponDamageCatalog.FALLBACK_REASON_MISSING,
		"Equipped gear without weapon fallback"
	)

	var bad_tier := _gear(GearItem.SlotType.WEAPON, 999, "gear.test.bad_tier")
	_assert_range(
		WeaponDamageCatalog.damage_range_for_weapon(bad_tier),
		1,
		1,
		GearItem.Tier.CRUDE,
		true,
		WeaponDamageCatalog.FALLBACK_REASON_UNKNOWN_TIER,
		"Unknown tier fallback"
	)


func _check_adventure_starter_dagger() -> void:
	var build_state = root.get_node_or_null("BuildState")
	_require(build_state != null, "Expected BuildState autoload for starter dagger check.")
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.reset()
	build_state.set_class(rogue)
	_require(build_state.equipped_weapon != null, "Expected new Adventure Rogue to start with a weapon.")
	_require(build_state.equipped_weapon.id == "gear.crude_dagger", "Expected new Adventure Rogue to start with Crude Dagger.")
	var stats := BuildResolver.resolve_stats(rogue, [], [], build_state.equipped_gear())
	_assert_range(stats.weapon_damage_range(), 16, 20, GearItem.Tier.CRUDE, false, "", "Starter Crude Dagger range")


func _check_retained_legendaries_use_legendary_range() -> void:
	for path in [
		"res://data/gear/wyvern_kriss.tres",
		"res://data/gear/bandit_blade.tres",
		"res://data/gear/umbral_stiletto.tres",
		"res://data/gear/mithril_karambit.tres",
		"res://data/gear/bejeweled_push_dagger.tres",
	]:
		var item: GearItem = load(path)
		_require(item != null, "Expected retained Legendary to load: %s" % path)
		_require(item.slot == GearItem.SlotType.WEAPON, "Expected retained Legendary to remain a Weapon: %s" % path)
		_assert_range(
			WeaponDamageCatalog.damage_range_for_weapon(item),
			21,
			27,
			GearItem.Tier.LEGENDARY,
			false,
			"",
			"Legendary range for %s" % item.display_name
		)


func _gear(slot: int, tier: int, id: String) -> GearItem:
	var item := GearItem.new()
	item.id = id
	item.slot = slot
	item.tier = tier
	item.item_family = GearGenerator.rogue_item_family_for_slot(slot)
	item.class_family = GearItem.ClassFamily.ROGUE
	item.source_kind = GearItem.SourceKind.GENERATED
	return item


func _assert_range(range: Dictionary, minimum: int, maximum: int, tier: int, uses_fallback: bool, fallback_reason: String, label: String) -> void:
	_require(int(range["min"]) == minimum, "%s expected min %d, got %d." % [label, minimum, int(range["min"])])
	_require(int(range["max"]) == maximum, "%s expected max %d, got %d." % [label, maximum, int(range["max"])])
	_require(int(range["tier"]) == tier, "%s expected tier %d, got %d." % [label, tier, int(range["tier"])])
	_require(bool(range["uses_fallback"]) == uses_fallback, "%s expected fallback %s, got %s." % [label, uses_fallback, bool(range["uses_fallback"])])
	_require(String(range["fallback_reason"]) == fallback_reason, "%s expected fallback reason '%s', got '%s'." % [label, fallback_reason, String(range["fallback_reason"])])


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
