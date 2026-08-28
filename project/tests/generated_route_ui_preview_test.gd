extends SceneTree
## Focused P4M6-T9 check: generated route previews are readable in the real
## Adventure combat/map UI while combat/debug internals stay hidden.

const ContractOfferSourceScript := preload("res://scripts/systems/contract_offer_source.gd")

var _failed := false


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")
	build_state.set_adventure_seed(424242)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_set_basic_rotation(build_state)

	var context: Dictionary = ContractOfferSourceScript.offer_context(
		424242,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Graveyard"]},
		false,
		true
	)
	_require(build_state.start_contract_offer(context), "Expected generated contract offer to start.")
	_require(build_state.accept_contract_offer(), "Expected generated contract offer to accept.")
	_require(build_state.run_phase == BuildState.RunPhase.CONTRACT_ROUTE, "Expected generated route choice phase.")

	combat_screen._show_map_overlay(false)
	await process_frame
	var map_overlay = combat_screen._map_overlay
	_require(map_overlay.visible, "Expected generated route map to be visible.")
	_require(map_overlay._map_contract_back_button.text == "Back", "Expected generated route back button to use compact Back label.")
	_require(map_overlay._map_contract_back_button.visible, "Expected generated route choice map to allow returning to contract offers.")
	_require(map_overlay._map_phase_label.text == _defeat_title_for_boss(build_state.active_contract.target_display_name), "Expected generated route map title to name the boss objective.")
	_require(not map_overlay._map_story_label.text.contains("The Gilded Serpent"), "Expected generated route map flavor to avoid authored contract copy.")
	_require(not map_overlay._map_story_label.text.contains("Enemy pressure and reward quality"), "Expected generated route map flavor to avoid generic mechanical guidance.")
	_require(build_state.current_route_node.node_type == ContractRouteNode.NodeType.START, "Expected generated route to start at start node.")
	_require(build_state.current_route_node.next_nodes.size() >= 1, "Expected generated start node to expose choices.")
	var visible_nodes := _visible_generated_route_nodes(build_state.active_contract.offer_node)
	_require(map_overlay._map_node_buttons.size() == visible_nodes.size(), "Expected map buttons for the full generated route graph.")
	_require(_visible_node_type_count(visible_nodes, ContractRouteNode.NodeType.BOSS) == 1, "Expected generated full map to show boss node.")
	_assert_generated_map_layout(map_overlay)
	var schematic := _generated_route_schematic(map_overlay)
	_require(schematic != null, "Expected generated route schematic canvas.")
	if schematic != null:
		_require(schematic.get_meta("generated_map_theme", "") == "graveyard", "Expected generated route schematic to use the contract biome theme.")
		_require(schematic.get_meta("generated_map_biome", "") == "Graveyard", "Expected generated route schematic to expose the themed biome.")
		_require(schematic.find_child("GeneratedMapThemeBackground", true, false) == null, "Expected generated route schematic to leave biome background color off.")
		_require(schematic.find_child("GeneratedMapBossMood", true, false) == null, "Expected generated route schematic to leave boss mood color off.")
	for node in visible_nodes:
		var button := _button_for_node(map_overlay, node)
		_require(button != null, "Expected visible generated map button for %s." % node.id)
		if node.route_preview.is_empty():
			continue
		_assert_generated_preview_text(_visible_button_text(button), node)

	var first_choice: ContractRouteNode = build_state.current_route_node.next_nodes[0]
	var first_button: Button = _button_for_node(map_overlay, first_choice)
	var preview: Dictionary = first_choice.route_preview
	_require(not preview.is_empty(), "Expected generated route choice to carry sparse preview data.")
	_require(first_button != null and not first_button.disabled, "Expected generated route choice to be selectable.")
	_assert_generated_preview_text(_visible_button_text(first_button), first_choice)
	for node in visible_nodes:
		if build_state.current_route_node.next_nodes.has(node):
			continue
		var future_button := _button_for_node(map_overlay, node)
		_require(future_button == null or future_button.disabled, "Expected non-adjacent generated node %s to be visible but not selectable." % node.id)

	first_button.pressed.emit()
	await process_frame
	_require(not map_overlay._map_proceed_button.disabled, "Expected Proceed to enable after selecting generated route choice.")
	_require(map_overlay._map_story_label.text.contains(first_choice.display_name), "Expected selected generated route story to name the chosen route.")
	_require(map_overlay._map_proceed_button.tooltip_text == "Proceed to %s as your next fight." % first_choice.display_name, "Expected generated route Proceed tooltip to name selected fight.")

	var story_text: String = map_overlay._map_story_label.text
	_assert_no_generated_internals(story_text, first_choice)

	map_overlay._map_proceed_button.pressed.emit()
	await process_frame
	_require(not map_overlay.visible, "Expected generated map to close after route commit.")
	_require(build_state.run_phase == BuildState.RunPhase.PLANNING, "Expected generated route commit to enter planning.")
	_require(build_state.current_route_node == first_choice, "Expected committed generated route node to become current.")
	_require(build_state.current_route_node.monster != null, "Expected committed generated route node to become combat-ready.")
	_require(build_state.current_fight_label() == first_choice.display_name, "Expected generated planning fight label to stay on route node.")
	build_state.set_locked(true)
	_require(build_state.can_start_current_fight(), "Expected generated route fight to be startable after route UI commit.")

	print("")
	if _failed:
		print("Generated route UI preview check: FAILED")
		quit(1)
	else:
		print("Generated route UI preview check: OK")
		quit()


