extends Control
## The persistent combat HUD, laid out per the user's mockups: a dominant
## central combat window (future home of animated combat) flanked by side
## columns -- left: Character Stats over Talent Trees; right: Enemy Stats
## over Gear -- with Fight/Combat Log, then the Available Skills and Skill
## Build strips, under the combat window. Each panel reads BuildState directly and
## refreshes on BuildState.build_changed -- no cross-panel coupling, per
## docs/Conventions.md's UI architecture principle. This script itself only
## owns the combat window, the log overlay, the top bar, and the Fight
## action.
##
## The combat log lives in a dismissible overlay rather than inline in the
## combat window -- once real combat animation exists, the window needs
## that space for the fight itself, not a wall of text. The log remains
## fully available on demand via "View Combat Log," since reading exactly
## what happened is core to the game (see docs/DPS_Engine_Phase2_Context.md's
## design philosophy), it just doesn't have to compete with animation for
## screen space.

signal main_menu_pressed
signal adventure_restart_pressed
signal save_and_quit_pressed

const CHARACTER_STATS_SCENE := preload("res://scenes/combat/character_stats_panel.tscn")
const ENEMY_SCENE := preload("res://scenes/combat/enemy_panel.tscn")
const TALENT_SCENE := preload("res://scenes/combat/talent_panel.tscn")
const AVAILABLE_SKILLS_SCENE := preload("res://scenes/combat/available_skills_panel.tscn")
const SKILL_BUILD_SCENE := preload("res://scenes/combat/skill_build_panel.tscn")
const GEAR_SCENE := preload("res://scenes/combat/gear_panel.tscn")

const SIDE_COLUMN_WIDTH := 300
const SCREEN_MARGIN := 16
const PANEL_SEPARATION := 16
const CARD_TITLE_FONT_SIZE := 20
const VICTORY_TITLE_FONT_SIZE := 36
const OUTCOME_TITLE_FONT_SIZE := 24
const OUTCOME_LOSS_COLOR := UIColors.OUTCOME_LOSS
const BACKDROP_COLOR := UIColors.OVERLAY_BACKDROP
const MAP_NODE_SIZE := Vector2(190, 150)
const CONTRACT_MAP_SIZE := Vector2(840, 470)
const CONTRACT_NODE_SIZE := Vector2(140, 96)
## Smaller than MAP_NODE_SIZE -- the Tavern map (P2:R7 story pass) makes room
## for TAVERN_ART_BOX_SIZE above it and sits lower in the panel, so its own
## node buttons shrink to match rather than crowding the reduced space.
const TAVERN_MAP_NODE_SIZE := Vector2(140, 100)
## Placeholder for future scene art above the Tavern's node row -- same
## "solid near-black fill, art to come later" convention as the combat
## window's own UIColors.PANEL_DEEP background.
const TAVERN_ART_BOX_SIZE := Vector2(760, 200)

## Story beat shown once, right after subclass selection and before the
## Tavern map ever appears (P2:R7 story pass, restoring a Phase 1 narrative
## element). Verbatim user-authored copy.
const INTRO_STORY_TEXT := "You find yourself in the shadow of the Dahm Henge Mountain. The highest peak, Peak Deeps is shrouded in darkness. You have heard tail of the secrets that lie there but know of none who had tried their hand at uncovering those hidden treasures and returned to tell the tale."

## The Tavern map's default flavor line, shown until a node is clicked to
## preview it (see _tavern_story_text()).
const TAVERN_INTRO_TEXT := "You find a nice respite from the rain in the dim light of a warm tavern. You do your best to mind your own business, but fate does not always abide."

## Per-encounter flavor line shown once its node is clicked (preview state,
## before Proceed commits the choice) -- keyed by Monster.display_name, the
## same key _tavern_story_text() already reads off BuildState.current_encounter().
const TAVERN_ENCOUNTER_FLAVOR_TEXT := {
	"Mouthy Drunk": "A red-faced patron decides your quiet corner is somehow his business.",
	"Drunk Buddy": "Leaping to his fallen companion's aid, another drunk patron wants to try his hand.",
	"Tavern Bouncer": "The burley bouncer grabs you to politely show you the door.",
	"Hired Goon": "A mysterious and sinister figure in the corner takes notice. His large bodyguard steps over to have a word with you.",
}

## Shown on the map when returning to it after winning that encounter --
## i.e. while choosing the *next* encounter, before its own node is previewed
## (see _tavern_pre_choice_story_text()). Keyed the same way as
## TAVERN_ENCOUNTER_FLAVOR_TEXT. Reflects the new state of the story rather
## than replaying TAVERN_INTRO_TEXT a second time.
const TAVERN_VICTORY_TEXT := {
	"Mouthy Drunk": "You easily dispatch him with a few well-placed strikes. He falls into a heap on the floor. However, this has caused quite the commotion.",
	"Drunk Buddy": "He lands with a thud atop the fallen body of his companion, but now the tavern is abuzz with action. You have made your pressence known; however you are not sure that was the best idea.",
	"Tavern Bouncer": "The night is cold and the fire warm, so you not-so politely decline his invitation. The rest of the patrons have scattered. Now you might get some peace and quite.",
	"Hired Goon": "Being in no mood for this, you \"pursuede\" the large gentlemen to joins the gorwing pile of bodies.",
}

## Ghit Gudd's introduction sequence, driven by the Contract Window
## (P2:R7 story pass) -- replaces the old single-click "Map"-styled Contract
## Offer overlay with a multi-step conversation, restoring a Phase 1-style
## narrative beat around accepting The Gilded Serpent contract. Verbatim
## user-authored copy (including its typos/inconsistent spelling of the
## broker's name -- not this codebase's to silently correct).
const CONTRACT_GREETING_TEXT := "Calm my friend. My name is Ghit Gudd. I am just a humble local... businessman. You are quite handy. You dispatched one of my best with such ease. I am always looking for useful individuals like yourself. How would you like to make a little coin?"
const CONTRACT_PITCH_TEXT := "I often have need for travelers of your ilk. Some of my rival competition needs to be reminded of the rules of free market capitalism. If you ... take care of them for me, I will pay you handsomely."
## Shown in the secondary-subclass overlay's body while it's reached via this
## contract sequence (see _build_secondary_subclass_overlay()).
const CONTRACT_SUBCLASS_PROMPT_TEXT := "This type of work may require a little extra skill."
## The Contract Window's post-subclass-choice step -- a single option today,
## but user-stated to grow into a real multi-contract hub later, hence a
## dedicated options row (_contract_options_box) rather than a single fixed
## button.
const CONTRACT_CHOICE_PROMPT_TEXT := "Choose a contract to pursue."
const CONTRACT_VYRA_NAME := "Vyra, the Leader of the Gilded Fang"
const CONTRACT_VYRA_DETAIL_TEXT := "Vyra is the leader of a rival gang. Ghet wants you to take her out so he can expand his business. She is hold up in her hideout at the edge of town. Ghet tells you that there are two ways in: through the front door and through the back door."
## The real route node backing the Vyra contract card -- read for its
## authored gold reward (see _contract_choice_reward_text()).
const VYRA_ROUTE_NODE_ID := "route.gilded_serpent.vyra"

const CONTRACT_LINE_COLOR := UIColors.STRUCTURE_LINE
const CONTRACT_LINE_THICKNESS := 5.0
## Map/contract-route/secondary-tree buttons carry dense multi-line data
## text (stats, difficulty, reward tags) rather than a short action label,
## so they stay on the VT323 body/data font instead of the theme's default
## Press Start 2P button font -- Press Start 2P's width would clip or
## badly overflow these fixed-size, multi-line buttons (P2:R7:T2 Phase 2
## legibility pass).
const DATA_BUTTON_FONT := preload("res://assets/fonts/VT323-Regular.ttf")

# -- Combat playback tuning (user-requested combat-playback addition,
# 2026-07-19). Every knob for the first-draft adjustment round lives here:
# playback speeds, HP-bar tween snappiness, and the comic-book skill-popup
# font sizes/colors/motion. The playback timeline itself is driven by
# CombatPlayback (scripts/ui/combat_playback.gd); these constants only shape
# how each fired event LOOKS. --
## Selectable playback speed multipliers, in button order. First entry is
## the default every playback starts at.
const PLAYBACK_SPEED_OPTIONS: Array[float] = [1.0, 2.0, 4.0]
## HP-bar tween duration for a direct cast hit -- short and punchy so each
## hit reads as a discrete chunk, not a smooth drain.
const PLAYBACK_HP_TWEEN_SEC := 0.15
## HP-bar tween duration for a poison tick -- slightly softer than a hit.
const PLAYBACK_TICK_HP_TWEEN_SEC := 0.3
## Comic-book popup font (Pirata One reads as a heavy action word; swap for
## MedievalSharp-Regular.ttf here if it lands better in real play).
const POPUP_FONT := preload("res://assets/fonts/PirataOne-Regular.ttf")
## Popup lifetime from spawn to fully faded/freed.
const POPUP_DURATION_SEC := 0.9
## How far a popup floats upward over its lifetime.
const POPUP_RISE_PX := 48.0
## Fade starts after this long, so the word is readable before it dissolves.
const POPUP_FADE_DELAY_SEC := 0.35
## Horizontal/vertical random jitter around the spawn point so rapid casts
## don't stack into one unreadable pile.
const POPUP_JITTER_X_PX := 90.0
const POPUP_JITTER_Y_PX := 24.0
## Vertical spawn anchor as a fraction of the combat panel's height.
const POPUP_BASE_Y_FRACTION := 0.55
## Popups never spawn above this y -- keeps the enemy HUD strip clear.
const POPUP_TOP_MARGIN_PX := 96.0
## Font sizes per popup kind.
const POPUP_FONT_SIZE := 26
const POPUP_CRIT_FONT_SIZE := 34
const POPUP_TICK_FONT_SIZE := 16
const POPUP_PROC_FONT_SIZE := 28
## Crit punch-scale: the label spawns at this scale and snaps to 1.0.
const POPUP_CRIT_PUNCH_SCALE := 1.35
const POPUP_CRIT_PUNCH_SEC := 0.12
## Simultaneous popup caps so long fights don't flood the panel -- poison
## ticks (1/second, low-stakes) get a tighter cap of their own.
const POPUP_MAX_ACTIVE := 10
const POPUP_MAX_TICK_ACTIVE := 3
## Popup colors per kind, all from UIColors: normal cast, crit (gold, per
## the agreed design), poison tick (low-key green), proc (flashy magic
## purple for Opportunity Strikes / Mithril Karambit triggers).
const POPUP_NORMAL_COLOR := UIColors.TEXT_NORMAL
const POPUP_CRIT_COLOR := UIColors.TEXT_GOLD
const POPUP_TICK_COLOR := UIColors.TEXT_POISON
const POPUP_PROC_COLOR := UIColors.TEXT_MAGIC
## Combat-playback adjustment round 1 (2026-07-19): a short pause between
## the timeline finishing and _reveal_fight_outcome() actually running, so
## the last spawned popup's float+fade (POPUP_DURATION_SEC 0.9s, fading
## after POPUP_FADE_DELAY_SEC 0.35s) has visibly finished before the
## outcome banner/recap pops in on top of it. Deliberately a little under
## the full 0.9s popup lifetime rather than a full match -- close enough
## that the last popup reads as "done" without adding a full extra second
## of dead air after every fight. Skipped entirely in instant_playback mode
## and when the reveal was reached via the Skip button (no popups spawn
## during a skip flush, so there is nothing left to outlast) -- see
## _on_playback_finished().
const PLAYBACK_OUTCOME_REVEAL_DELAY_SEC := 0.75
const TAVERN_BACKGROUND_TEXTURE := preload("res://assets/backgrounds/tavern_dummy_background_2.jpg")
const CONTRACT_BACKGROUND_TEXTURE := preload("res://assets/backgrounds/contract_exterior.jpg")
const TAVERN_BACKGROUND_TINT := Color(0, 0, 0, 0.42)
const SHOPKEEPER_TEXTURE := preload("res://assets/backgrounds/shop_dummy_background_2.jpg")
## Intro story art (the Dahm Henge Mountain overlook).
const STORY_BACKGROUND_TEXTURE := preload("res://assets/backgrounds/Ponesville.jpg")
## Tavern map's art box -- the exterior shot shown while choosing a Tavern
## encounter, replacing the earlier plain black placeholder.
const TAVERN_MAP_ART_TEXTURE := preload("res://assets/backgrounds/Tavern__Exterior.jpg")
## Ghit Gudd's portrait in the Contract Window.
const CONTRACT_PORTRAIT_TEXTURE := preload("res://assets/backgrounds/Ghit_Guud.jpg")

enum PopupKind { NORMAL, CRIT, POISON_TICK, PROC }

## Steps of Ghit Gudd's Contract Window sequence (see _build_contract_overlay()
## and _refresh_contract_overlay()).
enum ContractStep { GREETING, PITCH, CONTRACT_CHOICE, VYRA_DETAIL }

## P2:R7 second playtest-feedback pass (revises the first pass's rejected
## big comparison panel): hovering a shop/reward gear box shows the item's
## REGULAR small tooltip plus a second, identically tooltip-styled box
## labeled "Equipped" beside it -- two default-tooltip-sized boxes, no
## stat-diff text, no large card panels. Control's _make_custom_tooltip()
## is the only way to return an arbitrary Control for a tooltip, and that's
## a virtual method a plain Button.new() can't override -- this tiny
## subclass exists only to host the override, and delegates the actual
## Control-building back to combat_screen.gd via a Callable so the gear
## data reads stay in the main script instead of being duplicated here.
class GearCompareButton:
	extends Button
	var tooltip_builder: Callable

	func _make_custom_tooltip(_for_text: String) -> Object:
		if tooltip_builder.is_valid():
			return tooltip_builder.call()
		return null

