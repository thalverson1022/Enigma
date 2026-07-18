class_name CardStyle
extends RefCounted
## Shared "card" look used across the title/class_select/subclass_select/
## combat screens -- a bordered, dark panel. Centralized so the eventual
## full theming pass has one place to change, rather than each screen
## re-implementing a slightly different StyleBoxFlat.

## Highlight color tying the macro slot letters to the matching first
## letter in Available Skills, so the connection between the two reads at
## a glance.
const ACCENT_COLOR := Color(0.95, 0.75, 0.25)


static func make_stylebox(content_margin: int = 16) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.16, 0.18)
	style.border_color = Color(0.4, 0.4, 0.45)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(content_margin)
	return style
