extends SceneTree
## P4M5-T9 matrix coverage for deterministic generated route constraints.
## Run with:
##   godot --headless --path project -s res://tests/generated_route_matrix_test.gd

const ROUTE_GENERATOR := preload("res://scripts/systems/contract_route_generator/contract_route_generator.gd")
const GeneratedRouteInspectorScript := preload("res://scripts/tools/generated_route_inspector.gd")

const SPARSE_PREVIEW_KEYS := ["archetype_line", "archetype_tags", "biome", "elite_variant_label", "boss_variant_label", "encounter_level", "modifier_label", "monster_name"]
const FORBIDDEN_ROUTE_PREVIEW_KEYS := [
	"source_seed",
	"budget_metadata",
	"pressure_metadata",
	"route_pressure_scale",
	"route_pressure_axes",
	"defense_overrides",
	"selected_mechanics",
	"combat_preview",
	"debug_preview",
	"route_modifier_ids",
	"node_modifier_ids",
	"elite_variant_id",
	"elite_variant_model_version",
	"boss_variant_id",
	"boss_variant_model_version",
]


func _initialize() -> void:
	_check_matrix_determinism_and_variation()
	_check_matrix_route_constraints()
	_check_matrix_biome_preview_and_payload_constraints()
	_check_inspector_matches_generated_contract_matrix()
	_check_matrix_expanded_content_coverage()

	print("Generated route matrix check: OK")
	quit()


func _matrix_cases() -> Array:
	return [
		{
			"name": "default",
			"settings": {},
			"seeds": range(3000, 3012),
		},
		{
			"name": "single_swamp",
			"settings": {"allowed_biomes": ["Swamp"], "route_difficulty": "medium"},
			"seeds": range(3100, 3110),
		},
		{
			"name": "two_biomes_hard",
			"settings": {"allowed_biomes": ["Cave", "Graveyard"], "route_difficulty": "hard"},
			"seeds": range(3200, 3210),
		},
		{
			"name": "later_contract_pressure",
			"settings": {"allowed_biomes": ["Swamp", "Cave"], "route_difficulty": "medium", "completed_contract_count": 3},
			"seeds": range(3250, 3260),
		},
		{
			"name": "stage_five_captain_blend",
			"settings": {"allowed_biomes": ["Swamp", "Cave"], "route_difficulty": "medium", "completed_contract_count": 4},
			"seeds": range(3260, 3268),
		},
		{
			"name": "medium_to_hard_band",
			"settings": {"allowed_biomes": ["Cave", "Graveyard"], "route_difficulty": "medium", "completed_contract_count": 5},
			"seeds": range(3268, 3276),
		},
		{
			"name": "wide_nightmare",
			"settings": {
				"allowed_biomes": ["Haunted Forest", "Ruined Keep", "Ancient Ruins"],
				"route_difficulty": "nightmare",
				"completed_contract_count": 8,
			},
			"seeds": range(3300, 3310),
		},
	]


func _check_matrix_determinism_and_variation() -> void:
	for case in _matrix_cases():
		var settings: Dictionary = case["settings"]
		var signatures := {}
		for seed in case["seeds"]:
			var first: ContractDef = ROUTE_GENERATOR.generate(int(seed), settings)
			var second: ContractDef = ROUTE_GENERATOR.generate(int(seed), settings)
			_assert_no_notices(ROUTE_GENERATOR.validate(first), "%s seed %d" % [case["name"], int(seed)])
			assert(ROUTE_GENERATOR.graph_signature(first) == ROUTE_GENERATOR.graph_signature(second))
			assert(first.generator_version == ROUTE_GENERATOR.GENERATOR_VERSION)
			assert(first.modifier_model_version == ROUTE_GENERATOR.MODIFIER_MODEL_VERSION)
			assert(not first.generated_modifier_ids.is_empty())
			assert(first.generated_modifiers.size() == first.generated_modifier_ids.size())
			assert(first.template_id == first.route_settings["template_id"])
			assert(first.template_display_label == first.route_settings["template_display_label"])
			assert(int(first.template_width_summary["max_width"]) >= 3)
			assert(first.route_settings["template_id"] != "")
			signatures[ROUTE_GENERATOR.graph_signature(first)] = true
		assert(signatures.size() >= 2)

	var same_seed_default: ContractDef = ROUTE_GENERATOR.generate(4444, {})
	var same_seed_single_biome: ContractDef = ROUTE_GENERATOR.generate(4444, {"allowed_biomes": ["Cave"]})
	assert(ROUTE_GENERATOR.graph_signature(same_seed_default) != ROUTE_GENERATOR.graph_signature(same_seed_single_biome))


