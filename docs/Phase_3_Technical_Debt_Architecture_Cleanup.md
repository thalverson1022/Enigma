# Phase 3 Technical Debt: Architecture & Code Quality Cleanup

## Purpose

This document is the tasking and status doc for cleaning up the Section 1
("Architecture & Code Quality") findings from the 2026-07-30 adversarial
assessment of Project CrystalMaiden. It exists so any future session can pick
up this work without re-deriving the analysis, per the project's own working
agreement that implementation work should start with Task 0 planning and keep
its tasking doc updated as it progresses.

This work is cross-cutting technical debt, not new player-facing content. It
does not have a milestone number in `Phase_3_CrystalMaiden_Milestones.md`
because it cuts across whichever milestone happens to be active. Treat it as
an interstitial track: pick up pieces of it opportunistically between/within
milestones rather than blocking milestone work on it, except where a phase
below explicitly recommends doing it first.

## Status

Phases 1, 2, and 3 complete (2026-07-30). Phases 4-7 not started.

**Phase 3 result:** all 8 overlays extracted into their own scenes.
`combat_screen.gd` went from **3,564 lines to 2,157** (-40%). Verified after
every single extraction with the full 39-test suite; Balance Lab held at
19 pass / 0 warn / 0 fail throughout. No behavior change.

## Known Gotchas For Remaining Phase 3 Extractions

**1. Untyped-overlay-var `:=` parse error.** Every extracted overlay var on
combat_screen.gd (`_log_overlay`, `_talent_overlay`, `_story_overlay`,
`_secondary_subclass_overlay`, `_reward_choice_overlay`, `_shop_overlay`) is
declared **untyped** (`var _foo`, no `: Control`) so combat_screen.gd can call
each scene's custom public methods/signals on it -- GDScript won't let a
statically-typed `Control` var call a method `Control` doesn't declare.

The trap: assigning the *result* of one of those custom method calls with
`:=` fails to compile, because GDScript can't infer a type from an untyped
(effectively `Variant`) expression. This shipped once during the
Reward-Choice extraction (`var options_container := _reward_choice_overlay.
options_container()` at combat_screen.gd:2255) and silently broke the whole
screen -- `combat_screen.gd` failed to parse, which surfaced as
`build_panels_test.gd` hanging for 36+ minutes instead of failing fast, not as
an obvious error. Always give an explicit static type instead:
`var options_container: HBoxContainer = ...`.

**2. Missed test call sites to a moved private helper don't fail fast either.**
When a private helper function moves from combat_screen.gd into an extracted
overlay scene, every direct test call to it (`combat_screen._some_helper(...)`)
must become `combat_screen._some_overlay._some_helper(...)`. Missing one is a
*runtime* "Invalid call: Nonexistent function" error, not a parse error, but
it still manifested as another 30+ second hang rather than a clean test
failure (`reward_shop_route_ui_test.gd:111` still called
`combat_screen._make_shop_offer_row(...)` after that function moved to
`shop_overlay.gd` during the Shop extraction). **After moving any function out
of combat_screen.gd, grep every test file for its bare name before declaring
the extraction done** -- a single missed reference is currently the most
likely failure mode in this whole effort, and neither class of mistake fails
loudly.

**3. An extracted overlay that touches an autoload cannot declare a
`class_name`, and its script must not be `preload()`ed either.** Global-class
scripts are compiled during Godot's project scan, before autoloads are
registered, so `class_name ContractOverlay` on a script referencing
`BuildState` fails with "Identifier not found: BuildState" -- and that
compile failure cascades: `combat_screen.gd` then fails to attach its own
script, surfacing as yet another hang rather than a clear error.
`preload("res://.../contract_overlay.gd")` (the script, not the `.tscn`)
triggers the same premature compile, including from a test file. Preloading
the **`.tscn`** is fine.

Consequence for design: an extracted overlay's enums/constants can't be
reached via `SomeClass.MEMBER` from combat_screen.gd. Two workable options --
(a) access constants through the *instance* (`_some_overlay.SOME_CONST`),
which works and is what the tests do, or (b) don't send the enum across the
boundary at all. The Contract extraction chose (b), replacing a single
`action_pressed(step)` signal with two semantic signals
(`accept_requested`/`route_requested`); that turned out cleaner anyway, since
combat_screen.gd only ever cared about two of the four steps.

