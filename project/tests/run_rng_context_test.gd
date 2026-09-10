extends SceneTree
## Focused P2:R5:T5 check for Adventure-seed-derived RNG contexts, extended
## by P2:R9:T5/T6 for Knives' seeded 2-of-5 Legendary choice and the shop's
## Legendary-pool ownership dedupe/fallback.

const RunRngSystem = preload("res://scripts/systems/run_rng.gd")


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	build_state.set_adventure_seed(123)

	var combat_seed: int = build_state.current_combat_rng_seed()
	assert(combat_seed == RunRngSystem.seed_for_context(123, RunRngSystem.CONTEXT_COMBAT, ["encounter:0", 0]))
	build_state.run_phase = build_state.RunPhase.RESULT
	build_state.run_outcome = build_state.RunOutcome.FIGHT_LOSS_RETRY
	build_state.last_fight_won = false
	assert(build_state.retry_current_encounter())
	assert(build_state.current_combat_rng_seed() != combat_seed)
	assert(build_state.current_combat_rng_seed() == RunRngSystem.seed_for_context(123, RunRngSystem.CONTEXT_COMBAT, ["encounter:0", 1]))
	build_state.set_adventure_seed(124)
	assert(build_state.current_combat_rng_seed() != combat_seed)

	build_state.set_adventure_seed(123)
	var first_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(0, false)
	var second_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(0, false)
	assert(_gear_signature(first_shop) == _gear_signature(second_shop))
	assert(_unique_shop_signature_count(first_shop) == first_shop.size())
	assert(first_shop.all(func(offer): return GearGenerator.ACTIVE_GENERATED_TIERS.has(offer.tier)))

	var reroll_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(0, true)
	assert(_gear_signature(first_shop) != _gear_signature(reroll_shop))
	assert(_unique_shop_signature_count(reroll_shop) == reroll_shop.size())

	build_state.set_adventure_seed(124)
	var different_seed_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(0, false)
	assert(_gear_signature(first_shop) != _gear_signature(different_seed_shop))

	build_state.reset()
	build_state.set_adventure_seed(123)
	build_state.active_contract = ContractDef.new()
	var saw_master := false
	var saw_epic := false
	var saw_cursed := false
	var saw_chaos := false
	var saw_unique := false
	var saw_legendary := false
	for round_index in 1000:
		var contract_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(round_index, false)
		assert(_unique_shop_signature_count(contract_shop) == contract_shop.size())
		for offer in contract_shop:
			if offer.tier == GearItem.Tier.MASTER:
				saw_master = true
			elif offer.tier == GearItem.Tier.EPIC:
				saw_epic = true
			elif offer.tier == GearItem.Tier.CURSED:
				saw_cursed = true
			elif offer.tier == GearItem.Tier.CHAOS:
				saw_chaos = true
				assert(offer.is_unidentified)
			elif offer.tier == GearItem.Tier.UNIQUE:
				saw_unique = true
			elif offer.tier == GearItem.Tier.LEGENDARY:
				saw_legendary = true
				assert(offer.source_kind == GearItem.SourceKind.LEGENDARY)
			assert(offer.tier != GearItem.Tier.CRUDE)
	assert(saw_master)
	assert(saw_epic)
	assert(saw_cursed)
	assert(saw_chaos)
	assert(saw_unique)
	assert(saw_legendary)
	_check_shop_rarity_curve(build_state)
	_check_chaos_shop_identification(build_state)

	# -- P2:R9:T6 -- shop Legendary pool ownership dedupe + fallback --
	build_state.reset()
	build_state.set_adventure_seed(123)
	var owns_none: Array[String] = build_state._unowned_shop_legendary_paths()
	assert(owns_none.size() == build_state.shop_legendary_paths().size())

	build_state.equipped_weapon = load("res://data/gear/wyvern_kriss.tres")
	var owns_one: Array[String] = build_state._unowned_shop_legendary_paths()
	assert(owns_one.size() == owns_none.size() - 1)
	assert(not owns_one.has("res://data/gear/wyvern_kriss.tres"))

	for path in build_state.shop_legendary_paths():
		build_state.inventory.append(load(path))
	assert(build_state._unowned_shop_legendary_paths().is_empty())
	var fallback_rng := RandomNumberGenerator.new()
	fallback_rng.seed = 1
	var fallback_offer: GearItem = build_state._shop_offer_for_tier(
		GearItem.Tier.LEGENDARY, GearItem.SlotType.WEAPON, fallback_rng, "test_shop_legendary_fallback"
	)
	assert(fallback_offer.tier == GearItem.Tier.CURSED)

	build_state.reset()
	build_state.set_adventure_seed(123)
	var reward := EncounterReward.new()
	reward.generated_gear_choice_count = 2
	reward.generated_gear_tier = GearItem.Tier.MASTER
	reward.generated_gear_slots = [GearItem.SlotType.WEAPON, GearItem.SlotType.TRINKET]
	var first_reward_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	var second_reward_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	assert(_gear_signature(first_reward_choices) == _gear_signature(second_reward_choices))
	assert(first_reward_choices.all(func(item): return reward.generated_gear_slots.has(item.slot)))
	assert(_unique_stat_signature_count(first_reward_choices) == first_reward_choices.size())
	_check_reward_upgrade_chain(build_state)
	_check_reward_upgrade_depth_scaling(build_state)
	_check_reward_materialization_uses_contract_depth(build_state)

	build_state.set_adventure_seed(124)
	var different_seed_reward_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	assert(_gear_signature(first_reward_choices) != _gear_signature(different_seed_reward_choices))

	var same_slot_reward := EncounterReward.new()
	same_slot_reward.generated_gear_choice_count = 8
	same_slot_reward.generated_gear_tier = GearItem.Tier.MASTER
	same_slot_reward.generated_gear_slots = [GearItem.SlotType.WEAPON]
	var same_slot_choices: Array[GearItem] = build_state._gear_choices_for_reward(same_slot_reward)
	assert(same_slot_choices.size() == 8)
	assert(same_slot_choices.all(func(item): return item.slot == GearItem.SlotType.WEAPON))
	assert(_unique_stat_signature_count(same_slot_choices) == same_slot_choices.size())

	# -- P2:R9:T5 -- Knives' seeded 2-of-5 Legendary choice reproducibility --
	build_state.reset()
	build_state.set_adventure_seed(123)
	var legendary_reward := EncounterReward.new()
	legendary_reward.legendary_choice_count = 2
	legendary_reward.legendary_choice_pool = [
		load("res://data/gear/wyvern_kriss.tres"),
		load("res://data/gear/mithril_karambit.tres"),
		load("res://data/gear/bandit_blade.tres"),
		load("res://data/gear/umbral_stiletto.tres"),
		load("res://data/gear/bejeweled_push_dagger.tres"),
	]
	var first_legendary_choices: Array[GearItem] = build_state._gear_choices_for_reward(legendary_reward)
	var second_legendary_choices: Array[GearItem] = build_state._gear_choices_for_reward(legendary_reward)
	assert(first_legendary_choices.size() == 2)
	assert(first_legendary_choices[0].id != first_legendary_choices[1].id)
	assert(first_legendary_choices.all(func(item): return item.tier == GearItem.Tier.LEGENDARY))
	assert(_gear_signature(first_legendary_choices) == _gear_signature(second_legendary_choices))

	build_state.set_adventure_seed(124)
	var different_seed_legendary_choices: Array[GearItem] = build_state._gear_choices_for_reward(legendary_reward)
	assert(_gear_signature(first_legendary_choices) != _gear_signature(different_seed_legendary_choices))

	build_state.reset()
	build_state.set_adventure_seed(123)
	build_state.active_contract = ContractDef.new()
	build_state.run_phase = build_state.RunPhase.RESULT
	build_state.last_fight_won = true
	build_state.current_route_node = _route_node("route.alpha")
	var route_alpha_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	build_state.current_route_node = _route_node("route.beta")
	var route_beta_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	assert(_gear_signature(route_alpha_choices) != _gear_signature(route_beta_choices))

	print("Run RNG context check: OK")
	quit()


