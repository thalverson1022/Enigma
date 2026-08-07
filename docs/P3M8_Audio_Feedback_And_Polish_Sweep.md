# Phase 3 Milestone 8: Audio, Feedback, And Polish Sweep

## Purpose

Milestone 8 applies a consistency pass across interaction feedback,
presentation details, color-state language, and obvious rough edges before the
Phase 3 regression/export closeout.

This is the single tasking and status document for Milestone 8. It follows the
project hierarchy:

- Phase: 3, Project CrystalMaiden
- Milestone: 8, Audio, Feedback, And Polish Sweep
- Task: milestone-sized work item
- Step: implementation-sized action inside a task

## Status

Complete.

## Milestone Goal

Make the current Phase 3 build feel more coherent, responsive, and finished
without turning this milestone into a full production art or audio pass.

The milestone should tighten the experience players actually touch: buttons,
hover/focus/selected/disabled states, affordance colors, repeated panel
treatment, readable spacing, lightweight feedback beats, and optional
replaceable placeholder audio where it improves clarity.

## Design Direction

Milestone 8 is a polish sweep for the existing playable game. It should preserve
the current Rogue Adventure, Practice Room, combat flow, and balance behavior.

Prioritize:

- Consistent interactable states across major screens.
- A clearer, verified UI color palette and semantic color-state language.
- Better contrast and readability at the target resolution.
- Small repeated-panel and spacing fixes that make the game feel less rough.
- Feedback moments that clarify what happened or what the next action is.
- Lightweight placeholder audio only if approved and easy to replace.
- Focused verification based on the systems touched.

Avoid by default:

- New playable classes.
- New contracts, monsters, encounters, or route systems.
- Combat math or balance changes.
- A full fantasy UI skin or ornate frame production pass.
- Bespoke backgrounds, portraits, or complete art direction work.
- Large UI architecture refactors unless a narrow polish fix requires them.
- Deep Balance Lab interactivity.

## Current Baseline

Milestone 7 is complete locally. Balance Lab is now a run-and-read local app,
the test suite has a stronger coverage map, and focused mechanics diagnostics
have been hardened.

The current M8 closeout state:

- Placeholder audio was approved and implemented as replaceable ambience,
  music layers, SFX, and volume controls.
- Whole-game UI skin consistency stayed a light consistency pass.
- Full mock-up-quality fantasy UI production remains deferred to a later
  phase.
- Palette and interactable color-state cleanup was explicit and recorded in T1
  and T2 rather than hidden under generic polish.

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Plan and scope M8 | Complete | Created this plan, recorded the placeholder-audio approval question, and defined the polish sequence. |
| 1. Audit feedback states, palette, and interactable colors | Complete | Static palette/asset/state inventory recorded, current assignments table added, anomalies identified, and entity-unification work handed to T2. |
| 2. Clean up UI palette, color states, and repeated rough edges | Complete | Completed the palette/entity unification and code-only polish pass: Earth & Iron chrome, preserved rarity colors, shared bevel/depth treatment, map-node reward/icon language, title/seed controls, combat timer/playback HUD, Practice parity, Talent Trees presentation, and contract-route flavor text. |
| 3. Decide and implement replaceable placeholder audio if approved | Complete | Added replaceable ambience, music layering, volume controls, attack SFX, button SFX, shop transaction SFX, fades, and focused verification. |
| 4. Sweep combat and interaction feedback consistency | Complete | Added a shared blocked-action pulse helper and applied it to Practice Fight, map Proceed, shop reroll, and existing inventory-full reward/shop blocks. |
| 5. Check major states at target resolution | Complete | Captured and reviewed the major title, settings, selection, Adventure, shop, contract, and Practice states at 1600x900; added subtle Tavern fireplace and contract moon-flight background motion. |
| 6. Run focused verification | Complete | Ran the required M8-focused Godot checks plus adjacent UI/presentation checks; all exited 0. Balance Lab was skipped because M8 did not change combat math, build resolution, skill/talent/gear resources, enemy data, or balance-relevant data. |
| 7. Verify, document, and close Milestone 8 | Complete | Recorded final implementation summary, verification results, known caveats, deferrals, and handoff into M9 regression/export closeout. |

## Task Details

### P3:M8:T0 - Plan And Scope M8

Status: Complete.

Goal: establish a disciplined polish plan before implementation begins.

Steps:

- P3:M8:T0:S1 - Review the Phase 3 overview and current handoff.
- P3:M8:T0:S2 - Create the M8 tasking document.
- P3:M8:T0:S3 - Confirm whether placeholder audio is included in M8.
- P3:M8:T0:S4 - Identify the major screens and states to audit.
- P3:M8:T0:S5 - Record the focused verification plan.

Expected output:

- Current M8 tasking document.
- Explicit placeholder-audio decision.
- Explicit palette and interactable state audit path.

Notes:

- M8:T0 is complete as a planning/documentation task. No implementation checks
  were run because this task only created and updated documentation.
- Placeholder audio should not be added until approved.
- The palette pass should verify both aesthetics and function: color should
  consistently tell the player what is interactive, selected, blocked,
  dangerous, successful, affordable, unaffordable, rewarded, or next.

### P3:M8:T1 - Audit Feedback States, Palette, And Interactable Colors

Status: Complete.

Goal: identify inconsistent or unclear visual state language before changing
controls piecemeal.

Review these state types:

- Default interactable.
- Hover.
- Focus.
- Pressed.
- Selected.
- Disabled.
- Unavailable or locked.
- Affordable and unaffordable.
- Inventory full or blocked.
- Success, reward, and positive confirmation.
- Warning, danger, defeat, and destructive actions.
- Current next action.
- Combat-specific hit, crit, poison, proc, Shred, Decay, victory, and defeat
  feedback colors.

Review these surfaces:

- Title screen and main-menu actions.
- Adventure entry, class select, and subclass select.
- Tavern and contract choice flow.
- Route choice and route commit states.
- Combat screen, combat result overlays, and Combat Log access.
- Reward, shop, inventory, equip, unequip, sell, buy, reroll, and full-inventory
  states.
- Build screen, rotation strip, locked/ready states, and talent dependency
  states.
- Practice Room setup, gear editor, Legendary selection, playback, recap, and
  Combat Log surfaces.
- Local tools only if they share obvious CrystalMaiden UI language, without
  turning this milestone into a tool redesign.

Expected output:

- A short audit list of high-value state/color inconsistencies.
- Clear classification of must-fix, nice-to-fix, and defer.
- A candidate palette/state-language direction for implementation.

Audit result, 2026-08-05:

T1 is complete as the audit/enumeration task. The current codebase already has
a strong named palette foundation, but several player-facing states still use
local literal colors or local CSS palettes instead of named CrystalMaiden color
roles. T2 owns the entity-unification cleanup: every recurring UI asset/state
should map to a named role such as `window background`, `active button`,
`selected choice`, `unavailable choice`, `reward value`, or `combat poison`,
rather than to a bare color value.

Verified palette sources:

- `project/scripts/ui/ui_colors.gd` is the Godot source of truth for the
  warm playable-game palette. Current named roles include background, panel,
  highlighted panel, panel border/accent, normal/disabled/warning/magic/poison/
  gold text, modal backdrop, recessed panel, disabled panel, structure lines,
  map nodes, gear tiers, empty slots, health bar, outcome loss, and button
  normal/pressed fills.
- `project/assets/ui_theme.tres` is registered in `project/project.godot`
  through `gui/theme/custom` and carries the generated default Button, Label,
  RichTextLabel, Panel, PanelContainer, PanelHeader, and TitleHeading styles.
- `project/scripts/ui/card_style.gd` is the shared card, modal, selection-card,
  tooltip, gear-slot, and gear-tier styling helper.
- `tools/shop-lab/styles.css` and `tools/balance-lab/styles.css` use named CSS
  variables, but they are a separate cooler tool-app palette rather than the
  playable Godot palette. `tools/sprite-lab/styles.css` also uses a named but
  older editor-style palette.

Playable asset/state inventory:

- Fonts: `VT323` maps to body/data text, `PressStart2P` to action buttons,
  `MedievalSharp` to panel headers, and `PirataOne` to title/combat popup
  display text.
- Background art: title/class/subclass use `main_menu.jpg` with a local dark
  scrim; combat uses Tavern/contract backgrounds with local dark tints;
  Practice Room uses `Training_Room_background.jpg`; story/contract/shop/map
  surfaces use local image assets inside palette-styled panels. These assets
  are content art, not palette tokens, but their scrims/tints should map to
  named overlay/backdrop roles.
- UI icons: map, contract, fight, gold, talent point, build lock/unlock use
  palette-hosted labels/buttons around raster icons; disabled icon dimming is
  currently local literal modulation in build/skill panels.