var _status_label: Label
var _outcome_title_label: Label
var _seed_label: Label
var _phase_label: Label
var _lock_label: Label
var _next_action_label: Label
var _view_log_button: Button
var _fight_button_row: HBoxContainer
var _map_button: Button
var _retry_button: Button
var _restart_adventure_button: Button
var _combat_content: VBoxContainer
var _log_overlay: Control
var _log_label: RichTextLabel
var _map_overlay: Control
var _map_phase_label: Label
var _map_story_label: Label
var _map_art_box: Control
var _map_nodes_box: HBoxContainer
var _map_node_buttons: Array[Button] = []
var _map_close_button: Button
var _map_proceed_button: Button
var _map_manual_open: bool = false
## Which Tavern encounter's node was clicked to preview its flavor text
## (see _on_tavern_node_previewed()) -- -1 means no preview yet, so
## _tavern_story_text() falls back to TAVERN_INTRO_TEXT. Compared against
## BuildState.current_encounter_index rather than reset explicitly: moving to
## a new encounter naturally invalidates the old preview.
var _tavern_preview_index: int = -1
var _story_overlay: Control
var _story_label: Label
var _contract_overlay: Control
var _contract_body_label: Label
var _contract_options_box: HBoxContainer
var _contract_action_button: Button
var _contract_step: ContractStep = ContractStep.GREETING
var _victory_overlay: Control
var _victory_center: CenterContainer
var _victory_recap_label: Label
var _recap_label: Label
# -- Enemy status HUD (user-requested combat-HUD addition, 2026-07-18):
# compact enemy name/health-bar/status-row/info-line block anchored at the
# top of the black Combat panel, leaving the panel's center free for the
# future fight-action animations that black space is reserved for. --
var _enemy_hud: VBoxContainer
var _hud_name_label: Label
var _hud_hp_text_label: Label
var _hud_health_bar: ProgressBar
var _hud_status_row: HBoxContainer
var _hud_info_label: Label
## Combat resolves synchronously in one CombatResolver.resolve() call, so
## the HUD can't animate live values mid-fight. Instead it has exactly two
## display states: pre-fight (full HP / base armor / base resist / zero
## stacks, from the current Monster resource) and post-fight (the resolved
## outcome, derived from the stored CombatResult below). _hud_result is
## cleared at every new-fight setup transition, the same call sites that
## clear the T7 recap label. Not persisted across save/load, matching
## _log_label's existing behavior.
var _hud_result: CombatResolver.CombatResult = null
var _hud_result_monster: Monster = null
# -- Real-time combat playback (user-requested combat-playback addition,
# 2026-07-19). Combat still resolves synchronously and BuildState still
# mutates/autosaves immediately in _on_fight_pressed() -- ONLY the visual
# reveal (HUD post-fight state, victory banner, outcome presentation, recap)
# waits for the playback timeline to finish. instant_playback collapses the
# whole playback to the pre-playback behavior: it defaults to true under the
# headless display server so every existing headless test keeps observing
# post-fight UI state synchronously, while the real game window gets 1x
# playback; tests that exercise playback itself set it to false explicitly. --
var instant_playback: bool = DisplayServer.get_name() == "headless"
var _playback: CombatPlayback = null
var _playback_active := false
var _playback_skipping := false
var _playback_result: CombatResolver.CombatResult = null
var _playback_monster: Monster = null
## Live HUD values during playback, advanced per fired event by replaying
## the recorded CastEvent/TickEvent fields (no combat math reimplemented --
## the same event-replay reads the post-fight helpers below already use).
var _playback_hp := 0.0
var _playback_armor := 0
var _playback_resist := 0.0
var _playback_stacks := 0
var _playback_armor_reduced := 0
var _playback_controls: HBoxContainer
var _playback_time_label: Label
var _playback_speed_buttons: Array[Button] = []
var _playback_skip_button: Button
## Session-persistent playback speed (combat-playback adjustment round 2 +
## retry bug, 2026-07-19): the user asked for their last-chosen speed to
## carry forward into the next fight instead of always resetting to 1x.
## combat_screen.tscn is the persistent dashboard scene, not re-instantiated
## per fight (see game_root.gd -- _show_combat_screen() is only ever called
## once per run), so a plain instance var here already survives across every
## _on_fight_pressed() call for the rest of the session; no BuildState/
## SaveSystem plumbing needed for "carries into the next fight." Not
## persisted across a save/reload (the user asked for "into the next fight,"
## not "across sessions") -- a fresh session or a loaded save always starts
## back at PLAYBACK_SPEED_OPTIONS[0] (1x), which is judged an acceptable,
## easy-to-revisit default rather than adding save-file schema churn for a
## same-session-only ask.
var _last_playback_speed: float = PLAYBACK_SPEED_OPTIONS[0]
var _combat_window: PanelContainer
var _tavern_background: TextureRect
var _tavern_background_tint: ColorRect
var _popup_layer: Control
var _popup_rng := RandomNumberGenerator.new()
var _hp_bar_tween: Tween
var _active_popups := 0
var _active_tick_popups := 0
var _reward_label: Label
var _continue_button: Button
var _shop_overlay: Control
var _shop_gold_label: Label
var _shop_status_label: Label
var _shop_offers_box: GridContainer
var _shopkeeper_image: TextureRect
var _shop_reroll_button: Button
var _shop_leave_button: Button
var _reward_choice_overlay: Control
var _reward_choice_title: Label
var _reward_choice_options: HBoxContainer
var _secondary_subclass_overlay: Control
var _secondary_subclass_title: Label
var _secondary_subclass_body: Label
var _secondary_subclass_options: HBoxContainer
var _enemy_panel
var _confirm_dialog: ConfirmationDialog


func _ready() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margin.add_theme_constant_override(side, SCREEN_MARGIN)
	add_child(margin)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", PANEL_SEPARATION)
	margin.add_child(root_vbox)

	# -- Top bar: compact always-visible status (Phase/Build/Seed/Next) on
	# the left, Map/Save & Quit/Abandon Run buttons on the right.
	#
	# P2:R7 playtest-feedback pass (2026-07-18, revises T3): T3 originally
	# added a full-width status-bar row of its own, inserted between this
	# top bar and the three-column HUD body, with Target and Gold fields
	# plus a "Next" line on a second row underneath. Playtesting found that
	# row ate vertical space the loaded-state dashboard didn't have to
	# spare (see the overflow-bug notes in
	# docs/Phase_2_R7_Game_Like_UI_Pass.md), and that Target/Gold were
	# redundant with the enemy panel's own "Target:" line and the gear
	# panel's/shop overlay's own "Gold:" lines. The status concept is kept,
	# just consolidated directly into this top bar row instead of a
	# separate one -- Phase/Build/Seed on the left, the "Next" action line
	# expanding to fill the middle (clipped rather than wrapped, so a long
	# instruction can't push the buttons off the right edge), and the
	# existing Map/Save & Quit/Abandon Run buttons unchanged on the right.
	# Every field still reads BuildState only and refreshes off BuildState's
	# existing signals (build_changed/run_state_changed/lock_changed).
	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 20)

	_phase_label = Label.new()
	top_bar.add_child(_phase_label)

	_lock_label = Label.new()
	top_bar.add_child(_lock_label)

	_seed_label = Label.new()
	top_bar.add_child(_seed_label)

	_next_action_label = Label.new()
	_next_action_label.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	_next_action_label.clip_text = true
	_next_action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(_next_action_label)

	_map_button = Button.new()
	_map_button.text = "Map"
	_map_button.pressed.connect(_on_map_button_pressed)
	top_bar.add_child(_map_button)
	var save_quit_button := Button.new()
	save_quit_button.text = "Save & Quit"
	save_quit_button.pressed.connect(_on_save_and_quit_pressed)
	top_bar.add_child(save_quit_button)
	var menu_button := Button.new()
	menu_button.text = "Abandon Run"
	menu_button.pressed.connect(func(): _confirm_dialog.popup_centered())
	top_bar.add_child(menu_button)
	root_vbox.add_child(top_bar)

	# -- Three-column HUD body --
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", PANEL_SEPARATION)
	root_vbox.add_child(columns)

	# Left column: Character Stats over Talent Trees.
	var left_column := VBoxContainer.new()
	left_column.custom_minimum_size = Vector2(SIDE_COLUMN_WIDTH, 0)
	left_column.add_theme_constant_override("separation", PANEL_SEPARATION)
	columns.add_child(left_column)

	# Character Stats shrinks to its content; Subclass absorbs the leftover
	# column height (room for a second tree row once that's added).
	var character_stats_panel = CHARACTER_STATS_SCENE.instantiate()
	left_column.add_child(character_stats_panel)

	var talent_panel = TALENT_SCENE.instantiate()
	talent_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_column.add_child(talent_panel)

	# Center column: the combat window, then the two skill strips.
	var center_column := VBoxContainer.new()
	center_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_column.add_theme_constant_override("separation", PANEL_SEPARATION)
	columns.add_child(center_column)

	center_column.add_child(_build_combat_window())

	# Fight + Combat Log, centered directly under the combat window and above
	# Available Skills -- matches the Training Room's layout (P2:R7 playtest
	# feedback). The Fight button itself is enemy_panel.gd's (its disabled/
	# tooltip state machine lives there and stays there), just parented here
	# instead of inside the Enemy Stats card -- see below where _enemy_panel
	# is built.
	_fight_button_row = HBoxContainer.new()
	_fight_button_row.name = "FightButtonRow"
	_fight_button_row.add_theme_constant_override("separation", 8)
	_fight_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_fight_button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	center_column.add_child(_fight_button_row)

	center_column.add_child(AVAILABLE_SKILLS_SCENE.instantiate())
	center_column.add_child(SKILL_BUILD_SCENE.instantiate())

	# Right column: Enemy Stats over Gear.
	var right_column := VBoxContainer.new()
	right_column.custom_minimum_size = Vector2(SIDE_COLUMN_WIDTH, 0)
	right_column.add_theme_constant_override("separation", PANEL_SEPARATION)
	columns.add_child(right_column)

	# Enemy Stats shrinks to its content; Gear absorbs the leftover column
	# height.
	_enemy_panel = ENEMY_SCENE.instantiate()
	_enemy_panel.fight_pressed.connect(_on_fight_pressed)
	right_column.add_child(_enemy_panel)

	# enemy_panel.gd builds _fight_button but deliberately never adds it to
	# its own tree -- it lives in the centered row above instead.
	_fight_button_row.add_child(_enemy_panel._fight_button)
	_view_log_button = Button.new()
	_view_log_button.text = "View Combat Log"
	_view_log_button.disabled = true
	_view_log_button.pressed.connect(func(): _log_overlay.visible = true)
	_fight_button_row.add_child(_view_log_button)

	var gear_panel = GEAR_SCENE.instantiate()
	gear_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_column.add_child(gear_panel)

	_build_confirm_dialog()
	_build_victory_overlay()
	_build_shop_overlay()
	_build_reward_choice_overlay()
	_build_map_overlay()
	_build_story_overlay()
	_build_contract_overlay()
	_build_secondary_subclass_overlay()
	_build_log_overlay()
	BuildState.build_changed.connect(_on_build_state_changed)
	BuildState.run_state_changed.connect(_on_run_state_changed)
	BuildState.lock_changed.connect(_update_header_status)
	# A loaded save can resume directly into a terminal outcome (e.g. a
	# do-over still pending, or a contract already failed/won at save time).
	# _apply_outcome_presentation() no-ops for RunOutcome.NONE, so this is
	# safe for the normal fresh-run case too.
	_apply_outcome_presentation(BuildState.run_outcome)
	_update_header_status()
	_refresh_enemy_hud()
	# _process only runs while a combat playback is active.
	set_process(false)
	call_deferred("_show_initial_map_if_needed")


func _process(delta: float) -> void:
	if not _playback_active or _playback == null:
		return
	_playback.advance(delta)
	# advance() may finish the playback (nulling _playback) via its
	# finished callback -- only refresh the readout while it's still live.
	if _playback != null:
		_update_playback_time_label()


## The central combat window -- the future home of animated combat. For now
## it just shows a status line and a button to review the last fight's log.
func _build_combat_window() -> PanelContainer:
	var window := PanelContainer.new()
	window.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# P2:R7 playtest feedback (2026-07-18): the Combat panel is the future
	# home of animated combat, the same role the shop overlay's shopkeeper
	# box already reserves for future shopkeeper art -- give it the same
	# solid near-black fill (UIColors.PANEL_DEEP, reused rather than a new
	# constant) so both "reserved for future art" panels read consistently.
	var window_style := CardStyle.make_stylebox()
	window_style.bg_color = UIColors.PANEL_DEEP
	window.add_theme_stylebox_override("panel", window_style)
	_combat_window = window

	_tavern_background = TextureRect.new()
	_tavern_background.texture = TAVERN_BACKGROUND_TEXTURE
	_tavern_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tavern_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_tavern_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tavern_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tavern_background.visible = false
	window.add_child(_tavern_background)

	_tavern_background_tint = ColorRect.new()
	_tavern_background_tint.color = TAVERN_BACKGROUND_TINT
	_tavern_background_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tavern_background_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	_tavern_background_tint.visible = false
	window.add_child(_tavern_background_tint)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	window.add_child(content)
	_combat_content = content

	var title := Label.new()
	title.text = "Combat"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	content.add_child(title)

	# Enemy status HUD, pinned directly under the panel title so the black
	# center of the window stays clear for future fight-action animations.
	content.add_child(_build_enemy_hud())

	# Playback controls: elapsed/window readout plus 1x/2x/4x/Skip, visible
	# only while a fight's timeline is playing back. Sits directly under the
	# HUD so the black panel center stays the popup stage.
	content.add_child(_build_playback_controls())

	_outcome_title_label = Label.new()
	_outcome_title_label.visible = false
	_outcome_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_outcome_title_label.theme_type_variation = &"PanelHeader"
	_outcome_title_label.add_theme_font_size_override("font_size", OUTCOME_TITLE_FONT_SIZE)
	content.add_child(_outcome_title_label)

	_status_label = Label.new()
	_status_label.text = "Assemble your build and press FIGHT!"
	_status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	content.add_child(_status_label)

	# P2:R7:T7 loss recap -- the win path gets its own recap inside
	# _victory_overlay (built below); the loss path has no overlay of its
	# own (the outcome title/status/retry controls already occupy this same
	# _combat_content column), so this label carries the same recap lines
	# for a losing fight. Hidden until a losing fight actually resolves;
	# cleared at every "start planning the next fight" transition alongside
	# _status_label so a stale recap never lingers into an unrelated state.
	_recap_label = Label.new()
	_recap_label.visible = false
	_recap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_recap_label)

	# _view_log_button lives in _fight_button_row (centered under the combat
	# window, alongside Fight -- see the main build function), not here.

	_retry_button = Button.new()
	_retry_button.text = "Retry Encounter"
	_retry_button.visible = false
	_retry_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_retry_button.pressed.connect(_on_retry_pressed)
	content.add_child(_retry_button)

	_restart_adventure_button = Button.new()
	_restart_adventure_button.text = "Restart Adventure"
	_restart_adventure_button.visible = false
	_restart_adventure_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_restart_adventure_button.pressed.connect(func(): adventure_restart_pressed.emit())
	content.add_child(_restart_adventure_button)

	# Popup layer: a full-panel, mouse-transparent Control the comic-book
	# skill popups spawn into. Added after the content column so popups draw
	# over the black stage; a plain Control contributes no minimum size, so
	# the layout is unaffected.
	_popup_layer = Control.new()
	_popup_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	window.add_child(_popup_layer)

	return window


## The playback control strip: a compact "elapsed / window" time readout
## (the DPS-window pressure indicator -- on a loss the elapsed time visibly
## reaches the window cap while the HP bar still shows red) plus 1x/2x/4x
## speed buttons and a Skip-to-result button. Hidden outside playback.
func _build_playback_controls() -> HBoxContainer:
	_playback_controls = HBoxContainer.new()
	_playback_controls.visible = false
	_playback_controls.add_theme_constant_override("separation", 8)

	_playback_time_label = Label.new()
	_playback_time_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_playback_controls.add_child(_playback_time_label)

	_playback_speed_buttons = []
	for speed in PLAYBACK_SPEED_OPTIONS:
		var speed_button := Button.new()
		speed_button.text = "%dx" % int(speed)
		speed_button.pressed.connect(_set_playback_speed.bind(speed))
		_playback_speed_buttons.append(speed_button)
		_playback_controls.add_child(speed_button)

	_playback_skip_button = Button.new()
	_playback_skip_button.text = "Skip"
	_playback_skip_button.pressed.connect(_skip_playback)
	_playback_controls.add_child(_playback_skip_button)
	return _playback_controls


## The enemy status HUD (user-requested combat-HUD addition, 2026-07-18):
## a compact block at the top of the black Combat panel -- enemy name + HP
## text over a health bar, a small status-chip row (poison stacks / armor
## shredded / resist shredded, post-fight only), and a one-line info readout
## of current armor / poison resist. Intended to sit beside
## the enemy animations once those exist in a later phase; for now it's the
## HUD alone, anchored to the top edge so the panel center stays free.
## Presentation-only: every value comes from the current Monster resource
## (pre-fight) or the stored CombatResult (post-fight) -- no combat math is
## reimplemented here, per docs/Conventions.md's UI architecture principle.
func _build_enemy_hud() -> VBoxContainer:
	_enemy_hud = VBoxContainer.new()
	_enemy_hud.visible = false
	_enemy_hud.add_theme_constant_override("separation", 4)

	var name_row := HBoxContainer.new()
	_hud_name_label = Label.new()
	_hud_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_row.add_child(_hud_name_label)
	_hud_hp_text_label = Label.new()
	name_row.add_child(_hud_hp_text_label)
	_enemy_hud.add_child(name_row)

	_hud_health_bar = ProgressBar.new()
	_hud_health_bar.show_percentage = false
	_hud_health_bar.custom_minimum_size = Vector2(0, 14)
	var bar_background := StyleBoxFlat.new()
	bar_background.bg_color = UIColors.PANEL_DISABLED
	bar_background.border_color = UIColors.SLOT_BORDER
	bar_background.set_border_width_all(1)
	bar_background.set_corner_radius_all(4)
	_hud_health_bar.add_theme_stylebox_override("background", bar_background)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = UIColors.HEALTH_BAR_FILL
	bar_fill.set_corner_radius_all(4)
	_hud_health_bar.add_theme_stylebox_override("fill", bar_fill)
	_enemy_hud.add_child(_hud_health_bar)

	# Status bar: a deliberately minimal placeholder region that will grow
	# with future status mechanics. Empty pre-fight; carries small colored
	# chips post-fight for effects that actually occurred. Reserved height so
	# the HUD doesn't jump when chips appear.
	_hud_status_row = HBoxContainer.new()
	_hud_status_row.custom_minimum_size = Vector2(0, 16)
	_hud_status_row.add_theme_constant_override("separation", 10)
	_enemy_hud.add_child(_hud_status_row)

	_hud_info_label = Label.new()
	_enemy_hud.add_child(_hud_info_label)
	return _enemy_hud


