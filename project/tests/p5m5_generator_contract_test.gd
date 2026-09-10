extends SceneTree
## Focused P5M5-T2 check for the procedural gear generator request/result
## contract before the full rarity/stat rolling rules are expanded.

const TEST_SAVE_PATH := "res://.test_p5m5_generator_contract.json"
const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	SaveSystem.save_path = TEST_SAVE_PATH
	SaveSystem.delete_save()

	print("-- P5M5 generator request contract --")
	_check_request_result_metadata()
	_check_seeded_request_is_deterministic()
	_check_invalid_requests_fail_loudly()
	_check_legacy_generate_wrapper_still_works()
	_check_live_callers_stamp_source_metadata(build_state)
	_check_runtime_metadata_save_load_roundtrip(build_state)

	SaveSystem.delete_save()
	SaveSystem.save_path = SaveSystem.SAVE_PATH
	build_state.reset()
	print("P5M5 generator request contract check: OK")
	quit(0)


func _check_request_result_metadata() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5005
	var result := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.MASTER,
		"slot": GearItem.SlotType.HELM,
		"rng": rng,
		"id": "gear.test.p5m5.contract_hood",
		"deterministic_key": "p5m5:test:hood",
		"source_context": "p5m5_contract_test",
		"source_seed": 5005,
		"contract_depth": 2,
		"value_scale": 1.0,
	})
	_require(result["ok"], "Expected valid request to succeed.")
	_require((result["errors"] as PackedStringArray).is_empty(), "Expected no errors for valid request.")
	var item: GearItem = result["item"]
	_require(item != null, "Expected valid request to return item.")
	_require(item.id == "gear.test.p5m5.contract_hood", "Expected generated id from request.")
	_require(item.slot == GearItem.SlotType.HELM, "Expected generated slot from request.")
	_require(item.tier == GearItem.Tier.MASTER, "Expected generated rarity from request.")
	_require(item.item_family == "Hood", "Expected Rogue item family metadata.")
	_require(item.class_family == GearItem.ClassFamily.ROGUE, "Expected Rogue class family.")
	_require(item.source_kind == GearItem.SourceKind.GENERATED, "Expected generated source kind.")
	_require(item.source_context == "p5m5_contract_test", "Expected source context metadata.")
	_require(item.source_seed == 5005, "Expected source seed metadata.")
	_require(item.deterministic_key == "p5m5:test:hood", "Expected deterministic key metadata.")
	_require(item.affixes.size() == 2, "Expected Master procedural affix count.")
	_require(GearGenerator.stat_roll_key(item.deterministic_key, 1, "basic") == "p5m5:test:hood|basic|1", "Expected stable stat-roll key format.")


func _check_seeded_request_is_deterministic() -> void:
	var first := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.CURSED,
		"slot": GearItem.SlotType.ARMOR,
		"seed": 7701,
		"id": "gear.test.p5m5.seeded",
		"deterministic_key": "p5m5:seeded",
		"source_context": "determinism",
		"source_seed": 7701,
	})
	var second := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.CURSED,
		"slot": GearItem.SlotType.ARMOR,
		"seed": 7701,
		"id": "gear.test.p5m5.seeded",
		"deterministic_key": "p5m5:seeded",
		"source_context": "determinism",
		"source_seed": 7701,
	})
	_require(first["ok"] and second["ok"], "Expected seeded requests to succeed.")
	_require(_gear_signature(first["item"]) == _gear_signature(second["item"]), "Expected same seeded request to produce same item.")


func _check_invalid_requests_fail_loudly() -> void:
	_require(_errors_for({"tier": GearItem.Tier.BASIC, "slot": 99, "seed": 1}).has("invalid_slot:99"), "Expected invalid slot error.")
	_require(_errors_for({"tier": 99, "slot": GearItem.SlotType.WEAPON, "seed": 1}).has("invalid_rarity:99"), "Expected invalid rarity error.")
	_require(_errors_for({"tier": GearItem.Tier.CRUDE, "slot": GearItem.SlotType.WEAPON, "seed": 1}).has("crude_is_starter_only"), "Expected Crude procedural rejection.")
	_require(_errors_for({"tier": GearItem.Tier.LEGENDARY, "slot": GearItem.SlotType.WEAPON, "seed": 1}).has("legendary_requires_fixed_catalog"), "Expected Legendary procedural rejection.")
	_require(_errors_for({"tier": GearItem.Tier.BASIC, "slot": GearItem.SlotType.WEAPON, "seed": 1, "source_kind": GearItem.SourceKind.FIXED}).has("procedural_source_kind_required"), "Expected non-generated source rejection.")
	_require(_errors_for({"tier": GearItem.Tier.BASIC, "slot": GearItem.SlotType.WEAPON, "seed": 1, "value_scale": 0.0}).has("invalid_value_scale"), "Expected invalid value scale rejection.")


