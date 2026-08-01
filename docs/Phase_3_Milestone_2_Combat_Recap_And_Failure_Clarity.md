# Phase 3 Milestone 2: Combat Recap And Failure Clarity

## Purpose

Milestone 2 improves post-fight understanding: wins should feel earned, and
losses should teach the player what happened and what the next allowed action
is.

This is the single tasking and status document for Milestone 2. It follows the
project hierarchy:

- Phase: 3, Project CrystalMaiden
- Milestone: 2, Combat Recap And Failure Clarity
- Task: milestone-sized work item
- Step: implementation-sized action inside a task

## Status

Complete.

## Milestone Goal

Make combat results easier to scan, make defeat states informative rather than
only punitive, and bridge each fight result into the player's next useful
decision.

## Constraints

- Do not change combat math, event ordering, proc behavior, Adventure state
  mutation rules, save behavior, or Training Room isolation.
- Recap and failure messaging must be derived from the already-resolved
  `CombatResolver.CombatResult` and current run state.
- Keep the recap compact enough to read after every fight; detailed timelines
  belong in the Combat Log.
- Preserve Milestone 1's combat-window victory/defeat reveal timing.
- Keep Adventure and Training Room language consistent where their meanings
  overlap, but do not imply Training Room has Adventure win/loss state.

## Current Baseline

Already present:

- `combat_screen.gd` builds compact recap lines for total damage, DPS, biggest
  hit, physical/poison split, crit count, armor reduction, and poison summary.
- `CombatResultFormatter` renders the full chronological Combat Log.
- Adventure shows the win recap inside the victory overlay and loss recap
  inline in the combat panel.
- Run outcome presentation already distinguishes retry, contract failure,
  Adventure restart, contract victory, and completed Tavern sequence states.
- Training Room reuses `CombatResultFormatter.format_practice()` for its
  result log.
- Focused tests already cover recap helpers, live win/loss recap basics, run
  outcome presentation, retry rules, combat log presence, and Training Room
  log generation.

Milestone 2 should therefore refine and reorganize the existing result
surfaces rather than replace them wholesale.

## Milestone 1 Carryover Audit

Milestone 1 did not complete Milestone 2, but it did establish several pieces
that Milestone 2 should treat as baseline rather than new work:

