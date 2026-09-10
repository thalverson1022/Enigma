extends SceneTree
## Focused P4M1 enemy-defense mechanics check. Run with:
##   godot --headless -s res://tests/enemy_defense_mechanics_test.gd


func _initialize() -> void:
	_check_block_clamps_physical_damage()
	_check_crit_negation_reduces_crit_damage()
	_check_dodge_negates_physical_attack_and_attached_poison()
	_check_absorb_reduces_poison_tick_after_resistance()
	_check_suppress_increases_poison_tick_interval()
	_check_cleanse_resets_debuff_pressure()
	_check_slow_reduces_cast_count()
	_check_stun_delays_after_large_direct_hits()
	_check_interrupt_skips_only_repeated_direct_skill()
	_check_retriggers_count_toward_interrupt()
	_check_beguiling_strike_uses_base_decay_reduction()
	print("Enemy defense mechanics check: OK")
	quit()


func _check_block_clamps_physical_damage() -> void:
	var result := CombatResolver.resolve([_physical_skill(10.0, 1000)], _player(), _monster({"block": 25.0}), 1000, 1)
	assert(result.cast_events.size() == 1)
	assert(is_equal_approx(result.cast_events[0].physical_damage, 0.0))
	assert(is_equal_approx(result.cast_events[0].blocked_amount, 10.0))
	assert(is_equal_approx(result.total_damage, 0.0))


func _check_crit_negation_reduces_crit_damage() -> void:
	var player := _player()
	player.crit_chance = 1.0
	player.crit_multiplier = 2.0
	var result := CombatResolver.resolve([_physical_skill(100.0, 1000)], player, _monster({"crit_negation": 0.5}), 1000, 1)
	assert(result.cast_events.size() == 1)
	assert(result.cast_events[0].is_crit)
	assert(is_equal_approx(result.cast_events[0].physical_damage, 100.0))
	assert(is_equal_approx(result.cast_events[0].crit_negation_applied, 100.0))
	assert(is_equal_approx(result.cast_events[0].crit_negation_damage_prevented, 100.0))


func _check_dodge_negates_physical_attack_and_attached_poison() -> void:
	var skill := _physical_skill(100.0, 500)
	var poison := PoisonDamageEffect.new()
	poison.stacks_applied = 1
	skill.effects.append(poison)
	var player := _player()
	player.poison_damage_per_tick = 10.0
	var result := CombatResolver.resolve([skill], player, _monster({"dodge_chance": 1.0}), 1500, 1)
	assert(result.cast_events.size() == 3)
	for event in result.cast_events:
		assert(event.was_dodged)
		assert(is_equal_approx(event.physical_damage, 0.0))
		assert(event.poison_stacks_applied == 0)
	var log_text := CombatResultFormatter.format(result, _monster({"dodge_chance": 1.0}))
	assert(log_text.contains("Test Physical was DODGED"))
	assert(not log_text.contains("connects, to no effect"))
	assert(result.tick_events.any(func(tick): return tick.time_ms == 1000))
	assert(result.tick_events.all(func(tick): return is_equal_approx(tick.damage, 0.0)))


func _check_absorb_reduces_poison_tick_after_resistance() -> void:
	var player := _player()
	player.poison_damage_per_tick = 10.0
	var result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"poison_resistance": 0.5, "absorb": 3.0}), 1000, 1)
	assert(result.tick_events.size() == 1)
	assert(is_equal_approx(result.tick_events[0].damage, 2.0))
	assert(is_equal_approx(result.tick_events[0].absorbed_amount, 3.0))


func _check_suppress_increases_poison_tick_interval() -> void:
	var player := _player()
	player.poison_damage_per_tick = 10.0
	var result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"suppress": 0.5}), 3100, 1)
	var tick_times: PackedInt32Array = []
	for tick in result.tick_events:
		tick_times.append(tick.time_ms)
		assert(tick.tick_interval_ms == 1500)
	assert(tick_times.size() == 2)
	assert(tick_times[0] == 1500)
	assert(tick_times[1] == 3000)


func _check_cleanse_resets_debuff_pressure() -> void:
	var skill := _poison_skill(1, 500)
	var shred := ArmorReductionEffect.new()
	shred.amount = 10
	skill.effects.append(shred)
	var decay := PoisonResistanceReductionEffect.new()
	decay.reduction_fraction = 0.5
	skill.effects.append(decay)
	var result := CombatResolver.resolve([skill], _player(), _monster({"armor": 50, "poison_resistance": 0.4, "cleanse_threshold": 2}), 1000, 1)
	assert(result.cast_events.size() == 2)
	assert(not result.cast_events[0].cleanse_triggered)
	assert(result.cast_events[0].cleanse_counter == 1)
	assert(result.cast_events[1].cleanse_triggered)
	assert(result.cast_events[1].cleanse_counter == 0)


func _check_slow_reduces_cast_count() -> void:
	var skill := _physical_skill(1.0, 1000)
	var normal := CombatResolver.resolve([skill], _player(), _monster({}), 3000, 1)
	var slowed := CombatResolver.resolve([skill], _player(), _monster({"slow": 0.5}), 3000, 1)
	assert(normal.cast_events.size() == 3)
	assert(slowed.cast_events.size() == 2)
	assert(slowed.cast_events[0].time_ms == 1500)
	assert(slowed.cast_events[1].time_ms == 3000)