func _check_matrix_route_constraints() -> void:
	for case in _matrix_cases():
		for seed in case["seeds"]:
			var contract: ContractDef = ROUTE_GENERATOR.generate(int(seed), case["settings"])
			var nodes := _nodes(contract)
			var ids := {}
			var start_count := 0
			var boss_count := 0
			var branch_count := 0
			var boss: ContractRouteNode = null
			for node in nodes:
				assert(not ids.has(node.generated_node_id))
				ids[node.generated_node_id] = true
				if node.node_type == ContractRouteNode.NodeType.START:
					start_count += 1
				elif node.node_type == ContractRouteNode.NodeType.BOSS:
					boss_count += 1
					boss = node
				if node.next_nodes.size() > 1:
					branch_count += 1
				if node.node_type == ContractRouteNode.NodeType.BOSS:
					assert(node.next_nodes.is_empty())
				else:
					assert(not node.next_nodes.is_empty())
				_assert_outgoing_ids_match_next_nodes(node)
				for next_node in node.next_nodes:
					assert(next_node.depth > node.depth)
			assert(start_count == 1)
			assert(boss_count == 1)
			assert(branch_count >= 1)
			assert(_max_width(nodes) >= 3)
			assert(boss != null)
			var paths := _paths(contract)
			assert(paths.size() >= 2)
			_assert_pacing(contract, paths)
			_assert_elite_constraints(contract.offer_node, paths)
			assert(nodes.size() == ids.size())


func _check_matrix_biome_preview_and_payload_constraints() -> void:
	for case in _matrix_cases():
		for seed in case["seeds"]:
			var contract: ContractDef = ROUTE_GENERATOR.generate(int(seed), case["settings"])
			assert(Array(contract.allowed_biomes).has(contract.selected_biome))
			var child_seeds := {}
			for node in _nodes(contract):
				assert(Array(contract.allowed_biomes).has(node.biome))
				assert(node.biome == contract.selected_biome)
				_assert_sparse_route_preview(node)
				if node.node_type == ContractRouteNode.NodeType.START:
					assert(node.generated_encounter_payload.is_empty())
					continue
				_assert_presentation_pool(contract, node)
				_assert_generated_payload(node, child_seeds)
				_assert_modifier_payload(contract, node)
				_assert_elite_variant_payload(node)
				_assert_boss_variant_payload(node)
				assert(node.route_preview["archetype_tags"] == node.combat_preview["archetype_tags"])
			_assert_branch_previews_are_distinct(contract.offer_node)


func _check_inspector_matches_generated_contract_matrix() -> void:
	for case in _matrix_cases():
		var seeds: Array = case["seeds"]
		for index in range(mini(3, seeds.size())):
			var seed := int(seeds[index])
			var settings: Dictionary = case["settings"]
			var contract: ContractDef = ROUTE_GENERATOR.generate(seed, settings)
			var report: Dictionary = GeneratedRouteInspectorScript.inspect(seed, settings)
			assert((report["validation_notices"] as Array).is_empty())
			assert(GeneratedRouteInspectorScript.report_signature(report) == GeneratedRouteInspectorScript.report_signature(GeneratedRouteInspectorScript.inspect(seed, settings)))
			var route: Dictionary = report["route"]
			assert(route["generated_route_id"] == contract.generated_route_id)
			assert(route["generator_version"] == contract.generator_version)
			assert(route["selected_biome"] == contract.selected_biome)
			assert(route["modifier_model_version"] == contract.modifier_model_version)
			assert(route["generated_modifier_ids"] == Array(contract.generated_modifier_ids))
			var report_nodes: Array = report["nodes"]
			var contract_nodes := _nodes(contract)
			assert(report_nodes.size() == contract_nodes.size())
			var by_id := _report_nodes_by_id(report)
			for node in contract_nodes:
				var summary: Dictionary = by_id[node.generated_node_id]
				assert(summary["route_preview"] == node.route_preview)
				assert(summary["reward"] == _reward_summary(node))
				assert(summary["combat_preview"] == node.combat_preview)
				assert(summary["debug_preview"] == node.debug_preview)
				assert(summary["generated_modifier_ids"] == Array(node.generated_modifier_ids))
				assert(summary["generated_modifier_labels"] == Array(node.generated_modifier_labels))
				assert(summary["elite_variant_id"] == node.elite_variant_id)
				assert(summary["elite_variant_label"] == node.elite_variant_label)
				assert(summary["boss_variant_id"] == node.boss_variant_id)
				assert(summary["boss_variant_label"] == node.boss_variant_label)
				assert(bool(summary["has_generated_encounter_payload"]) == (not node.generated_encounter_payload.is_empty()))
				if node.node_type != ContractRouteNode.NodeType.START:
					assert((summary["encounter"] as Dictionary)["source_seed"] == node.generated_encounter_payload["source_seed"])