- Combat HUD icons: health, armor, resistance, poison stack, Shred, and Decay
  are raster assets; adjacent chip text maps to `TEXT_POISON`,
  `TEXT_WARNING`, and `TEXT_MAGIC`, with health using `HEALTH_BAR_FILL`.
- Skill icons, subclass icons, gear icons, combat sprites, and item art are
  content assets. Their containers should map to named UI roles; the images
  themselves should not be recolored by the UI palette except for disabled or
  feedback modulation.

Verified recurring state-role mapping:

- `window background` / page base: `UIColors.BACKGROUND` via theme, plus
  screen-specific background art.
- `panel/card background`: `UIColors.PANEL` through `CardStyle.make_stylebox()`
  and the generated theme.
- `recessed/inset panel`: `UIColors.PANEL_DEEP` in combat windows, inventory
  trays, portrait boxes, story panels, and Practice Room combat view.
- `panel/card border` and `section/header accent`: `UIColors.PANEL_BORDER` via
  `UIColors.ACCENT` / `CardStyle.ACCENT_COLOR`.
- `active/default button`: `UIColors.BUTTON_FILL` in the generated theme.
- `button hover`: `UIColors.PANEL_HIGHLIGHT` in the generated theme.
- `button pressed` and some committed/locked buttons:
  `UIColors.BUTTON_FILL_PRESSED`.
- `button disabled` / flat disabled fill: `UIColors.PANEL_DISABLED` with
  `UIColors.TEXT_DISABLED`.
- `body text`: `UIColors.TEXT_NORMAL`.
- `disabled/help/empty text`: `UIColors.TEXT_DISABLED`.
- `warning, loss, blocked, remove, defeated marker`: mostly
  `UIColors.TEXT_WARNING` / `UIColors.OUTCOME_LOSS`.
- `reward/gold/value/remaining points`: mostly `UIColors.TEXT_GOLD`.
- `poison`: `UIColors.TEXT_POISON` in popups, HUD chips, stat deltas, and
  talent cost circles.
- `proc/magic/Decay`: `UIColors.TEXT_MAGIC` in popups, HUD chips, and
  playback proc state.
- `map current/selected node`: `UIColors.MAP_NODE_CURRENT`.
- `map inactive/locked node`: `UIColors.MAP_NODE_INACTIVE` or
  `UIColors.PANEL_DISABLED`.
- `structure lines/connectors`: `UIColors.STRUCTURE_LINE` and
  `UIColors.STRUCTURE_LINE_LIGHT`.
- `gear tier container`: `UIColors.TIER_BASIC`, `TIER_MASTER`, `TIER_CURSED`,
  and `TIER_LEGENDARY`, with disabled shop/reward boxes darkened locally.

Must-fix during T2 before entity unification can be called complete:

- Add named roles for recurring active/selected build states currently defined
  as literals in `skill_build_panel.gd`: active slot border, active slot
  background, cast progress fill, and proc progress fill. These are not just
  one-off art effects; they are part of the core build/combat UI state
  language.
- Add named roles for selected talent state and dependency-warning pulse,
  currently local literals in `talent_panel.gd`. Selected talent, selectable
  talent, unavailable talent, and dependency-blocked feedback should read as
  named palette roles.
- Add named roles for combat-log chart semantics currently local to
  `combat_log_inspector.gd`: cast, poison, proc, crit, contact, grid, line,
  chart text, chart value, chart background, and armor/mechanic pip. These are
  repeated combat explanation colors, not disposable debug colors.
- Add named roles for reusable scrims/tints and outline/shadow colors used by
  title/class/subclass screens, combat result dimming, training combat
  backdrop, price badges, popup outlines, and map markers. These can alias
  existing overlay/backdrop/deep-panel roles, but they should be named by role.
- Normalize disabled icon/content dimming into named roles instead of local
  `Color(0.68, 0.64, 0.58, 1.0)` and alpha-only conventions across available
  skills, build lock, and talent nodes.

Nice-to-fix during T2:

- Make hover/focus/pressed treatment for map nodes, talent nodes, skill buttons,
  gear boxes, and route choices visibly stateful where possible. Many custom
  controls currently apply the same stylebox to every Button state, relying on
  border width, pulses, disabled flags, or text rather than native hover/focus
  changes.
- Split `selected choice`, `current node`, and `committed/locked` into clearly
  named roles. Today several of those states reuse `MAP_NODE_CURRENT`,
  `BUTTON_FILL_PRESSED`, or local green/gold literals depending on the screen.
- Give shop-lab and balance-lab CSS variables CrystalMaiden role names if the
  tools are meant to share the game identity during M8. The variables are
  named, but they do not yet correspond cleanly to the playable Godot palette.

Defer:

- Recoloring content art itself: background paintings, combat sprites, skill
  icons, gear item art, subclass icons, logos, and placeholder character
  frames should remain content assets unless a later production-art pass
  replaces them.
- Full fantasy frame/skin production, ornate panel art, custom widget art, and
  broad tool-app redesign remain later-phase work.

Candidate role-language direction for T2:

- Keep `UIColors` as the single source of truth for the playable Godot UI.
- Preserve the existing warm UI roles, but extend them with semantic aliases
  before changing screen code: `ACTION_DEFAULT`, `ACTION_HOVER`,
  `ACTION_PRESSED`, `ACTION_DISABLED`, `CHOICE_AVAILABLE`,
  `CHOICE_SELECTED`, `CHOICE_COMMITTED`, `CHOICE_LOCKED`,
  `BUILD_ACTIVE`, `BUILD_PROGRESS`, `BUILD_PROC_PROGRESS`,
  `TALENT_SELECTED`, `TALENT_DEPENDENCY_PULSE`, `SCRIM_SOFT`,
  `SCRIM_STRONG`, `TEXT_OUTLINE`, `ICON_DISABLED`, `FEEDBACK_BLOCKED`,
  `COMBAT_CAST`, `COMBAT_CRIT`, `COMBAT_CONTACT`, `COMBAT_CHART_GRID`,
  `COMBAT_CHART_LINE`, and `COMBAT_CHART_TEXT`.
- T2 should first add/alias these named roles, then replace local literals only
  where they represent recurring state language. Truly transient generated
  effects, such as randomized coin sparkle modulation, can remain local if
  documented as effect-only.

### P3:M8:T2 - Clean Up UI Palette, Color States, And Repeated Rough Edges

Status: Complete.

Goal: implement the highest-value findings from the audit with narrow,
consistent UI changes.

Direction:

- Normalize semantic colors for common states rather than tuning each screen in
  isolation.
- Preserve existing Godot UI patterns and theme/stylebox conventions.
- Improve contrast where text or state meaning is weak.
- Keep disabled states visually distinct from unaffordable, unavailable,
  selected, and already-complete states.
- Make selected/committed/next-action states easy to distinguish.
- Fix obvious repeated-panel rough edges when they are small and local.

Current color assignments before cleanup:

| Element or state | Current source | Current assignment | Current value | T2 cleanup note |
|---|---|---|---|---|
| Window/page base | `UIColors.BACKGROUND` | `BACKGROUND` | `#221811` | Keep as playable Godot base role. |
| Standard panel/card fill | `UIColors.PANEL` / `CardStyle.make_stylebox()` / theme | `PANEL` | `#5B3A25` | Keep as standard window/card background. |
| Panel hover/highlight fill | `UIColors.PANEL_HIGHLIGHT` / theme Button hover | `PANEL_HIGHLIGHT` | `#B46D3C` | Keep or alias to `ACTION_HOVER`. |
| Panel/card border and header accent | `UIColors.PANEL_BORDER`, `UIColors.ACCENT`, `CardStyle.ACCENT_COLOR` | `PANEL_BORDER` / `ACCENT` | `#E1A867` | Keep as border/header accent; consider explicit `HEADER_ACCENT`. |
| Normal text | `UIColors.TEXT_NORMAL` / theme Label/Button/RichTextLabel | `TEXT_NORMAL` | `#F4E2C4` | Keep. |
| Disabled/help/empty text | `UIColors.TEXT_DISABLED` / theme disabled colors | `TEXT_DISABLED` | `#A28D73` | Keep; ensure disabled icons use a named role too. |
| Warning/loss/blocked/remove text | `UIColors.TEXT_WARNING`, `UIColors.OUTCOME_LOSS` | `TEXT_WARNING` / `OUTCOME_LOSS` | `#D35C45` | Keep; alias blocked/destructive roles explicitly if useful. |
| Magic/proc/Decay text | `UIColors.TEXT_MAGIC` | `TEXT_MAGIC` | `#9D73D8` | Keep; alias to `COMBAT_PROC` / `COMBAT_DECAY` if T2 centralizes combat roles. |
| Poison text/chips/popups | `UIColors.TEXT_POISON` | `TEXT_POISON` | `#72B953` | Keep; alias to `COMBAT_POISON`. |
| Gold/reward/value text | `UIColors.TEXT_GOLD` | `TEXT_GOLD` | `#E3C35C` | Keep; alias to `REWARD_VALUE` / `CURRENCY_VALUE` if needed. |
| Modal overlay backdrop | `UIColors.OVERLAY_BACKDROP` | `OVERLAY_BACKDROP` | `Color(0, 0, 0, 0.6)` | Keep; add softer/stronger scrim aliases for local tint variants. |
| Recessed/inset panel | `UIColors.PANEL_DEEP` | `PANEL_DEEP` | `#150F0A` | Keep as inset/window-interior role. |
| Disabled button/slot fill | `UIColors.PANEL_DISABLED` | `PANEL_DISABLED` | `#3A2E22` | Keep; ensure unavailable, unaffordable, locked, and disabled do not collapse together unintentionally. |
| Structure line | `UIColors.STRUCTURE_LINE` | `STRUCTURE_LINE` | `#2E2318` | Keep for route/talent/map scaffolding. |
| Light structure line | `UIColors.STRUCTURE_LINE_LIGHT` | `STRUCTURE_LINE_LIGHT` | `#6B5644` | Keep for inactive borders/connectors. |
| Map current/selected node | `UIColors.MAP_NODE_CURRENT` | `MAP_NODE_CURRENT` | `#47708A` | Consider alias to `CHOICE_SELECTED` or split selected/current if needed. |
| Map inactive/locked node | `UIColors.MAP_NODE_INACTIVE` | `MAP_NODE_INACTIVE` | `#3A2E22` | Currently same value family as disabled; verify locked versus unavailable readability. |
| Basic gear tier container | `UIColors.TIER_BASIC` | `TIER_BASIC` | `#72B953` | Keep if tier/basic intentionally shares poison green; document if retained. |
| Master gear tier container | `UIColors.TIER_MASTER` | `TIER_MASTER` | `#4E8AC5` | Keep. |
| Cursed gear tier container | `UIColors.TIER_CURSED` | `TIER_CURSED` | `#9D73D8` | Keep. |
| Legendary gear tier container | `UIColors.TIER_LEGENDARY` | `TIER_LEGENDARY` | `#E3914C` | Keep. |
| Empty gear slot fill | `UIColors.SLOT_EMPTY` | `SLOT_EMPTY` | `#3A2E22` | Keep, but verify it does not read as disabled action when interactive. |
| Gear slot border | `UIColors.SLOT_BORDER` | `SLOT_BORDER` | `#221811` | Keep or alias to a slot-border role. |
| Enemy health bar fill | `UIColors.HEALTH_BAR_FILL` | `HEALTH_BAR_FILL` | `#9E3535` | Keep as combat HUD health role. |
| Default active button fill | `UIColors.BUTTON_FILL` / generated theme | `BUTTON_FILL` | `#9C6A21` | Alias to `ACTION_DEFAULT`. |
| Pressed/locked button fill | `UIColors.BUTTON_FILL_PRESSED` / generated theme / build lock | `BUTTON_FILL_PRESSED` | `#654515` | Alias to `ACTION_PRESSED`; separate committed/locked if needed. |
| Available skill button normal | `available_skills_panel.gd` | `PANEL_DEEP`, `STRUCTURE_LINE_LIGHT` | `#150F0A`, `#6B5644` | Already named; consider distinct `SKILL_AVAILABLE`. |
| Available skill button hover/focus | `available_skills_panel.gd` | `PANEL`, `ACCENT` | `#5B3A25`, `#E1A867` | Already named; verify hover/focus parity. |
| Available skill button pressed | `available_skills_panel.gd` | `BUTTON_FILL_PRESSED`, `ACCENT` | `#654515`, `#E1A867` | Already named. |
| Disabled skill icon tint | `available_skills_panel.gd`, `skill_build_panel.gd` | local literal | `Color(0.68, 0.64, 0.58, 1.0)` | Add `ICON_DISABLED` or `CONTENT_DISABLED`. |
| Skill-build active slot border/text | `skill_build_panel.gd` | local literal | `Color(1.0, 0.86, 0.28, 1.0)` | Add `BUILD_ACTIVE` or `BUILD_ACTIVE_BORDER`. |
| Skill-build active slot fill | `skill_build_panel.gd` | local literal | `Color(0.22, 0.17, 0.05, 0.94)` | Add `BUILD_ACTIVE_BG`. |
| Skill-build pulse slot border/text | `skill_build_panel.gd` | `TEXT_MAGIC` | `#9D73D8` | Already named; alias to `BUILD_PROC` if retained. |
| Skill-build pulse slot fill | `skill_build_panel.gd` | local literal | `Color(0.18, 0.08, 0.24, 0.94)` | Add `BUILD_PROC_BG` or `BUILD_PULSE_BG`. |
| Skill-build cast progress fill | `skill_build_panel.gd` | local literal | `Color(1.0, 0.86, 0.28, 0.36)` | Add `BUILD_PROGRESS_FILL`. |
| Skill-build proc progress fill | `skill_build_panel.gd` | local literal | `Color(0.62, 0.45, 0.85, 0.48)` | Add `BUILD_PROC_PROGRESS_FILL`. |
| Talent selected node fill | `talent_panel.gd` | local literal | `Color(0.24, 0.32, 0.15, 0.96)` | Add `TALENT_SELECTED_BG`. |
| Talent selected node border | `talent_panel.gd` | `TEXT_POISON` | `#72B953` | Alias to `TALENT_SELECTED_BORDER`. |
| Talent dependency pulse, clicked talent | `talent_panel.gd` | `TEXT_WARNING` | `#D35C45` | Already named; alias to `TALENT_BLOCKED_PULSE`. |
| Talent dependency pulse, dependent talents | `talent_panel.gd` | local literal | `Color(1.0, 0.95, 0.68, 1.0)` | Add `TALENT_DEPENDENCY_PULSE`. |
| Talent unavailable alpha | `talent_panel.gd` | local alpha constant | `0.45` | Consider `UNAVAILABLE_ALPHA` role or keep local layout constant. |
| Tavern/class/title background scrim | `title.gd`, `class_select.gd`, `subclass_select.gd` | local literal | `Color(0.05, 0.045, 0.055, 0.42)` | Add `SCRIM_SOFT` or `BACKGROUND_SCRIM`. |
| Tavern/contract combat background tint | `combat_screen.gd`, `story_overlay.gd` | local literal | `Color(0, 0, 0, 0.42)` | Add `SCRIM_SOFT`; align with title/class scrim if intended. |
| Practice combat background tint | `training_room_combat_view.gd` | local literal | `Color(0, 0, 0, 0.56)` | Add `SCRIM_STRONG` or `COMBAT_VIEW_SCRIM`. |
| Combat result dim | `combat_screen.gd` | local literal | `Color(0.0, 0.0, 0.0, 0.58)` | Add `RESULT_DIM` or reuse `SCRIM_STRONG`. |
| Text popup/ghost outline | combat/shop/gear/map labels | local literals | `Color(0, 0, 0, 0.9-0.95)` | Add `TEXT_OUTLINE`. |
| Inventory blocked pulse | `combat_screen.gd` | `TEXT_WARNING` | `#D35C45` | Already named; alias to `FEEDBACK_BLOCKED`. |
| Gear landing/reroll pulse | `gear_panel.gd`, `shop_overlay.gd` | local literals | `Color(1.25, 1.18, 0.82, 1.0)` / `Color(1.28, 1.18, 0.72, 1.0)` | Add `FEEDBACK_REWARD_PULSE` or keep as effect-only if documented. |
| Combat popup normal hit | `combat_popup_layer.gd` | `TEXT_NORMAL` | `#F4E2C4` | Keep; alias to `COMBAT_HIT_TEXT` if centralizing combat roles. |
| Combat popup crit | `combat_popup_layer.gd` | `TEXT_GOLD` | `#E3C35C` | Keep; alias to `COMBAT_CRIT_TEXT`. |
| Combat popup poison tick | `combat_popup_layer.gd` | `TEXT_POISON` | `#72B953` | Keep. |
| Combat popup proc | `combat_popup_layer.gd` | `TEXT_MAGIC` | `#9D73D8` | Keep. |
| Combat stage poison pulse | `combat_stage.gd` | local literal/generated | `Color(0.44, 1.0, 0.44, 1.0)` and generated green modulate | Add named effect role or document as actor-tint effect-only. |
| Combat stage hit/crit hurt tint | `combat_stage.gd` | local literal | hit `Color(1.0, 0.78, 0.78, 1.0)`, crit `Color(1.0, 0.72, 0.52, 1.0)` | Add `COMBAT_HIT_FLASH` and `COMBAT_CRIT_FLASH` or document as effect-only. |
| Combat stage outcome flash | `combat_stage.gd` | local literal | victory `Color(1.0, 0.86, 0.32, 0.0)`, defeat `Color(1.0, 0.24, 0.2, 0.0)` | Add `COMBAT_VICTORY_FLASH` / `COMBAT_DEFEAT_FLASH`. |
| Combat Log chart cast | `combat_log_inspector.gd` | local literal | `Color(0.55, 0.64, 0.70, 0.92)` | Add `COMBAT_CHART_CAST`. |
| Combat Log chart poison | `combat_log_inspector.gd` | local literal | `Color(0.47, 0.78, 0.30, 0.95)` | Add `COMBAT_CHART_POISON`, likely alias/derive from `TEXT_POISON`. |
| Combat Log chart proc | `combat_log_inspector.gd` | local literal | `Color(0.60, 0.32, 0.88, 0.95)` | Add `COMBAT_CHART_PROC`, likely alias/derive from `TEXT_MAGIC`. |
| Combat Log chart crit | `combat_log_inspector.gd` | local literal | `Color(1.0, 0.78, 0.22, 1.0)` | Add `COMBAT_CHART_CRIT`. |
| Combat Log chart contact line | `combat_log_inspector.gd` | local literal | `Color(0.82, 0.94, 1.0, 1.0)` | Add `COMBAT_CHART_CONTACT`. |
| Combat Log chart grid/line/text/value | `combat_log_inspector.gd` | local literals | grid `Color(0.75, 0.66, 0.50, 0.32)`, line `Color(0.85, 0.78, 0.62, 0.26-0.36)`, text `Color(0.88, 0.82, 0.68, 1.0)`, value `Color(1.0, 0.78, 0.34, 1.0)` | Add chart-specific roles. |
| Shop Lab / Balance Lab tool app palette | `tools/shop-lab/styles.css`, `tools/balance-lab/styles.css` | CSS variables | `--bg #0b1117`, `--surface #101820`, `--gold #f0c36b`, `--teal #77d9d0`, etc. | Named but separate cooler tool palette; decide whether M8 aligns these to CrystalMaiden roles. |
| Sprite Lab editor palette | `tools/sprite-lab/styles.css` | CSS variables | `--bg #15171a`, `--panel #20242a`, `--accent #58c4b6`, etc. | Defer unless Sprite Lab is intentionally pulled into M8 visual identity. |

