# P2:R8 - Playtest Build

## Purpose

Track the work for **P2:R8 - Playtest Build**.

The goal is to make the revised Phase 2 Rogue Adventure shareable with a
non-developer. This milestone is about bug fixing, export readiness, minimum
legibility, and collecting useful feedback.

Scope note from 2026-07-17: a compact **Training Room Lite** may be added near
the end of this milestone if the Rogue Adventure path is already stable. This
is playtest support, not a new Phase 2 parity blocker. Full Phase 1 Training
Room mode remains Phase 3+.

## Exit Criteria

P2:R8 is complete when:

- A Windows desktop build can be exported and launched outside the editor.
- A non-developer can play the Rogue Adventure unassisted.
- The run can proceed from character creation through Tavern, contract route,
  Knives, and Vyra.
- Save/load works in the exported build.
- Known critical bugs are fixed or documented.
- Feedback collection prompts are ready.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R8:T1 | Define Playtest Scope | What testers should and should not judge | Not started |
| P2:R8:T2 | Run Full Regression Pass | Current automated tests and manual playthrough results | Not started |
| P2:R8:T3 | Fix Critical Bugs | Blocking issues resolved | Not started |
| P2:R8:T4 | Prepare Export Settings | Windows export preset and output folder ready | Not started |
| P2:R8:T5 | Export Build | Shareable build artifact produced | Not started |
| P2:R8:T6 | Smoke Test Export | Exported build launched and played through key path | Not started |
| P2:R8:T7 | Prepare Playtest Notes | Tester instructions and feedback prompts | Not started |
| P2:R8:T8 | Record Known Issues | Non-blocking issues documented | Not started |
| P2:R8:T9 | Add Training Room Lite (Optional) | Compact practice mode if low-risk after Adventure/export stability | Not started |
| P2:R8:T10 | Update Docs | Phase 2 playtest readiness recorded | Not started |

## P2:R8:T1 - Define Playtest Scope

Tell testers what feedback is useful:

- Buildcraft clarity.
- UI comprehension.
- Encounter pressure.
- Reward/shop decision quality.
- Route choice clarity.
- Bugs and confusing states.

Also state what is not the focus:

- Final art.
- Final animation.
- Full content breadth.
- Balance perfection.
- Full Training Room/freeform lab parity.

## P2:R8:T2 - Run Full Regression Pass

Run:

- All headless tests.
- Manual editor/player click-through.
- At least one full route to victory.
- At least one loss/failure path.
- Save/load mid-run.

Record exact failures.

## P2:R8:T3 - Fix Critical Bugs

Prioritize:

- Crashes.
- Dead-end UI states.
- Save/load corruption.
- Cannot complete run.
- Impossible/default losing path if not intended.
- Text overlap that blocks critical interaction.

Non-blocking polish can go to known issues.

## P2:R8:T4 - Prepare Export Settings

Set up Windows export:

- Export preset.
- Output directory.
- Icon/name if available.
- Include required resources.
- Confirm `.godot/` and build artifacts are ignored appropriately.

Web export is optional only if low-effort.

## P2:R8:T5 - Export Build

Produce the build artifact in a clear local folder.

Do not treat export as complete until the exported executable launches.

## P2:R8:T6 - Smoke Test Export

In the exported build:

- Start new run.
- Choose Rogue/subclass.
- Fight at least one Tavern encounter.
- Visit reward/shop if available.
- Save/quit/resume.
- Continue to a later encounter or boss path.

Record results.

## P2:R8:T7 - Prepare Playtest Notes

Create concise notes for testers:

- What build they are playing.
- What the current goal is.
- What feedback is most useful.
- How to report seed/build/path issues.
- Known non-blocking rough edges.

## P2:R8:T8 - Record Known Issues

Document:

- Bugs not fixed before playtest.
- Balance concerns.
- UI rough edges.
- Missing polish.
- Deferred Phase 3 items that testers may notice.

## P2:R8:T9 - Add Training Room Lite (Optional)

Only start this after the exported Rogue Adventure path is stable enough for a
playtest. This task should be skipped or left as a documented known issue if it
risks delaying the shareable Adventure build.

Training Room Lite target:

- Enable the title-screen Training Room button.
- Reuse the existing combat dashboard/build resolver/combat resolver.
- Provide a compact practice flow for testing Rogue builds without mutating
  Adventure state.
- Include target and combat-window selection.
- Include visible seed/result/log output if seed work from R5 is available.
- Keep gear editing minimal: use current authored/generated gear systems only
  if they are easy to reuse safely.

Out of scope for Phase 2 Training Room Lite:

- Full freeform gear editor.
- All future classes/contracts.
- Full Phase 1 practice-gold sandbox.
- Player-facing Training Room target set beyond low-effort reusable targets.
- Any work that delays the Rogue Adventure playtest build.

## P2:R8:T10 - Update Docs

When complete:

- Update this checklist.
- Add playtest build notes to docs.
- Update `docs/Phase_2_Milestones.md`.
- Record feedback follow-up plan.

## Implementation Notes

TBD

## Verification Notes

TBD
