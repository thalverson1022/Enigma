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
