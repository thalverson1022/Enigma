class_name EncounterPreviewFormatter
extends RefCounted

const DEFAULT_BIOME := "Unknown Biome"
const DEFAULT_ENCOUNTER_LEVEL := "Normal"
const EncounterArchetypeVocabularyScript := preload("res://scripts/systems/runtime_monster_generator/encounter_archetype_vocabulary.gd")
const DIFFICULTY_LABELS := {
	1: "Easy",
	2: "Medium",
	3: "Hard",
	4: "Ultra",
	5: "Nightmare",
}


static func format_generated(draft: GeneratedMonsterDraft, context: Dictionary = {}) -> Dictionary:
	if draft == null:
		return {
			"contract_map": {},
			"combat": {},
			"debug": {},
		}

	var monster_name := String(context.get("monster_name", draft.display_name))
	var encounter_level := _encounter_level(context.get("encounter_level", draft.monster_kind))
	var archetype_tags := EncounterArchetypeVocabularyScript.tags_for_ids(draft.archetype_ids)
	var archetype_summaries := EncounterArchetypeVocabularyScript.combat_summaries_for_ids(draft.archetype_ids)

	return {
		"contract_map": {
			"biome": String(context.get("biome", DEFAULT_BIOME)),
			"monster_name": monster_name,
			"encounter_level": encounter_level,
			"archetype_tags": archetype_tags,
			"archetype_line": _join_strings(archetype_tags, " + "),
		},
		"combat": {
			"monster_name": monster_name,
			"hp": draft.hp,
			"duration_seconds": roundi(float(draft.duration_ms) / 1000.0),
			"encounter_level": encounter_level,
			"archetype_tags": archetype_tags,
			"archetype_summaries": archetype_summaries,
			"defense_overrides": draft.defense_overrides.duplicate(true),
			"selected_mechanics": draft.selected_mechanics.duplicate(true),
		},
		"debug": {
			"source_seed": draft.source_seed,
			"difficulty": _difficulty_label(draft),
			"difficulty_id": _difficulty_id(draft),
			"monster_kind": draft.monster_kind,
			"tempo_profile": _tempo_profile(draft),
			"archetype_ids": archetype_tags,
			"raw_archetype_ids": _packed_strings_to_array(draft.archetype_ids),
			"archetype_language": archetype_summaries.duplicate(true),
			"tags": _packed_strings_to_array(draft.tags),
			"selected_mechanics": draft.selected_mechanics.duplicate(true),
			"budget_metadata": draft.budget_metadata.duplicate(true),
			"pressure_metadata": draft.pressure_metadata.duplicate(true),
			"notices": _notice_dictionaries(draft.notices),
		},
	}


static func format_practice_debug_text(draft: GeneratedMonsterDraft) -> String:
	if draft == null:
		return "No generated target rolled."

	var preview := format_generated(draft)
	var debug: Dictionary = preview["debug"]
	var combat: Dictionary = preview["combat"]
	var lines := PackedStringArray()
	lines.append("Difficulty: %s | Kind: %s | Tempo: %s" % [
		String(debug["difficulty"]),
		String(debug["monster_kind"]).capitalize(),
		String(debug["tempo_profile"]).capitalize(),
	])
	lines.append("HP: %d | Duration: %ds | Seed: %d" % [
		int(combat["hp"]),
		int(combat["duration_seconds"]),
		int(debug["source_seed"]),
	])
	lines.append("Archetypes: %s" % _join_strings(debug["archetype_ids"]))
	lines.append("Tags: %s" % _join_strings(debug["tags"]))
	lines.append("")
	lines.append("Selected Mechanics")
	lines.append(_mechanic_summary(debug["selected_mechanics"]))
	lines.append("")
	lines.append("Budget")
	lines.append(_budget_summary(debug["budget_metadata"]))
	lines.append("")
	lines.append("Notices")
	lines.append(_notice_summary(debug["notices"]))
	return "\n".join(lines)


static func _difficulty_label(draft: GeneratedMonsterDraft) -> String:
	return DIFFICULTY_LABELS.get(_difficulty_id(draft), "Unknown")


static func _difficulty_id(draft: GeneratedMonsterDraft) -> int:
	if draft.source_input != null:
		return draft.source_input.difficulty_id
	return 0


static func _tempo_profile(draft: GeneratedMonsterDraft) -> String:
	if draft.source_input != null:
		return draft.source_input.tempo_profile
	return str(draft.pressure_metadata.get("tempo_profile", "unknown"))


static func _encounter_level(value: Variant) -> String:
	var text := String(value)
	if text == "":
		return DEFAULT_ENCOUNTER_LEVEL
	return text.capitalize()


static func _packed_strings_to_array(values: PackedStringArray) -> Array:
	var result := []
	for value in values:
		result.append(value)
	return result


static func _join_strings(values: Array, separator: String = ", ") -> String:
	var parts := PackedStringArray()
	for value in values:
		parts.append(str(value))
	return separator.join(parts) if not parts.is_empty() else "None"


static func _mechanic_summary(mechanics: Array) -> String:
	var parts := PackedStringArray()
	for entry in mechanics:
		parts.append("%s: raw %s, combat %s, field %s, cost %d" % [
			str(entry.get("short_name", entry.get("name", entry.get("id", "")))),
			str(entry.get("value", "")),
			str(entry.get("godot_value", entry.get("value", ""))),
			str(entry.get("godot_field", "")),
			int(entry.get("cost", 0)),
		])
	return "\n".join(parts) if not parts.is_empty() else "None"


static func _budget_summary(metadata: Dictionary) -> String:
	if metadata.is_empty():
		return "None"
	return "Budget %d | Total %d | Delta %+d | Major %d/%d" % [
		int(metadata.get("budget", 0)),
		int(metadata.get("total_cost", 0)),
		int(metadata.get("budget_delta", 0)),
		int(metadata.get("major_defense_count", 0)),
		int(metadata.get("max_major_defenses", 0)),
	]


static func _notice_summary(notices: Array) -> String:
	var parts := PackedStringArray()
	for notice in notices:
		parts.append("%s: %s" % [
			String(notice.get("severity", RuntimeMonsterNotice.SEVERITY_INFO)).capitalize(),
			String(notice.get("message", "")),
		])
	return "\n".join(parts) if not parts.is_empty() else "None"


static func _notice_dictionaries(notices: Array[RuntimeMonsterNotice]) -> Array:
	var result := []
	for notice in notices:
		result.append(notice.to_dictionary())
	return result
