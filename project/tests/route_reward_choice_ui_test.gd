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
	for choice in build_state.pending_reward_choices:
		_require(portly_cook.reward.generated_gear_slots.has(choice.slot), "Expected generated reward slot to come from Portly Cook's slot pool.")
	_require(_unique_stat_signature_count(build_state.pending_reward_choices) == build_state.pending_reward_choices.size(), "Expected generated rewards not to duplicate the same stat package.")
	_require(combat_screen._reward_choice_overlay.options_container().get_child_count() == 2, "Expected two generated reward buttons.")

	var generated_choice_button: Button = combat_screen._reward_choice_overlay.options_container().get_child(0)
	_require(generated_choice_button.tooltip_text.contains("Basic"), "Expected Basic generated reward tooltip.")
	var generated_choice: GearItem = build_state.pending_reward_choices[0]
	var fill_rng := RandomNumberGenerator.new()
	fill_rng.seed = 570
	while build_state.inventory.size() < build_state.INVENTORY_CAPACITY:
		_require(build_state.add_inventory_item(GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.CHARM, fill_rng)), "Expected inventory filler item.")
	generated_choice_button.pressed.emit()
	await process_frame
	_require(combat_screen._reward_choice_overlay.visible, "Expected generated reward overlay to stay visible when inventory is full.")
	_require(build_state.equipped_weapon == null, "Expected generated reward not to auto-equip when inventory is full.")
	_require(build_state.has_pending_reward_choice(), "Expected generated reward choices to remain pending after a full-inventory block.")
	_require(build_state.run_phase == BuildState.RunPhase.RESULT, "Expected route reward result phase to remain pending after a full-inventory block.")
	_require(not combat_screen._map_overlay.visible, "Expected route map to stay hidden after a blocked reward choice.")
	_require(combat_screen._last_inventory_blocked_source == generated_choice_button, "Expected blocked reward choice to record the pulsed button.")
	_require(generated_choice_button.get_meta("inventory_blocked_pulse") == true, "Expected blocked reward choice to pulse like a protected talent.")
	_require(combat_screen._reward_choice_overlay._status_label.text.contains("Inventory full"), "Expected reward overlay status to explain the full inventory block.")

	build_state.inventory.clear()
	combat_screen._reward_choice_overlay._skip_button.pressed.emit()
	await process_frame
	_require(not combat_screen._reward_choice_overlay.visible, "Expected generated reward overlay hidden after skipping gear reward.")
	_require(not build_state.has_pending_reward_choice(), "Expected pending reward choices cleared after skipping.")
	_require(not build_state.has_inventory_item(generated_choice), "Expected skipped generated reward not to enter inventory.")
	_require(build_state.equipped_weapon == null, "Expected skipped generated reward not to equip.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected route choice phase after skipping generated reward.")
	_require(combat_screen._map_overlay.visible, "Expected route map after skipping generated reward.")

	var regenerated_choices: Array[GearItem] = [generated_choice]
	build_state.pending_reward_choices = regenerated_choices
	build_state.current_route_node = portly_cook
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	build_state.run_state_changed.emit()
	combat_screen._show_reward_choice_overlay()
	await process_frame
	generated_choice_button = combat_screen._reward_choice_overlay.options_container().get_child(0)

	build_state.inventory.clear()
	generated_choice_button.pressed.emit()
	await process_frame
	await process_frame
	_require(not combat_screen._reward_choice_overlay.visible, "Expected generated reward overlay hidden after choice once space exists.")
	_require(build_state.has_inventory_item(generated_choice), "Expected generated reward to land in inventory once space exists.")
	_require(not build_state.has_pending_reward_choice(), "Expected pending choices cleared after choosing reward.")
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
	_require(combat_screen._reward_choice_overlay.options_container().get_child_count() == 2, "Expected two Legendary reward buttons.")
	var first_button: Button = combat_screen._reward_choice_overlay.options_container().get_child(0)
	var second_button: Button = combat_screen._reward_choice_overlay.options_container().get_child(1)
	var first_choice: GearItem = build_state.pending_reward_choices[0]
	var second_choice: GearItem = build_state.pending_reward_choices[1]
	_require(first_button.tooltip_text.contains(first_choice.display_name), "Expected first choice's own name in its tooltip.")
	_require(second_button.tooltip_text.contains(second_choice.display_name), "Expected second choice's own name in its tooltip.")
	for i in build_state.pending_reward_choices.size():
		var choice: GearItem = build_state.pending_reward_choices[i]
		var button: Button = combat_screen._reward_choice_overlay.options_container().get_child(i)
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
	_require(combat_screen._map_overlay._map_node_buttons.size() == 8, "Expected full route schematic after Legendary reward.")
	var vyra_button := _find_map_node_button(combat_screen._map_overlay, "route.gilded_serpent.vyra", "Vyra")
	_require(vyra_button != null, "Expected Vyra node after Knives.")
	if vyra_button == null:
		return
	_require(not vyra_button.disabled, "Expected Vyra selectable after Knives.")
	_require(combat_screen._map_overlay._map_proceed_button.text == "Proceed", "Expected late-route commit button to use the shared Proceed action.")
	_require(combat_screen._map_overlay._map_proceed_button.disabled, "Expected Proceed disabled before selecting Vyra.")
	_require(combat_screen._map_overlay._map_story_label.text == "The silk pajamas are a nice touch.", "Expected authored pre-selection Vyra story text.")
	combat_screen._map_overlay._on_map_proceed_pressed()
	await process_frame
	_require(combat_screen._map_overlay._map_proceed_button.get_meta("feedback_blocked_pulse") == true, "Expected disabled route Proceed to pulse when activated without a route selection.")
	vyra_button.pressed.emit()
	await process_frame
	_require(not combat_screen._map_overlay._map_proceed_button.disabled, "Expected Proceed enabled after selecting Vyra.")
	var selected_vyra_story: String = combat_screen._map_overlay._map_story_label.text.replace("\r\n", "\n")
	_require(
		selected_vyra_story == "Selected Route: Vyra\nTime to get paid.",
		"Expected selected Vyra story text to use authored flavor, got: %s" % selected_vyra_story
	)
	_require(combat_screen._map_overlay._map_proceed_button.tooltip_text == "Proceed to Vyra as your next fight.", "Expected selected Vyra tooltip to name the committed fight.")

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


func _find_map_node_button(map_overlay: Control, route_node_id: String, text: String) -> Button:
	for button in map_overlay._map_node_buttons:
		if not button is Button:
			continue
		var map_button := button as Button
		if String(map_button.get_meta("route_node_id", "")) == route_node_id:
			return map_button
		if map_button.text.contains(text):
			return map_button
		if _control_text_contains(map_button, text):
			return map_button
	return null


func _control_text_contains(control: Control, text: String) -> bool:
	for child in control.get_children():
		if child is Label and (child as Label).text.contains(text):
			return true
		if child is RichTextLabel and (child as RichTextLabel).text.contains(text):
			return true
		if child is Control and _control_text_contains(child, text):
			return true
	return false


func _unique_stat_signature_count(items: Array[GearItem]) -> int:
	var seen := {}
	for item in items:
		seen[_stat_signature(item)] = true
	return seen.size()


func _stat_signature(item: GearItem) -> String:
	var affix_parts: PackedStringArray = []
	for affix in item.affixes:
		affix_parts.append("%03d:%03d:%0.4f" % [affix.stat, affix.operation, affix.value])
	affix_parts.sort()
	return "%d|%s" % [item.tier, ",".join(affix_parts)]


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