func _check_reward_upgrade_chain(build_state) -> void:
	build_state.reset()
	build_state.set_adventure_seed(123)
	var context := "encounter:0"
	var first_tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, context, 0)
	var second_tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, context, 0)
	assert(first_tier == second_tier)

	var basic_seed := _find_upgrade_seed(build_state, GearItem.Tier.BASIC, GearItem.Tier.MASTER, "basic_to_master")
	build_state.set_adventure_seed(basic_seed)
	assert(build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "basic_to_master", 0) == GearItem.Tier.MASTER)

	var master_seed := _find_upgrade_seed(build_state, GearItem.Tier.MASTER, GearItem.Tier.EPIC, "master_to_epic")
	build_state.set_adventure_seed(master_seed)
	assert(build_state._upgraded_reward_tier(GearItem.Tier.MASTER, "master_to_epic", 0) == GearItem.Tier.EPIC)

	var high_seed := _find_high_tier_seed(build_state)
	build_state.set_adventure_seed(high_seed)
	var high_tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.EPIC, "epic_to_high", 0)
	assert(build_state._is_reward_upgrade_high_tier(high_tier))
	assert(not build_state._reward_upgrade_high_tier_options().has(GearItem.Tier.LEGENDARY))
	assert(not build_state._reward_upgrade_high_tier_options().has(GearItem.Tier.CRUDE))

	for expected_high_tier in build_state._reward_upgrade_high_tier_options():
		var high_tier_seed := _find_high_tier_seed_for_tier(build_state, expected_high_tier)
		build_state.set_adventure_seed(high_tier_seed)
		assert(build_state._upgraded_reward_tier(GearItem.Tier.EPIC, "high_tier_%d" % expected_high_tier, 0) == expected_high_tier)

	var independent_seed := _find_independent_choice_seed(build_state)
	build_state.set_adventure_seed(independent_seed)
	var choice_a: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "independent_choices", 0)
	var choice_b: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "independent_choices", 1)
	assert(choice_a != choice_b)

	var reward := EncounterReward.new()
	reward.generated_gear_choice_count = 1
	reward.generated_gear_tier = GearItem.Tier.EPIC
	reward.generated_gear_slots = [GearItem.SlotType.WEAPON]
	build_state.current_encounter_index = 0
	build_state.set_adventure_seed(_find_materialized_high_tier_seed(build_state, "encounter:0"))
	var choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	assert(choices.size() == 1)
	assert(build_state._is_reward_upgrade_high_tier(choices[0].tier))
	assert(choices[0].reward_base_tier == GearItem.Tier.EPIC)
	assert(choices[0].reward_tier_steps.size() == 2)
	assert(choices[0].reward_tier_steps[0] == GearItem.Tier.EPIC)
	assert(choices[0].reward_tier_steps[1] == choices[0].tier)

	var magic_find_seed := _find_magic_find_reward_upgrade_seed(build_state)
	build_state.set_adventure_seed(magic_find_seed)
	var no_magic_story: Dictionary = build_state._reward_tier_upgrade_story(GearItem.Tier.BASIC, "magic_find_story", 0, 1, 0.0)
	var magic_story: Dictionary = build_state._reward_tier_upgrade_story(GearItem.Tier.BASIC, "magic_find_story", 0, 1, 1.0)
	assert(int(no_magic_story["final_tier"]) == GearItem.Tier.BASIC)
	assert(int(magic_story["final_tier"]) == GearItem.Tier.MASTER)
	assert(bool(magic_story["magic_find_upgraded"]))

	for seed in range(1, 2000):
		build_state.set_adventure_seed(seed)
		for base_tier in [GearItem.Tier.BASIC, GearItem.Tier.MASTER, GearItem.Tier.EPIC]:
			var upgraded: GearItem.Tier = build_state._upgraded_reward_tier(base_tier, "no_legendary", 0)
			assert(upgraded != GearItem.Tier.LEGENDARY)
			assert(upgraded != GearItem.Tier.CRUDE)


