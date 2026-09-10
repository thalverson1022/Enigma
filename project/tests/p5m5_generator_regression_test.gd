extends SceneTree
## Consolidated P5M5-T12 regression coverage for the procedural generator
## surface now that the focused rarity, pool, value, drawback, Chaos, Unique,
## Legendary, fixed-gear, caller, and save/load rules have landed.

const TEST_SAVE_PATH := "res://.test_p5m5_generator_regression.json"
const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")

const FIXED_EXCLUDED_IDS := {
	"gear.lucky_coin": true,
	"gear.placeholder_dagger": true,
}


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	var original_save_path := SaveSystem.save_path
	build_state.reset(true)
	SaveSystem.save_path = TEST_SAVE_PATH
	SaveSystem.delete_save()

	print("-- P5M5 generator regression --")
	_check_full_generation_matrix()
	_check_deterministic_public_request()
	_check_shop_and_reward_callers(build_state)
	_check_save_load_roundtrip_for_complex_generated_items(build_state)
	_check_boundaries_and_fixed_exclusions()

	SaveSystem.delete_save()
	SaveSystem.save_path = original_save_path
	build_state.reset(true)
	print("P5M5 generator regression check: OK")
	quit(0)


func _check_full_generation_matrix() -> void:
	var seed := 120012
	for tier in GearGenerator.ACTIVE_GENERATED_TIERS:
		for slot in GearItem.universal_slot_order():
			var item_id := "gear.test.p5m5.t12.%d.%d" % [tier, slot]
			var source_seed := seed
			var result := GearGenerator.generate_from_request({
				"tier": tier,
				"slot": slot,
				"seed": source_seed,
				"id": item_id,
				"deterministic_key": "p5m5:t12:%d:%d" % [tier, slot],
				"source_context": "p5m5_t12_matrix",
				"source_seed": source_seed,
				"value_scale": 1.0,
			})
			seed += 37
			_require(result["ok"], "Expected generated item to succeed: %s." % str(result["errors"]))
			var item: GearItem = result["item"]
			_require(_is_clean_generated_item(item), "Expected clean generated item for %s." % item_id)
			_require(item.id == item_id, "Expected generated id to match request.")
			_require(item.slot == slot, "Expected generated slot to match request.")
			_require(item.tier == tier, "Expected generated tier to match request.")
			_require(item.item_family == GearGenerator.rogue_item_family_for_slot(slot), "Expected Rogue item-family metadata.")
			_require(item.class_family == GearItem.ClassFamily.ROGUE, "Expected Rogue class-family metadata.")
			_require(item.source_context == "p5m5_t12_matrix", "Expected source context metadata.")
			_require(item.source_seed == source_seed, "Expected source seed metadata.")
			_require(item.deterministic_key == "p5m5:t12:%d:%d" % [tier, slot], "Expected deterministic key metadata.")
			_require(item.display_name != "", "Expected generated display name.")
			_require(_has_expected_rarity_shape(item), "Expected rarity/category shape for %s." % item.display_name)
			if tier != GearItem.Tier.CHAOS:
				_require(_has_unique_stat_ids(item), "Expected no duplicate stat IDs on %s." % item.display_name)
			_require(_has_valid_affixes_for_slot(item), "Expected slot/category-valid affixes on %s." % item.display_name)
			_require(_has_scaled_values(item, 1.0), "Expected scaled values in catalog ranges on %s." % item.display_name)


func _check_deterministic_public_request() -> void:
	var request := {
		"tier": GearItem.Tier.CHAOS,
		"slot": GearItem.SlotType.CHARM,
		"seed": 220012,
		"id": "gear.test.p5m5.t12.deterministic",
		"deterministic_key": "p5m5:t12:deterministic",
		"source_context": "p5m5_t12_determinism",
		"source_seed": 220012,
	}
	var first := GearGenerator.generate_from_request(request)
	var second := GearGenerator.generate_from_request(request)
	_require(first["ok"] and second["ok"], "Expected repeated public requests to succeed.")
	_require(_gear_signature(first["item"]) == _gear_signature(second["item"]), "Expected repeated public requests to produce identical generated gear.")


