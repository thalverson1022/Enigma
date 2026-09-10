extends SceneTree
## Focused check for the Rogue Hold intrinsic skill: it consumes time and has
## no combat effect.

const CombatPlaybackPresenterScript := preload("res://scripts/ui/combat_playback_presenter.gd")

var _failed := false


func _initialize() -> void:
	var hold: Skill = load("res://data/skills/hold.tres")
	_require(hold != null, "Expected Hold skill resource to load.")
	_require(hold.id == "skill.hold", "Expected Hold skill ID.")
	_require(hold.display_name == "Hold", "Expected Hold display name.")
	_require(hold.icon != null, "Expected Hold to use the attached icon.")
	_require(hold.base_execution_ms == 1000, "Expected Hold base execution time to be 1.0s.")
	_require(hold.min_execution_ms == 1000, "Expected Hold minimum execution time to be 1.0s.")
	_require(hold.effects.is_empty(), "Expected Hold to have no effects.")

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	_require(rogue != null, "Expected Rogue class data.")
	_require(rogue.base_skills.any(func(skill: Skill) -> bool: return skill != null and skill.id == "skill.hold"), "Expected Rogue base skills to include Hold.")
	_require(rogue.base_skills.size() >= 3, "Expected Rogue to have at least three base skills.")
	_require(rogue.base_skills[0].id == "skill.hold", "Expected Hold to be Rogue's first base skill.")
	_require(rogue.base_skills[1].id == "skill.stab", "Expected Stab to follow Hold in Rogue's base skills.")
	_require(rogue.base_skills[2].id == "skill.heavy_slash", "Expected Heavy Slash to follow Stab in Rogue's base skills.")

	var result: CombatResolver.CombatResult = CombatResolver.resolve([hold], _player(), _monster(), 3000, 1)
	_require(result.cast_events.size() == 3, "Expected Hold to cast once per second over 3.0s.")
	_require(result.cast_events[0].time_ms == 1000, "Expected first Hold cast at 1.0s.")
	_require(result.cast_events[1].time_ms == 2000, "Expected second Hold cast at 2.0s.")
	_require(result.cast_events[2].time_ms == 3000, "Expected third Hold cast at 3.0s.")
	_require(is_equal_approx(result.total_damage, 0.0), "Expected Hold to deal no damage.")
	_require(is_equal_approx(result.dps, 0.0), "Expected Hold to produce zero DPS.")
	_require(not result.is_win, "Expected Hold alone not to defeat the target.")

	var mechanic_monster := _monster()
	mechanic_monster.cleanse_threshold = 1
	mechanic_monster.interrupt_skip_count = 1
	result = CombatResolver.resolve([hold], _player(), mechanic_monster, 3000, 1)
	for cast in result.cast_events:
		_require(cast.cleanse_counter == 0, "Expected Hold not to advance Cleanse.")
		_require(not cast.cleanse_triggered, "Expected Hold not to trigger Cleanse.")
		_require(cast.interrupt_repeat_count == 0, "Expected Hold not to advance Interrupt.")
		_require(not cast.interrupt_triggered and not cast.interrupt_skipped, "Expected Hold not to trigger or consume Interrupt.")

	var stab: Skill = load("res://data/skills/stab.tres")
	_require(stab != null, "Expected Stab skill resource to load.")
	mechanic_monster = _monster()
	mechanic_monster.hp = 9999
	mechanic_monster.cleanse_threshold = 2
	result = CombatResolver.resolve([hold, stab], _player(), mechanic_monster, 4000, 1)
	_require(result.cast_events.size() >= 2, "Expected Hold then Stab casts for mechanic-counter check.")
	_require(result.cast_events[0].skill.id == "skill.hold", "Expected the first mechanic-counter cast to be Hold.")
	_require(result.cast_events[0].cleanse_counter == 0, "Expected Hold not to count as the first Cleanse hit.")
	_require(result.cast_events[1].skill.id == "skill.stab", "Expected the second mechanic-counter cast to be Stab.")
	_require(result.cast_events[1].cleanse_counter == 1, "Expected Stab to become the first Cleanse-counting action after Hold.")
	_require(not result.cast_events[1].cleanse_triggered, "Expected Hold not to make the following Stab trigger a two-hit Cleanse.")
	_check_hold_spawns_no_adventure_popup(hold)

	print("")
	if _failed:
		print("Hold skill check: FAILED")
		quit(1)
	else:
		print("Hold skill check: OK")
		quit()


func _player() -> PlayerStats:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 0.0
	return player


func _monster() -> Monster:
	var monster := Monster.new()
	monster.id = "test.hold_dummy"
	monster.display_name = "Hold Dummy"
	monster.hp = 1
	monster.armor = 0
	monster.poison_resistance = 0.0
	return monster


func _check_hold_spawns_no_adventure_popup(hold: Skill) -> void:
	var presenter = CombatPlaybackPresenterScript.new()
	var popup_layer := CombatPopupLayer.new()
	popup_layer.size = Vector2(400, 200)
	root.add_child(popup_layer)
	presenter.set_popup_layer(popup_layer)
	var hold_cast := CombatResolver.CastEvent.new()
	hold_cast.skill = hold
	hold_cast.cast_start_ms = 0
	hold_cast.time_ms = 1000
	presenter._spawn_cast_popups(hold_cast)
	_require(popup_layer.get_child_count() == 0, "Expected Hold to spawn no Adventure floating text.")
	popup_layer.queue_free()
	presenter.queue_free()


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
