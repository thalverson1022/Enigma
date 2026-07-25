extends Control
## Training Room: freeform practice mode (P2:R10), distinct from the locked
## Adventure flow. Deliberately touches no BuildState/save fields -- practice
## builds, gear, and results here must never affect or be affected by a real
## Adventure run, per the P2:R10 scope decision. Owns its own
## `TrainingRoomState` (never the real `BuildState` autoload) and hands it to
## the reused dashboard panels via their `state` property.
##
## P2:R10:T3 scope: freeform tree/passive/rotation selection (reusing
## talent_panel/available_skills_panel/skill_build_panel/
## character_stats_panel, each parameterized to accept an injected state).
## Tree selection is two dropdowns (Primary/Secondary Tree) next to the
## Talents panel, backed by TrainingRoomState.set_primary_tree()/
## set_secondary_tree() (post-R10 UI-feedback pass).
##
## P2:R10:T4 scope, reworked into a rarity-first gear editor (post-R10
## UI-feedback pass): each slot's Rarity dropdown (Basic/Master/Cursed, plus
## Legendary for the weapon slot) fixes a real GearGenerator-shaped affix
## slot count rather than letting the player freely add/remove any number of
## affixes; each slot then gets a stat-choice dropdown that auto-fills the
## real tier value (still editable afterward). Choosing Legendary swaps the
## weapon's affix rows for a Legendary-name dropdown instead
## (TrainingRoomState.equip_legendary()/use_custom_weapon()); trinket/charm
## have no Legendary items today, so they're always the rarity-driven editor.
##
## P2:R10:T5 scope: fight-setup controls -- a target stats card
## (TrainingTargetPanel, styled like Adventure's enemy_panel.gd), a direct
## combat-duration input, a seed separate from the real Adventure seed, and a
## practice-gold input (feeds `BuildResolver.resolve_stats()`'s
## `current_gold` parameter so Bandit Blade's gold-scaling damage is actually
## testable here). Reworked post-R10 (UI-feedback pass): the target card no
## longer picks between 3 preset monsters -- Training Room only measures
## damage dealt in a fixed window, never whether the target dies, so it's
## just adjustable Armor/Poison Resist values on a single practice target
## with no HP concept anywhere in the UI.
##
## P2:R10:T6 scope, extended post-R10: a Fight button (centered under the
## combat view rather than spanning the screen) that runs
## `TrainingRoomState.run_fight()`, then plays the result through
## TrainingRoomCombatView -- a dedicated animated combat area (HP bar/skill
## popups/speed controls) built directly on the already-reusable
## CombatPlayback logic class, rather than extracting combat_screen.gd's
## entangled playback rendering. The result log (CombatResultFormatter/
## CombatRecap, same presentation logic Adventure's recap uses) now appears
## once that animation finishes rather than instantly.

signal back_pressed

const HEADING_FONT_SIZE := 32
const CARD_TITLE_FONT_SIZE := 20
const ROGUE_CLASS_PATH := "res://data/classes/rogue.tres"
const BACKDROP_COLOR := UIColors.OVERLAY_BACKDROP

const TALENT_PANEL_SCENE := preload("res://scenes/combat/talent_panel.tscn")
const AVAILABLE_SKILLS_PANEL_SCENE := preload("res://scenes/combat/available_skills_panel.tscn")
const SKILL_BUILD_PANEL_SCENE := preload("res://scenes/combat/skill_build_panel.tscn")
const CHARACTER_STATS_PANEL_SCENE := preload("res://scenes/combat/character_stats_panel.tscn")

const RARITY_NAMES := {
	GearItem.Tier.BASIC: "Basic",
	GearItem.Tier.MASTER: "Master",
	GearItem.Tier.CURSED: "Cursed",
}

