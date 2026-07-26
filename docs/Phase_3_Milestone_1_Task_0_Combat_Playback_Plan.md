# Phase 3 Milestone 1 Task 0: Combat Playback Juice Plan

## Purpose

This document starts Milestone 1 by turning the Milestone 0 audit findings into
a concrete planning brief.

Milestone 1 should improve combat playback feel, readability, and mechanical
clarity without changing combat resolution math.

## Milestone Goal

Make automated combat feel more readable, punchy, and satisfying while staying
faithful to the already-resolved combat timeline.

## Starting Baseline

Existing systems:

- `CombatResolver` resolves the fight synchronously.
- `CombatPlayback` replays the resolved cast/tick timeline.
- Adventure combat screen has HUD, HP bar, status chips, popups, speed
  controls, skip, delayed reveal, victory overlay, and loss recap.
- Training Room has its own combat playback surface using the same
  `CombatPlayback` controller.
- Focused headless checks pass for playback, HUD, recap, Training Room combat
  view, and Balance Lab after a one-time Godot import in the fresh clone.

Important constraint:

- Animation can add feel, anticipation, and readability, but it must not become
  a second combat simulator.

## Task List

### Task 0: Plan The Combat Playback Pass

Status: In Progress

Steps:

- Review Milestone 0 audit findings.
- Identify key combat scenarios for visual testing.
- Identify likely implementation files.
- Define the Milestone 1 definition of done.
- Decide whether any presentation-blocking event data is missing.

### Task 1: Build Controlled Playback Scenarios

Status: Not Started

Goal: make it easy to repeatedly test each mechanic's presentation.

Candidate scenarios:

- Basic physical hit.
- Guaranteed crit.
- Poison stack application followed by poison ticks.
- Armor reduction.
- Poison resistance reduction.
- Triggered skill or retrigger.
- Minimum-cast proc.
- Victory reveal.
- Defeat reveal.

Likely surfaces:

- Training Room target/build setup.
- Existing focused tests.
- Possibly a small developer-only scenario helper if repeated manual setup is
  too slow.

### Task 2: Improve Start-Of-Fight Readability

Status: Not Started

Goal: give combat a clearer beginning before timeline events start firing.

Possible work:

- Brief anticipation beat before first cast.
- Clearer "fight has begun" state in the combat window.
- Better transition from locked build to playback.

### Task 3: Improve Hit And Crit Feedback

Status: Not Started

Goal: make normal hits and crits feel distinct at a glance.

Possible work:

- Refine popup motion, size, color, and timing.
- Add impact pulse or HP-bar response polish.
- Ensure rapid casts do not create unreadable popup clutter.

### Task 4: Improve Poison Feedback

Status: Not Started

Goal: distinguish poison stack application from poison tick damage.

Possible work:

- Add clearer stack-add feedback.
- Keep tick feedback periodic and readable.
- Make active poison stacks easier to read before stack-scaling skills.

### Task 5: Improve Persistent Enemy State Feedback

Status: Not Started

Goal: make armor reduction and poison resistance reduction read as ongoing
enemy states.

Possible work:

- Give armor reduction and poison vulnerability distinct chip styles.
- Consider small persistent enemy-state indicators.
- Avoid making poison vulnerability look like armor shred.

### Task 6: Improve Proc And Minimum-Cast Feedback

Status: Not Started

Goal: make triggered skills and minimum-cast procs readable as different event
types.

Possible work:

- Visually chain triggered skills to their source cast.
- Make minimum-cast procs read as speed/timing events.
- Keep Legendary proc feedback special without implying extra damage when the
  mechanic is timing-based.

### Task 7: Improve Victory And Defeat Reveals

Status: Not Started

Goal: make combat-end moments feel better and make the next action clearer.

Possible work:

- Add a cleaner final beat after the last timeline event.
- Improve victory reveal timing.
- Improve defeat reveal clarity.
- Preserve Milestone 2's deeper recap/failure-teaching scope.

### Task 8: Verify And Document

Status: Not Started

Goal: confirm Milestone 1 did not alter combat math or break focused playback
behavior.

Verification targets:

- `res://tests/combat_playback_test.gd`
- `res://tests/combat_hud_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/combat_recap_test.gd` if reveal/recap timing changes.
- Balance Lab only if event ordering, combat timing, build resolution, or
  combat data changes.

## Likely Implementation Files

- `project/scripts/ui/combat_playback.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/training_room/training_room_combat_view.gd`
- `project/scripts/systems/combat_result_formatter.gd`
- `project/scripts/systems/combat_recap.gd`
- `project/tests/combat_playback_test.gd`
- `project/tests/combat_hud_test.gd`
- `project/tests/training_room_combat_view_test.gd`

## Definition Of Done

Milestone 1 is complete when:

- The major combat event types are visually distinct enough to read without
  opening the combat log.
- Poison stacks, poison ticks, armor reduction, poison vulnerability, triggered
  skills, and minimum-cast procs no longer feel like the same kind of popup.
- Victory and defeat reveals feel intentional rather than abrupt.
- Adventure combat and Training Room combat use compatible visual language.
- Focused playback/HUD/Training Room tests pass.
- Any known visual gaps are documented for later art/audio/UI passes.

## Guardrails

- Do not redesign combat resolution.
- Do not add new classes, contracts, or broad monster content.
- Do not start the Phase 4 encounter overhaul.
- Do not use animation timing to change gameplay timing.
- Do not make placeholder audio mandatory for Milestone 1.