func _check_matrix_expanded_content_coverage() -> void:
	var templates := {}
	var archetypes := {}
	var pressure_axes := {}
	var route_modifiers := {}
	var node_modifiers := {}
	var elite_variants := {}
	var boss_variants := {}
	var captain_seen := false
	var safe_intent_seen := false
	var risky_intent_seen := false
	var high_reward_intent_seen := false
	var elite_detour_intent_seen := false
	var pressure_gauntlet_intent_seen := false
	var captain_heavy_path_seen := false
	var wide_matchup_choice_seen := false
	var fork_rejoin_seen := false
	var boss_approach_seen := false
	var safe_boss_approach_seen := false
	var captain_boss_approach_seen := false
	var elite_boss_approach_seen := false
	var boss_content_promotion_seen := false
	var elite_content_promotion_seen := false
	var captain_content_promotion_seen := false
	var full_hard_band_seen := false
	var nightmare_overcap_seen := false
	var route_biomes := {}
	var node_biomes := {}
	for case in _matrix_cases():
		for seed in case["seeds"]:
			var contract: ContractDef = ROUTE_GENERATOR.generate(int(seed), case["settings"])
			templates[String(contract.route_settings.get("template_id", ""))] = true
			route_biomes[contract.selected_biome] = true
			for path in _paths(contract):
				captain_heavy_path_seen = captain_heavy_path_seen or _path_captain_count(path) >= 2
			wide_matchup_choice_seen = wide_matchup_choice_seen or _has_wide_matchup_choice(_nodes(contract))
			fork_rejoin_seen = fork_rejoin_seen or _has_fork_rejoin_branch(_nodes(contract))
			boss_approach_seen = boss_approach_seen or _has_boss_approach_lane_variation(_nodes(contract))
			for modifier_id in contract.generated_modifier_ids:
				route_modifiers[String(modifier_id)] = true
			for node in _nodes(contract):
				node_biomes[node.biome] = true
				if node.node_type == ContractRouteNode.NodeType.START:
					continue
				for archetype_id in node.generated_encounter_payload.get("archetype_ids", []):
					archetypes[String(archetype_id)] = true
				var profile: Dictionary = node.generated_encounter_payload.get("route_pressure_axes", {})
				for axis in profile.get("axes", []):
					pressure_axes[String(axis)] = true
				var scale: Dictionary = node.generated_encounter_payload.get("route_pressure_scale", {})
				var promotion_reason := String(scale.get("content_promotion_reason", ""))
				boss_content_promotion_seen = boss_content_promotion_seen or promotion_reason == "stage_3_boss_next_band"
				elite_content_promotion_seen = elite_content_promotion_seen or promotion_reason == "stage_4_elite_next_band"
				captain_content_promotion_seen = captain_content_promotion_seen or promotion_reason == "stage_5_captain_next_band"
				full_hard_band_seen = full_hard_band_seen or (
					int(scale.get("effective_contract_difficulty_id", 0)) >= 3
					and int(scale.get("contract_progression_stage", 0)) == 1
					and int(scale.get("content_difficulty_id", 0)) >= 3
				)
				nightmare_overcap_seen = nightmare_overcap_seen or (
					String(scale.get("effective_contract_difficulty_label", "")) == "nightmare"
					and int(scale.get("overcap_pressure", 0)) > 0
				)
				for modifier_id in node.generated_modifier_ids:
					node_modifiers[String(modifier_id)] = true
				safe_intent_seen = safe_intent_seen or node.branch_intent_tags.has("safe")
				risky_intent_seen = risky_intent_seen or node.branch_intent_tags.has("risky")
				high_reward_intent_seen = high_reward_intent_seen or node.branch_intent_tags.has("high_reward")
				elite_detour_intent_seen = elite_detour_intent_seen or node.branch_intent_tags.has("elite_detour")
				pressure_gauntlet_intent_seen = pressure_gauntlet_intent_seen or node.branch_intent_tags.has("pressure_gauntlet")
				wide_matchup_choice_seen = wide_matchup_choice_seen or node.branch_intent_tags.has("wide_matchup_choice")
				fork_rejoin_seen = fork_rejoin_seen or node.branch_intent_tags.has("fork_rejoin")
				safe_boss_approach_seen = safe_boss_approach_seen or node.branch_intent_tags.has("safe_boss_approach")
				captain_boss_approach_seen = captain_boss_approach_seen or node.branch_intent_tags.has("captain_boss_approach")
				elite_boss_approach_seen = elite_boss_approach_seen or node.branch_intent_tags.has("elite_boss_approach")
				if node.node_type == ContractRouteNode.NodeType.CAPTAIN:
					captain_seen = true
				if node.node_type == ContractRouteNode.NodeType.ELITE:
					elite_variants[node.elite_variant_id] = true
				if node.node_type == ContractRouteNode.NodeType.BOSS:
					boss_variants[node.boss_variant_id] = true
	assert(templates.size() == ROUTE_GENERATOR.TEMPLATES.size())
	assert(captain_seen)
	assert(safe_intent_seen)
	assert(risky_intent_seen)
	assert(high_reward_intent_seen)
	assert(elite_detour_intent_seen)
	assert(pressure_gauntlet_intent_seen)
	assert(captain_heavy_path_seen)
	assert(wide_matchup_choice_seen)
	assert(fork_rejoin_seen)
	assert(boss_approach_seen)
	assert(safe_boss_approach_seen)
	assert(captain_boss_approach_seen)
	assert(elite_boss_approach_seen)
	assert(boss_content_promotion_seen)
	assert(elite_content_promotion_seen)
	assert(captain_content_promotion_seen)
	assert(full_hard_band_seen)
	assert(nightmare_overcap_seen)
	assert(route_biomes.size() >= 6)
	assert(node_biomes.size() >= 6)
	_assert_contains_all(archetypes, ["aegis", "nullify", "spiteful", "riftbound"])
	_assert_contains_all(pressure_axes, ROUTE_GENERATOR.PRESSURE_AXIS_LABELS.keys())
	_assert_contains_all(route_modifiers, _catalog_ids(ROUTE_GENERATOR.MODIFIER_CATALOG))
	assert(node_modifiers.size() >= 3)
	_assert_contains_all(elite_variants, _catalog_ids(ROUTE_GENERATOR.ELITE_VARIANT_CATALOG))
	_assert_contains_all(boss_variants, _catalog_ids(ROUTE_GENERATOR.BOSS_VARIANT_CATALOG))


