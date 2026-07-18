class_name ContractRouteNode
extends Resource

enum NodeType {
	OFFER,
	SUBCLASS_CHOICE,
	FIGHT,
	ELITE,
	BOSS,
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
@export_multiline var summary_text: String = ""
@export_multiline var reward_summary: String = ""
