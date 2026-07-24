# P2:R11 - Training Room UI Polish

## Purpose

Track the work for **P2:R11 - Training Room UI Polish**.

`P2:R10 - Full Training Room Parity` (complete 2026-07-21) delivered the full
freeform Training Room feature set, but its own scope decisions were
deliberately the lower-effort option in a few places (a toggle-button tree
row, a raw per-slot affix editor, static-text-only fight results, a bare
target dropdown). Hands-on inspection of the running Training Room surfaced
UI feedback the user wanted addressed before treating the screen as
playtest-ready: it didn't yet look or feel like the real Adventure dashboard,
and a few real bugs turned up along the way. This milestone is that
follow-on polish pass, done directly via live testing rather than a
pre-written spec, plus two fixes discovered during it that reach beyond
Training Room: a project-wide canvas-scaling gap, and an Adventure-dashboard
overlay-layout bug.

Not a new engine capability milestone like `P2:R9`/`P2:R10` -- no new Resource
schema or combat mechanic is added here. It's a UI/UX and bug-fix pass, closer
in kind to `P2:R7 - Game-Like UI Pass`, scoped specifically to the screen
`P2:R10` had just finished.

## Exit Criteria

P2:R11 is complete when:

- The whole game's UI scales as one fixed layout with the window instead of
  reflowing non-uniformly.
- Training Room's build/target/combat/gear controls visually and structurally
  match the real Adventure dashboard's conventions (3-column layout, dropdown
  tree selection, a live animated combat view, a Combat Log overlay).
- The gear editor is rarity-first (matching how real gear actually generates)
  rather than a fully freeform raw affix table.
