extends SceneTree
## Focused P2:R4:T7 UI check for generated route rewards and Knives'
## Legendary choice panel.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var contract: ContractDef = load("res://data/contracts/the_gilded_serpent.tres")
	var portly_cook := _find_route_node(contract.offer_node, "route.gilded_serpent.portly_cook")
	var knives := _find_route_node(contract.offer_node, "route.gilded_serpent.knives")
	_require(rogue != null, "Expected Rogue class data.")
	_require(contract != null, "Expected Gilded Serpent contract data.")
	_require(portly_cook != null, "Expected Portly Cook route node.")
	_require(knives != null, "Expected Knives route node.")

	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.active_contract = contract
	build_state.current_route_node = portly_cook
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	build_state.run_state_changed.emit()

	combat_screen._on_continue_pressed()
	await process_frame
	_require(combat_screen._reward_choice_overlay.visible, "Expected generated reward choice overlay.")
	_require(build_state.has_pending_reward_choice(), "Expected generated reward choices pending.")
	_require(build_state.pending_reward_choices.size() == 2, "Expected two generated reward choices.")
	_require(build_state.pending_reward_choices[0].slot == GearItem.SlotType.WEAPON, "Expected first generated reward to be weapon.")
	_require(build_state.pending_reward_choices[1].slot == GearItem.SlotType.CHARM, "Expected second generated reward to be charm.")
	_require(combat_screen._reward_choice_options.get_child_count() == 2, "Expected two generated reward buttons.")

	var generated_choice_button: Button = combat_screen._reward_choice_options.get_child(0)
	_require(generated_choice_button.tooltip_text.contains("Basic"), "Expected Basic generated reward tooltip.")
	var fill_rng := RandomNumberGenerator.new()
	fill_rng.seed = 570
	while build_state.inventory.size() < build_state.INVENTORY_CAPACITY:
		_require(build_state.add_inventory_item(GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.CHARM, fill_rng)), "Expected inventory filler item.")
	generated_choice_button.pressed.emit()
	await process_frame
	_require(not combat_screen._reward_choice_overlay.visible, "Expected generated reward overlay hidden after choice.")
	_require(build_state.equipped_weapon != null, "Expected generated reward to auto-equip when inventory is full.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected route choice phase after generated reward.")
	_require(combat_screen._map_overlay.visible, "Expected route map after generated reward.")

	build_state.pending_reward_choices.clear()
	build_state.inventory.clear()
	build_state.equipped_weapon = null
	build_state.claimed_route_reward_ids.clear()
	build_state.current_route_node = knives
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	build_state.run_state_changed.emit()

	combat_screen._on_continue_pressed()
	await process_frame
	_require(combat_screen._reward_choice_overlay.visible, "Expected Legendary reward choice overlay.")
	# P2:R9:T5 -- Knives now offers a seeded random choice of 2 of 5
	# Legendaries instead of a fixed Wyvern Kriss/Mithril Karambit pair, so
	# this no longer asserts which 2 specifically -- only that the choice
	# is well-formed (2 distinct Legendary items, each tooltip naming
	# itself) and that choosing one equips exactly that one.
	_require(build_state.pending_reward_choices.size() == 2, "Expected two Legendary choices.")
	_require(
		build_state.pending_reward_choices[0].id != build_state.pending_reward_choices[1].id,
		"Expected two distinct Legendary choices."
	)
	_require(
		build_state.pending_reward_choices.all(func(gear): return gear.tier == GearItem.Tier.LEGENDARY),
		"Expected both Legendary choices to be Legendary tier."
	)
	_require(combat_screen._reward_choice_options.get_child_count() == 2, "Expected two Legendary reward buttons.")
	var first_button: Button = combat_screen._reward_choice_options.get_child(0)
	var second_button: Button = combat_screen._reward_choice_options.get_child(1)
	var first_choice: GearItem = build_state.pending_reward_choices[0]
	var second_choice: GearItem = build_state.pending_reward_choices[1]
	_require(first_button.tooltip_text.contains(first_choice.display_name), "Expected first choice's own name in its tooltip.")
	_require(second_button.tooltip_text.contains(second_choice.display_name), "Expected second choice's own name in its tooltip.")
	for i in build_state.pending_reward_choices.size():
		var choice: GearItem = build_state.pending_reward_choices[i]
		var button: Button = combat_screen._reward_choice_options.get_child(i)
		var expected_effect := LegendaryCatalog.effect_text(choice)
		_require(expected_effect != "", "Expected a Legendary flavor line for %s." % choice.display_name)
		_require(button.tooltip_text.contains(expected_effect), "Expected %s reward tooltip to include '%s', got: %s" % [choice.display_name, expected_effect, button.tooltip_text])

	var bandit_blade: GearItem = load("res://data/gear/bandit_blade.tres")
	var bandit_text: String = combat_screen._reward_choice_text(bandit_blade)
	_require(bandit_text.contains("+1 physical damage per 10 gold in stash"), "Expected Bandit Blade reward tooltip to include its Legendary flavor text, got: %s" % bandit_text)

	first_button.pressed.emit()
	await process_frame
	_require(not combat_screen._reward_choice_overlay.visible, "Expected Legendary reward overlay hidden after choice.")
	_require(build_state.equipped_weapon != null, "Expected Legendary weapon equipped.")
	_require(build_state.equipped_weapon.id == first_choice.id, "Expected the chosen Legendary to be equipped.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected route choice phase after Legendary reward.")
	_require(combat_screen._map_overlay.visible, "Expected route map after Legendary reward.")
	_require(combat_screen._map_node_buttons.size() == 8, "Expected full route schematic after Legendary reward.")
	_require(not combat_screen._map_node_buttons[7].disabled, "Expected Vyra selectable after Knives.")
	_require(combat_screen._map_node_buttons[7].text.contains("Vyra"), "Expected Vyra node after Knives.")

	print("Route reward choice UI check: OK")
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


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
