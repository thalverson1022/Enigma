extends Control
## Practice Room: freeform practice mode (P2:R10), distinct from the locked
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
## P2:R10:T4 scope, reworked into a compact paper-doll gear editor after
## Practice Room overflow feedback: the right panel shows equipment slots only,
## and clicking a slot opens its focused Rarity/stat popup. Each slot's Rarity
## dropdown (Basic/Master/Cursed, plus Legendary for the weapon slot) fixes a
## real GearGenerator-shaped affix slot count; each affix then gets a
## stat-choice dropdown that auto-fills the real tier value while staying
## editable. Choosing Legendary swaps the weapon's affix rows for a
## Legendary-name dropdown instead (TrainingRoomState.equip_legendary()/
## use_custom_weapon()); trinket/charm have no Legendary items today, so
## they're always the rarity-driven editor.
##
## P2:R10:T5 scope: fight-setup controls -- a target stats card
## (TrainingTargetPanel, styled like Adventure's enemy_panel.gd), a direct
## combat-duration input, a seed separate from the real Adventure seed, and a
## practice-gold input (feeds `BuildResolver.resolve_stats()`'s
## `current_gold` parameter so Bandit Blade's gold-scaling damage is actually
## testable here). Reworked post-R10 (UI-feedback pass): the target card no
## longer picks between 3 preset monsters -- Practice Room only measures
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
const SIDE_COLUMN_WIDTH := 300
const ACTION_BUTTON_FONT_SIZE := 16
const FIGHT_BUTTON_SIZE := Vector2(148, 52)
const LOG_BUTTON_SIZE := Vector2(148, 52)
const PRACTICE_SKILL_BUILD_MIN_HEIGHT := 148
const PAPER_DOLL_HELM_SLOT_SIZE := Vector2(66, 66)
const PAPER_DOLL_ARMOR_SLOT_SIZE := Vector2(96, 96)
const PAPER_DOLL_WEAPON_SLOT_SIZE := Vector2(78, 78)
const PAPER_DOLL_SMALL_SLOT_SIZE := Vector2(56, 56)
const GEAR_EDITOR_POPUP_SIZE := Vector2(390, 285)
const ROGUE_CLASS_PATH := "res://data/classes/rogue.tres"
const BACKDROP_COLOR := UIColors.OVERLAY_BACKDROP
const FIGHT_ICON := preload("res://assets/ui/icons/fight.png")
const PRACTICE_LOGO_PATH := "res://assets/ui/logos/peak_deeps_logo_mountain_crest.png"

const ACTIVE_TALENTS_PANEL_SCENE := preload("res://scenes/combat/active_talents_panel.tscn")
const TALENT_PANEL_SCENE := preload("res://scenes/combat/talent_panel.tscn")
const AVAILABLE_SKILLS_PANEL_SCENE := preload("res://scenes/combat/available_skills_panel.tscn")
const SKILL_BUILD_PANEL_SCENE := preload("res://scenes/combat/skill_build_panel.tscn")
const CHARACTER_STATS_PANEL_SCENE := preload("res://scenes/combat/character_stats_panel.tscn")
const COMBAT_LOG_INSPECTOR_SCRIPT := preload("res://scenes/combat/combat_log_inspector.gd")

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
var _weapon_slot_button: Button
var _trinket_slot_button: Button
var _charm_slot_button: Button
var _gear_slot_buttons: Dictionary = {}
var _gear_editor_overlay: Control
var _gear_editor_title: Label
var _gear_rarity_option: OptionButton
var _gear_legendary_option: OptionButton
var _gear_affix_column: VBoxContainer
var _editing_gear_item: GearItem = null
var _editing_gear_slot_name := ""
var _editing_gear_is_weapon := false
var _target_panel: TrainingTargetPanel
var _duration_spin: SpinBox
var _seed_spin: SpinBox
var _gold_spin: SpinBox
var _combat_view: TrainingRoomCombatView
var _skill_build_panel
var _fight_button: Button
var _view_log_button: Button
var _log_overlay: Control
var _log_inspector
var _result_log: RichTextLabel
var _talent_overlay: Control
var _talent_panel


