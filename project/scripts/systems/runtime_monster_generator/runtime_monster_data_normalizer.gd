class_name RuntimeMonsterDataNormalizer
extends RefCounted


static func snake_keys(data: Dictionary) -> Dictionary:
	var normalized := {}
	for key in data:
		var normalized_key := str(key).to_snake_case()
		var value = data[key]
		if value is Dictionary:
			value = snake_keys(value)
		normalized[normalized_key] = value
	return normalized


static func string_array(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if not (value is Array):
		return result
	for item in value:
		result.append(String(item))
	return result


static func int_pair(value: Variant, fallback_a: int = 0, fallback_b: int = 0) -> PackedInt32Array:
	var result := PackedInt32Array([fallback_a, fallback_b])
	if value is Array and value.size() >= 2:
		result[0] = int(value[0])
		result[1] = int(value[1])
	return result


static func float_pair(value: Variant, fallback_a: float = 0.0, fallback_b: float = 0.0) -> PackedFloat32Array:
	var result := PackedFloat32Array([fallback_a, fallback_b])
	if value is Array and value.size() >= 2:
		result[0] = float(value[0])
		result[1] = float(value[1])
	return result


static func scaled_export_value(value: float, export_scale: float) -> float:
	var scaled := value * export_scale
	if is_equal_approx(export_scale, 1.0) and is_equal_approx(scaled, roundf(scaled)):
		return roundf(scaled)
	return snappedf(scaled, 0.0001)


static func preserve_dictionary(value: Variant) -> Dictionary:
	return value.duplicate(true) if value is Dictionary else {}


static func preserve_array(value: Variant) -> Array:
	return value.duplicate(true) if value is Array else []
