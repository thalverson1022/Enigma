extends SceneTree
## Focused P2:R5:T4 check for visible Adventure seed state.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	assert(build_state.adventure_seed == build_state.DEFAULT_ADVENTURE_SEED)
	print("default adventure seed: %d" % build_state.adventure_seed)

	build_state.set_adventure_seed(12345)
	assert(build_state.adventure_seed == 12345)
	build_state.reset(true)
	assert(build_state.adventure_seed == 12345)
	build_state.reset()
	assert(build_state.adventure_seed == build_state.DEFAULT_ADVENTURE_SEED)

	var quick_cut: Skill = load("res://data/skills/quick_cut.tres")
	assert(quick_cut != null)

	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.5
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 0

	var monster := Monster.new()
	monster.display_name = "Seed Dummy"
	monster.hp = 1000000
	monster.armor = 0
	monster.poison_resistance = 0.0

	var rotation: Array[Skill] = [quick_cut]
	var first_result := CombatResolver.resolve(rotation, player, monster, 10000, 7)
	var second_result := CombatResolver.resolve(rotation, player, monster, 10000, 7)
	assert(_crit_count(first_result) == _crit_count(second_result))
	assert(is_equal_approx(first_result.total_damage, second_result.total_damage))

	var found_different_seed_outcome := false
	for seed in range(8, 64):
		var comparison := CombatResolver.resolve(rotation, player, monster, 10000, seed)
		if _crit_count(comparison) != _crit_count(first_result):
			found_different_seed_outcome = true
			break
	assert(found_different_seed_outcome)

	print("Adventure seed state check: OK")
	quit()


func _crit_count(result: CombatResolver.CombatResult) -> int:
	var count := 0
	for event in result.cast_events:
		if event.is_crit:
			count += 1
	return count
