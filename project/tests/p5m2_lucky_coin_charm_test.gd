extends SceneTree
## Focused P5M2-T5 check: Lucky Coin is preserved as a fixed Basic Trinket
## reward and does not enter generated/shop/Legendary pools.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	print("-- P5M2 Lucky Coin Trinket boundary --")
	_check_lucky_coin_resource()
	_check_drunk_buddy_reward()
	_check_reward_claim_and_trinket_equip(build_state)
	_check_lucky_coin_excluded_from_generated_and_legendary_pools(build_state)
	print("P5M2 Lucky Coin Trinket boundary check: OK")
	build_state.reset()
	quit(0)


func _check_lucky_coin_resource() -> void:
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(lucky_coin != null, "Expected Lucky Coin to load.")
	_require(lucky_coin.id == "gear.lucky_coin", "Expected Lucky Coin id.")
	_require(lucky_coin.display_name == "Lucky Coin", "Expected Lucky Coin display name.")
	_require(lucky_coin.slot == GearItem.SlotType.TRINKET, "Expected Lucky Coin to be a Trinket.")
	_require(lucky_coin.tier == GearItem.Tier.BASIC, "Expected Lucky Coin to remain Basic.")
	_require(lucky_coin.item_family == "Ring", "Expected Lucky Coin to use Rogue Ring family.")
	_require(lucky_coin.class_family == GearItem.ClassFamily.ROGUE, "Expected Lucky Coin Rogue class family.")
	_require(lucky_coin.source_kind == GearItem.SourceKind.FIXED, "Expected Lucky Coin fixed source kind.")
	_require(lucky_coin.affixes.size() == 1, "Expected one Lucky Coin stat.")
	var crit: StatModifier = lucky_coin.affixes[0]
	_require(crit.stat_id == "crit_chance", "Expected Lucky Coin crit chance stat id.")
	_require(crit.stat == StatModifier.StatType.CRIT_CHANCE, "Expected Lucky Coin crit chance stat.")
	_require(crit.category == StatModifier.StatCategory.BASIC, "Expected Lucky Coin Basic stat category.")
	_require(not crit.is_drawback, "Expected Lucky Coin stat not to be a drawback.")
	_require(is_equal_approx(crit.value, 0.05), "Expected Lucky Coin +5% crit chance.")


func _check_drunk_buddy_reward() -> void:
	var buddy: Encounter = load("res://data/encounters/02_drunk_buddy.tres")
	_require(buddy != null and buddy.reward != null, "Expected Drunk Buddy reward.")
	_require(buddy.reward.fixed_gear_rewards.size() == 1, "Expected Drunk Buddy to grant one fixed gear reward.")
	var reward_coin: GearItem = buddy.reward.fixed_gear_rewards[0]
	_require(reward_coin != null and reward_coin.id == "gear.lucky_coin", "Expected Drunk Buddy to grant Lucky Coin.")
	_require(reward_coin.slot == GearItem.SlotType.TRINKET, "Expected Drunk Buddy Lucky Coin reward to be Trinket.")
	_require(reward_coin.source_kind == GearItem.SourceKind.FIXED, "Expected Drunk Buddy Lucky Coin reward to stay fixed.")


func _check_reward_claim_and_trinket_equip(build_state) -> void:
	build_state.reset()
	build_state.current_encounter_index = 1
	build_state.finish_fight(true)
	_require(build_state.claim_current_reward(), "Expected Drunk Buddy reward claim.")
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(build_state.has_inventory_item(lucky_coin), "Expected claimed Lucky Coin in inventory.")
	_require(build_state.equipped_trinket == null, "Expected Lucky Coin not to auto-equip.")
	_require(build_state.equip_from_inventory(lucky_coin), "Expected Lucky Coin to equip from inventory.")
	_require(build_state.equipped_trinket == lucky_coin, "Expected Lucky Coin to equip into Trinket.")
	_require(build_state.equipped_charm == null, "Expected Lucky Coin not to occupy Charm.")
	_require(not build_state.has_inventory_item(lucky_coin), "Expected equipped Lucky Coin to leave inventory.")


func _check_lucky_coin_excluded_from_generated_and_legendary_pools(build_state) -> void:
	for legendary in LegendaryCatalog.all_items():
		_require(legendary.id != "gear.lucky_coin", "Expected Lucky Coin outside Legendary catalog.")

	var rng := RandomNumberGenerator.new()
	rng.seed = 5015
	for slot in GearItem.universal_slot_order():
		for i in 12:
			var generated := GearGenerator.generate(GearItem.Tier.BASIC, slot, rng, "gear.test.generated_%s_%d" % [slot, i])
			_require(generated.id != "gear.lucky_coin", "Expected generated gear not to duplicate Lucky Coin id.")
			_require(generated.display_name != "Lucky Coin", "Expected generated gear not to duplicate Lucky Coin name.")

	build_state.reset()
	build_state.shop_unlocked = true
	build_state.gold = 999
	_require(build_state.open_shop_round(), "Expected shop round to open.")
	for offer in build_state.shop_offers:
		_require(offer.id != "gear.lucky_coin", "Expected shop offers not to include Lucky Coin.")
		_require(offer.display_name != "Lucky Coin", "Expected shop offers not to name Lucky Coin.")


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
