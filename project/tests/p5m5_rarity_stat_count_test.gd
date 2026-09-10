extends SceneTree
## Focused P5M5-T3 check for procedural rarity stat-count rules.

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")


func _initialize() -> void:
	print("-- P5M5 rarity stat-count rules --")
	_check_active_generated_tiers()
	_check_roll_plans()
	_check_generated_rarity_counts_for_all_slots()
	_check_crude_and_legendary_boundaries()
	print("P5M5 rarity stat-count rules check: OK")
	quit(0)


func _check_active_generated_tiers() -> void:
	var expected: Array[GearItem.Tier] = [
		GearItem.Tier.BASIC,
		GearItem.Tier.MASTER,
		GearItem.Tier.EPIC,
		GearItem.Tier.CURSED,
		GearItem.Tier.CHAOS,
		GearItem.Tier.UNIQUE,
	]
	_require(GearGenerator.ACTIVE_GENERATED_TIERS == expected, "Expected active procedural rarities to exclude only Crude and Legendary.")


func _check_roll_plans() -> void:
	_require_plan(GearItem.Tier.BASIC, 1, 1, 0, 0, 0)
	_require_plan(GearItem.Tier.MASTER, 2, 2, 0, 0, 0)
	_require_plan(GearItem.Tier.EPIC, 3, 2, 1, 0, 0)
	_require_plan(GearItem.Tier.CURSED, 4, 2, 1, 1, 0)
	_require_chaos_variable_plan()
	_require_plan(GearItem.Tier.UNIQUE, 5, 3, 1, 0, 1)

	var crude_plan := GearGenerator.rarity_roll_plan(GearItem.Tier.CRUDE)
	_require(not crude_plan["ok"], "Expected Crude roll plan to be unsupported.")
	var legendary_plan := GearGenerator.rarity_roll_plan(GearItem.Tier.LEGENDARY)
	_require(not legendary_plan["ok"], "Expected Legendary roll plan to be unsupported.")


func _check_generated_rarity_counts_for_all_slots() -> void:
	var expectations := {
		GearItem.Tier.BASIC: {"total": 1, "basic": 1, "rare": 0, "drawback": 0, "special": 0},
		GearItem.Tier.MASTER: {"total": 2, "basic": 2, "rare": 0, "drawback": 0, "special": 0},
		GearItem.Tier.EPIC: {"total": 3, "basic": 2, "rare": 1, "drawback": 0, "special": 0},
		GearItem.Tier.CURSED: {"total": 4, "basic": 2, "rare": 1, "drawback": 1, "special": 0},
		GearItem.Tier.UNIQUE: {"total": 5, "basic": 3, "rare": 1, "drawback": 0, "special": 1},
	}
	var seed := 83001
	for slot in GearItem.universal_slot_order():
		for tier in GearGenerator.ACTIVE_GENERATED_TIERS:
			var rng := RandomNumberGenerator.new()
			rng.seed = seed
			seed += 17
			var result := GearGenerator.generate_from_request({
				"tier": tier,
				"slot": slot,
				"rng": rng,
				"id": "gear.test.p5m5.t3.%d.%d" % [tier, slot],
				"deterministic_key": "p5m5:t3:%d:%d" % [tier, slot],
				"source_context": "p5m5_t3",
				"source_seed": seed,
			})
			_require(result["ok"], "Expected %s %s request to succeed: %s." % [
				GearGenerator.tier_name(tier),
				GearGenerator.universal_slot_label(slot),
				str(result["errors"]),
			])
			var item: GearItem = result["item"]
			if tier == GearItem.Tier.CHAOS:
				_require(item.affixes.size() == GearGenerator.CHAOS_ROLL_COUNT, "Expected Chaos total affix count.")
				_require(_count_category(item, StatModifier.StatCategory.SPECIAL) == 0, "Expected Chaos to exclude Specials.")
				_require(_all_chaos_categories_allowed(item), "Expected Chaos to roll only Basic/Rare positives or Basic drawbacks.")
			else:
				var expected: Dictionary = expectations[tier]
				_require(item.affixes.size() == int(expected["total"]), "Expected %s total affix count." % GearGenerator.tier_name(tier))
				_require(_count_category(item, StatModifier.StatCategory.BASIC) == int(expected["basic"]), "Expected %s Basic count." % GearGenerator.tier_name(tier))
				_require(_count_category(item, StatModifier.StatCategory.RARE) == int(expected["rare"]), "Expected %s Rare count." % GearGenerator.tier_name(tier))
				_require(_count_category(item, StatModifier.StatCategory.DRAWBACK) == int(expected["drawback"]), "Expected %s drawback count." % GearGenerator.tier_name(tier))
				_require(_count_category(item, StatModifier.StatCategory.SPECIAL) == int(expected["special"]), "Expected %s Special count." % GearGenerator.tier_name(tier))
			_require(_all_stats_are_valid_for_slot(item), "Expected every stat on %s to come from a valid slot/category pool." % item.display_name)


