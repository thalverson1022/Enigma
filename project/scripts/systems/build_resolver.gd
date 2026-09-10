class_name BuildResolver
extends RefCounted
## Ports the Build Resolution order from
## docs/Phase 1 Context Docs/Current_Mechanics_Reference.md: base stats ->
## tree innate modifiers -> selected talent modifiers -> equipped gear
## modifiers -> filter rotation to unlocked skills.
##
## GOLD_REWARDS feeds both post-fight rewards and any combat effects that
## generate stash gold. The resolved multiplier lives on PlayerStats so the
## reward and combat paths share the same rounding policy.

## Rotation/macro slot cap (user-requested), enforced once here since both
## BuildState.set_rotation() (real Adventure) and TrainingRoomState.
## set_rotation() already route every rotation edit through
## resolve_rotation() -- a single chokepoint covers both screens.
const MAX_ROTATION_SIZE := 10
const GearStatSheet := preload("res://scripts/resources/stat_sheet.gd")
const WeaponDamageCatalog := preload("res://scripts/systems/weapon_damage_catalog.gd")


static func resolve_stats(class_def: ClassDef, selected_trees: Array[SubclassTree], selected_talents: Array[Talent], equipped_gear: Array[GearItem] = [], current_gold: int = 0) -> PlayerStats:
	var stats := PlayerStats.new()
	if class_def != null:
		stats.attack_speed = class_def.base_stats.attack_speed
		stats.crit_chance = class_def.base_stats.crit_chance
		stats.crit_multiplier = class_def.base_stats.crit_multiplier
		stats.base_poison_damage = class_def.base_stats.poison_damage_per_tick
		stats.poison_damage_per_tick = class_def.base_stats.poison_damage_per_tick
		stats.talent_physical_damage_multiplier = class_def.base_stats.physical_damage_multiplier
		stats.physical_damage_uses_buckets = true
		stats.sync_physical_damage_multiplier()
		stats.bonus_poison_stacks = class_def.base_stats.bonus_poison_stacks
		stats.bonus_armor_reduction = class_def.base_stats.bonus_armor_reduction
		stats.shred_value = class_def.base_stats.shred_value
		stats.bonus_shred_stacks = class_def.base_stats.bonus_shred_stacks
		stats.bonus_decay_stacks = class_def.base_stats.bonus_decay_stacks
		stats.decay_value = class_def.base_stats.decay_value
		stats.poison_stack_cap = class_def.base_stats.poison_stack_cap
		stats.poison_tick_interval_multiplier = class_def.base_stats.poison_tick_interval_multiplier
		stats.gold_reward_multiplier = class_def.base_stats.gold_reward_multiplier
		stats.crit_chance_per_stolen_gold = class_def.base_stats.crit_chance_per_stolen_gold
		stats.crit_multiplier_per_current_gold = class_def.base_stats.crit_multiplier_per_current_gold
	stats.triggered_skill_effects = []
	stats.current_gold = current_gold
	var gold_reward_talent_multiplier := 1.0

	for tree in selected_trees:
		for modifier in tree.innate_modifiers:
			if _is_gold_reward_multiplier_modifier(modifier):
				gold_reward_talent_multiplier *= _gold_reward_multiplier_for_modifier(modifier)
				continue
			_apply_modifier(stats, modifier)
	for talent in selected_talents:
		for modifier in talent.stat_modifiers:
			if _is_gold_reward_multiplier_modifier(modifier):
				gold_reward_talent_multiplier *= _gold_reward_multiplier_for_modifier(modifier)
				continue
			_apply_modifier(stats, modifier)
		for trigger in talent.triggered_skill_effects:
			if trigger != null:
				stats.triggered_skill_effects.append(trigger)
	var gear_stat_sheet = resolve_gear_stat_sheet(equipped_gear)
	gear_stat_sheet.apply_to_player_stats(stats)
	stats.gold_reward_multiplier = maxf(0.0, stats.gold_reward_multiplier * gold_reward_talent_multiplier)
	_apply_weapon_damage_range(stats, equipped_gear)
	for gear in equipped_gear:
		for trigger in gear.triggered_skill_effects:
			if trigger != null:
				stats.triggered_skill_effects.append(trigger)
		stats.bonus_physical_damage += gear.physical_damage_per_gold * float(current_gold)
		stats.min_cast_time_proc_chance += gear.min_cast_time_proc_chance

	return stats


static func resolve_gear_stat_sheet(equipped_gear: Array[GearItem] = []):
	var sheet = GearStatSheet.new()
	sheet.add_gear_collection(equipped_gear)
	sheet.finalize()
	return sheet


