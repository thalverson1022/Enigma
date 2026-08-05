# Phase 3 Milestone 3: Build Screen And Rotation UX Polish

## Purpose

Milestone 3 makes buildcraft easier to understand, faster to manipulate, and
more trustworthy before the project moves deeper into reward, flow, and
Practice Room-specific polish.

This is the single tasking and status document for Milestone 3. It follows the
project hierarchy:

- Phase: 3, Project CrystalMaiden
- Milestone: 3, Build Screen And Rotation UX Polish
- Task: milestone-sized work item
- Step: implementation-sized action inside a task

## Status

Complete.

## Milestone Goal

Make the player more confident about what their build currently does, what
changed after build decisions, when the build is ready to fight, and how to
quickly shape the skill rotation they intend to test.

## Constraints

- Do not change combat math, build-resolution rules, proc behavior, Adventure
  state progression, save behavior, or Practice Room isolation unless a
  specific user-approved bug fix requires it.
- Treat existing Phase 2, Milestone 1, and Milestone 2 build/rotation polish as
  baseline rather than duplicating it.
- Prefer improvements that benefit both Adventure and Practice Room through the
  shared build panels.
- Keep Gear, Rewards, Shop, and Legendary presentation work scoped to Milestone
  4 unless the gear detail is needed to explain current build changes.
- Keep broad Practice Room control/layout work scoped to Milestone 6 unless the
  issue directly affects shared build, talent, stat, or rotation clarity.
- Include only build/rotation-relevant visual consistency work in this
  milestone: selected, disabled, unavailable, capped, locked, active, hover,
  focus, and fight-ready states. Broader whole-game UI skinning belongs to
  Milestone 8, and full art-direction/UI-frame production belongs to a later
  phase.

## Visual Consistency Scope

The current UI was built pragmatically to get the playable loop working. It
has useful fonts, clearer icons, and several focused readability passes, but
many surfaces still read as flat boxes with outlines. Some interaction states
also differ by panel: selected, disabled, unavailable, locked, capped, hover,
focus, and active/fight-ready states are not always treated with the same
visual language.

Milestone 3 should address the portion of that problem that directly affects
buildcraft:

- Make build and rotation states consistent enough that the player can tell
  what is selected, unavailable, locked, capped, editable, active, or ready to
  fight.
- Prefer native Godot styling first: shared `StyleBoxFlat` helpers, consistent
  state colors, restrained fills, borders, separators, hover/focus treatment,
  disabled treatment, and typography/spacing rules.
- Add or reuse small icons only when they clarify a build/rotation state.
- Record broader visual-system needs for later instead of turning M3 into a
  full UI art pass.

Milestone 8 is the better home for a whole-game polish sweep: buttons, hover,
focus, selected, disabled, spacing, typography, contrast, repeated panel
treatments, and rough-edge cleanup across all screens.

A full mock-up-quality fantasy UI skin, with ornate frames, carved edges,
custom panel textures, portrait treatment, bespoke backgrounds, and cohesive
art direction, should be deferred to a later phase. That work needs a separate
assessment of the game's total art direction, asset strategy, and production
budget before implementation.

## Current Baseline

Already present:

- `available_skills_panel.gd` shows unlocked skills as icon/name buttons,
  appends clicked skills to the rotation, uses effect tooltips, uses authored
  speed labels, disables while locked, and disables at the rotation cap.
- `skill_build_panel.gd` shows the current rotation as ordered icon slots with
  order badges, remove affordances, an icon-only lock/unlock button, empty
  state copy, lock-aware editing, combat playback highlight, cast-progress
  fill, and proc/retrigger pulse language.
- `BuildResolver.resolve_rotation()` caps rotations at
  `BuildResolver.MAX_ROTATION_SIZE` and filters out skills no longer unlocked.
  Both `BuildState.set_rotation()` and `TrainingRoomState.set_rotation()` use
  this chokepoint.
- `talent_panel.gd` shows talent cost, visible effect details, selected and
  disabled states, prerequisite/budget lock reasons in tooltips, tree
  intrinsics, secondary-tree locked-state copy, and talent-point budget.
- `active_talents_panel.gd` summarizes active subclass/talent state and opens
  the full Talent Trees overlay. It draws attention to unspent points without
  changing button layout.