func _check_stun_delays_after_large_direct_hits() -> void:
	var monster := _monster({"stun_duration_ms": 500})
	monster.hp = 100
	var result := CombatResolver.resolve([_physical_skill(18.0, 1000)], _player(), monster, 3000, 1)
	assert(result.cast_events.size() == 2)
	assert(result.cast_events[0].time_ms == 1000)
	assert(result.cast_events[0].stun_duration_ms == 500)
	assert(result.cast_events[1].cast_start_ms == 1500)
	assert(result.cast_events[1].time_ms == 2500)


func _check_interrupt_skips_only_repeated_direct_skill() -> void:
	var stab := _physical_skill(10.0, 500)
	stab.id = "test.stab"
	stab.display_name = "Stab"
	var poison := _poison_skill(1, 500)
	poison.id = "test.poison"
	poison.display_name = "Poison"
	var monster := _monster({"interrupt_skip_count": 2})
	var repeated := CombatResolver.resolve([stab], _player(), monster, 3500, 1)
	assert(repeated.cast_events.size() == 7)
	assert(not repeated.cast_events[0].was_interrupted)
	assert(repeated.cast_events[0].interrupt_repeat_count == 1)
	assert(repeated.cast_events[0].interrupt_repeat_count_after == 1)
	assert(not repeated.cast_events[1].was_interrupted)
	assert(repeated.cast_events[1].interrupt_repeat_count == 2)
	assert(repeated.cast_events[1].interrupt_repeat_count_after == 2)
	assert(repeated.cast_events[2].interrupt_triggered)
	assert(repeated.cast_events[2].interrupt_repeat_count == 3)
	assert(repeated.cast_events[2].interrupt_repeat_count_after == 0)
	assert(repeated.cast_events[2].interrupt_skip_count_applied == 2)
	assert(repeated.cast_events[3].interrupt_skipped)
	assert(repeated.cast_events[3].interrupt_repeat_count_after == 0)
	assert(repeated.cast_events[4].interrupt_skipped)
	assert(not repeated.cast_events[5].was_interrupted)
	assert(repeated.cast_events[5].interrupt_repeat_count == 1)
	assert(is_equal_approx(repeated.total_damage, 40.0))

	var alternating := CombatResolver.resolve([stab, poison], _player(), monster, 3000, 1)
	assert(alternating.cast_events.size() == 6)
	assert(alternating.cast_events.all(func(event): return not event.was_interrupted))


func _check_retriggers_count_toward_interrupt() -> void:
	var stab := _physical_skill(10.0, 500)
	stab.id = "test.retrigger.stab"
	stab.display_name = "Retrigger Stab"
	var player := _player()
	player.retrigger_chance = 1.0
	var monster := _monster({"interrupt_skip_count": 1})
	var result := CombatResolver.resolve([stab], player, monster, 1000, 1)
	assert(result.cast_events.size() == 4)
	assert(not result.cast_events[0].was_interrupted)
	assert(result.cast_events[0].cast_kind == "cast")
	assert(result.cast_events[0].interrupt_repeat_count == 1)
	assert(not result.cast_events[1].was_interrupted)
	assert(result.cast_events[1].cast_kind == "proc")
	assert(result.cast_events[1].trigger_label == "RETRIGGER")
	assert(result.cast_events[1].interrupt_repeat_count == 2)
	assert(result.cast_events[2].cast_kind == "proc")
	assert(result.cast_events[2].trigger_label == "RETRIGGER")
	assert(result.cast_events[2].interrupt_triggered)
	assert(result.cast_events[2].interrupt_repeat_count == 3)
	assert(result.cast_events[2].interrupt_repeat_count_after == 0)
	assert(result.cast_events[2].interrupt_skip_count_applied == 1)
	assert(is_equal_approx(result.cast_events[2].physical_damage, 0.0))
	assert(result.cast_events[2].damage_contributions.is_empty())
	assert(result.cast_events[3].cast_kind == "cast")
	assert(result.cast_events[3].interrupt_skipped)
	assert(is_equal_approx(result.total_damage, 20.0))
	var log_text := CombatResultFormatter.format(result, monster)
	assert(log_text.contains("RETRIGGER"))
	assert(not log_text.contains("LEGENDARY"))


func _check_beguiling_strike_uses_base_decay_reduction() -> void:
	var beguiling_strike: Skill = load("res://data/skills/beguiling_strike.tres")
	var found_decay := false
	for effect in beguiling_strike.effects:
		if effect is PoisonResistanceReductionEffect:
			found_decay = true
			assert(is_equal_approx(effect.reduction_fraction, CombatResolver.BASE_DECAY_REDUCTION_FRACTION))
	assert(found_decay)


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


func _monster(values: Dictionary) -> Monster:
	var monster := Monster.new()
	monster.display_name = "Defense Dummy"
	monster.hp = 999999
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
