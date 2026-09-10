extends Control
## New top-level orchestrator, replacing the retired build_planner.gd
## wizard root. Swaps between title -> class_select -> subclass_select ->
## combat_screen, listening to each screen's signals -- screens don't know
## what comes next, matching the pattern the retired build_planner.gd used.

const TITLE_SCENE := preload("res://scenes/title/title.tscn")
const CLASS_SELECT_SCENE := preload("res://scenes/class_select/class_select.tscn")
const SUBCLASS_SELECT_SCENE := preload("res://scenes/subclass_select/subclass_select.tscn")
const COMBAT_SCREEN_SCENE := preload("res://scenes/combat/combat_screen.tscn")
const TRAINING_ROOM_SCENE := preload("res://scenes/training_room/training_room.tscn")
const SETTINGS_MENU_LAYER := preload("res://scripts/ui/settings_menu_layer.gd")
const ROGUE_CLASS_PATH := "res://data/classes/rogue.tres"
const ASSASSIN_TREE_PATH := "res://data/subclass_trees/assassin.tres"
const BLADEDANCER_TREE_PATH := "res://data/subclass_trees/bladedancer.tres"
const BANDIT_BLADE_PATH := "res://data/gear/bandit_blade.tres"
const SCREEN_TRANSITION_DURATION_SEC := 0.16

var _current_screen: Node = null
var _settings_menu_layer: Control = null
var _screen_transition_generation := 0
var _transition_input_blocker: Control = null


func _ready() -> void:
	BuildState.reset()
	AudioManager.play_menu_intro_audio()
	_show_title(false)
	_add_settings_menu_layer()


func _add_settings_menu_layer() -> void:
	_settings_menu_layer = SETTINGS_MENU_LAYER.new()
	_settings_menu_layer.name = "SettingsMenuLayer"
	add_child(_settings_menu_layer)


func _raise_settings_menu_layer() -> void:
	if _settings_menu_layer != null and _settings_menu_layer.get_parent() == self:
		move_child(_settings_menu_layer, get_child_count() - 1)
	if _transition_input_blocker != null and _transition_input_blocker.get_parent() == self:
		move_child(_transition_input_blocker, get_child_count() - 1)


func _clear_current() -> void:
	if _current_screen != null:
		_current_screen.queue_free()
		_current_screen = null


func _show_title(animate: bool = true) -> void:
	AudioManager.play_menu_intro_audio()
	var screen = TITLE_SCENE.instantiate()
	screen.adventure_pressed.connect(func(): _on_new_game_pressed(screen.selected_seed()))
	screen.continue_pressed.connect(_on_continue_pressed)
	screen.training_room_pressed.connect(_show_training_room)
	screen.contract_test_pressed.connect(func(): _on_contract_test_pressed(screen.selected_seed()))
	_present_screen(screen, animate)


## Practice Room is a separate practice mode (P2:R10) -- it deliberately
## never touches BuildState/save data, unlike every other screen swap here,
## so entering or leaving it can never affect a real Adventure run.
func _show_training_room() -> void:
	AudioManager.fade_out_all_menu_audio()
	var screen = TRAINING_ROOM_SCENE.instantiate()
	screen.back_pressed.connect(_show_title)
	_present_screen(screen)


func _on_new_game_pressed(seed: int = BuildState.DEFAULT_ADVENTURE_SEED) -> void:
	SaveSystem.delete_save()
	BuildState.reset()
	BuildState.set_adventure_seed(seed)
	_show_class_select()


func _on_continue_pressed() -> void:
	if SaveSystem.load_run(BuildState):
		_show_combat_screen()
	else:
		SaveSystem.delete_save()
		_show_title()


func _on_contract_test_pressed(seed: int = BuildState.DEFAULT_ADVENTURE_SEED) -> void:
	SaveSystem.delete_save()
	BuildState.reset()
	BuildState.set_adventure_seed(seed)
	var rogue: ClassDef = load(ROGUE_CLASS_PATH)
	var assassin: SubclassTree = load(ASSASSIN_TREE_PATH)
	var bladedancer: SubclassTree = load(BLADEDANCER_TREE_PATH)
	var bandit_blade: GearItem = load(BANDIT_BLADE_PATH)
	if rogue == null or assassin == null or bladedancer == null or bandit_blade == null:
		push_error("Contract Test requires Rogue, Assassin, Bladedancer, and Bandit Blade data.")
		_show_title()
		return
	BuildState.set_class(rogue)
	BuildState.selected_trees = [assassin, bladedancer]
	BuildState.selected_talents = []
	BuildState.rotation = []
	BuildState.earned_talent_points = 7
	BuildState.gold = 100
	BuildState.grant_gear(bandit_blade, true)
	if not BuildState.start_generated_contract_loop_offer({"route_difficulty": "medium"}, 3):
		push_error("Contract Test could not start the generated contract flow.")
		_show_title()
		return
	_show_combat_screen()


func _show_class_select() -> void:
	AudioManager.play_menu_intro_audio()
	var screen = CLASS_SELECT_SCENE.instantiate()
	screen.advanced.connect(_show_subclass_select)
	screen.back_pressed.connect(_show_title)
	_present_screen(screen)


