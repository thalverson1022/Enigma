extends Control
## Tavern Shop overlay: buy/reroll gear offers against current gold.
## Extracted from combat_screen.gd's inline overlay builder
## (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md Phase 3).
##
## Unlike the other extracted overlays, this one is intentionally NOT a
## blocking modal: gear can still be sold from the dashboard's Gear panel
## while the shop is open, so there is no full-screen backdrop here -- only
## the card itself catches clicks (mouse_filter below).
##
## combat_screen.gd still owns show/hide timing and the dashboard-chrome side
## effects (hiding status/recap/log/retry buttons, refreshing the enemy HUD,
## autosaving) since those are cross-cutting dashboard state, not
## shop-internal -- this scene only owns its own construction, its own
## refresh, and the buy/reroll/continue signals combat_screen.gd reacts to.

signal buy_pressed(offer: GearItem)
signal reroll_pressed
signal continue_pressed

const CARD_TITLE_FONT_SIZE := 20
const SHOPKEEPER_TEXTURE := preload("res://assets/backgrounds/shop_dummy_background_2.jpg")
const GOLD_ICON := preload("res://assets/ui/icons/gold.png")

var _shopkeeper_image: TextureRect
var _shop_gold_label: Label
var _shop_status_label: Label
var _shop_reroll_button: Button
var _shop_offers_box: GridContainer
var _shop_leave_button: Button


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	center.add_child(panel)

	var content := HBoxContainer.new()
	content.custom_minimum_size = Vector2(620, 420)
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	var shopkeeper := PanelContainer.new()
	shopkeeper.custom_minimum_size = Vector2(260, 0)
	shopkeeper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var keeper_style := CardStyle.make_stylebox(8)
	keeper_style.bg_color = UIColors.PANEL_DEEP
	shopkeeper.add_theme_stylebox_override("panel", keeper_style)
	content.add_child(shopkeeper)

	var keeper_stage := Control.new()
	keeper_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	keeper_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	keeper_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shopkeeper.add_child(keeper_stage)

	_shopkeeper_image = TextureRect.new()
	_shopkeeper_image.texture = SHOPKEEPER_TEXTURE
	_shopkeeper_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_shopkeeper_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_shopkeeper_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shopkeeper_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	keeper_stage.add_child(_shopkeeper_image)

	var shop_content := VBoxContainer.new()
	shop_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_content.add_theme_constant_override("separation", 12)
	content.add_child(shop_content)

	var header := HBoxContainer.new()
	shop_content.add_child(header)

	var title := Label.new()
	title.text = "Tavern Shop"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	header.add_child(title)

	_shop_reroll_button = Button.new()
	_shop_reroll_button.pressed.connect(func(): reroll_pressed.emit())
	header.add_child(_shop_reroll_button)

	# P2:R7:T6: gold must be visible inside the shop overlay itself, not only
	# via the T3 header (the header stays on-screen during a shop round, but
	# this makes the afford-state readable without looking away from the
	# shop card).
	var gold_row := HBoxContainer.new()
	gold_row.alignment = BoxContainer.ALIGNMENT_CENTER
	gold_row.add_theme_constant_override("separation", 6)
	gold_row.add_child(CardStyle.make_pixel_icon(GOLD_ICON, CardStyle.UI_ICON_SIZE))
	shop_content.add_child(gold_row)

	_shop_gold_label = Label.new()
	_shop_gold_label.add_theme_color_override("font_color", UIColors.TEXT_GOLD)
	gold_row.add_child(_shop_gold_label)

	_shop_status_label = Label.new()
	_shop_status_label.visible = false
	shop_content.add_child(_shop_status_label)

	_shop_offers_box = GridContainer.new()
	_shop_offers_box.columns = 2
	_shop_offers_box.add_theme_constant_override("h_separation", 10)
	_shop_offers_box.add_theme_constant_override("v_separation", 10)
	shop_content.add_child(_shop_offers_box)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_content.add_child(spacer)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	button_row.add_theme_constant_override("separation", 12)
	shop_content.add_child(button_row)

	_shop_leave_button = Button.new()
	_shop_leave_button.text = "Leave Shop"
	_shop_leave_button.pressed.connect(func(): continue_pressed.emit())
	button_row.add_child(_shop_leave_button)


## Public so combat_screen.gd's buy/reroll handlers (which also autosave and
## call BuildState -- cross-cutting concerns that stay in combat_screen.gd)
## can set feedback text without reaching into the private label.
func set_status_text(text: String) -> void:
	_shop_status_label.text = text


## Rebuilds gold/status/reroll-button/offers-grid from current BuildState.
## Called by combat_screen.gd on open, after buy/reroll, and whenever
## BuildState changes while the shop is visible (gear can be sold from the
## dashboard's Gear panel while the shop stays open).
func refresh() -> void:
	_shop_gold_label.text = "Gold: %dg" % BuildState.gold
	_shop_status_label.text = ""
	_shop_reroll_button.text = "Reroll (%d)" % (0 if BuildState.shop_reroll_used else 1)
	_shop_reroll_button.disabled = BuildState.shop_reroll_used
	for child in _shop_offers_box.get_children():
		child.queue_free()
	for offer in BuildState.shop_offers:
		_shop_offers_box.add_child(_make_shop_offer_row(offer))


func _make_shop_offer_row(offer: GearItem) -> Control:
	var item_box := GearCompareButton.new()
	item_box.custom_minimum_size = Vector2(88, 88)
	item_box.tooltip_text = _shop_offer_text(offer)
	item_box.tooltip_builder = func(): return CardStyle.build_gear_compare_tooltip(self, _shop_offer_text(offer), BuildState.equipped_item_for_slot(offer.slot))
	item_box.disabled = GearGenerator.price_for_tier(offer.tier) > BuildState.gold or not BuildState.can_store_shop_offer(offer)
	item_box.pressed.connect(func(): buy_pressed.emit(offer))
	CardStyle.style_shop_item_box(item_box, offer)
	CardStyle.build_gear_box_content(item_box, offer)
	return item_box


## The shop-offer gear box's regular tooltip text: slot/name, tier, affixes,
## the price, and an explicit afford/inventory-space/click hint (P2:R7:T6).
## Rendered inside the first of CardStyle.build_gear_compare_tooltip()'s two
## tooltip-styled boxes, and kept on Button.tooltip_text as the plain-text
## fallback/accessibility copy.
func _shop_offer_text(offer: GearItem) -> String:
	var lines := CardStyle.gear_tooltip_lines(offer)
	lines.append_array(_shop_offer_footer_lines(offer))
	return "\n".join(lines)


## Price + afford/inventory-space/click hint for a shop offer, appended to
## _shop_offer_text()'s item lines.
func _shop_offer_footer_lines(offer: GearItem) -> PackedStringArray:
	var lines: PackedStringArray = []
	lines.append("Price: %dg" % GearGenerator.price_for_tier(offer.tier))
	if not BuildState.can_store_shop_offer(offer):
		lines.append("Inventory full -- can't buy.")
	elif GearGenerator.price_for_tier(offer.tier) > BuildState.gold:
		lines.append("Not enough gold.")
	else:
		lines.append("Click to buy.")
	return lines
