extends SceneTree

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")
const StatSheet := preload("res://scripts/resources/stat_sheet.gd")


func _init() -> void:
	print("-- P5M3 special effect aggregation --")
	_check_duplicate_specials_collapse()
	_check_different_specials_combine()
	_check_fixed_special_constants()
	_check_player_stats_bridge()
	_check_specials_keep_binary_values_out_of_numeric_values()
	print("P5M3 special effect aggregation check: OK")
	quit(0)


func _check_duplicate_specials_collapse() -> void:
	var armor := _gear(GearItem.SlotType.ARMOR, [
		_modifier(StatCatalog.DISABLE_ENEMY_DODGE),
		_modifier(StatCatalog.DISABLE_ENEMY_DODGE),
	])
	var trinket := _gear(GearItem.SlotType.TRINKET, [
		_modifier(StatCatalog.DISABLE_ENEMY_DODGE),
	])
	var sheet = _sheet([armor, trinket])

	_require(sheet.active_specials().size() == 1, "Expected duplicate Specials to collapse to one active ID.")
	_require(sheet.has_special(StatCatalog.DISABLE_ENEMY_DODGE), "Expected dodge denial to be active.")
	_require(sheet.denies_enemy_dodge(), "Expected dodge denial accessor to be true.")
	_require(sheet.count_for(StatCatalog.DISABLE_ENEMY_DODGE) == 3, "Expected source count to keep duplicate provenance.")


func _check_different_specials_combine() -> void:
	var armor := _gear(GearItem.SlotType.ARMOR, [
		_modifier(StatCatalog.DISABLE_ENEMY_DODGE),
		_modifier(StatCatalog.DISABLE_ENEMY_BLOCK),
		_modifier(StatCatalog.IMMUNE_TO_STUN),
	])
	var charm := _gear(GearItem.SlotType.CHARM, [
		_modifier(StatCatalog.DISABLE_ENEMY_CLEANSE),
		_modifier(StatCatalog.DOUBLE_APPLIED_STACKS),
		_modifier(StatCatalog.IMMUNE_TO_SLOW),
	])
	var trinket := _gear(GearItem.SlotType.TRINKET, [
		_modifier(StatCatalog.CONVERT_DAMAGE_TO_PHYSICAL),
		_modifier(StatCatalog.CONVERT_DAMAGE_TO_MAGICAL),
	])
	var sheet = _sheet([armor, charm, trinket])

	_require(sheet.denies_enemy_dodge(), "Expected dodge denial to combine.")
	_require(sheet.denies_enemy_block(), "Expected block denial to combine.")
	_require(not sheet.denies_enemy_absorb(), "Expected absent absorb denial to stay false.")
	_require(not sheet.denies_enemy_suppress(), "Expected absent suppress denial to stay false.")
	_require(sheet.denies_enemy_cleanse(), "Expected cleanse denial to combine.")
	_require(sheet.doubles_applied_stacks(), "Expected stack-doubling accessor to be true.")
	_require(sheet.converts_damage_to_physical(), "Expected physical conversion accessor to be true.")
	_require(sheet.converts_damage_to_magical(), "Expected magical conversion accessor to be true.")
	_require(sheet.immune_to_stun(), "Expected stun immunity accessor to be true.")
	_require(sheet.immune_to_slow(), "Expected slow immunity accessor to be true.")
	_require(not sheet.immune_to_interrupt(), "Expected absent interrupt immunity to stay false.")

	var summary: Dictionary = sheet.special_effect_summary()
	var denial: Dictionary = summary["enemy_denial"]
	var conversion: Dictionary = summary["damage_conversion"]
	var immunities: Dictionary = summary["immunities"]
	_require(denial["dodge"] and denial["block"] and denial["cleanse"], "Expected summary to include active denial flags.")
	_require(not denial["absorb"] and not denial["suppress"], "Expected summary to keep inactive denial flags false.")
	_require(conversion["physical"] and conversion["magical"], "Expected summary to include both conversion flags.")
	_require(immunities["stun"] and immunities["slow"] and not immunities["interrupt"], "Expected summary to include immunity flags.")


func _check_fixed_special_constants() -> void:
	var item := _gear(GearItem.SlotType.HELM, [
		_modifier(StatCatalog.IGNORE_RESISTANCE_PHYSICAL_PENALTY),
		_modifier(StatCatalog.ALL_STATS_INCREASED),
		_modifier(StatCatalog.IGNORE_ARMOR_NO_SHRED),
	])
	var sheet = _sheet([item])

	_require(sheet.ignores_resistance_with_physical_penalty(), "Expected ignore-resistance accessor to be true.")
	_require_approx(sheet.physical_damage_penalty(), 0.5, "Expected fixed physical damage penalty constant.")
	_require(sheet.has_all_stats_increased(), "Expected all-stats flag accessor to be true.")
	_require_approx(sheet.all_stats_multiplier(), 1.2, "Expected fixed all-stats multiplier constant to be exposed.")
	_require(sheet.ignores_armor_without_shred(), "Expected ignore-armor accessor to be true.")


func _check_player_stats_bridge() -> void:
	var item := _gear(GearItem.SlotType.ARMOR, [
		_modifier(StatCatalog.DISABLE_ENEMY_ABSORB),
		_modifier(StatCatalog.IMMUNE_TO_INTERRUPT),
	])
	var stats := BuildResolver.resolve_stats(null, [], [], [item])

	_require(stats.special_stat_ids.size() == 2, "Expected resolved PlayerStats to carry active Special IDs.")
	_require(stats.special_stat_ids.has(StatCatalog.DISABLE_ENEMY_ABSORB), "Expected absorb denial on PlayerStats.")
	_require(stats.special_stat_ids.has(StatCatalog.IMMUNE_TO_INTERRUPT), "Expected interrupt immunity on PlayerStats.")
	var denial: Dictionary = stats.special_effects["enemy_denial"]
	var immunities: Dictionary = stats.special_effects["immunities"]
	_require(denial["absorb"], "Expected PlayerStats summary to carry absorb denial.")
	_require(immunities["interrupt"], "Expected PlayerStats summary to carry interrupt immunity.")


func _check_specials_keep_binary_values_out_of_numeric_values() -> void:
	var item := _gear(GearItem.SlotType.WEAPON, [
		_modifier(StatCatalog.ALL_STATS_INCREASED),
		_numeric_modifier(StatCatalog.CRIT_CHANCE, 0.50),
		_numeric_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.20),
	])
	var sheet = _sheet([item])

	_require_approx(sheet.crit_chance(), 0.60, "Expected all-stats Special to scale eligible crit chance after T7.")
	_require_approx(sheet.percent_physical_damage(), 0.24, "Expected all-stats Special to scale eligible physical damage after T7.")
	_require_approx(sheet.value_for(StatCatalog.ALL_STATS_INCREASED), 0.0, "Expected all-stats Special to stay out of numeric values.")


func _gear(slot: GearItem.SlotType, affixes: Array) -> GearItem:
	var item := GearItem.new()
	item.slot = slot
	item.tier = GearItem.Tier.UNIQUE
	item.source_kind = GearItem.SourceKind.GENERATED
	for affix in affixes:
		item.affixes.append(affix)
	return item


func _modifier(stat_id: String) -> StatModifier:
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


func _sheet(equipped_gear: Array):
	var sheet = StatSheet.new()
	sheet.add_gear_collection(equipped_gear)
	sheet.finalize()
	return sheet


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
