class_name SaveSystem
extends RefCounted
## Converts BuildState run state to/from a JSON save file, per
## docs/Phase_2_R6_Save_Load_Persistence.md's P2:R6:T1/T2 scope and format
## decisions.
##
## Authored resources (class/trees/talents/contract/route node, and any
## GearItem loaded from a .tres file) are saved as resource_path and
## restored via load(). Rotation skills are runtime clones with no
## resource_path, so they're saved by stable Skill.id and restored by
## matching against BuildState.unlocked_skills() after class/trees/talents
## are committed. Runtime-generated GearItem instances (empty resource_path,
## produced by GearGenerator) are saved as plain value data.
##
## load_run() resolves every field into locals first and only writes them to
## `state` if the whole save is structurally valid, so a corrupt/incompatible
## save file leaves the live state untouched. Individual unresolved gear
## references (e.g. a deleted authored .tres) degrade gracefully by being
## dropped/cleared rather than failing the whole load, since they only cost
## the player one item, not the ability to resume at all.

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1

static var save_path := SAVE_PATH


static func has_save() -> bool:
	return FileAccess.file_exists(save_path)


static func delete_save() -> void:
	if has_save():
		if save_path.begins_with("user://"):
			var user_dir := DirAccess.open("user://")
			if user_dir != null:
				user_dir.remove(save_path.trim_prefix("user://"))
		else:
			DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))


static func save_run(state) -> bool:
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(_serialize(state), "\t"))
	file.close()
	return true


## Returns true on a successful load, having written every field to `state`.
## Returns false and leaves `state` untouched on any missing/corrupt/
## incompatible save -- callers should treat that as "start a new run".
static func load_run(state) -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	if int(parsed.get("save_version", -1)) != SAVE_VERSION:
		return false
	return _deserialize(parsed, state)


static func _serialize(state) -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"selected_class": _resource_path_or_null(state.selected_class),
		"selected_trees": _resource_paths(state.selected_trees),
		"selected_talents": _resource_paths(state.selected_talents),
		"rotation_skill_ids": _skill_ids(state.rotation),
		"adventure_seed": state.adventure_seed,
		"gold": state.gold,
		"earned_talent_points": state.earned_talent_points,
		"inventory": _gear_list_to_data(state.inventory),
		"claimed_reward_encounter_indices": state.claimed_reward_encounter_indices.duplicate(),
		"shop_unlocked": state.shop_unlocked,
		"shop_round_pending": state.shop_round_pending,
		"shop_reroll_used": state.shop_reroll_used,
		"shop_reroll_count": state.shop_reroll_count,
		"shop_reroll_cost": state.shop_reroll_cost,
		"shop_round_index": state.shop_round_index,
		"shop_offers": _gear_list_to_data(state.shop_offers),
		"pending_reward_choices": _gear_list_to_data(state.pending_reward_choices),
		"equipped_weapon": _gear_entry_to_data(state.equipped_weapon),
		"equipped_trinket": _gear_entry_to_data(state.equipped_trinket),
		"equipped_charm": _gear_entry_to_data(state.equipped_charm),
		"active_contract": _resource_path_or_null(state.active_contract),
		"current_route_node": _resource_path_or_null(state.current_route_node),
		"claimed_route_reward_ids": state.claimed_route_reward_ids.duplicate(),
		"current_encounter_index": state.current_encounter_index,
		"encounter_failure_counts": state.encounter_failure_counts.duplicate(),
		# A mid-fight save can only happen from a hard crash/quit -- combat
		# resolves synchronously with no persisted tick state, so it's never
		# meaningful to resume mid-FIGHTING. Normalize it back to PLANNING.
		"run_phase": (
			state.RunPhase.PLANNING
			if state.run_phase == state.RunPhase.FIGHTING
			else state.run_phase
		),
		"run_outcome": state.run_outcome,
		"last_fight_won": state.last_fight_won,
		"tavern_map_choice_made": state.tavern_map_choice_made,
		# build_locked is intentionally not persisted -- any load should
		# require re-confirming the build lock before fighting again.
	}


