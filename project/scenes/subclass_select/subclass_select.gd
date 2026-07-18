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

const CARD_WIDTH := 280

const INSTRUCTION_FONT_SIZE := 40
const CARD_TITLE_FONT_SIZE := 24
const FLAVOR_FONT_SIZE := 15

const FLAVOR_TEXT := {
	"Assassin": "Poison, poison, and more poison.",
	"Thief": "Render you enemies defenseless.",
	"Shadow": "Poison with more steps.",
}

var _card_box: HBoxContainer


func _ready() -> void:
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
		_card_box.add_child(_build_card(tree.display_name, select_button))


func _build_card(tree_name_text: String, select_button: Button) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(CARD_WIDTH, 0)
	card.add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 10)
	card.add_child(card_vbox)

	var title_label := Label.new()
	title_label.text = tree_name_text
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	card_vbox.add_child(title_label)

	var flavor_label := Label.new()
	flavor_label.text = FLAVOR_TEXT.get(tree_name_text, "")
	flavor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flavor_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	flavor_label.add_theme_font_size_override("font_size", FLAVOR_FONT_SIZE)
	card_vbox.add_child(flavor_label)

	card_vbox.add_child(select_button)
	return card


func _on_tree_selected(tree: SubclassTree) -> void:
	BuildState.select_tree(tree)
	advanced.emit()
