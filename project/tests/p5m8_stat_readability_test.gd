extends SceneTree
## Focused P5M8-T5 check: stat and drawback text uses player-facing values,
## signs, and labels rather than raw ids or ambiguous multiplier shorthand.

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")


func _initialize() -> void:
	print("-- P5M8 stat readability --")
	_check_generated_value_kinds()
	_check_drawback_signs()
	_check_legacy_multiplier_wording()
	_check_card_uses_readable_lines()
	_check_non_chaos_stats_use_stable_order()
	_check_chaos_stats_keep_roll_order()
	_check_rich_tooltip_colors_and_bolds_max_rolls()
	print("P5M8 stat readability check: OK")
	quit(0)


func _check_generated_value_kinds() -> void:
	_require(StatModifierFormatter.format(_modifier(StatCatalog.BASE_DAMAGE, 4.0)) == "+4 Base Damage", "Expected flat stat wording.")
	_require(StatModifierFormatter.format(_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.18)) == "+18% Percent Physical Damage", "Expected percent stat wording.")
	_require(StatModifierFormatter.format(_modifier(StatCatalog.CRIT_CHANCE, 0.07)) == "+7% Crit Chance", "Expected chance stat wording.")
	_require(StatModifierFormatter.format(_modifier(StatCatalog.INCREASED_ALL_STACKS, 2.0)) == "+2 Increased All Stacks", "Expected stack stat wording.")
	_require(StatModifierFormatter.format(_modifier(StatCatalog.SHRED_VALUE, 10.0)) == "+10 Bonus Armor Shred", "Expected Shred value to read as armor shred, not stack count.")
	_require(StatModifierFormatter.format(_modifier(StatCatalog.CHANCE_FOR_RETRIGGER, 0.05, StatModifier.StatCategory.RARE)) == "+5% Chance for Retrigger", "Expected Rare chance wording.")
	_require(StatModifierFormatter.format(_modifier(StatCatalog.DOUBLE_APPLIED_STACKS, 1.0, StatModifier.StatCategory.SPECIAL)) == "Stacks you apply are doubled", "Expected binary Special wording.")


func _check_drawback_signs() -> void:
	_require(StatModifierFormatter.format(_modifier(StatCatalog.INCREASED_ATTACK_SPEED, -0.12, StatModifier.StatCategory.DRAWBACK, true)) == "-12% Increased Attack Speed", "Expected percent drawback sign.")
	_require(StatModifierFormatter.format(_modifier(StatCatalog.BASE_ELEMENTAL_DAMAGE, -8.0, StatModifier.StatCategory.DRAWBACK, true)) == "-8 Base Elemental Damage", "Expected flat drawback sign.")
	_require(StatModifierFormatter.format(_modifier(StatCatalog.INCREASED_ALL_STACKS, -2.0, StatModifier.StatCategory.DRAWBACK, true)) == "-2 Increased All Stacks", "Expected stack drawback sign.")


func _check_legacy_multiplier_wording() -> void:
	var physical := StatModifier.new()
	physical.stat = StatModifier.StatType.PHYSICAL_DAMAGE
	physical.operation = StatModifier.OperationType.MULTIPLY
	physical.value = 1.10
	_require(StatModifierFormatter.format(physical) == "x10% Physical Damage", "Expected legacy multiplier to read as a multiplicative bonus percent.")

	var physical_down := StatModifier.new()
	physical_down.stat = StatModifier.StatType.PHYSICAL_DAMAGE
	physical_down.operation = StatModifier.OperationType.MULTIPLY
	physical_down.value = 0.92
	physical_down.is_drawback = true
	_require(StatModifierFormatter.format(physical_down) == "-8% Physical Damage", "Expected legacy multiplier drawback to read as a penalty percent.")


