extends SceneTree
## Focused P4M3-T10 check: seeded runtime monster generation produces stable
## identity metadata, scaled Monster-compatible defense fields, and HP pressure
## metadata with Monster-compatible output, structural validation notices,
## repeatability across difficulty bands, and CombatResolver compatibility.
## Run with:
##   godot --headless -s res://tests/runtime_monster_generator_test.gd


func _initialize() -> void:
	_check_same_seed_and_input_repeat()
	_check_different_seed_changes_stable_output()
	_check_secondary_archetype_metadata()
	_check_required_mechanics_and_export_units()
	_check_overlapping_archetype_mechanics_gain_bounded_emphasis()
	_check_refined_p4m8_archetypes_do_not_emit_removed_mechanics()
	_check_curated_p4m8_pair_identities_are_deterministic()
	_check_p4m8_archetypes_generate_expected_defense_identities()
	_check_elite_kind_adds_extra_mechanics()
	_check_cleanse_inverted_scaling()
	_check_hp_budget_and_pressure_metadata()
	_check_harder_band_increases_pressure()
	_check_same_seed_repeatability_across_supported_bands()
	_check_different_seed_variation_across_supported_bands()
	_check_generated_output_to_monster_and_payload()
	_check_generated_output_serialization_round_trip()
	_check_generated_monster_combat_compatibility()
	_check_generated_monsters_resolve_combat_across_supported_bands()
	_check_validation_clean_generated_output_has_no_errors()
	_check_validation_reports_budget_pressure_and_readability_warnings()
	_check_validation_reports_hard_output_errors()
	_check_validation_notice_round_trip()
	_check_invalid_inputs_report_errors()
	print("Runtime monster generator check: OK")
	quit()


func _check_same_seed_and_input_repeat() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	assert(not library.has_errors())
	var input := RuntimeGenerationInput.from_dictionary({
		"seed": 4242,
		"archetypeA": "fortified",
		"difficulty": 1,
		"kind": "normal",
		"tempoProfile": "standard",
	})

	var first := RuntimeMonsterGenerator.generate(input, library)
	var second := RuntimeMonsterGenerator.generate(input, library)
	assert(not first.has_errors())
	assert(_draft_signature(first) == _draft_signature(second))
	assert(first.source_input.generator_version == RuntimeMonsterGenerator.GENERATOR_VERSION)
	assert(first.source_input.library_schema == RuntimeArchetypeLibraryLoader.EXPECTED_SCHEMA)


func _check_different_seed_changes_stable_output() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var input_a := RuntimeGenerationInput.from_dictionary({
		"seed": 111,
		"archetypeA": "fortified",
		"difficulty": 1,
		"kind": "normal",
		"tempoProfile": "standard",
	})
	var input_b := RuntimeGenerationInput.from_dictionary({
		"seed": 222,
		"archetypeA": "fortified",
		"difficulty": 1,
		"kind": "normal",
		"tempoProfile": "standard",
	})

	var first := RuntimeMonsterGenerator.generate(input_a, library)
	var second := RuntimeMonsterGenerator.generate(input_b, library)
	assert(not first.has_errors())
	assert(not second.has_errors())
	assert(first.id != second.id)


func _check_secondary_archetype_metadata() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var input := RuntimeGenerationInput.from_dictionary({
		"seed": 99,
		"archetypeA": "fortified",
		"archetypeB": "warded",
		"difficulty": 1,
		"kind": "normal",
		"tempoProfile": "standard",
	})

	var draft := RuntimeMonsterGenerator.generate(input, library)
	assert(not draft.has_errors())
	assert(draft.archetype_ids == PackedStringArray(["fortified", "warded"]))
	assert(draft.tags.has("physical"))
	assert(draft.tags.has("magical"))
	assert(draft.hp > 0)
	assert(draft.duration_ms >= 18000)
	assert(draft.duration_ms <= 24000)
	assert(_has_mechanic(draft, "armor"))
	assert(_has_mechanic(draft, "poison_resistance"))
	assert(draft.defense_overrides.has("armor"))
	assert(draft.defense_overrides.has("poison_resistance"))


