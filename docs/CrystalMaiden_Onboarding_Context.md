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
- Milestone 1: In Progress

Milestone 1 is currently in Task 0 planning. Implementation has not started
yet.

Latest known pushed commit:

- `4fbb186 Close Milestone 0 planning`

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
- `project/scripts/systems/combat_result_formatter.gd`
- `project/scripts/systems/combat_recap.gd`
- `project/scripts/systems/gear_generator.gd`
- `project/scripts/systems/run_rng.gd`
- `project/scripts/systems/save_system.gd`
- `project/scripts/tools/balance_lab.gd`

Key docs:

- `docs/Phase_3_CrystalMaiden_Milestones.md`
- `docs/Phase_3_Current_State_Audit_Checklist.md`
- `docs/Phase_3_Milestone_1_Task_0_Combat_Playback_Plan.md`
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
- Created Milestone 1 Task 0 planning doc.

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

## Current Milestone: Milestone 1

Milestone 1: Combat Playback Juice.

Goal:

- Make automated combat feel more readable, punchy, and satisfying while
  remaining faithful to the resolved combat timeline.

Current state:

- Task 0 planning doc exists.
- Implementation tasks have not started.

Milestone 1 should focus on:

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
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/training_room/training_room_combat_view.gd`
- `project/tests/combat_playback_test.gd`
- `project/tests/combat_hud_test.gd`
- `project/tests/training_room_combat_view_test.gd`

Recommended next action:

- Continue Milestone 1 Task 0 by choosing the first small implementation
  slice, likely start-of-fight readability plus clearer event-type visual
  language.

## Working Agreements

- Start each implementation milestone with Task 0 planning.
- Keep milestone/task/status docs updated as work progresses.
- Prefer conservative, scoped changes that match existing Godot patterns.
- Preserve determinism and avoid changing combat math during presentation work.
- Run focused tests after touching combat playback, HUD, Training Room combat
  playback, event formatting, or recap behavior.
- Run Balance Lab when changing combat timing, event ordering, build
  resolution, skill/talent/gear resources, or balance-relevant data.
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
