extends SceneTree

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")


func _initialize() -> void:
	print("-- P5M4 base damage and physical buckets --")
	_check_base_damage_and_separate_physical_buckets()
	_check_gear_bucket_stacks_additively()
	_check_legacy_physical_multiplier_still_works_for_manual_stats()
	_check_poison_ticks_ignore_physical_buckets()
	print("P5M4 base damage and physical buckets check: OK")
	quit(0)


func _check_base_damage_and_separate_physical_buckets() -> void:
	var weapon := _gear([
		_modifier(StatCatalog.BASE_DAMAGE, 5.0),
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.20),
	])
	var talent := _talent(_legacy_physical_modifier(1.50))
	var stats := BuildResolver.resolve_stats(null, [], [talent], [weapon])

	_require_approx(stats.bonus_physical_damage, 5.0, "Expected Base Damage to bridge as flat physical damage.")
	_require_approx(stats.gear_physical_damage_multiplier, 1.20, "Expected gear physical bucket.")
	_require_approx(stats.talent_physical_damage_multiplier, 1.50, "Expected talent physical bucket.")
	_require_approx(stats.physical_damage_multiplier, 1.80, "Expected legacy total multiplier to mirror separated buckets.")

	var result := CombatResolver.resolve([_physical_skill(10.0, 1000)], stats, _monster(), 1000, 1)
	_require_approx(result.cast_events[0].physical_damage, 27.0, "Expected (10 fixed base + 5 Base Damage) * 1.20 gear * 1.50 talent.")


func _check_gear_bucket_stacks_additively() -> void:
	var weapon := _gear([
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.10),
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.25),
	])
	var stats := BuildResolver.resolve_stats(null, [], [], [weapon])
	_require_approx(stats.gear_physical_damage_multiplier, 1.35, "Expected gear percent physical stats to add inside one bucket.")
	_require_approx(stats.talent_physical_damage_multiplier, 1.0, "Expected empty talent bucket to stay neutral.")
	_require_approx(stats.physical_damage_multiplier, 1.35, "Expected legacy total to mirror gear bucket.")


func _check_legacy_physical_multiplier_still_works_for_manual_stats() -> void:
	var stats := PlayerStats.new()
	stats.physical_damage_multiplier = 1.5
	stats.crit_chance = 0.0
	var result := CombatResolver.resolve([_physical_skill(20.0, 1000)], stats, _monster(), 1000, 1)
	_require_approx(result.cast_events[0].physical_damage, 30.0, "Expected manual PlayerStats legacy multiplier compatibility.")


func _check_poison_ticks_ignore_physical_buckets() -> void:
	var weapon := _gear([
		_modifier(StatCatalog.BASE_DAMAGE, 10.0),
		_modifier(StatCatalog.PERCENT_PHYSICAL_DAMAGE, 1.00),
	])
	var talent := _talent(_legacy_physical_modifier(2.0))
	var stats := BuildResolver.resolve_stats(null, [], [talent], [weapon])
	stats.poison_damage_per_tick = 5.0

	var result := CombatResolver.resolve([_poison_skill(1, 500)], stats, _monster(), 1000, 1)
	_require(result.tick_events.size() == 1, "Expected one poison tick.")
	_require_approx(result.tick_events[0].damage, 5.0, "Expected poison tick damage to ignore physical Base Damage and physical buckets.")


func _gear(affixes: Array) -> GearItem:
	var item := GearItem.new()
	item.slot = GearItem.SlotType.WEAPON
	item.tier = GearItem.Tier.BASIC
	item.source_kind = GearItem.SourceKind.GENERATED
	for affix in affixes:
		item.affixes.append(affix)
	return item


func _talent(modifier: StatModifier) -> Talent:
	var talent := Talent.new()
	talent.id = "talent.test_physical_bucket"
	talent.display_name = "Test Physical Bucket"
	talent.stat_modifiers = [modifier]
	return talent


func _modifier(stat_id: String, value: float) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat_id = stat_id
	modifier.stat = StatModifier.StatType.PHYSICAL_DAMAGE
	modifier.category = StatModifier.StatCategory.BASIC
	modifier.operation = StatModifier.OperationType.ADD
	modifier.value = value
	return modifier


func _legacy_physical_modifier(multiplier: float) -> StatModifier:
	var modifier := StatModifier.new()
	modifier.stat = StatModifier.StatType.PHYSICAL_DAMAGE
	modifier.operation = StatModifier.OperationType.MULTIPLY
	modifier.value = multiplier
	return modifier


func _physical_skill(amount: float, execution_ms: int) -> Skill:
	var skill := Skill.new()
	skill.id = "test.physical"
	skill.display_name = "Test Physical"
	skill.base_execution_ms = execution_ms
	skill.min_execution_ms = 100
	var damage := PhysicalDamageEffect.new()
	damage.amount = amount
	skill.effects = [damage]
	return skill


func _poison_skill(stacks: int, execution_ms: int) -> Skill:
	var skill := Skill.new()
	skill.id = "test.poison"
	skill.display_name = "Test Poison"
	skill.base_execution_ms = execution_ms
	skill.min_execution_ms = 100
	var poison := PoisonDamageEffect.new()
	poison.stacks_applied = stacks
	skill.effects = [poison]
	return skill


func _monster() -> Monster:
	var monster := Monster.new()
	monster.display_name = "Bucket Dummy"
	monster.hp = 999999
	monster.armor = 0
	monster.poison_resistance = 0.0
	return monster


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
