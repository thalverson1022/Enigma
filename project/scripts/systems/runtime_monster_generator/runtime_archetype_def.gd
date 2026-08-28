class_name RuntimeArchetypeDef
extends RefCounted

var id: String = ""
var name: String = ""
var tone: String = ""
var tags: PackedStringArray = []
var unlock_difficulty: int = 1
var allowed_kinds: PackedStringArray = []
var route_weight: int = 0
var base_hp_bias: float = 1.0
var mechanic_weights: Dictionary = {}
var mechanic_configs: Dictionary = {}
var name_parts: Dictionary = {}


static func from_dictionary(source: Dictionary) -> RuntimeArchetypeDef:
	var data := RuntimeMonsterDataNormalizer.snake_keys(source)
	var def := RuntimeArchetypeDef.new()
	def.id = String(data.get("id", ""))
	def.name = String(data.get("name", def.id))
	def.tone = String(data.get("tone", ""))
	def.tags = RuntimeMonsterDataNormalizer.string_array(data.get("tags", []))
	def.unlock_difficulty = int(data.get("unlock_difficulty", 1))
	def.allowed_kinds = RuntimeMonsterDataNormalizer.string_array(data.get("allowed_kinds", []))
	def.route_weight = int(data.get("route_weight", 0))
	def.base_hp_bias = float(data.get("base_hp_bias", 1.0))
	def.mechanic_weights = _normalized_weight_dictionary(data.get("mechanic_weights", {}))
	def.mechanic_configs = _normalized_config_dictionary(data.get("mechanic_configs", {}))
	def.name_parts = RuntimeMonsterDataNormalizer.preserve_dictionary(data.get("name_parts", {}))
	return def


static func _normalized_weight_dictionary(value: Variant) -> Dictionary:
	var result := {}
	if not (value is Dictionary):
		return result
	for key in value:
		result[String(key).to_snake_case()] = int(value[key])
	return result


static func _normalized_config_dictionary(value: Variant) -> Dictionary:
	var result := {}
	if not (value is Dictionary):
		return result
	for key in value:
		if value[key] is Dictionary:
			result[String(key).to_snake_case()] = RuntimeMechanicConfig.from_dictionary(value[key])
	return result
