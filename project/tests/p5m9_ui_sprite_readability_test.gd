extends SceneTree
## Focused P5M9-T6 live UI sprite readability capture for generated Rogue gear.

const OUT_DIR := "res://reports/p5m9_ui_readability"
const SCREENSHOT_SIZE := Vector2i(1344, 768)

var _screenshot_index := 1


func _initialize() -> void:
	DisplayServer.window_set_size(SCREENSHOT_SIZE)
	var output_path := ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_path)

	var build_state = root.get_node("BuildState")
	build_state.reset(true)

	print("-- P5M9 live UI sprite readability --")
	var combat_screen = await _build_combat_screen()
	var gear_panel = combat_screen.find_child("GearPanel", true, false)
	_require(gear_panel != null, "Expected live Gear panel.")

	var equipped_items := _p5m9_items("equipped", [
		[GearItem.SlotType.WEAPON, GearItem.Tier.EPIC],
		[GearItem.SlotType.HELM, GearItem.Tier.CURSED],
		[GearItem.SlotType.ARMOR, GearItem.Tier.CHAOS],
		[GearItem.SlotType.TRINKET, GearItem.Tier.UNIQUE],
		[GearItem.SlotType.CHARM, GearItem.Tier.MASTER],
	])
	var inventory_items := _p5m9_items("inventory", [
		[GearItem.SlotType.WEAPON, GearItem.Tier.UNIQUE],
		[GearItem.SlotType.HELM, GearItem.Tier.EPIC],
		[GearItem.SlotType.ARMOR, GearItem.Tier.CURSED],
	])
	var shop_items := _p5m9_items("shop", [
		[GearItem.SlotType.WEAPON, GearItem.Tier.BASIC],
		[GearItem.SlotType.HELM, GearItem.Tier.MASTER],
		[GearItem.SlotType.ARMOR, GearItem.Tier.EPIC],
		[GearItem.SlotType.TRINKET, GearItem.Tier.CHAOS],
		[GearItem.SlotType.CHARM, GearItem.Tier.UNIQUE],
	])
	var reward_items := _p5m9_items("reward", [
		[GearItem.SlotType.WEAPON, GearItem.Tier.CURSED],
		[GearItem.SlotType.HELM, GearItem.Tier.CHAOS],
		[GearItem.SlotType.ARMOR, GearItem.Tier.UNIQUE],
		[GearItem.SlotType.TRINKET, GearItem.Tier.EPIC],
		[GearItem.SlotType.CHARM, GearItem.Tier.CURSED],
	])

	await _capture_gear_panel_and_inventory(combat_screen, gear_panel, build_state, equipped_items, inventory_items)
	await _capture_shop(combat_screen, build_state, shop_items)
	await _capture_reward_choices(combat_screen, build_state, reward_items)
	await _capture_comparison_tooltips(combat_screen)
	combat_screen.queue_free()
	await process_frame

	await _capture_practice_room()

	_write_report([
		"Inventory/equipment icons: PASS",
		"Shop offer icons, including disabled offers: PASS",
		"Reward choice icons: PASS",
		"Comparison tooltip icons: PASS",
		"Practice Room paper doll icons: PASS",
		"Screenshots: %s" % output_path,
	])
	build_state.reset(true)
	print("P5M9 live UI sprite readability check: OK")
	quit(0)


func _build_combat_screen():
	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame
	await process_frame
	_hide_combat_overlays(combat_screen)
	return combat_screen


