class_name TrainingRoomCombatView
extends PanelContainer
## Training Room's own animated combat area (user-requested "blank area where
## we show the combat animations, like in Adventure mode"). Built directly on
## `CombatPlayback` (project/scripts/ui/combat_playback.gd -- already
## logic-only and BuildState-free) as a fresh, self-contained rendering
## surface, rather than extracting combat_screen.gd's playback rendering
## (HP bar/popups/HUD/speed controls, ~500 lines entangled with its own
## outcome-reveal/reward-claim code across a 2685-line file). That refactor
## remains a reasonable future cleanup once both screens' playback views
## exist, but duplicating a small rendering surface here is lower-risk than
## touching Adventure's already-playtested combat screen and its 3 existing
## whole-scene tests. No BuildState reference anywhere in this file.
##
## Visual design mirrors combat_screen.gd's popup/HUD/speed-control approach,
## but this is independent code against its own `CombatPlayback` instance --
## combat still resolves synchronously and completely inside
## `CombatResolver.resolve()` before `play()` is ever called; this class only
## re-plays the recorded timeline in real time. Unlike combat_screen.gd,
## there's no HP bar here at all (post-R10 UI-feedback pass) -- Training Room
## only measures damage dealt in a fixed window, never whether the target is
## "killed", so a running Damage Dealt readout replaces it.

signal finished

## Taller than the original 220px (user-requested) -- more room for
## animations, with Available Skills/Skill Build simply pushed further down
## the center column below it.
const PANEL_MIN_HEIGHT := 420
const POPUP_LIFETIME_SEC := 0.9
const POPUP_RISE_PX := 40.0
const SPEED_OPTIONS := [1.0, 2.0, 4.0]

## User-supplied background art, replacing the earlier black placeholder.
## Same TextureRect+tint approach as combat_screen.gd's tavern background
## (EXPAND_IGNORE_SIZE/STRETCH_KEEP_ASPECT_COVERED so it fills the panel
## without distortion, plus the same 0.42-alpha black tint so HUD text stays
## readable over whatever the art looks like).
const BACKGROUND_TEXTURE := preload("res://assets/backgrounds/Training_Room_background.jpg")
const BACKGROUND_TINT := Color(0, 0, 0, 0.42)

## Same headless-detection instant-mode pattern combat_screen.gd uses so
## headless tests don't have to wait out a real-time animation.
var _instant_playback: bool = DisplayServer.get_name() == "headless"
var _playback: CombatPlayback = null
## Running damage total for the current fight (post-R10 UI-feedback pass:
## Training Room only measures damage dealt in a fixed window, it never
## tracks the target's remaining HP -- there's no "killing" it here at all).
var _damage_dealt := 0.0
## Real-time armor/poison-resist/poison-stack tracking (user-requested,
## mirrors combat_screen.gd's _playback_armor/_playback_resist/
## _playback_stacks/_playback_armor_reduced) -- _armor and _monster's base
## poison_resistance never change after being set in play(); the *_reduced/
## _resist/_stacks fields accumulate per-cast the same way
## combat_screen.gd's _on_playback_event() does, so the player can watch
## these mechanics change live instead of only seeing the final numbers.
var _monster: Monster = null
var _armor := 0
var _armor_reduced := 0
var _resist := 0.0
var _stacks := 0

var _name_label: Label
var _damage_label: Label
var _info_label: Label
var _status_row: HBoxContainer
var _popup_layer: Control
var _controls_row: HBoxContainer
var _time_label: Label
var _speed_buttons: Array[Button] = []
var _skip_button: Button
var _last_speed: float = SPEED_OPTIONS[0]


