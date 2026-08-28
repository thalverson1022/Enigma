class_name ContractDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var target_display_name: String = ""
@export var target_monster: Monster
@export_multiline var offer_text: String = ""
@export var offer_node: ContractRouteNode
@export_group("Generated Route")
@export var generated_route_id: String = ""
@export var source_seed: int = 0
@export var generator_version: String = ""
@export var route_difficulty: String = ""
@export var selected_biome: String = ""
@export var allowed_biomes: PackedStringArray = []
@export var biome_table_version: String = ""
@export var runtime_monster_generator_version: String = ""
@export var runtime_monster_archetype_library_version: String = ""
@export var modifier_model_version: String = ""
@export var generated_modifier_ids: PackedStringArray = []
@export var generated_modifiers: Array[Dictionary] = []
@export var template_id: String = ""
@export var template_display_label: String = ""
@export var template_width_summary: Dictionary = {}
@export var route_settings: Dictionary = {}
@export var route_notices: PackedStringArray = []


func has_generated_route_state() -> bool:
	return (
		generated_route_id != ""
		or source_seed != 0
		or generator_version != ""
		or route_difficulty != ""
		or selected_biome != ""
		or not allowed_biomes.is_empty()
		or biome_table_version != ""
		or runtime_monster_generator_version != ""
		or runtime_monster_archetype_library_version != ""
		or modifier_model_version != ""
		or not generated_modifier_ids.is_empty()
		or not generated_modifiers.is_empty()
		or template_id != ""
		or template_display_label != ""
		or not template_width_summary.is_empty()
		or not route_settings.is_empty()
		or not route_notices.is_empty()
	)


func generated_route_state() -> Dictionary:
	return {
		"generated_route_id": generated_route_id,
		"source_seed": source_seed,
		"generator_version": generator_version,
		"route_difficulty": route_difficulty,
		"selected_biome": selected_biome,
		"allowed_biomes": Array(allowed_biomes),
		"biome_table_version": biome_table_version,
		"runtime_monster_generator_version": runtime_monster_generator_version,
		"runtime_monster_archetype_library_version": runtime_monster_archetype_library_version,
		"modifier_model_version": modifier_model_version,
		"generated_modifier_ids": Array(generated_modifier_ids),
		"generated_modifiers": generated_modifiers.duplicate(true),
		"template_id": template_id,
		"template_display_label": template_display_label,
		"template_width_summary": template_width_summary.duplicate(true),
		"route_settings": route_settings.duplicate(true),
		"route_notices": Array(route_notices),
	}


func apply_generated_route_state(state: Dictionary) -> void:
	generated_route_id = String(state.get("generated_route_id", generated_route_id))
	source_seed = int(state.get("source_seed", source_seed))
	generator_version = String(state.get("generator_version", generator_version))
	route_difficulty = String(state.get("route_difficulty", route_difficulty))
	selected_biome = String(state.get("selected_biome", selected_biome))
	allowed_biomes = _packed_string_array(state.get("allowed_biomes", allowed_biomes))
	biome_table_version = String(state.get("biome_table_version", biome_table_version))
	runtime_monster_generator_version = String(state.get("runtime_monster_generator_version", runtime_monster_generator_version))
	runtime_monster_archetype_library_version = String(state.get("runtime_monster_archetype_library_version", runtime_monster_archetype_library_version))
	modifier_model_version = String(state.get("modifier_model_version", modifier_model_version))
	generated_modifier_ids = _packed_string_array(state.get("generated_modifier_ids", generated_modifier_ids))
	generated_modifiers = _dictionary_array(state.get("generated_modifiers", generated_modifiers))
	var saved_route_settings: Dictionary = (state.get("route_settings", {}) as Dictionary)
	template_id = String(state.get("template_id", saved_route_settings.get("template_id", template_id)))
	template_display_label = String(state.get("template_display_label", saved_route_settings.get("template_display_label", template_display_label)))
	template_width_summary = (state.get("template_width_summary", saved_route_settings.get("template_width_summary", template_width_summary)) as Dictionary).duplicate(true)
	route_settings = (state.get("route_settings", route_settings) as Dictionary).duplicate(true)
	route_notices = _packed_string_array(state.get("route_notices", route_notices))


static func _packed_string_array(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if value is PackedStringArray:
		return value
	if value is Array:
		for item in value:
			result.append(String(item))
	return result


static func _dictionary_array(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				result.append((item as Dictionary).duplicate(true))
	return result
