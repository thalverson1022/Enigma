extends SceneTree

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")
const StatSheet := preload("res://scripts/resources/stat_sheet.gd")


func _init() -> void:
	print("-- P5M3 stat sheet aggregation --")
	_check_additive_numeric_stacking()
	_check_drawbacks_floor_and_caps()
	_check_legacy_modifier_mapping()
	_check_equipped_gear_only()
	_check_specials_do_not_pollute_numeric_values()
	_check_assassin_poison_talents_use_separate_multiplier_bucket()
	print("P5M3 stat sheet aggregation check: OK")
	quit(0)


func _check_additive_numeric_stacking() -> void:
	var weapon := _gear(GearItem.SlotType.WEAPON, [
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.20),
		_modifier(StatCatalog.INCREASED_ATTACK_SPEED, 0.08),
		_modifier(StatCatalog.BASE_DAMAGE, 4.0),
	])
	var charm := _gear(GearItem.SlotType.CHARM, [
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.10),
		_modifier(StatCatalog.INCREASED_ATTACK_SPEED, 0.12),
		_modifier(StatCatalog.INCREASED_GOLD, 0.25),
	])

	var sheet = _sheet([weapon, charm])
	_require_approx(sheet.percent_physical_damage(), 0.30, "Expected additive percent physical damage.")
	_require_approx(sheet.increased_attack_speed(), 0.20, "Expected additive attack speed.")
	_require_approx(sheet.base_damage(), 4.0, "Expected flat base damage aggregation.")
	_require_approx(sheet.increased_gold(), 0.25, "Expected gold gain aggregation.")

	var stats := BuildResolver.resolve_stats(null, [], [], [weapon, charm])
	_require_approx(stats.physical_damage_multiplier, 1.30, "Expected gear sheet to bridge percent physical into PlayerStats multiplier.")
	_require_approx(stats.attack_speed, 0.20, "Expected gear sheet to bridge attack speed.")
	_require_approx(stats.bonus_physical_damage, 4.0, "Expected base damage to bridge into current bonus damage compatibility field.")
	_require_approx(stats.gold_reward_multiplier, 1.25, "Expected gold gain to bridge into current reward multiplier.")


func _check_drawbacks_floor_and_caps() -> void:
	var item := _gear(GearItem.SlotType.TRINKET, [
		_modifier(StatCatalog.CRIT_CHANCE, 0.80),
		_modifier(StatCatalog.CRIT_CHANCE, 0.45),
		_modifier(StatCatalog.INCREASED_ATTACK_SPEED, -0.50, StatModifier.OperationType.ADD, true),
		_modifier(StatCatalog.CRIT_DAMAGE, -1.20, StatModifier.OperationType.ADD, true),
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, -0.40, StatModifier.OperationType.ADD, true),
		_modifier(StatCatalog.BASE_DAMAGE, -12.0, StatModifier.OperationType.ADD, true),
		_modifier(StatCatalog.BASE_ELEMENTAL_DAMAGE, -2.0, StatModifier.OperationType.ADD, true),
		_modifier(StatCatalog.PERCENT_ELEMENTAL_DAMAGE, -0.25, StatModifier.OperationType.ADD, true),
	])

	var sheet = _sheet([item])
	_require_approx(sheet.crit_chance(), 1.0, "Expected chance stats to cap at 100%.")
	_require_approx(sheet.increased_attack_speed(), -0.50, "Expected negative aggregate attack speed to survive aggregation.")
	_require_approx(sheet.crit_damage(), -1.20, "Expected negative aggregate crit damage to survive aggregation.")
	_require_approx(sheet.percent_physical_damage(), -0.40, "Expected negative aggregate physical damage to survive aggregation.")
	_require_approx(sheet.base_damage(), -12.0, "Expected negative aggregate base damage to survive aggregation.")
	_require_approx(sheet.base_elemental_damage(), -2.0, "Expected negative aggregate base elemental damage to survive aggregation.")
	_require_approx(sheet.percent_elemental_damage(), -0.25, "Expected negative aggregate elemental damage to survive aggregation.")

	var stats := BuildResolver.resolve_stats(null, [], [], [item])
	_require_approx(stats.crit_chance, 1.0, "Expected resolved PlayerStats crit chance to cap at 100%.")
	_require_approx(stats.attack_speed, -0.50, "Expected resolved attack speed to preserve slowing drawbacks.")
	_require_approx(stats.crit_multiplier, 1.0, "Expected resolved crit damage to clamp at 1.0x.")
	_require_approx(stats.bonus_physical_damage, -12.0, "Expected resolved bonus physical damage to preserve drawbacks.")
	_require_approx(stats.physical_damage_multiplier, 0.60, "Expected physical drawback to reduce multiplier below neutral.")
	_require_approx(stats.bonus_base_elemental_damage, -2.0, "Expected resolved base elemental damage to preserve drawbacks.")
	_require_approx(stats.elemental_damage_multiplier, 0.75, "Expected elemental damage drawback to reduce multiplier below neutral.")


