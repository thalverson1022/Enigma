extends SceneTree
## Focused P5M10-T4 checks for retained Rogue Legendary combat effects after
## fixed Phase 5 stat packages were applied to the authored resources.

var _failed := false


func _initialize() -> void:
	print("-- P5M10 Legendary combat effects --")
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require("Rogue loads", rogue != null)

	_check_wyvern_poison_cadence(rogue)
	_check_bandit_gold_damage(rogue)
	_check_umbral_death_strike_unlock_and_use(rogue)
	_check_mithril_source_filtered_retriggers(rogue)
	_check_bejeweled_min_cast_time_proc(rogue)

	if _failed:
		print("P5M10 Legendary combat effects: FAILED")
		quit(1)
	print("P5M10 Legendary combat effects: OK")
	quit(0)


func _check_wyvern_poison_cadence(rogue: ClassDef) -> void:
	var wyvern: GearItem = load("res://data/gear/wyvern_kriss.tres")
	_require("Wyvern Kriss loads", wyvern != null)
	var stats := BuildResolver.resolve_stats(rogue, [], [], [wyvern])
	_require_approx("Wyvern poison tick interval multiplier", stats.poison_tick_interval_multiplier, 0.5)
	_require_approx("Wyvern base elemental package", stats.bonus_base_elemental_damage, 8.0)
	_require_approx("Wyvern elemental percent package", stats.gear_elemental_damage_multiplier, 1.4)
	_require_approx("Wyvern decay chance package", stats.decay_chance, 0.12)

	var result := CombatResolver.resolve([_poison_skill()], stats, _target(), 1600, 11)
	_require_equal("Wyvern fast tick count", result.tick_events.size(), 3)
	for tick in result.tick_events:
		_require_equal("Wyvern tick interval", tick.tick_interval_ms, 500)


func _check_bandit_gold_damage(rogue: ClassDef) -> void:
	var bandit: GearItem = load("res://data/gear/bandit_blade.tres")
	_require("Bandit Blade loads", bandit != null)
	var no_gold_stats := BuildResolver.resolve_stats(rogue, [], [], [bandit], 0)
	var gold_stats := BuildResolver.resolve_stats(rogue, [], [], [bandit], 100)
	_require_approx("Bandit stat package physical", gold_stats.gear_physical_damage_multiplier, 1.2)
	_require_approx("Bandit stat package crit", gold_stats.crit_chance, 0.17)
	_require_approx("Bandit stat package gold", gold_stats.gold_reward_multiplier, 1.3)
	_require_approx("Bandit no gold bonus", no_gold_stats.bonus_physical_damage, 0.0)
	_require_approx("Bandit 100g bonus", gold_stats.bonus_physical_damage, 10.0)

	no_gold_stats.crit_chance = 0.0
	gold_stats.crit_chance = 0.0
	var no_gold := CombatResolver.resolve([_physical_skill()], no_gold_stats, _target(), 1000, 12)
	var with_gold := CombatResolver.resolve([_physical_skill()], gold_stats, _target(), 1000, 12)
	_require("Bandit gold adds combat damage", with_gold.cast_events[0].physical_damage > no_gold.cast_events[0].physical_damage)


func _check_umbral_death_strike_unlock_and_use(rogue: ClassDef) -> void:
	var umbral: GearItem = load("res://data/gear/umbral_stiletto.tres")
	_require("Umbral Stiletto loads", umbral != null)
	var stats := BuildResolver.resolve_stats(rogue, [], [], [umbral])
	_require_approx("Umbral crit package", stats.crit_chance, 0.15)
	_require_approx("Umbral crit damage package", stats.crit_multiplier, 3.0)
	_require_approx("Umbral crit poison package", stats.elemental_proc_chance, 1.0)

	var unlocked := BuildResolver.resolve_unlocked_skills(rogue, [], [], [umbral])
	var death_strike := _find_skill(unlocked, CombatResolver.DEATH_STRIKE_SKILL_ID)
	_require("Umbral unlocks Death Strike", death_strike != null)
	var result := CombatResolver.resolve([death_strike], stats, _target(), 1600, 13)
	_require("Umbral Death Strike casts", result.cast_events.size() > 0)
	_require("Umbral Death Strike uses Legendary weapon roll", _has_weapon_roll_from(result, umbral.id))


