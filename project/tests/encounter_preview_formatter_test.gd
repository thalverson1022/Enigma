extends SceneTree
## Focused P4M4-T5 check: generated encounter previews are split into sparse
## contract-map fields, combat-facing details, and debug/testing metadata.
## Run with:
##   godot --headless -s res://tests/encounter_preview_formatter_test.gd

const EncounterPreviewFormatterScript := preload("res://scripts/systems/runtime_monster_generator/encounter_preview_formatter.gd")
const EncounterArchetypeVocabularyScript := preload("res://scripts/systems/runtime_monster_generator/encounter_archetype_vocabulary.gd")


func _initialize() -> void:
	_check_generated_preview_sections()
	_check_contract_map_preview_stays_sparse()
	_check_archetype_vocabulary_covers_runtime_library()
	_check_unknown_archetype_falls_back_to_literal_tag()
	_check_practice_debug_text_uses_formatter()
	print("Encounter preview formatter check: OK")
	quit()


func _check_generated_preview_sections() -> void:
	var draft := _sample_draft()
	var preview: Dictionary = EncounterPreviewFormatterScript.format_generated(draft, {
		"biome": "Bog",
		"monster_name": "Defensive Bogling",
		"encounter_level": "elite",
	})

	assert(preview.has("contract_map"))
	assert(preview.has("combat"))
	assert(preview.has("debug"))

	var map: Dictionary = preview["contract_map"]
	assert(map["biome"] == "Bog")
	assert(map["monster_name"] == "Defensive Bogling")
	assert(map["encounter_level"] == "Elite")
	assert(map["archetype_tags"] == ["fortified", "warded"])
	assert(map["archetype_line"] == "fortified + warded")

	var combat: Dictionary = preview["combat"]
	assert(combat["monster_name"] == "Defensive Bogling")
	assert(combat["hp"] == 320)
	assert(combat["duration_seconds"] == 18)
	assert((combat["defense_overrides"] as Dictionary).has("armor"))
	assert((combat["selected_mechanics"] as Array).size() == 2)
	assert((combat["archetype_summaries"] as Array).size() == 2)
	var first_summary: Dictionary = (combat["archetype_summaries"] as Array)[0]
	assert(first_summary["id"] == "fortified")
	assert(first_summary["display_tag"] == "fortified")
	assert(String(first_summary["combat_summary"]).contains("physical"))

	var debug: Dictionary = preview["debug"]
	assert(debug["source_seed"] == 44004)
	assert(debug["difficulty"] == "Hard")
	assert(debug["difficulty_id"] == 3)
	assert(debug["monster_kind"] == "elite")
	assert(debug["tempo_profile"] == "standard")
	assert(debug["archetype_ids"] == ["fortified", "warded"])
	assert(debug["raw_archetype_ids"] == ["fortified", "warded"])
	assert((debug["archetype_language"] as Array).size() == 2)
	assert(debug["tags"] == ["physical", "magical"])
	assert((debug["budget_metadata"] as Dictionary)["budget"] == 120)
	assert((debug["pressure_metadata"] as Dictionary)["required_dps"] == 17.5)
	assert((debug["notices"] as Array).size() == 1)


func _check_contract_map_preview_stays_sparse() -> void:
	var preview: Dictionary = EncounterPreviewFormatterScript.format_generated(_sample_draft(), {
		"biome": "Bog",
		"encounter_level": "boss",
	})
	var map: Dictionary = preview["contract_map"]

	assert(map.keys().size() == 5)
	assert(map.has("biome"))
	assert(map.has("monster_name"))
	assert(map.has("encounter_level"))
	assert(map.has("archetype_tags"))
	assert(map.has("archetype_line"))
	assert(not map.has("source_seed"))
	assert(not map.has("budget_metadata"))
	assert(not map.has("pressure_metadata"))
	assert(not map.has("defense_overrides"))
	assert(not map.has("selected_mechanics"))
	assert(not map.has("archetype_summaries"))
	assert(not map.has("hp"))
	assert(map["encounter_level"] == "Boss")