Expected output:

- More coherent palette use across player-facing screens.
- Clearer interactable state colors.
- Fewer repeated panel and spacing rough edges.
- No intentional gameplay or combat-math changes.

Implementation progress, 2026-08-05:

- Added semantic M8 roles to `project/scripts/ui/ui_colors.gd` so repeated UI
  assets and feedback states can be retuned from one source. New roles cover
  action default/hover/pressed/focus/disabled states, choice states, build active/proc/progress states, talent
  selected/dependency pulse states, scrims, result dimming, price backdrops,
  text outlines, disabled icon tint, reward/action/warning pulses, Combat Log
  chart semantics, and combat-stage flash/tick/outcome colors.
- Replaced recurring local color literals with named `UIColors` roles in
  `skill_build_panel.gd`, `talent_panel.gd`, `available_skills_panel.gd`,
  `combat_log_inspector.gd`, `combat_screen.gd`, `gear_panel.gd`,
  `shop_overlay.gd`, `active_talents_panel.gd`, `map_overlay.gd`,
  `contract_overlay.gd`, title/class/subclass entry scrims,
  `story_overlay.gd`, `training_room_combat_view.gd`, and
  `combat_stage.gd`.
- Normalized native confirmation-dialog focused buttons by adding
  `ACTION_FOCUS`, updating the theme builder, and changing
  `project/assets/ui_theme.tres` so the focused OK button in Sell Gear,
  Abandon Run, and New Adventure dialogs remains in the same action-button
  color family as Cancel.
- Kept content-art colors and intentionally dynamic one-off effects local:
  background paintings, sprites, icons, gear/item art, ghost alpha fades, and
  randomized coin particle modulation are not treated as palette tokens in
  this pass.
- Static scan after cleanup found the targeted recurring literals only in
  `UIColors` itself; remaining local `Color()` usage in touched gameplay
  surfaces is effect-only or transparent/white state setup.

Verification:

- `res://tests/build_panels_test.gd`: passed with exit code 0.
- `res://tests/combat_screen_test.gd`: passed with exit code 0.
- `res://tests/reward_shop_route_ui_test.gd`: passed with exit code 0.
- `res://tests/training_room_combat_view_test.gd`: passed with exit code 0.
- `res://tests/combat_stage_visual_reset_test.gd`: passed with exit code 0.
- Godot printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings during these runs. Tests still exited 0.

Dark Mountain palette experiment, 2026-08-06:

- Applied the `Dark Mountain` exploratory palette from the visual theme sheet
  to the playable Godot palette. Main swatches now map as follows: Deep
  Charcoal `#0E1116` to `BACKGROUND`, Stone Gray `#2A2F36` to `PANEL`, Steel
  Blue `#425466` to `PANEL_HIGHLIGHT` and selected/current structure states,
  Frost Blue `#84A9C8` to magic/proc/disabled-support roles, Burnt Orange
  `#D46A2E` to warning/action-adjacent feedback, and Gold Accent `#E0C06B` to
  borders, rewards, headers, and value emphasis.
- Added derived supporting colors where the six-image swatches did not fully
  cover gameplay semantics: warm parchment body text, cold mountain poison
  green, deeper inset/disabled panels, deep health red, pressed action orange,
  combat chart alpha variants, and combat flash variants.
- Regenerated `project/assets/ui_theme.tres` from
  `project/scripts/tools/build_ui_theme.gd` so global Button, Label, Panel,
  PanelContainer, and native confirmation-dialog button states use the new
  palette.
- Initial theme-builder run without an explicit log path crashed while opening
  `user://logs/godot2026-08-06T08.40.03.log`, matching the known Godot log
  path instability on this machine. Rerunning with
  `--log-file project/reports/m8_dark_mountain_theme_builder.log` succeeded.

Dark Mountain verification:

- `res://tests/build_panels_test.gd`: passed with exit code 0.
- `res://tests/reward_shop_route_ui_test.gd`: passed with exit code 0.
- `res://tests/combat_screen_test.gd`: passed with exit code 0.
- `res://tests/training_room_combat_view_test.gd`: passed with exit code 0.
- `res://tests/combat_stage_visual_reset_test.gd`: passed with exit code 0.
- Godot printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings during these runs. Tests still exited 0.

Earth & Iron palette experiment, 2026-08-06:

- Replaced the active exploratory palette with `Earth & Iron` from the visual
  theme sheet. Main swatches now map as follows: Iron Black `#161616` to
  `BACKGROUND`, Earth Brown `#5C4631` to `PANEL`, Forest Green `#3E5B3B` to
  hover/current/poison-adjacent roles, Worn Gold `#C9A259` to borders,
  rewards, headers, value emphasis, and magic/proc roles, Iron Gray `#3A3A3A`
  to disabled panels, and Blood Red `#8A2E2E` to warning/action/health roles.
- Kept derived supporting colors for readable body text, disabled/help text,
  inset panels, pressed action states, structure-line variants, progress fill
  alpha variants, combat chart accents, and combat flash colors.
- After visual review, split poison text away from the darker Forest Green
  panel/current role. `TEXT_POISON` now uses readable derived green `#8FBF72`
  so poison stat lines remain legible on Earth Brown panels.
- After a second visual review, kept Iron Black `#161616` as the canvas and
  darkened the surface stack so Blood Red action buttons and Worn Gold borders
  pop more cleanly. The first pass used `PANEL #3A2A1E`; a later visual
  review pushed it darker to `PANEL #1D150F`, with `PANEL_DEEP #120D09`,
  `PANEL_DISABLED #201A15`, `STRUCTURE_LINE #120D09`, and
  `STRUCTURE_LINE_LIGHT #4A3B2F`.
- After visual review showed the dashboard canvas still reading as Godot's
  default gray clear color, added explicit full-screen `ScreenCanvas`
  `ColorRect`s behind the Adventure combat dashboard and Practice Room root
  screens. These use `UIColors.BACKGROUND`, so the page canvas now follows the
  active palette instead of relying on the engine viewport default.
- After visual review showed empty gear slots getting lost against the darker
  Earth & Iron panels, changed `SLOT_BORDER` from the black canvas role to
  `TEXT_DISABLED`, matching the muted gray border family used by disabled
  action buttons.
- Added a code-only UI material pass without importing external UI art. New
  `UIColors` material roles now cover panel shadows, button depth, hover glow,
  and slot inset treatment. `CardStyle` owns shared StyleBox helpers for
  raised action buttons and recessed slots, and those helpers are now used by
  the generated project theme, gear slots, inventory slots, skill buttons,
  macro slots, and the lock button.
- Tried a generated dark-mahogany window texture without importing external UI
  assets, then reverted it after visual review because it did not fit the
  current direction. The active window treatment is back to flat Earth & Iron
  panels with the shared depth/border styling intact.
