# Phase 3 Milestone 6: Practice Room Usability Pass

## Purpose

Milestone 6 finishes the Practice Room usability pass that was substantially
pulled forward during Milestone 5.

This is the single tasking and status document for Milestone 6. It follows the
project hierarchy:

- Phase: 3, Project CrystalMaiden
- Milestone: 6, Practice Room Usability Pass
- Task: milestone-sized work item
- Step: implementation-sized action inside a task

## Status

Complete.

## Milestone Goal

Make the Practice Room feel like a fast, clear, isolated place to learn the
game's mechanics by experimenting with builds, talents, gear, targets, combat
playback, and combat logs.

The player-facing framing should be positive: Practice Room is where players
learn how the systems work and get better through experimentation. Avoid
framing it mainly as a post-failure consolation space.

## Design Direction

Milestone 6 should be low effort and audit-driven because a substantial
Practice Room slice was already pulled forward during Milestone 5.

Already pulled forward:

- Player-facing `Practice Room` naming.
- Main-menu entry cleanup.
- Adventure/Practice combat-window parity.
- Training dummy presentation.
- Training dummy hit reactions.
- Fight Setup card.
- Practice Room logo/fill work.
- Practice-specific Talent Trees attention cleanup.
- Paper-doll gear editor direction.
- Focused slot popups for gear editing instead of a tall always-expanded form.

The remaining M6 work should tighten the loop:

1. Choose or adjust a build.
2. Configure the practice setup.
3. Fight.
4. Read what happened.
5. Change something and try again.

Prioritize:

- Small copy and layout fixes that improve learning through experimentation.
- Visual alignment issues that undermine combat readability.
- Focused checks that confirm Practice Room remains isolated from Adventure
  state and save data.
- Documentation that records what was already completed during M5.

Avoid by default:

- New mechanics.
- New enemy roster work.
- Balance changes.
- Turning Practice Room into the Balance Lab.
- A broad UI skin pass.
- Reworking shared build/talent/gear systems unless a Practice Room bug requires
  a narrow fix.

## Closeout Summary

Final state:

- The Practice Room subtitle now says:
  `Where questionable builds go to become slightly less questionable.`
- The Practice Target dummy art was lowered and slightly reduced in scale while
  preserving the existing contact-shadow floor line. User playtest confirmed
  the adjusted floor/scale read looks good.
- Target, Fight Setup, Legendary/gear, talent, rotation, playback, recap, and
  Combat Log surfaces were reviewed with the user and closed without additional
  functional changes.
- Practice Room combat presentation remains intentionally close to Adventure
  combat where useful, while Practice-specific wording and tool behavior stay
  Adventure-state-free.
- Final focused checks confirm Practice Room still does not affect Adventure
  state or save data.

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Plan and audit the pulled-forward Practice Room work | Complete | Created the M6 plan, recorded the low-effort scope, and classified M5-pulled Practice Room improvements as the baseline for a small finish pass. |
| 1. Replace Practice Room framing copy | Complete | Replaced the post-failure subtitle with `Where questionable builds go to become slightly less questionable.` The line keeps the Practice Room's irreverent early-2000s buildcraft flavor while framing it as an experimentation space. |
| 2. Fix training dummy floor alignment and scale | Complete | Lowered the Practice Target sprite, slightly reduced its scale, and kept the contact shadow on its existing floor line. Focused combat-view checks passed, and user playtest confirmed the result looks good. |
| 3. Audit target, Legendary, talent, and rotation setup friction | Complete | Audit-only closeout: user review confirmed the current Practice Room setup controls are in a good place, so no functional changes were made. Focused setup, gear, rotation, and geometry checks passed. |
| 4. Audit Practice combat playback, recap, and Combat Log usefulness | Complete | Audit-only closeout: user review confirmed Practice playback, recap, and Combat Log are in a good place, so no functional changes were made. Focused playback/fight/recap checks passed. |
| 5. Verify Practice Room isolation and focused regressions | Complete | Final focused Practice Room suite and adjacent combat/build checks passed. Practice Room entry, fight setup, build, gear, combat view, and fight tests continue to confirm Adventure state/save isolation. |
| 6. Verify, document, and close Milestone 6 | Complete | Updated M6 tasking, overview, and onboarding docs; recorded final verification notes; Balance Lab was skipped because M6 did not change combat math, build resolution, gear/talent resources, or balance data. |

## Task Details

