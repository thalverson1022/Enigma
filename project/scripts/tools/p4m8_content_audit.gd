extends SceneTree
## One-off P4M8-T1 generated content audit.
## Run with:
##   godot --headless --path project -s res://scripts/tools/p4m8_content_audit.gd

const ROUTE_GENERATOR := preload("res://scripts/systems/contract_route_generator/contract_route_generator.gd")
const GeneratedRouteInspectorScript := preload("res://scripts/tools/generated_route_inspector.gd")


func _initialize() -> void:
	var summary := {
		"static": _static_summary(),
		"sample": _sample_routes(),
	}
	print(JSON.stringify(_compact_summary(summary), "\t"))
	quit()


func _static_summary() -> Dictionary:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var archetypes := []
	var mechanics_by_archetype := {}
	var required_by_archetype := {}
	var kind_counts := {}
	for archetype in library.archetypes:
		var def: RuntimeArchetypeDef = archetype
		archetypes.append(def.id)
		mechanics_by_archetype[def.id] = def.mechanic_weights.keys()
		var required := []
		for mechanic_id in def.mechanic_configs:
			var config: RuntimeMechanicConfig = def.mechanic_configs[mechanic_id]
			if config.required:
				required.append(mechanic_id)
		required_by_archetype[def.id] = required
		for kind in def.allowed_kinds:
			kind_counts[String(kind)] = int(kind_counts.get(String(kind), 0)) + 1
	archetypes.sort()

	var mechanics := []
	for mechanic in RuntimeMechanicLibrary.built_in().mechanics:
		mechanics.append((mechanic as RuntimeMechanicDef).id)
	mechanics.sort()

	var biome_names := ROUTE_GENERATOR.BIOME_PRESENTATION.keys()
	biome_names.sort()
	var biome_pool_counts := {}
	for biome in biome_names:
		var table: Dictionary = ROUTE_GENERATOR.BIOME_PRESENTATION[biome]
		biome_pool_counts[biome] = {
			"normal": (table.get("normal", []) as Array).size(),
			"elite": (table.get("elite", []) as Array).size(),
			"boss": (table.get("boss", []) as Array).size(),
		}

	return {
		"archetype_count": archetypes.size(),
		"archetypes": archetypes,
		"kind_counts": kind_counts,
		"mechanic_count": mechanics.size(),
		"mechanics": mechanics,
		"mechanics_by_archetype": mechanics_by_archetype,
		"required_by_archetype": required_by_archetype,
		"biome_count": biome_names.size(),
		"biomes": biome_names,
		"biome_pool_counts": biome_pool_counts,
		"template_count": ROUTE_GENERATOR.TEMPLATES.size(),
		"archetype_tag_set_count": ROUTE_GENERATOR.ARCHETYPE_TAG_SETS.size(),
		"archetype_tag_sets": ROUTE_GENERATOR.ARCHETYPE_TAG_SETS,
		"modifier_model_version": ROUTE_GENERATOR.MODIFIER_MODEL_VERSION,
		"modifier_catalog_count": ROUTE_GENERATOR.MODIFIER_CATALOG.size(),
		"modifier_catalog_ids": _modifier_catalog_ids(),
		"elite_variant_model_version": ROUTE_GENERATOR.ELITE_VARIANT_MODEL_VERSION,
		"elite_variant_catalog_count": ROUTE_GENERATOR.ELITE_VARIANT_CATALOG.size(),
		"elite_variant_catalog_ids": _elite_variant_catalog_ids(),
		"boss_variant_model_version": ROUTE_GENERATOR.BOSS_VARIANT_MODEL_VERSION,
		"boss_variant_catalog_count": ROUTE_GENERATOR.BOSS_VARIANT_CATALOG.size(),
		"boss_variant_catalog_ids": _boss_variant_catalog_ids(),
	}


func _sample_routes() -> Dictionary:
	var cases := [
		{"name": "default_medium", "settings": {"route_difficulty": "medium"}, "seeds": range(4000, 4060)},
		{"name": "hard_all_biomes", "settings": {"route_difficulty": "hard"}, "seeds": range(4100, 4160)},
		{"name": "nightmare_all_biomes", "settings": {"route_difficulty": "nightmare"}, "seeds": range(4200, 4260)},
		{"name": "later_contract_pressure", "settings": {"route_difficulty": "medium", "completed_contract_count": 3}, "seeds": range(4300, 4360)},
	]
	var aggregate := _empty_sample_counts()
	var by_case := {}
	for case in cases:
		var counts := _empty_sample_counts()
		for seed in case["seeds"]:
			_sample_one(int(seed), case["settings"], counts)
		by_case[String(case["name"])] = counts
		_merge_counts(aggregate, counts)
	return {
		"case_count": cases.size(),
		"route_count": aggregate["route_count"],
		"combat_node_count": aggregate["combat_node_count"],
		"by_case": by_case,
		"aggregate": aggregate,
	}