## Sentinel OptionButton item id for the "None" rarity choice (empties the
## slot entirely) -- distinct from any real GearItem.Tier enum value (0-3).
## Deliberately NOT -1: Godot's OptionButton/PopupMenu.add_item() treats an
## explicit id of -1 as "auto-assign the item's index as its id" (the same
## sentinel meaning as omitting the id argument entirely), so passing -1
## here would silently collide with Basic's real id of 0 (since "None" is
## added at index 0) instead of ever comparing equal to -1 anywhere.
const NONE_RARITY_ID := 100

var _state: TrainingRoomState
var _primary_tree_option: OptionButton
var _secondary_tree_option: OptionButton
var _weapon_affix_column: VBoxContainer
var _trinket_affix_column: VBoxContainer
var _charm_affix_column: VBoxContainer
var _weapon_rarity_option: OptionButton
var _trinket_rarity_option: OptionButton
var _charm_rarity_option: OptionButton
var _weapon_legendary_option: OptionButton
var _target_panel: TrainingTargetPanel
var _duration_spin: SpinBox
var _seed_spin: SpinBox
var _gold_spin: SpinBox
var _combat_view: TrainingRoomCombatView
var _fight_button: Button
var _view_log_button: Button
var _log_overlay: Control
var _result_log: RichTextLabel