func _check_required_mechanics_and_export_units() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var draft := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 700,
		"archetypeA": "fortified",
		"difficulty": 1,
		"kind": "normal",
	}), library)

	assert(not draft.has_errors())
	var armor := _mechanic_entry(draft, "armor")
	assert(not armor.is_empty())
	assert(armor["required"])
	assert(draft.defense_overrides["armor"] == armor["value"])
	assert(armor["value"] >= armor["range"][0])
	assert(armor["value"] <= armor["range"][1])

	var resistance_draft := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 701,
		"archetypeA": "warded",
		"difficulty": 1,
		"kind": "normal",
	}), library)
	var resistance := _mechanic_entry(resistance_draft, "poison_resistance")
	assert(not resistance.is_empty())
	assert(resistance["required"])
	assert(is_equal_approx(float(resistance["godot_value"]), float(resistance["value"]) * 0.01))
	assert(is_equal_approx(float(resistance_draft.defense_overrides["poison_resistance"]), float(resistance["godot_value"])))


func _check_overlapping_archetype_mechanics_gain_bounded_emphasis() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var block_overlap := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 17701,
		"archetypeA": "aegis",
		"archetypeB": "fortified",
		"difficulty": 2,
		"kind": "normal",
		"tempoProfile": "standard",
	}), library)

	assert(not block_overlap.has_errors())
	assert(_mechanic_count(block_overlap, "block") == 1)
	var block := _mechanic_entry(block_overlap, "block")
	assert(not block.is_empty())
	assert(is_equal_approx(float((block["extras"] as Dictionary)["overlap_emphasis_bonus"]), RuntimeMonsterGenerator.OVERLAP_EMPHASIS_BONUS))
	assert((block["required_by"] as Array).has("A"))
	assert(block_overlap.defense_overrides.has("block"))

	var cleanse_overlap := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 17702,
		"archetypeA": "spiteful",
		"archetypeB": "hexed",
		"difficulty": 2,
		"kind": "normal",
		"tempoProfile": "standard",
	}), library)

	assert(not cleanse_overlap.has_errors())
	assert(_mechanic_count(cleanse_overlap, "cleanse_threshold") == 1)
	var cleanse := _mechanic_entry(cleanse_overlap, "cleanse_threshold")
	assert(not cleanse.is_empty())
	assert(is_equal_approx(float((cleanse["extras"] as Dictionary)["overlap_emphasis_bonus"]), RuntimeMonsterGenerator.OVERLAP_EMPHASIS_BONUS))
	assert((cleanse["required_by"] as Array).has("A"))
	assert(cleanse_overlap.defense_overrides.has("cleanse_threshold"))


func _check_refined_p4m8_archetypes_do_not_emit_removed_mechanics() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	for seed in range(17800, 17812):
		var aegis := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
			"seed": seed,
			"archetypeA": "aegis",
			"difficulty": 2,
			"kind": "normal",
			"tempoProfile": "standard",
		}), library)
		assert(not aegis.has_errors())
		assert(_has_mechanic(aegis, "block"))
		assert(not _has_mechanic(aegis, "armor"))

		var nullify := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
			"seed": seed,
			"archetypeA": "nullify",
			"difficulty": 2,
			"kind": "normal",
			"tempoProfile": "standard",
		}), library)
		assert(not nullify.has_errors())
		assert(_has_mechanic(nullify, "absorb"))
		assert(not _has_mechanic(nullify, "poison_resistance"))