func _show_subclass_select() -> void:
	AudioManager.play_menu_intro_audio()
	var screen = SUBCLASS_SELECT_SCENE.instantiate()
	screen.advanced.connect(_on_subclass_select_advanced)
	screen.back_pressed.connect(_show_class_select)
	_present_screen(screen)


## Autosave point: class + subclass are the first meaningful build choices
## in a fresh run, so a crash right after picking them shouldn't force a
## restart from Title.
func _on_subclass_select_advanced() -> void:
	SaveSystem.save_run(BuildState)
	_show_combat_screen()


func _show_combat_screen() -> void:
	var screen = COMBAT_SCREEN_SCENE.instantiate()
	screen.main_menu_pressed.connect(_on_main_menu_pressed)
	screen.adventure_restart_pressed.connect(_on_adventure_restart_pressed)
	screen.save_and_quit_pressed.connect(_on_save_and_quit_pressed)
	if BuildState.needs_tavern_map_choice() and BuildState.current_encounter_index == 0 and BuildState.active_contract == null:
		AudioManager.play_menu_intro_audio()
	elif _should_use_contract_audio_scene():
		var biome := _current_contract_audio_biome()
		if biome != "":
			AudioManager.transition_to_contract_biome_ambience(biome)
		else:
			AudioManager.transition_to_contract_ambience()
	elif BuildState.run_phase != BuildState.RunPhase.RUN_ENDED and not BuildState.is_contract_fight_active():
		AudioManager.play_tavern_map_rain()
	else:
		AudioManager.fade_out_all_menu_audio()
	_present_screen(screen)


func _present_screen(screen: Control, animate: bool = true) -> void:
	_screen_transition_generation += 1
	var generation := _screen_transition_generation
	var previous_screen := _current_screen as Control
	_current_screen = screen
	_add_screen_below_chrome(screen)
	_raise_settings_menu_layer()
	if previous_screen == null or not animate or DisplayServer.get_name() == "headless":
		if previous_screen != null:
			previous_screen.queue_free()
		screen.modulate.a = 1.0
		screen.position = Vector2.ZERO
		_set_transition_input_blocked(false)
		return
	_set_transition_input_blocked(true)
	screen.visible = true
	screen.modulate.a = 0.0
	screen.position = Vector2.ZERO
	previous_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	screen.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(previous_screen, "modulate:a", 0.0, SCREEN_TRANSITION_DURATION_SEC)
	tween.tween_property(screen, "modulate:a", 1.0, SCREEN_TRANSITION_DURATION_SEC)
	await tween.finished
	if generation != _screen_transition_generation:
		if is_instance_valid(previous_screen):
			previous_screen.queue_free()
		return
	if is_instance_valid(previous_screen):
		previous_screen.queue_free()
	screen.modulate.a = 1.0
	screen.position = Vector2.ZERO
	_set_transition_input_blocked(false)


func _add_screen_below_chrome(screen: Control) -> void:
	add_child(screen)
	if _settings_menu_layer != null and _settings_menu_layer.get_parent() == self:
		move_child(screen, max(0, _settings_menu_layer.get_index()))


func _set_transition_input_blocked(blocked: bool) -> void:
	if blocked:
		if _transition_input_blocker == null:
			_transition_input_blocker = Control.new()
			_transition_input_blocker.name = "TransitionInputBlocker"
			_transition_input_blocker.set_anchors_preset(Control.PRESET_FULL_RECT)
			_transition_input_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
		if _transition_input_blocker.get_parent() == null:
			add_child(_transition_input_blocker)
		_transition_input_blocker.visible = true
		_raise_settings_menu_layer()
		return
	if _transition_input_blocker != null:
		_transition_input_blocker.visible = false


func _current_contract_audio_biome() -> String:
	if BuildState.current_route_node != null and _has_biome_contract_audio(BuildState.current_route_node.biome):
		return BuildState.current_route_node.biome
	if BuildState.active_contract != null:
		if _has_biome_contract_audio(BuildState.active_contract.selected_biome):
			return BuildState.active_contract.selected_biome
	return ""


func _should_use_contract_audio_scene() -> bool:
	if BuildState.is_contract_fight_active():
		return true
	return (
		BuildState.active_contract != null
		and BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE
		and BuildState.current_route_node != null
		and BuildState.current_route_node != BuildState.active_contract.offer_node
	)


func _has_biome_contract_audio(biome: String) -> bool:
	return (
		AudioManager.BIOME_MUSIC_PATHS.has(biome)
		or biome in ["Forest", "Keep", "Ancient Keep", "Ruins"]
	)


func _on_main_menu_pressed() -> void:
	BuildState.reset()
	_show_title()


## P2:R7:T8: the prior save (autosaved at the just-ended terminal RUN_ENDED
## state -- contract failed/adventure-over/contract-victory/run-complete)
## must be cleared here, the same as _on_new_game_pressed() clears it for a
## fresh start from Title. Without this, a player who restarts/starts a new
## Adventure from combat_screen's terminal-state button and then quits
## before the next autosave point (class/subclass select) would see
## "Resume Adventure" on Title offer to resume the OLD, already-ended run
## instead of the new one they just chose to start.
func _on_adventure_restart_pressed() -> void:
	SaveSystem.delete_save()
	BuildState.reset(true)
	_show_class_select()


func _on_save_and_quit_pressed() -> void:
	_show_title()
