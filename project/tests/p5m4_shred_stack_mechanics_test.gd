extends SceneTree

var _failed := false


func _initialize() -> void:
	_check_bladedancer_talent_values()
	_check_base_shred_stack_value()
	_check_chance_to_shred_applies_bonus_stacks()
	_check_rending_slash_applies_bonus_stacks()
	_check_rending_slash_applies_doubled_bonus_stacks()
	_check_bonus_shred_value_changes_armor_reduction()
	_check_cleanse_resets_shred()
	_check_opportunity_and_retrigger_share_proc_chain()
	_check_hold_does_not_proc_shred_or_retrigger()
	if _failed:
		print("P5M4 Shred stack mechanics check: FAILED")
		quit(1)
		return
	print("P5M4 Shred stack mechanics check: OK")
	quit()


func _check_bladedancer_talent_values() -> void:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var bladedancer: SubclassTree = load("res://data/subclass_trees/bladedancer.tres")
	var quick_hands: Talent = load("res://data/talents/bladedancer/quick_hands.tres")
	var piercing_blades: Talent = load("res://data/talents/bladedancer/piercing_blades.tres")
	var practiced_rhythm: Talent = load("res://data/talents/bladedancer/practiced_rhythm.tres")
	var sunder: Talent = load("res://data/talents/bladedancer/sunder.tres")
	_require_equal("Quick Hands attack speed", quick_hands.stat_modifiers[0].value, 0.1)
	var rhythm_stats := BuildResolver.resolve_stats(rogue, [bladedancer], [practiced_rhythm])
	_require_approx("Practiced Rhythm physical damage", rhythm_stats.talent_physical_damage_multiplier, 1.1, 0.001)
	_require_approx("Practiced Rhythm retrigger chance", rhythm_stats.retrigger_chance, 0.1, 0.001)
	_require_approx("Practiced Rhythm no attack speed", rhythm_stats.attack_speed, 0.0, 0.001)
	var piercing_stats := BuildResolver.resolve_stats(rogue, [bladedancer], [piercing_blades])
	_require_equal("Piercing Blades Shred value", piercing_stats.shred_value, 30)
	var sunder_stats := BuildResolver.resolve_stats(rogue, [bladedancer], [piercing_blades, practiced_rhythm, load("res://data/talents/bladedancer/opportunity_strikes.tres"), sunder])
	_require_equal("Sunder Shred value", sunder_stats.shred_value, 50)
	_require_equal("Sunder bonus Shred stacks", sunder_stats.bonus_shred_stacks, 5)


func _check_base_shred_stack_value() -> void:
	var player := _player()
	var monster := _monster(50)
	var skill := _direct_attack("skill.test.shred.base", "Base Shred")
	var shred := ArmorReductionEffect.new()
	shred.amount = 1
	skill.effects.append(shred)
	var result := CombatResolver.resolve([skill], player, monster, 1000, 11)
	_require_equal("one Shred stack", result.cast_events[0].shred_stacks_applied, 1)
	_require_equal("base Shred armor reduction", result.cast_events[0].armor_reduction_applied, 10)
	_require_equal("final armor after base Shred", _final_armor(result, monster), 40)


func _check_chance_to_shred_applies_bonus_stacks() -> void:
	var player := _player()
	player.shred_chance = 1.0
	player.bonus_shred_stacks = 2
	var monster := _monster(80)
	var result := CombatResolver.resolve([_direct_attack("skill.test.shred.chance", "Chance Shred")], player, monster, 1000, 13)
	_require_equal("chance Shred includes bonus stacks", result.cast_events[0].shred_stacks_applied, 3)
	_require_equal("chance Shred armor reduction", result.cast_events[0].armor_reduction_applied, 30)
	_require_equal("chance Shred final armor", _final_armor(result, monster), 50)


func _check_rending_slash_applies_bonus_stacks() -> void:
	var player := _player()
	player.bonus_shred_stacks = 2
	var monster := _monster(80)
	var rending_slash: Skill = load("res://data/skills/rending_slash.tres")
	var result := CombatResolver.resolve([rending_slash], player, monster, rending_slash.base_execution_ms, 31)
	_require_equal("Rending Slash includes bonus Shred stacks", result.cast_events[0].shred_stacks_applied, 4)
	_require_equal("Rending Slash bonus Shred armor reduction", result.cast_events[0].armor_reduction_applied, 40)
	_require_equal("Rending Slash bonus Shred final armor", _final_armor(result, monster), 40)


