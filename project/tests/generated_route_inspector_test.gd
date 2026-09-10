extends SceneTree
## Focused P4M5-T8 check for isolated generated route inspection.
## Run with:
##   godot --headless --path project -s res://tests/generated_route_inspector_test.gd

const GeneratedRouteInspectorScript := preload("res://scripts/tools/generated_route_inspector.gd")
const RouteGeneratorScript := preload("res://scripts/systems/contract_route_generator/contract_route_generator.gd")


func _initialize() -> void:
	_check_same_seed_report_repeats()
	_check_different_seed_report_varies()
	_check_report_contains_route_graph_previews_and_encounters()
	_check_report_contains_t5_intent_coverage()
	_check_report_contains_elite_variant()
	_check_route_preview_remains_sparse()
	_check_text_formatter_is_useful()

	print("Generated route inspector check: OK")
	quit()


func _check_same_seed_report_repeats() -> void:
	var settings := {"route_difficulty": "medium", "allowed_biomes": ["Swamp", "Cave"]}
	var first: Dictionary = GeneratedRouteInspectorScript.inspect(4242, settings)
	var second: Dictionary = GeneratedRouteInspectorScript.inspect(4242, settings)
	assert(GeneratedRouteInspectorScript.report_signature(first) == GeneratedRouteInspectorScript.report_signature(second))


func _check_different_seed_report_varies() -> void:
	var settings := {"route_difficulty": "medium", "allowed_biomes": ["Swamp", "Cave"]}
	var first: Dictionary = GeneratedRouteInspectorScript.inspect(1111, settings)
	var second: Dictionary = GeneratedRouteInspectorScript.inspect(2222, settings)
	assert(GeneratedRouteInspectorScript.report_signature(first) != GeneratedRouteInspectorScript.report_signature(second))


