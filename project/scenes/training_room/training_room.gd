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
## and clicking a slot opens its focused Rarity/stat popup. Each slot's
## non-Legendary Rarity dropdown follows the active generated Phase 5 tiers;
## each affix then gets a stat-choice dropdown that auto-fills a real tier
## value while staying editable. Choosing Legendary swaps the weapon's rows for a
## Legendary-name dropdown instead (TrainingRoomState.equip_legendary()/
## use_custom_weapon()); non-weapon slots have no Legendary items today, so
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
## just adjustable defenses on a single practice target
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
const UI_BACK_ICON_PATH := "res://assets/ui/icons/abandon_ex.png"
const TOP_ACTION_BUTTON_SIZE := Vector2(56, 56)
const SETTINGS_BUTTON_RESERVED_WIDTH := 50.0

const ACTIVE_TALENTS_PANEL_SCENE := preload("res://scenes/combat/active_talents_panel.tscn")
const TALENT_PANEL_SCENE := preload("res://scenes/combat/talent_panel.tscn")
const AVAILABLE_SKILLS_PANEL_SCENE := preload("res://scenes/combat/available_skills_panel.tscn")
const SKILL_BUILD_PANEL_SCENE := preload("res://scenes/combat/skill_build_panel.tscn")
const CHARACTER_STATS_PANEL_SCENE := preload("res://scenes/combat/character_stats_panel.tscn")
const COMBAT_LOG_INSPECTOR_SCRIPT := preload("res://scenes/combat/combat_log_inspector.gd")

const RARITY_NAMES := {
	GearItem.Tier.CRUDE: "Crude",
	GearItem.Tier.BASIC: "Basic",
	GearItem.Tier.MASTER: "Master",
	GearItem.Tier.EPIC: "Epic",
	GearItem.Tier.CURSED: "Cursed",
	GearItem.Tier.CHAOS: "Chaos",
	GearItem.Tier.UNIQUE: "Unique",
}

# P5M2 practice customization started on Basic/Master/Cursed; P5M9 brings the
# editor up to the active generated Phase 5 rarity set now shown in Adventure.
const PRACTICE_CUSTOM_TIERS := [
	GearItem.Tier.BASIC,
	GearItem.Tier.MASTER,
	GearItem.Tier.EPIC,
	GearItem.Tier.CURSED,
	GearItem.Tier.CHAOS,
	GearItem.Tier.UNIQUE,
]

## Sentinel OptionButton item id for the "None" rarity choice (empties the
## slot entirely) -- distinct from any real GearItem.Tier enum value (0-3).
## Deliberately NOT -1: Godot's OptionButton/PopupMenu.add_item() treats an
## explicit id of -1 as "auto-assign the item's index as its id" (the same
## sentinel meaning as omitting the id argument entirely), so passing -1
## here would silently collide with Basic's real id of 0 (since "None" is
## added at index 0) instead of ever comparing equal to -1 anywhere.
const NONE_RARITY_ID := 100

var _state: TrainingRoomState
var _weapon_slot_button: Button
var _helm_slot_button: Button
var _armor_slot_button: Button
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
var _random_seed_toggle: CheckBox
var _gold_spin: SpinBox
var _combat_view: TrainingRoomCombatView
var _skill_build_panel
var _fight_button: Button
var _view_log_button: Button
var _log_overlay: Control
var _log_inspector
var _result_log: RichTextLabel
var _talent_overlay: Control
var _talent_overlay_content: VBoxContainer
var _talent_overlay_scroll: ScrollContainer
var _talent_panel


