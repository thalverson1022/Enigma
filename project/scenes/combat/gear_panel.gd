extends PanelContainer
## Combat dashboard panel: gear, split into an Equipment paper doll and an
## earned inventory grid per the user's mockup.
##
## Equipment doll layout: hood (top), doublet (center, largest), dagger
## (left), ring + necklace (stacked right). Dagger/ring/necklace are the
## three real slots, filled only by rewards/shop inventory decisions;
## hood/doublet are dummy UI slots for future content and always read Empty.
## Slots render as gray boxes when empty and tier-colored when filled --
## Basic=green, Master=blue, Cursed=purple, Legendary=orange. Hovering a slot
## shows its name, or the item's name and stats.
##
## Inventory contains up to three items bought from the shop or earned from
## rewards. Clicking an item equips it during planning, or sells it while a
## shop round is open.

const CARD_TITLE_FONT_SIZE := 20
const SECTION_LABEL_FONT_SIZE := 15

const HELM_SLOT_SIZE := Vector2(76, 76)
const ARMOR_SLOT_SIZE := Vector2(112, 112)
const WEAPON_SLOT_SIZE := Vector2(88, 88)
const SMALL_SLOT_SIZE := Vector2(60, 60)
const INVENTORY_SLOT_SIZE := Vector2(88, 88)

const EMPTY_SLOT_COLOR := UIColors.SLOT_EMPTY
const SLOT_BORDER_COLOR := UIColors.SLOT_BORDER
const TIER_COLORS := {
	GearItem.Tier.BASIC: UIColors.TIER_BASIC,
	GearItem.Tier.MASTER: UIColors.TIER_MASTER,
	GearItem.Tier.CURSED: UIColors.TIER_CURSED,
	GearItem.Tier.LEGENDARY: UIColors.TIER_LEGENDARY,
}

var _helm_slot: Panel
var _armor_slot: Panel
var _weapon_slot: Panel
var _trinket_slot: Panel
var _charm_slot: Panel
var _inventory_grid: GridContainer
var _gold_label: Label
var _sell_dialog: ConfirmationDialog
var _pending_sell_inventory_item: GearItem = null
var _pending_sell_equipped_slot: int = -1


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(content)

	var title := Label.new()
	title.text = "Gear"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	_gold_label = Label.new()
	_gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_gold_label.add_theme_color_override("font_color", UIColors.TEXT_GOLD)
	content.add_child(_gold_label)

	var equipment_label := Label.new()
	equipment_label.text = "Equipment"
	equipment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipment_label.add_theme_font_size_override("font_size", SECTION_LABEL_FONT_SIZE)
	content.add_child(equipment_label)

	var doll := _build_doll()
	doll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(doll)

	var inventory_label := Label.new()
	inventory_label.text = "Inventory"
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	inventory_label.add_theme_font_size_override("font_size", SECTION_LABEL_FONT_SIZE)
	content.add_child(inventory_label)

	var inventory := PanelContainer.new()
	inventory.custom_minimum_size = Vector2(0, 120)
	inventory.tooltip_text = "Inventory -- three slots for unequipped gear"
	var inventory_style := CardStyle.make_stylebox(8)
	inventory_style.bg_color = UIColors.PANEL_DEEP
	inventory.add_theme_stylebox_override("panel", inventory_style)
	content.add_child(inventory)

	var inventory_margin := MarginContainer.new()
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		inventory_margin.add_theme_constant_override(side, 8)
	inventory.add_child(inventory_margin)

	_inventory_grid = GridContainer.new()
	_inventory_grid.columns = 3
	_inventory_grid.add_theme_constant_override("h_separation", 8)
	_inventory_grid.add_theme_constant_override("v_separation", 8)
	_inventory_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_margin.add_child(_inventory_grid)

	BuildState.build_changed.connect(_refresh)
	_build_sell_dialog()
	_refresh()


