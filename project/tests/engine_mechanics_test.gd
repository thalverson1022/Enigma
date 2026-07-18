extends SceneTree
## Headless P2:M5 T0 check for the three new combat mechanics: armor
## reduction persisting across casts, physical damage multiplier, and bonus
## poison stacks. Uses synthetic Skill/Monster/PlayerStats objects (not real
## content) so the numbers are hand-computable in isolation. Run with:
##   godot --headless -s res://tests/engine_mechanics_test.gd


func _make_physical_skill(amount: float) -> Skill:
	var skill := Skill.new()
	skill.display_name = "Test Physical"
	skill.base_execution_ms = 1000
	skill.min_execution_ms = 500
	var effect := PhysicalDamageEffect.new()
	effect.amount = amount
	skill.effects = [effect]
	return skill


func _make_armor_reduction_skill(amount: float, reduction: int) -> Skill:
	var skill := Skill.new()
	skill.display_name = "Test Armor Reducer"
	skill.base_execution_ms = 1000
	skill.min_execution_ms = 500
	var physical := PhysicalDamageEffect.new()
	physical.amount = amount
	var armor_effect := ArmorReductionEffect.new()
	armor_effect.amount = reduction
	skill.effects = [physical, armor_effect]
	return skill


func _make_poison_skill(stacks: int) -> Skill:
	var skill := Skill.new()
	skill.display_name = "Test Poison"
	skill.base_execution_ms = 1000
	skill.min_execution_ms = 500
	var effect := PoisonDamageEffect.new()
	effect.stacks_applied = stacks
	skill.effects = [effect]
	return skill


func _make_poison_resistance_skill(reduction_fraction: float) -> Skill:
	var skill := Skill.new()
	skill.display_name = "Test Resistance Reducer"
	skill.base_execution_ms = 500
	skill.min_execution_ms = 500
	var effect := PoisonResistanceReductionEffect.new()
	effect.reduction_fraction = reduction_fraction
	skill.effects = [effect]
	return skill


func _make_stack_scaling_skill(damage_per_stack: float) -> Skill:
	var skill := Skill.new()
	skill.display_name = "Test Stack Scaler"
	skill.base_execution_ms = 1000
	skill.min_execution_ms = 500
	var effect := StackScalingPhysicalDamageEffect.new()
	effect.damage_per_stack = damage_per_stack
	skill.effects = [effect]
	return skill


func _make_stats() -> PlayerStats:
	var stats := PlayerStats.new()
	stats.attack_speed = 0.0
	stats.crit_chance = 0.0  # deterministic: no crits
	stats.crit_multiplier = 2.0
	stats.poison_damage_per_tick = 0.0
	return stats


func _make_trigger(skill: Skill, chance: float) -> TriggeredSkillEffect:
	var trigger := TriggeredSkillEffect.new()
	trigger.skill = skill
	trigger.chance = chance
	return trigger


func _make_monster(hp: int, armor: int, poison_resistance: float = 0.0) -> Monster:
	var monster := Monster.new()
	monster.display_name = "Test Dummy"
	monster.hp = hp
	monster.armor = armor
	monster.poison_resistance = poison_resistance
	return monster