func _empty_sample_counts() -> Dictionary:
	return {
		"route_count": 0,
		"combat_node_count": 0,
		"templates": {},
		"route_biomes": {},
		"node_biomes": {},
		"node_kinds": {},
		"presentation_names": {},
		"archetypes": {},
		"archetype_pairs": {},
		"mechanics": {},
		"mechanic_pairs": {},
		"pressure_axes": {},
		"secondary_pressure_axes": {},
		"tempo_profiles": {},
		"route_modifiers": {},
		"node_modifiers": {},
		"elite_variants": {},
		"elite_variant_axes": {},
		"boss_variants": {},
		"boss_variant_axes": {},
		"validation_notices": {},
	}


func _sample_one(seed: int, settings: Dictionary, counts: Dictionary) -> void:
	var report: Dictionary = GeneratedRouteInspectorScript.inspect(seed, settings)
	counts["route_count"] += 1
	var route: Dictionary = report.get("route", {})
	_count(counts["templates"], String(route.get("template_id", "")))
	_count(counts["route_biomes"], String(route.get("selected_biome", "")))
	for modifier_id in route.get("generated_modifier_ids", []):
		_count(counts["route_modifiers"], String(modifier_id))
	for notice in report.get("validation_notices", []):
		_count(counts["validation_notices"], String(notice))
	for node in report.get("nodes", []):
		var summary: Dictionary = node
		var node_type := String(summary.get("node_type", ""))
		_count(counts["node_biomes"], String(summary.get("biome", "")))
		_count(counts["node_kinds"], node_type)
		if node_type == "start":
			continue
		counts["combat_node_count"] += 1
		_count(counts["presentation_names"], String(summary.get("monster_presentation_type", "")))
		var encounter: Dictionary = summary.get("encounter", {})
		var archetype_ids: Array = encounter.get("archetype_ids", [])
		for archetype_id in archetype_ids:
			_count(counts["archetypes"], String(archetype_id))
		_count(counts["archetype_pairs"], _joined_sorted(archetype_ids))
		var mechanics: Array = encounter.get("selected_mechanic_ids", [])
		for mechanic_id in mechanics:
			_count(counts["mechanics"], String(mechanic_id))
		_count(counts["mechanic_pairs"], _joined_sorted(mechanics))
		_count(counts["tempo_profiles"], String(encounter.get("tempo_profile", "")))
		var debug: Dictionary = summary.get("debug_preview", {})
		var axes: Dictionary = debug.get("route_pressure_axes", {})
		_count(counts["pressure_axes"], String(axes.get("primary", "")))
		_count(counts["secondary_pressure_axes"], String(axes.get("secondary", "")))
		for modifier_id in summary.get("generated_modifier_ids", []):
			_count(counts["node_modifiers"], String(modifier_id))
		if node_type == "elite":
			_count(counts["elite_variants"], String(summary.get("elite_variant_id", "")))
			_count(counts["elite_variant_axes"], String(encounter.get("elite_variant_pressure_axis", "")))
		if node_type == "boss":
			_count(counts["boss_variants"], String(summary.get("boss_variant_id", "")))
			_count(counts["boss_variant_axes"], String(encounter.get("boss_variant_pressure_axis", "")))


func _merge_counts(target: Dictionary, source: Dictionary) -> void:
	target["route_count"] += int(source["route_count"])
	target["combat_node_count"] += int(source["combat_node_count"])
	for key in target:
		if target[key] is Dictionary:
			for entry in source[key]:
				target[key][entry] = int(target[key].get(entry, 0)) + int(source[key][entry])


func _count(counts: Dictionary, key: String) -> void:
	if key == "":
		key = "<blank>"
	counts[key] = int(counts.get(key, 0)) + 1


func _joined_sorted(values: Array) -> String:
	var parts := PackedStringArray()
	for value in values:
		parts.append(String(value))
	parts.sort()
	return "+".join(parts)


