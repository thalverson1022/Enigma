extends SceneTree
## Headless P2:R9:T1-T3 check for the three new engine mechanics the 3
## remaining Phase 1 Legendaries need: gear-granted skill unlocks (Umbral
## Stiletto), gold-scaling flat physical damage (Bandit Blade), and a
## minimum-cast-time proc (Bejeweled Push Dagger). Uses synthetic Skill/
## GearItem/PlayerStats/Monster objects (not real Legendary content) so the
## numbers are hand-computable in isolation. Run with:
##   godot --headless -s res://tests/legendary_mechanics_test.gd

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


func _make_poison_skill(stacks: int) -> Skill:
	var skill := Skill.new()
	skill.display_name = "Test Poison"
	skill.base_execution_ms = 1000
	skill.min_execution_ms = 500
	var effect := PoisonDamageEffect.new()
	effect.stacks_applied = stacks
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


func _make_monster(hp: int, armor: int, poison_resistance: float = 0.0) -> Monster:
	var monster := Monster.new()
	monster.display_name = "Test Dummy"
	monster.hp = hp
	monster.armor = armor
	monster.poison_resistance = poison_resistance
	return monster


## resolve_stats() (unlike resolve_unlocked_skills()) always expects a real
## class_def -- every real caller passes BuildState.selected_class, which is
## never null by the time a fight resolves -- so tests need a minimal
## synthetic one rather than passing null.
func _make_class_def() -> ClassDef:
	var class_def := ClassDef.new()
	class_def.base_stats = PlayerStats.new()
	return class_def


