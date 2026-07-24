extends Control
## Title screen: entry point of the game. Menu order: "Training Room"
## (P2:R10 freeform practice mode), "Adventure Mode" (starts the real flow),
## "Continue Adventure" (resume -- always present, disabled when no save
## exists), "Exit". No game logic here, per docs/Conventions.md's UI
## architecture principle.
##
## Layout per user direction: everything centered on the canvas, large
## title / smaller subtitle, menu set apart in a bordered card. Uses direct
## per-node overrides rather than a shared Theme resource -- a full palette/
## typography pass across all screens is still a deferred follow-up: this
## is card, no attempt to move that direction until it's decided.

signal adventure_pressed
signal continue_pressed
signal training_room_pressed

const TITLE_FONT_SIZE := 48
const SUBTITLE_FONT_SIZE := 20
const CARD_TITLE_FONT_SIZE := 22

var _new_game_confirm_dialog: ConfirmationDialog
var _seed_spin_box: SpinBox


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
	# Title/logo role -- Pirata One, not the shared MedievalSharp
	# PanelHeader variation (P2:R7:T2 font system, title screen only).
	heading.theme_type_variation = &"TitleHeading"
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
	card_label.theme_type_variation = &"PanelHeader"
	card_label.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	card_vbox.add_child(card_label)

	# Menu order per the P2:R7 second playtest-feedback pass: Training Room
	# (placeholder), Adventure Mode, Resume. All three are always present;
	# unavailable entries are disabled rather than hidden, per the same
	# disabled-state convention as class_select.gd's Mage/Crusader cards.
	var training_room_button := Button.new()
	training_room_button.text = "Training Room"
	training_room_button.tooltip_text = "Practice builds against a target dummy, freely."
	training_room_button.pressed.connect(func(): training_room_pressed.emit())
	card_vbox.add_child(training_room_button)

	var adventure_button := Button.new()
	adventure_button.text = "Adventure Mode"
	adventure_button.pressed.connect(_on_adventure_button_pressed)
	card_vbox.add_child(adventure_button)

	# Resume: always visible, grayed out (disabled) when there is no saved
	# run to resume -- previously hidden entirely, which made the menu shape
	# shift between sessions.
	var continue_button := Button.new()
	continue_button.text = "Continue Adventure"
	continue_button.disabled = not SaveSystem.has_save()
	if continue_button.disabled:
		continue_button.tooltip_text = "No saved Adventure to resume."
	continue_button.pressed.connect(func(): continue_pressed.emit())
	card_vbox.add_child(continue_button)

	var exit_button := Button.new()
	exit_button.text = "Exit"
	exit_button.pressed.connect(func(): get_tree().quit())
	card_vbox.add_child(exit_button)

	var seed_spacer := Control.new()
	seed_spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(seed_spacer)

	var seed_card := PanelContainer.new()
	seed_card.add_theme_stylebox_override("panel", CardStyle.make_stylebox(16))
	vbox.add_child(seed_card)

	var seed_row := HBoxContainer.new()
	seed_row.alignment = BoxContainer.ALIGNMENT_CENTER
	seed_row.add_theme_constant_override("separation", 8)
	seed_card.add_child(seed_row)

	var seed_label := Label.new()
	seed_label.text = "Seed"
	seed_row.add_child(seed_label)

	_seed_spin_box = SpinBox.new()
	_seed_spin_box.min_value = 0
	_seed_spin_box.max_value = 2147483647
	_seed_spin_box.step = 1
	_seed_spin_box.rounded = true
	_seed_spin_box.value = BuildState.adventure_seed
	_seed_spin_box.custom_minimum_size = Vector2(160, 0)
	_seed_spin_box.tooltip_text = "Adventure seed used for combat, rewards, and shop rolls."
	seed_row.add_child(_seed_spin_box)

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


func selected_seed() -> int:
	if _seed_spin_box == null:
		return BuildState.DEFAULT_ADVENTURE_SEED
	return int(_seed_spin_box.value)
