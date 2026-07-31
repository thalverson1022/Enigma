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
const SUBCLASS_ICON_SIZE := Vector2(36, 36)
const UI_ICON_SIZE := Vector2(22, 22)


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


## The regular tooltip lines for one gear item -- slot/name, tier, affixes,
## and any triggered-skill effects. Shared by combat_screen.gd's shop/reward
## offer tooltips and gear-compare "Equipped" box, and gear_panel.gd's
## inventory/equipped-slot tooltips, so the same item can't show different
## information in different screens.
static func gear_tooltip_lines(gear: GearItem) -> PackedStringArray:
	if gear != null and gear.tier == GearItem.Tier.LEGENDARY:
		return LegendaryCatalog.tooltip_lines(gear)
	var lines: PackedStringArray = []
	lines.append("%s - %s" % [GearGenerator.SLOT_TAGS[gear.slot], gear.display_name])
	lines.append(GearGenerator.TIER_NAMES[gear.tier])
	for affix in gear.affixes:
		lines.append(StatModifierFormatter.format(affix))
	for trigger in gear.triggered_skill_effects:
		if trigger != null and trigger.skill != null:
			lines.append("%d%% chance to trigger %s" % [roundi(trigger.chance * 100.0), trigger.skill.display_name])
	return lines


## Builds the backdrop -> CenterContainer -> bare PanelContainer inside
## `root` for a full-screen modal overlay, and returns the panel so the
## caller can style it and add its own content. The helper enforces the
## full-rect geometry on root/backdrop/center so extracted overlay scenes
## stay centered even if their serialized root anchors drift during refactors.
##
## `dismissable`: overlays that are pure informational views (Combat Log,
## Talent Trees) close on an outside click; overlays that gate a real
## decision (accept a contract, choose a reward, pick a route) with no
## defined "cancel" behavior stay locked -- see combat_screen.gd's overlay
## builders for which is which.
static func build_modal_panel(root: Control, dismissable: bool) -> PanelContainer:
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.grow_horizontal = Control.GROW_DIRECTION_BOTH
	root.grow_vertical = Control.GROW_DIRECTION_BOTH
	root.z_index = 100

	if dismissable:
		var backdrop := Button.new()
		backdrop.flat = true
		backdrop.z_index = 100
		backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var backdrop_style := StyleBoxFlat.new()
		backdrop_style.bg_color = UIColors.OVERLAY_BACKDROP
		for state in ["normal", "hover", "pressed", "focus"]:
			backdrop.add_theme_stylebox_override(state, backdrop_style)
		backdrop.pressed.connect(func(): root.visible = false)
		root.add_child(backdrop)
	else:
		var backdrop := ColorRect.new()
		backdrop.z_index = 100
		backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		backdrop.color = UIColors.OVERLAY_BACKDROP
		backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
		root.add_child(backdrop)

	var center := CenterContainer.new()
	center.z_index = 101
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(center)

	var panel := PanelContainer.new()
	panel.z_index = 102
	center.add_child(panel)
	return panel


## P2:R7 second playtest-feedback pass (replaces the first pass's rejected
## large side-by-side comparison panel): the on-hover visual for a
## shop/reward gear box is two SMALL boxes side by side, each styled
## identically to the default Godot tooltip -- the first carries the item's
## regular tooltip text unchanged, the second is headed "Equipped" and
## carries the equipped item's regular tooltip-style lines (or "Nothing
## equipped."). Returned from GearCompareButton's _make_custom_tooltip()
## override; Godot handles showing/hiding it like any other tooltip.
##
## `theme_owner` supplies the theme lookup (get_theme_stylebox/get_theme_color
## need a Control in the scene tree to resolve the active theme) -- pass the
## calling screen/overlay's own `self`. Shared by combat_screen.gd's
## reward-choice tooltip and shop_overlay.gd's shop-offer tooltip so the two
## can't drift apart.
static func build_gear_compare_tooltip(theme_owner: Control, item_text: String, equipped: GearItem) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(_make_tooltip_box(theme_owner, "", item_text))
	var equipped_text := "\n".join(gear_tooltip_lines(equipped)) if equipped != null else "Nothing equipped."
	row.add_child(_make_tooltip_box(theme_owner, "Equipped", equipped_text))
	return row


