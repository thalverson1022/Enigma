extends SceneTree
## Focused check for the current Adventure contract handoff: after the Tavern
## sequence's final reward, Ghit Gudd gives the materials-work pitch and the
## Accept Contract Work button opens three generated biome contract choices.
## The authored Vyra contract remains in data, but this flow intentionally
## skips it for now.


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
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected generated contract offers after Tavern.")
	_require(build_state.pending_contract_offers.size() == 3, "Expected three generated biome contracts.")
	_require(not combat_screen._shop_overlay.visible, "Expected the shop to be skipped after Hired Goon.")
	_require(combat_screen._contract_overlay.visible, "Expected Ghit Gudd's Contract Window to introduce the generated contract work.")
	_require(combat_screen._contract_overlay._contract_body_label.text == combat_screen._contract_overlay.CONTRACT_GREETING_TEXT, "Expected Ghit Gudd's greeting line.")
	_require(combat_screen._contract_overlay._contract_action_button.text == "Hear Him Out", "Expected the greeting's action button.")

	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame
	_require(combat_screen._contract_overlay._contract_body_label.text == combat_screen._contract_overlay.CONTRACT_PITCH_TEXT, "Expected the materials-work pitch line.")
	_require(combat_screen._contract_overlay._contract_body_label.text.contains("valuable... materials"), "Expected generated-contract pitch to mention valuable materials.")
	_require(combat_screen._contract_overlay._contract_action_button.text == "Accept Contract Work", "Expected the pitch's action button.")

	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected accept from pitch to open generated choices before route acceptance.")
	_require(combat_screen._contract_overlay._contract_title_label.text == "Choose a Contract", "Expected generated picker header.")
	_require(not combat_screen._contract_overlay._contract_body_label.visible, "Expected generated picker subtext to be hidden.")
	_require(combat_screen._contract_overlay._contract_options_box.get_child_count() == 3, "Expected exactly three generated contract cards.")
	_require(combat_screen._contract_overlay._contract_action_button.disabled, "Expected Proceed disabled before a contract is selected.")

	for index in range(combat_screen._contract_overlay._contract_options_box.get_child_count()):
		var button: Button = combat_screen._contract_overlay._contract_options_box.get_child(index)
		_require(button != null, "Expected generated contract option to be a button.")
		_require(button.text == "", "Expected generated contract card to use composed labels instead of button text.")
		_require(_card_label_text(button, "ContractBossNameLabel") != "Vyra", "Expected generated contract cards to omit Vyra.")
		_require(_card_label_text(button, "ContractBossNameLabel") != "", "Expected generated contract card to show boss name.")
		_require(_card_label_text(button, "ContractLocationLabel").begins_with("Location: "), "Expected generated contract card to show biome location.")
		var reward_amounts := _contract_reward_amount_texts(button)
		_require(_reward_amounts_contain_suffix(reward_amounts, "g"), "Expected generated contract card to show gold reward.")
		_require(reward_amounts.has("x 1"), "Expected generated contract card to show boss talent-point reward.")
		_require(_contract_card_icon(button).custom_minimum_size == Vector2(64, 64), "Expected generated contract card icon to be larger.")
		_require(_card_label_font_size(button, "ContractBossNameLabel") > _card_label_font_size(button, "ContractLocationLabel"), "Expected boss name to use the larger card font.")

	var first_offer_button: Button = combat_screen._contract_overlay._contract_options_box.get_child(0)
	first_offer_button.pressed.emit()
	await process_frame
	_require(not combat_screen._contract_overlay._contract_action_button.disabled, "Expected Proceed enabled after selecting a generated contract.")
	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame

	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected selected generated contract to become active.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected generated route phase after accepting the selected contract.")
	_require(build_state.pending_contract_offers.size() == 3, "Expected generated choices to remain available while previewing the route map.")
	_require(not combat_screen._contract_overlay.visible, "Expected the Contract Window hidden once generated route map takes over.")
	_require(combat_screen._map_overlay.visible, "Expected generated route map after choosing a generated contract.")
	_require(combat_screen._map_overlay._map_contract_back_button.visible, "Expected generated route preview to allow returning to contract offers before route commit.")
	_require(combat_screen._map_overlay._map_node_buttons.size() > build_state.current_route_node.next_nodes.size(), "Expected generated route preview to show the full route graph.")

	print("Contract offer flow check: OK")
	quit()


func _card_label_text(card: Button, label_name: String) -> String:
	var label: Label = card.find_child(label_name, true, false)
	_require(label != null, "Expected contract card label %s." % label_name)
	return label.text


func _card_label_font_size(card: Button, label_name: String) -> int:
	var label: Label = card.find_child(label_name, true, false)
	_require(label != null, "Expected contract card label %s." % label_name)
	return label.get_theme_font_size("font_size")


func _contract_card_icon(card: Button) -> TextureRect:
	var content: HBoxContainer = card.find_child("ContractOfferContent", true, false)
	_require(content != null, "Expected composed contract card content.")
	var icon: TextureRect = content.find_child("Icon", true, false)
	_require(icon != null, "Expected contract card icon.")
	return icon


func _contract_reward_amount_texts(card: Button) -> Array[String]:
	var stack: BoxContainer = card.find_child("ContractRewardStack", true, false)
	_require(stack != null, "Expected contract card reward icon stack.")
	var texts: Array[String] = []
	for label in stack.find_children("ContractRewardAmount", "Label", true, false):
		texts.append((label as Label).text)
	return texts


func _reward_amounts_contain_suffix(texts: Array[String], suffix: String) -> bool:
	for text in texts:
		if text.ends_with(suffix):
			return true
	return false


func _set_basic_rotation(build_state) -> void:
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected at least one unlocked skill for contract readiness setup.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
