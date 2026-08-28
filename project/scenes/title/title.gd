extends Control
## Title screen: entry point of the game. Menu order: "New Adventure"
## (starts the real flow), "Resume Adventure" (resume -- always present,
## disabled when no save exists), "Practice Room" (P2:R10 freeform practice
## mode), "Contract Test" (debug shortcut into the current contract flow),
## "Exit". No game logic here, per docs/Conventions.md's UI architecture
## principle.
##
## Layout per user direction: everything centered on the canvas, large
## title / smaller subtitle, menu set apart in a bordered card. Uses direct
## per-node overrides rather than a shared Theme resource -- a full palette/
## typography pass across all screens is still a deferred follow-up: this
## is card, no attempt to move that direction until it's decided.

signal adventure_pressed
signal continue_pressed
signal training_room_pressed
signal contract_test_pressed

const FLOW_TEXT := preload("res://scripts/ui/adventure_flow_text.gd")
const TITLE_FONT_SIZE := 48
const SUBTITLE_FONT_SIZE := 20
const CARD_TITLE_FONT_SIZE := 22
const SEED_CHECK_ICON_SIZE := 16
const RANDOM_SEED_MAX := 2147483647
const MAIN_MENU_BACKGROUND_PATH := "res://assets/backgrounds/main_menu.jpg"
const TITLE_LIGHTNING_FLASH_OVERLAY_SCRIPT := preload("res://scripts/ui/title_lightning_flash_overlay.gd")

var _new_game_confirm_dialog: ConfirmationDialog
var _random_seed_check_box: CheckBox
var _seed_spin_box: SpinBox
var _lightning_flash_overlay: Control

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
	scrim.color = UIColors.SCRIM_SOFT
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)

	_lightning_flash_overlay = TITLE_LIGHTNING_FLASH_OVERLAY_SCRIPT.new()
	_lightning_flash_overlay.name = "TitleLightningFlashOverlay"
	_lightning_flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_lightning_flash_overlay.bind_background(background)
	add_child(_lightning_flash_overlay)

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

	var contract_test_button := Button.new()
	contract_test_button.text = "Contract Test"
	contract_test_button.tooltip_text = "Skip setup and open the current contract test flow."
	contract_test_button.pressed.connect(func(): contract_test_pressed.emit())
	card_vbox.add_child(contract_test_button)

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
	_style_seed_spin_box(_seed_spin_box)
	seed_row.add_child(_seed_spin_box)

	_random_seed_check_box = CheckBox.new()
	_random_seed_check_box.text = "Random"
	_random_seed_check_box.button_pressed = true
	_random_seed_check_box.tooltip_text = FLOW_TEXT.TOOLTIP_RANDOM_ADVENTURE_SEED
	_style_random_seed_check_box(_random_seed_check_box)
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


func _style_seed_spin_box(spin_box: SpinBox) -> void:
	var field_style := _make_seed_field_style(false)
	var focus_style := _make_seed_field_style(true)
	for state_name in ["normal", "read_only"]:
		spin_box.add_theme_stylebox_override(state_name, field_style)
	spin_box.add_theme_stylebox_override("focus", focus_style)
	spin_box.add_theme_color_override("font_color", UIColors.TEXT_NORMAL)
	spin_box.add_theme_color_override("font_readonly_color", UIColors.TEXT_DISABLED)
	spin_box.add_theme_color_override("font_selected_color", UIColors.TEXT_NORMAL)
	spin_box.add_theme_color_override("selection_color", UIColors.BUTTON_INNER_GLOW)
	var line_edit := spin_box.get_line_edit()
	if line_edit == null:
		return
	for state_name in ["normal", "read_only"]:
		line_edit.add_theme_stylebox_override(state_name, field_style)
	line_edit.add_theme_stylebox_override("focus", focus_style)
	line_edit.add_theme_color_override("font_color", UIColors.TEXT_NORMAL)
	line_edit.add_theme_color_override("font_readonly_color", UIColors.TEXT_DISABLED)
	line_edit.add_theme_color_override("font_selected_color", UIColors.TEXT_NORMAL)
	line_edit.add_theme_color_override("selection_color", UIColors.BUTTON_INNER_GLOW)


