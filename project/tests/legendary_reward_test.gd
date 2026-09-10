extends SceneTree
## Focused P2:R4:T7 check for Knives' Legendary reward choice, plus
## P2:R9:T4 hand-verification of the 3 additional Legendaries (Bandit
## Blade, Umbral Stiletto, Bejeweled Push Dagger) and P2:R9:T5's seeded
## 2-of-5 choice (no longer a fixed Wyvern Kriss/Mithril Karambit pair --
## reproducibility of that choice across seeds is covered separately in
## run_rng_context_test.gd, alongside the shop's other seeded-RNG checks).


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
	assert(is_equal_approx(wyvern_stats.bonus_base_elemental_damage, 8.0))
	assert(is_equal_approx(wyvern_stats.gear_elemental_damage_multiplier, 1.4))
	assert(is_equal_approx(wyvern_stats.decay_chance, 0.12))
	assert(is_equal_approx(wyvern_stats.poison_tick_interval_multiplier, 0.5))

	var mithril_stats := BuildResolver.resolve_stats(rogue, [], [], [mithril])
	assert(is_equal_approx(mithril_stats.attack_speed, 0.15))
	assert(is_equal_approx(mithril_stats.crit_chance, 0.20))
	assert(is_equal_approx(mithril_stats.shred_chance, 0.20))
	assert(mithril_stats.triggered_skill_effects.size() == 2)
	assert(mithril_stats.triggered_skill_effects[0].skill.id == "skill.stab")
	assert(is_equal_approx(mithril_stats.triggered_skill_effects[0].chance, 0.5))

	build_state.set_class(rogue)
	build_state.active_contract = contract
	build_state.current_route_node = knives
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	assert(build_state.claim_current_reward())
	assert(build_state.gold == 42)
	assert(build_state.has_pending_reward_choice())

	# P2:R9:T5 -- Knives now offers a seeded random choice of 2 of a 5-item
	# Legendary pool instead of a fixed Wyvern Kriss/Mithril Karambit pair.
	# This asserts the choice is well-formed (2 distinct Legendary-tier
	# items, both members of the authored pool) rather than which 2
	# specifically -- seed reproducibility of the choice itself is covered
	# in run_rng_context_test.gd.
	assert(build_state.pending_reward_choices.size() == 2)
	assert(build_state.pending_reward_choices[0].id != build_state.pending_reward_choices[1].id)
	assert(build_state.pending_reward_choices.all(func(gear): return gear.tier == GearItem.Tier.LEGENDARY))
	var legendary_pool_ids: Array[String] = []
	for gear in knives.reward.legendary_choice_pool:
		legendary_pool_ids.append(gear.id)
	for choice in build_state.pending_reward_choices:
		assert(legendary_pool_ids.has(choice.id))

	var chosen: GearItem = build_state.pending_reward_choices[0]
	assert(build_state.choose_pending_reward_gear(chosen))
	assert(build_state.equipped_weapon == chosen)
	assert(not build_state.has_pending_reward_choice())
	assert(build_state.continue_after_win())
	assert(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE)
	assert(build_state.current_route_node == knives)
	assert(build_state.current_route_node.next_nodes[0].id == "route.gilded_serpent.vyra")

	# -- P2:R9:T4 -- the 3 additional Legendaries, hand-verified in isolation --
	var bandit_blade: GearItem = load("res://data/gear/bandit_blade.tres")
	var umbral_stiletto: GearItem = load("res://data/gear/umbral_stiletto.tres")
	var bejeweled_push_dagger: GearItem = load("res://data/gear/bejeweled_push_dagger.tres")
	assert(bandit_blade != null)
	assert(umbral_stiletto != null)
	assert(bejeweled_push_dagger != null)
	assert(bandit_blade.tier == GearItem.Tier.LEGENDARY)
	assert(umbral_stiletto.tier == GearItem.Tier.LEGENDARY)
	assert(bejeweled_push_dagger.tier == GearItem.Tier.LEGENDARY)

	# Rogue base stats (rogue_starter.tres): crit_chance=0.05, crit_multiplier=2.0,
	# physical_damage_multiplier=1.0 -- affixes below are additive/multiplicative
	# on top of that baseline, not standalone values.
	var bandit_stats := BuildResolver.resolve_stats(rogue, [], [], [bandit_blade], 100)
	print("Bandit Blade: gear_phys=%.2f crit=%.2f gold_mult=%.2f bonus_phys=%.2f (expect 1.20, 0.17, 1.30, 10.00)" % [
		bandit_stats.gear_physical_damage_multiplier, bandit_stats.crit_chance, bandit_stats.gold_reward_multiplier, bandit_stats.bonus_physical_damage
	])
	assert(is_equal_approx(bandit_stats.gear_physical_damage_multiplier, 1.2))
	assert(is_equal_approx(bandit_stats.crit_chance, 0.17))
	assert(is_equal_approx(bandit_stats.gold_reward_multiplier, 1.3))
	assert(is_equal_approx(bandit_stats.bonus_physical_damage, 10.0))
	var bandit_stats_no_gold := BuildResolver.resolve_stats(rogue, [], [], [bandit_blade], 0)
	assert(is_equal_approx(bandit_stats_no_gold.bonus_physical_damage, 0.0))

	var umbral_stats := BuildResolver.resolve_stats(rogue, [], [], [umbral_stiletto])
	print("Umbral Stiletto: crit=%.2f crit_mult=%.2f (expect 0.15, 3.00)" % [
		umbral_stats.crit_chance, umbral_stats.crit_multiplier
	])
	assert(is_equal_approx(umbral_stats.crit_chance, 0.15))
	assert(is_equal_approx(umbral_stats.crit_multiplier, 3.0))
	assert(is_equal_approx(umbral_stats.elemental_proc_chance, 1.0))
	var umbral_unlocked_skills := BuildResolver.resolve_unlocked_skills(rogue, [], [], [umbral_stiletto])
	var unlocks_death_strike := false
	for skill in umbral_unlocked_skills:
		if skill.id == "skill.killers_mark":
			unlocks_death_strike = true
	print("Umbral Stiletto unlocks Death Strike (expect true): %s" % unlocks_death_strike)
	assert(unlocks_death_strike)

	var bejeweled_stats := BuildResolver.resolve_stats(rogue, [], [], [bejeweled_push_dagger])
	print("Bejeweled Push Dagger: base_damage=%.2f gear_phys=%.2f crit=%.2f min_cast_proc=%.2f (expect 8.00, 1.20, 0.15, 0.20)" % [
		bejeweled_stats.bonus_physical_damage, bejeweled_stats.gear_physical_damage_multiplier, bejeweled_stats.crit_chance, bejeweled_stats.min_cast_time_proc_chance
	])
	assert(is_equal_approx(bejeweled_stats.bonus_physical_damage, 8.0))
	assert(is_equal_approx(bejeweled_stats.gear_physical_damage_multiplier, 1.2))
	assert(is_equal_approx(bejeweled_stats.crit_chance, 0.15))
	assert(is_equal_approx(bejeweled_stats.min_cast_time_proc_chance, 0.2))

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
