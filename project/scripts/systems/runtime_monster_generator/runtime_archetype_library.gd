class_name RuntimeArchetypeLibrary
extends RefCounted

var schema: String = ""
var library_name: String = ""
var source_path: String = ""
var archetypes: Array[RuntimeArchetypeDef] = []
var notices: Array[RuntimeMonsterNotice] = []

var _archetypes_by_id: Dictionary = {}


func add_archetype(archetype: RuntimeArchetypeDef) -> void:
	archetypes.append(archetype)
	_archetypes_by_id[archetype.id] = archetype


func get_archetype(archetype_id: String) -> RuntimeArchetypeDef:
	return _archetypes_by_id.get(archetype_id) as RuntimeArchetypeDef


func has_archetype(archetype_id: String) -> bool:
	return _archetypes_by_id.has(archetype_id)


func available_for(difficulty_id: int, monster_kind: String) -> Array[RuntimeArchetypeDef]:
	var result: Array[RuntimeArchetypeDef] = []
	for archetype in archetypes:
		if archetype.unlock_difficulty > difficulty_id:
			continue
		if monster_kind != "" and not archetype.allowed_kinds.has(monster_kind):
			continue
		result.append(archetype)
	return result


func add_notice(severity: String, code: String, message: String, context: Dictionary = {}) -> void:
	notices.append(RuntimeMonsterNotice.make(severity, code, message, context))


func has_errors() -> bool:
	for notice in notices:
		if notice.severity == RuntimeMonsterNotice.SEVERITY_ERROR:
			return true
	return false
