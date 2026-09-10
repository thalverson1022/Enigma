class_name CombatResolver
extends RefCounted

const POISON_TICK_INTERVAL_MS: int = 1000
const MAX_POISON_STACKS: int = 20
const MAX_SHRED_STACKS: int = 500
const MAX_RETRIGGER_CHAIN_DEPTH: int = 16
const BASE_DECAY_REDUCTION_FRACTION: float = 0.2
const STUN_TRIGGER_HIT_PERCENT: float = 0.12
const INTERRUPT_REPEAT_THRESHOLD: int = 3
const DEATH_STRIKE_SKILL_ID := "skill.killers_mark"
const DEATH_STRIKE_DAMAGE_SCALING := 1.11
const DEATH_STRIKE_DAMAGE_PER_POISON_STACK := 1.0
const WEAPON_SCALING_BY_SKILL_ID := {
	"skill.stab": 1.00,
	"skill.heavy_slash": 1.66,
	"skill.quick_cut": 0.66,
	"skill.steal": 1.06,
	"skill.venom_jab": 0.22,
	"skill.poison_strike": 0.83,
	"skill.rending_thrust": 0.78,
	"skill.toxic_flurry": 0.22,
}


class CastEvent:
	var cast_start_ms: int = 0
	var time_ms: int = 0
	var skill: Skill
	var rotation_index: int = -1
	var cast_kind: String = "cast"
	var trigger_label: String = ""
	var trigger_source_skill_id: String = ""
	var retrigger_depth: int = 0
	var retrigger_cap_reached: bool = false
	var physical_damage: float = 0.0
	var damage_contributions: Array[Dictionary] = []
	var is_crit: bool = false
	var was_dodged: bool = false
	var dodged_attacks: int = 0
	var blocked_amount: float = 0.0
	var crit_negation_applied: float = 0.0
	var crit_negation_damage_prevented: float = 0.0
	var poison_stacks_applied: int = 0
	var shred_stacks_applied: int = 0
	var decay_stacks_applied: int = 0
	var shred_value: int = 0
	var decay_value: float = 0.0
	var armor_reduction_applied: int = 0
	var poison_resistance_reduction_applied: float = 0.0
	var gold_stolen: int = 0
	var cleanse_counter: int = 0
	var cleanse_triggered: bool = false
	var triggered_skill_names: PackedStringArray = []
	var trigger_labels: PackedStringArray = []
	var min_cast_time_proc_applied: bool = false
	var weapon_damage_roll: int = 0
	var weapon_damage_min: int = 0
	var weapon_damage_max: int = 0
	var weapon_damage_rolls: Array[Dictionary] = []
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
	var had_active_stack: bool = false
	var stacks_remaining: int = 0
	var tick_interval_ms: int = POISON_TICK_INTERVAL_MS


