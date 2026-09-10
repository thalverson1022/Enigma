extends SceneTree
## Focused P5M2-T6 check: old gear assumptions are either migrated or named as
## explicit compatibility/quarantine boundaries.

const BalanceLab = preload("res://scripts/tools/balance_lab.gd")


func _initialize() -> void:
	print("-- P5M2 old gear quarantine boundary --")
	_check_generator_slot_and_tier_boundaries()
	_check_generated_offers_use_active_phase5_slots()
	_check_lucky_coin_stays_out_of_generated_pools()
	_check_active_source_text_has_no_old_three_slot_pool()
	_check_balance_lab_project_identity()
	print("P5M2 old gear quarantine boundary check: OK")
	quit(0)


func _check_generator_slot_and_tier_boundaries() -> void:
	_require(GearGenerator.ALL_SLOTS == GearItem.universal_slot_order(), "Expected generated slots to use five-slot universal order.")
	_require(GearGenerator.PHASE5_ALL_SLOTS == GearItem.universal_slot_order(), "Expected Phase 5 slot vocabulary to match universal order.")
	_require(GearGenerator.PHASE5_ALL_TIERS == GearItem.rarity_order(), "Expected Phase 5 rarity vocabulary to match canonical order.")

	var expected_active_tiers: Array[GearItem.Tier] = [
		GearItem.Tier.BASIC,
		GearItem.Tier.MASTER,
		GearItem.Tier.EPIC,
		GearItem.Tier.CURSED,
		GearItem.Tier.CHAOS,
		GearItem.Tier.UNIQUE,
	]
	_require(GearGenerator.ACTIVE_GENERATED_TIERS == expected_active_tiers, "Expected active generated tiers to use the P5M5 procedural pool.")
	_require(GearGenerator.ACTIVE_GENERATED_TIERS != GearGenerator.PHASE5_ALL_TIERS, "Expected active generated tiers to remain distinct from full Phase 5 tiers because Crude and Legendary are not procedural.")


func _check_generated_offers_use_active_phase5_slots() -> void:
	var offers := GearGenerator.generate_offers(120, 606)
	var seen_slots := {}
	for offer in offers:
		_require(GearGenerator.ALL_SLOTS.has(offer.slot), "Expected offer slot inside active five-slot pool.")
		_require(GearGenerator.ACTIVE_GENERATED_TIERS.has(offer.tier), "Expected offer tier inside active generated tier pool.")
		seen_slots[offer.slot] = true
	for slot in GearItem.universal_slot_order():
		_require(seen_slots.has(slot), "Expected deterministic offer sample to include slot %s." % GearGenerator.universal_slot_label(slot))


func _check_lucky_coin_stays_out_of_generated_pools() -> void:
	for offer in GearGenerator.generate_offers(80, 777):
		_require(offer.id != "gear.lucky_coin", "Expected shop/generated offer not to reuse Lucky Coin id.")
		_require(offer.display_name != "Lucky Coin", "Expected shop/generated offer not to reuse Lucky Coin name.")
	for legendary in LegendaryCatalog.all_items():
		_require(legendary.id != "gear.lucky_coin", "Expected Lucky Coin outside Legendary catalog.")


func _check_active_source_text_has_no_old_three_slot_pool() -> void:
	var gear_generator_source := FileAccess.get_file_as_string("res://scripts/systems/gear_generator.gd")
	var route_generator_source := FileAccess.get_file_as_string("res://scripts/systems/contract_route_generator/contract_route_generator.gd")
	var old_inline_pool := "[GearItem.SlotType.WEAPON, GearItem.SlotType.TRINKET, GearItem.SlotType.CHARM]"
	var old_inline_pool_wrapped := "WEAPON, GearItem.SlotType.TRINKET, GearItem.SlotType.CHARM"
	_require(not gear_generator_source.contains(old_inline_pool), "Expected GearGenerator not to carry the old inline three-slot pool.")
	_require(not gear_generator_source.contains(old_inline_pool_wrapped), "Expected GearGenerator not to carry the old wrapped three-slot pool.")
	_require(not route_generator_source.contains(old_inline_pool), "Expected route generator not to carry the old inline three-slot pool.")
	_require(not route_generator_source.contains(old_inline_pool_wrapped), "Expected route generator not to carry the old wrapped three-slot pool.")


func _check_balance_lab_project_identity() -> void:
	var report := BalanceLab.run_suite()
	_require(report["project"] == "Project Enigma", "Expected active Balance Lab project identity to use Project Enigma.")


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
