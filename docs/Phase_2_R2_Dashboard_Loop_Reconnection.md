# P2:R2 - Dashboard Loop Reconnection

## Purpose

Track the work for **P2:R2 - Dashboard Loop Reconnection**.

The goal is to reconnect the current game-like combat dashboard to real run
progression. The player should no longer fight a single hardcoded Mouthy
Drunk forever; the dashboard should consume run state, advance through the
Tavern encounter sequence, and expose clear post-fight continuation.

This milestone should reconnect the loop with simple reward placeholders where
needed. Full reward/shop/gear parity belongs to `P2:R3`.

## Exit Criteria

P2:R2 is complete when:

- The active dashboard uses `BuildState.current_encounter()` or an equivalent
  run-state source instead of a hardcoded enemy.
- The player can progress through the current Tavern encounter sequence from
  the dashboard.
- Fight result state supports continuing to the next encounter after a win.
- Defeat is represented clearly enough to unblock later failure-rule work.
- The retired wizard flow is not restored as the primary UI path.
- Headless tests drive the active dashboard through multiple encounters.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R2:T1 | Confirm R1 Inputs | Current encounter/progression requirements pulled from the R1 audit | Complete |
| P2:R2:T2 | Define Dashboard Run State | Minimal run-state model for active encounter, result, and continuation | Complete |
| P2:R2:T3 | Replace Hardcoded Enemy Panel | Enemy panel reads current encounter data | Complete |
| P2:R2:T4 | Add Post-Fight Continuation | Win flow advances to planning for the next encounter | Complete |
| P2:R2:T5 | Add Reward Stub | Temporary reward acknowledgement preserves R3 ownership of full rewards | Complete |
| P2:R2:T6 | Reconnect Basic Run End | Final encounter routes to a clear victory/ending state | Complete |
| P2:R2:T7 | Preserve Dashboard Architecture | Control scripts remain presentation/orchestration, not game-logic owners | Complete |
| P2:R2:T8 | Add/Update Tests | Headless dashboard progression test covers multiple encounters | Complete |
| P2:R2:T9 | Update Docs | Mark decisions and any changed boundaries in docs | Complete |

## P2:R2:T1 - Confirm R1 Inputs

Before changing code, read:

- `docs/Phase_2_R1_Adventure_Parity_Audit.md`
- `docs/Phase_2_Milestones.md`
- `docs/Codex_Onboarding_Context.md`

Confirm which sequence P2:R2 should reconnect first. Default assumption:
reconnect the existing Tavern ladder already represented by `RunFlow` and
encounter resources, while leaving contract branching for P2:R4.

## P2:R2:T2 - Define Dashboard Run State

Decide the minimal state the active dashboard needs:

- Current encounter index or encounter resource.
- Last combat result.
- Whether the player is planning, fighting, reviewing results, or ready to
  continue.
- Whether a run has ended.

Prefer extending `BuildState` only where the state is genuinely shared across
screens. Avoid burying run progression inside one panel script.

## P2:R2:T3 - Replace Hardcoded Enemy Panel

Refactor `enemy_panel.gd` so it displays the current encounter:

- Monster display name.
- HP.
- Armor.
- Poison resistance.
- Combat window.
- Fight button state.

The panel should not own the encounter ladder. It should receive/read current
encounter state and refresh when the run/build changes.

## P2:R2:T4 - Add Post-Fight Continuation

After a winning fight:

- Show result summary and combat log access.
- Provide a clear Continue action.
- Advance run state to the next encounter.
- Return the player to planning/build editing for the next fight.
- Clear or update lock state as appropriate.

Do not implement full reward choices here unless required to make progression
testable. P2:R3 owns real reward/shop parity.

## P2:R2:T5 - Add Reward Stub

If the encounter sequence requires reward acknowledgement before continuing,
use a clearly temporary reward stub:

- Show the reward that would be granted.
- Apply only minimal state needed for progression, if any.
- Document that full reward, inventory, shop, gold, and gear choice behavior
  belongs to P2:R3.

## P2:R2:T6 - Reconnect Basic Run End

When the sequence is exhausted:

- Show a run-end state reachable from the active dashboard flow.
- Offer restart/main-menu actions.
- Keep the implementation simple enough to be replaced or restyled later.

Full contract victory/failure polish belongs to later milestones.

## P2:R2:T7 - Preserve Dashboard Architecture

Keep the existing post-M5 UI principle:

- State in `BuildState` or small systems.
- Combat math in `CombatResolver`.
- Build math in `BuildResolver`.
- UI panels rendering state and emitting signals.

Avoid reviving the retired wizard as the main flow.

## P2:R2:T8 - Add/Update Tests

Add or update headless tests that:

- Start from the active `game_root.tscn`.
- Select Rogue and a subclass.
- Build and lock a rotation.
- Fight at least two encounters in sequence.
- Confirm the enemy panel changes between encounters.
- Confirm the run can reach an ending state.

Run relevant existing tests after changes.

## P2:R2:T9 - Update Docs

When complete:

- Update this checklist.
- Add a completion note to `docs/Phase_2_Milestones.md`.
- Note any temporary reward stubs that P2:R3 must replace.

## Implementation Notes

2026-07-16:

- `P2:R2:T1` confirmed the R1 input: reconnect the existing Tavern ladder
  already represented by `RunFlow` and encounter resources first. Contract
  branching, route choices, Knives, secondary subclass timing, and Vyra route
  parity remain `P2:R4`.
- `P2:R2:T2` defined the minimal dashboard run state in `BuildState`:
  `current_encounter_index` remains the encounter-position source,
  `current_encounter()` remains the active encounter accessor, and the new
  `run_phase` tracks `PLANNING`, `FIGHTING`, `RESULT`, and `RUN_ENDED`.
  `last_fight_won` records the latest result for continuation gating.
- `BuildState.start_fight()`, `finish_fight()`, `continue_after_win()`, and
  `end_run()` are the small transition surface for the dashboard. Combat log
  and recap presentation remain owned by `combat_screen.gd`; the shared state
  only stores what other panels/screens need.
- Defeat is intentionally represented only as a result state for now. Phase 1
  do-over/retry and harsher failure rules remain deferred to `P2:R5`.
- `P2:R2:T3`/`T4` are now implemented: `enemy_panel.gd` reads
  `BuildState.current_encounter()` instead of a hardcoded Mouthy Drunk, and
  the victory Continue button advances the active encounter and returns the
  dashboard to planning.
- `P2:R2:T5` is implemented as a temporary reward preview in the victory
  banner. It displays the current encounter's authored `gold_reward` value,
  but intentionally does not apply gold, grant talent points, add inventory,
  unlock shop actions, or equip gear. Full reward/shop/gear parity remains
  `P2:R3`.
- Basic run-end state is reconnected: exhausting the ladder moves
  `BuildState.run_phase` to `RUN_ENDED`, disables fighting, and the dashboard
  displays a simple "Run complete" status. The always-available main-menu
  action can reset the run. Richer victory/failure/restart presentation still
  belongs to later R5/R7 work.
- `combat_screen_test.gd` now drives the active dashboard through two
  encounters, confirms the enemy panel changes from Mouthy Drunk to Drunk
  Buddy and then Tavern Bouncer, asserts the temporary reward preview appears
  without applying gold, and asserts that continuing from the final encounter
  reaches `RUN_ENDED`.
- `P2:R2` is complete as a dashboard-loop reconnection milestone. The next
  implementation milestone is `P2:R3 - Reward, Shop, And Gear Parity`.

## Verification Notes

2026-07-16:

- Initial sandboxed Godot test runs crashed during engine startup while
  opening/writing `user://logs`, matching the known local issue called out in
  onboarding. Re-ran with escalated filesystem access and explicit log files.
- Passing headless checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r2_final.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r2_escalated.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r2_escalated.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r2_escalated.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r2_escalated.log -s res://tests/passive_allocator_test.gd`
- These runs still print the known Godot ObjectDB/resource cleanup warnings
  after passing assertions.

2026-07-16 R2 closeout:

- Added the temporary reward preview to the victory banner and confirmed it
  displays the current encounter's `gold_reward` without applying gold or
  other reward state. This is intentionally a P2:R3 handoff stub.
- The first sandboxed run of `combat_screen_test.gd` again crashed during
  Godot startup/log handling. Re-ran the focused dashboard test and regression
  checks with escalated filesystem access and explicit log files.
- Passing headless checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r2_reward_stub.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r2_reward_stub.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r2_reward_stub.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r2_reward_stub.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r2_reward_stub.log -s res://tests/passive_allocator_test.gd`
- These runs still print the known Godot ObjectDB/resource cleanup warnings
  after passing assertions.
