extends SceneTree
## Focused P4M5-T2 check for generated contract route data fields. Run with:
##   godot --headless --path project -s res://tests/generated_contract_route_data_shape_test.gd


func _initialize() -> void:
	_check_authored_defaults_stay_empty()
	_check_generated_node_state_round_trips()
	_check_generated_route_state_round_trips()
	_check_outgoing_ids_can_follow_existing_next_nodes()

	print("Generated contract route data shape check: OK")
	quit()


func _check_authored_defaults_stay_empty() -> void:
	var node := ContractRouteNode.new()
	assert(node.node_type == ContractRouteNode.NodeType.FIGHT)
	assert(ContractRouteNode.NodeType.OFFER == 0)
	assert(ContractRouteNode.NodeType.SUBCLASS_CHOICE == 1)
	assert(ContractRouteNode.NodeType.FIGHT == 2)
	assert(ContractRouteNode.NodeType.ELITE == 3)
	assert(ContractRouteNode.NodeType.BOSS == 4)
	assert(ContractRouteNode.NodeType.START == 5)
	assert(ContractRouteNode.NodeType.CAPTAIN == 6)
	assert(not node.has_generated_state())
	assert(node.generated_node_id == "")
	assert(node.depth == -1)
	assert(node.lane == -1)
	assert(node.outgoing_node_ids.is_empty())
	assert(node.biome == "")
	assert(node.monster_presentation_type == "")
	assert(node.generated_encounter_payload.is_empty())
	assert(node.combat_preview.is_empty())
	assert(node.debug_preview.is_empty())
	assert(node.branch_intent == "")
	assert(node.branch_intent_tags.is_empty())
	assert(node.generation_notices.is_empty())

	var contract := ContractDef.new()
	assert(not contract.has_generated_route_state())
	assert(contract.generated_route_id == "")
	assert(contract.source_seed == 0)
	assert(contract.generator_version == "")
	assert(contract.template_id == "")
	assert(contract.template_display_label == "")
	assert(contract.template_width_summary.is_empty())
	assert(contract.route_settings.is_empty())
	assert(contract.route_notices.is_empty())


func _check_generated_node_state_round_trips() -> void:
	var node := ContractRouteNode.new()
	node.id = "route.generated.d1_l0"
	node.node_type = ContractRouteNode.NodeType.ELITE
	node.apply_generated_state({
		"generated_node_id": "d1_l0",
		"depth": 1,
		"lane": 0,
		"outgoing_node_ids": ["d2_l0", "d2_l1"],
		"biome": "Swamp",
		"monster_presentation_type": "bogling",
		"route_preview": {
			"biome": "Swamp",
			"monster_name": "Shielded Bogling",
			"encounter_level": "Elite",
			"archetype_tags": ["armored", "warded"],
		},
		"generated_encounter_payload": {
			"source_seed": 991,
			"archetype_ids": ["armored_guard"],
		},
		"branch_intent": "elite_detour",
		"branch_intent_tags": ["risky", "high_reward"],
		"combat_preview": {
			"defense_summary": ["Armor 120"],
		},
		"debug_preview": {
			"budget": 115,
		},
		"generation_notices": ["optional elite branch"],
	})

	assert(node.has_generated_state())
	assert(node.generated_node_id == "d1_l0")
	assert(node.depth == 1)
	assert(node.lane == 0)
	assert(Array(node.outgoing_node_ids) == ["d2_l0", "d2_l1"])
	assert(node.biome == "Swamp")
	assert(node.monster_presentation_type == "bogling")
	assert(node.route_preview["monster_name"] == "Shielded Bogling")
	assert(node.generated_encounter_payload["source_seed"] == 991)
	assert(node.branch_intent == "elite_detour")
	assert(Array(node.branch_intent_tags) == ["risky", "high_reward"])
	assert(node.combat_preview["defense_summary"] == ["Armor 120"])
	assert(node.debug_preview["budget"] == 115)
	assert(Array(node.generation_notices) == ["optional elite branch"])

	var state := node.generated_state()
	assert(state["id"] == "route.generated.d1_l0")
	assert(state["generated_node_id"] == "d1_l0")
	assert(state["node_type"] == ContractRouteNode.NodeType.ELITE)
	assert(state["outgoing_node_ids"] == ["d2_l0", "d2_l1"])
	assert(state["route_preview"]["archetype_tags"] == ["armored", "warded"])
	assert(state["generated_encounter_payload"]["archetype_ids"] == ["armored_guard"])
	assert(state["branch_intent"] == "elite_detour")
	assert(state["branch_intent_tags"] == ["risky", "high_reward"])
	assert(state["generation_notices"] == ["optional elite branch"])

	state["route_preview"]["monster_name"] = "Mutated Elsewhere"
	assert(node.route_preview["monster_name"] == "Shielded Bogling")