func _assert_pacing(contract: ContractDef, paths: Array) -> void:
	var shortest := 999
	var longest := 0
	for path in paths:
		var length: int = path.size() - 1
		shortest = mini(shortest, length)
		longest = maxi(longest, length)
		assert(length >= int(contract.route_settings["min_path_length"]))
		assert(length <= int(contract.route_settings["max_path_length"]))
		assert(not _has_back_to_back_elites(path))
	assert(shortest <= int(contract.route_settings["shortest_path_max"]))
	assert(longest >= int(contract.route_settings["longest_path_min"]))
	assert(_elite_count(_shortest_path(paths)) <= 1)


func _assert_elite_constraints(start: ContractRouteNode, paths: Array) -> void:
	var all_openers_elite := true
	for next_node in start.next_nodes:
		if next_node.node_type != ContractRouteNode.NodeType.ELITE:
			all_openers_elite = false
	assert(not all_openers_elite)

	for path in paths:
		assert(not _has_back_to_back_elites(path))

	for node in _collect_from(start):
		if node.next_nodes.size() <= 1:
			continue
		var has_elite := false
		var has_non_elite := false
		for next_node in node.next_nodes:
			if next_node.node_type == ContractRouteNode.NodeType.ELITE:
				has_elite = true
			else:
				has_non_elite = true
		if has_elite:
			assert(has_non_elite)