func _capture_gear_panel_and_inventory(combat_screen, gear_panel, build_state, equipped_items: Array, inventory_items: Array) -> void:
	build_state.reset(true)
	for item in equipped_items:
		build_state.equip(item)
	for item in inventory_items:
		_require(build_state.add_inventory_item(item), "Expected inventory item add for %s." % item.display_name)
	build_state.build_changed.emit()
	await process_frame
	await process_frame
	_hide_combat_overlays(combat_screen)

	_assert_button_icon(gear_panel._weapon_slot, equipped_items[0], "equipped Weapon")
	_assert_slot_background(gear_panel._weapon_slot, GearItem.SlotType.WEAPON, "equipped Weapon")
	_assert_button_icon(gear_panel._helm_slot, equipped_items[1], "equipped Helm")
	_assert_slot_background(gear_panel._helm_slot, GearItem.SlotType.HELM, "equipped Helm")
	_assert_button_icon(gear_panel._armor_slot, equipped_items[2], "equipped Armor")
	_assert_slot_background(gear_panel._armor_slot, GearItem.SlotType.ARMOR, "equipped Armor")
	_assert_button_icon(gear_panel._trinket_slot, equipped_items[3], "equipped Trinket")
	_assert_slot_background(gear_panel._trinket_slot, GearItem.SlotType.TRINKET, "equipped Trinket")
	_assert_button_icon(gear_panel._charm_slot, equipped_items[4], "equipped Charm")
	_assert_slot_background(gear_panel._charm_slot, GearItem.SlotType.CHARM, "equipped Charm")
	for item in inventory_items:
		_assert_button_icon(gear_panel._inventory_button_for_item(item), item, "inventory %s" % item.display_name)
	if gear_panel._inventory_grid.get_child_count() > inventory_items.size():
		_require((gear_panel._inventory_grid.get_child(inventory_items.size()) as Button).get_node_or_null("Icon") == null, "Expected empty inventory slots to stay icon-free.")
	await _save_viewport("combat_gear_panel_inventory")


func _capture_shop(combat_screen, build_state, shop_items: Array) -> void:
	build_state.gold = 20
	build_state.shop_round_pending = true
	build_state.shop_offers.clear()
	for item in shop_items:
		build_state.shop_offers.append(item)
	combat_screen._shop_overlay.refresh()
	_hide_combat_overlays(combat_screen)
	combat_screen._shop_overlay.visible = true
	combat_screen._shop_overlay.move_to_front()
	await process_frame
	await process_frame

	for i in shop_items.size():
		var button: Button = combat_screen._shop_overlay._shop_offers_box.get_child(i)
		_assert_button_icon(button, shop_items[i], "shop %s" % shop_items[i].display_name)
		_require(button.find_child("PriceBadge", true, false) != null, "Expected shop price badge.")
	_require(not (combat_screen._shop_overlay._shop_offers_box.get_child(0) as Button).disabled, "Expected Basic shop item to stay affordable.")
	_require((combat_screen._shop_overlay._shop_offers_box.get_child(1) as Button).disabled, "Expected Master shop item to show disabled-state readability.")
	await _save_viewport("shop_offers_disabled_and_affordable")
	combat_screen._shop_overlay.visible = false


func _capture_reward_choices(combat_screen, build_state, reward_items: Array) -> void:
	build_state.pending_reward_choices.clear()
	for item in reward_items:
		build_state.pending_reward_choices.append(item)
	_hide_combat_overlays(combat_screen)
	combat_screen._show_reward_choice_overlay()
	combat_screen._reward_choice_overlay.move_to_front()
	await process_frame
	await process_frame

	var options: HBoxContainer = combat_screen._reward_choice_overlay.options_container()
	_require(options.get_child_count() == reward_items.size(), "Expected reward choices for all five slots.")
	for i in reward_items.size():
		_assert_button_icon(options.get_child(i), reward_items[i], "reward %s" % reward_items[i].display_name)
	await _save_viewport("reward_choices_all_slots")
	combat_screen._reward_choice_overlay.visible = false


