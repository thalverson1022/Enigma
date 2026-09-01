extends SceneTree
## P4M8-T11 stitched lifecycle regression for the real Adventure contract loop.
## Focuses on the boundary between authored Vyra and repeated generated
## contracts; focused UI, matrix, and Balance Lab tests cover their surfaces in
## more detail.

const SaveSystemScript := preload("res://scripts/systems/save_system.gd")

var _failed := false


func _initialize() -> void:
	SaveSystemScript.save_path = "res://.test_p4m8_adventure_lifecycle_save.json"
	SaveSystemScript.delete_save()

	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")

	_check_normal_adventure_to_repeated_generated_loop(build_state, rogue)
	_check_contract_test_style_repeated_generated_loop(build_state, rogue)

	SaveSystemScript.delete_save()
	SaveSystemScript.save_path = SaveSystemScript.SAVE_PATH
	build_state.reset()
	if _failed:
		print("P4M8 adventure lifecycle regression: FAILED")
		quit(1)
	else:
		print("P4M8 adventure lifecycle regression: OK")
		quit()


func _check_normal_adventure_to_repeated_generated_loop(build_state, rogue: ClassDef) -> void:
	print("normal Adventure should flow Tavern -> generated loop -> shop -> next generated offer")
	_start_rogue_adventure_at_final_tavern_reward(build_state, rogue, 515151)
	_require(build_state.claim_current_reward(), "Expected final Tavern reward claim.")
	_require(build_state.continue_after_win(), "Expected final Tavern continue to start generated contract offers.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected generated contract offer after Tavern.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected generated contract first.")
	_require(build_state.pending_contract_offers.size() == 3, "Expected three generated offers after Tavern.")
	_round_trip(build_state)
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected generated offer to survive save/load.")

	var first_generated_offer_signature := _pending_offer_signature(build_state)

	_complete_active_generated_contract(build_state, 1, 1)
	_require(build_state.completed_contract_count == 1, "Expected first completed contract after first generated boss.")
	_require(build_state.contract_offer_index == 1, "Expected first generated offer index after first generated boss.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected next generated offer after first generated boss.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected generated offer after first generated boss.")
	_require(_pending_offer_signature(build_state) != first_generated_offer_signature, "Expected deterministic next offer to differ from the prior generated offer.")
	_round_trip(build_state)


func _check_contract_test_style_repeated_generated_loop(build_state, rogue: ClassDef) -> void:
	print("Contract Test style flow should skip Tavern/Vyra and repeat generated contracts")
	build_state.reset()
	build_state.set_adventure_seed(616161)
	build_state.set_class(rogue)
	var trees: Array[SubclassTree] = [
		load("res://data/subclass_trees/assassin.tres") as SubclassTree,
		load("res://data/subclass_trees/bladedancer.tres") as SubclassTree,
	]
	build_state.selected_trees = trees
	_set_basic_rotation(build_state)
	build_state.earned_talent_points = 7
	build_state.gold = 100
	build_state.grant_gear(load("res://data/gear/bandit_blade.tres"), true)
	_require(build_state.start_generated_contract_loop_offer({"route_difficulty": "medium"}, 3), "Expected Contract Test style generated offers.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected Contract Test style generated offer phase.")
	_require(build_state.completed_contract_count == 0, "Expected Contract Test style flow to start with zero completed contracts.")
	_require(build_state.contract_offer_index == 0, "Expected Contract Test style flow to start at offer index zero.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected Contract Test style active generated contract.")
	_round_trip(build_state)

	_complete_active_generated_contract(build_state, 1, 1)
	var first_loop_signature := _pending_offer_signature(build_state)
	_complete_active_generated_contract(build_state, 2, 2)
	_require(build_state.completed_contract_count == 2, "Expected Contract Test style flow to repeat two generated completions.")
	_require(build_state.contract_offer_index == 2, "Expected Contract Test style offer index after two completions.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected generated offers after repeated Contract Test completions.")
	_require(_pending_offer_signature(build_state) != first_loop_signature, "Expected repeated Contract Test offers to advance deterministically.")


func _complete_active_generated_contract(build_state, expected_completed_count: int, expected_offer_index: int) -> void:
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected generated offer phase before completion.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected active generated offer before completion.")
	_require(build_state.accept_contract_offer(), "Expected generated contract acceptance.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected generated route phase after acceptance.")
	_round_trip(build_state)
	var boss := _advance_to_generated_boss(build_state)
	_require(boss != null and boss.node_type == ContractRouteNode.NodeType.BOSS, "Expected generated boss node.")
	_require(build_state.current_route_node == boss, "Expected generated boss to be current node.")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected generated boss fight to start.")
	build_state.finish_fight(true)
	_require(build_state.claim_current_reward(), "Expected generated boss reward claim.")
	if build_state.has_pending_reward_choice():
		_require(build_state.skip_pending_reward_gear(), "Expected generated boss reward choice skip.")
	_require(build_state.open_shop_round(), "Expected shop after generated boss completion.")
	_round_trip(build_state)
	_require(build_state.shop_round_pending, "Expected generated boss shop to survive save/load.")
	_require(build_state.close_shop_round(), "Expected generated boss shop to close.")
	_require(build_state.continue_after_win(), "Expected generated boss completion to offer next generated contract.")
	_require(build_state.completed_contract_count == expected_completed_count, "Expected completed-contract count after generated completion.")
	_require(build_state.contract_offer_index == expected_offer_index, "Expected offer index after generated completion.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected next generated offer phase.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected next active contract to be generated.")
	_require(build_state.pending_contract_offers.size() == 3, "Expected three generated offers after completion.")