func _check_rending_slash_applies_doubled_bonus_stacks() -> void:
	var player := _player()
	player.bonus_shred_stacks = 2
	player.special_effects = {"double_applied_stacks": true}
	var monster := _monster(80)
	var rending_slash: Skill = load("res://data/skills/rending_slash.tres")
	var result := CombatResolver.resolve([rending_slash], player, monster, rending_slash.base_execution_ms, 37)
	_require_equal("Rending Slash doubled Shred stacks", result.cast_events[0].shred_stacks_applied, 8)
	_require_equal("Rending Slash doubled Shred armor reduction", result.cast_events[0].armor_reduction_applied, 80)
	_require_equal("Rending Slash doubled Shred final armor", _final_armor(result, monster), 0)


func _check_bonus_shred_value_changes_armor_reduction() -> void:
	var player := _player()
	player.shred_value = 20
	player.shred_chance = 1.0
	var monster := _monster(80)
	var result := CombatResolver.resolve([_direct_attack("skill.test.shred.value", "Value Shred")], player, monster, 1000, 17)
	_require_equal("bonus Shred applies one stack", result.cast_events[0].shred_stacks_applied, 1)
	_require_equal("bonus Shred value armor reduction", result.cast_events[0].armor_reduction_applied, 20)
	_require_equal("bonus Shred final armor", _final_armor(result, monster), 60)


func _check_cleanse_resets_shred() -> void:
	var player := _player()
	player.shred_chance = 1.0
	var monster := _monster(80)
	monster.cleanse_threshold = 2
	var result := CombatResolver.resolve([_direct_attack("skill.test.shred.cleanse", "Cleanse Shred")], player, monster, 2000, 19)
	_require_equal("two casts before cleanse", result.cast_events.size(), 2)
	_require("second cast cleanses", result.cast_events[1].cleanse_triggered)
	_require_equal("cleanse resets final armor", _final_armor(result, monster), 80)


func _check_opportunity_and_retrigger_share_proc_chain() -> void:
	var player := _player()
	player.retrigger_chance = 1.0
	var quick_cut: Skill = load("res://data/skills/quick_cut.tres")
	var rending_slash: Skill = load("res://data/skills/rending_slash.tres")
	var trigger := TriggeredSkillEffect.new()
	trigger.skill = rending_slash
	trigger.chance = 1.0
	trigger.source_skill_ids = PackedStringArray(["skill.quick_cut"])
	player.triggered_skill_effects = [trigger]
	var result := CombatResolver.resolve([quick_cut], player, _monster(100), quick_cut.base_execution_ms, 29)
	_require("Opportunity proc produced Rending Slash", result.cast_events.any(func(event): return event.skill.id == "skill.rending_thrust" and event.cast_kind == "proc"))
	_require("Retrigger proc produced Quick Cut", result.cast_events.any(func(event): return event.skill.id == "skill.quick_cut" and event.cast_kind == "proc"))
	_require("Proc chain reaches technical cap", result.cast_events.any(func(event): return event.retrigger_cap_reached))


func _check_hold_does_not_proc_shred_or_retrigger() -> void:
	var player := _player()
	player.shred_chance = 1.0
	player.retrigger_chance = 1.0
	var hold := Skill.new()
	hold.id = "skill.hold"
	hold.display_name = "Hold"
	hold.base_execution_ms = 100
	var monster := _monster(80)
	var result := CombatResolver.resolve([hold], player, monster, 500, 23)
	for event in result.cast_events:
		_require_equal("Hold applies no Shred", event.shred_stacks_applied, 0)
		_require("Hold triggers no proc names", event.triggered_skill_names.is_empty())


func _player() -> PlayerStats:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 1.0
	player.weapon_damage_min = 1
	player.weapon_damage_max = 1
	return player


func _monster(armor: int) -> Monster:
	var monster := Monster.new()
	monster.display_name = "Shred Dummy"
	monster.hp = 100000
	monster.armor = armor
	monster.poison_resistance = 0.0
	return monster


func _direct_attack(id: String, display_name: String) -> Skill:
	var skill := Skill.new()
	skill.id = id
	skill.display_name = display_name
	skill.base_execution_ms = 1000
	var damage := PhysicalDamageEffect.new()
	damage.amount = 1.0
	skill.effects.append(damage)
	return skill


func _final_armor(result: CombatResolver.CombatResult, monster: Monster) -> int:
	var armor := monster.armor
	for event in result.cast_events:
		armor -= event.armor_reduction_applied
		if event.cleanse_triggered:
			armor = monster.armor
	return armor


func _require(label: String, condition: bool) -> void:
	if condition:
		return
	_failed = true
	print("FAILED: %s" % label)


func _require_equal(label: String, actual: Variant, expected: Variant) -> void:
	_require("%s expected %s got %s" % [label, str(expected), str(actual)], actual == expected)


func _require_approx(label: String, actual: float, expected: float, tolerance: float) -> void:
	_require("%s expected %.4f got %.4f" % [label, expected, actual], absf(actual - expected) <= tolerance)
