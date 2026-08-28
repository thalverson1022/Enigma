extends SceneTree
## Focused P4M6-T6 check: committed generated route nodes become
## deterministic combat-ready encounters while preserving generated payloads.

const ContractOfferSourceScript := preload("res://scripts/systems/contract_offer_source.gd")


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	build_state.set_adventure_seed(424242)

	var node := _commit_first_generated_route_node(build_state)
	var payload: Dictionary = node.generated_encounter_payload.duplicate(true)
	var combat_preview: Dictionary = node.combat_preview.duplicate(true)
	var debug_preview: Dictionary = node.debug_preview.duplicate(true)
	var draft := GeneratedMonsterDraft.from_dictionary(payload)

	_require(node.monster != null, "Expected committed generated route node to have a Monster.")
	_require(node.monster.id == String(payload["id"]), "Expected generated monster id to come from payload.")
	_require(node.monster.display_name == String(combat_preview["monster_name"]), "Expected generated monster presentation name to come from combat preview.")
	_require(node.monster.hp == int(payload["hp"]), "Expected generated monster HP to come from payload.")
	_require(node.duration_ms == int(payload["duration_ms"]), "Expected generated route duration to come from payload.")
	_require(node.duration_ms == draft.duration_ms, "Expected generated route duration to match restored draft.")
	for field in GeneratedMonsterDraft.MONSTER_DEFENSE_FIELDS:
		if (payload["defense_overrides"] as Dictionary).has(field):
			_require(_monster_field_value(node.monster, field) == (payload["defense_overrides"] as Dictionary)[field], "Expected generated monster field %s to match payload." % field)
	_require(node.generated_encounter_payload == payload, "Expected generated encounter payload to be preserved after combat setup.")
	_require(node.combat_preview == combat_preview, "Expected generated combat preview to be preserved after combat setup.")
	_require(node.debug_preview == debug_preview, "Expected generated debug preview to be preserved after combat setup.")
	_require(int(debug_preview["source_seed"]) == int(payload["source_seed"]), "Expected debug seed to match payload seed.")

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[0])
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected Rogue setup to unlock at least one skill.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)
	build_state.set_locked(true)
	_require(build_state.can_start_current_fight(), "Expected generated route fight to be startable after rotation and build lock.")
	_require(build_state.current_target_monster() == node.monster, "Expected current target monster to be the generated monster.")
	_require(build_state.current_target_duration_ms() == node.duration_ms, "Expected current target duration to be generated duration.")
	_require(build_state.current_fight_label() == node.display_name, "Expected fight label to remain the route node label.")
	_require(not build_state.pending_contract_offers.is_empty(), "Expected generated contract offers to remain pending before combat starts.")
	_require(build_state.start_fight(), "Expected generated route fight to start.")
	_require(build_state.pending_contract_offers.is_empty(), "Expected generated contract offers to clear when first combat starts.")

	print("Generated combat setup check: OK")
	quit()


func _commit_first_generated_route_node(build_state) -> ContractRouteNode:
	var context := ContractOfferSourceScript.offer_context(
		424242,
		0,
		0,
		-1,
		{"route_difficulty": "medium", "allowed_biomes": ["Graveyard"]},
		false,
		true
	)
	_require(build_state.start_contract_offer(context), "Expected generated-only contract offer to start.")
	_require(build_state.accept_contract_offer(), "Expected generated contract offer to accept.")
	var node: ContractRouteNode = build_state.current_route_node.next_nodes[0]
	_require(node.monster == null, "Expected generated route node to be unconverted before commit.")
	_require(build_state.choose_contract_route_node(node), "Expected generated route node commit to succeed.")
	return node


func _monster_field_value(monster: Monster, field: String) -> Variant:
	match field:
		"armor":
			return monster.armor
		"poison_resistance":
			return monster.poison_resistance
		"dodge_chance":
			return monster.dodge_chance
		"crit_negation":
			return monster.crit_negation
		"block":
			return monster.block
		"absorb":
			return monster.absorb
		"cleanse_threshold":
			return monster.cleanse_threshold
		"suppress":
			return monster.suppress
		"slow":
			return monster.slow
		"stun_duration_ms":
			return monster.stun_duration_ms
		"interrupt_skip_count":
			return monster.interrupt_skip_count
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
