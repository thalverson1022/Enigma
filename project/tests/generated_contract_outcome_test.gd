extends SceneTree
## Focused P4M7-T9 checks for generated contract failure, retry, restart,
## reward-claim, route progression, completion, and economy lifecycle behavior.

const ContractOfferSourceScript := preload("res://scripts/systems/contract_offer_source.gd")

var _failed := false


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")

	_check_generated_loss_retry_and_terminal_failure(build_state, rogue)
	_check_restart_clears_failed_generated_contract(build_state, rogue)
	_check_generated_win_claims_reward_and_returns_to_route(build_state, rogue)
	_check_generated_boss_win_marks_contract_victory(build_state, rogue)
	_check_generated_boss_stops_granting_talent_points_at_cap(build_state, rogue)

	print("")
	if _failed:
		print("Generated contract outcome check: FAILED")
		quit(1)
	else:
		print("Generated contract outcome check: OK")
		quit()


func _check_generated_loss_retry_and_terminal_failure(build_state, rogue: ClassDef) -> void:
	print("generated contract first loss should grant one retry and preserve materialized fight state")
	var node := _start_generated_contract_fight(build_state, rogue)
	var contract: ContractDef = build_state.active_contract
	var payload: Dictionary = node.generated_encounter_payload.duplicate(true)
	var reward_signature := _reward_signature(node.reward)
	var monster: Monster = node.monster
	var duration: int = node.duration_ms
	var fight_seed: int = build_state.current_combat_rng_seed()
	var fight_key: String = node.id

	_require(build_state.start_fight(), "Expected generated fight to start.")
	build_state.finish_fight(false)
	_require(build_state.run_phase == BuildState.RunPhase.RESULT, "Expected first generated loss to stay in result phase.")
	_require(build_state.run_outcome == BuildState.RunOutcome.FIGHT_LOSS_RETRY, "Expected first generated loss to offer retry.")
	_require(build_state.failure_count_for_current_encounter() == 1, "Expected first generated failure count.")
	_require(build_state.can_retry_current_encounter(), "Expected generated contract retry after first loss.")
	_require(build_state.retry_current_encounter(), "Expected generated retry to return to planning.")
	_require(build_state.active_contract == contract, "Expected generated retry to preserve materialized contract instance.")
	_require(build_state.current_route_node == node, "Expected generated retry to preserve route node.")
	_require(build_state.current_route_node.id == fight_key, "Expected generated retry to preserve fight key.")
	_require(build_state.current_route_node.generated_encounter_payload == payload, "Expected generated retry to preserve encounter payload.")
	_require(_reward_signature(build_state.current_route_node.reward) == reward_signature, "Expected generated retry to preserve materialized reward.")
	_require(not build_state.claimed_route_reward_ids.has(node.id), "Expected generated retry not to claim the route reward.")
	_require(build_state.current_route_node.monster == monster, "Expected generated retry to preserve combat-ready monster instance.")
	_require(build_state.current_route_node.duration_ms == duration, "Expected generated retry to preserve duration.")
	_require(build_state.current_combat_rng_seed() != fight_seed, "Expected generated retry to reroll combat RNG seed while preserving the encounter.")

	print("generated contract second loss should fail the contract")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected retried generated fight to start.")
	build_state.finish_fight(false)
	_require(build_state.failure_count_for_current_encounter() == 2, "Expected second generated failure count.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected second generated loss to end the run.")
	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_FAILED, "Expected second generated loss to mark contract failed.")
	_require(not build_state.can_retry_current_encounter(), "Expected no third generated attempt.")
	_require(build_state.active_contract == contract, "Expected failed generated contract context to remain visible.")
	_require(build_state.current_route_node == node, "Expected failed generated route node context to remain visible.")
	_require(not build_state.claimed_route_reward_ids.has(node.id), "Expected failed generated fight not to claim route reward.")


