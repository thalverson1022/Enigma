class_name BuildResolver
extends RefCounted
## Ports the Build Resolution order from
## docs/Phase 1 Context Docs/Current_Mechanics_Reference.md: base stats ->
## tree innate modifiers -> selected talent modifiers -> equipped gear
## modifiers -> filter rotation to unlocked skills.
##
## GOLD_REWARDS stays an intentional no-op here: it's reward-only (not a
## combat stat) per Current_Mechanics_Reference.md, and no seeded content
## uses it in combat.

## Rotation/macro slot cap (user-requested), enforced once here since both
## BuildState.set_rotation() (real Adventure) and TrainingRoomState.
## set_rotation() already route every rotation edit through
## resolve_rotation() -- a single chokepoint covers both screens.
const MAX_ROTATION_SIZE := 10


static func resolve_stats(class_def: ClassDef, selected_trees: Array[SubclassTree], selected_talents: Array[Talent], equipped_gear: Array[GearItem] = [], current_gold: int = 0) -> PlayerStats:
	var stats := PlayerStats.new()
	stats.attack_speed = class_def.base_stats.attack_speed
	stats.crit_chance = class_def.base_stats.crit_chance
	stats.crit_multiplier = class_def.base_stats.crit_multiplier
	stats.poison_damage_per_tick = class_def.base_stats.poison_damage_per_tick
	stats.physical_damage_multiplier = class_def.base_stats.physical_damage_multiplier
	stats.bonus_poison_stacks = class_def.base_stats.bonus_poison_stacks
	stats.bonus_armor_reduction = class_def.base_stats.bonus_armor_reduction
	stats.poison_tick_interval_multiplier = class_def.base_stats.poison_tick_interval_multiplier
	stats.triggered_skill_effects = []

	for tree in selected_trees:
		for modifier in tree.innate_modifiers:
			_apply_modifier(stats, modifier)
	for talent in selected_talents:
		for modifier in talent.stat_modifiers:
			_apply_modifier(stats, modifier)
		for trigger in talent.triggered_skill_effects:
			if trigger != null:
				stats.triggered_skill_effects.append(trigger)
	for gear in equipped_gear:
		for modifier in gear.affixes:
			_apply_modifier(stats, modifier)
		for trigger in gear.triggered_skill_effects:
			if trigger != null:
				stats.triggered_skill_effects.append(trigger)
		stats.bonus_physical_damage += gear.physical_damage_per_gold * float(current_gold)
		stats.min_cast_time_proc_chance += gear.min_cast_time_proc_chance

	return stats


static func resolve_unlocked_skills(class_def: ClassDef, selected_trees: Array[SubclassTree], selected_talents: Array[Talent], equipped_gear: Array[GearItem] = []) -> Array[Skill]:
	var skills: Array[Skill] = []
	if class_def != null:
		for skill in class_def.base_skills:
			_append_skill_clone(skills, skill)
	for tree in selected_trees:
		for skill in tree.unlocked_skills:
			_append_skill_clone(skills, skill)
	for talent in selected_talents:
		for skill in talent.unlocked_skills:
			_append_skill_clone(skills, skill)
	for gear in equipped_gear:
		for skill in gear.unlocked_skills:
			_append_skill_clone(skills, skill)
	for tree in selected_trees:
		for augment in tree.skill_augments:
			_apply_skill_augment(skills, augment)
	return skills


static func resolve_rotation(rotation: Array[Skill], unlocked_skills: Array[Skill]) -> Array[Skill]:
	var filtered: Array[Skill] = []
	for skill in rotation:
		if filtered.size() >= MAX_ROTATION_SIZE:
			break
		var resolved_skill := _find_skill_by_id(unlocked_skills, skill.id)
		if resolved_skill != null:
			filtered.append(resolved_skill)
	return filtered


static func _append_skill_clone(skills: Array[Skill], skill: Skill) -> void:
	if skill == null or _find_skill_by_id(skills, skill.id) != null:
		return
	skills.append(skill.duplicate(true))


static func _find_skill_by_id(skills: Array[Skill], skill_id: String) -> Skill:
	for skill in skills:
		if skill != null and skill.id == skill_id:
			return skill
	return null


static func _apply_skill_augment(skills: Array[Skill], augment: SkillAugment) -> void:
	if augment == null:
		return
	for target_id in augment.target_skill_ids:
		var skill := _find_skill_by_id(skills, target_id)
		if skill == null:
			continue
		var applied_poison_from_extra := false
		for effect in augment.extra_effects:
			if effect != null:
				skill.effects.append(effect.duplicate(true))
				if effect is PoisonDamageEffect:
					applied_poison_from_extra = true
		if augment.poison_stacks_applied > 0:
			skill.poison_stacks_applied += augment.poison_stacks_applied
		if augment.poison_stacks_applied > 0 and not applied_poison_from_extra:
			var poison_effect := PoisonDamageEffect.new()
			poison_effect.stacks_applied = augment.poison_stacks_applied
			skill.effects.append(poison_effect)


static func _apply_modifier(stats: PlayerStats, modifier: StatModifier) -> void:
	match modifier.stat:
		StatModifier.StatType.ATTACK_SPEED:
			stats.attack_speed = _apply_op(stats.attack_speed, modifier)
		StatModifier.StatType.CRIT_CHANCE:
			stats.crit_chance = _apply_op(stats.crit_chance, modifier)
		StatModifier.StatType.CRIT_MULTIPLIER:
			stats.crit_multiplier = _apply_op(stats.crit_multiplier, modifier)
		StatModifier.StatType.POISON_DAMAGE:
			stats.poison_damage_per_tick = _apply_op(stats.poison_damage_per_tick, modifier)
		StatModifier.StatType.PHYSICAL_DAMAGE:
			stats.physical_damage_multiplier = _apply_op(stats.physical_damage_multiplier, modifier)
		StatModifier.StatType.POISON_STACKS_APPLIED:
			stats.bonus_poison_stacks = int(round(_apply_op(float(stats.bonus_poison_stacks), modifier)))
		StatModifier.StatType.ARMOR_REDUCTION:
			stats.bonus_armor_reduction = int(round(_apply_op(float(stats.bonus_armor_reduction), modifier)))
		StatModifier.StatType.POISON_TICK_INTERVAL:
			stats.poison_tick_interval_multiplier = max(0.05, _apply_op(stats.poison_tick_interval_multiplier, modifier))
		_:
			pass


static func _apply_op(current: float, modifier: StatModifier) -> float:
	if modifier.operation == StatModifier.OperationType.MULTIPLY:
		return current * modifier.value
	return current + modifier.value