func _check_crude_and_legendary_boundaries() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var crude := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.CRUDE,
		"slot": GearItem.SlotType.WEAPON,
		"rng": rng,
	})
	_require(not crude["ok"], "Expected Crude procedural request to fail.")
	_require(crude["item"] == null, "Expected Crude procedural request not to return an item.")
	_require((crude["errors"] as PackedStringArray).has("crude_is_starter_only"), "Expected Crude starter-only error.")

	var legendary := GearGenerator.generate_from_request({
		"tier": GearItem.Tier.LEGENDARY,
		"slot": GearItem.SlotType.WEAPON,
		"rng": rng,
	})
	_require(not legendary["ok"], "Expected Legendary procedural request to fail.")
	_require(legendary["item"] == null, "Expected Legendary procedural request not to return an item.")
	_require((legendary["errors"] as PackedStringArray).has("legendary_requires_fixed_catalog"), "Expected Legendary fixed-catalog error.")


func _require_plan(tier: GearItem.Tier, total: int, basic: int, rare: int, drawback: int, special: int) -> void:
	var plan := GearGenerator.rarity_roll_plan(tier)
	_require(plan["ok"], "Expected supported roll plan for %s." % GearGenerator.tier_name(tier))
	var rolls: Array = plan["rolls"]
	_require(rolls.size() == total, "Expected %s roll plan total count." % GearGenerator.tier_name(tier))
	_require(_count_rolls(rolls, StatCatalog.CATEGORY_BASIC, false) == basic, "Expected %s Basic positive roll count." % GearGenerator.tier_name(tier))
	_require(_count_rolls(rolls, StatCatalog.CATEGORY_RARE, false) == rare, "Expected %s Rare positive roll count." % GearGenerator.tier_name(tier))
	_require(_count_rolls(rolls, StatCatalog.CATEGORY_BASIC, true) == drawback, "Expected %s Basic drawback roll count." % GearGenerator.tier_name(tier))
	_require(_count_rolls(rolls, StatCatalog.CATEGORY_SPECIAL, false) == special, "Expected %s Special roll count." % GearGenerator.tier_name(tier))


func _require_chaos_variable_plan() -> void:
	var plan := GearGenerator.rarity_roll_plan(GearItem.Tier.CHAOS)
	_require(plan["ok"], "Expected supported roll plan metadata for Chaos.")
	_require(bool(plan.get("variable", false)), "Expected Chaos roll plan to be variable.")
	_require(int(plan.get("roll_count", 0)) == GearGenerator.CHAOS_ROLL_COUNT, "Expected Chaos roll count metadata.")
	_require((plan["rolls"] as Array).is_empty(), "Expected static Chaos plan to avoid fixed category counts.")
	var outcomes: Array = plan["outcomes"]
	_require(_count_outcomes(outcomes, GearGenerator.CHAOS_OUTCOME_BASIC) == 1, "Expected Chaos Basic positive outcome.")
	_require(_count_outcomes(outcomes, GearGenerator.CHAOS_OUTCOME_RARE) == 1, "Expected Chaos Rare positive outcome.")
	_require(_count_outcomes(outcomes, GearGenerator.CHAOS_OUTCOME_DRAWBACK) == 1, "Expected Chaos Basic drawback outcome.")


func _count_rolls(rolls: Array, category: String, is_drawback: bool) -> int:
	var count := 0
	for roll in rolls:
		if String(roll.get("category", "")) == category and bool(roll.get("is_drawback", false)) == is_drawback:
			count += 1
	return count


func _count_outcomes(outcomes: Array, outcome_id: String) -> int:
	var count := 0
	for outcome in outcomes:
		if String(outcome.get("outcome", "")) == outcome_id:
			count += 1
	return count


func _count_category(item: GearItem, category: StatModifier.StatCategory) -> int:
	var count := 0
	for modifier in item.affixes:
		if modifier.category == category:
			count += 1
	return count


func _all_chaos_categories_allowed(item: GearItem) -> bool:
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
		elif modifier.category == StatModifier.StatCategory.SPECIAL:
			if not StatCatalog.is_stat_enabled_for_slot(item.slot, StatCatalog.CATEGORY_SPECIAL, stat_id):
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


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