- `character_stats_panel.gd` shows live resolved stats and uses BBCode hover
  hints for "from gear/talents" deltas instead of always-visible explanatory
  clutter.
- Adventure and Practice Room share the major build panels through an injected
  `state` property. Practice Room uses `TrainingRoomState` and remains isolated
  from real Adventure state.
- Milestone 2 invalidates completed Practice Room result review when build,
  gear, rotation, target, seed, duration, Legendary, talent, rarity, or
  practice-gold inputs change.
- Existing focused coverage includes `build_panels_test.gd`,
  `rotation_cap_test.gd`, `training_room_build_test.gd`,
  `training_room_fight_test.gd`, and related combat playback/log tests.

Open assessment questions:

- Can the player quickly answer "what changed?" after a talent, gear, route, or
  subclass choice?
- Is rotation editing fast and clear enough after several fights and retries?
- Is the lock/fight relationship obvious before the player learns it?
- Are selected, disabled, invalid, capped, locked, and unavailable states
  visually distinct at a glance?
- Do talent prerequisites and blocked deselects read clearly enough without
  relying entirely on hover?
- Does the Character Stats panel explain the right stats for current
  buildcraft decisions?
- Do Adventure and Practice Room use the same build language where appropriate
  while preserving Practice Room's freeform identity?
- Does the dashboard still fit cleanly at the target resolution after the
  Milestone 1 and 2 presentation additions?
- Which build/rotation UI states can be made more consistent with native Godot
  styling now, and which require a later visual-system or art-direction pass?

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Plan and audit the buildcraft pass | Complete | Initial audit completed from docs/code/tests; M3/M8/later-phase boundaries for visual consistency and art-direction work are recorded. |
| 1. Improve rotation editing UX | Complete | Cap/lock layout direction confirmed; 10-slot geometry guardrail added for Adventure and Practice Room; user review confirmed add/remove speed, duplicate readability, locked state, empty/cap language, and no extra controls are acceptable for now. |
| 2. Clarify fight readiness and build lock state | Complete | Lock Build is confirmed as the ready action; empty rotations cannot become locked/ready in Adventure or Practice Room; no extra instruction copy was added. |
| 3. Audit available skill readability | Complete | Current icon/name buttons, speed/effect tooltips, locked/capped disabled treatment, and shared Adventure/Practice Room behavior are sufficient for the current Rogue mechanics; broader comparison scaffolding is deferred until mechanics grow more complex. |
| 4. Improve talent tree clarity | Complete | Selected talents that support an active dependency chain keep the normal selected visual state, while blocked deselect clicks pulse the clicked talent and dependent chain instead of silently doing nothing. |
| 5. Improve character stats and change feedback | Complete | Current live stat lines, physical/poison grouping, and hover delta hints are sufficient for this phase; broader class/stat/gear presentation work is intentionally deferred until later mechanics changes settle. |
| 6. Align shared Adventure and Practice Room build language | Complete | Conservative audit closed with no product UI changes: shared build vocabulary is aligned enough for current Rogue mechanics, Practice Room remains practice-safe, and focused assertions now cover shared Skill Build behavior plus stale-result invalidation after rotation edits. |
| 7. Add focused tests, verify, and document closeout | Complete | Focused build/rotation/Practice Room tests and adjacent fixture checks passed; milestone docs/onboarding were updated; broader whole-game visual-system work remains deferred to M8 or a later phase. |

## Task Details

### P3:M3:T0 - Plan And Audit The Buildcraft Pass

Status: Complete.

Goal: turn Milestone 3 from a milestone-level goal into a concrete
implementation sequence grounded in the current UI.

Steps:

- P3:M3:T0:S1 - Review Phase 3 milestone docs and M1/M2 carryover work that
  already touched build/rotation surfaces.
- P3:M3:T0:S2 - Audit Adventure build surfaces: available skills, skill build,
  active talents, talent overlay, character stats, gear-derived stats, lock
  state, Fight readiness, retry readiness, and next-action copy.
- P3:M3:T0:S3 - Audit Practice Room shared build surfaces and identify which
  improvements should apply there automatically.
- P3:M3:T0:S4 - Identify boundaries with Milestone 4 gear/reward polish and
  Milestone 6 Practice Room usability work.
