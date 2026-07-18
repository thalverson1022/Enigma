extends Control
## New top-level orchestrator, replacing the retired build_planner.gd
## wizard root. Swaps between title -> class_select -> subclass_select ->
## combat_screen, listening to each screen's signals -- screens don't know
## what comes next, matching the pattern the retired build_planner.gd used.

const TITLE_SCENE := preload("res://scenes/title/title.tscn")
const CLASS_SELECT_SCENE := preload("res://scenes/class_select/class_select.tscn")
const SUBCLASS_SELECT_SCENE := preload("res://scenes/subclass_select/subclass_select.tscn")
const COMBAT_SCREEN_SCENE := preload("res://scenes/combat/combat_screen.tscn")

var _current_screen: Node = null


func _ready() -> void:
	BuildState.reset()
	_show_title()


func _clear_current() -> void:
	if _current_screen != null:
		_current_screen.queue_free()
		_current_screen = null


func _show_title() -> void:
	_clear_current()
	var screen = TITLE_SCENE.instantiate()
	screen.adventure_pressed.connect(_on_new_game_pressed)
	screen.continue_pressed.connect(_on_continue_pressed)
	add_child(screen)
	_current_screen = screen


func _on_new_game_pressed() -> void:
	SaveSystem.delete_save()
	BuildState.reset()
	_show_class_select()


func _on_continue_pressed() -> void:
	if SaveSystem.load_run(BuildState):
		_show_combat_screen()
	else:
		SaveSystem.delete_save()
		_show_title()


func _show_class_select() -> void:
	_clear_current()
	var screen = CLASS_SELECT_SCENE.instantiate()
	screen.advanced.connect(_show_subclass_select)
	screen.back_pressed.connect(_show_title)
	add_child(screen)
	_current_screen = screen


func _show_subclass_select() -> void:
	_clear_current()
	var screen = SUBCLASS_SELECT_SCENE.instantiate()
	screen.advanced.connect(_on_subclass_select_advanced)
	screen.back_pressed.connect(_show_class_select)
	add_child(screen)
	_current_screen = screen


## Autosave point: class + subclass are the first meaningful build choices
## in a fresh run, so a crash right after picking them shouldn't force a
## restart from Title.
func _on_subclass_select_advanced() -> void:
	SaveSystem.save_run(BuildState)
	_show_combat_screen()


func _show_combat_screen() -> void:
	_clear_current()
	var screen = COMBAT_SCREEN_SCENE.instantiate()
	screen.main_menu_pressed.connect(_on_main_menu_pressed)
	screen.adventure_restart_pressed.connect(_on_adventure_restart_pressed)
	screen.save_and_quit_pressed.connect(_on_save_and_quit_pressed)
	add_child(screen)
	_current_screen = screen


func _on_main_menu_pressed() -> void:
	BuildState.reset()
	_show_title()


func _on_adventure_restart_pressed() -> void:
	BuildState.reset(true)
	_show_class_select()


func _on_save_and_quit_pressed() -> void:
	_show_title()
