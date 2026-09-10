extends SceneTree


func _initialize() -> void:
	print("-- P5M4 deterministic weapon rolls --")
	_check_physical_casts_record_deterministic_rolls()
	_check_different_seeds_can_change_weapon_rolls()
	_check_poison_only_casts_do_not_roll_weapon_damage()
	_check_repeated_physical_casts_roll_independently()
	_check_weapon_roll_order_is_after_dodge_and_before_crit()
	_check_current_fixed_damage_is_unchanged()
	print("P5M4 deterministic weapon rolls check: OK")
	quit(0)


func _check_physical_casts_record_deterministic_rolls() -> void:
	var player := _player()
	player.weapon_damage_min = 17
	player.weapon_damage_max = 19
	player.weapon_damage_tier = GearItem.Tier.BASIC
	player.weapon_damage_weapon_id = "gear.test.basic_weapon"
	var rotation: Array[Skill] = [_physical_skill(18.0, 1000)]
	var monster := _monster()

	var first := CombatResolver.resolve(rotation, player, monster, 3000, 17)
	var second := CombatResolver.resolve(rotation, player, monster, 3000, 17)
	_require(_roll_signature(first) == _roll_signature(second), "Expected same-seed weapon roll signature to replay exactly.")
	for event in first.cast_events:
		_require(event.weapon_damage_rolls.size() == 1, "Expected each physical cast to record one weapon roll.")
		_require(event.weapon_damage_roll >= 17 and event.weapon_damage_roll <= 19, "Expected weapon roll inside Basic range.")
		_require(event.weapon_damage_min == 17 and event.weapon_damage_max == 19, "Expected event to record active range.")
		_require(event.weapon_damage_rolls[0]["weapon_id"] == "gear.test.basic_weapon", "Expected contribution to record weapon id.")


func _check_different_seeds_can_change_weapon_rolls() -> void:
	var player := _player()
	player.weapon_damage_min = 16
	player.weapon_damage_max = 25
	var rotation: Array[Skill] = [_physical_skill(18.0, 1000)]
	var monster := _monster()
	var signatures := {}
	for seed in range(1, 8):
		var result := CombatResolver.resolve(rotation, player, monster, 3000, seed)
		signatures[_roll_signature(result)] = true
	_require(signatures.size() > 1, "Expected varied seeds to produce varied weapon roll signatures.")


func _check_poison_only_casts_do_not_roll_weapon_damage() -> void:
	var player := _player()
	player.poison_damage_per_tick = 5.0
	var result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster(), 1500, 3)
	_require(result.cast_events.size() == 3, "Expected poison-only casts in setup.")
	for event in result.cast_events:
		_require(event.weapon_damage_roll == 0, "Expected poison-only cast to have no primary weapon roll.")
		_require(event.weapon_damage_rolls.is_empty(), "Expected poison-only cast to record no weapon roll entries.")


func _check_repeated_physical_casts_roll_independently() -> void:
	var player := _player()
	player.weapon_damage_min = 16
	player.weapon_damage_max = 20
	var result := CombatResolver.resolve([_physical_skill(10.0, 500)], player, _monster(), 2000, 11)
	_require(result.cast_events.size() == 4, "Expected four repeated physical casts.")
	_require(_rolls(result).size() == 4, "Expected one weapon roll per repeated physical cast.")


func _check_weapon_roll_order_is_after_dodge_and_before_crit() -> void:
	var player := _player()
	player.weapon_damage_min = 17
	player.weapon_damage_max = 19
	player.crit_chance = 0.5
	var monster := _monster()
	var seed := 123

	var expected_rng := RandomNumberGenerator.new()
	expected_rng.seed = seed
	expected_rng.randf() # Dodge check happens first for physical direct attacks.
	var expected_roll := expected_rng.randi_range(player.weapon_damage_min, player.weapon_damage_max)
	var expected_is_crit := expected_rng.randf() < player.crit_chance

	var result := CombatResolver.resolve([_physical_skill(10.0, 1000)], player, monster, 1000, seed)
	_require(result.cast_events.size() == 1, "Expected one physical cast.")
	_require(result.cast_events[0].weapon_damage_roll == expected_roll, "Expected weapon roll to happen after dodge RNG.")
	_require(result.cast_events[0].is_crit == expected_is_crit, "Expected crit RNG to happen after weapon roll.")


func _check_current_fixed_damage_is_unchanged() -> void:
	var player := _player()
	player.weapon_damage_min = 16
	player.weapon_damage_max = 25
	player.crit_chance = 0.0
	player.physical_damage_multiplier = 1.0
	var result := CombatResolver.resolve([_physical_skill(12.0, 1000)], player, _monster(), 1000, 5)
	_require(is_equal_approx(result.cast_events[0].physical_damage, 12.0), "Expected T3 to record weapon rolls without changing fixed damage yet.")
	_require(is_equal_approx(result.total_damage, 12.0), "Expected T3 not to change total damage yet.")


func _roll_signature(result: CombatResolver.CombatResult) -> String:
	var parts: PackedStringArray = []
	for event in result.cast_events:
		var event_rolls: PackedStringArray = []
		for roll in event.weapon_damage_rolls:
			event_rolls.append("%s:%s:%d:%d-%d" % [
				String(roll.get("kind", "")),
				String(roll.get("skill_id", "")),
				int(roll.get("roll", 0)),
				int(roll.get("min", 0)),
				int(roll.get("max", 0)),
			])
		parts.append("%d|%s|%d|%s|%.4f|%s" % [
			event.time_ms,
			event.skill.id,
			event.weapon_damage_roll,
			event.is_crit,
			event.physical_damage,
			",".join(event_rolls),
		])
	return "|".join(parts)


func _rolls(result: CombatResolver.CombatResult) -> PackedInt32Array:
	var rolls := PackedInt32Array()
	for event in result.cast_events:
		for roll in event.weapon_damage_rolls:
			rolls.append(int(roll["roll"]))
	return rolls


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


func _player() -> PlayerStats:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 0.0
	player.physical_damage_multiplier = 1.0
	player.poison_tick_interval_multiplier = 1.0
	return player


func _monster() -> Monster:
	var monster := Monster.new()
	monster.display_name = "Weapon Roll Dummy"
	monster.hp = 999999
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
