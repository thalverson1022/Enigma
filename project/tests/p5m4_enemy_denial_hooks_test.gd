extends SceneTree

func _initialize() -> void:
	print("-- P5M4 enemy denial hooks --")
	_check_dodge_denial_allows_guaranteed_dodge_monster_to_be_hit()
	_check_block_denial_prevents_physical_block()
	_check_absorb_denial_prevents_poison_absorb()
	_check_suppress_denial_restores_normal_tick_cadence()
	_check_cleanse_denial_preserves_debuff_pressure()
	_check_slow_immunity_restores_cast_timing()
	_check_stun_immunity_prevents_stun_delay()
	_check_interrupt_immunity_prevents_interrupts()
	_check_multiple_denials_combine()
	_check_stack_doubling_applies_after_flat_stack_bonus()
	_check_without_denials_enemy_mechanics_still_apply()
	print("P5M4 enemy denial hooks check: OK")
	quit(0)


func _check_dodge_denial_allows_guaranteed_dodge_monster_to_be_hit() -> void:
	var player := _player()
	player.special_effects = _specials(["dodge"])
	var result := CombatResolver.resolve([_physical_skill(10.0, 1000)], player, _monster({"dodge_chance": 1.0}), 1000, 3)
	var event := result.cast_events[0]
	_require(not event.was_dodged, "Expected dodge-denied monster not to dodge.")
	_require_approx(event.physical_damage, 10.0, "Expected dodge denial to let physical damage land.")


func _check_block_denial_prevents_physical_block() -> void:
	var player := _player()
	player.special_effects = _specials(["block"])
	var result := CombatResolver.resolve([_physical_skill(10.0, 1000)], player, _monster({"block": 25.0}), 1000, 5)
	var event := result.cast_events[0]
	_require_approx(event.physical_damage, 10.0, "Expected block denial to prevent physical block.")
	_require_approx(event.blocked_amount, 0.0, "Expected block denial to report no blocked amount.")


func _check_absorb_denial_prevents_poison_absorb() -> void:
	var player := _player()
	player.poison_damage_per_tick = 8.0
	player.special_effects = _specials(["absorb"])
	var result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"absorb": 20.0}), 1000, 7)
	_require_approx(result.tick_events[0].damage, 8.0, "Expected absorb denial to prevent poison absorb.")
	_require_approx(result.tick_events[0].absorbed_amount, 0.0, "Expected absorb denial to report no absorbed amount.")


func _check_suppress_denial_restores_normal_tick_cadence() -> void:
	var player := _player()
	player.poison_damage_per_tick = 5.0
	player.special_effects = _specials(["suppress"])
	var result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"suppress": 0.5}), 2100, 11)
	var tick_times := PackedInt32Array()
	for tick in result.tick_events:
		tick_times.append(tick.time_ms)
		_require(tick.tick_interval_ms == 1000, "Expected suppress denial to restore 1000ms poison ticks.")
	_require(tick_times.size() == 2, "Expected two normal-cadence ticks in 2100ms.")
	_require(tick_times[0] == 1000 and tick_times[1] == 2000, "Expected normal tick times with suppress denied.")


func _check_cleanse_denial_preserves_debuff_pressure() -> void:
	var player := _player()
	player.special_effects = _specials(["cleanse"])
	var skill := _physical_shred_skill(100.0, 1, 500)
	var result := CombatResolver.resolve([skill], player, _monster({"armor": 100, "cleanse_threshold": 2}), 1500, 13)
	_require(result.cast_events.size() == 3, "Expected three shred casts.")
	_require(result.cast_events.all(func(event): return not event.cleanse_triggered), "Expected cleanse denial to prevent cleanse triggers.")
	_require_approx(result.cast_events[0].physical_damage, 63.0, "Expected first hit against 100 armor.")
	_require_approx(result.cast_events[2].physical_damage, 67.0, "Expected third hit to keep reduced armor instead of cleanse-reset armor.")


func _check_slow_immunity_restores_cast_timing() -> void:
	var player := _player()
	player.special_effects = _specials([], {}, false, ["slow"])
	var result := CombatResolver.resolve([_physical_skill(10.0, 1000)], player, _monster({"slow": 0.5}), 2500, 14)
	_require(result.cast_events.size() == 2, "Expected slow immunity to allow two 1000ms casts in 2500ms.")
	_require(result.cast_events[0].time_ms == 1000 and result.cast_events[1].time_ms == 2000, "Expected slow immunity to preserve normal cast timing.")


func _check_stun_immunity_prevents_stun_delay() -> void:
	var player := _player()
	player.special_effects = _specials([], {}, false, ["stun"])
	var result := CombatResolver.resolve([_physical_skill(20.0, 1000)], player, _monster({"stun_duration_ms": 500, "hp": 100}), 2500, 16)
	_require(result.cast_events.size() == 2, "Expected stun immunity to avoid stun delay and allow two casts.")
	_require(result.cast_events.all(func(event): return event.stun_duration_ms == 0), "Expected stun immunity to prevent stun events.")
	_require(result.cast_events[0].time_ms == 1000 and result.cast_events[1].time_ms == 2000, "Expected stun immunity to preserve normal cast timing.")


