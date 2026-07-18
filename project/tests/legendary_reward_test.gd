extends SceneTree
## Focused P2:R4:T7 check for Knives' Legendary reward choice and the two
## item mechanics it introduces.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var contract: ContractDef = load("res://data/contracts/the_gilded_serpent.tres")
	var knives := _find_route_node(contract.offer_node, "route.gilded_serpent.knives")
	assert(rogue != null)
	assert(knives != null)

	var wyvern: GearItem = load("res://data/gear/wyvern_kriss.tres")
	var mithril: GearItem = load("res://data/gear/mithril_karambit.tres")
	assert(wyvern != null)
	assert(mithril != null)
	assert(wyvern.tier == GearItem.Tier.LEGENDARY)
	assert(mithril.tier == GearItem.Tier.LEGENDARY)
	assert(mithril.triggered_skill_effects.size() == 2)

	var wyvern_stats := BuildResolver.resolve_stats(rogue, [], [], [wyvern])
	assert(wyvern_stats.bonus_poison_stacks == 2)
	assert(is_equal_approx(wyvern_stats.poison_damage_per_tick, 11.2))
	assert(is_equal_approx(wyvern_stats.poison_tick_interval_multiplier, 0.5))

	var mithril_stats := BuildResolver.resolve_stats(rogue, [], [], [mithril])
	assert(is_equal_approx(mithril_stats.attack_speed, 0.2))
	assert(is_equal_approx(mithril_stats.crit_chance, 0.25))
	assert(mithril_stats.triggered_skill_effects.size() == 2)
	assert(mithril_stats.triggered_skill_effects[0].skill.id == "skill.stab")
	assert(is_equal_approx(mithril_stats.triggered_skill_effects[0].chance, 0.2))

	build_state.set_class(rogue)
	build_state.active_contract = contract
	build_state.current_route_node = knives
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	assert(build_state.claim_current_reward())
	assert(build_state.gold == 42)
	assert(build_state.has_pending_reward_choice())
	assert(build_state.pending_reward_choices.size() == 2)
	assert(build_state.pending_reward_choices.has(wyvern))
	assert(build_state.pending_reward_choices.has(mithril))

	assert(build_state.choose_pending_reward_gear(mithril))
	assert(build_state.equipped_weapon == mithril)
	assert(not build_state.has_pending_reward_choice())
	assert(build_state.continue_after_win())
	assert(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE)
	assert(build_state.current_route_node == knives)
	assert(build_state.current_route_node.next_nodes[0].id == "route.gilded_serpent.vyra")

	print("Legendary reward check: OK")
	quit()


func _find_route_node(node: ContractRouteNode, id: String, visited: Array[String] = []) -> ContractRouteNode:
	if node == null or visited.has(node.id):
		return null
	if node.id == id:
		return node
	visited.append(node.id)
	for child in node.next_nodes:
		var found := _find_route_node(child, id, visited)
		if found != null:
			return found
	return null
