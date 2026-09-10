extends SceneTree
## P5M11: Overkill Gold grants a small capped bonus for winning with excess damage.


func _initialize() -> void:
	_check_resolver_records_overkill_damage()
	_check_overkill_gold_breakpoints()
	_check_reward_claim_applies_gold_multiplier_after_cap()
	print("P5M11 Overkill Gold check: OK")
	quit()


func _check_resolver_records_overkill_damage() -> void:
	var player := PlayerStats.new()
	var monster := Monster.new()
	monster.display_name = "Overkill Dummy"
	monster.hp = 50
	var result := CombatResolver.resolve([_make_physical_skill(180.0)], player, monster, 1000, 1)
	_require(result.is_win, "Expected synthetic overkill fight to win.")
	_require_approx(result.overkill_damage, 130.0, "Expected result to record damage beyond enemy HP.")


func _check_overkill_gold_breakpoints() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	_require(build_state.overkill_gold_for_result(_result_with_overkill(false, 1000.0)) == 0, "Expected losses to grant no Overkill Gold.")
	_require(build_state.overkill_gold_for_result(_result_with_overkill(true, 99.0)) == 0, "Expected under 100 overkill to grant no Overkill Gold.")
	_require(build_state.overkill_gold_for_result(_result_with_overkill(true, 100.0)) == 10, "Expected 100 overkill to grant 10g.")
	_require(build_state.overkill_gold_for_result(_result_with_overkill(true, 250.0)) == 20, "Expected partial steps to round down.")
	_require(build_state.overkill_gold_for_result(_result_with_overkill(true, 500.0)) == 50, "Expected 500 overkill to hit the 50g cap.")
	_require(build_state.overkill_gold_for_result(_result_with_overkill(true, 900.0)) == 50, "Expected Overkill Gold to stay capped at 50g.")


func _check_reward_claim_applies_gold_multiplier_after_cap() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var thief: SubclassTree = load("res://data/subclass_trees/thief.tres")
	var sticky_fingers: Talent = _find_talent(thief, "talent.sticky_fingers")
	_require(rogue != null and thief != null and sticky_fingers != null, "Expected Rogue/Thief/Sticky Fingers data.")
	build_state.set_class(rogue)
	build_state.select_tree(thief)
	build_state.add_talent_points(1)
	_require(build_state.select_talent(sticky_fingers), "Expected Sticky Fingers to be selectable.")
	build_state.choose_current_tavern_encounter()
	build_state.run_phase = BuildState.RunPhase.RESULT
	build_state.last_fight_won = true
	build_state.last_combat_result = _result_with_overkill(true, 800.0)
	_require(build_state.current_overkill_gold() == 50, "Expected current Overkill Gold to use the capped base value.")
	_require(build_state.current_base_reward_gold() == 62, "Expected base reward gold to include 12g reward plus 50g overkill.")
	_require(build_state.current_modified_reward_gold() == 80, "Expected Sticky Fingers to multiply reward plus capped overkill gold.")
	_require(build_state.claim_current_reward(), "Expected reward claim to succeed.")
	_require(build_state.gold == 80, "Expected claimed gold to include Overkill Gold multiplied by Increased Gold.")


func _make_physical_skill(amount: float) -> Skill:
	var skill := Skill.new()
	skill.id = "skill.test_overkill"
	skill.display_name = "Test Overkill"
	skill.base_execution_ms = 1000
	skill.min_execution_ms = 500
	var effect := PhysicalDamageEffect.new()
	effect.amount = amount
	skill.effects = [effect]
	return skill


func _result_with_overkill(won: bool, overkill_damage: float) -> CombatResolver.CombatResult:
	var result := CombatResolver.CombatResult.new()
	result.is_win = won
	result.overkill_damage = overkill_damage
	return result


func _find_talent(tree: SubclassTree, talent_id: String) -> Talent:
	for talent in tree.talents:
		if talent.id == talent_id:
			return talent
	return null


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	if is_equal_approx(actual, expected):
		return
	push_error("%s got %.2f expected %.2f" % [message, actual, expected])
	quit(1)
