extends SceneTree
## Focused P5M8-T9 check: final UI regression net for all-five-slot
## comparison tooltip routing, hidden generated metadata, and live Epic style
## application across inventory, shop, and reward choice surfaces.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var gear_panel = combat_screen.find_child("GearPanel", true, false)
	_require(gear_panel != null, "Expected live Gear panel.")

	print("-- P5M8 UI regression --")
	await _check_inventory_comparison_all_slots(combat_screen, gear_panel, build_state)
	await _check_shop_comparison_all_slots(combat_screen, build_state)
	await _check_reward_comparison_all_slots(combat_screen, build_state)
	await _check_live_epic_styles(combat_screen, gear_panel, build_state)
	await _check_adventure_equipped_max_stack_tooltip(combat_screen, gear_panel, build_state)
	print("P5M8 UI regression check: OK")
	quit(0)


func _check_inventory_comparison_all_slots(combat_screen, gear_panel, build_state) -> void:
	for slot in GearItem.universal_slot_order():
		build_state.reset()
		var equipped := _metadata_item("gear.test.p5m8.t9.inventory.equipped.%d" % slot, "Equipped %s" % GearGenerator.rogue_item_family_for_slot(slot), slot, GearItem.Tier.MASTER)
		var candidate := _metadata_item("gear.test.p5m8.t9.inventory.candidate.%d" % slot, "Candidate %s" % GearGenerator.rogue_item_family_for_slot(slot), slot, GearItem.Tier.BASIC)
		var decoy := _metadata_item("gear.test.p5m8.t9.inventory.decoy.%d" % slot, "Decoy %s" % GearGenerator.rogue_item_family_for_slot(_different_slot(slot)), _different_slot(slot), GearItem.Tier.UNIQUE)
		build_state.equip(equipped)
		build_state.equip(decoy)
		_require(build_state.add_inventory_item(candidate), "Expected inventory candidate for %s." % GearGenerator.universal_slot_label(slot))
		build_state.build_changed.emit()
		await combat_screen.get_tree().process_frame
		var button: Button = gear_panel._inventory_button_for_item(candidate)
		_require(button is GearCompareButton, "Expected inventory candidate to use GearCompareButton for %s." % GearGenerator.universal_slot_label(slot))
		var tooltip: Control = button._make_custom_tooltip("")
		_check_compare_tooltip(tooltip, candidate, equipped, [decoy])
		tooltip.free()


func _check_shop_comparison_all_slots(combat_screen, build_state) -> void:
	for slot in GearItem.universal_slot_order():
		build_state.reset()
		var equipped := _metadata_item("gear.test.p5m8.t9.shop.equipped.%d" % slot, "Shop Equipped %s" % GearGenerator.rogue_item_family_for_slot(slot), slot, GearItem.Tier.MASTER)
		var offer := _metadata_item("gear.test.p5m8.t9.shop.offer.%d" % slot, "Shop Offer %s" % GearGenerator.rogue_item_family_for_slot(slot), slot, GearItem.Tier.EPIC)
		var decoy := _metadata_item("gear.test.p5m8.t9.shop.decoy.%d" % slot, "Shop Decoy %s" % GearGenerator.rogue_item_family_for_slot(_different_slot(slot)), _different_slot(slot), GearItem.Tier.UNIQUE)
		build_state.equip(equipped)
		build_state.equip(decoy)
		build_state.gold = 999
		build_state.shop_round_pending = true
		build_state.shop_offers.clear()
		build_state.shop_offers.append(offer)
		combat_screen._shop_overlay.refresh()
		await combat_screen.get_tree().process_frame
		var button: Button = combat_screen._shop_overlay._shop_offers_box.get_child(0)
		_require(button is GearCompareButton, "Expected shop offer to use GearCompareButton for %s." % GearGenerator.universal_slot_label(slot))
		var tooltip: Control = button._make_custom_tooltip("")
		_check_compare_tooltip(tooltip, offer, equipped, [decoy])
		tooltip.free()