func _ready() -> void:
	_state = TrainingRoomState.new()
	_state.set_class(load(ROGUE_CLASS_PATH))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	add_child(margin)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 14)
	scroll.add_child(vbox)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	vbox.add_child(header)

	var heading := Label.new()
	heading.text = "Training Room"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.theme_type_variation = &"TitleHeading"
	heading.add_theme_font_size_override("font_size", HEADING_FONT_SIZE)
	header.add_child(heading)

	var back_button := Button.new()
	back_button.name = "BackButton"
	back_button.text = "Back to Title"
	back_button.pressed.connect(func(): back_pressed.emit())
	header.add_child(back_button)

	var subtitle := Label.new()
	subtitle.text = "Freeform build practice -- never touches your real Adventure save."
	vbox.add_child(subtitle)

	# Three-column layout mirroring Adventure's real combat_screen.gd column
	# structure (Left: character stats + talents, Center: combat view +
	# skill strips, Right: target/fight-setup + gear), per user feedback
	# that Training Room should read as a variant of Adventure mode rather
	# than a flat stack of sections.
	var columns := HBoxContainer.new()
	columns.name = "Columns"
	columns.add_theme_constant_override("separation", 12)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(columns)

	var left_column := VBoxContainer.new()
	left_column.name = "LeftColumn"
	left_column.add_theme_constant_override("separation", 8)
	left_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Roughly 1/4, 1/2, 1/4 (user feedback) -- the center column (combat view
	# + skill strips) is the primary focus of the screen; Character Stats
	# still fits every line at this width since the font/card padding is the
	# same regardless of the exact ratio, just needs to not be squeezed.
	left_column.size_flags_stretch_ratio = 1.0
	columns.add_child(left_column)

	var character_stats_panel := CHARACTER_STATS_PANEL_SCENE.instantiate()
	character_stats_panel.name = "CharacterStatsPanel"
	character_stats_panel.state = _state
	left_column.add_child(character_stats_panel)

	var talent_column := VBoxContainer.new()
	talent_column.name = "TalentColumn"
	talent_column.add_theme_constant_override("separation", 8)
	left_column.add_child(talent_column)

	var tree_dropdowns_row := HBoxContainer.new()
	tree_dropdowns_row.name = "TreeDropdowns"
	tree_dropdowns_row.add_theme_constant_override("separation", 8)
	talent_column.add_child(tree_dropdowns_row)

	_primary_tree_option = _build_tree_option(tree_dropdowns_row, "Primary", _on_primary_tree_selected)
	_secondary_tree_option = _build_tree_option(tree_dropdowns_row, "Secondary", _on_secondary_tree_selected)

	var talent_panel := TALENT_PANEL_SCENE.instantiate()
	talent_panel.state = _state
	talent_column.add_child(talent_panel)

	var center_column := VBoxContainer.new()
	center_column.name = "CenterColumn"
	center_column.add_theme_constant_override("separation", 8)
	center_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_column.size_flags_stretch_ratio = 2.0
	columns.add_child(center_column)

	_combat_view = TrainingRoomCombatView.new()
	_combat_view.name = "CombatView"
	_combat_view.finished.connect(_on_combat_view_finished)
	center_column.add_child(_combat_view)

	# Fight + Combat Log, centered under the combat view rather than
	# spanning the full screen width.
	var fight_button_row := HBoxContainer.new()
	fight_button_row.name = "FightButtonRow"
	fight_button_row.add_theme_constant_override("separation", 8)
	fight_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fight_button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	center_column.add_child(fight_button_row)

	_fight_button = Button.new()
	_fight_button.name = "FightButton"
	_fight_button.text = "Fight"
	_fight_button.custom_minimum_size = Vector2(180, 0)
	_fight_button.pressed.connect(_on_fight_button_pressed)
	fight_button_row.add_child(_fight_button)

	_view_log_button = Button.new()
	_view_log_button.name = "ViewLogButton"
	_view_log_button.text = "Combat Log"
	_view_log_button.disabled = true
	_view_log_button.pressed.connect(func(): _log_overlay.visible = true)
	fight_button_row.add_child(_view_log_button)

	var available_skills_panel := AVAILABLE_SKILLS_PANEL_SCENE.instantiate()
	available_skills_panel.state = _state
	center_column.add_child(available_skills_panel)

	var skill_build_panel := SKILL_BUILD_PANEL_SCENE.instantiate()
	skill_build_panel.state = _state
	center_column.add_child(skill_build_panel)

	var right_column := VBoxContainer.new()
	right_column.name = "RightColumn"
	right_column.add_theme_constant_override("separation", 8)
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.size_flags_stretch_ratio = 1.0
	columns.add_child(right_column)

	_target_panel = TrainingTargetPanel.new()
	_target_panel.name = "TargetPanel"
	_target_panel.armor_changed.connect(_on_target_armor_changed)
	_target_panel.poison_resist_changed.connect(_on_target_poison_resist_changed)
	right_column.add_child(_target_panel)

	var fight_setup_title := Label.new()
	fight_setup_title.text = "Fight Setup"
	fight_setup_title.theme_type_variation = &"PanelHeader"
	right_column.add_child(fight_setup_title)

	# A VBoxContainer of stacked label+control rows, not one flat HBoxContainer
	# -- this column is too narrow for 3 label/spinbox pairs side by side.
	var fight_setup_column := VBoxContainer.new()
	fight_setup_column.name = "FightSetupRow"
	fight_setup_column.add_theme_constant_override("separation", 6)
	right_column.add_child(fight_setup_column)

	_build_fight_setup_controls(fight_setup_column)

	var gear_editor_title := Label.new()
	gear_editor_title.text = "Gear Editor"
	gear_editor_title.theme_type_variation = &"PanelHeader"
	right_column.add_child(gear_editor_title)

	# Slot columns stack vertically here (not side by side) -- a single
	# "Gear" card in the mockup, and this column is too narrow for 3 slots
	# side by side.
	var gear_editor_column := VBoxContainer.new()
	gear_editor_column.name = "GearEditorRow"
	gear_editor_column.add_theme_constant_override("separation", 12)
	right_column.add_child(gear_editor_column)

	_weapon_affix_column = _build_gear_slot_column(gear_editor_column, "Weapon", true)
	_trinket_affix_column = _build_gear_slot_column(gear_editor_column, "Trinket", false)
	_charm_affix_column = _build_gear_slot_column(gear_editor_column, "Charm", false)

	_build_log_overlay()

	_state.build_changed.connect(_refresh_tree_dropdowns)
	_state.build_changed.connect(_refresh_affix_columns)
	_state.build_changed.connect(_refresh_fight_button)
	_state.fight_setup_changed.connect(_refresh_target_panel)
	_state.fight_finished.connect(_on_state_fight_finished)
	_refresh_tree_dropdowns()
	_refresh_affix_columns()
	_refresh_fight_button()
	_refresh_target_panel()


## Builds one "None" + one-per-real-tree dropdown, next to the Talents panel
## rather than a row of toggle buttons spanning the whole screen. `on_selected`
## receives the chosen SubclassTree (or null for "None"), mirroring the old
## per-tree button handler's signature so callers/tests read the same way.
func _build_tree_option(parent: HBoxContainer, label_text: String, on_selected: Callable) -> OptionButton:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)

	var option := OptionButton.new()
	option.add_item("None")
	if _state.selected_class != null:
		for tree in _state.selected_class.trees:
			option.add_item(tree.display_name)
	option.item_selected.connect(func(index: int):
		var tree: SubclassTree = null if index == 0 else _state.selected_class.trees[index - 1]
		on_selected.call(tree)
	)
	parent.add_child(option)
	return option