func _check_restart_clears_failed_generated_contract(build_state, rogue: ClassDef) -> void:
	print("restart after generated contract failure should start fresh and drop failed generated state")
	_start_generated_contract_fight(build_state, rogue)
	build_state.start_fight()
	build_state.finish_fight(false)
	build_state.retry_current_encounter()
	build_state.set_locked(true)
	build_state.start_fight()
	build_state.finish_fight(false)
	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_FAILED, "Expected generated contract failure before restart.")
	build_state.reset(true)
	_require(build_state.adventure_seed == 424242, "Expected restart to preserve Adventure seed.")
	_require(build_state.selected_class == null, "Expected restart to clear class selection.")
	_require(build_state.pending_contract_offers.is_empty(), "Expected restart to clear generated pending offers.")
	_require(build_state.active_contract == null, "Expected restart to clear failed generated contract.")
	_require(build_state.current_route_node == null, "Expected restart to clear failed generated route node.")
	_require(build_state.claimed_route_reward_ids.is_empty(), "Expected restart to clear generated route rewards.")
	_require(build_state.encounter_failure_counts.is_empty(), "Expected restart to clear generated failure counts.")
	_require(build_state.run_phase == BuildState.RunPhase.PLANNING, "Expected restart to return to planning.")
	_require(build_state.run_outcome == BuildState.RunOutcome.NONE, "Expected restart to clear outcome.")


func _check_generated_win_claims_reward_and_returns_to_route(build_state, rogue: ClassDef) -> void:
	print("generated route win should claim through reward path and return to route when exits remain")
	var node := _start_generated_contract_fight(build_state, rogue)
	_require(not node.next_nodes.is_empty(), "Expected first generated node to have outgoing choices.")
	build_state.start_fight()
	build_state.finish_fight(true)
	var reward: EncounterReward = node.reward
	_require(reward != null, "Expected generated node to have a materialized reward.")
	var expected_gold: int = build_state.gold + build_state.modified_gold_reward(reward.gold_amount)
	var expected_talent_points: int = build_state.earned_talent_points + reward.talent_points
	build_state.shop_unlocked = true
	_require(build_state.run_phase == BuildState.RunPhase.RESULT, "Expected generated win to enter result phase.")
	_require(build_state.run_outcome == BuildState.RunOutcome.FIGHT_WIN, "Expected generated node win outcome before continue.")
	_require(reward.gold_amount > 0, "Expected generated node reward to include gold.")
	_require(reward.generated_gear_choice_count > 0, "Expected generated node reward to include gear choices.")
	_require(node.reward_summary != "", "Expected generated node reward summary to be materialized.")
	_require(node.reward_quality_label != "", "Expected generated node reward quality label to be materialized.")
	_require(build_state.claim_current_reward(), "Expected generated route reward claim to succeed.")
	_require(build_state.gold == expected_gold, "Expected generated route reward gold to apply through BuildState.")
	_require(build_state.earned_talent_points == expected_talent_points, "Expected generated route reward talent points to apply through BuildState.")
	_require(build_state.pending_reward_choices.size() == reward.generated_gear_choice_count, "Expected generated route reward choices to be pending after claim.")
	_require(build_state.claimed_route_reward_ids.has(node.id), "Expected generated route reward ID to be claimed.")
	_require(build_state.has_claimed_current_reward(), "Expected generated reward claim to be visible through shared helper.")
	_require(not build_state.claim_current_reward(), "Expected generated route reward duplicate claim to be rejected.")
	_require(build_state.gold == expected_gold, "Expected rejected duplicate generated reward claim not to add gold.")
	_require(build_state.skip_pending_reward_gear(), "Expected generated route pending gear choices to be skippable before continuing.")
	_require(not build_state.should_open_shop_after_current_reward(), "Expected generated route node reward not to open a mid-contract shop.")
	_require(not build_state.open_shop_round(), "Expected direct shop open to be rejected mid-contract.")
	_require(not build_state.shop_round_pending, "Expected no shop round to become pending mid-contract.")
	_require(build_state.continue_after_win(), "Expected generated node continue to return to route.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected generated win with exits to return to route phase.")
	_require(build_state.run_outcome == BuildState.RunOutcome.NONE, "Expected generated route continue to clear outcome.")
	_require(not build_state.last_fight_won, "Expected generated route continue to clear last_fight_won.")
	_require(build_state.current_route_node == node, "Expected generated route phase to remain anchored on completed node for next choices.")


