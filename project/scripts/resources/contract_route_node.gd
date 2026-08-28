class_name ContractRouteNode
extends Resource

enum NodeType {
	OFFER,
	SUBCLASS_CHOICE,
	FIGHT,
	ELITE,
	BOSS,
	START,
	CAPTAIN,
}

@export var id: String = ""
@export var display_name: String = ""
@export var node_type: NodeType = NodeType.FIGHT
@export var monster: Monster
@export var duration_ms: int = 0
@export var reward: EncounterReward
@export var next_nodes: Array[ContractRouteNode] = []
@export var difficulty_label: String = ""
@export var reward_quality_label: String = ""
@export var route_preview: Dictionary = {}
@export_multiline var summary_text: String = ""
@export_multiline var reward_summary: String = ""
@export_multiline var before_selection_text: String = ""
@export_multiline var selected_text: String = ""
@export_group("Generated Route")
@export var generated_node_id: String = ""
@export var depth: int = -1
@export var lane: int = -1
@export var outgoing_node_ids: PackedStringArray = []
@export var biome: String = ""
@export var monster_presentation_type: String = ""
@export var generated_encounter_payload: Dictionary = {}
@export var combat_preview: Dictionary = {}
@export var debug_preview: Dictionary = {}
@export var generated_modifier_ids: PackedStringArray = []
@export var generated_modifier_labels: PackedStringArray = []
@export var branch_intent: String = ""
@export var branch_intent_tags: PackedStringArray = []
@export var elite_variant_model_version: String = ""
@export var elite_variant_id: String = ""
@export var elite_variant_label: String = ""
@export var boss_variant_model_version: String = ""
@export var boss_variant_id: String = ""
@export var boss_variant_label: String = ""
@export var generation_notices: PackedStringArray = []


func has_generated_state() -> bool:
	return (
		generated_node_id != ""
		or node_type == NodeType.START
		or depth >= 0
		or lane >= 0
		or not outgoing_node_ids.is_empty()
		or biome != ""
		or monster_presentation_type != ""
		or not route_preview.is_empty()
		or not generated_encounter_payload.is_empty()
		or not combat_preview.is_empty()
		or not debug_preview.is_empty()
		or not generated_modifier_ids.is_empty()
		or not generated_modifier_labels.is_empty()
		or branch_intent != ""
		or not branch_intent_tags.is_empty()
		or elite_variant_model_version != ""
		or elite_variant_id != ""
		or elite_variant_label != ""
		or boss_variant_model_version != ""
		or boss_variant_id != ""
		or boss_variant_label != ""
		or not generation_notices.is_empty()
	)


func generated_state() -> Dictionary:
	return {
		"id": id,
		"generated_node_id": generated_node_id,
		"node_type": node_type,
		"depth": depth,
		"lane": lane,
		"outgoing_node_ids": Array(outgoing_node_ids),
		"biome": biome,
		"monster_presentation_type": monster_presentation_type,
		"route_preview": route_preview.duplicate(true),
		"generated_encounter_payload": generated_encounter_payload.duplicate(true),
		"combat_preview": combat_preview.duplicate(true),
		"debug_preview": debug_preview.duplicate(true),
		"generated_modifier_ids": Array(generated_modifier_ids),
		"generated_modifier_labels": Array(generated_modifier_labels),
		"branch_intent": branch_intent,
		"branch_intent_tags": Array(branch_intent_tags),
		"elite_variant_model_version": elite_variant_model_version,
		"elite_variant_id": elite_variant_id,
		"elite_variant_label": elite_variant_label,
		"boss_variant_model_version": boss_variant_model_version,
		"boss_variant_id": boss_variant_id,
		"boss_variant_label": boss_variant_label,
		"generation_notices": Array(generation_notices),
	}


func apply_generated_state(state: Dictionary) -> void:
	generated_node_id = String(state.get("generated_node_id", generated_node_id))
	depth = int(state.get("depth", depth))
	lane = int(state.get("lane", lane))
	outgoing_node_ids = _packed_string_array(state.get("outgoing_node_ids", outgoing_node_ids))
	biome = String(state.get("biome", biome))
	monster_presentation_type = String(state.get("monster_presentation_type", monster_presentation_type))
	route_preview = (state.get("route_preview", route_preview) as Dictionary).duplicate(true)
	generated_encounter_payload = (state.get("generated_encounter_payload", generated_encounter_payload) as Dictionary).duplicate(true)
	combat_preview = (state.get("combat_preview", combat_preview) as Dictionary).duplicate(true)
	debug_preview = (state.get("debug_preview", debug_preview) as Dictionary).duplicate(true)
	generated_modifier_ids = _packed_string_array(state.get("generated_modifier_ids", generated_modifier_ids))
	generated_modifier_labels = _packed_string_array(state.get("generated_modifier_labels", generated_modifier_labels))
	branch_intent = String(state.get("branch_intent", branch_intent))
	branch_intent_tags = _packed_string_array(state.get("branch_intent_tags", branch_intent_tags))
	elite_variant_model_version = String(state.get("elite_variant_model_version", elite_variant_model_version))
	elite_variant_id = String(state.get("elite_variant_id", elite_variant_id))
	elite_variant_label = String(state.get("elite_variant_label", elite_variant_label))
	boss_variant_model_version = String(state.get("boss_variant_model_version", boss_variant_model_version))
	boss_variant_id = String(state.get("boss_variant_id", boss_variant_id))
	boss_variant_label = String(state.get("boss_variant_label", boss_variant_label))
	generation_notices = _packed_string_array(state.get("generation_notices", generation_notices))


func sync_outgoing_node_ids_from_next_nodes() -> void:
	outgoing_node_ids.clear()
	for next_node in next_nodes:
		if next_node != null:
			outgoing_node_ids.append(next_node.generated_node_id if next_node.generated_node_id != "" else next_node.id)


static func _packed_string_array(value: Variant) -> PackedStringArray:
	var result := PackedStringArray()
	if value is PackedStringArray:
		return value
	if value is Array:
		for item in value:
			result.append(String(item))
	return result


## Depth-first search for a node by id, cycle-safe via `visited`. Static and
## living on the resource itself (rather than on any one screen) because both
## contract_overlay.gd and map_overlay.gd need it after the overlay
## decomposition in docs/Phase_3_Technical_Debt_Architecture_Cleanup.md --
## previously a private duplicate-prone helper on combat_screen.gd.
static func find_by_id(root_node: ContractRouteNode, id: String, visited: Array[String] = []) -> ContractRouteNode:
	if root_node == null or visited.has(root_node.id):
		return null
	if root_node.id == id:
		return root_node
	visited.append(root_node.id)
	for child in root_node.next_nodes:
		var found := find_by_id(child, id, visited)
		if found != null:
			return found
	return null