| M2 Task | Carryover From M1 | Remaining M2 Work |
|---|---|---|
| T1. Audit result surfaces and player questions | Partially covered. M1 documented victory/defeat reveal timing, Combat Log lock/unlock timing, skip behavior, Training Room outcome hold, and final recap/outcome test coverage. | Complete. M2 text/content audit is recorded in the T1 section below. |
| T2. Establish a shared recap data model | Barely covered. M1 verified existing `combat_recap_test.gd`, but did not move recap facts into a fuller shared model. | Still expand `CombatRecap` or equivalent summary data and reduce duplicated helper logic. |
| T3. Improve recap hierarchy and scanability | Partially covered. M1 moved victory recap into the integrated combat-window result state and confirmed loss recap appears after the defeat beat. | Still improve the semantic order, wording, and scanability of the recap itself. |
| T4. Align defeat result presentation with victory | Not covered. M1 made defeat presentation readable, but the live defeat result still used a looser inline layout than the victory overlay. | Complete. User review explicitly rejected adding more defeat-help text; T4 was rescoped to result-screen readability parity, retry function, and non-modal result overlays that leave dashboard controls such as `View Combat Log` usable. |
| T5. Clarify next-action and retry-rule messaging | Partially covered. M1 final verification included `run_outcome_presentation_test.gd`; existing UI distinguishes retry, restart, contract failure, contract victory, and new adventure. | Still sharpen copy around free opener retry, standard do-over, terminal loss, and what restart preserves. |
| T6. Improve Combat Log readability | Slightly covered. M1 ensured Combat Log access is locked during outcome hold and unlocked with the result; existing formatter and tests passed. | Still review and improve the log's text structure/readability if useful. |
| T7. Align Training Room recap/log usefulness | Partially covered. M1 gave Training Room the shared combat end beat and verified Training Room playback/log surfaces still pass. | Still decide whether Training Room needs a compact practice summary and keep language Adventure-state-free. |
| T8. Add focused tests for result clarity | Partially covered. M1 final checks already included `combat_recap_test.gd`, `run_outcome_presentation_test.gd`, `combat_screen_test.gd`, and Training Room checks. | Still add or update tests for any new recap model, diagnosis, action copy, log formatting, or practice summary changes. |
| T9. Verify, document, and close Milestone 2 | Not covered. M1 verification is historical baseline only. | Still run and record Milestone 2-specific checks after implementation. |

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Plan the recap and failure clarity pass | Complete | Scope, task boundaries, step list, implementation surfaces, verification plan, definition of done, and Milestone 1 carryover audit are documented. |
| 1. Audit result surfaces and player questions | Complete | M2 text/content audit recorded below; M1 timing/access coverage remains baseline. |
| 2. Establish a shared recap data model | Complete | `CombatRecap.summarize()` now provides the shared structured recap facts; `combat_screen.gd` formats from that model instead of duplicating aggregation. |
| 3. Improve result scanability through the Combat Log inspector | Complete | Direction revised after design review: the immediate result recap stays light, while the Adventure Combat Log now includes a first-pass visual inspector. |
| 4. Align defeat result presentation with victory | Complete | Rescoped after design review: no extra diagnosis/help copy. Defeat now uses the same combat-window result overlay rhythm as victory, keeps retry functional, and exposes `View Combat Log` directly on victory/defeat result screens. |
| 5. Clarify next-action and retry-rule messaging | Complete | Outcome copy now distinguishes unlimited opener retries, the standard one do-over, terminal Tavern losses, contract route failures, and new-Adventure actions. |
| 6. Improve Combat Log readability | Complete | The shared text formatter now uses target/timeline/summary sections, readable event labels, and preserved Legendary proc markers for Adventure and Training Room logs. |
| 7. Align Training Room recap/log usefulness | Complete | Training Room uses the shared visual inspector with practice-safe summary language, and completed result review now invalidates when practice inputs change. |
| 8. Add focused tests for result clarity | Complete | Focused assertions now cover shared recap facts, log readability, retry/action copy, Combat Log inspector wiring, practice-safe Training Room wording, and stale-result invalidation. |
| 9. Verify, document, and close Milestone 2 | Complete | Final focused M2 checks passed and closeout docs were updated. |

## Task Details

### P3:M2:T0 - Plan The Recap And Failure Clarity Pass

Status: Complete.

Goal: turn Milestone 2 from a high-level milestone into an executable task and
step plan.

Steps:

- P3:M2:T0:S1 - Read current Phase 3, Milestone 1, recap, outcome, and
  failure-state context.
- P3:M2:T0:S2 - Identify existing result/recap implementation surfaces and
  focused tests.
- P3:M2:T0:S3 - Define Milestone 2 tasks using the Phase:Milestone:Task:Step
  hierarchy.
- P3:M2:T0:S4 - Update Phase 3 docs so the next session can begin at
  implementation without re-planning.
- P3:M2:T0:S5 - Confirm the initial definition of done and recommended first
  implementation task with the user.

Expected output:

- This Milestone 2 tasking document.
- Updated Phase 3 milestone tracker and onboarding handoff.
- Milestone 1 carryover audit showing which M2 tasks already have partial
  baseline coverage from M1.

### P3:M2:T1 - Audit Result Surfaces And Player Questions

Status: Complete.

Goal: create a concrete map of every place the player sees fight-result
information and what question each surface should answer.

Steps:

- P3:M2:T1:S1 - Review Adventure victory, retryable loss, terminal Tavern
  loss, contract route failure, contract victory, and Tavern clear states.
- P3:M2:T1:S2 - Review Combat Log modal content, button states, and timing
  after natural playback and skip.
- P3:M2:T1:S3 - Review Training Room result log and combat playback finish
  state.
- P3:M2:T1:S4 - Record the player question for each surface, such as "Did I
  win?", "How close was I?", "What did most of my damage?", "What blocked me?",
  and "What can I do now?"
- P3:M2:T1:S5 - Identify any stale, duplicated, or contradictory result text.

Expected output:

- A short audit section in this document listing result surfaces, decisions,
  and any implementation risks.

Audit:

Audit verification: Rechecked against the current Adventure outcome,
Combat Log, and Training Room result code on 2026-07-31. The table below is
still the active implementation map for Milestone 2 follow-up work.

| Surface | Current Result Content | Player Question It Should Answer | Decision / Follow-Up |
|---|---|---|---|
| Adventure fight victory before claim | `combat_screen.gd` hides the generic status, shows the integrated `VICTORY!` combat-window overlay, compact recap lines, reward text, `Claim Rewards`, and `View Combat Log`. | Did I win, how much did I beat the target by, what worked, and what do I claim now? | Keep the M1 integrated reveal. T2/T3 should move recap facts out of local helpers and reorder the compact recap so overkill/actual-vs-needed is easier to scan. |
| Retryable loss | A live losing fight now shows `DEFEATED`, retry-rule body copy, compact recap, `View Combat Log`, and `Retry Encounter` inside the same dimmed combat-window result overlay shape as victory. Legacy `_apply_outcome_presentation()` still supports direct terminal outcome presentation. | Did I lose, how close was I, do I get another attempt, can I inspect the log now, and what can I change before retrying? | Keep the explicit retry action and overlay parity. User review chose not to add extra defeat-help/diagnosis copy. T5 should keep the unlimited opener retry distinct from the standard one do-over. |
| Terminal Tavern loss | `ADVENTURE OVER` appears with `No retries remain for this encounter. Restart preserves Seed ...`, `Restart Adventure`, inline recap, and log access. | Why can I not retry, what happened, and what does restart preserve? | Copy is accurate but terse. T5 should sharpen restart/preservation language while preserving the compact, diagnosis-free result surface chosen in T4. |
| Contract route failure | `CONTRACT FAILED` appears with `The route collapses here. Restart preserves Seed ...`, `Restart Adventure`, inline recap, and log access. | Did this fail the contract route, why can I not continue, and what can I do now? | Keep the distinct headline. T5 should clarify that the contract run is terminal because the route fight has no retry remaining. |
| Contract victory | After claiming the final route reward, `CONTRACT COMPLETE` appears with `Vyra is defeated...`, `Start New Adventure`, and no retry. | Did I finish the contract, who was defeated, and what is the next campaign-level action? | Existing presentation test covers the visible headline/action. No recap change is required here unless T3 changes final victory emphasis. |
| Tavern clear / non-contract run complete | `RUN COMPLETE` can present `Tavern sequence cleared...` with `Start New Adventure` when the Tavern ladder ends without an active contract. In the current main flow, the final Tavern win normally starts the contract offer instead. | Did I clear the Tavern sequence, and why am I starting over instead of continuing? | Treat as a valid fallback/edge result. T5 should preserve clear wording but avoid over-optimizing this lower-frequency path. |
| Combat Log modal in Adventure | `View Combat Log` is visible but disabled during playback/outcome hold, unlocks after reveal, and opens `CombatResultFormatter.format()` with matchup stats, chronological cast/tick lines, total damage/DPS, and final `VICTORY!` or `DEFEAT` summary. | What exactly happened, in what order, and what was the final result? | Keep log as the detailed timeline. T6 can improve scanability, but should not duplicate the compact recap or change event ordering. |
| Combat Log timing after skip | Skip flushes playback, snaps outcome pose, reveals result UI immediately, and unlocks log access after `_reveal_fight_outcome()`. | Can I skip the animation and still inspect the resolved fight without hidden delay or spoiled pre-reveal info? | Existing timing is coherent. Tests already cover skip/natural reveal for loss and log lock timing; update only if T6 changes log text. |
| Training Room result log | `training_room.gd` fills the gated `Combat Log` after `TrainingRoomCombatView.finished`; `CombatResultFormatter.format_practice()` shows target armor/resistance, combat window, timeline, and damage/DPS with no HP, victory, defeat, reward, retry, or Adventure state. | What did this practice build do against this target setup? | Keep Adventure-state-free language. T7 should decide whether to add a compact practice summary before the detailed log, using the same shared recap facts from T2 where useful. |
| Training Room playback finish state | `TrainingRoomCombatView` plays the shared intro/outcome beat, hides controls during the natural hold, and emits `finished`; skip resolves immediately. The parent enables the log only after finish. | Is the practice playback done, and can I inspect results now? | Timing is aligned with Adventure without implying a win/loss consequence. Preserve this boundary during T7. |