- P3:M3:T0:S5 - Identify boundaries between M3 build-state consistency,
  Milestone 8 whole-game polish, and later-phase full art-direction/UI-skin
  work.
- P3:M3:T0:S6 - Finalize task order, verification plan, and definition of done
  with the user.

Expected output:

- This Milestone 3 tasking document.
- Updated Phase 3 milestone tracker.
- A clear implementation order for the first M3 feature task.
- A recorded visual-consistency boundary so M3 improves build usability without
  absorbing the full UI glow-up.

Implementation notes:

- Audited the current build/rotation baseline across Adventure and Training
  Room shared panels.
- Confirmed that several buildcraft basics already exist from Phase 2,
  Milestone 1, and Milestone 2: skill icons/tooltips, rotation order/remove
  affordances, lock/fight readiness gates, talent lock reasons, stat deltas,
  Practice Room state injection, and focused tests.
- Recorded the Milestone 3 boundary for targeted build/rotation visual-state
  consistency, with whole-game UI skinning deferred to Milestone 8 and full
  mock-up-quality art-direction work deferred to a later phase.
- Established M3:T1, rotation editing UX, as the recommended next
  implementation task.

### P3:M3:T1 - Improve Rotation Editing UX

Status: Complete.

Goal: make skill rotation manipulation fast, legible, and forgiving.

Steps:

- P3:M3:T1:S1 - Audit current add/remove behavior in Adventure and Training
  Room, including duplicate skills and repeated edits.
- P3:M3:T1:S2 - Review cap feedback at 10 skills and empty rotation feedback.
- P3:M3:T1:S3 - Review locked-state editing affordances and tooltips.
- P3:M3:T1:S4 - Review whether slot, remove, locked, active, capped, and empty
  states use consistent visual language with other build panels.
- P3:M3:T1:S5 - Decide whether the current click-to-add/click-to-remove model
  needs additional controls such as clear-all, reorder, duplicate count, or
  slot-specific action affordances.
- P3:M3:T1:S6 - Implement only the highest-value scoped interaction changes.
- P3:M3:T1:S7 - Add or update focused tests for changed behavior.

Expected output:

- Faster, clearer rotation editing with deterministic state behavior and test
  coverage.

Implementation notes:

- Confirmed the player-facing cap direction: keep `Slots: x/10` as the
  capacity signal and avoid empty placeholder boxes for now, since empty boxes
  could imply that filling all ten slots is expected.
- Confirmed that the lock button should remain a fixed far-right asset in the
  Skill Build row, not another macro slot.
- Added `res://tests/skill_build_geometry_test.gd` as a focused geometry
  guardrail. It fills the macro to ten `Stab` slots in both Adventure and
  Practice Room, then asserts that slot 10, the fixed lock lane, and the lock
  button stay inside the shared `SkillBuildPanel`, do not overlap, and do not
  bleed outside the host screen at the target 1600x900 viewport.
- The geometry check passed with the current shared `SkillBuildPanel`
  constants, so no additional slot-size or lock-size tuning was made in this
  pass.
- A normal-renderer screenshot probe was used for manual review because the
  headless/dummy renderer cannot capture viewport textures. Adventure and
  Practice Room were checked at one slotted skill and ten slotted skills.
- User review accepted the current add/remove interaction speed, duplicate
  skill readability, lock-state behavior, empty/cap language, and the decision
  to skip Clear All, reorder, duplicate-count badges, and slot-specific action
  menus for now. These controls can be reconsidered after more playtesting,
  but they are not needed to close M3:T1.

### P3:M3:T2 - Clarify Fight Readiness And Build Lock State

Status: Complete.

Goal: make the build lock behave as the clear fight-readiness action without
adding more instructional UI.

Steps:

- P3:M3:T2:S1 - Audit Adventure and Practice Room Fight button disabled states,
  lock button states, top-bar next-action copy, and retry setup copy.
- P3:M3:T2:S2 - Identify any contradictory language between `Build: Locked`,
  lock tooltips, Fight button tooltips, and result/retry instructions.
- P3:M3:T2:S3 - Preserve the current visual/instruction treatment; the disabled
  Fight button and grayed-out lock treatment are intentionally enough for now.
