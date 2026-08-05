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
	assert(combat_seed == RunRngSystem.seed_for_context(123, RunRngSystem.CONTEXT_COMBAT, ["encounter:0"]))
	build_state.set_adventure_seed(124)
	assert(build_state.current_combat_rng_seed() != combat_seed)

	build_state.set_adventure_seed(123)
	var first_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(0, false)
	var second_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(0, false)
	assert(_gear_signature(first_shop) == _gear_signature(second_shop))
	assert(_unique_shop_signature_count(first_shop) == first_shop.size())
	assert(first_shop.all(func(offer): return offer.tier == GearItem.Tier.BASIC))

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
	var saw_cursed := false
	var saw_legendary := false
	for round_index in 300:
		var contract_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(round_index, false)
		assert(_unique_shop_signature_count(contract_shop) == contract_shop.size())
		for offer in contract_shop:
			if offer.tier == GearItem.Tier.MASTER:
				saw_master = true
			elif offer.tier == GearItem.Tier.CURSED:
				saw_cursed = true
			elif offer.tier == GearItem.Tier.LEGENDARY:
				saw_legendary = true
				assert(offer.resource_path != "")
				assert(offer.affixes.size() > 0 or offer.triggered_skill_effects.size() > 0)
	assert(saw_master)
	assert(saw_cursed)
	assert(saw_legendary)

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
