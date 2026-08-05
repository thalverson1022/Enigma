extends Control
## Title screen: entry point of the game. Menu order: "New Adventure"
## (starts the real flow), "Resume Adventure" (resume -- always present,
## disabled when no save exists), "Practice Room" (P2:R10 freeform practice
## mode), "Exit". No game logic here, per docs/Conventions.md's UI
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

const FLOW_TEXT := preload("res://scripts/ui/adventure_flow_text.gd")
const TITLE_FONT_SIZE := 48
const SUBTITLE_FONT_SIZE := 20
const CARD_TITLE_FONT_SIZE := 22
const RANDOM_SEED_MAX := 2147483647
const MAIN_MENU_BACKGROUND_PATH := "res://assets/backgrounds/main_menu.jpg"

var _new_game_confirm_dialog: ConfirmationDialog
var _random_seed_check_box: CheckBox
var _seed_spin_box: SpinBox


func _ready() -> void:
	var background := TextureRect.new()
	background.name = "MainMenuBackground"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background_texture: Texture2D = null
	if ResourceLoader.exists(MAIN_MENU_BACKGROUND_PATH):
		background_texture = load(MAIN_MENU_BACKGROUND_PATH)
	if background_texture == null:
		var image: Image = Image.load_from_file(ProjectSettings.globalize_path(MAIN_MENU_BACKGROUND_PATH))
		if image != null:
			background_texture = ImageTexture.create_from_image(image)
	if background_texture != null:
		background.texture = background_texture
	add_child(background)

	var scrim := ColorRect.new()
	scrim.name = "MainMenuScrim"
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.05, 0.045, 0.055, 0.42)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)

	var center := CenterContainer.new()
	center.name = "MainMenuCenter"
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

	# Menu order per the P3:M5:T3 entry cleanup: New Adventure, Resume,
	# Practice Room. All three are always present;
	# unavailable entries are disabled rather than hidden, per the same
	# disabled-state convention as class_select.gd's Mage/Crusader cards.
	var adventure_button := Button.new()
	adventure_button.text = FLOW_TEXT.ACTION_START_ADVENTURE
	adventure_button.pressed.connect(_on_adventure_button_pressed)
	card_vbox.add_child(adventure_button)

	# Resume: always visible, grayed out (disabled) when there is no saved
	# run to resume -- previously hidden entirely, which made the menu shape
	# shift between sessions.
	var continue_button := Button.new()
	continue_button.text = FLOW_TEXT.ACTION_RESUME_ADVENTURE
	continue_button.disabled = not SaveSystem.has_save()
	if continue_button.disabled:
		continue_button.tooltip_text = FLOW_TEXT.TOOLTIP_NO_SAVED_ADVENTURE
	continue_button.pressed.connect(func(): continue_pressed.emit())
	card_vbox.add_child(continue_button)

	var training_room_button := Button.new()
	training_room_button.text = "Practice Room"
	training_room_button.tooltip_text = FLOW_TEXT.TOOLTIP_PRACTICE_ROOM
	training_room_button.pressed.connect(func(): training_room_pressed.emit())
	card_vbox.add_child(training_room_button)

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
	_seed_spin_box.tooltip_text = FLOW_TEXT.TOOLTIP_ADVENTURE_SEED
	seed_row.add_child(_seed_spin_box)

	_random_seed_check_box = CheckBox.new()
	_random_seed_check_box.text = "Random"
	_random_seed_check_box.button_pressed = true
	_random_seed_check_box.tooltip_text = FLOW_TEXT.TOOLTIP_RANDOM_ADVENTURE_SEED
	_random_seed_check_box.toggled.connect(_on_random_seed_toggled)
	seed_row.add_child(_random_seed_check_box)
	_on_random_seed_toggled(_random_seed_check_box.button_pressed)

	_new_game_confirm_dialog = ConfirmationDialog.new()
	_new_game_confirm_dialog.title = "New Adventure"
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
	if is_random_seed_enabled():
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		return rng.randi_range(0, RANDOM_SEED_MAX)
	return int(_seed_spin_box.value)


func is_random_seed_enabled() -> bool:
	return _random_seed_check_box != null and _random_seed_check_box.button_pressed


func _on_random_seed_toggled(enabled: bool) -> void:
	if _seed_spin_box == null:
		return
	_seed_spin_box.editable = not enabled
	_seed_spin_box.tooltip_text = (
		FLOW_TEXT.TOOLTIP_RANDOM_ADVENTURE_SEED
		if enabled
		else FLOW_TEXT.TOOLTIP_ADVENTURE_SEED
	)
