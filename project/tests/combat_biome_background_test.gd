extends SceneTree


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var contract := ContractDef.new()
	contract.display_name = "Generated Contract"
	build_state.active_contract = contract
	build_state.run_phase = BuildState.RunPhase.PLANNING

	var expected := {
		"Swamp": combat_screen.BIOME_BACKGROUND_TEXTURE_PATHS["Swamp"],
		"Cave": combat_screen.BIOME_BACKGROUND_TEXTURE_PATHS["Cave"],
		"Graveyard": combat_screen.BIOME_BACKGROUND_TEXTURE_PATHS["Graveyard"],
		"Haunted Forest": combat_screen.BIOME_BACKGROUND_TEXTURE_PATHS["Haunted Forest"],
		"Ruined Keep": combat_screen.BIOME_BACKGROUND_TEXTURE_PATHS["Ruined Keep"],
		"Ancient Ruins": combat_screen.BIOME_BACKGROUND_TEXTURE_PATHS["Ancient Ruins"],
	}
	for biome in expected.keys():
		var node := ContractRouteNode.new()
		node.biome = biome
		node.monster = Monster.new()
		node.monster.display_name = "%s Dummy" % biome
		node.duration_ms = 1000
		build_state.current_route_node = node
		combat_screen._update_combat_background()
		assert(combat_screen._tavern_background.visible)
		assert(combat_screen._tavern_background.texture == combat_screen._biome_background_texture(biome))
		assert(combat_screen._tavern_background.texture.get_image().get_size() == Vector2i(1344, 768))
		assert(not combat_screen._tavern_fireplace_overlay.visible)
		assert(not combat_screen._contract_moon_bat_overlay.visible)

	var fallback_node := ContractRouteNode.new()
	fallback_node.monster = Monster.new()
	fallback_node.monster.display_name = "Authored Contract Dummy"
	fallback_node.duration_ms = 1000
	build_state.current_route_node = fallback_node
	contract.selected_biome = ""
	combat_screen._update_combat_background()
	assert(combat_screen._tavern_background.texture == combat_screen.CONTRACT_BACKGROUND_TEXTURE)
	assert(combat_screen._contract_moon_bat_overlay.visible)

	print("Combat biome background check: OK")
	quit()
