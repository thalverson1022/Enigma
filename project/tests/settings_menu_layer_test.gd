extends SceneTree
## Focused regression for the shared settings chrome mounted by GameRoot.


func _initialize() -> void:
	var audio_manager = root.get_node("AudioManager")

	var game_root_scene: PackedScene = load("res://scenes/game_root.tscn")
	var game_root = game_root_scene.instantiate()
	root.add_child(game_root)
	await process_frame
	await process_frame

	var settings_layer: Control = game_root.find_child("SettingsMenuLayer", false, false)
	_require(settings_layer != null, "Expected GameRoot to mount the shared settings layer.")
	_require(settings_layer.z_index >= 1000, "Expected settings layer to render above swapped screens.")

	var settings_button := settings_layer.find_child("SettingsButton", true, false) as Button
	_require(settings_button != null, "Expected a top-right SettingsButton.")
	_require(settings_button.icon != null, "Expected SettingsButton to use the gear icon.")
	var viewport_rect := root.get_viewport().get_visible_rect()
	var button_rect := settings_button.get_global_rect()
	_require(abs(button_rect.end.x - (viewport_rect.size.x - 16.0)) <= 1.0, "Expected SettingsButton to align near the right edge.")
	_require(abs(button_rect.position.y - 16.0) <= 1.0, "Expected SettingsButton to align near the top edge.")

	var overlay := settings_layer.find_child("SettingsOverlay", true, false) as Control
	_require(overlay != null, "Expected settings overlay to exist.")
	_require(not overlay.visible, "Expected settings overlay to start hidden.")

	var button_sfx_before: int = audio_manager.button_press_sfx_play_count
	settings_button.pressed.emit()
	await process_frame
	_require(overlay.visible, "Expected pressing SettingsButton to show the overlay.")
	_require(audio_manager.button_press_sfx_play_count == button_sfx_before + 1, "Expected SettingsButton to play click SFX.")

	var blackout := overlay.find_child("SettingsBlackout", true, false) as ColorRect
	_require(blackout != null, "Expected settings blackout to exist.")
	_require(blackout.color.a >= 0.85, "Expected settings blackout to be heavy.")

	var panel := overlay.find_child("SettingsPanel", true, false) as PanelContainer
	_require(panel != null, "Expected centered settings panel.")
	var audio_panel := overlay.find_child("AudioSettingsPanel", true, false) as PanelContainer
	_require(audio_panel != null, "Expected separate audio settings panel.")
	_require(panel.visible, "Expected main Settings panel to open first.")
	_require(not audio_panel.visible, "Expected Audio panel to start hidden.")
	var viewport_center := viewport_rect.size / 2.0
	_require(panel.get_global_rect().get_center().distance_to(viewport_center) <= 1.0, "Expected settings panel to be centered.")

	for label in ["Gameplay", "Video", "Credits"]:
		var button := overlay.find_child("%sButton" % label, true, false) as Button
		_require(button != null, "Expected %s settings button." % label)
		_require(button.disabled, "Expected %s settings button to be disabled until implemented." % label)

	var audio_button := overlay.find_child("AudioButton", true, false) as Button
	_require(audio_button != null, "Expected active Audio button.")
	_require(not audio_button.disabled, "Expected Audio button to be enabled.")
	button_sfx_before = audio_manager.button_press_sfx_play_count
	audio_button.pressed.emit()
	await process_frame
	_require(not panel.visible, "Expected Settings panel to hide after pressing Audio.")
	_require(audio_panel.visible, "Expected Audio panel to show after pressing Audio.")
	_require(audio_manager.button_press_sfx_play_count == button_sfx_before + 1, "Expected Audio button to play click SFX even though it swaps panels.")
	_require(audio_panel.get_global_rect().get_center().distance_to(viewport_center) <= 1.0, "Expected audio panel to be centered.")

	for slider_name in ["MasterVolumeSlider", "MusicVolumeSlider", "EffectsVolumeSlider"]:
		var slider := overlay.find_child(slider_name, true, false) as HSlider
		_require(slider != null, "Expected %s to exist." % slider_name)
		_require(slider.min_value == 0 and slider.max_value == 100, "Expected %s to use percent values." % slider_name)

	var audio_main_menu_button := overlay.find_child("AudioMainMenuButton", true, false) as Button
	_require(audio_main_menu_button != null, "Expected Audio panel Main Menu button.")
	_require(audio_main_menu_button.text == "Main Menu", "Expected Audio panel back button text to be Main Menu.")
	button_sfx_before = audio_manager.button_press_sfx_play_count
	audio_main_menu_button.pressed.emit()
	await process_frame
	_require(panel.visible, "Expected Main Menu to return to the Settings panel.")
	_require(not audio_panel.visible, "Expected Main Menu to hide the Audio panel.")
	_require(audio_manager.button_press_sfx_play_count == button_sfx_before + 1, "Expected Audio Main Menu button to play click SFX.")

	var close_button := overlay.find_child("CloseSettingsButton", true, false) as Button
	_require(close_button != null, "Expected active Close button.")
	_require(close_button.text == "Close", "Expected settings dismiss button text to be Close.")
	_require(not close_button.disabled, "Expected Close button to be enabled.")
	button_sfx_before = audio_manager.button_press_sfx_play_count
	close_button.pressed.emit()
	await process_frame
	_require(not overlay.visible, "Expected Close to close the settings overlay.")
	_require(audio_manager.button_press_sfx_play_count == button_sfx_before + 1, "Expected Settings Close button to play click SFX even though it hides the overlay.")

	var title = game_root._current_screen
	title.adventure_pressed.emit()
	await process_frame

	var class_select = game_root._current_screen
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	class_select._on_class_selected(rogue)
	class_select.advanced.emit()
	await process_frame

	var subclass_select = game_root._current_screen
	var bladedancer: SubclassTree = rogue.trees[1]
	subclass_select._on_tree_selected(bladedancer)
	subclass_select.advanced.emit()
	await process_frame

	_require(game_root._current_screen.has_method("_on_fight_pressed"), "Expected to reach the Adventure combat screen.")
	_require(settings_layer.get_index() == game_root.get_child_count() - 1, "Expected settings layer to stay above swapped screens.")
	button_sfx_before = audio_manager.button_press_sfx_play_count
	settings_button.pressed.emit()
	await process_frame
	_require(overlay.visible, "Expected settings button to open from the Adventure combat screen.")
	_require(audio_manager.button_press_sfx_play_count == button_sfx_before + 1, "Expected SettingsButton to play click SFX from Adventure.")
	button_sfx_before = audio_manager.button_press_sfx_play_count
	close_button.pressed.emit()
	await process_frame
	_require(not overlay.visible, "Expected Close to close the settings overlay from Adventure.")
	_require(audio_manager.button_press_sfx_play_count == button_sfx_before + 1, "Expected Adventure settings Close button to play click SFX.")

	print("Settings menu layer check: OK")
	quit()


func _require(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
