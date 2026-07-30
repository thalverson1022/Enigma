class_name CombatStatusIcons
extends RefCounted

const ICON_SIZE := Vector2(22, 22)
const VALUE_FONT_SIZE := 24
const HEALTH_ICON := preload("res://assets/combat_ui_icons/enemy_health.png")
const ARMOR_ICON := preload("res://assets/combat_ui_icons/enemy_armor.png")
const RESISTANCE_ICON := preload("res://assets/combat_ui_icons/resistance.png")
const POISON_ICON := preload("res://assets/combat_ui_icons/poison_stack.png")
const SHRED_ICON := preload("res://assets/combat_ui_icons/shred.png")
const DECAY_ICON := preload("res://assets/combat_ui_icons/decay.png")


static func add_icon_label(parent: Container, icon: Texture2D, text: String, color: Color, node_name: String = "") -> HBoxContainer:
	var row := HBoxContainer.new()
	if node_name != "":
		row.name = node_name
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)

	var icon_rect := TextureRect.new()
	icon_rect.name = "Icon"
	icon_rect.texture = icon
	icon_rect.custom_minimum_size = ICON_SIZE
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon_rect)

	var label := Label.new()
	label.name = "Text"
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", VALUE_FONT_SIZE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	return row