func _check_report_contains_route_graph_previews_and_encounters() -> void:
	var report: Dictionary = GeneratedRouteInspectorScript.inspect(9911, {
		"route_difficulty": "hard",
		"allowed_biomes": ["Graveyard"],
	})
	var route: Dictionary = report["route"]
	assert(report["source"] == "generated_route_inspector")
	assert(report["version"] == GeneratedRouteInspectorScript.VERSION)
	assert(route["generator_version"] == RouteGeneratorScript.GENERATOR_VERSION)
	assert(route["biome_table_version"] == RouteGeneratorScript.PRESENTATION_TABLE_VERSION)
	assert(route["modifier_model_version"] == RouteGeneratorScript.MODIFIER_MODEL_VERSION)
	assert(not (route["generated_modifier_ids"] as Array).is_empty())
	assert((route["generated_modifiers"] as Array).size() == (route["generated_modifier_ids"] as Array).size())
	assert(route["selected_biome"] == "Graveyard")
	assert(route["allowed_biomes"] == ["Graveyard"])
	assert(route["template_id"] != "")
	assert(route["template_display_label"] != "")
	assert(not (route["template_width_summary"] as Dictionary).is_empty())
	assert(int((route["template_width_summary"] as Dictionary)["max_width"]) >= 3)
	assert(route["pacing_profile"] != "")
	assert((report["validation_notices"] as Array).is_empty())
	assert((report["nodes"] as Array).size() >= 5)
	assert((report["checks"] as Dictionary)["all_combat_nodes_have_payloads"])
	assert((report["checks"] as Dictionary)["all_combat_nodes_have_previews"])
	assert(int((report["checks"] as Dictionary)["captain_node_count"]) > 0)
	assert(int((report["checks"] as Dictionary)["safe_intent_node_count"]) > 0)
	assert(int((report["checks"] as Dictionary)["risky_intent_node_count"]) > 0)
	assert(int((report["checks"] as Dictionary)["high_reward_intent_node_count"]) > 0)
	assert(bool((report["checks"] as Dictionary)["has_safe_risky_branch_intent"]))

	var start := _node_by_id(report, "start")
	assert(start["node_type"] == "start")
	assert((start["encounter"] as Dictionary).is_empty())
	assert(not bool(start["has_generated_encounter_payload"]))

	var combat_node := _first_combat_node(report)
	assert(not combat_node.is_empty())
	assert((combat_node["outgoing_node_ids"] as Array).size() >= 1 or combat_node["node_type"] == "boss")
	assert((combat_node["route_preview"] as Dictionary)["biome"] == "Graveyard")
	assert((combat_node["combat_preview"] as Dictionary).has("defense_overrides"))
	assert((combat_node["debug_preview"] as Dictionary).has("raw_archetype_ids"))
	assert(bool(combat_node["has_generated_encounter_payload"]))
	assert(bool(combat_node["has_combat_preview"]))
	assert(bool(combat_node["has_debug_preview"]))
	assert((combat_node["debug_preview"] as Dictionary).has("node_modifier_ids"))
	assert(String(combat_node["branch_intent"]) != "")
	assert(not (combat_node["branch_intent_tags"] as Array).is_empty())
	assert((combat_node["debug_preview"] as Dictionary)["branch_intent"] == combat_node["branch_intent"])
	assert(((combat_node["debug_preview"] as Dictionary)["branch_intent_tags"] as Array) == (combat_node["branch_intent_tags"] as Array))
	assert((combat_node["encounter"] as Dictionary)["branch_intent"] == combat_node["branch_intent"])
	assert((combat_node["generated_modifier_ids"] as Array) == ((combat_node["encounter"] as Dictionary)["node_modifier_ids"] as Array))
	var boss_node := _node_by_type(report, "boss")
	assert(not boss_node.is_empty())
	assert(String(boss_node["boss_variant_model_version"]) == RouteGeneratorScript.BOSS_VARIANT_MODEL_VERSION)
	assert(String(boss_node["boss_variant_id"]) != "")
	assert(String(boss_node["boss_variant_label"]) != "")
	assert((boss_node["route_preview"] as Dictionary)["boss_variant_label"] == boss_node["boss_variant_label"])
	assert((boss_node["debug_preview"] as Dictionary)["boss_variant_id"] == boss_node["boss_variant_id"])
	assert((boss_node["encounter"] as Dictionary)["boss_variant_id"] == boss_node["boss_variant_id"])

	var encounter: Dictionary = combat_node["encounter"]
	assert(int(encounter["source_seed"]) > 0)
	assert(encounter["generator_version"] == RuntimeMonsterGenerator.GENERATOR_VERSION)
	assert(encounter["library_schema"] == RuntimeArchetypeLibraryLoader.EXPECTED_SCHEMA)
	assert(["normal", "elite", "boss"].has(String(encounter["kind"])))
	assert(int(encounter["difficulty_id"]) > 0)
	assert(String(encounter["tempo_profile"]) != "")
	assert(not (encounter["archetype_ids"] as Array).is_empty())
	assert(not (encounter["selected_mechanic_ids"] as Array).is_empty())
	assert(not (encounter["defense_overrides"] as Dictionary).is_empty())
	assert(String(encounter["pressure_status"]) != "")
	assert(float(encounter["required_dps"]) > 0.0)
	assert(int(encounter["effective_hp"]) > 0)

	var generated_reward := _first_generated_gear_reward(report)
	assert(not generated_reward.is_empty())
	assert(String(generated_reward["generated_gear_tier_label"]) != "")
	assert(not (generated_reward["generated_gear_slot_labels"] as Array).is_empty())
	assert(not (generated_reward["generated_gear_item_families"] as Array).is_empty())


func _check_report_contains_t5_intent_coverage() -> void:
	var elite_detour_seen := false
	var pressure_gauntlet_seen := false
	var wide_matchup_seen := false
	var fork_rejoin_seen := false
	var boss_approach_seen := false
	for seed in range(3000, 3040):
		var report: Dictionary = GeneratedRouteInspectorScript.inspect(int(seed), {
			"route_difficulty": "hard",
			"allowed_biomes": ["Swamp", "Cave"],
		})
		var checks: Dictionary = report["checks"]
		elite_detour_seen = elite_detour_seen or bool(checks["has_elite_detour_intent"])
		pressure_gauntlet_seen = pressure_gauntlet_seen or bool(checks["has_pressure_gauntlet_intent"])
		wide_matchup_seen = wide_matchup_seen or bool(checks["has_wide_matchup_choice_intent"])
		fork_rejoin_seen = fork_rejoin_seen or bool(checks["has_fork_rejoin_intent"])
		boss_approach_seen = boss_approach_seen or bool(checks["has_boss_approach_lane_variation"])
	assert(elite_detour_seen)
	assert(pressure_gauntlet_seen)
	assert(wide_matchup_seen)
	assert(fork_rejoin_seen)
	assert(boss_approach_seen)