**All three gotchas share one trait: none of them fail loudly.** Each one
manifested as a multi-minute hang, not an error. The mitigation that actually
worked was, after every extraction: (1) run the single most-affected test
alone with a short timeout *before* the full suite, and (2) grep `tests/*.gd`
exhaustively for every symbol moved or renamed. Step (2) caught two stale
`_route_tradeoff_text` call sites during the Map extraction that would
otherwise have hung the suite.

## Source

Findings below are drawn from Section 1 of the adversarial assessment
delivered 2026-07-30 (code review of `combat_screen.gd`, `combat_stage.gd`,
`save_system.gd`, `training_room_state.gd`, `balance_lab.gd`, `gear_panel.gd`,
plus the core resolvers). That assessment also covered UX/UI, artistic
cohesion, QA, and doc/repo hygiene, which are out of scope for this document
and are not repeated here.

## Guardrails

- Every phase below is a pure refactor with **no intended behavior change**,
  except 1.5 (adds a logged fallback instead of a silent one) and 1.8 (a
  deliberate, recorded policy decision). Any other observed behavior change
  during this work is a regression, not an improvement, and should be treated
  as a bug in the refactor.
- After every step: run the full 39-file headless test suite (not just the
  "focused" subset), not only the tests that obviously relate to the touched
  file, since these changes shift encapsulation boundaries. Run Balance Lab
  for anything touching resolvers, resources, or build/gear data.
- Commit one logical extraction/fix at a time so a regression is bisectable.
- Do not build speculative machinery for problems that do not exist yet (see
  1.4, 1.8, 1.10 below) -- record the decision or defer the generalization
  until the triggering need (a second contract, an imminent save-version
  bump, a third Legendary effect) actually arrives.

## Prioritization (value-per-effort, highest first)

1. **Phase 2 (shared modal-overlay shell)** -- single best move available.
   Small effort, fixes a real player-facing bug today, and is a hard
   prerequisite that makes every Phase 3 overlay extraction cheaper.
2. **1.6 (Balance Lab null-guards)** -- cheapest insurance in the whole list;
   makes the project's regression safety net actually work.
3. **1.3 (encapsulation fixes) and 1.11 (gear tooltip dedup)** -- small, fast,
   each closes a concrete problem that already exists today.
4. **Phase 3 (`combat_screen.gd` decomposition)** -- largest total
   risk-reduction in the codebase, but a multi-session structural investment
   with real regression risk during transition. Highest total value, worst
   value-per-effort of the big items -- sequence it deliberately, don't rush
   it for the sake of a quick win.
5. **Phase 4 (extract inline playback/VFX layer)** -- wait until Milestone 1
   fully closes; it's the most actively-changing part of the file right now.
