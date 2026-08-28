extends SceneTree
## Focused P4M3-T3 check: Godot-side runtime monster generator data shapes can
## represent Monster Lab-style dictionaries without doing generation yet. Run
## with:
##   godot --headless -s res://tests/runtime_monster_data_shapes_test.gd


func _initialize() -> void:
	_check_mechanic_definition_normalizes_monster_lab_shape()
	_check_archetype_definition_normalizes_nested_configs()
	_check_difficulty_and_generation_input_shapes()
	_check_generated_draft_exports_monster_compatible_fields()
	_check_built_in_mechanic_icons_load()
	print("Runtime monster data shapes check: OK")
	quit()


func _check_mechanic_definition_normalizes_monster_lab_shape() -> void:
	var mechanic := RuntimeMechanicDef.from_dictionary({
		"id": "poison_resistance",
		"godotField": "poison_resistance",
		"name": "Resistance",
		"shortName": "Resist",
		"description": "Reduces magical damage by a percentage.",
		"icon": "res://assets/ui/icons/mechanics/resistance.png",
		"tags": ["magical", "mitigation"],
		"matchup": {"identity": "magical resistance"},
		"valueLabel": "resistance %",
		"min": 0,
		"max": 80,
		"exportScale": 0.01,
		"baseCost": 7,
		"costPerValue": 0.54,
		"effectiveHpPerValue": 0.01,
		"poisonModifier": -0.36,
		"burstModifier": -0.04,
		"sustainedModifier": -0.08,
		"curves": {1: [3, 10]},
	})
	assert(mechanic.id == "poison_resistance")
	assert(mechanic.godot_field == "poison_resistance")
	assert(mechanic.short_name == "Resist")
	assert(mechanic.icon_path == "res://assets/ui/icons/mechanics/resistance.png")
	assert(mechanic.tags == PackedStringArray(["magical", "mitigation"]))
	assert(mechanic.matchup["identity"] == "magical resistance")
	assert(is_equal_approx(mechanic.export_scale, 0.01))
	assert(is_equal_approx(mechanic.export_value(25.0), 0.25))
	assert(mechanic.runtime_supported)

	var interrupt := RuntimeMechanicDef.from_dictionary({
		"id": "interrupt_skip_count",
		"godotField": "interrupt_skip_count",
		"name": "Interrupt",
		"previewOnly": true,
		"extraFields": [{"id": "interrupt_repeat_threshold", "default": 3}],
	}, true)
	assert(interrupt.preview_only)
	assert(interrupt.runtime_supported)
	assert(interrupt.extra_fields.size() == 1)


func _check_archetype_definition_normalizes_nested_configs() -> void:
	var archetype := RuntimeArchetypeDef.from_dictionary({
		"id": "fortified",
		"name": "Fortified",
		"tone": "custom enemy pressure profile",
		"tags": ["generic", "physical"],
		"unlock_difficulty": 1,
		"allowed_kinds": ["normal", "elite", "boss"],
		"route_weight": 80,
		"baseHpBias": 1.09,
		"mechanicWeights": {
			"armor": 100,
			"crit_negation": 30,
		},
		"mechanicConfigs": {
			"armor": {
				"enabled": true,
				"required": true,
				"weight": 100,
				"min": 80,
				"max": 120,
				"scaling": "standard",
			},
		},
		"nameParts": {
			"prefixes": ["Fortified"],
			"nouns": ["Monster"],
		},
	})
	assert(archetype.id == "fortified")
	assert(is_equal_approx(archetype.base_hp_bias, 1.09))
	assert(archetype.allowed_kinds.has("boss"))
	assert(archetype.mechanic_weights["armor"] == 100)
	assert(archetype.mechanic_configs.has("armor"))
	var armor_config: RuntimeMechanicConfig = archetype.mechanic_configs["armor"]
	assert(armor_config.enabled)
	assert(armor_config.required)
	assert(is_equal_approx(armor_config.min_value, 80.0))
	assert(archetype.name_parts["prefixes"][0] == "Fortified")