func _check_reward_comparison_all_slots(combat_screen, build_state) -> void:
	for slot in GearItem.universal_slot_order():
		build_state.reset()
		var equipped := _metadata_item("gear.test.p5m8.t9.reward.equipped.%d" % slot, "Reward Equipped %s" % GearGenerator.rogue_item_family_for_slot(slot), slot, GearItem.Tier.MASTER)
		var choice := _metadata_item("gear.test.p5m8.t9.reward.choice.%d" % slot, "Reward Choice %s" % GearGenerator.rogue_item_family_for_slot(slot), slot, GearItem.Tier.CHAOS)
		var decoy := _metadata_item("gear.test.p5m8.t9.reward.decoy.%d" % slot, "Reward Decoy %s" % GearGenerator.rogue_item_family_for_slot(_different_slot(slot)), _different_slot(slot), GearItem.Tier.UNIQUE)
		build_state.equip(equipped)
		build_state.equip(decoy)
		build_state.pending_reward_choices.clear()
		build_state.pending_reward_choices.append(choice)
		combat_screen._show_reward_choice_overlay()
		await combat_screen.get_tree().process_frame
		var button: Button = combat_screen._reward_choice_overlay.options_container().get_child(0)
		_require(button is GearCompareButton, "Expected reward choice to use GearCompareButton for %s." % GearGenerator.universal_slot_label(slot))
		var tooltip: Control = button._make_custom_tooltip("")
		_check_compare_tooltip(tooltip, choice, equipped, [decoy])
		tooltip.free()
		combat_screen._reward_choice_overlay.visible = false


func _check_live_epic_styles(combat_screen, gear_panel, build_state) -> void:
	build_state.reset()
	var epic_inventory := _metadata_item("gear.test.p5m8.t9.epic.inventory", "Epic Inventory Doublet", GearItem.SlotType.ARMOR, GearItem.Tier.EPIC)
	var epic_equipped := _metadata_item("gear.test.p5m8.t9.epic.equipped", "Epic Equipped Hood", GearItem.SlotType.HELM, GearItem.Tier.EPIC)
	var epic_offer := _metadata_item("gear.test.p5m8.t9.epic.offer", "Epic Shop Dagger", GearItem.SlotType.WEAPON, GearItem.Tier.EPIC)
	var epic_choice := _metadata_item("gear.test.p5m8.t9.epic.choice", "Epic Reward Ring", GearItem.SlotType.TRINKET, GearItem.Tier.EPIC)
	build_state.equip(epic_equipped)
	_require(build_state.add_inventory_item(epic_inventory), "Expected Epic inventory item.")
	build_state.shop_round_pending = true
	build_state.shop_offers.clear()
	build_state.shop_offers.append(epic_offer)
	build_state.pending_reward_choices.clear()
	build_state.pending_reward_choices.append(epic_choice)
	build_state.build_changed.emit()
	combat_screen._shop_overlay.refresh()
	combat_screen._show_reward_choice_overlay()
	await combat_screen.get_tree().process_frame

	_check_epic_style(gear_panel._helm_slot.get_theme_stylebox("panel") as StyleBoxFlat, "equipped Helm")
	_check_epic_style(gear_panel._inventory_button_for_item(epic_inventory).get_theme_stylebox("normal") as StyleBoxFlat, "inventory")
	_check_epic_style(combat_screen._shop_overlay._shop_offers_box.get_child(0).get_theme_stylebox("normal") as StyleBoxFlat, "shop")
	_check_epic_style(combat_screen._reward_choice_overlay.options_container().get_child(0).get_theme_stylebox("normal") as StyleBoxFlat, "reward")


func _check_compare_tooltip(tooltip: Control, candidate: GearItem, equipped: GearItem, decoys: Array) -> void:
	_require(tooltip is HBoxContainer, "Expected comparison tooltip row.")
	_require(tooltip.get_child_count() == 2, "Expected item and Equipped tooltip boxes.")
	var item_box: Control = tooltip.get_child(0)
	var equipped_box: Control = tooltip.get_child(1)
	var item_text: String = _labels_text(item_box)
	var equipped_text: String = _labels_text(equipped_box)
	_require(equipped_text.begins_with("Equipped"), "Expected Equipped comparison header.")
	_require(item_text.contains(candidate.display_name), "Expected candidate item text, got: %s" % item_text)
	_require(equipped_text.contains(equipped.display_name), "Expected equipped same-slot item text, got: %s" % equipped_text)
	_require(equipped_text.contains("%s %s / %s" % [GearGenerator.tier_name(equipped.tier), GearGenerator.universal_slot_label(equipped.slot), GearGenerator.item_family_for(equipped)]), "Expected equipped same-slot header, got: %s" % equipped_text)
	for decoy in decoys:
		_require(not equipped_text.contains(decoy.display_name), "Expected comparison to ignore decoy slot item %s, got: %s" % [decoy.display_name, equipped_text])
	_require(_hides_metadata(item_text, candidate), "Expected candidate metadata hidden, got: %s" % item_text)
	_require(_hides_metadata(equipped_text, equipped), "Expected equipped metadata hidden, got: %s" % equipped_text)