class CombatResult:
	var duration_ms: int = 0
	var total_damage: float = 0.0
	var dps: float = 0.0
	var is_win: bool = false
	var overkill_damage: float = 0.0
	var gold_stolen: int = 0
	var cast_events: Array[CastEvent] = []
	var tick_events: Array[TickEvent] = []
	var poison_stack_cap: int = MAX_POISON_STACKS


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
	result.poison_stack_cap = _poison_stack_cap(player)

	if rotation.is_empty():
		return result

	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed

	var current_armor: int = monster.armor
	var current_shred_stacks: int = 0
	var current_poison_resistance: float = monster.poison_resistance
	var active_stacks: int = 0
	var tick_interval_ms: int = max(1, roundi(float(POISON_TICK_INTERVAL_MS) * player.poison_tick_interval_multiplier * (1.0 + maxf(_effective_enemy_suppress(player, monster), 0.0))))
	var next_tick_time_ms: int = tick_interval_ms
	var cast_time_ms: int = 0
	var rotation_index: int = 0
	var cleanse_counter: int = 0
	var interrupt_state := {
		"repeat_skill_id": "",
		"repeat_count": 0,
		"skips_by_skill": {},
	}
	var gold_stolen_this_fight := 0
	var simulated_current_gold := player.current_gold
	while true:
		var skill: Skill = rotation[rotation_index % rotation.size()]
		var used_min_cast_time: bool = player.min_cast_time_proc_chance > 0.0 and rng.randf() <= player.min_cast_time_proc_chance
		var exec_ms: int = skill.min_execution_ms if used_min_cast_time else CombatTiming.execution_time_ms_with_slow(skill, player.attack_speed, effective_enemy_slow(player, monster))
		var cast_end_ms: int = cast_time_ms + exec_ms
		if cast_end_ms > duration_ms:
			break
		while next_tick_time_ms <= cast_end_ms:
			active_stacks = _resolve_poison_tick(result, next_tick_time_ms, active_stacks, player, current_armor, current_poison_resistance, monster, tick_interval_ms)
			next_tick_time_ms += tick_interval_ms

		var event := CastEvent.new()
		event.cast_start_ms = cast_time_ms
		event.time_ms = cast_end_ms
		event.skill = skill
		event.rotation_index = rotation_index % rotation.size()
		event.min_cast_time_proc_applied = used_min_cast_time
		var counts_for_mechanics := not _skill_is_hold(skill)
		var is_direct_attack := counts_for_mechanics and _skill_is_direct_attack(skill)
		if _apply_interrupt_to_event(event, skill, player, monster, interrupt_state):
			result.cast_events.append(event)
			cast_time_ms = cast_end_ms
			rotation_index += 1
			continue
		var state := _apply_skill_effects(
			skill, event, player, monster, current_armor, current_poison_resistance,
			active_stacks, current_shred_stacks, rng, "cast", gold_stolen_this_fight, simulated_current_gold
		)
		current_armor = state["armor"]
		current_shred_stacks = state["shred_stacks"]
		current_poison_resistance = state["poison_resistance"]
		gold_stolen_this_fight += int(state.get("gold_stolen", 0))
		simulated_current_gold += int(state.get("gold_stolen", 0))
		var finalize_state := _finalize_cast_event(
			result, event, player, monster, active_stacks, current_armor,
			current_poison_resistance, current_shred_stacks, cleanse_counter, counts_for_mechanics
		)
		active_stacks = finalize_state["active_stacks"]
		current_armor = finalize_state["armor"]
		current_shred_stacks = finalize_state["shred_stacks"]
		current_poison_resistance = finalize_state["poison_resistance"]
		cleanse_counter = finalize_state["cleanse_counter"]
		if is_direct_attack and not bool(state.get("dodged", false)):
			var retrigger_state := _resolve_retrigger_chain(
				event, result, player, monster, current_armor, current_poison_resistance,
				current_shred_stacks, active_stacks, rng, gold_stolen_this_fight, simulated_current_gold,
				cleanse_counter, interrupt_state, 0
			)
			active_stacks = retrigger_state["active_stacks"]
			current_armor = retrigger_state["armor"]
			current_shred_stacks = retrigger_state["shred_stacks"]
			current_poison_resistance = retrigger_state["poison_resistance"]
			cleanse_counter = retrigger_state["cleanse_counter"]
			gold_stolen_this_fight = retrigger_state["gold_stolen_this_fight"]
			simulated_current_gold = retrigger_state["simulated_current_gold"]
		cast_time_ms = cast_end_ms + event.stun_duration_ms
		rotation_index += 1

	while next_tick_time_ms <= duration_ms:
		active_stacks = _resolve_poison_tick(result, next_tick_time_ms, active_stacks, player, current_armor, current_poison_resistance, monster, tick_interval_ms)
		next_tick_time_ms += tick_interval_ms

	result.dps = result.total_damage / (float(duration_ms) / 1000.0)
	result.is_win = result.total_damage >= float(monster.hp)
	result.overkill_damage = maxf(0.0, result.total_damage - float(monster.hp)) if result.is_win else 0.0
	return result


static func _trigger_matches_source(trigger: TriggeredSkillEffect, source_skill: Skill) -> bool:
	if trigger.source_skill_ids.is_empty():
		return true
	if source_skill == null:
		return false
	return trigger.source_skill_ids.has(source_skill.id)


static func _triggers_for_source(source_event: CastEvent, player: PlayerStats) -> Array[TriggeredSkillEffect]:
	var triggers: Array[TriggeredSkillEffect] = []
	if player == null or source_event == null or source_event.skill == null or _skill_is_hold(source_event.skill):
		return triggers
	triggers.append_array(player.triggered_skill_effects)
	if player.retrigger_chance > 0.0 and _skill_is_direct_attack(source_event.skill):
		var self_retrigger := TriggeredSkillEffect.new()
		self_retrigger.skill = source_event.skill
		self_retrigger.chance = clampf(player.retrigger_chance, 0.0, 1.0)
		self_retrigger.source_skill_ids = PackedStringArray([source_event.skill.id])
		triggers.append(self_retrigger)
	return triggers