func _assert_sparse_route_preview(node: ContractRouteNode) -> void:
	for key in ["biome", "monster_name", "encounter_level", "archetype_tags"]:
		assert(node.route_preview.has(key))
	for key in FORBIDDEN_ROUTE_PREVIEW_KEYS:
		assert(not node.route_preview.has(key))
	for key in node.route_preview:
		assert(SPARSE_PREVIEW_KEYS.has(String(key)))
	if node.node_type != ContractRouteNode.NodeType.START:
		assert(String(node.route_preview["biome"]) != "")
		assert(String(node.route_preview["monster_name"]) != "")
		assert(not _preview_tags(node.route_preview).is_empty())
		if node.node_type != ContractRouteNode.NodeType.BOSS:
			assert(node.branch_intent != "")
			assert(not node.branch_intent_tags.is_empty())


func _assert_presentation_pool(contract: ContractDef, node: ContractRouteNode) -> void:
	assert(Array(contract.allowed_biomes).has(node.biome))
	assert(node.biome == contract.selected_biome)
	var kind := _expected_kind(node)
	assert(_presentation_candidates(node.biome, kind).has(node.monster_presentation_type))
	assert(node.route_preview["monster_name"] == node.monster_presentation_type)


func _assert_generated_payload(node: ContractRouteNode, child_seeds: Dictionary) -> void:
	var payload := node.generated_encounter_payload
	assert(not payload.is_empty())
	assert(not node.combat_preview.is_empty())
	assert(not node.debug_preview.is_empty())
	var source_seed := int(payload.get("source_seed", 0))
	assert(source_seed > 0)
	assert(not child_seeds.has(source_seed))
	child_seeds[source_seed] = true
	var input: Dictionary = payload["source_input"]
	assert(input["generator_version"] == RuntimeMonsterGenerator.GENERATOR_VERSION)
	assert(input["library_schema"] == RuntimeArchetypeLibraryLoader.EXPECTED_SCHEMA)
	assert(input["monster_kind"] == _expected_combat_kind(node))
	assert(int(input["difficulty_id"]) > 0)
	assert(String(input["tempo_profile"]) != "")
	assert(not (payload.get("archetype_ids", []) as Array).is_empty())
	assert(not (payload.get("selected_mechanics", []) as Array).is_empty())
	assert(not (payload.get("defense_overrides", {}) as Dictionary).is_empty())
	assert((payload.get("budget_metadata", {}) as Dictionary).has("budget"))
	assert((payload.get("pressure_metadata", {}) as Dictionary).has("status"))
	assert(payload.has("notices"))
	assert(node.combat_preview["defense_overrides"] == payload["defense_overrides"])
	assert(node.debug_preview["source_seed"] == payload["source_seed"])
	assert(node.debug_preview["raw_archetype_ids"] == payload["archetype_ids"])
	assert(node.debug_preview["branch_intent"] == node.branch_intent)
	assert(Array(node.debug_preview["branch_intent_tags"]) == Array(node.branch_intent_tags))
	assert(payload["branch_intent"] == node.branch_intent)
	assert(Array(payload["branch_intent_tags"]) == Array(node.branch_intent_tags))


