extends SceneTree
## Integrated P5M4 smoke: Practice Room state resolves a real Rogue build,
## real gear, target defenses, weapon rolls, Death Strike, and retriggers
## through the same CombatResolver boundary as direct combat.

var _failed := false


func _initialize() -> void:
	print("-- P5M4 Practice Room combat smoke --")
	var state := TrainingRoomState.new()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var assassin: SubclassTree = load("res://data/subclass_trees/assassin.tres")
	var bladedancer: SubclassTree = load("res://data/subclass_trees/bladedancer.tres")
	var umbral: GearItem = load("res://data/gear/umbral_stiletto.tres")
	var poison_strike: Skill = load("res://data/skills/poison_strike.tres")
	var quick_cut: Skill = load("res://data/skills/quick_cut.tres")
	var death_strike: Skill = load("res://data/skills/death_strike.tres")

	_require("fixture loads Rogue", rogue != null)
	_require("fixture loads Assassin", assassin != null)
	_require("fixture loads Bladedancer", bladedancer != null)
	_require("fixture loads Umbral Stiletto", umbral != null)
	_require("fixture loads rotation skills", poison_strike != null and quick_cut != null and death_strike != null)

	state.set_class(rogue)
	_require("selects Assassin primary tree", state.set_primary_tree(assassin))
	_require("selects Bladedancer secondary tree", state.set_secondary_tree(bladedancer))
	_select_talent_path(state, assassin, [
		"talent.venom_edge",
		"talent.lethal_intent",
		"talent.toxic_technique",
	])
	_select_talent_path(state, bladedancer, [
		"talent.piercing_blades",
		"talent.practiced_rhythm",
		"talent.opportunity_strikes",
	])

	var opportunity := _find_talent(bladedancer, "talent.opportunity_strikes")
	var trigger := opportunity.triggered_skill_effects[0]
	trigger.chance = 1.0

	state.equip_legendary(umbral)
	state.set_slot_rarity(state.practice_helm, GearItem.Tier.MASTER)
	state.set_affix_stat(state.practice_helm, 0, StatModifier.StatType.PHYSICAL_DAMAGE)
	state.notify_gear_edited()
	state.apply_target_preset("fortified")
	state.set_target_defense("poison_resistance", 0.2)
	state.set_target_defense("absorb", 2.0)
	state.set_target_defense("suppress", 0.25)
	state.set_duration_ms(7000)
	state.set_fight_seed(31)
	state.set_rotation([poison_strike, quick_cut, death_strike])
	_require_equal("resolved smoke rotation size", state.rotation.size(), 3)
	state.set_locked(true)
	_require("Practice Room state can run fight", state.can_run_fight())
	state.run_fight()

	var result := state.last_result
	_require("Practice Room produced a result", result != null)
	var stats := BuildResolver.resolve_stats(
		state.selected_class, state.selected_trees, state.selected_talents, state.equipped_gear(), state.gold
	)
	var expected := CombatResolver.resolve(state.rotation, stats, state.selected_target, state.duration_ms, state.fight_seed)
	_require_equal("Practice Room/direct resolver signature", _result_signature(result), _result_signature(expected))

	_require_equal("Legendary weapon damage source", stats.weapon_damage_weapon_id, "gear.legendary.umbral_stiletto")
	_require_equal("Legendary weapon min", stats.weapon_damage_min, 21)
	_require_equal("Legendary weapon max", stats.weapon_damage_max, 27)
	_require("weapon damage did not use fallback", not stats.weapon_damage_uses_fallback)
	_require("gear physical bucket applied", stats.gear_physical_damage_multiplier > 1.0)
	_require("talent physical bucket applied", stats.talent_physical_damage_multiplier > 1.0)

	_require("fight dealt damage", result.total_damage > 0.0)
	_require("poison ticks resolved", result.tick_events.size() > 0)
	_require("Poison Strike applied poison stacks", _any_cast_applied_stacks(result, "skill.poison_strike"))
	_require("Death Strike resolved with weapon roll", _death_strike_used_legendary_roll(result))
	_require("Opportunity Strikes resolved as proc cast", _has_proc_skill(result, "skill.rending_thrust"))
	_require("source cast records triggered skill name", _source_records_trigger(result, "skill.quick_cut", "Rending Slash"))
	_require("final damage values are whole numbers", _all_damage_values_are_whole(result))

	if _failed:
		print("P5M4 Practice Room combat smoke: FAILED")
		quit(1)
	print("P5M4 Practice Room combat smoke: OK")
	quit(0)


