extends Control
## Title screen: entry point of the game. "Training Room" is a stubbed,
## disabled button (feature comes later); "Adventure Mode" starts the real
## flow; "Exit" quits. No game logic here, per docs/Conventions.md's UI
## architecture principle.
##
## Layout per user direction: everything centered on the canvas, large
## title / smaller subtitle, menu set apart in a bordered card. Uses direct
## per-node overrides rather than a shared Theme resource -- a full palette/
## typography pass across all screens is still a deferred follow-up: this
## is card, no attempt to move that direction until it's decided.

signal adventure_pressed
signal continue_pressed

const TITLE_FONT_SIZE := 48
const SUBTITLE_FONT_SIZE := 20
const CARD_TITLE_FONT_SIZE := 22

var _new_game_confirm_dialog: ConfirmationDialog


func _ready() -> void:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 12)
	center.add_child(vbox)

	var heading := Label.new()
	heading.text = "The Road to Peak Deeps"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	vbox.add_child(heading)

	var subtitle := Label.new()
	subtitle.text = "Do you have what it takes?"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", SUBTITLE_FONT_SIZE)
	vbox.add_child(subtitle)

	var card_spacer := Control.new()
	card_spacer.custom_minimum_size = Vector2(0, 24)
	vbox.add_child(card_spacer)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", CardStyle.make_stylebox(24))
	vbox.add_child(card)

	var card_vbox := VBoxContainer.new()
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_vbox.add_theme_constant_override("separation", 10)
	card.add_child(card_vbox)

	var card_label := Label.new()
	card_label.text = "Pick Your Poison"
	card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_label.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	card_vbox.add_child(card_label)

	var continue_button := Button.new()
	continue_button.text = "Continue Adventure"
	continue_button.visible = SaveSystem.has_save()
	continue_button.pressed.connect(func(): continue_pressed.emit())
	card_vbox.add_child(continue_button)

	var training_room_button := Button.new()
	training_room_button.text = "Training Room"
	training_room_button.disabled = true
	card_vbox.add_child(training_room_button)

	var adventure_button := Button.new()
	adventure_button.text = "Adventure Mode"
	adventure_button.pressed.connect(_on_adventure_button_pressed)
	card_vbox.add_child(adventure_button)

	var exit_button := Button.new()
	exit_button.text = "Exit"
	exit_button.pressed.connect(func(): get_tree().quit())
	card_vbox.add_child(exit_button)

	_new_game_confirm_dialog = ConfirmationDialog.new()
	_new_game_confirm_dialog.title = "Start New Adventure"
	_new_game_confirm_dialog.dialog_text = "Starting a new Adventure will discard your saved run. Continue?"
	_new_game_confirm_dialog.confirmed.connect(func(): adventure_pressed.emit())
	add_child(_new_game_confirm_dialog)


func _on_adventure_button_pressed() -> void:
	if SaveSystem.has_save():
		_new_game_confirm_dialog.popup_centered()
	else:
		adventure_pressed.emit()