func _capture_comparison_tooltips(combat_screen) -> void:
	var build_state = root.get_node("BuildState")
	var equipped := _item("tooltip_equipped_helm", GearItem.SlotType.HELM, GearItem.Tier.MASTER)
	var candidate := _item("tooltip_candidate_helm", GearItem.SlotType.HELM, GearItem.Tier.CHAOS)
	build_state.reset(true)
	build_state.equip(equipped)
	build_state.pending_reward_choices.clear()
	build_state.pending_reward_choices.append(candidate)
	_hide_combat_overlays(combat_screen)
	combat_screen._show_reward_choice_overlay()
	combat_screen._reward_choice_overlay.move_to_front()
	await process_frame

	var button: Button = combat_screen._reward_choice_overlay.options_container().get_child(0)
	var tooltip: Control = button._make_custom_tooltip("")
	tooltip.position = Vector2(36, 36)
	root.add_child(tooltip)
	await process_frame
	_assert_texture_in_tree(tooltip, GearIcons.icon_for(candidate), "candidate comparison tooltip")
	_assert_texture_in_tree(tooltip, GearIcons.icon_for(equipped), "equipped comparison tooltip")
	await _save_viewport("comparison_tooltip_pair")
	tooltip.queue_free()
	combat_screen._reward_choice_overlay.visible = false
	await process_frame


func _capture_practice_room() -> void:
	var training_scene: PackedScene = load("res://scenes/training_room/training_room.tscn")
	var training_room = training_scene.instantiate()
	root.add_child(training_room)
	await process_frame
	await process_frame

	training_room._state.set_slot_rarity(training_room._state.practice_weapon, GearItem.Tier.UNIQUE)
	training_room._state.set_slot_rarity(training_room._state.practice_helm, GearItem.Tier.EPIC)
	training_room._state.set_slot_rarity(training_room._state.practice_armor, GearItem.Tier.CURSED)
	training_room._state.set_slot_rarity(training_room._state.practice_trinket, GearItem.Tier.CHAOS)
	training_room._state.set_slot_rarity(training_room._state.practice_charm, GearItem.Tier.MASTER)
	training_room._refresh_paper_doll_slots()
	await process_frame
	await process_frame

	_assert_button_icon(training_room._weapon_slot_button, training_room._state.equipped_weapon, "Practice Room Weapon")
	_assert_slot_background(training_room._weapon_slot_button, GearItem.SlotType.WEAPON, "Practice Room Weapon")
	_assert_button_icon(training_room._helm_slot_button, training_room._state.equipped_helm, "Practice Room Helm")
	_assert_slot_background(training_room._helm_slot_button, GearItem.SlotType.HELM, "Practice Room Helm")
	_assert_button_icon(training_room._armor_slot_button, training_room._state.equipped_armor, "Practice Room Armor")
	_assert_slot_background(training_room._armor_slot_button, GearItem.SlotType.ARMOR, "Practice Room Armor")
	_assert_button_icon(training_room._trinket_slot_button, training_room._state.equipped_trinket, "Practice Room Trinket")
	_assert_slot_background(training_room._trinket_slot_button, GearItem.SlotType.TRINKET, "Practice Room Trinket")
	_assert_button_icon(training_room._charm_slot_button, training_room._state.equipped_charm, "Practice Room Charm")
	_assert_slot_background(training_room._charm_slot_button, GearItem.SlotType.CHARM, "Practice Room Charm")
	await _save_viewport("practice_room_paper_doll")
	training_room.queue_free()


func _p5m9_items(context: String, specs: Array) -> Array:
	var items: Array = []
	for spec in specs:
		items.append(_item("%s_%s_%s" % [context, spec[0], spec[1]], spec[0], spec[1]))
	return items


func _hide_combat_overlays(combat_screen) -> void:
	for property in [
		"_story_overlay",
		"_map_overlay",
		"_contract_overlay",
		"_shop_overlay",
		"_reward_choice_overlay",
		"_secondary_subclass_overlay",
		"_talent_overlay",
		"_log_overlay",
		"_monster_manual_overlay",
	]:
		var overlay = combat_screen.get(property)
		if overlay != null and overlay is CanvasItem:
			overlay.visible = false


