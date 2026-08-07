extends SceneTree
## Headless P2:M5 T0 check for the three new combat mechanics: armor
## reduction persisting across casts, physical damage multiplier, and bonus
## poison stacks. Uses synthetic Skill/Monster/PlayerStats objects (not real
## content) so the numbers are hand-computable in isolation. Run with:
##   godot --headless -s res://tests/engine_mechanics_test.gd

var _failed := false


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


func _damage_contribution(event: CombatResolver.CastEvent, name: String) -> Dictionary:
	for contribution in event.damage_contributions:
		if String(contribution.get("name", "")) == name:
			return contribution
	return {}


func _initialize() -> void:
	# -- Armor reduction persists across casts (skill effect, not stat modifier) --
	# armor=100 -> mitigation 0.625; after -20 reduction, armor=80 -> mitigation 0.6667.
	var skill := _make_armor_reduction_skill(100.0, 20)
	var stats := _make_stats()
	var monster := _make_monster(1000000, 100)
	var rotation: Array[Skill] = [skill]
	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, stats, monster, 3000)
	print("armor-reduction casts=%d (expect 3)" % result.cast_events.size())
	_require_equal("armor_reduction_persists cast count", result.cast_events.size(), 3, {
		"rotation": _skill_names(rotation),
		"monster": _monster_summary(monster),
		"duration_ms": 3000,
	})
	var first: float = result.cast_events[0].physical_damage
	var second: float = result.cast_events[1].physical_damage
	print("cast1 damage=%.4f (expect ~62.5)" % first)
	print("cast2 damage=%.4f (expect ~66.6667, > cast1)" % second)
	_require_approx("armor_reduction_persists first cast damage", first, 62.5, 0.01, {
		"armor_before": 100,
		"reduction": 20,
	})
	_require_approx("armor_reduction_persists second cast damage", second, 66.6667, 0.01, {
		"armor_before": 100,
		"reduction": 20,
	})
	_require("armor_reduction_persists damage increases", second > first, {
		"first": first,
		"second": second,
	})
	_require_equal("armor_reduction_persists applied amount", result.cast_events[0].armor_reduction_applied, 20, {
		"event": _cast_summary(result.cast_events[0]),
	})

	# -- physical_damage_multiplier --
	var mult_skill := _make_physical_skill(100.0)
	var mult_stats := _make_stats()
	mult_stats.physical_damage_multiplier = 1.5
	var flat_monster := _make_monster(1000000, 0)
	var mult_rotation: Array[Skill] = [mult_skill]
	var mult_result: CombatResolver.CombatResult = CombatResolver.resolve(mult_rotation, mult_stats, flat_monster, 1000)
	print("physical_damage_multiplier cast damage=%.2f (expect 150.0)" % mult_result.cast_events[0].physical_damage)
	_require_approx("physical_damage_multiplier damage", mult_result.cast_events[0].physical_damage, 150.0, 0.001, {
		"rotation": _skill_names(mult_rotation),
		"multiplier": mult_stats.physical_damage_multiplier,
		"monster": _monster_summary(flat_monster),
	})

	# -- bonus_poison_stacks --
	var poison_skill := _make_poison_skill(1)
	var poison_stats := _make_stats()
	poison_stats.bonus_poison_stacks = 2
	var poison_rotation: Array[Skill] = [poison_skill]
	var poison_result: CombatResolver.CombatResult = CombatResolver.resolve(poison_rotation, poison_stats, flat_monster, 1000)
	print("bonus_poison_stacks event stacks=%d (expect 3)" % poison_result.cast_events[0].poison_stacks_applied)
	_require_equal("bonus_poison_stacks applied stacks", poison_result.cast_events[0].poison_stacks_applied, 3, {
		"base_stacks": 1,
		"bonus_stacks": poison_stats.bonus_poison_stacks,
	})

	var primitive_poison_skill := _make_physical_skill(1.0)
	primitive_poison_skill.poison_stacks_applied = 1
	var primitive_poison_stats := _make_stats()
	primitive_poison_stats.poison_damage_per_tick = 10.0
	var primitive_poison_result: CombatResolver.CombatResult = CombatResolver.resolve([primitive_poison_skill], primitive_poison_stats, flat_monster, 2000)
	print("primitive poison stacks=%d ticks=%d (expect 1, >0)" % [
		primitive_poison_result.cast_events[0].poison_stacks_applied,
		primitive_poison_result.tick_events.filter(func(tick): return tick.damage > 0.0).size(),
	])
	_require_equal("primitive_poison stacks applied", primitive_poison_result.cast_events[0].poison_stacks_applied, 1, {
		"skill": primitive_poison_skill.display_name,
	})
	_require("primitive_poison produces damaging tick", primitive_poison_result.tick_events.any(func(tick): return tick.damage > 0.0), {
		"ticks": _tick_summaries(primitive_poison_result.tick_events),
	})

	# -- poison tick interval modifier --
	var cadence_stats := _make_stats()
	cadence_stats.poison_damage_per_tick = 10.0
	cadence_stats.poison_tick_interval_multiplier = 0.5
	var cadence_result: CombatResolver.CombatResult = CombatResolver.resolve(poison_rotation, cadence_stats, flat_monster, 2000)
	print("fast poison cadence ticks=%d (expect 4)" % cadence_result.tick_events.size())
	_require_equal("poison_tick_interval_modifier tick count", cadence_result.tick_events.size(), 4, {
		"duration_ms": 2000,
		"interval_multiplier": cadence_stats.poison_tick_interval_multiplier,
		"ticks": _tick_summaries(cadence_result.tick_events),
	})

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
	_require_equal("triggered_skill_immediate cast count", trigger_result.cast_events.size(), 1, {
		"rotation": _skill_names(trigger_rotation),
		"duration_ms": 1000,
	})
	_require("triggered_skill_immediate proc name", trigger_result.cast_events[0].triggered_skill_names.has("Triggered Stab"), {
		"triggered_skill_names": trigger_result.cast_events[0].triggered_skill_names,
	})
	_require_approx("triggered_skill_immediate total damage", trigger_result.cast_events[0].physical_damage, 11.0, 0.001, {
		"event": _cast_summary(trigger_result.cast_events[0]),
	})
	_require_equal("triggered_skill_immediate contribution count", trigger_result.cast_events[0].damage_contributions.size(), 2, {
		"contributions": trigger_result.cast_events[0].damage_contributions,
	})
	_require_equal("triggered_skill_immediate base contribution kind", _damage_contribution(trigger_result.cast_events[0], "Trigger Base").get("kind", ""), "cast", {
		"contributions": trigger_result.cast_events[0].damage_contributions,
	})
	_require_equal("triggered_skill_immediate proc contribution kind", _damage_contribution(trigger_result.cast_events[0], "Triggered Stab").get("kind", ""), "proc", {
		"contributions": trigger_result.cast_events[0].damage_contributions,
	})
	_require_approx("triggered_skill_immediate base contribution damage", float(_damage_contribution(trigger_result.cast_events[0], "Trigger Base").get("damage", -1.0)), 1.0, 0.001, {
		"contributions": trigger_result.cast_events[0].damage_contributions,
	})
	_require_approx("triggered_skill_immediate proc contribution damage", float(_damage_contribution(trigger_result.cast_events[0], "Triggered Stab").get("damage", -1.0)), 10.0, 0.001, {
		"contributions": trigger_result.cast_events[0].damage_contributions,
	})

	# -- poison resistance reduction persists for later poison ticks --
	var resist_stats := _make_stats()
	resist_stats.poison_damage_per_tick = 10.0
	var resist_monster := _make_monster(1000000, 0, 0.5)
	var resist_rotation: Array[Skill] = [_make_poison_resistance_skill(0.5), _make_poison_skill(2)]
	var resist_result: CombatResolver.CombatResult = CombatResolver.resolve(resist_rotation, resist_stats, resist_monster, 3000)
	print("poison resistance reduction tick damage=%.2f (expect 7.5)" % resist_result.tick_events[1].damage)
	_require_approx("poison_resistance_reduction applied", resist_result.cast_events[0].poison_resistance_reduction_applied, 0.5, 0.001, {
		"monster": _monster_summary(resist_monster),
		"rotation": _skill_names(resist_rotation),
	})
	_require_approx("poison_resistance_reduction later tick damage", resist_result.tick_events[1].damage, 7.5, 0.001, {
		"monster": _monster_summary(resist_monster),
		"ticks": _tick_summaries(resist_result.tick_events),
	})

	# -- stack-scaling physical damage reads active poison stacks at cast time --
	var stack_stats := _make_stats()
	stack_stats.poison_damage_per_tick = 0.0
	var stack_rotation: Array[Skill] = [_make_poison_skill(3), _make_stack_scaling_skill(2.0)]
	var stack_result: CombatResolver.CombatResult = CombatResolver.resolve(stack_rotation, stack_stats, flat_monster, 2000)
	print("stack-scaling damage=%.2f (expect 4.0 after one poison tick consumed)" % stack_result.cast_events[1].physical_damage)
	_require_approx("stack_scaling_physical_damage active stack read", stack_result.cast_events[1].physical_damage, 4.0, 0.001, {
		"rotation": _skill_names(stack_rotation),
		"ticks": _tick_summaries(stack_result.tick_events),
	})

	print("")
	if _failed:
		print("P2:M5 T0 engine mechanics check: FAILED")
		quit(1)
	print("P2:M5 T0 engine mechanics check: OK")
	quit()