static func _apply_interrupt_to_event(event: CastEvent, skill: Skill, player: PlayerStats, monster: Monster, interrupt_state: Dictionary) -> bool:
	var counts_for_mechanics := not _skill_is_hold(skill)
	var is_direct_attack := counts_for_mechanics and _skill_is_direct_attack(skill)
	if not is_direct_attack:
		interrupt_state["repeat_skill_id"] = ""
		interrupt_state["repeat_count"] = 0
		return false
	var skill_key := _interrupt_skill_key(skill)
	var skips_by_skill: Dictionary = interrupt_state["skips_by_skill"]
	if int(skips_by_skill.get(skill_key, 0)) > 0:
		event.was_interrupted = true
		event.interrupt_skipped = true
		skips_by_skill[skill_key] = maxi(0, int(skips_by_skill.get(skill_key, 0)) - 1)
		interrupt_state["repeat_skill_id"] = ""
		interrupt_state["repeat_count"] = 0
		event.interrupt_repeat_count_after = 0
		return true
	var repeat_skill_id := String(interrupt_state.get("repeat_skill_id", ""))
	var repeat_count := int(interrupt_state.get("repeat_count", 0))
	if skill_key == repeat_skill_id:
		repeat_count += 1
	else:
		repeat_skill_id = skill_key
		repeat_count = 1
	interrupt_state["repeat_skill_id"] = repeat_skill_id
	interrupt_state["repeat_count"] = repeat_count
	event.interrupt_repeat_count = repeat_count
	event.interrupt_repeat_count_after = repeat_count
	if _effective_enemy_interrupt_skip_count(player, monster) <= 0 or repeat_count < INTERRUPT_REPEAT_THRESHOLD:
		return false
	event.was_interrupted = true
	event.interrupt_triggered = true
	event.interrupt_skip_count_applied = _effective_enemy_interrupt_skip_count(player, monster)
	skips_by_skill[skill_key] = event.interrupt_skip_count_applied
	interrupt_state["repeat_skill_id"] = ""
	interrupt_state["repeat_count"] = 0
	event.interrupt_repeat_count_after = 0
	return true


static func _finalize_cast_event(result: CombatResult, event: CastEvent, player: PlayerStats, monster: Monster, active_stacks: int, current_armor: int, current_poison_resistance: float, current_shred_stacks: int, cleanse_counter: int, counts_for_mechanics: bool) -> Dictionary:
	result.total_damage += event.physical_damage
	result.gold_stolen += event.gold_stolen
	var stun_duration_ms := _effective_enemy_stun_duration_ms(player, monster)
	if stun_duration_ms > 0 and _stun_should_trigger(event, monster):
		event.stun_duration_ms = stun_duration_ms
	active_stacks = mini(active_stacks + event.poison_stacks_applied, _poison_stack_cap(player))
	if counts_for_mechanics and monster.cleanse_threshold > 0 and not _denies_enemy_cleanse(player):
		cleanse_counter += 1
		event.cleanse_counter = cleanse_counter
		if cleanse_counter >= monster.cleanse_threshold:
			cleanse_counter = 0
			active_stacks = 0
			current_shred_stacks = 0
			current_armor = monster.armor
			current_poison_resistance = monster.poison_resistance
			event.cleanse_triggered = true
			event.cleanse_counter = 0
	result.cast_events.append(event)
	return {
		"active_stacks": active_stacks,
		"armor": current_armor,
		"shred_stacks": current_shred_stacks,
		"poison_resistance": current_poison_resistance,
		"cleanse_counter": cleanse_counter,
	}


static func _resolve_retrigger_chain(source_event: CastEvent, result: CombatResult, player: PlayerStats, monster: Monster, current_armor: int, current_poison_resistance: float, current_shred_stacks: int, active_stacks: int, rng: RandomNumberGenerator, gold_stolen_this_fight: int, simulated_current_gold: int, cleanse_counter: int, interrupt_state: Dictionary, depth: int) -> Dictionary:
	if depth >= MAX_RETRIGGER_CHAIN_DEPTH:
		source_event.retrigger_cap_reached = true
		return {
			"active_stacks": active_stacks,
			"armor": current_armor,
			"shred_stacks": current_shred_stacks,
			"poison_resistance": current_poison_resistance,
			"cleanse_counter": cleanse_counter,
			"gold_stolen_this_fight": gold_stolen_this_fight,
			"simulated_current_gold": simulated_current_gold,
		}

	var triggers := _triggers_for_source(source_event, player)
	for trigger in triggers:
		if trigger == null or trigger.skill == null:
			continue
		if not _trigger_matches_source(trigger, source_event.skill):
			continue
		if rng.randf() > trigger.chance:
			continue

		var event := CastEvent.new()
		event.cast_start_ms = source_event.time_ms
		event.time_ms = source_event.time_ms
		event.skill = trigger.skill
		event.rotation_index = source_event.rotation_index
		event.cast_kind = "proc"
		event.trigger_source_skill_id = source_event.skill.id if source_event.skill != null else ""
		event.trigger_label = _trigger_label(trigger, source_event.skill)
		event.retrigger_depth = depth + 1
		if _apply_interrupt_to_event(event, trigger.skill, player, monster, interrupt_state):
			result.cast_events.append(event)
			continue
		var state := _apply_skill_effects(
			trigger.skill, event, player, monster, current_armor, current_poison_resistance,
			active_stacks, current_shred_stacks, rng, "proc", gold_stolen_this_fight, simulated_current_gold
		)
		current_armor = state["armor"]
		current_shred_stacks = state["shred_stacks"]
		current_poison_resistance = state["poison_resistance"]
		gold_stolen_this_fight += int(state.get("gold_stolen", 0))
		simulated_current_gold += int(state.get("gold_stolen", 0))
		if not bool(state.get("dodged", false)):
			source_event.triggered_skill_names.append(trigger.skill.display_name)
			if not source_event.trigger_labels.has(event.trigger_label):
				source_event.trigger_labels.append(event.trigger_label)
		var finalize_state := _finalize_cast_event(
			result, event, player, monster, active_stacks, current_armor,
			current_poison_resistance, current_shred_stacks, cleanse_counter, not _skill_is_hold(trigger.skill)
		)
		active_stacks = finalize_state["active_stacks"]
		current_armor = finalize_state["armor"]
		current_shred_stacks = finalize_state["shred_stacks"]
		current_poison_resistance = finalize_state["poison_resistance"]
		cleanse_counter = finalize_state["cleanse_counter"]
		if _skill_is_direct_attack(trigger.skill) and not bool(state.get("dodged", false)):
			var chain_state := _resolve_retrigger_chain(
				event, result, player, monster, current_armor, current_poison_resistance,
				current_shred_stacks, active_stacks, rng, gold_stolen_this_fight, simulated_current_gold,
				cleanse_counter, interrupt_state, depth + 1
			)
			active_stacks = chain_state["active_stacks"]
			current_armor = chain_state["armor"]
			current_shred_stacks = chain_state["shred_stacks"]
			current_poison_resistance = chain_state["poison_resistance"]
			cleanse_counter = chain_state["cleanse_counter"]
			gold_stolen_this_fight = chain_state["gold_stolen_this_fight"]
			simulated_current_gold = chain_state["simulated_current_gold"]
	return {
		"active_stacks": active_stacks,
		"armor": current_armor,
		"shred_stacks": current_shred_stacks,
		"poison_resistance": current_poison_resistance,
		"cleanse_counter": cleanse_counter,
		"gold_stolen_this_fight": gold_stolen_this_fight,
		"simulated_current_gold": simulated_current_gold,
	}


