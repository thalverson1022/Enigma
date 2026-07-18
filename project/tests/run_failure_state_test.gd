extends SceneTree
## Focused P2:R5:T6 check for Adventure failure tracking and outcomes.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")

	build_state.set_adventure_seed(8675309)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()

	print("first Tavern loss should grant one do-over")
	build_state.start_fight()
	build_state.finish_fight(false)
	_require(build_state.run_phase == BuildState.RunPhase.RESULT, "Expected first loss to stay in result phase.")
	_require(build_state.run_outcome == BuildState.RunOutcome.FIGHT_LOSS_RETRY, "Expected retry outcome after first loss.")
	_require(build_state.failure_count_for_current_encounter() == 1, "Expected first failure count.")
	_require(build_state.can_retry_current_encounter(), "Expected retry availability after first loss.")
	_require(build_state.retry_current_encounter(), "Expected retry to return to planning.")
	_require(build_state.run_phase == BuildState.RunPhase.PLANNING, "Expected retry to return to planning.")
	_require(build_state.run_outcome == BuildState.RunOutcome.NONE, "Expected retry to clear outcome.")
	_require(build_state.current_encounter_index == 0, "Expected retry to keep the same Tavern encounter.")
	_require(build_state.adventure_seed == 8675309, "Expected retry to preserve seed.")

	print("second Tavern loss should require Adventure restart")
	build_state.choose_current_tavern_encounter()
	build_state.set_locked(true)
	build_state.start_fight()
	build_state.finish_fight(false)
	_require(build_state.failure_count_for_current_encounter() == 2, "Expected second failure count.")
	_require(not build_state.can_retry_current_encounter(), "Expected no retry after second loss.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected second loss to end the current Adventure.")
	_require(
		build_state.run_outcome == BuildState.RunOutcome.ADVENTURE_RESTART_REQUIRED,
		"Expected Adventure restart outcome after second Tavern loss."
	)
	_require(not build_state.build_locked, "Expected terminal loss to clear build lock.")

	print("seed-preserving Adventure restart should clear run progress")
	build_state.reset(true)
	_require(build_state.adventure_seed == 8675309, "Expected preserved seed after restart.")
	_require(build_state.selected_class == null, "Expected class selection to reset.")
	_require(build_state.current_encounter_index == 0, "Expected encounter progress to reset.")
	_require(build_state.encounter_failure_counts.is_empty(), "Expected failure counts to reset.")
	_require(build_state.run_outcome == BuildState.RunOutcome.NONE, "Expected outcome to reset.")

	print("contract route loss should mark the contract failed")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_require(build_state.start_contract_offer(), "Expected contract offer to start.")
	_require(build_state.accept_contract_offer(), "Expected contract offer accept to work.")
	_require(build_state.choose_secondary_tree(rogue.trees[0]), "Expected secondary tree choice to work.")
	var opener: ContractRouteNode = build_state.current_route_node.next_nodes[1]
	_require(opener.id == "route.gilded_serpent.portly_cook", "Expected Portly Cook route opener.")
	_require(build_state.choose_contract_route_node(opener), "Expected route node choice to enter planning.")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected contract fight to start.")
	build_state.finish_fight(false)
	_require(build_state.failure_count_for_current_encounter() == 1, "Expected contract failure count.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected contract failure to end the run.")
	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_FAILED, "Expected contract failed outcome.")
	_require(not build_state.can_retry_current_encounter(), "Expected no contract do-over.")
	_require(build_state.active_contract != null, "Expected failed contract context to remain visible.")
	_require(build_state.current_route_node == opener, "Expected failed route node context to remain visible.")

	print("contract boss win should mark contract victory")
	build_state.reset(true)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_require(build_state.start_contract_offer(), "Expected contract offer to start for victory check.")
	_require(build_state.accept_contract_offer(), "Expected contract offer accept for victory check.")
	build_state.current_route_node = _find_route_node(build_state.active_contract.offer_node, "route.gilded_serpent.vyra")
	_require(build_state.current_route_node != null, "Expected Vyra route node.")
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	_require(build_state.continue_after_win() == false, "Expected final contract node to have no next route.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected Vyra win to end the run.")
	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_VICTORY, "Expected contract victory outcome.")

	print("")
	print("Run failure state check: OK")
	quit()


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
	quit(1)