func _ready() -> void:
	_state = TrainingRoomState.new()
	_state.set_class(load(ROGUE_CLASS_PATH))

	var canvas := ColorRect.new()
	canvas.name = "ScreenCanvas"
	canvas.color = UIColors.BACKGROUND
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(canvas)

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
	header.add_theme_constant_override("separation", 20)
	vbox.add_child(header)

	var heading := Label.new()
	heading.text = "Practice Room"
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.theme_type_variation = &"TitleHeading"
	heading.add_theme_font_size_override("font_size", HEADING_FONT_SIZE)
	header.add_child(heading)

	var back_button := Button.new()
	_configure_top_icon_button(back_button, "BackButton", _texture_from_path(UI_BACK_ICON_PATH), "Back to Title")
	back_button.pressed.connect(func(): back_pressed.emit())
	header.add_child(back_button)

	var settings_reserved_space := Control.new()
	settings_reserved_space.custom_minimum_size = Vector2(SETTINGS_BUTTON_RESERVED_WIDTH, 0)
	header.add_child(settings_reserved_space)

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
	_combat_view.gold_stolen_callback = Callable(_state, "add_practice_combat_gold")
	_combat_view.set_fight_window_ms(_state.duration_ms)
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

	var right_scroll := ScrollContainer.new()
	right_scroll.name = "RightColumnScroll"
	right_scroll.custom_minimum_size = Vector2(SIDE_COLUMN_WIDTH, 0)
	right_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	columns.add_child(right_scroll)

	var right_column := VBoxContainer.new()
	right_column.name = "RightColumn"
	right_column.add_theme_constant_override("separation", 6)
	right_column.custom_minimum_size = Vector2(SIDE_COLUMN_WIDTH, 0)
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_scroll.add_child(right_column)

	_build_gear_paper_doll(right_column)

	_target_panel = TrainingTargetPanel.new()
	_target_panel.name = "TargetPanel"
	_target_panel.defense_changed.connect(_on_target_defense_changed)
	_target_panel.preset_selected.connect(_on_target_preset_selected)
	_target_panel.generated_roll_requested.connect(_on_generated_roll_requested)
	right_column.add_child(_target_panel)

	_build_fight_setup_panel(right_column)
	_build_practice_logo(right_column)

	_build_talent_overlay()
	_build_gear_editor_overlay()
	_build_log_overlay()

	_state.build_changed.connect(_refresh_talent_panel)
	_state.build_changed.connect(_refresh_gear_editor)
	_state.build_changed.connect(_refresh_fight_button)
	_state.build_changed.connect(_refresh_fight_setup_controls)
	_state.build_changed.connect(_invalidate_result_review)
	_state.stats_preview_changed.connect(_refresh_fight_setup_controls)
	_state.lock_changed.connect(_refresh_fight_button)
	_state.fight_setup_changed.connect(_refresh_target_panel)
	_state.fight_setup_changed.connect(_refresh_fight_setup_controls)
	_state.fight_setup_changed.connect(_refresh_combat_view_fight_window)
	_state.fight_setup_changed.connect(_refresh_combat_view_target)
	_state.fight_setup_changed.connect(_invalidate_result_review)
	_state.fight_finished.connect(_on_state_fight_finished)
	_refresh_talent_panel()
	_refresh_gear_editor()
	_refresh_fight_button()
	_refresh_target_panel()
	_refresh_combat_view_target()


func _refresh_talent_panel() -> void:
	if _talent_panel != null and _talent_panel.has_method("refresh_panel"):
		_talent_panel.refresh_panel()


func _on_primary_tree_selected(tree: SubclassTree) -> void:
	_state.set_primary_tree(tree)
	_refresh_talent_panel()


func _on_secondary_tree_selected(tree: SubclassTree) -> void:
	_state.set_secondary_tree(tree)
	_refresh_talent_panel()


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
	_talent_overlay_content = content
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

	var scroll := ScrollContainer.new()
	_talent_overlay_scroll = scroll
	scroll.name = "TalentTreeScroll"
	scroll.custom_minimum_size = Vector2(860, 590)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(scroll)

	_talent_panel = TALENT_PANEL_SCENE.instantiate()
	_talent_panel.name = "TalentPanel"
	_talent_panel.state = _state
	_talent_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_talent_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(_talent_panel)
	if get_viewport() != null:
		get_viewport().size_changed.connect(_resize_talent_overlay_to_viewport)
	_resize_talent_overlay_to_viewport()


