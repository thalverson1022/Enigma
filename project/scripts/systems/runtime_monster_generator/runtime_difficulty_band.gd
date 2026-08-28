class_name RuntimeDifficultyBand
extends RefCounted

var id: int = 0
var name: String = ""
var budget: int = 0
var mechanic_count: PackedInt32Array = PackedInt32Array([0, 0])
var max_major_defenses: int = 0
var major_defense_cost: int = 0
var target_dps_range: PackedFloat32Array = PackedFloat32Array([0.0, 0.0])
var dps_tolerance: float = 0.0


static func from_dictionary(source: Dictionary) -> RuntimeDifficultyBand:
	var data := RuntimeMonsterDataNormalizer.snake_keys(source)
	var band := RuntimeDifficultyBand.new()
	band.id = int(data.get("id", 0))
	band.name = String(data.get("name", ""))
	band.budget = int(data.get("budget", 0))
	band.mechanic_count = RuntimeMonsterDataNormalizer.int_pair(data.get("mechanic_count", []))
	band.max_major_defenses = int(data.get("max_major_defenses", 0))
	band.major_defense_cost = int(data.get("major_defense_cost", 0))
	band.target_dps_range = RuntimeMonsterDataNormalizer.float_pair(data.get("target_dps_range", []))
	band.dps_tolerance = float(data.get("dps_tolerance", 0.0))
	return band
