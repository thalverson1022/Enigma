class_name RuntimeMechanicLibrary
extends RefCounted

const SUPPORTED_GODOT_FIELDS := [
	"armor",
	"poison_resistance",
	"dodge_chance",
	"crit_negation",
	"block",
	"absorb",
	"cleanse_threshold",
	"suppress",
	"slow",
	"stun_duration_ms",
	"interrupt_skip_count",
]

const _MECHANICS := [
	{"id": "armor", "godotField": "armor", "name": "Armor", "shortName": "Armor", "tags": ["physical", "mitigation", "shred-check"], "valueLabel": "armor", "min": 0, "max": 120, "exportScale": 1, "baseCost": 8, "costPerValue": 0.44, "effectiveHpPerValue": 0.012, "poisonModifier": 0.0, "burstModifier": -0.18, "sustainedModifier": -0.08, "curves": {1: [4, 14], 2: [12, 28], 3: [24, 44], 4: [38, 62], 5: [56, 88], 6: [78, 115]}},
	{"id": "dodge_chance", "godotField": "dodge_chance", "name": "Dodge", "shortName": "Dodge", "icon": "res://assets/ui/icons/mechanics/dodge.png", "tags": ["physical", "avoidance", "reliability-check"], "valueLabel": "dodge %", "min": 0, "max": 40, "exportScale": 0.01, "baseCost": 12, "costPerValue": 1.45, "effectiveHpPerValue": 0.014, "poisonModifier": 0.1, "burstModifier": -0.24, "sustainedModifier": -0.12, "curves": {1: [3, 7], 2: [6, 12], 3: [10, 18], 4: [15, 25], 5: [22, 32], 6: [28, 38]}},
	{"id": "crit_negation", "godotField": "crit_negation", "name": "Crit Negation", "shortName": "Crit Neg", "icon": "res://assets/ui/icons/mechanics/crit_negation.png", "tags": ["physical", "crit-check", "burst-check"], "valueLabel": "crit negation %", "min": 0, "max": 80, "exportScale": 0.01, "baseCost": 10, "costPerValue": 0.8, "effectiveHpPerValue": 0.006, "poisonModifier": 0.08, "burstModifier": -0.26, "sustainedModifier": -0.04, "curves": {1: [8, 18], 2: [16, 28], 3: [24, 42], 4: [36, 56], 5: [50, 68], 6: [62, 78]}},
	{"id": "block", "godotField": "block", "name": "Block", "shortName": "Block", "icon": "res://assets/ui/icons/mechanics/block.png", "tags": ["physical", "flat-reduction", "multi-hit-check"], "valueLabel": "blocked damage", "min": 0, "max": 24, "exportScale": 1, "baseCost": 9, "costPerValue": 2.9, "effectiveHpPerValue": 0.02, "poisonModifier": 0.12, "burstModifier": -0.16, "sustainedModifier": -0.2, "curves": {1: [1, 3], 2: [3, 6], 3: [5, 10], 4: [8, 14], 5: [12, 19], 6: [16, 23]}},
	{"id": "poison_resistance", "godotField": "poison_resistance", "name": "Resistance", "shortName": "Resist", "tags": ["magical", "mitigation", "poison-check"], "valueLabel": "resistance %", "min": 0, "max": 80, "exportScale": 0.01, "baseCost": 7, "costPerValue": 0.54, "effectiveHpPerValue": 0.01, "poisonModifier": -0.36, "burstModifier": -0.04, "sustainedModifier": -0.08, "curves": {1: [3, 10], 2: [8, 20], 3: [16, 32], 4: [26, 46], 5: [38, 62], 6: [54, 76]}},
	{"id": "absorb", "godotField": "absorb", "name": "Absorb", "shortName": "Absorb", "icon": "res://assets/ui/icons/mechanics/absorb.png", "tags": ["magical", "flat-reduction", "dot-check"], "valueLabel": "absorbed damage", "min": 0, "max": 18, "exportScale": 1, "baseCost": 9, "costPerValue": 3.2, "effectiveHpPerValue": 0.018, "poisonModifier": -0.3, "burstModifier": -0.04, "sustainedModifier": -0.16, "curves": {1: [1, 2], 2: [2, 4], 3: [3, 7], 4: [5, 10], 5: [8, 14], 6: [12, 18]}},
	{"id": "cleanse_threshold", "godotField": "cleanse_threshold", "name": "Cleanse", "shortName": "Cleanse", "icon": "res://assets/ui/icons/mechanics/cleanse.png", "tags": ["debuff", "cleanse", "poison-check"], "valueLabel": "attack threshold", "min": 1, "max": 8, "exportScale": 1, "invertCost": true, "baseCost": 18, "costPerValue": 5.2, "effectiveHpPerValue": 0.012, "poisonModifier": -0.42, "burstModifier": 0.08, "sustainedModifier": -0.1, "conflicts": ["poison_resistance"], "curves": {1: [6, 8], 2: [5, 7], 3: [4, 6], 4: [3, 5], 5: [2, 4], 6: [1, 3]}},
	{"id": "suppress", "godotField": "suppress", "name": "Suppress", "shortName": "Suppress", "icon": "res://assets/ui/icons/mechanics/suppress.png", "tags": ["debuff", "dot-timing", "poison-check"], "valueLabel": "DOT delay %", "min": 0, "max": 100, "exportScale": 0.01, "baseCost": 11, "costPerValue": 0.78, "effectiveHpPerValue": 0.007, "poisonModifier": -0.38, "burstModifier": 0.08, "sustainedModifier": -0.12, "curves": {1: [8, 16], 2: [14, 26], 3: [24, 40], 4: [36, 58], 5: [52, 78], 6: [70, 95]}},
	{"id": "slow", "godotField": "slow", "name": "Slow", "shortName": "Slow", "icon": "res://assets/ui/icons/mechanics/slow.png", "tags": ["timing", "attack-speed-check", "sustained-check"], "valueLabel": "slow %", "min": 0, "max": 80, "exportScale": 0.01, "baseCost": 12, "costPerValue": 0.9, "effectiveHpPerValue": 0.009, "poisonModifier": -0.06, "burstModifier": 0.04, "sustainedModifier": -0.28, "curves": {1: [6, 12], 2: [10, 20], 3: [18, 32], 4: [28, 46], 5: [42, 62], 6: [56, 76]}},
	{"id": "stun_duration_ms", "godotField": "stun_duration_ms", "name": "Stun", "shortName": "Stun", "icon": "res://assets/ui/icons/mechanics/stun.png", "tags": ["timing", "disruption"], "valueLabel": "stun ms", "min": 0, "max": 1200, "exportScale": 1, "previewOnly": false, "baseCost": 14, "costPerValue": 0.06, "effectiveHpPerValue": 0.0005, "poisonModifier": -0.02, "burstModifier": -0.08, "sustainedModifier": -0.16, "extraFields": [{"id": "stun_trigger_hit_percent", "min": 1, "max": 100, "default": 12}], "curves": {1: [100, 200], 2: [150, 300], 3: [250, 450], 4: [400, 650], 5: [600, 900], 6: [800, 1100]}},
	{"id": "interrupt_skip_count", "godotField": "interrupt_skip_count", "name": "Interrupt", "shortName": "Interrupt", "icon": "res://assets/ui/icons/mechanics/interrupt.png", "tags": ["timing", "disruption"], "valueLabel": "skipped casts", "min": 0, "max": 3, "exportScale": 1, "previewOnly": false, "baseCost": 16, "costPerValue": 18, "effectiveHpPerValue": 0.018, "poisonModifier": 0.04, "burstModifier": -0.18, "sustainedModifier": -0.22, "extraFields": [{"id": "interrupt_repeat_threshold", "min": 2, "max": 12, "default": 3}], "curves": {1: [1, 1], 2: [1, 1], 3: [1, 2], 4: [1, 2], 5: [2, 2], 6: [2, 3]}},
]

