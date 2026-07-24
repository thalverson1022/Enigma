# Codex Onboarding Context

Use this document as the starting point when a new Codex conversation begins
for Project Bane.

## Current Project Frame

Project Bane is a Godot 4.x/GDScript port and expansion of the validated
Project Abaddon Phase 1 React prototype.

The Phase 2 goal was revised on 2026-07-15. The current target is no longer a
very light Godot vertical slice. The target is:

> Phase 1 Rogue adventure parity in Godot, plus a more game-like UI.

In practice, this means the current Phase 2 should rebuild the proven Rogue
adventure experience from Phase 1: class/subclass/build planning, automated
DPS-window combat, Tavern progression, rewards, shop/gear, first contract
route, deterministic run behavior, failure/retry rules, save/load, and a
shareable playtest build. It does **not** mean building the whole imagined
game, all classes, additional contracts, full art/animation production, or a
large procedural meta-progression layer.

## Read These First

Read these docs before implementing anything substantial:

1. `docs/Phase_2_Milestones.md`
   - Current revised roadmap.
   - Historical M0-M7 notes.
   - Defines the revised milestone sequence `P2:R1` through `P2:R12`, all
     now complete.
   - No active implementation milestone remains; the only open item is a
     non-blocking re-export/re-smoke-test of the Windows build (see below).

2. `docs/Phase_2_R1_Adventure_Parity_Audit.md`
   - Completed audit milestone: `P2:R1 - Adventure Parity Audit`.
   - Contains the Phase 1 baseline, current Godot inventory, parity matrix,
     gap lists, revised/cut decisions, and compact roadmap for `P2:R2`
     through `P2:R8`.

3. `docs/Phase_2_R2_Dashboard_Loop_Reconnection.md`
   - Completed implementation milestone: `P2:R2 - Dashboard Loop
     Reconnection`.
   - Use this as closeout context for the connected dashboard loop that R3
     replaced with real reward/shop/gear progression.

   Remaining revised roadmap tracking docs:
   - `docs/Phase_2_R3_Reward_Shop_Gear_Parity.md`
   - `docs/Phase_2_R4_Contract_Route_Parity.md`
   - `docs/Phase_2_R5_Run_Rules_And_Determinism.md`
   - `docs/Phase_2_R6_Save_Load_Persistence.md`
   - `docs/Phase_2_R7_Game_Like_UI_Pass.md`
   - `docs/Phase_2_R8_Playtest_Build.md`
   - `docs/Phase_2_R9_Full_Legendary_Item_Parity.md`
   - `docs/Phase_2_R10_Full_Training_Room_Parity.md`
   - `docs/Phase_2_R11_Training_Room_UI_Polish.md`
   - `docs/Phase_2_R12_Gear_Icon_Art_Integration.md`

4. `docs/DPS_Engine_Phase2_Context.md`
   - Game vision, combat philosophy, technical principles, and working
     agreements.
   - Includes the 2026-07-15 scope revision.

5. `docs/Conventions.md`
   - Repository layout, naming rules, data-driven content policy, and UI
     architecture principle.

6. Phase 1 reference docs under `docs/Phase 1 Context Docs/`
   - `Phase_1_Design_Recap.md`
   - `Current_Mechanics_Reference.md`
   - `Content_Library_Reference.md`
   - `Balance_Baseline_Report.md`

The Phase 1 docs are now the design/content parity reference for the first
Rogue adventure. They are not an implementation architecture to copy.

## Current Next Milestone

`P2:R8 - Playtest Build` is complete (`T1`-`T8` done, `T9` superseded,
`T10` closed out -- see `docs/Phase_2_R8_Playtest_Build.md`). The user's own
hands-on Smoke Test Protocol pass against the exported Windows build (seed
`123456`, 2026-07-21) found no blockers, but raised a question about
Legendary variety that led to a deliberate second Phase 2 scope revision:
two items previously placed on the Phase 3+/optional-only side of the
boundary (the 3 Legendaries beyond the Knives pair, and full Training Room
mode) are now back in Phase 2 scope. See
`docs/Phase_2_Milestones.md`'s "Revised Phase 2 Boundary" section's
2026-07-21 addendum for the full framing.