func _check_shop_rarity_curve(build_state) -> void:
	build_state.reset()
	build_state.active_contract = ContractDef.new()
	_check_shop_weights(build_state._shop_rarity_weights_for_depth(1), [65, 23, 6, 2, 3, 1, 1])
	_check_shop_weights(build_state._shop_rarity_weights_for_depth(6), [54, 26, 10, 4, 4, 2, 2])
	_check_shop_weights(build_state._shop_rarity_weights_for_depth(12), [41, 29, 15, 7, 5, 3, 3])
	_check_shop_weights(build_state._shop_rarity_weights_for_depth(-20), [65, 23, 6, 2, 3, 1, 1])
	_check_shop_weights(build_state._shop_rarity_weights_for_depth(99), [41, 29, 15, 7, 5, 3, 3])

	var depth_three: Dictionary = build_state._shop_rarity_weights_for_depth(3)
	_require(int(depth_three[GearItem.Tier.BASIC]) < 65, "Expected interpolated shop Basic weight to decline after depth 1.")
	_require(int(depth_three[GearItem.Tier.EPIC]) > 6, "Expected interpolated shop Epic weight to rise after depth 1.")

	var rng := RandomNumberGenerator.new()
	for expected_tier in build_state.SHOP_ROLL_TIERS:
		var seed := _find_shop_tier_seed(build_state, expected_tier, 12)
		rng.seed = seed
		_require(build_state._shop_tier_for_current_phase(rng, 12) == expected_tier, "Expected shop curve to be able to roll tier %d." % expected_tier)

	rng.seed = 1
	build_state.active_contract = null
	_require(build_state._shop_tier_for_current_phase(rng, 12) == GearItem.Tier.BASIC, "Expected pre-contract tavern shop to remain Basic-only.")