func _check_shop_and_reward_callers(build_state) -> void:
	build_state.reset(true)
	build_state.adventure_seed = 330012
	var shop_rng := RunRng.rng_for_context(build_state.adventure_seed, RunRng.CONTEXT_SHOP_OFFER, ["p5m5_t12"])
	var shop_offer: GearItem = build_state._shop_offer_for_tier(
		GearItem.Tier.MASTER,
		GearItem.SlotType.TRINKET,
		shop_rng,
		"gear.test.p5m5.t12.shop"
	)
	_require(_is_clean_generated_item(shop_offer), "Expected shop helper to return clean generated gear.")
	_require(shop_offer.source_context == "shop_offer:encounter:0", "Expected shop source context.")
	_require(shop_offer.source_seed == build_state.adventure_seed, "Expected shop source seed.")
	_require(shop_offer.deterministic_key == "gear.test.p5m5.t12.shop", "Expected shop deterministic key.")
	_require(_has_valid_affixes_for_slot(shop_offer), "Expected shop affixes to be slot-valid.")

	var reward := EncounterReward.new()
	reward.generated_gear_choice_count = 3
	reward.generated_gear_tier = GearItem.Tier.UNIQUE
	var slots: Array[int] = [
		GearItem.SlotType.WEAPON,
		GearItem.SlotType.HELM,
		GearItem.SlotType.ARMOR,
	]
	reward.generated_gear_slots = slots
	var choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	_require(choices.size() == 3, "Expected generated reward choices.")
	var seen_reward_signatures := {}
	for choice in choices:
		_require(_is_clean_generated_item(choice), "Expected reward helper to return clean generated gear.")
		_require(choice.source_context == "reward_choice:encounter:0", "Expected reward source context.")
		_require(choice.source_seed == build_state.adventure_seed, "Expected reward source seed.")
		_require(choice.deterministic_key.begins_with("gear.generated.reward_"), "Expected reward deterministic key.")
		_require(slots.has(choice.slot), "Expected reward slot to come from requested slot pool.")
		_require(_has_expected_rarity_shape(choice), "Expected reward rarity/category shape.")
		_require(_has_valid_affixes_for_slot(choice), "Expected reward affixes to be slot-valid.")
		var signature: String = build_state._generated_reward_stat_signature(choice)
		_require(not seen_reward_signatures.has(signature), "Expected reward choices to avoid duplicate stat signatures.")
		seen_reward_signatures[signature] = true


func _check_save_load_roundtrip_for_complex_generated_items(build_state) -> void:
	build_state.reset(true)
	build_state.adventure_seed = 440012
	var cursed := _generated_item(GearItem.Tier.CURSED, GearItem.SlotType.HELM, 440101, "gear.test.p5m5.t12.save.cursed")
	var unique := _generated_item(GearItem.Tier.UNIQUE, GearItem.SlotType.ARMOR, 440102, "gear.test.p5m5.t12.save.unique")
	_require(cursed != null and unique != null, "Expected complex generated save fixtures.")
	var cursed_signature := _gear_signature(cursed)
	var unique_signature := _gear_signature(unique)
	build_state.equip(cursed)
	build_state.equip(unique)
	_require(SaveSystem.save_run(build_state), "Expected save with generated gear to succeed.")

	build_state.reset(true)
	_require(SaveSystem.load_run(build_state), "Expected load with generated gear to succeed.")
	_require(build_state.equipped_helm != null, "Expected generated Cursed helm to restore.")
	_require(build_state.equipped_armor != null, "Expected generated Unique armor to restore.")
	_require(_gear_signature(build_state.equipped_helm) == cursed_signature, "Expected Cursed generated gear metadata and affixes to roundtrip.")
	_require(_gear_signature(build_state.equipped_armor) == unique_signature, "Expected Unique generated gear metadata and affixes to roundtrip.")
	_require(_count_category(build_state.equipped_helm, StatModifier.StatCategory.DRAWBACK) == 1, "Expected restored Cursed item to keep drawback.")
	_require(_count_category(build_state.equipped_armor, StatModifier.StatCategory.SPECIAL) == 1, "Expected restored Unique item to keep Special.")