## One compact box of build_gear_compare_tooltip()'s pair, deliberately
## styled to be visually identical to a standard tooltip: the theme chain's
## own TooltipPanel stylebox and TooltipLabel font color, default font and
## size, no extra padding. `header`, when non-empty, renders as an
## accent-colored first line ("Equipped").
static func _make_tooltip_box(theme_owner: Control, header: String, body: String) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", theme_owner.get_theme_stylebox("panel", "TooltipPanel"))
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	if header != "":
		var header_label := Label.new()
		header_label.text = header
		header_label.add_theme_color_override("font_color", ACCENT_COLOR)
		vbox.add_child(header_label)

	var body_label := Label.new()
	body_label.text = body
	body_label.add_theme_color_override("font_color", theme_owner.get_theme_color("font_color", "TooltipLabel"))
	vbox.add_child(body_label)
	return panel


## Tier-colored button stylebox for a shop/reward gear box, muted when
## unaffordable/unstorable (Button.disabled == true) so "can't afford" reads
## without opening the tooltip. Shared by combat_screen.gd's reward-choice
## boxes and shop_overlay.gd's shop-offer boxes.
static func style_shop_item_box(button: Button, offer: GearItem) -> void:
	var color := UIColors.TIER_BASIC
	match offer.tier:
		GearItem.Tier.MASTER:
			color = UIColors.TIER_MASTER
		GearItem.Tier.CURSED:
			color = UIColors.TIER_CURSED
		GearItem.Tier.LEGENDARY:
			color = UIColors.TIER_LEGENDARY
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = color.darkened(0.55) if state == "disabled" else color
		style.border_color = UIColors.TEXT_DISABLED if state == "disabled" else UIColors.SLOT_BORDER
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		button.add_theme_stylebox_override(state, style)


static func make_pixel_icon(texture: Texture2D, icon_size: Vector2 = SUBCLASS_ICON_SIZE) -> TextureRect:
	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.texture = texture
	icon.custom_minimum_size = icon_size
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


static func configure_icon_button(button: Button, texture: Texture2D, separation: int = 8) -> void:
	button.icon = texture
	button.expand_icon = false
	button.add_theme_constant_override("h_separation", separation)


static func make_icon_label_row(texture: Texture2D, text: String, icon_size: Vector2 = UI_ICON_SIZE) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 6)
	row.add_child(make_pixel_icon(texture, icon_size))

	var label := Label.new()
	label.name = "Label"
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	return row


## The selection-card layout used by class/subclass select (large title,
## small descriptive text, action button below) -- shared so
## combat_screen.gd's secondary Rogue tree chooser matches the primary
## subclass select screen exactly instead of approximating it.
static func make_selection_card(title_text: String, body_text: String, action_button: Button, card_width: int = SELECTION_CARD_WIDTH, icon_texture: Texture2D = null) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(card_width, 0)
	card.add_theme_stylebox_override("panel", make_stylebox())

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 10)
	card.add_child(card_vbox)

	var title_row := HBoxContainer.new()
	title_row.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_theme_constant_override("separation", 8)
	card_vbox.add_child(title_row)

	if icon_texture != null:
		title_row.add_child(make_pixel_icon(icon_texture))

	var title_label := Label.new()
	title_label.name = "Title"
	title_label.text = title_text
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.theme_type_variation = &"PanelHeader"
	title_label.add_theme_font_size_override("font_size", SELECTION_CARD_TITLE_FONT_SIZE)
	title_row.add_child(title_label)

	var body_label := Label.new()
	body_label.text = body_text
	body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	body_label.add_theme_font_size_override("font_size", SELECTION_CARD_BODY_FONT_SIZE)
	card_vbox.add_child(body_label)

	card_vbox.add_child(action_button)
	return card
