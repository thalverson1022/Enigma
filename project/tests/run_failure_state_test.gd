extends SceneTree
## Focused P2:R5:T6 check for Adventure failure tracking and outcomes.


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")

	build_state.set_adventure_seed(8675309)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_set_basic_rotation(build_state)
	build_state.choose_current_tavern_encounter()

	print("first Tavern encounter (Mouthy Drunk) losses should grant unlimited retries")
	# Project Bane revision to the R5/Phase 1 baseline rule (combat-playback
	# adjustment round 2 + retry bug, 2026-07-19; corrected 2026-07-19 -- see
	# docs/Phase_2_R5_Run_Rules_And_Determinism.md's revision note): every
	# other encounter (Tavern or contract route) keeps the Phase 1 baseline,
	# but the very first Tavern encounter (encounter index 0, Mouthy Drunk)
	# is exempted from the one-do-over limit so new players get more leeway
	# right at the start of the Adventure.
	# The build must actually be locked before start_fight() -- otherwise
	# can_start_current_fight() is false, start_fight() no-ops, and
	# tavern_map_choice_made is never cleared, which would make the RETRY
	# BUG regression check below vacuously pass regardless of the fix.
	_require(build_state.current_encounter_index == 0, "Expected to start on the first Tavern encounter.")
	_require(build_state.is_unlimited_retry_encounter(), "Expected the first Tavern encounter to be the unlimited-retry encounter.")
	for attempt in range(1, 6):
		build_state.set_locked(true)
		_require(build_state.can_start_current_fight(), "Expected the first encounter to be fightable on attempt %d." % attempt)
		_require(build_state.start_fight(), "Expected first-encounter fight %d to start." % attempt)
		build_state.finish_fight(false)
		_require(build_state.failure_count_for_current_encounter() == attempt, "Expected first-encounter failure count %d." % attempt)
		_require(
			build_state.run_outcome == BuildState.RunOutcome.FIGHT_LOSS_RETRY,
			"Expected first-encounter loss #%d to stay FIGHT_LOSS_RETRY, never ADVENTURE_RESTART_REQUIRED." % attempt
		)
		_require(build_state.run_phase == BuildState.RunPhase.RESULT, "Expected first-encounter loss #%d to stay in result phase, not RUN_ENDED." % attempt)
		_require(build_state.can_retry_current_encounter(), "Expected the first encounter to still offer a retry after loss #%d." % attempt)
		_require(build_state.retry_current_encounter(), "Expected first-encounter retry #%d to succeed." % attempt)
		_require(build_state.run_phase == BuildState.RunPhase.PLANNING, "Expected first-encounter retry #%d to return to planning." % attempt)
		_require(build_state.current_encounter_index == 0, "Expected retry #%d to keep the same Tavern encounter." % attempt)
		_require(build_state.adventure_seed == 8675309, "Expected retry #%d to preserve seed." % attempt)

	print("RETRY BUG regression: retry must make the same encounter fightable again without re-choosing the map")
	# The retry bug (combat-playback adjustment round 2 + retry bug,
	# 2026-07-19): retry_current_encounter() cleared run_phase/run_outcome
	# but never restored tavern_map_choice_made, which start_fight() had
	# cleared when the original (losing) attempt began. needs_tavern_map_
	# choice() therefore stayed true after a retry, so can_start_current_
	# fight() (and the real enemy panel's FIGHT! button) stayed disabled
	# until the player rediscovered they had to reopen the Map overlay and
	# re-click the SAME already-only encounter -- exactly what "Retry
	# doesn't work, I can't try again" looks like in play, even though
	# retry_current_encounter() itself returned true. This block fails
	# against the pre-fix code (needs_tavern_map_choice() true, can_start_
	# current_fight() false even once locked) and passes once retry restores
	# the flag directly.
	_require(not build_state.needs_tavern_map_choice(), "Expected retry to make the same Tavern encounter immediately fightable again, with no map re-choice required.")
	build_state.set_locked(true)
	_require(build_state.can_start_current_fight(), "Expected the retried encounter to be startable once the build is re-locked, with no other state to fix up.")

	print("winning the first encounter should advance to the second Tavern encounter")
	build_state.finish_fight(true)
	_require(build_state.run_outcome == BuildState.RunOutcome.FIGHT_WIN, "Expected a win outcome for the first encounter.")
	_require(build_state.continue_after_win(), "Expected continue_after_win to advance past the first encounter.")
	_require(build_state.current_encounter_index == 1, "Expected to advance to the second Tavern encounter.")
	_require(not build_state.is_unlimited_retry_encounter(), "Expected the second Tavern encounter to use the standard retry rule, not the first-encounter exemption.")
	build_state.choose_current_tavern_encounter()

	print("second Tavern encounter (non-first) loss should grant exactly one do-over, then require Adventure restart")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected the second Tavern fight to start.")
	build_state.finish_fight(false)
	_require(build_state.run_phase == BuildState.RunPhase.RESULT, "Expected first loss on the second encounter to stay in result phase.")
	_require(build_state.run_outcome == BuildState.RunOutcome.FIGHT_LOSS_RETRY, "Expected retry outcome after first loss on the second encounter.")
	_require(build_state.failure_count_for_current_encounter() == 1, "Expected first failure count on the second encounter.")
	_require(build_state.can_retry_current_encounter(), "Expected retry availability after first loss on the second encounter.")
	_require(build_state.retry_current_encounter(), "Expected retry to return to planning.")
	_require(build_state.current_encounter_index == 1, "Expected retry to keep the same (second) Tavern encounter.")

	build_state.set_locked(true)
	build_state.start_fight()
	build_state.finish_fight(false)
	_require(build_state.failure_count_for_current_encounter() == 2, "Expected second failure count on the second encounter.")
	_require(not build_state.can_retry_current_encounter(), "Expected no retry after second loss on the second encounter.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected second loss on the second encounter to end the current Adventure.")
	_require(
		build_state.run_outcome == BuildState.RunOutcome.ADVENTURE_RESTART_REQUIRED,
		"Expected Adventure restart outcome after second loss on the second (non-first) Tavern encounter."
	)
	_require(not build_state.build_locked, "Expected terminal loss to clear build lock.")

	print("seed-preserving Adventure restart should clear run progress")
	build_state.reset(true)
	_require(build_state.adventure_seed == 8675309, "Expected preserved seed after restart.")
	_require(build_state.selected_class == null, "Expected class selection to reset.")
	_require(build_state.current_encounter_index == 0, "Expected encounter progress to reset.")
	_require(build_state.encounter_failure_counts.is_empty(), "Expected failure counts to reset.")
	_require(build_state.run_outcome == BuildState.RunOutcome.NONE, "Expected outcome to reset.")

	print("contract route loss should grant exactly one do-over, then mark the contract failed")
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_set_basic_rotation(build_state)
	_require(build_state.start_contract_offer(), "Expected contract offer to start.")
	_require(build_state.accept_contract_offer(), "Expected contract offer accept to work.")
	_require(build_state.choose_secondary_tree(rogue.trees[0]), "Expected secondary tree choice to work.")
	var opener: ContractRouteNode = build_state.current_route_node.next_nodes[1]
	_require(opener.id == "route.gilded_serpent.portly_cook", "Expected Portly Cook route opener.")
	_require(build_state.choose_contract_route_node(opener), "Expected route node choice to enter planning.")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected contract fight to start.")
	build_state.finish_fight(false)
	_require(build_state.failure_count_for_current_encounter() == 1, "Expected contract failure count.")
	_require(build_state.run_phase == BuildState.RunPhase.RESULT, "Expected first contract loss to stay in result phase.")
	_require(build_state.run_outcome == BuildState.RunOutcome.FIGHT_LOSS_RETRY, "Expected first contract loss to offer one retry.")
	_require(build_state.can_retry_current_encounter(), "Expected a contract do-over after the first loss.")
	_require(build_state.retry_current_encounter(), "Expected contract retry to return to planning.")
	_require(build_state.current_route_node == opener, "Expected retry to keep the same contract route node.")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected retried contract fight to start.")
	build_state.finish_fight(false)
	_require(build_state.failure_count_for_current_encounter() == 2, "Expected second contract failure count.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected second contract loss to end the run.")
	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_FAILED, "Expected contract failed outcome after second loss.")
	_require(not build_state.can_retry_current_encounter(), "Expected no third attempt for the same contract node.")
	_require(build_state.active_contract != null, "Expected failed contract context to remain visible.")
	_require(build_state.current_route_node == opener, "Expected failed route node context to remain visible.")

	print("Vyra losses should follow the standard one-do-over rule, not the first-fight unlimited retry")
	build_state.reset(true)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_set_basic_rotation(build_state)
	_require(build_state.start_contract_offer(), "Expected contract offer to start for the Vyra control check.")
	_require(build_state.accept_contract_offer(), "Expected contract offer accept for the Vyra control check.")
	build_state.current_route_node = _find_route_node(build_state.active_contract.offer_node, "route.gilded_serpent.vyra")
	_require(build_state.current_route_node != null, "Expected Vyra route node.")
	build_state.run_phase = BuildState.RunPhase.PLANNING
	_require(not build_state.is_unlimited_retry_encounter(), "Expected Vyra to not be identified as the unlimited-retry encounter.")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected the Vyra control fight to start.")
	build_state.finish_fight(false)
	_require(build_state.failure_count_for_current_encounter() == 1, "Expected Vyra failure count 1.")
	_require(build_state.run_phase == BuildState.RunPhase.RESULT, "Expected first Vyra loss to stay in result phase for the one retry.")
	_require(build_state.run_outcome == BuildState.RunOutcome.FIGHT_LOSS_RETRY, "Expected first Vyra loss to offer one retry.")
	_require(build_state.can_retry_current_encounter(), "Expected one do-over for a Vyra loss.")
	_require(build_state.retry_current_encounter(), "Expected Vyra retry to return to planning.")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected the retried Vyra fight to start.")
	build_state.finish_fight(false)
	_require(build_state.failure_count_for_current_encounter() == 2, "Expected Vyra failure count 2.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected second Vyra loss to end the run.")
	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_FAILED, "Expected second Vyra loss to resolve to CONTRACT_FAILED.")
	_require(not build_state.can_retry_current_encounter(), "Expected no third attempt for Vyra.")
	_require(build_state.active_contract != null, "Expected failed contract context to remain visible after a Vyra loss.")

	print("non-Vyra contract nodes use the same one-do-over rule")
	var portly_cook: ContractRouteNode = _find_route_node(build_state.active_contract.offer_node, "route.gilded_serpent.portly_cook")
	_require(portly_cook != null, "Expected to find Portly Cook for the non-Vyra control check.")
	build_state.current_route_node = portly_cook
	build_state.run_phase = BuildState.RunPhase.PLANNING
	_require(not build_state.is_unlimited_retry_encounter(), "Expected Portly Cook to not be identified as the unlimited-retry encounter.")
	build_state.set_locked(true)
	_require(build_state.start_fight(), "Expected the Portly Cook control fight to start.")
	build_state.finish_fight(false)
	_require(build_state.run_outcome == BuildState.RunOutcome.FIGHT_LOSS_RETRY, "Expected first non-Vyra contract loss to offer one retry.")
	_require(build_state.can_retry_current_encounter(), "Expected one do-over for a non-Vyra contract node.")

	print("contract boss win should mark contract victory")
	build_state.reset(true)
	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	_set_basic_rotation(build_state)
	_require(build_state.start_contract_offer(), "Expected contract offer to start for victory check.")
	_require(build_state.accept_contract_offer(), "Expected contract offer accept for victory check.")
	build_state.current_route_node = _find_route_node(build_state.active_contract.offer_node, "route.gilded_serpent.vyra")
	_require(build_state.current_route_node != null, "Expected Vyra route node.")
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	_require(build_state.continue_after_win() == false, "Expected final contract node to have no next route.")
	_require(build_state.run_phase == BuildState.RunPhase.RUN_ENDED, "Expected Vyra win to end the run.")
	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_VICTORY, "Expected contract victory outcome.")

	print("")
	if _failed:
		print("Run failure state check: FAILED")
		quit(1)
	else:
		print("Run failure state check: OK")
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


func _set_basic_rotation(build_state) -> void:
	var unlocked: Array[Skill] = build_state.unlocked_skills()
	_require(not unlocked.is_empty(), "Expected at least one unlocked skill for the lock-as-ready test setup.")
	var rotation: Array[Skill] = [unlocked[0]]
	build_state.set_rotation(rotation)


## Fixed to record-and-continue rather than quit(1) immediately (combat-
## playback adjustment round 2 + retry bug, 2026-07-19): quit() only
## *requests* a SceneTree exit at end-of-frame, it doesn't halt the calling
## function, so the old quit(1)-on-failure idiom let execution keep running
## after a failed check and the file's own final unconditional quit() at the
## end silently overwrote the exit code back to 0 -- the same "_require()
## exit-code-masking idiom" already fixed in combat_recap_test.gd and flagged
## as latent in every other file still using it. Single quit() at the very
## end of _initialize() now, so a failure can't be masked by an earlier one.
var _failed := false


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	_failed = true
