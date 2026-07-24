class_name CardStyle
extends RefCounted
## Shared "card" look used across the title/class_select/subclass_select/
## combat screens -- a bordered, dark panel. Centralized so the eventual
## full theming pass has one place to change, rather than each screen
## re-implementing a slightly different StyleBoxFlat. As of P2:R7:T2, both
## the color values below and the project-wide Theme
## (project/assets/ui_theme.tres) read from UIColors, so this file and the
## Theme resource can never drift out of sync with the adopted palette.

## Highlight color tying the macro slot letters to the matching first
## letter in Available Skills, so the connection between the two reads at
## a glance. Also used throughout as the general header/highlight accent.
const ACCENT_COLOR := UIColors.ACCENT

## Body/data font for small fixed-size boxes carrying multi-line data text
## (map nodes) -- the theme's default Press Start 2P button font would
## overflow them. Mirrors combat_screen.gd's DATA_BUTTON_FONT rationale
## (P2:R7:T2 legibility pass).
const DATA_FONT := preload("res://assets/fonts/VT323-Regular.ttf")

## Shared selection-card sizing/typography, extracted from
## subclass_select.gd so the primary subclass select screen and
## combat_screen.gd's secondary Rogue tree chooser render identical cards
## (P2:R7 second playtest-feedback pass, item 5).
const SELECTION_CARD_WIDTH := 280
const SELECTION_CARD_TITLE_FONT_SIZE := 24
const SELECTION_CARD_BODY_FONT_SIZE := 15


static func make_stylebox(content_margin: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UIColors.PANEL
	style.border_color = UIColors.PANEL_BORDER
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(content_margin)
	return style


## Adds the standard gear-box icon (GearIcons.icon_for()'s art over the
## button's existing tier-colored background) as a child of `button` --
## shared by gear_panel.gd's inventory slots and combat_screen.gd's
## shop/reward-choice boxes (P2:R7 gear-art pass) so this layout only exists
## once. The icon alone now carries slot/tier at a glance (art distinguishes
## slot type, background color distinguishes tier), so the caption text this
## helper used to add alongside it was dropped as redundant.
static func build_gear_box_content(button: Button, gear: GearItem) -> void:
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Nearest-neighbor keeps the 32x32 pixel art crisp when scaled up to fit
	# an 88-112px box, instead of blurring like the project's photographic
	# backgrounds (which use the default linear filter).
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.texture = GearIcons.icon_for(gear)
	button.add_child(icon)


## The selection-card layout used by class/subclass select (large title,
## small descriptive text, action button below) -- shared so
## combat_screen.gd's secondary Rogue tree chooser matches the primary
## subclass select screen exactly instead of approximating it.
static func make_selection_card(title_text: String, body_text: String, action_button: Button, card_width: int = SELECTION_CARD_WIDTH) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(card_width, 0)
	card.add_theme_stylebox_override("panel", make_stylebox())

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 10)
	card.add_child(card_vbox)

	var title_label := Label.new()
	title_label.text = title_text
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.theme_type_variation = &"PanelHeader"
	title_label.add_theme_font_size_override("font_size", SELECTION_CARD_TITLE_FONT_SIZE)
	card_vbox.add_child(title_label)

	var body_label := Label.new()
	body_label.text = body_text
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	body_label.add_theme_font_size_override("font_size", SELECTION_CARD_BODY_FONT_SIZE)
	card_vbox.add_child(body_label)

	card_vbox.add_child(action_button)
	return card