- Real bugs surfaced during the pass (poison ticks at 0 stacks, a
  stuck-disabled rarity dropdown, Mithril Karambit's cross-skill trigger leak,
  Adventure's overlay reflow) are fixed, not just Training-Room cosmetics.
- The full regression suite passes after every change.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R11:T1 | Global Canvas Scaling Fix | `project.godot` stretch mode so the UI scales uniformly with the window | Complete |
| P2:R11:T2 | Talent Tree Dropdowns | Toggle-button tree row replaced with Primary/Secondary `OptionButton`s | Complete |
| P2:R11:T3 | Target Stats Panel | Dedicated `TrainingTargetPanel` card (Armor/Poison Resist inputs) | Complete |
| P2:R11:T4 | Combat Playback View | New `TrainingRoomCombatView` (animated popups/HP-adjacent status) built on the existing `CombatPlayback` class; Fight button repositioned under it | Complete |
| P2:R11:T5 | Gear Editor Rarity-First Rework | Raw add/remove-affix flow replaced with a per-slot Rarity dropdown | Complete |
| P2:R11:T6 | Dashboard Layout Parity | 3-column layout (1:2:1 ratio) matching Adventure; Combat Log button + overlay; shared 10-skill rotation cap; Legendary hover tooltip | Complete |
| P2:R11:T7 | Combat Feel Fixes | Taller/dark combat window with a live armor/resist/poison-stack readout, background image, proc-highlighted popups, 0-damage-tick-at-0-stacks fix, stuck-disabled-rarity-dropdown fix, "None" rarity option | Complete |
| P2:R11:T8 | Mithril Karambit Per-Skill Trigger Fix | Each of its two triggers now only fires from its own source skill | Complete |
| P2:R11:T9 | Adventure Overlay Reflow Fix | Victory/Shop/Reward-choice overlays converted to true full-rect root overlays | Complete |
| P2:R11:T10 | Regression + Docs | Full suite green after every change; this doc | Complete |

## P2:R11:T1 - Global Canvas Scaling Fix

`project/project.godot` gained, under `[display]`:

```
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
```

The existing `viewport_width=1600`/`viewport_height=900` stay the fixed
logical design size; the whole UI now scales uniformly to fit the actual
window instead of individual `Control`s reflowing/growing independently.
(`[gui]` also gained `theme/custom="res://assets/ui_theme.tres"`, wiring the
project-wide Theme resource at the project-settings level rather than only
per-scene.)

## P2:R11:T2 - Talent Tree Dropdowns

`training_room.gd`'s `_build_tree_option()` builds an `OptionButton` per tree
slot (item 0 = `"None"`, then one item per `_state.selected_class.trees`),
labeled `"Primary"` and `"Secondary"` (not "Tree 1"/"Tree 2"), wired to
`TrainingRoomState.set_primary_tree()`/`set_secondary_tree()`. Replaces the
original `P2:R10` toggle-button row.

## P2:R11:T3 - Target Stats Panel

New `project/scenes/training_room/training_target_panel.gd`
(`class_name TrainingTargetPanel extends PanelContainer`), a "Target" card
with `ArmorSpin` (0-999) and `PoisonResistSpin` (0-100%) rows. Deliberately
narrower than an Adventure enemy panel -- no HP or Required DPS field, since
Training Room measures damage dealt in a fixed window, never "kills" a
target the way an Adventure fight does.

## P2:R11:T4 - Combat Playback View

New `project/scenes/training_room/training_room_combat_view.gd`
(`class_name TrainingRoomCombatView extends PanelContainer`), built directly
on the existing reusable `CombatPlayback` class
(`project/scripts/ui/combat_playback.gd`) rather than duplicating its timing
logic. Shows a "Damage Dealt" readout (not an HP bar, since Training Room
targets have no HP pool to draw down), a skill-popup layer, and
speed/skip controls (`SPEED_OPTIONS := [1.0, 2.0, 4.0]`). The Fight button
(`training_room.gd`, node name `"FightButton"`) now sits centered directly
under this view, alongside a new "Combat Log" button, instead of spanning
the full screen width.

## P2:R11:T5 - Gear Editor Rarity-First Rework

`TrainingRoomState` gained `set_slot_rarity(item, tier)`,
`set_affix_stat(item, index, stat)`, and `clear_slot(item)`, replacing the
original `P2:R10:T4` raw add/remove-affix flow. The UI side builds a
`RarityOption` `OptionButton` per slot (`None`/`Basic`/`Master`/`Cursed`,
plus `Legendary` on the weapon slot only) instead of free-form stat/
operation/value rows -- matching how real generated gear actually looks,
while keeping the auto-filled tier value in an editable field per the
locked-in design (see `P2:R11:T7`'s "None" rarity note and stuck-disabled
fix below).

## P2:R11:T6 - Dashboard Layout Parity

- **3-column layout, 1:2:1 ratio:** `training_room.gd`'s top-level `Columns`
  `HBoxContainer` (`LeftColumn`/`CenterColumn`/`RightColumn`) uses
  `size_flags_stretch_ratio` of `1.0`/`2.0`/`1.0` respectively, matching
  Adventure's `combat_screen.gd` dashboard proportions instead of an earlier
  even 1:1:1 split that squeezed the center combat column.
- **Combat Log button + overlay:** `_view_log_button` ("Combat Log", disabled
  until the first fight) opens `_build_log_overlay()`'s dimmed backdrop +
  centered `PanelContainer` holding a `RichTextLabel` result log (matching
  the same "click to view details" pattern Adventure uses) instead of an
  always-visible result text block.
- **Shared 10-skill rotation cap:** `build_resolver.gd` gained
  `const MAX_ROTATION_SIZE := 10`, enforced once in `resolve_rotation()` as a
  single chokepoint used by both `BuildState.set_rotation()` (Adventure) and
  `TrainingRoomState.set_rotation()` (Training Room), so a build can no
  longer construct an absurdly long macro on either screen. Covered by
  `project/tests/rotation_cap_test.gd`.
- **Legendary hover tooltip:** `_legendary_tooltip(item)` builds a tooltip
  with the item's affix lines first, then its flavor/effect line last (via
  `_legendary_effect_text(item)`), set on the weapon Legendary dropdown so a
  player can compare Legendaries without equipping each one first.

## P2:R11:T7 - Combat Feel Fixes

- **Taller, dark combat window:** `training_room_combat_view.gd`'s
  `PANEL_MIN_HEIGHT` raised to `420` (from the original `220`), with a
  near-black `UIColors.PANEL_DEEP` background.
- **Live status readout:** `_update_status_readout()` shows
  `"Armor: %d | Resist: %.0f%%"` plus live chips for poison stacks/armor
  shred/resist reduction, updated on every playback event -- a player
  watching the fight can now see pressure building in real time instead of
  only reading the final text recap.
- **Background image:** a `Training_Room_background.jpg` texture (with a
  `Color(0,0,0,0.42)` tint) now sits behind the combat view, matching the
  photographic-background treatment already used for Adventure's story/map/
  contract overlays.
- **Proc-highlighted popups:** legendary-triggered casts now spawn a visually
  distinct popup kind (see `P2:R11:T9`... actually shared with the Adventure
  fix below) colored `UIColors.TEXT_MAGIC`, so "this damage came from a
  Legendary proc" reads at a glance instead of blending into normal hits.
