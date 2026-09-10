extends SceneTree
## Headless check for GearGenerator's procedural tier structure. Run with:
##   godot --headless -s res://tests/gear_generator_test.gd
## Verifies the P5M5 procedural rarity count surface while later P5M5 tasks
## fill in final Unique tuning.


func _initialize() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1

	var basic := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.WEAPON, rng)
	print("basic affixes=%d (expect 1)" % basic.affixes.size())
	assert(basic.affixes.size() == 1)
	assert(basic.display_name.contains("Dagger"))
	assert(GearGenerator.rogue_item_family_for_slot(GearItem.SlotType.WEAPON) == "Dagger")
	assert(GearGenerator.rogue_item_family_for_slot(GearItem.SlotType.TRINKET) == "Ring")
	assert(GearGenerator.rogue_item_family_for_slot(GearItem.SlotType.CHARM) == "Necklace")
	assert(GearGenerator.universal_slot_label(GearItem.SlotType.WEAPON) == "Weapon")
	assert(GearGenerator.universal_slot_label(GearItem.SlotType.TRINKET) == "Trinket")
	assert(GearGenerator.universal_slot_label(GearItem.SlotType.CHARM) == "Charm")
	assert(GearGenerator.PREFIX_BY_STAT[StatModifier.StatType.CRIT_CHANCE] == "Sharp")
	assert(GearGenerator.SUFFIX_BY_STAT[StatModifier.StatType.CRIT_CHANCE] == "of Sharpness")
	assert(GearGenerator.PREFIX_BY_STAT[StatModifier.StatType.GOLD_REWARDS] == "Greedy")
	assert(GearGenerator.SUFFIX_BY_STAT[StatModifier.StatType.GOLD_REWARDS] == "of Avarice")

	var master := GearGenerator.generate(GearItem.Tier.MASTER, GearItem.SlotType.TRINKET, rng)
	print("master affixes=%d (expect 2)" % master.affixes.size())
	assert(master.affixes.size() == 2)
	assert(master.display_name.contains("Ring"))

	var cursed := GearGenerator.generate(GearItem.Tier.CURSED, GearItem.SlotType.CHARM, rng)
	print("cursed affixes=%d (expect 4)" % cursed.affixes.size())
	assert(cursed.affixes.size() == 4)
	assert(cursed.display_name.contains("Necklace"))
	var has_drawback := false
	for affix in cursed.affixes:
		if affix.is_drawback and affix.category == StatModifier.StatCategory.DRAWBACK:
			has_drawback = true
	print("cursed has drawback affix (expect true): %s" % has_drawback)
	assert(has_drawback)

	var epic := GearGenerator.generate(GearItem.Tier.EPIC, GearItem.SlotType.ARMOR, rng)
	print("epic affixes=%d (expect 3)" % epic.affixes.size())
	assert(epic.affixes.size() == 3)
	assert(_count_category(epic, StatModifier.StatCategory.BASIC) == 2)
	assert(_count_category(epic, StatModifier.StatCategory.RARE) == 1)

	var chaos := GearGenerator.generate(GearItem.Tier.CHAOS, GearItem.SlotType.HELM, rng)
	print("chaos affixes=%d (expect %d)" % [chaos.affixes.size(), GearGenerator.CHAOS_ROLL_COUNT])
	assert(chaos.affixes.size() == GearGenerator.CHAOS_ROLL_COUNT)
	assert(_count_category(chaos, StatModifier.StatCategory.SPECIAL) == 0)
	assert(_all_chaos_categories_allowed(chaos))

	var unique := GearGenerator.generate(GearItem.Tier.UNIQUE, GearItem.SlotType.TRINKET, rng)
	print("unique affixes=%d (expect 5)" % unique.affixes.size())
	assert(unique.affixes.size() == 5)
	assert(_count_category(unique, StatModifier.StatCategory.SPECIAL) == 1)

	print("prices: basic=%d master=%d cursed=%d legendary=%d" % [
		GearGenerator.price_for_tier(GearItem.Tier.BASIC),
		GearGenerator.price_for_tier(GearItem.Tier.MASTER),
		GearGenerator.price_for_tier(GearItem.Tier.CURSED),
		GearGenerator.price_for_tier(GearItem.Tier.LEGENDARY),
	])
	assert(GearGenerator.price_for_tier(GearItem.Tier.LEGENDARY) > GearGenerator.price_for_tier(GearItem.Tier.CURSED))

	var offers := GearGenerator.generate_offers(3, 42)
	print("seeded offers=%d (expect 3)" % offers.size())
	assert(offers.size() == 3)

	var basic_text := StatModifierFormatter.format(basic.affixes[0])
	print("basic affix text: %s" % basic_text)
	assert(basic_text != "")

	var physical_modifier := StatModifier.new()
	physical_modifier.stat = StatModifier.StatType.PHYSICAL_DAMAGE
	physical_modifier.operation = StatModifier.OperationType.MULTIPLY
	physical_modifier.value = 1.05
	assert(StatModifierFormatter.format(physical_modifier) == "x5% Physical Damage")

	var crit_damage_modifier := StatModifier.new()
	crit_damage_modifier.stat = StatModifier.StatType.CRIT_MULTIPLIER
	crit_damage_modifier.operation = StatModifier.OperationType.ADD
	crit_damage_modifier.value = 0.2
	assert(StatModifierFormatter.format(crit_damage_modifier) == "+20% Crit Damage")

	# BuildResolver: equipped generated gear must aggregate through StatSheet.
	var class_def: ClassDef = load("res://data/classes/rogue.tres")
	var gear_rng := RandomNumberGenerator.new()
	gear_rng.seed = 7
	var weapon := GearGenerator.generate(GearItem.Tier.UNIQUE, GearItem.SlotType.WEAPON, gear_rng)
	var stats_with_gear := BuildResolver.resolve_stats(class_def, [], [], [weapon])
	print("BuildResolver special count=%d (expect >0)" % stats_with_gear.special_stat_ids.size())
	assert(stats_with_gear.special_stat_ids.size() > 0)

	print("")
	print("GearGenerator tier structure check: OK")
	quit()


func _count_category(item: GearItem, category: StatModifier.StatCategory) -> int:
	var count := 0
	for modifier in item.affixes:
		if modifier.category == category:
			count += 1
	return count


func _all_chaos_categories_allowed(item: GearItem) -> bool:
	for modifier in item.affixes:
		if modifier.category == StatModifier.StatCategory.BASIC:
			continue
		if modifier.category == StatModifier.StatCategory.RARE:
			continue
		if modifier.category == StatModifier.StatCategory.DRAWBACK:
			continue
		return false
	return true
