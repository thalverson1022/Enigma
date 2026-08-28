extends SceneTree
## Focused P4M6-T2/T3 check for the contract offer source seam. Run with:
##   godot --headless --path project -s res://tests/contract_offer_source_test.gd

const ContractOfferSourceScript := preload("res://scripts/systems/contract_offer_source.gd")
const ContractRouteGeneratorScript := preload("res://scripts/systems/contract_route_generator/contract_route_generator.gd")


func _initialize() -> void:
	_check_context_is_stable_and_future_ready()
	_check_authored_gilded_serpent_offer_is_preserved()
	_check_generated_offer_is_opt_in_and_deterministic()
	_check_generated_offer_text_is_rogue_voiced_and_preview_safe()
	_check_generated_offer_seed_and_settings_change_route()
	_check_generated_offer_talent_cap_does_not_change_route_identity()
	_check_build_state_starts_offer_through_source()
	_check_build_state_authored_and_generated_offers_coexist()

	print("Contract offer source check: OK")
	quit()


func _check_context_is_stable_and_future_ready() -> void:
	var settings := {"route_difficulty": "medium"}
	var context := ContractOfferSourceScript.offer_context(424242, 1, 2, 777, settings)
	assert(context["source_version"] == ContractOfferSourceScript.SOURCE_VERSION)
	assert(context["adventure_seed"] == 424242)
	assert(context["contract_offer_index"] == 1)
	assert(context["completed_contract_count"] == 2)
	assert(context["debug_seed_override"] == 777)
	assert(context["settings"]["route_difficulty"] == "medium")
	assert(context["include_authored"])
	assert(not context["include_generated"])
	assert(context["generated_offer_count"] == 1)

	settings["route_difficulty"] = "hard"
	assert(context["settings"]["route_difficulty"] == "medium")


func _check_authored_gilded_serpent_offer_is_preserved() -> void:
	var paths := ContractOfferSourceScript.authored_offer_paths()
	assert(Array(paths) == ["res://data/contracts/the_gilded_serpent.tres"])

	var offers := ContractOfferSourceScript.contract_offers(
		ContractOfferSourceScript.offer_context(424242)
	)
	assert(offers.size() == 1)

	var contract: ContractDef = offers[0]
	assert(contract != null)
	assert(contract.resource_path == "res://data/contracts/the_gilded_serpent.tres")
	assert(contract.id == "contract.gilded_serpent")
	assert(contract.display_name == "The Gilded Serpent Contract")
	assert(contract.offer_node != null)
	assert(contract.offer_node.id == "route.gilded_serpent.offer")
	assert(not contract.has_generated_route_state())

	var authored_first := ContractOfferSourceScript.first_contract_offer(
		ContractOfferSourceScript.offer_context(424242, 0, 0, -1, {}, true, true)
	)
	assert(authored_first.id == "contract.gilded_serpent")


func _check_generated_offer_is_opt_in_and_deterministic() -> void:
	var context := ContractOfferSourceScript.offer_context(
		424242,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Graveyard"]},
		false,
		true
	)
	var first_offers := ContractOfferSourceScript.contract_offers(context)
	var second_offers := ContractOfferSourceScript.contract_offers(context)
	assert(first_offers.size() == 1)
	assert(second_offers.size() == 1)

	var first: ContractDef = first_offers[0]
	var second: ContractDef = second_offers[0]
	assert(first.has_generated_route_state())
	assert(first.resource_path == "")
	assert(first.generated_route_id.begins_with("route.generated_"))
	assert(first.source_seed > 0)
	assert(first.generator_version == ContractRouteGeneratorScript.GENERATOR_VERSION)
	assert(first.route_difficulty == "medium")
	assert(first.selected_biome == "Graveyard")
	assert(first.display_name == "Graveyard Contract")
	assert(first.target_display_name != "")
	assert(first.offer_text.contains("Graveyard"))
	assert(first.offer_text.contains(first.target_display_name))
	assert(first.offer_node != null)
	assert(first.offer_node.node_type == ContractRouteNode.NodeType.START)
	assert(not first.offer_node.next_nodes.is_empty())
	assert(
		ContractRouteGeneratorScript.graph_signature(first)
		== ContractRouteGeneratorScript.graph_signature(second)
	)

	var first_fight := _first_combat_node(first.offer_node)
	assert(first_fight != null)
	assert(not first_fight.route_preview.is_empty())
	assert(first_fight.route_preview.has("biome"))
	assert(first_fight.route_preview.has("monster_name"))
	assert(first_fight.route_preview.has("encounter_level"))
	assert(first_fight.route_preview.has("archetype_tags"))
	assert(not first_fight.route_preview.has("source_seed"))
	assert(not first_fight.generated_encounter_payload.is_empty())
	assert(not first_fight.combat_preview.is_empty())
	assert(not first_fight.debug_preview.is_empty())