## Freeform, up to 2 of the class's real trees -- distinct from Adventure's
## "pick exactly one, then a second one later" flow, since Training Room lets
## the player freely choose either tree into either slot at will.
func _refresh_tree_dropdowns() -> void:
	_select_tree_option(_primary_tree_option, _state.tree_at_slot(0))
	_select_tree_option(_secondary_tree_option, _state.tree_at_slot(1))


func _select_tree_option(option: OptionButton, tree: SubclassTree) -> void:
	if tree == null or _state.selected_class == null:
		option.select(0)
		return
	option.select(_state.selected_class.trees.find(tree) + 1)


func _on_primary_tree_selected(tree: SubclassTree) -> void:
	_state.set_primary_tree(tree)
	_refresh_tree_dropdowns()


func _on_secondary_tree_selected(tree: SubclassTree) -> void:
	_state.set_secondary_tree(tree)
	_refresh_tree_dropdowns()


## Builds one gear slot's column: a title, a Rarity dropdown (Basic/Master/
## Cursed, plus a Legendary entry for the weapon slot only, reusing
## GearItem.Tier's own enum values as the OptionButton item ids so no
## separate sentinel is needed), an affix-rows container (sized to the
## chosen rarity's real GearGenerator slot count), and -- weapon only -- a
## Legendary-name dropdown shown instead of the affix rows when Legendary is
## the chosen rarity. Returns the affix-rows container; `_refresh_affix_columns()`
## repopulates it (and the rarity/legendary dropdowns' selection) on every
## `build_changed`, matching every other panel's `_refresh()` pattern in this
## codebase.
func _build_gear_slot_column(parent: Container, slot_name: String, is_weapon: bool) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.name = "%sAffixColumn" % slot_name
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 4)
	parent.add_child(column)

	var title := Label.new()
	title.text = slot_name
	column.add_child(title)

	var item: GearItem = _state.practice_weapon if is_weapon else (
		_state.practice_trinket if slot_name == "Trinket" else _state.practice_charm
	)

	var rarity_option := OptionButton.new()
	rarity_option.name = "RarityOption"
	rarity_option.add_item("None", NONE_RARITY_ID)
	for tier in [GearItem.Tier.BASIC, GearItem.Tier.MASTER, GearItem.Tier.CURSED]:
		rarity_option.add_item(RARITY_NAMES[tier], tier)
	if is_weapon:
		rarity_option.add_item("Legendary", GearItem.Tier.LEGENDARY)
		_weapon_rarity_option = rarity_option
	elif slot_name == "Trinket":
		_trinket_rarity_option = rarity_option
	else:
		_charm_rarity_option = rarity_option
	rarity_option.item_selected.connect(_on_rarity_selected.bind(rarity_option, item, is_weapon))
	column.add_child(rarity_option)

	if is_weapon:
		_weapon_legendary_option = OptionButton.new()
		_weapon_legendary_option.name = "LegendaryOption"
		for legendary_item in LegendaryCatalog.all_items():
			_weapon_legendary_option.add_item(legendary_item.display_name)
		_weapon_legendary_option.item_selected.connect(_on_weapon_legendary_selected)
		column.add_child(_weapon_legendary_option)

	var rows := VBoxContainer.new()
	rows.name = "AffixRows"
	rows.add_theme_constant_override("separation", 2)
	column.add_child(rows)

	return rows


