extends SceneTree
## Focused P4M4-T8 check: route preview surfaces can consume compact
## generated encounter fields without requiring procedural route generation.
## Run with:
##   godot --headless -s res://tests/map_overlay_route_preview_test.gd


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var map_scene: PackedScene = load("res://scenes/combat/map_overlay.tscn")
	var map_overlay = map_scene.instantiate()
	root.add_child(map_overlay)
	await process_frame

	_check_authored_route_text_still_uses_existing_fallback(map_overlay)
	_check_compact_route_preview_text_stays_sparse(map_overlay)
	_check_compact_route_preview_shows_reward_language(map_overlay)
	_check_compact_preview_renders_in_schematic_card(map_overlay)
	_check_generated_layout_offsets_are_deterministic_and_bounded(map_overlay)
	_check_generated_edges_render_as_curves(map_overlay)
	_check_generated_biome_themes_are_renderer_side(map_overlay)
	_check_generated_biome_frames_use_individual_textures_without_layout_growth(map_overlay)
	_check_generated_node_visual_state_metadata(map_overlay)
	_check_generated_edge_visual_states(map_overlay)

	print("Map overlay route preview check: OK")
	quit()


func _check_authored_route_text_still_uses_existing_fallback(map_overlay) -> void:
	var node := _route_node("route.test.authored", "Authored Guard", ContractRouteNode.NodeType.FIGHT)
	node.monster = _monster("Authored Guard", 250, 80, 0.25)
	node.duration_ms = 18000
	node.difficulty_label = "Normal Fight"
	node.reward_quality_label = "Basic Reward"
	assert(not node.has_generated_state())
	assert(node.route_preview.is_empty())
	assert(node.generated_encounter_payload.is_empty())
	assert(node.combat_preview.is_empty())
	assert(node.debug_preview.is_empty())

	var text: String = map_overlay._route_node_button_text(node)
	assert(text.contains("Authored Guard"))
	assert(text.contains("HP 250"))
	assert(text.contains("Armor 80"))
	assert(text.contains("Resist 25%"))
	assert(text.contains("18s"))
	assert(text.contains("Normal Fight"))
	assert(text.contains("Basic Reward"))


func _check_compact_route_preview_text_stays_sparse(map_overlay) -> void:
	var node := _route_node("route.test.generated", "Internal Generated Node", ContractRouteNode.NodeType.ELITE)
	node.monster = _monster("Generated Stat Carrier", 999, 180, 0.65)
	node.duration_ms = 45000
	node.route_preview = {
		"biome": "Bog",
		"monster_name": "Defensive Bogling",
		"archetype_tags": ["armored", "warded"],
		"modifier_label": "Mire Hazard",
		"elite_variant_label": "Null Priest",
		"elite_variant_id": "null_priest",
		"elite_variant_model_version": "p4m8.elite_variants.v1",
		"source_seed": 44004,
		"budget_metadata": {"budget": 120},
		"pressure_metadata": {"required_dps": 999.0},
		"defense_overrides": {"armor": 180},
	}

	var preview: Dictionary = map_overlay._route_node_compact_preview(node)
	assert(preview["biome"] == "Bog")
	assert(preview["monster_name"] == "Defensive Bogling")
	assert(preview["encounter_level"] == "Elite")
	assert(preview["archetype_tags"] == ["armored", "warded"])
	assert(preview["modifier_label"] == "Mire Hazard")
	assert(preview["elite_variant_label"] == "Null Priest")
	assert(not preview.has("source_seed"))
	assert(not preview.has("budget_metadata"))
	assert(not preview.has("pressure_metadata"))
	assert(not preview.has("defense_overrides"))
	assert(not preview.has("elite_variant_id"))
	assert(not preview.has("elite_variant_model_version"))

	var text: String = map_overlay._route_node_button_text(node)
	var lines := text.split("\n")
	assert(not lines.has("Bog"))
	assert(lines[0].contains("Defensive Bogling"))
	assert(text.contains("Defensive Bogling"))
	assert(not text.contains("\nElite\n"))
	assert(text.contains("[center][color=#%s][b]armored + warded[/b][/color][/center]" % UIColors.TEXT_GOLD.to_html(false)))
	assert(not text.contains("Mire Hazard"))
	assert(not text.contains("Null Priest"))
	assert(lines.size() == 2)
	assert(not text.contains("HP"))
	assert(not text.contains("Armor"))
	assert(not text.contains("Resist"))
	assert(not text.contains("45s"))
	assert(not text.contains("44004"))
	assert(not text.contains("budget"))
	assert(not text.contains("pressure"))
	assert(not text.contains("null_priest"))


