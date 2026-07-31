class_name PlaybackControls
extends HBoxContainer
## The playback control strip: a compact "elapsed / window" time readout
## (the DPS-window pressure indicator -- on a loss the elapsed time visibly
## reaches the window cap while the HP bar still shows red) plus 1x/2x/4x
## speed buttons and a Skip-to-result button. Hidden outside playback.
## Extracted from combat_screen.gd's inline playback/VFX layer
## (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md Phase 4).
##
## This widget owns its own construction and visual state (which speed
## button reads as "active", the time label's text) but not the actual
## playback speed/skip logic -- combat_screen.gd (soon a dedicated playback
## presenter, in a later step of this same extraction) owns the
## CombatPlayback instance and decides what a speed selection or skip
## actually does, then calls back into set_active_speed()/set_time_text() to
## reflect it. `speed_selected`/`skip_pressed` are the only way in.

signal speed_selected(speed: float)
signal skip_pressed

## Selectable playback speed multipliers, in button order. First entry is
## the default every playback starts at.
const SPEED_OPTIONS: Array[float] = [1.0, 2.0, 4.0]

var _time_label: Label
var _speed_buttons: Array[Button] = []
var _skip_button: Button


func _ready() -> void:
	visible = false
	add_theme_constant_override("separation", 8)

	_time_label = Label.new()
	_time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(_time_label)

	_speed_buttons = []
	for speed in SPEED_OPTIONS:
		var speed_button := Button.new()
		speed_button.text = "%dx" % int(speed)
		speed_button.pressed.connect(func(): speed_selected.emit(speed))
		_speed_buttons.append(speed_button)
		add_child(speed_button)

	_skip_button = Button.new()
	_skip_button.text = "Skip"
	_skip_button.pressed.connect(func(): skip_pressed.emit())
	add_child(_skip_button)


## Reflects `speed` as the active selection by disabling its matching button,
## so the active speed is visible at a glance.
func set_active_speed(speed: float) -> void:
	for i in _speed_buttons.size():
		_speed_buttons[i].disabled = is_equal_approx(SPEED_OPTIONS[i], speed)


func set_time_text(text: String) -> void:
	_time_label.text = text
