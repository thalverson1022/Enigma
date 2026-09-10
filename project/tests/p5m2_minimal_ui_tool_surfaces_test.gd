extends SceneTree
## Focused P5M2-T8 check: minimal UI/tool surfaces can display the Phase 5
## gear vocabulary without blank icons, stale Rogue family names, or raw-only
## generated route reward metadata.

const GeneratedRouteInspectorScript := preload("res://scripts/tools/generated_route_inspector.gd")


func _initialize() -> void:
	print("-- P5M2 minimal UI/tool surfaces --")
	_check_tooltips_and_icons_cover_all_slots()
	_check_tooltips_and_icons_cover_all_rarities()
	_check_practice_room_uses_rogue_families()
	_check_generated_route_inspector_labels_rewards()
	_check_shop_lab_current_scope_note()
	print("P5M2 minimal UI/tool surfaces check: OK")
	quit(0)


func _check_tooltips_and_icons_cover_all_slots() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 8128
	for slot in GearItem.universal_slot_order():
		var item: GearItem = GearGenerator.generate(GearItem.Tier.BASIC, slot, rng, "gear.test.ui_slot_%s" % slot)
		var lines := CardStyle.gear_tooltip_lines(item)
		_require(lines[0] == item.display_name, "Expected item name to start tooltip for slot %s." % slot)
		_require(lines[1] == "Basic %s / %s" % [GearGenerator.universal_slot_label(slot), GearGenerator.rogue_item_family_for_slot(slot)], "Expected rarity, universal slot, and Rogue family in tooltip for slot %s." % slot)
		_require(GearIcons.icon_for(item) != null, "Expected a visible icon fallback for slot %s." % slot)


func _check_tooltips_and_icons_cover_all_rarities() -> void:
	for tier in GearItem.rarity_order():
		var item := _make_display_item(tier, GearItem.SlotType.ARMOR) if tier != GearItem.Tier.LEGENDARY else LegendaryCatalog.all_items()[0]
		var lines := CardStyle.gear_tooltip_lines(item)
		if tier != GearItem.Tier.LEGENDARY:
			_require(lines[1] == "%s Armor / Doublet" % GearGenerator.tier_name(tier), "Expected safe tier/slot/family label for tier %s." % tier)
		else:
			_require(lines[0] == item.display_name, "Expected named Legendary tooltip to keep its catalog identity.")
			_require(lines[1] == "Legendary Weapon / Dagger", "Expected named Legendary tooltip to show tier/slot/family.")
		_require(GearIcons.icon_for(item) != null, "Expected a visible icon fallback for tier %s." % tier)
		_require(GearGenerator.tier_color(tier) != UIColors.TRANSPARENT, "Expected a visible tier color for tier %s." % tier)


func _check_practice_room_uses_rogue_families() -> void:
	var state := TrainingRoomState.new()
	_require(state.practice_helm.display_name == "Custom Hood", "Expected Practice Helm to display as Hood.")
	_require(state.practice_armor.display_name == "Custom Doublet", "Expected Practice Armor to display as Doublet.")
	_require(state.practice_trinket.display_name == "Custom Ring", "Expected Practice Trinket to display as Ring.")
	_require(state.practice_charm.display_name == "Custom Necklace", "Expected Practice Charm to display as Necklace.")
	for item in [state.practice_weapon, state.practice_helm, state.practice_armor, state.practice_trinket, state.practice_charm]:
		_require(item.item_family == GearGenerator.rogue_item_family_for_slot(item.slot), "Expected Practice Room family metadata for %s." % item.display_name)


func _check_generated_route_inspector_labels_rewards() -> void:
	var report: Dictionary = GeneratedRouteInspectorScript.inspect(4242, {
		"route_difficulty": "medium",
		"allowed_biomes": ["Cave"],
	})
	var reward := _first_generated_gear_reward(report)
	_require(not reward.is_empty(), "Expected at least one generated gear reward in inspected route.")
	_require(String(reward.get("generated_gear_tier_label", "")) != "", "Expected generated reward tier label.")
	_require(not (reward.get("generated_gear_slot_labels", []) as Array).is_empty(), "Expected generated reward slot labels.")
	_require(not (reward.get("generated_gear_item_families", []) as Array).is_empty(), "Expected generated reward item families.")


func _check_shop_lab_current_scope_note() -> void:
	var file := FileAccess.open("res://../tools/shop-lab/README.md", FileAccess.READ)
	_require(file != null, "Expected Shop Lab README scope note.")
	var text := file.get_as_text()
	_require(text.contains("Project Enigma Phase 5"), "Expected Shop Lab README to name Phase 5.")
	_require(text.contains("Current Scope"), "Expected Shop Lab README to keep a current scope section.")
	_require(text.contains("five universal gear slots"), "Expected Shop Lab README to mention the five-slot model.")
	_require(text.contains("P5M6"), "Expected Shop Lab README to preserve its tuning-surface boundary.")
	_require(text.contains("final P5M8 player-facing item presentation"), "Expected Shop Lab README to defer final P5M8 presentation.")


func _make_display_item(tier: int, slot: int) -> GearItem:
	var item := GearItem.new()
	item.id = "gear.test.ui_tier_%s" % tier
	item.slot = slot
	item.tier = tier
	item.item_family = GearGenerator.rogue_item_family_for_slot(slot)
	item.class_family = GearItem.ClassFamily.ROGUE
	item.source_kind = GearItem.SourceKind.GENERATED
	item.display_name = "%s %s" % [GearGenerator.tier_name(tier), item.item_family]
	return item


func _first_generated_gear_reward(report: Dictionary) -> Dictionary:
	for node in report.get("nodes", []):
		var summary: Dictionary = node
		var reward: Dictionary = summary.get("reward", {})
		if int(reward.get("generated_gear_choice_count", 0)) > 0:
			return reward
	return {}


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