func _check_compact_route_preview_shows_reward_language(map_overlay) -> void:
	var normal := _generated_preview_node("route.test.normal", ContractRouteNode.NodeType.FIGHT, "Bogling")
	normal.reward_quality_label = "Steady"
	normal.reward = _reward(12, 0, 1, GearItem.Tier.BASIC)
	normal.reward_summary = "Basic gear choice + 12g"

	var hard := _generated_preview_node("route.test.hard", ContractRouteNode.NodeType.CAPTAIN, "Bog Brute")
	hard.reward_quality_label = "Captain"
	hard.reward = _reward(18, 0, 1, GearItem.Tier.BASIC)
	hard.reward_summary = "Basic gear choice + 18g"

	var elite := _generated_preview_node("route.test.elite", ContractRouteNode.NodeType.ELITE, "Bog Knight")
	elite.reward_quality_label = "Elite"
	elite.reward = _reward(28, 1, 2, GearItem.Tier.MASTER)
	elite.reward_summary = "Master gear choice + 1 talent point + 28g"

	var boss := _generated_preview_node("route.test.boss", ContractRouteNode.NodeType.BOSS, "Bog Monarch")
	boss.route_preview["modifier_label"] = "Volatile Route"
	boss.route_preview["boss_variant_label"] = "Apex Bulwark"
	boss.route_preview["boss_variant_id"] = "apex_bulwark"
	boss.reward_quality_label = "Contract Victory"
	boss.reward = _reward(58, 1, 2, GearItem.Tier.CURSED)
	boss.reward_summary = "Cursed gear choice + 1 talent point + 58g"

	var normal_text: String = map_overlay._route_node_button_text(normal)
	var hard_text: String = map_overlay._route_node_button_text(hard)
	var elite_text: String = map_overlay._route_node_button_text(elite)
	var boss_text: String = map_overlay._route_node_button_text(boss)
	assert(not normal_text.contains("Basic gear"))
	assert(not normal_text.contains("12g"))
	assert(not hard_text.contains("Basic gear"))
	assert(not hard_text.contains("18g"))
	assert(not elite_text.contains("Master gear"))
	assert(not elite_text.contains("1 talent point"))
	assert(not elite_text.contains("28g"))
	assert(not boss_text.contains("Cursed gear"))
	assert(not boss_text.contains("1 talent point"))
	assert(not boss_text.contains("58g"))
	assert(boss_text.split("\n").size() <= 2)
	assert(not boss_text.contains("Volatile Route"))
	assert(not boss_text.contains("Apex Bulwark"))
	var enemy_name_font_size: int = map_overlay.GENERATED_ENEMY_NAME_FONT_SIZE
	assert(normal_text.contains("[center][font_size=%d][color=#%s][b]Bogling[/b][/color][/font_size][/center]" % [enemy_name_font_size, UIColors.TEXT_POISON.to_html(false)]))
	assert(hard_text.contains("[center][font_size=%d][color=#%s][b]Bog Brute[/b][/color][/font_size][/center]" % [enemy_name_font_size, UIColors.TIER_MASTER.to_html(false)]))
	assert(elite_text.contains("[center][font_size=%d][color=#%s][b]Bog Knight[/b][/color][/font_size][/center]" % [enemy_name_font_size, UIColors.TIER_LEGENDARY.to_html(false)]))
	assert(boss_text.contains("[center][font_size=%d][color=#%s][b]Bog Monarch[/b][/color][/font_size][/center]" % [enemy_name_font_size, UIColors.TEXT_WARNING.to_html(false)]))
	assert(not normal_text.contains("Steady:"))
	assert(not hard_text.contains("Captain:"))
	assert(not elite_text.contains("Elite:"))
	assert(not boss_text.contains("Contract Victory:"))
	assert(normal_text != elite_text)
	assert(hard_text != normal_text)
	assert(hard_text != elite_text)
	assert(elite_text != boss_text)
	assert(not normal_text.contains("source_seed"))
	assert(not elite_text.contains("pressure_metadata"))
	assert(not boss_text.contains("debug_preview"))
	assert(not boss_text.contains("apex_bulwark"))


