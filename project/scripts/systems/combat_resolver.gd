class_name CombatResolver
extends RefCounted

const POISON_TICK_INTERVAL_MS: int = 1000
const MAX_POISON_STACKS: int = 20


class CastEvent:
	var time_ms: int = 0
	var skill: Skill
	var physical_damage: float = 0.0
	var is_crit: bool = false
	var poison_stacks_applied: int = 0
	var armor_reduction_applied: int = 0
	var poison_resistance_reduction_applied: float = 0.0
	var triggered_skill_names: PackedStringArray = []
	var min_cast_time_proc_applied: bool = false


class TickEvent:
	var time_ms: int = 0
	var damage: float = 0.0
	var stacks_remaining: int = 0


class CombatResult:
	var duration_ms: int = 0
	var total_damage: float = 0.0
	var dps: float = 0.0
	var is_win: bool = false
	var cast_events: Array[CastEvent] = []
	var tick_events: Array[TickEvent] = []


## Resolves a looping rotation against a monster for a fixed-duration DPS window.
## Casts that would finish after the window are skipped; poison ticks on a fixed
## cadence independent of cast timing, per docs/Phase 1 Context Docs/Current_Mechanics_Reference.md.
## Armor reductions from ArmorReductionEffect persist for the rest of the fight
## (P2:M5) -- effects are applied in Skill.effects array order, so a
## PhysicalDamageEffect listed before an ArmorReductionEffect on the same skill
## uses pre-reduction armor for its own hit; only later casts see the reduction.
static func resolve(rotation: Array[Skill], player: PlayerStats, monster: Monster, duration_ms: int, rng_seed: int = 1) -> CombatResult:
	var result := CombatResult.new()
	result.duration_ms = duration_ms

	if rotation.is_empty():
		return result

	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed

	var current_armor: int = monster.armor
	var current_poison_resistance: float = monster.poison_resistance
	var active_stacks: int = 0
	var tick_interval_ms: int = max(1, roundi(float(POISON_TICK_INTERVAL_MS) * player.poison_tick_interval_multiplier))
	var next_tick_time_ms: int = tick_interval_ms
	var cast_time_ms: int = 0
	var rotation_index: int = 0
	while true:
		var skill: Skill = rotation[rotation_index % rotation.size()]
		var used_min_cast_time: bool = player.min_cast_time_proc_chance > 0.0 and rng.randf() <= player.min_cast_time_proc_chance
		var exec_ms: int = skill.min_execution_ms if used_min_cast_time else CombatTiming.execution_time_ms(skill, player.attack_speed)
		var cast_end_ms: int = cast_time_ms + exec_ms
		if cast_end_ms > duration_ms:
			break
		while next_tick_time_ms <= cast_end_ms:
			active_stacks = _resolve_poison_tick(result, next_tick_time_ms, active_stacks, player, current_poison_resistance)
			next_tick_time_ms += tick_interval_ms

		var event := CastEvent.new()
		event.time_ms = cast_end_ms
		event.skill = skill
		event.min_cast_time_proc_applied = used_min_cast_time
		var state := _apply_skill_effects(skill, event, player, current_armor, current_poison_resistance, active_stacks, rng)
		current_armor = state["armor"]
		current_poison_resistance = state["poison_resistance"]
		for trigger in player.triggered_skill_effects:
			if trigger == null or trigger.skill == null:
				continue
			if not _trigger_matches_source(trigger, skill):
				continue
			if rng.randf() <= trigger.chance:
				event.triggered_skill_names.append(trigger.skill.display_name)
				state = _apply_skill_effects(trigger.skill, event, player, current_armor, current_poison_resistance, active_stacks, rng)
				current_armor = state["armor"]
				current_poison_resistance = state["poison_resistance"]

		result.total_damage += event.physical_damage
		active_stacks = mini(active_stacks + event.poison_stacks_applied, MAX_POISON_STACKS)
		result.cast_events.append(event)
		cast_time_ms = cast_end_ms
		rotation_index += 1

	while next_tick_time_ms <= duration_ms:
		active_stacks = _resolve_poison_tick(result, next_tick_time_ms, active_stacks, player, current_poison_resistance)
		next_tick_time_ms += tick_interval_ms

	result.dps = result.total_damage / (float(duration_ms) / 1000.0)
	result.is_win = result.total_damage >= float(monster.hp)
	return result


static func _trigger_matches_source(trigger: TriggeredSkillEffect, source_skill: Skill) -> bool:
	if trigger.source_skill_ids.is_empty():
		return true
	if source_skill == null:
		return false
	return trigger.source_skill_ids.has(source_skill.id)


static func _resolve_poison_tick(result: CombatResult, tick_time_ms: int, active_stacks: int, player: PlayerStats, current_poison_resistance: float) -> int:
	var tick := TickEvent.new()
	tick.time_ms = tick_time_ms
	if active_stacks > 0:
		active_stacks -= 1
		tick.damage = DamageCalculator.resolve_poison_tick(player.poison_damage_per_tick, current_poison_resistance)
		result.total_damage += tick.damage
	tick.stacks_remaining = active_stacks
	result.tick_events.append(tick)
	return active_stacks


static func _apply_skill_effects(skill: Skill, event: CastEvent, player: PlayerStats, current_armor: int, current_poison_resistance: float, active_poison_stacks: int, rng: RandomNumberGenerator) -> Dictionary:
	var effect_poison_stacks := 0
	for effect in skill.effects:
		if effect is PhysicalDamageEffect:
			var physical_effect: PhysicalDamageEffect = effect
			var hit := DamageCalculator.resolve_physical_hit(
				physical_effect.amount + player.bonus_physical_damage, current_armor, player.crit_chance, player.crit_multiplier, rng, player.physical_damage_multiplier
			)
			event.physical_damage += hit.amount
			event.is_crit = event.is_crit or hit.is_crit
		elif effect is StackScalingPhysicalDamageEffect:
			var stack_effect: StackScalingPhysicalDamageEffect = effect
			if active_poison_stacks > 0:
				var hit := DamageCalculator.resolve_physical_hit(
					stack_effect.damage_per_stack * float(active_poison_stacks) + player.bonus_physical_damage, current_armor, player.crit_chance, player.crit_multiplier, rng, player.physical_damage_multiplier
				)
				event.physical_damage += hit.amount
				event.is_crit = event.is_crit or hit.is_crit
		elif effect is PoisonDamageEffect:
			var poison_effect: PoisonDamageEffect = effect
			effect_poison_stacks += poison_effect.stacks_applied
		elif effect is ArmorReductionEffect:
			var armor_effect: ArmorReductionEffect = effect
			var reduction: int = armor_effect.amount + player.bonus_armor_reduction
			current_armor -= reduction
			event.armor_reduction_applied += reduction
		elif effect is PoisonResistanceReductionEffect:
			var resistance_effect: PoisonResistanceReductionEffect = effect
			var reduction_fraction: float = clampf(resistance_effect.reduction_fraction, 0.0, 1.0)
			current_poison_resistance *= 1.0 - reduction_fraction
			event.poison_resistance_reduction_applied += reduction_fraction
	var poison_stacks := effect_poison_stacks if effect_poison_stacks > 0 else skill.poison_stacks_applied
	if poison_stacks > 0:
		event.poison_stacks_applied += poison_stacks + player.bonus_poison_stacks
	return {
		"armor": current_armor,
		"poison_resistance": current_poison_resistance,
	}