## Paper doll arrangement: helm centered on top, then weapon | armor |
## (trinket over charm), matching the mockup's positions.
func _build_doll() -> VBoxContainer:
	var doll := VBoxContainer.new()
	doll.add_theme_constant_override("separation", 8)

	_helm_slot = _make_slot(HELM_SLOT_SIZE)
	_helm_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	doll.add_child(_helm_slot)

	var middle_row := HBoxContainer.new()
	middle_row.alignment = BoxContainer.ALIGNMENT_CENTER
	middle_row.add_theme_constant_override("separation", 10)

	_weapon_slot = _make_slot(WEAPON_SLOT_SIZE)
	middle_row.add_child(_weapon_slot)

	_armor_slot = _make_slot(ARMOR_SLOT_SIZE)
	middle_row.add_child(_armor_slot)

	var right_stack := VBoxContainer.new()
	right_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	right_stack.add_theme_constant_override("separation", 6)
	_trinket_slot = _make_slot(SMALL_SLOT_SIZE)
	right_stack.add_child(_trinket_slot)
	_charm_slot = _make_slot(SMALL_SLOT_SIZE)
	right_stack.add_child(_charm_slot)
	middle_row.add_child(right_stack)

	doll.add_child(middle_row)
	return doll


func _make_slot(slot_size: Vector2) -> Panel:
	var slot := Panel.new()
	slot.custom_minimum_size = slot_size
	slot.mouse_filter = Control.MOUSE_FILTER_STOP

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Nearest-neighbor keeps the 32x32 pixel art crisp when scaled up to fill
	# the slot, instead of blurring like the project's photographic
	# backgrounds (which use the default linear filter).
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(icon)
	return slot


func _refresh() -> void:
	_gold_label.text = "Gold: %dg" % BuildState.gold
	_update_slot(_helm_slot, "Hood", null)
	_update_slot(_armor_slot, "Doublet", null)
	_update_slot(_weapon_slot, "Dagger", BuildState.equipped_weapon)
	_update_slot(_trinket_slot, "Ring", BuildState.equipped_trinket)
	_update_slot(_charm_slot, "Necklace", BuildState.equipped_charm)
	_refresh_inventory()


func _refresh_inventory() -> void:
	for child in _inventory_grid.get_children():
		child.queue_free()
	for index in BuildState.INVENTORY_CAPACITY:
		var gear: GearItem = BuildState.inventory[index] if index < BuildState.inventory.size() else null
		_inventory_grid.add_child(_make_inventory_slot(gear))


func _make_inventory_slot(gear: GearItem) -> Button:
	var slot := Button.new()
	slot.custom_minimum_size = INVENTORY_SLOT_SIZE
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slot.focus_mode = Control.FOCUS_NONE
	slot.text = ""
	_style_box_button(slot, gear)
	if gear == null:
		slot.disabled = true
		slot.tooltip_text = "Empty inventory slot"
	else:
		# Icon + slot/tier caption, same box content the shop item boxes
		# carry (shared via CardStyle rather than duplicated -- P2:R7 second
		# playtest-feedback pass, item 2; art added in the P2:R7 gear-art
		# pass).
		CardStyle.build_gear_box_content(slot, gear)
		slot.tooltip_text = _inventory_tooltip(gear)
		slot.pressed.connect(_on_inventory_slot_pressed.bind(gear))
	return slot


func _on_inventory_slot_pressed(gear: GearItem) -> void:
	if BuildState.shop_round_pending:
		_confirm_sell_inventory_item(gear)
	else:
		BuildState.equip_from_inventory(gear)


func _build_sell_dialog() -> void:
	_sell_dialog = ConfirmationDialog.new()
	_sell_dialog.title = "Sell Gear"
	_sell_dialog.confirmed.connect(_on_sell_confirmed)
	add_child(_sell_dialog)


func _confirm_sell_inventory_item(gear: GearItem) -> void:
	_pending_sell_inventory_item = gear
	_pending_sell_equipped_slot = -1
	_sell_dialog.dialog_text = "Sell %s for %dg?" % [gear.display_name, BuildState.sell_value_for(gear)]
	_sell_dialog.popup_centered()


func _confirm_sell_equipped_item(slot: GearItem.SlotType) -> void:
	var gear: GearItem = BuildState.equipped_weapon if slot == GearItem.SlotType.WEAPON else BuildState.equipped_trinket if slot == GearItem.SlotType.TRINKET else BuildState.equipped_charm
	if gear == null:
		return
	_pending_sell_inventory_item = null
	_pending_sell_equipped_slot = slot
	_sell_dialog.dialog_text = "Sell equipped %s for %dg?" % [gear.display_name, BuildState.sell_value_for(gear)]
	_sell_dialog.popup_centered()