func _compact_summary(summary: Dictionary) -> Dictionary:
	var sample: Dictionary = summary["sample"]
	var aggregate: Dictionary = sample["aggregate"]
	return {
		"static": summary["static"],
		"sample": {
			"route_count": sample["route_count"],
			"combat_node_count": sample["combat_node_count"],
			"templates": aggregate["templates"],
			"route_biomes": aggregate["route_biomes"],
			"node_biomes": aggregate["node_biomes"],
			"node_kinds": aggregate["node_kinds"],
			"archetypes": aggregate["archetypes"],
			"mechanics": aggregate["mechanics"],
			"pressure_axes": aggregate["pressure_axes"],
			"secondary_pressure_axes": aggregate["secondary_pressure_axes"],
			"tempo_profiles": aggregate["tempo_profiles"],
			"route_modifiers": aggregate["route_modifiers"],
			"node_modifiers": aggregate["node_modifiers"],
			"elite_variants": aggregate["elite_variants"],
			"elite_variant_axes": aggregate["elite_variant_axes"],
			"boss_variants": aggregate["boss_variants"],
			"boss_variant_axes": aggregate["boss_variant_axes"],
			"validation_notices": aggregate["validation_notices"],
			"coverage": _coverage_summary(summary["static"], aggregate),
			"unique_archetype_pair_count": (aggregate["archetype_pairs"] as Dictionary).size(),
			"top_archetype_pairs": _top_counts(aggregate["archetype_pairs"], 12),
			"unique_mechanic_set_count": (aggregate["mechanic_pairs"] as Dictionary).size(),
			"top_mechanic_sets": _top_counts(aggregate["mechanic_pairs"], 12),
			"unique_presentation_name_count": (aggregate["presentation_names"] as Dictionary).size(),
			"top_presentation_names": _top_counts(aggregate["presentation_names"], 15),
		}
	}


func _coverage_summary(static_summary: Dictionary, aggregate: Dictionary) -> Dictionary:
	return {
		"template_count": (aggregate["templates"] as Dictionary).size(),
		"template_target": int(static_summary.get("template_count", 0)),
		"pressure_axis_count": (aggregate["pressure_axes"] as Dictionary).size(),
		"pressure_axis_target": ROUTE_GENERATOR.PRESSURE_AXIS_LABELS.size(),
		"route_modifier_count": (aggregate["route_modifiers"] as Dictionary).size(),
		"route_modifier_target": int(static_summary.get("modifier_catalog_count", 0)),
		"missing_route_modifiers": _missing_ids(aggregate["route_modifiers"], static_summary.get("modifier_catalog_ids", [])),
		"elite_variant_count": (aggregate["elite_variants"] as Dictionary).size(),
		"elite_variant_target": int(static_summary.get("elite_variant_catalog_count", 0)),
		"missing_elite_variants": _missing_ids(aggregate["elite_variants"], static_summary.get("elite_variant_catalog_ids", [])),
		"boss_variant_count": (aggregate["boss_variants"] as Dictionary).size(),
		"boss_variant_target": int(static_summary.get("boss_variant_catalog_count", 0)),
		"missing_boss_variants": _missing_ids(aggregate["boss_variants"], static_summary.get("boss_variant_catalog_ids", [])),
		"expanded_archetype_count": _present_id_count(aggregate["archetypes"], ["aegis", "nullify", "spiteful", "riftbound"]),
		"expanded_archetype_target": 4,
		"missing_expanded_archetypes": _missing_ids(aggregate["archetypes"], ["aegis", "nullify", "spiteful", "riftbound"]),
	}


func _present_id_count(seen: Dictionary, expected: Array) -> int:
	var count := 0
	for id in expected:
		if seen.has(String(id)):
			count += 1
	return count


func _missing_ids(seen: Dictionary, expected: Array) -> Array:
	var missing := []
	for id in expected:
		if not seen.has(String(id)):
			missing.append(String(id))
	return missing


func _top_counts(counts: Dictionary, limit: int) -> Array:
	var entries := []
	for key in counts:
		entries.append({"id": String(key), "count": int(counts[key])})
	entries.sort_custom(func(a: Dictionary, b: Dictionary): return int(a["count"]) > int(b["count"]) if int(a["count"]) != int(b["count"]) else String(a["id"]) < String(b["id"]))
	return entries.slice(0, mini(limit, entries.size()))


func _modifier_catalog_ids() -> Array:
	var ids := []
	for modifier in ROUTE_GENERATOR.MODIFIER_CATALOG:
		ids.append(String((modifier as Dictionary).get("id", "")))
	return ids


func _elite_variant_catalog_ids() -> Array:
	var ids := []
	for variant in ROUTE_GENERATOR.ELITE_VARIANT_CATALOG:
		ids.append(String((variant as Dictionary).get("id", "")))
	return ids


func _boss_variant_catalog_ids() -> Array:
	var ids := []
	for variant in ROUTE_GENERATOR.BOSS_VARIANT_CATALOG:
		ids.append(String((variant as Dictionary).get("id", "")))
	return ids