func _check_generated_boss_win_marks_contract_victory(build_state, rogue: ClassDef) -> void:
	print("generated boss win should continue into the repeatable generated loop")
	_start_generated_contract_offer(build_state, rogue)
	_require(build_state.accept_contract_offer(), "Expected generated contract acceptance for boss path.")
	var boss := _advance_to_generated_boss(build_state)
	_require(boss != null, "Expected generated boss node.")
	_require(boss.node_type == ContractRouteNode.NodeType.BOSS, "Expected selected generated node to be boss.")
	_require(boss.next_nodes.is_empty(), "Expected generated boss to have no outgoing nodes.")
	build_state.start_fight()
	build_state.finish_fight(true)
	var reward: EncounterReward = boss.reward
	_require(reward != null, "Expected generated boss to have a materialized reward.")
	var expected_gold: int = build_state.gold + build_state.modified_gold_reward(reward.gold_amount)
	var expected_talent_points: int = build_state.earned_talent_points + reward.talent_points
	_require(reward.gold_amount > 0, "Expected generated boss reward to include gold.")
	_require(reward.talent_points > 0, "Expected generated boss reward to include talent points.")
	_require(reward.generated_gear_choice_count > 0, "Expected generated boss reward to include generated gear choices.")
	_require(boss.reward_summary != "", "Expected generated boss reward summary to be materialized.")
	_require(boss.reward_quality_label != "", "Expected generated boss reward quality label to be materialized.")
	_require(build_state.claim_current_reward(), "Expected generated boss reward claim path to succeed.")
	_require(build_state.gold == expected_gold, "Expected generated boss reward gold to apply through BuildState.")
	_require(build_state.earned_talent_points == expected_talent_points, "Expected generated boss reward talent points to apply through BuildState.")
	_require(build_state.pending_reward_choices.size() == reward.generated_gear_choice_count, "Expected generated boss gear choices to be pending after claim.")
	_require(build_state.claimed_route_reward_ids.has(boss.id), "Expected generated boss reward ID to be claimed.")
	_require(not build_state.claim_current_reward(), "Expected generated boss duplicate reward claim to be rejected.")
	_require(build_state.skip_pending_reward_gear(), "Expected generated boss pending gear choices to be skippable before victory.")
	_require(build_state.should_open_shop_after_current_reward(), "Expected generated boss completion to unlock a between-contract shop.")
	_require(build_state.open_shop_round(), "Expected generated boss completion to open a shop round.")
	_require(build_state.shop_round_pending, "Expected between-contract shop to remain pending.")
	_require(build_state.close_shop_round(), "Expected between-contract shop to close before the next offer.")
	_require(build_state.continue_after_win(), "Expected generated boss continue to offer the next generated contract.")
	_require(build_state.completed_contract_count == 1, "Expected generated boss win to increment completed-contract count.")
	_require(build_state.contract_offer_index == 1, "Expected generated boss win to increment contract offer index.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected generated boss win to return to generated offer phase.")
	_require(build_state.run_outcome == BuildState.RunOutcome.NONE, "Expected generated boss loop continue to clear terminal outcome.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected next active contract to be generated.")
	_require(build_state.pending_contract_offers.size() == 3, "Expected next generated loop offer to provide three choices.")
	_require(build_state.claimed_route_reward_ids.is_empty(), "Expected next generated contract to clear previous route reward IDs.")


