extends SceneTree
## P5M7-T9: Increased Gold affects incoming reward gold only.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var thief: SubclassTree = load("res://data/subclass_trees/thief.tres")
	var sticky_fingers: Talent = _find_talent(thief, "talent.sticky_fingers")
	_require(rogue != null, "Expected Rogue class data.")
	_require(thief != null, "Expected Thief tree data.")
	_require(sticky_fingers != null, "Expected Sticky Fingers talent.")

	build_state.set_class(rogue)
	build_state.select_tree(thief)
	build_state.add_talent_points(1)
	_require(build_state.select_talent(sticky_fingers), "Expected Sticky Fingers to be selectable.")
	_require(build_state.modified_gold_reward(12) == 15, "Expected Increased Gold to scale incoming reward gold.")

	build_state.choose_current_tavern_encounter()
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	_require(build_state.claim_current_reward(), "Expected reward claim to succeed.")
	_require(build_state.gold == 15, "Expected claimed reward gold to enter the stash with Increased Gold applied.")

	build_state.gold = 100
	build_state.shop_unlocked = true
	_require(build_state.open_shop_round(), "Expected shop to open for outgoing economy checks.")
	_require(build_state.shop_offers.size() > 0, "Expected shop offers.")
	var offer: GearItem = build_state.shop_offers[0]
	var expected_price: int = GearGenerator.price_for_tier(offer.tier)
	_require(expected_price == 18, "Expected pre-contract Basic shop offer price to remain fixed.")

	_require(build_state.shop_reroll_cost == BuildState.SHOP_REROLL_INITIAL_COST, "Expected initial reroll cost to stay fixed.")
	var gold_before_reroll: int = build_state.gold
	_require(build_state.reroll_shop_offers(), "Expected reroll to spend gold.")
	_require(build_state.gold == gold_before_reroll - BuildState.SHOP_REROLL_INITIAL_COST, "Expected Increased Gold not to discount reroll costs.")
	_require(build_state.shop_reroll_cost == BuildState.SHOP_REROLL_INITIAL_COST + BuildState.SHOP_REROLL_COST_STEP, "Expected reroll cost step to stay fixed.")

	offer = build_state.shop_offers[0]
	expected_price = GearGenerator.price_for_tier(offer.tier)
	var gold_before_purchase: int = build_state.gold
	_require(build_state.buy_shop_offer(offer), "Expected shop purchase to succeed.")
	_require(build_state.gold == gold_before_purchase - expected_price, "Expected Increased Gold not to discount shop purchases.")
	_require(build_state.has_inventory_item(offer), "Expected bought offer to enter inventory.")

	var expected_sale_value: int = max(1, int(floor(float(GearGenerator.price_for_tier(offer.tier)) * BuildState.SELL_VALUE_RATIO)))
	_require(build_state.sell_value_for(offer) == expected_sale_value, "Expected sell value to ignore Increased Gold.")
	var gold_before_sale: int = build_state.gold
	_require(build_state.sell_inventory_item(offer), "Expected inventory sale to succeed.")
	_require(build_state.gold == gold_before_sale + expected_sale_value, "Expected sale payout to use fixed sell value.")

	print("P5M7 gold gain economy check: OK")
	quit()


func _find_talent(tree: SubclassTree, talent_id: String) -> Talent:
	for talent in tree.talents:
		if talent.id == talent_id:
			return talent
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
