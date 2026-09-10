extends SceneTree
## Focused P5M4-T10 checks for final damage floors, rounding, and mitigation order.


func _initialize() -> void:
	print("-- P5M4 rounding, floors, and mitigation order --")
	_check_tiny_physical_hit_floors_to_one()
	_check_full_block_stays_zero()
	_check_partial_blocked_hit_can_floor_to_one()
	_check_tiny_magical_hit_floors_to_one()
	_check_full_absorb_stays_zero()
	_check_fractional_damage_rounds_once_at_the_end()
	_check_crit_before_conversion()
	_check_dual_conversion_order()
	_check_crit_negation_order_and_reporting()
	_check_poison_ticks_use_final_policy()
	print("P5M4 rounding, floors, and mitigation order check: OK")
	quit(0)


func _check_tiny_physical_hit_floors_to_one() -> void:
	var damage := DamageCalculator.resolve_damage_packet(0.25, "physical", 0, 0.0, 0.0, 2.0, null)
	_require_approx(damage["amount"], 1.0, "Expected tiny non-prevented physical hit to floor to 1.")


func _check_full_block_stays_zero() -> void:
	var damage := DamageCalculator.resolve_damage_packet(0.25, "physical", 0, 0.0, 0.0, 2.0, null, 1.0, 0.0, 1.0)
	_require_approx(damage["amount"], 0.0, "Expected fully blocked physical hit to stay 0.")
	_require_approx(damage["blocked_amount"], 0.25, "Expected block to record the prevented physical amount.")


func _check_partial_blocked_hit_can_floor_to_one() -> void:
	var damage := DamageCalculator.resolve_damage_packet(2.2, "physical", 0, 0.0, 0.0, 2.0, null, 1.0, 0.0, 1.8)
	_require_approx(damage["amount"], 1.0, "Expected partially blocked physical hit below 1 to floor to 1.")
	_require_approx(damage["blocked_amount"], 1.8, "Expected partial block amount to be preserved before final floor.")


func _check_tiny_magical_hit_floors_to_one() -> void:
	var damage := DamageCalculator.resolve_damage_packet(0.4, "magical", 0, 0.0, 0.0, 1.0, null)
	_require_approx(damage["amount"], 1.0, "Expected tiny non-prevented magical hit to floor to 1.")


func _check_full_absorb_stays_zero() -> void:
	var damage := DamageCalculator.resolve_damage_packet(0.4, "magical", 0, 0.0, 0.0, 1.0, null, 1.0, 0.0, 0.0, 1.0)
	_require_approx(damage["amount"], 0.0, "Expected fully absorbed magical hit to stay 0.")
	_require_approx(damage["absorbed_amount"], 0.4, "Expected absorb to record the prevented magical amount.")


func _check_fractional_damage_rounds_once_at_the_end() -> void:
	var damage := DamageCalculator.resolve_damage_packet(10.0, "physical", 0, 0.0, 0.0, 2.0, null, 1.049)
	_require_approx(damage["amount"], 10.0, "Expected final damage to round once after multiplier and mitigation.")
	var rounds_up := DamageCalculator.resolve_damage_packet(10.0, "physical", 0, 0.0, 0.0, 2.0, null, 1.051)
	_require_approx(rounds_up["amount"], 11.0, "Expected final damage to round to nearest whole damage after mitigation.")


func _check_crit_before_conversion() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	var damage := DamageCalculator.resolve_damage_packet(
		10.0, "physical", 0, 0.5, 1.0, 2.0, rng, 1.0, 0.0, 0.0, 0.0,
		1.0, 1.0, false, true
	)
	_require(bool(damage["is_crit"]), "Expected forced crit to be recorded before magical conversion.")
	_require_approx(damage["amount"], 10.0, "Expected crit to double damage before resistance mitigation.")


func _check_dual_conversion_order() -> void:
	var damage := DamageCalculator.resolve_damage_packet(
		40.0, "physical", 100, 0.2, 0.0, 2.0, null, 1.0, 0.0, 0.0, 0.0,
		1.0, 1.0, true, true
	)
	_require_approx(damage["amount"], 20.0, "Expected dual conversion to apply armor first, then resistance, then final rounding.")


func _check_crit_negation_order_and_reporting() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 2
	var damage := DamageCalculator.resolve_damage_packet(100.0, "physical", 0, 0.0, 1.0, 2.0, rng, 1.0, 0.5)
	_require(bool(damage["is_crit"]), "Expected forced crit before crit negation.")
	_require_approx(damage["amount"], 100.0, "Expected crit negation to halve a 200 damage crit before final damage.")
	_require_approx(damage["crit_negation_applied"], 100.0, "Expected crit negation to record raw prevented crit damage.")
	_require_approx(damage["crit_negation_damage_prevented"], 100.0, "Expected crit negation prevented damage reporting to remain stable.")


func _check_poison_ticks_use_final_policy() -> void:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 0.4
	var monster := Monster.new()
	monster.display_name = "Rounding Dummy"
	monster.hp = 999999
	monster.armor = 0
	monster.poison_resistance = 0.0
	var result := CombatResolver.resolve([_poison_skill()], player, monster, 1000, 7)
	_require(result.tick_events.size() == 1, "Expected one poison cadence tick.")
	_require_approx(result.tick_events[0].damage, 1.0, "Expected poison tick to use the shared final floor policy.")


func _poison_skill() -> Skill:
	var skill := Skill.new()
	skill.id = "test.poison"
	skill.display_name = "Test Poison"
	skill.base_execution_ms = 500
	skill.min_execution_ms = 100
	var poison := PoisonDamageEffect.new()
	poison.stacks_applied = 1
	skill.effects = [poison]
	return skill


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
