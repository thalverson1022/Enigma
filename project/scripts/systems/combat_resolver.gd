class_name CombatResolver
extends RefCounted

const POISON_TICK_INTERVAL_MS: int = 1000
const MAX_POISON_STACKS: int = 20
const STUN_TRIGGER_HIT_PERCENT: float = 0.12
const INTERRUPT_REPEAT_THRESHOLD: int = 3


class CastEvent:
	var cast_start_ms: int = 0
	var time_ms: int = 0
	var skill: Skill
	var rotation_index: int = -1
	var physical_damage: float = 0.0
	var damage_contributions: Array[Dictionary] = []
	var is_crit: bool = false
	var was_dodged: bool = false
	var dodged_attacks: int = 0
	var blocked_amount: float = 0.0
	var crit_negation_applied: float = 0.0
	var crit_negation_damage_prevented: float = 0.0
	var poison_stacks_applied: int = 0
	var armor_reduction_applied: int = 0
	var poison_resistance_reduction_applied: float = 0.0
	var cleanse_counter: int = 0
	var cleanse_triggered: bool = false
	var triggered_skill_names: PackedStringArray = []
	var min_cast_time_proc_applied: bool = false
	var stun_duration_ms: int = 0
	var was_interrupted: bool = false
	var interrupt_triggered: bool = false
	var interrupt_skipped: bool = false
	var interrupt_repeat_count: int = 0
	var interrupt_repeat_count_after: int = 0
	var interrupt_skip_count_applied: int = 0


class TickEvent:
	var time_ms: int = 0
	var damage: float = 0.0
	var absorbed_amount: float = 0.0
	var stacks_remaining: int = 0
	var tick_interval_ms: int = POISON_TICK_INTERVAL_MS


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
	var tick_interval_ms: int = max(1, roundi(float(POISON_TICK_INTERVAL_MS) * player.poison_tick_interval_multiplier * (1.0 + maxf(monster.suppress, 0.0))))
	var next_tick_time_ms: int = tick_interval_ms
	var cast_time_ms: int = 0
	var rotation_index: int = 0
	var cleanse_counter: int = 0
	var repeat_skill_id := ""
	var repeat_count := 0
	var interrupt_skips_by_skill := {}
	while true:
		var skill: Skill = rotation[rotation_index % rotation.size()]
		var used_min_cast_time: bool = player.min_cast_time_proc_chance > 0.0 and rng.randf() <= player.min_cast_time_proc_chance
		var exec_ms: int = skill.min_execution_ms if used_min_cast_time else CombatTiming.execution_time_ms_with_slow(skill, player.attack_speed, monster.slow)
		var cast_end_ms: int = cast_time_ms + exec_ms
		if cast_end_ms > duration_ms:
			break
		while next_tick_time_ms <= cast_end_ms:
			active_stacks = _resolve_poison_tick(result, next_tick_time_ms, active_stacks, player, current_poison_resistance, monster.absorb, tick_interval_ms)
			next_tick_time_ms += tick_interval_ms

		var event := CastEvent.new()
		event.cast_start_ms = cast_time_ms
		event.time_ms = cast_end_ms
		event.skill = skill
		event.rotation_index = rotation_index % rotation.size()
		event.min_cast_time_proc_applied = used_min_cast_time
		var skill_key := _interrupt_skill_key(skill)
		var is_direct_attack := _skill_is_direct_attack(skill)
		var should_skip_for_interrupt := is_direct_attack and int(interrupt_skips_by_skill.get(skill_key, 0)) > 0
		var should_trigger_interrupt := false
		if is_direct_attack and not should_skip_for_interrupt:
			if skill_key == repeat_skill_id:
				repeat_count += 1
			else:
				repeat_skill_id = skill_key
				repeat_count = 1
			should_trigger_interrupt = monster.interrupt_skip_count > 0 and repeat_count >= INTERRUPT_REPEAT_THRESHOLD
			event.interrupt_repeat_count = repeat_count
			event.interrupt_repeat_count_after = repeat_count
		elif not is_direct_attack:
			repeat_skill_id = ""
			repeat_count = 0
		if should_skip_for_interrupt:
			event.was_interrupted = true
			event.interrupt_skipped = true
			interrupt_skips_by_skill[skill_key] = maxi(0, int(interrupt_skips_by_skill.get(skill_key, 0)) - 1)
			repeat_skill_id = ""
			repeat_count = 0
			event.interrupt_repeat_count_after = 0
			result.cast_events.append(event)
			cast_time_ms = cast_end_ms
			rotation_index += 1
			continue
		if should_trigger_interrupt:
			event.was_interrupted = true
			event.interrupt_triggered = true
			event.interrupt_skip_count_applied = monster.interrupt_skip_count
			interrupt_skips_by_skill[skill_key] = monster.interrupt_skip_count
			repeat_skill_id = ""
			repeat_count = 0
			event.interrupt_repeat_count_after = 0
			result.cast_events.append(event)
			cast_time_ms = cast_end_ms
			rotation_index += 1
			continue
		var state := _apply_skill_effects(skill, event, player, monster, current_armor, current_poison_resistance, active_stacks, rng, "cast")
		current_armor = state["armor"]
		current_poison_resistance = state["poison_resistance"]
		if not bool(state.get("dodged", false)):
			for trigger in player.triggered_skill_effects:
				if trigger == null or trigger.skill == null:
					continue
				if not _trigger_matches_source(trigger, skill):
					continue
				if rng.randf() <= trigger.chance:
					state = _apply_skill_effects(trigger.skill, event, player, monster, current_armor, current_poison_resistance, active_stacks, rng, "proc")
					if not bool(state.get("dodged", false)):
						event.triggered_skill_names.append(trigger.skill.display_name)
				current_armor = state["armor"]
				current_poison_resistance = state["poison_resistance"]

		result.total_damage += event.physical_damage
		if monster.stun_duration_ms > 0 and _stun_should_trigger(event, monster):
			event.stun_duration_ms = monster.stun_duration_ms
		active_stacks = mini(active_stacks + event.poison_stacks_applied, MAX_POISON_STACKS)
		if monster.cleanse_threshold > 0:
			cleanse_counter += 1
			event.cleanse_counter = cleanse_counter
			if cleanse_counter >= monster.cleanse_threshold:
				cleanse_counter = 0
				active_stacks = 0
				current_armor = monster.armor
				current_poison_resistance = monster.poison_resistance
				event.cleanse_triggered = true
				event.cleanse_counter = 0
		result.cast_events.append(event)
		cast_time_ms = cast_end_ms + event.stun_duration_ms
		rotation_index += 1

	while next_tick_time_ms <= duration_ms:
		active_stacks = _resolve_poison_tick(result, next_tick_time_ms, active_stacks, player, current_poison_resistance, monster.absorb, tick_interval_ms)
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


