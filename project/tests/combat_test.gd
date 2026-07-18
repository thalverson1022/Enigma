extends SceneTree
## Headless P2:M2 combat resolution check. Run with:
##   godot --headless -s res://tests/combat_test.gd
## Rotation and target are placeholder content (armor=0, poison_resist=0) so the
## printed per-event log is hand-verifiable against the formulas in
## docs/Phase 1 Context Docs/Current_Mechanics_Reference.md.


func _initialize() -> void:
	var strike: Skill = load("res://data/skills/placeholder_strike.tres")
	var quick_cut: Skill = load("res://data/skills/placeholder_quick_cut.tres")
	var player: PlayerStats = load("res://data/player/placeholder_player.tres")
	var dummy: Monster = load("res://data/monsters/placeholder_dummy.tres")

	var rotation: Array[Skill] = [strike, quick_cut]
	var duration_ms: int = 10000

	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, player, dummy, duration_ms, 1)

	print("=== P2:M2 Combat Resolution Test ===")
	print("Rotation: %s -> %s (looped)" % [strike.display_name, quick_cut.display_name])
	print("Target: %s (hp=%d armor=%d poison_resist=%.0f%%)" % [
		dummy.display_name, dummy.hp, dummy.armor, dummy.poison_resistance * 100.0
	])
	print("Window: %dms" % duration_ms)
	print("")

	print("-- Casts --")
	for event in result.cast_events:
		print("t=%dms cast=%s physical=%.2f crit=%s poison_stacks+=%d" % [
			event.time_ms, event.skill.display_name, event.physical_damage, event.is_crit, event.poison_stacks_applied
		])

	print("")
	print("-- Poison Ticks --")
	for tick in result.tick_events:
		print("t=%dms damage=%.2f stacks_remaining=%d" % [tick.time_ms, tick.damage, tick.stacks_remaining])

	print("")
	print("-- Summary --")
	print("Total damage: %.2f" % result.total_damage)
	print("DPS: %.2f" % result.dps)
	print("Target HP: %d" % dummy.hp)
	print("Result: %s" % ("WIN" if result.is_win else "LOSS"))

	quit()
