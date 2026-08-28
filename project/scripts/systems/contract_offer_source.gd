class_name ContractOfferSource
extends RefCounted

const SOURCE_VERSION := "p4m6.t3.v1"
const GILDED_SERPENT_CONTRACT_PATH := "res://data/contracts/the_gilded_serpent.tres"
const GENERATED_ROLL_CONTEXT := "contract_offer_source.generated"
const GENERATED_DEBUG_ROLL_CONTEXT := "contract_offer_source.generated_debug"
const OFFER_TEXT_VERSION := "p4m8.t4.rogue.v1"
const OFFER_TEXT_CONTEXT := "contract_offer_source.offer_text"
const ContractRouteGeneratorScript := preload("res://scripts/systems/contract_route_generator/contract_route_generator.gd")
const RunRngScript := preload("res://scripts/systems/run_rng.gd")

const ROGUE_DIFFICULTY_LEADS := {
	"easy": "Looks simple enough. Which is exactly how people get embarrassed.",
	"medium": "Could be worse. Could be raining knives.",
	"hard": "This one might be a bit dicey. Good thing I am a gambler.",
	"ultra": "That is a terrible idea. I am listening.",
	"nightmare": "Everyone says this is suicide. Rude of them to make it sound tempting.",
}

const ROGUE_CONTRACT_TEXT_TEMPLATES := [
	"Someone went into {biome} and did not come back. Tragic, yes. Also billable. The name on the board is {boss_name}.",
	"The road through {biome} is closed again. Merchants call it a crisis. I call it leverage, especially with {boss_name} involved.",
	"{biome} is doing that charming thing where the locals refuse to say what they saw. They did write down {boss_name}, though, so that is something.",
	"{boss_name} has a price on their head somewhere in {biome}. I do enjoy when paperwork and violence agree.",
	"Whatever is spreading out of {biome}, people want it stopped before it learns ambition. Naturally, that means finding {boss_name}.",
	"A client lost something valuable in {biome}. I am told it was not their nerve, but we shall see once {boss_name} stops objecting.",
	"Someone made a bargain near {biome}. Someone else hired me to make it stop collecting interest. {boss_name} is apparently the collector.",
	"{boss_name} is claiming territory in {biome}. Bold. I respect bold. I also invoice it.",
	"Survivors keep pointing toward {biome} and then getting very quiet. I suppose {boss_name} and I should have a professional disagreement.",
	"The notice says not to underestimate {boss_name}. Adorable. It also says {biome}, so at least the scenery will try to kill me too.",
	"People are leaving offerings around {biome} and pretending that is a plan. I prefer my plan: find {boss_name}, get paid.",
	"A sealed report names {boss_name} as the problem in {biome}. I love sealed reports. They make the danger sound expensive.",
]


static func contract_offers(context: Dictionary = {}) -> Array[ContractDef]:
	var offers: Array[ContractDef] = []
	if bool(context.get("include_authored", true)):
		var gilded_serpent := _load_authored_contract(GILDED_SERPENT_CONTRACT_PATH)
		if gilded_serpent != null:
			offers.append(gilded_serpent)
	if bool(context.get("include_generated", false)):
		var count: int = max(1, int(context.get("generated_offer_count", 1)))
		for i in count:
			var generated: ContractDef = generated_contract_offer(context, i)
			if generated != null:
				offers.append(generated)
	return offers


static func first_contract_offer(context: Dictionary = {}) -> ContractDef:
	var offers: Array[ContractDef] = contract_offers(context)
	return offers[0] if not offers.is_empty() else null


static func generated_contract_offer(context: Dictionary = {}, generated_offer_index: int = 0) -> ContractDef:
	var route_settings: Dictionary = (context.get("settings", {}) as Dictionary).duplicate(true)
	route_settings["completed_contract_count"] = int(context.get("completed_contract_count", 0))
	route_settings["earned_talent_points"] = int(context.get("earned_talent_points", route_settings.get("earned_talent_points", 0)))
	var seed: int = _generated_offer_seed(context, generated_offer_index, route_settings)
	var contract: ContractDef = ContractRouteGeneratorScript.generate(seed, route_settings)
	if contract == null:
		return null
	_apply_generated_offer_identity(contract)
	return contract