static func _interrupt_skill_key(skill: Skill) -> String:
	if skill == null:
		return ""
	if skill.id.strip_edges() != "":
		return skill.id
	return skill.display_name


static func _skill_is_direct_attack(skill: Skill) -> bool:
	if skill == null:
		return false
	for effect in skill.effects:
		if (effect is PhysicalDamageEffect) or (effect is StackScalingPhysicalDamageEffect):
			return true
	return false


static func _stun_should_trigger(event: CastEvent, monster: Monster) -> bool:
	if event == null or monster == null or monster.hp <= 0:
		return false
	var trigger_damage := float(monster.hp) * STUN_TRIGGER_HIT_PERCENT
	return _largest_direct_hit(event) >= trigger_damage


static func _largest_direct_hit(event: CastEvent) -> float:
	if event.damage_contributions.is_empty():
		return event.physical_damage
	var largest := 0.0
	for contribution in event.damage_contributions:
		largest = maxf(largest, float(contribution.get("damage", 0.0)))
	return largest


static func _resolve_poison_tick(result: CombatResult, tick_time_ms: int, active_stacks: int, player: PlayerStats, current_poison_resistance: float, absorb: float, tick_interval_ms: int) -> int:
	var tick := TickEvent.new()
	tick.time_ms = tick_time_ms
	tick.tick_interval_ms = tick_interval_ms
	if active_stacks > 0:
		active_stacks -= 1
		var damage := DamageCalculator.resolve_magical_damage(player.poison_damage_per_tick, current_poison_resistance, absorb)
		tick.damage = damage["amount"]
		tick.absorbed_amount = damage["absorbed_amount"]
		result.total_damage += tick.damage
	tick.stacks_remaining = active_stacks
	result.tick_events.append(tick)
	return active_stacks