func _check_boundaries_and_fixed_exclusions() -> void:
	_require(_errors_for({"tier": GearItem.Tier.CRUDE, "slot": GearItem.SlotType.WEAPON, "seed": 1}).has("crude_is_starter_only"), "Expected Crude procedural rejection.")
	_require(_errors_for({"tier": GearItem.Tier.LEGENDARY, "slot": GearItem.SlotType.WEAPON, "seed": 1}).has("legendary_requires_fixed_catalog"), "Expected Legendary procedural rejection.")
	_require(_errors_for({
		"tier": GearItem.Tier.BASIC,
		"slot": GearItem.SlotType.WEAPON,
		"seed": 1,
		"source_kind": GearItem.SourceKind.FIXED,
	}).has("procedural_source_kind_required"), "Expected fixed-source procedural rejection.")

	var rng := RandomNumberGenerator.new()
	rng.seed = 550012
	var too_many_weapon_specials: Array[Dictionary] = [
		{"category": StatCatalog.CATEGORY_SPECIAL, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_SPECIAL, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_SPECIAL, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_SPECIAL, "is_drawback": false},
	]
	var impossible := GearGenerator._affixes_for_rolls(GearItem.SlotType.WEAPON, GearItem.Tier.UNIQUE, too_many_weapon_specials, rng)
	_require((impossible["affixes"] as Array).is_empty(), "Expected impossible direct plan to return no partial affixes.")
	_require((impossible["errors"] as PackedStringArray).has("insufficient_special_pool:Weapon"), "Expected impossible direct plan to fail loudly.")

	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(lucky_coin != null and lucky_coin.source_kind == GearItem.SourceKind.FIXED, "Expected Lucky Coin to remain fixed.")
	var placeholder: GearItem = load("res://data/gear/placeholder_dagger.tres")
	_require(placeholder != null and placeholder.source_kind == GearItem.SourceKind.COMPATIBILITY, "Expected placeholder dagger to remain compatibility gear.")
	for legendary in LegendaryCatalog.all_items():
		_require(legendary != null, "Expected Legendary catalog item.")
		_require(legendary.source_kind == GearItem.SourceKind.LEGENDARY, "Expected catalog Legendary source kind.")
		_require(legendary.id.begins_with("gear.legendary."), "Expected catalog Legendary id namespace.")

	for seed in range(1, 16):
		for offer in GearGenerator.generate_offers(8, seed):
			_require(_is_clean_generated_item(offer), "Expected standalone generated offers to exclude fixed/catalog gear.")


func _generated_item(tier: GearItem.Tier, slot: GearItem.SlotType, seed: int, item_id: String) -> GearItem:
	var result := GearGenerator.generate_from_request({
		"tier": tier,
		"slot": slot,
		"seed": seed,
		"id": item_id,
		"deterministic_key": item_id,
		"source_context": "p5m5_t12_save",
		"source_seed": seed,
	})
	_require(result["ok"], "Expected generated save fixture to succeed: %s." % str(result["errors"]))
	return result["item"]


func _has_expected_rarity_shape(item: GearItem) -> bool:
	match item.tier:
		GearItem.Tier.BASIC:
			return item.affixes.size() == 1 and _count_category(item, StatModifier.StatCategory.BASIC) == 1
		GearItem.Tier.MASTER:
			return item.affixes.size() == 2 and _count_category(item, StatModifier.StatCategory.BASIC) == 2
		GearItem.Tier.EPIC:
			return item.affixes.size() == 3 and _count_category(item, StatModifier.StatCategory.BASIC) == 2 and _count_category(item, StatModifier.StatCategory.RARE) == 1
		GearItem.Tier.CURSED:
			return item.affixes.size() == 4 and _count_category(item, StatModifier.StatCategory.BASIC) == 2 and _count_category(item, StatModifier.StatCategory.RARE) == 1 and _count_category(item, StatModifier.StatCategory.DRAWBACK) == 1
		GearItem.Tier.CHAOS:
			return item.affixes.size() == GearGenerator.CHAOS_ROLL_COUNT and _count_category(item, StatModifier.StatCategory.SPECIAL) == 0 and _count_category(item, StatModifier.StatCategory.COMPATIBILITY) == 0
		GearItem.Tier.UNIQUE:
			return item.affixes.size() == 5 and _count_category(item, StatModifier.StatCategory.BASIC) == 3 and _count_category(item, StatModifier.StatCategory.RARE) == 1 and _count_category(item, StatModifier.StatCategory.SPECIAL) == 1
	return false


func _has_unique_stat_ids(item: GearItem) -> bool:
	var seen := {}
	for modifier in item.affixes:
		var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
		if stat_id == "" or seen.has(stat_id):
			return false
		seen[stat_id] = true
	return true