## Single refresh for both HUD display states. Hidden whenever there is no
## enemy to show: the shop/reward overlays own the combat window in their
## states, and the pre-fight gating mirrors enemy_panel.gd::_refresh()'s
## own empty-state checks so the two enemy displays agree about when a
## target exists.
func _refresh_enemy_hud() -> void:
	if _enemy_hud == null:
		return
	# During a playback the timeline drives the HUD directly (per fired
	# event); signal-driven refreshes must not overwrite the animated values
	# or leak the already-resolved outcome early.
	if _playback_active:
		return
	if _shop_overlay != null and _shop_overlay.visible:
		_enemy_hud.visible = false
		return
	if _reward_choice_overlay != null and _reward_choice_overlay.visible:
		_enemy_hud.visible = false
		return
	if _hud_result != null and _hud_result_monster != null:
		_render_enemy_hud_post_fight()
		return
	var enemy := _hud_pre_fight_monster()
	if enemy == null:
		_enemy_hud.visible = false
		return
	_set_enemy_hud_display(enemy.display_name, float(enemy.hp), enemy.hp, enemy.armor, enemy.poison_resistance)
	_clear_hud_status_chips()
	_enemy_hud.visible = true


## The monster the HUD should show before a fight, or null when the current
## state has no fightable target -- the same gating enemy_panel.gd's
## _refresh() uses for its own empty state.
func _hud_pre_fight_monster() -> Monster:
	if BuildState.run_phase == BuildState.RunPhase.RUN_ENDED:
		return null
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		return null
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE and not BuildState.is_contract_fight_active():
		return null
	if BuildState.needs_tavern_map_choice():
		return null
	return BuildState.current_target_monster()


func _render_enemy_hud_post_fight() -> void:
	var monster := _hud_result_monster
	var result := _hud_result
	var remaining := _hud_post_fight_hp(result, monster)
	var final_armor := _hud_final_armor(result, monster)
	var final_resist := _hud_final_poison_resist(result, monster)
	var peak_stacks := _hud_peak_poison_stacks(result.tick_events)
	_set_enemy_hud_display(monster.display_name, remaining, monster.hp, final_armor, final_resist)
	_clear_hud_status_chips()
	if peak_stacks > 0:
		_add_hud_status_chip("Poison x%d" % peak_stacks, UIColors.TEXT_POISON)
	var armor_reduced := _hud_total_armor_reduction(result.cast_events)
	if armor_reduced > 0:
		_add_hud_status_chip("Armor -%d" % armor_reduced, UIColors.TEXT_WARNING)
	var resist_reduced := monster.poison_resistance - final_resist
	if resist_reduced > 0.001:
		_add_hud_status_chip("Resist -%.0f%%" % (resist_reduced * 100.0), UIColors.TEXT_WARNING)
	_enemy_hud.visible = true


func _set_enemy_hud_display(display_name: String, hp_remaining: float, hp_max: int, armor: int, poison_resistance: float) -> void:
	_hud_name_label.text = display_name
	# ceili() so a not-quite-dead enemy never displays a misleading "0" --
	# hp_remaining is only exactly 0.0 on a win (total damage >= HP).
	_hud_hp_text_label.text = "HP %d/%d" % [ceili(hp_remaining), hp_max]
	_hud_health_bar.max_value = hp_max
	_hud_health_bar.value = hp_remaining
	_hud_info_label.text = "Armor: %d | Resist: %.0f%%" % [armor, poison_resistance * 100.0]


func _clear_hud_status_chips() -> void:
	# remove_child() before queue_free() so the chip row's child list is
	# accurate immediately -- several HUD refreshes happen in the same frame
	# during a synchronous fight resolution, and stale queued-free chips
	# would otherwise coexist with the fresh ones until end of frame (the
	# same stale-child class of bug P2:R7:T4's _refresh() note documents).
	for child in _hud_status_row.get_children():
		_hud_status_row.remove_child(child)
		child.queue_free()


func _add_hud_status_chip(text: String, color: Color) -> void:
	var chip := Label.new()
	chip.text = text
	chip.add_theme_color_override("font_color", color)
	_hud_status_row.add_child(chip)


## Stores a resolved fight for the HUD's post-fight display state and
## refreshes immediately. Called from _on_fight_pressed() for both outcomes.
func _show_enemy_hud_post_fight(result: CombatResolver.CombatResult, monster: Monster) -> void:
	_hud_result = result
	_hud_result_monster = monster
	_refresh_enemy_hud()


## Drops the stored post-fight result so the HUD returns to its pre-fight
## display for whatever target the run state now points at. Called at every
## new-fight setup transition, the same call sites that clear the T7 recap.
func _reset_enemy_hud() -> void:
	_hud_result = null
	_hud_result_monster = null
	_refresh_enemy_hud()


## Enemy HP left after the resolved fight, clamped to [0, monster.hp] --
## exactly 0 on a win (CombatResolver sets is_win when total damage reaches
## HP), positive on a loss where the damage fell short.
func _hud_post_fight_hp(result: CombatResolver.CombatResult, monster: Monster) -> float:
	if monster == null or result == null:
		return 0.0
	return clampf(float(monster.hp) - result.total_damage, 0.0, float(monster.hp))


## Sum of every cast's applied armor reduction -- the same per-event field
## the T7 _armor_reduction_summary() reads.
func _hud_total_armor_reduction(cast_events: Array) -> int:
	var total := 0
	for event in cast_events:
		total += event.armor_reduction_applied
	return total


## The monster's armor at fight end: base armor minus every applied
## reduction, mirroring CombatResolver's own additive bookkeeping
## (current_armor -= reduction per event; not clamped, matching the
## resolver). Not new combat math -- just replaying the recorded events.
func _hud_final_armor(result: CombatResolver.CombatResult, monster: Monster) -> int:
	if monster == null or result == null:
		return 0
	return monster.armor - _hud_total_armor_reduction(result.cast_events)


## The monster's poison resistance at fight end: the base value with each
## recorded per-cast reduction applied multiplicatively, mirroring
## CombatResolver's `current_poison_resistance *= 1.0 - fraction`. Exact for
## every authored skill (each applies at most one
## PoisonResistanceReductionEffect per cast; CastEvent sums fractions within
## one cast, so a hypothetical multi-reduction cast would read slightly
## stronger here than the resolver applied).
func _hud_final_poison_resist(result: CombatResolver.CombatResult, monster: Monster) -> float:
	if monster == null or result == null:
		return 0.0
	var resist := monster.poison_resistance
	for event in result.cast_events:
		if event.poison_resistance_reduction_applied > 0.0:
			resist *= 1.0 - clampf(event.poison_resistance_reduction_applied, 0.0, 1.0)
	return resist


## Highest concurrent poison stack count observed across the fight's ticks
## -- the same stacks_remaining + 1 read the T7 _poison_summary_text() uses
## (TickEvent records the count after its own decrement).
func _hud_peak_poison_stacks(tick_events: Array) -> int:
	var peak := 0
	for tick in tick_events:
		if tick.damage <= 0.0:
			continue
		var stacks_before_tick: int = tick.stacks_remaining + 1
		if stacks_before_tick > peak:
			peak = stacks_before_tick
	return peak


## Victory banner: shown automatically after a winning fight, with a short
## recap (total damage, DPS, biggest hit, physical/poison damage split from
## CombatRecap). A true full-rect overlay added at the screen root -- same
## shape as _build_log_overlay() below -- not a normal flow child of
## _combat_content (bug fix: it used to be a CenterContainer added straight
## into _combat_content's VBoxContainer, so becoming visible immediately grew
## that VBox's required height by the whole reward panel's worth of content,
## pushing every later sibling down and, with no ScrollContainer anywhere in
## this screen, off the bottom of the viewport with no way to reach it).
## Deliberately no backdrop-click-to-dismiss (unlike _log_overlay's) -- the
## backdrop only blocks clicks from reaching the dashboard underneath;
## Claim Rewards is the only intended way past this screen.
func _build_victory_overlay() -> void:
	_victory_overlay = Control.new()
	_victory_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_victory_overlay.visible = false
	add_child(_victory_overlay)

	var backdrop := ColorRect.new()
	backdrop.color = BACKDROP_COLOR
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	_victory_overlay.add_child(backdrop)

	# Deliberately NOT full-rect (unlike every other overlay's center wrapper)
	# -- P2:R7 playtest feedback: centering over the whole screen put the
	# banner in an odd spot well below the combat window, since the side
	# columns run the full column height while the combat window is only the
	# top portion of the center column. _show_victory_banner() repositions
	# this to the combat window's own rect every time it's shown instead, so
	# the banner reads as "popping up over the fight," not the whole screen.
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_victory_center = center
	_victory_overlay.add_child(center)

	var stack := VBoxContainer.new()
	stack.name = "VictoryStack"
	stack.add_theme_constant_override("separation", 10)
	center.add_child(stack)

	var victory_panel := PanelContainer.new()
	victory_panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox(24))
	stack.add_child(victory_panel)

	var victory_content := VBoxContainer.new()
	victory_content.add_theme_constant_override("separation", 12)
	victory_panel.add_child(victory_content)

	var banner_title := Label.new()
	banner_title.text = "VICTORY!"
	banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_title.theme_type_variation = &"PanelHeader"
	banner_title.add_theme_font_size_override("font_size", VICTORY_TITLE_FONT_SIZE)
	banner_title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	victory_content.add_child(banner_title)

	_victory_recap_label = Label.new()
	victory_content.add_child(_victory_recap_label)

	var reward_panel := PanelContainer.new()
	reward_panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox(16))
	stack.add_child(reward_panel)

	var reward_content := VBoxContainer.new()
	reward_content.add_theme_constant_override("separation", 10)
	reward_panel.add_child(reward_content)

	var reward_title := Label.new()
	reward_title.text = "Rewards"
	reward_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_title.theme_type_variation = &"PanelHeader"
	reward_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	reward_content.add_child(reward_title)

	_reward_label = Label.new()
	_reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_content.add_child(_reward_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 12)

	var continue_button := Button.new()
	continue_button.text = "Claim Rewards"
	continue_button.pressed.connect(_on_continue_pressed)
	_continue_button = continue_button
	button_row.add_child(_continue_button)

	reward_content.add_child(button_row)


func _show_victory_banner(result: CombatResolver.CombatResult, monster: Monster) -> void:
	_status_label.visible = false
	_recap_label.visible = false
	_view_log_button.visible = true
	_retry_button.visible = false
	_restart_adventure_button.visible = false
	_victory_recap_label.text = "\n".join(_build_recap_lines(result, monster))
	_reward_label.text = _reward_text()
	_continue_button.disabled = BuildState.has_claimed_current_reward()
	_position_victory_center_over_combat_window()
	_victory_overlay.visible = true


## Recomputes _victory_center's rect from the combat window's current global
## rect -- done live (not just once at build time) so the banner still lands
## in the right place after any window resize between fights.
func _position_victory_center_over_combat_window() -> void:
	if _combat_window == null or _victory_center == null:
		return
	var window_rect := _combat_window.get_global_rect()
	var overlay_origin := _victory_overlay.get_global_rect().position
	_victory_center.position = window_rect.position - overlay_origin
	_victory_center.size = window_rect.size


## P2:R7:T7 -- compact, buildcraft-focused fight recap shared by the win
## banner (_victory_recap_label, inside _victory_overlay) and the loss path
## (_recap_label, shown inline in the main _combat_content column since a
## loss has no overlay of its own). Two always-present headline lines
## restate the actual result next to the target's required number (per the
## task's "needed X, did Y" framing), followed by a short list of secondary
## highlight lines; armor-reduction and poison lines are omitted entirely
## when that mechanic didn't come up in the fight, keeping a build with
## neither poison nor armor shred from reading a wall of "0"/"N/A" lines.
## Every field is read directly off the already-resolved CombatResult's
## CastEvent/TickEvent arrays -- no combat math is reimplemented here, per
## docs/Conventions.md's UI architecture principle.
func _build_recap_lines(result: CombatResolver.CombatResult, monster: Monster) -> PackedStringArray:
	var lines: PackedStringArray = []
	var required_dps := _recap_required_dps(monster, result.duration_ms)
	var required_damage := monster.hp if monster != null else 0
	lines.append("Total Damage: %.1f (needed %d)" % [result.total_damage, required_damage])
	lines.append("DPS: %.1f (needed %.1f)" % [result.dps, required_dps])
	lines.append(_biggest_hit_text(result.cast_events))
	lines.append(_damage_split_text(result.cast_events, result.tick_events))
	lines.append(_crit_count_text(result.cast_events))
	var armor_line := _armor_reduction_summary(result.cast_events)
	if armor_line != "":
		lines.append(armor_line)
	var poison_line := _poison_summary_text(result.tick_events)
	if poison_line != "":
		lines.append(poison_line)
	return lines


## HP / fight-window-seconds -- mirrors enemy_panel.gd's _required_dps_text()
## calculation (P2:R7:T5) so the recap's "needed" figure matches the one the
## player already saw before the fight. Kept as a small local mirror rather
## than a cross-panel call to _enemy_panel's underscore-prefixed helper,
## consistent with this file's existing convention of only calling panels'
## explicitly public methods (monster()/duration_ms()) across panel
## boundaries.
func _recap_required_dps(monster: Monster, duration_ms: int) -> float:
	if monster == null or duration_ms <= 0:
		return 0.0
	return float(monster.hp) / (float(duration_ms) / 1000.0)


## Largest single direct cast (poison ticks are damage-over-time, not a
## "hit"), naming the skill and whether that specific cast crit -- e.g.
## "Biggest Hit: Heavy Slash for 84.0 (crit)".
func _biggest_hit_text(cast_events: Array) -> String:
	var biggest := 0.0
	var biggest_skill := ""
	var biggest_crit := false
	for event in cast_events:
		if event.physical_damage > biggest:
			biggest = event.physical_damage
			biggest_skill = event.skill.display_name if event.skill != null else "Unknown"
			biggest_crit = event.is_crit
	if biggest_skill == "":
		return "Biggest Hit: none."
	var crit_note := " (crit)" if biggest_crit else ""
	return "Biggest Hit: %s for %.1f%s" % [biggest_skill, biggest, crit_note]


## Physical (direct cast damage) vs. poison (tick damage) split, both as raw
## amounts and as a share of total damage -- Rogue's Assassin/Thief/Shadow
## identity hinges on this split per the Phase 1 reference docs.
func _damage_split_text(cast_events: Array, tick_events: Array) -> String:
	var physical := 0.0
	for event in cast_events:
		physical += event.physical_damage
	var poison := 0.0
	for tick in tick_events:
		poison += tick.damage
	var total := physical + poison
	var physical_pct := (physical / total * 100.0) if total > 0.0 else 0.0
	var poison_pct := (poison / total * 100.0) if total > 0.0 else 0.0
	return "Physical: %.0f (%.0f%%) / Poison: %.0f (%.0f%%)" % [physical, physical_pct, poison, poison_pct]


## Counts crit occurrences across every direct cast (a triggered skill's own
## hit can also crit independently of its source cast).
func _crit_count_text(cast_events: Array) -> String:
	var count := 0
	for event in cast_events:
		if event.is_crit:
			count += 1
	return "Crits: %d" % count


## Only returns a non-empty line when at least one cast actually applied
## armor reduction (Rending Slash, Sunder, etc. via ArmorReductionEffect) --
## omitted entirely otherwise so a build with no armor shred doesn't show a
## dead "0" line.
func _armor_reduction_summary(cast_events: Array) -> String:
	var total := 0
	var casts := 0
	for event in cast_events:
		if event.armor_reduction_applied > 0:
			total += event.armor_reduction_applied
			casts += 1
	if casts == 0:
		return ""
	return "Armor reduced by %d (%d cast%s)" % [total, casts, "" if casts == 1 else "s"]


## Only returns a non-empty line when poison actually ticked this fight --
## omitted entirely for a build with no poison stacks applied. "Peak stacks"
## reads the stack count immediately before each tick consumed one (i.e.
## TickEvent.stacks_remaining + 1 for any tick that actually dealt damage),
## since TickEvent only records the count left *after* the tick.
func _poison_summary_text(tick_events: Array) -> String:
	var ticks := 0
	var peak_stacks := 0
	var poison_damage := 0.0
	for tick in tick_events:
		if tick.damage <= 0.0:
			continue
		ticks += 1
		poison_damage += tick.damage
		var stacks_before_tick: int = tick.stacks_remaining + 1
		if stacks_before_tick > peak_stacks:
			peak_stacks = stacks_before_tick
	if ticks == 0:
		return ""
	return "Poison: %d ticks, peak %d stacks, %.1f tick damage" % [ticks, peak_stacks, poison_damage]