func _check_mithril_source_filtered_retriggers(rogue: ClassDef) -> void:
	var mithril: GearItem = load("res://data/gear/mithril_karambit.tres")
	var stab: Skill = load("res://data/skills/stab.tres")
	var heavy: Skill = load("res://data/skills/heavy_slash.tres")
	_require("Mithril Karambit loads", mithril != null)
	_require("Mithril source skills load", stab != null and heavy != null)
	var stats := BuildResolver.resolve_stats(rogue, [], [], [mithril])
	_require_approx("Mithril speed package", stats.attack_speed, 0.15)
	_require_approx("Mithril crit package", stats.crit_chance, 0.20)
	_require_approx("Mithril shred chance package", stats.shred_chance, 0.20)
	_require_equal("Mithril trigger count", stats.triggered_skill_effects.size(), 2)
	for trigger in stats.triggered_skill_effects:
		trigger.chance = 1.0

	var result := CombatResolver.resolve([stab, heavy], stats, _target(), 5000, 14)
	_require("Mithril emits proc casts", result.cast_events.any(func(event): return event.cast_kind == "proc"))
	for event in result.cast_events:
		if event.cast_kind != "proc":
			continue
		if event.trigger_source_skill_id == "skill.stab":
			_require_equal("Mithril Stab proc remains Stab", event.skill.id, "skill.stab")
		elif event.trigger_source_skill_id == "skill.heavy_slash":
			_require_equal("Mithril Heavy Slash proc remains Heavy Slash", event.skill.id, "skill.heavy_slash")
		else:
			_require("Mithril proc records source", false)


func _check_bejeweled_min_cast_time_proc(rogue: ClassDef) -> void:
	var bejeweled: GearItem = load("res://data/gear/bejeweled_push_dagger.tres")
	_require("Bejeweled Push Dagger loads", bejeweled != null)
	var stats := BuildResolver.resolve_stats(rogue, [], [], [bejeweled])
	_require_approx("Bejeweled base damage package", stats.bonus_physical_damage, 8.0)
	_require_approx("Bejeweled physical package", stats.gear_physical_damage_multiplier, 1.2)
	_require_approx("Bejeweled crit package", stats.crit_chance, 0.15)
	_require_approx("Bejeweled proc metadata", stats.min_cast_time_proc_chance, 0.2)

	stats.min_cast_time_proc_chance = 1.0
	var result := CombatResolver.resolve([_slow_skill()], stats, _target(), 1000, 15)
	_require_equal("Bejeweled forced proc cast count", result.cast_events.size(), 2)
	for event in result.cast_events:
		_require("Bejeweled cast uses minimum time", event.min_cast_time_proc_applied)
		_require_equal("Bejeweled forced proc timing", event.time_ms % 500, 0)


func _target() -> Monster:
	var monster := Monster.new()
	monster.display_name = "P5M10 Target"
	monster.hp = 1000000
	monster.armor = 0
	monster.poison_resistance = 0.0
	return monster


func _physical_skill() -> Skill:
	var skill := Skill.new()
	skill.id = "skill.p5m10_physical"
	skill.display_name = "P5M10 Physical"
	skill.base_execution_ms = 500
	skill.min_execution_ms = 250
	var effect := PhysicalDamageEffect.new()
	effect.amount = 10.0
	skill.effects = [effect]
	return skill


func _poison_skill() -> Skill:
	var skill := Skill.new()
	skill.id = "skill.p5m10_poison"
	skill.display_name = "P5M10 Poison"
	skill.base_execution_ms = 100
	skill.min_execution_ms = 100
	var effect := PoisonDamageEffect.new()
	effect.stacks_applied = 1
	skill.effects = [effect]
	return skill


func _slow_skill() -> Skill:
	var skill := _physical_skill()
	skill.id = "skill.p5m10_slow"
	skill.display_name = "P5M10 Slow"
	skill.base_execution_ms = 2000
	skill.min_execution_ms = 500
	return skill


func _find_skill(skills: Array[Skill], skill_id: String) -> Skill:
	for skill in skills:
		if skill != null and skill.id == skill_id:
			return skill
	return null


func _has_weapon_roll_from(result: CombatResolver.CombatResult, weapon_id: String) -> bool:
	for event in result.cast_events:
		for roll in event.weapon_damage_rolls:
			if String(roll.get("weapon_id", "")) == weapon_id:
				return true
	return false


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


func _require_approx(label: String, actual: float, expected: float, tolerance: float = 0.001) -> void:
	if absf(actual - expected) <= tolerance:
		return
	_failed = true
	print("FAILED: %s" % label)
	print("  expected: %.4f" % expected)
	print("  actual:   %.4f" % actual)
