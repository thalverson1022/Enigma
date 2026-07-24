extends SceneTree
## Headless P2:M4 check for GearGenerator's tier structure. Run with:
##   godot --headless -s res://tests/gear_generator_test.gd
## Verifies the affix-count structure from
## docs/Phase 1 Context Docs/Current_Mechanics_Reference.md's Generated Gear
## Tiers section (Basic=1, Master=2, Cursed=1 amplified + 1 more + 1
## downside), now using the real per-tier magnitudes from
## Content_Library_Reference.md's Generated Gear Affixes table (P2:M5).


func _initialize() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1

	var basic := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.WEAPON, rng)
	print("basic affixes=%d (expect 1)" % basic.affixes.size())
	assert(basic.affixes.size() == 1)
	assert(basic.display_name.contains("Dagger"))
	assert(GearGenerator.SLOT_NAMES[GearItem.SlotType.WEAPON] == "Dagger")
	assert(GearGenerator.SLOT_NAMES[GearItem.SlotType.TRINKET] == "Ring")
	assert(GearGenerator.SLOT_NAMES[GearItem.SlotType.CHARM] == "Necklace")
	assert(GearGenerator.SLOT_TAGS[GearItem.SlotType.WEAPON] == "Weapon")
	assert(GearGenerator.SLOT_TAGS[GearItem.SlotType.TRINKET] == "Trinket")
	assert(GearGenerator.SLOT_TAGS[GearItem.SlotType.CHARM] == "Charm")
	assert(GearGenerator.PREFIX_BY_STAT[StatModifier.StatType.CRIT_CHANCE] == "Sharp")
	assert(GearGenerator.SUFFIX_BY_STAT[StatModifier.StatType.CRIT_CHANCE] == "of Sharpness")
	assert(GearGenerator.PREFIX_BY_STAT[StatModifier.StatType.GOLD_REWARDS] == "Greedy")
	assert(GearGenerator.SUFFIX_BY_STAT[StatModifier.StatType.GOLD_REWARDS] == "of Avarice")

	var master := GearGenerator.generate(GearItem.Tier.MASTER, GearItem.SlotType.TRINKET, rng)
	print("master affixes=%d (expect 2)" % master.affixes.size())
	assert(master.affixes.size() == 2)
	assert(master.display_name.contains("Ring"))

	var cursed := GearGenerator.generate(GearItem.Tier.CURSED, GearItem.SlotType.CHARM, rng)
	print("cursed affixes=%d (expect 3)" % cursed.affixes.size())
	assert(cursed.affixes.size() == 3)
	assert(cursed.display_name.contains("Necklace"))
	var has_negative := false
	for affix in cursed.affixes:
		if affix.value < 0:
			has_negative = true
	print("cursed has downside affix (expect true): %s" % has_negative)
	assert(has_negative)

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

	var armor_item: GearItem = null
	var armor_rng := RandomNumberGenerator.new()
	armor_rng.seed = 2
	for i in 50:
		var candidate := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.WEAPON, armor_rng)
		if candidate.affixes[0].stat == StatModifier.StatType.ARMOR_REDUCTION:
			armor_item = candidate
			break
	assert(armor_item != null)
	var armor_text := StatModifierFormatter.format(armor_item.affixes[0])
	print("armor reduction text: %s" % armor_text)
	assert(armor_text.contains("armor"))
	assert(armor_text.begins_with("-"))

	# BuildResolver: equipped gear must change resolved stats vs. no gear.
	# Checks all 7 PlayerStats fields BuildResolver writes to -- GearGenerator's
	# pool now spans all 7 combat-relevant StatModifier types (P2:M5), so a
	# single random Basic affix could land on any of them, not just the
	# original 4 from P2:M3/M4.
	var class_def: ClassDef = load("res://data/classes/rogue.tres")
	var stats_no_gear := BuildResolver.resolve_stats(class_def, [], [], [])
	var gear_rng := RandomNumberGenerator.new()
	gear_rng.seed = 7
	var weapon := GearGenerator.generate(GearItem.Tier.BASIC, GearItem.SlotType.WEAPON, gear_rng)
	var stats_with_gear := BuildResolver.resolve_stats(class_def, [], [], [weapon])
	var changed: bool = (
		stats_no_gear.attack_speed != stats_with_gear.attack_speed
		or stats_no_gear.crit_chance != stats_with_gear.crit_chance
		or stats_no_gear.crit_multiplier != stats_with_gear.crit_multiplier
		or stats_no_gear.poison_damage_per_tick != stats_with_gear.poison_damage_per_tick
		or stats_no_gear.physical_damage_multiplier != stats_with_gear.physical_damage_multiplier
		or stats_no_gear.bonus_poison_stacks != stats_with_gear.bonus_poison_stacks
		or stats_no_gear.bonus_armor_reduction != stats_with_gear.bonus_armor_reduction
	)
	print("BuildResolver applies equipped gear affixes (expect true): %s" % changed)
	assert(changed)

	print("")
	print("GearGenerator tier structure check: OK")
	quit()
