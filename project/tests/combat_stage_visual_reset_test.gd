extends SceneTree
## Regression check: status-only presentation state (especially poison tint)
## must not leak from one configured target sprite to the next pre-fight target.

const CombatStageScript := preload("res://scripts/ui/combat_stage.gd")


func _initialize() -> void:
	var stage = CombatStageScript.new()
	root.add_child(stage)
	await process_frame

	stage.configure("Rogue", "Mouthy Drunk")
	stage.set_poison_stacks(3, false)
	_require(stage.last_poison_stack_tint_stacks == 3, "Expected poison stacks to tint the current enemy.")
	_require(stage.enemy_actor_anchor.modulate != Color.WHITE, "Expected the poisoned enemy to be visibly tinted.")

	stage.configure("Rogue", "Tavern Bouncer")
	_require(stage.last_poison_stack_tint_stacks == 0, "Expected configuring a new target to clear poison tint state.")
	_require(stage.enemy_actor_anchor.modulate == Color.WHITE, "Expected the newly configured target to start untinted.")

	stage.queue_free()
	await process_frame
	print("Combat stage visual reset check: OK")
	quit()


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	assert(condition, message)