func _check_compact_preview_renders_in_schematic_card(map_overlay) -> void:
	var node := _route_node("route.test.generated_boss", "Internal Boss Node", ContractRouteNode.NodeType.BOSS)
	node.route_preview = {
		"biome": "City",
		"monster_name": "Oathbound Captain",
		"archetype_tags": PackedStringArray(["fortified", "devious"]),
		"seed": 77,
		"selected_mechanics": [{"id": "armor"}],
	}
	var canvas := Control.new()
	root.add_child(canvas)
	map_overlay._add_contract_route_button(canvas, node, Vector2.ZERO)
	await process_frame

	var text_block := canvas.find_child("MapTextBlock", true, false) as RichTextLabel
	assert(text_block != null)
	assert(not text_block.text.contains("City"))
	assert(text_block.text.contains("Oathbound Captain"))
	assert(not text_block.text.contains("\nBoss\n"))
	assert(text_block.text.contains("fortified + devious"))
	assert(not text_block.text.contains("seed"))
	assert(not text_block.text.contains("selected_mechanics"))
	assert(not text_block.text.contains("Internal Boss Node"))
	canvas.queue_free()


func _check_generated_layout_offsets_are_deterministic_and_bounded(map_overlay) -> void:
	var nodes: Array[ContractRouteNode] = []
	for index in range(5):
		nodes.append(_generated_layout_node("route.test.market_%d" % index, 1, index, ContractRouteNode.NodeType.FIGHT))
	nodes.append(_generated_layout_node("route.test.left_merge", 2, 1, ContractRouteNode.NodeType.CAPTAIN))
	nodes.append(_generated_layout_node("route.test.right_merge", 2, 3, ContractRouteNode.NodeType.FIGHT))
	nodes.append(_generated_layout_node("route.test.boss", 3, 2, ContractRouteNode.NodeType.BOSS))

	var first: Dictionary = map_overlay._generated_schematic_positions(nodes)
	var second: Dictionary = map_overlay._generated_schematic_positions(nodes)
	assert(first == second)
	for node in nodes:
		var position: Vector2 = first[node]
		assert(position.x >= 0.0)
		assert(position.y >= 0.0)
		assert(position.x + map_overlay.GENERATED_CONTRACT_NODE_SIZE.x <= map_overlay.GENERATED_CONTRACT_MAP_SIZE.x)
		assert(position.y + map_overlay.GENERATED_CONTRACT_NODE_SIZE.y <= map_overlay.GENERATED_CONTRACT_MAP_SIZE.y)
	for i in range(nodes.size()):
		var left := Rect2(first[nodes[i]], map_overlay.GENERATED_CONTRACT_NODE_SIZE)
		for j in range(i + 1, nodes.size()):
			var right := Rect2(first[nodes[j]], map_overlay.GENERATED_CONTRACT_NODE_SIZE)
			assert(not left.intersects(right))
	var opener_nodes := nodes.slice(0, 5)
	assert(first[opener_nodes[1]].x > first[opener_nodes[0]].x + 135.0)
	assert(first[opener_nodes[1]].x < first[opener_nodes[0]].x + 175.0)
	assert(first[opener_nodes[3]].x > first[opener_nodes[2]].x + 135.0)
	assert(first[opener_nodes[3]].x < first[opener_nodes[2]].x + 175.0)
	assert(first[nodes[5]].x > first[opener_nodes[0]].x + 470.0)
	assert(first[nodes[6]].x > first[opener_nodes[0]].x + 470.0)
	assert(first[nodes[7]].x > first[nodes[5]].x)
	assert(first[nodes[7]].x - first[nodes[5]].x < 360.0)

	var split_nodes: Array[ContractRouteNode] = []
	for index in range(4):
		split_nodes.append(_generated_layout_node("route.test.split_start_%d" % index, 1, index, ContractRouteNode.NodeType.FIGHT))
	split_nodes.append(_generated_layout_node("route.test.split_gate_a", 2, 0, ContractRouteNode.NodeType.CAPTAIN))
	split_nodes.append(_generated_layout_node("route.test.split_recovery", 2, 2, ContractRouteNode.NodeType.FIGHT))
	split_nodes.append(_generated_layout_node("route.test.split_final_gate", 3, 1, ContractRouteNode.NodeType.CAPTAIN))
	split_nodes.append(_generated_layout_node("route.test.split_boss", 4, 1, ContractRouteNode.NodeType.BOSS))
	var split_positions: Dictionary = map_overlay._generated_schematic_positions(split_nodes)
	assert(split_positions[split_nodes[1]].x > split_positions[split_nodes[0]].x + 120.0)
	assert(split_positions[split_nodes[1]].x < split_positions[split_nodes[0]].x + 160.0)
	assert(split_positions[split_nodes[3]].x > split_positions[split_nodes[2]].x + 120.0)
	assert(split_positions[split_nodes[3]].x < split_positions[split_nodes[2]].x + 160.0)
	assert(split_positions[split_nodes[4]].x > split_positions[split_nodes[0]].x + 430.0)
	assert(split_positions[split_nodes[5]].x > split_positions[split_nodes[0]].x + 430.0)
	assert(split_positions[split_nodes[6]].x > split_positions[split_nodes[4]].x)
	assert(split_positions[split_nodes[7]].x > split_positions[split_nodes[6]].x)