func _check_curated_p4m8_pair_identities_are_deterministic() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var cases := [
		{
			"seed": 21000,
			"archetype_a": "aegis",
			"archetype_b": "fortified",
			"difficulty": 2,
			"kind": "normal",
			"required": ["block", "armor"],
			"overlap": ["block"],
		},
		{
			"seed": 21000,
			"archetype_a": "nullify",
			"archetype_b": "warded",
			"difficulty": 2,
			"kind": "normal",
			"required": ["absorb", "poison_resistance"],
			"overlap": ["absorb"],
		},
		{
			"seed": 21001,
			"archetype_a": "spiteful",
			"archetype_b": "hexed",
			"difficulty": 2,
			"kind": "normal",
			"required": ["cleanse_threshold", "suppress"],
			"overlap": ["cleanse_threshold", "suppress"],
		},
		{
			"seed": 21006,
			"archetype_a": "nimble",
			"archetype_b": "devious",
			"difficulty": 2,
			"kind": "normal",
			"required": ["dodge_chance", "slow"],
			"overlap": [],
		},
		{
			"seed": 21004,
			"archetype_a": "aegis",
			"archetype_b": "nullify",
			"difficulty": 2,
			"kind": "normal",
			"required": ["block", "absorb"],
			"overlap": [],
		},
	]

	for case in cases:
		var input := RuntimeGenerationInput.from_dictionary({
			"seed": case["seed"],
			"archetypeA": case["archetype_a"],
			"archetypeB": case["archetype_b"],
			"difficulty": case["difficulty"],
			"kind": case["kind"],
			"tempoProfile": "standard",
		})
		var first := RuntimeMonsterGenerator.generate(input, library)
		var second := RuntimeMonsterGenerator.generate(input, library)
		assert(not first.has_errors())
		assert(_draft_signature(first) == _draft_signature(second))
		for mechanic_id in case["required"]:
			assert(_has_mechanic(first, String(mechanic_id)))
		for mechanic_id in case["overlap"]:
			var mechanic := _mechanic_entry(first, String(mechanic_id))
			assert(not mechanic.is_empty())
			assert((mechanic["extras"] as Dictionary).has("overlap_emphasis_bonus"))


func _check_p4m8_archetypes_generate_expected_defense_identities() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var cases := [
		{"id": "aegis", "difficulty": 2, "kind": "normal", "required": "block", "field": "block"},
		{"id": "nullify", "difficulty": 2, "kind": "normal", "required": "absorb", "field": "absorb"},
		{"id": "spiteful", "difficulty": 2, "kind": "normal", "required": "cleanse_threshold", "field": "cleanse_threshold"},
		{"id": "riftbound", "difficulty": 3, "kind": "elite", "required": "", "field": ""},
	]

	for index in range(cases.size()):
		var case: Dictionary = cases[index]
		var input := RuntimeGenerationInput.from_dictionary({
			"seed": 17000 + index,
			"archetypeA": case["id"],
			"difficulty": case["difficulty"],
			"kind": case["kind"],
			"tempoProfile": "standard",
		})
		var first := RuntimeMonsterGenerator.generate(input, library)
		var second := RuntimeMonsterGenerator.generate(input, library)
		assert(not first.has_errors())
		assert(_draft_signature(first) == _draft_signature(second))
		assert(first.archetype_ids == PackedStringArray([String(case["id"])]))
		assert(first.tags.size() > 0)
		_assert_generated_output_shape(first)
		if String(case["required"]) != "":
			var mechanic := _mechanic_entry(first, String(case["required"]))
			assert(not mechanic.is_empty())
			assert(mechanic["required"])
			assert(first.defense_overrides.has(String(case["field"])))


func _check_elite_kind_adds_extra_mechanics() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var normal := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 22,
		"archetypeA": "fortified",
		"difficulty": 3,
		"kind": "normal",
	}), library)
	var elite := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 22,
		"archetypeA": "fortified",
		"difficulty": 3,
		"kind": "elite",
	}), library)

	assert(not normal.has_errors())
	assert(not elite.has_errors())
	assert(normal.selected_mechanics.size() >= 2)
	assert(normal.selected_mechanics.size() <= 4)
	assert(elite.selected_mechanics.size() >= 3)
	assert(elite.selected_mechanics.size() <= 5)