func _assert_generated_preview_text(text: String, node: ContractRouteNode) -> void:
	var preview: Dictionary = node.route_preview
	_require(not text.contains(String(preview.get("biome", ""))), "Expected generated route button to let the biome sprite carry biome identity.")
	_require(text.contains(String(preview.get("monster_name", ""))), "Expected generated route button to show monster name.")
	_require(not text.contains("\nNormal\n"), "Expected generated route button to hide Normal as a separate line.")
	_require(not text.contains("\nCaptain\n"), "Expected generated route button to hide Captain as a separate line.")
	_require(not text.contains("\nHard\n"), "Expected generated route button to hide Hard as a separate line.")
	_require(not text.contains("\nElite\n"), "Expected generated route button to hide Elite as a separate line.")
	_require(not text.contains("\nBoss\n"), "Expected generated route button to hide Boss as a separate line.")
	var tags: Array[String] = _string_array(preview.get("archetype_tags", []))
	_require(not tags.is_empty(), "Expected generated route preview tags.")
	_require(text.contains("[center][color=#%s][b]%s[/b][/color][/center]" % [UIColors.TEXT_GOLD.to_html(false), " + ".join(tags)]), "Expected generated route button to color and bold archetype tags.")
	_require(not text.contains(String(preview.get("modifier_label", ""))), "Expected generated route button to hide modifier labels.")
	_require(not text.contains(String(preview.get("elite_variant_label", ""))), "Expected generated route button to hide elite variant labels.")
	_require(not text.contains(String(preview.get("boss_variant_label", ""))), "Expected generated route button to hide boss variant labels.")
	_require(text.split("\n").size() <= 7, "Expected generated route button text to stay within the compact generated card shape.")
	_require(node.reward != null, "Expected generated route node to carry a materialized reward.")
	_require(not text.contains("%s:" % node.reward_quality_label), "Expected generated route button to omit reward quality qualifier.")
	for reward_part in _compact_reward_summary(node).split(" + "):
		_require(not text.contains(reward_part), "Expected generated route button to move reward text out of the rich text block.")
	_assert_no_generated_internals(text, node)


func _visible_button_text(button: Button) -> String:
	if button == null:
		return ""
	var text_block := button.get_node_or_null("MapTextBlock")
	if text_block is RichTextLabel:
		return (text_block as RichTextLabel).text
	if text_block is Label:
		return (text_block as Label).text
	return button.text


func _assert_no_generated_internals(text: String, node: ContractRouteNode) -> void:
	_require(not text.contains("HP"), "Expected generated map text to hide HP.")
	_require(not text.contains("Armor"), "Expected generated map text to hide armor.")
	_require(not text.contains("Resist"), "Expected generated map text to hide resistance.")
	_require(not text.contains("Seed"), "Expected generated map text to hide seed labels.")
	_require(not text.contains(str(int(node.generated_encounter_payload.get("source_seed", 0)))), "Expected generated map text to hide generated source seed.")
	_require(not text.contains("budget"), "Expected generated map text to hide budget metadata.")
	_require(not text.contains("pressure"), "Expected generated map text to hide pressure metadata.")
	_require(not text.contains("defense_overrides"), "Expected generated map text to hide defense override keys.")
	_require(not text.contains("generated_"), "Expected generated map text to hide generated payload IDs.")
	if node.elite_variant_id != "":
		_require(not text.contains(String(node.elite_variant_id)), "Expected generated map text to hide elite variant IDs.")
	if node.boss_variant_id != "":
		_require(not text.contains(String(node.boss_variant_id)), "Expected generated map text to hide boss variant IDs.")


