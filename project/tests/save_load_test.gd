extends SceneTree
## Focused P2:R6:T3/T8 check for save/load round-trip persistence.

const SaveSystemScript = preload("res://scripts/systems/save_system.gd")


func _initialize() -> void:
	# Start clean: no stray save file from a previous run of this test.
	SaveSystemScript.save_path = "res://.test_save_load_save.json"
	SaveSystemScript.delete_save()
	assert(not SaveSystemScript.has_save())

	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")

	# Build a nontrivial in-progress run: class/tree/talents/rotation, gold,
	# an authored inventory item, a generated equipped item, adventure seed,
	# contract route progress, shop round state, and failure tracking.
	build_state.set_adventure_seed(424242)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])  # Thief
	build_state.add_talent_points(2)
	var talent: Talent = rogue.trees[1].talents[0]
	_require(build_state.select_talent(talent), "Expected talent selection to succeed.")
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(unlocked.size() > 0, "Expected at least one unlocked skill.")
	var chosen_rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(chosen_rotation)

	build_state.add_gold(77)

	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(lucky_coin != null, "Expected Lucky Coin gear data.")
	_require(build_state.add_inventory_item(lucky_coin), "Expected authored gear to enter inventory.")

	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	var generated_charm: GearItem = GearGenerator.generate(GearItem.Tier.MASTER, GearItem.SlotType.CHARM, rng, "gear.test.charm")
	build_state.equip(generated_charm)

	build_state.choose_current_tavern_encounter()
	build_state.set_locked(true)
	build_state.start_fight()
	build_state.finish_fight(false)
	_require(build_state.run_outcome == build_state.RunOutcome.FIGHT_LOSS_RETRY, "Expected a retryable loss before saving.")
	_require(build_state.failure_count_for_current_encounter() == 1, "Expected one recorded failure before saving.")

	build_state.shop_unlocked = true
	build_state.open_shop_round()
	_require(build_state.shop_round_pending, "Expected an open shop round before saving.")
	_require(build_state.shop_offers.size() == 6, "Expected generated shop offers before saving.")
	_require(build_state.reroll_shop_offers(), "Expected a paid shop reroll before saving.")
	_require(build_state.shop_reroll_cost == 10, "Expected next reroll to cost 10g before saving.")

	var pre_save_signature := _state_signature(build_state)

	_require(SaveSystemScript.save_run(build_state), "Expected save_run to succeed.")
	_require(SaveSystemScript.has_save(), "Expected a save file to exist after saving.")

	# Reset to a completely different state to prove load_run() actually
	# restores rather than coincidentally matching leftover state.
	build_state.reset()
	build_state.set_adventure_seed(1)
	_require(build_state.selected_class == null, "Expected reset to clear class selection.")

	_require(SaveSystemScript.load_run(build_state), "Expected load_run to succeed.")
	var post_load_signature := _state_signature(build_state)
	_require(pre_save_signature == post_load_signature, "Expected loaded state to match saved state.\n%s\n!=\n%s" % [pre_save_signature, post_load_signature])

	# Restored state must actually be usable, not just structurally present:
	# retry the recorded loss and resolve a fresh fight against it.
	_require(build_state.can_retry_current_encounter(), "Expected restored state to allow retry.")
	_require(build_state.retry_current_encounter(), "Expected retry to succeed after load.")
	build_state.choose_current_tavern_encounter()
	build_state.set_locked(true)
	_require(build_state.can_start_current_fight(), "Expected restored build to be fightable.")
	build_state.start_fight()
	var result := CombatResolver.resolve(
		BuildResolver.resolve_rotation(build_state.rotation, build_state.unlocked_skills()),
		BuildResolver.resolve_stats(build_state.selected_class, build_state.selected_trees, build_state.selected_talents, build_state.equipped_gear()),
		build_state.current_target_monster(),
		build_state.current_target_duration_ms(),
		build_state.current_combat_rng_seed()
	)
	_require(result != null, "Expected combat to resolve after loading a save.")

	print("Missing save round trip")
	SaveSystemScript.delete_save()
	_require(not SaveSystemScript.has_save(), "Expected delete_save to remove the save file.")
	build_state.reset()
	_require(not SaveSystemScript.load_run(build_state), "Expected load_run to fail with no save file present.")

	print("Corrupt save round trip")
	var file := FileAccess.open(SaveSystemScript.save_path, FileAccess.WRITE)
	file.store_string("{ not valid json")
	file.close()
	_require(not SaveSystemScript.load_run(build_state), "Expected load_run to fail on corrupt JSON.")

	print("Incompatible save version round trip")
	file = FileAccess.open(SaveSystemScript.save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"save_version": SaveSystemScript.SAVE_VERSION + 1}))
	file.close()
	_require(not SaveSystemScript.load_run(build_state), "Expected load_run to fail on a future save_version.")

	SaveSystemScript.delete_save()

	print("")
	print("Save/load round trip check: OK")
	SaveSystemScript.delete_save()
	SaveSystemScript.save_path = SaveSystemScript.SAVE_PATH
	quit()


func _state_signature(state) -> String:
	var parts: PackedStringArray = []
	parts.append("class:%s" % (state.selected_class.id if state.selected_class != null else "none"))
	for tree in state.selected_trees:
		parts.append("tree:%s" % tree.id)
	for talent in state.selected_talents:
		parts.append("talent:%s" % talent.id)
	for skill in state.rotation:
		parts.append("rotation:%s" % skill.id)
	parts.append("seed:%d" % state.adventure_seed)
	parts.append("gold:%d" % state.gold)
	parts.append("talent_points:%d" % state.earned_talent_points)
	for item in state.inventory:
		parts.append("inventory:%s" % _gear_signature(item))
	parts.append("weapon:%s" % _gear_signature(state.equipped_weapon))
	parts.append("trinket:%s" % _gear_signature(state.equipped_trinket))
	parts.append("charm:%s" % _gear_signature(state.equipped_charm))
	parts.append("shop_unlocked:%s" % state.shop_unlocked)
	parts.append("shop_round_pending:%s" % state.shop_round_pending)
	parts.append("shop_reroll_used:%s" % state.shop_reroll_used)
	parts.append("shop_reroll_count:%d" % state.shop_reroll_count)
	parts.append("shop_reroll_cost:%d" % state.shop_reroll_cost)
	parts.append("shop_round_index:%d" % state.shop_round_index)
	for offer in state.shop_offers:
		parts.append("shop_offer:%s" % _gear_signature(offer))
	parts.append("encounter_index:%d" % state.current_encounter_index)
	parts.append("failure_counts:%s" % JSON.stringify(state.encounter_failure_counts))
	parts.append("run_phase:%d" % state.run_phase)
	parts.append("run_outcome:%d" % state.run_outcome)
	parts.append("last_fight_won:%s" % state.last_fight_won)
	return "\n".join(parts)


func _gear_signature(item: GearItem) -> String:
	if item == null:
		return "none"
	var affix_parts: PackedStringArray = []
	for affix in item.affixes:
		affix_parts.append("%d:%d:%.4f" % [affix.stat, affix.operation, affix.value])
	return "%s|%d|%d|%s|%s" % [item.id, item.tier, item.slot, item.display_name, ",".join(affix_parts)]


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)