func _on_sell_confirmed() -> void:
	if _pending_sell_inventory_item != null:
		BuildState.sell_inventory_item(_pending_sell_inventory_item)
	elif _pending_sell_equipped_slot != -1:
		BuildState.sell_equipped_item(_pending_sell_equipped_slot)
	_pending_sell_inventory_item = null
	_pending_sell_equipped_slot = -1
	_sell_dialog.hide()


## Equipped slots use a thicker accent-colored border (vs. the neutral
## SLOT_BORDER_COLOR on empty slots and inventory items) so "this is worn"
## reads as visually distinct from "this is in the bag," per the task's
## equipped-vs-inventory clarity requirement -- inventory slots keep the
## plain border via _style_box_button() below.
func _update_slot(slot: Panel, slot_name: String, gear: GearItem) -> void:
	var fill: Color = EMPTY_SLOT_COLOR if gear == null else TIER_COLORS[gear.tier]
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = CardStyle.ACCENT_COLOR if gear != null else SLOT_BORDER_COLOR
	style.set_border_width_all(3 if gear != null else 2)
	style.set_corner_radius_all(6)
	slot.add_theme_stylebox_override("panel", style)
	(slot.get_node("Icon") as TextureRect).texture = GearIcons.icon_for(gear)

	if gear == null:
		slot.tooltip_text = "%s: Empty" % slot_name
		return
	slot.tooltip_text = _equipped_tooltip(gear)
	if slot == _weapon_slot:
		_connect_equipped_slot_click(slot, GearItem.SlotType.WEAPON)
	elif slot == _trinket_slot:
		_connect_equipped_slot_click(slot, GearItem.SlotType.TRINKET)
	elif slot == _charm_slot:
		_connect_equipped_slot_click(slot, GearItem.SlotType.CHARM)


func _connect_equipped_slot_click(slot: Panel, gear_slot: GearItem.SlotType) -> void:
	if not slot.has_meta("sell_click_connected"):
		slot.gui_input.connect(_on_equipped_slot_gui_input.bind(gear_slot))
		slot.set_meta("sell_click_connected", true)


## During a shop round, clicking an equipped slot offers to sell it (matches
## the existing sell-inventory-item flow). Outside a shop round, it offers
## to unequip it back to the inventory tray instead -- previously the only
## way to bench an equipped item was to equip a replacement over it, which
## silently displaced it; this makes "send it back to the bag" an explicit,
## discoverable action of its own, unambiguous from equipping. No-op while
## the build is locked or the inventory is already full.
func _on_equipped_slot_gui_input(event: InputEvent, gear_slot: GearItem.SlotType) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if BuildState.shop_round_pending:
		_confirm_sell_equipped_item(gear_slot)
	elif not BuildState.build_locked and BuildState.can_add_inventory_item():
		BuildState.unequip(gear_slot)


func _style_box_button(button: Button, gear: GearItem) -> void:
	var fill: Color = EMPTY_SLOT_COLOR if gear == null else TIER_COLORS[gear.tier]
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = fill
		style.border_color = SLOT_BORDER_COLOR
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		button.add_theme_stylebox_override(state, style)


func _inventory_tooltip(gear: GearItem) -> String:
	var action := "Sell for %dg" % BuildState.sell_value_for(gear) if BuildState.shop_round_pending else "Equip"
	return "%s\nIn inventory -- %s" % [_gear_tooltip(gear), action]


func _equipped_tooltip(gear: GearItem) -> String:
	var action: String
	if BuildState.shop_round_pending:
		action = "Sell for %dg" % BuildState.sell_value_for(gear)
	elif BuildState.build_locked:
		action = "Unlock build to change"
	elif not BuildState.can_add_inventory_item():
		action = "Inventory full -- can't unequip"
	else:
		action = "Unequip to inventory"
	return "%s\nEquipped -- %s" % [_gear_tooltip(gear), action]


func _gear_tooltip(gear: GearItem) -> String:
	if gear.tier == GearItem.Tier.LEGENDARY:
		return "\n".join(LegendaryCatalog.tooltip_lines(gear))
	var lines: PackedStringArray = []
	lines.append("%s - %s" % [GearGenerator.SLOT_TAGS[gear.slot], gear.display_name])
	for affix in gear.affixes:
		lines.append("  %s" % StatModifierFormatter.format(affix))
	return "\n".join(lines)
