extends SceneTree


func _init() -> void:
	print("-- P5M4 crit applies poison --")
	_check_guaranteed_crit_applies_scaled_poison()
	_check_non_crit_does_not_apply_poison()
	_check_zero_proc_chance_does_not_apply_poison()
	_check_hold_does_not_apply_poison()
	_check_crit_poison_ticks_on_global_timer()
	_check_practice_room_gear_crit_poison_proc()
	print("P5M4 crit applies poison check: OK")
	quit(0)


func _check_guaranteed_crit_applies_scaled_poison() -> void:
	var player := _player()
	player.crit_chance = 1.0
	player.elemental_proc_chance = 1.0
	player.bonus_poison_stacks = 2
	var result := CombatResolver.resolve([_physical_skill()], player, _monster(), 1000, 1)
	_require(result.cast_events[0].is_crit, "Expected the setup to force a crit.")
	_require_equal("crit poison stacks", result.cast_events[0].poison_stacks_applied, 3)
	_require_equal("crit poison contribution stacks", _contribution_poison(result.cast_events[0]), 3)


func _check_non_crit_does_not_apply_poison() -> void:
	var player := _player()
	player.crit_chance = 0.0
	player.elemental_proc_chance = 1.0
	var result := CombatResolver.resolve([_physical_skill()], player, _monster(), 1000, 2)
	_require(not result.cast_events[0].is_crit, "Expected the setup to prevent crits.")
	_require_equal("non-crit poison stacks", result.cast_events[0].poison_stacks_applied, 0)


func _check_zero_proc_chance_does_not_apply_poison() -> void:
	var player := _player()
	player.crit_chance = 1.0
	player.elemental_proc_chance = 0.0
	var result := CombatResolver.resolve([_physical_skill()], player, _monster(), 1000, 3)
	_require(result.cast_events[0].is_crit, "Expected the setup to force a crit.")
	_require_equal("zero proc poison stacks", result.cast_events[0].poison_stacks_applied, 0)


func _check_hold_does_not_apply_poison() -> void:
	var player := _player()
	player.crit_chance = 1.0
	player.elemental_proc_chance = 1.0
	var result := CombatResolver.resolve([_hold_skill()], player, _monster(), 1000, 4)
	_require_equal("hold poison stacks", result.cast_events[0].poison_stacks_applied, 0)


func _check_crit_poison_ticks_on_global_timer() -> void:
	var player := _player()
	player.crit_chance = 1.0
	player.elemental_proc_chance = 1.0
	player.base_poison_damage = 8.0
	player.poison_damage_per_tick = 8.0
	var before_global_tick := CombatResolver.resolve([_physical_skill(750)], player, _monster(), 999, 5)
	_require_equal("single pre-tick cast count", before_global_tick.cast_events.size(), 1)
	_require_equal("pre-tick applied poison stacks", before_global_tick.cast_events[0].poison_stacks_applied, 1)
	_require_equal("pre-tick tick event count", before_global_tick.tick_events.size(), 0)

	var at_global_tick := CombatResolver.resolve([_physical_skill(750)], player, _monster(), 1000, 5)
	_require_equal("global tick first cast count", at_global_tick.cast_events.size(), 1)
	_require_equal("global tick applied poison stacks", at_global_tick.cast_events[0].poison_stacks_applied, 1)
	_require_equal("global tick event count", at_global_tick.tick_events.size(), 1)
	_require_equal("global tick time", at_global_tick.tick_events[0].time_ms, 1000)
	_require_equal("global tick stacks remaining", at_global_tick.tick_events[0].stacks_remaining, 0)
	_require_approx("global tick damage", at_global_tick.tick_events[0].damage, 8.0)


func _check_practice_room_gear_crit_poison_proc() -> void:
	var state := TrainingRoomState.new()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var stab: Skill = load("res://data/skills/stab.tres")
	state.set_class(rogue)
	state.set_slot_rarity(state.practice_helm, GearItem.Tier.EPIC)
	state.set_affix_stat(state.practice_helm, 0, StatCatalog.CRIT_CHANCE)
	state.practice_helm.affixes[0].value = 1.0
	state.set_affix_stat(state.practice_helm, 2, StatCatalog.CRIT_APPLIES_ELEMENT)
	state.practice_helm.affixes[2].value = 1.0
	state.notify_gear_edited()
	state.set_duration_ms(1500)
	state.set_fight_seed(7)
	state.set_rotation([stab])
	state.set_locked(true)

	var stats := BuildResolver.resolve_stats(state.selected_class, state.selected_trees, state.selected_talents, state.equipped_gear(), state.gold)
	_require_equal("practice resolved crit chance", stats.crit_chance, 1.0)
	_require_equal("practice resolved crit poison chance", stats.elemental_proc_chance, 1.0)
	state.run_fight()
	_require(state.last_result != null, "Expected Practice Room fight to produce a result.")
	_require_equal("practice one cast", state.last_result.cast_events.size(), 1)
	_require(state.last_result.cast_events[0].is_crit, "Expected Practice Room cast to crit.")
	_require_equal("practice crit poison stacks", state.last_result.cast_events[0].poison_stacks_applied, 1)
	_require_equal("practice crit poison contribution stacks", _contribution_poison(state.last_result.cast_events[0]), 1)


func _player() -> PlayerStats:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_multiplier = 2.0
	player.weapon_damage_min = 10
	player.weapon_damage_max = 10
	player.weapon_damage_uses_fallback = false
	return player


func _physical_skill(execution_ms: int = 500) -> Skill:
	var skill := Skill.new()
	skill.id = "skill.test_crit_poison_hit"
	skill.display_name = "Crit Poison Hit"
	skill.base_execution_ms = execution_ms
	skill.min_execution_ms = execution_ms
	var damage := PhysicalDamageEffect.new()
	damage.amount = 10.0
	skill.effects = [damage]
	return skill


func _hold_skill() -> Skill:
	var skill := Skill.new()
	skill.id = "skill.hold"
	skill.display_name = "Hold"
	skill.base_execution_ms = 500
	skill.min_execution_ms = 500
	return skill


func _monster() -> Monster:
	var monster := Monster.new()
	monster.display_name = "Crit Poison Dummy"
	monster.hp = 100000
	monster.armor = 0
	monster.poison_resistance = 0.0
	return monster


func _contribution_poison(event: CombatResolver.CastEvent) -> int:
	if event.damage_contributions.is_empty():
		return 0
	return int(event.damage_contributions[0].get("poison_stacks_applied", 0))


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_equal(label: String, actual: Variant, expected: Variant) -> void:
	_require(actual == expected, "%s expected %s, got %s." % [label, str(expected), str(actual)])


func _require_approx(label: String, actual: float, expected: float) -> void:
	_require(is_equal_approx(actual, expected), "%s expected %.3f, got %.3f." % [label, expected, actual])