- Tried a second, reference-based wood veneer treatment using the user's dark
  wood screenshot as source material. After visual review showed the result
  still fighting the UI instead of supporting it, removed the veneer PNG,
  import metadata, `CardStyle.make_window_stylebox()`, and all window uses of
  that helper. The active window treatment is again the flat
  `CardStyle.make_stylebox()` Earth & Iron panel with depth/border styling.
- Added a code-only gilded bevel pass after the wood-texture experiment was
  removed. Panels now use a brighter worn-gold edge, heavier right/bottom
  border weights, and a deeper drop shadow so windows sit off the black canvas
  without requiring texture art. Action buttons now use the same gilded edge
  language with stronger raised/pressed geometry, brighter hover/focus edging,
  and a small pressed-state content shift so they read more like physical
  controls.
- Promoted the Gear-panel gold stash readout into the same header row as the
  `Gear` title. The coin/value pair now sits inside a raised, gold-outlined
  badge using the shared bevel style, with larger icon/text sizing so current
  gold is easier to scan.
- Changed reward claiming so gold and talent-point fly-ins play at the same
  time. The reward is marked claimed immediately to prevent double-claims, but
  the visible gold and earned-talent counters now update only after each
  fly-in reaches its destination badge.
- Promoted the Active Talents point counter to the same raised badge treatment
  as the Gear gold stash: larger star icon, larger `: spent/earned` text, and
  a gold-outlined bevel in the panel header. Removed the duplicate point
  footer from the full Talent Trees overlay because the dashboard badge is now
  the clear source of truth while the tree is open.
- Extended the code-only bevel pass to the Tavern and Contract Route map:
  route nodes now use the shared recessed/raised slot styling, connectors have
  a subtle highlighted rail, map reward tier text uses only `Basic`, `Master`,
  `Cursed`, or `Legendary`, and gold/talent rewards appear as compact currency
  rows without adding a gear icon.
- Restored gear rarity colors to the original green/blue/purple/orange visual
  language (`Basic #72B953`, `Master #4E8AC5`, `Cursed #9D73D8`,
  `Legendary #E3914C`) so item tier recognition stays consistent across
  palette experiments.
- Regenerated `project/assets/ui_theme.tres` with
  `--log-file project/reports/m8_earth_iron_theme_builder.log` so global
  Button, Label, Panel, PanelContainer, and native confirmation-dialog button
  states use the Earth & Iron palette.

Earth & Iron verification:

- `res://tests/build_panels_test.gd`: passed with exit code 0.
- `res://tests/reward_shop_route_ui_test.gd`: passed with exit code 0.
- `res://tests/combat_screen_test.gd`: passed with exit code 0.
- `res://tests/training_room_combat_view_test.gd`: passed with exit code 0.
- `res://tests/combat_stage_visual_reset_test.gd`: passed with exit code 0.
- Poison readability follow-up: `res://tests/build_panels_test.gd` and
  `res://tests/combat_screen_test.gd` passed with exit code 0 after changing
  `TEXT_POISON` to `#8FBF72`.
- Darker-panel follow-up: `res://tests/build_panels_test.gd` and
  `res://tests/combat_screen_test.gd` passed with exit code 0 after darkening
  `PANEL`, `PANEL_DEEP`, `PANEL_DISABLED`, and structure-line roles.
- `#1D150F` panel follow-up: `res://tests/build_panels_test.gd` and
  `res://tests/combat_screen_test.gd` passed with exit code 0 after pushing
  Earth Brown panels a few shades darker and regenerating `ui_theme.tres`.
- Canvas-background follow-up: `res://tests/combat_screen_test.gd` and
  `res://tests/training_room_entry_test.gd` passed with exit code 0 after
  adding explicit `UIColors.BACKGROUND` screen canvases.
- Gear-slot border follow-up: `res://tests/build_panels_test.gd` and
  `res://tests/combat_screen_test.gd` passed with exit code 0 after changing
  `SLOT_BORDER` to `TEXT_DISABLED`.
- Code-only material-pass follow-up: regenerated `project/assets/ui_theme.tres`
  with `--log-file project/reports/ui_material_pass_theme.log`, then
  `res://tests/build_panels_test.gd`,
  `res://tests/combat_screen_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`, and
  `res://tests/training_room_combat_view_test.gd` passed with exit code 0.
- Mahogany texture follow-up: regenerated `project/assets/ui_theme.tres` with
  `--log-file project/reports/ui_wood_texture_theme.log`, then
  `res://tests/build_panels_test.gd`,
  `res://tests/combat_screen_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`, and
  `res://tests/training_room_entry_test.gd` passed with exit code 0.
- Flat-panel restore follow-up: removed the generated wood texture helper and
  all `make_textured_stylebox()` panel uses, regenerated
  `project/assets/ui_theme.tres` with
  `--log-file project/reports/ui_flat_restore_theme.log`, then
  `res://tests/build_panels_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/reward_shop_route_ui_test.gd` passed with exit code 0.
- Reference veneer window follow-up: regenerated `project/assets/ui_theme.tres`
  with `--log-file project/reports/ui_window_wood_theme.log`, then
  `res://tests/build_panels_test.gd`,
  `res://tests/combat_screen_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`, and
  `res://tests/training_room_entry_test.gd` passed with exit code 0.
- Wood veneer removal follow-up: deleted the generated veneer texture and
  import file, restored all major windows to `CardStyle.make_stylebox()`,
  regenerated `project/assets/ui_theme.tres` with
  `--log-file project/reports/ui_flat_restore_theme.log`, then
  `res://tests/build_panels_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/reward_shop_route_ui_test.gd` passed with exit code 0.
- Gilded bevel follow-up: regenerated `project/assets/ui_theme.tres` with
  `--log-file project/reports/ui_gilded_bevel_theme.log`, then
  `res://tests/build_panels_test.gd`,
  `res://tests/combat_screen_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`, and
  `res://tests/training_room_entry_test.gd` passed with exit code 0.
- Gear gold-badge follow-up: `res://tests/build_panels_test.gd` and
  `res://tests/combat_screen_test.gd` passed with exit code 0 after moving the
  gold readout into the Gear header and framing it as a raised badge.
- Reward deposit / talent badge follow-up: `res://tests/build_panels_test.gd`,
  `res://tests/combat_screen_test.gd`, and `res://tests/inventory_model_test.gd`
  passed with exit code 0 after making reward currency fly-ins simultaneous,
  deferring visible currency deposits until arrival, promoting Active Talents
  points to a raised badge, and removing the Talent Trees footer counter.
- Map bevel/reward follow-up: `res://tests/contract_offer_flow_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/reward_shop_route_ui_test.gd` passed with exit code 0 after
  applying the shared beveled slot treatment to Tavern/Contract map nodes,
  adding highlighted connector rails, keeping map gear rewards to tier words
  only, and showing gold/talent map reward rows with currency icons.
- Gear rarity color follow-up: `res://tests/build_panels_test.gd` and
  `res://tests/reward_shop_route_ui_test.gd` passed with exit code 0 after
  restoring the original green/blue/purple/orange tier colors while leaving
  the Earth & Iron UI chrome in place.
- Map label/layout follow-up: `res://tests/contract_offer_flow_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`, and
  `res://tests/combat_screen_test.gd` passed with exit code 0 after changing
  the Contract Route commit button back to `Proceed`, labeling route gear
  rewards as `Reward: Basic/Master/Cursed/Legendary`, and tightening/clipping
  the map currency rows so reward icons stay inside the beveled node bounds.
- Map overhang follow-up: `res://tests/contract_offer_flow_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/route_reward_choice_ui_test.gd` passed with exit code 0 after
  converting Tavern/Contract nodes into encounter-marker cards: idle enemy
  sprites now overhang the top edge, gold/talent reward rows are larger and
  deliberately overhang the bottom edge, and the underlying button hitboxes
  stay stable.
- Map mockup-match follow-up: the overhanging marker treatment was tuned
  closer to the user's reference mockup by increasing enemy marker size,
  making Tavern nodes wider, enlarging gold/talent icons and values, moving
  the reward row across the bottom edge, and using outlined white reward text
  for better contrast over the card edge.
- Map left-anchor follow-up: re-anchored Tavern and Contract encounter nodes
  around the enemy sprite. The sprite now overlaps the left side of the
  beveled card, the visible name/reward label is drawn in a right-side text
  block, and the larger gold/talent reward row intentionally crosses the
  bottom edge while the underlying button text remains available for tests,
  tooltips, and route logic.
- Left-anchored map-node verification:
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/route_reward_choice_ui_test.gd` passed with exit code 0.
- Map contained-layout follow-up: removed the experimental visual bleed from
  Tavern and Contract encounter nodes. Nodes now keep their content clipped
  inside the beveled card, with a contained enemy sprite, the encounter name to
  its right, and the gold/talent reward row below.
- Contained map-node verification: `res://tests/contract_offer_flow_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`, and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- Map sprite/defeat-marker follow-up: increased contained encounter sprites
  and moved the Tavern defeated `X` marker onto the sprite area with higher
  draw order, so defeated state no longer obscures the encounter name.
