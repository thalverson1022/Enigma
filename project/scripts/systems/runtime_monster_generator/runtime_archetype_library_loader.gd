class_name RuntimeArchetypeLibraryLoader
extends RefCounted

const EXPECTED_SCHEMA := "monster_lab_archetype_catalog.v1"
const DEFAULT_LIBRARY_PATHS := [
	"res://data/runtime_monster_generator/dawnbringer_archetypes_v1.json",
	"res://../tools/monster-lab/Monster_Libraries/dawnbringer_archetypes_v1.json",
]


static func load_default() -> RuntimeArchetypeLibrary:
	for candidate in DEFAULT_LIBRARY_PATHS:
		var resolved := _resolve_path(candidate)
		if resolved != "" and FileAccess.file_exists(resolved):
			return load_from_path(resolved)

	var library := RuntimeArchetypeLibrary.new()
	library.add_notice(
		RuntimeMonsterNotice.SEVERITY_ERROR,
		"library_missing",
		"Runtime archetype library JSON could not be found.",
		{"paths": DEFAULT_LIBRARY_PATHS}
	)
	return library


static func load_from_path(path: String) -> RuntimeArchetypeLibrary:
	var library := RuntimeArchetypeLibrary.new()
	library.source_path = path
	var resolved_path := _resolve_path(path)
	if resolved_path == "" or not FileAccess.file_exists(resolved_path):
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"library_missing",
			"Runtime archetype library JSON could not be found.",
			{"path": path}
		)
		return library

	var file_text := FileAccess.get_file_as_string(resolved_path)
	if file_text == "":
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"library_empty",
			"Runtime archetype library JSON is empty.",
			{"path": resolved_path}
		)
		return library

	var parsed = JSON.parse_string(file_text)
	if not (parsed is Dictionary):
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"library_parse_failed",
			"Runtime archetype library JSON did not parse into an object.",
			{"path": resolved_path}
		)
		return library

	return load_from_dictionary(parsed, resolved_path)


static func load_from_dictionary(source: Dictionary, source_path: String = "") -> RuntimeArchetypeLibrary:
	var data := RuntimeMonsterDataNormalizer.snake_keys(source)
	var library := RuntimeArchetypeLibrary.new()
	library.source_path = source_path
	library.schema = String(data.get("schema", ""))
	library.library_name = String(data.get("library_name", ""))

	if library.schema == "":
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"schema_missing",
			"Runtime archetype library is missing a schema.",
			{"path": source_path}
		)
	elif library.schema != EXPECTED_SCHEMA:
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"schema_mismatch",
			"Runtime archetype library schema is not supported.",
			{"expected": EXPECTED_SCHEMA, "actual": library.schema}
		)

	var entries = data.get("archetypes", [])
	if not (entries is Array) or entries.is_empty():
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetypes_missing",
			"Runtime archetype library has no archetype entries.",
			{"path": source_path}
		)
		return library

	var seen_ids := {}
	for index in range(entries.size()):
		var entry = entries[index]
		if not (entry is Dictionary):
			library.add_notice(
				RuntimeMonsterNotice.SEVERITY_ERROR,
				"archetype_invalid",
				"Runtime archetype entry is not an object.",
				{"index": index}
			)
			continue

		var archetype := RuntimeArchetypeDef.from_dictionary(entry)
		_validate_archetype(archetype, index, library)
		if archetype.id == "":
			continue
		if seen_ids.has(archetype.id):
			library.add_notice(
				RuntimeMonsterNotice.SEVERITY_ERROR,
				"archetype_duplicate_id",
				"Runtime archetype library contains a duplicate archetype ID.",
				{"id": archetype.id, "index": index}
			)
			continue

		seen_ids[archetype.id] = true
		library.add_archetype(archetype)

	if library.archetypes.is_empty() and not library.has_errors():
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetypes_missing",
			"Runtime archetype library produced no usable archetypes.",
			{"path": source_path}
		)

	return library


static func _validate_archetype(archetype: RuntimeArchetypeDef, index: int, library: RuntimeArchetypeLibrary) -> void:
	var context := {"id": archetype.id, "index": index}
	if archetype.id == "":
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetype_missing_id",
			"Runtime archetype is missing an ID.",
			context
		)
	if archetype.name == "":
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetype_missing_name",
			"Runtime archetype is missing a name.",
			context
		)
	if archetype.tone == "":
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetype_missing_tone",
			"Runtime archetype is missing tone language.",
			context
		)
	if archetype.base_hp_bias <= 0.0:
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetype_invalid_hp_bias",
			"Runtime archetype must have a positive base HP bias.",
			context
		)
	if archetype.mechanic_weights.is_empty():
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetype_missing_weights",
			"Runtime archetype must define mechanic weights.",
			context
		)
	for mechanic_id in archetype.mechanic_weights:
		if int(archetype.mechanic_weights[mechanic_id]) <= 0:
			library.add_notice(
				RuntimeMonsterNotice.SEVERITY_ERROR,
				"archetype_invalid_weight",
				"Runtime archetype mechanic weights must be positive.",
				{"id": archetype.id, "mechanic": mechanic_id}
			)
	if not _has_name_part(archetype, "prefixes"):
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetype_missing_name_prefixes",
			"Runtime archetype must define name prefixes.",
			context
		)
	if not _has_name_part(archetype, "nouns"):
		library.add_notice(
			RuntimeMonsterNotice.SEVERITY_ERROR,
			"archetype_missing_name_nouns",
			"Runtime archetype must define name nouns.",
			context
		)


static func _has_name_part(archetype: RuntimeArchetypeDef, key: String) -> bool:
	return archetype.name_parts.has(key) and archetype.name_parts[key] is Array and not archetype.name_parts[key].is_empty()


static func _resolve_path(path: String) -> String:
	if path == "":
		return ""
	if path.begins_with("res://") or path.begins_with("user://"):
		if FileAccess.file_exists(path):
			return path
		var globalized := ProjectSettings.globalize_path(path)
		return globalized if FileAccess.file_exists(globalized) else path
	return path