func _resize_talent_overlay_to_viewport() -> void:
	if _talent_overlay_content == null or _talent_overlay_scroll == null:
		return
	var available := get_viewport_rect().size - Vector2(96, 96)
	var content_size := Vector2(
		minf(900.0, maxf(560.0, available.x)),
		minf(700.0, maxf(360.0, available.y))
	)
	_talent_overlay_content.custom_minimum_size = content_size
	_talent_overlay_scroll.custom_minimum_size = Vector2(
		minf(860.0, maxf(520.0, content_size.x - 40.0)),
		minf(590.0, maxf(180.0, content_size.y - 80.0))
	)


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

	_helm_slot_button = _make_gear_slot_button(PAPER_DOLL_HELM_SLOT_SIZE, GearItem.SlotType.HELM)
	_helm_slot_button.name = "HelmSlot"
	_helm_slot_button.pressed.connect(_show_gear_slot_editor.bind("Helm", _state.practice_helm, false))
	doll.add_child(_helm_slot_button)

	var middle_row := HBoxContainer.new()
	middle_row.alignment = BoxContainer.ALIGNMENT_CENTER
	middle_row.add_theme_constant_override("separation", 8)
	doll.add_child(middle_row)

	_weapon_slot_button = _make_gear_slot_button(PAPER_DOLL_WEAPON_SLOT_SIZE, GearItem.SlotType.WEAPON)
	_weapon_slot_button.name = "WeaponSlot"
	_weapon_slot_button.pressed.connect(_show_gear_slot_editor.bind("Weapon", _state.practice_weapon, true))
	middle_row.add_child(_weapon_slot_button)

	_armor_slot_button = _make_gear_slot_button(PAPER_DOLL_ARMOR_SLOT_SIZE, GearItem.SlotType.ARMOR)
	_armor_slot_button.name = "ArmorSlot"
	_armor_slot_button.pressed.connect(_show_gear_slot_editor.bind("Armor", _state.practice_armor, false))
	middle_row.add_child(_armor_slot_button)

	# P5M8 equipment layout source of truth matches the live Gear panel:
	# Charm/Necklace should sit above Trinket/Ring on the right stack.
	var right_stack := VBoxContainer.new()
	right_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	right_stack.add_theme_constant_override("separation", 6)
	middle_row.add_child(right_stack)

	_charm_slot_button = _make_gear_slot_button(PAPER_DOLL_SMALL_SLOT_SIZE, GearItem.SlotType.CHARM)
	_charm_slot_button.name = "CharmSlot"
	_charm_slot_button.pressed.connect(_show_gear_slot_editor.bind("Charm", _state.practice_charm, false))
	right_stack.add_child(_charm_slot_button)

	_trinket_slot_button = _make_gear_slot_button(PAPER_DOLL_SMALL_SLOT_SIZE, GearItem.SlotType.TRINKET)
	_trinket_slot_button.name = "TrinketSlot"
	_trinket_slot_button.pressed.connect(_show_gear_slot_editor.bind("Trinket", _state.practice_trinket, false))
	right_stack.add_child(_trinket_slot_button)

	_gear_slot_buttons = {
		_state.practice_weapon: _weapon_slot_button,
		_state.practice_helm: _helm_slot_button,
		_state.practice_armor: _armor_slot_button,
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
	return load(path) as Texture2D


func _configure_top_icon_button(button: Button, button_name: String, texture: Texture2D, tooltip: String) -> void:
	button.name = button_name
	button.text = ""
	button.tooltip_text = tooltip
	button.custom_minimum_size = TOP_ACTION_BUTTON_SIZE
	button.icon = texture
	button.expand_icon = true
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_constant_override("h_separation", 0)
	button.add_theme_stylebox_override("normal", _top_icon_button_style(UIColors.BUTTON_FILL, UIColors.PANEL_BORDER))
	button.add_theme_stylebox_override("hover", _top_icon_button_style(UIColors.BUTTON_TOP_LIGHT, UIColors.PANEL_BORDER))
	button.add_theme_stylebox_override("pressed", _top_icon_button_style(UIColors.BUTTON_FILL_PRESSED, UIColors.PANEL_BORDER))
	button.add_theme_stylebox_override("focus", _top_icon_button_style(UIColors.BUTTON_FILL, UIColors.TEXT_GOLD))


func _top_icon_button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 4
	style.border_width_bottom = 5
	style.border_blend = true
	style.set_corner_radius_all(6)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 5
	style.content_margin_bottom = 6
	style.shadow_color = UIColors.PANEL_DROP_SHADOW
	style.shadow_size = 7
	style.shadow_offset = Vector2(2, 4)
	return style


func _make_gear_slot_button(slot_size: Vector2, gear_slot: int) -> Button:
	var slot := GearCompareButton.new()
	slot.text = ""
	slot.custom_minimum_size = slot_size
	slot.focus_mode = Control.FOCUS_NONE
	slot.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var slot_background := TextureRect.new()
	slot_background.name = "SlotTypeBackground"
	slot_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slot_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	slot_background.texture = GearIcons.slot_background_for(gear_slot)
	slot_background.modulate = Color(1, 1, 1, 0.46)
	slot_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(slot_background)

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
	if is_weapon:
		_gear_rarity_option.add_item(RARITY_NAMES[GearItem.Tier.CRUDE], GearItem.Tier.CRUDE)
	for tier in PRACTICE_CUSTOM_TIERS:
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
	_update_paper_doll_slot(_helm_slot_button, "Helm", _state.equipped_helm)
	_update_paper_doll_slot(_armor_slot_button, "Armor", _state.equipped_armor)
	_update_paper_doll_slot(_charm_slot_button, "Charm", _state.equipped_charm)
	_update_paper_doll_slot(_trinket_slot_button, "Trinket", _state.equipped_trinket)


func _update_paper_doll_slot(slot: Button, slot_name: String, gear: GearItem) -> void:
	if slot == null:
		return
	_style_gear_slot_button(slot, gear)
	(slot.get_node("Icon") as TextureRect).texture = GearIcons.icon_for(gear)
	(slot.get_node("SlotTypeBackground") as TextureRect).modulate = Color(1, 1, 1, 0.28 if gear != null else 0.56)
	slot.tooltip_text = "%s: Empty" % slot_name if gear == null else _gear_tooltip(gear)
	var compare_slot := slot as GearCompareButton
	if compare_slot == null:
		return
	if gear == null:
		compare_slot.tooltip_builder = Callable()
	else:
		compare_slot.tooltip_builder = func() -> Control:
			return CardStyle.build_gear_tooltip(self, gear)


func _style_gear_slot_button(slot: Button, gear: GearItem) -> void:
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		slot.add_theme_stylebox_override(state, CardStyle.make_gear_item_stylebox(gear, gear != null, state))


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
	var pool := _stat_ids_for_affix_slot(item, index)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var stat_option := OptionButton.new()
	for stat_id in pool:
		stat_option.add_item(StatCatalog.label_for(stat_id))
		stat_option.set_item_metadata(stat_option.item_count - 1, stat_id)
	stat_option.select(_stat_option_index(stat_option, StatCatalog.canonical_id_for_modifier(modifier)))
	stat_option.item_selected.connect(_on_affix_stat_selected.bind(item, index, stat_option))
	row.add_child(stat_option)

	var value_spin := SpinBox.new()
	value_spin.min_value = -1000.0
	value_spin.max_value = 1000.0
	value_spin.step = _editor_step_for_modifier(modifier)
	value_spin.rounded = _editor_uses_integer_steps(modifier)
	value_spin.value = _editor_value_for_modifier(modifier)
	value_spin.value_changed.connect(_on_affix_value_changed.bind(modifier))
	row.add_child(value_spin)

	return row


func _on_affix_stat_selected(index: int, item: GearItem, affix_index: int, stat_option: OptionButton) -> void:
	var metadata: Variant = stat_option.get_item_metadata(index)
	_state.set_affix_stat(item, affix_index, metadata if metadata != null else stat_option.get_item_id(index))


## Still freely editable after the stat pick auto-fills a real tier value,
## per the confirmed design -- this preserves the raw editor's original
## magnitude-testing power on top of the new rarity-first defaults.
func _on_affix_value_changed(new_value: float, modifier: StatModifier) -> void:
	modifier.value = _modifier_value_from_editor(modifier, new_value)
	_state.notify_gear_edited()


func _editor_value_for_modifier(modifier: StatModifier) -> float:
	var kind := _value_kind_for_modifier(modifier)
	match kind:
		StatCatalog.VALUE_PERCENT, StatCatalog.VALUE_CHANCE:
			return round(modifier.value * 100.0)
		StatCatalog.VALUE_FLAT, StatCatalog.VALUE_STACKS:
			return round(modifier.value)
	return modifier.value


func _modifier_value_from_editor(modifier: StatModifier, editor_value: float) -> float:
	var kind := _value_kind_for_modifier(modifier)
	match kind:
		StatCatalog.VALUE_PERCENT, StatCatalog.VALUE_CHANCE:
			return round(editor_value) / 100.0
		StatCatalog.VALUE_FLAT, StatCatalog.VALUE_STACKS:
			return round(editor_value)
	return editor_value


func _editor_step_for_modifier(modifier: StatModifier) -> float:
	return 1.0 if _editor_uses_integer_steps(modifier) else 0.1


func _editor_uses_integer_steps(modifier: StatModifier) -> bool:
	var kind := _value_kind_for_modifier(modifier)
	return (
		kind == StatCatalog.VALUE_PERCENT
		or kind == StatCatalog.VALUE_CHANCE
		or kind == StatCatalog.VALUE_FLAT
		or kind == StatCatalog.VALUE_STACKS
	)


func _value_kind_for_modifier(modifier: StatModifier) -> String:
	if modifier == null:
		return ""
	return StatCatalog.value_kind_for(StatCatalog.canonical_id_for_modifier(modifier))


func _stat_ids_for_affix_slot(item: GearItem, index: int) -> Array[String]:
	if item == null or index < 0 or index >= item.affixes.size():
		return []
	if item.tier == GearItem.Tier.CHAOS:
		return _chaos_stat_ids_for_slot(item.slot)
	var modifier: StatModifier = item.affixes[index]
	if modifier.category == StatModifier.StatCategory.DRAWBACK:
		return StatCatalog.drawback_stat_ids_for_slot(item.slot)
	var category := StatCatalog.CATEGORY_BASIC
	if modifier.category == StatModifier.StatCategory.RARE:
		category = StatCatalog.CATEGORY_RARE
	elif modifier.category == StatModifier.StatCategory.SPECIAL:
		category = StatCatalog.CATEGORY_SPECIAL
	return StatCatalog.stat_ids_for_slot(item.slot, category)


func _chaos_stat_ids_for_slot(slot: GearItem.SlotType) -> Array[String]:
	var ids: Array[String] = []
	for category in [StatCatalog.CATEGORY_BASIC, StatCatalog.CATEGORY_RARE]:
		for stat_id in StatCatalog.stat_ids_for_slot(slot, category):
			if not ids.has(stat_id):
				ids.append(stat_id)
	for stat_id in StatCatalog.drawback_stat_ids_for_slot(slot):
		if not ids.has(stat_id):
			ids.append(stat_id)
	return ids


func _stat_option_index(option: OptionButton, stat_id: String) -> int:
	for i in option.item_count:
		if String(option.get_item_metadata(i)) == stat_id:
			return i
	return 0


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


## Duration/practice-gold (P2:R10:T5; target now lives in its own
## TrainingTargetPanel card, see _refresh_target_panel()) -- built once,
## unlike the build/gear sections above, since nothing external changes
## these values; only this row's own controls do.
func _build_fight_setup_controls(parent: VBoxContainer) -> void:
	var timing_row := HBoxContainer.new()
	timing_row.add_theme_constant_override("separation", 6)
	parent.add_child(timing_row)

	var duration_label := Label.new()
	duration_label.text = "Seconds"
	duration_label.custom_minimum_size = Vector2(62, 0)
	timing_row.add_child(duration_label)

	_duration_spin = SpinBox.new()
	_duration_spin.min_value = 1
	_duration_spin.max_value = 120
	_duration_spin.step = 1
	_duration_spin.value = _state.duration_ms / 1000.0
	_duration_spin.custom_minimum_size = Vector2(72, 0)
	_duration_spin.value_changed.connect(_on_duration_changed)
	timing_row.add_child(_duration_spin)

	var seed_label := Label.new()
	seed_label.text = "Seed"
	seed_label.custom_minimum_size = Vector2(40, 0)
	timing_row.add_child(seed_label)

	_seed_spin = SpinBox.new()
	_seed_spin.name = "FightSeedSpin"
	_seed_spin.min_value = 0
	_seed_spin.max_value = 2147483647
	_seed_spin.step = 1
	_seed_spin.rounded = true
	_seed_spin.value = _state.fight_seed
	_seed_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_seed_spin.value_changed.connect(_on_fight_seed_changed)
	timing_row.add_child(_seed_spin)

	_random_seed_toggle = CheckBox.new()
	_random_seed_toggle.name = "RandomFightSeedToggle"
	_random_seed_toggle.text = "Random"
	_random_seed_toggle.tooltip_text = "Use a fresh random seed for each practice fight and generated target roll"
	_random_seed_toggle.button_pressed = _state.random_fight_seed_enabled
	_random_seed_toggle.toggled.connect(_on_random_fight_seed_toggled)
	timing_row.add_child(_random_seed_toggle)

	var gold_row := _build_labeled_row(parent, "Practice Gold")
	_gold_spin = SpinBox.new()
	_gold_spin.name = "PracticeGoldSpin"
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


func _on_target_defense_changed(field: String, value: Variant) -> void:
	_state.set_target_defense(field, value)


func _on_target_preset_selected(preset_id: String) -> void:
	_state.apply_target_preset(preset_id)


func _on_generated_roll_requested(contract_level: int, difficulty_id: int, monster_kind: String, archetype_a_id: String, archetype_b_id: String) -> void:
	var seed := -1 if _state.random_fight_seed_enabled else _state.fight_seed
	_state.roll_generated_target(difficulty_id, seed, monster_kind, archetype_a_id, archetype_b_id, contract_level)


## Pushes the target's current defenses into the card -- called
## once up front and again on every fight_setup_changed (target or duration
## edits).
func _refresh_target_panel() -> void:
	_target_panel.refresh_defenses(_state.target_defense_snapshot())
	_target_panel.refresh_generated_info(_state.generated_monster_draft)


func _refresh_fight_setup_controls() -> void:
	if _duration_spin != null:
		_duration_spin.set_block_signals(true)
		_duration_spin.value = _state.duration_ms / 1000.0
		_duration_spin.set_block_signals(false)
	if _seed_spin != null:
		_seed_spin.set_block_signals(true)
		_seed_spin.value = _state.fight_seed
		_seed_spin.editable = not _state.random_fight_seed_enabled
		_seed_spin.set_block_signals(false)
	if _random_seed_toggle != null:
		_random_seed_toggle.set_block_signals(true)
		_random_seed_toggle.button_pressed = _state.random_fight_seed_enabled
		_random_seed_toggle.set_block_signals(false)
	if _gold_spin != null:
		_gold_spin.set_block_signals(true)
		_gold_spin.value = _state.gold
		_gold_spin.set_block_signals(false)


func _refresh_combat_view_fight_window() -> void:
	if _combat_view != null:
		_combat_view.set_fight_window_ms(_state.duration_ms)


func _refresh_combat_view_target() -> void:
	if _combat_view != null:
		_combat_view.set_target_preview(_state.selected_target)


func _on_duration_changed(seconds: float) -> void:
	_state.set_duration_ms(roundi(seconds * 1000.0))


func _on_fight_seed_changed(value: float) -> void:
	_state.set_fight_seed(int(value))


func _on_random_fight_seed_toggled(enabled: bool) -> void:
	_state.set_random_fight_seed_enabled(enabled)


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
		CardStyle.pulse_blocked_control(_fight_button)
		return
	_state.run_fight()


## Combat has already fully resolved synchronously inside _state.run_fight()
## by this point -- this only starts the combat view's re-play of the
## already-recorded timeline. The result log itself is filled in once that
## animation (or its headless instant-skip) finishes, via _combat_view's
## `finished` signal -> _on_combat_view_finished().
func _on_state_fight_finished() -> void:
	var stats := BuildResolver.resolve_stats(
		_state.selected_class,
		_state.selected_trees,
		_state.selected_talents,
		_state.equipped_gear(),
		_state.gold
	)
	_combat_view.play(
		_state.last_result,
		_state.selected_target,
		_state.equipped_gear(),
		stats.shred_value,
		CombatResolver.effective_enemy_slow(stats, _state.selected_target),
		_base_poison_damage_for_stats(stats),
		stats.decay_value
	)


func _base_poison_damage_for_stats(stats: PlayerStats) -> float:
	var base_damage := stats.base_poison_damage + stats.bonus_base_elemental_damage
	if stats.base_poison_damage > 0.0 or stats.bonus_base_elemental_damage != 0.0:
		base_damage = maxf(PlayerStats.MIN_DAMAGE_BASE, base_damage)
	return base_damage


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