func _reward_text() -> String:
	var reward := BuildState.current_reward()
	if reward == null:
		return "Rewards: none."
	var parts: PackedStringArray = []
	if reward.gold_amount > 0:
		parts.append("%dg" % reward.gold_amount)
	if reward.talent_points > 0:
		parts.append("%d talent point%s" % [
			reward.talent_points,
			"" if reward.talent_points == 1 else "s",
		])
	for gear in reward.fixed_gear_rewards:
		if gear != null:
			parts.append(gear.display_name)
	if reward.unlocks_shop:
		parts.append("shop access")
	if reward.gear_choice_rewards.size() > 0:
		var gear_names: PackedStringArray = []
		for gear in reward.gear_choice_rewards:
			if gear != null:
				gear_names.append(gear.display_name)
		if not gear_names.is_empty():
			parts.append("choose %s" % " or ".join(gear_names))
	if BuildState.is_contract_fight_active() and BuildState.current_route_node != null and BuildState.current_route_node.reward_summary != "":
		parts.append(BuildState.current_route_node.reward_summary)
	if parts.is_empty():
		return "Rewards: none."
	return "Rewards: %s." % ", ".join(parts)


## Dimmed backdrop (click to dismiss) + a centered card holding the actual
## log. Hidden until the first fight resolves.
func _build_log_overlay() -> void:
	_log_overlay = Control.new()
	_log_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_log_overlay.visible = false
	add_child(_log_overlay)

	var backdrop := Button.new()
	backdrop.flat = true
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	var backdrop_style := StyleBoxFlat.new()
	backdrop_style.bg_color = BACKDROP_COLOR
	for state in ["normal", "hover", "pressed", "focus"]:
		backdrop.add_theme_stylebox_override(state, backdrop_style)
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

	_log_label = RichTextLabel.new()
	_log_label.custom_minimum_size = Vector2(600, 400)
	content.add_child(_log_label)


## One-time story beat shown before the Tavern map ever appears on a fresh
## run (see _show_initial_map_if_needed()) -- a blocking full-rect overlay
## like Victory/Reward-Choice, since there's nothing behind it to interact
## with yet. The panel shows the Dahm Henge Mountain overlook (STORY_
## BACKGROUND_TEXTURE) behind the story text, tinted for readability the
## same way the combat window's own tavern background is.
func _build_story_overlay() -> void:
	_story_overlay = Control.new()
	_story_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_story_overlay.visible = false
	add_child(_story_overlay)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = BACKDROP_COLOR
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_story_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_story_overlay.add_child(center)

	var panel := PanelContainer.new()
	var style := CardStyle.make_stylebox(24)
	style.bg_color = UIColors.PANEL_DEEP
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var background := TextureRect.new()
	background.texture = STORY_BACKGROUND_TEXTURE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(background)

	var background_tint := ColorRect.new()
	background_tint.color = TAVERN_BACKGROUND_TINT
	background_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(background_tint)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(900, 420)
	content.add_theme_constant_override("separation", 24)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(content)

	_story_label = Label.new()
	_story_label.name = "StoryLabel"
	_story_label.text = INTRO_STORY_TEXT
	_story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_story_label.custom_minimum_size = Vector2(820, 0)
	content.add_child(_story_label)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(button_row)

	var proceed_button := Button.new()
	proceed_button.name = "StoryProceedButton"
	proceed_button.text = "Proceed"
	proceed_button.pressed.connect(_on_intro_story_proceed_pressed)
	button_row.add_child(proceed_button)


func _build_map_overlay() -> void:
	_map_overlay = Control.new()
	_map_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_overlay.visible = false
	add_child(_map_overlay)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = BACKDROP_COLOR
	_map_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_overlay.add_child(center)

	var panel := PanelContainer.new()
	var style := CardStyle.make_stylebox(18)
	style.set_border_width_all(3)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(940, 560)
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	var title := Label.new()
	title.text = "Map"
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	content.add_child(title)

	_map_phase_label = Label.new()
	_map_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_map_phase_label.add_theme_font_size_override("font_size", 24)
	content.add_child(_map_phase_label)

	_map_story_label = Label.new()
	_map_story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_map_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_map_story_label.custom_minimum_size = Vector2(760, 0)
	content.add_child(_map_story_label)

	# Tavern-only scene art (hidden for Contract Offer/Route, which never set
	# it visible) -- sized/positioned so the node row below reads as smaller
	# and pushed toward the bottom of the panel, per the story pass's mockup.
	_map_art_box = PanelContainer.new()
	_map_art_box.custom_minimum_size = TAVERN_ART_BOX_SIZE
	_map_art_box.visible = false
	var art_box_style := CardStyle.make_stylebox(8)
	art_box_style.bg_color = UIColors.PANEL_DEEP
	_map_art_box.add_theme_stylebox_override("panel", art_box_style)
	content.add_child(_map_art_box)

	var map_art_image := TextureRect.new()
	map_art_image.texture = TAVERN_MAP_ART_TEXTURE
	map_art_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	map_art_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	map_art_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_art_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	_map_art_box.add_child(map_art_image)

	var center_row := CenterContainer.new()
	center_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(center_row)

	_map_nodes_box = HBoxContainer.new()
	_map_nodes_box.add_theme_constant_override("separation", 0)
	center_row.add_child(_map_nodes_box)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	button_row.add_theme_constant_override("separation", 8)
	content.add_child(button_row)

	# Tavern-only (hidden otherwise): clicking a node just previews its
	# flavor text (_on_tavern_node_previewed()) -- Proceed is the actual
	# commit step, matching the story pass's two-step "read the flavor, then
	# commit" flow. Contract Offer/Route stay single-click, as before.
	_map_proceed_button = Button.new()
	_map_proceed_button.text = "Proceed"
	_map_proceed_button.visible = false
	_map_proceed_button.disabled = true
	_map_proceed_button.pressed.connect(_on_tavern_proceed_pressed)
	button_row.add_child(_map_proceed_button)

	_map_close_button = Button.new()
	_map_close_button.text = "Close Map"
	_map_close_button.pressed.connect(func(): _map_overlay.visible = false)
	button_row.add_child(_map_close_button)
	_refresh_map_overlay()


func _refresh_map_overlay() -> void:
	if _map_nodes_box == null:
		return
	if _map_close_button != null:
		_map_close_button.visible = _map_manual_open or not _map_requires_choice()
	for child in _map_nodes_box.get_children():
		child.queue_free()
	_map_node_buttons = []
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_refresh_contract_offer_map()
	elif BuildState.active_contract != null:
		_refresh_contract_route_map()
	else:
		_refresh_tavern_map()


func _refresh_tavern_map() -> void:
	_map_phase_label.text = "The Nooby Tavern"
	_map_story_label.text = _tavern_story_text()
	_map_art_box.visible = true
	# Always visible while a choice is pending (not just once previewed),
	# just disabled until then -- same "always there, grayed out until you
	# act" pattern as the Contract Window's own Proceed button, deliberately,
	# so this teaches the player what to expect there.
	_map_proceed_button.visible = BuildState.needs_tavern_map_choice()
	_map_proceed_button.disabled = _tavern_preview_index != BuildState.current_encounter_index
	for i in RunFlow.tavern_encounter_count():
		var button := _make_tavern_map_node_button(i)
		_map_node_buttons.append(button)
		_map_nodes_box.add_child(button)
		if i < RunFlow.tavern_encounter_count() - 1:
			_map_nodes_box.add_child(_make_map_connector())


func _refresh_contract_offer_map() -> void:
	var contract := BuildState.active_contract
	_map_phase_label.text = "Contract"
	_map_story_label.text = contract.offer_text if contract != null else "The trail out of the Tavern has gone cold."
	_map_art_box.visible = false
	_map_proceed_button.visible = false
	var button := Button.new()
	button.custom_minimum_size = MAP_NODE_SIZE
	button.text = contract.display_name if contract != null else "Unknown Contract"
	button.disabled = contract == null
	button.pressed.connect(_on_contract_map_pressed)
	_style_map_node(button, true)
	_map_node_buttons.append(button)
	_map_nodes_box.add_child(button)


func _refresh_contract_route_map() -> void:
	_map_phase_label.text = BuildState.active_contract.display_name if BuildState.active_contract != null else "Contract Route"
	_map_story_label.text = _contract_route_story_text()
	_map_art_box.visible = false
	_map_proceed_button.visible = false
	var schematic := _make_contract_route_schematic()
	if schematic != null:
		_map_nodes_box.add_child(schematic)
		return
	var node := BuildState.current_route_node
	var choices: Array[ContractRouteNode] = []
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE and node != null:
		choices = node.next_nodes
	if choices.is_empty():
		var button := Button.new()
		button.custom_minimum_size = MAP_NODE_SIZE
		button.text = _route_node_button_text(node) if node != null else "Route Pending"
		button.disabled = true
		_style_map_node(button, false)
		_map_node_buttons.append(button)
		_map_nodes_box.add_child(button)
		return
	for i in choices.size():
		var choice := choices[i]
		var button := Button.new()
		button.custom_minimum_size = MAP_NODE_SIZE
		button.text = _route_node_button_text(choice)
		button.tooltip_text = _route_node_tooltip(choice)
		button.disabled = BuildState.needs_secondary_subclass_choice()
		button.pressed.connect(_on_contract_route_node_pressed.bind(choice))
		_style_map_node(button, not button.disabled)
		_map_node_buttons.append(button)
		_map_nodes_box.add_child(button)
		if i < choices.size() - 1:
			_map_nodes_box.add_child(_make_map_connector())


func _make_contract_route_schematic() -> Control:
	var secondary := _gilded_serpent_secondary_node()
	if secondary == null or secondary.next_nodes.size() < 2:
		return null
	var door_guard := _find_route_node(secondary, "route.gilded_serpent.door_guard")
	var portly_cook := _find_route_node(secondary, "route.gilded_serpent.portly_cook")
	var sleeping := _find_route_node(secondary, "route.gilded_serpent.sleeping_henchman")
	var cloaked := _find_route_node(secondary, "route.gilded_serpent.cloaked_watchmen")
	var lazy := _find_route_node(secondary, "route.gilded_serpent.lazy_henchman")
	var patrol := _find_route_node(secondary, "route.gilded_serpent.patrolling_guard")
	var knives := _find_route_node(secondary, "route.gilded_serpent.knives")
	var vyra := _find_route_node(secondary, "route.gilded_serpent.vyra")
	if door_guard == null or portly_cook == null or sleeping == null or cloaked == null or lazy == null or patrol == null or knives == null or vyra == null:
		return null

	var canvas := Control.new()
	canvas.custom_minimum_size = CONTRACT_MAP_SIZE

	var positions := {
		door_guard: Vector2(20, 95),
		portly_cook: Vector2(20, 320),
		sleeping: Vector2(235, 20),
		cloaked: Vector2(235, 135),
		lazy: Vector2(235, 250),
		patrol: Vector2(235, 365),
		knives: Vector2(515, 190),
		vyra: Vector2(690, 190),
	}
	_add_contract_route_lines(canvas, positions, door_guard, portly_cook, sleeping, cloaked, lazy, patrol, knives, vyra)
	_add_contract_route_button(canvas, door_guard, positions[door_guard])
	_add_contract_route_button(canvas, portly_cook, positions[portly_cook])
	_add_contract_route_button(canvas, sleeping, positions[sleeping])
	_add_contract_route_button(canvas, cloaked, positions[cloaked])
	_add_contract_route_button(canvas, lazy, positions[lazy])
	_add_contract_route_button(canvas, patrol, positions[patrol])
	_add_contract_route_button(canvas, knives, positions[knives])
	_add_contract_route_button(canvas, vyra, positions[vyra])
	return canvas


func _add_contract_route_lines(canvas: Control, positions: Dictionary, door_guard: ContractRouteNode, portly_cook: ContractRouteNode, sleeping: ContractRouteNode, cloaked: ContractRouteNode, lazy: ContractRouteNode, patrol: ContractRouteNode, knives: ContractRouteNode, vyra: ContractRouteNode) -> void:
	var door_center := _contract_node_center(positions[door_guard])
	var cook_center := _contract_node_center(positions[portly_cook])
	var sleeping_center := _contract_node_center(positions[sleeping])
	var cloaked_center := _contract_node_center(positions[cloaked])
	var lazy_center := _contract_node_center(positions[lazy])
	var patrol_center := _contract_node_center(positions[patrol])
	var knives_center := _contract_node_center(positions[knives])
	var vyra_center := _contract_node_center(positions[vyra])
	var opener_branch_x := 195.0
	var convergence_x := 465.0

	_add_map_line(canvas, Vector2(door_center.x + CONTRACT_NODE_SIZE.x * 0.5, door_center.y), Vector2(opener_branch_x, door_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, sleeping_center.y), Vector2(opener_branch_x, cloaked_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, sleeping_center.y), Vector2(sleeping_center.x - CONTRACT_NODE_SIZE.x * 0.5, sleeping_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, cloaked_center.y), Vector2(cloaked_center.x - CONTRACT_NODE_SIZE.x * 0.5, cloaked_center.y))

	_add_map_line(canvas, Vector2(cook_center.x + CONTRACT_NODE_SIZE.x * 0.5, cook_center.y), Vector2(opener_branch_x, cook_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, lazy_center.y), Vector2(opener_branch_x, patrol_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, lazy_center.y), Vector2(lazy_center.x - CONTRACT_NODE_SIZE.x * 0.5, lazy_center.y))
	_add_map_line(canvas, Vector2(opener_branch_x, patrol_center.y), Vector2(patrol_center.x - CONTRACT_NODE_SIZE.x * 0.5, patrol_center.y))

	for center in [sleeping_center, cloaked_center, lazy_center, patrol_center]:
		_add_map_line(canvas, Vector2(center.x + CONTRACT_NODE_SIZE.x * 0.5, center.y), Vector2(convergence_x, center.y))
	_add_map_line(canvas, Vector2(convergence_x, sleeping_center.y), Vector2(convergence_x, patrol_center.y))
	_add_map_line(canvas, Vector2(convergence_x, knives_center.y), Vector2(knives_center.x - CONTRACT_NODE_SIZE.x * 0.5, knives_center.y))
	_add_map_line(canvas, Vector2(knives_center.x + CONTRACT_NODE_SIZE.x * 0.5, knives_center.y), Vector2(vyra_center.x - CONTRACT_NODE_SIZE.x * 0.5, vyra_center.y))


func _contract_node_center(top_left: Vector2) -> Vector2:
	return top_left + CONTRACT_NODE_SIZE * 0.5


func _add_map_line(canvas: Control, start: Vector2, end: Vector2) -> void:
	var line := ColorRect.new()
	line.color = CONTRACT_LINE_COLOR
	if absf(end.x - start.x) >= absf(end.y - start.y):
		line.position = Vector2(minf(start.x, end.x), start.y - CONTRACT_LINE_THICKNESS * 0.5)
		line.custom_minimum_size = Vector2(absf(end.x - start.x), CONTRACT_LINE_THICKNESS)
		line.size = line.custom_minimum_size
	else:
		line.position = Vector2(start.x - CONTRACT_LINE_THICKNESS * 0.5, minf(start.y, end.y))
		line.custom_minimum_size = Vector2(CONTRACT_LINE_THICKNESS, absf(end.y - start.y))
		line.size = line.custom_minimum_size
	canvas.add_child(line)


func _add_contract_route_button(canvas: Control, node: ContractRouteNode, position: Vector2) -> void:
	var button := Button.new()
	button.position = position
	button.custom_minimum_size = CONTRACT_NODE_SIZE
	button.size = CONTRACT_NODE_SIZE
	button.text = _contract_schematic_node_text(node)
	button.tooltip_text = _route_node_tooltip(node)
	var selectable := _route_node_is_selectable(node)
	button.disabled = not selectable
	if selectable:
		button.pressed.connect(_on_contract_route_node_pressed.bind(node))
	_style_map_node(button, selectable or BuildState.current_route_node == node)
	_map_node_buttons.append(button)
	canvas.add_child(button)