static func _apply_skill_effects(skill: Skill, event: CastEvent, player: PlayerStats, monster: Monster, current_armor: int, current_poison_resistance: float, active_poison_stacks: int, rng: RandomNumberGenerator, contribution_kind: String) -> Dictionary:
	if _skill_can_be_dodged(skill, active_poison_stacks) and rng.randf() < clampf(monster.dodge_chance, 0.0, 1.0):
		event.was_dodged = true
		event.dodged_attacks += 1
		return {
			"armor": current_armor,
			"poison_resistance": current_poison_resistance,
			"dodged": true,
		}
	var effect_poison_stacks := 0
	var contribution_damage := 0.0
	var contribution_crit := false
	var contribution_armor_reduction := 0
	var contribution_resistance_reduction := 0.0
	for effect in skill.effects:
		if effect is PhysicalDamageEffect:
			var physical_effect: PhysicalDamageEffect = effect
			var hit := DamageCalculator.resolve_physical_hit(
				physical_effect.amount + player.bonus_physical_damage, current_armor, player.crit_chance, player.crit_multiplier, rng, player.physical_damage_multiplier, monster.crit_negation, monster.block
			)
			event.physical_damage += hit.amount
			event.is_crit = event.is_crit or hit.is_crit
			event.blocked_amount += hit.blocked_amount
			event.crit_negation_applied += hit.crit_negation_applied
			event.crit_negation_damage_prevented += hit.crit_negation_damage_prevented
			contribution_damage += hit.amount
			contribution_crit = contribution_crit or hit.is_crit
		elif effect is StackScalingPhysicalDamageEffect:
			var stack_effect: StackScalingPhysicalDamageEffect = effect
			if active_poison_stacks > 0:
				var hit := DamageCalculator.resolve_physical_hit(
					stack_effect.damage_per_stack * float(active_poison_stacks) + player.bonus_physical_damage, current_armor, player.crit_chance, player.crit_multiplier, rng, player.physical_damage_multiplier, monster.crit_negation, monster.block
				)
				event.physical_damage += hit.amount
				event.is_crit = event.is_crit or hit.is_crit
				event.blocked_amount += hit.blocked_amount
				event.crit_negation_applied += hit.crit_negation_applied
				event.crit_negation_damage_prevented += hit.crit_negation_damage_prevented
				contribution_damage += hit.amount
				contribution_crit = contribution_crit or hit.is_crit
		elif effect is PoisonDamageEffect:
			var poison_effect: PoisonDamageEffect = effect
			effect_poison_stacks += poison_effect.stacks_applied
		elif effect is ArmorReductionEffect:
			var armor_effect: ArmorReductionEffect = effect
			var reduction: int = armor_effect.amount + player.bonus_armor_reduction
			current_armor -= reduction
			event.armor_reduction_applied += reduction
			contribution_armor_reduction += reduction
		elif effect is PoisonResistanceReductionEffect:
			var resistance_effect: PoisonResistanceReductionEffect = effect
			var reduction_fraction: float = clampf(resistance_effect.reduction_fraction, 0.0, 1.0)
			current_poison_resistance *= 1.0 - reduction_fraction
			event.poison_resistance_reduction_applied += reduction_fraction
			contribution_resistance_reduction += reduction_fraction
	var poison_stacks := effect_poison_stacks if effect_poison_stacks > 0 else skill.poison_stacks_applied
	if poison_stacks > 0:
		event.poison_stacks_applied += poison_stacks + player.bonus_poison_stacks
	_record_damage_contribution(
		event,
		skill,
		contribution_kind,
		contribution_damage,
		contribution_crit,
		contribution_armor_reduction,
		contribution_resistance_reduction,
		(poison_stacks + player.bonus_poison_stacks) if poison_stacks > 0 else 0
	)
	return {
		"armor": current_armor,
		"poison_resistance": current_poison_resistance,
		"dodged": false,
	}


static func _skill_can_be_dodged(skill: Skill, active_poison_stacks: int) -> bool:
	if skill == null:
		return false
	for effect in skill.effects:
		if effect is PhysicalDamageEffect:
			return true
		if effect is StackScalingPhysicalDamageEffect and active_poison_stacks > 0:
			return true
	return false


static func _record_damage_contribution(event: CastEvent, skill: Skill, kind: String, damage: float, is_crit: bool, armor_reduction: int, poison_resistance_reduction: float, poison_stacks: int) -> void:
	if skill == null:
		return
	if damage <= 0.0 and armor_reduction <= 0 and poison_resistance_reduction <= 0.0 and poison_stacks <= 0:
		return
	event.damage_contributions.append({
		"skill_id": skill.id,
		"name": skill.display_name,
		"icon": skill.icon,
		"kind": kind,
		"damage": damage,
		"is_crit": is_crit,
		"armor_reduction_applied": armor_reduction,
		"poison_resistance_reduction_applied": poison_resistance_reduction,
		"poison_stacks_applied": poison_stacks,
	})