Stale / duplicated / contradictory text notes:

- Recap aggregation is duplicated in `combat_screen.gd` helper methods even
  though `project/scripts/systems/combat_recap.gd` exists; this is the main
  T2 implementation risk.
- Compact recap and Combat Log both report total damage, DPS, and result, but
  their purposes are distinct: recap should answer "what mattered?" while log
  should answer "what happened?" T3 and T6 should maintain that separation.
- Adventure loss copy is factually correct, and user review chose not to add
  more defeat-help/diagnosis copy. T4 instead moved live defeat results into
  the same combat-window overlay rhythm as victory while keeping the recap
  compact and numeric.
- Retry wording already avoids the stale "one retry" problem for the unlimited
  first Tavern encounter. T5 should preserve that distinction while making the
  standard one-do-over and terminal no-retry states easier to compare.
- Training Room currently avoids contradictory Adventure language. The risk in
  T7 is adding a practice summary that accidentally says "win", "loss",
  "needed damage", "reward", or "retry" when the Training Room is only a
  measurement surface.

### P3:M2:T2 - Establish A Shared Recap Data Model

Status: Complete.

Goal: separate recap facts from UI rendering so Adventure and Training Room can
share trustworthy summary data.

Steps:

- P3:M2:T2:S1 - Expand or replace `CombatRecap.summarize()` with a structured
  recap object/dictionary that includes damage required, damage shortfall or
  overkill, required DPS, actual DPS, biggest hit, crit count, physical damage,
  poison damage, armor reduction, poison tick count, peak poison stacks, and
  mitigation-relevant values.
- P3:M2:T2:S2 - Keep aggregation driven only by `CombatResult`, `Monster`, and
  fight duration data that already exists.
- P3:M2:T2:S3 - Move duplicated helper logic out of `combat_screen.gd` where
  it belongs in `CombatRecap`, while preserving local rendering choices in UI.
- P3:M2:T2:S4 - Add direct tests for edge cases: zero damage, physical-only,
  poison-only or poison-heavy, armor reduction present, crit present, and no
  casts.

Expected output:

- A system-level recap summary API with focused unit coverage.

Implementation notes:

- Expanded `project/scripts/systems/combat_recap.gd` so
  `CombatRecap.summarize(result, monster)` returns shared recap facts:
  required damage, shortfall/overkill, required and actual DPS, biggest hit,
  crit count, cast count, physical/poison damage split, armor reduction,
  poison tick count, peak poison stacks, poison tick damage, and base/final
  armor and poison resistance.
- Kept aggregation driven only by `CombatResolver.CombatResult`, `Monster`,
  and the result's existing fight duration.
- Updated `project/scenes/combat/combat_screen.gd` so compact recap rendering
  formats from the shared summary dictionary instead of recomputing recap
  values locally.
- Updated `project/tests/combat_recap_test.gd` to test `CombatRecap`
  directly for poison-heavy, armor-reduction, crit, physical-only, zero-damage
  cast, and no-cast cases while preserving live Adventure win/loss rendering
  checks.

Focused checks:

- `res://tests/combat_recap_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_screen_test.gd`: Pass on 2026-07-31.
- Godot still printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

### P3:M2:T3 - Improve Result Scanability Through The Combat Log Inspector

Status: Complete.

Goal: keep the immediate fight result surface concise while making the
optional Combat Log a more useful visual fight inspector for players who want
to dive into the numbers.

Steps:

- P3:M2:T3:S1 - Preserve the current immediate result recap as a compact,
  decision-focused surface rather than expanding it into a larger stat block.
- P3:M2:T3:S2 - Add shared Combat Log inspector data derived only from
  `CombatResolver.CombatResult`, `Monster`, and `CombatRecap` summary facts.
