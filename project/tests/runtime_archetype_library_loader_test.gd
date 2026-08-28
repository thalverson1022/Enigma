extends SceneTree
## Focused P4M3-T4 check: Godot can load and validate the Monster Lab archetype
## library bridge source. Run with:
##   godot --headless -s res://tests/runtime_archetype_library_loader_test.gd


func _initialize() -> void:
	_check_default_library_loads_checked_in_archetypes()
	_check_p4m8_archetypes_load_with_expected_identities()
	_check_validation_reports_hard_contract_errors()
	print("Runtime archetype library loader check: OK")
	quit()


func _check_default_library_loads_checked_in_archetypes() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	assert(not library.has_errors())
	assert(library.schema == RuntimeArchetypeLibraryLoader.EXPECTED_SCHEMA)
	assert(library.archetypes.size() >= 8)
	assert(library.has_archetype("fortified"))

	var fortified := library.get_archetype("fortified")
	assert(fortified != null)
	assert(fortified.name == "Fortified")
	assert(fortified.allowed_kinds.has("boss"))
	assert(fortified.mechanic_weights["armor"] == 100)
	assert(fortified.mechanic_configs.has("armor"))
	assert(fortified.name_parts["prefixes"].has("Fortified"))

	var normal_starter_archetypes := library.available_for(1, "normal")
	assert(normal_starter_archetypes.size() > 0)
	for archetype in normal_starter_archetypes:
		assert(archetype.unlock_difficulty <= 1)
		assert(archetype.allowed_kinds.has("normal"))


func _check_p4m8_archetypes_load_with_expected_identities() -> void:
	var library := RuntimeArchetypeLibraryLoader.load_default()
	assert(not library.has_errors())
	assert(library.archetypes.size() >= 14)

	var aegis := library.get_archetype("aegis")
	assert(aegis != null)
	assert(aegis.allowed_kinds.has("normal"))
	assert(aegis.allowed_kinds.has("boss"))
	assert(aegis.mechanic_weights["block"] == 100)
	assert(not aegis.mechanic_weights.has("armor"))
	assert(not (aegis.mechanic_configs["armor"] as RuntimeMechanicConfig).enabled)
	assert((aegis.mechanic_configs["block"] as RuntimeMechanicConfig).required)
	assert(aegis.name_parts["prefixes"].has("Braced"))

	var nullify := library.get_archetype("nullify")
	assert(nullify != null)
	assert(nullify.mechanic_weights["absorb"] == 100)
	assert(not nullify.mechanic_weights.has("poison_resistance"))
	assert(not (nullify.mechanic_configs["poison_resistance"] as RuntimeMechanicConfig).enabled)
	assert((nullify.mechanic_configs["absorb"] as RuntimeMechanicConfig).required)
	assert(nullify.allowed_kinds.has("elite"))

	var spiteful := library.get_archetype("spiteful")
	assert(spiteful != null)
	assert(spiteful.mechanic_weights["cleanse_threshold"] == 80)
	assert((spiteful.mechanic_configs["cleanse_threshold"] as RuntimeMechanicConfig).required)

	var riftbound := library.get_archetype("riftbound")
	assert(riftbound != null)
	assert(not riftbound.allowed_kinds.has("normal"))
	assert(riftbound.allowed_kinds.has("elite"))
	assert(riftbound.allowed_kinds.has("boss"))
	assert(riftbound.mechanic_weights.has("armor"))
	assert(riftbound.mechanic_weights.has("absorb"))
	assert(riftbound.mechanic_weights.has("slow"))


func _check_validation_reports_hard_contract_errors() -> void:
	var broken := RuntimeArchetypeLibraryLoader.load_from_dictionary({
		"schema": "monster_lab_archetype_catalog.v1",
		"library_name": "Broken Test Library",
		"archetypes": [
			{
				"id": "duplicate",
				"name": "Duplicate",
				"tone": "first duplicate",
				"baseHpBias": 1.0,
				"mechanicWeights": {"armor": 100},
				"nameParts": {"prefixes": ["One"], "nouns": ["Target"]},
			},
			{
				"id": "duplicate",
				"name": "Duplicate",
				"tone": "second duplicate",
				"baseHpBias": 1.0,
				"mechanicWeights": {"armor": 100},
				"nameParts": {"prefixes": ["Two"], "nouns": ["Target"]},
			},
			{
				"id": "",
				"name": "",
				"tone": "",
				"baseHpBias": 0,
				"mechanicWeights": {},
				"nameParts": {},
			},
		],
	})

	assert(broken.has_errors())
	assert(_has_notice(broken, "archetype_duplicate_id"))
	assert(_has_notice(broken, "archetype_missing_id"))
	assert(_has_notice(broken, "archetype_invalid_hp_bias"))


func _has_notice(library: RuntimeArchetypeLibrary, code: String) -> bool:
	for notice in library.notices:
		if notice.code == code:
			return true
	return false
