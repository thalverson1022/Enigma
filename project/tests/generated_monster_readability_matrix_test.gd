extends SceneTree
## Focused P4M4-T9 check: representative runtime-generated monsters across
## difficulties, archetypes, kinds, and tempos produce stable, non-empty
## encounter preview metadata while contract-map previews stay sparse.
## Run with:
##   godot --headless -s res://tests/generated_monster_readability_matrix_test.gd

const EncounterPreviewFormatterScript := preload("res://scripts/systems/runtime_monster_generator/encounter_preview_formatter.gd")


func _initialize() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	assert(not library.has_errors())

	_check_representative_readability_matrix(library)
	_check_every_runtime_archetype_can_preview(library)
	print("Generated monster readability matrix check: OK")
	quit()


func _check_representative_readability_matrix(library: RuntimeArchetypeLibrary) -> void:
	var seen_difficulties := {}
	var seen_kinds := {}
	var seen_tempos := {}
	var paired_case_count := 0

	for case in _matrix_cases():
		var draft := _generate_case(case, library)
		assert(not draft.has_errors())
		var preview: Dictionary = EncounterPreviewFormatterScript.format_generated(draft, {
			"biome": case["biome"],
			"encounter_level": case["kind"],
		})
		_assert_preview_is_readable(case, draft, preview)
		_assert_same_seed_preview_is_stable(case, draft, preview, library)

		seen_difficulties[int(case["difficulty"])] = true
		seen_kinds[String(case["kind"])] = true
		seen_tempos[String(case["tempo"])] = true
		if String(case.get("archetype_b", "")) != "":
			paired_case_count += 1

	for difficulty in [1, 2, 3, 4, 5]:
		assert(seen_difficulties.has(difficulty))
	for kind in ["normal", "elite", "boss"]:
		assert(seen_kinds.has(kind))
	for tempo in ["standard", "burst", "extended", "endurance"]:
		assert(seen_tempos.has(tempo))
	assert(paired_case_count >= 3)


func _check_every_runtime_archetype_can_preview(library: RuntimeArchetypeLibrary) -> void:
	assert(library.archetypes.size() >= 1)
	for archetype in library.archetypes:
		var kind := String(archetype.allowed_kinds[0])
		var case := {
			"id": "coverage_%s" % archetype.id,
			"seed": 45000 + library.archetypes.find(archetype),
			"archetype_a": archetype.id,
			"difficulty": archetype.unlock_difficulty,
			"kind": kind,
			"tempo": "standard",
			"biome": "Coverage",
		}
		var draft := _generate_case(case, library)
		assert(not draft.has_errors())
		var preview: Dictionary = EncounterPreviewFormatterScript.format_generated(draft, {
			"biome": "Coverage",
			"encounter_level": kind,
		})
		_assert_preview_is_readable(case, draft, preview)


func _matrix_cases() -> Array:
	return [
		{
			"id": "easy_armored_normal_standard",
			"seed": 41001,
			"archetype_a": "armored",
			"difficulty": 1,
			"kind": "normal",
			"tempo": "standard",
			"biome": "Roadside",
		},
		{
			"id": "medium_fortified_warded_normal_burst",
			"seed": 41002,
			"archetype_a": "fortified",
			"archetype_b": "warded",
			"difficulty": 2,
			"kind": "normal",
			"tempo": "burst",
			"biome": "City",
		},
		{
			"id": "hard_nimble_hexed_elite_extended",
			"seed": 41003,
			"archetype_a": "nimble",
			"archetype_b": "hexed",
			"difficulty": 3,
			"kind": "elite",
			"tempo": "extended",
			"biome": "Fen",
		},
		{
			"id": "ultra_relentless_arcane_elite_standard",
			"seed": 41004,
			"archetype_a": "relentless",
			"archetype_b": "arcane",
			"difficulty": 4,
			"kind": "elite",
			"tempo": "standard",
			"biome": "Archive",
		},
		{
			"id": "nightmare_unstable_devious_boss_endurance",
			"seed": 41005,
			"archetype_a": "unstable",
			"archetype_b": "devious",
			"difficulty": 5,
			"kind": "boss",
			"tempo": "endurance",
			"biome": "Vault",
		},
		{
			"id": "easy_resistant_normal_extended",
			"seed": 41006,
			"archetype_a": "resistant",
			"difficulty": 1,
			"kind": "normal",
			"tempo": "extended",
			"biome": "Bog",
		},
	]


