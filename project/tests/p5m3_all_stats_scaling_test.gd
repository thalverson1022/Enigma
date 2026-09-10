extends SceneTree

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")
const StatSheet := preload("res://scripts/resources/stat_sheet.gd")


func _init() -> void:
	print("-- P5M3 all-stats scaling --")
	_check_absent_all_stats_leaves_values_unchanged()
	_check_all_stats_scales_eligible_values_once()
	_check_scaling_preserves_damage_drawbacks_and_caps_chances()
	_check_player_stats_bridge_uses_scaled_values()
	_check_fixed_special_constants_are_not_scaled()
	print("P5M3 all-stats scaling check: OK")
	quit(0)


func _check_absent_all_stats_leaves_values_unchanged() -> void:
	var sheet = _sheet([_gear([
		_numeric_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.20),
		_numeric_modifier(StatCatalog.CRIT_CHANCE, 0.50),
	])])

	_require_approx(sheet.percent_physical_damage(), 0.20, "Expected physical damage to stay unscaled without all-stats.")
	_require_approx(sheet.crit_chance(), 0.50, "Expected crit chance to stay unscaled without all-stats.")
	_require_approx(sheet.all_stats_multiplier(), 1.0, "Expected inactive all-stats multiplier to be neutral.")


func _check_all_stats_scales_eligible_values_once() -> void:
	var sheet = _sheet([
		_gear([
			_special_modifier(StatCatalog.ALL_STATS_INCREASED),
			_special_modifier(StatCatalog.ALL_STATS_INCREASED),
			_numeric_modifier(StatCatalog.BASE_DAMAGE, 5.0),
			_numeric_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.20),
			_numeric_modifier(StatCatalog.INCREASED_ATTACK_SPEED, 0.10),
			_numeric_modifier(StatCatalog.CRIT_DAMAGE, 0.50),
			_numeric_modifier(StatCatalog.INCREASED_ELEMENTAL_STACKS, 1.0),
		]),
		_gear([
			_special_modifier(StatCatalog.ALL_STATS_INCREASED),
			_numeric_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.10),
		]),
	])

	_require(sheet.has_all_stats_increased(), "Expected all-stats Special to be active.")
	_require(sheet.active_specials().size() == 1, "Expected duplicate all-stats Specials to collapse.")
	_require(sheet.count_for(StatCatalog.ALL_STATS_INCREASED) == 3, "Expected all-stats source count to preserve duplicates.")
	_require_approx(sheet.all_stats_multiplier(), 1.2, "Expected one all-stats multiplier.")
	_require_approx(sheet.base_damage(), 5.0, "Expected base damage to opt out of all-stats scaling.")
	_require_approx(sheet.percent_physical_damage(), 0.36, "Expected additive physical damage to scale once.")
	_require_approx(sheet.increased_attack_speed(), 0.12, "Expected attack speed to scale once.")
	_require_approx(sheet.crit_damage(), 0.60, "Expected crit damage to scale once.")
	_require(sheet.increased_elemental_stacks() == 1, "Expected rounded stack accessors to stay deterministic after scaling.")


func _check_scaling_preserves_damage_drawbacks_and_caps_chances() -> void:
	var damage_drawback = _sheet([_gear([
		_special_modifier(StatCatalog.ALL_STATS_INCREASED),
		_numeric_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, -0.25),
	])])
	_require_approx(damage_drawback.percent_physical_damage(), -0.30, "Expected negative physical damage value to scale without flooring.")

	var capped = _sheet([_gear([
		_special_modifier(StatCatalog.ALL_STATS_INCREASED),
		_numeric_modifier(StatCatalog.CRIT_CHANCE, 0.90),
		_numeric_modifier(StatCatalog.CHANCE_TO_SHRED, 0.95),
	])])
	_require_approx(capped.crit_chance(), 1.0, "Expected crit chance to cap after scaling.")
	_require_approx(capped.chance_to_shred(), 1.0, "Expected Rare chance to cap after scaling.")


func _check_player_stats_bridge_uses_scaled_values() -> void:
	var stats := BuildResolver.resolve_stats(null, [], [], [_gear([
		_special_modifier(StatCatalog.ALL_STATS_INCREASED),
		_numeric_modifier(StatCatalog.BASE_DAMAGE, 4.0),
		_numeric_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.25),
		_numeric_modifier(StatCatalog.CRIT_CHANCE, 0.50),
		_numeric_modifier(StatCatalog.INCREASED_ATTACK_SPEED, 0.10),
	])])

	_require_approx(stats.bonus_physical_damage, 4.0, "Expected PlayerStats base damage bridge to remain unscaled.")
	_require_approx(stats.physical_damage_multiplier, 1.30, "Expected PlayerStats physical multiplier to use scaled percent physical.")
	_require_approx(stats.crit_chance, 0.60, "Expected PlayerStats crit chance to use scaled value.")
	_require_approx(stats.attack_speed, 0.12, "Expected PlayerStats attack speed to use scaled value.")


func _check_fixed_special_constants_are_not_scaled() -> void:
	var sheet = _sheet([_gear([
		_special_modifier(StatCatalog.ALL_STATS_INCREASED),
		_special_modifier(StatCatalog.IGNORE_RESISTANCE_PHYSICAL_PENALTY),
	])])
	var summary: Dictionary = sheet.special_effect_summary()

	_require_approx(sheet.physical_damage_penalty(), 0.5, "Expected physical penalty fixed constant to remain unchanged.")
	_require_approx(float(summary["physical_damage_penalty"]), 0.5, "Expected summary fixed penalty to remain unchanged.")
	_require_approx(sheet.all_stats_multiplier(), 1.2, "Expected all-stats fixed multiplier to remain unchanged.")
	_require_approx(float(summary["all_stats_multiplier"]), 1.2, "Expected summary all-stats multiplier to remain unchanged.")


func _gear(affixes: Array) -> GearItem:
	var item := GearItem.new()
	item.slot = GearItem.SlotType.WEAPON
	item.tier = GearItem.Tier.UNIQUE
	item.source_kind = GearItem.SourceKind.GENERATED
	for affix in affixes:
		item.affixes.append(affix)
	return item


func _sheet(equipped_gear: Array):
	var sheet = StatSheet.new()
	sheet.add_gear_collection(equipped_gear)
	sheet.finalize()
	return sheet


func _special_modifier(stat_id: String) -> StatModifier:
	var modifier := _numeric_modifier(stat_id, 1.0)
	modifier.category = StatModifier.StatCategory.SPECIAL
	return modifier


func _numeric_modifier(stat_id: String, value: float) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat_id = stat_id
	modifier.stat = StatModifier.StatType.ATTACK_SPEED
	modifier.operation = StatModifier.OperationType.ADD
	modifier.value = value
	modifier.category = StatModifier.StatCategory.BASIC
	return modifier


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
