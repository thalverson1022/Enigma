extends SceneTree
## Focused P5M5-T6 check for generated stat value ranges and scaling.

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")


func _initialize() -> void:
	print("-- P5M5 stat value scaling --")
	_check_catalog_ranges_cover_enabled_numeric_pools()
	_check_generated_values_fit_scaled_ranges()
	_check_flat_stack_and_percent_rounding()
	_check_specials_stay_binary()
	_check_same_seed_values_are_deterministic()
	_check_value_scale_changes_output()
	_check_contract_depth_value_scale_changes_output()
	print("P5M5 stat value scaling check: OK")
	quit(0)


func _check_catalog_ranges_cover_enabled_numeric_pools() -> void:
	for slot in GearItem.universal_slot_order():
		for category in [StatCatalog.CATEGORY_BASIC, StatCatalog.CATEGORY_RARE]:
			for entry in StatCatalog.pool_for_slot(slot, category):
				if int(entry.get("weight", 0)) <= 0:
					continue
				var stat_id := String(entry["stat_id"])
				_require(StatCatalog.value_range_for_slot_category(slot, category, stat_id)["ok"], "Expected value range for enabled %s %s." % [
					GearGenerator.universal_slot_label(slot),
					stat_id,
				])


func _check_generated_values_fit_scaled_ranges() -> void:
	var seed := 61006
	for slot in GearItem.universal_slot_order():
		for tier in GearGenerator.ACTIVE_GENERATED_TIERS:
			var rng := RandomNumberGenerator.new()
			rng.seed = seed
			seed += 29
			var result := GearGenerator.generate_from_request({
				"tier": tier,
				"slot": slot,
				"rng": rng,
				"id": "gear.test.p5m5.t6.%d.%d" % [tier, slot],
				"deterministic_key": "p5m5:t6:%d:%d" % [tier, slot],
				"source_context": "p5m5_t6",
				"source_seed": seed,
			})
			_require(result["ok"], "Expected generated item to succeed: %s." % str(result["errors"]))
			for modifier in (result["item"] as GearItem).affixes:
				_require(_modifier_value_in_scaled_range(slot, tier, modifier, 1.0), "Expected %s value %.4f in scaled range." % [
					modifier.stat_id,
					modifier.value,
				])


func _check_flat_stack_and_percent_rounding() -> void:
	var flat_rng := RandomNumberGenerator.new()
	flat_rng.seed = 71006
	var flat := GearGenerator._roll_value_for_stat_id(StatCatalog.BASE_DAMAGE, GearItem.SlotType.WEAPON, false, GearItem.Tier.BASIC, flat_rng)
	_require(flat["ok"], "Expected flat value roll to succeed.")
	_require(is_equal_approx(float(flat["value"]), round(float(flat["value"]))), "Expected flat value to round to an integer.")

	var stack_rng := RandomNumberGenerator.new()
	stack_rng.seed = 71007
	var stack := GearGenerator._roll_value_for_stat_id(StatCatalog.INCREASED_ALL_STACKS, GearItem.SlotType.ARMOR, false, GearItem.Tier.BASIC, stack_rng)
	_require(stack["ok"], "Expected stack value roll to succeed.")
	_require(float(stack["value"]) >= 1.0, "Expected positive stack roll never below +1.")
	_require(is_equal_approx(float(stack["value"]), round(float(stack["value"]))), "Expected stack value to round to an integer.")

	var percent_rng := RandomNumberGenerator.new()
	percent_rng.seed = 71008
	var percent := GearGenerator._roll_value_for_stat_id(StatCatalog.PERCENT_PHYSICAL_DAMAGE, GearItem.SlotType.WEAPON, false, GearItem.Tier.MASTER, percent_rng)
	_require(percent["ok"], "Expected percent value roll to succeed.")
	_require(absf(float(percent["value"]) * 100.0 - round(float(percent["value"]) * 100.0)) < 0.0001, "Expected percent value to round to whole percent internally.")

	var drawback_rng := RandomNumberGenerator.new()
	drawback_rng.seed = 71009
	var drawback := GearGenerator._roll_value_for_stat_id(StatCatalog.INCREASED_ALL_STACKS, GearItem.SlotType.HELM, true, GearItem.Tier.CURSED, drawback_rng)
	_require(drawback["ok"], "Expected drawback value roll to succeed.")
	_require(float(drawback["value"]) < 0.0, "Expected Cursed drawback value to be negative.")
	_require(is_equal_approx(float(drawback["value"]), round(float(drawback["value"]))), "Expected drawback stack value to round to an integer.")