## Rarity dropdown -> Legendary swaps the weapon slot into Legendary mode
## (equipping whatever's currently shown there, or the first catalog item);
## -> None empties the slot entirely (no stats); any other rarity choice
## edits the practice item's slot count. Any choice switches back out of
## Legendary mode first if needed.
func _on_rarity_selected(index: int, option: OptionButton, item: GearItem, is_weapon: bool) -> void:
	var tier: int = option.get_item_id(index)
	if is_weapon and tier == GearItem.Tier.LEGENDARY:
		var items := LegendaryCatalog.all_items()
		var current_index := items.find(_state.equipped_weapon)
		_state.equip_legendary(items[current_index] if current_index >= 0 else items[0])
		return
	if is_weapon and _state.is_weapon_legendary():
		_state.use_custom_weapon()
	if tier == NONE_RARITY_ID:
		_state.clear_slot(item)
	else:
		_state.set_slot_rarity(item, tier)


func _on_weapon_legendary_selected(index: int) -> void:
	_state.equip_legendary(LegendaryCatalog.all_items()[index])


## Mirrors gear_panel.gd's private _gear_tooltip() format for the header and
## plain-stat lines (slot tag + name, then one line per affix via
## StatModifierFormatter.format()), then appends a flavor-text line for the
## item's special Legendary mechanic (per the user's requested "stat 1, stat
## 2, then legendary effect" order) instead of a raw formula -- Wyvern
## Kriss's tick-rate affix in particular read as an opaque "x0.50 Poison
## Tick Interval" rather than the "poison ticks twice as fast" it actually
## means. Duplicated from gear_panel.gd's private helper rather than shared,
## since this is the only place Training Room needs it. A hover tooltip is
## the only way to see a Legendary's stats here now that equipping one hides
## the affix rows entirely in favor of this dropdown (user-reported gap).
func _legendary_tooltip(item: GearItem) -> String:
	return "\n".join(LegendaryCatalog.tooltip_lines(item))


## Human flavor text for each Legendary's special mechanic -- never a raw
## stat formula. Keyed by the item's stable `id` (same convention as
## available_skills_panel.gd's SPEED_LABEL_BY_SKILL_ID), since each of the 5
## catalog Legendaries has a different, hand-authored special effect that
## doesn't reduce to a shared formula. Percentages/multipliers are still
## read off the item's real fields rather than hardcoded, so this can't
## silently drift out of sync if a Legendary's numbers are ever retuned.
func _legendary_effect_text(item: GearItem) -> String:
	return LegendaryCatalog.effect_text(item)


func _refresh_affix_columns() -> void:
	_refresh_gear_slot(_weapon_affix_column, _weapon_rarity_option, _state.practice_weapon, _state.is_weapon_legendary())
	_refresh_gear_slot(_trinket_affix_column, _trinket_rarity_option, _state.practice_trinket, false)
	_refresh_gear_slot(_charm_affix_column, _charm_rarity_option, _state.practice_charm, false)
	_weapon_legendary_option.visible = _state.is_weapon_legendary()
	if _state.is_weapon_legendary():
		_weapon_legendary_option.select(LegendaryCatalog.all_items().find(_state.equipped_weapon))
		_weapon_legendary_option.tooltip_text = _legendary_tooltip(_state.equipped_weapon)


