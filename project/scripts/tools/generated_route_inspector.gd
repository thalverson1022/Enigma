class_name GeneratedRouteInspector
extends RefCounted

const VERSION := "p4m5.t8.v1"
const ROUTE_GENERATOR := preload("res://scripts/systems/contract_route_generator/contract_route_generator.gd")


static func inspect(seed: int = 4242, settings: Dictionary = {}) -> Dictionary:
	var contract: ContractDef = ROUTE_GENERATOR.generate(seed, settings)
	var nodes := _collect_nodes(contract.offer_node)
	var report := {
		"version": VERSION,
		"source": "generated_route_inspector",
		"seed": seed,
		"settings": settings.duplicate(true),
		"route": _route_summary(contract),
		"validation_notices": Array(ROUTE_GENERATOR.validate(contract)),
		"nodes": [],
		"checks": _checks(nodes),
	}
	for node in nodes:
		report["nodes"].append(_node_summary(node))
	return report


static func report_signature(report: Dictionary) -> String:
	return JSON.stringify(report)


static func format_text(report: Dictionary) -> String:
	var route: Dictionary = report.get("route", {})
	var lines := PackedStringArray()
	lines.append("Generated Route Inspection")
	lines.append("Seed: %d | Route: %s | Template: %s | Biome: %s" % [
		int(report.get("seed", 0)),
		String(route.get("generated_route_id", "")),
		String(route.get("template_id", "")),
		String(route.get("selected_biome", "")),
	])
	lines.append("Template Label: %s | Width: %s" % [
		String(route.get("template_display_label", "")),
		JSON.stringify(route.get("template_width_summary", {})),
	])
	lines.append("Versions: route %s | presentation %s | monster %s | archetypes %s" % [
		String(route.get("generator_version", "")),
		String(route.get("biome_table_version", "")),
		String(route.get("runtime_monster_generator_version", "")),
		String(route.get("runtime_monster_archetype_library_version", "")),
	])
	var notices: Array = report.get("validation_notices", [])
	lines.append("Validation: %s" % ("OK" if notices.is_empty() else ", ".join(_string_array(notices))))
	lines.append("Modifiers: %s" % ", ".join(_string_array(route.get("generated_modifier_ids", []))))
	lines.append("")
	lines.append("Nodes")
	for node in report.get("nodes", []):
		var summary: Dictionary = node
		var preview: Dictionary = summary.get("route_preview", {})
		lines.append("- %s [%s d%d/l%d] -> %s" % [
			String(summary.get("id", "")),
			String(summary.get("node_type", "")),
			int(summary.get("depth", -1)),
			int(summary.get("lane", -1)),
			", ".join(_string_array(summary.get("outgoing_node_ids", []))),
		])
		lines.append("  %s | %s | %s | %s" % [
			String(preview.get("biome", "")),
			String(preview.get("monster_name", "")),
			String(preview.get("encounter_level", "")),
			", ".join(_string_array(preview.get("archetype_tags", []))),
		])
		var encounter: Dictionary = summary.get("encounter", {})
		if not encounter.is_empty():
			lines.append("  seed %d | difficulty %d | %s | %s | %s" % [
				int(encounter.get("source_seed", 0)),
				int(encounter.get("difficulty_id", 0)),
				String(encounter.get("kind", "")),
				String(encounter.get("tempo_profile", "")),
				", ".join(_string_array(encounter.get("archetype_ids", []))),
			])
			lines.append("  mechanics: %s" % ", ".join(_string_array(encounter.get("selected_mechanic_ids", []))))
			lines.append("  pressure: %s | req DPS %.2f | eHP %d" % [
				String(encounter.get("pressure_status", "")),
				float(encounter.get("required_dps", 0.0)),
				int(encounter.get("effective_hp", 0)),
			])
		var reward: Dictionary = summary.get("reward", {})
		if not reward.is_empty():
			lines.append("  reward: %s" % String(reward.get("summary", "")))
		if String(summary.get("branch_intent", "")) != "":
			lines.append("  branch intent: %s | %s" % [
				String(summary.get("branch_intent", "")),
				", ".join(_string_array(summary.get("branch_intent_tags", []))),
			])
		var modifiers: Array = summary.get("generated_modifier_labels", [])
		if not modifiers.is_empty():
			lines.append("  modifiers: %s" % ", ".join(_string_array(modifiers)))
		if String(summary.get("elite_variant_label", "")) != "":
			lines.append("  elite variant: %s" % String(summary.get("elite_variant_label", "")))
		if String(summary.get("boss_variant_label", "")) != "":
			lines.append("  boss variant: %s" % String(summary.get("boss_variant_label", "")))
	return "\n".join(lines)


