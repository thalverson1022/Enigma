class_name GeneratedMonsterDraft
extends RefCounted

const MONSTER_DEFENSE_FIELDS := [
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

var id: String = ""
var display_name: String = ""
var hp: int = 0
var duration_ms: int = 0
var target_dps: float = 0.0
var monster_kind: String = "normal"
var defense_overrides: Dictionary = {}
var selected_mechanics: Array = []
var archetype_ids: PackedStringArray = []
var tags: PackedStringArray = []
var budget_metadata: Dictionary = {}
var pressure_metadata: Dictionary = {}
var notices: Array[RuntimeMonsterNotice] = []
var source_seed: int = 1
var source_input: RuntimeGenerationInput = null


static func from_dictionary(source: Dictionary) -> GeneratedMonsterDraft:
	var data := RuntimeMonsterDataNormalizer.snake_keys(source)
	var draft := GeneratedMonsterDraft.new()
	draft.id = String(data.get("id", ""))
	draft.display_name = String(data.get("display_name", data.get("name", "")))
	draft.hp = int(data.get("hp", 0))
	draft.duration_ms = int(data.get("duration_ms", data.get("duration", 0)))
	draft.target_dps = float(data.get("target_dps", 0.0))
	draft.monster_kind = String(data.get("monster_kind", data.get("kind", "normal")))
	draft.defense_overrides = RuntimeMonsterDataNormalizer.preserve_dictionary(data.get("defense_overrides", data.get("monster_overrides", {})))
	draft.selected_mechanics = RuntimeMonsterDataNormalizer.preserve_array(data.get("selected_mechanics", []))
	draft.archetype_ids = RuntimeMonsterDataNormalizer.string_array(data.get("archetype_ids", data.get("archetypes", [])))
	draft.tags = RuntimeMonsterDataNormalizer.string_array(data.get("tags", []))
	draft.budget_metadata = RuntimeMonsterDataNormalizer.preserve_dictionary(data.get("budget_metadata", {}))
	draft.pressure_metadata = RuntimeMonsterDataNormalizer.preserve_dictionary(data.get("pressure_metadata", {}))
	for notice_data in RuntimeMonsterDataNormalizer.preserve_array(data.get("notices", [])):
		if notice_data is Dictionary:
			draft.notices.append(RuntimeMonsterNotice.from_dictionary(notice_data))
	draft.source_seed = int(data.get("source_seed", data.get("seed", 1)))
	if data.get("source_input", null) is Dictionary:
		draft.source_input = RuntimeGenerationInput.from_dictionary(data["source_input"])
	return draft


func to_monster() -> Monster:
	var monster := Monster.new()
	monster.id = id
	monster.display_name = display_name
	monster.hp = hp
	for field in MONSTER_DEFENSE_FIELDS:
		if defense_overrides.has(field):
			_apply_monster_field(monster, field, defense_overrides[field])
	return monster


func to_combat_payload() -> Dictionary:
	return {
		"monster": to_monster(),
		"duration_ms": duration_ms,
		"target_dps": target_dps,
		"metadata": _metadata_dictionary(),
	}


func to_dictionary() -> Dictionary:
	var notice_data := []
	for notice in notices:
		notice_data.append(notice.to_dictionary())
	return {
		"id": id,
		"display_name": display_name,
		"hp": hp,
		"duration_ms": duration_ms,
		"target_dps": target_dps,
		"monster_kind": monster_kind,
		"defense_overrides": defense_overrides.duplicate(true),
		"selected_mechanics": selected_mechanics.duplicate(true),
		"archetype_ids": _packed_strings_to_array(archetype_ids),
		"tags": _packed_strings_to_array(tags),
		"budget_metadata": budget_metadata.duplicate(true),
		"pressure_metadata": pressure_metadata.duplicate(true),
		"notices": notice_data,
		"source_seed": source_seed,
		"source_input": source_input.to_dictionary() if source_input != null else {},
	}


func add_notice(severity: String, code: String, message: String, context: Dictionary = {}) -> RuntimeMonsterNotice:
	var notice := RuntimeMonsterNotice.make(severity, code, message, context)
	notices.append(notice)
	return notice


func has_errors() -> bool:
	for notice in notices:
		if notice.severity == RuntimeMonsterNotice.SEVERITY_ERROR:
			return true
	return false


func _metadata_dictionary() -> Dictionary:
	return {
		"source_seed": source_seed,
		"source_input": source_input.to_dictionary() if source_input != null else {},
		"archetype_ids": _packed_strings_to_array(archetype_ids),
		"tags": _packed_strings_to_array(tags),
		"monster_kind": monster_kind,
		"selected_mechanics": selected_mechanics.duplicate(true),
		"budget_metadata": budget_metadata.duplicate(true),
		"pressure_metadata": pressure_metadata.duplicate(true),
		"notices": _notice_dictionaries(),
	}


func _notice_dictionaries() -> Array:
	var result := []
	for notice in notices:
		result.append(notice.to_dictionary())
	return result


func _packed_strings_to_array(values: PackedStringArray) -> Array:
	var result := []
	for value in values:
		result.append(value)
	return result


func _apply_monster_field(monster: Monster, field: String, value: Variant) -> void:
	match field:
		"armor":
			monster.armor = int(value)
		"poison_resistance":
			monster.poison_resistance = float(value)
		"dodge_chance":
			monster.dodge_chance = float(value)
		"crit_negation":
			monster.crit_negation = float(value)
		"block":
			monster.block = float(value)
		"absorb":
			monster.absorb = float(value)
		"cleanse_threshold":
			monster.cleanse_threshold = int(value)
		"suppress":
			monster.suppress = float(value)
		"slow":
			monster.slow = float(value)
		"stun_duration_ms":
			monster.stun_duration_ms = int(value)
		"interrupt_skip_count":
			monster.interrupt_skip_count = int(value)