func _check_shop_weights(weights: Dictionary, expected_values: Array) -> void:
	var tiers := [
		GearItem.Tier.BASIC,
		GearItem.Tier.MASTER,
		GearItem.Tier.EPIC,
		GearItem.Tier.CURSED,
		GearItem.Tier.CHAOS,
		GearItem.Tier.UNIQUE,
		GearItem.Tier.LEGENDARY,
	]
	for i in tiers.size():
		_require(int(weights.get(tiers[i], 0)) == int(expected_values[i]), "Unexpected shop rarity weight for tier %d." % tiers[i])
	_require(not weights.has(GearItem.Tier.CRUDE), "Expected shop rarity curve to exclude Crude.")


func _check_chaos_shop_identification(build_state) -> void:
	build_state.reset()
	build_state.active_contract = ContractDef.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 112358
	var offer: GearItem = build_state._shop_offer_for_tier(
		GearItem.Tier.CHAOS, GearItem.SlotType.WEAPON, rng, "test.shop.chaos.identification", 12
	)
	_require(offer != null, "Expected Chaos shop offer to generate.")
	_require(offer.is_unidentified, "Expected Chaos shop offer to be unidentified before purchase.")
	var tooltip := "\n".join(CardStyle.gear_tooltip_lines(offer))
	_require(tooltip.begins_with("Unidentified"), "Expected unidentified Chaos tooltip heading, got: %s" % tooltip)
	_require(tooltip.contains("Stats:\nUnidentified"), "Expected unidentified Chaos tooltip to hide stat values, got: %s" % tooltip)
	_require(not tooltip.contains("+"), "Expected unidentified Chaos tooltip to hide positive values, got: %s" % tooltip)
	build_state.shop_round_pending = true
	var offers: Array[GearItem] = [offer]
	build_state.shop_offers = offers
	build_state.gold = GearGenerator.price_for_tier(GearItem.Tier.CHAOS)
	_require(build_state.buy_shop_offer(offer), "Expected Chaos shop offer purchase to succeed.")
	_require(not offer.is_unidentified, "Expected purchased Chaos item to reveal.")
	_require(CardStyle.gear_tooltip_lines(offer)[0] != "Unidentified", "Expected purchased Chaos tooltip to show real item name.")


func _find_shop_tier_seed(build_state, expected_tier: GearItem.Tier, contract_depth: int) -> int:
	for seed in range(1, 100000):
		var rng := RandomNumberGenerator.new()
		rng.seed = seed
		if build_state._shop_tier_for_current_phase(rng, contract_depth) == expected_tier:
			return seed
	assert(false, "Expected to find deterministic shop seed for tier %d." % expected_tier)
	return 0