func _ready() -> void:
	# Near-black fallback fill (matches combat_screen.gd's own
	# UIColors.PANEL_DEEP under its tavern background) -- mostly hidden
	# behind the background art below, visible only at the panel's edges/
	# before the texture would show through any transparency.
	var style := CardStyle.make_stylebox()
	style.bg_color = UIColors.PANEL_DEEP
	add_theme_stylebox_override("panel", style)
	custom_minimum_size = Vector2(0, PANEL_MIN_HEIGHT)
	set_process(false)

	var background := TextureRect.new()
	background.name = "Background"
	background.texture = BACKGROUND_TEXTURE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var background_tint := ColorRect.new()
	background_tint.name = "BackgroundTint"
	background_tint.color = BACKGROUND_TINT
	background_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background_tint)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 6)
	add_child(content)

	var hud_row := HBoxContainer.new()
	content.add_child(hud_row)

	_name_label = Label.new()
	_name_label.name = "NameLabel"
	_name_label.text = "No Target"
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_row.add_child(_name_label)

	_damage_label = Label.new()
	_damage_label.name = "DamageLabel"
	hud_row.add_child(_damage_label)

	_info_label = Label.new()
	_info_label.name = "InfoLabel"
	content.add_child(_info_label)

	_status_row = HBoxContainer.new()
	_status_row.name = "StatusRow"
	_status_row.add_theme_constant_override("separation", 8)
	content.add_child(_status_row)

	# Popups spawn and animate here, over the background art -- no
	# character/monster sprites yet (no such assets exist in the project;
	# matches combat_screen.gd's own tavern-background-only approach).
	_popup_layer = Control.new()
	_popup_layer.name = "PopupLayer"
	_popup_layer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_popup_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(_popup_layer)

	_controls_row = HBoxContainer.new()
	_controls_row.name = "PlaybackControls"
	_controls_row.visible = false
	_controls_row.add_theme_constant_override("separation", 8)
	content.add_child(_controls_row)

	_time_label = Label.new()
	_time_label.name = "TimeLabel"
	_time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_controls_row.add_child(_time_label)

	_speed_buttons = []
	for speed in SPEED_OPTIONS:
		var speed_button := Button.new()
		speed_button.text = "%sx" % speed
		speed_button.pressed.connect(_set_speed.bind(speed))
		_speed_buttons.append(speed_button)
		_controls_row.add_child(speed_button)

	_skip_button = Button.new()
	_skip_button.name = "SkipButton"
	_skip_button.text = "Skip"
	_skip_button.pressed.connect(_skip)
	_controls_row.add_child(_skip_button)


## Starts animating `result` against `monster`'s Armor/Poison Resist --
## `result` is already a fully-resolved CombatResolver.CombatResult; this
## never re-resolves combat, only re-plays its recorded timeline. Emits
## `finished` when the animation (or, in headless/instant mode, the
## immediate skip) completes.
func play(result: CombatResolver.CombatResult, monster: Monster) -> void:
	_monster = monster
	_damage_dealt = 0.0
	_name_label.text = monster.display_name
	_update_damage_label()
	_armor = monster.armor
	_armor_reduced = 0
	_resist = monster.poison_resistance
	_stacks = 0
	_update_status_readout()
	for child in _popup_layer.get_children():
		child.queue_free()

	_playback = CombatPlayback.new()
	_playback.event_callback = _on_playback_event
	_playback.finished_callback = _on_playback_finished
	_playback.start(result)

	if _instant_playback:
		_controls_row.visible = false
		_playback.skip()
		return

	_set_speed(_last_speed)
	_controls_row.visible = true
	_update_time_label()
	set_process(true)


func _process(delta: float) -> void:
	if _playback == null:
		return
	_playback.advance(delta)
	if _playback != null:
		_update_time_label()


func _on_playback_event(event: CombatPlayback.PlaybackEvent) -> void:
	if event.damage > 0.0:
		_damage_dealt += event.damage
		_update_damage_label()
	if event.is_tick:
		# The tick's own stacks_remaining is authoritative (CombatResolver
		# consumes exactly one stack per tick when stacks are active) --
		# matches combat_screen.gd's _on_playback_event(), and fixes a real
		# gap here where stacks previously only ever increased from casts
		# and never reflected a tick consuming one.
		_stacks = event.tick.stacks_remaining
		_update_status_readout()
		# A cadence beat with no active stacks still fires (fixed 1000ms
		# cadence independent of stacks, per CombatResolver.resolve()) but
		# deals 0 damage -- CombatResultFormatter already treats these as
		# "noise" and skips them in the text log; the popup should too,
		# instead of showing a "Poison 0.0" popup with nothing happening.
		if event.damage > 0.0:
			_spawn_popup(event)
		return
	var cast := event.cast
	_armor_reduced += cast.armor_reduction_applied
	if cast.poison_resistance_reduction_applied > 0.0:
		_resist *= 1.0 - clampf(cast.poison_resistance_reduction_applied, 0.0, 1.0)
	_stacks = mini(_stacks + cast.poison_stacks_applied, CombatResolver.MAX_POISON_STACKS)
	_update_status_readout()
	_spawn_popup(event)