func _assert_generated_map_layout(map_overlay) -> void:
	var schematic := _generated_route_schematic(map_overlay)
	_require(schematic != null, "Expected generated route schematic canvas.")
	if schematic != null:
		_require(schematic.custom_minimum_size == Vector2(980, 640), "Expected generated route canvas to stay compact while supporting five-wide maps.")
		_assert_generated_route_edges_are_curved(schematic)
	for i in map_overlay._map_node_buttons.size():
		var left_button: Button = map_overlay._map_node_buttons[i]
		var left_rect := Rect2(left_button.position, left_button.custom_minimum_size)
		_require(left_button.custom_minimum_size.is_equal_approx(Vector2(148, 116)), "Expected generated map buttons to use compact readable generated-card sizing.")
		_require(left_button.size.is_equal_approx(Vector2(148, 116)), "Expected generated map button actual size to stay fixed instead of expanding to hidden text, got %s." % left_button.size)
		_require(left_button.text == "", "Expected generated map button to render composed text only, not expand from native Button text.")
		var text_block := left_button.get_node_or_null("MapTextBlock")
		_require(text_block != null, "Expected generated map button to use composed text block.")
		if text_block != null:
			_require(text_block.position == Vector2(-34, 10), "Expected generated map text to center a wider hidden text box over the sprite.")
			_require(text_block.size.x >= 216.0, "Expected generated map text block to be wide enough for longer enemy names.")
		var biome_frame := left_button.find_child("GeneratedBiomeFrame", true, false) as TextureRect
		_require(biome_frame != null, "Expected generated map button to render biome frame art.")
		if biome_frame != null:
			_require(biome_frame.size == Vector2(174, 174), "Expected biome frame to overhang without changing route-node layout.")
			_require(biome_frame.get_meta("layout_size") == Vector2(148, 116), "Expected biome frame metadata to preserve rectangular layout size.")
			_require(biome_frame.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Expected biome frame pixel art to use nearest texture filtering.")
			var visual_state := String(left_button.get_meta("route_visual_state", "locked"))
			var expected_modulate := Color(0.72, 0.72, 0.72, 0.92) if visual_state == "locked" else Color.WHITE
			_require(biome_frame.modulate == expected_modulate, "Expected biome frame art modulation to match route visual state.")
			var biome_glow := left_button.find_child("GeneratedBiomeGlow", true, false) as TextureRect
			if visual_state == "locked":
				_require(biome_glow == null, "Expected locked generated map nodes to avoid highlight glow.")
			else:
				_require(biome_glow != null, "Expected active generated map nodes to use a sprite-shaped outline instead of old boxes.")
				_require(biome_glow.get_meta("highlight_style") == "gray_silhouette_texture", "Expected generated node highlight to use the gray silhouette asset as its shape.")
				_require(String(biome_glow.get_meta("texture_path", "")).ends_with("_gray.png"), "Expected generated node highlight to source a gray silhouette texture.")
				_require((biome_glow.material as ShaderMaterial) != null, "Expected generated node highlight to use the outline shader material.")
			_require(left_button.find_child("ContractAvailablePulse", true, false) == null, "Expected generated map nodes to avoid rectangular available pulse boxes.")
		var reward_stack := left_button.find_child("GeneratedRewardStack", true, false) as VBoxContainer
		_require(reward_stack != null, "Expected generated map button to render compact icon reward stack.")
		if reward_stack != null:
			_require(reward_stack.find_child("GeneratedRewardIconBacking", true, false) != null, "Expected generated reward icons to use readable dark backing.")
			_require(reward_stack.find_child("GeneratedGearReward", true, false) != null, "Expected generated reward stack to show gear icon reward.")
			_require(reward_stack.find_child("GeneratedGoldReward", true, false) != null, "Expected generated reward stack to show gold icon reward.")
		_assert_generated_node_visual_state_metadata(left_button)
		if schematic != null:
			_require(left_rect.position.x >= 0.0, "Expected generated map button to stay inside the canvas horizontally.")
			_require(left_rect.position.y >= 0.0, "Expected generated map button to stay inside the canvas vertically.")
			_require(left_rect.end.x <= schematic.custom_minimum_size.x, "Expected generated map button right edge to stay inside the canvas.")
			_require(left_rect.end.y <= schematic.custom_minimum_size.y, "Expected generated map button bottom edge to stay inside the canvas.")
		for j in range(i + 1, map_overlay._map_node_buttons.size()):
			var right_button: Button = map_overlay._map_node_buttons[j]
			var right_rect := Rect2(right_button.position, right_button.custom_minimum_size)
			_require(not left_rect.intersects(right_rect), "Expected generated route map buttons not to overlap.")


func _generated_route_schematic(map_overlay) -> Control:
	if map_overlay._map_nodes_box == null or map_overlay._map_nodes_box.get_child_count() == 0:
		return null
	return map_overlay._map_nodes_box.get_child(0) as Control


func _assert_generated_route_edges_are_curved(schematic: Control) -> void:
	var edges := _children_named(schematic, "GeneratedRouteEdge")
	_require(not edges.is_empty(), "Expected generated route map to draw route edges.")
	for edge_node in edges:
		var edge := edge_node as Line2D
		_require(edge != null, "Expected generated route edge to use Line2D trail marks.")
		if edge == null:
			continue
		_require(edge.get_meta("edge_kind", "") == "map_path", "Expected generated route edge to be marked as a map path.")
		_require(int(edge.get_meta("trail_segment_count", 0)) > 1, "Expected generated route edge to render as repeated path marks.")
		_require(edge.points.size() >= 2, "Expected each generated path mark to have a visible segment.")
		_require(edge.z_index >= 1, "Expected generated route edge to render above the map background.")
		_require(edge.get_meta("from_route_node_id", "") != "", "Expected visible generated route edges to start from visible route nodes.")
		_require(edge.get_meta("to_route_node_id", "") != "", "Expected visible generated route edges to end at visible route nodes.")


func _assert_generated_node_visual_state_metadata(button: Button) -> void:
	_require(button.has_meta("route_visual_state"), "Expected generated node to expose visual state metadata for UI tests.")
	_require(button.has_meta("route_role"), "Expected generated node to expose role metadata for UI tests.")
	_require(button.find_child("GeneratedRoleStrip", true, false) == null, "Expected generated node role to avoid unexplained strip cues.")
	_require(button.find_child("GeneratedDangerCue", true, false) == null, "Expected generated node danger to avoid unexplained corner cues.")
	_require(button.find_child("GeneratedRewardCue", true, false) == null, "Expected generated node rewards to avoid unexplained corner cues.")


func _children_named(root_node: Node, child_name: String) -> Array:
	var out := []
	_collect_children_named(root_node, child_name, out)
	return out


func _collect_children_named(node: Node, child_name: String, out: Array) -> void:
	if node.name == child_name:
		out.append(node)
	for child in node.get_children():
		_collect_children_named(child, child_name, out)


func _edge_has_curve(points: PackedVector2Array) -> bool:
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


func _set_basic_rotation(build_state) -> void:
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected at least one unlocked skill for generated route UI setup.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)