- Map sprite/defeat-marker verification:
  `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`, and
  `res://tests/route_reward_choice_ui_test.gd` passed with exit code 0.
- Map sprite/name spacing follow-up: pulled the encounter name closer to the
  sprite, lowered the name block toward the sprite's feet, and reduced the
  visible name font slightly so two-line names read as part of the character
  grouping instead of floating near the top of the card.
- Map sprite/name spacing verification:
  `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`, and
  `res://tests/route_reward_choice_ui_test.gd` passed with exit code 0.
- Map group/reward spacing follow-up: moved the sprite/name grouping upward
  and moved the contained reward row slightly lower so the character identity
  and reward information read as two separate bands inside each node.
- Map group/reward spacing verification:
  `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`, and
  `res://tests/route_reward_choice_ui_test.gd` passed with exit code 0.
- Map hover-text follow-up: hidden logical Button text is now transparent for
  every composed-map-node Button state, including hover, focus, pressed,
  hover-pressed, disabled, and outline colors. This prevents the underlying
  route/reward text from reappearing behind the custom sprite/name/reward
  composition when a node is hovered or focused.
- Map hover-text verification: `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`, and
  `res://tests/route_reward_choice_ui_test.gd` passed with exit code 0.
- Map tooltip pause follow-up: Tavern and Contract map-entry tooltips are
  disabled for now by clearing `Button.tooltip_text`, while the existing
  tooltip builder functions remain in code for a future tooltip/flavor pass.
- Map tooltip pause verification: `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`, and
  `res://tests/route_reward_choice_ui_test.gd` passed with exit code 0.
- Map gear-reward marker follow-up: map reward rows now show gear presence
  with a small helm marker recolored to the original shop/gear rarity colors:
  Basic green, Master blue, Cursed purple, and Legendary orange. The marker
  uses `x1` to mean one gear reward result, even when the actual reward flow
  offers a choice from multiple generated or authored items. Map node content
  clipping is disabled so long reward values can extend past the card edge
  instead of being cut off.
- Map gear-reward marker verification:
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`, and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- Map reward-centering follow-up: three-part map reward rows, such as
  talent + gear + gold, now shift slightly left so their combined icon/text
  run centers better under the encounter card. One- and two-part reward rows
  keep their previous placement.
- Map reward-centering verification:
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`, and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- Combat health-bar follow-up: the enemy HUD health bar now uses semantic
  health-bar palette roles, a taller beveled track, a gold-edged inset, and
  a small drawn shine/shadow overlay tied to the live ProgressBar value so it
  keeps the existing playback behavior while reading less flat.
- Combat health-bar verification: `res://tests/combat_hud_test.gd` and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- Title random-toggle follow-up: removed the experimental raised-button
  treatment from the `Random` seed control and left it as a native CheckBox,
  since the only interaction is toggling random seed generation. The control
  explicitly clears inherited Button styleboxes so it renders as just the
  checkbox glyph plus label instead of a clickable red box. The seed number
  field now has a thin gold outline, and the Random checkbox uses explicit
  checked/unchecked icons with a matching gold outline so both controls read
  clearly against the dark seed card.
- Title random-toggle verification: `res://tests/save_load_ui_test.gd`
  passed with exit code 0.
- Title lightning follow-up: added a mouse-transparent procedural lightning
  flash overlay to the main menu. It draws subtle purple cloud glow, jagged
  bolt branches aligned to the background image's aspect-covered display
  rect, an early first flash, and longer randomized follow-up flashes below
  the menu/title controls. Follow-up tuning shifted the bolt cluster right
  and reduced its scale/glow so it sits closer to the painted lightning.
- Title lightning verification: `res://tests/save_load_ui_test.gd` passed
  with exit code 0.
- Combat timer follow-up: added a raised top-center clock badge to the combat
  window. It shows the selected target's full fight window before combat and
  counts down during real-time playback. Follow-up cleanup moved the badge up
  into the HUD row above the health bar, removed the older playback-controls
  time readout, and hid the redundant combat-stage enemy name in Adventure
  combat. A later placement pass moved the badge higher toward the Combat
  title line and moved the playback speed controls into the top-right HUD
  space above HP/armor/resist, where they remain visible. Skip now behaves as
  a persistent playback mode: choosing it before Fight auto-skips the fight
  playback to the resolved victory/defeat presentation. Follow-up timing fix:
  Skip now skips only the attack timeline; it still plays the victory/defeat
  pose beat and waits before opening the result overlay.
- Combat timer verification: `res://tests/combat_hud_test.gd` and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- Practice combat parity follow-up: brought the Practice Room combat window
  into the same timer/playback-control language as Adventure, including the
  top-center clock badge, permanent playback controls with label, darker
  training-room backdrop scrim, sword icon for damage, and removal of
  redundant in-window target text.
- Practice combat parity verification:
  `res://tests/training_room_combat_view_test.gd`,
  `res://tests/training_room_fight_setup_test.gd`, and
  `res://tests/training_room_entry_test.gd` passed with exit code 0 during the
  follow-up passes.
- Talent Trees presentation follow-up: removed the duplicate inner Talent
  Trees frame/title treatment, split the tree view into Primary and Secondary
  columns, kept the Active Talents badge as the clear point source of truth,
  and changed Practice Room tree selection so both empty columns are visible
  immediately with their dropdowns centered inside each column.
- Talent Trees verification: `res://tests/build_panels_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/training_room_build_test.gd` passed with exit code 0.
- Contract-route flavor follow-up: added authored `before_selection_text` and
  `selected_text` fields to `ContractRouteNode`, then replaced the top
  contract-map route text with short story beats for The Gilded Serpent while
  retaining the older pressure/reward helper as fallback data logic.
- Contract-route flavor verification:
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`,
  `res://tests/contract_route_data_test.gd`, and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- T2 closeout, 2026-08-06: after user review, the palette/color-state/repeated
  rough-edge pass is complete. Remaining polish should proceed through T3+
  rather than expanding T2 indefinitely.
- Godot printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings during these runs. Tests still exited 0.

### P3:M8:T3 - Decide And Implement Replaceable Placeholder Audio If Approved

Status: Complete.

Goal: add lightweight audio feedback only where it clarifies interaction or
combat state.

Approval question:

- Approved: M8 should include audio, starting with menu/class/subclass ambience
  using the provided rain-storm source and a settings path for volume control.

Candidate audio moments if approved:

- Button confirm.
- Cancel/back.
- Selection or commit.
- Disabled/blocked action.
- Shop buy, sell, equip, unequip, and reroll.
- Reward claim.
- Combat hit.
- Combat crit.
- Poison tick or poison stack.
- Proc trigger.
- Victory.
- Defeat.

Direction:

- Use replaceable placeholder assets.
- Keep volume and frequency restrained.
- Avoid changing combat timing, result logic, or player input flow.
- Prefer a small reusable playback path over scattered one-off calls.

Expected output:

- Either a documented decision to defer audio, or a small implemented
  placeholder audio set with focused verification.

Progress:

- 2026-08-07: Added the shared settings-menu shell before wiring audio. A red
  circular gear button is mounted once by `GameRoot` in the upper-right corner
  of every screen through `project/scripts/ui/settings_menu_layer.gd`. Pressing
  it shows a heavy black full-screen blackout and a centered Settings panel
  with `Gameplay`, `Video`, `Audio`, `Credits`, and `Exit`. The first four
  entries are disabled placeholders; `Exit` closes the overlay.
- Copied the provided gear icon into the Godot project as
  `project/assets/ui/icons/settings_gear.png`.
- Added `res://tests/settings_menu_layer_test.gd` to verify the shared button
  placement, blackout strength, centered panel, disabled placeholder buttons,
  and close behavior.
- Follow-up UI cleanup: retuned the settings button to use the shared red/gold
  action-button palette, aligned it with the Adventure top function row, and
  converted the Adventure `Map`, `Save & Quit`, and `Abandon Run` controls into
  named icon-only buttons. The map button now shows only the larger map icon;
  save/quit uses the copied inventory icon; abandon uses the copied `ex` icon.
  A reserved top-bar gap keeps those Adventure buttons clear of the global
  settings button.
- Follow-up settings/audio implementation: renamed the Settings dismiss action
  from `Exit` to `Close`, added Master, Music, and Effects volume sliders, and
  added `AudioManager` as a new autoload. `AudioManager` creates runtime
  `Music` and `Effects` buses, persists audio settings to
  `user://audio_settings.cfg`, and routes the first rain ambience through the
  Music bus.
- The requested source path named `rain_storm.mp4`, but the Sounds folder
  contained `rain_storm.mp3`. The MP3 was copied into the project as
  `project/assets/audio/music/rain_storm.mp3` and is loaded as the first
  replaceable menu ambience asset.
