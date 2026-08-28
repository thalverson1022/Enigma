extends SceneTree
## Focused P4M6-T5 check: generated route nodes can be committed from the
## Adventure route flow before generated combat conversion exists.

const ContractOfferSourceScript := preload("res://scripts/systems/contract_offer_source.gd")


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	build_state.set_adventure_seed(424242)

	_check_generated_offer_acceptance_stays_at_start(build_state)
	_check_generated_route_node_can_commit(build_state)
	_check_invalid_generated_and_authored_nodes_are_rejected(build_state)
	await _check_map_selectability_uses_generated_commit_rules(build_state)

	print("Generated route commit flow check: OK")
	quit()


func _check_generated_offer_acceptance_stays_at_start(build_state) -> void:
	_start_generated_contract_offer(build_state)
	_require(build_state.accept_contract_offer(), "Expected generated offer acceptance to succeed.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected accepted generated offer to enter route flow.")
	_require(not build_state.pending_contract_offers.is_empty(), "Expected generated offers to remain pending after route preview selection.")
	_require(build_state.current_route_node != null, "Expected current generated route node.")
	_require(build_state.current_route_node.node_type == ContractRouteNode.NodeType.START, "Expected generated route flow to stay at the generated start node.")
	_require(not build_state.current_route_node.next_nodes.is_empty(), "Expected generated start node to expose route choices.")
	_require(build_state.can_return_to_contract_offer(), "Expected generated route preview to allow returning to contract offers before route commit.")


func _check_generated_route_node_can_commit(build_state) -> void:
	var first_choice: ContractRouteNode = build_state.current_route_node.next_nodes[0]
	_require(first_choice.monster == null, "Expected generated route choice to be unconverted before commit.")
	_require(not first_choice.generated_encounter_payload.is_empty(), "Expected generated route choice to carry generated encounter payload.")
	_require(build_state.can_commit_contract_route_node(first_choice), "Expected generated route choice to be commit-eligible.")
	_require(build_state.choose_contract_route_node(first_choice), "Expected generated route choice commit to succeed.")
	_require(build_state.run_phase == BuildState.RunPhase.PLANNING, "Expected committed generated route node to enter planning.")
	_require(build_state.current_route_node == first_choice, "Expected committed generated route node to become current.")
	_require(not build_state.pending_contract_offers.is_empty(), "Expected generated offers to remain pending until first combat starts.")
	_require(not build_state.can_return_to_contract_offer(), "Expected accepted generated contract to stay final after route commit.")
	_require(first_choice.monster != null, "Expected generated route choice to become combat-ready on commit.")
	_require(first_choice.duration_ms > 0, "Expected generated route choice to receive combat duration on commit.")


func _check_invalid_generated_and_authored_nodes_are_rejected(build_state) -> void:
	_start_generated_contract_offer(build_state)
	_require(build_state.accept_contract_offer(), "Expected generated offer acceptance for invalid-node checks.")
	var invalid_generated := ContractRouteNode.new()
	invalid_generated.id = "route.generated.invalid_empty_payload"
	invalid_generated.node_type = ContractRouteNode.NodeType.FIGHT
	invalid_generated.route_preview = {
		"biome": "Bog",
		"monster_name": "Hollow Decoy",
	}
	build_state.current_route_node.next_nodes.append(invalid_generated)
	_require(not build_state.can_commit_contract_route_node(invalid_generated), "Expected generated node without payload to be rejected.")
	_require(not build_state.choose_contract_route_node(invalid_generated), "Expected generated node without payload commit to fail.")

	build_state.reset()
	build_state.set_adventure_seed(424242)
	_require(build_state.start_contract_offer(), "Expected authored offer to start.")
	_require(build_state.accept_contract_offer(), "Expected authored offer to accept.")
	var invalid_authored := ContractRouteNode.new()
	invalid_authored.id = "route.authored.invalid_no_monster"
	invalid_authored.node_type = ContractRouteNode.NodeType.FIGHT
	invalid_authored.duration_ms = 20000
	build_state.current_route_node.next_nodes.append(invalid_authored)
	_require(not build_state.can_commit_contract_route_node(invalid_authored), "Expected authored node without monster to be rejected.")
	_require(not build_state.choose_contract_route_node(invalid_authored), "Expected authored node without monster commit to fail.")


func _check_map_selectability_uses_generated_commit_rules(build_state) -> void:
	_start_generated_contract_offer(build_state)
	_require(build_state.accept_contract_offer(), "Expected generated offer acceptance for map selectability.")
	var first_choice: ContractRouteNode = build_state.current_route_node.next_nodes[0]

	var map_scene: PackedScene = load("res://scenes/combat/map_overlay.tscn")
	var map_overlay = map_scene.instantiate()
	root.add_child(map_overlay)
	await process_frame

	_require(map_overlay._route_node_is_selectable(first_choice), "Expected map to treat generated route choice as selectable.")
	var text: String = map_overlay._route_node_button_text(first_choice)
	_require(text.contains(String(first_choice.route_preview.get("monster_name", ""))), "Expected map text to show generated monster preview.")
	_require(not text.contains("HP"), "Expected generated map text to stay sparse.")
	_require(not text.contains("Armor"), "Expected generated map text to hide combat internals.")
	map_overlay.queue_free()


func _start_generated_contract_offer(build_state) -> void:
	build_state.reset()
	build_state.set_adventure_seed(424242)
	var context := ContractOfferSourceScript.offer_context(
		424242,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Graveyard"]},
		false,
		true
	)
	_require(build_state.start_contract_offer(context), "Expected generated-only contract offer to start.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected active generated contract.")


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
