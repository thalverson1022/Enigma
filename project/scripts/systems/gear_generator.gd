class_name GearGenerator
extends RefCounted
## Real gear generation (P2:M5) implementing the tier structure and per-tier
## affix magnitudes from docs/Phase 1 Context Docs/Content_Library_Reference.md's
## Generated Gear Affixes table (Basic: 1 affix, Master: 2 affixes, Cursed: 1
## amplified + 1 more + 1 downside). GOLD_REWARDS is excluded from the pool --
## reward-only, not a combat stat, per Current_Mechanics_Reference.md.
## Armor Reduction has no real downside value ("None" in the reference
## table), so it's excluded from the downside-eligible pool specifically.

const AFFIX_POOL: Array[StatModifier.StatType] = [
	StatModifier.StatType.ATTACK_SPEED,
	StatModifier.StatType.CRIT_CHANCE,
	StatModifier.StatType.CRIT_MULTIPLIER,
	StatModifier.StatType.POISON_DAMAGE,
	StatModifier.StatType.PHYSICAL_DAMAGE,
	StatModifier.StatType.POISON_STACKS_APPLIED,
	StatModifier.StatType.ARMOR_REDUCTION,
]

const DOWNSIDE_POOL: Array[StatModifier.StatType] = [
	StatModifier.StatType.ATTACK_SPEED,
	StatModifier.StatType.CRIT_CHANCE,
	StatModifier.StatType.CRIT_MULTIPLIER,
	StatModifier.StatType.POISON_DAMAGE,
	StatModifier.StatType.PHYSICAL_DAMAGE,
	StatModifier.StatType.POISON_STACKS_APPLIED,
]

const OPERATION := {
	StatModifier.StatType.ATTACK_SPEED: StatModifier.OperationType.ADD,
	StatModifier.StatType.CRIT_CHANCE: StatModifier.OperationType.ADD,
	StatModifier.StatType.CRIT_MULTIPLIER: StatModifier.OperationType.ADD,
	StatModifier.StatType.POISON_DAMAGE: StatModifier.OperationType.ADD,
	StatModifier.StatType.PHYSICAL_DAMAGE: StatModifier.OperationType.MULTIPLY,
	StatModifier.StatType.POISON_STACKS_APPLIED: StatModifier.OperationType.ADD,
	StatModifier.StatType.ARMOR_REDUCTION: StatModifier.OperationType.ADD,
}

const BASIC_VALUE := {
	StatModifier.StatType.ATTACK_SPEED: 0.08,
	StatModifier.StatType.CRIT_CHANCE: 0.05,
	StatModifier.StatType.CRIT_MULTIPLIER: 0.20,
	StatModifier.StatType.POISON_DAMAGE: 4.0,
	StatModifier.StatType.PHYSICAL_DAMAGE: 1.08,
	StatModifier.StatType.POISON_STACKS_APPLIED: 1.0,
	StatModifier.StatType.ARMOR_REDUCTION: 10.0,
}

const MASTER_VALUE := {
	StatModifier.StatType.ATTACK_SPEED: 0.10,
	StatModifier.StatType.CRIT_CHANCE: 0.06,
	StatModifier.StatType.CRIT_MULTIPLIER: 0.25,
	StatModifier.StatType.POISON_DAMAGE: 6.0,
	StatModifier.StatType.PHYSICAL_DAMAGE: 1.10,
	StatModifier.StatType.POISON_STACKS_APPLIED: 1.0,
	StatModifier.StatType.ARMOR_REDUCTION: 15.0,
}

const CURSED_AMPLIFIED_VALUE := {
	StatModifier.StatType.ATTACK_SPEED: 0.20,
	StatModifier.StatType.CRIT_CHANCE: 0.12,
	StatModifier.StatType.CRIT_MULTIPLIER: 0.50,
	StatModifier.StatType.POISON_DAMAGE: 12.0,
	StatModifier.StatType.PHYSICAL_DAMAGE: 1.20,
	StatModifier.StatType.POISON_STACKS_APPLIED: 2.0,
	StatModifier.StatType.ARMOR_REDUCTION: 30.0,
}

const CURSED_DOWNSIDE_VALUE := {
	StatModifier.StatType.ATTACK_SPEED: -0.08,
	StatModifier.StatType.CRIT_CHANCE: -0.05,
	StatModifier.StatType.CRIT_MULTIPLIER: -0.20,
	StatModifier.StatType.POISON_DAMAGE: -4.0,
	StatModifier.StatType.PHYSICAL_DAMAGE: 0.92,
	StatModifier.StatType.POISON_STACKS_APPLIED: -1.0,
}

const PRICE_BY_TIER := {
	GearItem.Tier.BASIC: 18,
	GearItem.Tier.MASTER: 32,
	GearItem.Tier.CURSED: 40,
	GearItem.Tier.LEGENDARY: 0,
}

const TIER_NAMES := {
	GearItem.Tier.BASIC: "Basic",
	GearItem.Tier.MASTER: "Master",
	GearItem.Tier.CURSED: "Cursed",
	GearItem.Tier.LEGENDARY: "Legendary",
}

const SLOT_NAMES := {
	GearItem.SlotType.WEAPON: "Dagger",
	GearItem.SlotType.TRINKET: "Ring",
	GearItem.SlotType.CHARM: "Necklace",
}

const SLOT_TAGS := {
	GearItem.SlotType.WEAPON: "Weapon",
	GearItem.SlotType.TRINKET: "Trinket",
	GearItem.SlotType.CHARM: "Charm",
}

