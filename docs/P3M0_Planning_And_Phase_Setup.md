# Phase 3 Milestone 0: Planning And Phase Setup

## Purpose

Milestone 0 established the Phase 3 workspace, scope, baseline checks, and
documentation structure for Project CrystalMaiden.

## Status

Complete.

## Tasking

| Task | Status | Notes |
|---|---|---|
| Preserve Phase 2 closeout state | Complete | Created the `phase-2-bane-closeout` tag. |
| Create Phase 3 working branch | Complete | Created `phase-3-crystalmaiden`. |
| Set up the Phase 3 workspace | Complete | `Project-CrystalMaiden` is the clean Phase 3 local clone; `Project-Bane` remains the Phase 2 historical clone. |
| Approve the Phase 3 milestone structure | Complete | Phase 3 Milestones 0-9 are tracked in `P3_CrystalMaiden_Overview.md`. |
| Audit the current playable flow | Complete | Reviewed the major Adventure, combat, reward, training, testing, and export surfaces. |
| Establish Milestone 1 as the first implementation target | Complete | Milestone 1 begins with combat playback presentation work. |
| Run focused baseline checks | Complete | Playback, HUD, recap, Practice Room combat view, and Balance Lab checks passed after the initial import pass. |

## Completed Work

- Created and pushed the Phase 3 branch.
- Created and pushed the Phase 2 closeout tag.
- Set up `Project-CrystalMaiden` as its own Phase 3 clone.
- Cleaned Phase 3 docs to the handoff/planning set.
- Approved the Phase 3 milestone structure.
- Completed the current-state audit.
- Created the Milestone 1 tasking plan.

## Baseline Verification

Focused checks passed after a one-time Godot import:

- `res://tests/combat_playback_test.gd`
- `res://tests/combat_recap_test.gd`
- `res://tests/combat_hud_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/balance_lab_test.gd`

Known caveats:

- Godot may print ObjectDB/resource cleanup warnings at exit even when checks
  pass with exit code 0.
- A fresh clone may need a headless editor/import run before tests can resolve
  imported fonts and global classes.

## Audit Summary

The current build already has a functional Phase 2 presentation layer:

- Persistent Adventure dashboard.
- Combat HUD with HP bar and status chips.
- Real-time combat playback using a deterministic event timeline.
- Skill popups for hits, crits, poison ticks, and procs.
- Playback speed controls and skip.
- Victory and loss recap presentation.
- Practice Room combat playback.
- Focused tests for playback, HUD, recap, Practice Room combat view, and
  Balance Lab.

The Phase 3 opportunity is to make this visual language clearer, stronger,
more consistent, and more satisfying without redesigning the core game.

## Deferred To Later Milestones

- Combat recap hierarchy and failure teaching belong primarily to Milestone 2.
- Build, rotation, and talent manipulation belong primarily to Milestone 3.
- Gear, shop, rewards, and Legendary presentation belong primarily to
  Milestone 4.
- Adventure transitions and major route/story beats belong primarily to
  Milestone 5.
- Practice Room control ergonomics belong primarily to Milestone 6.
- Test-suite and Balance Lab hardening belong primarily to Milestone 7.
- Placeholder audio remains provisional until Milestone 8.