func _has_valid_affixes_for_slot(item: GearItem) -> bool:
	for modifier in item.affixes:
		var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
		if stat_id == "":
			return false
		if modifier.is_drawback or modifier.category == StatModifier.StatCategory.DRAWBACK:
			if not StatCatalog.drawback_stat_ids_for_slot(item.slot).has(stat_id):
				return false
			if not modifier.is_drawback:
				return false
			continue
		if modifier.category == StatModifier.StatCategory.BASIC:
			if not StatCatalog.is_stat_valid_for_slot(item.slot, StatCatalog.CATEGORY_BASIC, stat_id):
				return false
		elif modifier.category == StatModifier.StatCategory.RARE:
			if not StatCatalog.is_stat_valid_for_slot(item.slot, StatCatalog.CATEGORY_RARE, stat_id):
				return false
		elif modifier.category == StatModifier.StatCategory.SPECIAL:
			if not StatCatalog.is_stat_valid_for_slot(item.slot, StatCatalog.CATEGORY_SPECIAL, stat_id):
				return false
			if not is_equal_approx(modifier.value, GearGenerator.PLACEHOLDER_BINARY_VALUE):
				return false
		else:
			return false
	return true


func _has_scaled_values(item: GearItem, value_scale: float) -> bool:
	for modifier in item.affixes:
		if not _modifier_value_in_scaled_range(item.slot, item.tier, modifier, value_scale):
			return false
	return true


func _modifier_value_in_scaled_range(slot: GearItem.SlotType, tier: GearItem.Tier, modifier: StatModifier, value_scale: float) -> bool:
	var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
	if StatCatalog.is_binary(stat_id):
		return is_equal_approx(modifier.value, GearGenerator.PLACEHOLDER_BINARY_VALUE)
	var range := StatCatalog.value_range_for_slot_category(slot, _catalog_category_for_modifier(modifier), stat_id)
	if not bool(range.get("ok", false)):
		return false
	var multiplier := GearGenerator._rarity_value_multiplier(tier, modifier.is_drawback) * value_scale
	var low := float(range["min"]) * multiplier
	var high := float(range["max"]) * multiplier
	var min_value = minf(low, high)
	var max_value = maxf(low, high)
	var tolerance := 1.0 if StatCatalog.value_kind_for(stat_id) in [StatCatalog.VALUE_FLAT, StatCatalog.VALUE_STACKS] else 0.01
	return modifier.value >= min_value - tolerance and modifier.value <= max_value + tolerance


func _catalog_category_for_modifier(modifier: StatModifier) -> String:
	if modifier.category == StatModifier.StatCategory.RARE:
		return StatCatalog.CATEGORY_RARE
	if modifier.category == StatModifier.StatCategory.SPECIAL:
		return StatCatalog.CATEGORY_SPECIAL
	return StatCatalog.CATEGORY_BASIC


func _is_clean_generated_item(item: GearItem) -> bool:
	if item == null:
		return false
	if item.source_kind != GearItem.SourceKind.GENERATED:
		return false
	if not GearGenerator.is_procedural_tier(item.tier):
		return false
	if item.id == "" or item.deterministic_key == "":
		return false
	if item.id.begins_with("gear.legendary."):
		return false
	if FIXED_EXCLUDED_IDS.has(item.id):
		return false
	return item.display_name != "Lucky Coin" and item.display_name != "Placeholder Dagger"


func _errors_for(request: Dictionary) -> PackedStringArray:
	var result := GearGenerator.generate_from_request(request)
	_require(not result["ok"], "Expected invalid request to fail.")
	_require(result["item"] == null, "Expected invalid request not to return item.")
	return result["errors"]


func _gear_signature(item: GearItem) -> String:
	if item == null:
		return "null"
	var parts: PackedStringArray = [
		item.id,
		item.display_name,
		str(item.slot),
		str(item.tier),
		item.item_family,
		str(item.class_family),
		str(item.source_kind),
		item.source_context,
		str(item.source_seed),
		item.deterministic_key,
	]
	for affix in item.affixes:
		parts.append(_affix_signature(affix))
	return "|".join(parts)


func _affix_signature(affix: StatModifier) -> String:
	if affix == null:
		return "null"
	return "%s:%d:%d:%s:%.4f:%s" % [
		StatCatalog.canonical_id_for_modifier(affix),
		affix.category,
		affix.operation,
		"drawback" if affix.is_drawback else "positive",
		affix.value,
		affix.display_label,
	]


func _count_category(item: GearItem, category: StatModifier.StatCategory) -> int:
	var count := 0
	for modifier in item.affixes:
		if modifier.category == category:
			count += 1
	return count


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