func _check_generated_edges_render_as_curves(map_overlay) -> void:
	var from_node := _generated_layout_node("route.test.from", 1, 0, ContractRouteNode.NodeType.FIGHT)
	var to_node := _generated_layout_node("route.test.to", 2, 2, ContractRouteNode.NodeType.CAPTAIN)
	var theme: Dictionary = map_overlay._generated_contract_map_theme("Swamp")
	var canvas := Control.new()
	root.add_child(canvas)
	map_overlay._add_generated_map_edge(canvas, from_node, to_node, Vector2(20, 40), Vector2(320, 220), theme)
	await process_frame

	var edge := canvas.find_child("GeneratedRouteEdge", true, false) as Line2D
	assert(edge != null)
	assert(edge.get_meta("edge_kind") == "map_path")
	assert(edge.get_meta("edge_theme") == "swamp")
	assert(edge.get_meta("from_route_node_id") == from_node.id)
	assert(edge.get_meta("to_route_node_id") == to_node.id)
	assert(edge.get_meta("trail_segment_count") > 1)
	assert(edge.get_meta("trail_dash_length") == map_overlay.GENERATED_EDGE_TRAIL_DASH_LENGTH)
	assert(edge.z_index >= 1)
	assert(edge.default_color == map_overlay._generated_map_edge_color("locked", theme))
	var visible_edges := 0
	for edge_node in canvas.find_children("GeneratedRouteEdge", "Line2D", true, false):
		if edge_node.visible:
			visible_edges += 1
	assert(visible_edges > 1)
	assert(canvas.find_children("GeneratedRouteEdgeShadow", "Line2D", true, false).size() > 1)
	assert(canvas.find_child("GeneratedRouteEdgeHighlight", true, false) == null)
	canvas.queue_free()


func _check_generated_biome_themes_are_renderer_side(map_overlay) -> void:
	var biome_ids := {}
	for biome in ["Swamp", "Cave", "Graveyard", "Haunted Forest", "Ruined Keep", "Ancient Ruins"]:
		var theme: Dictionary = map_overlay._generated_contract_map_theme(biome)
		assert(String(theme.get("biome", "")) == biome)
		assert(String(theme.get("id", "")) != "")
		assert(theme.has("background"))
		assert(theme.has("route"))
		assert(theme.has("available"))
		assert(theme.has("selected"))
		assert(theme.has("completed"))
		assert(theme.has("boss"))
		biome_ids[String(theme["id"])] = true
	assert(biome_ids.size() == 6)

	var theme: Dictionary = map_overlay._generated_contract_map_theme("Ancient Ruins")
	var canvas := Control.new()
	root.add_child(canvas)
	map_overlay._apply_generated_contract_map_theme(canvas, theme)
	await process_frame
	assert(canvas.get_meta("generated_map_theme") == "ancient_ruins")
	assert(canvas.get_meta("generated_map_biome") == "Ancient Ruins")
	assert(canvas.find_child("GeneratedMapThemeBackground", true, false) == null)
	assert(canvas.find_child("GeneratedMapThemeWash", true, false) == null)
	assert(canvas.find_child("GeneratedMapBossMood", true, false) == null)
	assert(canvas.find_children("GeneratedMapMoodBand", "", true, false).is_empty())
	canvas.queue_free()