func _contract_schematic_node_text(node: ContractRouteNode) -> String:
	var lines: PackedStringArray = []
	lines.append(node.display_name)
	for reward_line in _contract_schematic_reward_lines(node):
		lines.append(reward_line)
	return "\n".join(lines)


func _contract_schematic_reward_lines(node: ContractRouteNode) -> PackedStringArray:
	var lines: PackedStringArray = []
	if node == null or node.reward == null:
		return lines
	var reward_label := _contract_reward_display(node)
	if reward_label != "":
		lines.append(reward_label)
	return lines


func _contract_reward_display(node: ContractRouteNode) -> String:
	if node == null or node.reward == null:
		return ""
	if node.reward.gear_choice_rewards.size() > 0:
		return "%s Gear" % _tier_name_for_reward_gear(node.reward.gear_choice_rewards[0])
	if node.reward.generated_gear_choice_count > 0:
		return "%s Gear" % GearGenerator.TIER_NAMES[node.reward.generated_gear_tier]
	if node.reward_quality_label == "Contract Victory":
		return node.reward_quality_label
	return ""


func _tier_name_for_reward_gear(gear: GearItem) -> String:
	if gear == null:
		return "Gear"
	return GearGenerator.TIER_NAMES[gear.tier]


func _route_node_is_selectable(node: ContractRouteNode) -> bool:
	return (
		BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE
		and not BuildState.needs_secondary_subclass_choice()
		and BuildState.current_route_node != null
		and BuildState.current_route_node.next_nodes.has(node)
	)


func _gilded_serpent_secondary_node() -> ContractRouteNode:
	if BuildState.active_contract == null or BuildState.active_contract.offer_node == null:
		return null
	if BuildState.active_contract.offer_node.next_nodes.is_empty():
		return null
	return BuildState.active_contract.offer_node.next_nodes[0]


func _find_route_node(root_node: ContractRouteNode, id: String, visited: Array[String] = []) -> ContractRouteNode:
	if root_node == null or visited.has(root_node.id):
		return null
	if root_node.id == id:
		return root_node
	visited.append(root_node.id)
	for child in root_node.next_nodes:
		var found := _find_route_node(child, id, visited)
		if found != null:
			return found
	return null


func _make_tavern_map_node_button(index: int) -> Button:
	var current_index := BuildState.current_encounter_index
	var is_current := BuildState.is_tavern_planning() and index == current_index
	var is_selectable := is_current and BuildState.needs_tavern_map_choice()
	var is_revealed := index <= current_index
	# Deliberately NOT highlighted just for being the current/clickable node
	# (user-requested): the player has to actually click it -- previewing it
	# (_tavern_preview_index == index) or having already committed it
	# (needs_tavern_map_choice() false, e.g. reopening the map later via the
	# Map button to review a locked-in choice) is what earns the highlight.
	# This mirrors -- and is meant to teach the player toward -- the Contract
	# Window's own select-then-Proceed card behavior.
	var is_highlighted := is_current and (_tavern_preview_index == index or not BuildState.needs_tavern_map_choice())
	var encounter := RunFlow.load_encounter(index)
	var button := Button.new()
	button.custom_minimum_size = TAVERN_MAP_NODE_SIZE
	button.text = encounter.monster.display_name if is_revealed and encounter != null else "Unknown"
	button.disabled = not is_selectable
	button.pressed.connect(_on_tavern_node_previewed.bind(index))
	_style_map_node(button, is_highlighted)
	return button


func _make_map_connector() -> Control:
	var connector := ColorRect.new()
	connector.custom_minimum_size = Vector2(80, 6)
	connector.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	connector.color = UIColors.STRUCTURE_LINE_LIGHT
	return connector


func _style_map_node(button: Button, is_current: bool) -> void:
	var color := UIColors.MAP_NODE_CURRENT if is_current else UIColors.MAP_NODE_INACTIVE
	var border_color := CardStyle.ACCENT_COLOR if is_current else UIColors.STRUCTURE_LINE_LIGHT
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var style := StyleBoxFlat.new()
		style.bg_color = color
		style.border_color = border_color
		style.set_border_width_all(3)
		style.set_corner_radius_all(8)
		button.add_theme_stylebox_override(state, style)
		button.add_theme_color_override("font_color", UIColors.TEXT_NORMAL)
		button.add_theme_color_override("font_disabled_color", UIColors.TEXT_DISABLED)
	# Multi-line stat/reward data, not a short action label -- see
	# DATA_BUTTON_FONT's comment.
	button.add_theme_font_override("font", DATA_BUTTON_FONT)
	button.add_theme_font_size_override("font_size", 14)


## Before any node is (re-)previewed, _tavern_pre_choice_story_text() sets
## the scene; clicking the current node previews its
## TAVERN_ENCOUNTER_FLAVOR_TEXT without committing (see
## _on_tavern_node_previewed()); Proceed then commits it, after which this
## falls to the same "marked" line it always has.
func _tavern_story_text() -> String:
	var encounter := BuildState.current_encounter()
	if encounter == null:
		return "The Tavern is quiet for the moment."
	if BuildState.needs_tavern_map_choice():
		if _tavern_preview_index == BuildState.current_encounter_index:
			return TAVERN_ENCOUNTER_FLAVOR_TEXT.get(
				encounter.monster.display_name, "A stranger's business becomes yours."
			)
		return _tavern_pre_choice_story_text()
	return "%s is marked. Tune the build, lock in, and start the fight when ready." % encounter.monster.display_name


## The very first Tavern choice (nothing defeated yet) sets the scene with
## TAVERN_INTRO_TEXT; every later choice instead shows the encounter just
## defeated's TAVERN_VICTORY_TEXT, so returning to the map after a win
## reflects the new state of the story instead of replaying the intro.
func _tavern_pre_choice_story_text() -> String:
	if BuildState.current_encounter_index == 0:
		return TAVERN_INTRO_TEXT
	var previous_encounter := RunFlow.load_encounter(BuildState.current_encounter_index - 1)
	if previous_encounter == null or previous_encounter.monster == null:
		return TAVERN_INTRO_TEXT
	return TAVERN_VICTORY_TEXT.get(previous_encounter.monster.display_name, TAVERN_INTRO_TEXT)


## P2:R7:T6: when the player is choosing between exactly two branches, this
## appends a data-derived tradeoff sentence (see _route_tradeoff_text())
## naming the harder branch and comparing reward tier, so the choice isn't
## blind. Applies at every branch point, not only the opener choice -- the
## base line no longer says "first route" since this story text is reused
## for every later fork too (Door Guard's/Portly Cook's own next-node choice).
func _contract_route_story_text() -> String:
	var node := BuildState.current_route_node
	if node == null:
		return "The route has not been charted yet."
	if BuildState.needs_secondary_subclass_choice():
		return node.summary_text
	if BuildState.is_contract_fight_active():
		return "%s is marked. Tune the build, lock in, and start the fight when ready." % node.display_name
	var base := "Choose your next route into The Gilded Serpent. Enemy pressure and reward quality matter from here."
	if node.next_nodes.size() == 2:
		var tradeoff := _route_tradeoff_text(node.next_nodes[0], node.next_nodes[1])
		if tradeoff != "":
			return "%s %s" % [base, tradeoff]
	return base


## Relative pressure score for a route branch, used only to rank two
## branches against each other (not shown as an absolute number) --
## higher armor/poison resistance reads as a harder branch, from the same
## real Monster fields enemy_panel.gd's _build_pressure_text() (P2:R7:T5)
## already reads.
func _route_pressure_score(node: ContractRouteNode) -> float:
	if node == null or node.monster == null:
		return 0.0
	return float(node.monster.armor) + node.monster.poison_resistance * 200.0


## Reward tier rank for a route branch's reward, covering both the
## authored gear_choice_rewards path (Knives' Legendary pair) and the
## generated_gear_tier path every other route reward uses. Returns -1 when
## the node has no gear reward to rank (e.g. Vyra's gold-only reward).
func _route_reward_tier_rank(node: ContractRouteNode) -> int:
	if node == null or node.reward == null:
		return -1
	if node.reward.gear_choice_rewards.size() > 0:
		var best := -1
		for gear in node.reward.gear_choice_rewards:
			if gear != null:
				best = maxi(best, gear.tier)
		return best
	if node.reward.generated_gear_choice_count > 0:
		return node.reward.generated_gear_tier
	return -1


## Data-derived tradeoff sentence for a pair of route branches, comparing
## real Monster pressure and reward tier rather than authored per-node
## flavor text -- so a newly authored branch pair reads correctly with zero
## additional authoring, matching the same discipline as T5's
## _build_pressure_text(). Pure ContractRouteNode -> String, no BuildState
## writes.
func _route_tradeoff_text(node_a: ContractRouteNode, node_b: ContractRouteNode) -> String:
	if node_a == null or node_b == null:
		return ""
	var pressure_a := _route_pressure_score(node_a)
	var pressure_b := _route_pressure_score(node_b)
	var pressure_line: String
	if is_equal_approx(pressure_a, pressure_b):
		pressure_line = "%s and %s carry similar pressure" % [node_a.display_name, node_b.display_name]
	elif pressure_a > pressure_b:
		pressure_line = "%s is the harder branch" % node_a.display_name
	else:
		pressure_line = "%s is the harder branch" % node_b.display_name
	var tier_a := _route_reward_tier_rank(node_a)
	var tier_b := _route_reward_tier_rank(node_b)
	var tier_a_name: String = GearGenerator.TIER_NAMES[tier_a] if tier_a >= 0 else "no gear"
	var tier_b_name: String = GearGenerator.TIER_NAMES[tier_b] if tier_b >= 0 else "no gear"
	return "%s. %s reward: %s -- %s reward: %s." % [pressure_line, node_a.display_name, tier_a_name, node_b.display_name, tier_b_name]


func _route_node_button_text(node: ContractRouteNode) -> String:
	if node == null:
		return "Route Pending"
	var lines: PackedStringArray = []
	lines.append(node.display_name)
	if node.monster != null:
		lines.append("HP %d | Armor %d" % [node.monster.hp, node.monster.armor])
		lines.append("Poison %.0f%% | %.0fs" % [node.monster.poison_resistance * 100.0, node.duration_ms / 1000.0])
	if node.difficulty_label != "":
		lines.append(node.difficulty_label)
	if node.reward_quality_label != "":
		lines.append(node.reward_quality_label)
	return "\n".join(lines)


func _route_node_tooltip(node: ContractRouteNode) -> String:
	var parts: PackedStringArray = []
	parts.append(node.summary_text)
	if node.difficulty_label != "":
		parts.append("Difficulty: %s" % node.difficulty_label)
	var reward_label := _contract_reward_display(node)
	if reward_label != "":
		parts.append("Reward: %s" % reward_label)
	return "\n".join(parts)


## Resumes into whichever overlay a loaded save left mid-transition -- the
## intro story only ever gates the very first Tavern choice (encounter index
## 0; once proceeded past, tavern_map_choice_made or a higher
## current_encounter_index means that branch is never hit again, so no
## separate "already shown" flag is needed), and the three Contract-sequence
## checks below cover a save made mid-conversation, mid-subclass-choice, or
## between choosing the subclass and confirming Vyra's contract card --
## none of these steps persist their own "which screen was showing" state,
## so this reconstructs it from the BuildState fields that do persist.
func _show_initial_map_if_needed() -> void:
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_show_contract_overlay(ContractStep.GREETING)
		return
	if BuildState.needs_secondary_subclass_choice():
		_show_secondary_subclass_overlay()
		return
	if _is_awaiting_contract_choice():
		_show_contract_overlay(ContractStep.CONTRACT_CHOICE)
		return
	if not BuildState.needs_tavern_map_choice():
		return
	if BuildState.current_encounter_index == 0:
		_show_story_overlay()
	else:
		_show_map_overlay(false)


## True once the secondary tree is chosen but the player hasn't yet
## confirmed Vyra's contract card -- current_route_node only moves off the
## SUBCLASS_CHOICE node when a real route node is chosen, so sitting on it
## with the subclass choice already satisfied is exactly this in-between
## state.
func _is_awaiting_contract_choice() -> bool:
	var node := BuildState.current_route_node
	return (
		BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE
		and node != null
		and node.node_type == ContractRouteNode.NodeType.SUBCLASS_CHOICE
		and not BuildState.needs_secondary_subclass_choice()
	)


func _on_map_button_pressed() -> void:
	_show_map_overlay(true)


func _show_map_overlay(manual_open: bool = false) -> void:
	if _story_overlay != null:
		_story_overlay.visible = false
	_map_manual_open = manual_open
	_refresh_map_overlay()
	_map_overlay.visible = true


func _show_story_overlay() -> void:
	_story_overlay.visible = true


func _on_intro_story_proceed_pressed() -> void:
	_story_overlay.visible = false
	_show_map_overlay(false)


func _map_requires_choice() -> bool:
	return (
		BuildState.needs_tavern_map_choice()
		or BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER
		or BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE
	)


## Clicking a Tavern node only previews its flavor text (_tavern_story_text())
## and reveals the Proceed button -- it never commits the choice itself.
## Proceed (_on_tavern_proceed_pressed()) does what this function used to do
## unconditionally, restoring a two-step "read the flavor, then commit" flow.
func _on_tavern_node_previewed(index: int) -> void:
	if index != BuildState.current_encounter_index or not BuildState.needs_tavern_map_choice():
		return
	_tavern_preview_index = index
	_refresh_map_overlay()


func _on_tavern_proceed_pressed() -> void:
	if BuildState.choose_current_tavern_encounter():
		_tavern_preview_index = -1
		_map_overlay.visible = false
		_map_manual_open = false
		_status_label.visible = true
		_recap_label.visible = false
		_reset_enemy_hud()
		var encounter := BuildState.current_encounter()
		if encounter != null:
			_status_label.text = "Selected: %s. Adjust your build, lock in, then fight." % encounter.monster.display_name
		_autosave()


func _on_contract_map_pressed() -> void:
	if BuildState.accept_contract_offer():
		_map_overlay.visible = false
		_map_manual_open = false
		_show_secondary_subclass_overlay()
		_autosave()


func _on_contract_route_node_pressed(node: ContractRouteNode) -> void:
	if node == null or BuildState.needs_secondary_subclass_choice():
		return
	if BuildState.choose_contract_route_node(node):
		_map_overlay.visible = false
		_map_manual_open = false
		_status_label.visible = true
		_recap_label.visible = false
		_reset_enemy_hud()
		_status_label.text = "Selected route: %s. Adjust your build, lock in, then fight." % node.display_name
		_autosave()


## Same bug fix as _build_victory_overlay() above: this was a PanelContainer
## added straight into _combat_content's VBoxContainer flow, so opening the
## shop (a fixed 620x420 HBoxContainer's worth of content) grew that VBox's
## required height and pushed later siblings off the bottom of the viewport.
## Now a true full-rect root-level overlay, matching _build_map_overlay()'s
## already-correct shape.
func _build_shop_overlay() -> void:
	_shop_overlay = Control.new()
	_shop_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shop_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_overlay.visible = false
	add_child(_shop_overlay)

	# Unlike Victory/Reward-Choice, the shop is not a blocking modal: gear can
	# still be sold from the dashboard's Gear panel while it's open, so no
	# full-screen dimming/backdrop here -- only the card itself should catch
	# clicks, everything else on the dashboard stays lit and interactive.
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shop_overlay.add_child(center)

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
	_shop_reroll_button.pressed.connect(_on_shop_reroll_pressed)
	header.add_child(_shop_reroll_button)

	# P2:R7:T6: gold must be visible inside the shop overlay itself, not only
	# via the T3 header (the header stays on-screen during a shop round, but
	# this makes the afford-state readable without looking away from the
	# shop card).
	_shop_gold_label = Label.new()
	_shop_gold_label.add_theme_color_override("font_color", UIColors.TEXT_GOLD)
	shop_content.add_child(_shop_gold_label)

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
	_shop_leave_button.pressed.connect(_on_shop_continue_pressed)
	button_row.add_child(_shop_leave_button)