func _check_cleanse_inverted_scaling() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var easy := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 303,
		"archetypeA": "hexed",
		"difficulty": 2,
		"kind": "normal",
	}), library)
	var boss := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 303,
		"archetypeA": "hexed",
		"difficulty": 5,
		"kind": "normal",
	}), library)

	assert(not easy.has_errors())
	assert(not boss.has_errors())
	var easy_cleanse := _mechanic_entry(easy, "cleanse_threshold")
	var boss_cleanse := _mechanic_entry(boss, "cleanse_threshold")
	if not easy_cleanse.is_empty() and not boss_cleanse.is_empty():
		assert(boss_cleanse["range"][1] <= easy_cleanse["range"][1])


func _check_hp_budget_and_pressure_metadata() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var draft := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 515,
		"archetypeA": "fortified",
		"archetypeB": "warded",
		"difficulty": 2,
		"kind": "elite",
		"tempoProfile": "burst",
	}), library)

	assert(not draft.has_errors())
	assert(draft.hp > 0)
	assert(draft.duration_ms >= 12000)
	assert(draft.duration_ms <= 17000)
	assert(draft.target_dps >= 14.0 * 1.08)
	assert(draft.target_dps <= 20.0 * 1.08)
	assert(draft.budget_metadata["task_scope"] == "hp_budget_and_pressure")
	assert(draft.budget_metadata["budget"] == roundi(118.0 * 1.2))
	assert(draft.budget_metadata["total_cost"] > 0)
	assert(draft.budget_metadata["mechanic_cost"] > 0)
	assert(draft.budget_metadata["major_defense_count"] >= 0)
	assert(draft.budget_metadata["max_major_defenses"] == 1)
	assert(draft.pressure_metadata["effective_hp"] >= draft.hp)
	assert(draft.pressure_metadata["required_dps"] > 0.0)
	assert(draft.pressure_metadata["target_dps"] == draft.target_dps)
	assert(["under_band", "slightly_under", "in_band", "slightly_over", "over_band"].has(draft.pressure_metadata["status"]))
	assert((draft.pressure_metadata["pressure"] as Dictionary).has("poison"))
	for entry in draft.selected_mechanics:
		assert(entry.has("cost"))
		assert(int(entry["cost"]) > 0)


func _check_harder_band_increases_pressure() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var easy := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 880,
		"archetypeA": "fortified",
		"difficulty": 1,
		"kind": "normal",
		"tempoProfile": "standard",
	}), library)
	var boss := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 880,
		"archetypeA": "fortified",
		"difficulty": 5,
		"kind": "boss",
		"tempoProfile": "standard",
	}), library)

	assert(not easy.has_errors())
	assert(not boss.has_errors())
	assert(boss.target_dps > easy.target_dps)
	assert(boss.hp > easy.hp)
	assert(boss.pressure_metadata["effective_hp"] > easy.pressure_metadata["effective_hp"])
	assert(boss.budget_metadata["budget"] > easy.budget_metadata["budget"])


func _check_same_seed_repeatability_across_supported_bands() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var cases := _difficulty_band_cases()
	for index in range(cases.size()):
		var case: Dictionary = cases[index]
		var input := RuntimeGenerationInput.from_dictionary({
			"seed": 12000 + index,
			"archetypeA": case["archetype_a"],
			"archetypeB": case.get("archetype_b", ""),
			"difficulty": case["difficulty"],
			"kind": case["kind"],
			"tempoProfile": case["tempo"],
		})

		var first := RuntimeMonsterGenerator.generate(input, library)
		var second := RuntimeMonsterGenerator.generate(input, library)
		assert(not first.has_errors())
		assert(not second.has_errors())
		assert(_draft_signature(first) == _draft_signature(second))
		assert(first.to_dictionary() == second.to_dictionary())
		_assert_generated_output_shape(first)