- P3:M2:T3:S3 - Add a static Gantt-like Skill Timeline to the Adventure Combat
  Log showing cast windows, contact timing, crit markers, poison ticks, and
  proc/retrigger markers.
- P3:M2:T3:S4 - Add a ranked horizontal Damage By Skill chart below the
  timeline, aggregating direct skill damage by skill and poison tick damage
  into a clear poison row for the first pass.
- P3:M2:T3:S5 - Preserve the existing chronological text Combat Log below the
  new visual inspector as the exact detail layer.
- P3:M2:T3:S6 - Update focused tests for inspector data generation and the
  Adventure log overlay wiring.

Expected output:

- A first-pass visual Combat Log inspector for Adventure fights, with the
  existing text log preserved and stable test assertions covering the new data
  and overlay population.

Implementation notes:

- Added `project/scripts/systems/combat_log_inspector_data.gd` to derive
  inspector data from resolved combat results without changing combat math.
- Added `project/scenes/combat/combat_log_inspector.gd`, a static first-pass
  visual inspector with a compact summary strip, Gantt-like Skill Timeline,
  and ranked Damage By Skill chart.
- Updated `project/scenes/combat/log_overlay.gd` and
  `project/scenes/combat/combat_screen.gd` so Adventure's existing
  `View Combat Log` modal shows the visual inspector above the existing
  chronological text log.
- Follow-up review changes replaced timeline and damage-chart text labels with
  skill/effect icons while keeping the prose event log textual, corrected the
  time-axis marks so labels represent exact seconds instead of rounded quarter
  positions, and wired the same inspector into Training Room with
  practice-safe summary language.
- Follow-up proc-attribution work added per-skill damage contributions to
  `CombatResolver.CastEvent` so triggered skills such as Opportunity Strikes'
  Rending Slash keep contributing to the original cast total while also
  appearing as their own source in the Combat Log inspector's timeline,
  Damage By Skill chart, and prose event log.
- Follow-up timeline scaling work added a fight-local max individual event
  damage value and uses it to scale timeline bar height and poison tick dot
  radius relative to the largest hit/tick in the parse. Width remains cast
  timing, while thickness/size now communicates relative damage; crit markers
  and armor-shred pips sit above the bars.

Focused checks:

- `res://tests/combat_recap_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_screen_test.gd`: Pass on 2026-07-31.
- `res://tests/training_room_fight_test.gd`: Pass on 2026-07-31.
- `res://tests/opportunity_strikes_test.gd`: Pass on 2026-07-31.
- `res://tests/engine_mechanics_test.gd`: Pass on 2026-07-31.
- `res://tests/legendary_mechanics_test.gd`: Pass on 2026-07-31.
- Godot still printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

### P3:M2:T4 - Align Defeat Result Presentation With Victory

Status: Complete.

Goal: make defeat results as readable and usable as victory results without
adding more defeat-help text.

Design review:

- User review rejected adding additional diagnosis/help language to the defeat
  state. The existing recap facts were considered sufficient.
- The problem to solve was presentation: the defeat screen's information was
  not as cleanly displayed as the victory screen.

Steps:

- P3:M2:T4:S1 - Reuse the combat-window result overlay structure for live
  defeat results instead of rendering title/body/recap inline through the
  combat content column.
- P3:M2:T4:S2 - Keep the victory and defeat recap hierarchy aligned:
  centered headline, divider, compact recap, and clear action row.
- P3:M2:T4:S3 - Preserve existing retry-rule copy and avoid adding new
  strategy/diagnosis text.
- P3:M2:T4:S4 - Fix real mouse interaction for result-overlay buttons by
  allowing the visible overlay content to receive input while the backdrop
  continues blocking dashboard clicks.
- P3:M2:T4:S5 - Ensure retry dismisses the result overlay and returns to the
  same encounter planning state.
- P3:M2:T4:S6 - Keep dashboard controls such as `View Combat Log` usable
  while the victory or defeat result overlay is visible.

Expected output:

- Live defeat results visually match victory results, retry remains functional,
  and both victory/defeat result screens can open the Combat Log.

Implementation notes:

- Updated `project/scenes/combat/combat_screen.gd` so live fight losses call
  `_show_defeat_banner()` and reuse the same overlay shell as `_show_victory_banner()`.
