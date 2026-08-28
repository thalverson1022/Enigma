class_name TrainingTargetPanel
extends PanelContainer
## Practice Room's target stats card (visual parity with Adventure's
## enemy_panel.gd's card look): adjustable functional defense values for the
## practice target. Training Room only measures damage dealt in a fixed window,
## never whether the target is "killed", so HP/required-DPS never belongs here.
##
## Never touches TrainingRoomState directly -- training_room.gd owns the
## practice target and pushes its current stats in via refresh(), same
## "owner pushes data in" pattern the other reused dashboard panels use via
## their `state` property.

signal armor_changed(value: int)
signal poison_resist_changed(value: float)
signal defense_changed(field: String, value: Variant)
signal preset_selected(preset_id: String)
signal generated_roll_requested(difficulty_id: int)
signal generated_seed_requested(difficulty_id: int, seed: int)

const CARD_TITLE_FONT_SIZE := 20
const PANEL_MIN_HEIGHT := 300
const EncounterPreviewFormatterScript := preload("res://scripts/systems/runtime_monster_generator/encounter_preview_formatter.gd")
const PERCENT_FIELDS := ["poison_resistance", "dodge_chance", "crit_negation", "suppress", "slow"]
const DEFENSE_LABELS := {
	"armor": "Armor",
	"poison_resistance": "Resist",
	"dodge_chance": "Dodge",
	"crit_negation": "Crit Negate",
	"block": "Block",
	"absorb": "Absorb",
	"cleanse_threshold": "Cleanse",
	"suppress": "Suppress",
	"slow": "Slow",
	"stun_duration_ms": "Stun",
	"interrupt_skip_count": "Interrupt",
}
const DIFFICULTY_LABELS := {
	1: "Easy",
	2: "Medium",
	3: "Hard",
	4: "Ultra",
	5: "Nightmare",
}

var _armor_spin: SpinBox
var _poison_resist_spin: SpinBox
var _defense_spins: Dictionary = {}
var _preset_option: OptionButton
var _generator_difficulty_option: OptionButton
var _generated_seed_spin: SpinBox
var _generated_info_label: Label
var _refreshing_defenses := false


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

	var preset_row := _build_labeled_row(content, "Preset")
	_preset_option = OptionButton.new()
	_preset_option.name = "DefensePresetOption"
	_preset_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for preset in TrainingRoomState.TARGET_PRESETS:
		_preset_option.add_item(preset["name"])
		_preset_option.set_item_metadata(_preset_option.item_count - 1, preset["id"])
	_preset_option.item_selected.connect(func(index: int): preset_selected.emit(str(_preset_option.get_item_metadata(index))))
	preset_row.add_child(_preset_option)

	var generator_title := Label.new()
	generator_title.text = "Generated Target"
	generator_title.theme_type_variation = &"PanelHeader"
	content.add_child(generator_title)

	var generator_row := _build_labeled_row(content, "Difficulty")
	_generator_difficulty_option = OptionButton.new()
	_generator_difficulty_option.name = "GeneratedDifficultyOption"
	_generator_difficulty_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for difficulty_id in DIFFICULTY_LABELS:
		_generator_difficulty_option.add_item(DIFFICULTY_LABELS[difficulty_id], difficulty_id)
	generator_row.add_child(_generator_difficulty_option)

	var seed_row := _build_labeled_row(content, "Gen Seed")
	_generated_seed_spin = SpinBox.new()
	_generated_seed_spin.name = "GeneratedSeedSpin"
	_generated_seed_spin.min_value = 0
	_generated_seed_spin.max_value = 2147483647
	_generated_seed_spin.step = 1
	_generated_seed_spin.rounded = true
	_generated_seed_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seed_row.add_child(_generated_seed_spin)

	var generator_button_row := HBoxContainer.new()
	generator_button_row.add_theme_constant_override("separation", 6)
	content.add_child(generator_button_row)

	var roll_button := Button.new()
	roll_button.name = "RollGeneratedMonsterButton"
	roll_button.text = "Reroll"
	roll_button.tooltip_text = "Roll a new random generated Practice Room target"
	roll_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roll_button.pressed.connect(_on_roll_generated_pressed)
	generator_button_row.add_child(roll_button)

	var seed_button := Button.new()
	seed_button.name = "GenerateFromSeedButton"
	seed_button.text = "From Seed"
	seed_button.tooltip_text = "Generate the selected difficulty from the seed value"
	seed_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seed_button.pressed.connect(_on_generate_from_seed_pressed)
	generator_button_row.add_child(seed_button)

	_generated_info_label = Label.new()
	_generated_info_label.name = "GeneratedMonsterInfo"
	_generated_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_generated_info_label.add_theme_color_override("font_color", UIColors.TEXT_DISABLED)
	_generated_info_label.add_theme_font_size_override("font_size", 13)
	_generated_info_label.text = "No generated target rolled."
	content.add_child(_generated_info_label)

	_add_defense_spin(content, "armor", "Armor", 0, 999, 1, true)
	_add_defense_spin(content, "poison_resistance", "Resist %", 0, 100, 1, true)
	_add_defense_spin(content, "dodge_chance", "Dodge %", 0, 100, 1, true)
	_add_defense_spin(content, "crit_negation", "Crit Negate %", 0, 100, 1, true)
	_add_defense_spin(content, "block", "Block", 0, 100, 1, false)
	_add_defense_spin(content, "absorb", "Absorb", 0, 100, 1, false)
	_add_defense_spin(content, "cleanse_threshold", "Cleanse", 0, 20, 1, true)
	_add_defense_spin(content, "suppress", "Suppress %", 0, 100, 1, true)
	_add_defense_spin(content, "slow", "Slow %", 0, 100, 1, true)
	_add_defense_spin(content, "stun_duration_ms", "Stun ms", 0, 5000, 50, true)
	_add_defense_spin(content, "interrupt_skip_count", "Interrupt", 0, 5, 1, true)