func _check_generated_biome_frames_use_individual_textures_without_layout_growth(map_overlay) -> void:
	var expected_paths := {
		"Graveyard": "res://assets/ui/map/biome_frames/grave_box.png",
		"Swamp": "res://assets/ui/map/biome_frames/swap_box.png",
		"Cave": "res://assets/ui/map/biome_frames/cave_box.png",
		"Haunted Forest": "res://assets/ui/map/biome_frames/forest_box.png",
		"Ruined Keep": "res://assets/ui/map/biome_frames/keep_box.png",
		"Ancient Ruins": "res://assets/ui/map/biome_frames/ruins_box.png",
	}
	var expected_highlight_paths := {
		"Graveyard": "res://assets/ui/map/biome_frames/grave_box_gray.png",
		"Swamp": "res://assets/ui/map/biome_frames/swap_box_gray.png",
		"Cave": "res://assets/ui/map/biome_frames/cave_box_gray.png",
		"Haunted Forest": "res://assets/ui/map/biome_frames/forest_box_gray.png",
		"Ruined Keep": "res://assets/ui/map/biome_frames/keep_box_gray.png",
		"Ancient Ruins": "res://assets/ui/map/biome_frames/ruins_box_gray.png",
	}
	for biome in expected_paths.keys():
		assert(map_overlay.GENERATED_BIOME_FRAME_TEXTURE_PATHS[biome] == expected_paths[biome])
		assert(map_overlay.GENERATED_BIOME_HIGHLIGHT_TEXTURE_PATHS[biome] == expected_highlight_paths[biome])
		var texture: Texture2D = map_overlay._generated_biome_frame_texture(biome)
		assert(texture != null)
		assert(texture.resource_path == expected_paths[biome])

	var node := _generated_preview_node("route.test.frame_graveyard", ContractRouteNode.NodeType.FIGHT, "Restless Ghoul")
	node.route_preview["biome"] = "Graveyard"
	var canvas := Control.new()
	root.add_child(canvas)
	map_overlay._add_contract_route_button(canvas, node, Vector2.ZERO, map_overlay.GENERATED_CONTRACT_NODE_SIZE, map_overlay.GENERATED_MAP_TEXT_INSET, false)
	await process_frame
	var button := _button_for_route_node(canvas, node.id)
	assert(button != null)
	assert(button.custom_minimum_size == map_overlay.GENERATED_CONTRACT_NODE_SIZE)
	assert(button.size == map_overlay.GENERATED_CONTRACT_NODE_SIZE)
	var frame := button.find_child("GeneratedBiomeFrame", true, false) as TextureRect
	assert(frame != null)
	assert(frame.get_meta("biome") == "Graveyard")
	assert(frame.get_meta("texture_path") == expected_paths["Graveyard"])
	assert(frame.get_meta("layout_size") == map_overlay.GENERATED_CONTRACT_NODE_SIZE)
	assert(frame.size == map_overlay.GENERATED_BIOME_FRAME_VISUAL_SIZE)
	assert(frame.position == (map_overlay.GENERATED_CONTRACT_NODE_SIZE - map_overlay.GENERATED_BIOME_FRAME_VISUAL_SIZE) * 0.5)
	assert(frame.mouse_filter == Control.MOUSE_FILTER_IGNORE)
	assert(frame.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	assert(frame.modulate == Color(0.72, 0.72, 0.72, 0.92))
	assert(button.find_child("GeneratedBiomeGlow", true, false) == null)
	var text_block := button.find_child("MapTextBlock", true, false) as RichTextLabel
	assert(text_block != null)
	assert(text_block.size.x == map_overlay.GENERATED_MAP_TEXT_MIN_WIDTH)
	assert(text_block.position.x < 0.0)
	canvas.queue_free()


func _check_generated_node_visual_state_metadata(map_overlay) -> void:
	var canvas := Control.new()
	root.add_child(canvas)

	var normal := _generated_preview_node("route.test.visual_normal", ContractRouteNode.NodeType.FIGHT, "Bogling")
	normal.reward = _reward(12, 0, 1, GearItem.Tier.BASIC)
	map_overlay._add_contract_route_button(canvas, normal, Vector2.ZERO, map_overlay.GENERATED_CONTRACT_NODE_SIZE, map_overlay.GENERATED_MAP_TEXT_INSET, false)

	var elite := _generated_preview_node("route.test.visual_elite", ContractRouteNode.NodeType.ELITE, "Bog Knight")
	elite.reward = _reward(28, 1, 2, GearItem.Tier.MASTER)
	map_overlay._add_contract_route_button(canvas, elite, Vector2(170, 0), map_overlay.GENERATED_CONTRACT_NODE_SIZE, map_overlay.GENERATED_MAP_TEXT_INSET, false)
	var captain := _generated_preview_node("route.test.visual_captain", ContractRouteNode.NodeType.CAPTAIN, "Bog Brute")
	captain.reward = _reward(18, 0, 1, GearItem.Tier.BASIC)
	map_overlay._add_contract_route_button(canvas, captain, Vector2(340, 0), map_overlay.GENERATED_CONTRACT_NODE_SIZE, map_overlay.GENERATED_MAP_TEXT_INSET, false)
	await process_frame

	var normal_button := _button_for_route_node(canvas, normal.id)
	var elite_button := _button_for_route_node(canvas, elite.id)
	var captain_button := _button_for_route_node(canvas, captain.id)
	assert(normal_button != null)
	assert(elite_button != null)
	assert(captain_button != null)
	assert(normal_button.get_meta("route_visual_state") == "locked")
	assert(normal_button.get_meta("route_role") == "normal")
	assert(normal_button.find_child("GeneratedBiomeGlow", true, false) == null)
	var normal_reward_stack := normal_button.find_child("GeneratedRewardStack", true, false) as VBoxContainer
	assert(normal_reward_stack != null)
	assert(normal_reward_stack.find_child("GeneratedGearReward", true, false) != null)
	assert(normal_reward_stack.find_child("GeneratedGoldReward", true, false) != null)
	assert(_generated_reward_amount_texts(normal_reward_stack).has("x 1"))
	assert(_generated_reward_amount_texts(normal_reward_stack).has("12g"))
	assert(normal_reward_stack.find_child("GeneratedRewardIconBacking", true, false) != null)
	var normal_reward_amount := normal_reward_stack.find_child("GeneratedRewardAmount", true, false) as Label
	assert(normal_reward_amount != null)
	assert(normal_reward_amount.get_theme_font_size("font_size") == map_overlay.GENERATED_REWARD_AMOUNT_FONT_SIZE)
	assert(normal_button.find_child("GeneratedRewardCue", true, false) == null)
	assert(normal_button.find_child("GeneratedDangerCue", true, false) == null)
	assert(normal_button.find_child("GeneratedRoleStrip", true, false) == null)
	assert(captain_button.get_meta("route_role") == "captain")
	assert(elite_button.get_meta("route_role") == "elite")
	var elite_reward_stack := elite_button.find_child("GeneratedRewardStack", true, false) as VBoxContainer
	assert(elite_reward_stack != null)
	assert(elite_reward_stack.find_child("GeneratedGearReward", true, false) != null)
	assert(elite_reward_stack.find_child("GeneratedTalentReward", true, false) != null)
	assert(elite_reward_stack.find_child("GeneratedGoldReward", true, false) != null)
	assert(_generated_reward_amount_texts(elite_reward_stack).has("x 2"))
	assert(_generated_reward_amount_texts(elite_reward_stack).has("x 1"))
	assert(_generated_reward_amount_texts(elite_reward_stack).has("28g"))
	assert(elite_button.find_child("GeneratedRewardCue", true, false) == null)
	assert(elite_button.find_child("GeneratedDangerCue", true, false) == null)
	assert(elite_button.find_child("GeneratedRoleStrip", true, false) == null)
	canvas.queue_free()

	var build_state = root.get_node("BuildState")
	build_state.run_phase = BuildState.RunPhase.CONTRACT_ROUTE
	var start := _generated_layout_node("route.test.visual_start", 0, 0, ContractRouteNode.NodeType.START)
	var available := _generated_preview_node("route.test.visual_available", ContractRouteNode.NodeType.FIGHT, "Bog Witch")
	available.reward = _reward(24, 0, 1, GearItem.Tier.BASIC)
	start.next_nodes = [available]
	build_state.current_route_node = start
	var available_canvas := Control.new()
	root.add_child(available_canvas)
	map_overlay._add_contract_route_button(available_canvas, available, Vector2.ZERO, map_overlay.GENERATED_CONTRACT_NODE_SIZE, map_overlay.GENERATED_MAP_TEXT_INSET, false)
	await process_frame
	var available_button := _button_for_route_node(available_canvas, available.id)
	assert(available_button != null)
	assert(available_button.get_meta("route_visual_state") == "available")
	assert(available_button.find_child("ContractAvailablePulse", true, false) == null)
	var available_glow := available_button.find_child("GeneratedBiomeGlow", true, false) as TextureRect
	assert(available_glow != null)
	assert(available_glow.get_meta("route_visual_state") == "available")
	assert(available_glow.get_meta("highlight_style") == "gray_silhouette_texture")
	assert(available_glow.get_meta("texture_path") == map_overlay.GENERATED_BIOME_HIGHLIGHT_TEXTURE_PATHS["Swamp"])
	assert(available_glow.size == map_overlay.GENERATED_BIOME_FRAME_VISUAL_SIZE + map_overlay.GENERATED_BIOME_GLOW_PADDING)
	assert((available_glow.material as ShaderMaterial) != null)
	assert(map_overlay._generated_biome_glow_color("selected").a > 0.90)
	assert(map_overlay._generated_biome_glow_color("selected").a > map_overlay._generated_biome_glow_color("available").a)
	var available_frame := available_button.find_child("GeneratedBiomeFrame", true, false) as TextureRect
	assert(available_frame != null)
	assert(available_frame.modulate == Color.WHITE)
	available_canvas.queue_free()


func _check_generated_edge_visual_states(map_overlay) -> void:
	var build_state = root.get_node("BuildState")
	build_state.run_phase = BuildState.RunPhase.CONTRACT_ROUTE
	var start := _generated_layout_node("route.test.start", 0, 0, ContractRouteNode.NodeType.START)
	var to_node := _generated_layout_node("route.test.available", 1, 1, ContractRouteNode.NodeType.FIGHT)
	to_node.monster = _monster("Generated Stat Carrier", 300, 20, 0.1)
	to_node.duration_ms = 20000
	start.next_nodes = [to_node]
	build_state.current_route_node = start

	var canvas := Control.new()
	root.add_child(canvas)
	map_overlay._add_generated_map_edge(canvas, start, to_node, Vector2(0, 120), Vector2(260, 120))
	await process_frame
	var available_edge := canvas.find_child("GeneratedRouteEdge", true, false) as Line2D
	assert(available_edge != null)
	assert(available_edge.get_meta("edge_visual_state") == "available")
	assert(available_edge.width == map_overlay.GENERATED_EDGE_THICKNESS_ACTIVE)
	assert(canvas.find_child("GeneratedRouteEdgeHighlight", true, false) != null)
	canvas.queue_free()

	map_overlay._pending_contract_route_node = to_node
	var selected_canvas := Control.new()
	root.add_child(selected_canvas)
	var forward_node := _generated_layout_node("route.test.forward", 2, 1, ContractRouteNode.NodeType.FIGHT)
	var alternate_node := _generated_layout_node("route.test.alternate", 1, 2, ContractRouteNode.NodeType.FIGHT)
	to_node.next_nodes = [forward_node]
	start.next_nodes = [to_node, alternate_node]
	map_overlay._add_generated_map_edge(selected_canvas, start, to_node, Vector2(0, 120), Vector2(260, 120))
	map_overlay._add_generated_map_edge(selected_canvas, start, alternate_node, Vector2(0, 120), Vector2(260, 260))
	map_overlay._add_generated_map_edge(selected_canvas, to_node, forward_node, Vector2(260, 120), Vector2(520, 120))
	await process_frame
	var selected_edges := selected_canvas.find_children("GeneratedRouteEdge", "Line2D", true, false)
	assert(selected_edges.size() == 3)
	var selected_step := _edge_for_nodes(selected_edges, start.id, to_node.id)
	var alternate_step := _edge_for_nodes(selected_edges, start.id, alternate_node.id)
	var outgoing_edge := _edge_for_nodes(selected_edges, to_node.id, forward_node.id)
	assert(selected_step != null)
	assert(selected_step.get_meta("edge_visual_state") == "selected")
	assert(selected_step.width == map_overlay.GENERATED_EDGE_THICKNESS_ACTIVE)
	assert(alternate_step != null)
	assert(alternate_step.get_meta("edge_visual_state") == "locked")
	assert(alternate_step.width == map_overlay.GENERATED_EDGE_THICKNESS)
	assert(outgoing_edge != null)
	assert(outgoing_edge.get_meta("edge_visual_state") == "selected")
	assert(outgoing_edge.width == map_overlay.GENERATED_EDGE_THICKNESS_ACTIVE)
	assert(selected_canvas.find_children("GeneratedRouteEdgeHighlight", "", true, false).size() >= 2)
	selected_canvas.queue_free()

	build_state.claimed_route_reward_ids = [start.id, to_node.id]
	build_state.current_route_node = to_node
	map_overlay._pending_contract_route_node = forward_node
	var completed_path_canvas := Control.new()
	root.add_child(completed_path_canvas)
	map_overlay._add_generated_map_edge(completed_path_canvas, start, to_node, Vector2(0, 120), Vector2(260, 120))
	map_overlay._add_generated_map_edge(completed_path_canvas, to_node, forward_node, Vector2(260, 120), Vector2(520, 120))
	await process_frame
	var completed_path_edges := completed_path_canvas.find_children("GeneratedRouteEdge", "Line2D", true, false)
	var completed_step := _edge_for_nodes(completed_path_edges, start.id, to_node.id)
	var selected_forward_step := _edge_for_nodes(completed_path_edges, to_node.id, forward_node.id)
	assert(completed_step != null)
	assert(completed_step.get_meta("edge_visual_state") == "completed")
	assert(completed_step.width == map_overlay.GENERATED_EDGE_THICKNESS_ACTIVE)
	assert(selected_forward_step != null)
	assert(selected_forward_step.get_meta("edge_visual_state") == "selected")
	assert(selected_forward_step.width == map_overlay.GENERATED_EDGE_THICKNESS_ACTIVE)
	assert(completed_path_canvas.find_children("GeneratedRouteEdgeHighlight", "", true, false).size() >= 2)
	completed_path_canvas.queue_free()
	build_state.claimed_route_reward_ids = []
	map_overlay._pending_contract_route_node = null


func _route_node(id: String, display_name: String, node_type: int) -> ContractRouteNode:
	var node := ContractRouteNode.new()
	node.id = id
	node.display_name = display_name
	node.node_type = node_type
	return node


func _generated_layout_node(id: String, depth: int, lane: int, node_type: int) -> ContractRouteNode:
	var node := _route_node(id, id, node_type)
	node.generated_node_id = id.get_slice(".", id.get_slice_count(".") - 1)
	node.depth = depth
	node.lane = lane
	return node


func _button_for_route_node(root_node: Node, route_node_id: String) -> Button:
	for child in root_node.get_children():
		if child is Button and String((child as Button).get_meta("route_node_id", "")) == route_node_id:
			return child as Button
	return null


func _edge_for_nodes(edges: Array[Node], from_id: String, to_id: String) -> Line2D:
	for edge in edges:
		if (
			edge is Line2D
			and String(edge.get_meta("from_route_node_id", "")) == from_id
			and String(edge.get_meta("to_route_node_id", "")) == to_id
		):
			return edge as Line2D
	return null


func _generated_reward_amount_texts(root_node: Node) -> Array[String]:
	var texts: Array[String] = []
	for label in root_node.find_children("GeneratedRewardAmount", "Label", true, false):
		texts.append((label as Label).text)
	return texts


func _generated_frame_rect(position: Vector2, map_overlay) -> Rect2:
	return Rect2(
		position + (map_overlay.GENERATED_CONTRACT_NODE_SIZE - map_overlay.GENERATED_BIOME_FRAME_VISUAL_SIZE) * 0.5,
		map_overlay.GENERATED_BIOME_FRAME_VISUAL_SIZE
	)


func _edge_has_intermediate_curve(points: PackedVector2Array) -> bool:
	if points.size() < 3:
		return false
	var start := points[0]
	var end := points[points.size() - 1]
	for index in range(1, points.size() - 1):
		var point := points[index]
		var progress := inverse_lerp(start.x, end.x, point.x)
		var straight_y := lerpf(start.y, end.y, progress)
		if absf(point.y - straight_y) > 1.0:
			return true
	return false


func _generated_preview_node(id: String, node_type: int, monster_name: String) -> ContractRouteNode:
	var node := _route_node(id, "Internal Generated Node", node_type)
	node.route_preview = {
		"biome": "Bog",
		"monster_name": monster_name,
		"archetype_tags": PackedStringArray(["fortified"]),
		"source_seed": 44004,
		"pressure_metadata": {"required_dps": 999.0},
		"debug_preview": {"budget": 120},
	}
	return node


func _reward(gold: int, talent_points: int, choice_count: int, tier: int) -> EncounterReward:
	var reward := EncounterReward.new()
	reward.gold_amount = gold
	reward.talent_points = talent_points
	reward.generated_gear_choice_count = choice_count
	reward.generated_gear_tier = tier
	reward.generated_gear_slots = [GearItem.SlotType.WEAPON]
	return reward


func _monster(display_name: String, hp: int, armor: int, poison_resistance: float) -> Monster:
	var monster := Monster.new()
	monster.display_name = display_name
	monster.hp = hp
	monster.armor = armor
	monster.poison_resistance = poison_resistance
	return monster
