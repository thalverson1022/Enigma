extends SceneTree
## Focused P2:R4:T3 check: after the Tavern sequence's final reward, the
## dashboard shows The Gilded Serpent in the map, selecting it opens the
## secondary subclass modal, and picking the second tree reveals the contract
## route choices in the map.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])

	_require(RunFlow.tavern_encounter_count() == 4, "Tavern route should stop after four encounters.")

	build_state.current_encounter_index = RunFlow.tavern_encounter_count() - 1
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	build_state.run_state_changed.emit()

	_require(build_state.current_encounter().monster.display_name == "Hired Goon", "Expected Hired Goon as final Tavern encounter.")
	_require(build_state.claim_current_reward(), "Expected Hired Goon reward claim to succeed.")
	_require(build_state.gold == 36, "Expected Hired Goon to grant 36g before contract offer.")
	_require(build_state.earned_talent_points == 1, "Expected Hired Goon to grant 1 talent point.")

	combat_screen._advance_after_reward_or_shop()
	await process_frame

	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected contract offer phase after Hired Goon.")
	_require(build_state.active_contract != null, "Expected active contract.")
	_require(build_state.active_contract.display_name == "The Gilded Serpent Contract", "Expected Gilded Serpent contract.")
	_require(build_state.current_route_node.id == "route.gilded_serpent.offer", "Expected offer route node.")
	_require(combat_screen._map_overlay.visible, "Expected map overlay to show contract offer.")
	_require(combat_screen._map_phase_label.text == "Contract", "Expected contract map phase.")
	_require(combat_screen._map_story_label.text.contains("Vyra"), "Expected contract story to name Vyra.")
	_require(combat_screen._map_node_buttons.size() == 1, "Expected one contract node.")
	_require(combat_screen._map_node_buttons[0].text == "The Gilded Serpent Contract", "Expected contract node label.")

	combat_screen._map_node_buttons[0].pressed.emit()
	await process_frame

	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected contract route phase after accept.")
	_require(build_state.current_route_node.id == "route.gilded_serpent.secondary_rogue_tree", "Expected secondary-tree route node after accept.")
	_require(combat_screen._secondary_subclass_overlay.visible, "Expected secondary subclass modal after contract select.")
	_require(combat_screen._secondary_subclass_options.get_child_count() == 2, "Expected two available second trees after Thief start.")
	_require(combat_screen._secondary_subclass_options.get_child(1).text.contains("Shadow"), "Expected Shadow second-tree choice.")
	_require(
		combat_screen._secondary_subclass_options.get_child(1).text.contains("Stab & Heavy Slash now apply +1 poison stacks"),
		"Expected Shadow intrinsic in second-tree choice."
	)

	var second_tree_button: Button = combat_screen._secondary_subclass_options.get_child(0)
	_require(second_tree_button.text.contains("Assassin"), "Expected Assassin second-tree choice.")
	second_tree_button.pressed.emit()
	await process_frame

	_require(build_state.selected_trees.size() == 2, "Expected two selected trees.")
	_require(not combat_screen._secondary_subclass_overlay.visible, "Expected subclass modal hidden after choice.")
	_require(combat_screen._map_overlay.visible, "Expected contract route map after second-tree choice.")
	_require(combat_screen._map_node_buttons.size() == 8, "Expected full Gilded Serpent schematic.")
	_require(combat_screen._map_node_buttons[0].text.contains("Door Guard"), "Expected Door Guard route label.")
	_require(combat_screen._map_node_buttons[0].text.contains("Master Gear"), "Expected Door Guard item rarity reward.")
	_require(not combat_screen._map_node_buttons[0].text.contains("Weapon or Ring"), "Expected Door Guard map reward to omit slots.")
	_require(not combat_screen._map_node_buttons[0].disabled, "Expected Door Guard to be selectable.")
	_require(combat_screen._map_node_buttons[0].tooltip_text.contains("Hard Opener"), "Expected Door Guard pressure label.")
	_require(combat_screen._map_node_buttons[1].text.contains("Portly Cook"), "Expected Portly Cook route label.")
	_require(combat_screen._map_node_buttons[1].text.contains("Basic Gear"), "Expected Portly Cook item rarity reward.")
	_require(not combat_screen._map_node_buttons[1].text.contains("Weapon or Necklace"), "Expected Portly Cook map reward to omit slots.")
	_require(not combat_screen._map_node_buttons[1].disabled, "Expected Portly Cook to be selectable.")
	_require(combat_screen._map_node_buttons[1].tooltip_text.contains("Easy Opener"), "Expected Portly Cook pressure label.")
	_require(combat_screen._map_node_buttons[2].text.contains("Sleeping"), "Expected Sleeping Henchman on schematic.")
	_require(combat_screen._map_node_buttons[4].text.contains("Lazy"), "Expected Lazy Henchman on schematic.")
	_require(combat_screen._map_node_buttons[6].text.contains("Knives"), "Expected Knives on schematic.")
	_require(combat_screen._map_node_buttons[7].text.contains("Vyra"), "Expected Vyra on schematic.")
	_require(combat_screen._map_node_buttons[2].disabled, "Expected second-layer nodes locked before opener choice.")

	combat_screen._map_node_buttons[1].pressed.emit()
	await process_frame

	_require(build_state.run_phase == BuildState.RunPhase.PLANNING, "Expected selected route node to enter planning.")
	_require(build_state.current_route_node.id == "route.gilded_serpent.portly_cook", "Expected Portly Cook as current route node.")
	_require(not combat_screen._map_overlay.visible, "Expected route map hidden after route selection.")
	_require(combat_screen._enemy_panel._info_label.text.contains("Target: Portly Cook"), "Expected enemy panel to show selected route target.")
	_require(combat_screen._enemy_panel._info_label.text.contains("Window: 20s"), "Expected enemy panel to show route window.")
	_require(not combat_screen._enemy_panel._info_label.text.contains("Contract:"), "Expected enemy panel to omit contract context.")
	_require(not combat_screen._enemy_panel._info_label.text.contains("Pressure:"), "Expected enemy panel to omit pressure label.")
	_require(not combat_screen._enemy_panel._info_label.text.contains("Reward:"), "Expected enemy panel to omit reward label.")
	_require(combat_screen._enemy_panel._fight_button.disabled, "Expected route fight blocked until build lock.")

	build_state.set_locked(true)
	await process_frame
	_require(not combat_screen._enemy_panel._fight_button.disabled, "Expected selected route fight enabled after build lock.")

	print("Contract offer flow check: OK")
	quit()


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