6. **Phase 5/6/7** -- real but narrow; capture opportunistically alongside
   the milestone each already relates to (see each item's notes).

## Tasking

| Phase | Item | Status | Notes |
|---|---|---|---|
| 1 | 1.3: Fix `enemy_panel.gd` private `_fight_button` reach-in (combat_screen.gd:498) | Complete | Added public `enemy_panel.gd:fight_button()` accessor; combat_screen.gd now reparents through it instead of touching the private field. |
| 1 | 1.3: Replace combat_screen.gd's drifted private `_equipped_item_for_slot()` mirror (~line 2789) | Complete | `BuildState._equipped_item_for_slot()` renamed to public `equipped_item_for_slot()`; combat_screen.gd's mirror deleted, its 2 call sites now call `BuildState.equipped_item_for_slot()` directly. |
| 1 | 1.11: Dedupe gear tooltip formatting (gear_panel.gd:318-325 vs. combat_screen.gd's `_gear_tooltip_lines()` ~2729-2740) | Complete | Added `CardStyle.gear_tooltip_lines()` as the single shared formatter (tier line, affixes, triggered-skill-effect lines). combat_screen.gd's local copy deleted (3 call sites updated); gear_panel.gd's `_gear_tooltip()` now delegates to it -- this also fixes the info-parity bug, since the Gear panel previously omitted the tier name and triggered-skill-effect lines the shop/reward tooltip showed. |
| 1 | 1.6: Add null-guards to Balance Lab content loads (balance_lab.gd:42-79, 190-250) | Complete | `_run_mechanics_checks()` split into one helper per Legendary item, each guarded so a missing `.tres` reports a single failed check instead of crashing the suite. `_run_scenario()` now guards `class_def`/`monster` loads and returns a same-shaped `_failed_scenario_result()` (zeroed aggregate, "fail" status) instead of dereferencing a null. |
| 2 | 1.2/1.1: Build shared `_build_modal_shell(dismissable: bool)` helper | Complete | Added at combat_screen.gd:1306. Builds the full-rect root, backdrop (dismissable `Button` or locked `ColorRect`), and centered bare `PanelContainer`; returns `{"overlay": Control, "panel": PanelContainer}` so each caller still styles its own panel and builds its own content. Victory and Shop are deliberately excluded (see notes below). |
| 2 | Convert log + talent overlays to the shared shell | Complete | Both use `_build_modal_shell(true)`, preserving their existing dismiss-on-click-outside behavior exactly. |
| 2 | Convert story/map/contract/reward-choice/secondary-subclass overlays to the shared shell | Complete | **Product-decision question resolved by reading the actual overlay contents, not asked to the user:** all five gate a real decision (Proceed/route choice/accept-decline/choose reward/choose tree) via an explicit button, and none had defined "cancel" semantics -- Victory's own backdrop confirms the existing pattern (block, don't dismiss) is deliberate for action-gated overlays. All five now use `_build_modal_shell(false)`, preserving current non-dismissable behavior exactly. No behavior change. |
| 3 | Extract log overlay into its own scene+script | Complete | `scenes/combat/log_overlay.gd`/`.tscn`. Public `set_result_text()`. Dismissable (unchanged). |
| 3 | Extract talent overlay into its own scene+script | Complete | `scenes/combat/talent_overlay.gd`/`.tscn`. Wraps `talent_panel.tscn` internally; combat_screen.gd just toggles `.visible`. Dismissable (unchanged). |
| 3 | Extract story overlay | Complete | `scenes/combat/story_overlay.gd`/`.tscn`. Public `proceed_pressed` signal (combat_screen.gd still does `_show_map_overlay(false)` on proceed). Locked/non-dismissable (unchanged). |
| 3 | Extract secondary-subclass overlay | Complete | `scenes/combat/secondary_subclass_overlay.gd`/`.tscn`. Public `show_overlay()` and `tree_chosen(tree)` signal; combat_screen.gd's `_on_secondary_tree_pressed` (status label, recap, contract-overlay reveal, autosave) stays in combat_screen.gd since it's cross-cutting dashboard orchestration, not overlay-internal. Locked (unchanged). |
| 3 | Extract reward-choice overlay | Complete | `scenes/combat/reward_choice_overlay.gd`/`.tscn`. Public `options_container()` accessor -- populating the actual option buttons stays in combat_screen.gd (`_make_reward_choice_button`, `_reward_choice_text`) since it depends on `_build_gear_compare_tooltip()`/`_style_shop_item_box()`, still shared with the not-yet-extracted Shop overlay. Locked (unchanged). Hit and fixed the `:=`-on-untyped-var parse-error gotcha described above. |
| 3 | Extract shop overlay | Complete | `scenes/combat/shop_overlay.gd`/`.tscn`. Resolved the shared-helper problem by promoting `_build_gear_compare_tooltip()`/`_make_tooltip_box()` and `_style_shop_item_box()` to static `CardStyle.build_gear_compare_tooltip(theme_owner, ...)`/`CardStyle.style_shop_item_box(...)`, and promoting the `GearCompareButton` inner class to its own global-class script (`scripts/ui/gear_compare_button.gd`) -- all three were blockers to moving Shop's item-building logic into its own scene while reward-choice's (still in combat_screen.gd) kept working. Public `refresh()`, `set_status_text()`, and `buy_pressed`/`reroll_pressed`/`continue_pressed` signals; combat_screen.gd's `_on_shop_buy_pressed`/`_on_shop_reroll_pressed`/`_on_shop_continue_pressed` stay in combat_screen.gd (autosave, dashboard-chrome toggling). Non-blocking (unchanged). Hit and fixed gotcha #2 above (a missed `reward_shop_route_ui_test.gd` call site). |
| 3 | Extract contract overlay | Complete | `scenes/combat/contract_overlay.gd`/`.tscn`. Owns the `Step` wizard state and advances itself through the two purely-narrative transitions; emits `accept_requested`/`route_requested` for the two steps with cross-cutting effects, which combat_screen.gd still handles (BuildState mutation, secondary-subclass reveal, enemy HUD, route map, autosave). **Two semantic signals instead of one `action_pressed(step)` deliberately, so the enum never crosses the scene boundary** -- see gotcha #3 below for why that mattered. |
| 3 | Extract map overlay | Complete | `scenes/combat/map_overlay.gd`/`.tscn` (640 lines -- by far the largest extraction; renders the Tavern ladder, Contract Offer node, and route schematic from one window). Public `show_map(manual_open)`, `close()`, `clear_tavern_preview()`, `refresh()`; emits `tavern_proceed_pressed`/`contract_offer_pressed`/`route_node_pressed(node)`. Tavern node *previewing* stays internal (local state only); only commits cross the boundary. The hardcoded Gilded Serpent schematic moved as-is -- finding 1.4 is still deliberately deferred, now noted in the new file's header. |
| 3 | Promote `_find_route_node` to `ContractRouteNode.find_by_id()` | Complete | Was private on combat_screen.gd but needed by *both* the contract and map overlays after extraction. Now a static, cycle-safe traversal on the resource itself. (Test files each keep their own local `_find_route_node` helper -- unrelated, untouched.) |
| 4 | Extract inline real-time combat playback/VFX layer (~900 lines, combat_screen.gd consts ~125-193, vars ~296-352, functions ~2925-3216) into/alongside `CombatPlayback` | Not Started | **Do not start until Milestone 1 is fully closed** -- this is the most actively-changing part of the file right now; extracting mid-milestone maximizes merge-conflict risk for no benefit. |
| 5 | 1.9: Move enemy visual-key mapping (combat_stage.gd `ENEMY_VISUAL_KEYS_BY_NAME`, ~176-194) onto the `Monster` resource as authored data | Not Started | Fold into M1:T13 (placeholder-asset-mapping) since it's the same task already in flight. |
| 5 | 1.4: Move contract-route node stage-positions (combat_screen.gd `_make_contract_route_schematic` and helpers, ~1653-1806) from hardcoded script logic onto `ContractRouteNode` resource fields | Not Started | Defer until a second contract actually starts (Milestone 5). Don't generalize for a hypothetical second contract before it exists. |
| 5 | 1.10: Decide a general pattern for Legendary-specific visual effects (currently hardcoded gear-ID branches for Bandit Blade and Wyvern Kriss, split across combat_stage.gd and combat_screen.gd) | Not Started | No urgency at 2 items. Decide (e.g. an optional `visual_effect_id` dispatched through a small registry) before a 3rd Legendary effect is added, not before. |
| 5 | 1.5: Switch Tavern/contract flavor text lookup (combat_screen.gd `TAVERN_ENCOUNTER_FLAVOR_TEXT` etc., ~74-113) from `Monster.display_name` string-matching to id-keyed lookup | Not Started | Low risk, can happen anytime. Removes a silent-fallback-to-generic-text failure mode on enemy rename. |
| 6 | 1.8: Decide and document save-version policy (save_system.gd ~58-59, 160-161) | Not Started | Decision, not a build task: commit to a migration dispatcher, or explicitly document "version bumps wipe saves" as accepted policy. Don't build migration machinery until a version bump is actually imminent. |
| 7 | 1.7: Reduce Balance Lab's hardcoded tuning-value literals (balance_lab.gd ~54-79) that duplicate values already authored on Legendary `.tres` resources | Not Started | Defer to Milestone 7 (Testing Suite And Balance Lab Hardening), which is already scoped for this. |

## Phase Detail

### Phase 1: Quick, isolated wins
Small, mechanical, low-risk fixes with no shared dependencies. Good to do
first for confidence and to shrink the surface area before the bigger cuts.

### Phase 2: Shared modal-overlay shell (Complete)
Converted 7 of the file's 9 overlays (log, talent, story, map, contract,
reward-choice, secondary-subclass) to a shared `_build_modal_shell()` at
combat_screen.gd:1306, removing the duplicated root/backdrop/center/panel
scaffolding. Victory and Shop were deliberately left out of the shell:
Victory overlays only the combat window (not a generic centered card) and
Shop is an intentionally non-blocking overlay by its own documented design
(gear can still be sold from the dashboard while it's open) -- forcing
either into the same shape would have been a bad abstraction, not a
refactor.

This also resolved the original assessment's "5 of 8 don't dismiss on
click-outside, 3 do" framing: on inspection, every non-dismissable overlay
(Victory, Story, Map, Contract, Reward-Choice, Secondary-Subclass) gates a
real decision through its own explicit button (Claim Rewards, Proceed, a
route/contract choice, Accept/Decline, Choose), with no defined "cancel"
semantics -- Victory's backdrop (a `ColorRect` with `MOUSE_FILTER_STOP` and
no click handler, never lumped in with the other 8 in the original count)
already confirms "block, don't dismiss" is the deliberate pattern for
action-gated overlays, not an accident. Log and Talent Trees are the only
two that are pure informational views, and they already dismissed correctly.
So the "inconsistency" was real as duplicated code, but not as a product
bug -- this refactor fixes the former without changing any overlay's actual
dismiss behavior. No behavior change; verified via the full 39-test suite
and Balance Lab (19/0/0) both before and after.