func _build_labeled_row(parent: VBoxContainer, label_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(120, 0)
	row.add_child(label)
	return row


func _add_defense_spin(parent: VBoxContainer, field: String, label_text: String, min_value: float, max_value: float, step: float, rounded: bool) -> void:
	var row := _build_labeled_row(parent, label_text)
	var spin := SpinBox.new()
	spin.name = "%sSpin" % field.to_pascal_case()
	spin.min_value = min_value
	spin.max_value = max_value
	spin.step = step
	spin.rounded = rounded
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spin.value_changed.connect(_on_defense_spin_changed.bind(field))
	row.add_child(spin)
	_defense_spins[field] = spin
	if field == "armor":
		_armor_spin = spin
	elif field == "poison_resistance":
		_poison_resist_spin = spin


func _on_defense_spin_changed(value: float, field: String) -> void:
	if _refreshing_defenses:
		return
	if field == "armor":
		armor_changed.emit(roundi(value))
	elif field == "poison_resistance":
		poison_resist_changed.emit(value / 100.0)
	if PERCENT_FIELDS.has(field):
		defense_changed.emit(field, value / 100.0)
	elif field == "armor" or field == "cleanse_threshold" or field == "stun_duration_ms" or field == "interrupt_skip_count":
		defense_changed.emit(field, roundi(value))
	else:
		defense_changed.emit(field, value)


func _on_roll_generated_pressed() -> void:
	generated_roll_requested.emit(_selected_generated_difficulty_id())


func _on_generate_from_seed_pressed() -> void:
	generated_seed_requested.emit(_selected_generated_difficulty_id(), int(_generated_seed_spin.value))


func _selected_generated_difficulty_id() -> int:
	var difficulty_id := 1
	if _generator_difficulty_option != null:
		difficulty_id = _generator_difficulty_option.get_item_id(_generator_difficulty_option.selected)
	return difficulty_id


func refresh_generated_seed(seed: int) -> void:
	if _generated_seed_spin == null:
		return
	_generated_seed_spin.value = seed


## Pushes the target's current stats into the spinboxes. Safe to call after
## every edit (including this panel's own, via training_room.gd's
## fight_setup_changed round-trip) -- SpinBox.value only emits value_changed
## on an actual change, so refreshing with the value that's already current
## is a no-op signal-wise, same as the Duration/Seed/Gold controls.
func refresh(armor: int, poison_resistance: float) -> void:
	refresh_defenses({
		"armor": armor,
		"poison_resistance": poison_resistance,
	})


func refresh_defenses(defenses: Dictionary) -> void:
	_refreshing_defenses = true
	for field in _defense_spins:
		var spin: SpinBox = _defense_spins[field]
		var value: Variant = defenses.get(field, 0)
		spin.value = roundi(float(value) * 100.0) if PERCENT_FIELDS.has(field) else float(value)
	_refreshing_defenses = false


func refresh_generated_info(draft: GeneratedMonsterDraft) -> void:
	if _generated_info_label == null:
		return
	if draft == null:
		_generated_info_label.text = "No generated target rolled."
		return
	refresh_generated_seed(draft.source_seed)
	_generated_info_label.text = EncounterPreviewFormatterScript.format_practice_debug_text(draft)