func _on_playback_finished() -> void:
	set_process(false)
	_controls_row.visible = false
	_playback = null
	finished.emit()


## Base armor (never reduced in the readout itself, matching
## combat_screen.gd's own _hud_info_label -- only the reduction is shown,
## as a separate chip) alongside the live poison-resist percentage, plus
## status chips for whichever of poison stacks/armor shred/resist reduction
## currently apply. Mirrors combat_screen.gd's
## _update_playback_hud_readout()/_add_hud_status_chip() exactly.
func _update_status_readout() -> void:
	_info_label.text = "Armor: %d | Resist: %.0f%%" % [_armor, _resist * 100.0]
	for child in _status_row.get_children():
		_status_row.remove_child(child)
		child.queue_free()
	if _stacks > 0:
		_add_status_chip("Poison x%d" % _stacks, UIColors.TEXT_POISON)
	if _armor_reduced > 0:
		_add_status_chip("Armor -%d" % _armor_reduced, UIColors.TEXT_WARNING)
	var resist_reduced: float = _monster.poison_resistance - _resist
	if resist_reduced > 0.001:
		_add_status_chip("Resist -%.0f%%" % (resist_reduced * 100.0), UIColors.TEXT_WARNING)


func _add_status_chip(text: String, color: Color) -> void:
	var chip := Label.new()
	chip.text = text
	chip.add_theme_color_override("font_color", color)
	_status_row.add_child(chip)


func _set_speed(speed: float) -> void:
	_last_speed = speed
	if _playback != null:
		_playback.speed = speed
	for i in _speed_buttons.size():
		_speed_buttons[i].disabled = is_equal_approx(SPEED_OPTIONS[i], speed)


func _skip() -> void:
	if _playback != null:
		_playback.skip()


func _update_damage_label() -> void:
	_damage_label.text = "Damage: %.1f" % _damage_dealt


func _update_time_label() -> void:
	if _playback == null:
		return
	_time_label.text = "%.1fs / %.1fs" % [_playback.elapsed_ms() / 1000.0, _playback.timeline_end_ms() / 1000.0]


## Ticks always use TEXT_POISON; casts use TEXT_MAGIC (matching
## combat_screen.gd's POPUP_PROC_COLOR) whenever a legendary effect actually
## fired on that cast (Bejeweled Push Dagger's minimum-cast-time proc), so
## it reads visually distinct from an ordinary hit -- user-requested, since
## these were otherwise impossible to notice in the moment. Any triggered
## skill (Mithril Karambit) gets its own separate magic-colored popup,
## mirroring combat_screen.gd's per-trigger popup exactly.
func _spawn_popup(event: CombatPlayback.PlaybackEvent) -> void:
	if event.is_tick:
		_spawn_text_popup(_popup_text(event), UIColors.TEXT_POISON)
		return
	var cast := event.cast
	var color := UIColors.TEXT_MAGIC if cast.min_cast_time_proc_applied else UIColors.TEXT_NORMAL
	_spawn_text_popup(_popup_text(event), color)
	for triggered_name in cast.triggered_skill_names:
		_spawn_text_popup(String(triggered_name), UIColors.TEXT_MAGIC)


func _spawn_text_popup(text: String, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	var area_size := _popup_layer.size
	var start_x: float = randf_range(area_size.x * 0.2, area_size.x * 0.8) if area_size.x > 0.0 else 0.0
	var start_y := area_size.y * 0.5
	label.position = Vector2(start_x, start_y)
	_popup_layer.add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "position:y", start_y - POPUP_RISE_PX, POPUP_LIFETIME_SEC)
	tween.parallel().tween_property(label, "modulate:a", 0.0, POPUP_LIFETIME_SEC)
	tween.tween_callback(label.queue_free)


func _popup_text(event: CombatPlayback.PlaybackEvent) -> String:
	if event.is_tick:
		return "Poison %.1f" % event.damage
	var cast := event.cast
	var crit_suffix := " CRIT" if cast.is_crit else ""
	var proc_suffix := " PROC!" if cast.min_cast_time_proc_applied else ""
	return "%s %.1f%s%s" % [cast.skill.display_name, cast.physical_damage, crit_suffix, proc_suffix]
