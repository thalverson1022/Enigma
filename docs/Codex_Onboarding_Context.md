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
   - Defines the revised milestone sequence `P2:R1` through `P2:R8`.
   - Current immediate implementation milestone is `P2:R5`.

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

The next milestone is:

> **P2:R5 - Run Rules And Determinism**

This is the next implementation milestone after the completed R4 contract
route parity work.

The purpose is to add visible Adventure seed handling, deterministic
run-context RNG, failure/retry polish, and explicit contract victory/failure
state transitions over the now-connected Tavern and Gilded Serpent route.

Scope update from 2026-07-17: R5 now also includes the remaining Rogue
tree/proc parity needed before deterministic run rules can be considered
complete. Shadow has been implemented as the third Rogue subclass, Thief's
missing `Opportunity Strikes` trigger has been restored using the generic
triggered-skill support added in R4, and visible Adventure seed state is now
stored/displayed. Deterministic RNG context routing for combat, shop offers,
generated reward choices, and generated item IDs is also complete. Failure
tracking and explicit run outcome state are also complete: Tavern encounters
allow one do-over, a second Tavern failure requires a seed-preserving
Adventure restart from class select, contract route failure marks the contract
failed, and Vyra victory marks contract victory. The next active R5 task is
UI feedback polish for those states.

Default R5 scope:

- Add Opportunity Strikes proc behavior and route it through deterministic
  proc RNG.
- Add visible run seed state.
- Route combat, generated reward choices, shop offers, and special procs
  through stable run-context RNG.
- Restore or deliberately revise first-failure do-over and second-failure
  restart/contract-failure rules.
- Make contract victory/failure explicit run states.
- Keep required Phase 2 Legendary scope to the Knives pair already added in
  R4: Wyvern Kriss and Mithril Karambit. Other authored Legendary weapons stay
  deferred unless route reward scope is explicitly expanded.
- Keep save/load and broad UI polish scoped to later revised milestones.

Use `docs/Phase_2_R5_Run_Rules_And_Determinism.md` as the working file.
Use `docs/Phase_2_R1_Adventure_Parity_Audit.md` and
`docs/Phase_2_R4_Contract_Route_Parity.md` as completed scope context, not as
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
- Subclass select with Assassin/Thief active, Shadow disabled.
- Persistent combat dashboard.
- Talent panel.
- Available skills panel.
- Skill build/rotation panel.
- Character stats panel.
- Enemy panel using fixed Mouthy Drunk target.
- Gear panel with auto-rolled/rerollable gear.
- Lock build -> fight -> combat log/victory recap.

Dormant or partially disconnected pieces:

- `RunFlow` fixed encounter ladder.
- Encounter resources.
- Tavern shop scene.
- Run end scene.
- Earlier wizard-style full-loop flow, replaced by dashboard structure.

Revised roadmap closeout:

- `P2:R1 - Adventure Parity Audit` is complete as of 2026-07-16.
- `P2:R2 - Dashboard Loop Reconnection` is complete as of 2026-07-16.
- `P2:R3 - Reward, Shop, And Gear Parity` is complete as of 2026-07-16.
- `P2:R4 - Contract Route Parity` is complete as of 2026-07-16.
- The audit confirmed the active dashboard direction should stay.
- The next build order is `P2:R5` run rules/determinism, then `P2:R6`
  save/load, `P2:R7` game-like UI pass, and `P2:R8` playtest build.
- Phase 3+ deferrals are recorded in `phase3_ideas.md`.

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
- Full Training Room mode is Phase 3+, but a compact Training Room Lite is an
  optional `P2:R8` playtest-support task if it does not delay the Rogue
  Adventure build.
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
7. If continuing `P2:R5`, start with UI feedback for the new loss/retry,
   Adventure restart, contract failed, and contract victory states, then audit
   proc determinism before touching save/load or the full game-like UI pass.

## Notes For Future Codex

- Be careful with the `P2:R*` naming: `R` means revised roadmap, not Phase 1.
- The user is intentionally recalibrating scope. Help keep ambition structured
  rather than shrinking the goal back to the old lightweight port.
- When a change smells like Phase 3, classify it explicitly instead of
  silently building it.
- When a feature exists in Phase 1 but is changed for Project Bane, document
  the reason.