func _initialize() -> void:
	var flat_monster := _make_monster(1000000, 0)

	# ---- P2:R9:T1 -- gear-granted skill unlock (Umbral Stiletto pattern) ----
	var unlock_skill := Skill.new()
	unlock_skill.id = "skill.test_gear_unlock"
	unlock_skill.display_name = "Test Gear-Unlocked Skill"
	var unlock_gear := GearItem.new()
	unlock_gear.id = "gear.test_unlocker"
	unlock_gear.slot = GearItem.SlotType.WEAPON
	unlock_gear.unlocked_skills = [unlock_skill]

	# No class/trees/talents at all -- the skill must still surface purely
	# from equipped gear, exactly like Umbral Stiletto unlocking Death Strike
	# regardless of chosen talents/trees.
	var unlocked_without_gear: Array[Skill] = BuildResolver.resolve_unlocked_skills(null, [], [])
	var unlocked_with_gear: Array[Skill] = BuildResolver.resolve_unlocked_skills(null, [], [], [unlock_gear])
	print("gear unlock: without gear=%d skills, with gear=%d skills (expect 0, 1)" % [
		unlocked_without_gear.size(), unlocked_with_gear.size()
	])
	_require("gear_granted_skill_unlock baseline empty", unlocked_without_gear.is_empty(), {
		"gear": "none",
		"unlocked": _skill_names(unlocked_without_gear),
	})
	_require_equal("gear_granted_skill_unlock count", unlocked_with_gear.size(), 1, {
		"gear": _gear_summary(unlock_gear),
		"unlocked": _skill_names(unlocked_with_gear),
	})
	_require_equal("gear_granted_skill_unlock id", unlocked_with_gear[0].id, "skill.test_gear_unlock", {
		"gear": _gear_summary(unlock_gear),
		"unlocked": _skill_names(unlocked_with_gear),
	})

	var class_def := _make_class_def()

	# ---- P2:R9:T2 -- gold-scaling flat physical damage (Bandit Blade) ----
	var gold_gear := GearItem.new()
	gold_gear.id = "gear.test_bandit_blade"
	gold_gear.slot = GearItem.SlotType.WEAPON
	gold_gear.physical_damage_per_gold = 0.1  # +1 physical damage per 10 gold

	var stats_no_gold := BuildResolver.resolve_stats(class_def, [], [], [gold_gear], 0)
	var stats_100_gold := BuildResolver.resolve_stats(class_def, [], [], [gold_gear], 100)
	print("gold-scaling bonus_physical_damage: 0 gold=%.2f (expect 0.0), 100 gold=%.2f (expect 10.0)" % [
		stats_no_gold.bonus_physical_damage, stats_100_gold.bonus_physical_damage
	])
	_require_approx("gold_scaling no gold bonus", stats_no_gold.bonus_physical_damage, 0.0, 0.001, {
		"gear": _gear_summary(gold_gear),
		"gold": 0,
	})
	_require_approx("gold_scaling 100 gold bonus", stats_100_gold.bonus_physical_damage, 10.0, 0.001, {
		"gear": _gear_summary(gold_gear),
		"gold": 100,
	})

	# No gear equipped at all must reproduce the pre-P2:R9 baseline exactly --
	# resolve_stats() defaults current_gold to 0 and no gear contributes the
	# new field, so bonus_physical_damage stays 0.0 regardless of live gold.
	var stats_no_gear_but_gold := BuildResolver.resolve_stats(class_def, [], [], [], 500)
	_require_approx("gold_scaling no gear ignores live gold", stats_no_gear_but_gold.bonus_physical_damage, 0.0, 0.001, {
		"gear": "none",
		"gold": 500,
	})

	# The bonus applies like flat base damage: crits/mitigates normally, and
	# applies to both PhysicalDamageEffect and StackScalingPhysicalDamageEffect
	# hits, consistent with how physical_damage_multiplier already applies to
	# both branches in CombatResolver._apply_skill_effects().
	var flat_stats := _make_stats()
	flat_stats.bonus_physical_damage = 5.0
	var flat_skill := _make_physical_skill(10.0)
	var flat_result: CombatResolver.CombatResult = CombatResolver.resolve([flat_skill], flat_stats, flat_monster, 1000)
	print("gold-scaling flat hit damage=%.2f (expect 15.0 = 10 base + 5 bonus)" % flat_result.cast_events[0].physical_damage)
	_require_approx("gold_scaling flat hit damage", flat_result.cast_events[0].physical_damage, 15.0, 0.001, {
		"bonus_physical_damage": flat_stats.bonus_physical_damage,
		"rotation": _skill_names([flat_skill]),
		"monster": _monster_summary(flat_monster),
	})

	var stack_stats := _make_stats()
	stack_stats.bonus_physical_damage = 5.0
	var stack_rotation: Array[Skill] = [_make_poison_skill(3), _make_stack_scaling_skill(2.0)]
	var stack_result: CombatResolver.CombatResult = CombatResolver.resolve(stack_rotation, stack_stats, flat_monster, 2000)
	print("gold-scaling stack-scaling hit damage=%.2f (expect 9.0 = 4.0 base + 5 bonus)" % stack_result.cast_events[1].physical_damage)
	_require_approx("gold_scaling stack-scaling hit damage", stack_result.cast_events[1].physical_damage, 9.0, 0.001, {
		"bonus_physical_damage": stack_stats.bonus_physical_damage,
		"rotation": _skill_names(stack_rotation),
		"monster": _monster_summary(flat_monster),
	})

	# ---- P2:R9:T3 -- minimum-cast-time proc (Bejeweled Push Dagger) ----
	var proc_gear := GearItem.new()
	proc_gear.id = "gear.test_bejeweled_push_dagger"
	proc_gear.slot = GearItem.SlotType.WEAPON
	proc_gear.min_cast_time_proc_chance = 0.2
	var proc_stats_resolved := BuildResolver.resolve_stats(class_def, [], [], [proc_gear])
	print("min_cast_time_proc_chance resolved=%.2f (expect 0.20)" % proc_stats_resolved.min_cast_time_proc_chance)
	_require_approx("min_cast_time_proc resolved chance", proc_stats_resolved.min_cast_time_proc_chance, 0.2, 0.001, {
		"gear": _gear_summary(proc_gear),
	})

	# A skill whose scaled time (2000ms, at 0 attack speed) is far above its
	# 500ms floor: a guaranteed proc (chance=1.0) should let 2 casts fit in a
	# 1000ms window instead of the 0 that fit without the proc.
	var slow_skill := Skill.new()
	slow_skill.display_name = "Test Slow Skill"
	slow_skill.base_execution_ms = 2000
	slow_skill.min_execution_ms = 500
	var slow_effect := PhysicalDamageEffect.new()
	slow_effect.amount = 1.0
	slow_skill.effects = [slow_effect]

	var no_proc_stats := _make_stats()
	var no_proc_result: CombatResolver.CombatResult = CombatResolver.resolve([slow_skill], no_proc_stats, flat_monster, 1000)
	print("no proc casts=%d (expect 0, since 2000ms scaled time exceeds the 1000ms window)" % no_proc_result.cast_events.size())
	_require("min_cast_time_proc baseline has no casts", no_proc_result.cast_events.is_empty(), {
		"seed": "default",
		"duration_ms": 1000,
		"skill_base_execution_ms": slow_skill.base_execution_ms,
		"min_execution_ms": slow_skill.min_execution_ms,
	})

	var guaranteed_proc_stats := _make_stats()
	guaranteed_proc_stats.min_cast_time_proc_chance = 1.0
	var guaranteed_proc_result: CombatResolver.CombatResult = CombatResolver.resolve([slow_skill], guaranteed_proc_stats, flat_monster, 1000)
	print("guaranteed proc casts=%d (expect 2, each forced to the 500ms floor)" % guaranteed_proc_result.cast_events.size())
	_require_equal("min_cast_time_proc guaranteed cast count", guaranteed_proc_result.cast_events.size(), 2, {
		"seed": "default",
		"duration_ms": 1000,
		"proc_chance": guaranteed_proc_stats.min_cast_time_proc_chance,
		"events": _cast_summaries(guaranteed_proc_result.cast_events),
	})
	_require("min_cast_time_proc first cast flagged", guaranteed_proc_result.cast_events[0].min_cast_time_proc_applied, {
		"event": _cast_summary(guaranteed_proc_result.cast_events[0]),
	})
	_require("min_cast_time_proc second cast flagged", guaranteed_proc_result.cast_events[1].min_cast_time_proc_applied, {
		"event": _cast_summary(guaranteed_proc_result.cast_events[1]),
	})
	_require_equal("min_cast_time_proc first cast timing", guaranteed_proc_result.cast_events[0].time_ms, 500, {
		"event": _cast_summary(guaranteed_proc_result.cast_events[0]),
	})
	_require_equal("min_cast_time_proc second cast timing", guaranteed_proc_result.cast_events[1].time_ms, 1000, {
		"event": _cast_summary(guaranteed_proc_result.cast_events[1]),
	})

	# Regression guard: chance=0.0 (the default for every build without this
	# Legendary) must never roll the proc RNG at all (short-circuited `and`),
	# so timing/crit sequences for existing builds are provably unaffected.
	var zero_chance_stats := _make_stats()
	zero_chance_stats.min_cast_time_proc_chance = 0.0
	var zero_chance_result: CombatResolver.CombatResult = CombatResolver.resolve([slow_skill], zero_chance_stats, flat_monster, 1000)
	print("zero-chance casts=%d (expect 0, identical to no-proc baseline)" % zero_chance_result.cast_events.size())
	_require("min_cast_time_proc zero chance matches baseline", zero_chance_result.cast_events.is_empty(), {
		"seed": "default",
		"duration_ms": 1000,
		"proc_chance": zero_chance_stats.min_cast_time_proc_chance,
		"events": _cast_summaries(zero_chance_result.cast_events),
	})

	# ---- Mithril Karambit: each trigger must only fire from its own skill
	# (user-reported bug: mithril_karambit.tres left source_skill_ids empty
	# on both its Stab and Heavy Slash triggers, and an empty list means
	# "matches any cast" per CombatResolver._trigger_matches_source() -- so
	# casting Stab could wrongly trigger a bonus Heavy Slash, and casting
	# Heavy Slash could wrongly trigger a bonus Stab) ----
	var mithril: GearItem = load("res://data/gear/mithril_karambit.tres")
	var stab_skill: Skill = load("res://data/skills/stab.tres")
	var heavy_skill: Skill = load("res://data/skills/heavy_slash.tres")
	var mithril_stats := BuildResolver.resolve_stats(class_def, [], [], [mithril])
	_require_equal("mithril_karambit trigger count", mithril_stats.triggered_skill_effects.size(), 2, {
		"gear": _gear_summary(mithril),
	})
	for trigger in mithril_stats.triggered_skill_effects:
		trigger.chance = 1.0  # force certainty for a deterministic check
	var mithril_result: CombatResolver.CombatResult = CombatResolver.resolve(
		[stab_skill, heavy_skill], mithril_stats, flat_monster, 10000, 1
	)
	var stab_events: Array = mithril_result.cast_events.filter(func(e): return e.skill == stab_skill)
	var heavy_events: Array = mithril_result.cast_events.filter(func(e): return e.skill == heavy_skill)
	print("Mithril Karambit: %d Stab casts, %d Heavy Slash casts" % [stab_events.size(), heavy_events.size()])
	_require("mithril_karambit has Stab casts", not stab_events.is_empty(), {
		"seed": 1,
		"rotation": _skill_names([stab_skill, heavy_skill]),
		"events": _cast_summaries(mithril_result.cast_events),
	})
	_require("mithril_karambit has Heavy Slash casts", not heavy_events.is_empty(), {
		"seed": 1,
		"rotation": _skill_names([stab_skill, heavy_skill]),
		"events": _cast_summaries(mithril_result.cast_events),
	})
	for i in mithril_result.cast_events.size():
		var event: CombatResolver.CastEvent = mithril_result.cast_events[i]
		var expected_skill := stab_skill if i % 2 == 0 else heavy_skill
		var expected_rotation_index := i % 2
		_require_equal("mithril_karambit macro alternates skill at event %d" % i, event.skill, expected_skill, {
			"seed": 1,
			"event": _cast_summary(event),
			"expected_skill": expected_skill.display_name,
		})
		_require_equal("mithril_karambit macro alternates rotation index at event %d" % i, event.rotation_index, expected_rotation_index, {
			"seed": 1,
			"event": _cast_summary(event),
		})
	for event in stab_events:
		_require("mithril_karambit Stab cast retriggers Stab", event.triggered_skill_names.has("Stab"), {
			"seed": 1,
			"event": _cast_summary(event),
		})
		_require("mithril_karambit Stab cast does not trigger Heavy Slash", not event.triggered_skill_names.has("Heavy Slash"), {
			"seed": 1,
			"event": _cast_summary(event),
		})
	for event in heavy_events:
		_require("mithril_karambit Heavy Slash cast retriggers Heavy Slash", event.triggered_skill_names.has("Heavy Slash"), {
			"seed": 1,
			"event": _cast_summary(event),
		})
		_require("mithril_karambit Heavy Slash cast does not trigger Stab", not event.triggered_skill_names.has("Stab"), {
			"seed": 1,
			"event": _cast_summary(event),
		})
	print("Stab/Heavy macro order still alternates while each cast retriggers itself: OK")

	print("")
	if _failed:
		print("P2:R9:T1-T3 legendary mechanics check: FAILED")
		quit(1)
	print("P2:R9:T1-T3 legendary mechanics check: OK")
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


func _gear_summary(gear: GearItem) -> Dictionary:
	return {
		"id": gear.id,
		"name": gear.display_name,
		"slot": gear.slot,
		"tier": gear.tier,
		"resource_path": gear.resource_path,
	}


func _monster_summary(monster: Monster) -> Dictionary:
	return {
		"name": monster.display_name,
		"hp": monster.hp,
		"armor": monster.armor,
		"poison_resistance": monster.poison_resistance,
	}


func _cast_summaries(events: Array) -> Array:
	var summaries: Array = []
	for event in events:
		summaries.append(_cast_summary(event))
	return summaries


func _cast_summary(event: CombatResolver.CastEvent) -> Dictionary:
	return {
		"time_ms": event.time_ms,
		"skill": "%s(%s)" % [event.skill.display_name, event.skill.id],
		"rotation_index": event.rotation_index,
		"physical_damage": event.physical_damage,
		"min_cast_time_proc_applied": event.min_cast_time_proc_applied,
		"triggered_skill_names": event.triggered_skill_names,
		"damage_contributions": event.damage_contributions,
	}