func _check_card_uses_readable_lines() -> void:
	var item := GearItem.new()
	item.id = "gear.test.p5m8.readability"
	item.slot = GearItem.SlotType.CHARM
	item.tier = GearItem.Tier.CHAOS
	item.class_family = GearItem.ClassFamily.ROGUE
	item.item_family = GearGenerator.rogue_item_family_for_slot(item.slot)
	item.source_kind = GearItem.SourceKind.GENERATED
	item.display_name = "Readable Necklace"
	item.affixes = [
		_modifier(StatCatalog.CRIT_CHANCE, 0.08),
		_modifier(StatCatalog.CHANCE_TO_DECAY, 0.10, StatModifier.StatCategory.RARE),
		_modifier(StatCatalog.INCREASED_GOLD, -0.45, StatModifier.StatCategory.DRAWBACK, true),
	]
	var text := "\n".join(CardStyle.gear_tooltip_lines(item))
	_require(text.contains("+8% Crit Chance"), "Expected readable positive chance line, got: %s" % text)
	_require(text.contains("+10% Chance to Decay"), "Expected readable Rare chance line, got: %s" % text)
	_require(text.contains("-45% Increased Gold"), "Expected readable drawback line, got: %s" % text)
	_require(not text.contains("crit_chance"), "Expected hidden raw stat id, got: %s" % text)
	_require(not text.contains("chance_to_decay"), "Expected hidden raw Rare stat id, got: %s" % text)


func _check_non_chaos_stats_use_stable_order() -> void:
	var item := GearItem.new()
	item.display_name = "Sorted Doublet"
	item.slot = GearItem.SlotType.ARMOR
	item.tier = GearItem.Tier.EPIC
	item.item_family = GearGenerator.rogue_item_family_for_slot(item.slot)
	item.class_family = GearItem.ClassFamily.ROGUE
	item.affixes = [
		_modifier(StatCatalog.INCREASED_GOLD, 0.30),
		_modifier(StatCatalog.CRIT_CHANCE, 0.04),
		_modifier(StatCatalog.PERCENT_ELEMENTAL_DAMAGE, 0.40),
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.20),
	]
	var lines := CardStyle.gear_tooltip_lines(item)
	_require(lines.find("+20% Percent Physical Damage") < lines.find("+4% Crit Chance"), "Expected physical damage before crit chance: %s" % lines)
	_require(lines.find("+4% Crit Chance") < lines.find("+40% Percent Elemental Damage"), "Expected crit chance before elemental damage: %s" % lines)
	_require(lines.find("+40% Percent Elemental Damage") < lines.find("+30% Increased Gold"), "Expected elemental damage before gold: %s" % lines)


func _check_chaos_stats_keep_roll_order() -> void:
	var item := GearItem.new()
	item.display_name = "Rolled Necklace"
	item.slot = GearItem.SlotType.CHARM
	item.tier = GearItem.Tier.CHAOS
	item.item_family = GearGenerator.rogue_item_family_for_slot(item.slot)
	item.class_family = GearItem.ClassFamily.ROGUE
	item.source_kind = GearItem.SourceKind.GENERATED
	item.affixes = [
		_modifier(StatCatalog.INCREASED_GOLD, -0.45, StatModifier.StatCategory.DRAWBACK, true),
		_modifier(StatCatalog.CRIT_CHANCE, 0.08),
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.25),
	]
	var lines := CardStyle.gear_tooltip_lines(item)
	_require(not lines.has("Drawbacks:"), "Expected identified Chaos to keep all rolls in one ordered Stats block: %s" % lines)
	_require(lines.find("-45% Increased Gold") < lines.find("+8% Crit Chance"), "Expected Chaos drawback to stay in rolled position: %s" % lines)
	_require(lines.find("+8% Crit Chance") < lines.find("+25% Percent Physical Damage"), "Expected Chaos positives to stay in rolled position: %s" % lines)


