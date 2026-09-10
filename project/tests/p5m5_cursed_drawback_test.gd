extends SceneTree
## Focused P5M5-T7 check for Cursed drawback rules.

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")


func _initialize() -> void:
	print("-- P5M5 Cursed drawbacks --")
	_check_cursed_roll_plan_shape()
	_check_cursed_items_for_every_slot()
	_check_cursed_generation_is_deterministic()
	_check_exhausted_drawback_pool_fails_without_partial_affixes()
	print("P5M5 Cursed drawback check: OK")
	quit(0)


func _check_cursed_roll_plan_shape() -> void:
	var rolls := GearGenerator.cursed_roll_plan()
	_require(rolls.size() == 4, "Expected Cursed roll plan to contain four rolls.")
	_require(_count_rolls(rolls, StatCatalog.CATEGORY_BASIC, false) == 2, "Expected Cursed to roll two Basic positives.")
	_require(_count_rolls(rolls, StatCatalog.CATEGORY_RARE, false) == 1, "Expected Cursed to roll one Rare positive.")
	_require(_count_rolls(rolls, StatCatalog.CATEGORY_BASIC, true) == 1, "Expected Cursed to roll one Basic drawback.")

	var plan := GearGenerator.rarity_roll_plan(GearItem.Tier.CURSED)
	_require(plan["ok"], "Expected Cursed rarity plan to be supported.")
	_require(plan["rolls"] == rolls, "Expected rarity_roll_plan(Cursed) to use the named Cursed plan.")


func _check_cursed_items_for_every_slot() -> void:
	var seed := 73007
	for slot in GearItem.universal_slot_order():
		for sample in 30:
			var rng := RandomNumberGenerator.new()
			rng.seed = seed
			seed += 19
			var result := GearGenerator.generate_from_request({
				"tier": GearItem.Tier.CURSED,
				"slot": slot,
				"rng": rng,
				"id": "gear.test.p5m5.t7.%d.%d" % [slot, sample],
				"deterministic_key": "p5m5:t7:%d:%d" % [slot, sample],
				"source_context": "p5m5_t7",
				"source_seed": seed,
			})
			_require(result["ok"], "Expected Cursed generation to succeed: %s." % str(result["errors"]))
			var item: GearItem = result["item"]
			_require(item.affixes.size() == 4, "Expected Cursed item to have four affixes.")
			_require(_count_category(item, StatModifier.StatCategory.BASIC) == 2, "Expected Cursed item to have two Basic positives.")
			_require(_count_category(item, StatModifier.StatCategory.RARE) == 1, "Expected Cursed item to have one Rare positive.")
			_require(_count_category(item, StatModifier.StatCategory.DRAWBACK) == 1, "Expected Cursed item to have one drawback.")
			_require(_count_category(item, StatModifier.StatCategory.SPECIAL) == 0, "Expected Cursed item not to roll Specials.")
			_require(_duplicate_stat_ids(item).is_empty(), "Expected Cursed item not to duplicate stat IDs.")
			_require(_cursed_drawback_is_valid(item), "Expected Cursed drawback to be a valid slot Basic stat with negative value.")


func _check_cursed_generation_is_deterministic() -> void:
	var first := _cursed_signature(83007, GearItem.SlotType.CHARM)
	var second := _cursed_signature(83007, GearItem.SlotType.CHARM)
	_require(first == second, "Expected same Cursed seed/request to produce identical stats and values.")


func _check_exhausted_drawback_pool_fails_without_partial_affixes() -> void:
	var rolls: Array[Dictionary] = [
		{"category": StatCatalog.CATEGORY_BASIC, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_BASIC, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_BASIC, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_BASIC, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_BASIC, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_BASIC, "is_drawback": false},
		{"category": StatCatalog.CATEGORY_BASIC, "is_drawback": true},
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = 93007
	var result := GearGenerator._affixes_for_rolls(GearItem.SlotType.WEAPON, GearItem.Tier.CURSED, rolls, rng)
	_require((result["affixes"] as Array).is_empty(), "Expected exhausted Cursed drawback plan to return no partial affixes.")
	_require((result["errors"] as PackedStringArray).has("insufficient_drawback_pool:Weapon"), "Expected exhausted drawback pool error.")


func _cursed_drawback_is_valid(item: GearItem) -> bool:
	var positive_ids := {}
	var drawback: StatModifier = null
	for modifier in item.affixes:
		var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
		if modifier.is_drawback:
			drawback = modifier
		else:
			positive_ids[stat_id] = true
	if drawback == null:
		return false
	var drawback_id := StatCatalog.canonical_id_for_modifier(drawback)
	if positive_ids.has(drawback_id):
		return false
	if drawback.category != StatModifier.StatCategory.DRAWBACK:
		return false
	if not StatCatalog.drawback_stat_ids_for_slot(item.slot).has(drawback_id):
		return false
	if StatCatalog.category_for(drawback_id) != StatCatalog.CATEGORY_BASIC:
		return false
	if drawback.value >= 0.0:
		return false
	return _drawback_value_uses_cursed_range(item.slot, drawback)


func _drawback_value_uses_cursed_range(slot: GearItem.SlotType, modifier: StatModifier) -> bool:
	var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
	var range := StatCatalog.value_range_for_slot(slot, stat_id)
	if not bool(range.get("ok", false)):
		return false
	var low := float(range["min"]) * GearGenerator._rarity_value_multiplier(GearItem.Tier.CURSED, true)
	var high := float(range["max"]) * GearGenerator._rarity_value_multiplier(GearItem.Tier.CURSED, true)
	var min_value = minf(low, high)
	var max_value = maxf(low, high)
	var tolerance := 1.0 if StatCatalog.value_kind_for(stat_id) in [StatCatalog.VALUE_FLAT, StatCatalog.VALUE_STACKS] else 0.01
	return modifier.value >= min_value - tolerance and modifier.value <= max_value + tolerance


func _cursed_signature(seed: int, slot: GearItem.SlotType) -> String:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var item := GearGenerator.generate(GearItem.Tier.CURSED, slot, rng, "gear.test.p5m5.t7.deterministic")
	_require(item != null, "Expected deterministic Cursed item to generate.")
	var parts: PackedStringArray = []
	for modifier in item.affixes:
		parts.append("%s:%d:%s:%.4f" % [
			StatCatalog.canonical_id_for_modifier(modifier),
			modifier.category,
			"drawback" if modifier.is_drawback else "positive",
			modifier.value,
		])
	return "|".join(parts)


func _count_rolls(rolls: Array, category: String, is_drawback: bool) -> int:
	var count := 0
	for roll in rolls:
		if String(roll.get("category", "")) == category and bool(roll.get("is_drawback", false)) == is_drawback:
			count += 1
	return count


func _count_category(item: GearItem, category: StatModifier.StatCategory) -> int:
	var count := 0
	for modifier in item.affixes:
		if modifier.category == category:
			count += 1
	return count


func _duplicate_stat_ids(item: GearItem) -> Array[String]:
	var seen := {}
	var duplicates: Array[String] = []
	for modifier in item.affixes:
		var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
		if seen.has(stat_id) and not duplicates.has(stat_id):
			duplicates.append(stat_id)
		seen[stat_id] = true
	return duplicates


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
