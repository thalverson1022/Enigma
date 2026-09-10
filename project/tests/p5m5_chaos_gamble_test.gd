extends SceneTree
## Focused P5M5-T8 check for Chaos outcome-first gamble rules.

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")


func _initialize() -> void:
	print("-- P5M5 Chaos gamble rules --")
	_check_chaos_plan_metadata()
	_check_generated_chaos_items_for_all_slots()
	_check_chaos_can_roll_extreme_and_mixed_outcomes()
	_check_chaos_is_deterministic()
	_check_impossible_chaos_rolls_fail_cleanly()
	print("P5M5 Chaos gamble rules check: OK")
	quit(0)


func _check_chaos_plan_metadata() -> void:
	var plan := GearGenerator.rarity_roll_plan(GearItem.Tier.CHAOS)
	_require(plan["ok"], "Expected Chaos rarity metadata to be supported.")
	_require(bool(plan.get("variable", false)), "Expected Chaos to be marked variable.")
	_require(int(plan.get("roll_count", 0)) == GearGenerator.CHAOS_ROLL_COUNT, "Expected Chaos to use configured outcome count.")
	_require((plan["rolls"] as Array).is_empty(), "Expected Chaos static plan to avoid fixed categories.")
	var outcomes: Array = plan["outcomes"]
	_require(_count_outcome(outcomes, GearGenerator.CHAOS_OUTCOME_BASIC) == 1, "Expected Chaos Basic positive outcome.")
	_require(_count_outcome(outcomes, GearGenerator.CHAOS_OUTCOME_RARE) == 1, "Expected Chaos Rare positive outcome.")
	_require(_count_outcome(outcomes, GearGenerator.CHAOS_OUTCOME_DRAWBACK) == 1, "Expected Chaos Basic drawback outcome.")
	_require(_weight_for_outcome(outcomes, GearGenerator.CHAOS_OUTCOME_RARE) == 4, "Expected Chaos Rare outcome to be weighted 20% below Basic.")
	_require(_weight_for_outcome(outcomes, GearGenerator.CHAOS_OUTCOME_BASIC) == 5, "Expected Chaos Basic positive outcome weight.")


func _check_generated_chaos_items_for_all_slots() -> void:
	var seed := 88008
	for slot in GearItem.universal_slot_order():
		for sample in 80:
			var rng := RandomNumberGenerator.new()
			rng.seed = seed
			seed += 31
			var result := GearGenerator.generate_from_request({
				"tier": GearItem.Tier.CHAOS,
				"slot": slot,
				"rng": rng,
				"id": "gear.test.p5m5.t8.%d.%d" % [slot, sample],
				"deterministic_key": "p5m5:t8:%d:%d" % [slot, sample],
				"source_context": "p5m5_t8",
				"source_seed": seed,
			})
			_require(result["ok"], "Expected Chaos generation to succeed: %s." % str(result["errors"]))
			var item: GearItem = result["item"]
			_require(item.affixes.size() == GearGenerator.CHAOS_ROLL_COUNT, "Expected Chaos item to use configured affix count.")
			_require(_count_category(item, StatModifier.StatCategory.SPECIAL) == 0, "Expected Chaos to exclude Specials.")
			_require(_all_categories_allowed(item), "Expected Chaos affixes to be Basic/Rare positives or Basic drawbacks.")
			_require(_all_stats_are_valid_for_slot(item), "Expected every Chaos stat to be valid for its slot.")
			_require(_values_fit_chaos_ranges(item), "Expected Chaos values to fit massive positive/drawback ranges.")
	_check_chaos_can_duplicate_stat_ids()