func _check_generated_route_state_round_trips() -> void:
	var contract := ContractDef.new()
	contract.id = "contract.generated.test"
	contract.apply_generated_route_state({
		"generated_route_id": "generated.route.42",
		"source_seed": 424242,
		"generator_version": "route_gen_v1",
		"route_difficulty": "medium",
		"selected_biome": "City",
		"allowed_biomes": ["City", "Ruins"],
		"biome_table_version": "biomes_v1",
		"runtime_monster_generator_version": "monster_gen_v3",
		"runtime_monster_archetype_library_version": "archetypes_v2",
		"template_id": "braided_sideboard",
		"template_display_label": "Braided Sideboard",
		"template_width_summary": {
			"max_width": 3,
			"wide_node_ids": ["start"],
		},
		"route_settings": {
			"template_id": "braided_sideboard",
			"min_path_length": 3,
			"max_path_length": 6,
		},
		"route_notices": ["template split_merge"],
	})

	assert(contract.has_generated_route_state())
	assert(contract.generated_route_id == "generated.route.42")
	assert(contract.source_seed == 424242)
	assert(contract.generator_version == "route_gen_v1")
	assert(contract.route_difficulty == "medium")
	assert(contract.selected_biome == "City")
	assert(Array(contract.allowed_biomes) == ["City", "Ruins"])
	assert(contract.biome_table_version == "biomes_v1")
	assert(contract.runtime_monster_generator_version == "monster_gen_v3")
	assert(contract.runtime_monster_archetype_library_version == "archetypes_v2")
	assert(contract.template_id == "braided_sideboard")
	assert(contract.template_display_label == "Braided Sideboard")
	assert(contract.template_width_summary["max_width"] == 3)
	assert(contract.route_settings["max_path_length"] == 6)
	assert(Array(contract.route_notices) == ["template split_merge"])

	var state := contract.generated_route_state()
	assert(state["generated_route_id"] == "generated.route.42")
	assert(state["source_seed"] == 424242)
	assert(state["allowed_biomes"] == ["City", "Ruins"])
	assert(state["template_id"] == "braided_sideboard")
	assert(state["template_display_label"] == "Braided Sideboard")
	assert(state["template_width_summary"]["wide_node_ids"] == ["start"])
	assert(state["route_settings"]["min_path_length"] == 3)
	assert(state["route_notices"] == ["template split_merge"])

	state["route_settings"]["min_path_length"] = 99
	assert(contract.route_settings["min_path_length"] == 3)


func _check_outgoing_ids_can_follow_existing_next_nodes() -> void:
	var start := ContractRouteNode.new()
	start.id = "route.generated.start"
	start.generated_node_id = "start"
	start.node_type = ContractRouteNode.NodeType.START

	var left := ContractRouteNode.new()
	left.id = "route.generated.d1_l0"
	left.generated_node_id = "d1_l0"

	var right := ContractRouteNode.new()
	right.id = "route.generated.d1_l1"

	start.next_nodes = [left, right]
	start.sync_outgoing_node_ids_from_next_nodes()

	assert(Array(start.outgoing_node_ids) == ["d1_l0", "route.generated.d1_l1"])
	assert(ContractRouteNode.find_by_id(start, "route.generated.d1_l0") == left)
	assert(ContractRouteNode.find_by_id(start, "route.generated.d1_l1") == right)