func _ready() -> void:
	_state = TrainingRoomState.new()
	_state.set_class(load(ROGUE_CLASS_PATH))

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, 16)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	vbox.add_child(header)

	var heading := Label.new()
	heading.text = "Practice Room"
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
	subtitle.text = "Where questionable builds go to become slightly less questionable."
	vbox.add_child(subtitle)

	# Three-column layout mirroring Adventure's real combat_screen.gd column
	# structure (Left: character stats + talents, Center: combat view +
	# skill strips, Right: target/fight-setup + gear), per user feedback
	# that Practice Room should read as a variant of Adventure mode rather
	# than a flat stack of sections.
	var columns := HBoxContainer.new()
	columns.name = "Columns"
	columns.add_theme_constant_override("separation", 10)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(columns)

	var left_column := VBoxContainer.new()
	left_column.name = "LeftColumn"
	left_column.add_theme_constant_override("separation", 6)
	left_column.custom_minimum_size = Vector2(SIDE_COLUMN_WIDTH, 0)
	columns.add_child(left_column)

	var character_stats_panel := CHARACTER_STATS_PANEL_SCENE.instantiate()
	character_stats_panel.name = "CharacterStatsPanel"
	character_stats_panel.state = _state
	left_column.add_child(character_stats_panel)

	var active_talents_panel := ACTIVE_TALENTS_PANEL_SCENE.instantiate()
	active_talents_panel.name = "ActiveTalentsPanel"
	active_talents_panel.state = _state
	active_talents_panel.enable_open_button_attention = false
	active_talents_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	active_talents_panel.open_talents_pressed.connect(_show_talent_overlay)
	left_column.add_child(active_talents_panel)

	var center_column := VBoxContainer.new()
	center_column.name = "CenterColumn"
	center_column.add_theme_constant_override("separation", 6)
	center_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_column.size_flags_stretch_ratio = 2.0
	columns.add_child(center_column)

	_combat_view = TrainingRoomCombatView.new()
	_combat_view.name = "CombatView"
	_combat_view.finished.connect(_on_combat_view_finished)
	center_column.add_child(_combat_view)

	# Fight + Combat Log live inside the combat view's lower band, matching
	# Adventure's M5 combat-window treatment.
	var fight_button_row := HBoxContainer.new()
	fight_button_row.name = "FightButtonRow"
	fight_button_row.add_theme_constant_override("separation", 8)
	fight_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fight_button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_combat_view.add_action_row(fight_button_row)

	_fight_button = Button.new()
	_fight_button.name = "FightButton"
	_fight_button.text = "Fight"
	CardStyle.configure_icon_button(_fight_button, FIGHT_ICON, 6)
	_fight_button.custom_minimum_size = FIGHT_BUTTON_SIZE
	_fight_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_fight_button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)
	_fight_button.pressed.connect(_on_fight_button_pressed)
	fight_button_row.add_child(_fight_button)

	_view_log_button = Button.new()
	_view_log_button.name = "ViewLogButton"
	_view_log_button.text = "Combat Log"
	_view_log_button.custom_minimum_size = LOG_BUTTON_SIZE
	_view_log_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_view_log_button.add_theme_font_size_override("font_size", ACTION_BUTTON_FONT_SIZE)
	_view_log_button.disabled = true
	_view_log_button.pressed.connect(func(): _log_overlay.visible = true)
	fight_button_row.add_child(_view_log_button)

	var available_skills_panel := AVAILABLE_SKILLS_PANEL_SCENE.instantiate()
	available_skills_panel.state = _state
	center_column.add_child(available_skills_panel)

	_skill_build_panel = SKILL_BUILD_PANEL_SCENE.instantiate()
	_skill_build_panel.state = _state
	_combat_view.skill_build_panel = _skill_build_panel
	center_column.add_child(_skill_build_panel)
	_skill_build_panel.custom_minimum_size = Vector2(0, PRACTICE_SKILL_BUILD_MIN_HEIGHT)

	var right_column := VBoxContainer.new()
	right_column.name = "RightColumn"
	right_column.add_theme_constant_override("separation", 6)
	right_column.custom_minimum_size = Vector2(SIDE_COLUMN_WIDTH, 0)
	columns.add_child(right_column)

	_target_panel = TrainingTargetPanel.new()
	_target_panel.name = "TargetPanel"
	_target_panel.armor_changed.connect(_on_target_armor_changed)
	_target_panel.poison_resist_changed.connect(_on_target_poison_resist_changed)
	right_column.add_child(_target_panel)

	_build_fight_setup_panel(right_column)

	_build_gear_paper_doll(right_column)
	_build_practice_logo(right_column)

	_build_talent_overlay()
	_build_gear_editor_overlay()
	_build_log_overlay()

	_state.build_changed.connect(_refresh_tree_dropdowns)
	_state.build_changed.connect(_refresh_gear_editor)
	_state.build_changed.connect(_refresh_fight_button)
	_state.build_changed.connect(_invalidate_result_review)
	_state.lock_changed.connect(_refresh_fight_button)
	_state.fight_setup_changed.connect(_refresh_target_panel)
	_state.fight_setup_changed.connect(_invalidate_result_review)
	_state.fight_finished.connect(_on_state_fight_finished)
	_refresh_tree_dropdowns()
	_refresh_gear_editor()
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
## "pick exactly one, then a second one later" flow, since Practice Room lets
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