static func _deserialize(data: Dictionary, state) -> bool:
	var resolved_class: ClassDef = null
	if data.get("selected_class") != null:
		resolved_class = _load_or_null(data.get("selected_class"))
		if resolved_class == null:
			return false

	var resolved_trees: Array[SubclassTree] = []
	for path in data.get("selected_trees", []):
		var tree: SubclassTree = _load_or_null(path)
		if tree == null:
			return false
		resolved_trees.append(tree)

	var resolved_talents: Array[Talent] = []
	for path in data.get("selected_talents", []):
		var talent: Talent = _load_or_null(path)
		if talent == null:
			return false
		resolved_talents.append(talent)

	var resolved_active_contract: ContractDef = null
	if data.get("active_contract") != null:
		resolved_active_contract = _load_or_null(data.get("active_contract"))
		if resolved_active_contract == null:
			return false

	var resolved_route_node: ContractRouteNode = null
	if data.get("current_route_node") != null:
		resolved_route_node = _load_or_null(data.get("current_route_node"))
		if resolved_route_node == null:
			return false

	state.selected_class = resolved_class
	state.selected_trees = resolved_trees
	state.selected_talents = resolved_talents
	state.adventure_seed = int(data.get("adventure_seed", 1))
	state.gold = int(data.get("gold", 0))
	state.earned_talent_points = int(data.get("earned_talent_points", 0))
	state.inventory = _gear_list_from_data(data.get("inventory", []))
	state.claimed_reward_encounter_indices = _int_array(data.get("claimed_reward_encounter_indices", []))
	state.shop_unlocked = bool(data.get("shop_unlocked", false))
	state.shop_round_pending = bool(data.get("shop_round_pending", false))
	state.shop_reroll_used = bool(data.get("shop_reroll_used", false))
	state.shop_reroll_count = int(data.get("shop_reroll_count", 1 if state.shop_reroll_used else 0))
	state.shop_reroll_cost = int(data.get(
		"shop_reroll_cost",
		state.SHOP_REROLL_INITIAL_COST + (state.shop_reroll_count * state.SHOP_REROLL_COST_STEP)
	))
	state.shop_round_index = int(data.get("shop_round_index", 0))
	state.shop_offers = _gear_list_from_data(data.get("shop_offers", []))
	state.pending_reward_choices = _gear_list_from_data(data.get("pending_reward_choices", []))
	state.equipped_weapon = _gear_from_entry(data.get("equipped_weapon"))
	state.equipped_trinket = _gear_from_entry(data.get("equipped_trinket"))
	state.equipped_charm = _gear_from_entry(data.get("equipped_charm"))
	state.active_contract = resolved_active_contract
	state.current_route_node = resolved_route_node
	state.claimed_route_reward_ids = _string_array(data.get("claimed_route_reward_ids", []))
	state.current_encounter_index = int(data.get("current_encounter_index", 0))
	state.encounter_failure_counts = _int_dictionary(data.get("encounter_failure_counts", {}))
	var saved_phase := int(data.get("run_phase", state.RunPhase.PLANNING))
	state.run_phase = state.RunPhase.PLANNING if saved_phase == state.RunPhase.FIGHTING else saved_phase
	state.run_outcome = int(data.get("run_outcome", state.RunOutcome.NONE))
	state.last_fight_won = bool(data.get("last_fight_won", false))
	state.tavern_map_choice_made = bool(data.get("tavern_map_choice_made", false))
	state.build_locked = false

	# Rotation depends on unlocked_skills(), which reads selected_class/
	# selected_trees/selected_talents -- resolve it last, now that those are
	# committed.
	var unlocked: Array[Skill] = state.unlocked_skills()
	var resolved_rotation: Array[Skill] = []
	for skill_id in data.get("rotation_skill_ids", []):
		var skill := _find_skill_by_id(unlocked, str(skill_id))
		if skill != null:
			resolved_rotation.append(skill)
	state.rotation = resolved_rotation

	state.build_changed.emit()
	state.run_state_changed.emit()
	state.lock_changed.emit()
	return true