- Centralized run-outcome title/body/action data through
  `_outcome_presentation()` so the overlay path and legacy direct
  `_apply_outcome_presentation()` path stay consistent.
- Kept result-overlay action rows focused on the outcome action: victory shows
  `Claim Rewards`, while defeat shows `Retry Encounter` or restart when
  applicable. The normal dashboard `View Combat Log` button remains visible
  and usable while the result overlay is up.
- Adjusted overlay mouse filters so real clicks reach the visible overlay
  buttons while the transparent backdrop still blocks the dashboard behind the
  result state.
- Updated focused tests for victory result log access, defeat result log
  access, retry overlay dismissal, and playback reveal expectations.

Focused checks:

- `res://tests/combat_screen_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_hud_test.gd`: Pass on 2026-07-31.
- `res://tests/run_outcome_presentation_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_playback_test.gd`: Pass on 2026-07-31 after rerunning
  outside the sandbox for the known autosave/user-data assertion. The first
  sandboxed run failed only on that known assertion.
- Godot still printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

### P3:M2:T5 - Clarify Next-Action And Retry-Rule Messaging

Status: Complete.

Goal: make the allowed action after a loss or terminal result unmistakable.

Steps:

- P3:M2:T5:S1 - Review current `BuildState.RunOutcome` presentation text and
  button labels for retry, Adventure restart, contract failure, contract
  victory, and new adventure.
- P3:M2:T5:S2 - Update retryable-loss copy to explain whether this is a free
  opener retry or the one standard do-over.
- P3:M2:T5:S3 - Update terminal-loss copy to explain why retry is unavailable
  and what restart preserves.
- P3:M2:T5:S4 - Ensure contract failure and Adventure-over language are
  distinct.
- P3:M2:T5:S5 - Add or update focused tests for every visible action state.

Expected output:

- The result surface tells the player exactly what can happen next and why.

Implementation notes:

- Updated `project/scenes/combat/combat_screen.gd` outcome presentation copy
  so retryable losses explicitly distinguish the unlimited Tavern opener from
  the standard one-do-over rule.
- Updated terminal loss copy so `ADVENTURE OVER` explains that no retries
  remain for the Tavern encounter, while `CONTRACT FAILED` explains that the
  contract route has no retries remaining.
- Kept restart and new-Adventure buttons unchanged, but clarified that restart
  begins a fresh Adventure while preserving the current Seed.
- Expanded `project/tests/run_outcome_presentation_test.gd` to assert visible
  action-state copy for unlimited opener retry, standard do-over, terminal
  Tavern loss, contract route failure, and contract victory/new Adventure.

Focused checks:

- `res://tests/run_outcome_presentation_test.gd`: Pass on 2026-07-31.
- `res://tests/run_failure_state_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_screen_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_hud_test.gd`: Pass on 2026-07-31.
- Godot still printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

### P3:M2:T6 - Improve Combat Log Readability

Status: Complete.

Goal: keep the detailed log chronologically faithful while making it easier to
scan after the fight.

Steps:

- P3:M2:T6:S1 - Review `CombatResultFormatter.format()` and
  `format_practice()` line structure for headers, timeline lines, proc
  markers, tick lines, and summary lines.
- P3:M2:T6:S2 - Add clearer section spacing or labels if useful, without
  turning the log into a second recap panel.
- P3:M2:T6:S3 - Preserve exact event ordering and zero-damage poison tick
  omission.
- P3:M2:T6:S4 - Ensure Legendary proc markers remain easy to scan.
- P3:M2:T6:S5 - Update Adventure and Training Room log tests for the chosen
  formatting.

Expected output:

- Combat Log reads as a clean detailed timeline, not an undifferentiated text
  dump.

Implementation notes:

- Updated `project/scripts/systems/combat_result_formatter.gd` so Adventure
  logs are divided into `Target`, `Timeline`, and `Summary` sections while
  Training Room logs use `Practice Target`, `Timeline`, and `Summary`.
- Added explicit timeline row labels: `CAST` for normal casts, `DOT` for
  damaging poison ticks, and `LEGENDARY` for minimum-cast or triggered-proc
  events while preserving the existing `>>>` scan marker.