func _check_chaos_can_roll_extreme_and_mixed_outcomes() -> void:
	var all_positive := _generate_for_drawback_count(0)
	var all_drawback := _generate_for_drawback_count(GearGenerator.CHAOS_ROLL_COUNT)
	var mixed := _generate_for_mixed_outcome()
	_require(all_positive != null, "Expected deterministic Chaos samples to include all-positive output.")
	_require(all_drawback != null, "Expected deterministic Chaos samples to include all-drawback output.")
	_require(mixed != null, "Expected deterministic Chaos samples to include mixed output.")
	_require(_count_category(all_positive, StatModifier.StatCategory.DRAWBACK) == 0, "Expected all-positive Chaos sample.")
	_require(_count_category(all_drawback, StatModifier.StatCategory.DRAWBACK) == GearGenerator.CHAOS_ROLL_COUNT, "Expected all-drawback Chaos sample.")
	_require(_count_category(mixed, StatModifier.StatCategory.DRAWBACK) > 0, "Expected mixed Chaos sample to include drawbacks.")
	_require(_positive_count(mixed) > 0, "Expected mixed Chaos sample to include positives.")


func _check_chaos_is_deterministic() -> void:
	var first := _generated_signature(99008)
	var second := _generated_signature(99008)
	_require(first == second, "Expected same Chaos seed to produce identical stat IDs, categories, and values.")


func _check_chaos_can_duplicate_stat_ids() -> void:
	for seed in range(1, 5000):
		var item := _generate_chaos_item(seed)
		if item != null and not _has_unique_stat_ids(item):
			return
	_require(false, "Expected at least one deterministic Chaos sample to duplicate a stat ID.")


func _check_impossible_chaos_rolls_fail_cleanly() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 71008
	var too_many_rare: Array[Dictionary] = [
		GearGenerator._roll_spec(StatCatalog.CATEGORY_RARE),
		GearGenerator._roll_spec(StatCatalog.CATEGORY_RARE),
		GearGenerator._roll_spec(StatCatalog.CATEGORY_RARE),
		GearGenerator._roll_spec(StatCatalog.CATEGORY_RARE),
	]
	var rare_result := GearGenerator._affixes_for_rolls(GearItem.SlotType.WEAPON, GearItem.Tier.CHAOS, too_many_rare, rng)
	_require((rare_result["errors"] as PackedStringArray).is_empty(), "Expected repeat Chaos Rare plan to allow duplicate stats.")
	_require((rare_result["affixes"] as Array).size() == too_many_rare.size(), "Expected repeat Chaos Rare plan to produce all affixes.")

	var invalid_forced := GearGenerator._roll_spec(StatCatalog.CATEGORY_RARE)
	invalid_forced["forced_stat_id"] = StatCatalog.BASE_DAMAGE
	var forced_result := GearGenerator._affixes_for_rolls(GearItem.SlotType.WEAPON, GearItem.Tier.CHAOS, [invalid_forced], rng)
	_require(not (forced_result["errors"] as PackedStringArray).is_empty(), "Expected invalid forced Chaos stat to return errors.")
	_require((forced_result["affixes"] as Array).is_empty(), "Expected invalid forced Chaos stat to return no affixes.")


func _generate_for_drawback_count(target_count: int) -> GearItem:
	for seed in range(1, 20000):
		var item := _generate_chaos_item(seed)
		if item != null and _count_category(item, StatModifier.StatCategory.DRAWBACK) == target_count:
			return item
	return null


func _generate_for_mixed_outcome() -> GearItem:
	for seed in range(1, 20000):
		var item := _generate_chaos_item(seed)
		if item != null and _count_category(item, StatModifier.StatCategory.DRAWBACK) > 0 and _positive_count(item) > 0:
			return item
	return null


func _generate_chaos_item(seed: int) -> GearItem:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var result := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.CHAOS,
		"slot": GearItem.SlotType.CHARM,
		"rng": rng,
		"id": "gear.test.p5m5.t8.pattern.%d" % seed,
		"deterministic_key": "p5m5:t8:pattern:%d" % seed,
		"source_context": "p5m5_t8_pattern",
		"source_seed": seed,
	})
	_require(result["ok"], "Expected Chaos pattern search item to generate: %s." % str(result["errors"]))
	return result["item"]