func _check_rich_tooltip_colors_and_bolds_max_rolls() -> void:
	var item := GearItem.new()
	item.display_name = "Max Hood"
	item.slot = GearItem.SlotType.HELM
	item.tier = GearItem.Tier.BASIC
	item.item_family = GearGenerator.rogue_item_family_for_slot(item.slot)
	item.class_family = GearItem.ClassFamily.ROGUE
	item.generation_value_scale = 1.0
	item.generation_contract_depth = 1
	item.affixes = [
		_modifier(StatCatalog.INCREASED_ATTACK_SPEED, 0.07),
		_modifier(StatCatalog.CHANCE_TO_DECAY, 0.09, StatModifier.StatCategory.RARE),
		_modifier(StatCatalog.DOUBLE_APPLIED_STACKS, 1.0, StatModifier.StatCategory.SPECIAL),
		_modifier(StatCatalog.INCREASED_GOLD, -0.90, StatModifier.StatCategory.DRAWBACK, true),
	]
	var host := Control.new()
	root.add_child(host)
	var tooltip := CardStyle.build_gear_tooltip(host, item)
	var rich_text := _rich_tooltip_text(tooltip)
	for label in tooltip.find_children("*", "RichTextLabel", true, false):
		_require((label as RichTextLabel).custom_minimum_size.x <= CardStyle.TOOLTIP_RICH_MAX_WIDTH, "Expected rich tooltip stat rows to stay compact, got width: %s" % (label as RichTextLabel).custom_minimum_size.x)
		_require((label as RichTextLabel).custom_minimum_size.y == 0.0, "Expected rich tooltip stat rows to derive height from content, got: %s" % (label as RichTextLabel).custom_minimum_size.y)
	_require(rich_text.contains("[font_size=%d][b][color=#%s]+7%% Increased Attack Speed[/color][/b][/font_size]" % [
		CardStyle.TOOLTIP_RICH_MAX_ROLL_FONT_SIZE,
		CardStyle.STAT_COLOR_BASIC.to_html(false),
	]), "Expected max Basic roll to be basic-colored, bold, and one font size larger, got: %s" % rich_text)
	_require(rich_text.contains("[color=#" + CardStyle.STAT_COLOR_RARE.to_html(false) + "]+9% Chance to Decay[/color]"), "Expected Rare stat to be blue, got: %s" % rich_text)
	_require(rich_text.contains("[color=#" + CardStyle.STAT_COLOR_SPECIAL.to_html(false) + "]Stacks you apply are doubled[/color]"), "Expected Special stat to be yellow, got: %s" % rich_text)
	_require(rich_text.contains("[color=#" + CardStyle.STAT_COLOR_DRAWBACK.to_html(false) + "]-90% Increased Gold[/color]"), "Expected drawback to be red, got: %s" % rich_text)
	tooltip.free()
	host.free()


func _modifier(stat_id: String, value: float, category: StatModifier.StatCategory = StatModifier.StatCategory.BASIC, is_drawback: bool = false) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat_id = stat_id
	modifier.stat = _legacy_stat_for(stat_id)
	modifier.operation = StatModifier.OperationType.ADD
	modifier.category = category
	modifier.value = value
	modifier.is_drawback = is_drawback
	modifier.display_label = StatCatalog.label_for(stat_id)
	return modifier


func _legacy_stat_for(stat_id: String) -> StatModifier.StatType:
	match StatCatalog.canonicalize_stat_id(stat_id):
		StatCatalog.BASE_DAMAGE, StatCatalog.PERCENT_PHYSICAL_DAMAGE:
			return StatModifier.StatType.PHYSICAL_DAMAGE
		StatCatalog.INCREASED_ATTACK_SPEED:
			return StatModifier.StatType.ATTACK_SPEED
		StatCatalog.CRIT_CHANCE, StatCatalog.CHANCE_FOR_RETRIGGER, StatCatalog.CHANCE_TO_SHRED, StatCatalog.CHANCE_TO_DECAY, StatCatalog.CRIT_APPLIES_ELEMENT:
			return StatModifier.StatType.CRIT_CHANCE
		StatCatalog.CRIT_DAMAGE:
			return StatModifier.StatType.CRIT_MULTIPLIER
		StatCatalog.BASE_ELEMENTAL_DAMAGE, StatCatalog.PERCENT_ELEMENTAL_DAMAGE:
			return StatModifier.StatType.POISON_DAMAGE
		StatCatalog.INCREASED_ALL_STACKS:
			return StatModifier.StatType.ARMOR_REDUCTION
		StatCatalog.INCREASED_GOLD:
			return StatModifier.StatType.GOLD_REWARDS
	return StatModifier.StatType.ATTACK_SPEED


func _rich_tooltip_text(root_node: Node) -> String:
	var parts: PackedStringArray = []
	for label in root_node.find_children("*", "RichTextLabel", true, false):
		parts.append((label as RichTextLabel).text)
	return "\n".join(parts)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(false, message)
