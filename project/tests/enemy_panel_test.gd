extends SceneTree
## Focused P2:R7:T5 check for the enemy panel's pre-fight target-pressure
## readout: required DPS (HP / fight-window-seconds), armor/poison
## resistance display, the known-reward preview shown before the fight (not
## only via the post-fight claim UI), and the data-derived "why this target
## pressures certain builds" line across a low-pressure Tavern target, a
## Gilded Serpent route target, and the Vyra boss's real stat block
## (600 HP / 160 armor / 35% poison resist / 30s window). Same headless-only
## caveat as every prior UI milestone -- no rendered click-through available
## in this environment.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var enemy_panel = combat_screen.find_child("EnemyPanel", true, false)
	_require(enemy_panel != null, "Expected to find EnemyPanel in combat_screen.")

	# -- Pure-helper checks: required DPS math for a known monster/window --
	print("required DPS helper checks")
	var mouthy_drunk: Monster = load("res://data/monsters/mouthy_drunk.tres")
	_require(
		enemy_panel._required_dps_text(mouthy_drunk, 12000) == "Required DPS: 12.5",
		"Expected 150 HP / 12s = 12.5 required DPS, got: %s" % enemy_panel._required_dps_text(mouthy_drunk, 12000)
	)
	var vyra: Monster = load("res://data/monsters/vyra.tres")
	_require(vyra.hp == 600 and vyra.armor == 160 and is_equal_approx(vyra.poison_resistance, 0.35), "Expected Vyra's authored stat block (600/160/35%%), got hp=%d armor=%d resist=%.2f" % [vyra.hp, vyra.armor, vyra.poison_resistance])
	_require(
		enemy_panel._required_dps_text(vyra, 30000) == "Required DPS: 20.0",
		"Expected 600 HP / 30s = 20.0 required DPS, got: %s" % enemy_panel._required_dps_text(vyra, 30000)
	)
	_require(enemy_panel._required_dps_text(null, 12000) == "Required DPS: NONE", "Expected NONE for a null monster.")
	_require(enemy_panel._required_dps_text(mouthy_drunk, 0) == "Required DPS: NONE", "Expected NONE for a zero window.")

	# -- Pure-helper checks: the build-pressure line differs by real stats --
	print("build-pressure helper checks")
	_require(
		enemy_panel._build_pressure_text(mouthy_drunk) == "Pressure: No notable defensive pressure.",
		"Expected no-pressure line for 0 armor/0%% resist Mouthy Drunk, got: %s" % enemy_panel._build_pressure_text(mouthy_drunk)
	)
	_require(
		enemy_panel._build_pressure_text(vyra) == "Pressure: Heavy armor and poison resistance -- physical and poison builds both struggle.",
		"Expected the armor+poison pressure line for Vyra, got: %s" % enemy_panel._build_pressure_text(vyra)
	)
	var armor_only := Monster.new()
	armor_only.armor = 160
	armor_only.poison_resistance = 0.0
	_require(
		enemy_panel._build_pressure_text(armor_only) == "Pressure: Heavy armor -- physical builds struggle here.",
		"Expected armor-only pressure line, got: %s" % enemy_panel._build_pressure_text(armor_only)
	)
	var poison_only := Monster.new()
	poison_only.armor = 0
	poison_only.poison_resistance = 0.65
	_require(
		enemy_panel._build_pressure_text(poison_only) == "Pressure: High poison resistance -- poison builds struggle here.",
		"Expected poison-resist-only pressure line, got: %s" % enemy_panel._build_pressure_text(poison_only)
	)

	# -- Live scene check: Tavern (Mouthy Drunk) shows HP/required DPS/armor/
	# poison resist/window/reward/pressure all together, before any fight --
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
	_require(text.contains("Required DPS: 12.5"), "Expected Mouthy Drunk's required DPS.")
	_require(text.contains("Armor: 0"), "Expected Mouthy Drunk's armor.")
	_require(text.contains("Poison Resist: 0%"), "Expected Mouthy Drunk's poison resist.")
	_require(text.contains("Window: 12s"), "Expected Mouthy Drunk's fight window.")
	_require(text.contains("Reward: 12g, 1 talent point"), "Expected Mouthy Drunk's authored reward preview before the fight.")
	_require(text.contains("Pressure: No notable defensive pressure."), "Expected the no-pressure line for Mouthy Drunk.")
	_require(not build_state.build_locked, "Reward preview must be visible before locking/fighting, not only after.")

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
	_require(vyra_text.contains("Required DPS: 20.0"), "Expected Vyra's required DPS.")
	_require(vyra_text.contains("Armor: 160"), "Expected Vyra's armor.")
	_require(vyra_text.contains("Poison Resist: 35%"), "Expected Vyra's poison resist.")
	_require(vyra_text.contains("Window: 30s"), "Expected Vyra's fight window.")
	_require(vyra_text.contains("Reward: 120g"), "Expected Vyra's authored reward preview before the fight.")
	_require(vyra_text.contains("Pressure: Heavy armor and poison resistance -- physical and poison builds both struggle."), "Expected Vyra to be flagged as armor-heavy/poison-resistant.")

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
	_require(cloaked_text.contains("Required DPS: 20.2"), "Expected Cloaked Watchmen required DPS.")
	_require(cloaked_text.contains("Armor: 160"), "Expected Cloaked Watchmen armor.")
	_require(cloaked_text.contains("Poison Resist: 40%"), "Expected Cloaked Watchmen poison resist.")
	_require(cloaked_text.contains("Window: 26s"), "Expected Cloaked Watchmen fight window.")
	_require(cloaked_text.contains("Reward: 1 talent point, Cursed Gear"), "Expected Cloaked Watchmen Cursed gear reward preview.")
	_require(cloaked_text.contains("Pressure: Heavy armor and poison resistance -- physical and poison builds both struggle."), "Expected Cloaked Watchmen pressure line.")

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
