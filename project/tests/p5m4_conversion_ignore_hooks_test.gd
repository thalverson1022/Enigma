extends SceneTree

const RENDING_SLASH := preload("res://data/skills/rending_slash.tres")


func _initialize() -> void:
	print("-- P5M4 conversion and ignore hooks --")
	_check_physical_converted_to_magical_uses_resistance()
	_check_poison_converted_to_physical_uses_armor()
	_check_dual_conversion_applies_physical_then_magical()
	_check_ignore_armor_uses_zero_armor()
	_check_ignore_armor_prevents_shred()
	_check_ignore_resistance_uses_zero_resistance()
	_check_ignore_resistance_penalizes_original_physical()
	_check_original_magical_converted_to_physical_is_not_penalized()
	print("P5M4 conversion and ignore hooks check: OK")
	quit(0)


func _check_physical_converted_to_magical_uses_resistance() -> void:
	var player := _player()
	player.special_effects = _specials({"magical": true})
	var result := CombatResolver.resolve([_physical_skill(100.0)], player, _monster({"armor": 100, "poison_resistance": 0.5}), 1000, 3)
	_require_approx(result.cast_events[0].physical_damage, 50.0, "Expected physical packet converted to magical to use resistance, not armor.")


func _check_poison_converted_to_physical_uses_armor() -> void:
	var player := _player()
	player.poison_damage_per_tick = 100.0
	player.special_effects = _specials({"physical": true})
	var result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"armor": 100, "poison_resistance": 0.5}), 1000, 5)
	_require_approx(result.tick_events[0].damage, 63.0, "Expected poison tick converted to physical to use armor, not resistance.")


func _check_dual_conversion_applies_physical_then_magical() -> void:
	var player := _player()
	player.special_effects = _specials({"physical": true, "magical": true})
	var result := CombatResolver.resolve([_physical_skill(100.0)], player, _monster({"armor": 100, "poison_resistance": 0.2}), 1000, 7)
	_require_approx(result.cast_events[0].physical_damage, 50.0, "Expected dual conversion to apply armor first, then resistance.")


func _check_ignore_armor_uses_zero_armor() -> void:
	var player := _player()
	player.special_effects = _specials({}, true)
	var result := CombatResolver.resolve([_physical_skill(100.0)], player, _monster({"armor": 100}), 1000, 11)
	_require_approx(result.cast_events[0].physical_damage, 100.0, "Expected ignore armor to treat armor as zero.")


func _check_ignore_armor_prevents_shred() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	player.special_effects = _specials({}, true)
	var result := CombatResolver.resolve([RENDING_SLASH], player, _monster({"armor": 100}), RENDING_SLASH.base_execution_ms, 13)
	_require(result.cast_events[0].armor_reduction_applied == 0, "Expected ignore armor Special to prevent Rending Slash shred.")


func _check_ignore_resistance_uses_zero_resistance() -> void:
	var player := _player()
	player.poison_damage_per_tick = 100.0
	player.special_effects = _specials({}, false, true)
	var result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"poison_resistance": 0.5}), 1000, 17)
	_require_approx(result.tick_events[0].damage, 100.0, "Expected ignore resistance to treat resistance as zero for magical packets.")


func _check_ignore_resistance_penalizes_original_physical() -> void:
	var player := _player()
	player.special_effects = _specials({"magical": true}, false, true)
	var result := CombatResolver.resolve([_physical_skill(100.0)], player, _monster({"poison_resistance": 0.5}), 1000, 19)
	_require_approx(result.cast_events[0].physical_damage, 50.0, "Expected ignore resistance to halve original physical damage before conversion and mitigation.")


func _check_original_magical_converted_to_physical_is_not_penalized() -> void:
	var player := _player()
	player.poison_damage_per_tick = 100.0
	player.special_effects = _specials({"physical": true}, false, true)
	var result := CombatResolver.resolve([_poison_skill(1, 500)], player, _monster({"armor": 0, "poison_resistance": 0.5}), 1000, 23)
	_require_approx(result.tick_events[0].damage, 100.0, "Expected original magical damage converted to physical to avoid the original-physical penalty.")


func _player() -> PlayerStats:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 0.0
	player.physical_damage_multiplier = 1.0
	player.poison_tick_interval_multiplier = 1.0
	return player


func _physical_skill(amount: float) -> Skill:
	var skill := Skill.new()
	skill.id = "test.fixed_physical"
	skill.display_name = "Test Fixed Physical"
	skill.base_execution_ms = 1000
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


func _monster(values: Dictionary = {}) -> Monster:
	var monster := Monster.new()
	monster.display_name = "Conversion Dummy"
	monster.hp = 999999
	monster.armor = int(values.get("armor", 0))
	monster.poison_resistance = float(values.get("poison_resistance", 0.0))
	monster.dodge_chance = 0.0
	monster.crit_negation = 0.0
	monster.block = float(values.get("block", 0.0))
	monster.absorb = float(values.get("absorb", 0.0))
	return monster


func _specials(conversion: Dictionary = {}, ignore_armor: bool = false, ignore_resistance: bool = false) -> Dictionary:
	return {
		"enemy_denial": {
			"dodge": false,
			"block": false,
			"absorb": false,
			"suppress": false,
			"cleanse": false,
		},
		"ignore_armor_no_shred": ignore_armor,
		"ignore_resistance_physical_penalty": ignore_resistance,
		"physical_damage_penalty": 0.5,
		"damage_conversion": {
			"physical": bool(conversion.get("physical", false)),
			"magical": bool(conversion.get("magical", false)),
		},
	}


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