func _check_generated_boss_stops_granting_talent_points_at_cap(build_state, rogue: ClassDef) -> void:
	print("generated boss reward should stop granting talent points at cap")
	_start_generated_contract_offer(build_state, rogue, BuildState.TALENT_POINT_CAP)
	_require(build_state.accept_contract_offer(), "Expected generated contract acceptance for capped boss path.")
	var boss := _advance_to_generated_boss(build_state)
	_require(boss != null and boss.node_type == ContractRouteNode.NodeType.BOSS, "Expected generated boss node for capped reward check.")
	_require(boss.reward != null, "Expected capped generated boss reward to exist.")
	_require(boss.reward.gold_amount > 0, "Expected capped generated boss reward to keep gold.")
	_require(boss.reward.generated_gear_choice_count > 0, "Expected capped generated boss reward to keep generated gear.")
	_require(boss.reward.talent_points == 0, "Expected capped generated boss reward to omit talent points.")
	_require(not boss.reward_summary.contains("talent point"), "Expected capped generated boss summary to omit talent points.")
	build_state.start_fight()
	build_state.finish_fight(true)
	_require(build_state.claim_current_reward(), "Expected capped generated boss reward claim to succeed.")
	_require(build_state.earned_talent_points == BuildState.TALENT_POINT_CAP, "Expected capped generated boss reward not to exceed talent cap.")


func _start_generated_contract_fight(build_state, rogue: ClassDef) -> ContractRouteNode:
	_start_generated_contract_offer(build_state, rogue)
	_require(build_state.accept_contract_offer(), "Expected generated contract acceptance.")
	var node: ContractRouteNode = build_state.current_route_node.next_nodes[0]
	_require(build_state.choose_contract_route_node(node), "Expected generated route node choice.")
	_require(node.monster != null, "Expected generated node to be combat-ready.")
	build_state.set_locked(true)
	_require(build_state.can_start_current_fight(), "Expected generated fight to be startable.")
	return node


func _start_generated_contract_offer(build_state, rogue: ClassDef, earned_talent_points: int = 0) -> void:
	build_state.reset()
	build_state.set_adventure_seed(424242)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.earned_talent_points = earned_talent_points
	_set_basic_rotation(build_state)
	var context := ContractOfferSourceScript.offer_context(
		424242,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Graveyard"]},
		false,
		true
	)
	context["earned_talent_points"] = earned_talent_points
	_require(build_state.start_contract_offer(context), "Expected generated-only contract offer to start.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected active generated contract.")


func _advance_to_generated_boss(build_state) -> ContractRouteNode:
	while (
		build_state.current_route_node != null
		and build_state.current_route_node.node_type != ContractRouteNode.NodeType.BOSS
	):
		_require(not build_state.current_route_node.next_nodes.is_empty(), "Expected route choices before generated boss.")
		var next_node: ContractRouteNode = build_state.current_route_node.next_nodes[0]
		_require(build_state.choose_contract_route_node(next_node), "Expected generated route node choice on boss path.")
		if next_node.node_type == ContractRouteNode.NodeType.BOSS:
			return next_node
		build_state.set_locked(true)
		_require(build_state.start_fight(), "Expected generated boss-path fight to start.")
		build_state.finish_fight(true)
		_require(build_state.claim_current_reward(), "Expected generated boss-path reward claim.")
		if build_state.has_pending_reward_choice():
			_require(build_state.skip_pending_reward_gear(), "Expected generated boss-path pending reward choice skip.")
		_require(build_state.continue_after_win(), "Expected generated boss-path route continue.")
	return build_state.current_route_node


func _set_basic_rotation(build_state) -> void:
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected at least one unlocked skill for generated contract outcome setup.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)


func _reward_signature(reward: EncounterReward) -> String:
	if reward == null:
		return "none"
	return JSON.stringify({
		"gold_amount": reward.gold_amount,
		"talent_points": reward.talent_points,
		"generated_gear_choice_count": reward.generated_gear_choice_count,
		"generated_gear_tier": reward.generated_gear_tier,
		"generated_gear_slots": reward.generated_gear_slots.duplicate(),
	})


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failed = true
