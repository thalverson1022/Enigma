class_name RuntimeDifficultyLibrary
extends RefCounted

const _BANDS := [
	{"id": 1, "name": "Easy", "budget": 62, "mechanicCount": [1, 2], "maxMajorDefenses": 1, "majorDefenseCost": 28, "targetDpsRange": [6, 10], "dpsTolerance": 0.18},
	{"id": 2, "name": "Medium", "budget": 118, "mechanicCount": [2, 3], "maxMajorDefenses": 1, "majorDefenseCost": 34, "targetDpsRange": [14, 20], "dpsTolerance": 0.16},
	{"id": 3, "name": "Hard", "budget": 154, "mechanicCount": [2, 4], "maxMajorDefenses": 2, "majorDefenseCost": 42, "targetDpsRange": [21, 28], "dpsTolerance": 0.14},
	{"id": 4, "name": "Ultra", "budget": 204, "mechanicCount": [3, 4], "maxMajorDefenses": 3, "majorDefenseCost": 52, "targetDpsRange": [30, 40], "dpsTolerance": 0.12},
	{"id": 5, "name": "Nightmare", "budget": 270, "mechanicCount": [4, 5], "maxMajorDefenses": 4, "majorDefenseCost": 64, "targetDpsRange": [42, 55], "dpsTolerance": 0.1},
]

var bands: Array[RuntimeDifficultyBand] = []
var _bands_by_id: Dictionary = {}


static func built_in() -> RuntimeDifficultyLibrary:
	var library := RuntimeDifficultyLibrary.new()
	for data in _BANDS:
		library.add_band(RuntimeDifficultyBand.from_dictionary(data))
	return library


func add_band(band: RuntimeDifficultyBand) -> void:
	bands.append(band)
	_bands_by_id[band.id] = band


func get_band(difficulty_id: int) -> RuntimeDifficultyBand:
	return _bands_by_id.get(difficulty_id) as RuntimeDifficultyBand


func has_band(difficulty_id: int) -> bool:
	return _bands_by_id.has(difficulty_id)


func max_band_id() -> int:
	var result := 1
	for band in bands:
		result = maxi(result, band.id)
	return result