func _make_seed_field_style(focused: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.PANEL_DEEP
	style.border_color = UIColors.PANEL_EDGE_LIGHT if focused else UIColors.PANEL_BORDER
	style.set_border_width_all(2)
	style.border_blend = true
	style.set_corner_radius_all(4)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


func _style_random_seed_check_box(check_box: CheckBox) -> void:
	# CheckBox inherits the project's Button style unless explicitly cleared.
	# The Random seed control is just a checkbox, not a raised action button.
	var empty_style := StyleBoxEmpty.new()
	for state_name in [
		"normal",
		"hover",
		"pressed",
		"disabled",
		"focus",
		"hover_pressed",
	]:
		check_box.add_theme_stylebox_override(state_name, empty_style)
	check_box.add_theme_color_override("font_color", UIColors.TEXT_NORMAL)
	check_box.add_theme_color_override("font_hover_color", UIColors.TEXT_NORMAL)
	check_box.add_theme_color_override("font_focus_color", UIColors.TEXT_NORMAL)
	check_box.add_theme_color_override("font_pressed_color", UIColors.TEXT_NORMAL)
	check_box.add_theme_color_override("font_disabled_color", UIColors.TEXT_DISABLED)
	var unchecked_icon := _make_seed_check_icon(false)
	var checked_icon := _make_seed_check_icon(true)
	for icon_name in [
		"unchecked",
		"unchecked_hover",
		"unchecked_pressed",
		"unchecked_focus",
		"unchecked_hover_pressed",
	]:
		check_box.add_theme_icon_override(icon_name, unchecked_icon)
	for icon_name in [
		"checked",
		"checked_hover",
		"checked_pressed",
		"checked_focus",
		"checked_hover_pressed",
	]:
		check_box.add_theme_icon_override(icon_name, checked_icon)


func _make_seed_check_icon(checked: bool) -> Texture2D:
	var image := Image.create_empty(SEED_CHECK_ICON_SIZE, SEED_CHECK_ICON_SIZE, false, Image.FORMAT_RGBA8)
	image.fill(UIColors.TRANSPARENT)
	for y in range(SEED_CHECK_ICON_SIZE):
		for x in range(SEED_CHECK_ICON_SIZE):
			var on_border := x == 0 or y == 0 or x == SEED_CHECK_ICON_SIZE - 1 or y == SEED_CHECK_ICON_SIZE - 1
			if on_border:
				image.set_pixel(x, y, UIColors.PANEL_BORDER)
			elif x >= 2 and y >= 2 and x < SEED_CHECK_ICON_SIZE - 2 and y < SEED_CHECK_ICON_SIZE - 2:
				image.set_pixel(x, y, UIColors.PANEL_DEEP)
	if checked:
		for offset in range(3):
			image.set_pixel(4 + offset, 8 + offset, UIColors.TEXT_NORMAL)
			image.set_pixel(7 + offset, 10 - offset, UIColors.TEXT_NORMAL)
			image.set_pixel(8 + offset, 9 - offset, UIColors.TEXT_NORMAL)
	var texture := ImageTexture.create_from_image(image)
	texture.resource_name = "SeedRandomChecked" if checked else "SeedRandomUnchecked"
	return texture


func _on_random_seed_toggled(enabled: bool) -> void:
	if _seed_spin_box == null:
		return
	_seed_spin_box.editable = not enabled
	_seed_spin_box.tooltip_text = (
		FLOW_TEXT.TOOLTIP_RANDOM_ADVENTURE_SEED
		if enabled
		else FLOW_TEXT.TOOLTIP_ADVENTURE_SEED
	)