func _check_legacy_modifier_mapping() -> void:
	var legacy_physical := StatModifier.new()
	legacy_physical.stat = StatModifier.StatType.PHYSICAL_DAMAGE
	legacy_physical.operation = StatModifier.OperationType.MULTIPLY
	legacy_physical.value = 1.2

	var legacy_downside := StatModifier.new()
	legacy_downside.stat = StatModifier.StatType.PHYSICAL_DAMAGE
	legacy_downside.operation = StatModifier.OperationType.MULTIPLY
	legacy_downside.value = 0.92
	legacy_downside.is_drawback = true

	var legacy_stacks := StatModifier.new()
	legacy_stacks.stat = StatModifier.StatType.POISON_STACKS_APPLIED
	legacy_stacks.operation = StatModifier.OperationType.ADD
	legacy_stacks.value = 2.0

	var legacy_poison := StatModifier.new()
	legacy_poison.stat = StatModifier.StatType.POISON_DAMAGE
	legacy_poison.operation = StatModifier.OperationType.MULTIPLY
	legacy_poison.value = 1.4

	var legacy_tick_interval := StatModifier.new()
	legacy_tick_interval.stat = StatModifier.StatType.POISON_TICK_INTERVAL
	legacy_tick_interval.operation = StatModifier.OperationType.MULTIPLY
	legacy_tick_interval.value = 0.5

	var gear := _gear(GearItem.SlotType.WEAPON, [legacy_physical, legacy_downside, legacy_stacks, legacy_poison, legacy_tick_interval])
	var sheet = _sheet([gear])
	_require_approx(sheet.percent_physical_damage(), 0.12, "Expected legacy physical multipliers to normalize into additive percent physical damage.")
	_require(sheet.increased_all_stacks() == 2, "Expected legacy poison stacks to map to all stacks.")
	_require_approx(sheet.legacy_poison_damage_multiplier, 1.4, "Expected legacy poison damage to keep multiplier compatibility.")
	_require_approx(sheet.legacy_poison_tick_interval_multiplier, 0.5, "Expected legacy poison tick interval to keep multiplier compatibility.")

	var class_def := ClassDef.new()
	class_def.base_stats = PlayerStats.new()
	class_def.base_stats.poison_damage_per_tick = 8.0
	var stats := BuildResolver.resolve_stats(class_def, [], [], [gear])
	_require_approx(stats.physical_damage_multiplier, 1.12, "Expected normalized legacy physical gear to preserve PlayerStats compatibility.")
	_require(stats.bonus_poison_stacks == 2, "Expected all stacks to bridge to poison stacks.")
	_require(stats.bonus_armor_reduction == 2, "Expected all stacks to bridge to shred stacks.")
	_require(stats.bonus_decay_stacks == 2, "Expected all stacks to bridge to decay stacks.")
	_require_approx(stats.poison_damage_per_tick, 11.2, "Expected legacy poison damage multiplier to preserve PlayerStats compatibility.")
	_require_approx(stats.poison_tick_interval_multiplier, 0.5, "Expected legacy poison tick interval multiplier to preserve PlayerStats compatibility.")

	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	var lucky_sheet = _sheet([lucky_coin])
	_require_approx(lucky_sheet.crit_chance(), 0.05, "Expected Lucky Coin to aggregate by canonical crit_chance stat_id.")

	var proc_gear := _gear(GearItem.SlotType.WEAPON, [
		_modifier(StatCatalog.CHANCE_TO_SHRED, 0.10),
		_modifier(StatCatalog.CHANCE_TO_DECAY, 0.20),
	])
	var proc_stats := BuildResolver.resolve_stats(class_def, [], [], [proc_gear])
	_require_approx(proc_stats.shred_chance, 0.10, "Expected shred chance to bridge separately into PlayerStats.")
	_require_approx(proc_stats.decay_chance, 0.20, "Expected decay chance to bridge separately into PlayerStats.")
	_require_approx(proc_stats.elemental_proc_chance, 0.0, "Expected elemental proc chance not to include Shred or Decay chance.")

	var element_proc_gear := _gear(GearItem.SlotType.WEAPON, [
		_modifier(StatCatalog.CRIT_APPLIES_ELEMENT, 0.30),
	])
	var element_proc_stats := BuildResolver.resolve_stats(class_def, [], [], [element_proc_gear])
	_require_approx(element_proc_stats.elemental_proc_chance, 0.30, "Expected elemental proc chance to come from Crit Applies Element.")


