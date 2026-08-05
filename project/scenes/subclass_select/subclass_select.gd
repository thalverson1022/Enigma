extends Control
## Subclass select: lists the chosen class's real SubclassTrees as
## single-choice cards (BuildState.select_tree(), not the multi-select
## toggle_tree()).
##
## Same treatment as class_select.gd: centered on the canvas, large
## instruction above, cards arranged horizontally with title + flavor text.
## Flavor text is UI copy, not gameplay data, kept here rather than added
## to the SubclassTree schema, same reasoning as class_select.gd's.

signal advanced
signal back_pressed

const INSTRUCTION_FONT_SIZE := 40
const MAIN_MENU_BACKGROUND_PATH := "res://assets/backgrounds/main_menu.jpg"

const FLAVOR_TEXT := {
	"Assassin": "Poison, poison, and more poison.",
	"Thief": "Render you enemies defenseless.",
	"Shadow": "Poison with more steps.",
}

var _card_box: HBoxContainer


func _ready() -> void:
	_add_entry_background()

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)
	center.add_child(vbox)

	var label := Label.new()
	label.text = "Choose Your Subclass"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.theme_type_variation = &"PanelHeader"
	label.add_theme_font_size_override("font_size", INSTRUCTION_FONT_SIZE)
	vbox.add_child(label)

	_card_box = HBoxContainer.new()
	_card_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_card_box.add_theme_constant_override("separation", 20)
	vbox.add_child(_card_box)

	var back_button := Button.new()
	back_button.text = "Go Back"
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(func(): back_pressed.emit())
	vbox.add_child(back_button)

	_populate_trees()


func _populate_trees() -> void:
	for child in _card_box.get_children():
		child.queue_free()
	for tree in BuildState.selected_class.trees:
		var select_button := Button.new()
		select_button.text = "Select"
		select_button.pressed.connect(_on_tree_selected.bind(tree))
		_card_box.add_child(_build_card(tree, select_button))


## Card layout now lives in CardStyle.make_selection_card() (shared with
## combat_screen.gd's secondary Rogue tree chooser -- P2:R7 second
## playtest-feedback pass, item 5); only the flavor-text lookup stays here.
func _build_card(tree: SubclassTree, select_button: Button) -> PanelContainer:
	return CardStyle.make_selection_card(
		tree.display_name,
		FLAVOR_TEXT.get(tree.display_name, ""),
		select_button,
		CardStyle.SELECTION_CARD_WIDTH,
		tree.icon
	)


func _on_tree_selected(tree: SubclassTree) -> void:
	BuildState.select_tree(tree)
	advanced.emit()


func _add_entry_background() -> void:
	var background := TextureRect.new()
	background.name = "SubclassSelectBackground"
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
	scrim.name = "SubclassSelectScrim"
	scrim.set_anchors_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color(0.05, 0.045, 0.055, 0.42)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(scrim)