### Phase 3: Decompose `combat_screen.gd` into per-overlay scenes (Complete)
Was the largest file in the project (3,564 lines) and the single biggest
standing architectural risk. All 8 overlays now live in their own
scene+script under `scenes/combat/`, each exposing a narrow public interface
and emitting signals for anything with cross-cutting consequences;
`combat_screen.gd` composes them and owns only the dashboard-level reactions
(BuildState mutation, chrome toggling, autosave). Final: **2,157 lines,
-40%**.

Done overlay-by-overlay, never big-bang, with the full 39-test suite rerun
after each single extraction -- which is what kept three separate
silently-hanging failures (see the gotchas above) to one extraction each
instead of compounding.

Three shared helpers had to be promoted out of `combat_screen.gd` along the
way, because two different extracted scenes needed them:
`CardStyle.build_gear_compare_tooltip()` + `CardStyle.style_shop_item_box()`
(shop and reward-choice), the `GearCompareButton` inner class →
`scripts/ui/gear_compare_button.gd` (same pair), and
`ContractRouteNode.find_by_id()` (contract and map). None of these were in
the original plan; they surfaced as blockers and are genuine improvements in
their own right.

Two overlays intentionally keep a non-standard shape, both documented in
their headers: `shop_overlay.gd` is non-blocking (no backdrop -- gear stays
sellable from the dashboard behind it), and Victory was never a candidate at
all (it overlays only the combat window, not a centered card).