func _require(label: String, condition: bool, context: Dictionary = {}) -> void:
	if condition:
		return
	_failed = true
	print("FAILED: %s" % label)
	for key in context.keys():
		print("  %s: %s" % [key, str(context[key])])


func _require_equal(label: String, actual: Variant, expected: Variant, context: Dictionary = {}) -> void:
	context["expected"] = expected
	context["actual"] = actual
	_require(label, actual == expected, context)


func _require_approx(label: String, actual: float, expected: float, tolerance: float, context: Dictionary = {}) -> void:
	context["expected"] = expected
	context["actual"] = actual
	context["tolerance"] = tolerance
	_require(label, absf(actual - expected) <= tolerance, context)


func _skill_names(skills: Array[Skill]) -> PackedStringArray:
	var names: PackedStringArray = []
	for skill in skills:
		names.append("%s(%s)" % [skill.display_name, skill.id])
	return names


func _monster_summary(monster: Monster) -> Dictionary:
	return {
		"name": monster.display_name,
		"hp": monster.hp,
		"armor": monster.armor,
		"poison_resistance": monster.poison_resistance,
	}


func _cast_summary(event: CombatResolver.CastEvent) -> Dictionary:
	return {
		"time_ms": event.time_ms,
		"skill": event.skill.display_name,
		"physical_damage": event.physical_damage,
		"poison_stacks_applied": event.poison_stacks_applied,
		"armor_reduction_applied": event.armor_reduction_applied,
		"poison_resistance_reduction_applied": event.poison_resistance_reduction_applied,
		"triggered_skill_names": event.triggered_skill_names,
		"damage_contributions": event.damage_contributions,
	}


func _tick_summaries(ticks: Array) -> Array:
	var summaries: Array = []
	for tick in ticks:
		summaries.append({
			"time_ms": tick.time_ms,
			"damage": tick.damage,
			"stacks_remaining": tick.stacks_remaining,
		})
	return summaries