func _assert_modifier_payload(contract: ContractDef, node: ContractRouteNode) -> void:
	assert(Array(node.generated_encounter_payload.get("route_modifier_ids", [])) == Array(contract.generated_modifier_ids))
	assert(Array(node.generated_encounter_payload.get("node_modifier_ids", [])) == Array(node.generated_modifier_ids))
	assert(String(node.generated_encounter_payload.get("modifier_model_version", "")) == contract.modifier_model_version)
	assert(Array(node.debug_preview.get("node_modifier_ids", [])) == Array(node.generated_modifier_ids))
	assert(Array(node.debug_preview.get("node_modifier_labels", [])) == Array(node.generated_modifier_labels))
	if node.route_preview.has("modifier_label"):
		assert(not node.generated_modifier_labels.is_empty())
		assert(String(node.route_preview["modifier_label"]) == " / ".join(Array(node.generated_modifier_labels)))


func _assert_elite_variant_payload(node: ContractRouteNode) -> void:
	if node.node_type != ContractRouteNode.NodeType.ELITE:
		assert(node.elite_variant_id == "")
		assert(not node.route_preview.has("elite_variant_label"))
		return
	assert(node.elite_variant_model_version == ROUTE_GENERATOR.ELITE_VARIANT_MODEL_VERSION)
	assert(node.elite_variant_id != "")
	assert(node.elite_variant_label != "")
	assert(String(node.generated_encounter_payload.get("elite_variant_id", "")) == node.elite_variant_id)
	assert(String(node.generated_encounter_payload.get("elite_variant_label", "")) == node.elite_variant_label)
	assert(String(node.generated_encounter_payload.get("elite_variant_model_version", "")) == node.elite_variant_model_version)
	assert(String(node.debug_preview.get("elite_variant_id", "")) == node.elite_variant_id)
	assert(String(node.debug_preview.get("elite_variant_label", "")) == node.elite_variant_label)
	assert(String(node.route_preview.get("elite_variant_label", "")) == node.elite_variant_label)


func _assert_boss_variant_payload(node: ContractRouteNode) -> void:
	if node.node_type != ContractRouteNode.NodeType.BOSS:
		assert(node.boss_variant_id == "")
		assert(not node.route_preview.has("boss_variant_label"))
		return
	assert(node.boss_variant_model_version == ROUTE_GENERATOR.BOSS_VARIANT_MODEL_VERSION)
	assert(node.boss_variant_id != "")
	assert(node.boss_variant_label != "")
	assert(String(node.generated_encounter_payload.get("boss_variant_id", "")) == node.boss_variant_id)
	assert(String(node.generated_encounter_payload.get("boss_variant_label", "")) == node.boss_variant_label)
	assert(String(node.generated_encounter_payload.get("boss_variant_model_version", "")) == node.boss_variant_model_version)
	assert(String(node.debug_preview.get("boss_variant_id", "")) == node.boss_variant_id)
	assert(String(node.debug_preview.get("boss_variant_label", "")) == node.boss_variant_label)
	assert(String(node.route_preview.get("boss_variant_label", "")) == node.boss_variant_label)


func _assert_branch_previews_are_distinct(start: ContractRouteNode) -> void:
	for node in _collect_from(start):
		if node.next_nodes.size() <= 1:
			continue
		var signatures := {}
		for next_node in node.next_nodes:
			signatures[_branch_signature(next_node)] = true
		assert(signatures.size() == node.next_nodes.size())


func _assert_outgoing_ids_match_next_nodes(node: ContractRouteNode) -> void:
	var expected := []
	for next_node in node.next_nodes:
		expected.append(next_node.generated_node_id)
	assert(Array(node.outgoing_node_ids) == expected)


func _nodes(contract: ContractDef) -> Array:
	var result := _collect_from(contract.offer_node)
	result.sort_custom(func(a: ContractRouteNode, b: ContractRouteNode): return a.depth < b.depth if a.depth != b.depth else a.lane < b.lane)
	return result


func _max_width(nodes: Array) -> int:
	var result := 0
	for node in nodes:
		result = maxi(result, node.next_nodes.size())
	return result


func _collect_from(start: ContractRouteNode) -> Array:
	var result := []
	_collect(start, {}, result)
	return result


func _collect(node: ContractRouteNode, visited: Dictionary, result: Array) -> void:
	if node == null or visited.has(node.generated_node_id):
		return
	visited[node.generated_node_id] = true
	result.append(node)
	for next_node in node.next_nodes:
		_collect(next_node, visited, result)