func _check_archetype_vocabulary_covers_runtime_library() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	assert(not library.has_errors())
	for archetype in library.archetypes:
		var entry: Dictionary = EncounterArchetypeVocabularyScript.entry_for_id(archetype.id)
		assert(entry["display_tag"] == archetype.id)
		assert(String(entry["display_name"]) == archetype.name)
		assert(not (entry["likely_mechanics"] as Array).is_empty())
		assert(String(entry["pressures"]).length() > 20)
		assert(String(entry["rewards"]).length() > 20)
		assert(String(entry["combat_summary"]).length() > 20)


func _check_unknown_archetype_falls_back_to_literal_tag() -> void:
	var draft := _sample_draft()
	draft.archetype_ids = PackedStringArray(["mysterious"])
	var preview: Dictionary = EncounterPreviewFormatterScript.format_generated(draft)
	var map: Dictionary = preview["contract_map"]
	var combat: Dictionary = preview["combat"]
	var summary: Dictionary = (combat["archetype_summaries"] as Array)[0]

	assert(map["archetype_tags"] == ["mysterious"])
	assert(map["archetype_line"] == "mysterious")
	assert(summary["display_tag"] == "mysterious")
	assert(String(summary["combat_summary"]).contains("Unknown archetype"))


func _check_practice_debug_text_uses_formatter() -> void:
	var text: String = EncounterPreviewFormatterScript.format_practice_debug_text(_sample_draft())

	assert(text.contains("Difficulty: Hard"))
	assert(text.contains("Kind: Elite"))
	assert(text.contains("Tempo: Standard"))
	assert(text.contains("HP: 320"))
	assert(text.contains("Seed: 44004"))
	assert(text.contains("Archetypes: fortified, warded"))
	assert(text.contains("Tags: physical, magical"))
	assert(text.contains("Selected Mechanics"))
	assert(text.contains("raw"))
	assert(text.contains("combat"))
	assert(text.contains("field"))
	assert(text.contains("Budget"))
	assert(text.contains("Major"))
	assert(text.contains("Notices"))
	assert(not text.contains("Pressure"))
	assert(not text.contains("Effective HP"))
	assert(not text.contains("Defenses"))


func _sample_draft() -> GeneratedMonsterDraft:
	var draft := GeneratedMonsterDraft.new()
	draft.id = "generated_sample"
	draft.display_name = "Generated Sample"
	draft.hp = 320
	draft.duration_ms = 18000
	draft.target_dps = 15.5
	draft.monster_kind = "elite"
	draft.defense_overrides = {
		"armor": 72,
		"poison_resistance": 0.25,
	}
	draft.selected_mechanics = [
		{
			"id": "armor",
			"short_name": "Armor",
			"value": 72,
			"godot_value": 72,
			"godot_field": "armor",
			"cost": 35,
		},
		{
			"id": "poison_resistance",
			"short_name": "Resist",
			"value": 25,
			"godot_value": 0.25,
			"godot_field": "poison_resistance",
			"cost": 30,
		},
	]
	draft.archetype_ids = PackedStringArray(["fortified", "warded"])
	draft.tags = PackedStringArray(["physical", "magical"])
	draft.budget_metadata = {
		"budget": 120,
		"total_cost": 105,
		"budget_delta": -15,
		"major_defense_count": 1,
		"max_major_defenses": 2,
	}
	draft.pressure_metadata = {
		"required_dps": 17.5,
		"effective_hp": 315.0,
		"status": "in_band",
	}
	draft.source_seed = 44004
	draft.source_input = RuntimeGenerationInput.from_dictionary({
		"seed": 44004,
		"archetypeA": "fortified",
		"archetypeB": "warded",
		"difficulty": 3,
		"kind": "elite",
		"tempoProfile": "standard",
	})
	draft.add_notice(RuntimeMonsterNotice.SEVERITY_WARNING, "sample_warning", "Sample warning")
	return draft
