extends SceneTree
## Focused P2:R5:T5 check for Adventure-seed-derived RNG contexts.

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

	var reroll_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(0, true)
	assert(_gear_signature(first_shop) != _gear_signature(reroll_shop))

	build_state.set_adventure_seed(124)
	var different_seed_shop: Array[GearItem] = build_state._generate_tavern_shop_offers(0, false)
	assert(_gear_signature(first_shop) != _gear_signature(different_seed_shop))

	build_state.reset()
	build_state.set_adventure_seed(123)
	var reward := EncounterReward.new()
	reward.generated_gear_choice_count = 2
	reward.generated_gear_tier = GearItem.Tier.MASTER
	reward.generated_gear_slots = [GearItem.SlotType.WEAPON, GearItem.SlotType.TRINKET]
	var first_reward_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	var second_reward_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	assert(_gear_signature(first_reward_choices) == _gear_signature(second_reward_choices))

	build_state.set_adventure_seed(124)
	var different_seed_reward_choices: Array[GearItem] = build_state._gear_choices_for_reward(reward)
	assert(_gear_signature(first_reward_choices) != _gear_signature(different_seed_reward_choices))

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