func _generated_signature(seed: int) -> String:
	var item := _generate_chaos_item(seed)
	var parts: PackedStringArray = []
	for modifier in item.affixes:
		parts.append("%s:%d:%s:%.4f" % [
			modifier.stat_id,
			modifier.category,
			"drawback" if modifier.is_drawback else "positive",
			modifier.value,
		])
	return "|".join(parts)


func _count_outcome(outcomes: Array, outcome_id: String) -> int:
	var count := 0
	for outcome in outcomes:
		if String(outcome.get("outcome", "")) == outcome_id:
			count += 1
	return count


func _weight_for_outcome(outcomes: Array, outcome_id: String) -> int:
	for outcome in outcomes:
		if String(outcome.get("outcome", "")) == outcome_id:
			return int(outcome.get("weight", 0))
	return 0


func _count_category(item: GearItem, category: StatModifier.StatCategory) -> int:
	var count := 0
	for modifier in item.affixes:
		if modifier.category == category:
			count += 1
	return count


func _positive_count(item: GearItem) -> int:
	var count := 0
	for modifier in item.affixes:
		if modifier.category == StatModifier.StatCategory.BASIC or modifier.category == StatModifier.StatCategory.RARE:
			count += 1
	return count


func _all_categories_allowed(item: GearItem) -> bool:
	for modifier in item.affixes:
		if modifier.category == StatModifier.StatCategory.BASIC:
			continue
		if modifier.category == StatModifier.StatCategory.RARE:
			continue
		if modifier.category == StatModifier.StatCategory.DRAWBACK:
			continue
		return false
	return true


func _all_stats_are_valid_for_slot(item: GearItem) -> bool:
	for modifier in item.affixes:
		var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
		if stat_id == "":
			return false
		if modifier.category == StatModifier.StatCategory.DRAWBACK:
			if not StatCatalog.drawback_stat_ids_for_slot(item.slot).has(stat_id):
				return false
		elif modifier.category == StatModifier.StatCategory.RARE:
			if not StatCatalog.is_stat_enabled_for_slot(item.slot, StatCatalog.CATEGORY_RARE, stat_id):
				return false
		elif modifier.category == StatModifier.StatCategory.BASIC:
			if not StatCatalog.is_stat_enabled_for_slot(item.slot, StatCatalog.CATEGORY_BASIC, stat_id):
				return false
		else:
			return false
	return true


func _has_unique_stat_ids(item: GearItem) -> bool:
	var used := {}
	for modifier in item.affixes:
		var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
		if used.has(stat_id):
			return false
		used[stat_id] = true
	return true


func _values_fit_chaos_ranges(item: GearItem) -> bool:
	for modifier in item.affixes:
		var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
		var range := StatCatalog.value_range_for_slot_category(item.slot, _catalog_category_for_modifier(modifier), stat_id)
		if not bool(range.get("ok", false)):
			return false
		var multiplier := GearGenerator._rarity_value_multiplier(GearItem.Tier.CHAOS, modifier.is_drawback)
		var low := float(range["min"]) * multiplier
		var high := float(range["max"]) * multiplier
		var min_value = minf(low, high)
		var max_value = maxf(low, high)
		var tolerance := 1.0 if StatCatalog.value_kind_for(stat_id) in [StatCatalog.VALUE_FLAT, StatCatalog.VALUE_STACKS] else 0.01
		if modifier.value < min_value - tolerance or modifier.value > max_value + tolerance:
			return false
	return true


func _catalog_category_for_modifier(modifier: StatModifier) -> String:
	if modifier.category == StatModifier.StatCategory.RARE:
		return StatCatalog.CATEGORY_RARE
	if modifier.category == StatModifier.StatCategory.SPECIAL:
		return StatCatalog.CATEGORY_SPECIAL
	return StatCatalog.CATEGORY_BASIC


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