- Preserved the merged chronological event order, zero-damage poison tick
  omission, proc contribution wording, and Training Room's Adventure-state-free
  language.
- Updated `project/tests/combat_recap_test.gd` with formatter assertions for
  Adventure and Training Room section labels, normal cast rows, poison DOT
  rows, Legendary marker readability, zero-damage tick omission, and
  practice-safe wording. The live loss recap test was also synced to the
  current shared defeat-overlay baseline from T4.

Focused checks:

- `res://tests/combat_recap_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_screen_test.gd`: Pass on 2026-07-31.
- `res://tests/training_room_fight_test.gd`: Pass on 2026-07-31.
- `res://tests/opportunity_strikes_test.gd`: Pass on 2026-07-31.
- `res://tests/training_room_combat_view_test.gd`: Pass on 2026-07-31.
- Godot still printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

### P3:M2:T7 - Align Training Room Recap And Log Usefulness

Status: Complete.

Goal: make Training Room fight results better for build testing while keeping
it separate from Adventure state.

Steps:

- P3:M2:T7:S1 - Decide whether Training Room needs a compact summary above or
  beside the existing detailed log.
- P3:M2:T7:S2 - If added, use practice-safe language: damage, DPS, damage mix,
  biggest hit, poison contribution, armor interaction, and target defenses.
- P3:M2:T7:S3 - Do not show Adventure-only concepts such as rewards, retries,
  contract failure, or defeated-state requirements unless the Training Room
  explicitly has a selected HP target.
- P3:M2:T7:S4 - Ensure changing target, gear, rotation, rarity, Legendary, or
  seed refreshes result text predictably after the next fight.
- P3:M2:T7:S5 - Add or update Training Room tests for result-log/summary
  updates and Adventure-state isolation.

Expected output:

- Training Room result review becomes more useful for build iteration.

Implementation notes:

- Kept the Training Room result review inside the existing Combat Log modal
  rather than adding another large practice recap surface.
- Reused the shared Combat Log inspector in practice mode, where the compact
  summary chip reports `Practice` instead of Adventure win/loss language.
- Preserved the detailed Training Room text log's practice-safe
  `Practice Target`, `Timeline`, and `Summary` sections.
- Updated `project/scenes/training_room/training_room.gd` so build or fight
  setup changes invalidate the completed result review: the Combat Log button
  disables, the modal hides, the inspector clears, and the text log clears
  until the next resolved practice fight finishes.
- This keeps target, seed, duration, gear, rarity, Legendary, talent, rotation,
  and practice-gold edits from leaving stale result text visible as if it still
  described the current setup.

Focused checks:

- `res://tests/training_room_fight_test.gd`: Pass on 2026-07-31.
- Godot still printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

### P3:M2:T8 - Add Focused Tests For Result Clarity

Status: Complete.

Goal: make Milestone 2 changes safe to maintain.

Steps:

- P3:M2:T8:S1 - Expand `combat_recap_test.gd` or add a focused recap-summary
  test for the shared recap model.
- P3:M2:T8:S2 - Expand `run_outcome_presentation_test.gd` for retry-rule and
  terminal-action copy.
- P3:M2:T8:S3 - Add Combat Log formatting assertions where wording changes.
- P3:M2:T8:S4 - Add Training Room result assertions if T7 changes the practice
  result surface.
- P3:M2:T8:S5 - Keep tests deterministic and fixture-driven where possible.

Expected output:

- Focused tests guard recap facts, failure teaching, action-state copy, and log
  readability.

Implementation notes:

- `project/tests/combat_recap_test.gd` covers shared recap facts, inspector
  data, readable Adventure log sections, readable Training Room log sections,
  Legendary proc markers, zero-damage poison tick omission, and
  Adventure-state-free practice wording.
- `project/tests/combat_screen_test.gd` covers Adventure Combat Log inspector
  wiring and result overlay/log access.
- `project/tests/run_outcome_presentation_test.gd` and
  `project/tests/run_failure_state_test.gd` cover retry, no-retry, restart,
  contract-failure, and contract-victory action states.