func _check_equipped_gear_only() -> void:
	var equipped := _gear(GearItem.SlotType.HELM, [_modifier(StatCatalog.CRIT_DAMAGE, 0.30)])
	var inventory_only := _gear(GearItem.SlotType.ARMOR, [_modifier(StatCatalog.CRIT_DAMAGE, 0.70)])

	var sheet = _sheet([equipped])
	_require_approx(sheet.crit_damage(), 0.30, "Expected stat sheet to use only the gear it is given.")
	_require(not _sheet([equipped]).crit_damage() == _sheet([equipped, inventory_only]).crit_damage(), "Expected unequipped gear to be absent unless passed explicitly.")


func _check_specials_do_not_pollute_numeric_values() -> void:
	var item := _gear(GearItem.SlotType.ARMOR, [
		_modifier(StatCatalog.ALL_STATS_INCREASED, 1.0),
		_modifier(StatCatalog.DISABLE_ENEMY_DODGE, 1.0),
		_modifier(StatCatalog.CRIT_APPLIES_ELEMENT, 0.40),
	])

	var sheet = _sheet([item])
	_require(sheet.has_special(StatCatalog.ALL_STATS_INCREASED), "Expected Special IDs to be recorded once.")
	_require(sheet.has_special(StatCatalog.DISABLE_ENEMY_DODGE), "Expected denial Special to be recorded once.")
	_require_approx(sheet.value_for(StatCatalog.ALL_STATS_INCREASED), 0.0, "Expected binary Specials to stay out of numeric values.")
	_require_approx(sheet.crit_applies_element(), 0.48, "Expected Rare chance stats to remain numeric and receive T7 all-stats scaling.")


func _check_assassin_poison_talents_use_separate_multiplier_bucket() -> void:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var assassin: SubclassTree = load("res://data/subclass_trees/assassin.tres")
	var venom_edge: Talent = load("res://data/talents/assassin/venom_edge.tres")
	var precise_cuts: Talent = load("res://data/talents/assassin/precise_cuts.tres")
	var lethal_intent: Talent = load("res://data/talents/assassin/lethal_intent.tres")
	var toxic_technique: Talent = load("res://data/talents/assassin/toxic_technique.tres")
	var perfect_toxin: Talent = load("res://data/talents/assassin/perfect_toxin.tres")
	var gear := _gear(GearItem.SlotType.WEAPON, [
		_modifier(StatCatalog.PERCENT_ELEMENTAL_DAMAGE, 0.25),
	])

	var stats := BuildResolver.resolve_stats(
		rogue,
		[assassin],
		[venom_edge, precise_cuts, lethal_intent, toxic_technique, perfect_toxin],
		[gear]
	)
	_require_approx(stats.bonus_base_elemental_damage, 13.0, "Expected Venom Edge and Toxic Technique to add flat poison damage.")
	_require_approx(stats.gear_elemental_damage_multiplier, 1.25, "Expected gear elemental percent to stay additive in the gear bucket.")
	_require_approx(stats.talent_elemental_damage_multiplier, 2.4, "Expected Assassin poison percent bonuses to multiply in the talent bucket.")
	_require_approx(stats.elemental_damage_multiplier, 3.0, "Expected final elemental multiplier to be gear bucket times talent bucket.")
	_require_approx(stats.poison_damage_per_tick, 63.0, "Expected poison damage to use base poison plus flat bonuses, then the final elemental multiplier.")
	_require_approx(stats.crit_chance, 0.15, "Expected Precise Cuts to add ten crit chance points.")
	_require_approx(stats.crit_multiplier, 2.5, "Expected Lethal Intent to add 0.5x crit damage.")


func _gear(slot: GearItem.SlotType, affixes: Array) -> GearItem:
	var item := GearItem.new()
	item.slot = slot
	item.tier = GearItem.Tier.BASIC
	item.source_kind = GearItem.SourceKind.GENERATED
	for affix in affixes:
		item.affixes.append(affix)
	return item


func _sheet(equipped_gear: Array):
	var sheet = StatSheet.new()
	sheet.add_gear_collection(equipped_gear)
	sheet.finalize()
	return sheet


func _modifier(stat_id: String, value: float, operation: StatModifier.OperationType = StatModifier.OperationType.ADD, is_drawback: bool = false) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat_id = stat_id
	modifier.stat = StatModifier.StatType.ATTACK_SPEED
	modifier.operation = operation
	modifier.value = value
	modifier.category = StatModifier.StatCategory.DRAWBACK if is_drawback else StatModifier.StatCategory.BASIC
	modifier.is_drawback = is_drawback
	return modifier


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