func _generate_case(case: Dictionary, library: RuntimeArchetypeLibrary) -> GeneratedMonsterDraft:
	return RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": case["seed"],
		"archetypeA": case["archetype_a"],
		"archetypeB": case.get("archetype_b", ""),
		"difficulty": case["difficulty"],
		"kind": case["kind"],
		"tempoProfile": case["tempo"],
	}), library)


func _assert_preview_is_readable(case: Dictionary, draft: GeneratedMonsterDraft, preview: Dictionary) -> void:
	assert(preview.has("contract_map"))
	assert(preview.has("combat"))
	assert(preview.has("debug"))

	var contract_map: Dictionary = preview["contract_map"]
	assert(contract_map.keys().size() == 5)
	assert(contract_map["biome"] == case["biome"])
	assert(String(contract_map["monster_name"]).length() > 0)
	assert(String(contract_map["encounter_level"]) == String(case["kind"]).capitalize())
	assert((contract_map["archetype_tags"] as Array).size() == draft.archetype_ids.size())
	assert(String(contract_map["archetype_line"]).length() > 0)
	assert(not contract_map.has("source_seed"))
	assert(not contract_map.has("difficulty"))
	assert(not contract_map.has("budget_metadata"))
	assert(not contract_map.has("pressure_metadata"))
	assert(not contract_map.has("defense_overrides"))
	assert(not contract_map.has("selected_mechanics"))
	assert(not contract_map.has("archetype_summaries"))
	assert(not contract_map.has("hp"))

	var combat: Dictionary = preview["combat"]
	assert(String(combat["monster_name"]).length() > 0)
	assert(int(combat["hp"]) > 0)
	assert(int(combat["duration_seconds"]) > 0)
	assert(String(combat["encounter_level"]) == String(case["kind"]).capitalize())
	assert((combat["archetype_tags"] as Array).size() == draft.archetype_ids.size())
	assert((combat["archetype_summaries"] as Array).size() == draft.archetype_ids.size())
	assert((combat["defense_overrides"] as Dictionary).size() > 0)
	assert((combat["selected_mechanics"] as Array).size() > 0)

	var debug: Dictionary = preview["debug"]
	assert(int(debug["source_seed"]) == int(case["seed"]))
	assert(int(debug["difficulty_id"]) == int(case["difficulty"]))
	assert(String(debug["monster_kind"]) == String(case["kind"]))
	assert(String(debug["tempo_profile"]) == String(case["tempo"]))
	assert((debug["raw_archetype_ids"] as Array).size() == draft.archetype_ids.size())
	assert((debug["archetype_language"] as Array).size() == draft.archetype_ids.size())
	assert((debug["tags"] as Array).size() > 0)
	assert((debug["selected_mechanics"] as Array).size() > 0)
	assert((debug["budget_metadata"] as Dictionary).size() > 0)
	assert((debug["pressure_metadata"] as Dictionary).size() > 0)
	assert(debug.has("notices"))
	assert(debug["notices"] is Array)


func _assert_same_seed_preview_is_stable(case: Dictionary, draft: GeneratedMonsterDraft, preview: Dictionary, library: RuntimeArchetypeLibrary) -> void:
	var repeated := _generate_case(case, library)
	assert(not repeated.has_errors())
	var repeated_preview: Dictionary = EncounterPreviewFormatterScript.format_generated(repeated, {
		"biome": case["biome"],
		"encounter_level": case["kind"],
	})
	assert(JSON.stringify(draft.to_dictionary()) == JSON.stringify(repeated.to_dictionary()))
	assert(JSON.stringify(preview) == JSON.stringify(repeated_preview))
