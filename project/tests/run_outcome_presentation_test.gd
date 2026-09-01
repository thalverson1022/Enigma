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

	_require(build_state.shop_round_pending, "Expected Vyra completion to open the between-contract shop.")
	_require(combat_screen._shop_overlay.visible, "Expected shop overlay visible after Vyra completion.")
	_require(not combat_screen._status_label.visible, "Expected shop overlay to own the combat window after Vyra completion.")
	_require(not combat_screen._outcome_title_label.visible, "Expected terminal outcome title hidden for repeatable loop.")
	_require(not combat_screen._retry_button.visible, "Expected retry hidden after contract victory.")
	_require(not combat_screen._restart_adventure_button.visible, "Expected new-adventure action hidden while repeatable loop continues.")

	print("all-bosses victory outcome shows a final victory screen with new Adventure available")
	build_state.set_adventure_seed(5150)
	combat_screen._apply_outcome_presentation(BuildState.RunOutcome.ALL_BOSSES_DEFEATED)
	_require(combat_screen._outcome_title_label.visible, "Expected all-bosses victory title visible.")
	_require(combat_screen._outcome_title_label.text == "YOU KILLED ALL BOSSES", "Expected all-bosses victory headline.")
	_require(combat_screen._status_label.visible, "Expected all-bosses victory body visible.")
	_require(combat_screen._status_label.text.contains("Every boss in the Monster Manual is defeated"), "Expected all-bosses victory body to celebrate the full checklist.")
	_require(combat_screen._status_label.text.contains("Seed 5150"), "Expected preserved seed called out in all-bosses victory body.")
	_require(not combat_screen._retry_button.visible, "Expected retry hidden after all-bosses victory.")
	_require(combat_screen._restart_adventure_button.visible and not combat_screen._restart_adventure_button.disabled, "Expected Start New Adventure enabled after all-bosses victory.")
	_require(combat_screen._restart_adventure_button.text == "Start New Adventure", "Expected Start New Adventure label after all-bosses victory.")

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