`P2:R9 - Full Legendary Item Parity` is now complete
(`docs/Phase_2_R9_Full_Legendary_Item_Parity.md`, `P2:R9:T1`-`T8`). All 5
Phase 1 Rogue Legendaries exist (Wyvern Kriss, Mithril Karambit, Bandit
Blade, Umbral Stiletto, Bejeweled Push Dagger), Knives now offers a seeded
random choice of 2 of the 5 (`EncounterReward.legendary_choice_pool`/
`legendary_choice_count`, sampled in
`BuildState._gear_choices_for_reward()`), and the shop's existing
low-chance Legendary drop (`build_state.gd`'s
`CONTRACT_SHOP_LEGENDARY_WEIGHT`) now rolls from all 5 with an ownership
dedupe (`_unowned_shop_legendary_paths()`, falling back to `CURSED` tier if
every Legendary is already owned). Three small new engine mechanics needed
one per missing Legendary, everything else reusing existing affix stat
types:
- Bandit Blade: a **gold-scaling flat physical damage bonus**
  (`GearItem.physical_damage_per_gold` / `PlayerStats.bonus_physical_damage`,
  reads live current gold at resolve time).
- Umbral Stiletto: **gear-granted skill unlocks**
  (`GearItem.unlocked_skills`, extending `resolve_unlocked_skills()`
  alongside the existing tree/talent unlocks) -- unlocks Death Strike
  regardless of chosen talents.
- Bejeweled Push Dagger: a **minimum-cast-time proc**
  (`GearItem.min_cast_time_proc_chance`, a seeded per-cast roll in
  `CombatResolver.resolve()` that substitutes `skill.min_execution_ms` for
  the normal scaled cast time).

All 30 `project/tests/*.gd` files passed clean after every `P2:R9` change.

`P2:R10 - Full Training Room Parity`
(`docs/Phase_2_R10_Full_Training_Room_Parity.md`) is also now complete
(`P2:R10:T1`-`T8`). This supersedes `P2:R8:T9`'s optional "Training Room
Lite" -- the user chose the full Phase 1 Training Room instead: a separate
seed, up to 2 freely-toggleable active trees + passives, a **raw affix
editor** (deliberately chosen over the lower-risk tiered-generator-reuse
option), all 5 Legendaries directly selectable (with a Custom/Legendary
toggle on the weapon slot), rotation, target (the 3 new seeded practice
Monsters), combat duration, practice gold, and a Fight button that runs a
real `CombatResolver` fight with the result shown via the reused
`CombatResultFormatter`/`CombatRecap` presentation -- all without ever
touching real Adventure/save state.

Building `P2:R10:T3` required parameterizing 4 shared dashboard panels
(`talent_panel.gd`, `available_skills_panel.gd`, `skill_build_panel.gd`,
`character_stats_panel.gd`) to accept an injected state object (a new
`TrainingRoomState`, never an autoload) instead of hardcoding the
`BuildState` singleton -- literal unmodified reuse would have let Training
Room mutations leak into a real Adventure run. Each task's own tests caught
and fixed real bugs before landing, including two genuine, standing gaps
unrelated to this effort's prior work: `save_load_ui_test.gd` had hardcoded
the Training Room button as permanently disabled, and
`character_stats_panel.gd` was never updated when `P2:R9` added
`bonus_physical_damage`/`min_cast_time_proc_chance` to `PlayerStats` --
both fixed, benefiting the real Adventure dashboard as well as Training
Room. The full regression suite (36 `project/tests/*.gd` files, including 5
new dedicated Training Room tests) passed clean throughout.

With `P2:R9` and `P2:R10` both complete, the revised Phase 2 roadmap
(`P2:R0`-`P2:R10`) was fully closed out as of 2026-07-21.

Two further UI/polish milestones landed on top of that closed roadmap:

`P2:R11 - Training Room UI Polish`
(`docs/Phase_2_R11_Training_Room_UI_Polish.md`, complete 2026-07-23) is a
follow-on pass bringing the just-finished `P2:R10` Training Room up to
Adventure-dashboard look/feel: global canvas scaling
(`project.godot`'s `[display]` stretch mode, so the whole UI now scales
uniformly with the window), Primary/Secondary tree dropdowns, a dedicated
target stats card, a real animated combat-playback view (built on the
existing `CombatPlayback` class) replacing the static-text-only recap, a
rarity-first gear editor (replacing `P2:R10`'s raw affix editor), a
3-column (1:2:1) layout matching Adventure, a Combat Log overlay, a
10-skill rotation cap shared with Adventure, and a Legendary hover tooltip.
Also fixed several real bugs found along the way, including one in
Adventure itself: the shop/reward-choice overlays grew their parent
container instead of rendering as true full-rect overlays, pushing sibling
panels off-screen.

`P2:R12 - Gear Icon Art Integration`
(`docs/Phase_2_R12_Gear_Icon_Art_Integration.md`, complete 2026-07-24)
integrates a folder of user-supplied 32x32 transparent gear art
(`project/assets/Items/Rogue/`) into every gear box in the Adventure
dashboard (shop offers, reward-choice cards, inventory slots, equipped
Equipment-doll slots) -- the "icon-pack integration" `P2:R7` explicitly
deferred. Named art for the 5 Legendaries and Lucky Coin, a shared generic
icon per slot/tier for everything else, layered over the existing
tier-colored backgrounds. The redundant slot/tier caption text every box
used to show below the icon was then removed as duplicate information.

The full `project/tests/*.gd` regression suite (38 files as of `P2:R12`)
passed clean after both milestones. The only remaining open item is
non-blocking: the exported Windows build at
`project/export/windows/ProjectBane.exe` predates `P2:R9` through `P2:R12`
and needs a re-export plus a re-smoke-test before being shared as a build
that includes them.

Use `docs/Phase_2_R9_Full_Legendary_Item_Parity.md` through
`docs/Phase_2_R12_Gear_Icon_Art_Integration.md` (and
`docs/Phase_2_R5_Run_Rules_And_Determinism.md` through
`docs/Phase_2_R8_Playtest_Build.md`) as completed scope context, not as
active task lists.

## Current Godot Project Shape

Repo root:

- `Project-Bane/`

Godot project root:

- `project/`

Important active files:

- `project/project.godot`
  - Main scene: `res://scenes/game_root.tscn`
  - Autoload: `BuildState`

- `project/scripts/autoload/build_state.gd`
  - Shared run/build state.

- `project/scenes/game_root.gd`
  - Current top-level flow:
    `Title -> Class Select -> Subclass Select -> Combat Dashboard`

- `project/scenes/combat/combat_screen.gd`
  - Current persistent dashboard.

Important systems:

- `project/scripts/systems/build_resolver.gd`
- `project/scripts/systems/combat_resolver.gd`
- `project/scripts/systems/damage_calculator.gd`
- `project/scripts/systems/combat_timing.gd`
- `project/scripts/systems/gear_generator.gd`
- `project/scripts/systems/passive_allocator.gd`
- `project/scripts/systems/run_flow.gd`

Important data/resource areas:

- `project/scripts/resources/`
- `project/data/classes/`
- `project/data/subclass_trees/`
- `project/data/talents/`
- `project/data/skills/`
- `project/data/gear/`
- `project/data/monsters/`
- `project/data/encounters/`
- `project/data/player/`

## Current Implementation Reality

The working tree currently contains much more than the committed git history.
As of the last reconnaissance pass, git history only clearly reflected early
P2:M0 work, while M1-M5 and the dashboard restructure existed as working-tree
changes. Treat the working tree as current reality unless the user says
otherwise.

Current active experience:

- Title screen.
- Class select with Rogue active, Mage/Crusader disabled.
- Subclass select with Assassin/Thief/Shadow active.
- Persistent combat dashboard.
- Talent panel.
- Available skills panel.
- Skill build/rotation panel.
- Character stats panel.
- Enemy panel using the current Tavern encounter or selected contract route
  node.
- Gear panel showing earned inventory/equipment from rewards, shops, and
  Legendary choices, with real icon art (`P2:R12`) over each box's
  tier-colored background instead of a plain colored square.
- Training Room: a full freeform practice mode (`P2:R10`) with an
  Adventure-dashboard-matching 3-column layout, animated combat playback,
  and a rarity-first gear editor (`P2:R11`).
- Connected Tavern -> reward/shop -> contract offer -> secondary subclass ->
  route choice -> Knives Legendary reward -> Vyra flow.
- Save/load UI: Continue Adventure, Save & Quit, Abandon Run, and restart/new
  Adventure handling.
- Styled dashboard header, combat HUD/playback, combat recap, route/reward/shop
  overlays, and explicit retry/failure/victory state presentation.

Dormant or partially disconnected pieces:

- Tavern shop scene.
- Run end scene.
- Earlier wizard-style full-loop flow, replaced by dashboard structure.

Revised roadmap closeout:

- `P2:R1 - Adventure Parity Audit` is complete as of 2026-07-16.
- `P2:R2 - Dashboard Loop Reconnection` is complete as of 2026-07-16.
- `P2:R3 - Reward, Shop, And Gear Parity` is complete as of 2026-07-16.
- `P2:R4 - Contract Route Parity` is complete as of 2026-07-16.
- `P2:R5 - Run Rules And Determinism` is complete as of 2026-07-17.
- `P2:R6 - Save/Load Persistence` is complete as of 2026-07-17.
- `P2:R7 - Game-Like UI Pass` is complete as of 2026-07-19.
- `P2:R8:T1 - Define Playtest Scope` is complete as of 2026-07-19.
- `P2:R8:T2 - Run Full Regression Pass` is complete as of 2026-07-19.
- `P2:R8:T3 - Fix Critical Bugs` is complete for the T2 pass as of
  2026-07-19 because no blocking production issue was found.
- `P2:R8:T4 - Prepare Export Settings` is complete as of 2026-07-19.
- `P2:R8:T5 - Export Build` is complete as of 2026-07-19.
- `P2:R8:T6 - Smoke Test Export` is complete as of 2026-07-21, via the user's
  hands-on Smoke Test Protocol pass (seed `123456`); no blockers found.
- `P2:R8:T7 - Prepare Playtest Notes` is complete as of 2026-07-21.
- `P2:R8:T8 - Record Known Issues` is complete as of 2026-07-21.
- `P2:R8:T9 - Add Training Room Lite (Optional)` is superseded as of
  2026-07-21 by the full Training Room now scoped as `P2:R10`.
- `P2:R8:T10 - Update Docs` is complete as of 2026-07-21. `P2:R8` is fully
  closed out.
- The audit confirmed the active dashboard direction should stay.
- Scope revision (2026-07-21): `P2:R9 - Full Legendary Item Parity` and
  `P2:R10 - Full Training Room Parity` were added, moving two previously
  Phase-3+/optional items back into Phase 2. See
  `docs/Phase_2_R9_Full_Legendary_Item_Parity.md` and
  `docs/Phase_2_R10_Full_Training_Room_Parity.md`.
- `P2:R9 - Full Legendary Item Parity` is complete as of 2026-07-21
  (`P2:R9:T1`-`T8`). All 5 Legendaries exist, Knives randomizes its choice,
  the shop's Legendary pool covers all 5 with an ownership dedupe, and the
  full 30-file regression suite passed clean throughout.
- `P2:R10 - Full Training Room Parity` is complete as of 2026-07-21
  (`P2:R10:T1`-`T8`). Full freeform build/gear/target/fight controls,
  reusing 4 parameterized dashboard panels plus a new `TrainingRoomState`,
  a raw affix editor, and a Fight button using the real `CombatResolver`/
  `CombatResultFormatter`. The full 36-file regression suite (including 5
  new dedicated Training Room tests) passed clean throughout.
- `P2:R11 - Training Room UI Polish` is complete as of 2026-07-23. Brought
  Training Room up to Adventure-dashboard look/feel (canvas scaling,
  dropdown tree selection, target card, animated combat playback, 3-column
  1:2:1 layout, Combat Log overlay, shared rotation cap, Legendary tooltip,
  rarity-first gear editor) and fixed several real bugs found along the way,
  including an Adventure-dashboard overlay-reflow bug. See
  `docs/Phase_2_R11_Training_Room_UI_Polish.md`.
- `P2:R12 - Gear Icon Art Integration` is complete as of 2026-07-24.
  Integrated user-supplied gear art into every Adventure gear box (shop,
  reward-choice, inventory, equipped slots) and removed the now-redundant
  caption text once the icon art made it unnecessary. See
  `docs/Phase_2_R12_Gear_Icon_Art_Integration.md`.
- No active milestone remains in the revised `P2:R0`-`P2:R12` roadmap. The
  only open item is a non-blocking Windows re-export/re-smoke-test to
  include `P2:R9` through `P2:R12` (the current export predates all four).
- Remaining Phase 3+ deferrals are recorded in `phase3_ideas.md`.

## Test Commands

Godot is installed at:

`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`

Use the explicit executable path; `godot` is not guaranteed to be on PATH.

Run tests serially. Parallel Godot runs previously collided on `user://logs`
and crashed. Use `--log-file` if running several tests in one session.

Known passing tests from the last reconnaissance pass:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless -s res://tests/combat_test.gd
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless -s res://tests/engine_mechanics_test.gd
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless -s res://tests/gear_generator_test.gd
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless -s res://tests/passive_allocator_test.gd
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless -s res://tests/combat_screen_test.gd
```

These tests may print Godot cleanup warnings about leaked ObjectDB/resource
instances even when assertions pass and exit code is `0`.

## Important Scope Boundaries

In revised Phase 2:

- Phase 1 first-contract route shape is in scope.
- Larger procedural/meta Contract Run systems are Phase 3+.
- Additional classes beyond Rogue are Phase 3+ unless explicitly rescoped.
- Additional contracts beyond the first proven route are Phase 3+.
- Full Training Room mode is in scope and complete as `P2:R10` (2026-07-21
  revision -- no longer Phase 3+, and no longer just an optional "Lite"
  version), further polished to Adventure-dashboard parity as `P2:R11`
  (2026-07-23).
- All 5 Phase 1 Legendaries are in scope and complete as `P2:R9` (2026-07-21
  revision -- no longer deferred to just the Knives pair).
- Full art/animation/polish production is later work.
- Game-like UI clarity is in scope.
- Data-driven content remains mandatory.
- Avoid hardcoding game content in GDScript logic.

## Suggested First Actions In A New Conversation

1. Read this file.
2. Read `docs/Phase_2_R2_Dashboard_Loop_Reconnection.md`.
3. Skim `docs/Phase_2_R1_Adventure_Parity_Audit.md` for completed audit
   context and milestone boundaries.
4. Read `docs/Phase_2_Milestones.md` scope revision and revised roadmap.
5. Check `git status --short`.
6. Inspect the current Godot project shape if implementation work is being
   requested.
7. The revised `P2:R0`-`P2:R12` roadmap is fully complete. If the user asks
   what's next, the only outstanding item is a non-blocking Windows
   re-export/re-smoke-test to include `P2:R9` through `P2:R12` -- otherwise,
   any new work is a fresh scope decision, not a continuation of an existing
   milestone; classify it explicitly (Phase 2 addendum vs. Phase 3+) rather
   than silently building it, per the note below.

## Notes For Future Codex

- Be careful with the `P2:R*` naming: `R` means revised roadmap, not Phase 1.
- The user is intentionally recalibrating scope. Help keep ambition structured
  rather than shrinking the goal back to the old lightweight port.
- When a change smells like Phase 3, classify it explicitly instead of
  silently building it.
- When a feature exists in Phase 1 but is changed for Project Bane, document
  the reason.