func _show_talent_overlay() -> void:
	_talent_overlay.visible = true


func _build_talent_overlay() -> void:
	_talent_overlay = Control.new()
	_talent_overlay.name = "TalentOverlay"
	_talent_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_talent_overlay.visible = false
	add_child(_talent_overlay)

	var panel := CardStyle.build_modal_panel(_talent_overlay, true)
	var style := CardStyle.make_stylebox(18)
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(900, 700)
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)

	var header := HBoxContainer.new()
	var title := Label.new()
	title.text = "Talent Trees"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	header.add_child(title)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): _talent_overlay.visible = false)
	header.add_child(close_button)
	content.add_child(header)

	var tree_dropdowns_row := HBoxContainer.new()
	tree_dropdowns_row.name = "TreeDropdowns"
	tree_dropdowns_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tree_dropdowns_row.add_theme_constant_override("separation", 10)
	content.add_child(tree_dropdowns_row)

	_primary_tree_option = _build_tree_option(tree_dropdowns_row, "Primary", _on_primary_tree_selected)
	_secondary_tree_option = _build_tree_option(tree_dropdowns_row, "Secondary", _on_secondary_tree_selected)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(860, 590)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	_talent_panel = TALENT_PANEL_SCENE.instantiate()
	_talent_panel.name = "TalentPanel"
	_talent_panel.state = _state
	_talent_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_talent_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(_talent_panel)


