extends SceneTree
## Focused P4M6-T4 check: authored and generated contracts can coexist in
## the player-facing contract offer picker without changing the authored
## single-offer baseline.

const ContractOfferSourceScript := preload("res://scripts/systems/contract_offer_source.gd")


func _initialize() -> void:
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
	_require(build_state.start_contract_offer(context), "Expected authored/generated contract offer to start.")
	_require(build_state.pending_contract_offers.size() == 2, "Expected one authored and one generated pending offer.")
	_require(build_state.active_contract.id == "contract.gilded_serpent", "Expected authored contract to remain the default offer.")

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	combat_screen._contract_overlay.show_greeting()
	await process_frame
	_require(combat_screen._contract_overlay.visible, "Expected contract overlay to open.")
	_require(combat_screen._contract_overlay._contract_action_button.text == "Hear Him Out", "Expected greeting action.")

	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame
	_require(combat_screen._contract_overlay._contract_action_button.text == "Accept Contract Work", "Expected pitch action.")

	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_OFFER, "Expected multi-offer choice to stay in offer phase before selection.")
	_require(combat_screen._contract_overlay._contract_options_box.get_child_count() == 2, "Expected authored and generated offer cards.")
	var authored_button: Button = combat_screen._contract_overlay._contract_options_box.find_child("AuthoredContractOfferButton", true, false)
	var generated_button: Button = combat_screen._contract_overlay._contract_options_box.find_child("GeneratedContractOfferButton", true, false)
	_require(authored_button != null, "Expected authored Gilded Serpent card.")
	_require(generated_button != null, "Expected generated contract card.")
	_require(combat_screen._contract_overlay._contract_title_label.text == "Choose a Contract", "Expected the offer picker header to invite contract choice.")
	_require(not combat_screen._contract_overlay._contract_body_label.visible, "Expected the offer picker subtext to be hidden.")
	_require(authored_button.text == "", "Expected authored card to use composed labels instead of button text.")
	_require(generated_button.text == "", "Expected generated card to use composed labels instead of button text.")
	_require(_card_label_text(authored_button, "ContractBossNameLabel") == "Vyra", "Expected authored card to name its boss.")
	_require(_card_label_text(generated_button, "ContractBossNameLabel") != "Graveyard Contract", "Expected generated card to show the boss name, not contract title.")
	_require(_card_label_text(generated_button, "ContractLocationLabel") == "Location: Graveyard", "Expected generated card to show biome location.")
	var generated_reward_amounts := _contract_reward_amount_texts(generated_button)
	_require(_reward_amounts_contain_suffix(generated_reward_amounts, "g"), "Expected generated card to show the gold reward as an icon row.")
	_require(generated_reward_amounts.has("x 1"), "Expected generated card to show the boss talent-point reward as an icon row.")
	_require(_contract_card_icon(generated_button).custom_minimum_size == Vector2(64, 64), "Expected generated contract card icon to be larger.")
	_require(_card_label_font_size(generated_button, "ContractBossNameLabel") > _card_label_font_size(generated_button, "ContractLocationLabel"), "Expected generated boss name to use the larger card font.")
	_require(combat_screen._contract_overlay._contract_action_button.disabled, "Expected Proceed disabled before choosing an offer.")

	generated_button.pressed.emit()
	await process_frame
	_require(not combat_screen._contract_overlay._contract_action_button.disabled, "Expected Proceed enabled after choosing generated offer.")

	combat_screen._contract_overlay._contract_action_button.pressed.emit()
	await process_frame
	_require(build_state.active_contract != null and build_state.active_contract.has_generated_route_state(), "Expected generated contract to become active.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected generated offer acceptance to enter contract route flow.")
	_require(build_state.pending_contract_offers.size() == 2, "Expected pending offers to remain available while previewing route map.")
	_require(combat_screen._map_overlay.visible, "Expected generated route fallback map to open after acceptance.")

	print("Contract offer coexistence check: OK")
	quit()


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


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