func _check_reward_upgrade_depth_scaling(build_state) -> void:
	build_state.reset()
	_require(build_state._reward_upgrade_contract_depth(-5) == 1, "Expected reward upgrade depth to clamp low.")
	_require(build_state._reward_upgrade_contract_depth(99) == 12, "Expected reward upgrade depth to clamp high.")
	build_state.completed_contract_count = 0
	_require(build_state._current_contract_reward_depth() == 1, "Expected first live contract to use reward depth 1.")
	build_state.completed_contract_count = 11
	_require(build_state._current_contract_reward_depth() == 12, "Expected twelfth live contract to use reward depth 12.")
	build_state.completed_contract_count = 20
	_require(build_state._current_contract_reward_depth() == 12, "Expected later live contracts to stay clamped at reward depth 12.")

	_require(build_state._scaled_reward_upgrade_chance_bp(build_state.REWARD_UPGRADE_BASIC_TO_MASTER_BP, 1) == 1500, "Expected depth 1 Basic upgrade chance to use base odds.")
	_require(build_state._scaled_reward_upgrade_chance_bp(build_state.REWARD_UPGRADE_MASTER_TO_EPIC_BP, 1) == 800, "Expected depth 1 Master upgrade chance to use base odds.")
	_require(build_state._scaled_reward_upgrade_chance_bp(build_state.REWARD_UPGRADE_EPIC_TO_HIGH_TIER_BP, 1) == 300, "Expected depth 1 Epic upgrade chance to use base odds.")
	_require(build_state._scaled_reward_upgrade_chance_bp(build_state.REWARD_UPGRADE_BASIC_TO_MASTER_BP, 12) == 2250, "Expected depth 12 Basic upgrade chance to gain the max relative bonus.")
	_require(build_state._scaled_reward_upgrade_chance_bp(build_state.REWARD_UPGRADE_MASTER_TO_EPIC_BP, 12) == 1200, "Expected depth 12 Master upgrade chance to gain the max relative bonus.")
	_require(build_state._scaled_reward_upgrade_chance_bp(build_state.REWARD_UPGRADE_EPIC_TO_HIGH_TIER_BP, 12) == 450, "Expected depth 12 Epic upgrade chance to gain the max relative bonus.")

	var previous := 0
	for depth in range(1, 13):
		var chance: int = build_state._scaled_reward_upgrade_chance_bp(build_state.REWARD_UPGRADE_BASIC_TO_MASTER_BP, depth)
		_require(chance >= previous, "Expected reward upgrade chance to scale monotonically.")
		previous = chance

	build_state.set_adventure_seed(12345)
	var depth_one_tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "depth_determinism", 0, 1)
	var depth_one_repeat: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "depth_determinism", 0, 1)
	_require(depth_one_tier == depth_one_repeat, "Expected same seed/context/depth reward upgrade to be deterministic.")

	var depth_sensitive_seed := _find_depth_sensitive_seed(build_state)
	build_state.set_adventure_seed(depth_sensitive_seed)
	var early_tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "depth_sensitive", 0, 1)
	var late_tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "depth_sensitive", 0, 12)
	_require(early_tier != late_tier, "Expected changing only reward depth to be able to change upgrade outcome.")
	_require(late_tier != GearItem.Tier.CRUDE and late_tier != GearItem.Tier.LEGENDARY, "Expected scaled reward upgrade to preserve rarity boundaries.")


func _check_reward_materialization_uses_contract_depth(build_state) -> void:
	build_state.reset()
	build_state.set_adventure_seed(22222)
	var reward := EncounterReward.new()
	reward.generated_gear_choice_count = 1
	reward.generated_gear_tier = GearItem.Tier.UNIQUE
	reward.generated_gear_slots = [GearItem.SlotType.WEAPON]
	build_state.completed_contract_count = 0
	var early_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	build_state.completed_contract_count = 11
	var late_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	_require(early_choices.size() == 1 and late_choices.size() == 1, "Expected one generated reward choice at each depth.")
	_require(early_choices[0].deterministic_key != late_choices[0].deterministic_key, "Expected reward deterministic key to include contract depth.")
	_require(_gear_signature(early_choices) != _gear_signature(late_choices), "Expected live reward materialization to change when only contract depth changes.")
	_require(early_choices[0].source_context == late_choices[0].source_context, "Expected contract depth not to change reward context identity.")
	_require(early_choices[0].source_seed == late_choices[0].source_seed, "Expected contract depth not to change reward source seed.")


func _find_upgrade_seed(build_state, base_tier: GearItem.Tier, expected_tier: GearItem.Tier, context: String) -> int:
	for seed in range(1, 50000):
		build_state.set_adventure_seed(seed)
		if build_state._upgraded_reward_tier(base_tier, context, 0) == expected_tier:
			return seed
	assert(false, "Expected to find deterministic reward upgrade seed.")
	return 0