static func _interrupt_skill_key(skill: Skill) -> String:
	if skill == null:
		return ""
	if skill.id.strip_edges() != "":
		return skill.id
	return skill.display_name


static func _trigger_label(trigger: TriggeredSkillEffect, source_skill: Skill) -> String:
	if trigger == null or trigger.skill == null:
		return "PROC"
	if source_skill != null and trigger.skill.id == source_skill.id:
		return "RETRIGGER"
	if (
		source_skill != null
		and source_skill.id == "skill.quick_cut"
		and trigger.skill.id == "skill.rending_thrust"
	):
		return "Opportunity Strike"
	return "PROC"


static func _skill_is_direct_attack(skill: Skill) -> bool:
	if skill == null:
		return false
	for effect in skill.effects:
		if (effect is PhysicalDamageEffect) or (effect is StackScalingPhysicalDamageEffect):
			return true
	return false


static func _skill_is_hold(skill: Skill) -> bool:
	return skill != null and skill.id == "skill.hold"


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


static func _resolve_poison_tick(result: CombatResult, tick_time_ms: int, active_stacks: int, player: PlayerStats, current_armor: int, current_poison_resistance: float, monster: Monster, tick_interval_ms: int) -> int:
	var tick := TickEvent.new()
	tick.time_ms = tick_time_ms
	tick.tick_interval_ms = tick_interval_ms
	if active_stacks > 0:
		tick.had_active_stack = true
		active_stacks -= 1
		var damage := DamageCalculator.resolve_damage_packet(
			player.poison_damage_per_tick,
			"magical",
			current_armor,
			current_poison_resistance,
			0.0,
			1.0,
			null,
			1.0,
			0.0,
			_effective_enemy_block(player, monster),
			_effective_enemy_absorb(player, monster),
			1.0,
			1.0,
			_converts_damage_to_physical(player),
			_converts_damage_to_magical(player),
			_ignores_armor_without_shred(player),
			_ignores_resistance_with_physical_penalty(player),
			1.0
		)
		tick.damage = damage["amount"]
		tick.absorbed_amount = damage["absorbed_amount"]
		result.total_damage += tick.damage
	tick.stacks_remaining = active_stacks
	result.tick_events.append(tick)
	return active_stacks


