extends SceneTree
## Focused smoke test for generated-contract biome music transitions.


func _initialize() -> void:
	var audio_manager = root.get_node("AudioManager")
	_require(audio_manager != null, "Expected AudioManager autoload.")
	await process_frame

	_require(audio_manager._biome_mood_player != null, "Expected contract biome mood player.")
	_require(audio_manager._biome_music_player != null, "Expected contract biome music player.")
	_require(audio_manager._biome_mood_player.bus == "Music", "Expected biome mood to use the Music bus.")
	_require(audio_manager._biome_music_player.bus == "Music", "Expected biome music to use the Music bus.")
	for biome in audio_manager.BIOME_MUSIC_PATHS.keys():
		_require(_audio_file_exists(String(audio_manager.BIOME_MUSIC_PATHS[biome])), "Expected biome music file for %s." % biome)
	for biome in audio_manager.BIOME_MOOD_PATHS.keys():
		_require(_audio_file_exists(String(audio_manager.BIOME_MOOD_PATHS[biome])), "Expected biome mood file for %s." % biome)
	_require(not audio_manager.BIOME_MOOD_PATHS.has("Ruined Keep"), "Expected Ruined Keep to avoid using rain as a fallback mood layer.")
	_require(audio_manager.CONTRACT_ENTRY_FADE_SECONDS > audio_manager.DEFAULT_FADE_SECONDS, "Expected contract entry fades to be slower than general UI fades.")

	audio_manager.transition_to_tavern_ambience(0.05)
	await create_timer(0.12).timeout
	_require(audio_manager._tavern_theme_player.playing, "Expected Tavern music to be active before contract transition.")

	audio_manager.transition_to_contract_biome_ambience("Cave", 0.05)
	await create_timer(0.12).timeout
	_require(audio_manager._current_contract_biome == "Cave", "Expected Cave to become the active contract audio biome.")
	_require(audio_manager._biome_mood_player.playing, "Expected Cave mood to begin before Cave music.")
	_require(not audio_manager._biome_music_player.playing, "Expected biome music to wait for the mood lead-in.")
	_require(not audio_manager._night_player.playing, "Expected generic contract night layer to stay silent for biome contracts.")
	_require(not audio_manager._serpent_theme_player.playing, "Expected old serpent theme to stay silent for biome contracts.")

	await create_timer(audio_manager.BIOME_MUSIC_LEAD_SECONDS + 0.15).timeout
	_require(audio_manager._biome_music_player.playing, "Expected Cave music to fade in after the mood lead-in.")
	var cave_transition_id: int = audio_manager._contract_transition_id
	var cave_mood_stream: AudioStream = audio_manager._biome_mood_player.stream
	var cave_music_stream: AudioStream = audio_manager._biome_music_player.stream
	audio_manager.transition_to_contract_biome_ambience("Cave", 0.05)
	await process_frame
	_require(audio_manager._contract_transition_id == cave_transition_id, "Expected repeat Cave transition request not to restart contract audio.")
	_require(audio_manager._biome_mood_player.stream == cave_mood_stream, "Expected repeat Cave request to preserve the mood stream.")
	_require(audio_manager._biome_music_player.stream == cave_music_stream, "Expected repeat Cave request to preserve the music stream.")
	_require(audio_manager._biome_mood_player.playing, "Expected repeat Cave request to leave mood playing.")
	_require(audio_manager._biome_music_player.playing, "Expected repeat Cave request to leave music playing.")

	audio_manager.transition_to_contract_biome_ambience("Ancient Keep", 0.05)
	await create_timer(0.12).timeout
	_require(audio_manager._current_contract_biome == "Ruined Keep", "Expected Ancient Keep alias to resolve to Ruined Keep audio.")
	_require(audio_manager._biome_mood_player.stream == null, "Expected Ruined Keep to skip the mood layer instead of using rain.")
	_require(not audio_manager._biome_mood_player.playing, "Expected Ruined Keep mood player to stay silent without a dedicated mood file.")
	_require(audio_manager._biome_music_player.stream != null, "Expected Ruined Keep music stream.")

	audio_manager.transition_to_contract_biome_ambience("Graveyard", 0.05)
	await create_timer(0.02).timeout
	audio_manager.transition_to_tavern_ambience(0.05)
	await create_timer(audio_manager.BIOME_MUSIC_LEAD_SECONDS + 0.25).timeout
	_require(audio_manager._current_contract_biome == "", "Expected Tavern transition to clear active contract biome.")
	_require(not audio_manager._biome_mood_player.playing, "Expected Tavern transition to cancel pending biome mood.")
	_require(not audio_manager._biome_music_player.playing, "Expected Tavern transition to cancel pending biome music.")
	_require(audio_manager._tavern_theme_player.playing, "Expected Tavern music to return after contract completion.")

	print("Biome contract audio check: OK")
	quit()


func _audio_file_exists(resource_path: String) -> bool:
	return FileAccess.file_exists(ProjectSettings.globalize_path(resource_path))


func _require(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
