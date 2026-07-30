extends SceneTree
## Headless P2:R9:T1-T3 check for the three new engine mechanics the 3
## remaining Phase 1 Legendaries need: gear-granted skill unlocks (Umbral
## Stiletto), gold-scaling flat physical damage (Bandit Blade), and a
## minimum-cast-time proc (Bejeweled Push Dagger). Uses synthetic Skill/
## GearItem/PlayerStats/Monster objects (not real Legendary content) so the
## numbers are hand-computable in isolation. Run with:
##   godot --headless -s res://tests/legendary_mechanics_test.gd


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
	assert(unlocked_without_gear.is_empty())
	assert(unlocked_with_gear.size() == 1)
	assert(unlocked_with_gear[0].id == "skill.test_gear_unlock")

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
	assert(is_equal_approx(stats_no_gold.bonus_physical_damage, 0.0))
	assert(is_equal_approx(stats_100_gold.bonus_physical_damage, 10.0))

	# No gear equipped at all must reproduce the pre-P2:R9 baseline exactly --
	# resolve_stats() defaults current_gold to 0 and no gear contributes the
	# new field, so bonus_physical_damage stays 0.0 regardless of live gold.
	var stats_no_gear_but_gold := BuildResolver.resolve_stats(class_def, [], [], [], 500)
	assert(is_equal_approx(stats_no_gear_but_gold.bonus_physical_damage, 0.0))

	# The bonus applies like flat base damage: crits/mitigates normally, and
	# applies to both PhysicalDamageEffect and StackScalingPhysicalDamageEffect
	# hits, consistent with how physical_damage_multiplier already applies to
	# both branches in CombatResolver._apply_skill_effects().
	var flat_stats := _make_stats()
	flat_stats.bonus_physical_damage = 5.0
	var flat_skill := _make_physical_skill(10.0)
	var flat_result: CombatResolver.CombatResult = CombatResolver.resolve([flat_skill], flat_stats, flat_monster, 1000)
	print("gold-scaling flat hit damage=%.2f (expect 15.0 = 10 base + 5 bonus)" % flat_result.cast_events[0].physical_damage)
	assert(is_equal_approx(flat_result.cast_events[0].physical_damage, 15.0))

	var stack_stats := _make_stats()
	stack_stats.bonus_physical_damage = 5.0
	var stack_rotation: Array[Skill] = [_make_poison_skill(3), _make_stack_scaling_skill(2.0)]
	var stack_result: CombatResolver.CombatResult = CombatResolver.resolve(stack_rotation, stack_stats, flat_monster, 2000)
	print("gold-scaling stack-scaling hit damage=%.2f (expect 9.0 = 4.0 base + 5 bonus)" % stack_result.cast_events[1].physical_damage)
	assert(is_equal_approx(stack_result.cast_events[1].physical_damage, 9.0))

	# ---- P2:R9:T3 -- minimum-cast-time proc (Bejeweled Push Dagger) ----
	var proc_gear := GearItem.new()
	proc_gear.id = "gear.test_bejeweled_push_dagger"
	proc_gear.slot = GearItem.SlotType.WEAPON
	proc_gear.min_cast_time_proc_chance = 0.2
	var proc_stats_resolved := BuildResolver.resolve_stats(class_def, [], [], [proc_gear])
	print("min_cast_time_proc_chance resolved=%.2f (expect 0.20)" % proc_stats_resolved.min_cast_time_proc_chance)
	assert(is_equal_approx(proc_stats_resolved.min_cast_time_proc_chance, 0.2))

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
	assert(no_proc_result.cast_events.is_empty())

	var guaranteed_proc_stats := _make_stats()
	guaranteed_proc_stats.min_cast_time_proc_chance = 1.0
	var guaranteed_proc_result: CombatResolver.CombatResult = CombatResolver.resolve([slow_skill], guaranteed_proc_stats, flat_monster, 1000)
	print("guaranteed proc casts=%d (expect 2, each forced to the 500ms floor)" % guaranteed_proc_result.cast_events.size())
	assert(guaranteed_proc_result.cast_events.size() == 2)
	assert(guaranteed_proc_result.cast_events[0].min_cast_time_proc_applied)
	assert(guaranteed_proc_result.cast_events[1].min_cast_time_proc_applied)
	assert(guaranteed_proc_result.cast_events[0].time_ms == 500)
	assert(guaranteed_proc_result.cast_events[1].time_ms == 1000)

	# Regression guard: chance=0.0 (the default for every build without this
	# Legendary) must never roll the proc RNG at all (short-circuited `and`),
	# so timing/crit sequences for existing builds are provably unaffected.
	var zero_chance_stats := _make_stats()
	zero_chance_stats.min_cast_time_proc_chance = 0.0
	var zero_chance_result: CombatResolver.CombatResult = CombatResolver.resolve([slow_skill], zero_chance_stats, flat_monster, 1000)
	print("zero-chance casts=%d (expect 0, identical to no-proc baseline)" % zero_chance_result.cast_events.size())
	assert(zero_chance_result.cast_events.is_empty())

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
	assert(mithril_stats.triggered_skill_effects.size() == 2)
	for trigger in mithril_stats.triggered_skill_effects:
		trigger.chance = 1.0  # force certainty for a deterministic check
	var mithril_result: CombatResolver.CombatResult = CombatResolver.resolve(
		[stab_skill, heavy_skill], mithril_stats, flat_monster, 10000, 1
	)
	var stab_events: Array = mithril_result.cast_events.filter(func(e): return e.skill == stab_skill)
	var heavy_events: Array = mithril_result.cast_events.filter(func(e): return e.skill == heavy_skill)
	print("Mithril Karambit: %d Stab casts, %d Heavy Slash casts" % [stab_events.size(), heavy_events.size()])
	assert(not stab_events.is_empty())
	assert(not heavy_events.is_empty())
	for i in mithril_result.cast_events.size():
		var event: CombatResolver.CastEvent = mithril_result.cast_events[i]
		var expected_skill := stab_skill if i % 2 == 0 else heavy_skill
		var expected_rotation_index := i % 2
		assert(event.skill == expected_skill)
		assert(event.rotation_index == expected_rotation_index)
	for event in stab_events:
		assert(event.triggered_skill_names.has("Stab"))
		assert(not event.triggered_skill_names.has("Heavy Slash"))
	for event in heavy_events:
		assert(event.triggered_skill_names.has("Heavy Slash"))
		assert(not event.triggered_skill_names.has("Stab"))
	print("Stab/Heavy macro order still alternates while each cast retriggers itself: OK")

	print("")
	print("P2:R9:T1-T3 legendary mechanics check: OK")
	quit()
