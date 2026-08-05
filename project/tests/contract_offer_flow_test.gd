extends SceneTree
## Focused P2:R4:T3 check (updated for the P2:R7 story pass): after the
## Tavern sequence's final reward, Ghit Gudd's Contract Window introduces
## The Gilded Serpent contract (no shop in between), accepting it opens the
## Contract Window hub (Vyra), accepting Vyra reveals the contract route map,
## and the second-tree choice remains available from Talent Trees during the
## following build phase instead of interrupting the contract-selection flow.



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
	_set_basic_rotation(build_state)

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
	_require(not combat_screen._shop_overlay.visible, "Expected the shop to be skipped after Hired Goon (P2:R7 story pass).")
	_require(combat_screen._contract_overlay.visible, "Expected Ghit Gudd's Contract Window to introduce the contract.")
	_require(combat_screen._contract_overlay._contract_body_label.text == combat_screen._contract_overlay.CONTRACT_GREETING_TEXT, "Expected Ghit Gudd's greeting line.")
	_require(combat_screen._contract_overlay._contract_action_button.text == "Hear Him Out", "Expected the greeting's action button.")

	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame
	_require(combat_screen._contract_overlay._contract_body_label.text == combat_screen._contract_overlay.CONTRACT_PITCH_TEXT, "Expected Ghit Gudd's pitch line.")
	_require(combat_screen._contract_overlay._contract_action_button.text == "Accept Contract Work", "Expected the pitch's action button.")

	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame

	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected contract route phase after accept.")
	_require(build_state.current_route_node.id == "route.gilded_serpent.secondary_rogue_tree", "Expected secondary-tree route node after accept.")
	_require(combat_screen._contract_overlay.visible, "Expected the Contract Window to stay in the contract-choice flow.")
	_require(not combat_screen._secondary_subclass_overlay.visible, "Expected no separate secondary subclass modal.")

	# -- Contract Window becomes a hub with a single contract card for now
	# (Vyra) -- a larger toggleable rectangle naming the contract and its
	# gold reward, not a plain button. Selecting it only enables Proceed;
	# Proceed then previews her, and her own Accept reveals the interactive
	# route schematic without forcing the second-tree build choice. --
	_require(combat_screen._contract_overlay._contract_options_box.get_child_count() == 1, "Expected one contract option (Vyra).")
	_require(combat_screen._contract_overlay._contract_options_box.alignment == BoxContainer.ALIGNMENT_BEGIN, "Expected contract options to stack from the top like a list.")
	_require(combat_screen._contract_overlay._contract_options_box.position.y < 160.0, "Expected the contract list to start near the top of the Contract Window.")
	var vyra_button: Button = combat_screen._contract_overlay._contract_options_box.get_child(0)
	_require(vyra_button.text.contains(combat_screen._contract_overlay.CONTRACT_VYRA_NAME), "Expected Vyra's contract card label.")
	_require(vyra_button.text.contains("Reward: 120g"), "Expected Vyra's authored gold reward on her contract card.")
	_require(combat_screen._contract_overlay._contract_action_button.disabled, "Expected Proceed disabled before a contract is selected.")
	_require(vyra_button.find_child("ContractChoicePulse", true, false) != null, "Expected available contract card to pulse.")
	vyra_button.pressed.emit()
	await process_frame
	vyra_button = combat_screen._contract_overlay._contract_options_box.get_child(0)
	_require(not combat_screen._contract_overlay._contract_action_button.disabled, "Expected Proceed enabled after selecting Vyra's card.")
	_require(vyra_button.find_child("ContractChoicePulse", true, false) == null, "Expected selected contract card to stop pulsing.")
	var vyra_selected_style: StyleBoxFlat = vyra_button.get_theme_stylebox("normal")
	_require(vyra_selected_style.border_color == CardStyle.ACCENT_COLOR, "Expected selected contract card to use active styling.")
	vyra_button.pressed.emit()
	await process_frame
	vyra_button = combat_screen._contract_overlay._contract_options_box.get_child(0)
	_require(combat_screen._contract_overlay._contract_action_button.disabled, "Expected clicking selected Vyra again to deselect it.")
	_require(vyra_button.find_child("ContractChoicePulse", true, false) != null, "Expected deselected contract card to pulse again.")
	vyra_button.pressed.emit()
	await process_frame
	vyra_button = combat_screen._contract_overlay._contract_options_box.get_child(0)
	_require(not combat_screen._contract_overlay._contract_action_button.disabled, "Expected Proceed enabled after reselecting Vyra.")
	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame
	_require(combat_screen._contract_overlay._contract_body_label.text == combat_screen._contract_overlay.CONTRACT_VYRA_DETAIL_TEXT, "Expected Vyra's contract detail text.")
	_require(combat_screen._contract_overlay._contract_action_button.text == "Accept", "Expected the Vyra detail's Accept button.")
	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame

	_require(not combat_screen._contract_overlay.visible, "Expected the Contract Window hidden once the route map takes over.")
	_require(not combat_screen._talent_overlay.visible, "Expected Talent Trees not to auto-open during contract selection.")
	_require(combat_screen._map_overlay.visible, "Expected contract route map after accepting Vyra's contract.")
	_require(combat_screen._map_overlay._map_node_buttons.size() == 8, "Expected full Gilded Serpent schematic.")
	_require(combat_screen._map_overlay._map_node_buttons[0].text.contains("Door Guard"), "Expected Door Guard route label.")
	_require(combat_screen._map_overlay._map_node_buttons[0].text.contains("Master Gear"), "Expected Door Guard item rarity reward.")
	_require(not combat_screen._map_overlay._map_node_buttons[0].text.contains("Weapon or Ring"), "Expected Door Guard map reward to omit slots.")
	_require(not combat_screen._map_overlay._map_node_buttons[0].disabled, "Expected Door Guard to be selectable.")
	_require(combat_screen._map_overlay._map_node_buttons[0].find_child("ContractAvailablePulse", true, false) != null, "Expected Door Guard to pulse as an available route.")
	_require(combat_screen._map_overlay._map_node_buttons[0].tooltip_text.contains("Hard Opener"), "Expected Door Guard pressure label.")
	_require(combat_screen._map_overlay._map_node_buttons[1].text.contains("Portly Cook"), "Expected Portly Cook route label.")
	_require(combat_screen._map_overlay._map_node_buttons[1].text.contains("Basic Gear"), "Expected Portly Cook item rarity reward.")
	_require(not combat_screen._map_overlay._map_node_buttons[1].text.contains("Weapon or Necklace"), "Expected Portly Cook map reward to omit slots.")
	_require(not combat_screen._map_overlay._map_node_buttons[1].disabled, "Expected Portly Cook to be selectable.")
	_require(combat_screen._map_overlay._map_node_buttons[1].find_child("ContractAvailablePulse", true, false) != null, "Expected Portly Cook to pulse as an available route.")
	_require(combat_screen._map_overlay._map_node_buttons[1].tooltip_text.contains("Easy Opener"), "Expected Portly Cook pressure label.")
	_require(combat_screen._map_overlay._map_node_buttons[2].text.contains("Sleeping"), "Expected Sleeping Henchman on schematic.")
	_require(combat_screen._map_overlay._map_node_buttons[4].text.contains("Lazy"), "Expected Lazy Henchman on schematic.")
	_require(combat_screen._map_overlay._map_node_buttons[6].text.contains("Knives"), "Expected Knives on schematic.")
	_require(combat_screen._map_overlay._map_node_buttons[7].text.contains("Vyra"), "Expected Vyra on schematic.")
	_require(combat_screen._map_overlay._map_node_buttons[2].disabled, "Expected second-layer nodes locked before opener choice.")
	_require(combat_screen._map_overlay._map_proceed_button.visible, "Expected route-map Proceed button.")
	_require(combat_screen._map_overlay._map_proceed_button.text == "Mark Route", "Expected route-map commit button to explain that it marks the selected route.")
	_require(combat_screen._map_overlay._map_proceed_button.disabled, "Expected Proceed disabled before a route is selected.")
	_require(combat_screen._map_overlay._map_proceed_button.tooltip_text == "Select a route first.", "Expected route-map disabled tooltip to explain the missing selection.")

	combat_screen._map_overlay._map_node_buttons[0].pressed.emit()
	await process_frame
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected clicking Door Guard to select only, not commit.")
	_require(build_state.current_route_node.id == "route.gilded_serpent.secondary_rogue_tree", "Expected current route to remain at the route-choice hub before Proceed.")
	_require(not combat_screen._map_overlay._map_proceed_button.disabled, "Expected Proceed enabled after selecting Door Guard.")
	_require(combat_screen._map_overlay._map_story_label.text == "Selected route: Door Guard. Mark it to tune your build, lock in, and fight.", "Expected selected route story text to explain the next step.")
	_require(combat_screen._map_overlay._map_proceed_button.tooltip_text == "Mark Door Guard as your next fight.", "Expected selected route tooltip to name the fight being committed.")
	_require(combat_screen._map_overlay._map_node_buttons[0].find_child("ContractAvailablePulse", true, false) == null, "Expected selected Door Guard to stop pulsing.")
	var door_selected_style: StyleBoxFlat = combat_screen._map_overlay._map_node_buttons[0].get_theme_stylebox("normal")
	_require(door_selected_style.border_color == CardStyle.ACCENT_COLOR, "Expected selected Door Guard to use selected styling.")

	combat_screen._map_overlay._map_node_buttons[0].pressed.emit()
	await process_frame
	_require(combat_screen._map_overlay._map_proceed_button.disabled, "Expected clicking the selected route again to deselect it.")
	_require(combat_screen._map_overlay._map_node_buttons[0].find_child("ContractAvailablePulse", true, false) != null, "Expected deselected Door Guard to pulse again.")

	combat_screen._map_overlay._map_node_buttons[0].pressed.emit()
	await process_frame
	combat_screen._map_overlay._map_node_buttons[1].pressed.emit()
	await process_frame
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected switching to Portly Cook to select only, not commit.")
	_require(build_state.current_route_node.id == "route.gilded_serpent.secondary_rogue_tree", "Expected current route to remain at the hub after switching pending selection.")
	_require(not combat_screen._map_overlay._map_proceed_button.disabled, "Expected Proceed enabled after switching to Portly Cook.")
	_require(combat_screen._map_overlay._map_node_buttons[0].find_child("ContractAvailablePulse", true, false) != null, "Expected unselected Door Guard to pulse again after switching.")
	_require(combat_screen._map_overlay._map_node_buttons[1].find_child("ContractAvailablePulse", true, false) == null, "Expected selected Portly Cook to stop pulsing.")

	combat_screen._map_overlay._map_proceed_button.pressed.emit()
	await process_frame

	_require(build_state.run_phase == BuildState.RunPhase.PLANNING, "Expected selected route node to enter planning.")
	_require(build_state.current_route_node.id == "route.gilded_serpent.portly_cook", "Expected Portly Cook as current route node.")
	_require(not combat_screen._map_overlay.visible, "Expected route map hidden after route selection.")
	_require(build_state.needs_secondary_subclass_choice(), "Expected second-tree choice to remain available during contract build planning.")
	_require(combat_screen._enemy_panel._title_label.text == "Portly Cook", "Expected enemy panel title to show selected route target.")
	_require(not combat_screen._enemy_panel._info_label.text.contains("Target:"), "Expected enemy panel body to omit redundant target label.")
	_require(combat_screen._enemy_panel._info_label.text.contains("Fight Window: 20s"), "Expected enemy panel to show route window.")
	_require(not combat_screen._enemy_panel._info_label.text.contains("Contract:"), "Expected enemy panel to omit contract context.")
	# P2:R7:T5 (already shipped, predates this test's last update) added
	# always-visible damage goal/Reward/Pressure lines to every enemy panel
	# state, including route targets -- these were stale assertions against
	# the pre-T5 panel; updated to match Portly Cook's real authored data,
	# same values combat_screen_test.gd's Portly Cook check already asserts.
	_require(combat_screen._enemy_panel._info_label.text.contains("Pressure: No notable defensive pressure."), "Expected enemy panel's real pressure label for Portly Cook (0 armor/0%% resist).")
	_require(combat_screen._enemy_panel._info_label.text.contains("Reward: 26g, Basic Gear"), "Expected enemy panel's real reward preview for Portly Cook.")
	_require(combat_screen._enemy_panel._fight_button.disabled, "Expected route fight blocked until build lock.")

	combat_screen._show_talent_overlay()
	await process_frame
	var secondary_choices: VBoxContainer = combat_screen._talent_overlay.find_child("SecondaryTreeChoices", true, false)
	_require(secondary_choices != null, "Expected secondary tree choices in the Talent Trees panel during build planning.")
	_require(secondary_choices.get_child_count() == 2, "Expected two available second trees after Thief start.")
	var tree_card_0_vbox: VBoxContainer = secondary_choices.get_child(0).get_child(0)
	var tree_card_1_vbox: VBoxContainer = secondary_choices.get_child(1).get_child(0)
	_require(tree_card_1_vbox.find_child("Title", true, false).text.contains("Shadow"), "Expected Shadow second-tree choice.")
	_require(tree_card_1_vbox.find_child("Icon", true, false) != null, "Expected Shadow second-tree choice to show an icon.")
	_require(
		tree_card_1_vbox.get_child(1).text.contains("Stab & Heavy Slash apply +1 poison stack"),
		"Expected Shadow intrinsic in second-tree choice."
	)
	_require(tree_card_0_vbox.find_child("Title", true, false).text.contains("Assassin"), "Expected Assassin second-tree choice.")
	_require(tree_card_0_vbox.find_child("Icon", true, false) != null, "Expected Assassin second-tree choice to show an icon.")
	var choose_button: Button = tree_card_0_vbox.get_child(2)
	_require(choose_button.text == "Choose", "Expected a Choose button on the second-tree card.")
	choose_button.pressed.emit()
	await process_frame
	_require(build_state.selected_trees.size() == 2, "Expected two selected trees.")
	_require(combat_screen._talent_overlay.visible, "Expected Talent Trees to stay open after choosing the second tree so points can be spent.")
	combat_screen._talent_overlay.visible = false

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


func _set_basic_rotation(build_state) -> void:
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected at least one unlocked skill for contract readiness setup.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)