func _select_talent_path(state: TrainingRoomState, tree: SubclassTree, talent_ids: Array[String]) -> void:
	for talent_id in talent_ids:
		var talent := _find_talent(tree, talent_id)
		_require("finds %s" % talent_id, talent != null)
		_require("selects %s" % talent_id, state.select_talent(talent))


func _find_talent(tree: SubclassTree, talent_id: String) -> Talent:
	for talent in tree.talents:
		if talent.id == talent_id:
			return talent
	return null


func _result_signature(result: CombatResolver.CombatResult) -> String:
	var casts: Array[String] = []
	for event in result.cast_events:
		casts.append("%d:%s:%s:%s:%d:%.2f:%s:%s" % [
			event.time_ms,
			event.skill.id,
			event.cast_kind,
			event.trigger_source_skill_id,
			event.weapon_damage_roll,
			event.physical_damage,
			str(event.is_crit),
			str(event.triggered_skill_names),
		])
	var ticks: Array[String] = []
	for tick in result.tick_events:
		ticks.append("%d:%.2f:%.2f:%d" % [
			tick.time_ms,
			tick.damage,
			tick.absorbed_amount,
			tick.stacks_remaining,
		])
	return "total=%.2f|casts=%s|ticks=%s" % [result.total_damage, "|".join(casts), "|".join(ticks)]


func _any_cast_applied_stacks(result: CombatResolver.CombatResult, skill_id: String) -> bool:
	for event in result.cast_events:
		if event.skill.id == skill_id and event.poison_stacks_applied > 0:
			return true
	return false


func _death_strike_used_legendary_roll(result: CombatResolver.CombatResult) -> bool:
	for event in result.cast_events:
		if event.skill.id != CombatResolver.DEATH_STRIKE_SKILL_ID:
			continue
		if event.was_dodged or event.weapon_damage_rolls.size() != 1:
			continue
		var roll := int(event.weapon_damage_rolls[0].get("roll", 0))
		var weapon_id := String(event.weapon_damage_rolls[0].get("weapon_id", ""))
		if roll >= 21 and roll <= 27 and weapon_id == "gear.legendary.umbral_stiletto":
			return true
	return false


func _has_proc_skill(result: CombatResolver.CombatResult, skill_id: String) -> bool:
	for event in result.cast_events:
		if event.skill.id == skill_id and event.cast_kind == "proc":
			return true
	return false


func _source_records_trigger(result: CombatResolver.CombatResult, skill_id: String, triggered_name: String) -> bool:
	for event in result.cast_events:
		if event.skill.id == skill_id and event.cast_kind == "cast" and event.triggered_skill_names.has(triggered_name):
			return true
	return false


func _all_damage_values_are_whole(result: CombatResolver.CombatResult) -> bool:
	for event in result.cast_events:
		if not is_equal_approx(event.physical_damage, float(roundi(event.physical_damage))):
			return false
	for tick in result.tick_events:
		if not is_equal_approx(tick.damage, float(roundi(tick.damage))):
			return false
	return is_equal_approx(result.total_damage, float(roundi(result.total_damage)))


func _require(label: String, condition: bool) -> void:
	if condition:
		return
	_failed = true
	print("FAILED: %s" % label)


func _require_equal(label: String, actual: Variant, expected: Variant) -> void:
	if actual == expected:
		return
	_failed = true
	print("FAILED: %s" % label)
	print("  expected: %s" % str(expected))
	print("  actual:   %s" % str(actual))
