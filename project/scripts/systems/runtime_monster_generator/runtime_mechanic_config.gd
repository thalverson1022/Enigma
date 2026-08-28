class_name RuntimeMechanicConfig
extends RefCounted

var enabled: bool = false
var required: bool = false
var weight: int = 0
var min_value: float = 0.0
var max_value: float = 0.0
var scaling: String = "standard"
var extras: Dictionary = {}


static func from_dictionary(source: Dictionary) -> RuntimeMechanicConfig:
	var data := RuntimeMonsterDataNormalizer.snake_keys(source)
	var config := RuntimeMechanicConfig.new()
	config.enabled = bool(data.get("enabled", false))
	config.required = bool(data.get("required", false))
	config.weight = int(data.get("weight", 0))
	config.min_value = float(data.get("min", data.get("min_value", 0.0)))
	config.max_value = float(data.get("max", data.get("max_value", 0.0)))
	config.scaling = String(data.get("scaling", "standard"))
	config.extras = RuntimeMonsterDataNormalizer.preserve_dictionary(data.get("extras", {}))
	return config


func to_dictionary() -> Dictionary:
	return {
		"enabled": enabled,
		"required": required,
		"weight": weight,
		"min": min_value,
		"max": max_value,
		"scaling": scaling,
		"extras": extras.duplicate(true),
	}