## `showing_legendary` is true only for the weapon slot while a Legendary is
## equipped -- the affix rows (which always describe `item`, the practice
## item, never the Legendary itself) hide entirely in favor of the
## Legendary-name dropdown built alongside this column. The rarity dropdown
## itself stays enabled even in Legendary mode (bug fix: disabling it here
## left no way back to Basic/Master/Cursed once Legendary was chosen, since
## the old separate "Custom Weapon" button was removed in favor of picking a
## rarity from this same dropdown) -- re-selecting any real rarity switches
## back out of Legendary mode via _on_rarity_selected().
func _refresh_gear_slot(rows: VBoxContainer, rarity_option: OptionButton, item: GearItem, showing_legendary: bool) -> void:
	if showing_legendary:
		rarity_option.select(rarity_option.get_item_index(GearItem.Tier.LEGENDARY))
	elif item.affixes.is_empty():
		rarity_option.select(rarity_option.get_item_index(NONE_RARITY_ID))
	else:
		rarity_option.select(rarity_option.get_item_index(item.tier))
	rows.visible = not showing_legendary

	for child in rows.get_children():
		child.queue_free()
	if showing_legendary:
		return
	for i in item.affixes.size():
		rows.add_child(_build_affix_row(item, i))


func _build_affix_row(item: GearItem, index: int) -> HBoxContainer:
	var modifier: StatModifier = item.affixes[index]
	var pool: Array[StatModifier.StatType] = (
		GearGenerator.DOWNSIDE_POOL if item.tier == GearItem.Tier.CURSED and index == item.affixes.size() - 1
		else GearGenerator.AFFIX_POOL
	)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var stat_option := OptionButton.new()
	for stat_type in pool:
		stat_option.add_item(StatModifierFormatter.STAT_NAMES[stat_type], stat_type)
	stat_option.select(stat_option.get_item_index(modifier.stat))
	stat_option.item_selected.connect(_on_affix_stat_selected.bind(item, index, stat_option))
	row.add_child(stat_option)

	var value_spin := SpinBox.new()
	value_spin.min_value = -1000.0
	value_spin.max_value = 1000.0
	value_spin.step = 0.01
	value_spin.value = modifier.value
	value_spin.value_changed.connect(_on_affix_value_changed.bind(modifier))
	row.add_child(value_spin)

	return row


func _on_affix_stat_selected(index: int, item: GearItem, affix_index: int, stat_option: OptionButton) -> void:
	_state.set_affix_stat(item, affix_index, stat_option.get_item_id(index))


## Still freely editable after the stat pick auto-fills a real tier value,
## per the confirmed design -- this preserves the raw editor's original
## magnitude-testing power on top of the new rarity-first defaults.
func _on_affix_value_changed(new_value: float, modifier: StatModifier) -> void:
	modifier.value = new_value
	_state.notify_gear_edited()


## Duration/seed/practice-gold (P2:R10:T5; target now lives in its own
## TrainingTargetPanel card, see _refresh_target_panel()) -- built once,
## unlike the build/gear sections above, since nothing external changes
## these values; only this row's own controls do.
func _build_fight_setup_controls(parent: VBoxContainer) -> void:
	var duration_row := _build_labeled_row(parent, "Duration (s)")
	_duration_spin = SpinBox.new()
	_duration_spin.min_value = 1
	_duration_spin.max_value = 120
	_duration_spin.step = 1
	_duration_spin.value = _state.duration_ms / 1000.0
	_duration_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_duration_spin.value_changed.connect(_on_duration_changed)
	duration_row.add_child(_duration_spin)

	var seed_row := _build_labeled_row(parent, "Seed")
	_seed_spin = SpinBox.new()
	_seed_spin.min_value = 0
	_seed_spin.max_value = 2147483647
	_seed_spin.step = 1
	_seed_spin.rounded = true
	_seed_spin.value = _state.fight_seed
	_seed_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_seed_spin.value_changed.connect(_on_fight_seed_changed)
	seed_row.add_child(_seed_spin)

	var gold_row := _build_labeled_row(parent, "Practice Gold")
	_gold_spin = SpinBox.new()
	_gold_spin.min_value = 0
	_gold_spin.max_value = 99999
	_gold_spin.step = 1
	_gold_spin.rounded = true
	_gold_spin.value = _state.gold
	_gold_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gold_spin.value_changed.connect(_on_practice_gold_changed)
	gold_row.add_child(_gold_spin)


