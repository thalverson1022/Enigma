class_name TrainingTargetPanel
extends PanelContainer
## Practice Room's target stats card (visual parity with Adventure's
## enemy_panel.gd's card look): adjustable Armor and Poison Resist values for
## the practice target. Replaced the earlier "pick one of 3 preset monsters"
## dropdown + HP/Required-DPS readout (post-R10 UI-feedback pass) -- Training
## Room only measures damage dealt in a fixed window, never whether the
## target is "killed", so HP/required-DPS never belonged here.
##
## Never touches TrainingRoomState directly -- training_room.gd owns the
## practice target and pushes its current stats in via refresh(), same
## "owner pushes data in" pattern the other reused dashboard panels use via
## their `state` property.

signal armor_changed(value: int)
signal poison_resist_changed(value: float)

const CARD_TITLE_FONT_SIZE := 20
const PANEL_MIN_HEIGHT := 140

var _armor_spin: SpinBox
var _poison_resist_spin: SpinBox


func _ready() -> void:
	add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	custom_minimum_size = Vector2(0, PANEL_MIN_HEIGHT)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	add_child(content)

	var title := Label.new()
	title.text = "Target"
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	var armor_row := _build_labeled_row(content, "Armor")
	_armor_spin = SpinBox.new()
	_armor_spin.name = "ArmorSpin"
	_armor_spin.min_value = 0
	_armor_spin.max_value = 999
	_armor_spin.step = 1
	_armor_spin.rounded = true
	_armor_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_armor_spin.value_changed.connect(func(value: float): armor_changed.emit(roundi(value)))
	armor_row.add_child(_armor_spin)

	var resist_row := _build_labeled_row(content, "Poison Resist %")
	_poison_resist_spin = SpinBox.new()
	_poison_resist_spin.name = "PoisonResistSpin"
	_poison_resist_spin.min_value = 0
	_poison_resist_spin.max_value = 100
	_poison_resist_spin.step = 1
	_poison_resist_spin.rounded = true
	_poison_resist_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_poison_resist_spin.value_changed.connect(func(value: float): poison_resist_changed.emit(value / 100.0))
	resist_row.add_child(_poison_resist_spin)


func _build_labeled_row(parent: VBoxContainer, label_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(120, 0)
	row.add_child(label)
	return row


## Pushes the target's current stats into the spinboxes. Safe to call after
## every edit (including this panel's own, via training_room.gd's
## fight_setup_changed round-trip) -- SpinBox.value only emits value_changed
## on an actual change, so refreshing with the value that's already current
## is a no-op signal-wise, same as the Duration/Seed/Gold controls.
func refresh(armor: int, poison_resistance: float) -> void:
	_armor_spin.value = armor
	_poison_resist_spin.value = roundi(poison_resistance * 100.0)
