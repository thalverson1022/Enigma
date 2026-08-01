extends SceneTree
## Focused P2:R5:T8 check for run-outcome presentation: each RunOutcome gets
## an explicit headline, body text, and single primary action, and the
## terminal contract-victory path actually surfaces its status text (a
## regression this closes -- previously the victory banner hid the status
## label and nothing restored it before "Contract complete." was set).


func _initialize() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()

	var combat_scene: PackedScene = load("res://scenes/combat/combat_screen.tscn")
	var combat_screen = combat_scene.instantiate()
	root.add_child(combat_screen)
	await process_frame

	print("first-loss retry outcome shows DEFEATED with unlimited opener retry available")
	build_state.current_encounter_index = 0
	combat_screen._apply_outcome_presentation(BuildState.RunOutcome.FIGHT_LOSS_RETRY)
	_require(combat_screen._outcome_title_label.visible, "Expected outcome title visible for retry outcome.")
	_require(combat_screen._outcome_title_label.text == "DEFEATED", "Expected DEFEATED headline for retry outcome.")
	_require(combat_screen._status_label.visible, "Expected status label visible for retry outcome.")
	_require(combat_screen._status_label.text.contains("opener has unlimited retries"), "Expected opener retry copy to call out unlimited retries.")
	_require(combat_screen._retry_button.visible and not combat_screen._retry_button.disabled, "Expected retry enabled.")
	_require(not combat_screen._restart_adventure_button.visible, "Expected restart hidden during retry outcome.")

	print("standard retry outcome shows one do-over copy")
	build_state.current_encounter_index = 1
	build_state.encounter_failure_counts["encounter:1"] = 1
	combat_screen._apply_outcome_presentation(BuildState.RunOutcome.FIGHT_LOSS_RETRY)
	_require(combat_screen._outcome_title_label.text == "DEFEATED", "Expected DEFEATED headline for standard retry outcome.")
	_require(combat_screen._status_label.text.contains("One standard do-over is available"), "Expected standard retry copy to call out the one do-over rule.")
	_require(combat_screen._status_label.text.contains("Attempts: 1/2 remaining"), "Expected standard retry copy to include remaining-attempt context.")
	_require(combat_screen._retry_button.visible and not combat_screen._retry_button.disabled, "Expected retry enabled for standard do-over.")
	_require(not combat_screen._restart_adventure_button.visible, "Expected restart hidden during standard retry outcome.")

	print("contract-route loss outcome shows CONTRACT FAILED with restart available")
	build_state.set_adventure_seed(4242)
	combat_screen._apply_outcome_presentation(BuildState.RunOutcome.CONTRACT_FAILED)
	_require(combat_screen._outcome_title_label.text == "CONTRACT FAILED", "Expected CONTRACT FAILED headline.")
	_require(not combat_screen._retry_button.visible, "Expected retry hidden after contract failure.")
	_require(combat_screen._restart_adventure_button.visible and not combat_screen._restart_adventure_button.disabled, "Expected restart enabled after contract failure.")
	_require(combat_screen._restart_adventure_button.text == "Restart Adventure", "Expected Restart Adventure label after contract failure.")
	_require(combat_screen._status_label.text.contains("contract route has no retries remaining"), "Expected contract-failed body text to explain the route retry rule.")
	_require(combat_screen._status_label.text.contains("fresh Adventure"), "Expected contract-failed body text to explain restart consequence.")
	_require(combat_screen._status_label.text.contains("Seed 4242"), "Expected preserved seed called out in contract-failed body text.")

	print("second-loss outcome shows ADVENTURE OVER with restart available")
	combat_screen._apply_outcome_presentation(BuildState.RunOutcome.ADVENTURE_RESTART_REQUIRED)
	_require(combat_screen._outcome_title_label.text == "ADVENTURE OVER", "Expected ADVENTURE OVER headline.")
	_require(not combat_screen._retry_button.visible, "Expected retry hidden after Adventure restart requirement.")
	_require(combat_screen._restart_adventure_button.visible and not combat_screen._restart_adventure_button.disabled, "Expected restart enabled after Adventure restart requirement.")
	_require(combat_screen._restart_adventure_button.text == "Restart Adventure", "Expected Restart Adventure label after Adventure restart requirement.")
	_require(combat_screen._status_label.text.contains("Tavern encounter"), "Expected Adventure-over body text to distinguish Tavern terminal loss from contract failure.")
	_require(combat_screen._status_label.text.contains("fresh Adventure"), "Expected Adventure-over body text to explain restart consequence.")
	_require(combat_screen._status_label.text.contains("Seed 4242"), "Expected preserved seed called out in Adventure-over body text.")

	print("contract victory outcome shows CONTRACT COMPLETE, offers a new Adventure, and is actually visible")
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var contract: ContractDef = load("res://data/contracts/the_gilded_serpent.tres")
	var vyra_node := _find_route_node(contract.offer_node, "route.gilded_serpent.vyra")
	_require(rogue != null, "Expected Rogue class data.")
	_require(contract != null, "Expected Gilded Serpent contract data.")
	_require(vyra_node != null, "Expected Vyra route node.")

	build_state.set_class(rogue)
	build_state.select_tree(rogue.trees[1])
	build_state.active_contract = contract
	build_state.current_route_node = vyra_node
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	# Mirrors the real post-fight state left behind by _show_victory_banner:
	# the banner hides the status label, and prior to this fix nothing ever
	# restored it once the run ended without a further reward-choice/shop step.
	combat_screen._status_label.visible = false
	combat_screen._on_continue_pressed()
	await process_frame

	_require(build_state.run_outcome == BuildState.RunOutcome.CONTRACT_VICTORY, "Expected contract victory outcome.")
	_require(combat_screen._status_label.visible, "Expected status label visible after contract victory -- this was the T8 regression.")
	_require(combat_screen._status_label.text.contains("Vyra is defeated"), "Expected Vyra defeat called out in victory body text.")
	_require(combat_screen._status_label.text.contains("start a new Adventure"), "Expected victory body text to explain the new-Adventure action.")
	_require(combat_screen._outcome_title_label.visible, "Expected outcome title visible for contract victory.")
	_require(combat_screen._outcome_title_label.text == "CONTRACT COMPLETE", "Expected CONTRACT COMPLETE headline.")
	_require(not combat_screen._retry_button.visible, "Expected retry hidden after contract victory.")
	_require(combat_screen._restart_adventure_button.visible and not combat_screen._restart_adventure_button.disabled, "Expected a next action available after contract victory.")
	_require(combat_screen._restart_adventure_button.text == "Start New Adventure", "Expected victory framing on the restart button label.")

	print("")
	print("Run outcome presentation check: OK")
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