static func resolve_weapon_damage_range(equipped_gear: Array[GearItem] = []) -> Dictionary:
	return WeaponDamageCatalog.damage_range_for_equipped_gear(equipped_gear)


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
	if _is_legacy_poison_damage_multiplier(modifier):
		stats.talent_elemental_damage_multiplier = stats.talent_elemental_damage_multiplier * modifier.value
		stats.sync_elemental_damage_multiplier()
		stats.sync_poison_damage_per_tick()
		return
	if _apply_canonical_modifier(stats, modifier):
		return
	match modifier.stat:
		StatModifier.StatType.ATTACK_SPEED:
			stats.attack_speed = _apply_op(stats.attack_speed, modifier)
		StatModifier.StatType.CRIT_CHANCE:
			stats.crit_chance = _apply_op(stats.crit_chance, modifier)
		StatModifier.StatType.CRIT_MULTIPLIER:
			stats.crit_multiplier = maxf(1.0, _apply_op(stats.crit_multiplier, modifier))
		StatModifier.StatType.POISON_DAMAGE:
			if modifier.operation == StatModifier.OperationType.MULTIPLY:
				stats.talent_elemental_damage_multiplier = stats.talent_elemental_damage_multiplier * modifier.value
				stats.sync_elemental_damage_multiplier()
			else:
				stats.bonus_base_elemental_damage = stats.bonus_base_elemental_damage + modifier.value
			stats.sync_poison_damage_per_tick()
		StatModifier.StatType.PHYSICAL_DAMAGE:
			stats.talent_physical_damage_multiplier = _apply_op(stats.talent_physical_damage_multiplier, modifier)
			stats.physical_damage_uses_buckets = true
			stats.sync_physical_damage_multiplier()
		StatModifier.StatType.POISON_STACKS_APPLIED:
			_apply_all_stack_bonus(stats, int(round(_modifier_additive_value(modifier))))
		StatModifier.StatType.ARMOR_REDUCTION:
			_apply_all_stack_bonus(stats, int(round(_modifier_additive_value(modifier))))
		StatModifier.StatType.POISON_TICK_INTERVAL:
			stats.poison_tick_interval_multiplier = max(0.05, _apply_op(stats.poison_tick_interval_multiplier, modifier))
		StatModifier.StatType.GOLD_REWARDS:
			stats.gold_reward_multiplier = maxf(0.0, stats.gold_reward_multiplier * (1.0 + modifier.value))
		StatModifier.StatType.CRIT_CHANCE_PER_STOLEN_GOLD:
			stats.crit_chance_per_stolen_gold = _apply_op(stats.crit_chance_per_stolen_gold, modifier)
		StatModifier.StatType.CRIT_MULTIPLIER_PER_CURRENT_GOLD:
			stats.crit_multiplier_per_current_gold = _apply_op(stats.crit_multiplier_per_current_gold, modifier)
		_:
			pass


static func _apply_canonical_modifier(stats: PlayerStats, modifier: StatModifier) -> bool:
	if modifier == null or modifier.stat_id.strip_edges() == "":
		return false
	var stat_id := StatCatalog.canonical_id_for_modifier(modifier)
	if stat_id == "" or not StatCatalog.has_stat(stat_id):
		return false
	match stat_id:
		StatCatalog.BASE_DAMAGE:
			stats.bonus_physical_damage = stats.bonus_physical_damage + _modifier_additive_value(modifier)
		StatCatalog.PERCENT_PHYSICAL_DAMAGE:
			stats.talent_physical_damage_multiplier = stats.talent_physical_damage_multiplier * _modifier_talent_multiplier(modifier)
			stats.physical_damage_uses_buckets = true
			stats.sync_physical_damage_multiplier()
		StatCatalog.INCREASED_ATTACK_SPEED:
			stats.attack_speed = stats.attack_speed + _modifier_additive_value(modifier)
		StatCatalog.CRIT_CHANCE:
			stats.crit_chance = clampf(stats.crit_chance + _modifier_additive_value(modifier), 0.0, 1.0)
		StatCatalog.CRIT_DAMAGE:
			stats.crit_multiplier = maxf(1.0, stats.crit_multiplier + _modifier_additive_value(modifier))
		StatCatalog.BASE_ELEMENTAL_DAMAGE:
			stats.bonus_base_elemental_damage = stats.bonus_base_elemental_damage + _modifier_additive_value(modifier)
			stats.sync_poison_damage_per_tick()
		StatCatalog.PERCENT_ELEMENTAL_DAMAGE:
			stats.talent_elemental_damage_multiplier = stats.talent_elemental_damage_multiplier * _modifier_talent_multiplier(modifier)
			stats.sync_elemental_damage_multiplier()
			stats.sync_poison_damage_per_tick()
		StatCatalog.INCREASED_ALL_STACKS:
			_apply_all_stack_bonus(stats, int(round(_modifier_additive_value(modifier))))
		StatCatalog.SHRED_VALUE:
			stats.shred_value = max(0, stats.shred_value + int(round(_modifier_additive_value(modifier))))
		StatCatalog.BONUS_SHRED_STACKS:
			stats.bonus_shred_stacks = max(0, stats.bonus_shred_stacks + int(round(_modifier_additive_value(modifier))))
		StatCatalog.DECAY_VALUE:
			stats.decay_value = maxf(0.0, stats.decay_value + _modifier_additive_value(modifier))
		StatCatalog.INCREASED_GOLD:
			stats.gold_reward_multiplier = maxf(0.0, stats.gold_reward_multiplier * _modifier_talent_multiplier(modifier))
		StatCatalog.SHOP_DISCOUNT:
			stats.shop_discount = maxf(0.0, stats.shop_discount + _modifier_additive_value(modifier))
		StatCatalog.INCREASED_MAGIC_FIND:
			stats.magic_find = maxf(0.0, stats.magic_find + _modifier_additive_value(modifier))
		StatCatalog.CHANCE_FOR_RETRIGGER:
			stats.retrigger_chance = clampf(stats.retrigger_chance + _modifier_additive_value(modifier), 0.0, 1.0)
		StatCatalog.CHANCE_TO_SHRED:
			stats.shred_chance = clampf(stats.shred_chance + _modifier_additive_value(modifier), 0.0, 1.0)
		StatCatalog.CHANCE_TO_DECAY:
			stats.decay_chance = clampf(stats.decay_chance + _modifier_additive_value(modifier), 0.0, 1.0)
		StatCatalog.CRIT_APPLIES_ELEMENT:
			stats.elemental_proc_chance = clampf(stats.elemental_proc_chance + _modifier_additive_value(modifier), 0.0, 1.0)
		_:
			if not StatCatalog.is_special(stat_id):
				return false
			_apply_special_modifier(stats, stat_id)
	return true