- Rain ambience now starts on Title, continues through class/subclass and the
  first Tavern intro/map preview, and stops when the first Tavern opponent
  Mouthy Drunk is committed. Practice Room and resumed runs after that first
  Tavern choice stop the menu rain.
- Follow-up layered menu music pass: the main Settings panel now opens a
  separate Audio panel when `Audio` is pressed. The main Settings panel hides,
  the Audio panel appears in the same centered location, and its `Main Menu`
  button returns to the main Settings panel. The Audio panel owns the Master,
  Music, and Effects sliders.
- The requested `epic_theme.mp4` source was present as `epic_theme.mp3`; it was
  copied into `project/assets/audio/music/epic_theme.mp3`. Title, class select,
  and subclass select now play the epic theme over the rain. The rain is mixed
  lower than the theme so it remains subtle but audible.
- The epic theme fades out when the Tavern map appears, leaving rain in place.
  The rain then fades out when Mouthy Drunk is committed. Entering Practice
  Room fades out both the epic theme and rain.
- Attack SFX follow-up: copied the six approved sword-hit/swing examples into
  `project/assets/audio/fx/sword/` and added them as a randomized Effects-bus
  pool in `AudioManager`. Each attack picks a random source with small pitch
  and volume variation, uses an eight-player pool so overlapping attacks do
  not cut each other off, and scales playback pitch by both skill attack time
  and the current combat playback speed.
- Combat playback now triggers one sword SFX for each non-skipped physical cast
  impact. Poison ticks and skip playback do not emit these sounds, which keeps
  fast-forward and skipped fights from turning into audio spam.
- Practice Room follow-up: its upper-right Back action now uses the same
  square red/gold icon-button treatment and settings-button spacing as
  Adventure's top action row. Practice Room combat playback also emits the
  same randomized sword SFX on non-skipped realtime physical attacks.
- Proc-aware attack audio follow-up: attack SFX now count damaging proc
  contributions inside each `CombatResolver.CastEvent`. A normal physical cast
  plays one sword sound; each additional damaging `kind = "proc"` contribution
  schedules an extra, lightly staggered sword sound so triggered Rending Slash
  and retrigger-style legendary effects read as chained hits.
- Tavern ambience follow-up: copied `fireplace.mp3`, `chatter.mp3`, and
  `tavern_theme.mp3` into `project/assets/audio/music/` and added them as
  subtle Music-bus ambience. The Tavern map now fades rain/theme out while
  fading fireplace/chatter/distant-band theme in. Tavern ambience continues
  through Tavern encounter selection and Tavern fights, then fades out when
  the first Vyra contract route fight is selected.
- Vyra contract ambience follow-up: copied `night_time.mp3` and
  `serpent_theme.mp3` into `project/assets/audio/music/` and added them as a
  separate Music-bus contract ambience scene. Selecting the first Vyra contract
  route fight now fades Tavern ambience out while fading in rain, nighttime
  ambience, and a subtle serpent theme.
- UI/shop SFX follow-up: copied `button_press.mp3` and `change.mp3` into
  `project/assets/audio/fx/`. `AudioManager` now auto-connects visible,
  enabled buttons as they enter the scene tree and plays the button press
  sound through the Effects bus. Successful shop buys and sells play the
  change sound through the Effects bus with a lowered pitch scale so it reads
  more like a coin jingle; blocked shop buys remain silent except for their
  existing visual feedback.
- Button SFX reliability follow-up: fixed missed click sounds on self-hiding
  or immediately-disabling controls such as Settings panel buttons, Talent
  Trees Close, map Proceed/Close Map, and Fight. `AudioManager` now connects
  all `BaseButton` controls, plays on `button_down` for real UI interactions,
  keeps a `pressed` fallback for keyboard/programmatic activation, and
  suppresses same-frame duplicates.
- Button SFX duplicate follow-up: tightened the click path so mouse
  interaction plays once on press, then suppresses the matching release-side
  `pressed` event until the button-up cycle clears. Keyboard/programmatic
  `pressed` activation remains covered by the fallback.

Verification:

- `res://tests/settings_menu_layer_test.gd`: passed with exit code 0.
- `res://tests/training_room_entry_test.gd`: passed with exit code 0.
- Settings/top-button follow-up: `res://tests/settings_menu_layer_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/save_load_ui_test.gd` passed with exit code 0.
- Audio follow-up: `res://tests/menu_rain_audio_test.gd`,
  `res://tests/settings_menu_layer_test.gd`, `res://tests/combat_screen_test.gd`,
  and `res://tests/save_load_ui_test.gd` passed with exit code 0.
- Layered menu audio follow-up: `res://tests/menu_rain_audio_test.gd`,
  `res://tests/settings_menu_layer_test.gd`, `res://tests/save_load_ui_test.gd`,
  and `res://tests/combat_screen_test.gd` passed with exit code 0.
- Attack SFX follow-up: `res://tests/attack_sfx_audio_test.gd`,
  `res://tests/menu_rain_audio_test.gd`, and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- Practice Room SFX/header follow-up: `res://tests/training_room_entry_test.gd`,
  `res://tests/training_room_combat_view_test.gd`,
  `res://tests/training_room_fight_test.gd`,
  `res://tests/settings_menu_layer_test.gd`, and
  `res://tests/attack_sfx_audio_test.gd` passed with exit code 0.
- Proc-aware attack audio follow-up: `res://tests/attack_sfx_audio_test.gd`,
  `res://tests/training_room_combat_view_test.gd`, and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- Tavern ambience follow-up: `res://tests/menu_rain_audio_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/settings_menu_layer_test.gd` passed with exit code 0.
- Vyra contract ambience follow-up: `res://tests/menu_rain_audio_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/settings_menu_layer_test.gd` passed with exit code 0.
- UI/shop SFX follow-up: `res://tests/attack_sfx_audio_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/settings_menu_layer_test.gd` passed with exit code 0.
- Button SFX reliability follow-up: `res://tests/attack_sfx_audio_test.gd`,
  `res://tests/settings_menu_layer_test.gd`, and
  `res://tests/combat_screen_test.gd` passed with exit code 0.
- `res://tests/combat_playback_test.gd` was also run during the attack-SFX
  follow-up, but it failed at its pre-existing autosave timing assertion
  (`Expected the autosave to have fired before playback started`) before any
  new audio-specific assertion was reached.
- Godot printed the known Windows root-certificate-store warning and cleanup
  warnings during these runs. Tests still exited 0.

### P3:M8:T4 - Sweep Combat And Interaction Feedback Consistency

Status: Complete.

Goal: ensure earlier Phase 3 feedback improvements feel like one coherent game
rather than separate milestone layers.

Direction:

- Compare Adventure and Practice Room combat feedback for intentional parity.
- Check that result overlays, recap access, retry/restart actions, and Combat
  Log entry points remain clear.
- Check that reward/shop/build/talent handoffs use consistent next-action and
  blocked-action language.
- Check that route and contract choices use clear selected versus committed
  states.

Expected output:

- Small consistency fixes where state language has drifted.
- Clear notes for any larger feedback work deferred to a later phase.

Progress:

- 2026-08-07: Added `CardStyle.pulse_blocked_control()` as the shared visual
  feedback helper for blocked or rejected interactions. The helper preserves
  existing control text/tooltips/status labels, pulses the attempted control
  with the shared blocked-feedback color, and records a metadata marker for
  focused tests.
- Moved Adventure's inventory-full reward/shop pulse onto the shared helper
  while preserving the existing `inventory_blocked_pulse` metadata used by
  tests.
- Practice Room Fight now uses the same blocked-action feedback when invoked
  while the build cannot run, matching the existing tooltip/disabled-state
  guard for empty or unlocked rotations.
- Map `Proceed` now pulses when activated without a Tavern preview or pending
  contract-route selection, matching the select-then-commit pattern already
  shown by the disabled button and tooltip.
- Shop reroll now pulses the reroll action and keeps the `Not enough gold.`
  status when invoked without enough gold, matching the visual-feedback
  language used by blocked reward/shop item interactions.

Verification:

- `res://tests/training_room_fight_test.gd` passed with exit code 0.
- `res://tests/reward_shop_route_ui_test.gd` passed with exit code 0.
- `res://tests/route_reward_choice_ui_test.gd` passed with exit code 0.
- `res://tests/combat_screen_test.gd` passed with exit code 0.
- `res://tests/training_room_combat_view_test.gd` passed with exit code 0.
- Godot printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings during these runs. Tests still exited 0.

### P3:M8:T5 - Check Major States At Target Resolution

Status: Complete.

Goal: verify that major screens read cleanly at the target resolution before
Phase 3 closeout.

Direction:

- Check for clipped text.
- Check for overlapping controls.
- Check for awkward wrapping.
- Check for low-contrast labels.
- Check for unfinished-looking repeated panels.
- Check for unclear primary actions.
- Check for state colors that become ambiguous in context.