- P3:M3:T2:S4 - Preserve the existing rule that build mutations automatically
  clear the lock.
- P3:M3:T2:S5 - Tighten the state model so an empty rotation cannot enter the
  locked/ready state in Adventure or Practice Room, even through direct state
  calls.
- P3:M3:T2:S6 - Add or update focused tests for lock/fight readiness states.

Expected output:

- The build lock reads as a clear readiness step rather than a hidden gate.
- Empty rotations cannot be locked or started; real losing-fight tests now use
  a slotted skill against an impossible HP target instead of an empty macro.
- No new persistent instruction copy or readiness controls were added.

Closeout notes:

- `BuildState.set_locked(true)` and `TrainingRoomState.set_locked(true)` now
  refuse the locked state while the rotation is empty.
- `BuildState.can_start_current_fight()` now explicitly requires both a locked
  build and a non-empty rotation.
- Older Adventure loss/playback/recap/HUD tests that used an empty macro as a
  guaranteed loss setup were updated to use a real Stab rotation against an
  intentionally impossible HP target, keeping defeat coverage compatible with
  the ready-button contract.

Focused checks:

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
  sandbox for the known autosave/user-data assertion. The first sandboxed run
  failed only on that assertion after the empty-rotation loss fixtures were
  updated.

Known caveats:

- A direct `user://logs/...` Godot log path still crashed on this machine; the
  checks above used explicit workspace `--log-file` paths.
- `res://tests/save_load_test.gd` was not counted in this closeout. A sandboxed
  run hit its startup save-file assertion and timed out; rerunning outside the
  sandbox was rejected because that test deletes the normal Godot user save.
  An attempted isolated `--user-data-dir` rerun still saw the existing save on
  this Godot invocation.
- Godot still printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

### P3:M3:T3 - Audit Available Skill Readability

Status: Complete.

Goal: confirm whether the available-skill strip needs more comparison
scaffolding now, or whether the current compact skill transparency is enough
for the present Rogue mechanics.

Steps:

- P3:M3:T3:S1 - Audit current icon/name buttons and tooltips for each Rogue
  skill and talent/gear-unlocked skill.
- P3:M3:T3:S2 - Compare the current skill strip against today's mechanics
  complexity rather than designing for future skill-system depth.
- P3:M3:T3:S3 - Review selected/capped/locked/disabled treatment for scannable
  differences in Adventure and Practice Room.
- P3:M3:T3:S4 - Implement only true readability defects, such as overlap,
  missing disabled states, or inconsistent shared-panel behavior.
- P3:M3:T3:S5 - Record future revisit triggers for when available-skill
  comparison becomes meaningfully harder.

Expected output:

- A documented audit/defer decision that preserves the compact current strip
  and avoids adding comparison UI before the mechanics require it.

Implementation notes:

- Audited `available_skills_panel.gd`, current Rogue skill resources, subclass
  unlock/augment data, and focused build/rotation tests.
- Confirmed that the current available-skill panel already exposes the useful
  information for today's kit: assigned skill icons, skill names, authored
  flavor speed labels, effect summaries derived from the live `SkillEffect`
  resources, disabled styling while the build is locked, and disabled/full
  tooltip treatment at the rotation cap.
- Confirmed that Adventure and Practice Room share the same panel behavior via
  the injected `state` pattern, and existing focused tests cover tooltip
  summary derivation plus cap-disabled behavior.
- No code changes were made for T3. Current skill transparency is sufficient
  for the present Rogue mechanics, and adding role tags, always-visible effect
  captions, or a larger comparison surface now would likely add clutter before
  it solves a real player problem.
- Revisit available-skill comparison when mechanics introduce enough overlap or
  dependency to make the compact strip insufficient: more playable classes or
  subclasses, larger unlocked skill pools, sharper enemy build asks, proc
  chains, gear-skill dependencies, mutually exclusive skill paths, or several
  skills with similar names/roles but materially different combat jobs.

### P3:M3:T4 - Improve Talent Tree Clarity

Status: Complete.

Goal: make talent spending, prerequisites, and selected effects easier to read
and trust.

Steps:

- P3:M3:T4:S1 - Audit selected, selectable, budget-locked, prerequisite-locked,
  and dependency-blocked deselect states.
