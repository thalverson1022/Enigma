class_name RuntimeGenerationInput
extends RefCounted

var seed: int = 1
var archetype_a_id: String = ""
var archetype_b_id: String = ""
var difficulty_id: int = 1
var monster_kind: String = "normal"
var tempo_profile: String = "standard"
var overrides: Dictionary = {}
var generator_version: String = ""
var library_schema: String = ""


static func from_dictionary(source: Dictionary) -> RuntimeGenerationInput:
	var data := RuntimeMonsterDataNormalizer.snake_keys(source)
	var input := RuntimeGenerationInput.new()
	input.seed = int(data.get("seed", 1))
	input.archetype_a_id = String(data.get("archetype_a_id", data.get("archetype_a", "")))
	input.archetype_b_id = String(data.get("archetype_b_id", data.get("archetype_b", "")))
	input.difficulty_id = int(data.get("difficulty_id", data.get("difficulty", 1)))
	input.monster_kind = String(data.get("monster_kind", data.get("kind", "normal")))
	input.tempo_profile = String(data.get("tempo_profile", "standard"))
	input.overrides = RuntimeMonsterDataNormalizer.preserve_dictionary(data.get("overrides", {}))
	input.generator_version = String(data.get("generator_version", ""))
	input.library_schema = String(data.get("library_schema", ""))
	return input


func to_dictionary() -> Dictionary:
	return {
		"seed": seed,
		"archetype_a_id": archetype_a_id,
		"archetype_b_id": archetype_b_id,
		"difficulty_id": difficulty_id,
		"monster_kind": monster_kind,
		"tempo_profile": tempo_profile,
		"overrides": overrides.duplicate(true),
		"generator_version": generator_version,
		"library_schema": library_schema,
	}