func _check_different_seed_variation_across_supported_bands() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var cases := _difficulty_band_cases()
	for index in range(cases.size()):
		var case: Dictionary = cases[index]
		var base_input := {
			"archetypeA": case["archetype_a"],
			"archetypeB": case.get("archetype_b", ""),
			"difficulty": case["difficulty"],
			"kind": case["kind"],
			"tempoProfile": case["tempo"],
		}
		var input_a := RuntimeGenerationInput.from_dictionary(base_input.merged({"seed": 13000 + index * 2}))
		var input_b := RuntimeGenerationInput.from_dictionary(base_input.merged({"seed": 13001 + index * 2}))

		var first := RuntimeMonsterGenerator.generate(input_a, library)
		var second := RuntimeMonsterGenerator.generate(input_b, library)
		assert(not first.has_errors())
		assert(not second.has_errors())
		assert(_draft_signature(first) != _draft_signature(second))
		_assert_generated_output_shape(first)
		_assert_generated_output_shape(second)


func _check_invalid_inputs_report_errors() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var missing := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 5,
		"archetypeA": "not_real",
		"difficulty": 1,
		"kind": "normal",
	}), library)
	assert(missing.has_errors())
	assert(_has_notice(missing, "archetype_a_unknown"))

	var mismatch := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 5,
		"archetypeA": "fortified",
		"difficulty": 1,
		"kind": "normal",
		"generatorVersion": "old.generator",
		"librarySchema": "old.schema",
	}), library)
	assert(mismatch.has_errors())
	assert(_has_notice(mismatch, "generator_version_mismatch"))
	assert(_has_notice(mismatch, "library_schema_mismatch"))


func _check_generated_output_to_monster_and_payload() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var draft := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 902,
		"archetypeA": "devious",
		"difficulty": 3,
		"kind": "normal",
		"tempoProfile": "extended",
	}), library)

	assert(not draft.has_errors())
	var monster := draft.to_monster()
	assert(monster is Monster)
	assert(monster.id == draft.id)
	assert(monster.display_name == draft.display_name)
	assert(monster.hp == draft.hp)
	for field in GeneratedMonsterDraft.MONSTER_DEFENSE_FIELDS:
		if draft.defense_overrides.has(field):
			assert(_monster_field_value(monster, field) == draft.defense_overrides[field])
	assert(not _monster_has_property(monster, "duration_ms"))
	assert(not _monster_has_property(monster, "pressure_metadata"))

	var payload := draft.to_combat_payload()
	assert(payload["monster"] is Monster)
	assert(payload["duration_ms"] == draft.duration_ms)
	assert(payload["target_dps"] == draft.target_dps)
	assert((payload["metadata"] as Dictionary)["source_seed"] == draft.source_seed)
	assert(((payload["metadata"] as Dictionary)["pressure_metadata"] as Dictionary)["status"] == draft.pressure_metadata["status"])


func _check_generated_output_serialization_round_trip() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var draft := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 903,
		"archetypeA": "fortified",
		"archetypeB": "warded",
		"difficulty": 2,
		"kind": "elite",
		"tempoProfile": "standard",
	}), library)
	draft.add_notice(RuntimeMonsterNotice.SEVERITY_WARNING, "round_trip_probe", "Round trip probe.", {"seed": draft.source_seed})

	var data := draft.to_dictionary()
	var restored := GeneratedMonsterDraft.from_dictionary(data)
	assert(restored.id == draft.id)
	assert(restored.display_name == draft.display_name)
	assert(restored.hp == draft.hp)
	assert(restored.duration_ms == draft.duration_ms)
	assert(restored.target_dps == draft.target_dps)
	assert(restored.monster_kind == draft.monster_kind)
	assert(restored.defense_overrides == draft.defense_overrides)
	assert(restored.selected_mechanics.size() == draft.selected_mechanics.size())
	assert(restored.archetype_ids == draft.archetype_ids)
	assert(restored.tags == draft.tags)
	assert(restored.budget_metadata["total_cost"] == draft.budget_metadata["total_cost"])
	assert(restored.pressure_metadata["status"] == draft.pressure_metadata["status"])
	assert(restored.source_seed == draft.source_seed)
	assert(restored.source_input.generator_version == RuntimeMonsterGenerator.GENERATOR_VERSION)
	assert(_has_notice(restored, "round_trip_probe"))