## Ghit Gudd's contract introduction (P2:R7 story pass) -- visually mirrors
## _build_shop_overlay()'s layout (a portrait box, CONTRACT_PORTRAIT_TEXTURE,
## beside the text/action content) since this is explicitly meant to grow
## into the same kind of hub the shop already is, just for choosing contracts
## instead of gear, per the user's stated plan. Unlike the shop, this is a
## blocking modal (full STOP-filter backdrop) like Victory/Reward-Choice --
## there's no dashboard interaction to leave open behind a conversation.
func _build_contract_overlay() -> void:
	_contract_overlay = Control.new()
	_contract_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_contract_overlay.visible = false
	add_child(_contract_overlay)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = BACKDROP_COLOR
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	_contract_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_contract_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	center.add_child(panel)

	var content := HBoxContainer.new()
	content.custom_minimum_size = Vector2(700, 420)
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)

	var portrait := PanelContainer.new()
	portrait.custom_minimum_size = Vector2(260, 0)
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var portrait_style := CardStyle.make_stylebox(8)
	portrait_style.bg_color = UIColors.PANEL_DEEP
	portrait.add_theme_stylebox_override("panel", portrait_style)
	content.add_child(portrait)

	var portrait_image := TextureRect.new()
	portrait_image.texture = CONTRACT_PORTRAIT_TEXTURE
	portrait_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	portrait_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	portrait.add_child(portrait_image)

	var contract_content := VBoxContainer.new()
	contract_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	contract_content.add_theme_constant_override("separation", 14)
	content.add_child(contract_content)

	var title := Label.new()
	title.text = "Contract"
	title.theme_type_variation = &"PanelHeader"
	title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	contract_content.add_child(title)

	_contract_body_label = Label.new()
	_contract_body_label.name = "ContractBodyLabel"
	_contract_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_contract_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	contract_content.add_child(_contract_body_label)

	# Empty/hidden except during ContractStep.CONTRACT_CHOICE -- one option
	# today (Vyra), but a row rather than a single fixed button since the
	# user's stated plan is for this step to grow into a real multi-contract
	# picker later.
	_contract_options_box = HBoxContainer.new()
	_contract_options_box.name = "ContractOptionsBox"
	_contract_options_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_contract_options_box.add_theme_constant_override("separation", 12)
	contract_content.add_child(_contract_options_box)

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_END
	contract_content.add_child(button_row)

	_contract_action_button = Button.new()
	_contract_action_button.name = "ContractActionButton"
	_contract_action_button.pressed.connect(_on_contract_action_pressed)
	button_row.add_child(_contract_action_button)


func _show_contract_overlay(step: ContractStep) -> void:
	_contract_step = step
	_refresh_contract_overlay()
	_contract_overlay.visible = true


## Drives the Contract Window through Ghit Gudd's introduction -- see the
## CONTRACT_* text constants near the top of this file for the exact copy at
## each step.
func _refresh_contract_overlay() -> void:
	for child in _contract_options_box.get_children():
		child.queue_free()
	_contract_options_box.visible = false
	_contract_action_button.visible = true
	_contract_action_button.disabled = false
	match _contract_step:
		ContractStep.GREETING:
			_contract_body_label.text = CONTRACT_GREETING_TEXT
			_contract_action_button.text = "Hear Him Out"
		ContractStep.PITCH:
			_contract_body_label.text = CONTRACT_PITCH_TEXT
			_contract_action_button.text = "Accept Contract Work"
		ContractStep.CONTRACT_CHOICE:
			_contract_body_label.text = CONTRACT_CHOICE_PROMPT_TEXT
			_contract_action_button.text = "Proceed"
			_contract_action_button.disabled = true
			_contract_options_box.visible = true
			var vyra_node: ContractRouteNode = null
			if BuildState.active_contract != null:
				vyra_node = _find_route_node(BuildState.active_contract.offer_node, VYRA_ROUTE_NODE_ID)
			var choice_group := ButtonGroup.new()
			_contract_options_box.add_child(_build_contract_choice_card(CONTRACT_VYRA_NAME, vyra_node, choice_group))
		ContractStep.VYRA_DETAIL:
			_contract_body_label.text = CONTRACT_VYRA_DETAIL_TEXT
			_contract_action_button.text = "Accept"


## A larger, toggleable rectangle (not a plain button) naming the contract
## and its final-fight gold reward -- selecting one only enables the bottom
## Proceed button rather than committing immediately, since
## CONTRACT_CHOICE_PROMPT_TEXT's step is meant to grow into a real
## multi-contract picker later. `group` keeps future cards mutually
## exclusive; harmless with today's single card.
func _build_contract_choice_card(display_name: String, node: ContractRouteNode, group: ButtonGroup) -> Button:
	var card := Button.new()
	card.name = "VyraContractButton"
	card.custom_minimum_size = Vector2(340, 110)
	card.toggle_mode = true
	card.button_group = group
	card.text = "%s\n%s" % [display_name, _contract_choice_reward_text(node)]
	var normal_style := CardStyle.make_stylebox()
	var selected_style := CardStyle.make_stylebox()
	selected_style.border_color = CardStyle.ACCENT_COLOR
	selected_style.set_border_width_all(3)
	card.add_theme_stylebox_override("normal", normal_style)
	card.add_theme_stylebox_override("hover", normal_style)
	card.add_theme_stylebox_override("pressed", selected_style)
	card.add_theme_stylebox_override("hover_pressed", selected_style)
	card.add_theme_stylebox_override("focus", selected_style)
	card.toggled.connect(_on_contract_choice_toggled)
	return card


func _contract_choice_reward_text(node: ContractRouteNode) -> String:
	if node == null or node.reward == null:
		return "Reward: unknown"
	return "Reward: %dg" % node.reward.gold_amount


func _on_contract_choice_toggled(pressed: bool) -> void:
	_contract_action_button.disabled = not pressed


## The Contract Window's single action button means something different at
## each step: GREETING/PITCH/CONTRACT_CHOICE just advance the conversation;
## PITCH's press is also the real commit point
## (BuildState.accept_contract_offer()) before handing off to the existing
## secondary-subclass overlay; VYRA_DETAIL's press is what finally reveals
## the (unchanged) interactive route schematic.
func _on_contract_action_pressed() -> void:
	match _contract_step:
		ContractStep.GREETING:
			_contract_step = ContractStep.PITCH
			_refresh_contract_overlay()
		ContractStep.PITCH:
			if BuildState.accept_contract_offer():
				_contract_overlay.visible = false
				_show_secondary_subclass_overlay()
				_autosave()
		ContractStep.CONTRACT_CHOICE:
			_contract_step = ContractStep.VYRA_DETAIL
			_refresh_contract_overlay()
		ContractStep.VYRA_DETAIL:
			_contract_overlay.visible = false
			_status_label.visible = true
			_recap_label.visible = false
			_reset_enemy_hud()
			_status_label.text = "Contract accepted: %s. Choose your route." % CONTRACT_VYRA_NAME
			_show_map_overlay(false)
			_autosave()


## Same bug fix as _build_victory_overlay()/_build_shop_overlay() above --
## was a PanelContainer added straight into _combat_content's VBoxContainer
## flow. Now a true full-rect root-level overlay.
func _build_reward_choice_overlay() -> void:
	_reward_choice_overlay = Control.new()
	_reward_choice_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_reward_choice_overlay.visible = false
	add_child(_reward_choice_overlay)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = BACKDROP_COLOR
	_reward_choice_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_reward_choice_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox())
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(520, 240)
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)

	_reward_choice_title = Label.new()
	_reward_choice_title.text = "Choose Reward"
	_reward_choice_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reward_choice_title.theme_type_variation = &"PanelHeader"
	_reward_choice_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	_reward_choice_title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	content.add_child(_reward_choice_title)

	_reward_choice_options = HBoxContainer.new()
	_reward_choice_options.alignment = BoxContainer.ALIGNMENT_CENTER
	_reward_choice_options.add_theme_constant_override("separation", 12)
	content.add_child(_reward_choice_options)


func _build_secondary_subclass_overlay() -> void:
	_secondary_subclass_overlay = Control.new()
	_secondary_subclass_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_secondary_subclass_overlay.visible = false
	add_child(_secondary_subclass_overlay)

	var backdrop := ColorRect.new()
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.color = BACKDROP_COLOR
	_secondary_subclass_overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_secondary_subclass_overlay.add_child(center)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", CardStyle.make_stylebox(18))
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.custom_minimum_size = Vector2(640, 300)
	content.add_theme_constant_override("separation", 14)
	panel.add_child(content)

	_secondary_subclass_title = Label.new()
	_secondary_subclass_title.text = "Choose a Second Rogue Tree"
	_secondary_subclass_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_secondary_subclass_title.theme_type_variation = &"PanelHeader"
	_secondary_subclass_title.add_theme_font_size_override("font_size", CARD_TITLE_FONT_SIZE)
	_secondary_subclass_title.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
	content.add_child(_secondary_subclass_title)

	_secondary_subclass_body = Label.new()
	_secondary_subclass_body.text = CONTRACT_SUBCLASS_PROMPT_TEXT
	_secondary_subclass_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_secondary_subclass_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_secondary_subclass_body)

	_secondary_subclass_options = HBoxContainer.new()
	_secondary_subclass_options.alignment = BoxContainer.ALIGNMENT_CENTER
	_secondary_subclass_options.add_theme_constant_override("separation", 20)
	content.add_child(_secondary_subclass_options)


func _show_secondary_subclass_overlay() -> void:
	_refresh_secondary_subclass_options()
	_secondary_subclass_overlay.visible = true


func _refresh_secondary_subclass_options() -> void:
	for child in _secondary_subclass_options.get_children():
		child.queue_free()
	if BuildState.selected_class == null:
		return
	for tree in BuildState.selected_class.trees:
		if BuildState.selected_trees.has(tree):
			continue
		_secondary_subclass_options.add_child(_make_secondary_tree_card(tree))


## One selectable tree card in the secondary-tree chooser, built through the
## same shared CardStyle.make_selection_card() layout the primary subclass
## select screen uses (larger-font title, small intrinsic description, an
## action button) so the two choosers read as the same UI (P2:R7 second
## playtest-feedback pass, item 5 -- replaces the previous single dense
## multi-line Button per tree).
func _make_secondary_tree_card(tree: SubclassTree) -> PanelContainer:
	var choose_button := Button.new()
	choose_button.text = "Choose"
	choose_button.pressed.connect(_on_secondary_tree_pressed.bind(tree))
	return CardStyle.make_selection_card(
		tree.display_name,
		"Intrinsic: %s" % _intrinsic_description_for_tree(tree),
		choose_button
	)


func _intrinsic_description_for_tree(tree: SubclassTree) -> String:
	if tree.intrinsic_text != "":
		return tree.intrinsic_text
	var parts: PackedStringArray = []
	for skill in tree.unlocked_skills:
		parts.append("Unlocks %s" % skill.display_name)
	for modifier in tree.innate_modifiers:
		parts.append(StatModifierFormatter.format(modifier))
	for augment in tree.skill_augments:
		parts.append(_skill_augment_description_for_tree(augment))
	if parts.is_empty():
		return "None"
	return ", ".join(parts)


func _skill_augment_description_for_tree(augment: SkillAugment) -> String:
	if augment == null:
		return ""
	var target_names: PackedStringArray = []
	for target_id in augment.target_skill_ids:
		target_names.append(_skill_name_for_id(target_id))
	var effect_names: PackedStringArray = []
	for effect in augment.extra_effects:
		if effect is PoisonDamageEffect:
			var poison_effect: PoisonDamageEffect = effect
			effect_names.append("+%d poison stack%s" % [poison_effect.stacks_applied, "" if poison_effect.stacks_applied == 1 else "s"])
	if target_names.is_empty() or effect_names.is_empty():
		return "Enhances selected skills"
	return "%s gain %s" % [", ".join(target_names), ", ".join(effect_names)]


func _skill_name_for_id(skill_id: String) -> String:
	if BuildState.selected_class != null:
		for skill in BuildState.selected_class.base_skills:
			if skill.id == skill_id:
				return skill.display_name
		for tree in BuildState.selected_class.trees:
			for skill in tree.unlocked_skills:
				if skill.id == skill_id:
					return skill.display_name
			for talent in tree.talents:
				for skill in talent.unlocked_skills:
					if skill.id == skill_id:
						return skill.display_name
	return skill_id


func _show_shop_overlay() -> void:
	if _map_overlay != null:
		_map_overlay.visible = false
	_status_label.visible = false
	_recap_label.visible = false
	_view_log_button.visible = false
	_retry_button.visible = false
	_restart_adventure_button.visible = false
	_refresh_shop_overlay()
	_shop_overlay.visible = true
	# The shop owns the combat window in this state; _refresh_enemy_hud()
	# keeps the HUD hidden while the overlay is visible.
	_refresh_enemy_hud()


func _show_reward_choice_overlay() -> void:
	if _map_overlay != null:
		_map_overlay.visible = false
	_status_label.visible = false
	_recap_label.visible = false
	_view_log_button.visible = false
	_retry_button.visible = false
	_restart_adventure_button.visible = false
	for child in _reward_choice_options.get_children():
		child.queue_free()
	for gear in BuildState.pending_reward_choices:
		_reward_choice_options.add_child(_make_reward_choice_button(gear))
	_reward_choice_overlay.visible = true
	# Same overlay-owns-the-window rule as _show_shop_overlay().
	_refresh_enemy_hud()


func _make_reward_choice_button(gear: GearItem) -> Button:
	var item_box := GearCompareButton.new()
	item_box.custom_minimum_size = Vector2(112, 112)
	item_box.tooltip_text = _reward_choice_text(gear)
	item_box.tooltip_builder = func(): return _build_gear_compare_tooltip(_reward_choice_text(gear), _equipped_item_for_slot(gear.slot))
	item_box.pressed.connect(_on_reward_choice_pressed.bind(gear))
	_style_shop_item_box(item_box, gear)
	CardStyle.build_gear_box_content(item_box, gear)
	return item_box


## The reward-choice gear box's regular tooltip text: slot/name, tier,
## affixes, triggered skills, and the click hint. Rendered inside the first
## of _build_gear_compare_tooltip()'s two tooltip-styled boxes, and kept on
## Button.tooltip_text as the plain-text fallback/accessibility copy. The
## T6-era appended stat-diff comparison line was removed in the P2:R7
## second playtest-feedback pass -- the "Equipped" box beside this tooltip
## replaces it.
func _reward_choice_text(gear: GearItem) -> String:
	var lines := _gear_tooltip_lines(gear)
	lines.append("Click to choose.")
	return "\n".join(lines)


func _on_build_state_changed() -> void:
	if _shop_overlay != null and _shop_overlay.visible:
		_refresh_shop_overlay()
	_update_header_status()
	_refresh_enemy_hud()
	_update_combat_background()


func _on_run_state_changed() -> void:
	if _map_overlay != null:
		_refresh_map_overlay()
	_update_header_status()
	_refresh_enemy_hud()
	_update_combat_background()


func _refresh_shop_overlay() -> void:
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
	item_box.tooltip_builder = func(): return _build_gear_compare_tooltip(_shop_offer_text(offer), _equipped_item_for_slot(offer.slot))
	item_box.disabled = GearGenerator.price_for_tier(offer.tier) > BuildState.gold or not BuildState.can_store_shop_offer(offer)
	item_box.pressed.connect(_on_shop_buy_pressed.bind(offer))
	_style_shop_item_box(item_box, offer)
	CardStyle.build_gear_box_content(item_box, offer)
	return item_box


func _style_shop_item_box(button: Button, offer: GearItem) -> void:
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
		# Unaffordable/unstorable offers (Button.disabled == true) read as
		# visibly muted rather than full tier color, so "can't afford"
		# communicates itself without reading the tooltip.
		style.bg_color = color.darkened(0.55) if state == "disabled" else color
		style.border_color = UIColors.TEXT_DISABLED if state == "disabled" else UIColors.SLOT_BORDER
		style.set_border_width_all(2)
		style.set_corner_radius_all(6)
		button.add_theme_stylebox_override(state, style)


## The shop-offer gear box's regular tooltip text: slot/name, tier, affixes,
## the price, and an explicit afford/inventory-space/click hint (P2:R7:T6).
## Rendered inside the first of _build_gear_compare_tooltip()'s two
## tooltip-styled boxes, and kept on Button.tooltip_text as the plain-text
## fallback/accessibility copy. The T6-era appended stat-diff comparison
## line was removed in the P2:R7 second playtest-feedback pass -- the
## "Equipped" box beside this tooltip replaces it.
func _shop_offer_text(offer: GearItem) -> String:
	var lines := _gear_tooltip_lines(offer)
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


