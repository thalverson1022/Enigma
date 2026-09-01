extends SceneTree
## Focused generated boss checklist behavior: boss IDs, defeated-state
## persistence, generated offer filtering, and kill marking.

const SaveSystemScript := preload("res://scripts/systems/save_system.gd")
const ContractOfferSourceScript := preload("res://scripts/systems/contract_offer_source.gd")

var _failed := false


func _initialize() -> void:
	SaveSystemScript.save_path = "res://.test_generated_boss_checklist_save.json"
	SaveSystemScript.delete_save()

	var build_state = root.get_node("BuildState")
	build_state.reset()

	_check_catalog_identity(build_state)
	_check_generated_offers_skip_defeated_bosses(build_state)
	_check_generated_boss_kill_marks_defeated(build_state)
	_check_final_generated_boss_ends_run(build_state)
	_check_defeated_bosses_round_trip(build_state)

	SaveSystemScript.delete_save()
	SaveSystemScript.save_path = SaveSystemScript.SAVE_PATH
	build_state.reset()

	print("")
	if _failed:
		print("Generated boss checklist check: FAILED")
		quit(1)
	else:
		print("Generated boss checklist check: OK")
		quit()


func _check_catalog_identity(build_state) -> void:
	var catalog := ContractOfferSourceScript.generated_boss_catalog()
	var seen := {}
	_require(catalog.size() == 30, "Expected generated boss catalog to list 30 bosses.")
	_require(build_state.generated_bosses_total_count() == 30, "Expected BuildState boss total helper to mirror catalog.")
	for entry in catalog:
		var boss_id := String(entry.get("id", ""))
		_require(boss_id == "%s::%s" % [String(entry.get("biome", "")), String(entry.get("boss_name", ""))], "Expected stable biome/name boss ID.")
		_require(not seen.has(boss_id), "Expected unique boss ID: %s." % boss_id)
		seen[boss_id] = true


func _check_generated_offers_skip_defeated_bosses(build_state) -> void:
	var base_context := ContractOfferSourceScript.offer_context(
		424242,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Swamp"]},
		false,
		true,
		3
	)
	var first_offers := ContractOfferSourceScript.contract_offers(base_context)
	_require(first_offers.size() == 3, "Expected initial generated offer batch.")
	var first_ids := _offer_boss_ids(first_offers)
	_require(first_ids.size() == 3, "Expected offer batch to use unique boss IDs.")

	var filtered_context := base_context.duplicate(true)
	filtered_context["defeated_generated_boss_ids"] = first_ids
	var filtered_offers := ContractOfferSourceScript.contract_offers(filtered_context)
	_require(filtered_offers.size() == 2, "Expected only two Swamp bosses left after defeating three.")
	for boss_id in _offer_boss_ids(filtered_offers):
		_require(not first_ids.has(boss_id), "Expected generated offers to skip defeated boss %s." % boss_id)

	filtered_context["defeated_generated_boss_ids"] = _all_boss_ids_for_biome("Swamp")
	_require(ContractOfferSourceScript.contract_offers(filtered_context).is_empty(), "Expected no generated offers when every allowed boss is defeated.")


func _check_generated_boss_kill_marks_defeated(build_state) -> void:
	_start_generated_contract_offer(build_state)
	_require(build_state.accept_contract_offer(), "Expected generated contract acceptance.")
	var boss := _advance_to_generated_boss(build_state)
	_require(boss != null and boss.node_type == ContractRouteNode.NodeType.BOSS, "Expected generated boss node.")
	var boss_id: String = build_state.generated_boss_id_for_contract(build_state.active_contract)
	_require(boss_id != "", "Expected active generated contract to resolve a boss ID.")
	_require(not build_state.is_generated_boss_defeated(boss_id), "Expected boss to start undefeated.")
	build_state.run_phase = BuildState.RunPhase.FIGHTING
	build_state.finish_fight(true)
	_require(build_state.is_generated_boss_defeated(boss_id), "Expected generated boss win to mark boss defeated.")
	_require(build_state.defeated_generated_boss_count() == 1, "Expected exactly one defeated boss after generated boss win.")
	build_state.mark_generated_boss_defeated(build_state.active_contract)
	_require(build_state.defeated_generated_boss_count() == 1, "Expected duplicate boss marks to be ignored.")