func _check_generated_offer_text_is_rogue_voiced_and_preview_safe() -> void:
	assert(ContractOfferSourceScript.ROGUE_CONTRACT_TEXT_TEMPLATES.size() == 12)
	var debug_terms := [
		"archetype",
		"source_seed",
		"budget",
		"pressure axis",
		"route_pressure",
		"defense_overrides",
		"armor",
		"block",
		"absorb",
		"poison_resistance",
		"cleanse_threshold",
		"suppress",
		"dodge_chance",
		"crit_negation",
		"stun_duration_ms",
		"interrupt_skip_count",
	]
	var contexts := [
		ContractOfferSourceScript.offer_context(6001, 0, 0, -1, {"route_difficulty": "easy", "allowed_biomes": ["Swamp"]}, false, true),
		ContractOfferSourceScript.offer_context(6002, 0, 0, -1, {"route_difficulty": "medium", "allowed_biomes": ["Cave"]}, false, true),
		ContractOfferSourceScript.offer_context(6003, 0, 0, -1, {"route_difficulty": "hard", "allowed_biomes": ["Graveyard"]}, false, true),
		ContractOfferSourceScript.offer_context(6004, 0, 0, -1, {"route_difficulty": "ultra", "allowed_biomes": ["Ruined Keep"]}, false, true),
		ContractOfferSourceScript.offer_context(6005, 0, 0, -1, {"route_difficulty": "nightmare", "allowed_biomes": ["Haunted Forest"]}, false, true),
	]
	var seen_texts := {}
	for context in contexts:
		var first: ContractDef = ContractOfferSourceScript.first_contract_offer(context)
		var second: ContractDef = ContractOfferSourceScript.first_contract_offer(context)
		assert(first != null)
		assert(second != null)
		assert(first.offer_text == second.offer_text)
		assert(first.offer_text.contains(first.selected_biome))
		assert(first.offer_text.contains(first.target_display_name))
		assert(_has_rogue_voice(first.offer_text))
		var lower_text := first.offer_text.to_lower()
		for term in debug_terms:
			assert(not lower_text.contains(String(term).to_lower()))
		seen_texts[first.offer_text] = true
	assert(seen_texts.size() >= 3)


func _check_generated_offer_seed_and_settings_change_route() -> void:
	var context_a := ContractOfferSourceScript.offer_context(
		111,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Swamp"]},
		false,
		true
	)
	var context_b := ContractOfferSourceScript.offer_context(
		222,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Swamp"]},
		false,
		true
	)
	var context_c := ContractOfferSourceScript.offer_context(
		111,
		0,
		0,
		-1,
		{"route_difficulty": "hard", "allowed_biomes": ["Swamp"]},
		false,
		true
	)
	var contract_a: ContractDef = ContractOfferSourceScript.first_contract_offer(context_a)
	var contract_b: ContractDef = ContractOfferSourceScript.first_contract_offer(context_b)
	var contract_c: ContractDef = ContractOfferSourceScript.first_contract_offer(context_c)
	assert(contract_a != null)
	assert(contract_b != null)
	assert(contract_c != null)
	assert(ContractRouteGeneratorScript.graph_signature(contract_a) != ContractRouteGeneratorScript.graph_signature(contract_b))
	assert(ContractRouteGeneratorScript.graph_signature(contract_a) != ContractRouteGeneratorScript.graph_signature(contract_c))
	assert(contract_a.offer_text != contract_b.offer_text)

	var debug_a := ContractOfferSourceScript.offer_context(
		111,
		0,
		0,
		9090,
		{"route_difficulty": "medium", "allowed_biomes": ["Cave"]},
		false,
		true
	)
	var debug_b := ContractOfferSourceScript.offer_context(
		222,
		0,
		0,
		9090,
		{"route_difficulty": "medium", "allowed_biomes": ["Cave"]},
		false,
		true
	)
	var debug_contract_a: ContractDef = ContractOfferSourceScript.first_contract_offer(debug_a)
	var debug_contract_b: ContractDef = ContractOfferSourceScript.first_contract_offer(debug_b)
	assert(debug_contract_a.source_seed == 9090)
	assert(debug_contract_b.source_seed == 9090)
	assert(
		ContractRouteGeneratorScript.graph_signature(debug_contract_a)
		== ContractRouteGeneratorScript.graph_signature(debug_contract_b)
	)