const PREFIX_BY_STAT := {
	StatModifier.StatType.ATTACK_SPEED: "Swift",
	StatModifier.StatType.CRIT_CHANCE: "Sharp",
	StatModifier.StatType.CRIT_MULTIPLIER: "Savage",
	StatModifier.StatType.POISON_DAMAGE: "Lethal",
	StatModifier.StatType.PHYSICAL_DAMAGE: "Brutal",
	StatModifier.StatType.POISON_STACKS_APPLIED: "Poison",
	StatModifier.StatType.ARMOR_REDUCTION: "Bloody",
	StatModifier.StatType.GOLD_REWARDS: "Greedy",
}

const SUFFIX_BY_STAT := {
	StatModifier.StatType.ATTACK_SPEED: "of Speed",
	StatModifier.StatType.CRIT_CHANCE: "of Sharpness",
	StatModifier.StatType.CRIT_MULTIPLIER: "of Savagery",
	StatModifier.StatType.POISON_DAMAGE: "of Lethality",
	StatModifier.StatType.PHYSICAL_DAMAGE: "of Brutality",
	StatModifier.StatType.POISON_STACKS_APPLIED: "of Poisoning",
	StatModifier.StatType.ARMOR_REDUCTION: "of Rending",
	StatModifier.StatType.GOLD_REWARDS: "of Avarice",
}

const ALL_SLOTS: Array[GearItem.SlotType] = [
	GearItem.SlotType.WEAPON, GearItem.SlotType.TRINKET, GearItem.SlotType.CHARM
]
const ALL_TIERS: Array[GearItem.Tier] = [
	GearItem.Tier.BASIC, GearItem.Tier.MASTER, GearItem.Tier.CURSED
]


static func price_for_tier(tier: GearItem.Tier) -> int:
	return PRICE_BY_TIER[tier]


static func generate(tier: GearItem.Tier, slot: GearItem.SlotType, rng: RandomNumberGenerator, stable_id: String = "") -> GearItem:
	var item := GearItem.new()
	item.id = stable_id if stable_id != "" else "gear.generated_%d" % rng.randi()
	item.slot = slot
	item.tier = tier
	item.affixes = _affixes_for_tier(tier, rng)
	item.display_name = _display_name_for(item)
	return item


## Generates a fixed-size, seeded batch of shop offers across random
## slots/tiers -- mirrors Current_Mechanics_Reference.md's "generated shop
## gear is seeded" convention (simplified: no run/route/context seeding
## since there's no branching route in P2:M5).
static func generate_offers(count: int, rng_seed: int) -> Array[GearItem]:
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	var offers: Array[GearItem] = []
	for i in count:
		var slot: GearItem.SlotType = ALL_SLOTS[rng.randi_range(0, ALL_SLOTS.size() - 1)]
		var tier: GearItem.Tier = ALL_TIERS[rng.randi_range(0, ALL_TIERS.size() - 1)]
		offers.append(generate(tier, slot, rng))
	return offers


static func _affixes_for_tier(tier: GearItem.Tier, rng: RandomNumberGenerator) -> Array[StatModifier]:
	var affixes: Array[StatModifier] = []
	match tier:
		GearItem.Tier.BASIC:
			var stats := _pick_distinct(AFFIX_POOL, 1, rng)
			affixes.append(_make_modifier(stats[0], BASIC_VALUE[stats[0]]))
		GearItem.Tier.MASTER:
			var stats := _pick_distinct(AFFIX_POOL, 2, rng)
			for stat in stats:
				affixes.append(_make_modifier(stat, MASTER_VALUE[stat]))
		GearItem.Tier.CURSED:
			var positive_stats := _pick_distinct(AFFIX_POOL, 2, rng)
			affixes.append(_make_modifier(positive_stats[0], CURSED_AMPLIFIED_VALUE[positive_stats[0]]))
			affixes.append(_make_modifier(positive_stats[1], MASTER_VALUE[positive_stats[1]]))

			var eligible_downsides: Array[StatModifier.StatType] = []
			for stat in DOWNSIDE_POOL:
				if not positive_stats.has(stat):
					eligible_downsides.append(stat)
			if eligible_downsides.is_empty():
				eligible_downsides = DOWNSIDE_POOL.duplicate()
			var downside_stats := _pick_distinct(eligible_downsides, 1, rng)
			affixes.append(_make_modifier(downside_stats[0], CURSED_DOWNSIDE_VALUE[downside_stats[0]]))
	return affixes


static func _pick_distinct(pool: Array[StatModifier.StatType], count: int, rng: RandomNumberGenerator) -> Array[StatModifier.StatType]:
	var remaining: Array[StatModifier.StatType] = pool.duplicate()
	var picked: Array[StatModifier.StatType] = []
	while picked.size() < count and not remaining.is_empty():
		var index: int = rng.randi_range(0, remaining.size() - 1)
		picked.append(remaining[index])
		remaining.remove_at(index)
	return picked


static func _make_modifier(stat: StatModifier.StatType, value: float) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat = stat
	modifier.operation = OPERATION[stat]
	modifier.value = value
	return modifier


static func _display_name_for(item: GearItem) -> String:
	var base_name: String = SLOT_NAMES[item.slot]
	if item.affixes.is_empty():
		return "%s %s" % [TIER_NAMES[item.tier], base_name]
	var prefix: String = PREFIX_BY_STAT.get(item.affixes[0].stat, TIER_NAMES[item.tier])
	if item.affixes.size() == 1:
		return "%s %s" % [prefix, base_name]
	var suffix: String = SUFFIX_BY_STAT.get(item.affixes[1].stat, "")
	return "%s %s %s" % [prefix, base_name, suffix]
