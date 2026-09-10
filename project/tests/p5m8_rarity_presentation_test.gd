extends SceneTree
## Focused P5M8-T6 check: rarity colors and shared item-box treatments are
## scannable across the full Phase 5 rarity set, with Epic using documented
## white plus a distinct border/glow treatment.


func _initialize() -> void:
	print("-- P5M8 rarity presentation --")
	_check_tier_color_contract()
	_check_shared_item_box_styles()
	_check_epic_treatment_is_not_basic_or_empty()
	print("P5M8 rarity presentation check: OK")
	quit(0)


func _check_tier_color_contract() -> void:
	_require(UIColors.TIER_CRUDE == Color("8A8A7A"), "Expected Crude gray rarity color.")
	_require(UIColors.TIER_BASIC == Color("72B953"), "Expected Basic green rarity color.")
	_require(UIColors.TIER_MASTER == Color("4E8AC5"), "Expected Master blue rarity color.")
	_require(UIColors.TIER_EPIC == Color("F5F1DD"), "Expected Epic to use the documented white/light rarity color.")
	_require(UIColors.TIER_CURSED == Color("9D73D8"), "Expected Cursed purple rarity color.")
	_require(UIColors.TIER_CHAOS == Color("2A292F"), "Expected Chaos dark rarity color.")
	_require(UIColors.TIER_UNIQUE == Color("D6C547"), "Expected Unique yellow rarity color.")
	_require(UIColors.TIER_LEGENDARY == Color("E3914C"), "Expected Legendary orange rarity color.")
	for tier in GearItem.rarity_order():
		_require(GearGenerator.tier_color(tier) == CardStyle.rarity_fill_color(tier), "Expected shared rarity fill to match GearGenerator for %s." % GearGenerator.tier_name(tier))


func _check_shared_item_box_styles() -> void:
	for tier in GearItem.rarity_order():
		var item := _display_item(tier)
		var normal := CardStyle.make_gear_item_stylebox(item, false, "normal")
		var disabled := CardStyle.make_gear_item_stylebox(item, false, "disabled")
		_require(normal.bg_color == GearGenerator.tier_color(tier).darkened(0.08), "Expected normal item box fill to derive from tier color for %s." % GearGenerator.tier_name(tier))
		_require(disabled.bg_color == GearGenerator.tier_color(tier).darkened(0.35), "Expected disabled item box fill to mute tier color for %s." % GearGenerator.tier_name(tier))
		_require(disabled.border_color == UIColors.TEXT_DISABLED, "Expected disabled item box border to be muted for %s." % GearGenerator.tier_name(tier))


func _check_epic_treatment_is_not_basic_or_empty() -> void:
	var epic := _display_item(GearItem.Tier.EPIC)
	var basic := _display_item(GearItem.Tier.BASIC)
	var empty := CardStyle.make_gear_item_stylebox(null, false, "normal")
	var epic_normal := CardStyle.make_gear_item_stylebox(epic, false, "normal")
	var basic_normal := CardStyle.make_gear_item_stylebox(basic, false, "normal")
	var epic_equipped := CardStyle.make_gear_item_stylebox(epic, true, "normal")
	_require(epic_normal.bg_color != basic_normal.bg_color, "Expected Epic fill to differ from Basic.")
	_require(epic_normal.bg_color != empty.bg_color, "Expected Epic fill to differ from empty slot fill.")
	_require(epic_normal.border_color == UIColors.PANEL_EDGE_LIGHT, "Expected Epic item boxes to use a distinct bright border.")
	_require(epic_normal.border_width_top > basic_normal.border_width_top, "Expected Epic item boxes to have a stronger border than Basic.")
	_require(epic_normal.shadow_size > basic_normal.shadow_size, "Expected Epic item boxes to have a stronger glow/shadow treatment than Basic.")
	_require(epic_equipped.border_width_top >= epic_normal.border_width_top, "Expected equipped Epic slots to preserve the strong border treatment.")


func _display_item(tier: int) -> GearItem:
	var item := GearItem.new()
	item.id = "gear.test.p5m8.rarity_%s" % tier
	item.slot = GearItem.SlotType.ARMOR if tier != GearItem.Tier.LEGENDARY else GearItem.SlotType.WEAPON
	item.tier = tier
	item.class_family = GearItem.ClassFamily.ROGUE
	item.item_family = GearGenerator.rogue_item_family_for_slot(item.slot)
	item.source_kind = GearItem.SourceKind.GENERATED
	item.display_name = "%s %s" % [GearGenerator.tier_name(tier), item.item_family]
	return item


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