func _check_final_generated_boss_ends_run(build_state) -> void:
	_start_generated_contract_offer(build_state)
	_require(build_state.accept_contract_offer(), "Expected generated contract acceptance for final boss check.")
	var boss := _advance_to_generated_boss(build_state)
	_require(boss != null and boss.node_type == ContractRouteNode.NodeType.BOSS, "Expected generated boss node for final boss check.")
	var final_boss_id: String = build_state.generated_boss_id_for_contract(build_state.active_contract)
	_require(final_boss_id != "", "Expected final boss check to resolve a boss ID.")
	var defeated_before_final: Array[String] = []
	for entry in ContractOfferSourceScript.generated_boss_catalog():
		var boss_id := String(entry.get("id", ""))
		if boss_id != final_boss_id:
			defeated_before_final.append(boss_id)
	build_state.defeated_generated_boss_ids = defeated_before_final
	build_state.run_phase = BuildState.RunPhase.FIGHTING
	build_state.finish_fight(true)
	_require(build_state.is_generated_boss_defeated(final_boss_id), "Expected final boss win to mark the last boss defeated.")
	_require(build_state.all_generated_bosses_defeated(), "Expected all generated bosses to be defeated after the final boss win.")
	_require(not build_state.should_open_shop_after_current_reward(), "Expected final boss reward to skip the between-contract shop.")
	_require(build_state.continue_after_win() == false, "Expected final boss continue to end the generated contract loop.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected final boss completion to end the run.")
	_require(build_state.run_outcome == BuildState.RunOutcome.ALL_BOSSES_DEFEATED, "Expected final boss completion to use the all-bosses victory outcome.")
	_require(build_state.completed_contract_count == 1, "Expected final boss completion to increment completed-contract count.")


func _check_defeated_bosses_round_trip(build_state) -> void:
	build_state.reset()
	var defeated_ids: Array[String] = ["Swamp::Swamp Hydra", "Cave::The Deep Maw", "Swamp::Swamp Hydra"]
	build_state.defeated_generated_boss_ids = defeated_ids
	_require(SaveSystemScript.save_run(build_state), "Expected save with defeated generated bosses.")
	build_state.reset()
	_require(SaveSystemScript.load_run(build_state), "Expected load with defeated generated bosses.")
	_require(build_state.defeated_generated_boss_ids.size() == 2, "Expected defeated generated boss IDs to load uniquely.")
	_require(build_state.is_generated_boss_defeated("Swamp::Swamp Hydra"), "Expected Swamp Hydra defeated state after load.")
	_require(build_state.is_generated_boss_defeated("Cave::The Deep Maw"), "Expected Cave boss defeated state after load.")


func _start_generated_contract_offer(build_state) -> void:
	build_state.reset()
	build_state.set_adventure_seed(424242)
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
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
	_require(build_state.start_contract_offer(context), "Expected generated-only contract offer to start.")
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected active generated contract.")


func _advance_to_generated_boss(build_state) -> ContractRouteNode:
	while (
		build_state.current_route_node != null
		and build_state.current_route_node.node_type != ContractRouteNode.NodeType.BOSS
	):
		var next_nodes: Array[ContractRouteNode] = build_state.current_route_node.next_nodes
		if next_nodes.is_empty():
			return null
		var next_node: ContractRouteNode = next_nodes[next_nodes.size() - 1]
		_require(build_state.choose_contract_route_node(next_node), "Expected generated route node choice toward boss.")
		build_state.run_phase = BuildState.RunPhase.RESULT
		build_state.run_outcome = BuildState.RunOutcome.FIGHT_WIN
		build_state.last_fight_won = true
		if build_state.current_route_node.reward != null:
			_require(build_state.claim_current_reward(), "Expected route reward claim while advancing to boss.")
			if build_state.has_pending_reward_choice():
				_require(build_state.skip_pending_reward_gear(), "Expected pending reward choices to be skippable.")
		if build_state.current_route_node.node_type != ContractRouteNode.NodeType.BOSS:
			_require(build_state.continue_after_win(), "Expected generated route to continue toward boss.")
	return build_state.current_route_node


func _offer_boss_ids(offers: Array[ContractDef]) -> Array[String]:
	var ids: Array[String] = []
	for offer in offers:
		var boss_id: String = ContractOfferSourceScript.boss_id_for_contract(offer)
		if boss_id != "":
			_require(not ids.has(boss_id), "Expected unique boss ID in offer batch: %s." % boss_id)
			ids.append(boss_id)
	return ids


func _all_boss_ids_for_biome(biome: String) -> Array[String]:
	var ids: Array[String] = []
	for entry in ContractOfferSourceScript.generated_boss_catalog():
		if String(entry.get("biome", "")) == biome:
			ids.append(String(entry.get("id", "")))
	return ids


func _set_basic_rotation(build_state) -> void:
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected at least one unlocked skill for generated boss checklist setup.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