func _find_depth_sensitive_seed(build_state) -> int:
	for seed in range(1, 100000):
		build_state.set_adventure_seed(seed)
		var early_tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "depth_sensitive", 0, 1)
		var late_tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "depth_sensitive", 0, 12)
		if early_tier != late_tier:
			return seed
	assert(false, "Expected to find deterministic seed where reward depth changes the upgrade outcome.")
	return 0


func _find_high_tier_seed(build_state) -> int:
	for seed in range(1, 100000):
		build_state.set_adventure_seed(seed)
		var tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.EPIC, "epic_to_high", 0)
		if build_state._is_reward_upgrade_high_tier(tier):
			return seed
	assert(false, "Expected to find deterministic high-tier reward upgrade seed.")
	return 0


func _find_high_tier_seed_for_tier(build_state, expected_tier: GearItem.Tier) -> int:
	var context := "high_tier_%d" % expected_tier
	for seed in range(1, 250000):
		build_state.set_adventure_seed(seed)
		if build_state._upgraded_reward_tier(GearItem.Tier.EPIC, context, 0) == expected_tier:
			return seed
	assert(false, "Expected to find deterministic high-tier seed for tier %d." % expected_tier)
	return 0


func _find_independent_choice_seed(build_state) -> int:
	for seed in range(1, 50000):
		build_state.set_adventure_seed(seed)
		var choice_a: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "independent_choices", 0)
		var choice_b: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.BASIC, "independent_choices", 1)
		if choice_a != choice_b:
			return seed
	assert(false, "Expected to find seed with independently upgraded reward choices.")
	return 0


func _find_magic_find_reward_upgrade_seed(build_state) -> int:
	for seed in range(1, 5000):
		build_state.set_adventure_seed(seed)
		var no_magic_story: Dictionary = build_state._reward_tier_upgrade_story(GearItem.Tier.BASIC, "magic_find_story", 0, 1, 0.0)
		var magic_story: Dictionary = build_state._reward_tier_upgrade_story(GearItem.Tier.BASIC, "magic_find_story", 0, 1, 1.0)
		if int(no_magic_story["final_tier"]) == GearItem.Tier.BASIC and int(magic_story["final_tier"]) == GearItem.Tier.MASTER and bool(magic_story["magic_find_upgraded"]):
			return seed
	return 0


func _find_materialized_high_tier_seed(build_state, context: String) -> int:
	for seed in range(1, 100000):
		build_state.set_adventure_seed(seed)
		var tier: GearItem.Tier = build_state._upgraded_reward_tier(GearItem.Tier.EPIC, context, 0)
		if build_state._is_reward_upgrade_high_tier(tier):
			return seed
	assert(false, "Expected to find materialized high-tier reward seed.")
	return 0


func _route_node(id: String) -> ContractRouteNode:
	var node := ContractRouteNode.new()
	node.id = id
	node.monster = Monster.new()
	node.duration_ms = 1000
	return node


func _gear_signature(items: Array[GearItem]) -> String:
	var parts: PackedStringArray = []
	for item in items:
		var affix_parts: PackedStringArray = []
		for affix in item.affixes:
			affix_parts.append("%d:%d:%.4f" % [affix.stat, affix.operation, affix.value])
		parts.append("%s|%d|%d|%s|%s" % [
			item.id,
			item.tier,
			item.slot,
			item.display_name,
			",".join(affix_parts),
		])
	return ";".join(parts)


func _unique_shop_signature_count(items: Array[GearItem]) -> int:
	var seen := {}
	for item in items:
		seen[_shop_visible_signature(item)] = true
	return seen.size()


func _unique_stat_signature_count(items: Array[GearItem]) -> int:
	var seen := {}
	for item in items:
		seen[_stat_signature(item)] = true
	return seen.size()


func _stat_signature(item: GearItem) -> String:
	var affix_parts: PackedStringArray = []
	for affix in item.affixes:
		affix_parts.append("%03d:%03d:%0.4f" % [affix.stat, affix.operation, affix.value])
	affix_parts.sort()
	return "%d|%s" % [item.tier, ",".join(affix_parts)]


func _shop_visible_signature(item: GearItem) -> String:
	var affix_parts: PackedStringArray = []
	for affix in item.affixes:
		affix_parts.append("%d:%d:%.4f" % [affix.stat, affix.operation, affix.value])
	return "%d|%d|%s" % [item.tier, item.slot, ",".join(affix_parts)]


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
