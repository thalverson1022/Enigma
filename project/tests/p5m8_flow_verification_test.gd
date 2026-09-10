extends SceneTree
## Focused P5M8-T8 check: inventory/equipment, reward choice, shop, sell, and
## save/load flows keep routing all five universal gear slots by slot enum.

const SaveSystemScript := preload("res://scripts/systems/save_system.gd")
const TEST_SAVE_PATH := "res://.test_p5m8_flow_verification_save.json"


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	SaveSystemScript.save_path = TEST_SAVE_PATH
	SaveSystemScript.delete_save()

	print("-- P5M8 flow verification --")
	_check_all_five_direct_equip_replace_unequip(build_state)
	_check_all_five_inventory_equip(build_state)
	_check_all_five_shop_buy_and_sell(build_state)
	_check_all_five_reward_choice_claim(build_state)
	_check_full_inventory_blocks_reward_and_shop(build_state)
	_check_save_load_after_flow_changes(build_state)

	SaveSystemScript.delete_save()
	SaveSystemScript.save_path = SaveSystemScript.SAVE_PATH
	build_state.reset()
	print("P5M8 flow verification check: OK")
	quit(0)


func _check_all_five_direct_equip_replace_unequip(build_state) -> void:
	build_state.reset()
	for slot in GearItem.universal_slot_order():
		var first := _make_item("gear.test.p5m8.direct.%d.first" % slot, slot)
		var replacement := _make_item("gear.test.p5m8.direct.%d.replacement" % slot, slot)
		build_state.equip(first)
		_require(build_state.equipped_item_for_slot(slot) == first, "Expected direct equip for %s." % GearGenerator.universal_slot_label(slot))
		build_state.equip(replacement)
		_require(build_state.equipped_item_for_slot(slot) == replacement, "Expected replacement equip for %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.has_inventory_item(first), "Expected replaced %s item to move to inventory." % GearGenerator.universal_slot_label(slot))
		build_state.unequip(slot)
		_require(build_state.equipped_item_for_slot(slot) == null, "Expected unequip to clear %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.has_inventory_item(replacement), "Expected unequipped %s item to move to inventory." % GearGenerator.universal_slot_label(slot))


func _check_all_five_inventory_equip(build_state) -> void:
	build_state.reset()
	for slot in GearItem.universal_slot_order():
		var item := _make_item("gear.test.p5m8.inventory.%d" % slot, slot)
		_require(build_state.add_inventory_item(item), "Expected inventory add for %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.equip_from_inventory(item), "Expected inventory equip for %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.equipped_item_for_slot(slot) == item, "Expected inventory item to equip into %s." % GearGenerator.universal_slot_label(slot))
		_require(not build_state.has_inventory_item(item), "Expected equipped %s item to leave inventory." % GearGenerator.universal_slot_label(slot))
		_require(_slot_field_matches(build_state, slot, item), "Expected concrete equipped field to match %s." % GearGenerator.universal_slot_label(slot))


func _check_all_five_shop_buy_and_sell(build_state) -> void:
	build_state.reset()
	build_state.shop_round_pending = true
	for slot in GearItem.universal_slot_order():
		var offer := _make_item("gear.test.p5m8.shop.%d" % slot, slot, GearItem.Tier.BASIC)
		build_state.inventory.clear()
		build_state.gold = 999
		build_state.shop_offers.clear()
		build_state.shop_offers.append(offer)
		var gold_before: int = build_state.gold
		_require(build_state.buy_shop_offer(offer), "Expected shop buy for %s." % GearGenerator.universal_slot_label(offer.slot))
		_require(build_state.gold == gold_before - GearGenerator.price_for_tier(offer.tier), "Expected shop buy to spend gold for %s." % GearGenerator.universal_slot_label(offer.slot))
		_require(build_state.has_inventory_item(offer), "Expected bought %s offer to enter inventory." % GearGenerator.universal_slot_label(offer.slot))
		_require(not build_state.shop_offers.has(offer), "Expected bought %s offer to leave shop offers." % GearGenerator.universal_slot_label(offer.slot))

	for slot in GearItem.universal_slot_order():
		build_state.reset()
		build_state.shop_round_pending = true
		build_state.gold = 100
		var sold_from_inventory := _make_item("gear.test.p5m8.shop.sell_inventory.%d" % slot, slot)
		_require(build_state.add_inventory_item(sold_from_inventory), "Expected inventory item before sale for %s." % GearGenerator.universal_slot_label(slot))
		var inventory_sale_before: int = build_state.gold
		_require(build_state.sell_inventory_item(sold_from_inventory), "Expected inventory sale during shop for %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.gold == inventory_sale_before + build_state.sell_value_for(sold_from_inventory), "Expected inventory sale to add gold for %s." % GearGenerator.universal_slot_label(slot))
		_require(not build_state.has_inventory_item(sold_from_inventory), "Expected sold inventory item to leave inventory for %s." % GearGenerator.universal_slot_label(slot))

		var equipped_sale := _make_item("gear.test.p5m8.shop.sell_equipped.%d" % slot, slot)
		build_state.equip(equipped_sale)
		var equipped_sale_before: int = build_state.gold
		_require(build_state.sell_equipped_item(slot), "Expected equipped sale during shop for %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.gold == equipped_sale_before + build_state.sell_value_for(equipped_sale), "Expected equipped sale to add gold for %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.equipped_item_for_slot(slot) == null, "Expected equipped sale to clear %s." % GearGenerator.universal_slot_label(slot))


func _check_all_five_reward_choice_claim(build_state) -> void:
	build_state.reset()
	for slot in GearItem.universal_slot_order():
		var choice := _make_item("gear.test.p5m8.reward.%d" % slot, slot)
		build_state.pending_reward_choices.clear()
		build_state.pending_reward_choices.append(choice)
		_require(build_state.has_pending_reward_choice(), "Expected pending reward choice for %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.can_choose_pending_reward_gear(choice), "Expected reward choice to be choosable for %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.choose_pending_reward_gear(choice), "Expected reward choice claim for %s." % GearGenerator.universal_slot_label(slot))
		_require(not build_state.has_pending_reward_choice(), "Expected reward choices to clear after choosing %s." % GearGenerator.universal_slot_label(slot))
		_require(build_state.has_inventory_item(choice), "Expected non-Legendary reward choice to enter inventory for %s." % GearGenerator.universal_slot_label(slot))
		build_state.inventory.clear()

	var legendary: GearItem = load("res://data/gear/wyvern_kriss.tres")
	build_state.pending_reward_choices.clear()
	build_state.pending_reward_choices.append(legendary)
	_require(build_state.choose_pending_reward_gear(legendary), "Expected Legendary reward choice to auto-equip.")
	_require(build_state.equipped_weapon == legendary, "Expected Legendary reward to equip to Weapon.")
	_require(not build_state.has_inventory_item(legendary), "Expected Legendary reward not to consume inventory.")


func _check_full_inventory_blocks_reward_and_shop(build_state) -> void:
	build_state.reset()
	_fill_inventory(build_state)
	var reward_choice := _make_item("gear.test.p5m8.blocked_reward", GearItem.SlotType.CHARM)
	build_state.pending_reward_choices.clear()
	build_state.pending_reward_choices.append(reward_choice)
	_require(not build_state.can_choose_pending_reward_gear(reward_choice), "Expected full inventory to block non-Legendary reward choice.")
	_require(not build_state.choose_pending_reward_gear(reward_choice), "Expected blocked reward choice not to mutate state.")
	_require(build_state.has_pending_reward_choice(), "Expected blocked reward choices to remain pending.")
	_require(not build_state.has_inventory_item(reward_choice), "Expected blocked reward choice not to enter inventory.")

	build_state.gold = 999
	build_state.shop_round_pending = true
	var shop_offer := _make_item("gear.test.p5m8.blocked_shop", GearItem.SlotType.TRINKET)
	build_state.shop_offers.clear()
	build_state.shop_offers.append(shop_offer)
	_require(not build_state.can_store_shop_offer(shop_offer), "Expected full inventory to block shop storage.")
	_require(not build_state.buy_shop_offer(shop_offer), "Expected full inventory to block shop buy.")
	_require(build_state.gold == 999, "Expected blocked shop buy not to spend gold.")
	_require(build_state.shop_offers.has(shop_offer), "Expected blocked shop buy to leave offer available.")


func _check_save_load_after_flow_changes(build_state) -> void:
	build_state.reset()
	var equipped := {}
	for slot in GearItem.universal_slot_order():
		var item := _make_item("gear.test.p5m8.saved.%d" % slot, slot, GearItem.Tier.MASTER)
		build_state.equip(item)
		equipped[slot] = item.id
	var inventory_item := _make_item("gear.test.p5m8.saved.inventory", GearItem.SlotType.CHARM)
	_require(build_state.add_inventory_item(inventory_item), "Expected saved inventory item.")
	var pending_choice := _make_item("gear.test.p5m8.saved.pending", GearItem.SlotType.ARMOR)
	build_state.pending_reward_choices.clear()
	build_state.pending_reward_choices.append(pending_choice)
	build_state.gold = 123
	build_state.shop_round_pending = true
	build_state.shop_reroll_count = 1
	build_state.shop_reroll_cost = 10
	build_state.shop_offers.clear()
	build_state.shop_offers.append(_make_item("gear.test.p5m8.saved.offer", GearItem.SlotType.WEAPON))

	_require(SaveSystemScript.save_run(build_state), "Expected T8 save to write.")
	build_state.reset()
	_require(SaveSystemScript.load_run(build_state), "Expected T8 save to load.")
	for slot in GearItem.universal_slot_order():
		var loaded: GearItem = build_state.equipped_item_for_slot(slot)
		_require(loaded != null and loaded.id == equipped[slot], "Expected saved equipped %s to roundtrip." % GearGenerator.universal_slot_label(slot))
		_require(loaded.slot == slot, "Expected saved equipped slot enum to roundtrip for %s." % GearGenerator.universal_slot_label(slot))
	_require(build_state.inventory.size() == 1 and build_state.inventory[0].id == inventory_item.id, "Expected inventory item to roundtrip.")
	_require(build_state.pending_reward_choices.size() == 1 and build_state.pending_reward_choices[0].id == pending_choice.id, "Expected pending reward choice to roundtrip.")
	_require(build_state.shop_round_pending, "Expected shop round pending to roundtrip.")
	_require(build_state.shop_offers.size() == 1, "Expected shop offer to roundtrip.")
	_require(build_state.gold == 123, "Expected gold to roundtrip.")


func _fill_inventory(build_state) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 8818
	while build_state.inventory.size() < build_state.INVENTORY_CAPACITY:
		var slot: GearItem.SlotType = GearItem.universal_slot_order()[build_state.inventory.size() % GearItem.universal_slot_order().size()]
		_require(build_state.add_inventory_item(GearGenerator.generate(GearItem.Tier.BASIC, slot, rng, "gear.test.p5m8.fill.%d" % build_state.inventory.size())), "Expected inventory filler add.")


func _make_item(id: String, slot: GearItem.SlotType, tier: GearItem.Tier = GearItem.Tier.BASIC) -> GearItem:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id)
	return GearGenerator.generate(tier, slot, rng, id)


func _slot_field_matches(build_state, slot: GearItem.SlotType, item: GearItem) -> bool:
	match slot:
		GearItem.SlotType.WEAPON:
			return build_state.equipped_weapon == item
		GearItem.SlotType.HELM:
			return build_state.equipped_helm == item
		GearItem.SlotType.ARMOR:
			return build_state.equipped_armor == item
		GearItem.SlotType.TRINKET:
			return build_state.equipped_trinket == item
		GearItem.SlotType.CHARM:
			return build_state.equipped_charm == item
	return false


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
