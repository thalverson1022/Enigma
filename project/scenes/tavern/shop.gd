extends Control
## P2:M5 Tavern shop: shows gold, the 3 equip slots (with unequip), a batch
## of generated offers to buy, and a "Continue" button that hands control
## back to build_planner.gd to advance to the next real encounter (P2:M4's
## "Fight Again" re-fought a fixed dummy in place; P2:M5 has a real
## encounter ladder, so continuing now means moving to the next fight, not
## repeating this one). No game logic beyond reading/calling BuildState,
## per docs/Conventions.md's UI architecture principle.

signal continue_pressed

const OFFER_COUNT: int = 3
const RunRngSystem = preload("res://scripts/systems/run_rng.gd")

var _vbox: VBoxContainer
var _gold_label: Label
var _slots_box: VBoxContainer
var _offers_box: VBoxContainer
var _offers: Array[GearItem] = []


func _ready() -> void:
	_vbox = VBoxContainer.new()
	add_child(_vbox)

	_gold_label = Label.new()
	_vbox.add_child(_gold_label)

	var slots_label := Label.new()
	slots_label.text = "Equipped"
	_vbox.add_child(slots_label)
	_slots_box = VBoxContainer.new()
	_vbox.add_child(_slots_box)

	var offers_label := Label.new()
	offers_label.text = "Shop"
	_vbox.add_child(offers_label)
	_offers_box = VBoxContainer.new()
	_vbox.add_child(_offers_box)

	_offers = GearGenerator.generate_offers(
		OFFER_COUNT,
		RunRngSystem.seed_for_context(BuildState.adventure_seed, RunRngSystem.CONTEXT_SHOP_OFFER, ["dormant_tavern_shop"])
	)

	var continue_button := Button.new()
	continue_button.text = "Continue"
	continue_button.pressed.connect(func(): continue_pressed.emit())
	_vbox.add_child(continue_button)

	_refresh()


func _refresh() -> void:
	_gold_label.text = "Gold: %d" % BuildState.gold
	_refresh_slots()
	_refresh_offers()


func _refresh_slots() -> void:
	for child in _slots_box.get_children():
		child.queue_free()
	_add_slot_row("Weapon", BuildState.equipped_weapon, GearItem.SlotType.WEAPON)
	_add_slot_row("Trinket", BuildState.equipped_trinket, GearItem.SlotType.TRINKET)
	_add_slot_row("Charm", BuildState.equipped_charm, GearItem.SlotType.CHARM)


func _add_slot_row(label_text: String, gear: GearItem, slot: GearItem.SlotType) -> void:
	var row := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = "%s: %s" % [label_text, gear.display_name if gear != null else "Empty"]
	row.add_child(name_label)
	var unequip_button := Button.new()
	unequip_button.text = "Unequip"
	unequip_button.disabled = gear == null
	unequip_button.pressed.connect(_on_unequip_pressed.bind(slot))
	row.add_child(unequip_button)
	_slots_box.add_child(row)


func _on_unequip_pressed(slot: GearItem.SlotType) -> void:
	BuildState.unequip(slot)
	_refresh()


func _refresh_offers() -> void:
	for child in _offers_box.get_children():
		child.queue_free()
	for offer in _offers:
		var row := HBoxContainer.new()
		var name_label := Label.new()
		name_label.text = "%s (%d affixes)" % [offer.display_name, offer.affixes.size()]
		row.add_child(name_label)
		var price: int = GearGenerator.price_for_tier(offer.tier)
		var buy_button := Button.new()
		buy_button.text = "Buy (%dg)" % price
		buy_button.disabled = price > BuildState.gold
		buy_button.pressed.connect(_on_buy_pressed.bind(offer, price))
		row.add_child(buy_button)
		_offers_box.add_child(row)


func _on_buy_pressed(offer: GearItem, price: int) -> void:
	if BuildState.spend_gold(price):
		BuildState.equip(offer)
	_refresh()