func _paths(contract: ContractDef) -> Array:
	var nodes := _nodes(contract)
	return _paths_from(contract.offer_node, nodes[nodes.size() - 1], {}, [])


func _paths_from(node: ContractRouteNode, boss: ContractRouteNode, visited: Dictionary, path: Array) -> Array:
	if node == null or visited.has(node.generated_node_id):
		return []
	var next_path := path.duplicate()
	next_path.append(node)
	if node == boss:
		return [next_path]
	var next_visited := visited.duplicate()
	next_visited[node.generated_node_id] = true
	var paths := []
	for next_node in node.next_nodes:
		paths.append_array(_paths_from(next_node, boss, next_visited, next_path))
	return paths


func _shortest_path(paths: Array) -> Array:
	var shortest: Array = paths[0]
	for path in paths:
		if path.size() < shortest.size():
			shortest = path
	return shortest


func _elite_count(path: Array) -> int:
	var count := 0
	for node in path:
		if node.node_type == ContractRouteNode.NodeType.ELITE:
			count += 1
	return count


func _path_captain_count(path: Array) -> int:
	var count := 0
	for node in path:
		if node.node_type == ContractRouteNode.NodeType.CAPTAIN:
			count += 1
	return count


func _has_wide_matchup_choice(nodes: Array) -> bool:
	for node in nodes:
		if node.next_nodes.size() < 3:
			continue
		var matchup_options := 0
		for next_node in node.next_nodes:
			if next_node.branch_intent_tags.has("wide_matchup_choice"):
				matchup_options += 1
		if matchup_options >= 3:
			return true
	return false


func _has_fork_rejoin_branch(nodes: Array) -> bool:
	if nodes.is_empty():
		return false
	var boss: ContractRouteNode = nodes[nodes.size() - 1]
	for node in nodes:
		if node.next_nodes.size() < 2:
			continue
		var branch_reach_sets := []
		for next_node in node.next_nodes:
			branch_reach_sets.append(_reachable_node_ids_before_boss(next_node, boss))
		for i in range(branch_reach_sets.size()):
			for j in range(i + 1, branch_reach_sets.size()):
				for reached_id in branch_reach_sets[i]:
					if reached_id != boss.generated_node_id and (branch_reach_sets[j] as Dictionary).has(reached_id):
						return true
	return false


func _has_boss_approach_lane_variation(nodes: Array) -> bool:
	if nodes.is_empty():
		return false
	var boss: ContractRouteNode = nodes[nodes.size() - 1]
	var approach_count := 0
	var roles := {}
	for node in nodes:
		if node == null or not node.branch_intent_tags.has("boss_approach"):
			continue
		if not node.next_nodes.has(boss):
			continue
		approach_count += 1
		if node.branch_intent_tags.has("safe_boss_approach"):
			roles["safe"] = true
		if node.branch_intent_tags.has("captain_boss_approach"):
			roles["captain"] = true
		if node.branch_intent_tags.has("elite_boss_approach"):
			roles["elite"] = true
	return approach_count >= 2 and roles.size() >= 2


func _reachable_node_ids_before_boss(start: ContractRouteNode, boss: ContractRouteNode) -> Dictionary:
	var reached := {}
	_collect_reachable_node_ids_before_boss(start, boss, {}, reached)
	return reached


func _collect_reachable_node_ids_before_boss(
	node: ContractRouteNode,
	boss: ContractRouteNode,
	visited: Dictionary,
	reached: Dictionary
) -> void:
	if node == null or visited.has(node.generated_node_id):
		return
	visited[node.generated_node_id] = true
	reached[node.generated_node_id] = true
	if node == boss:
		return
	for next_node in node.next_nodes:
		_collect_reachable_node_ids_before_boss(next_node, boss, visited, reached)


func _has_back_to_back_elites(path: Array) -> bool:
	var previous_elite := false
	for node in path:
		var current_elite: bool = node.node_type == ContractRouteNode.NodeType.ELITE
		if previous_elite and current_elite:
			return true
		previous_elite = current_elite
	return false


