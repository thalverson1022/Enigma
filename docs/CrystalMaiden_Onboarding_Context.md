# CrystalMaiden Onboarding Context

## Purpose

Read this document first at the start of a new Project CrystalMaiden
conversation.

It is the compact working handoff for the current phase. It should be updated
as milestones and tasks are completed so the next conversation can start from
the current project state without rereading every document in `docs/`.

## Project Identity

Project CrystalMaiden is Phase 3 of the game project.

Phase naming follows Dota 2 heroes by first letter:

- Phase 1: Project Abaddon
- Phase 2: Project Bane
- Phase 3: Project CrystalMaiden

Phase 1 was the React alpha/prototype. Phase 2 rebuilt the validated Rogue
adventure loop in Godot 4.x. Phase 3 continues from the Godot codebase and is
focused on adding juice, clarity, animation, usability, and presentation polish
before deeper mechanics work begins in a later phase.

## Repository And Folder Setup

There are two local clones on the user's PC:

- `F:\Data\Claude Projects\Project-Bane`
- `F:\Data\Claude Projects\Project-CrystalMaiden`

Use `Project-CrystalMaiden` for Phase 3 work.

Current Phase 3 workspace:

- VS Code folder: `F:\Data\Claude Projects\Project-CrystalMaiden`
- Godot project folder: `F:\Data\Claude Projects\Project-CrystalMaiden\project`
- Git branch: `phase-3-crystalmaiden`
- GitHub remote: `https://github.com/thalverson1022/Bane.git`

Phase 2 historical workspace:

- Folder: `F:\Data\Claude Projects\Project-Bane`
- Branch: `main`
- Phase 2 closeout tag: `phase-2-bane-closeout`

The CrystalMaiden branch has intentionally cleaner docs than Bane. It keeps the
Phase 3 handoff/planning docs and does not carry forward the full Phase 1/2
tracking archive.

## Current Phase Status

Current milestone status:

- Milestone 0: Complete
- Milestone 1: Complete
- Milestone 2: Complete
- Milestone 3: Complete

Milestone 1 planning, M1:T1 controlled playback scenarios, M1:T2 combat
stage/actor layer, M1:T3 sprite configuration, M1:T4 fallback-compatible Rogue
vs Mouthy Drunk animation prototype, M1:T5 cast animation language, M1:T6
attack timing, M1:T7 start-of-fight readability, M1:T8 hit/crit feedback,
M1:T9 poison feedback, M1:T10 persistent enemy state feedback, M1:T11
proc/minimum-cast feedback, M1:T12 victory/defeat reveal timing, and M1:T13
placeholder asset mapping, and M1:T14 verification/documentation closeout are
complete.

Latest known state:

- Milestone 1 closeout committed and pushed on `phase-3-crystalmaiden`.
- Milestone 3 Tasks 0-7 are complete locally. The single Milestone 3 tasking
  doc is `docs/Phase_3_Milestone_3_Build_Screen_And_Rotation_UX_Polish.md`.
  M3:T0 planned the buildcraft pass and recorded the boundary between M3,
  M8, and later full art-direction work. M3:T1 confirmed the 10-slot Skill
  Build cap/count layout, fixed far-right lock lane, and current add/remove
  behavior, and added `res://tests/skill_build_geometry_test.gd` to guard
  Adventure and Training Room fit at 1600x900. M3:T2 made Lock Build the
  clear ready state and prevented empty rotations from becoming locked/ready
  in Adventure or Training Room. M3:T3 audited Available Skills and deferred
  broader comparison scaffolding until mechanics create real comparison
  pressure. M3:T4 added dependency-aware blocked-deselect pulse feedback for
  selected talents that support active dependent chains without changing
  talent rules. M3:T5 audited Character Stats and deferred broader stat/change
  presentation until class, stat, and gear changes settle. M3:T6 confirmed
  shared Adventure/Training Room build language is aligned enough for current
  Rogue mechanics and added Training Room assertions for shared Skill Build
  behavior plus stale-result invalidation after rotation edits. M3:T7 closed
  the milestone with focused tests, adjacent fixture updates, final
  verification, and documentation closeout. Balance Lab was not run for M3:T7
  because the closeout did not change combat math, resolver behavior,
  build-resolution rules, skill/talent/gear resources, or balance-relevant
  data.