func _build_gear_paper_doll(parent: Container) -> void:
	var panel := PanelContainer.new()
	panel.name = "PracticeGearPanel"
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox(12))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Gear"
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	var equipment_label := Label.new()
	equipment_label.text = "Equipment"
	equipment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	equipment_label.add_theme_font_size_override("font_size", 15)
	content.add_child(equipment_label)

	var doll := VBoxContainer.new()
	doll.name = "PracticeGearDoll"
	doll.add_theme_constant_override("separation", 6)
	content.add_child(doll)

	var helm_slot := _make_gear_slot_button(PAPER_DOLL_HELM_SLOT_SIZE)
	helm_slot.name = "HelmSlot"
	helm_slot.disabled = true
	helm_slot.tooltip_text = "Helm: Future slot"
	helm_slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_style_gear_slot_button(helm_slot, null, true)
	doll.add_child(helm_slot)

	var middle_row := HBoxContainer.new()
	middle_row.alignment = BoxContainer.ALIGNMENT_CENTER
	middle_row.add_theme_constant_override("separation", 8)
	doll.add_child(middle_row)

	_weapon_slot_button = _make_gear_slot_button(PAPER_DOLL_WEAPON_SLOT_SIZE)
	_weapon_slot_button.name = "WeaponSlot"
	_weapon_slot_button.pressed.connect(_show_gear_slot_editor.bind("Weapon", _state.practice_weapon, true))
	middle_row.add_child(_weapon_slot_button)

	var armor_slot := _make_gear_slot_button(PAPER_DOLL_ARMOR_SLOT_SIZE)
	armor_slot.name = "ArmorSlot"
	armor_slot.disabled = true
	armor_slot.tooltip_text = "Armor: Future slot"
	_style_gear_slot_button(armor_slot, null, true)
	middle_row.add_child(armor_slot)

	var right_stack := VBoxContainer.new()
	right_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	right_stack.add_theme_constant_override("separation", 6)
	middle_row.add_child(right_stack)

	_trinket_slot_button = _make_gear_slot_button(PAPER_DOLL_SMALL_SLOT_SIZE)
	_trinket_slot_button.name = "TrinketSlot"
	_trinket_slot_button.pressed.connect(_show_gear_slot_editor.bind("Trinket", _state.practice_trinket, false))
	right_stack.add_child(_trinket_slot_button)

	_charm_slot_button = _make_gear_slot_button(PAPER_DOLL_SMALL_SLOT_SIZE)
	_charm_slot_button.name = "CharmSlot"
	_charm_slot_button.pressed.connect(_show_gear_slot_editor.bind("Charm", _state.practice_charm, false))
	right_stack.add_child(_charm_slot_button)

	_gear_slot_buttons = {
		_state.practice_weapon: _weapon_slot_button,
		_state.practice_trinket: _trinket_slot_button,
		_state.practice_charm: _charm_slot_button,
	}


func _build_practice_logo(parent: Container) -> void:
	var holder := CenterContainer.new()
	holder.name = "PracticeLogoHolder"
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	parent.add_child(holder)

	var logo := TextureRect.new()
	logo.name = "PracticeLogo"
	logo.texture = _texture_from_path(PRACTICE_LOGO_PATH)
	logo.custom_minimum_size = Vector2(270, 170)
	logo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.modulate = Color(1, 1, 1, 0.92)
	holder.add_child(logo)


func _texture_from_path(path: String) -> Texture2D:
	var image := Image.new()
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)


func _make_gear_slot_button(slot_size: Vector2) -> Button:
	var slot := Button.new()
	slot.text = ""
	slot.custom_minimum_size = slot_size
	slot.focus_mode = Control.FOCUS_NONE
	slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(icon)
	return slot


func _build_gear_editor_overlay() -> void:
	_gear_editor_overlay = Control.new()
	_gear_editor_overlay.name = "GearEditorOverlay"
	_gear_editor_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gear_editor_overlay.visible = false
	add_child(_gear_editor_overlay)

	var panel := CardStyle.build_modal_panel(_gear_editor_overlay, true)
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())

	var content := VBoxContainer.new()
	content.custom_minimum_size = GEAR_EDITOR_POPUP_SIZE
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)

	var header := HBoxContainer.new()
	_gear_editor_title = Label.new()
	_gear_editor_title.text = "Edit Gear"
	_gear_editor_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gear_editor_title.theme_type_variation = &"PanelHeader"
	_gear_editor_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	header.add_child(_gear_editor_title)

	var close_button := Button.new()
	close_button.text = "Done"
	close_button.pressed.connect(func(): _gear_editor_overlay.visible = false)
	header.add_child(close_button)
	content.add_child(header)

	var rarity_row := _build_labeled_row(content, "Rarity")
	_gear_rarity_option = OptionButton.new()
	_gear_rarity_option.name = "RarityOption"
	_gear_rarity_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gear_rarity_option.item_selected.connect(_on_editor_rarity_selected)
	rarity_row.add_child(_gear_rarity_option)

	_gear_legendary_option = OptionButton.new()
	_gear_legendary_option.name = "LegendaryOption"
	_gear_legendary_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_gear_legendary_option.item_selected.connect(_on_weapon_legendary_selected)
	content.add_child(_gear_legendary_option)

	var separator := HSeparator.new()
	content.add_child(separator)

	_gear_affix_column = VBoxContainer.new()
	_gear_affix_column.name = "AffixRows"
	_gear_affix_column.add_theme_constant_override("separation", 4)
	content.add_child(_gear_affix_column)