static func _apply_skill_effects(skill: Skill, event: CastEvent, player: PlayerStats, monster: Monster, current_armor: int, current_poison_resistance: float, active_poison_stacks: int, active_shred_stacks: int, rng: RandomNumberGenerator, contribution_kind: String, gold_stolen_this_fight: int = 0, current_gold: int = 0) -> Dictionary:
	if _skill_can_be_dodged(skill, active_poison_stacks) and rng.randf() < clampf(_effective_enemy_dodge_chance(player, monster), 0.0, 1.0):
		event.was_dodged = true
		event.dodged_attacks += 1
		return {
			"armor": current_armor,
			"shred_stacks": active_shred_stacks,
			"poison_resistance": current_poison_resistance,
			"dodged": true,
			"gold_stolen": 0,
		}
	var effect_poison_stacks := 0
	var effect_shred_stacks := 0
	var effect_decay_stacks := 0
	var contribution_damage := 0.0
	var contribution_crit := false
	var contribution_armor_reduction := 0
	var contribution_resistance_reduction := 0.0
	var contribution_gold_stolen := 0
	var contribution_weapon_roll := _roll_weapon_damage_for_skill(skill, player, active_poison_stacks, rng)
	if not contribution_weapon_roll.is_empty():
		if event.weapon_damage_roll <= 0:
			event.weapon_damage_roll = int(contribution_weapon_roll["roll"])
			event.weapon_damage_min = int(contribution_weapon_roll["min"])
			event.weapon_damage_max = int(contribution_weapon_roll["max"])
		contribution_weapon_roll["kind"] = contribution_kind
		contribution_weapon_roll["skill_id"] = skill.id if skill != null else ""
		contribution_weapon_roll["name"] = skill.display_name if skill != null else ""
		event.weapon_damage_rolls.append(contribution_weapon_roll)
	var crit_chance := player.crit_chance + (float(gold_stolen_this_fight) * player.crit_chance_per_stolen_gold)
	var crit_multiplier := maxf(1.0, player.crit_multiplier + (float(current_gold) * player.crit_multiplier_per_current_gold))
	var physical_buckets := player.physical_damage_buckets()
	var death_strike_packet_applied := false
	for effect in skill.effects:
		if _skill_is_death_strike(skill) and not death_strike_packet_applied and ((effect is PhysicalDamageEffect) or (effect is StackScalingPhysicalDamageEffect)):
			death_strike_packet_applied = true
			var roll_amount := float(contribution_weapon_roll.get("roll", 0))
			var raw_base := _damage_base_with_bonus(roll_amount + (DEATH_STRIKE_DAMAGE_PER_POISON_STACK * float(active_poison_stacks)), player.bonus_physical_damage)
			var raw_amount := raw_base * DEATH_STRIKE_DAMAGE_SCALING
			var hit := _apply_conversion_to_physical_hit(
				raw_amount,
				current_armor,
				current_poison_resistance,
				crit_chance,
				crit_multiplier,
				rng,
				physical_buckets,
				player,
				monster
			)
			event.physical_damage += hit.amount
			event.is_crit = event.is_crit or hit.is_crit
			event.blocked_amount += hit.blocked_amount
			event.crit_negation_applied += hit.crit_negation_applied
			event.crit_negation_damage_prevented += hit.crit_negation_damage_prevented
			contribution_damage += hit.amount
			contribution_crit = contribution_crit or hit.is_crit
		elif _skill_is_death_strike(skill) and ((effect is PhysicalDamageEffect) or (effect is StackScalingPhysicalDamageEffect)):
			continue
		elif effect is PhysicalDamageEffect:
			var physical_effect: PhysicalDamageEffect = effect
			var raw_amount := _damage_base_with_bonus(physical_effect.amount, player.bonus_physical_damage)
			var weapon_scaling := _weapon_scaling_for_skill(skill)
			if weapon_scaling > 0.0:
				raw_amount = _damage_base_with_bonus(float(contribution_weapon_roll.get("roll", 0)), player.bonus_physical_damage) * weapon_scaling
			var hit := _apply_conversion_to_physical_hit(
				raw_amount,
				current_armor,
				current_poison_resistance,
				crit_chance,
				crit_multiplier,
				rng,
				physical_buckets,
				player,
				monster
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
				var raw_amount := _damage_base_with_bonus(stack_effect.damage_per_stack * float(active_poison_stacks), player.bonus_physical_damage)
				var hit := _apply_conversion_to_physical_hit(
					raw_amount,
					current_armor,
					current_poison_resistance,
					crit_chance,
					crit_multiplier,
					rng,
					physical_buckets,
					player,
					monster
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
			if _ignores_armor_without_shred(player):
				continue
			effect_shred_stacks += max(0, armor_effect.amount)
		elif effect is PoisonResistanceReductionEffect:
			effect_decay_stacks += 1
		elif effect is StealGoldOnCritEffect:
			var steal_effect: StealGoldOnCritEffect = effect
			if contribution_crit:
				contribution_gold_stolen += max(0, int(floor(float(steal_effect.amount) * player.gold_reward_multiplier)))
	event.gold_stolen += contribution_gold_stolen
	var poison_stacks := effect_poison_stacks if effect_poison_stacks > 0 else skill.poison_stacks_applied
	var applied_poison_stacks := 0
	if poison_stacks > 0:
		applied_poison_stacks = _applied_poison_stacks(poison_stacks, player)
		event.poison_stacks_applied += applied_poison_stacks
	if _skill_is_direct_attack(skill) and contribution_crit and player.elemental_proc_chance > 0.0 and rng.randf() <= clampf(player.elemental_proc_chance, 0.0, 1.0):
		var crit_poison_stacks := _applied_poison_stacks(1, player)
		applied_poison_stacks += crit_poison_stacks
		event.poison_stacks_applied += crit_poison_stacks
	if effect_decay_stacks > 0:
		var decay_state := _apply_decay_stacks(effect_decay_stacks, current_poison_resistance, player)
		current_poison_resistance = float(decay_state["poison_resistance"])
		var applied_decay_stacks := int(decay_state["applied"])
		event.decay_stacks_applied += applied_decay_stacks
		event.decay_value = _decay_value(player)
		event.poison_resistance_reduction_applied = _combine_reduction(event.poison_resistance_reduction_applied, float(decay_state["reduction"]))
		contribution_resistance_reduction = _combine_reduction(contribution_resistance_reduction, float(decay_state["reduction"]))
		if applied_decay_stacks > 0 and _decay_applies_shred(player) and not _ignores_armor_without_shred(player):
			var mirrored_shred_state := _apply_shred_stack_total(applied_decay_stacks, active_shred_stacks)
			active_shred_stacks = int(mirrored_shred_state["stacks"])
			current_armor = _armor_after_shred(monster.armor, active_shred_stacks, player)
			event.shred_stacks_applied += int(mirrored_shred_state["applied"])
			event.shred_value = player.shred_value
			event.armor_reduction_applied += int(mirrored_shred_state["applied"]) * player.shred_value
			contribution_armor_reduction += int(mirrored_shred_state["applied"]) * player.shred_value
	if effect_shred_stacks > 0:
		var shred_state := _apply_shred_stacks(effect_shred_stacks + player.bonus_shred_stacks, active_shred_stacks, player)
		active_shred_stacks = int(shred_state["stacks"])
		current_armor = _armor_after_shred(monster.armor, active_shred_stacks, player)
		event.shred_stacks_applied += int(shred_state["applied"])
		event.shred_value = player.shred_value
		event.armor_reduction_applied += int(shred_state["applied"]) * player.shred_value
		contribution_armor_reduction += int(shred_state["applied"]) * player.shred_value
	if _skill_is_direct_attack(skill) and player.shred_chance > 0.0 and not _ignores_armor_without_shred(player) and rng.randf() <= clampf(player.shred_chance, 0.0, 1.0):
		var shred_state := _apply_shred_stacks(1 + player.bonus_shred_stacks, active_shred_stacks, player)
		active_shred_stacks = int(shred_state["stacks"])
		current_armor = _armor_after_shred(monster.armor, active_shred_stacks, player)
		event.shred_stacks_applied += int(shred_state["applied"])
		event.shred_value = player.shred_value
		event.armor_reduction_applied += int(shred_state["applied"]) * player.shred_value
		contribution_armor_reduction += int(shred_state["applied"]) * player.shred_value
	if _skill_is_direct_attack(skill) and player.decay_chance > 0.0 and rng.randf() <= clampf(player.decay_chance, 0.0, 1.0):
		var chance_decay_state := _apply_decay_stacks(1, current_poison_resistance, player)
		current_poison_resistance = float(chance_decay_state["poison_resistance"])
		var chance_decay_stacks := int(chance_decay_state["applied"])
		event.decay_stacks_applied += chance_decay_stacks
		event.decay_value = _decay_value(player)
		event.poison_resistance_reduction_applied = _combine_reduction(event.poison_resistance_reduction_applied, float(chance_decay_state["reduction"]))
		contribution_resistance_reduction = _combine_reduction(contribution_resistance_reduction, float(chance_decay_state["reduction"]))
		if chance_decay_stacks > 0 and _decay_applies_shred(player) and not _ignores_armor_without_shred(player):
			var chance_mirrored_shred_state := _apply_shred_stack_total(chance_decay_stacks, active_shred_stacks)
			active_shred_stacks = int(chance_mirrored_shred_state["stacks"])
			current_armor = _armor_after_shred(monster.armor, active_shred_stacks, player)
			event.shred_stacks_applied += int(chance_mirrored_shred_state["applied"])
			event.shred_value = player.shred_value
			event.armor_reduction_applied += int(chance_mirrored_shred_state["applied"]) * player.shred_value
			contribution_armor_reduction += int(chance_mirrored_shred_state["applied"]) * player.shred_value
	_record_damage_contribution(
		event,
		skill,
		contribution_kind,
		contribution_damage,
		contribution_crit,
		contribution_armor_reduction,
		contribution_resistance_reduction,
		applied_poison_stacks,
		contribution_gold_stolen
	)
	return {
		"armor": current_armor,
		"shred_stacks": active_shred_stacks,
		"poison_resistance": current_poison_resistance,
		"dodged": false,
		"gold_stolen": contribution_gold_stolen,
	}


static func _apply_conversion_to_physical_hit(raw_amount: float, current_armor: int, current_poison_resistance: float, crit_chance: float, crit_multiplier: float, rng: RandomNumberGenerator, physical_buckets: Dictionary, player: PlayerStats, monster: Monster) -> Dictionary:
	return DamageCalculator.resolve_damage_packet(
		raw_amount,
		"physical",
		current_armor,
		current_poison_resistance,
		crit_chance,
		crit_multiplier,
		rng,
		float(physical_buckets["legacy"]),
		monster.crit_negation,
		_effective_enemy_block(player, monster),
		_effective_enemy_absorb(player, monster),
		float(physical_buckets["gear"]),
		float(physical_buckets["talent"]),
		_converts_damage_to_physical(player),
		_converts_damage_to_magical(player),
		_ignores_armor_without_shred(player),
		_ignores_resistance_with_physical_penalty(player),
		_physical_damage_penalty(player)
	)


static func _skill_can_be_dodged(skill: Skill, active_poison_stacks: int) -> bool:
	if skill == null:
		return false
	for effect in skill.effects:
		if effect is PhysicalDamageEffect:
			return true
		if effect is StackScalingPhysicalDamageEffect and active_poison_stacks > 0:
			return true
	return false


static func _skill_is_death_strike(skill: Skill) -> bool:
	return skill != null and skill.id == DEATH_STRIKE_SKILL_ID


static func _damage_base_with_bonus(base_amount: float, bonus_physical_damage: float) -> float:
	return maxf(PlayerStats.MIN_DAMAGE_BASE, base_amount + bonus_physical_damage)


static func _weapon_scaling_for_skill(skill: Skill) -> float:
	return weapon_scaling_for_skill(skill)


static func weapon_scaling_for_skill(skill: Skill) -> float:
	if skill == null:
		return 0.0
	return float(WEAPON_SCALING_BY_SKILL_ID.get(skill.id, 0.0))


static func _applied_poison_stacks(base_stacks: int, player: PlayerStats) -> int:
	var total := base_stacks + player.bonus_poison_stacks
	if _doubles_applied_stacks(player):
		total *= 2
	return total


static func _poison_stack_cap(player: PlayerStats) -> int:
	if player == null:
		return MAX_POISON_STACKS
	return maxi(1, player.poison_stack_cap)


static func _decay_value(player: PlayerStats) -> float:
	if player == null:
		return BASE_DECAY_REDUCTION_FRACTION
	return clampf(player.decay_value, 0.0, 1.0)


static func _applied_decay_stacks(base_stacks: int, player: PlayerStats) -> int:
	var total := base_stacks + player.bonus_decay_stacks
	if _doubles_applied_stacks(player):
		total *= 2
	return max(0, total)


static func _apply_decay_stacks(base_stacks: int, current_poison_resistance: float, player: PlayerStats) -> Dictionary:
	var applied := _applied_decay_stacks(base_stacks, player)
	var decay_value := _decay_value(player)
	var retained_multiplier := pow(1.0 - decay_value, applied)
	var reduction := 1.0 - retained_multiplier
	return {
		"applied": applied,
		"poison_resistance": current_poison_resistance * retained_multiplier,
		"reduction": reduction,
	}


static func _apply_shred_stacks(base_stacks: int, active_shred_stacks: int, player: PlayerStats) -> Dictionary:
	var total: int = max(0, base_stacks)
	if _doubles_applied_stacks(player):
		total *= 2
	return _apply_shred_stack_total(total, active_shred_stacks)


static func _apply_shred_stack_total(total: int, active_shred_stacks: int) -> Dictionary:
	total = max(0, total)
	var new_total: int = mini(MAX_SHRED_STACKS, active_shred_stacks + total)
	return {
		"stacks": new_total,
		"applied": max(0, new_total - active_shred_stacks),
	}


static func _combine_reduction(existing: float, added: float) -> float:
	return 1.0 - ((1.0 - clampf(existing, 0.0, 1.0)) * (1.0 - clampf(added, 0.0, 1.0)))


static func _armor_after_shred(base_armor: int, active_shred_stacks: int, player: PlayerStats) -> int:
	if player == null:
		return base_armor
	return base_armor - (active_shred_stacks * max(0, player.shred_value))


static func _effective_enemy_dodge_chance(player: PlayerStats, monster: Monster) -> float:
	if _denies_enemy_dodge(player) or monster == null:
		return 0.0
	return monster.dodge_chance


static func _effective_enemy_block(player: PlayerStats, monster: Monster) -> float:
	if _denies_enemy_block(player) or monster == null:
		return 0.0
	return monster.block


static func _effective_enemy_absorb(player: PlayerStats, monster: Monster) -> float:
	if _denies_enemy_absorb(player) or monster == null:
		return 0.0
	return monster.absorb


static func _effective_enemy_suppress(player: PlayerStats, monster: Monster) -> float:
	if _denies_enemy_suppress(player) or monster == null:
		return 0.0
	return monster.suppress


static func effective_enemy_slow(player: PlayerStats, monster: Monster) -> float:
	if _immune_to_slow(player) or monster == null:
		return 0.0
	return monster.slow


static func _effective_enemy_stun_duration_ms(player: PlayerStats, monster: Monster) -> int:
	if _immune_to_stun(player) or monster == null:
		return 0
	return monster.stun_duration_ms


static func _effective_enemy_interrupt_skip_count(player: PlayerStats, monster: Monster) -> int:
	if _immune_to_interrupt(player) or monster == null:
		return 0
	return monster.interrupt_skip_count


static func _denies_enemy_dodge(player: PlayerStats) -> bool:
	var denial := _special_dict(player, "enemy_denial")
	return bool(denial.get("dodge", false))


static func _denies_enemy_block(player: PlayerStats) -> bool:
	var denial := _special_dict(player, "enemy_denial")
	return bool(denial.get("block", false))


static func _denies_enemy_absorb(player: PlayerStats) -> bool:
	var denial := _special_dict(player, "enemy_denial")
	return bool(denial.get("absorb", false))


static func _denies_enemy_suppress(player: PlayerStats) -> bool:
	var denial := _special_dict(player, "enemy_denial")
	return bool(denial.get("suppress", false))


static func _denies_enemy_cleanse(player: PlayerStats) -> bool:
	var denial := _special_dict(player, "enemy_denial")
	return bool(denial.get("cleanse", false))


static func _immune_to_slow(player: PlayerStats) -> bool:
	var immunities := _special_dict(player, "immunities")
	return bool(immunities.get("slow", false))


static func _immune_to_stun(player: PlayerStats) -> bool:
	var immunities := _special_dict(player, "immunities")
	return bool(immunities.get("stun", false))


static func _immune_to_interrupt(player: PlayerStats) -> bool:
	var immunities := _special_dict(player, "immunities")
	return bool(immunities.get("interrupt", false))


static func _doubles_applied_stacks(player: PlayerStats) -> bool:
	if player == null:
		return false
	return bool(player.special_effects.get("double_applied_stacks", false))


static func _decay_applies_shred(player: PlayerStats) -> bool:
	if player == null:
		return false
	return bool(player.special_effects.get("decay_applies_shred", false))


static func _converts_damage_to_physical(player: PlayerStats) -> bool:
	var conversion := _special_dict(player, "damage_conversion")
	return bool(conversion.get("physical", false))


static func _converts_damage_to_magical(player: PlayerStats) -> bool:
	var conversion := _special_dict(player, "damage_conversion")
	return bool(conversion.get("magical", false))


static func _ignores_armor_without_shred(player: PlayerStats) -> bool:
	if player == null:
		return false
	return bool(player.special_effects.get("ignore_armor_no_shred", false))


static func _ignores_resistance_with_physical_penalty(player: PlayerStats) -> bool:
	if player == null:
		return false
	return bool(player.special_effects.get("ignore_resistance_physical_penalty", false))


static func _physical_damage_penalty(player: PlayerStats) -> float:
	if not _ignores_resistance_with_physical_penalty(player):
		return 1.0
	if player == null:
		return 1.0
	return float(player.special_effects.get("physical_damage_penalty", 0.5))


static func _special_dict(player: PlayerStats, key: String) -> Dictionary:
	if player == null:
		return {}
	var value = player.special_effects.get(key, {})
	if value is Dictionary:
		return value
	return {}


static func _roll_weapon_damage_for_skill(skill: Skill, player: PlayerStats, active_poison_stacks: int, rng: RandomNumberGenerator) -> Dictionary:
	if not _skill_uses_weapon_roll(skill, active_poison_stacks):
		return {}
	var minimum := mini(player.weapon_damage_min, player.weapon_damage_max)
	var maximum := maxi(player.weapon_damage_min, player.weapon_damage_max)
	if minimum <= 0 or maximum <= 0:
		minimum = 1
		maximum = 1
	return {
		"roll": rng.randi_range(minimum, maximum),
		"min": minimum,
		"max": maximum,
		"tier": player.weapon_damage_tier,
		"weapon_id": player.weapon_damage_weapon_id,
		"uses_fallback": player.weapon_damage_uses_fallback,
		"fallback_reason": player.weapon_damage_fallback_reason,
	}


static func _skill_uses_weapon_roll(skill: Skill, active_poison_stacks: int) -> bool:
	if skill == null:
		return false
	for effect in skill.effects:
		if effect is PhysicalDamageEffect:
			return true
		if effect is StackScalingPhysicalDamageEffect and active_poison_stacks > 0:
			return true
	return false


static func _record_damage_contribution(event: CastEvent, skill: Skill, kind: String, damage: float, is_crit: bool, armor_reduction: int, poison_resistance_reduction: float, poison_stacks: int, gold_stolen: int = 0) -> void:
	if skill == null:
		return
	if damage <= 0.0 and armor_reduction <= 0 and poison_resistance_reduction <= 0.0 and poison_stacks <= 0 and gold_stolen <= 0:
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
		"gold_stolen": gold_stolen,
	})