func _advance_to_generated_boss(build_state) -> ContractRouteNode:
	while (
		build_state.current_route_node != null
		and build_state.current_route_node.node_type != ContractRouteNode.NodeType.BOSS
	):
		_require(not build_state.current_route_node.next_nodes.is_empty(), "Expected route choices before generated boss.")
		var next_node: ContractRouteNode = build_state.current_route_node.next_nodes[0]
		_require(build_state.choose_contract_route_node(next_node), "Expected generated route node choice.")
		if next_node.node_type == ContractRouteNode.NodeType.BOSS:
			return next_node
		_require(build_state.current_route_node.monster != null, "Expected generated combat setup after route choice.")
		build_state.set_locked(true)
		_require(build_state.start_fight(), "Expected generated route fight to start.")
		build_state.finish_fight(true)
		_require(build_state.claim_current_reward(), "Expected generated route reward claim.")
		if build_state.has_pending_reward_choice():
			_require(build_state.skip_pending_reward_gear(), "Expected generated route reward choice skip.")
		if build_state.should_open_shop_after_current_reward():
			_require(build_state.open_shop_round(), "Expected generated route shop to open.")
			_require(build_state.close_shop_round(), "Expected generated route shop to close.")
		_require(build_state.continue_after_win(), "Expected generated route continue.")
	return build_state.current_route_node


func _start_rogue_adventure_at_final_tavern_reward(build_state, rogue: ClassDef, seed: int) -> void:
	build_state.reset()
	build_state.set_adventure_seed(seed)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_set_basic_rotation(build_state)
	build_state.current_encounter_index = RunFlow.tavern_encounter_count() - 1
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true


func _set_basic_rotation(build_state) -> void:
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected at least one unlocked skill.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)


func _round_trip(build_state) -> void:
	var before := _state_signature(build_state)
	_require(SaveSystemScript.save_run(build_state), "Expected lifecycle save to succeed.")
	build_state.reset(true)
	_require(SaveSystemScript.load_run(build_state), "Expected lifecycle load to succeed.")
	var after := _state_signature(build_state)
	if after != before:
		print("Lifecycle round-trip before:\n%s" % before)
		print("Lifecycle round-trip after:\n%s" % after)
	_require(after == before, "Expected lifecycle state to round-trip.")


func _state_signature(build_state) -> String:
	var parts: PackedStringArray = []
	parts.append("seed:%d" % build_state.adventure_seed)
	parts.append("phase:%d" % build_state.run_phase)
	parts.append("outcome:%d" % build_state.run_outcome)
	parts.append("won:%s" % build_state.last_fight_won)
	parts.append("completed:%d" % build_state.completed_contract_count)
	parts.append("offer_index:%d" % build_state.contract_offer_index)
	parts.append("shop:%s:%d:%d" % [build_state.shop_round_pending, build_state.shop_round_index, build_state.shop_offers.size()])
	parts.append("gold:%d" % build_state.gold)
	parts.append("talent_points:%d" % build_state.earned_talent_points)
	parts.append("active:%s" % _contract_signature(build_state.active_contract))
	parts.append("current:%s" % _route_node_id(build_state.current_route_node))
	parts.append("pending:%s" % _meaningful_pending_offer_signature(build_state))
	parts.append("claimed:%s" % JSON.stringify(build_state.claimed_route_reward_ids))
	return "\n".join(parts)


func _pending_offer_signature(build_state) -> String:
	var parts: PackedStringArray = []
	for offer in build_state.pending_contract_offers:
		parts.append(_contract_signature(offer))
	return "\n".join(parts)


func _meaningful_pending_offer_signature(build_state) -> String:
	if not (build_state.run_phase in [BuildState.RunPhase.CONTRACT_OFFER, BuildState.RunPhase.CONTRACT_ROUTE]):
		return ""
	return _pending_offer_signature(build_state)


func _contract_signature(contract: ContractDef) -> String:
	if contract == null:
		return "none"
	if contract.has_generated_route_state():
		return "generated:%s:%s" % [
			contract.generated_route_id,
			contract.source_seed,
		]
	return "authored:%s" % contract.id


func _route_node_id(node: ContractRouteNode) -> String:
	if node == null:
		return "none"
	return node.generated_node_id if node.generated_node_id != "" else node.id


func _find_route_node(root_node: ContractRouteNode, id: String) -> ContractRouteNode:
	if root_node == null:
		return null
	if root_node.id == id:
		return root_node
	for child in root_node.next_nodes:
		var found := _find_route_node(child, id)
		if found != null:
			return found
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failed = true
	SaveSystemScript.delete_save()
	SaveSystemScript.save_path = SaveSystemScript.SAVE_PATH