- P3:M3:T4:S2 - Review whether lock reasons being tooltip-only is still enough
  after the current dashboard layout.
- P3:M3:T4:S3 - Review the Active Talents summary as the "what is active now"
  surface.
- P3:M3:T4:S4 - Improve prerequisite/change/readability language where useful
  while preserving compact layout.
- P3:M3:T4:S5 - Add or update focused tests for talent state text, tooltips,
  selected effects, and point-budget feedback.

Expected output:

- Talent choices feel explainable before and after the player spends points.

Implementation notes:

- Audited selected, selectable, budget-locked, prerequisite-locked, and
  dependency-blocked deselect states in the shared `talent_panel.gd`.
- Preserved the previous playtest decision that unavailable talent lock
  reasons stay tooltip-only; no always-visible prerequisite captions were
  reintroduced.
- Added protected-selected detection for selected talents that cannot be
  removed because a selected dependent talent requires them. These talents keep
  the normal selected visual state to avoid idle UI noise.
- Blocked deselect clicks now trigger visual feedback instead of feeling inert:
  the clicked protected talent flashes with warning color, and the selected
  dependent chain above it pulses. The dependency walk respects OR-prerequisite
  rules, so a talent stops reading as protected once another selected option
  still satisfies the dependent requirement.
- User review accepted the quieter final direction: no persistent yellow
  protected outline or anchor marker at rest; the visual explanation comes from
  the blocked-click pulse.
- The change is presentation-only. It does not change `PassiveAllocator`,
  combat math, build resolution, talent costs, selected talent rules, Adventure
  progression, save behavior, or Practice Room isolation.
- Updated `build_panels_test.gd` to cover the real Thief chain
  `Quick Hands -> Practiced Rhythm -> Opportunity Strikes`, including the
  alternate `Piercing Blades` OR-prerequisite case.

### P3:M3:T5 - Improve Character Stats And Change Feedback

Status: Complete.

Goal: help the player understand build-impact changes without adding constant
noise.

Steps:

- P3:M3:T5:S1 - Audit current stat lines, grouping, labels, values, and hover
  deltas.
- P3:M3:T5:S2 - Identify which build changes should produce more visible
  feedback: gear equip, talent spend, subclass choice, route choice, Legendary
  equip, practice gold, or rotation changes.
- P3:M3:T5:S3 - Decide whether to add lightweight recent-change emphasis,
  clearer stat grouping, comparison language, or enemy-relevance hints.
- P3:M3:T5:S4 - Keep gear-card excitement and deep comparisons deferred to
  Milestone 4 unless the stat panel needs the information for build clarity.
- P3:M3:T5:S5 - Add or update focused tests for stat text, delta hints, and
  any change-feedback state.

Expected output:

- The stats panel better answers "what did my build decision change?" without
  becoming a tutorial block.

Implementation notes:

- Audited the current `character_stats_panel.gd` implementation and existing
  Practice Room stat-change coverage.
- Confirmed that the panel already exposes the useful first-pass information
  for current Rogue buildcraft: live resolved values, physical stats grouped
  before poison stats, poison-colored poison lines, bonus physical damage,
  bonus armor shred, min-cast proc chance, bonus poison stacks, and hover
  deltas against the class-only baseline.
- Confirmed that Adventure and Practice Room share the same stat panel through
  the injected `state` pattern, and that existing focused tests already cover
  visible stat refreshes after Practice Room Legendary, practice-gold, and gear
  editor changes.
- No code changes were made for T5. The current character stat feedback is
  good enough for Phase 3, and adding recent-change emphasis, enemy-relevance
  hints, deeper comparison copy, or larger stat restructuring now would risk
  churn ahead of planned extensive later-phase changes to classes, stats, and
  gear.
- Revisit character-stat presentation after those mechanics changes settle,
  especially if future classes add meaningfully different stat needs, gear
  affixes become more numerous or conditional, or enemies start asking for
  sharper stat-specific answers.

### P3:M3:T6 - Align Shared Adventure And Practice Room Build Language

Status: Complete.

Goal: ensure shared build panels improve both modes consistently while keeping
mode-specific meanings separate.

Steps:

- P3:M3:T6:S1 - Identify which M3 changes should apply to both `BuildState`
  and `TrainingRoomState` through shared panels.