### P3:M6:T0 - Plan And Audit The Pulled-Forward Practice Room Work

Status: Complete.

Goal: turn M6 into a small, accurate finish pass rather than repeating work
already completed during M5.

Steps:

- P3:M6:T0:S1 - Review M5 pulled-forward Practice Room improvements.
- P3:M6:T0:S2 - Mark original M6 goals as already covered, still useful, or
  deferred.
- P3:M6:T0:S3 - Record the low-effort milestone direction.
- P3:M6:T0:S4 - Add the current user feedback: learning-oriented Practice Room
  copy, dummy sprite floor alignment, and slightly smaller dummy scale if
  needed.
- P3:M6:T0:S5 - Identify focused Practice Room test files for closeout.

Expected output:

- A current M6 plan that reflects the actual state after M5.
- Clear small-fix targets for Practice Room copy and dummy presentation.
- A focused verification plan.

Notes:

- M6:T0 is complete as a planning task. No implementation checks were run
  because this task only created and updated documentation.

### P3:M6:T1 - Replace Practice Room Framing Copy

Status: Complete.

Goal: make the Practice Room subtitle match the intended player promise.

Current issue:

- `Experiment after a failed Adventure -- never touches your real save.` frames
  Practice Room as a failure fallback, which is not the desired tone.

Direction:

- Frame Practice Room as a place to learn mechanics through experimentation.
- Reinforce that experimentation is a core part of getting good.
- Preserve save-isolation clarity where useful, but do not make it the emotional
  center of the subtitle.

Notes:

- Replaced the subtitle with `Where questionable builds go to become slightly
  less questionable.`
- Kept save-isolation out of the headline copy so the Practice Room reads as a
  proactive experimentation tool rather than a failed-Adventure fallback.
- Verification: `res://tests/training_room_entry_test.gd` passed on
  2026-08-05 with the known Godot certificate/resource cleanup warnings.

### P3:M6:T2 - Fix Training Dummy Floor Alignment And Scale

Status: Complete.

Goal: make the Practice Room combat stage read as a shared floor plane.

Current issue:

- The dummy shadow is on the right floor line, but the training dummy sprite
  sits too high above the shadow.
- The dummy also reads slightly large relative to the Rogue.

Direction:

- Keep the shadow where it is.
- Bring the training dummy sprite down to meet the shadow.
- Make the dummy slightly smaller if that improves scale matching.
- Preserve the existing Adventure/Practice combat-window parity and dummy hit
  reactions.

Implementation notes:

- Adjusted `PRACTICE_DUMMY_SPRITE_SCALE` from `4.35` to `4.15`.
- Adjusted `PRACTICE_DUMMY_SPRITE_OFFSET` from `Vector2(0.0, 72.0)` to
  `Vector2(0.0, 88.0)`.
- Added `PRACTICE_DUMMY_SHADOW_OFFSET := Vector2(0.0, -16.0)` so the dummy
  art can sit lower while the contact shadow remains on the prior floor line.
- Added a focused combat-view assertion for the lowered dummy art versus the
  retained shadow line.
- Verification: `res://tests/training_room_combat_view_test.gd` passed on
  2026-08-05 with the known Godot certificate/resource cleanup warnings.
- Adjacent shared-stage sanity check: `res://tests/combat_screen_test.gd`
  passed on 2026-08-05 with the known Godot certificate/resource cleanup
  warnings.
- User playtest confirmed the adjusted dummy floor alignment and scale look
  good; T2 is complete.

### P3:M6:T3 - Audit Target, Legendary, Talent, And Rotation Setup Friction

Status: Complete.

Goal: confirm setup controls are fast enough for repeated experiments.

This should mostly be an audit/check task unless a clear low-risk fix appears.
The milestone should not expand into a broad Practice Room redesign.

Notes:

- Closed as an audit-only task after user review confirmed the current
  Practice Room target, Fight Setup, Legendary/gear, talent, and rotation
  controls are in a good place.
- No functional changes were made for T3.
- Verification passed on 2026-08-05:
  `res://tests/training_room_fight_setup_test.gd`,
  `res://tests/training_room_build_test.gd`,
  `res://tests/training_room_gear_editor_test.gd`,
  `res://tests/rotation_cap_test.gd`, and
  `res://tests/skill_build_geometry_test.gd`.
- Checks emitted the known Godot certificate/resource cleanup warnings.

### P3:M6:T4 - Audit Practice Combat Playback, Recap, And Combat Log Usefulness

