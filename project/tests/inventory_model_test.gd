extends SceneTree
## Headless P2:R3:T4 check for BuildState's inventory/equipment model.
## Run with:
##   godot --headless --path project -s res://tests/inventory_model_test.gd


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var dagger: GearItem = load("res://data/gear/placeholder_dagger.tres")
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")

	assert(build_state.inventory.is_empty())
	assert(build_state.equipped_gear().is_empty())
	assert(build_state.earned_talent_points == 0)

	print("retries are available after the first encounter failure")
	build_state.finish_fight(false)
	assert(build_state.failure_count_for_current_encounter() == 1)
	assert(build_state.can_retry_current_encounter())
	assert(build_state.retry_current_encounter())
	assert(build_state.run_phase == build_state.RunPhase.PLANNING)
	build_state.finish_fight(false)
	assert(build_state.failure_count_for_current_encounter() == 2)
	# current_encounter_index is 0 here (fresh reset default), which is the
	# unlimited-retry encounter per BuildState.is_unlimited_retry_encounter()
	# (docs/Phase_2_R5_Run_Rules_And_Determinism.md's 2026-07-19 retry-exception
	# correction) -- a second loss on the very first Tavern encounter still
	# grants a retry rather than requiring an Adventure restart.
	assert(build_state.can_retry_current_encounter())
	assert(build_state.retry_current_encounter())
	assert(build_state.run_phase == build_state.RunPhase.PLANNING)
	build_state.reset()

	build_state.add_talent_points(1)
	print("earned talent points after grant (expect 1): %d" % build_state.earned_talent_points)
	assert(build_state.earned_talent_points == 1)

	print("grant Lucky Coin to inventory")
	assert(build_state.grant_gear(lucky_coin))
	assert(build_state.inventory.size() == 1)
	assert(build_state.has_inventory_item(lucky_coin))
	assert(build_state.equipped_trinket == null)

	print("equip Lucky Coin from inventory")
	assert(build_state.equip_from_inventory(lucky_coin))
	assert(build_state.equipped_trinket == lucky_coin)
	assert(not build_state.has_inventory_item(lucky_coin))

	print("unequip Lucky Coin back to inventory")
	build_state.unequip(GearItem.SlotType.TRINKET)
	assert(build_state.equipped_trinket == null)
	assert(build_state.has_inventory_item(lucky_coin))

	print("direct-equip weapon as reward/shop shortcut")
	assert(build_state.grant_gear(dagger, true))
	assert(build_state.equipped_weapon == dagger)
	assert(not build_state.has_inventory_item(dagger))

	var stats_no_gear := BuildResolver.resolve_stats(rogue, [], [], [])
	var stats_with_weapon := BuildResolver.resolve_stats(rogue, [], [], build_state.equipped_gear())
	print("attack speed without/with dagger: %.2f / %.2f" % [
		stats_no_gear.attack_speed,
		stats_with_weapon.attack_speed,
	])
	assert(stats_with_weapon.attack_speed > stats_no_gear.attack_speed)

	print("replace equipped weapon and keep old weapon")
	var rng := RandomNumberGenerator.new()
	rng.seed = 19
	var replacement_weapon := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.WEAPON, rng)
	build_state.add_inventory_item(replacement_weapon)
	assert(build_state.equip_from_inventory(replacement_weapon))
	assert(build_state.equipped_weapon == replacement_weapon)
	assert(build_state.has_inventory_item(dagger))
	assert(not build_state.has_inventory_item(replacement_weapon))

	print("remove inventory item")
	assert(build_state.remove_inventory_item(dagger))
	assert(not build_state.has_inventory_item(dagger))

	print("inventory capacity blocks extra shop storage")
	var capacity_items: Array[GearItem] = []
	while build_state.inventory.size() < build_state.INVENTORY_CAPACITY:
		var item := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.CHARM, rng)
		capacity_items.append(item)
		assert(build_state.add_inventory_item(item))
	assert(build_state.inventory.size() == build_state.INVENTORY_CAPACITY)
	var overflow_item := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.CHARM, rng)
	assert(not build_state.add_inventory_item(overflow_item))

	print("sell inventory item returns gold and frees one slot")
	var gold_before_sale: int = build_state.gold
	var sold_item: GearItem = capacity_items[0]
	assert(build_state.sell_inventory_item(sold_item))
	assert(build_state.gold == gold_before_sale + build_state.sell_value_for(sold_item))
	assert(not build_state.has_inventory_item(sold_item))
	assert(build_state.inventory.size() == build_state.INVENTORY_CAPACITY - 1)

	print("unequip empty charm is a no-op")
	var inventory_size_before: int = build_state.inventory.size()
	build_state.unequip(GearItem.SlotType.CHARM)
	assert(build_state.inventory.size() == inventory_size_before)

	print("Gold Rewards modifiers affect claimed gold only")
	build_state.reset()
	build_state.set_class(rogue)
	var gold_trinket := _make_gold_reward_item("gear.test_gold_ring", "Gold Ring", GearItem.SlotType.TRINKET, 0.5)
	var inventory_gold_charm := _make_gold_reward_item("gear.test_gold_charm", "Pocket Ledger", GearItem.SlotType.CHARM, 1.0)
	var stats_before_gold_rewards := BuildResolver.resolve_stats(rogue, [], [], [])
	assert(build_state.grant_gear(gold_trinket, true))
	assert(build_state.add_inventory_item(inventory_gold_charm))
	var stats_after_gold_rewards := BuildResolver.resolve_stats(rogue, [], [], build_state.equipped_gear())
	assert(stats_after_gold_rewards.attack_speed == stats_before_gold_rewards.attack_speed)
	assert(stats_after_gold_rewards.crit_chance == stats_before_gold_rewards.crit_chance)
	assert(stats_after_gold_rewards.crit_multiplier == stats_before_gold_rewards.crit_multiplier)
	assert(stats_after_gold_rewards.poison_damage_per_tick == stats_before_gold_rewards.poison_damage_per_tick)
	assert(stats_after_gold_rewards.physical_damage_multiplier == stats_before_gold_rewards.physical_damage_multiplier)
	assert(stats_after_gold_rewards.bonus_poison_stacks == stats_before_gold_rewards.bonus_poison_stacks)
	assert(stats_after_gold_rewards.bonus_armor_reduction == stats_before_gold_rewards.bonus_armor_reduction)
	assert(build_state.modified_gold_reward(12) == 18)
	build_state.finish_fight(true)
	assert(build_state.claim_current_reward())
	assert(build_state.gold == 18)

	print("multiple Gold Rewards modifiers compound and clamp")
	build_state.reset()
	var gold_weapon := _make_gold_reward_item("gear.test_gold_knife", "Gilded Knife", GearItem.SlotType.WEAPON, 0.25)
	var gold_charm := _make_gold_reward_item("gear.test_gold_charm_equipped", "Receipt Charm", GearItem.SlotType.CHARM, 0.5)
	assert(build_state.grant_gear(gold_weapon, true))
	assert(build_state.grant_gear(gold_charm, true))
	assert(build_state.modified_gold_reward(100) == 187)
	var cursed_ledger := _make_gold_reward_item("gear.test_cursed_ledger", "Cursed Ledger", GearItem.SlotType.TRINKET, -2.0)
	assert(build_state.grant_gear(cursed_ledger, true))
	assert(build_state.modified_gold_reward(100) == 0)

	print("full inventory blocks fixed gear reward claim without mutating reward state")
	build_state.reset()
	build_state.current_encounter_index = 1
	var full_reward_rng := RandomNumberGenerator.new()
	full_reward_rng.seed = 91
	while build_state.inventory.size() < build_state.INVENTORY_CAPACITY:
		assert(build_state.add_inventory_item(GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.CHARM, full_reward_rng)))
	build_state.finish_fight(true)
	assert(not build_state.can_claim_current_reward())
	assert(not build_state.claim_current_reward())
	assert(build_state.gold == 0)
	assert(build_state.earned_talent_points == 0)
	assert(build_state.claimed_reward_encounter_indices.is_empty())
	assert(not build_state.has_pending_reward_choice())
	var freed_reward_slot: GearItem = build_state.inventory[0]
	assert(build_state.remove_inventory_item(freed_reward_slot))
	assert(build_state.can_claim_current_reward())
	assert(build_state.claim_current_reward())
	assert(build_state.gold > 0)
	assert(build_state.inventory.size() == build_state.INVENTORY_CAPACITY)
	assert(build_state.claimed_reward_encounter_indices == [1])

	print("skip pending gear reward clears choices without granting gear")
	build_state.reset()
	var skip_reward_choice := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.WEAPON, full_reward_rng, "gear.test.skip_reward")
	var skip_choices: Array[GearItem] = [skip_reward_choice]
	build_state.pending_reward_choices = skip_choices
	assert(build_state.has_pending_reward_choice())
	assert(build_state.skip_pending_reward_gear())
	assert(not build_state.has_pending_reward_choice())
	assert(not build_state.has_inventory_item(skip_reward_choice))
	assert(build_state.equipped_item_for_slot(skip_reward_choice.slot) != skip_reward_choice)
	assert(not build_state.skip_pending_reward_gear())

	print("shop reroll spends scaling gold and resets per shop")
	build_state.reset()
	build_state.shop_unlocked = true
	build_state.gold = 16
	assert(build_state.open_shop_round())
	assert(build_state.shop_reroll_cost == 5)
	assert(build_state.can_reroll_shop_offers())
	var first_shop_ids := _offer_ids(build_state.shop_offers)
	assert(build_state.reroll_shop_offers())
	assert(build_state.gold == 11)
	assert(build_state.shop_reroll_used)
	assert(build_state.shop_reroll_count == 1)
	assert(build_state.shop_reroll_cost == 10)
	var second_shop_ids := _offer_ids(build_state.shop_offers)
	assert(first_shop_ids != second_shop_ids)
	assert(build_state.reroll_shop_offers())
	assert(build_state.gold == 1)
	assert(build_state.shop_reroll_count == 2)
	assert(build_state.shop_reroll_cost == 15)
	assert(not build_state.can_reroll_shop_offers())
	assert(not build_state.reroll_shop_offers())
	assert(build_state.close_shop_round())
	assert(build_state.open_shop_round())
	assert(build_state.shop_reroll_count == 0)
	assert(build_state.shop_reroll_cost == 5)

	print("")
	print("Inventory model check: OK")
	quit()


func _make_gold_reward_item(id: String, display_name: String, slot: GearItem.SlotType, value: float) -> GearItem:
	var modifier := StatModifier.new()
	modifier.stat = StatModifier.StatType.GOLD_REWARDS
	modifier.operation = StatModifier.OperationType.ADD
	modifier.value = value

	var item := GearItem.new()
	item.id = id
	item.display_name = display_name
	item.slot = slot
	item.tier = GearItem.Tier.BASIC
	item.affixes = [modifier]
	return item


func _offer_ids(offers: Array[GearItem]) -> PackedStringArray:
	var ids: PackedStringArray = []
	for offer in offers:
		ids.append(offer.id)
	return ids