- P3:M3:T6:S2 - Keep Adventure-only language out of Practice Room surfaces.
- P3:M3:T6:S3 - Confirm Practice Room result-review invalidation remains
  correct after shared build-panel changes.
- P3:M3:T6:S4 - Defer target controls, gear editor layout, and broad practice
  workflow improvements to Milestone 6 unless directly affected by shared
  build/rotation changes.
- P3:M3:T6:S5 - Add or update focused Practice Room assertions for shared
  panel behavior and Adventure-state isolation.

Expected output:

- Adventure and Practice Room share build vocabulary where appropriate, and
  remain semantically distinct where they should.

Closeout:

- Audited the M3 shared build-panel changes against Adventure's `BuildState`
  and Practice Room's `TrainingRoomState`. Rotation cap display, empty-lock
  prevention, lock/unlock tooltips, Available Skills capped/locked behavior,
  talent dependency feedback, and Character Stats language all flow through
  shared panels where appropriate.
- Kept Practice Room product UI unchanged after user review confirmed the
  current Practice Room state is acceptable. The shared Skill Build lock
  language remains neutral enough for both modes: it talks about the skill
  macro and the fight, not Adventure rewards, route progress, map state,
  contracts, or save commitment.
- Confirmed Practice Room result-review invalidation still clears completed
  practice review after shared build-panel changes. `training_room_fight_test`
  now exercises a real post-result rotation edit through `SkillBuildPanel`
  and asserts the Combat Log/review UI is invalidated before the build is
  re-locked and rerun.
- Added `training_room_build_test` assertions that Practice Room's injected
  shared Skill Build panel is not pointed at the real `BuildState`, starts
  with `Slots: 0/10`, refuses empty locking, uses no Adventure/reward wording
  in the empty-lock tooltip, updates to `Slots: 1/10` after a practice skill
  is slotted, and exposes the same lock/unlock tooltip rhythm as Adventure.
- Deferred target controls, gear editor layout, and broader practice workflow
  improvements to Milestone 6. No combat math, build resolution, skill/talent/
  gear resources, Adventure progression, save behavior, or Practice Room
  isolation rules were changed.

Focused checks passed on 2026-08-02 using
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

### P3:M3:T7 - Add Focused Tests, Verify, And Document Closeout

Status: Complete.

Goal: finish Milestone 3 with focused coverage and current handoff docs.

Steps:

- P3:M3:T7:S1 - Add or update focused tests for each implemented M3 behavior.
- P3:M3:T7:S2 - Run focused checks after touching shared build panels,
  `BuildState`, `TrainingRoomState`, or Practice Room build wiring.
- P3:M3:T7:S3 - Run Balance Lab only if implementation touches combat math,
  build resolution, skill/talent/gear resources, or balance-relevant data.
- P3:M3:T7:S4 - Update this document with completed work and latest checks.
- P3:M3:T7:S5 - Update `P3_CrystalMaiden_Overview.md` and
  `P3_CrystalMaiden_Onboarding_Context.md`.
- P3:M3:T7:S6 - Record any deferred visual-system or art-direction items for
  Milestone 8 or a later phase.
- P3:M3:T7:S7 - Commit and push Milestone 3 work after review/approval.

Expected output:

- M3 behavior is covered by focused tests, documented, and ready for Milestone
  4.

Implementation notes:

- Added or confirmed focused coverage for each implemented M3 behavior:
  slot count/cap display, empty-macro lock prevention, fixed lock-lane
  geometry, Practice Room shared Skill Build language, stale practice result
  invalidation after rotation edits, and talent dependency blocked-deselect
  pulse feedback.
- Updated adjacent loss fixtures that previously depended on empty rotations.
  They now use real Stab rotations against intentionally impossible HP targets
  so the new lock-as-ready rule is preserved without weakening the loss,
  retry, HUD, playback, or recap checks.
- Verified Practice Room's no-gear default and rarity-driven equip/unequip
  behavior with focused Practice Room gear assertions.
- Balance Lab was not run because T7 did not change combat math, resolver
  behavior, build-resolution rules, skill/talent/gear resources, or
  balance-relevant data.
- Broader visual-system and art-direction work remains deferred as recorded
  in the Visual Consistency Scope: Milestone 8 should own the whole-game UI
  polish sweep, while full fantasy UI skin/art direction belongs to a later
  phase.

