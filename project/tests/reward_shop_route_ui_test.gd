extends SceneTree
## Focused P2:R7:T6 check for the reward-claim, Tavern shop, and Gilded
## Serpent route-choice UI: shop offer tier/slot/affix/afford-state
## rendering with a known gold value, the two-box "item + Equipped" hover
## tooltip (P2:R7 second playtest-feedback pass -- two compact
## default-tooltip-styled boxes, no stat-diff text, replacing both the
## T6-era appended comparison line and the first feedback pass's rejected
## large comparison panel), route-branch tradeoff text differing between
## two real Gilded Serpent branch pairs, and reward-claim (Legendary)
## tier/slot/affix rendering. Same headless-only caveat as every prior
## P2:R7 UI test -- no rendered click-through available in this
## environment.


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

	# -- Shop offer rendering: known gold, affordable vs. unaffordable tiers --
	print("shop offer tier/slot/affix/afford-state checks")
	build_state.gold = 20
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var unaffordable_offer := GearGenerator.generate(GearItem.Tier.MASTER, GearItem.SlotType.WEAPON, rng, "test.shop.master_weapon")
	var affordable_offer := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.TRINKET, rng, "test.shop.basic_trinket")
	var offers: Array[GearItem] = [unaffordable_offer, affordable_offer]
	build_state.shop_round_pending = true
	build_state.shop_offers = offers
	build_state.build_changed.emit()
	combat_screen._shop_overlay.refresh()
	await process_frame

	_require(combat_screen._shop_overlay._shopkeeper_image != null, "Expected the shopkeeper image node to exist.")
	_require(combat_screen._shop_overlay._shopkeeper_image.texture != null, "Expected the shopkeeper image texture to be loaded.")
	_require(combat_screen._shop_overlay.z_index > combat_screen._combat_stage.player_actor_anchor.z_index, "Expected the shop overlay to render above combat actor sprites.")
	_require(combat_screen._shop_overlay.z_index > combat_screen.COMBAT_BUTTON_ROW_Z_INDEX, "Expected the shop overlay to render above the raised combat button row.")
	_require(combat_screen.find_child("GearPanel", true, false)._gold_label.text == "20g", "Expected the Gear panel to be the primary gold stash readout.")
	_require(combat_screen._shop_overlay._shop_reroll_button.text == "Reroll 5g", "Expected reroll to show its current gold cost.")
	_require(not combat_screen._shop_overlay._shop_reroll_button.disabled, "Expected 20g to afford the initial 5g reroll.")
	_require(combat_screen._shop_overlay._shop_reroll_button.tooltip_text.contains("Spend 5g"), "Expected reroll tooltip to explain the gold spend.")
	var found_shop_gold_label := false
	for label in combat_screen._shop_overlay.find_children("*", "Label", true, false):
		if label.text == "Gold: 20g":
			found_shop_gold_label = true
	_require(not found_shop_gold_label, "Expected the shop overlay to avoid a duplicate Gold row.")
	_require(combat_screen._shop_overlay._shop_offers_box.get_child_count() == 2, "Expected two shop offer boxes.")

	var unaffordable_button: Button = combat_screen._shop_overlay._shop_offers_box.get_child(0)
	_require(unaffordable_button.disabled, "Expected the 32g Master offer to be disabled at 20 gold.")
	_require(unaffordable_button.find_child("PriceBadge", true, false) != null, "Expected the unaffordable offer to show an always-visible price badge.")
	_require(unaffordable_button.find_child("PriceLabel", true, false).text == "32g", "Expected the unaffordable offer price badge to show 32g.")
	_require(unaffordable_button.find_child("PriceLabel", true, false).get_theme_font_size("font_size") == 16, "Expected the price badge value font to be larger.")
	_require(unaffordable_button.find_child("GoldIcon", true, false).custom_minimum_size == Vector2(11, 11), "Expected the price badge gold icon to be smaller.")
	# The offer box's icon lives in a child TextureRect (P2:R7 gear-art pass)
	# -- see CardStyle.build_gear_box_content(). The caption text it used to
	# carry alongside the icon was dropped as redundant once the icon art +
	# tier-colored background conveyed slot/tier on their own.
	var unaffordable_icon: TextureRect = unaffordable_button.get_node("Icon")
	_require(unaffordable_icon.texture == GearIcons.MASTER_WEAPON_ICON, "Expected the unaffordable offer box to show the generic Master Weapon icon.")
	var unaffordable_tooltip: String = unaffordable_button.tooltip_text
	_require(unaffordable_tooltip.contains("Weapon - "), "Expected the slot tag in the tooltip, got: %s" % unaffordable_tooltip)
	_require(unaffordable_tooltip.contains("Master"), "Expected the tier name in the tooltip, got: %s" % unaffordable_tooltip)
	_require(unaffordable_tooltip.contains("Price: 32g"), "Expected the price in the tooltip, got: %s" % unaffordable_tooltip)
	_require(unaffordable_tooltip.contains("Not enough gold."), "Expected an explicit afford-state hint, got: %s" % unaffordable_tooltip)

	var affordable_button: Button = combat_screen._shop_overlay._shop_offers_box.get_child(1)
	_require(not affordable_button.disabled, "Expected the 18g Basic offer to be affordable at 20 gold.")
	_require(affordable_button.find_child("PriceBadge", true, false) != null, "Expected the affordable offer to show an always-visible price badge.")
	_require(affordable_button.find_child("PriceLabel", true, false).text == "18g", "Expected the affordable offer price badge to show 18g.")
	_require(affordable_button.find_child("PriceLabel", true, false).get_theme_font_size("font_size") == 16, "Expected the affordable price badge value font to be larger.")
	var affordable_tooltip: String = affordable_button.tooltip_text
	_require(affordable_tooltip.contains("Click to buy."), "Expected an explicit buy hint on an affordable offer, got: %s" % affordable_tooltip)
	_require(not affordable_tooltip.contains("vs. equipped"), "Expected no stat-diff comparison text in the tooltip anymore, got: %s" % affordable_tooltip)
	_require(not affordable_tooltip.contains("Upgrade --"), "Expected no upgrade-comparison text in the tooltip anymore, got: %s" % affordable_tooltip)

	# -- Two-box hover tooltip (P2:R7 second playtest-feedback pass): the
	# custom tooltip is a compact HBox of two default-tooltip-styled boxes --
	# the item's regular tooltip text, and an "Equipped" box beside it. --
	print("two-box gear tooltip checks")
	var tooltip_control: Control = affordable_button._make_custom_tooltip("")
	_require(tooltip_control is HBoxContainer, "Expected the custom tooltip to be a compact HBox of two boxes.")
	_require(tooltip_control.get_child_count() == 2, "Expected exactly two tooltip boxes.")
	var item_box: Control = tooltip_control.get_child(0)
	var equipped_box: Control = tooltip_control.get_child(1)
	_require(item_box is PanelContainer and equipped_box is PanelContainer, "Expected both tooltip boxes to be tooltip-styled panels.")
	var item_box_text: String = item_box.get_child(0).get_child(0).text
	_require(item_box_text == affordable_tooltip, "Expected the first box to carry the item's regular tooltip text verbatim, got: %s" % item_box_text)
	var equipped_header: String = equipped_box.get_child(0).get_child(0).text
	_require(equipped_header == "Equipped", "Expected the second box to be headed 'Equipped', got: %s" % equipped_header)
	var equipped_body: String = equipped_box.get_child(0).get_child(1).text
	_require(equipped_body == "Nothing equipped.", "Expected 'Nothing equipped.' for the empty trinket slot, got: %s" % equipped_body)
	tooltip_control.free()

	var equipped_weapon := GearItem.new()
	equipped_weapon.id = "test.equipped.weapon"
	equipped_weapon.display_name = "Test Equipped Dagger"
	equipped_weapon.slot = GearItem.SlotType.WEAPON
	equipped_weapon.tier = GearItem.Tier.BASIC
	var equipped_mod := StatModifier.new()
	equipped_mod.stat = StatModifier.StatType.ATTACK_SPEED
	equipped_mod.operation = StatModifier.OperationType.ADD
	equipped_mod.value = 0.05
	equipped_weapon.affixes = [equipped_mod]

	var candidate_weapon := GearItem.new()
	candidate_weapon.id = "test.candidate.weapon"
	candidate_weapon.display_name = "Test Candidate Dagger"
	candidate_weapon.slot = GearItem.SlotType.WEAPON
	candidate_weapon.tier = GearItem.Tier.MASTER
	var candidate_mod := StatModifier.new()
	candidate_mod.stat = StatModifier.StatType.ATTACK_SPEED
	candidate_mod.operation = StatModifier.OperationType.ADD
	candidate_mod.value = 0.10
	candidate_weapon.affixes = [candidate_mod]

	# With a weapon equipped, hovering a weapon offer shows the equipped
	# item's own regular tooltip lines in the second box -- still no diff
	# text anywhere.
	build_state.equipped_weapon = equipped_weapon
	var candidate_row: Button = combat_screen._shop_overlay._make_shop_offer_row(candidate_weapon)
	var candidate_tooltip: Control = candidate_row._make_custom_tooltip("")
	_require(candidate_tooltip.get_child_count() == 2, "Expected two tooltip boxes for the candidate weapon offer.")
	var candidate_equipped_box: Control = candidate_tooltip.get_child(1)
	_require(candidate_equipped_box.get_child(0).get_child(0).text == "Equipped", "Expected the 'Equipped' header on the second box.")
	var candidate_equipped_body: String = candidate_equipped_box.get_child(0).get_child(1).text
	print(candidate_equipped_body)
	_require(candidate_equipped_body.contains("Weapon - Test Equipped Dagger"), "Expected the equipped weapon's slot/name in the Equipped box, got: %s" % candidate_equipped_body)
	_require(candidate_equipped_body.contains("Basic"), "Expected the equipped weapon's tier in the Equipped box, got: %s" % candidate_equipped_body)
	_require(candidate_equipped_body.contains("Attack Speed"), "Expected the equipped weapon's affix line in the Equipped box, got: %s" % candidate_equipped_body)
	_require(not candidate_equipped_body.contains("vs. equipped"), "Expected no stat-diff text in the Equipped box, got: %s" % candidate_equipped_body)
	candidate_tooltip.free()
	candidate_row.free()
	build_state.equipped_weapon = null

	build_state.gold = 4
	combat_screen._shop_overlay.refresh()
	await process_frame
	_require(combat_screen._shop_overlay._shop_reroll_button.disabled, "Expected reroll to disable below its current gold cost.")
	_require(combat_screen._shop_overlay._shop_reroll_button.tooltip_text.contains("Need 5g"), "Expected reroll tooltip to explain the unaffordable cost.")
	build_state.gold = 20
	combat_screen._shop_overlay.refresh()
	await process_frame

	# -- Route tradeoff text: differs between two real Gilded Serpent branch
	# pairs, derived from real Monster/EncounterReward data. --
	print("route tradeoff text checks")
	var contract: ContractDef = load("res://data/contracts/the_gilded_serpent.tres")
	var door_guard := _find_route_node(contract.offer_node, "route.gilded_serpent.door_guard")
	var portly_cook := _find_route_node(contract.offer_node, "route.gilded_serpent.portly_cook")
	var sleeping := _find_route_node(contract.offer_node, "route.gilded_serpent.sleeping_henchman")
	var cloaked := _find_route_node(contract.offer_node, "route.gilded_serpent.cloaked_watchmen")
	_require(door_guard != null and portly_cook != null and sleeping != null and cloaked != null, "Expected to find all four route nodes.")

	var opener_tradeoff: String = combat_screen._map_overlay._route_tradeoff_text(door_guard, portly_cook)
	print(opener_tradeoff)
	_require(
		opener_tradeoff == "Door Guard is the harder branch. Door Guard reward: Master -- Portly Cook reward: Basic.",
		"Expected the opener tradeoff sentence, got: %s" % opener_tradeoff
	)

	var second_layer_tradeoff: String = combat_screen._map_overlay._route_tradeoff_text(sleeping, cloaked)
	print(second_layer_tradeoff)
	_require(
		second_layer_tradeoff == "Cloaked Watchmen is the harder branch. Sleeping Henchman reward: Basic -- Cloaked Watchmen reward: Cursed.",
		"Expected the second-layer tradeoff sentence, got: %s" % second_layer_tradeoff
	)
	_require(opener_tradeoff != second_layer_tradeoff, "Expected the tradeoff text to differ between two different Gilded Serpent branch pairs.")

	# -- Live scene check: the route map's story text carries the tradeoff at
	# the real opener-choice state. --
	# A second selected tree is required so BuildState.needs_secondary_subclass_
	# choice() reads false at the door_guard/portly_cook branch node (its
	# parent node's node_type is SUBCLASS_CHOICE) -- appended directly rather
	# than driving the full choice-overlay click flow, matching how
	# route_reward_choice_ui_test.gd sets route state directly.
	build_state.selected_trees.append(rogue.trees[0])
	build_state.active_contract = contract
	build_state.current_route_node = contract.offer_node.next_nodes[0]
	build_state.run_phase = BuildState.RunPhase.CONTRACT_ROUTE
	build_state.run_state_changed.emit()
	await process_frame
	print(combat_screen._map_overlay._map_story_label.text)
	_require(combat_screen._map_overlay._map_story_label.text.contains("Door Guard is the harder branch."), "Expected the live route map story text to include the opener tradeoff sentence.")

	print("contract reward-row summary checks")
	build_state.current_route_node = door_guard
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	build_state.run_state_changed.emit()
	combat_screen._populate_reward_row()
	await process_frame
	var door_reward_row_text := _reward_row_text(combat_screen)
	print(door_reward_row_text)
	_require(door_reward_row_text.contains("Choice of Master Gear"), "Expected Door Guard result reward row to show the compact generated-gear label.")
	_require(door_reward_row_text.contains(": 22g"), "Expected Door Guard result reward row to show the gold icon value.")
	_require(not door_reward_row_text.contains("weapon or ring"), "Expected Door Guard result reward row to omit route-preview slot copy.")
	_require(not door_reward_row_text.contains("22g and"), "Expected Door Guard result reward row not to duplicate gold in prose.")
	_require(_reward_row_icon_count(combat_screen) == 1, "Expected Door Guard reward row to show only the gold icon.")

	# -- Reward-claim UI: Legendary reward tier/slot/affix rendering, using
	# Knives' real authored gear_choice_rewards. --
	print("Legendary reward-claim tier/slot/affix checks")
	var wyvern: GearItem = load("res://data/gear/wyvern_kriss.tres")
	var reward_text: String = combat_screen._reward_choice_text(wyvern)
	print(reward_text)
	_require(reward_text.begins_with("Weapon - Wyvern Kriss"), "Expected the slot tag and item name, got: %s" % reward_text)
	_require(reward_text.contains("Poison"), "Expected an affix line, got: %s" % reward_text)
	_require(reward_text.contains("Poison ticks twice as fast"), "Expected Wyvern Kriss Legendary flavor text, got: %s" % reward_text)
	_require(not reward_text.contains("Poison Tick Interval"), "Expected Wyvern's tick-rate mechanic to be flavor text, not a raw interval affix, got: %s" % reward_text)
	_require(not reward_text.contains("Upgrade --"), "Expected no upgrade-comparison line anymore (removed in the P2:R7 second playtest-feedback pass), got: %s" % reward_text)
	_require(reward_text.contains("Click to choose."), "Expected an explicit choose hint, got: %s" % reward_text)

	print("")
	print("Reward/shop/route UI check: OK")
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


func _reward_row_text(combat_screen) -> String:
	var parts: PackedStringArray = []
	for child in combat_screen._victory_reward_row.get_children():
		if child is Label:
			parts.append(child.text)
	return " ".join(parts)


func _reward_row_icon_count(combat_screen) -> int:
	var count := 0
	for child in combat_screen._victory_reward_row.get_children():
		if child is TextureRect:
			count += 1
	return count


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
