extends SceneTree
## Focused check for the enemy panel's pre-fight combat-stat readout: the
## dashboard enemy card is the single place for target combat information,
## ordered as HP/window, physical defenses, magical defenses, and control
## mechanics. Same headless-only caveat as every prior UI milestone -- no
## rendered click-through available in this environment.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var enemy_panel = combat_screen.find_child("EnemyPanel", true, false)
	_require(enemy_panel != null, "Expected to find EnemyPanel in combat_screen.")

	var mouthy_drunk: Monster = load("res://data/monsters/mouthy_drunk.tres")
	var vyra: Monster = load("res://data/monsters/vyra.tres")
	_require(vyra.hp == 600 and vyra.armor == 160 and is_equal_approx(vyra.poison_resistance, 0.35), "Expected Vyra's authored stat block (600/160/35%%), got hp=%d armor=%d resist=%.2f" % [vyra.hp, vyra.armor, vyra.poison_resistance])

	print("combat-stat helper ordering")
	var full_stats := Monster.new()
	full_stats.hp = 1234
	full_stats.armor = 12
	full_stats.block = 4.5
	full_stats.dodge_chance = 0.13
	full_stats.crit_negation = 0.27
	full_stats.slow = 0.08
	full_stats.poison_resistance = 0.35
	full_stats.absorb = 7.5
	full_stats.suppress = 0.2
	full_stats.cleanse_threshold = 4
	full_stats.stun_duration_ms = 1500
	full_stats.interrupt_skip_count = 2
	var expected_full_text := "\n".join(PackedStringArray([
		"HP: 1234",
		"Fight Window: 28s",
		"",
		"Armor: 12",
		"Block: 4.5",
		"Dodge: 13%",
		"Crit Negation: 27%",
		"Slow: 8%",
		"",
		"[color=#%s]Resistance: 35%%[/color]" % UIColors.TEXT_MAGIC.to_html(false),
		"Absorb: 7.5",
		"Suppress: 20%",
		"",
		"Cleanse: 4 hits",
		"Stun: 12%/1.5s",
		"Interrupt: 3 / 2",
	]))
	_require(
		enemy_panel._enemy_combat_info_text(full_stats, 28000) == expected_full_text,
		"Expected full enemy combat stat block in requested order, got:\n%s" % enemy_panel._enemy_combat_info_text(full_stats, 28000)
	)

	# -- Live scene check: Tavern (Mouthy Drunk) shows the full combat-stat
	# block before any fight, without reward/attempt/pressure clutter. --
	print("live Tavern encounter panel text")
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.choose_current_tavern_encounter()
	await process_frame
	var text: String = enemy_panel._info_label.text
	print(text)
	_require(enemy_panel._title_label.text == "Mouthy Drunk", "Expected Mouthy Drunk as the live panel title.")
	_require(not text.contains("Target:"), "Expected target name to live in the panel title, not the stat body.")
	_require(not text.contains("Encounter:"), "Expected Tavern encounter count to be omitted from the enemy panel body.")
	_require(text.contains("HP: 150"), "Expected Mouthy Drunk's HP.")
	_require(not text.contains("Damage Goal:"), "Expected no Damage Goal line.")
	_require(text.contains("Fight Window: 12s"), "Expected Mouthy Drunk's fight window.")
	_require(text.contains("Armor: 0"), "Expected Mouthy Drunk's armor.")
	_require(text.contains("Resistance: 0%"), "Expected Mouthy Drunk's resistance.")
	_require(not text.contains("Block:"), "Expected zero Block to stay hidden.")
	_require(not text.contains("Dodge:"), "Expected zero Dodge to stay hidden.")
	_require(not text.contains("Crit Negation:"), "Expected zero Crit Negation to stay hidden.")
	_require(not text.contains("Slow:"), "Expected zero Slow to stay hidden.")
	_require(not text.contains("Absorb:"), "Expected zero Absorb to stay hidden.")
	_require(not text.contains("Suppress:"), "Expected zero Suppress to stay hidden.")
	_require(not text.contains("Cleanse:"), "Expected zero Cleanse to stay hidden.")
	_require(not text.contains("Stun:"), "Expected zero Stun to stay hidden.")
	_require(not text.contains("Interrupt:"), "Expected zero Interrupt to stay hidden.")
	_require(not text.contains("Attempts:"), "Expected attempts to move out of the enemy combat stat body.")
	_require(not text.contains("Reward:"), "Expected reward to move out of the enemy combat stat body.")
	_require(not text.contains("Pressure:"), "Expected pressure summary to move out of the enemy combat stat body.")

	# -- Live scene check: the Vyra boss route node (P2:R7:T1's explicit
	# "Boss (Vyra)" reachable state) shows her real stat block and correctly
	# flags her as armor-heavy/poison-resistant --
	print("live Vyra boss panel text")
	var contract: ContractDef = load("res://data/contracts/the_gilded_serpent.tres")
	var vyra_node := _find_route_node(contract.offer_node, "route.gilded_serpent.vyra")
	_require(vyra_node != null, "Expected to find the Vyra route node.")
	build_state.active_contract = contract
	build_state.current_route_node = vyra_node
	build_state.run_phase = BuildState.RunPhase.PLANNING
	build_state.build_changed.emit()
	await process_frame
	var vyra_text: String = enemy_panel._info_label.text
	print(vyra_text)
	_require(enemy_panel._title_label.text == "Vyra", "Expected Vyra as the live panel title.")
	_require(not vyra_text.contains("Target:"), "Expected target name to live in the panel title, not the stat body.")
	_require(vyra_text.contains("HP: 600"), "Expected Vyra's HP.")
	_require(not vyra_text.contains("Damage Goal:"), "Expected no Damage Goal line.")
	_require(vyra_text.contains("Fight Window: 30s"), "Expected Vyra's fight window.")
	_require(vyra_text.contains("Armor: 160"), "Expected Vyra's armor.")
	_require(vyra_text.contains("Resistance: 35%"), "Expected Vyra's resistance.")
	_require(not vyra_text.contains("Cleanse:"), "Expected zero Vyra cleanse to stay hidden.")
	_require(not vyra_text.contains("Stun:"), "Expected zero Vyra stun to stay hidden.")
	_require(not vyra_text.contains("Interrupt:"), "Expected zero Vyra interrupt to stay hidden.")
	_require(not vyra_text.contains("Attempts:"), "Expected attempts to be omitted from Vyra stat body.")
	_require(not vyra_text.contains("Reward:"), "Expected reward to be omitted from Vyra stat body.")
	_require(not vyra_text.contains("Pressure:"), "Expected pressure to be omitted from Vyra stat body.")
	build_state.run_phase = BuildState.RunPhase.RUN_ENDED
	build_state.run_state_changed.emit()
	await process_frame
	_require(enemy_panel._title_label.text == "Vyra", "Expected run-ended enemy panel to keep showing enemy info, not a status title.")
	_require(enemy_panel._info_label.text.contains("HP: 600"), "Expected run-ended enemy panel to keep showing enemy stats.")
	_require(not enemy_panel._info_label.text.contains("This Adventure has ended."), "Expected run-ended state to avoid replacing enemy info with a status message.")

	print("live Cloaked Watchmen route panel text")
	var cloaked_node := _find_route_node(contract.offer_node, "route.gilded_serpent.cloaked_watchmen")
	_require(cloaked_node != null, "Expected to find the Cloaked Watchmen route node.")
	build_state.current_route_node = cloaked_node
	build_state.run_phase = BuildState.RunPhase.PLANNING
	build_state.run_state_changed.emit()
	await process_frame
	var cloaked_text: String = enemy_panel._info_label.text
	print(cloaked_text)
	_require(enemy_panel._title_label.text == "Cloaked Watchmen", "Expected Cloaked Watchmen as the live panel title.")
	_require(cloaked_text.contains("HP: 525"), "Expected Cloaked Watchmen HP.")
	_require(not cloaked_text.contains("Damage Goal:"), "Expected no Damage Goal line.")
	_require(cloaked_text.contains("Fight Window: 26s"), "Expected Cloaked Watchmen fight window.")
	_require(cloaked_text.contains("Armor: 160"), "Expected Cloaked Watchmen armor.")
	_require(cloaked_text.contains("Resistance: 40%"), "Expected Cloaked Watchmen resistance.")
	_require(not cloaked_text.contains("Cleanse:"), "Expected zero Cloaked Watchmen cleanse to stay hidden.")
	_require(not cloaked_text.contains("Stun:"), "Expected zero Cloaked Watchmen stun to stay hidden.")
	_require(not cloaked_text.contains("Interrupt:"), "Expected zero Cloaked Watchmen interrupt to stay hidden.")
	_require(not cloaked_text.contains("Reward:"), "Expected Cloaked Watchmen reward to be omitted from stat body.")
	_require(not cloaked_text.contains("Pressure:"), "Expected Cloaked Watchmen pressure to be omitted from stat body.")

	print("")
	print("Enemy panel check: OK")
	quit()


func _find_route_node(root_node: ContractRouteNode, id: String) -> ContractRouteNode:
	if root_node == null:
		return null
	if root_node.id == id:
		return root_node
	for child in root_node.next_nodes:
		var found := _find_route_node(child, id)
		if found != null:
			return found
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