func _show_gear_slot_editor(slot_name: String, item: GearItem, is_weapon: bool) -> void:
	_editing_gear_slot_name = slot_name
	_editing_gear_item = item
	_editing_gear_is_weapon = is_weapon
	_gear_editor_title.text = "%s Gear" % slot_name
	_populate_rarity_option(is_weapon)
	_refresh_gear_editor()
	_gear_editor_overlay.visible = true


func _populate_rarity_option(is_weapon: bool) -> void:
	_gear_rarity_option.clear()
	_gear_rarity_option.add_item("None", NONE_RARITY_ID)
	for tier in [GearItem.Tier.BASIC, GearItem.Tier.MASTER, GearItem.Tier.CURSED]:
		_gear_rarity_option.add_item(RARITY_NAMES[tier], tier)
	if is_weapon:
		_gear_rarity_option.add_item("Legendary", GearItem.Tier.LEGENDARY)


func _on_editor_rarity_selected(index: int) -> void:
	if _editing_gear_item == null:
		return
	_on_rarity_selected(index, _gear_rarity_option, _editing_gear_item, _editing_gear_is_weapon)


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


func _refresh_gear_editor() -> void:
	_refresh_paper_doll_slots()
	if _editing_gear_item == null or _gear_affix_column == null:
		return
	_refresh_popup_slot(_editing_gear_item, _editing_gear_is_weapon and _state.is_weapon_legendary())


func _refresh_paper_doll_slots() -> void:
	_update_paper_doll_slot(_weapon_slot_button, "Weapon", _state.equipped_weapon)
	_update_paper_doll_slot(_trinket_slot_button, "Trinket", _state.equipped_trinket)
	_update_paper_doll_slot(_charm_slot_button, "Charm", _state.equipped_charm)


func _update_paper_doll_slot(slot: Button, slot_name: String, gear: GearItem) -> void:
	if slot == null:
		return
	_style_gear_slot_button(slot, gear)
	(slot.get_node("Icon") as TextureRect).texture = GearIcons.icon_for(gear)
	slot.tooltip_text = "%s: Empty" % slot_name if gear == null else _gear_tooltip(gear)


func _style_gear_slot_button(slot: Button, gear: GearItem, future_slot: bool = false) -> void:
	var fill := UIColors.SLOT_EMPTY
	if future_slot:
		fill = UIColors.SLOT_EMPTY.darkened(0.25)
	elif gear != null:
		match gear.tier:
			GearItem.Tier.BASIC:
				fill = UIColors.TIER_BASIC
			GearItem.Tier.MASTER:
				fill = UIColors.TIER_MASTER
			GearItem.Tier.CURSED:
				fill = UIColors.TIER_CURSED
			GearItem.Tier.LEGENDARY:
				fill = UIColors.TIER_LEGENDARY
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = fill.darkened(0.35) if state == "disabled" else fill
		style.border_color = CardStyle.ACCENT_COLOR if gear != null else UIColors.SLOT_BORDER
		style.set_border_width_all(3 if gear != null else 2)
		style.set_corner_radius_all(6)
		slot.add_theme_stylebox_override(state, style)


func _refresh_popup_slot(item: GearItem, showing_legendary: bool) -> void:
	if _gear_rarity_option.item_count == 0:
		_populate_rarity_option(_editing_gear_is_weapon)
	if showing_legendary:
		_gear_rarity_option.select(_gear_rarity_option.get_item_index(GearItem.Tier.LEGENDARY))
	elif item.affixes.is_empty():
		_gear_rarity_option.select(_gear_rarity_option.get_item_index(NONE_RARITY_ID))
	else:
		_gear_rarity_option.select(_gear_rarity_option.get_item_index(item.tier))

	_gear_legendary_option.visible = showing_legendary
	_gear_affix_column.visible = not showing_legendary
	for child in _gear_affix_column.get_children():
		child.queue_free()

	if showing_legendary:
		_refresh_legendary_option()
		return
	for i in item.affixes.size():
		_gear_affix_column.add_child(_build_affix_row(item, i))
	if item.affixes.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No gear equipped."
		empty_label.add_theme_color_override("font_color", UIColors.TEXT_DISABLED)
		_gear_affix_column.add_child(empty_label)