static func _route_summary(contract: ContractDef) -> Dictionary:
	return {
		"contract_id": contract.id,
		"generated_route_id": contract.generated_route_id,
		"source_seed": contract.source_seed,
		"generator_version": contract.generator_version,
		"route_difficulty": contract.route_difficulty,
		"selected_biome": contract.selected_biome,
		"allowed_biomes": Array(contract.allowed_biomes),
		"biome_table_version": contract.biome_table_version,
		"runtime_monster_generator_version": contract.runtime_monster_generator_version,
		"runtime_monster_archetype_library_version": contract.runtime_monster_archetype_library_version,
		"modifier_model_version": contract.modifier_model_version,
		"generated_modifier_ids": Array(contract.generated_modifier_ids),
		"generated_modifiers": contract.generated_modifiers.duplicate(true),
		"template_id": contract.template_id,
		"template_display_label": contract.template_display_label,
		"template_width_summary": contract.template_width_summary.duplicate(true),
		"pacing_profile": String(contract.route_settings.get("pacing_profile", "")),
		"route_settings": contract.route_settings.duplicate(true),
		"route_notices": Array(contract.route_notices),
	}


static func _node_summary(node: ContractRouteNode) -> Dictionary:
	return {
		"id": node.generated_node_id,
		"resource_id": node.id,
		"node_type": _node_type_label(node.node_type),
		"depth": node.depth,
		"lane": node.lane,
		"outgoing_node_ids": Array(node.outgoing_node_ids),
		"biome": node.biome,
		"monster_presentation_type": node.monster_presentation_type,
		"display_name": node.display_name,
		"route_preview": node.route_preview.duplicate(true),
		"reward": _reward_summary(node),
		"encounter": _encounter_summary(node),
		"combat_preview": node.combat_preview.duplicate(true),
		"debug_preview": node.debug_preview.duplicate(true),
		"generated_modifier_ids": Array(node.generated_modifier_ids),
		"generated_modifier_labels": Array(node.generated_modifier_labels),
		"branch_intent": node.branch_intent,
		"branch_intent_tags": Array(node.branch_intent_tags),
		"elite_variant_model_version": node.elite_variant_model_version,
		"elite_variant_id": node.elite_variant_id,
		"elite_variant_label": node.elite_variant_label,
		"boss_variant_model_version": node.boss_variant_model_version,
		"boss_variant_id": node.boss_variant_id,
		"boss_variant_label": node.boss_variant_label,
		"generation_notices": Array(node.generation_notices),
		"has_generated_encounter_payload": not node.generated_encounter_payload.is_empty(),
		"has_combat_preview": not node.combat_preview.is_empty(),
		"has_debug_preview": not node.debug_preview.is_empty(),
	}


static func _reward_summary(node: ContractRouteNode) -> Dictionary:
	if node.reward == null:
		return {}
	return {
		"gold_amount": node.reward.gold_amount,
		"talent_points": node.reward.talent_points,
		"generated_gear_choice_count": node.reward.generated_gear_choice_count,
		"generated_gear_tier": node.reward.generated_gear_tier,
		"generated_gear_slots": node.reward.generated_gear_slots.duplicate(),
		"quality_label": node.reward_quality_label,
		"summary": node.reward_summary,
	}


