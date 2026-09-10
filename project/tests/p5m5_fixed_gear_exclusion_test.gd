extends SceneTree
## Focused P5M5-T11 check for fixed, Legendary, and compatibility gear
## exclusion from procedural generation.

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")
const FIXED_EXCLUDED_IDS := {
	"gear.lucky_coin": true,
	"gear.placeholder_dagger": true,
}


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset(true)
	print("-- P5M5 fixed gear exclusion --")
	_check_lucky_coin_remains_fixed_authored_gear()
	_check_placeholder_dagger_remains_compatibility_gear()
	_check_legendary_catalog_remains_fixed_authored_gear()
	_check_procedural_requests_reject_non_generated_sources()
	_check_generated_offers_exclude_fixed_and_catalog_gear()
	_check_generated_reward_choices_exclude_fixed_and_catalog_gear(build_state)
	_check_fixed_reward_path_can_still_grant_lucky_coin(build_state)
	build_state.reset(true)
	print("P5M5 fixed gear exclusion check: OK")
	quit(0)


func _check_lucky_coin_remains_fixed_authored_gear() -> void:
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(lucky_coin != null, "Expected Lucky Coin to load.")
	_require(lucky_coin.id == "gear.lucky_coin", "Expected Lucky Coin authored ID.")
	_require(lucky_coin.display_name == "Lucky Coin", "Expected Lucky Coin authored name.")
	_require(lucky_coin.slot == GearItem.SlotType.TRINKET, "Expected Lucky Coin to remain Trinket slot.")
	_require(lucky_coin.tier == GearItem.Tier.BASIC, "Expected Lucky Coin to remain Basic tier.")
	_require(lucky_coin.item_family == "Ring", "Expected Lucky Coin to remain Rogue Ring family.")
	_require(lucky_coin.source_kind == GearItem.SourceKind.FIXED, "Expected Lucky Coin to remain fixed source kind.")
	_require(lucky_coin.affixes.size() == 1, "Expected Lucky Coin to retain one fixed affix.")
	var affix: StatModifier = lucky_coin.affixes[0]
	_require(StatCatalog.canonical_id_for_modifier(affix) == StatCatalog.CRIT_CHANCE, "Expected Lucky Coin to keep fixed Crit Chance.")
	_require(affix.category == StatModifier.StatCategory.BASIC, "Expected Lucky Coin fixed stat to be Basic category.")
	_require(not affix.is_drawback, "Expected Lucky Coin fixed stat not to be a drawback.")
	_require(is_equal_approx(affix.value, 0.05), "Expected Lucky Coin to keep +5% Crit Chance.")


func _check_placeholder_dagger_remains_compatibility_gear() -> void:
	var placeholder: GearItem = load("res://data/gear/placeholder_dagger.tres")
	_require(placeholder != null, "Expected placeholder dagger to load.")
	_require(placeholder.id == "gear.placeholder_dagger", "Expected placeholder dagger authored ID.")
	_require(placeholder.slot == GearItem.SlotType.WEAPON, "Expected placeholder dagger to remain Weapon slot.")
	_require(placeholder.item_family == "Dagger", "Expected placeholder dagger Rogue family.")
	_require(placeholder.source_kind == GearItem.SourceKind.COMPATIBILITY, "Expected placeholder dagger to remain compatibility gear.")
	_require(placeholder.id not in _generated_ids_sample(), "Expected generated samples not to reuse placeholder dagger ID.")


func _check_legendary_catalog_remains_fixed_authored_gear() -> void:
	var legendary_ids := {}
	for item in LegendaryCatalog.all_items():
		_require(item != null, "Expected Legendary catalog item to load.")
		_require(item.id.begins_with("gear.legendary."), "Expected Legendary catalog ID namespace.")
		_require(item.tier == GearItem.Tier.LEGENDARY, "Expected catalog item to stay Legendary tier.")
		_require(item.source_kind == GearItem.SourceKind.LEGENDARY, "Expected catalog item to stay Legendary source kind.")
		_require(item.id != "gear.lucky_coin", "Expected Lucky Coin outside Legendary catalog.")
		_require(item.id != "gear.placeholder_dagger", "Expected placeholder dagger outside Legendary catalog.")
		_require(not legendary_ids.has(item.id), "Expected Legendary catalog IDs to be unique.")
		legendary_ids[item.id] = true
	_require(legendary_ids.size() == LegendaryCatalog.all_paths().size(), "Expected every Legendary path to have a unique item ID.")


func _check_procedural_requests_reject_non_generated_sources() -> void:
	for source_kind in [GearItem.SourceKind.FIXED, GearItem.SourceKind.LEGENDARY, GearItem.SourceKind.COMPATIBILITY]:
		var result := GearGenerator.generate_from_request({
			"tier": GearItem.Tier.BASIC,
			"slot": GearItem.SlotType.WEAPON,
			"source_kind": source_kind,
			"seed": 11011,
		})
		_require(not result["ok"], "Expected non-generated source request to fail.")
		_require(result["item"] == null, "Expected non-generated source request not to return an item.")
		_require((result["errors"] as PackedStringArray).has("procedural_source_kind_required"), "Expected procedural source-kind error.")


func _check_generated_offers_exclude_fixed_and_catalog_gear() -> void:
	for seed in range(1, 80):
		for offer in GearGenerator.generate_offers(16, seed):
			_require(_is_clean_generated_item(offer), "Expected generated offers to exclude authored/fixed gear.")


func _check_generated_reward_choices_exclude_fixed_and_catalog_gear(build_state) -> void:
	build_state.reset(true)
	build_state.adventure_seed = 511011
	var reward := EncounterReward.new()
	reward.generated_gear_choice_count = 8
	reward.generated_gear_tier = GearItem.Tier.UNIQUE
	var slots: Array[int] = []
	slots.append_array(GearItem.universal_slot_order())
	reward.generated_gear_slots = slots
	var choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	_require(choices.size() == 8, "Expected generated reward choices.")
	for choice in choices:
		_require(_is_clean_generated_item(choice), "Expected generated reward choices to exclude authored/fixed gear.")


func _check_fixed_reward_path_can_still_grant_lucky_coin(build_state) -> void:
	build_state.reset(true)
	build_state.current_encounter_index = 1
	build_state.finish_fight(true)
	_require(build_state.claim_current_reward(), "Expected Drunk Buddy fixed reward claim to work.")
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(build_state.has_inventory_item(lucky_coin), "Expected fixed reward path to grant Lucky Coin.")
	_require(lucky_coin.source_kind == GearItem.SourceKind.FIXED, "Expected granted Lucky Coin to remain fixed.")
	build_state.reset(true)


func _is_clean_generated_item(item: GearItem) -> bool:
	if item == null:
		return false
	if item.source_kind != GearItem.SourceKind.GENERATED:
		return false
	if not GearGenerator.is_procedural_tier(item.tier):
		return false
	if FIXED_EXCLUDED_IDS.has(item.id):
		return false
	if item.id.begins_with("gear.legendary."):
		return false
	if item.display_name == "Lucky Coin" or item.display_name == "Placeholder Dagger":
		return false
	return item.deterministic_key != ""


func _generated_ids_sample() -> Dictionary:
	var ids := {}
	for seed in range(1, 12):
		for offer in GearGenerator.generate_offers(8, seed):
			ids[offer.id] = true
	return ids


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