func _check_difficulty_and_generation_input_shapes() -> void:
	var band := RuntimeDifficultyBand.from_dictionary({
		"id": 3,
		"name": "Hard",
		"budget": 154,
		"mechanicCount": [2, 4],
		"maxMajorDefenses": 2,
		"majorDefenseCost": 42,
		"targetDpsRange": [21, 28],
		"dpsTolerance": 0.14,
	})
	assert(band.id == 3)
	assert(band.mechanic_count[0] == 2)
	assert(band.mechanic_count[1] == 4)
	assert(is_equal_approx(band.target_dps_range[1], 28.0))

	var input := RuntimeGenerationInput.from_dictionary({
		"seed": 12345,
		"archetypeA": "fortified",
		"archetypeB": "warded",
		"difficulty": 3,
		"kind": "elite",
		"tempoProfile": "standard",
		"generatorVersion": "p4m3-test",
		"librarySchema": "monster_lab_archetype_catalog.v1",
	})
	assert(input.seed == 12345)
	assert(input.archetype_a_id == "fortified")
	assert(input.archetype_b_id == "warded")
	assert(input.difficulty_id == 3)
	assert(input.monster_kind == "elite")
	assert(input.to_dictionary()["generator_version"] == "p4m3-test")


func _check_generated_draft_exports_monster_compatible_fields() -> void:
	var draft := GeneratedMonsterDraft.from_dictionary({
		"id": "generated.test",
		"name": "Fortified Dummy",
		"hp": 240,
		"duration": 20000,
		"targetDps": 12.0,
		"kind": "normal",
		"monsterOverrides": {
			"armor": 100,
			"poison_resistance": 0.25,
			"block": 3,
			"stun_duration_ms": 300,
			"interrupt_skip_count": 1,
		},
		"selectedMechanics": [{"id": "armor", "value": 100}],
		"archetypes": ["fortified"],
		"tags": ["physical"],
		"sourceInput": {
			"seed": 99,
			"archetypeA": "fortified",
			"difficulty": 2,
		},
	})
	draft.add_notice(RuntimeMonsterNotice.SEVERITY_WARNING, "readability_load", "Many defenses may be hard to read.", {"count": 5})
	assert(not draft.has_errors())
	assert(draft.notices.size() == 1)
	assert(draft.source_input != null)
	assert(draft.source_input.seed == 99)

	var monster := draft.to_monster()
	assert(monster.id == "generated.test")
	assert(monster.display_name == "Fortified Dummy")
	assert(monster.hp == 240)
	assert(monster.armor == 100)
	assert(is_equal_approx(monster.poison_resistance, 0.25))
	assert(is_equal_approx(monster.block, 3.0))
	assert(monster.stun_duration_ms == 300)
	assert(monster.interrupt_skip_count == 1)


func _check_built_in_mechanic_icons_load() -> void:
	var expected_icons := {
		"dodge_chance": "res://assets/ui/icons/mechanics/dodge.png",
		"crit_negation": "res://assets/ui/icons/mechanics/crit_negation.png",
		"block": "res://assets/ui/icons/mechanics/block.png",
		"absorb": "res://assets/ui/icons/mechanics/absorb.png",
		"cleanse_threshold": "res://assets/ui/icons/mechanics/cleanse.png",
		"suppress": "res://assets/ui/icons/mechanics/suppress.png",
		"slow": "res://assets/ui/icons/mechanics/slow.png",
		"stun_duration_ms": "res://assets/ui/icons/mechanics/stun.png",
		"interrupt_skip_count": "res://assets/ui/icons/mechanics/interrupt.png",
	}
	var library := RuntimeMechanicLibrary.built_in()
	for mechanic_id in expected_icons:
		var mechanic := library.get_mechanic(mechanic_id)
		assert(mechanic != null)
		assert(mechanic.icon_path == expected_icons[mechanic_id])
		assert(load(mechanic.icon_path) is Texture2D)