static func _apply_all_stack_bonus(stats: PlayerStats, bonus: int) -> void:
	stats.bonus_poison_stacks = max(0, stats.bonus_poison_stacks + bonus)
	stats.bonus_armor_reduction = max(0, stats.bonus_armor_reduction + bonus)
	stats.bonus_shred_stacks = max(0, stats.bonus_shred_stacks + bonus)
	stats.bonus_decay_stacks = max(0, stats.bonus_decay_stacks + bonus)


static func _apply_special_modifier(stats: PlayerStats, stat_id: String) -> void:
	if not stats.special_stat_ids.has(stat_id):
		stats.special_stat_ids.append(stat_id)
	stats.special_effects[stat_id] = true
	match stat_id:
		StatCatalog.DECAY_APPLIES_SHRED:
			stats.special_effects["decay_applies_shred"] = true
		StatCatalog.POISON_STACK_CAP_40:
			var def := StatCatalog.definition(stat_id)
			stats.poison_stack_cap = maxi(stats.poison_stack_cap, int((def.get("fixed_constants", {}) as Dictionary).get("poison_stack_cap", 40)))


static func _modifier_additive_value(modifier: StatModifier) -> float:
	if modifier.operation == StatModifier.OperationType.MULTIPLY:
		return modifier.value - 1.0
	return modifier.value


static func _modifier_talent_multiplier(modifier: StatModifier) -> float:
	if modifier.operation == StatModifier.OperationType.MULTIPLY:
		return modifier.value
	return 1.0 + modifier.value


static func _is_legacy_poison_damage_multiplier(modifier: StatModifier) -> bool:
	return (
		modifier != null
		and modifier.stat_id.strip_edges() == ""
		and modifier.stat == StatModifier.StatType.POISON_DAMAGE
		and modifier.operation == StatModifier.OperationType.MULTIPLY
	)


static func _apply_op(current: float, modifier: StatModifier) -> float:
	if modifier.operation == StatModifier.OperationType.MULTIPLY:
		return current * modifier.value
	return current + modifier.value


static func _apply_weapon_damage_range(stats: PlayerStats, equipped_gear: Array[GearItem]) -> void:
	var range := resolve_weapon_damage_range(equipped_gear)
	stats.weapon_damage_min = int(range["min"])
	stats.weapon_damage_max = int(range["max"])
	stats.weapon_damage_tier = int(range["tier"])
	stats.weapon_damage_weapon_id = String(range["weapon_id"])
	stats.weapon_damage_uses_fallback = bool(range["uses_fallback"])
	stats.weapon_damage_fallback_reason = String(range["fallback_reason"])


static func _is_gold_reward_multiplier_modifier(modifier: StatModifier) -> bool:
	if modifier == null:
		return false
	if modifier.stat_id.strip_edges() != "":
		return StatCatalog.canonical_id_for_modifier(modifier) == StatCatalog.INCREASED_GOLD
	return modifier.stat == StatModifier.StatType.GOLD_REWARDS


static func _gold_reward_multiplier_for_modifier(modifier: StatModifier) -> float:
	if modifier == null:
		return 1.0
	if modifier.operation == StatModifier.OperationType.MULTIPLY:
		return modifier.value
	return 1.0 + modifier.value