func _check_generated_offer_talent_cap_does_not_change_route_identity() -> void:
	var base_context := ContractOfferSourceScript.offer_context(
		12345,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Graveyard"]},
		false,
		true
	)
	var capped_context := base_context.duplicate(true)
	capped_context["earned_talent_points"] = ContractRouteGeneratorScript.TALENT_POINT_REWARD_CAP
	var uncapped: ContractDef = ContractOfferSourceScript.first_contract_offer(base_context)
	var capped: ContractDef = ContractOfferSourceScript.first_contract_offer(capped_context)
	assert(uncapped != null)
	assert(capped != null)
	assert(uncapped.source_seed == capped.source_seed)
	assert(uncapped.generated_route_id == capped.generated_route_id)
	assert(uncapped.template_id == capped.template_id)
	assert(uncapped.target_display_name == capped.target_display_name)
	var uncapped_boss := _first_node_of_type(uncapped.offer_node, ContractRouteNode.NodeType.BOSS)
	var capped_boss := _first_node_of_type(capped.offer_node, ContractRouteNode.NodeType.BOSS)
	assert(uncapped_boss.reward.talent_points == 1)
	assert(capped_boss.reward.talent_points == 0)


func _check_build_state_starts_offer_through_source() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	build_state.set_adventure_seed(424242)

	assert(build_state.start_contract_offer())
	assert(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER)
	assert(build_state.active_contract != null)
	assert(build_state.active_contract.id == "contract.gilded_serpent")
	assert(build_state.current_route_node != null)
	assert(build_state.current_route_node.id == "route.gilded_serpent.offer")
	assert(not build_state.active_contract.has_generated_route_state())
	assert(build_state.pending_contract_offers.size() == 1)


func _check_build_state_authored_and_generated_offers_coexist() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	build_state.set_adventure_seed(424242)

	var context := ContractOfferSourceScript.offer_context(
		424242,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Graveyard"]},
		true,
		true
	)
	assert(build_state.start_contract_offer(context))
	assert(build_state.pending_contract_offers.size() == 2)
	assert(build_state.active_contract.id == "contract.gilded_serpent")
	assert(not build_state.active_contract.has_generated_route_state())

	var generated: ContractDef = null
	for offer in build_state.pending_contract_offers:
		if offer.has_generated_route_state():
			generated = offer
			break
	assert(generated != null)
	var generated_key: String = build_state.contract_offer_key(generated)
	assert(generated_key != "")
	assert(build_state.select_pending_contract_offer(generated_key))
	assert(build_state.active_contract == generated)
	assert(build_state.current_route_node == generated.offer_node)
	assert(build_state.active_contract.has_generated_route_state())
	assert(build_state.accept_contract_offer())
	assert(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE)
	assert(build_state.pending_contract_offers.size() == 2)


func _first_combat_node(node: ContractRouteNode, visited: Dictionary = {}) -> ContractRouteNode:
	if node == null or visited.has(node.id):
		return null
	visited[node.id] = true
	if node.node_type in [
		ContractRouteNode.NodeType.FIGHT,
		ContractRouteNode.NodeType.CAPTAIN,
		ContractRouteNode.NodeType.ELITE,
		ContractRouteNode.NodeType.BOSS,
	]:
		return node
	for next_node in node.next_nodes:
		var found := _first_combat_node(next_node, visited)
		if found != null:
			return found
	return null


func _first_node_of_type(node: ContractRouteNode, node_type: int, visited: Dictionary = {}) -> ContractRouteNode:
	if node == null or visited.has(node.id):
		return null
	visited[node.id] = true
	if node.node_type == node_type:
		return node
	for next_node in node.next_nodes:
		var found := _first_node_of_type(next_node, node_type, visited)
		if found != null:
			return found
	return null


func _has_rogue_voice(text: String) -> bool:
	var lower_text := text.to_lower()
	var voice_markers := [
		"gambler",
		"raining knives",
		"tragic",
		"billable",
		"leverage",
		"charming thing",
		"I am listening",
		"tempting",
		"naturally",
		"collecting interest",
		"invoice",
		"get paid",
		"expensive",
		"adorable",
		"professional disagreement",
		"objecting",
		"violence agree",
		"I do enjoy",
		"I prefer",
	]
	for marker in voice_markers:
		if lower_text.contains(String(marker).to_lower()):
			return true
	return false
