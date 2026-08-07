extends SceneTree
## Focused smoke test for the first M8 audio pass: menu theme and rain layer
## during pre-fight entry, then fade at the Tavern transition boundaries.


func _initialize() -> void:
	var audio_manager = root.get_node("AudioManager")
	_require(audio_manager != null, "Expected AudioManager autoload.")
	await process_frame
	_require(AudioServer.get_bus_index("Music") >= 0, "Expected Music audio bus.")
	_require(AudioServer.get_bus_index("Effects") >= 0, "Expected Effects audio bus.")

	var game_root_scene: PackedScene = load("res://scenes/game_root.tscn")
	var game_root = game_root_scene.instantiate()
	root.add_child(game_root)
	await process_frame
	await process_frame

	_require(audio_manager._rain_player != null, "Expected menu rain player.")
	_require(audio_manager._rain_player.stream != null, "Expected menu rain stream to load.")
	_require(audio_manager._rain_player.bus == "Music", "Expected menu rain to use the Music bus.")
	_require(audio_manager._theme_player != null, "Expected menu theme player.")
	_require(audio_manager._theme_player.stream != null, "Expected menu theme stream to load.")
	_require(audio_manager._theme_player.bus == "Music", "Expected menu theme to use the Music bus.")
	_require(audio_manager._fireplace_player != null, "Expected Tavern fireplace player.")
	_require(audio_manager._fireplace_player.stream != null, "Expected Tavern fireplace stream to load.")
	_require(audio_manager._fireplace_player.bus == "Music", "Expected Tavern fireplace to use the Music bus.")
	_require(audio_manager._chatter_player != null, "Expected Tavern chatter player.")
	_require(audio_manager._chatter_player.stream != null, "Expected Tavern chatter stream to load.")
	_require(audio_manager._chatter_player.bus == "Music", "Expected Tavern chatter to use the Music bus.")
	_require(audio_manager._tavern_theme_player != null, "Expected Tavern theme player.")
	_require(audio_manager._tavern_theme_player.stream != null, "Expected Tavern theme stream to load.")
	_require(audio_manager._tavern_theme_player.bus == "Music", "Expected Tavern theme to use the Music bus.")
	_require(audio_manager._night_player != null, "Expected contract night player.")
	_require(audio_manager._night_player.stream != null, "Expected contract night stream to load.")
	_require(audio_manager._night_player.bus == "Music", "Expected contract night to use the Music bus.")
	_require(audio_manager._serpent_theme_player != null, "Expected serpent theme player.")
	_require(audio_manager._serpent_theme_player.stream != null, "Expected serpent theme stream to load.")
	_require(audio_manager._serpent_theme_player.bus == "Music", "Expected serpent theme to use the Music bus.")
	_require(audio_manager._rain_player.playing, "Expected menu rain to play on Title.")
	_require(audio_manager._theme_player.playing, "Expected menu theme to play on Title.")
	_require(not audio_manager._fireplace_player.playing, "Expected Tavern fireplace to stay silent on Title.")
	_require(not audio_manager._chatter_player.playing, "Expected Tavern chatter to stay silent on Title.")
	_require(not audio_manager._tavern_theme_player.playing, "Expected Tavern theme to stay silent on Title.")
	_require(not audio_manager._night_player.playing, "Expected contract night to stay silent on Title.")
	_require(not audio_manager._serpent_theme_player.playing, "Expected serpent theme to stay silent on Title.")
	_require(audio_manager._rain_player.volume_db < audio_manager._theme_player.volume_db, "Expected rain to be mixed under the epic theme.")

	var title = game_root._current_screen
	title.training_room_pressed.emit()
	await process_frame
	await create_timer(1.5).timeout
	_require(not audio_manager._rain_player.playing, "Expected rain to fade out when entering Practice Room.")
	_require(not audio_manager._theme_player.playing, "Expected epic theme to fade out when entering Practice Room.")
	_require(not audio_manager._fireplace_player.playing, "Expected Tavern fireplace to stay silent in Practice Room.")
	_require(not audio_manager._chatter_player.playing, "Expected Tavern chatter to stay silent in Practice Room.")
	_require(not audio_manager._tavern_theme_player.playing, "Expected Tavern theme to stay silent in Practice Room.")
	_require(not audio_manager._night_player.playing, "Expected contract night to stay silent in Practice Room.")
	_require(not audio_manager._serpent_theme_player.playing, "Expected serpent theme to stay silent in Practice Room.")

	var training_room = game_root._current_screen
	var back_button: Button = training_room.find_child("BackButton", true, false)
	back_button.pressed.emit()
	await process_frame
	await process_frame
	_require(audio_manager._rain_player.playing, "Expected rain to restart after returning to Title.")
	_require(audio_manager._theme_player.playing, "Expected epic theme to restart after returning to Title.")

	title = game_root._current_screen
	title.adventure_pressed.emit()
	await process_frame

	var class_select = game_root._current_screen
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	class_select._on_class_selected(rogue)
	class_select.advanced.emit()
	await process_frame
	_require(audio_manager._rain_player.playing, "Expected menu rain to continue through class select.")
	_require(audio_manager._theme_player.playing, "Expected menu theme to continue through class select.")

	var subclass_select = game_root._current_screen
	var thief: SubclassTree = rogue.trees[1]
	subclass_select._on_tree_selected(thief)
	subclass_select.advanced.emit()
	await process_frame
	_require(audio_manager._rain_player.playing, "Expected menu rain to continue until the Tavern choice is committed.")
	_require(audio_manager._theme_player.playing, "Expected menu theme to continue through the intro story.")

	var combat_screen = game_root._current_screen
	var story_proceed_button: Button = combat_screen._story_overlay.find_child("StoryProceedButton", true, false)
	story_proceed_button.pressed.emit()
	await process_frame
	await create_timer(1.5).timeout
	_require(not audio_manager._rain_player.playing, "Expected rain to fade out on the Tavern map.")
	_require(not audio_manager._theme_player.playing, "Expected epic theme to fade out on the Tavern map.")
	_require(audio_manager._fireplace_player.playing, "Expected Tavern fireplace to fade in on the Tavern map.")
	_require(audio_manager._chatter_player.playing, "Expected Tavern chatter to fade in on the Tavern map.")
	_require(audio_manager._tavern_theme_player.playing, "Expected Tavern theme to fade in on the Tavern map.")
	_require(not audio_manager._night_player.playing, "Expected contract night to stay silent on the Tavern map.")
	_require(not audio_manager._serpent_theme_player.playing, "Expected serpent theme to stay silent on the Tavern map.")
	_require(audio_manager._chatter_player.volume_db < audio_manager._fireplace_player.volume_db, "Expected chatter to sit under the fireplace ambience.")
	_require(audio_manager._tavern_theme_player.volume_db < audio_manager._chatter_player.volume_db, "Expected Tavern theme to sit quietly behind the nearby ambience.")
	_require(audio_manager._fireplace_player.volume_db < audio_manager._theme_player.volume_db, "Expected Tavern ambience to be subtle compared to the menu theme mix.")

	combat_screen._map_overlay._map_node_buttons[0].pressed.emit()
	await process_frame
	combat_screen._map_overlay._map_proceed_button.pressed.emit()
	await process_frame
	await create_timer(1.5).timeout

	_require(not audio_manager._rain_player.playing, "Expected menu rain to stay faded after choosing Mouthy Drunk.")
	_require(audio_manager._fireplace_player.playing, "Expected Tavern fireplace to continue after choosing Mouthy Drunk.")
	_require(audio_manager._chatter_player.playing, "Expected Tavern chatter to continue after choosing Mouthy Drunk.")
	_require(audio_manager._tavern_theme_player.playing, "Expected Tavern theme to continue after choosing Mouthy Drunk.")
	_require(not audio_manager._night_player.playing, "Expected contract night to stay silent after choosing Mouthy Drunk.")
	_require(not audio_manager._serpent_theme_player.playing, "Expected serpent theme to stay silent after choosing Mouthy Drunk.")

	print("Menu rain audio check: OK")
	quit()


func _require(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