func _check_generated_monster_combat_compatibility() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var draft := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 904,
		"archetypeA": "fortified",
		"difficulty": 1,
		"kind": "normal",
		"tempoProfile": "burst",
	}), library)
	var payload := draft.to_combat_payload()
	var strike: Skill = load("res://data/skills/placeholder_strike.tres")
	var player: PlayerStats = load("res://data/player/placeholder_player.tres")
	var result: CombatResolver.CombatResult = CombatResolver.resolve(
		[strike],
		player,
		payload["monster"] as Monster,
		int(payload["duration_ms"]),
		draft.source_seed
	)

	assert(not draft.has_errors())
	assert(result.duration_ms == draft.duration_ms)
	assert(result.total_damage >= 0.0)


func _check_generated_monsters_resolve_combat_across_supported_bands() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var strike: Skill = load("res://data/skills/placeholder_strike.tres")
	var player: PlayerStats = load("res://data/player/placeholder_player.tres")
	var cases := _difficulty_band_cases()
	for index in range(cases.size()):
		var case: Dictionary = cases[index]
		var draft := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
			"seed": 14000 + index,
			"archetypeA": case["archetype_a"],
			"archetypeB": case.get("archetype_b", ""),
			"difficulty": case["difficulty"],
			"kind": case["kind"],
			"tempoProfile": case["tempo"],
		}), library)
		var payload := draft.to_combat_payload()
		var monster := payload["monster"] as Monster
		var result: CombatResolver.CombatResult = CombatResolver.resolve(
			[strike],
			player,
			monster,
			int(payload["duration_ms"]),
			draft.source_seed
		)

		assert(not draft.has_errors())
		_assert_generated_output_shape(draft)
		assert(monster.id == draft.id)
		assert(result.duration_ms == draft.duration_ms)
		assert(result.total_damage >= 0.0)
		assert(result.cast_events.size() + result.tick_events.size() > 0)


func _check_validation_clean_generated_output_has_no_errors() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	var draft := RuntimeMonsterGenerator.generate(RuntimeGenerationInput.from_dictionary({
		"seed": 905,
		"archetypeA": "fortified",
		"difficulty": 1,
		"kind": "normal",
		"tempoProfile": "standard",
	}), library)

	assert(not draft.has_errors())
	assert(not _has_notice(draft, "output_missing_hp"))
	assert(not _has_notice(draft, "output_missing_duration"))
	assert(not _has_notice(draft, "output_missing_budget_metadata"))
	assert(not _has_notice(draft, "output_missing_pressure_metadata"))
	assert(not _has_notice(draft, "output_no_combat_mechanics"))


func _check_validation_reports_budget_pressure_and_readability_warnings() -> void:
	var draft := _valid_output_draft()
	draft.monster_kind = "normal"
	draft.selected_mechanics = [
		{"id": "armor", "godot_field": "armor", "value": 80, "godot_value": 80, "cost": 80},
		{"id": "block", "godot_field": "block", "value": 20, "godot_value": 20, "cost": 70},
		{"id": "poison_resistance", "godot_field": "poison_resistance", "value": 60, "godot_value": 0.6, "cost": 60},
		{"id": "slow", "godot_field": "slow", "value": 50, "godot_value": 0.5, "cost": 50},
	]
	draft.defense_overrides = {"armor": 80, "block": 20, "poison_resistance": 0.6, "slow": 0.5}
	draft.budget_metadata = {
		"budget": 100,
		"total_cost": 160,
		"budget_delta": 60,
		"major_defense_count": 3,
		"max_major_defenses": 1,
		"major_defense_cost": 40,
	}
	draft.pressure_metadata["status"] = "over_band"
	draft.pressure_metadata["required_dps"] = 18.0
	RuntimeMonsterGenerator.validate_draft_output(draft, _test_band())

	assert(not draft.has_errors())
	assert(_has_notice(draft, "budget_over"))
	assert(_has_notice(draft, "major_defenses_over"))
	assert(_has_notice(draft, "normal_readability_busy"))
	assert(_has_notice(draft, "pressure_high"))

	var low_pressure := _valid_output_draft()
	low_pressure.pressure_metadata["status"] = "slightly_under"
	low_pressure.pressure_metadata["required_dps"] = 6.0
	RuntimeMonsterGenerator.validate_draft_output(low_pressure, _test_band())
	assert(_has_notice(low_pressure, "pressure_low"))