## The regular tooltip lines for one gear item -- slot/name, tier, affixes,
## and any triggered-skill effects. Shared by _shop_offer_text(),
## _reward_choice_text(), and _build_gear_compare_tooltip()'s "Equipped"
## box so the three can't drift apart.
func _gear_tooltip_lines(gear: GearItem) -> PackedStringArray:
	var lines: PackedStringArray = []
	lines.append("%s - %s" % [GearGenerator.SLOT_TAGS[gear.slot], gear.display_name])
	lines.append(GearGenerator.TIER_NAMES[gear.tier])
	for affix in gear.affixes:
		lines.append(StatModifierFormatter.format(affix))
	for trigger in gear.triggered_skill_effects:
		if trigger != null and trigger.skill != null:
			lines.append("%d%% chance to trigger %s" % [roundi(trigger.chance * 100.0), trigger.skill.display_name])
	return lines


## P2:R7 second playtest-feedback pass (replaces the first pass's rejected
## large side-by-side comparison panel): the on-hover visual for a
## shop/reward gear box is two SMALL boxes side by side, each styled
## identically to the default Godot tooltip (same TooltipPanel stylebox,
## same TooltipLabel font color, default font size, tight padding) -- the
## first carries the item's regular tooltip text unchanged, the second is
## headed "Equipped" and carries the equipped item's regular tooltip-style
## lines (or "Nothing equipped."). No stat-diff text anywhere. Returned
## from GearCompareButton's _make_custom_tooltip() override; Godot handles
## showing/hiding it like any other tooltip.
func _build_gear_compare_tooltip(item_text: String, equipped: GearItem) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.add_child(_make_tooltip_box("", item_text))
	var equipped_text := "\n".join(_gear_tooltip_lines(equipped)) if equipped != null else "Nothing equipped."
	row.add_child(_make_tooltip_box("Equipped", equipped_text))
	return row


## One compact box of _build_gear_compare_tooltip()'s pair, deliberately
## styled to be visually identical to a standard tooltip: the theme chain's
## own TooltipPanel stylebox and TooltipLabel font color, default font and
## size, no extra padding. `header`, when non-empty, renders as an
## accent-colored first line ("Equipped").
func _make_tooltip_box(header: String, body: String) -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", get_theme_stylebox("panel", "TooltipPanel"))
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 0)
	panel.add_child(vbox)

	if header != "":
		var header_label := Label.new()
		header_label.text = header
		header_label.add_theme_color_override("font_color", CardStyle.ACCENT_COLOR)
		vbox.add_child(header_label)

	var body_label := Label.new()
	body_label.text = body
	body_label.add_theme_color_override("font_color", get_theme_color("font_color", "TooltipLabel"))
	vbox.add_child(body_label)
	return panel


## Reads the currently equipped item for a gear slot. Mirrors
## BuildState._equipped_item_for_slot()'s private lookup (that helper is
## private to BuildState) -- used only to compare a shop/reward gear offer
## against what the player already has equipped in the same slot.
func _equipped_item_for_slot(slot: GearItem.SlotType) -> GearItem:
	match slot:
		GearItem.SlotType.WEAPON:
			return BuildState.equipped_weapon
		GearItem.SlotType.TRINKET:
			return BuildState.equipped_trinket
		GearItem.SlotType.CHARM:
			return BuildState.equipped_charm
	return null


func _build_confirm_dialog() -> void:
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.title = "Abandon Run"
	_confirm_dialog.dialog_text = "Are you sure you want to abandon this run? Any saved progress will be deleted."
	_confirm_dialog.confirmed.connect(_on_abandon_confirmed)
	add_child(_confirm_dialog)


func _on_abandon_confirmed() -> void:
	SaveSystem.delete_save()
	main_menu_pressed.emit()


func _on_save_and_quit_pressed() -> void:
	SaveSystem.save_run(BuildState)
	save_and_quit_pressed.emit()


## Autosave point (P2:R6:T6): called after each meaningful state
## transition (encounter/route choice, fight result, reward claim, shop
## action, retry) so a crash or unexpected quit loses at most the current
## in-progress build edit, not the whole run. Never called while
## BuildState.run_phase == FIGHTING -- BuildState.finish_fight() always
## resolves the fight synchronously before any of these handlers reach
## their autosave call, so there's no mid-fight state to snapshot.
func _autosave() -> void:
	SaveSystem.save_run(BuildState)


func _on_fight_pressed() -> void:
	if not BuildState.start_fight():
		return
	if _map_overlay != null:
		_map_overlay.visible = false
	var stats := BuildResolver.resolve_stats(
		BuildState.selected_class, BuildState.selected_trees, BuildState.selected_talents, BuildState.equipped_gear(), BuildState.gold
	)
	var rotation := BuildResolver.resolve_rotation(BuildState.rotation, BuildState.unlocked_skills())
	_apply_shadow_export_fallback(rotation)
	var monster: Monster = _enemy_panel.monster()
	var duration_ms: int = _enemy_panel.duration_ms()
	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, stats, monster, duration_ms, BuildState.current_combat_rng_seed())
	_log_label.text = CombatResultFormatter.format(result, monster)
	if not instant_playback:
		# Real-time playback path (user-requested combat-playback addition):
		# every state mutation below is IDENTICAL to instant mode and happens
		# right now -- finish_fight() advances the run state machine exactly
		# as before and the result is autosaved immediately, so killing the
		# process mid-playback resumes exactly like killing it post-fight.
		# Only the visual reveal (_reveal_fight_outcome) waits for the
		# timeline to finish or be skipped. _playback_active is raised BEFORE
		# finish_fight() so the run_state_changed refreshes it emits neither
		# overwrite the animated HUD nor leak the outcome into the header.
		_playback_active = true
		BuildState.finish_fight(result.is_win)
		_autosave()
		_begin_playback(result, monster)
		return
	# Stored before finish_fight() so the run_state_changed refresh it emits
	# already renders the HUD's post-fight state, not a pre-fight flicker.
	_show_enemy_hud_post_fight(result, monster)
	BuildState.finish_fight(result.is_win)
	_reveal_fight_outcome(result, monster)
	_autosave()


func _apply_shadow_export_fallback(rotation: Array[Skill]) -> void:
	if not _has_selected_tree("tree.shadow"):
		return
	for skill in rotation:
		if skill == null:
			continue
		if skill.id == "skill.stab" or skill.id == "skill.heavy_slash":
			skill.poison_stacks_applied = max(skill.poison_stacks_applied, 1)


func _has_selected_tree(tree_id: String) -> bool:
	for tree in BuildState.selected_trees:
		if tree != null and tree.id == tree_id:
			return true
	return false


## The full post-fight presentation reveal -- everything that used to happen
## inline the moment a fight resolved: status line, log access, and the
## win/loss outcome UI (victory banner or outcome title + retry/restart +
## inline recap). Instant mode calls this synchronously from
## _on_fight_pressed(); playback calls it once from _on_playback_finished().
func _reveal_fight_outcome(result: CombatResolver.CombatResult, monster: Monster) -> void:
	_status_label.text = "Fight complete: %s" % ("WIN" if result.is_win else "LOSS")
	_status_label.visible = true
	_view_log_button.visible = true
	_view_log_button.disabled = false
	if result.is_win:
		_outcome_title_label.visible = false
		_retry_button.visible = false
		_restart_adventure_button.visible = false
		_show_victory_banner(result, monster)
	else:
		_apply_outcome_presentation(BuildState.run_outcome)
		# P2:R7:T7 -- the loss path has no overlay of its own, so the same
		# recap lines the win banner shows go directly into _combat_content
		# underneath _apply_outcome_presentation()'s outcome title/status
		# text, right where _status_label already sits.
		_recap_label.text = "\n".join(_build_recap_lines(result, monster))
		_recap_label.visible = true


## Starts the real-time visual playback of an already-resolved fight. The
## HUD is reset to the monster's pre-fight values and then driven forward
## per event by _on_playback_event(); every outcome-revealing control is
## hidden/locked until _on_playback_finished().
func _begin_playback(result: CombatResolver.CombatResult, monster: Monster) -> void:
	_playback_active = true
	_playback_result = result
	_playback_monster = monster
	_playback_hp = float(monster.hp)
	_playback_armor = monster.armor
	_playback_resist = monster.poison_resistance
	_playback_stacks = 0
	_playback_armor_reduced = 0
	_active_popups = 0
	_active_tick_popups = 0
	_popup_rng.randomize()
	# Lock out everything that would reveal or act on the outcome early. The
	# build panels are already locked (build_locked stays true through the
	# fight), and the enemy panel's FIGHT! button is already disabled because
	# can_start_current_fight() is false in the post-fight run state.
	_status_label.visible = false
	_recap_label.visible = false
	# Stays visible (P2:R7 playtest feedback: it shouldn't disappear mid-fight)
	# but disabled -- _log_label.text already holds the new fight's full
	# result at this point (set synchronously before playback starts), so
	# leaving it clickable here would let the log spoil the outcome before
	# the animation finishes.
	_view_log_button.disabled = true
	_retry_button.visible = false
	_restart_adventure_button.visible = false
	_outcome_title_label.visible = false
	_victory_overlay.visible = false
	_map_button.disabled = true
	# Pre-fight HUD state, driven directly (signal refreshes are suspended
	# while _playback_active).
	_set_enemy_hud_display(monster.display_name, float(monster.hp), monster.hp, monster.armor, monster.poison_resistance)
	_clear_hud_status_chips()
	_enemy_hud.visible = true
	_playback = CombatPlayback.new()
	_playback.event_callback = _on_playback_event
	_playback.finished_callback = _on_playback_finished
	# Full window always plays on both a win and a loss (adjustment round 1,
	# 2026-07-19) -- a win used to truncate at the recorded kill moment; the
	# user wants the "overkill" feel of watching every remaining cast/tick
	# still land on the corpse. The HUD's HP bar clamps at 0 in
	# _on_playback_event() so it never dips below dead or un-dies.
	_playback.start(result)
	# Session-persistent speed (adjustment round 2, 2026-07-19): initialize
	# from the last speed the player chose instead of always defaulting back
	# to 1x -- see _last_playback_speed's declaration.
	_set_playback_speed(_last_playback_speed)
	_playback_controls.visible = true
	_update_playback_time_label()
	_update_header_status()
	set_process(true)


## Applies one fired timeline event to the live HUD: drains HP with a quick
## tween, replays the event's recorded armor/resist/stack changes (the same
## event-replay reads _hud_final_armor()/_hud_final_poison_resist() use --
## no combat math reimplemented), refreshes the info line and status chips,
## and spawns the matching comic-book popup.
func _on_playback_event(event: CombatPlayback.PlaybackEvent) -> void:
	if event.is_tick:
		_playback_stacks = event.tick.stacks_remaining
		if event.tick.damage > 0.0:
			_playback_hp = maxf(_playback_hp - event.tick.damage, 0.0)
			_apply_playback_hp(PLAYBACK_TICK_HP_TWEEN_SEC)
			# "Poison -N" (combat-playback adjustment round 2, 2026-07-19) --
			# matches the "SkillName -N" pattern the physical cast popups use
			# (added in adjustment round 1) for visual cohesion; font
			# size/color are unchanged, only the text gained a label.
			_spawn_skill_popup("Poison -%.0f" % event.tick.damage, PopupKind.POISON_TICK)
	else:
		var cast := event.cast
		if cast.physical_damage > 0.0:
			_playback_hp = maxf(_playback_hp - cast.physical_damage, 0.0)
		_playback_armor -= cast.armor_reduction_applied
		_playback_armor_reduced += cast.armor_reduction_applied
		if cast.poison_resistance_reduction_applied > 0.0:
			_playback_resist *= 1.0 - clampf(cast.poison_resistance_reduction_applied, 0.0, 1.0)
		_playback_stacks = mini(_playback_stacks + cast.poison_stacks_applied, CombatResolver.MAX_POISON_STACKS)
		_apply_playback_hp(PLAYBACK_HP_TWEEN_SEC)
		var skill_name := cast.skill.display_name if cast.skill != null else "Attack"
		# Damage number appended in the same "-N" style poison ticks already
		# use (combat-playback adjustment round 1, 2026-07-19) -- omitted
		# only when the cast dealt no physical damage at all (a pure
		# poison-stack/utility cast), so nothing renders "-0". The number is
		# the event's full physical_damage, which already includes any
		# triggered-skill damage folded into the same cast by the resolver
		# (CombatResolver merges a trigger's hit into the source event rather
		# than recording it separately) -- there is no per-trigger damage
		# breakdown to attribute to the proc popup below without touching
		# systems/, which is out of scope for this pass.
		var damage_suffix := ""
		if cast.physical_damage > 0.0:
			damage_suffix = " -%.0f" % cast.physical_damage
		if cast.is_crit:
			_spawn_skill_popup("%s%s!" % [skill_name, damage_suffix], PopupKind.CRIT)
		else:
			_spawn_skill_popup("%s%s" % [skill_name, damage_suffix], PopupKind.NORMAL)
		for triggered_name in cast.triggered_skill_names:
			_spawn_skill_popup(String(triggered_name), PopupKind.PROC)
	_update_playback_hud_readout()


## Updates the HP text immediately and tweens the bar to the new value --
## discrete per-hit chunks rather than one smooth constant drain. Skipping
## sets the value directly (no tween churn for dozens of events at once).
func _apply_playback_hp(tween_sec: float) -> void:
	_hud_hp_text_label.text = "HP %d/%d" % [ceili(_playback_hp), _playback_monster.hp]
	if _hp_bar_tween != null and _hp_bar_tween.is_valid():
		_hp_bar_tween.kill()
	if _playback_skipping:
		_hud_health_bar.value = _playback_hp
		return
	_hp_bar_tween = create_tween()
	_hp_bar_tween.tween_property(_hud_health_bar, "value", _playback_hp, tween_sec)


## Refreshes the HUD info line and status chips from the live playback
## values -- the real-time version of _render_enemy_hud_post_fight()'s
## chip logic, updating as each event lands.
func _update_playback_hud_readout() -> void:
	_hud_info_label.text = "Armor: %d | Resist: %.0f%%" % [_playback_armor, _playback_resist * 100.0]
	_clear_hud_status_chips()
	if _playback_stacks > 0:
		_add_hud_status_chip("Poison x%d" % _playback_stacks, UIColors.TEXT_POISON)
	if _playback_armor_reduced > 0:
		_add_hud_status_chip("Armor -%d" % _playback_armor_reduced, UIColors.TEXT_WARNING)
	var resist_reduced := _playback_monster.poison_resistance - _playback_resist
	if resist_reduced > 0.001:
		_add_hud_status_chip("Resist -%.0f%%" % (resist_reduced * 100.0), UIColors.TEXT_WARNING)


## Spawns one comic-book popup in the black combat panel: the text pops in,
## floats up, and fades out. Crits punch-scale in bigger and gold; poison
## ticks are small, green, and tightly capped; procs are magic purple.
func _spawn_skill_popup(text: String, kind: int) -> void:
	if _playback_skipping or _popup_layer == null:
		return
	if _active_popups >= POPUP_MAX_ACTIVE:
		return
	if kind == PopupKind.POISON_TICK and _active_tick_popups >= POPUP_MAX_TICK_ACTIVE:
		return
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", POPUP_FONT)
	var font_size := POPUP_FONT_SIZE
	var color := POPUP_NORMAL_COLOR
	match kind:
		PopupKind.CRIT:
			font_size = POPUP_CRIT_FONT_SIZE
			color = POPUP_CRIT_COLOR
		PopupKind.POISON_TICK:
			font_size = POPUP_TICK_FONT_SIZE
			color = POPUP_TICK_COLOR
		PopupKind.PROC:
			font_size = POPUP_PROC_FONT_SIZE
			color = POPUP_PROC_COLOR
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	_popup_layer.add_child(label)
	label.reset_size()
	label.pivot_offset = label.size * 0.5
	var spawn_x := _popup_layer.size.x * 0.5 - label.size.x * 0.5 + _popup_rng.randf_range(-POPUP_JITTER_X_PX, POPUP_JITTER_X_PX)
	var spawn_y := maxf(
		_popup_layer.size.y * POPUP_BASE_Y_FRACTION + _popup_rng.randf_range(-POPUP_JITTER_Y_PX, POPUP_JITTER_Y_PX),
		POPUP_TOP_MARGIN_PX
	)
	label.position = Vector2(spawn_x, spawn_y)
	_active_popups += 1
	if kind == PopupKind.POISON_TICK:
		_active_tick_popups += 1
	var tween := label.create_tween()
	tween.set_parallel(true)
	if kind == PopupKind.CRIT:
		label.scale = Vector2.ONE * POPUP_CRIT_PUNCH_SCALE
		tween.tween_property(label, "scale", Vector2.ONE, POPUP_CRIT_PUNCH_SEC)
	tween.tween_property(label, "position:y", spawn_y - POPUP_RISE_PX, POPUP_DURATION_SEC)
	tween.tween_property(label, "modulate:a", 0.0, POPUP_DURATION_SEC - POPUP_FADE_DELAY_SEC).set_delay(POPUP_FADE_DELAY_SEC)
	tween.finished.connect(_on_popup_finished.bind(label, kind))


