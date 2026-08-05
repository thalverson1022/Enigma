extends SceneTree
## Focused check for the always-visible dashboard top-bar status: run phase,
## build lock state, seed, and the "next expected action" line all read
## BuildState correctly across several of the P2:R7:T1 reachable dashboard
## states (fresh Tavern planning, locked planning, fight loss/retry,
## second-loss Adventure restart, contract offer, secondary subclass choice,
## contract route choice, shop, reward choice, and contract victory). Same
## headless-only caveat as every prior UI milestone -- no rendered
## click-through available in this environment.
##
## P2:R7 playtest-feedback pass (2026-07-18, revises T3): originally also
## checked _node_label ("Target: ...") and _header_gold_label ("Gold: ...")
## as part of a separate full-width status-bar row. Both fields were dropped
## when that row was consolidated into the top bar -- Target duplicated the
## enemy panel's own "Target:" line, and Gold duplicated the gear panel's/
## shop overlay's own "Gold:" lines. combat_screen.gd no longer has
## _node_label/_header_gold_label at all, so every assertion against them
## was removed rather than updated.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")

	# -- Fresh Tavern planning: nothing chosen yet --
	print("fresh Tavern planning header")
	_require(combat_screen._phase_label.text == "Phase: Tavern - Planning", "Expected fresh Tavern planning phase text, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._lock_label.text == "Build: Unlocked", "Expected unlocked build state, got: %s" % combat_screen._lock_label.text)
	_require(combat_screen._next_action_label.text == "Next: Choose your next opponent on the map.", "Expected map-choice next action, got: %s" % combat_screen._next_action_label.text)
	_require(combat_screen._seed_label.text == "Seed: 1", "Expected default seed text, got: %s" % combat_screen._seed_label.text)

	build_state.set_adventure_seed(555)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_set_basic_rotation(build_state)
	build_state.choose_current_tavern_encounter()
	await process_frame
	print("Tavern encounter chosen, build not yet locked")
	_require(combat_screen._seed_label.text == "Seed: 555", "Expected updated seed text, got: %s" % combat_screen._seed_label.text)
	_require(combat_screen._next_action_label.text == "Next: Lock your build, then fight.", "Expected lock-build next action, got: %s" % combat_screen._next_action_label.text)

	build_state.set_locked(true)
	await process_frame
	print("build locked and ready to fight")
	_require(combat_screen._lock_label.text == "Build: Locked", "Expected locked build state, got: %s" % combat_screen._lock_label.text)
	_require(combat_screen._next_action_label.text == "Next: Fight when ready.", "Expected fight-ready next action, got: %s" % combat_screen._next_action_label.text)

	# -- First loss: do-over available --
	build_state.start_fight()
	build_state.finish_fight(false)
	await process_frame
	print("first Tavern loss shows retry next action")
	_require(combat_screen._phase_label.text == "Phase: Fight Result", "Expected fight result phase text, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._next_action_label.text == "Next: Adjust your build, then retry the fight.", "Expected retry next action, got: %s" % combat_screen._next_action_label.text)

	# The first Tavern encounter (encounter index 0) is the unlimited-retry
	# encounter per BuildState.is_unlimited_retry_encounter() (see
	# docs/Phase_2_R5_Run_Rules_And_Determinism.md's 2026-07-19 retry-exception
	# correction), so it never reaches "Run Failed" no matter how many times
	# it's lost. Win it here to advance to the second (non-first) Tavern
	# encounter, which uses the standard one-do-over-then-restart rule, so the
	# "second loss requires an Adventure restart" header state below is
	# actually reachable.
	build_state.retry_current_encounter()
	build_state.set_locked(true)
	build_state.start_fight()
	build_state.finish_fight(true)
	build_state.continue_after_win()
	build_state.choose_current_tavern_encounter()
	build_state.set_locked(true)
	await process_frame

	build_state.start_fight()
	build_state.finish_fight(false)
	await process_frame
	print("first loss on the second Tavern encounter shows retry next action")
	_require(combat_screen._next_action_label.text == "Next: Adjust your build, then retry the fight.", "Expected retry next action, got: %s" % combat_screen._next_action_label.text)

	build_state.retry_current_encounter()
	build_state.set_locked(true)
	build_state.start_fight()
	build_state.finish_fight(false)
	await process_frame
	print("second Tavern loss (on the second, non-first encounter) requires an Adventure restart")
	_require(combat_screen._phase_label.text == "Phase: Run Failed", "Expected run-failed phase text, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._next_action_label.text == "Next: Restart your Adventure.", "Expected restart next action, got: %s" % combat_screen._next_action_label.text)

	# -- Contract offer and contract route. The secondary subclass choice
	# stays available in Talent Trees, but no longer owns the dashboard
	# header during the contract-picking flow. --
	build_state.reset(true)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_set_basic_rotation(build_state)
	_require(build_state.start_contract_offer(), "Expected contract offer to start.")
	await process_frame
	print("contract offer header")
	_require(combat_screen._phase_label.text == "Phase: Contract Offer", "Expected contract offer phase text, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._next_action_label.text == "Next: Hear out the Contract Window.", "Expected accept-contract next action, got: %s" % combat_screen._next_action_label.text)

	_require(build_state.accept_contract_offer(), "Expected contract offer accept to work.")
	await process_frame
	print("contract route choice header before second tree")
	_require(combat_screen._phase_label.text == "Phase: Contract Route - Choose Path", "Expected contract route phase text before second tree, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._next_action_label.text == "Next: Choose your next route on the map.", "Expected route-choice next action before second tree, got: %s" % combat_screen._next_action_label.text)

	_require(build_state.choose_secondary_tree(rogue.trees[0]), "Expected secondary tree choice to work.")
	await process_frame
	print("contract route choice header")
	_require(combat_screen._phase_label.text == "Phase: Contract Route - Choose Path", "Expected contract route phase text, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._next_action_label.text == "Next: Choose your next route on the map.", "Expected route-choice next action, got: %s" % combat_screen._next_action_label.text)

	# -- Shop and reward choice overlays take header priority over the
	# underlying RunPhase, matching what the player actually sees on screen --
	print("shop round header")
	build_state.shop_round_pending = true
	build_state.run_state_changed.emit()
	await process_frame
	_require(combat_screen._phase_label.text == "Phase: Shop", "Expected shop phase text, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._next_action_label.text == "Next: Buy gear or leave the shop.", "Expected shop next action, got: %s" % combat_screen._next_action_label.text)
	build_state.shop_round_pending = false

	print("reward choice header")
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require(lucky_coin != null, "Expected Lucky Coin gear data.")
	var reward_choices: Array[GearItem] = [lucky_coin]
	build_state.pending_reward_choices = reward_choices
	build_state.run_state_changed.emit()
	await process_frame
	_require(combat_screen._phase_label.text == "Phase: Reward Choice", "Expected reward choice phase text, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._next_action_label.text == "Next: Choose your reward.", "Expected reward choice next action, got: %s" % combat_screen._next_action_label.text)
	var no_reward_choices: Array[GearItem] = []
	build_state.pending_reward_choices = no_reward_choices
	build_state.run_state_changed.emit()

	# -- Contract victory --
	print("contract victory header")
	var contract: ContractDef = load("res://data/contracts/the_gilded_serpent.tres")
	var vyra_node := _find_route_node(contract.offer_node, "route.gilded_serpent.vyra")
	_require(vyra_node != null, "Expected Vyra route node.")
	build_state.active_contract = contract
	build_state.current_route_node = vyra_node
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	combat_screen._on_continue_pressed()
	await process_frame
	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_VICTORY, "Expected contract victory outcome.")
	_require(combat_screen._phase_label.text == "Phase: Contract Victory", "Expected contract victory phase text, got: %s" % combat_screen._phase_label.text)
	_require(combat_screen._next_action_label.text == "Next: Start a new Adventure.", "Expected start-new-adventure next action, got: %s" % combat_screen._next_action_label.text)

	print("")
	print("Dashboard header check: OK")
	quit()


func _find_route_node(root_node: ContractRouteNode, id: String) -> ContractRouteNode:
	if root_node == null:
		return null
	if root_node.id == id:
		return root_node
	for child in root_node.next_nodes:
		var found := _find_route_node(child, id)
		if found != null:
			return found
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _set_basic_rotation(build_state) -> void:
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected at least one unlocked skill for dashboard readiness setup.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)