## Implementation Surfaces

Likely files:

- `project/scenes/combat/available_skills_panel.gd`
- `project/scenes/combat/skill_build_panel.gd`
- `project/scenes/combat/talent_panel.gd`
- `project/scenes/combat/active_talents_panel.gd`
- `project/scenes/combat/character_stats_panel.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/training_room/training_room.gd`
- `project/scripts/autoload/build_state.gd`
- `project/scripts/systems/training_room_state.gd`
- `project/scripts/systems/build_resolver.gd`
- `project/scripts/ui/card_style.gd`
- `project/scripts/ui/ui_colors.gd`
- `project/tests/build_panels_test.gd`
- `project/tests/rotation_cap_test.gd`
- `project/tests/training_room_build_test.gd`
- `project/tests/training_room_fight_test.gd`
- `project/tests/training_room_fight_setup_test.gd`

## Verification Plan

Focused checks expected during this milestone:

- `res://tests/build_panels_test.gd`
- `res://tests/rotation_cap_test.gd`
- `res://tests/skill_build_geometry_test.gd`
- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_fight_test.gd`
- `res://tests/training_room_fight_setup_test.gd`

Add or rerun these if the implementation touches adjacent behavior:

- `res://tests/combat_screen_test.gd`
- `res://tests/combat_hud_test.gd`
- `res://tests/save_load_test.gd`
- `res://tests/passive_allocator_test.gd`
- `res://tests/balance_lab_test.gd`

Run Balance Lab if implementation touches build resolution, combat math,
skill/talent/gear resources, resolver behavior, or balance-relevant data.

Known caveats from the current project still apply:

- Godot may print ObjectDB/resource cleanup warnings at exit even when checks
  pass with exit code 0.
- `combat_playback_test.gd` may need to run outside the sandbox for the known
  autosave/user-data assertion.
- Use explicit workspace `--log-file` paths for headless Godot checks.
- Viewport screenshot capture requires the normal renderer on this machine;
  headless checks use the dummy renderer and cannot read viewport textures.

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

- P3:M3:T5 character stats and change-feedback audit completed on 2026-08-02:
  docs-only audit/defer decision, no code changes, no Godot checks required.
  Current live stat lines and hover delta hints are sufficient for this phase;
  broader stat/change presentation is deferred until later class, stat, and
  gear changes settle.

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

- P3:M3:T3 available-skill readability audit completed on 2026-08-02:
  docs-only audit/defer decision, no code changes, no Godot checks required.
  Current available-skill transparency is sufficient for current Rogue
  mechanics; revisit when mechanics create real comparison pressure.

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
  - A normal-renderer screenshot probe saved and reviewed Adventure and
    Practice Room at one slotted skill and ten slotted skills. The temporary
    probe script was removed afterward; the permanent coverage is the geometry
    test.
  - Godot still printed the known Windows root-certificate-store warning and
    ObjectDB/resource cleanup warnings at exit despite passing exit code 0.

## Definition Of Done

Milestone 3 is done when:

- The build and rotation surfaces have been audited from the player's
  decision-making perspective.
- Rotation editing is clearer and no slower than the current baseline.
- Fight readiness and build lock state are obvious in Adventure and Training
  Room.
- Available skill states and skill identity have been audited; current
  transparency is sufficient for present Rogue mechanics, with future
  comparison scaffolding deferred until mechanics grow more complex.
- Talent selection, lock reasons, point spending, and active-talent summaries
  are clear enough for current Rogue builds.
- Character stats have been audited from the player's decision-making
  perspective; current live values and hover delta hints are sufficient for
  this phase without noisy permanent explanation text.
- Shared improvements preserve Practice Room isolation and avoid Adventure-only
  language in practice mode.
- Build/rotation state styling is more consistent for selected, disabled,
  unavailable, capped, locked, hover, focus, active, and fight-ready states,
  using native Godot styling unless small existing assets are clearly useful.
- Broader whole-game UI skinning needs are recorded for Milestone 8, and full
  mock-up-quality fantasy UI/art-direction work is deferred to a later phase.
- Focused checks pass and results are recorded here.
- Phase 3 milestone tracker and onboarding handoff are updated.