func _check_interrupt_immunity_prevents_interrupts() -> void:
	var player := _player()
	player.special_effects = _specials([], {}, false, ["interrupt"])
	var result := CombatResolver.resolve([_physical_skill(10.0, 500)], player, _monster({"interrupt_skip_count": 1}), 2500, 18)
	_require(result.cast_events.size() == 5, "Expected interrupt immunity to allow every repeated cast through.")
	_require(result.cast_events.all(func(event): return not event.was_interrupted), "Expected interrupt immunity to prevent trigger and skipped casts.")
	_require(result.cast_events.all(func(event): return event.interrupt_skip_count_applied == 0), "Expected interrupt immunity to apply no interrupt skip count.")


func _check_multiple_denials_combine() -> void:
	var player := _player()
	player.poison_damage_per_tick = 8.0
	player.special_effects = _specials(["dodge", "block", "absorb"])
	var physical_result := CombatResolver.resolve([_physical_skill(10.0, 1000)], player, _monster({"dodge_chance": 1.0, "block": 25.0}), 1000, 17)
	_require(not physical_result.cast_events[0].was_dodged, "Expected combined dodge denial.")
	_require_approx(physical_result.cast_events[0].physical_damage, 10.0, "Expected combined block denial.")

	var poison_result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"absorb": 20.0}), 1000, 19)
	_require_approx(poison_result.tick_events[0].damage, 8.0, "Expected combined absorb denial.")


func _check_stack_doubling_applies_after_flat_stack_bonus() -> void:
	var player := _player()
	player.bonus_poison_stacks = 1
	player.special_effects = _specials([], {}, true)
	var result := CombatResolver.resolve([_poison_skill(2, 1000)], player, _monster({}), 1000, 23)
	_require(result.cast_events[0].poison_stacks_applied == 6, "Expected (2 base + 1 bonus) doubled once to 6 stacks.")


func _check_without_denials_enemy_mechanics_still_apply() -> void:
	var player := _player()
	player.poison_damage_per_tick = 8.0
	var dodge_result := CombatResolver.resolve([_physical_skill(10.0, 1000)], player, _monster({"dodge_chance": 1.0}), 1000, 29)
	_require(dodge_result.cast_events[0].was_dodged, "Expected guaranteed dodge to work without denial.")

	var block_result := CombatResolver.resolve([_physical_skill(10.0, 1000)], player, _monster({"block": 25.0}), 1000, 31)
	_require_approx(block_result.cast_events[0].physical_damage, 0.0, "Expected block to work without denial.")
	_require_approx(block_result.cast_events[0].blocked_amount, 10.0, "Expected blocked amount without denial.")

	var absorb_result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"absorb": 20.0}), 1000, 37)
	_require_approx(absorb_result.tick_events[0].damage, 0.0, "Expected absorb to work without denial.")
	_require_approx(absorb_result.tick_events[0].absorbed_amount, 8.0, "Expected absorbed amount without denial.")


func _player() -> PlayerStats:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 0.0
	player.physical_damage_multiplier = 1.0
	player.poison_tick_interval_multiplier = 1.0
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	return player


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


func _physical_shred_skill(amount: float, shred_amount: int, execution_ms: int) -> Skill:
	var skill := _physical_skill(amount, execution_ms)
	var shred := ArmorReductionEffect.new()
	shred.amount = shred_amount
	skill.effects.append(shred)
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


func _monster(values: Dictionary) -> Monster:
	var monster := Monster.new()
	monster.display_name = "Denial Dummy"
	monster.hp = int(values.get("hp", 999999))
	monster.armor = int(values.get("armor", 0))
	monster.poison_resistance = float(values.get("poison_resistance", 0.0))
	monster.dodge_chance = float(values.get("dodge_chance", 0.0))
	monster.crit_negation = float(values.get("crit_negation", 0.0))
	monster.block = float(values.get("block", 0.0))
	monster.absorb = float(values.get("absorb", 0.0))
	monster.cleanse_threshold = int(values.get("cleanse_threshold", 0))
	monster.suppress = float(values.get("suppress", 0.0))
	monster.slow = float(values.get("slow", 0.0))
	monster.stun_duration_ms = int(values.get("stun_duration_ms", 0))
	monster.interrupt_skip_count = int(values.get("interrupt_skip_count", 0))
	return monster


func _specials(denied: Array[String] = [], conversions: Dictionary = {}, double_stacks: bool = false, immunities: Array[String] = []) -> Dictionary:
	return {
		"enemy_denial": {
			"dodge": denied.has("dodge"),
			"block": denied.has("block"),
			"absorb": denied.has("absorb"),
			"suppress": denied.has("suppress"),
			"cleanse": denied.has("cleanse"),
		},
		"ignore_armor_no_shred": false,
		"ignore_resistance_physical_penalty": false,
		"physical_damage_penalty": 0.5,
		"double_applied_stacks": double_stacks,
		"damage_conversion": {
			"physical": bool(conversions.get("physical", false)),
			"magical": bool(conversions.get("magical", false)),
		},
		"immunities": {
			"stun": immunities.has("stun"),
			"slow": immunities.has("slow"),
			"interrupt": immunities.has("interrupt"),
		},
	}


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(absf(actual - expected) <= 0.01, "%s Expected %.4f, got %.4f." % [message, expected, actual])