func _refresh_legendary_option() -> void:
	_gear_legendary_option.clear()
	var items := LegendaryCatalog.all_items()
	for legendary_item in items:
		_gear_legendary_option.add_item(legendary_item.display_name)
	var current_index := items.find(_state.equipped_weapon)
	_gear_legendary_option.select(maxi(current_index, 0))
	_gear_legendary_option.tooltip_text = _gear_tooltip(_state.equipped_weapon)


func _gear_tooltip(gear: GearItem) -> String:
	if gear == null:
		return ""
	return "\n".join(CardStyle.gear_tooltip_lines(gear))


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


func _build_fight_setup_panel(parent: Container) -> void:
	var panel := PanelContainer.new()
	panel.name = "FightSetupPanel"
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox(12))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Fight Setup"
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	var controls := VBoxContainer.new()
	controls.name = "FightSetupRow"
	controls.add_theme_constant_override("separation", 6)
	content.add_child(controls)

	_build_fight_setup_controls(controls)


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
	_fight_button.disabled = not _state.can_run_fight()
	if _state.rotation.is_empty():
		_fight_button.tooltip_text = "Slot at least one skill before fighting"
	elif not _state.build_locked:
		_fight_button.tooltip_text = "Lock your skill build to fight"
	else:
		_fight_button.tooltip_text = ""


func _on_fight_button_pressed() -> void:
	if not _state.can_run_fight():
		_refresh_fight_button()
		return
	_state.run_fight()


## Combat has already fully resolved synchronously inside _state.run_fight()
## by this point -- this only starts the combat view's re-play of the
## already-recorded timeline. The result log itself is filled in once that
## animation (or its headless instant-skip) finishes, via _combat_view's
## `finished` signal -> _on_combat_view_finished().
func _on_state_fight_finished() -> void:
	_combat_view.play(_state.last_result, _state.selected_target, _state.equipped_gear())


## Fills the (button-gated, see _build_log_overlay()) Combat Log and enables
## the button that reveals it -- mirrors combat_screen.gd's
## _view_log_button/_log_overlay pattern (disabled until the first fight
## resolves, dismissible via Close or clicking the backdrop).
func _on_combat_view_finished() -> void:
	_log_inspector.set_result(_state.last_result, _state.selected_target, true)
	_result_log.text = CombatResultFormatter.format_practice(_state.last_result, _state.selected_target)
	_view_log_button.disabled = false


func _invalidate_result_review() -> void:
	if _view_log_button != null:
		_view_log_button.disabled = true
	if _log_overlay != null:
		_log_overlay.visible = false
	if _log_inspector != null:
		_log_inspector.clear()
	if _result_log != null:
		_result_log.text = ""


## Dimmed backdrop (click to dismiss) + a centered card holding the actual
## log -- same shape as combat_screen.gd's _build_log_overlay(). Hidden until
## the first fight resolves.
func _build_log_overlay() -> void:
	_log_overlay = Control.new()
	_log_overlay.name = "LogOverlay"
	_log_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_log_overlay.visible = false
	add_child(_log_overlay)

	var panel := CardStyle.build_modal_panel(_log_overlay, true)
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())

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

	_log_inspector = COMBAT_LOG_INSPECTOR_SCRIPT.new()
	_log_inspector.visible = false
	content.add_child(_log_inspector)

	var detail_title := Label.new()
	detail_title.text = "Event Log"
	detail_title.theme_type_variation = &"PanelHeader"
	content.add_child(detail_title)

	_result_log = RichTextLabel.new()
	_result_log.name = "ResultLog"
	_result_log.bbcode_enabled = false
	_result_log.custom_minimum_size = Vector2(760, 180)
	_result_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_result_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(_result_log)