- **0-damage-tick-at-0-stacks fix:** `combat_resolver.gd`'s
  `_resolve_poison_tick()` only applies damage/decrement `if active_stacks >
  0`; the Training Room playback view additionally only spawns a popup
  `if event.damage > 0.0`, so a poison tick firing before any stack has
  landed no longer shows a misleading "0 damage" popup.
- **Stuck-disabled rarity dropdown fix:** the per-slot Rarity `OptionButton`
  used to get disabled while a Legendary was equipped, with no way back to
  Basic/Master/Cursed short of restarting Training Room. Fixed by keeping it
  enabled in Legendary mode; re-selecting any rarity now routes through
  `_on_rarity_selected()`, which calls `TrainingRoomState.use_custom_weapon()`
  to switch back off the Legendary first.
- **"None" rarity option:** a sentinel `NONE_RARITY_ID` item added as the
  first Rarity dropdown entry, calling `TrainingRoomState.clear_slot(item)`
  to empty a slot's affixes entirely -- lets a player test an intentionally
  bare slot instead of always being forced into at least Basic.

## P2:R11:T8 - Mithril Karambit Per-Skill Trigger Fix

Mithril Karambit's two `TriggeredSkillEffect`s (one tied to Stab, one to
Heavy Slash) were bleeding into each other -- either skill's cast could fire
either trigger. Fixed at the data and engine level together:
`mithril_karambit.tres`'s two triggers now each carry a `source_skill_ids`
`PackedStringArray` (`["skill.stab"]` and `["skill.heavy_slash"]`
respectively), and `combat_resolver.gd`'s `_trigger_matches_source()` only
fires a trigger when `source_skill_ids` is empty (untargeted, existing
behavior for other triggered effects) or contains the casting skill's id.

## P2:R11:T9 - Adventure Overlay Reflow Fix

Found while comparing Training Room's new overlay patterns against
Adventure's existing ones: `combat_screen.gd`'s shop and reward-choice
overlays were `PanelContainer`s added directly into `_combat_content`'s
`VBoxContainer` flow, so opening either one grew that container's height and
pushed sibling panels off-screen. The victory overlay and map overlay
already used the correct pattern. Fixed by converting the shop and
reward-choice overlays to true full-rect root-level overlays
(`set_anchors_preset(Control.PRESET_FULL_RECT)`, added at the scene root),
matching `_build_map_overlay()`/`_build_victory_overlay()`'s existing shape.
This is an Adventure-dashboard bug, not a Training Room one -- recorded here
because it was found during this pass, not because it's in scope for
`P2:R10`'s Training Room feature set.

## P2:R11:T10 - Regression + Docs

The full `project/tests/*.gd` suite (38 files as of this milestone, including
`training_room_combat_view_test.gd` -- new for `T4` -- alongside the 5
Training Room tests from `P2:R10`) passed clean after this pass's changes.
This document, `docs/Phase_2_Milestones.md`, and
`docs/Phase_2_R10_Full_Training_Room_Parity.md` (a pointer note, since its
"Scope Decisions" section describes the now-superseded raw affix editor and
toggle-button tree row) were updated.

## Implementation Notes

2026-07-23:

- Investigated the running Training Room hands-on before writing any code and
  compared it screen-by-screen against the real Adventure dashboard; the
  resulting gap list became `T1`-`T5` above, refined into a short plan before
  implementation (canvas scaling, tree dropdowns, target card, a dedicated
  Training-Room-only combat playback view built on the existing
  `CombatPlayback` class rather than refactoring `combat_screen.gd`'s
  entangled rendering, and the rarity-first gear rework). `T1`-`T5` were
  implemented and regression-tested in that order, per the original plan's
  stated implementation order (canvas scaling first since it's independent
  and benefits everything; gear editor rework last since it was the largest
  and most test-impacting).
- Further hands-on passes surfaced `T6`-`T9` iteratively: layout parity
  (3-column, then corrected to 1:2:1 after an initial even split squeezed the
  combat column), the Combat Log overlay, the shared rotation cap, the
  Legendary tooltip, then a cluster of feel/bug fixes found while watching
  real fights play out in the new combat view (dark/taller window with a
  live readout, background image, proc highlighting, the 0-stack poison-tick
  popup, the stuck-disabled rarity dropdown, the "None" rarity option, the
  Mithril Karambit cross-skill trigger leak, and the Adventure overlay-reflow
  bug). Each landed with its own regression pass rather than batching fixes
  before testing.
- The full regression suite was rerun after every numbered task, per this
  project's established practice; all runs passed clean by the time `T10`
  closed this milestone out.