func _on_popup_finished(label: Label, kind: int) -> void:
	_active_popups = maxi(_active_popups - 1, 0)
	if kind == PopupKind.POISON_TICK:
		_active_tick_popups = maxi(_active_tick_popups - 1, 0)
	label.queue_free()


## Sets the playback speed and disables the matching speed button so the
## active speed is visible at a glance. Also remembers the choice
## (_last_playback_speed, adjustment round 2, 2026-07-19) so the next
## fight's playback starts at this speed instead of always resetting to 1x
## -- called both from a real speed-button press and from _begin_playback()
## initializing a fresh playback from the remembered speed, so recording it
## here covers both without a second call site.
func _set_playback_speed(speed: float) -> void:
	_last_playback_speed = speed
	if _playback != null:
		_playback.speed = speed
	for i in _playback_speed_buttons.size():
		_playback_speed_buttons[i].disabled = is_equal_approx(PLAYBACK_SPEED_OPTIONS[i], speed)


## Fires every remaining timeline event instantly and reveals the outcome --
## the Skip button's action, and the path the playback-enabled headless
## checks drive. Popup spawning and per-hit tweening are suppressed while
## the burst of remaining events fires.
func _skip_playback() -> void:
	if not _playback_active or _playback == null:
		return
	_playback_skipping = true
	_playback.skip()
	_playback_skipping = false


func _update_playback_time_label() -> void:
	if _playback == null or _playback_time_label == null:
		return
	_playback_time_label.text = "%.1fs / %.0fs" % [_playback.elapsed_ms() / 1000.0, _playback.window_ms() / 1000.0]


## The end of a playback (natural or skipped): unlocks the controls the
## playback froze, snaps the HUD to the exact resolved post-fight state, and
## runs the deferred outcome reveal. CombatPlayback guarantees this fires
## exactly once per fight.
func _on_playback_finished() -> void:
	set_process(false)
	_update_playback_time_label()
	if _hp_bar_tween != null and _hp_bar_tween.is_valid():
		_hp_bar_tween.kill()
	var result := _playback_result
	var monster := _playback_monster
	_playback = null
	_playback_result = null
	_playback_monster = null
	_playback_active = false
	_playback_controls.visible = false
	_map_button.disabled = false
	# Exact final HUD state (bar value, chips, info line) from the stored
	# result -- the same rendering the instant path uses.
	_show_enemy_hud_post_fight(result, monster)
	# Brief pause so the last popup's float+fade finishes before the outcome
	# reveal pops in on top of it (adjustment round 1). Skipped when Skip was
	# pressed (_playback_skipping is still true here -- set before
	# CombatPlayback.skip() is called and cleared only after it returns, so
	# it reads true for the duration of this synchronously-triggered call --
	# no popups spawn during a skip flush, so nothing needs outlasting) and
	# in instant_playback mode (headless tests never reach this function at
	# all today, since _begin_playback() is only entered when playback is
	# non-instant, but the check is kept here too so this function stays
	# correct if that ever changes).
	if not instant_playback and not _playback_skipping:
		await get_tree().create_timer(PLAYBACK_OUTCOME_REVEAL_DELAY_SEC).timeout
	_reveal_fight_outcome(result, monster)
	_update_header_status()


func _on_continue_pressed() -> void:
	var claimed := BuildState.claim_current_reward()
	_victory_overlay.visible = false
	if claimed:
		_autosave()
	if claimed and BuildState.has_pending_reward_choice():
		_show_reward_choice_overlay()
		return
	# Skip the shop for the Hired Goon -> Contract Offer transition
	# (user-requested story pass): head straight into Ghit Gudd's Contract
	# Window instead. `and` short-circuits before open_shop_round() runs, so
	# it never mutates shop_round_pending/shop_offers for this one
	# transition -- the shop still opens normally everywhere else.
	if claimed and not BuildState.is_last_tavern_reward() and BuildState.open_shop_round():
		_status_label.text = "Spend gold or keep saving, then leave the shop."
		_show_shop_overlay()
		return
	_advance_after_reward_or_shop()


func _on_shop_buy_pressed(offer: GearItem) -> void:
	if BuildState.buy_shop_offer(offer):
		_shop_status_label.text = ""
		_autosave()
	elif not BuildState.can_store_shop_offer(offer):
		_shop_status_label.text = ""
	else:
		_shop_status_label.text = ""
	_refresh_shop_overlay()


func _on_shop_reroll_pressed() -> void:
	if BuildState.reroll_shop_offers():
		_shop_status_label.text = "New offers."
		_autosave()
	_refresh_shop_overlay()


func _on_shop_continue_pressed() -> void:
	BuildState.close_shop_round()
	_shop_overlay.visible = false
	_status_label.visible = true
	_view_log_button.visible = true
	_advance_after_reward_or_shop()


func _on_secondary_tree_pressed(tree: SubclassTree) -> void:
	if BuildState.choose_secondary_tree(tree):
		_secondary_subclass_overlay.visible = false
		_status_label.visible = true
		_recap_label.visible = false
		_reset_enemy_hud()
		_status_label.text = "Second tree chosen: %s." % tree.display_name
		_show_contract_overlay(ContractStep.CONTRACT_CHOICE)
		_autosave()


func _on_reward_choice_pressed(gear: GearItem) -> void:
	if BuildState.choose_pending_reward_gear(gear):
		_reward_choice_overlay.visible = false
		_autosave()
		if BuildState.open_shop_round():
			_status_label.text = "Spend gold or keep saving, then leave the shop."
			_show_shop_overlay()
			return
		_status_label.visible = true
		_view_log_button.visible = true
		_advance_after_reward_or_shop()


func _on_retry_pressed() -> void:
	if BuildState.retry_current_encounter():
		_outcome_title_label.visible = false
		_retry_button.visible = false
		_restart_adventure_button.visible = false
		_recap_label.visible = false
		_reset_enemy_hud()
		_status_label.text = "Retry ready. Adjust your build, lock in, then fight again."
		_autosave()


func _advance_after_reward_or_shop() -> void:
	# The finished fight is behind us -- drop its stored HUD result so the
	# HUD reads the next target (or hides in map/offer states).
	_reset_enemy_hud()
	var advanced := BuildState.continue_after_win()
	if BuildState.run_phase == BuildState.RunPhase.CONTRACT_OFFER:
		_show_contract_overlay(ContractStep.GREETING)
	elif BuildState.run_phase == BuildState.RunPhase.CONTRACT_ROUTE:
		_status_label.text = "Choose the next route step."
		_show_map_overlay(false)
	elif advanced:
		_status_label.text = "Choose the next opponent on the map."
		_show_map_overlay(false)
	else:
		_apply_outcome_presentation(BuildState.run_outcome)
	_autosave()


func _seed_label_text() -> String:
	return "Seed: %d" % BuildState.adventure_seed


## Refreshes every status field in the top bar from BuildState. Called from
## every signal the dashboard already listens to (build_changed,
## run_state_changed, lock_changed) so no call site needs to remember to
## refresh the header on top of its own work (P2:R7:T3). Target and Gold
## were dropped from this readout in the P2:R7 playtest-feedback pass --
## both were redundant with the enemy panel's own "Target:" line and the
## gear panel's/shop overlay's own "Gold:" lines.
func _update_header_status() -> void:
	# During a playback the run state has ALREADY advanced to the resolved
	# outcome (state mutates instantly; only presentation waits), so the
	# normal phase/next-action lookups would spoil the result mid-fight.
	# Freeze the header on "Fighting" until the reveal.
	if _playback_active:
		if _seed_label != null:
			_seed_label.text = _seed_label_text()
		if _phase_label != null:
			_phase_label.text = "Phase: Fighting"
		if _lock_label != null:
			_lock_label.text = "Build: %s" % _build_lock_text()
		if _next_action_label != null:
			_next_action_label.text = "Next: Watch the fight play out."
		_update_combat_background()
		return
	if _seed_label != null:
		_seed_label.text = _seed_label_text()
	if _phase_label != null:
		_phase_label.text = "Phase: %s" % _run_phase_text()
	if _lock_label != null:
		_lock_label.text = "Build: %s" % _build_lock_text()
	if _next_action_label != null:
		_next_action_label.text = "Next: %s" % _next_action_text()
	_update_combat_background()


func _update_combat_background() -> void:
	if _tavern_background == null or _tavern_background_tint == null:
		return
	var background_texture := _combat_background_texture()
	_tavern_background.texture = background_texture
	var show_background := background_texture != null
	_tavern_background.visible = show_background
	_tavern_background_tint.visible = show_background


func _combat_background_texture() -> Texture2D:
	match BuildState.run_phase:
		BuildState.RunPhase.PLANNING, BuildState.RunPhase.FIGHTING, BuildState.RunPhase.RESULT:
			return CONTRACT_BACKGROUND_TEXTURE if BuildState.active_contract != null else TAVERN_BACKGROUND_TEXTURE
	return null


## Pure BuildState -> label lookup for the current run phase, matching the
## priority order a player actually experiences: an open shop round or
## pending reward/subclass choice always takes precedence over the
## underlying RunPhase, since RunPhase itself doesn't change while those
## overlays are open (see BuildState.open_shop_round()/claim_current_reward()
## /choose_secondary_tree()).
func _run_phase_text() -> String:
	if BuildState.shop_round_pending:
		return "Shop"
	if BuildState.has_pending_reward_choice():
		return "Reward Choice"
	if BuildState.needs_secondary_subclass_choice():
		return "Subclass Choice"
	match BuildState.run_phase:
		BuildState.RunPhase.PLANNING:
			return "Contract Route - Planning" if BuildState.is_contract_fight_active() else "Tavern - Planning"
		BuildState.RunPhase.FIGHTING:
			return "Fighting"
		BuildState.RunPhase.RESULT:
			return "Victory - Claim Reward" if BuildState.last_fight_won else "Fight Result"
		BuildState.RunPhase.CONTRACT_OFFER:
			return "Contract Offer"
		BuildState.RunPhase.CONTRACT_ROUTE:
			return "Contract Route - Choose Path"
		BuildState.RunPhase.RUN_ENDED:
			if BuildState.run_outcome == BuildState.RunOutcome.CONTRACT_VICTORY or BuildState.run_outcome == BuildState.RunOutcome.FIGHT_WIN:
				return "Contract Victory"
			return "Run Failed"
	return "Unknown"


## Pure BuildState -> label lookup for the build lock state.
func _build_lock_text() -> String:
	return "Locked" if BuildState.build_locked else "Unlocked"


## Pure BuildState -> short instruction lookup: "what should the player do
## right now." Priority mirrors _run_phase_text() -- an open shop round or
## pending reward/subclass choice takes precedence over the underlying
## RunPhase for the same reason. Kept as a single small function so the next
## action is easy to reason about and test in isolation (P2:R7:T3), separate
## from _apply_outcome_presentation()'s richer loss/victory body text.
func _next_action_text() -> String:
	if BuildState.shop_round_pending:
		return "Buy gear or leave the shop."
	if BuildState.has_pending_reward_choice():
		return "Choose your reward."
	if BuildState.needs_secondary_subclass_choice():
		return "Choose your second subclass tree."
	match BuildState.run_phase:
		BuildState.RunPhase.RUN_ENDED:
			match BuildState.run_outcome:
				BuildState.RunOutcome.CONTRACT_FAILED, BuildState.RunOutcome.ADVENTURE_RESTART_REQUIRED:
					return "Restart your Adventure."
				BuildState.RunOutcome.CONTRACT_VICTORY, BuildState.RunOutcome.FIGHT_WIN:
					return "Start a new Adventure."
			return "Choose your next step."
		BuildState.RunPhase.RESULT:
			if BuildState.last_fight_won:
				return "Claim your reward."
			if BuildState.run_outcome == BuildState.RunOutcome.FIGHT_LOSS_RETRY:
				return "Adjust your build, then retry the fight."
			return "Review the fight result."
		BuildState.RunPhase.CONTRACT_OFFER:
			return "Hear out the Contract Window."
		BuildState.RunPhase.CONTRACT_ROUTE:
			return "Choose your next route on the map."
		BuildState.RunPhase.PLANNING:
			if BuildState.needs_tavern_map_choice():
				return "Choose your next opponent on the map."
			if not BuildState.build_locked:
				return "Lock your build, then fight."
			if BuildState.can_start_current_fight():
				return "Fight when ready."
			return "Finish your build to fight."
		BuildState.RunPhase.FIGHTING:
			return "Fighting..."
	return ""


## Central mapping from BuildState.RunOutcome to a headline, body text, and
## available actions, so every loss/do-over/restart/victory state is
## explicit instead of scattered inline status text (P2:R5:T8). Called both
## right after a losing fight and after claiming the final contract/Tavern
## reward, since a terminal win outcome is only known post-claim.
func _apply_outcome_presentation(outcome: int) -> void:
	_status_label.visible = true
	_restart_adventure_button.text = "Restart Adventure"
	match outcome:
		BuildState.RunOutcome.FIGHT_LOSS_RETRY:
			_set_outcome_title("DEFEATED", OUTCOME_LOSS_COLOR)
			# First-encounter revision (combat-playback adjustment round 2 +
			# retry bug, 2026-07-19; corrected 2026-07-19): the first Tavern
			# encounter gets unlimited retries, so "One retry available"
			# would be misleading for it specifically -- every other
			# encounter that reaches this outcome only ever gets it once
			# before a second loss becomes ADVENTURE_RESTART_REQUIRED, so the
			# original wording stays accurate for them.
			_status_label.text = (
				"You can retry as many times as you need: adjust your build, then retry."
				if BuildState.is_unlimited_retry_encounter()
				else "One retry available: adjust your build, then retry this encounter."
			)
			_retry_button.visible = true
			_retry_button.disabled = false
			_restart_adventure_button.visible = false
		BuildState.RunOutcome.CONTRACT_FAILED:
			_set_outcome_title("CONTRACT FAILED", OUTCOME_LOSS_COLOR)
			_status_label.text = "The route collapses here. Restart preserves Seed %d." % BuildState.adventure_seed
			_retry_button.visible = false
			_restart_adventure_button.visible = true
			_restart_adventure_button.disabled = false
		BuildState.RunOutcome.ADVENTURE_RESTART_REQUIRED:
			_set_outcome_title("ADVENTURE OVER", OUTCOME_LOSS_COLOR)
			_status_label.text = "No retries remain for this encounter. Restart preserves Seed %d." % BuildState.adventure_seed
			_retry_button.visible = false
			_restart_adventure_button.visible = true
			_restart_adventure_button.disabled = false
		BuildState.RunOutcome.CONTRACT_VICTORY:
			_set_outcome_title("CONTRACT COMPLETE", CardStyle.ACCENT_COLOR)
			_status_label.text = "Vyra is defeated. Seed %d is preserved if you start a new Adventure." % BuildState.adventure_seed
			_retry_button.visible = false
			_restart_adventure_button.visible = true
			_restart_adventure_button.disabled = false
			_restart_adventure_button.text = "Start New Adventure"
		BuildState.RunOutcome.FIGHT_WIN:
			# Only reached if the Tavern ladder ends without an active contract.
			_set_outcome_title("RUN COMPLETE", CardStyle.ACCENT_COLOR)
			_status_label.text = "Tavern sequence cleared. Seed %d is preserved if you start a new Adventure." % BuildState.adventure_seed
			_retry_button.visible = false
			_restart_adventure_button.visible = true
			_restart_adventure_button.disabled = false
			_restart_adventure_button.text = "Start New Adventure"
		_:
			_outcome_title_label.visible = false
			_retry_button.visible = false
			_restart_adventure_button.visible = false


func _set_outcome_title(text: String, color: Color) -> void:
	_outcome_title_label.text = text
	_outcome_title_label.add_theme_color_override("font_color", color)
	_outcome_title_label.visible = true