static func _gear_entry_to_data(item: GearItem) -> Variant:
	if item == null:
		return null
	if item.resource_path != "":
		return {"resource_path": item.resource_path}
	var affixes := []
	for modifier in item.affixes:
		affixes.append({"stat": modifier.stat, "operation": modifier.operation, "value": modifier.value})
	return {
		"id": item.id,
		"display_name": item.display_name,
		"slot": item.slot,
		"tier": item.tier,
		"affixes": affixes,
	}


static func _gear_list_to_data(items: Array[GearItem]) -> Array:
	var out := []
	for item in items:
		out.append(_gear_entry_to_data(item))
	return out


static func _gear_from_entry(entry) -> GearItem:
	if typeof(entry) != TYPE_DICTIONARY:
		return null
	if entry.has("resource_path"):
		return _load_or_null(entry["resource_path"])
	var item := GearItem.new()
	item.id = str(entry.get("id", ""))
	item.display_name = str(entry.get("display_name", ""))
	item.slot = int(entry.get("slot", GearItem.SlotType.WEAPON))
	item.tier = int(entry.get("tier", GearItem.Tier.BASIC))
	var affixes: Array[StatModifier] = []
	for affix_data in entry.get("affixes", []):
		var modifier := StatModifier.new()
		modifier.stat = int(affix_data.get("stat", 0))
		modifier.operation = int(affix_data.get("operation", 0))
		modifier.value = float(affix_data.get("value", 0.0))
		affixes.append(modifier)
	item.affixes = affixes
	return item


## Drops entries that fail to resolve (e.g. a deleted authored .tres) rather
## than failing the whole load -- see the class-level doc comment.
static func _gear_list_from_data(list) -> Array[GearItem]:
	var out: Array[GearItem] = []
	if typeof(list) != TYPE_ARRAY:
		return out
	for entry in list:
		var item := _gear_from_entry(entry)
		if item != null:
			out.append(item)
	return out


static func _resource_path_or_null(resource: Resource) -> Variant:
	return resource.resource_path if resource != null else null


static func _resource_paths(resources: Array) -> Array:
	var out := []
	for resource in resources:
		out.append(resource.resource_path)
	return out


static func _skill_ids(skills: Array[Skill]) -> Array:
	var out := []
	for skill in skills:
		out.append(skill.id)
	return out


static func _find_skill_by_id(skills: Array[Skill], skill_id: String) -> Skill:
	for skill in skills:
		if skill != null and skill.id == skill_id:
			return skill
	return null


## JSON has no int/float distinction -- Godot's JSON parser always produces
## float values for numbers, so failure counts must be explicitly re-cast to
## int on load or they'd silently become floats (harmless where callers
## already wrap reads in int(), but not a faithful restore of the field).
static func _int_dictionary(dict) -> Dictionary:
	var out := {}
	if typeof(dict) != TYPE_DICTIONARY:
		return out
	for key in dict.keys():
		out[str(key)] = int(dict[key])
	return out


static func _int_array(list) -> Array[int]:
	var out: Array[int] = []
	if typeof(list) != TYPE_ARRAY:
		return out
	for value in list:
		out.append(int(value))
	return out


static func _string_array(list) -> Array[String]:
	var out: Array[String] = []
	if typeof(list) != TYPE_ARRAY:
		return out
	for value in list:
		out.append(str(value))
	return out


static func _load_or_null(path):
	if typeof(path) != TYPE_STRING or path == "":
		return null
	if not ResourceLoader.exists(path):
		return null
	return load(path)