Status: Complete.

Goal: confirm Practice Room fights help the player understand what happened and
what to try next.

Practice mode should share Adventure's combat clarity where useful, but wording
should remain practice-safe and should not imply Adventure consequences.

Notes:

- Closed as an audit-only task after user review confirmed the current Practice
  playback, recap, and Combat Log surfaces are in a good place.
- No functional changes were made for T4.
- Practice wording remains Adventure-state-free in the focused recap/log
  coverage.
- Verification passed on 2026-08-05:
  `res://tests/training_room_combat_view_test.gd`,
  `res://tests/training_room_fight_test.gd`, and
  `res://tests/combat_recap_test.gd`.
- Checks emitted the known Godot certificate/resource cleanup warnings.

### P3:M6:T5 - Verify Practice Room Isolation And Focused Regressions

Status: Complete.

Goal: prove Practice Room remains safe to experiment in.

Likely focused checks:

- `res://tests/training_room_entry_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/training_room_fight_test.gd`
- `res://tests/training_room_fight_setup_test.gd`
- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_gear_editor_test.gd`

Run adjacent combat/build checks if implementation touches shared combat stage,
build panels, talent panels, or gear editor behavior.

Notes:

- Final closeout verification passed on 2026-08-05.
- Practice Room isolation checks passed through entry/exit, fight setup,
  build/talent/Legendary setup, gear editor, and fight-result assertions.
- Focused Practice Room checks:
  `res://tests/training_room_entry_test.gd`,
  `res://tests/training_room_combat_view_test.gd`,
  `res://tests/training_room_fight_test.gd`,
  `res://tests/training_room_fight_setup_test.gd`,
  `res://tests/training_room_build_test.gd`, and
  `res://tests/training_room_gear_editor_test.gd`.
- Adjacent shared checks:
  `res://tests/combat_screen_test.gd`,
  `res://tests/rotation_cap_test.gd`,
  `res://tests/skill_build_geometry_test.gd`, and
  `res://tests/combat_recap_test.gd`.
- Checks emitted the known Godot certificate/resource/RID cleanup warnings.

### P3:M6:T6 - Verify, Document, And Close Milestone 6

Status: Complete.

Goal: close the small Practice Room finish pass cleanly.

Expected output:

- Updated M6 task statuses.
- Final focused verification notes.
- Updated `docs/P3_CrystalMaiden_Overview.md`.
- Updated `docs/P3_CrystalMaiden_Onboarding_Context.md`.
- Deferred notes for any larger Practice Room, Balance Lab, or mechanics-tooling
  ideas that belong in M7 or a later phase.

Notes:

- M6 closed as a low-effort audit and finish pass after the largest Practice
  Room usability improvements were pulled forward during M5.
- T1 replaced the Practice Room subtitle with `Where questionable builds go to
  become slightly less questionable.`
- T2 fixed the Practice Target floor/scale read by lowering the dummy art,
  slightly reducing its scale, and keeping the contact shadow on the existing
  floor line; user playtest confirmed the result.
- T3 and T4 closed as audit-only tasks after user review confirmed the current
  setup, playback, recap, and Combat Log surfaces are in a good place.
- T5 final verification passed, including the focused Practice Room suite plus
  adjacent shared combat/build checks.
- Balance Lab was not run because M6 did not change combat math, event
  ordering, build resolution rules, skill/talent/gear resources, or
  balance-relevant data.

## Verification Notes

Use `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` for focused
Godot checks. Prefer explicit workspace `--log-file` paths for headless test
runs.

Known caveats from previous milestones:

- Godot may print Windows root-certificate-store warnings.
- Godot may print ObjectDB/resource cleanup warnings at exit even when tests
  pass with exit code 0.
- `res://tests/combat_playback_test.gd` may reproduce the known sandbox
  autosave/user-data assertion and pass outside the sandbox.

Final M6 closeout checks passed on 2026-08-05:

- `res://tests/training_room_entry_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/training_room_fight_test.gd`
- `res://tests/training_room_fight_setup_test.gd`
- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_gear_editor_test.gd`
- `res://tests/combat_screen_test.gd`
- `res://tests/rotation_cap_test.gd`
- `res://tests/skill_build_geometry_test.gd`
- `res://tests/combat_recap_test.gd`

Balance Lab was skipped for M6 closeout because this milestone did not change
combat math, event ordering, build resolution rules, skill/talent/gear
resources, or balance-relevant data.
