class_name ContractDef
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var target_display_name: String = ""
@export var target_monster: Monster
@export_multiline var offer_text: String = ""
@export var offer_node: ContractRouteNode