func _check_report_contains_elite_variant() -> void:
	var report := {}
	var elite_node := {}
	for seed in range(3000, 3040):
		report = GeneratedRouteInspectorScript.inspect(int(seed), {
			"route_difficulty": "hard",
			"allowed_biomes": ["Swamp", "Cave"],
		})
		elite_node = _node_by_type(report, "elite")
		if not elite_node.is_empty():
			break
	assert(not elite_node.is_empty())
	assert(String(elite_node["elite_variant_model_version"]) == RouteGeneratorScript.ELITE_VARIANT_MODEL_VERSION)
	assert(String(elite_node["elite_variant_id"]) != "")
	assert(String(elite_node["elite_variant_label"]) != "")
	assert((elite_node["route_preview"] as Dictionary)["elite_variant_label"] == elite_node["elite_variant_label"])
	assert((elite_node["debug_preview"] as Dictionary)["elite_variant_id"] == elite_node["elite_variant_id"])
	assert((elite_node["encounter"] as Dictionary)["elite_variant_id"] == elite_node["elite_variant_id"])
	assert(String((elite_node["encounter"] as Dictionary)["elite_variant_pressure_axis"]) != "")


func _check_route_preview_remains_sparse() -> void:
	var report: Dictionary = GeneratedRouteInspectorScript.inspect(5150, {
		"allowed_biomes": ["Ancient Ruins"],
	})
	for node in report["nodes"]:
		var summary: Dictionary = node
		var preview: Dictionary = summary["route_preview"]
		assert(preview.has("biome"))
		assert(preview.has("monster_name"))
		assert(preview.has("encounter_level"))
		assert(preview.has("archetype_tags"))
		assert(not preview.has("source_seed"))
		assert(not preview.has("budget_metadata"))
		assert(not preview.has("pressure_metadata"))
		assert(not preview.has("defense_overrides"))
		assert(not preview.has("route_modifier_ids"))
		assert(not preview.has("node_modifier_ids"))
		assert(not preview.has("elite_variant_id"))
		assert(not preview.has("elite_variant_model_version"))
		assert(not preview.has("boss_variant_id"))
		assert(not preview.has("boss_variant_model_version"))
		assert(not preview.has("branch_intent"))
		assert(not preview.has("branch_intent_tags"))
		if summary["node_type"] != "start":
			assert(not (summary["combat_preview"] as Dictionary).is_empty())
			assert(not (summary["debug_preview"] as Dictionary).is_empty())


func _check_text_formatter_is_useful() -> void:
	var report: Dictionary = _first_report_with_node_type("elite", {
		"route_difficulty": "hard",
		"allowed_biomes": ["Swamp", "Cave"],
	})
	assert(not report.is_empty())
	var text: String = GeneratedRouteInspectorScript.format_text(report)
	assert(text.contains("Generated Route Inspection"))
	assert(text.contains("Seed:"))
	assert(text.contains("Template Label:"))
	assert(text.contains("Nodes"))
	assert(text.contains("mechanics:"))
	assert(text.contains("pressure:"))
	assert(text.contains("branch intent:"))
	assert(text.contains("elite variant:"))
	assert(text.contains("boss variant:"))


func _first_report_with_node_type(node_type: String, settings: Dictionary) -> Dictionary:
	for seed in range(3000, 3040):
		var report: Dictionary = GeneratedRouteInspectorScript.inspect(int(seed), settings)
		if not _node_by_type(report, node_type).is_empty():
			return report
	return {}


func _node_by_id(report: Dictionary, node_id: String) -> Dictionary:
	for node in report["nodes"]:
		var summary: Dictionary = node
		if summary["id"] == node_id:
			return summary
	return {}


func _first_combat_node(report: Dictionary) -> Dictionary:
	for node in report["nodes"]:
		var summary: Dictionary = node
		if summary["node_type"] != "start":
			return summary
	return {}


func _first_generated_gear_reward(report: Dictionary) -> Dictionary:
	for node in report["nodes"]:
		var summary: Dictionary = node
		var reward: Dictionary = summary["reward"]
		if int(reward.get("generated_gear_choice_count", 0)) > 0:
			return reward
	return {}


func _node_by_type(report: Dictionary, node_type: String) -> Dictionary:
	for node in report["nodes"]:
		var summary: Dictionary = node
		if summary["node_type"] == node_type:
			return summary
	return {}
