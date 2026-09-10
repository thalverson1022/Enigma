extends SceneTree


func _init() -> void:
	print("-- P5M4 negative stat floors --")
	_check_negative_attack_speed_slows_cast_time()
	_check_crit_damage_can_drop_to_one_x()
	_check_talent_crit_damage_clamps_at_one_x()
	_check_negative_flat_physical_damage_floors_base_at_one()
	_check_negative_damage_increase_reduces_below_base()
	_check_negative_poison_damage_floors_base_at_one()
	print("P5M4 negative stat floors check: OK")
	quit(0)


func _check_negative_attack_speed_slows_cast_time() -> void:
	var skill := _skill(1000)
	_require_equal("base cast time", CombatTiming.execution_time_ms(skill, 0.0), 1000)
	_require_equal("positive attack speed cast time", CombatTiming.execution_time_ms(skill, 0.10), 910)
	_require_equal("negative attack speed cast time", CombatTiming.execution_time_ms(skill, -0.10), 1112)
	_require_equal("deep negative attack speed safety clamp", CombatTiming.execution_time_ms(skill, -1.50), 20000)


func _check_crit_damage_can_drop_to_one_x() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var reduced := DamageCalculator.resolve_damage_packet(10.0, "physical", 0, 0.0, 1.0, 1.25, rng)
	_require_approx("reduced crit damage", float(reduced["amount"]), 13.0)

	rng.seed = 1
	var floored := DamageCalculator.resolve_damage_packet(10.0, "physical", 0, 0.0, 1.0, 0.40, rng)
	_require_approx("floored crit damage", float(floored["amount"]), 10.0)


func _check_talent_crit_damage_clamps_at_one_x() -> void:
	var class_def := ClassDef.new()
	class_def.base_stats = PlayerStats.new()
	class_def.base_stats.crit_multiplier = 2.0
	var talent := Talent.new()
	var modifier := StatModifier.new()
	modifier.stat_id = StatCatalog.CRIT_DAMAGE
	modifier.operation = StatModifier.OperationType.ADD
	modifier.value = -2.0
	talent.stat_modifiers = [modifier]

	var stats := BuildResolver.resolve_stats(class_def, [], [talent])
	_require_approx("talent crit damage floor", stats.crit_multiplier, 1.0)


func _check_negative_flat_physical_damage_floors_base_at_one() -> void:
	var skill := _physical_skill("skill.stab", 1000, 10.0)
	var player := PlayerStats.new()
	player.weapon_damage_min = 16
	player.weapon_damage_max = 16
	player.bonus_physical_damage = -100.0
	player.crit_multiplier = 2.0
	player.sync_physical_damage_multiplier()
	var result := CombatResolver.resolve([skill], player, _monster(), 1000, 3)
	_require_approx("flat physical floor combat damage", result.cast_events[0].physical_damage, 1.0)


func _check_negative_damage_increase_reduces_below_base() -> void:
	var skill := _physical_skill("skill.stab", 1000, 10.0)
	var player := PlayerStats.new()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	player.gear_physical_damage_multiplier = 0.60
	player.talent_physical_damage_multiplier = 1.0
	player.physical_damage_uses_buckets = true
	player.sync_physical_damage_multiplier()
	var result := CombatResolver.resolve([skill], player, _monster(), 1000, 5)
	_require_approx("negative physical increase combat damage", result.cast_events[0].physical_damage, 12.0)


func _check_negative_poison_damage_floors_base_at_one() -> void:
	var stats := PlayerStats.new()
	stats.base_poison_damage = 8.0
	stats.bonus_base_elemental_damage = -2.0
	stats.gear_elemental_damage_multiplier = 0.50
	stats.talent_elemental_damage_multiplier = 1.0
	stats.sync_elemental_damage_multiplier()
	stats.sync_poison_damage_per_tick()
	_require_approx("reduced poison damage", stats.poison_damage_per_tick, 3.0)

	stats.bonus_base_elemental_damage = -100.0
	stats.sync_poison_damage_per_tick()
	_require_approx("poison base floor before multiplier", stats.poison_damage_per_tick, 0.5)
	_require_approx("poison tick final floor", DamageCalculator.resolve_poison_tick(stats.poison_damage_per_tick, 0.0), 1.0)


func _skill(execution_ms: int) -> Skill:
	var skill := Skill.new()
	skill.id = "skill.test_timing"
	skill.display_name = "Timing Test"
	skill.base_execution_ms = execution_ms
	skill.min_execution_ms = 1
	return skill


func _physical_skill(id: String, execution_ms: int, amount: float) -> Skill:
	var skill := _skill(execution_ms)
	skill.id = id
	var effect := PhysicalDamageEffect.new()
	effect.amount = amount
	skill.effects = [effect]
	return skill


func _monster() -> Monster:
	var monster := Monster.new()
	monster.display_name = "Negative Dummy"
	monster.hp = 99999
	monster.armor = 0
	monster.poison_resistance = 0.0
	monster.dodge_chance = 0.0
	monster.block = 0.0
	monster.absorb = 0.0
	return monster


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_equal(label: String, actual: Variant, expected: Variant) -> void:
	_require(actual == expected, "%s expected %s, got %s." % [label, str(expected), str(actual)])


func _require_approx(label: String, actual: float, expected: float) -> void:
	_require(is_equal_approx(actual, expected), "%s expected %.3f, got %.3f." % [label, expected, actual])
