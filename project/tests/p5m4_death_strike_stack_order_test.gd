extends SceneTree

const DEATH_STRIKE := preload("res://data/skills/death_strike.tres")
const DEATH_STRIKE_SCALING := 1.11


func _initialize() -> void:
	print("-- P5M4 Death Strike stack order --")
	_check_death_strike_zero_stacks_uses_weapon_roll()
	_check_stack_bonus_is_inside_one_scaled_packet()
	_check_seeded_death_strike_crit_order()
	_check_bandit_blade_bonus_applies_once()
	_check_dodge_prevents_death_strike_packet()
	print("P5M4 Death Strike stack order check: OK")
	quit(0)


func _check_death_strike_zero_stacks_uses_weapon_roll() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	var result := CombatResolver.resolve([DEATH_STRIKE], player, _monster(), 1500, 7)
	var event := result.cast_events[0]
	var expected := float(roundi(20.0 * DEATH_STRIKE_SCALING))
	_require_approx(event.physical_damage, expected, "Expected zero-stack Death Strike to scale its weapon roll.")
	_require(event.weapon_damage_rolls.size() == 1, "Expected Death Strike to record one weapon roll.")
	_require(not event.is_crit, "Expected no crit when crit chance is zero.")


func _check_stack_bonus_is_inside_one_scaled_packet() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	player.gear_physical_damage_multiplier = 1.20
	player.talent_physical_damage_multiplier = 1.50
	player.physical_damage_uses_buckets = true
	player.poison_tick_interval_multiplier = 10.0
	player.sync_physical_damage_multiplier()

	var rotation: Array[Skill] = [_poison_skill(4), DEATH_STRIKE]
	var result := CombatResolver.resolve(rotation, player, _monster(), 1501, 11)
	_require(result.cast_events.size() == 2, "Expected poison setup cast and Death Strike cast.")
	var event := result.cast_events[1]
	var expected := float(roundi((20.0 + 4.0) * DEATH_STRIKE_SCALING * 1.20 * 1.50))
	_require_approx(event.physical_damage, expected, "Expected poison-stack bonus before skill scaling and physical buckets.")
	_require(event.damage_contributions.size() == 1, "Expected Death Strike to produce one damage contribution.")
	_require(event.weapon_damage_rolls.size() == 1, "Expected Death Strike to roll weapon damage once.")


func _check_seeded_death_strike_crit_order() -> void:
	var player := _player()
	player.weapon_damage_min = 16
	player.weapon_damage_max = 20
	player.crit_chance = 0.5
	player.crit_multiplier = 2.0
	var seed := 29

	var expected_rng := RandomNumberGenerator.new()
	expected_rng.seed = seed
	expected_rng.randf() # Dodge check.
	var expected_roll := expected_rng.randi_range(player.weapon_damage_min, player.weapon_damage_max)
	var expected_is_crit := expected_rng.randf() < player.crit_chance
	var expected := float(expected_roll) * DEATH_STRIKE_SCALING
	if expected_is_crit:
		expected *= player.crit_multiplier
	expected = float(roundi(expected))

	var first := CombatResolver.resolve([DEATH_STRIKE], player, _monster(), 1500, seed)
	var second := CombatResolver.resolve([DEATH_STRIKE], player, _monster(), 1500, seed)
	var first_event := first.cast_events[0]
	var second_event := second.cast_events[0]
	_require(first_event.weapon_damage_roll == expected_roll, "Expected Death Strike weapon roll after dodge RNG.")
	_require(first_event.is_crit == expected_is_crit, "Expected Death Strike crit roll after weapon roll.")
	_require_approx(first_event.physical_damage, expected, "Expected Death Strike to apply one crit roll to the combined packet.")
	_require(_death_strike_signature(first) == _death_strike_signature(second), "Expected same-seed Death Strike result to replay exactly.")


func _check_bandit_blade_bonus_applies_once() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	player.bonus_physical_damage = 5.0
	player.poison_tick_interval_multiplier = 10.0

	var rotation: Array[Skill] = [_poison_skill(3), DEATH_STRIKE]
	var result := CombatResolver.resolve(rotation, player, _monster(), 1501, 13)
	var event := result.cast_events[1]
	var expected := float(roundi((20.0 + 3.0 + 5.0) * DEATH_STRIKE_SCALING))
	_require_approx(event.physical_damage, expected, "Expected flat bonus physical damage to apply once to Death Strike's combined packet.")


func _check_dodge_prevents_death_strike_packet() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	var monster := _monster()
	monster.dodge_chance = 1.0

	var result := CombatResolver.resolve([DEATH_STRIKE], player, monster, 1500, 17)
	var event := result.cast_events[0]
	_require(event.was_dodged, "Expected Death Strike to be dodged.")
	_require_approx(event.physical_damage, 0.0, "Expected dodged Death Strike to deal no damage.")
	_require(event.weapon_damage_rolls.is_empty(), "Expected dodged Death Strike to skip weapon rolling.")


func _player() -> PlayerStats:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 0.0
	player.physical_damage_multiplier = 1.0
	player.poison_tick_interval_multiplier = 1.0
	return player


func _poison_skill(stacks: int) -> Skill:
	var skill := Skill.new()
	skill.id = "test.poison.setup"
	skill.display_name = "Test Poison Setup"
	skill.base_execution_ms = 1
	skill.min_execution_ms = 1
	var poison := PoisonDamageEffect.new()
	poison.stacks_applied = stacks
	skill.effects = [poison]
	return skill


func _monster() -> Monster:
	var monster := Monster.new()
	monster.display_name = "Death Strike Dummy"
	monster.hp = 999999
	monster.armor = 0
	monster.poison_resistance = 0.0
	monster.dodge_chance = 0.0
	monster.block = 0.0
	monster.absorb = 0.0
	return monster


func _death_strike_signature(result: CombatResolver.CombatResult) -> String:
	var parts: PackedStringArray = []
	for event in result.cast_events:
		parts.append("%d:%d:%s:%.4f:%d" % [
			event.time_ms,
			event.weapon_damage_roll,
			event.is_crit,
			event.physical_damage,
			event.weapon_damage_rolls.size(),
		])
	return "|".join(parts)


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