func _initialize() -> void:
	# -- Armor reduction persists across casts (skill effect, not stat modifier) --
	# armor=100 -> mitigation 0.625; after -20 reduction, armor=80 -> mitigation 0.6667.
	var skill := _make_armor_reduction_skill(100.0, 20)
	var stats := _make_stats()
	var monster := _make_monster(1000000, 100)
	var rotation: Array[Skill] = [skill]
	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, stats, monster, 3000)
	print("armor-reduction casts=%d (expect 3)" % result.cast_events.size())
	assert(result.cast_events.size() == 3)
	var first: float = result.cast_events[0].physical_damage
	var second: float = result.cast_events[1].physical_damage
	print("cast1 damage=%.4f (expect ~62.5)" % first)
	print("cast2 damage=%.4f (expect ~66.6667, > cast1)" % second)
	assert(absf(first - 62.5) < 0.01)
	assert(absf(second - 66.6667) < 0.01)
	assert(second > first)
	assert(result.cast_events[0].armor_reduction_applied == 20)

	# -- physical_damage_multiplier --
	var mult_skill := _make_physical_skill(100.0)
	var mult_stats := _make_stats()
	mult_stats.physical_damage_multiplier = 1.5
	var flat_monster := _make_monster(1000000, 0)
	var mult_rotation: Array[Skill] = [mult_skill]
	var mult_result: CombatResolver.CombatResult = CombatResolver.resolve(mult_rotation, mult_stats, flat_monster, 1000)
	print("physical_damage_multiplier cast damage=%.2f (expect 150.0)" % mult_result.cast_events[0].physical_damage)
	assert(absf(mult_result.cast_events[0].physical_damage - 150.0) < 0.001)

	# -- bonus_poison_stacks --
	var poison_skill := _make_poison_skill(1)
	var poison_stats := _make_stats()
	poison_stats.bonus_poison_stacks = 2
	var poison_rotation: Array[Skill] = [poison_skill]
	var poison_result: CombatResolver.CombatResult = CombatResolver.resolve(poison_rotation, poison_stats, flat_monster, 1000)
	print("bonus_poison_stacks event stacks=%d (expect 3)" % poison_result.cast_events[0].poison_stacks_applied)
	assert(poison_result.cast_events[0].poison_stacks_applied == 3)

	# -- poison tick interval modifier --
	var cadence_stats := _make_stats()
	cadence_stats.poison_damage_per_tick = 10.0
	cadence_stats.poison_tick_interval_multiplier = 0.5
	var cadence_result: CombatResolver.CombatResult = CombatResolver.resolve(poison_rotation, cadence_stats, flat_monster, 2000)
	print("fast poison cadence ticks=%d (expect 4)" % cadence_result.tick_events.size())
	assert(cadence_result.tick_events.size() == 4)

	# -- triggered skills resolve immediately without consuming cast time --
	var trigger_base := _make_physical_skill(1.0)
	trigger_base.display_name = "Trigger Base"
	var trigger_skill := _make_physical_skill(10.0)
	trigger_skill.display_name = "Triggered Stab"
	var trigger_stats := _make_stats()
	trigger_stats.triggered_skill_effects = [_make_trigger(trigger_skill, 1.0)]
	var trigger_rotation: Array[Skill] = [trigger_base]
	var trigger_result: CombatResolver.CombatResult = CombatResolver.resolve(trigger_rotation, trigger_stats, flat_monster, 1000)
	print("triggered skills=%s" % str(trigger_result.cast_events[0].triggered_skill_names))
	assert(trigger_result.cast_events.size() == 1)
	assert(trigger_result.cast_events[0].triggered_skill_names.has("Triggered Stab"))
	assert(absf(trigger_result.cast_events[0].physical_damage - 11.0) < 0.001)

	# -- poison resistance reduction persists for later poison ticks --
	var resist_stats := _make_stats()
	resist_stats.poison_damage_per_tick = 10.0
	var resist_monster := _make_monster(1000000, 0, 0.5)
	var resist_rotation: Array[Skill] = [_make_poison_resistance_skill(0.5), _make_poison_skill(2)]
	var resist_result: CombatResolver.CombatResult = CombatResolver.resolve(resist_rotation, resist_stats, resist_monster, 3000)
	print("poison resistance reduction tick damage=%.2f (expect 7.5)" % resist_result.tick_events[1].damage)
	assert(is_equal_approx(resist_result.cast_events[0].poison_resistance_reduction_applied, 0.5))
	assert(absf(resist_result.tick_events[1].damage - 7.5) < 0.001)

	# -- stack-scaling physical damage reads active poison stacks at cast time --
	var stack_stats := _make_stats()
	stack_stats.poison_damage_per_tick = 0.0
	var stack_rotation: Array[Skill] = [_make_poison_skill(3), _make_stack_scaling_skill(2.0)]
	var stack_result: CombatResolver.CombatResult = CombatResolver.resolve(stack_rotation, stack_stats, flat_monster, 2000)
	print("stack-scaling damage=%.2f (expect 4.0 after one poison tick consumed)" % stack_result.cast_events[1].physical_damage)
	assert(absf(stack_result.cast_events[1].physical_damage - 4.0) < 0.001)

	print("")
	print("P2:M5 T0 engine mechanics check: OK")
	quit()