func _check_validation_reports_hard_output_errors() -> void:
	var draft := GeneratedMonsterDraft.new()
	draft.id = "broken"
	draft.display_name = "Broken"
	RuntimeMonsterGenerator.validate_draft_output(draft, _test_band())

	assert(draft.has_errors())
	assert(_has_notice(draft, "output_missing_hp"))
	assert(_has_notice(draft, "output_missing_duration"))
	assert(_has_notice(draft, "output_no_combat_mechanics"))
	assert(_has_notice(draft, "output_no_defense_overrides"))
	assert(_has_notice(draft, "output_missing_budget_metadata"))
	assert(_has_notice(draft, "output_missing_pressure_metadata"))

	var invalid_mechanic := _valid_output_draft()
	invalid_mechanic.selected_mechanics = [{"id": "fake", "godot_field": "fake_field", "value": 1, "godot_value": 1, "cost": 1}]
	invalid_mechanic.defense_overrides = {"fake_field": 1}
	RuntimeMonsterGenerator.validate_draft_output(invalid_mechanic, _test_band())
	assert(invalid_mechanic.has_errors())
	assert(_has_notice(invalid_mechanic, "output_mechanic_not_combat_usable"))


func _check_validation_notice_round_trip() -> void:
	var draft := _valid_output_draft()
	draft.budget_metadata["total_cost"] = 180
	draft.budget_metadata["budget_delta"] = 80
	RuntimeMonsterGenerator.validate_draft_output(draft, _test_band())
	var restored := GeneratedMonsterDraft.from_dictionary(draft.to_dictionary())

	assert(_has_notice(draft, "budget_over"))
	assert(_has_notice(restored, "budget_over"))


func _draft_signature(draft: GeneratedMonsterDraft) -> String:
	var parts := PackedStringArray([
		draft.id,
		draft.display_name,
		str(draft.hp),
		str(draft.duration_ms),
		str(draft.target_dps),
		str(draft.monster_kind),
		_join_strings(draft.archetype_ids),
		_join_strings(draft.tags),
		str(draft.source_seed),
		draft.source_input.generator_version,
		draft.source_input.library_schema,
		_mechanics_signature(draft),
	])
	return "|".join(parts)


func _join_strings(values: PackedStringArray) -> String:
	var parts := []
	for value in values:
		parts.append(value)
	return ",".join(parts)


func _has_notice(draft: GeneratedMonsterDraft, code: String) -> bool:
	for notice in draft.notices:
		if notice.code == code:
			return true
	return false


func _has_mechanic(draft: GeneratedMonsterDraft, mechanic_id: String) -> bool:
	return not _mechanic_entry(draft, mechanic_id).is_empty()


func _mechanic_entry(draft: GeneratedMonsterDraft, mechanic_id: String) -> Dictionary:
	for entry in draft.selected_mechanics:
		if entry["id"] == mechanic_id:
			return entry
	return {}


func _mechanic_count(draft: GeneratedMonsterDraft, mechanic_id: String) -> int:
	var count := 0
	for entry in draft.selected_mechanics:
		if entry["id"] == mechanic_id:
			count += 1
	return count


func _mechanics_signature(draft: GeneratedMonsterDraft) -> String:
	var parts := PackedStringArray()
	for entry in draft.selected_mechanics:
		parts.append("%s:%s:%s" % [entry["id"], entry["value"], entry["godot_value"]])
	return ";".join(parts)