func _item(id_suffix: String, slot: int, tier: int) -> GearItem:
	var rng := RandomNumberGenerator.new()
	rng.seed = abs(hash("p5m9_t6:%s" % id_suffix))
	var result := GearGenerator.generate_from_request({
		"tier": tier,
		"slot": slot,
		"rng": rng,
		"id": "gear.test.p5m9.t6.%s" % id_suffix,
		"deterministic_key": "p5m9_t6:%s" % id_suffix,
		"source_context": "p5m9_ui_sprite_readability",
		"source_seed": rng.seed,
	})
	_require(bool(result.get("ok", false)), "Expected generated P5M9 item for %s: %s" % [id_suffix, result.get("errors", [])])
	var item: GearItem = result["item"]
	item.display_name = "%s %s" % [GearGenerator.tier_name(tier), GearGenerator.rogue_item_family_for_slot(slot)]
	return item


func _assert_button_icon(button: Control, gear: GearItem, surface: String) -> void:
	_require(button != null, "Expected button for %s." % surface)
	var icon := button.get_node_or_null("Icon") as TextureRect
	_require(icon != null, "Expected icon node for %s." % surface)
	_require(icon.texture == GearIcons.icon_for(gear), "Expected %s to use mapped generated icon." % surface)
	_require(icon.texture != null, "Expected icon texture for %s." % surface)
	_require(icon.texture.resource_path == _expected_icon_path(gear), "Expected %s icon path %s, got %s." % [surface, _expected_icon_path(gear), icon.texture.resource_path])
	_require(icon.get_global_rect().size.x >= 32.0 and icon.get_global_rect().size.y >= 32.0, "Expected readable icon rect for %s, got %s." % [surface, icon.get_global_rect()])


func _assert_slot_background(button: Control, gear_slot: int, surface: String) -> void:
	var background := button.get_node_or_null("SlotTypeBackground") as TextureRect
	var icon := button.get_node_or_null("Icon") as TextureRect
	_require(background != null, "Expected slot type background for %s." % surface)
	_require(background.texture == GearIcons.slot_background_for(gear_slot), "Expected mapped slot type background for %s." % surface)
	_require(background.get_index() < icon.get_index(), "Expected slot type background behind item icon for %s." % surface)
	_require(background.get_global_rect().size.x >= 32.0 and background.get_global_rect().size.y >= 32.0, "Expected readable slot type background rect for %s." % surface)


func _assert_texture_in_tree(root_node: Node, texture: Texture2D, surface: String) -> void:
	for child in root_node.find_children("*", "TextureRect", true, false):
		var rect := child as TextureRect
		if rect.texture == texture:
			_require(rect.get_global_rect().size.x >= 32.0 and rect.get_global_rect().size.y >= 32.0, "Expected readable texture rect for %s." % surface)
			return
	_require(false, "Expected texture in %s." % surface)


func _expected_icon_path(gear: GearItem) -> String:
	var family := GearGenerator.rogue_item_family_for_slot(gear.slot).to_lower()
	var tier_name := GearGenerator.tier_name(gear.tier).to_lower()
	if gear.slot == GearItem.SlotType.WEAPON:
		family = "dagger"
	return "res://assets/Items/Rogue/Generated/rogue_%s_%s.png" % [family, tier_name]


func _save_viewport(label: String) -> void:
	await root.get_viewport().get_tree().process_frame
	var image := root.get_viewport().get_texture().get_image()
	var path := "%s/%02d_%s.png" % [OUT_DIR, _screenshot_index, label]
	var error := image.save_png(path)
	_require(error == OK, "Expected screenshot save for %s, got error %s." % [label, error])
	_screenshot_index += 1


func _write_report(lines: Array[String]) -> void:
	var file := FileAccess.open("%s/README.md" % OUT_DIR, FileAccess.WRITE)
	_require(file != null, "Expected P5M9 UI readability report file.")
	file.store_line("# P5M9 UI Sprite Readability")
	file.store_line("")
	for line in lines:
		file.store_line("- %s" % line)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
