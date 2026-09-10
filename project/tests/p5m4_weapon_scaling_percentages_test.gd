extends SceneTree

const STAB := preload("res://data/skills/stab.tres")
const HEAVY_SLASH := preload("res://data/skills/heavy_slash.tres")
const QUICK_CUT := preload("res://data/skills/quick_cut.tres")
const STEAL := preload("res://data/skills/steal.tres")
const VENOM_JAB := preload("res://data/skills/venom_jab.tres")
const POISON_STRIKE := preload("res://data/skills/poison_strike.tres")
const RENDING_SLASH := preload("res://data/skills/rending_slash.tres")
const BEGUILING_STRIKE := preload("res://data/skills/beguiling_strike.tres")
const PLACEHOLDER_QUICK_CUT := preload("res://data/skills/placeholder_quick_cut.tres")


func _initialize() -> void:
	print("-- P5M4 weapon scaling percentages --")
	_check_scaling_percentages()
	_check_base_damage_applies_before_skill_scaling()
	_check_physical_buckets_apply_after_skill_scaling()
	_check_seeded_crit_order_for_scaled_skill()
	_check_dodge_prevents_scaled_packet()
	_check_steal_uses_scaled_hit_crit()
	_check_attached_effects_survive_scaling()
	_check_poison_strike_timing()
	_check_unlisted_physical_skill_keeps_fixed_damage()
	print("P5M4 weapon scaling percentages check: OK")
	quit(0)


func _check_scaling_percentages() -> void:
	_check_scaled_skill(STAB, 1.00)
	_check_scaled_skill(HEAVY_SLASH, 1.66)
	_check_scaled_skill(QUICK_CUT, 0.66)
	_check_scaled_skill(STEAL, 1.06)
	_check_scaled_skill(VENOM_JAB, 0.22)
	_check_scaled_skill(POISON_STRIKE, 0.83)
	_check_scaled_skill(RENDING_SLASH, 0.78)
	_check_scaled_skill(BEGUILING_STRIKE, 0.22)


func _check_scaled_skill(skill: Skill, scaling: float) -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	var result := CombatResolver.resolve([skill], player, _monster(), skill.base_execution_ms, 3)
	var expected := float(roundi(20.0 * scaling))
	_require_approx(result.cast_events[0].physical_damage, expected, "Expected %s to use weapon damage scaling." % skill.display_name)
	_require(result.cast_events[0].weapon_damage_rolls.size() == 1, "Expected %s to record one weapon roll." % skill.display_name)


func _check_base_damage_applies_before_skill_scaling() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	player.bonus_physical_damage = 5.0
	var result := CombatResolver.resolve([HEAVY_SLASH], player, _monster(), HEAVY_SLASH.base_execution_ms, 5)
	_require_approx(result.cast_events[0].physical_damage, float(roundi((20.0 + 5.0) * 1.66)), "Expected Base Damage before skill scaling.")


func _check_physical_buckets_apply_after_skill_scaling() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	player.bonus_physical_damage = 5.0
	player.gear_physical_damage_multiplier = 1.20
	player.talent_physical_damage_multiplier = 1.50
	player.physical_damage_uses_buckets = true
	player.sync_physical_damage_multiplier()
	var result := CombatResolver.resolve([POISON_STRIKE], player, _monster(), POISON_STRIKE.base_execution_ms, 7)
	var expected := float(roundi((20.0 + 5.0) * 0.83 * 1.20 * 1.50))
	_require_approx(result.cast_events[0].physical_damage, expected, "Expected physical buckets after skill scaling.")


func _check_seeded_crit_order_for_scaled_skill() -> void:
	var player := _player()
	player.weapon_damage_min = 16
	player.weapon_damage_max = 20
	player.crit_chance = 0.5
	player.crit_multiplier = 2.0
	var seed := 31

	var expected_rng := RandomNumberGenerator.new()
	expected_rng.seed = seed
	expected_rng.randf() # Dodge check.
	var expected_roll := expected_rng.randi_range(player.weapon_damage_min, player.weapon_damage_max)
	var expected_is_crit := expected_rng.randf() < player.crit_chance
	var expected := float(expected_roll) * 1.00
	if expected_is_crit:
		expected *= player.crit_multiplier
	expected = float(roundi(expected))

	var result := CombatResolver.resolve([STAB], player, _monster(), STAB.base_execution_ms, seed)
	var event := result.cast_events[0]
	_require(event.weapon_damage_roll == expected_roll, "Expected weapon roll after dodge RNG.")
	_require(event.is_crit == expected_is_crit, "Expected crit roll after weapon roll.")
	_require_approx(event.physical_damage, expected, "Expected crit to apply to the scaled weapon packet.")


func _check_dodge_prevents_scaled_packet() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	var monster := _monster()
	monster.dodge_chance = 1.0
	var result := CombatResolver.resolve([STAB], player, monster, STAB.base_execution_ms, 11)
	var event := result.cast_events[0]
	_require(event.was_dodged, "Expected scaled Stab to be dodged.")
	_require_approx(event.physical_damage, 0.0, "Expected dodged scaled Stab to deal no damage.")
	_require(event.weapon_damage_rolls.is_empty(), "Expected dodged scaled Stab to skip weapon rolling.")


func _check_steal_uses_scaled_hit_crit() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	player.crit_chance = 1.0
	player.crit_multiplier = 2.0
	var result := CombatResolver.resolve([STEAL], player, _monster(), STEAL.base_execution_ms, 13)
	var event := result.cast_events[0]
	_require(event.is_crit, "Expected forced crit Steal to crit.")
	_require_approx(event.physical_damage, float(roundi(20.0 * 1.06 * 2.0)), "Expected Steal crit to use scaled weapon damage.")
	_require(event.gold_stolen == 3, "Expected Steal's gold-on-crit effect to survive scaled damage.")


func _check_attached_effects_survive_scaling() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	var venom_result := CombatResolver.resolve([VENOM_JAB], player, _monster(), VENOM_JAB.base_execution_ms, 17)
	_require_approx(venom_result.cast_events[0].physical_damage, float(roundi(20.0 * 0.22)), "Expected Venom Jab's scaled damage.")
	_require(venom_result.cast_events[0].poison_stacks_applied == 8, "Expected Venom Jab to still apply poison stacks.")

	var rending_result := CombatResolver.resolve([RENDING_SLASH], player, _monster(), RENDING_SLASH.base_execution_ms, 19)
	_require_approx(rending_result.cast_events[0].physical_damage, float(roundi(20.0 * 0.78)), "Expected Rending Slash's scaled damage.")
	_require(rending_result.cast_events[0].shred_stacks_applied == 2, "Expected Rending Slash to apply two Shred stacks.")
	_require(rending_result.cast_events[0].armor_reduction_applied == 20, "Expected base Shred to reduce 20 armor.")


func _check_poison_strike_timing() -> void:
	_require(POISON_STRIKE.base_execution_ms == 1200, "Expected Poison Strike to use 1.2s base attack time.")
	_require(POISON_STRIKE.min_execution_ms == 500, "Expected Poison Strike to use the fast minimum attack time.")


func _check_unlisted_physical_skill_keeps_fixed_damage() -> void:
	var player := _player()
	player.weapon_damage_min = 20
	player.weapon_damage_max = 20
	var result := CombatResolver.resolve([PLACEHOLDER_QUICK_CUT], player, _monster(), PLACEHOLDER_QUICK_CUT.base_execution_ms, 23)
	_require_approx(result.cast_events[0].physical_damage, 12.0, "Expected unlisted physical skills to keep fixed damage compatibility.")


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
	monster.display_name = "Scaling Dummy"
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


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