- Milestone 2 Tasks 0-9 are complete locally. The single Milestone 2 tasking doc
  is `docs/Phase_3_Milestone_2_Combat_Recap_And_Failure_Clarity.md`; it
  defines P3:M2:T0 through P3:M2:T9 and uses the Phase:Milestone:Task:Step
  hierarchy requested for implementation planning. It also includes a
  Milestone 1 carryover audit so M2 work starts from the existing recap,
  outcome, Combat Log, and Training Room baselines rather than duplicating
  M1 work. T1 verified the current result-surface/player-question audit. T2
  expanded `CombatRecap.summarize(result, monster)` into the shared structured
  recap data model and updated `combat_screen.gd` to render compact recaps from
  that model instead of duplicating aggregation locally. T3 revised the
  result-scanability direction after design review: the immediate result recap
  stays light, while Adventure's `View Combat Log` modal now includes a
  first-pass visual inspector with a compact summary strip, Gantt-like Skill
  Timeline, and ranked Damage By Skill chart above the existing chronological
  text log. Follow-up review changes replaced visual chart text labels with
  skill/effect icons while preserving words in the Event Log, corrected the
  timeline axis to use exact whole-second marks instead of rounded quarter
  labels, and wired the same inspector into Training Room with practice-safe
  summary language. A later T3 proc-attribution follow-up added
  per-skill damage contributions to `CombatResolver.CastEvent` so triggered
  skills such as Opportunity Strikes' Rending Slash still contribute to the
  original cast total but now appear as their own damage source in the Combat
  Log inspector's timeline, Damage By Skill chart, and prose Event Log. A
  timeline scaling follow-up now computes fight-local max individual event
  damage and scales timeline bar height plus poison tick dot radius relative
  to that value, keeping width as cast timing while thickness/size communicates
  relative damage; crit markers and armor-shred pips sit above the bars. T4
  was rescoped after user design review: do not add more defeat-help/diagnosis
  copy. Instead, live defeat results now use the same dimmed combat-window
  result overlay rhythm as victory, retry remains functional from that overlay,
  and the result overlay remains non-modal so dashboard controls such as
  `View Combat Log` stay usable before claiming rewards, retrying, or
  restarting. T5 clarified next-action and retry-rule messaging: retryable
  losses now distinguish the unlimited Tavern opener from the standard one
  do-over, terminal Tavern loss and contract route failure use distinct
  no-retry language, and restart/new-Adventure copy makes the seed-preserving
  fresh Adventure action explicit. T6 improved Combat Log text readability:
  Adventure and Training Room logs now use clear target/timeline/summary
  sections, `CAST`/`DOT`/`LEGENDARY` timeline labels, preserved `>>>`
  Legendary proc scan markers, exact event ordering, zero-damage poison tick
  omission, and practice-safe Training Room wording. T7 kept Training Room
  result review in the Combat Log modal, reused the visual inspector in
  practice mode, and invalidates completed practice result review whenever
  build or fight setup inputs change so stale logs cannot look current after
  target, seed, duration, gear, rarity, Legendary, talent, rotation, or
  practice-gold edits. T8 added/updated focused assertions for recap facts,
  result/action copy, log formatting, inspector wiring, practice-safe wording,
  Training Room stale-result invalidation, and Adventure-state isolation. T9
  final focused checks passed and closeout docs were updated. This closeout is
  not yet committed/pushed as of 2026-07-31.
