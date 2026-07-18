extends SceneTree
## Focused P2:R5:T10 check for deterministic combat/proc replay.
##
## Confirms the P2:R5 exit criterion that CombatResolver.resolve() is fully
## reproducible for a given rng_seed (crits, proc rolls, and their ordering),
## and that varying the seed can change the outcome. This is the committed
## regression test flagged as missing by the P2:R5:T9 proc-determinism audit.


func _initialize() -> void:
	_check_basic_combat_replay()
	_check_proc_replay()
	print("Deterministic replay check: OK")
	quit()


func _check_basic_combat_replay() -> void:
	var strike: Skill = load("res://data/skills/placeholder_strike.tres")
	var quick_cut: Skill = load("res://data/skills/placeholder_quick_cut.tres")
	var player: PlayerStats = load("res://data/player/placeholder_player.tres")
	var dummy: Monster = load("res://data/monsters/placeholder_dummy.tres")
	var rotation: Array[Skill] = [strike, quick_cut]

	var first: CombatResolver.CombatResult = CombatResolver.resolve(rotation, player, dummy, 10000, 7)
	var second: CombatResolver.CombatResult = CombatResolver.resolve(rotation, player, dummy, 10000, 7)
	assert(_combat_signature(first) == _combat_signature(second))

	var signatures := {}
	for seed in range(1, 6):
		var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, player, dummy, 10000, seed)
		signatures[_combat_signature(result)] = true
	assert(signatures.size() > 1)


func _check_proc_replay() -> void:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var thief: SubclassTree = load("res://data/subclass_trees/thief.tres")
	var quick_cut: Skill = load("res://data/skills/quick_cut.tres")
	var opportunity: Talent = load("res://data/talents/thief/opportunity_strikes.tres")
	var rotation: Array[Skill] = [quick_cut]

	var monster := Monster.new()
	monster.display_name = "Replay Dummy"
	monster.hp = 1000000
	monster.armor = 0
	monster.poison_resistance = 0.0

	var stats := BuildResolver.resolve_stats(rogue, [thief], [opportunity])
	var first: CombatResolver.CombatResult = CombatResolver.resolve(rotation, stats, monster, 8000, 1)
	var second: CombatResolver.CombatResult = CombatResolver.resolve(rotation, stats, monster, 8000, 1)
	assert(_combat_signature(first) == _combat_signature(second))

	var signatures := {}
	for seed in range(1, 6):
		var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, stats, monster, 8000, seed)
		signatures[_combat_signature(result)] = true
	assert(signatures.size() > 1)


func _combat_signature(result: CombatResolver.CombatResult) -> String:
	var parts: PackedStringArray = []
	for event in result.cast_events:
		parts.append("cast|%d|%s|%.4f|%s|%d|%d|%.4f|%s" % [
			event.time_ms,
			event.skill.id,
			event.physical_damage,
			event.is_crit,
			event.poison_stacks_applied,
			event.armor_reduction_applied,
			event.poison_resistance_reduction_applied,
			",".join(event.triggered_skill_names),
		])
	for tick in result.tick_events:
		parts.append("tick|%d|%.4f|%d" % [tick.time_ms, tick.damage, tick.stacks_remaining])
	return "|".join(parts)