static func _encounter_summary(node: ContractRouteNode) -> Dictionary:
	if node.generated_encounter_payload.is_empty():
		return {}
	var payload := node.generated_encounter_payload
	var input: Dictionary = payload.get("source_input", {})
	var pressure: Dictionary = payload.get("pressure_metadata", {})
	return {
		"id": String(payload.get("id", "")),
		"display_name": String(payload.get("display_name", "")),
		"source_seed": int(payload.get("source_seed", 0)),
		"generator_version": String(input.get("generator_version", "")),
		"library_schema": String(input.get("library_schema", "")),
		"difficulty_id": int(input.get("difficulty_id", 0)),
		"kind": String(input.get("monster_kind", "")),
		"tempo_profile": String(input.get("tempo_profile", "")),
		"archetype_ids": _string_array(payload.get("archetype_ids", [])),
		"tags": _string_array(payload.get("tags", [])),
		"selected_mechanic_ids": _selected_mechanic_ids(payload.get("selected_mechanics", [])),
		"selected_mechanics": (payload.get("selected_mechanics", []) as Array).duplicate(true),
		"defense_overrides": (payload.get("defense_overrides", {}) as Dictionary).duplicate(true),
		"budget_metadata": (payload.get("budget_metadata", {}) as Dictionary).duplicate(true),
		"pressure_status": String(pressure.get("status", "")),
		"required_dps": float(pressure.get("required_dps", 0.0)),
		"effective_hp": int(pressure.get("effective_hp", 0)),
		"pressure_metadata": pressure.duplicate(true),
		"route_modifier_ids": _string_array(payload.get("route_modifier_ids", [])),
		"node_modifier_ids": _string_array(payload.get("node_modifier_ids", [])),
		"modifier_model_version": String(payload.get("modifier_model_version", "")),
		"branch_intent": String(payload.get("branch_intent", "")),
		"branch_intent_tags": _string_array(payload.get("branch_intent_tags", [])),
		"elite_variant_model_version": String(payload.get("elite_variant_model_version", "")),
		"elite_variant_id": String(payload.get("elite_variant_id", "")),
		"elite_variant_label": String(payload.get("elite_variant_label", "")),
		"elite_variant_pressure_axis": String(payload.get("elite_variant_pressure_axis", "")),
		"boss_variant_model_version": String(payload.get("boss_variant_model_version", "")),
		"boss_variant_id": String(payload.get("boss_variant_id", "")),
		"boss_variant_label": String(payload.get("boss_variant_label", "")),
		"boss_variant_pressure_axis": String(payload.get("boss_variant_pressure_axis", "")),
		"notices": (payload.get("notices", []) as Array).duplicate(true),
	}