func _check_epic_style(style: StyleBoxFlat, surface_name: String) -> void:
	_require(style != null, "Expected Epic style for %s." % surface_name)
	_require(style.bg_color == UIColors.TIER_EPIC.darkened(0.08), "Expected Epic fill on %s." % surface_name)
	_require(style.border_width_top >= 2, "Expected distinct Epic border width on %s." % surface_name)
	_require(style.shadow_size >= 5, "Expected distinct Epic glow/shadow on %s." % surface_name)


func _check_adventure_equipped_max_stack_tooltip(combat_screen, gear_panel, build_state) -> void:
	build_state.reset()
	var max_stack_result := GearGenerator.max_rolled_value_for_stat_id(
		StatCatalog.INCREASED_ALL_STACKS,
		GearItem.SlotType.HELM,
		false,
		GearItem.Tier.MASTER
	)
	_require(bool(max_stack_result.get("ok", false)), "Expected Master stack max lookup to succeed.")
	_require(is_equal_approx(float(max_stack_result["value"]), 4.0), "Expected Master Increased All Stacks max to round to +4.")

	var helm := GearItem.new()
	helm.id = "gear.test.p5m8.adventure.max_stack"
	helm.display_name = "Max Stack Hood"
	helm.slot = GearItem.SlotType.HELM
	helm.tier = GearItem.Tier.MASTER
	helm.class_family = GearItem.ClassFamily.ROGUE
	helm.item_family = GearGenerator.rogue_item_family_for_slot(helm.slot)
	helm.affixes = [_modifier(StatCatalog.INCREASED_ALL_STACKS, 4.0)]
	build_state.equip(helm)
	build_state.build_changed.emit()
	await combat_screen.get_tree().process_frame

	var tooltip: Control = gear_panel._helm_slot._make_custom_tooltip("")
	var rich_text := _rich_text(tooltip)
	_require(rich_text.contains("[font_size=%d][b][color=#%s]+4 Increased All Stacks[/color][/b][/font_size]" % [
		CardStyle.TOOLTIP_RICH_MAX_ROLL_FONT_SIZE,
		CardStyle.STAT_COLOR_BASIC.to_html(false),
	]), "Expected Adventure equipped max stack tooltip to be larger, bold, and colored, got: %s" % rich_text)
	tooltip.free()


func _metadata_item(id: String, display_name: String, slot: GearItem.SlotType, tier: GearItem.Tier) -> GearItem:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(id)
	var result := GearGenerator.generate_from_request({
		"tier": tier,
		"slot": slot,
		"rng": rng,
		"id": id,
		"deterministic_key": "%s:key" % id,
		"source_context": "p5m8_t9_ui_regression",
		"source_seed": abs(hash("%s:seed" % id)),
	})
	_require(bool(result.get("ok", false)), "Expected generated item for %s: %s" % [id, result.get("errors", [])])
	var item: GearItem = result["item"]
	item.display_name = display_name
	return item


func _modifier(stat_id: String, value: float, category: StatModifier.StatCategory = StatModifier.StatCategory.BASIC, is_drawback: bool = false) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat_id = stat_id
	modifier.stat = StatModifier.StatType.POISON_STACKS_APPLIED
	modifier.operation = StatModifier.OperationType.ADD
	modifier.category = category
	modifier.value = value
	modifier.is_drawback = is_drawback
	modifier.display_label = StatCatalog.label_for(stat_id)
	return modifier


func _different_slot(slot: GearItem.SlotType) -> GearItem.SlotType:
	for candidate in GearItem.universal_slot_order():
		if candidate != slot:
			return candidate
	return GearItem.SlotType.WEAPON


func _hides_metadata(text: String, item: GearItem) -> bool:
	return (
		not text.contains(item.id)
		and not text.contains(item.deterministic_key)
		and not text.contains(item.source_context)
		and not text.contains(str(item.source_seed))
		and not text.contains("source_seed")
		and not text.contains("deterministic_key")
		and not text.contains("source_context")
	)


func _labels_text(root_node: Node) -> String:
	var lines: PackedStringArray = []
	for label in root_node.find_children("*", "Label", true, false):
		lines.append((label as Label).text)
	return "\n".join(lines)


func _rich_text(root_node: Node) -> String:
	var lines: PackedStringArray = []
	for label in root_node.find_children("*", "RichTextLabel", true, false):
		lines.append((label as RichTextLabel).text)
	return "\n".join(lines)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