- `project/tests/training_room_fight_test.gd` now covers Training Room
  inspector population, practice-safe summary chips, practice log content,
  stale-result invalidation after setup/build edits, and Adventure-state
  isolation.

### P3:M2:T9 - Verify, Document, And Close Milestone 2

Status: Complete.

Goal: finish the milestone with the same handoff quality as Milestone 1.

Steps:

- P3:M2:T9:S1 - Run focused tests after each implementation task that touches
  recap, log, outcome presentation, Training Room result review, or run-state
  copy.
- P3:M2:T9:S2 - Run Balance Lab only if implementation touches combat timing,
  resolver behavior, build resolution, gear data, skill data, or
  balance-relevant resources.
- P3:M2:T9:S3 - Run the final focused Milestone 2 check set.
- P3:M2:T9:S4 - Update this document with completed work and latest checks.
- P3:M2:T9:S5 - Update `Phase_3_CrystalMaiden_Milestones.md` and
  `CrystalMaiden_Onboarding_Context.md`.
- P3:M2:T9:S6 - Commit and push Milestone 2 work after review/approval.

Expected output:

- Milestone 2 marked complete with tests, docs, and handoff context updated.

Final focused checks:

- `res://tests/combat_recap_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_screen_test.gd`: Pass on 2026-07-31.
- `res://tests/run_outcome_presentation_test.gd`: Pass on 2026-07-31.
- `res://tests/run_failure_state_test.gd`: Pass on 2026-07-31.
- `res://tests/combat_hud_test.gd`: Pass on 2026-07-31.
- `res://tests/training_room_fight_test.gd`: Pass on 2026-07-31.
- `res://tests/training_room_combat_view_test.gd`: Pass on 2026-07-31.
- Balance Lab was not run for T7-T9 because the closeout pass did not change
  combat math, resolver behavior, build resolution, skill/gear data, or
  balance-relevant resources.
- Godot still printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

## Implementation Surfaces

Likely files:

- `project/scripts/systems/combat_recap.gd`
- `project/scripts/systems/combat_result_formatter.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/training_room/training_room.gd`
- `project/scenes/training_room/training_room_combat_view.gd`
- `project/tests/combat_recap_test.gd`
- `project/tests/combat_screen_test.gd`
- `project/tests/run_outcome_presentation_test.gd`
- `project/tests/run_failure_state_test.gd`
- `project/tests/training_room_fight_test.gd`
- `project/tests/training_room_combat_view_test.gd`

## Verification Plan

Focused checks expected during this milestone:

- `res://tests/combat_recap_test.gd`
- `res://tests/combat_screen_test.gd`
- `res://tests/run_outcome_presentation_test.gd`
- `res://tests/run_failure_state_test.gd`
- `res://tests/combat_hud_test.gd`
- `res://tests/training_room_fight_test.gd`
- `res://tests/training_room_combat_view_test.gd`

Add `res://tests/balance_lab_test.gd` or run Balance Lab if any implementation
touches balance-relevant data or resolver/build behavior.

Known caveats from the current project still apply:

- Godot may print ObjectDB/resource cleanup warnings at exit even when checks
  pass with exit code 0.
- `combat_playback_test.gd` may need to run outside the sandbox for the known
  autosave/user-data assertion.
- Use explicit workspace `--log-file` paths for headless Godot checks.

## Definition Of Done

Milestone 2 is done when:

- Win and loss recap hierarchy is clearer and covered by tests.
- Defeat result presentation matches the victory result's readability and
  preserves the existing compact recap without extra diagnosis copy.
- Victory and defeat result overlays can open the Combat Log before claiming
  rewards, retrying, or restarting.
- Retry, do-over, restart, contract-failure, contract-victory, and
  new-adventure options are explicit and state-faithful.
- Combat Log readability improves without changing event ordering.
- Training Room result review remains Adventure-state-free and useful for
  build iteration.
- Focused checks pass and results are recorded here.
- Phase 3 milestone tracker and onboarding handoff are updated.

## Closeout

Milestone 2 is complete. Recommended next action is to review and commit/push
the closeout work, then begin Milestone 3 Task 0 planning for Build Screen And
Rotation UX Polish.