static func _checks(nodes: Array[ContractRouteNode]) -> Dictionary:
	var combat_nodes := 0
	var captain_nodes := 0
	var safe_intent_nodes := 0
	var risky_intent_nodes := 0
	var high_reward_intent_nodes := 0
	var elite_detour_nodes := 0
	var pressure_gauntlet_nodes := 0
	var wide_matchup_nodes := 0
	var fork_rejoin_nodes := 0
	var boss_approach_nodes := 0
	var boss_approach_roles := {}
	var missing_payload := []
	var missing_combat_preview := []
	var missing_debug_preview := []
	for node in nodes:
		if node.node_type == ContractRouteNode.NodeType.START:
			continue
		combat_nodes += 1
		if node.node_type == ContractRouteNode.NodeType.CAPTAIN:
			captain_nodes += 1
		if node.branch_intent_tags.has("safe"):
			safe_intent_nodes += 1
		if node.branch_intent_tags.has("risky"):
			risky_intent_nodes += 1
		if node.branch_intent_tags.has("high_reward"):
			high_reward_intent_nodes += 1
		if node.branch_intent_tags.has("elite_detour"):
			elite_detour_nodes += 1
		if node.branch_intent_tags.has("pressure_gauntlet"):
			pressure_gauntlet_nodes += 1
		if node.branch_intent_tags.has("wide_matchup_choice"):
			wide_matchup_nodes += 1
		if node.branch_intent_tags.has("fork_rejoin"):
			fork_rejoin_nodes += 1
		if node.branch_intent_tags.has("boss_approach"):
			boss_approach_nodes += 1
			if node.branch_intent_tags.has("safe_boss_approach"):
				boss_approach_roles["safe"] = true
			if node.branch_intent_tags.has("captain_boss_approach"):
				boss_approach_roles["captain"] = true
			if node.branch_intent_tags.has("elite_boss_approach"):
				boss_approach_roles["elite"] = true
			if node.branch_intent_tags.has("reward_boss_approach"):
				boss_approach_roles["reward"] = true
		if node.generated_encounter_payload.is_empty():
			missing_payload.append(node.generated_node_id)
		if node.combat_preview.is_empty():
			missing_combat_preview.append(node.generated_node_id)
		if node.debug_preview.is_empty():
			missing_debug_preview.append(node.generated_node_id)
	return {
		"combat_node_count": combat_nodes,
		"captain_node_count": captain_nodes,
		"safe_intent_node_count": safe_intent_nodes,
		"risky_intent_node_count": risky_intent_nodes,
		"high_reward_intent_node_count": high_reward_intent_nodes,
		"elite_detour_node_count": elite_detour_nodes,
		"pressure_gauntlet_node_count": pressure_gauntlet_nodes,
		"wide_matchup_choice_node_count": wide_matchup_nodes,
		"fork_rejoin_node_count": fork_rejoin_nodes,
		"boss_approach_node_count": boss_approach_nodes,
		"boss_approach_roles": boss_approach_roles.keys(),
		"has_safe_risky_branch_intent": safe_intent_nodes > 0 and risky_intent_nodes > 0,
		"has_elite_detour_intent": elite_detour_nodes > 0,
		"has_pressure_gauntlet_intent": pressure_gauntlet_nodes > 0,
		"has_wide_matchup_choice_intent": wide_matchup_nodes > 0,
		"has_fork_rejoin_intent": fork_rejoin_nodes > 0,
		"has_boss_approach_lane_variation": boss_approach_nodes >= 2 and boss_approach_roles.size() >= 2,
		"missing_payload": missing_payload,
		"missing_combat_preview": missing_combat_preview,
		"missing_debug_preview": missing_debug_preview,
		"all_combat_nodes_have_payloads": missing_payload.is_empty(),
		"all_combat_nodes_have_previews": missing_combat_preview.is_empty() and missing_debug_preview.is_empty(),
	}


static func _collect_nodes(start: ContractRouteNode) -> Array[ContractRouteNode]:
	var result: Array[ContractRouteNode] = []
	var visited := {}
	_collect_nodes_recursive(start, visited, result)
	result.sort_custom(func(a: ContractRouteNode, b: ContractRouteNode): return a.depth < b.depth if a.depth != b.depth else a.lane < b.lane)
	return result


static func _collect_nodes_recursive(node: ContractRouteNode, visited: Dictionary, result: Array[ContractRouteNode]) -> void:
	if node == null or visited.has(node.generated_node_id):
		return
	visited[node.generated_node_id] = true
	result.append(node)
	for next_node in node.next_nodes:
		_collect_nodes_recursive(next_node, visited, result)


static func _node_type_label(node_type: int) -> String:
	match node_type:
		ContractRouteNode.NodeType.START:
			return "start"
		ContractRouteNode.NodeType.ELITE:
			return "elite"
		ContractRouteNode.NodeType.BOSS:
			return "boss"
		ContractRouteNode.NodeType.FIGHT:
			return "fight"
		ContractRouteNode.NodeType.CAPTAIN:
			return "captain"
		ContractRouteNode.NodeType.OFFER:
			return "offer"
		ContractRouteNode.NodeType.SUBCLASS_CHOICE:
			return "subclass_choice"
	return "unknown"


static func _selected_mechanic_ids(mechanics: Array) -> Array:
	var result := []
	for entry in mechanics:
		result.append(String(entry.get("id", "")))
	return result


static func _string_array(values: Variant) -> Array:
	var result := []
	for value in values:
		result.append(String(value))
	return result