- Phase 1-4 of the cross-cutting technical-debt cleanup (see
  `docs/Phase_3_Technical_Debt_Architecture_Cleanup.md`) are complete but not
  yet committed as of 2026-07-31. `combat_screen.gd` went from 3,564 to 1,825
  lines (-49%) via 8 extracted overlay scenes (Phase 3) plus a playback/VFX
  layer extraction into `combat_popup_layer.gd`, `playback_controls.gd`, and
  `combat_playback_presenter.gd` (Phase 4). No behavior change; verified with
  the full 41-test suite and Balance Lab after every sub-step, plus a manual
  playtest pass. Phases 5-7 remain deliberately deferred behind their own
  triggers (see that doc's Status section).
- A stale test assertion in `tests/contract_offer_flow_test.gd` (expecting
  Shadow's old, longer `intrinsic_text`) was fixed to match the corrected
  `data/subclass_trees/shadow.tres` text ("Stab & Heavy Slash apply +1 poison
  stack") during Milestone 1 verification; this was a test-sync fix, not a
  mechanics change.

## Phase 3 Scope

Phase 3 is a presentation, game-feel, and usability phase.

In scope:

- Combat animation timing and readability.
- Hit, crit, proc, poison, armor-shred, victory, and defeat feedback.
- Skill popup polish.
- UI layout polish and clearer information hierarchy.
- Better hover, focus, disabled, selected, and comparison states.
- Better transitions between major adventure states.
- Training Room usability and visualization improvements.
- Testing-suite and Balance Lab hardening for future mechanics and balance
  work.
- Lightweight placeholder audio if explicitly useful and easy to replace.
- Documentation and UX checklists for future art, animation, and mechanics
  work.

Out of scope unless explicitly rescoped:

- New playable classes.
- New contracts.
- Broad enemy roster expansion.
- Monster or encounter-system redesign.
- Procedural map systems.
- Meta-progression systems.
- Major combat-engine redesign.
- Full production art pass.

## Current Game Context

The current playable build centers on the Rogue Adventure.

The main flow is:

1. Title screen.
2. Adventure Mode.
3. Rogue class select.
4. Primary subclass select.
5. Tavern encounter ladder.
6. Rewards, shop offers, gear decisions, and talent spending.
7. Contract offer for The Gilded Serpent.
8. Secondary subclass choice.
9. Contract route choices.
10. Knives Legendary reward choice.
11. Vyra climax.
12. Contract victory, contract failure, or adventure restart state.

The Training Room is also complete and important. It supports freeform Rogue
tree/talent setup, rotation editing, rarity-first gear editing, direct
Legendary selection, target controls, animated combat playback, and combat log
review without mutating Adventure state.

## Design Pillars

Buildcraft First:

- The player should understand why a build works.
- UI should show what changed, what matters, and what the enemy asks of the
  build.

Combat As Proof:

- Combat is the proof step for a build, not a reflex test.
- Animation should make the automated result legible and satisfying without
  implying manual control.

Pressure Is A Readable Puzzle:

- Enemies are fixed-duration DPS checks with personality and defensive
  profiles.
- HP, armor, poison resistance, duration, rewards, and route pressure should be
  clear before the player commits.

Failure Should Teach:

- Failed fights should show what happened and what the next allowed action is.
- Damage dealt, damage needed, biggest hit, poison contribution, armor behavior,
  and retry/restart rules should be clear.

## Important Files

Core screens:

- `project/scenes/game_root.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/training_room/training_room.gd`
- `project/scenes/training_room/training_room_combat_view.gd`

Combat and build systems:

- `project/scripts/systems/build_resolver.gd`
- `project/scripts/systems/combat_resolver.gd`
- `project/scripts/ui/combat_playback.gd`
- `project/scripts/ui/combat_playback_presenter.gd`
- `project/scripts/ui/combat_popup_layer.gd`
- `project/scripts/ui/playback_controls.gd`
- `project/scripts/ui/combat_stage.gd`
- `project/scripts/systems/combat_result_formatter.gd`
- `project/scripts/systems/combat_recap.gd`
- `project/scripts/systems/gear_generator.gd`
- `project/scripts/systems/run_rng.gd`
- `project/scripts/systems/save_system.gd`
- `project/scripts/tools/balance_lab.gd`
- `project/tests/helpers/combat_playback_scenarios.gd`

Key docs:

- `docs/Phase_3_CrystalMaiden_Milestones.md`
- `docs/Phase_3_Milestone_0_Planning_And_Phase_Setup.md`
- `docs/Phase_3_Milestone_1_Combat_Playback_Juice.md`
- `docs/Phase_3_Milestone_2_Combat_Recap_And_Failure_Clarity.md`
- `docs/Phase_3_Technical_Debt_Architecture_Cleanup.md`
- `docs/Phase_3_Context/Game_Summary_And_Phase_3_Brief.md`
- `docs/Phase_3_Context/Mechanics_And_Balance_Glossary.md`
- `docs/Phase_3_Context/Phase_2_Closeout_Review.md`
- `docs/Phase_3_Context/Rogue_Class_Overview.md`

## Milestone 0 Closeout Summary

Milestone 0 is complete.

Completed:

- Created and pushed Phase 3 branch: `phase-3-crystalmaiden`.
- Created and pushed Phase 2 closeout tag: `phase-2-bane-closeout`.
- Set up `Project-CrystalMaiden` as its own local Phase 3 clone.
- Kept `Project-Bane` as the Phase 2 historical clone.
- Cleaned Phase 3 docs to the handoff/planning set.
- Approved Phase 3 milestone structure.
- Completed current-state audit.
- Created the Milestone 1 tasking doc.

Focused baseline checks passed after a one-time Godot import:

- `res://tests/combat_playback_test.gd`
- `res://tests/combat_recap_test.gd`
- `res://tests/combat_hud_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/balance_lab_test.gd`

Known caveat:

- Godot may print ObjectDB/resource cleanup warnings at exit even when checks
  pass with exit code 0.
- A fresh clone may need a headless editor/import run before tests can resolve
  imported fonts and global classes.

## Completed Milestone: Milestone 1

Milestone 1: Combat Playback Juice.

Goal:

- Make automated combat feel more readable, punchy, and satisfying while
  remaining faithful to the resolved combat timeline.

Current state:

- Milestone 1 planning is complete.
- M1:T1 controlled playback scenarios are complete.
- M1:T2 combat stage and actor layer is complete.
- M1:T3 combat sprite configuration is in place; purchased RogueBandit and
  Townsfolk PNGs were copied into `project/assets/placeholder_combat_sprites/`
  on 2026-07-26 and imported by Godot.
- M1:T4 fallback-compatible Rogue vs Mouthy Drunk animation implementation and
  sprite-region tuning are complete.
- M1:T5 cast animation language is complete, mapping physical casts, poison
  casts, poison-themed utility casts, poison ticks, and minimum-cast procs to
  distinct presentation paths without changing combat math.
- M1:T6 attack timing is complete enough for the current pass: attack
  presentation now lasts long enough for the selected Rogue animation to finish.
- M1:T7 start-of-fight readability is complete: Adventure and Training Room
  both play a short shared visual pre-roll before the resolved combat timeline
  advances, keeping the combat clock and HUD at pre-fight values until the
  first event can legitimately fire.
- M1:T8 hit/crit feedback is complete for the current pass: enemy recoil/hurt
  timing begins on the second-to-last Rogue attack frame, shared contact
  flashes distinguish regular hits from larger gold crits, crit recoil is
  stronger, and Training Room crit popups now mirror Adventure's gold emphasis.
- M1:T9 poison feedback is complete for the current pass: poison-applying casts
  deepen the enemy's green tint based on active stacks while HUD/status chips
  track the stack count, and damaging poison ticks use smaller green
  enemy-centered damage-over-time pulse/text feedback.
- M1:T10 persistent enemy state feedback is complete for the current pass:
  combat-window HP, current armor, current resistance, poison stacks, Shred
  stacks, and Decay stacks now use persistent icon/value language. The selected
  placeholder heart, metal shield, resistance, poison, shred, and decay icons
  live under `project/assets/combat_ui_icons/`. Shred and Decay are
  presentation keywords for planned future mechanics language; this pass does
  not change combat math. Poison, Shred, and Decay counters remain visible at
  `x0` before they are active. Floating combat text was intentionally left
  unchanged.
- M1:T11 proc/minimum-cast feedback is complete for the current pass:
  triggered skills and retriggers now present as the normal source attack plus
  a fast follow-up attack; minimum-cast procs compress the source attack to max
  speed; Adventure and Training Room damage popups now wait for contact timing
  instead of appearing at cast-event start; and the Skill Build strip highlights
  and fills the current macro slot from cast start through contact, pulsing the
  source slot for triggered/retriggered casts. Bejeweled Push Dagger
  minimum-cast procs remain a single fast attack with purple proc-styled damage
  text and a purple macro fill. Bandit Blade has a first-pass always-on combat
  effect that reuses the Lucky Coin asset as a restrained 3-coin physical-hit
  spray, with 5 coins on crits, at contact timing. Wyvern Kriss has a
  first-pass always-on combat effect that makes poison tick text smaller while
  equipped. Umbral Stiletto intentionally has no extra combat overlay because
  Death Strike is the visible Legendary payoff. Karambit retriggers
  were verified not to skip the next macro attack; a same-timestamp playback
  ordering tweak keeps the next cast-start highlight from being visually hidden
  by the retrigger pulse. `CastEvent.cast_start_ms` and
  `CastEvent.rotation_index` were added as presentation metadata and do not
  change combat math.
- M1:T12 victory/defeat reveal timing is complete for the current pass:
  Adventure and Training Room now land on a shared terminal outcome beat before
  the result UI or Training Room finished signal resolves during natural
  playback. Victory uses the configured enemy defeat pose plus a restrained
  gold stage flash; the win result now uses the Option 3 integrated transition,
  dimming only the combat window while `VICTORY!`, recap, rewards, and
  `Claim Rewards` fade/scale into the same combat-window area over the still-
  visible Rogue/defeated enemy stage. Defeat uses the Rogue hurt/defeat
  presentation plus a restrained red stage flash. Adventure keeps outcome UI,
  combat log access, and Map locked during the natural reveal hold, then
  unlocks them together when the result is revealed. Skip remains instant,
  suppresses delayed popups, and still snaps actors to the correct outcome
  pose. This pass is presentation-only and does not change combat math, event
  ordering, BuildState mutation timing, autosave timing, or Training Room
  damage accounting.
- Cast windup alignment has been added as a follow-up Milestone 1 playback
  polish adjustment: Skill Build slot fill now represents the source cast
  windup, Rogue attack animation begins during that fill, and the animation
  contact frame aligns with `CastEvent.time_ms` when the slot completes.
  Enemy recoil, Bandit Blade coins, HUD damage, and damage popups remain tied
  to the resolved cast event. Triggered follow-up popups still wait for the
  fast follow-up hit beat. The playback controller now interleaves cast-start
  callbacks and cast/tick events by timestamp while preserving prior
  cast-end-before-next-cast-start ordering at exact same-timestamp boundaries.
- M1:T13 placeholder asset mapping is complete for the current pass: current
  Tavern and contract enemies have configured combat sprites, and the remaining
  current fight targets reuse the Hired Goon visual until bespoke art is
  assigned. Selected Rogue skill icons, Rogue subclass icons, combat/status
  icons, and stable misc UI icons are wired into the relevant game surfaces.
  `inventory.png` is intentionally deferred to the later Gear panel pass.
  `CombatStage.configure()` now clears previous target status visuals so poison
  tint and outcome pose state cannot leak onto the next pre-fight enemy sprite.
- M1:T14 verification/documentation closeout is complete: final focused checks
  passed, the Milestone 1 tasking document was closed, the Phase 3 milestone
  tracker now marks Milestone 1 complete, and this onboarding handoff points to
  Milestone 2 planning.
- Documentation has been consolidated to one Phase 3 overview document and one
  document per started milestone. Avoid adding per-task docs; update the
  relevant milestone document instead.

Milestone 1 should focus on:

- Controlled playback scenarios for the major combat event types.
- A combat stage and actor layer.
- Placeholder Rogue and Mouthy Drunk animation using purchased sprite assets.
- Cast-to-animation mapping for physical-only and poison-themed attacks.
- Attack timing that fits cast duration without changing combat math.
- Start-of-fight readability.
- Hit and crit feedback.
- Poison stack and poison tick feedback.
- Persistent armor reduction feedback.
- Persistent poison vulnerability feedback.
- Triggered skill and retrigger feedback.
- Minimum-cast proc feedback.
- Victory and defeat reveal timing.
- Adventure and Training Room visual-language consistency.

Likely implementation files:

- `project/scripts/ui/combat_playback.gd`
- `project/scripts/ui/combat_stage.gd`
- `project/scripts/systems/combat_resolver.gd`
- `project/scenes/combat/skill_build_panel.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/training_room/training_room.gd`
- `project/scenes/training_room/training_room_combat_view.gd`
- `project/tests/helpers/combat_playback_scenarios.gd`
- `project/tests/combat_playback_test.gd`
- `project/tests/combat_hud_test.gd`
- `project/tests/training_room_combat_view_test.gd`

Recommended next action:

- Start Milestone 4 planning for Gear, Rewards, Shop, and Legendary
  Presentation. Milestone 3 is complete: M3:T0 planning/audit, M3:T1 rotation
  editing UX, M3:T2 fight readiness and build lock state, M3:T3
  available-skill readability audit, M3:T4 talent tree clarity, M3:T5
  character stats/change-feedback audit, M3:T6 shared Adventure/Training Room
  build-language alignment, and M3:T7 focused tests/verification/docs closeout
  are complete in
  `docs/Phase_3_Milestone_3_Build_Screen_And_Rotation_UX_Polish.md`.
  M3:T1 confirmed the 10-slot cap/lock layout direction (`Slots: x/10`, no
  empty placeholder boxes, fixed far-right lock button), added
  `res://tests/skill_build_geometry_test.gd` to guard that a full ten-slot
  macro plus lock button fits inside Adventure and Training Room at the target
  1600x900 viewport, and closed with user acceptance of the current add/remove
  speed, duplicate readability, lock behavior, empty/cap language, and no
  extra Clear All/reorder/duplicate helper controls for now. M3:T2 confirmed
  that Lock Build is the ready action, kept the current grayed-out/disabled
  visual treatment without adding more instruction copy, and tightened the
  state model so empty rotations cannot become locked/ready in Adventure or
  Training Room. M3:T3 audited the current Available Skills strip and made no
  code changes: icon/name buttons, authored speed labels, live effect-summary
  tooltips, locked/capped disabled states, and shared Adventure/Training Room
  behavior are sufficient for current Rogue mechanics. Broader skill-comparison
  scaffolding should be revisited when mechanics become more complex, such as
  larger unlocked skill pools, sharper enemy build asks, proc chains,
  gear-skill dependencies, mutually exclusive skill paths, or several similar
  skills with materially different jobs. M3:T4 added a visual
  dependency-aware blocked-deselect pulse feedback for selected talents that
  support an active dependency chain, while keeping those protected talents
  visually quiet at rest. The change is presentation-only and preserves
  `PassiveAllocator`, talent rules, build resolution, Adventure progression,
  save behavior, and Training Room isolation. M3:T5 audited the current
  Character Stats panel and made no code changes: current live resolved stat
  lines, physical/poison grouping, poison-color treatment, bonus stat lines,
  and hover deltas against the class-only baseline are good enough for Phase 3.
  Broader recent-change emphasis, enemy-relevance hints, deeper comparison
  copy, or stat-panel restructuring should wait until later extensive changes
  to classes, stats, and gear settle. M3:T6 audited the shared Adventure and
  Training Room build language after user review confirmed the Training Room
  is in a good state. No product UI changes were made: shared Skill Build,
  Available Skills, Talent, and Character Stats vocabulary is aligned enough
  for current Rogue mechanics, Training Room remains practice-safe, broad
  practice workflow/target-control/gear-editor improvements stay deferred to
  Milestone 6, and focused assertions now cover Training Room shared Skill
  Build behavior plus stale-result invalidation after rotation edits. M3:T7
  updated adjacent loss fixtures that previously depended on empty rotations,
  verified the Training Room no-gear default and rarity-driven equip/unequip
  behavior, recorded the final checks, and left broader whole-game visual
  polish in Milestone 8 or a later art-direction phase.

Latest focused checks:

- P3:M3:T7 final focused checks passed on 2026-08-02 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/rotation_cap_test.gd`: Pass.
  - `res://tests/skill_build_geometry_test.gd`: Pass.
  - `res://tests/training_room_build_test.gd`: Pass.
  - `res://tests/training_room_fight_test.gd`: Pass.
  - `res://tests/training_room_fight_setup_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/combat_recap_test.gd`: Pass.
  - `res://tests/contract_offer_flow_test.gd`: Pass.
  - `res://tests/dashboard_header_test.gd`: Pass.
  - `res://tests/run_failure_state_test.gd`: Pass.
  - `res://tests/training_room_gear_editor_test.gd`: Pass.
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that documented assertion.
  - Balance Lab was not run because T7 did not change combat math, resolver
    behavior, build-resolution rules, skill/talent/gear resources, or
    balance-relevant data.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

- P3:M3:T6 shared Adventure/Training Room build-language checks passed on
  2026-08-02 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/training_room_build_test.gd`: Pass.
  - `res://tests/training_room_fight_test.gd`: Pass.
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/rotation_cap_test.gd`: Pass.
  - `res://tests/skill_build_geometry_test.gd`: Pass.
  - Balance Lab was not run because T6 changed only focused assertions and
    documentation; it did not change combat math, build resolution,
    skill/talent/gear resources, or balance-relevant data.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

- P3:M3:T5 character stats and change-feedback audit completed on 2026-08-02:
  docs-only audit/defer decision, no code changes, no Godot checks required.
  Current stat feedback is sufficient for Phase 3; broader stat/change
  presentation is deferred until later class, stat, and gear changes settle.

- P3:M3:T4 talent dependency visual-language checks passed on 2026-08-02 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/training_room_build_test.gd`: Pass.
  - Balance Lab was not run because T4 changed only shared talent UI
    presentation and focused assertions; it did not change combat math, build
    resolution, skill/talent/gear resources, or balance-relevant data.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

- P3:M3:T2 lock-as-ready focused checks passed on 2026-08-02 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/training_room_fight_test.gd`: Pass.
  - `res://tests/run_failure_state_test.gd`: Pass.
  - `res://tests/dashboard_header_test.gd`: Pass.
  - `res://tests/contract_offer_flow_test.gd`: Pass.
  - `res://tests/rotation_cap_test.gd`: Pass.
  - `res://tests/skill_build_geometry_test.gd`: Pass.
  - `res://tests/training_room_build_test.gd`: Pass.
  - `res://tests/training_room_gear_editor_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/combat_recap_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that assertion after the empty-rotation loss fixtures
    were updated.
  - `res://tests/save_load_test.gd` was not counted for this closeout: a
    sandboxed run hit its startup save-file assertion and timed out; rerunning
    outside the sandbox was rejected because that test deletes the normal
    Godot user save. An attempted isolated `--user-data-dir` rerun still saw
    the existing save on this Godot invocation.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

- P3:M3:T1 closeout checks passed using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/rotation_cap_test.gd`: Pass.
  - `res://tests/skill_build_geometry_test.gd`: Pass.
  - `res://tests/training_room_build_test.gd`: Pass.
  - `res://tests/training_room_fight_test.gd`: Pass.
  - `res://tests/training_room_fight_setup_test.gd`: Pass.
  - Balance Lab was not run because M3:T1 did not change combat math, build
    resolution rules, skill/talent/gear resources, or balance-relevant data.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

- P3:M3:T1 cap/lock geometry guardrail checks passed using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/rotation_cap_test.gd`: Pass.
  - `res://tests/skill_build_geometry_test.gd`: Pass.
  - `res://tests/training_room_build_test.gd`: Pass.
  - `res://tests/training_room_fight_test.gd`: Pass.
  - `res://tests/training_room_fight_setup_test.gd`: Pass.
  - A normal-renderer screenshot probe was used for manual review because
    headless/dummy rendering cannot capture viewport textures on this
    machine. Adventure and Training Room were reviewed at one slotted skill
    and ten slotted skills; the temporary probe script was removed afterward.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

- P3:M2:T9 final focused checks passed on 2026-07-31 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_recap_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/run_outcome_presentation_test.gd`: Pass.
  - `res://tests/run_failure_state_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/training_room_fight_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - Balance Lab was not run for T7-T9 because the closeout pass did not change
    combat math, resolver behavior, build resolution, skill/gear data, or
    balance-relevant resources.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

- P3:M2:T6 focused checks passed on 2026-07-31 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_recap_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/training_room_fight_test.gd`: Pass.
  - `res://tests/opportunity_strikes_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.
- P3:M2:T5 focused checks passed on 2026-07-31 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/run_outcome_presentation_test.gd`: Pass.
  - `res://tests/run_failure_state_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.
- P3:M2:T4 focused checks passed on 2026-07-31 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/run_outcome_presentation_test.gd`: Pass.
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.
- P3:M2:T3 focused checks passed on 2026-07-31 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_recap_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/training_room_fight_test.gd`: Pass.
  - `res://tests/opportunity_strikes_test.gd`: Pass.
  - `res://tests/engine_mechanics_test.gd`: Pass.
  - `res://tests/legendary_mechanics_test.gd`: Pass.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.
- P3:M2:T2 focused checks passed on 2026-07-31 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_recap_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

- M1:T14 final closeout checks passed on 2026-07-31 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/combat_stage_visual_reset_test.gd`: Pass.
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/run_outcome_presentation_test.gd`: Pass.
  - `res://tests/combat_recap_test.gd`: Pass.
  - `res://tests/rotation_cap_test.gd`: Pass.
  - `res://tests/training_room_build_test.gd`: Pass.
  - `res://tests/legendary_mechanics_test.gd`: Pass.

- M1:T13 closeout checks passed on 2026-07-31 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_stage_visual_reset_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.

- M1:T13 Rogue skill icon focused checks passed on 2026-07-30 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - Direct `project.godot --import`: Pass; generated import metadata for the
    eight new skill icon PNGs.
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/rotation_cap_test.gd`: Pass.
  - `res://tests/training_room_build_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.
- M1:T12 focused checks passed on 2026-07-29 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
- Cast windup alignment focused checks passed on 2026-07-29 using the same
  Godot executable and explicit workspace `--log-file` paths:
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
- Integrated combat-window victory transition focused checks passed on
  2026-07-29 using the same Godot executable and explicit workspace
  `--log-file` paths:
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/run_outcome_presentation_test.gd`: Pass.
  - `res://tests/combat_recap_test.gd`: Pass.
- `res://tests/combat_playback_test.gd`: Pass.
- `res://tests/combat_hud_test.gd`: Pass.
- `res://tests/training_room_combat_view_test.gd`: Pass.
- `res://tests/build_panels_test.gd`: Pass.
- `res://tests/combat_screen_test.gd`: Pass.
- M1:T11 focused checks passed on 2026-07-29 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/legendary_mechanics_test.gd`: Pass for Karambit macro order.
  - Final Bandit Blade coin-position/timing and Wyvern Kriss smaller-poison-
    tick checks also passed in `combat_playback_test.gd`,
    `training_room_combat_view_test.gd`, and `combat_screen_test.gd`.
- Earlier baseline:
  - `res://tests/combat_recap_test.gd`: Pass.
- M1:T10 focused checks passed on 2026-07-29 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths after a direct `project.godot --import` pass
  imported the new combat UI icon PNGs:
  - `res://tests/combat_playback_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
- M1:T9 focused checks passed on 2026-07-29 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_playback_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass after rerunning outside the sandbox
    because the sandboxed `--path` invocation exited before creating its log.
  - The direct `project.godot` invocation was not a valid substitute for the
    HUD check because it did not load normal project autoloads.
- M1:T8 focused checks passed on 2026-07-28 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
- M1:T3 through M1:T6 Godot import and focused checks completed using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`.
- `res://tests/combat_playback_test.gd`: Pass after running outside the
  sandbox so the autosave assertion can access normal user data.
- `res://tests/combat_hud_test.gd`: Pass.
- `res://tests/training_room_combat_view_test.gd`: Pass.
- M1:T7 focused checks passed on 2026-07-28 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`.
- Godot still prints the known ObjectDB/resource cleanup warnings at exit even
  when checks pass.
- Godot 4.7 crashed with `--path project --import` in this shell; importing by
  passing the direct `project.godot` file worked.
- Focused M1:T2 checks used explicit `--log-file` paths because the default
  Godot `user://logs` path crashed while another Godot process was running.
- This machine also printed a Windows root-certificate-store warning during
  focused headless test runs.

## Working Agreements

- Start each implementation milestone with Task 0 planning.
- Keep milestone/task/status docs updated as work progresses.
- Prefer conservative, scoped changes that match existing Godot patterns.
- Preserve determinism and avoid changing combat math during presentation work.
- Run focused tests after touching combat playback, HUD, Training Room combat
  playback, event formatting, or recap behavior.
- Run Balance Lab when changing combat timing, event ordering, build
  resolution, skill/talent/gear resources, or balance-relevant data.
- Use the installed `godot-ui` skill whenever working on Godot UI layout,
  styling, Control nodes, containers, themes, HUDs, panels, buttons, or
  responsive screen fit for Project CrystalMaiden.
- Use the installed `godot` skill for broader Godot 4 development workflow:
  Godot test/export/build guidance, GDScript project work, Godot automation,
  deployment/export questions, or when a task spans engine workflow rather
  than only code structure.
- Use the installed `godot-gdscript-patterns` skill for Godot architecture and
  GDScript implementation patterns: signals, scene composition, resources,
  state management, state machines, performance-sensitive logic, or refactors.
- Use the installed `game-design` skill for player-facing design assessment:
  core loop, progression, reward pacing, difficulty curve, onboarding,
  visual-language legibility, and whether a mechanic teaches itself.
- Prefer the smallest relevant skill set for the task. If multiple skills
  apply, load them in order from product/design intent to engine architecture
  to UI/layout implementation, and state that order before acting.
- Do not revert user changes or Phase 2 historical context unless explicitly
  asked.

## Update Instructions

When future work completes:

- Update the current milestone status in
  `docs/Phase_3_CrystalMaiden_Milestones.md`.
- Update this onboarding document with the latest milestone/task status.
- Add or update the relevant milestone/task planning doc.
- Record any new baseline test results or known caveats.
- Commit and push documentation updates with the related work.