func _check_specials_stay_binary() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 81006
	var special := GearGenerator._roll_value_for_stat_id(StatCatalog.ALL_STATS_INCREASED, GearItem.SlotType.WEAPON, false, GearItem.Tier.UNIQUE, rng, 5.0, 99)
	_require(special["ok"], "Expected Special value roll to succeed.")
	_require(is_equal_approx(float(special["value"]), 1.0), "Expected Special value to stay binary 1.0.")


func _check_same_seed_values_are_deterministic() -> void:
	var first := _generated_signature(91006)
	var second := _generated_signature(91006)
	_require(first == second, "Expected same seed to produce identical stat IDs and values.")


func _check_value_scale_changes_output() -> void:
	var normal_rng := RandomNumberGenerator.new()
	normal_rng.seed = 101006
	var scaled_rng := RandomNumberGenerator.new()
	scaled_rng.seed = 101006
	var normal := GearGenerator._roll_value_for_stat_id(StatCatalog.PERCENT_PHYSICAL_DAMAGE, GearItem.SlotType.WEAPON, false, GearItem.Tier.BASIC, normal_rng, 1.0)
	var scaled := GearGenerator._roll_value_for_stat_id(StatCatalog.PERCENT_PHYSICAL_DAMAGE, GearItem.SlotType.WEAPON, false, GearItem.Tier.BASIC, scaled_rng, 2.0)
	_require(normal["ok"] and scaled["ok"], "Expected value-scale rolls to succeed.")
	_require(float(scaled["value"]) > float(normal["value"]), "Expected larger value_scale to increase positive output.")
	_require(absf(float(scaled["value"]) - float(normal["value"]) * 2.0) <= 0.02, "Expected value_scale to approximately double rounded percent output.")


func _check_contract_depth_value_scale_changes_output() -> void:
	_require(is_equal_approx(GearGenerator._contract_depth_value_scale(-5), 1.0), "Expected contract depth value scale to clamp low.")
	_require(is_equal_approx(GearGenerator._contract_depth_value_scale(1), 1.0), "Expected depth 1 value scale to be neutral.")
	_require(is_equal_approx(GearGenerator._contract_depth_value_scale(12), 1.35), "Expected depth 12 value scale to match P5M6 handoff.")
	_require(is_equal_approx(GearGenerator._contract_depth_value_scale(99), 1.35), "Expected contract depth value scale to clamp high.")
	_require(GearGenerator._contract_depth_value_scale(6) > GearGenerator._contract_depth_value_scale(1), "Expected middle depth value scale to exceed depth 1.")
	_require(GearGenerator._contract_depth_value_scale(6) < GearGenerator._contract_depth_value_scale(12), "Expected middle depth value scale below depth 12.")

	var depth_one_rng := RandomNumberGenerator.new()
	depth_one_rng.seed = 111006
	var depth_twelve_rng := RandomNumberGenerator.new()
	depth_twelve_rng.seed = 111006
	var depth_one := GearGenerator._roll_value_for_stat_id(StatCatalog.PERCENT_PHYSICAL_DAMAGE, GearItem.SlotType.WEAPON, false, GearItem.Tier.BASIC, depth_one_rng, 1.0, 1)
	var depth_twelve := GearGenerator._roll_value_for_stat_id(StatCatalog.PERCENT_PHYSICAL_DAMAGE, GearItem.SlotType.WEAPON, false, GearItem.Tier.BASIC, depth_twelve_rng, 1.0, 12)
	_require(depth_one["ok"] and depth_twelve["ok"], "Expected depth-scaled value rolls to succeed.")
	_require(float(depth_twelve["value"]) > float(depth_one["value"]), "Expected higher contract depth to increase positive stat value.")


func _modifier_value_in_scaled_range(slot: GearItem.SlotType, tier: GearItem.Tier, modifier: StatModifier, value_scale: float) -> bool:
	var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
	if StatCatalog.is_binary(stat_id):
		return is_equal_approx(modifier.value, 1.0)
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


func _generated_signature(seed: int) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var result := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.UNIQUE,
		"slot": GearItem.SlotType.CHARM,
		"rng": rng,
		"id": "gear.test.p5m5.t6.deterministic",
		"deterministic_key": "p5m5:t6:deterministic",
		"source_context": "p5m5_t6",
		"source_seed": seed,
	})
	_require(result["ok"], "Expected deterministic generation request to succeed.")
	var parts: PackedStringArray = []
	for modifier in (result["item"] as GearItem).affixes:
		parts.append("%s:%d:%s:%.4f" % [
			modifier.stat_id,
			modifier.category,
			"drawback" if modifier.is_drawback else "positive",
			modifier.value,
		])
	return "|".join(parts)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