## One label + control row, stacked in the narrow right column rather than
## all three pairs crammed into a single horizontal row (which fit fine when
## this sat in its own full-width section, but not in a column this narrow).
func _build_labeled_row(parent: VBoxContainer, label_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(100, 0)
	row.add_child(label)
	return row


func _on_target_armor_changed(value: int) -> void:
	_state.set_target_armor(value)


func _on_target_poison_resist_changed(value: float) -> void:
	_state.set_target_poison_resistance(value)


## Pushes the target's current Armor/Poison Resist into the card -- called
## once up front and again on every fight_setup_changed (target or duration
## edits).
func _refresh_target_panel() -> void:
	_target_panel.refresh(_state.selected_target.armor, _state.selected_target.poison_resistance)


func _on_duration_changed(seconds: float) -> void:
	_state.set_duration_ms(roundi(seconds * 1000.0))


func _on_fight_seed_changed(value: float) -> void:
	_state.set_fight_seed(int(value))


func _on_practice_gold_changed(value: float) -> void:
	_state.set_practice_gold(int(value))


## An empty macro is a guaranteed zero-damage loss -- same guard
## `skill_build_panel.gd`'s Lock button already uses for the same reason.
func _refresh_fight_button() -> void:
	_fight_button.disabled = _state.rotation.is_empty()


func _on_fight_button_pressed() -> void:
	_state.run_fight()


## Combat has already fully resolved synchronously inside _state.run_fight()
## by this point -- this only starts the combat view's re-play of the
## already-recorded timeline. The result log itself is filled in once that
## animation (or its headless instant-skip) finishes, via _combat_view's
## `finished` signal -> _on_combat_view_finished().
func _on_state_fight_finished() -> void:
	_combat_view.play(_state.last_result, _state.selected_target)


## Fills the (button-gated, see _build_log_overlay()) Combat Log and enables
## the button that reveals it -- mirrors combat_screen.gd's
## _view_log_button/_log_overlay pattern (disabled until the first fight
## resolves, dismissible via Close or clicking the backdrop).
func _on_combat_view_finished() -> void:
	_result_log.text = CombatResultFormatter.format_practice(_state.last_result, _state.selected_target)
	_view_log_button.disabled = false


## Dimmed backdrop (click to dismiss) + a centered card holding the actual
## log -- same shape as combat_screen.gd's _build_log_overlay(). Hidden until
## the first fight resolves.
func _build_log_overlay() -> void:
	_log_overlay = Control.new()
	_log_overlay.name = "LogOverlay"
	_log_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_log_overlay.visible = false
	add_child(_log_overlay)

	var backdrop := Button.new()
	backdrop.flat = true
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop_style := StyleBoxFlat.new()
	backdrop_style.bg_color = BACKDROP_COLOR
	for backdrop_state in ["normal", "hover", "pressed", "focus"]:
		backdrop.add_theme_stylebox_override(backdrop_state, backdrop_style)
	backdrop.pressed.connect(func(): _log_overlay.visible = false)
	_log_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_log_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	var header := HBoxContainer.new()
	var header_title := Label.new()
	header_title.text = "Combat Log"
	header_title.theme_type_variation = &"PanelHeader"
	header_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	header.add_child(header_title)
	var header_spacer := Control.new()
	header_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(header_spacer)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): _log_overlay.visible = false)
	header.add_child(close_button)
	content.add_child(header)

	_result_log = RichTextLabel.new()
	_result_log.name = "ResultLog"
	_result_log.bbcode_enabled = false
	_result_log.custom_minimum_size = Vector2(600, 400)
	content.add_child(_result_log)