### Phase 4: Extract the inline playback/VFX layer
Move the ~900-line real-time combat playback/VFX block into (or alongside)
the existing `CombatPlayback` class as a proper presenter. Deliberately
sequenced after Phase 3 and after Milestone 1 closes, since this is currently
the most actively-changing part of the file.

### Phase 5: Data-driven fixes for scope/scale problems
Each of these swaps a hardcoded/string-keyed pattern for authored data, but
each is scoped to happen alongside the milestone or trigger event it's
actually tied to (see per-row notes above) rather than as a standalone push.

### Phase 6: Save-version policy
A decision to record now, not a build task to do now.

### Phase 7: Balance Lab literal-duplication
Deferred to Milestone 7, which already owns this kind of hardening.

## Definition Of Done

This document's work is complete when:

- All Phase 1-4 items are resolved and the full test suite + Balance Lab
  pass with no behavior change beyond the two explicitly-flagged exceptions.
- `combat_screen.gd` no longer contains the 8 hand-built overlays inline (they
  live in their own scenes) and no longer contains the inline playback/VFX
  layer.
- The Phase 2 product decision (which overlays dismiss on outside-click) has
  been made and documented, not left as accidental behavior.
- Phase 5/6/7 items are either resolved or explicitly still deferred with a
  recorded reason (matching their "defer until X" condition above).
- This document's tasking table reflects the true current state, updated as
  each row completes.