static func offer_context(
	adventure_seed: int,
	contract_offer_index: int = 0,
	completed_contract_count: int = 0,
	debug_seed_override: int = -1,
	settings: Dictionary = {},
	include_authored: bool = true,
	include_generated: bool = false,
	generated_offer_count: int = 1
) -> Dictionary:
	return {
		"source_version": SOURCE_VERSION,
		"adventure_seed": adventure_seed,
		"contract_offer_index": contract_offer_index,
		"completed_contract_count": completed_contract_count,
		"debug_seed_override": debug_seed_override,
		"settings": settings.duplicate(true),
		"include_authored": include_authored,
		"include_generated": include_generated,
		"generated_offer_count": generated_offer_count,
	}


static func authored_offer_paths() -> PackedStringArray:
	return PackedStringArray([GILDED_SERPENT_CONTRACT_PATH])


static func _load_authored_contract(path: String) -> ContractDef:
	if not ResourceLoader.exists(path):
		return null
	return load(path) as ContractDef


static func _generated_offer_seed(context: Dictionary, generated_offer_index: int, route_settings: Dictionary) -> int:
	var debug_seed := int(context.get("debug_seed_override", -1))
	if debug_seed >= 0 and int(context.get("generated_offer_count", 1)) <= 1:
		return debug_seed
	var seed_base: int = debug_seed if debug_seed >= 0 else int(context.get("adventure_seed", 1))
	var roll_context: String = GENERATED_DEBUG_ROLL_CONTEXT if debug_seed >= 0 else GENERATED_ROLL_CONTEXT
	return RunRngScript.seed_for_context(seed_base, roll_context, [
		SOURCE_VERSION,
		ContractRouteGeneratorScript.GENERATOR_VERSION,
		int(context.get("contract_offer_index", 0)),
		int(context.get("completed_contract_count", 0)),
		generated_offer_index,
		_settings_signature(route_settings),
	])


static func _apply_generated_offer_identity(contract: ContractDef) -> void:
	var biome: String = contract.selected_biome if contract.selected_biome != "" else "Unknown"
	contract.display_name = "%s Contract" % biome
	contract.target_display_name = _generated_boss_name(contract)
	contract.offer_text = _generated_offer_text(contract, biome, contract.target_display_name)


static func _generated_offer_text(contract: ContractDef, biome: String, boss_name: String) -> String:
	var difficulty := contract.route_difficulty if contract.route_difficulty != "" else "medium"
	var lead: String = ROGUE_DIFFICULTY_LEADS.get(difficulty, ROGUE_DIFFICULTY_LEADS["medium"])
	var template := _pick_offer_template(contract, biome, boss_name, difficulty)
	return "%s %s" % [
		lead,
		_template_offer_text(template, biome, boss_name),
	]


static func _pick_offer_template(contract: ContractDef, biome: String, boss_name: String, difficulty: String) -> String:
	var rng := RunRngScript.rng_for_context(
		contract.source_seed,
		OFFER_TEXT_CONTEXT,
		[
			SOURCE_VERSION,
			OFFER_TEXT_VERSION,
			contract.generated_route_id,
			biome,
			boss_name,
			difficulty,
			ROGUE_CONTRACT_TEXT_TEMPLATES.size(),
		]
	)
	var index := rng.randi_range(0, ROGUE_CONTRACT_TEXT_TEMPLATES.size() - 1)
	return String(ROGUE_CONTRACT_TEXT_TEMPLATES[index])


static func _template_offer_text(template: String, biome: String, boss_name: String) -> String:
	return template.replace("{biome}", biome).replace("{boss_name}", boss_name)


static func _generated_boss_name(contract: ContractDef) -> String:
	var boss: ContractRouteNode = _first_node_of_type(contract.offer_node, ContractRouteNode.NodeType.BOSS)
	if boss != null:
		var name := String(boss.route_preview.get("monster_name", ""))
		if name != "":
			return name
	return "Generated Boss"


static func _first_node_of_type(node: ContractRouteNode, node_type: int, visited: Dictionary = {}) -> ContractRouteNode:
	if node == null or visited.has(node.id):
		return null
	visited[node.id] = true
	if node.node_type == node_type:
		return node
	for next_node in node.next_nodes:
		var found: ContractRouteNode = _first_node_of_type(next_node, node_type, visited)
		if found != null:
			return found
	return null


static func _settings_signature(settings: Dictionary) -> String:
	var parts: PackedStringArray = []
	var keys: Array = settings.keys()
	keys.sort()
	for key in keys:
		if String(key) == "earned_talent_points":
			continue
		parts.append("%s=%s" % [String(key), str(settings[key])])
	return ";".join(parts)