func _preview_signature(preview: Dictionary, node_type: int) -> String:
	return "%s|%s|%s|%s|%s|%s|%d" % [
		preview.get("biome", ""),
		preview.get("monster_name", ""),
		preview.get("encounter_level", ""),
		preview.get("elite_variant_label", ""),
		preview.get("boss_variant_label", ""),
		",".join(_preview_tags(preview)),
		node_type,
	]


func _branch_signature(node: ContractRouteNode) -> String:
	return "%s|%s" % [
		_preview_signature(node.route_preview, node.node_type),
		_reward_signature(node),
	]


func _preview_tags(preview: Dictionary) -> PackedStringArray:
	var tags := PackedStringArray()
	for tag in preview.get("archetype_tags", []):
		tags.append(String(tag))
	return tags


func _reward_summary(node: ContractRouteNode) -> Dictionary:
	if node.reward == null:
		return {}
	return {
		"gold_amount": node.reward.gold_amount,
		"talent_points": node.reward.talent_points,
		"generated_gear_choice_count": node.reward.generated_gear_choice_count,
		"generated_gear_tier": node.reward.generated_gear_tier,
		"generated_gear_tier_label": GearGenerator.tier_name(node.reward.generated_gear_tier),
		"generated_gear_slots": node.reward.generated_gear_slots.duplicate(),
		"generated_gear_slot_labels": _gear_slot_labels(node.reward.generated_gear_slots),
		"generated_gear_item_families": _gear_item_families(node.reward.generated_gear_slots),
		"quality_label": node.reward_quality_label,
		"summary": node.reward_summary,
	}


func _reward_signature(node: ContractRouteNode) -> String:
	if node.reward == null:
		return "none"
	return "%d:%d:%d:%d:%s:%s:%s" % [
		node.reward.gold_amount,
		node.reward.talent_points,
		node.reward.generated_gear_choice_count,
		node.reward.generated_gear_tier,
		",".join(_int_strings(node.reward.generated_gear_slots)),
		node.reward_quality_label,
		node.reward_summary,
	]


func _int_strings(values: Array) -> PackedStringArray:
	var out := PackedStringArray()
	for value in values:
		out.append(str(int(value)))
	return out


func _gear_slot_labels(slots: Array) -> Array:
	var result := []
	for slot in slots:
		result.append(GearGenerator.universal_slot_label(int(slot)))
	return result


func _gear_item_families(slots: Array) -> Array:
	var result := []
	for slot in slots:
		result.append(GearGenerator.rogue_item_family_for_slot(int(slot)))
	return result


func _catalog_ids(catalog: Array) -> Array:
	var ids := []
	for entry in catalog:
		ids.append(String((entry as Dictionary).get("id", "")))
	return ids


func _assert_contains_all(seen: Dictionary, expected: Array) -> void:
	for id in expected:
		assert(seen.has(String(id)))


func _expected_kind(node: ContractRouteNode) -> String:
	match node.node_type:
		ContractRouteNode.NodeType.CAPTAIN:
			return "captain"
		ContractRouteNode.NodeType.ELITE:
			return "elite"
		ContractRouteNode.NodeType.BOSS:
			return "boss"
	return "normal"


func _expected_combat_kind(node: ContractRouteNode) -> String:
	match node.node_type:
		ContractRouteNode.NodeType.ELITE:
			return "elite"
		ContractRouteNode.NodeType.BOSS:
			return "boss"
	return "normal"


func _presentation_candidates(biome: String, kind: String) -> Array:
	var table: Dictionary = ROUTE_GENERATOR.BIOME_PRESENTATION[biome]
	var candidates := Array(table[kind]).duplicate()
	if kind == "captain":
		for normal_name in table["normal"]:
			candidates.append(String(ROUTE_GENERATOR.CAPTAIN_PROMOTED_NORMAL_NAMES.get(String(normal_name), "Veteran %s" % String(normal_name))))
	return candidates


func _report_nodes_by_id(report: Dictionary) -> Dictionary:
	var result := {}
	for node in report["nodes"]:
		var summary: Dictionary = node
		result[summary["id"]] = summary
	return result


func _assert_no_notices(notices: PackedStringArray, context: String) -> void:
	if not notices.is_empty():
		print("%s validation notices: %s" % [context, ", ".join(notices)])
	assert(notices.is_empty())