func _defeat_title_for_boss(boss_name: String) -> String:
	var clean_name := boss_name.strip_edges()
	if clean_name.begins_with("The "):
		return "Defeat %s" % clean_name
	if clean_name.find(",") >= 0:
		return "Defeat %s" % clean_name
	return "Defeat the %s" % clean_name


func _visible_generated_route_nodes(root_node: ContractRouteNode) -> Array[ContractRouteNode]:
	var all_nodes := _collect_route_nodes(root_node)
	var visible: Array[ContractRouteNode] = []
	for node in all_nodes:
		if node.node_type != ContractRouteNode.NodeType.START:
			visible.append(node)
	return visible


func _collect_route_nodes(root_node: ContractRouteNode) -> Array[ContractRouteNode]:
	var out: Array[ContractRouteNode] = []
	var visited := {}
	_collect_route_nodes_recursive(root_node, visited, out)
	return out


func _collect_route_nodes_recursive(
	node: ContractRouteNode,
	visited: Dictionary,
	out: Array[ContractRouteNode]
) -> void:
	if node == null or visited.has(node.id):
		return
	visited[node.id] = true
	out.append(node)
	for next_node in node.next_nodes:
		_collect_route_nodes_recursive(next_node, visited, out)


func _visible_node_type_count(nodes: Array[ContractRouteNode], node_type: int) -> int:
	var count := 0
	for node in nodes:
		if node.node_type == node_type:
			count += 1
	return count


func _button_for_node(map_overlay, node: ContractRouteNode) -> Button:
	for button in map_overlay._map_node_buttons:
		var candidate: Button = button
		if String(candidate.get_meta("route_node_id", "")) == node.id:
			return candidate
	return null


func _string_array(value: Variant) -> Array[String]:
	var out: Array[String] = []
	if value is PackedStringArray or value is Array:
		for item in value:
			out.append(String(item))
	return out


func _compact_reward_summary(node: ContractRouteNode) -> String:
	if node == null or node.reward == null:
		return ""
	return node.reward_summary.replace(" gear choice", " gear")


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failed = true