func _check_legacy_generate_wrapper_still_works() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 6006
	var item := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.CHARM, rng, "gear.test.legacy_wrapper")
	_require(item != null, "Expected legacy wrapper to return item.")
	_require(item.id == "gear.test.legacy_wrapper", "Expected legacy wrapper stable id.")
	_require(item.slot == GearItem.SlotType.CHARM, "Expected legacy wrapper slot.")
	_require(item.source_kind == GearItem.SourceKind.GENERATED, "Expected generated source kind.")
	_require(item.source_context == "legacy_generate", "Expected legacy wrapper source context.")
	_require(item.deterministic_key == "gear.test.legacy_wrapper", "Expected legacy wrapper deterministic key.")


func _check_live_callers_stamp_source_metadata(build_state) -> void:
	build_state.reset()
	build_state.adventure_seed = 9090
	var rng := RunRng.rng_for_context(build_state.adventure_seed, RunRng.CONTEXT_SHOP_OFFER, ["p5m5"])
	var shop_offer: GearItem = build_state._shop_offer_for_tier(
		GearItem.Tier.BASIC,
		GearItem.SlotType.TRINKET,
		rng,
		"gear.test.p5m5.shop"
	)
	_require(shop_offer != null, "Expected shop helper to produce gear.")
	_require(shop_offer.source_context == "shop_offer:encounter:0", "Expected shop source context.")
	_require(shop_offer.source_seed == 9090, "Expected shop source seed.")
	_require(shop_offer.deterministic_key == "gear.test.p5m5.shop", "Expected shop deterministic key.")

	var reward := EncounterReward.new()
	reward.generated_gear_choice_count = 2
	reward.generated_gear_tier = GearItem.Tier.MASTER
	reward.generated_gear_slots = [GearItem.SlotType.WEAPON]
	var choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	_require(choices.size() == 2, "Expected generated reward choices.")
	for choice in choices:
		_require(choice.source_context == "reward_choice:encounter:0", "Expected reward source context.")
		_require(choice.source_seed == 9090, "Expected reward source seed.")
		_require(choice.deterministic_key.begins_with("gear.generated.reward_"), "Expected reward deterministic key.")
		_require(choice.slot == GearItem.SlotType.WEAPON, "Expected reward slot request.")
	var signature_a: String = build_state._generated_reward_stat_signature(choices[0])
	var signature_b: String = build_state._generated_reward_stat_signature(choices[1])
	_require(signature_a.contains(choices[0].affixes[0].stat_id), "Expected canonical stat id in reward signature.")
	_require(signature_b.contains(choices[1].affixes[0].stat_id), "Expected canonical stat id in reward signature.")


func _check_runtime_metadata_save_load_roundtrip(build_state) -> void:
	build_state.reset()
	build_state.adventure_seed = 1111
	var rng := RandomNumberGenerator.new()
	rng.seed = 1111
	var result := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.BASIC,
		"slot": GearItem.SlotType.ARMOR,
		"rng": rng,
		"id": "gear.test.p5m5.save",
		"deterministic_key": "p5m5:save",
		"source_context": "save_roundtrip",
		"source_seed": 1111,
	})
	_require(result["ok"], "Expected save roundtrip item request to succeed.")
	build_state.equip(result["item"])
	_require(SaveSystem.save_run(build_state), "Expected save to succeed.")
	build_state.reset()
	_require(SaveSystem.load_run(build_state), "Expected load to succeed.")
	_require(build_state.equipped_armor != null, "Expected generated armor to restore.")
	_require(build_state.equipped_armor.id == "gear.test.p5m5.save", "Expected restored id.")
	_require(build_state.equipped_armor.source_context == "save_roundtrip", "Expected restored source context.")
	_require(build_state.equipped_armor.source_seed == 1111, "Expected restored source seed.")
	_require(build_state.equipped_armor.deterministic_key == "p5m5:save", "Expected restored deterministic key.")


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
		str(item.slot),
		str(item.tier),
		item.source_context,
		str(item.source_seed),
		item.deterministic_key,
	]
	for affix in item.affixes:
		parts.append("%s:%d:%d:%s:%.4f" % [
			StatCatalog.canonical_id_for_modifier(affix),
			affix.category,
			affix.operation,
			"drawback" if affix.is_drawback else "positive",
			affix.value,
		])
	return "|".join(parts)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