Expected output:

- A short target-resolution pass/fix list.
- Narrow UI fixes for any major unfinished-looking state.

Progress:

- 2026-08-07: Added a subtle procedural fire/glow overlay for the Tavern
  combat-window fireplace, matching the main-menu lightning approach without
  adding new bitmap assets. The overlay binds to the existing Tavern
  background `TextureRect`, uses normalized image coordinates so it stays
  aligned under `STRETCH_KEEP_ASPECT_COVERED`, renders below the combat tint
  for restrained brightness, and hides automatically when the combat window
  switches to the contract exterior background.
- Contract lair follow-up: added a rare procedural black bat/bird silhouette
  that crosses the moon area on the contract exterior background. It uses the
  same background-bound overlay pattern as the Tavern fireplace, renders below
  the combat tint, and stays hidden on Tavern-background fights.
- 2026-08-07 target-resolution review: captured and visually inspected the
  title, settings main/audio panels, class/subclass select, intro story, Tavern
  map/selected map, Tavern combat ready, Tavern victory, Tavern shop, contract
  route map/selected route, contract combat ready, Practice Room, Practice
  Talent Trees overlay, and Practice gear editor at 1600x900. Screenshots are
  retained under `project/reports/m8_t5_screenshots/`. No clipping, incoherent
  overlap, ambiguous primary actions, or major low-contrast regressions were
  found in the inspected set, so no additional layout patch was required for
  T5.

Verification:

- `res://tests/combat_screen_test.gd` passed with exit code 0.
- Contract moon follow-up: `res://tests/combat_screen_test.gd` passed with
  exit code 0.
- Screenshot pass: normal-renderer Godot probe exited 0 and saved
  `01_title.png` through `17_practice_gear_editor.png` under
  `project/reports/m8_t5_screenshots/`.
- Focused post-review checks passed with exit code 0:
  `res://tests/combat_screen_test.gd`,
  `res://tests/settings_menu_layer_test.gd`,
  `res://tests/training_room_entry_test.gd`, and
  `res://tests/training_room_combat_view_test.gd`.
- An earlier parallel attempt to run those four checks was discarded because
  simultaneous Godot processes collided on the same timestamped user log file
  and crashed before test assertions ran. The listed sequential reruns used
  explicit log files and passed.
- Godot printed the known Windows root-certificate-store warning and
  ObjectDB/RID/resource cleanup warnings during the runs. The tests/probe still
  exited 0.

### P3:M8:T6 - Run Focused Verification

Status: Complete.

Goal: verify changed surfaces without turning M8 into the full Phase 3
closeout regression pass.

Candidate focused checks:

- `res://tests/combat_screen_test.gd`
- `res://tests/combat_playback_test.gd`
- `res://tests/combat_recap_test.gd`
- `res://tests/training_room_entry_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/training_room_fight_test.gd`
- `res://tests/training_room_fight_setup_test.gd`
- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_gear_editor_test.gd`
- `res://tests/rotation_cap_test.gd`
- `res://tests/skill_build_geometry_test.gd`

Run Balance Lab only if M8 touches:

- Combat math.
- Combat event ordering.
- Build resolution.
- Skill, talent, gear, or enemy resources.
- Balance-relevant data.

Expected output:

- Focused verification notes recorded in this document.
- Known Godot caveats recorded if they reproduce.

Result:

- 2026-08-07: Required M8-focused checks passed with exit code 0:
  `res://tests/combat_screen_test.gd`,
  `res://tests/settings_menu_layer_test.gd`,
  `res://tests/attack_sfx_audio_test.gd`,
  `res://tests/menu_rain_audio_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`,
  `res://tests/save_load_ui_test.gd`,
  `res://tests/training_room_entry_test.gd`, and
  `res://tests/training_room_combat_view_test.gd`.
- Adjacent UI/presentation checks also passed with exit code 0:
  `res://tests/combat_hud_test.gd`,
  `res://tests/combat_playback_test.gd`,
  `res://tests/build_panels_test.gd`, and
  `res://tests/training_room_fight_setup_test.gd`.
- Logs were written under `project/logs/` with `m8_t6_` and
  `m8_t6_adjacent_` prefixes.
- Balance Lab was not run for T6 because the M8 changes are presentation,
  feedback, audio, and UI state changes rather than combat math, event
  ordering, build resolution, skill/talent/gear/enemy resource, or
  balance-data changes.
- Godot printed the known Windows root-certificate-store warning, image-load
  export warnings for existing UI/logo images, and ObjectDB/RID/resource
  cleanup warnings during the runs. The tests still exited 0.

### P3:M8:T7 - Verify, Document, And Close Milestone 8

Status: Complete.

Goal: close M8 cleanly after implementation and review.

Steps:

- P3:M8:T7:S1 - Record final implementation summary.
- P3:M8:T7:S2 - Record final verification commands and results.
- P3:M8:T7:S3 - Update `docs/P3_CrystalMaiden_Overview.md`.
- P3:M8:T7:S4 - Update `docs/P3_CrystalMaiden_Onboarding_Context.md`.
- P3:M8:T7:S5 - Record any Phase 4 or production-art/audio deferrals.

Expected output:

- M8 marked complete.
- Overview and onboarding updated.
- Clear handoff into Milestone 9 regression/export closeout.

Final implementation summary:

- M8:T0 established the polish scope and kept the milestone focused on
  current-build presentation, feedback, and audio rather than new gameplay or a
  full production-art pass.
- M8:T1 audited feedback states, palette usage, repeated panel treatment,
  interactable colors, and rough edges.
- M8:T2 completed the palette/color-state cleanup: Earth & Iron chrome,
  preserved gear rarity colors, shared bevel/depth treatment, clearer map and
  reward language, title/seed polish, Adventure/Practice combat timer and
  playback parity, Talent Trees presentation cleanup, and Gilded Serpent
  route-map flavor text.
- M8:T3 implemented the approved replaceable audio pass: shared settings/audio
  menu, Master/Music/Effects volume controls, layered menu/Tavern/contract
  ambience, Adventure/Practice attack SFX, button click SFX, shop transaction
  SFX, and fade rules.
- M8:T4 added shared blocked-action feedback for Practice Fight, map Proceed,
  shop reroll, and inventory-full reward/shop blocks.
- M8:T5 added subtle procedural background motion for the Tavern fireplace and
  contract moon area, then reviewed major title, settings, selection,
  Adventure, shop, contract, and Practice states at 1600x900. Screenshots are
  retained under `project/reports/m8_t5_screenshots/`.
- M8:T6 ran the focused verification set plus adjacent UI/presentation checks;
  all exited 0. Balance Lab was skipped because M8 did not touch
  balance-relevant data or combat math.

Final verification:

- `res://tests/combat_screen_test.gd`: passed with exit code 0.
- `res://tests/settings_menu_layer_test.gd`: passed with exit code 0.
- `res://tests/attack_sfx_audio_test.gd`: passed with exit code 0.
- `res://tests/menu_rain_audio_test.gd`: passed with exit code 0.
- `res://tests/reward_shop_route_ui_test.gd`: passed with exit code 0.
- `res://tests/route_reward_choice_ui_test.gd`: passed with exit code 0.
- `res://tests/save_load_ui_test.gd`: passed with exit code 0.
- `res://tests/training_room_entry_test.gd`: passed with exit code 0.
- `res://tests/training_room_combat_view_test.gd`: passed with exit code 0.
- Adjacent checks also passed with exit code 0:
  `res://tests/combat_hud_test.gd`,
  `res://tests/combat_playback_test.gd`,
  `res://tests/build_panels_test.gd`, and
  `res://tests/training_room_fight_setup_test.gd`.
- T5 normal-renderer screenshot probe exited 0 and saved the 1600x900 review
  set under `project/reports/m8_t5_screenshots/`.
- Logs from the T6 verification run are retained under `project/logs/` with
  `m8_t6_` and `m8_t6_adjacent_` prefixes.

Known caveats:

- Godot still prints the known Windows root-certificate-store warning in
  headless runs.
- Existing image-load export warnings still appear for UI/logo images loaded
  as image files.
- Godot still prints ObjectDB/RID/resource cleanup warnings at process exit.
  These warnings did not prevent any M8 verification command from exiting 0.

Deferred:

- Full fantasy UI production, ornate frame sets, bespoke panel textures,
  custom portraits, and a complete art-direction pass remain deferred.
- Final production-quality audio mix, sourced/commissioned sound assets, and
  deeper audio polish remain deferred beyond this replaceable placeholder pass.
- Balance Lab, export smoke testing, full regression, final screenshots/video,
  and Phase 4 handoff notes belong to M9 regression/export closeout.

Handoff:

- Milestone 8 is complete locally. Continue with Milestone 9: Regression,
  Export, And Phase 3 Closeout.