var mechanics: Array[RuntimeMechanicDef] = []
var notices: Array[RuntimeMonsterNotice] = []
var _mechanics_by_id: Dictionary = {}


static func built_in() -> RuntimeMechanicLibrary:
	var library := RuntimeMechanicLibrary.new()
	for data in _MECHANICS:
		var mechanic := RuntimeMechanicDef.from_dictionary(data, true)
		if not SUPPORTED_GODOT_FIELDS.has(mechanic.godot_field):
			library.add_notice(RuntimeMonsterNotice.SEVERITY_ERROR, "mechanic_unsupported_field", "Runtime mechanic maps to an unsupported Monster field.", {"id": mechanic.id, "field": mechanic.godot_field})
			continue
		library.add_mechanic(mechanic)
	return library


func add_mechanic(mechanic: RuntimeMechanicDef) -> void:
	mechanics.append(mechanic)
	_mechanics_by_id[mechanic.id] = mechanic


func get_mechanic(mechanic_id: String) -> RuntimeMechanicDef:
	return _mechanics_by_id.get(mechanic_id) as RuntimeMechanicDef


func has_mechanic(mechanic_id: String) -> bool:
	return _mechanics_by_id.has(mechanic_id)


func add_notice(severity: String, code: String, message: String, context: Dictionary = {}) -> void:
	notices.append(RuntimeMonsterNotice.make(severity, code, message, context))


func has_errors() -> bool:
	for notice in notices:
		if notice.severity == RuntimeMonsterNotice.SEVERITY_ERROR:
			return true
	return false