func _difficulty_band_cases() -> Array:
	return [
		{"difficulty": 1, "kind": "normal", "archetype_a": "fortified", "tempo": "standard"},
		{"difficulty": 2, "kind": "normal", "archetype_a": "warded", "tempo": "burst"},
		{"difficulty": 3, "kind": "elite", "archetype_a": "nimble", "tempo": "standard"},
		{"difficulty": 4, "kind": "elite", "archetype_a": "hexed", "archetype_b": "devious", "tempo": "extended"},
		{"difficulty": 5, "kind": "boss", "archetype_a": "devious", "archetype_b": "fortified", "tempo": "endurance"},
	]


func _assert_generated_output_shape(draft: GeneratedMonsterDraft) -> void:
	assert(draft.id != "")
	assert(draft.display_name != "")
	assert(draft.hp > 0)
	assert(draft.duration_ms > 0)
	assert(draft.target_dps > 0.0)
	assert(not draft.selected_mechanics.is_empty())
	assert(not draft.defense_overrides.is_empty())
	assert(draft.budget_metadata.has("budget"))
	assert(draft.budget_metadata.has("total_cost"))
	assert(draft.pressure_metadata.has("target_dps"))
	assert(draft.pressure_metadata.has("required_dps"))
	assert(draft.pressure_metadata.has("effective_hp"))
	assert(draft.pressure_metadata.has("status"))
	for field in draft.defense_overrides:
		assert(GeneratedMonsterDraft.MONSTER_DEFENSE_FIELDS.has(field))
	for entry in draft.selected_mechanics:
		assert(entry.has("id"))
		assert(entry.has("godot_field"))
		assert(entry.has("cost"))


func _monster_field_value(monster: Monster, field: String) -> Variant:
	match field:
		"armor":
			return monster.armor
		"poison_resistance":
			return monster.poison_resistance
		"dodge_chance":
			return monster.dodge_chance
		"crit_negation":
			return monster.crit_negation
		"block":
			return monster.block
		"absorb":
			return monster.absorb
		"cleanse_threshold":
			return monster.cleanse_threshold
		"suppress":
			return monster.suppress
		"slow":
			return monster.slow
		"stun_duration_ms":
			return monster.stun_duration_ms
		"interrupt_skip_count":
			return monster.interrupt_skip_count
	return null


func _monster_has_property(monster: Monster, property_name: String) -> bool:
	for property in monster.get_property_list():
		if String(property.get("name", "")) == property_name:
			return true
	return false


func _valid_output_draft() -> GeneratedMonsterDraft:
	var draft := GeneratedMonsterDraft.new()
	draft.id = "monster.generated.validation"
	draft.display_name = "Validation Target"
	draft.hp = 100
	draft.duration_ms = 20000
	draft.target_dps = 10.0
	draft.monster_kind = "normal"
	draft.selected_mechanics = [{"id": "armor", "godot_field": "armor", "value": 10, "godot_value": 10, "cost": 12}]
	draft.defense_overrides = {"armor": 10}
	draft.budget_metadata = {
		"budget": 100,
		"total_cost": 20,
		"budget_delta": -80,
		"major_defense_count": 0,
		"max_major_defenses": 1,
		"major_defense_cost": 40,
	}
	draft.pressure_metadata = {
		"status": "in_band",
		"target_dps": 10.0,
		"required_dps": 10.0,
		"effective_hp": 100,
		"target_dps_range": PackedFloat32Array([8.0, 12.0]),
	}
	return draft


func _test_band() -> RuntimeDifficultyBand:
	return RuntimeDifficultyBand.from_dictionary({
		"id": 1,
		"name": "Validation",
		"budget": 100,
		"mechanicCount": [1, 4],
		"maxMajorDefenses": 1,
		"majorDefenseCost": 40,
		"targetDpsRange": [8, 12],
		"dpsTolerance": 0.15,
	})
