# Phase 3: Project CrystalMaiden Milestones

## Purpose

This document proposes the milestone plan for Phase 3 of the project.

Phase 3 is a presentation, game-feel, and usability phase. The goal is to add
juice and clarity to the current Godot Rogue adventure before the project moves
on to deeper core-mechanics work in a later phase.

The working hierarchy is:

- Phase
- Milestone
- Task
- Step

This document stops at the milestone and task level. Individual implementation
steps should be added once a milestone is approved and ready to begin.

## Approval Status

This milestone plan is approved as the working Phase 3 structure.

Approved decisions:

- Phase 3 includes Milestones 0 through 9.
- Milestone 1, Combat Playback Juice, is the recommended first implementation
  milestone.
- Milestone 2, Combat Recap And Failure Clarity, remains separate from
  Milestone 1 for now.
- Milestone 7, Testing Suite And Balance Lab Hardening, is included in Phase 3.
- Each implementation milestone should begin with a Task 0 planning pass that
  establishes or updates that milestone's single tasking document.

Open decisions:

- Placeholder audio remains provisional and should be confirmed before
  Milestone 8 begins.
- The final definition of done for Phase 3 should be refined during Milestone
  9 closeout planning.

## Milestone 0 Progress

Completed:

- Phase 2 closeout tag created in the Godot repository:
  `phase-2-bane-closeout`.
- Phase 3 branch created in the Godot repository:
  `phase-3-crystalmaiden`.
- Phase 3 milestone plan approved as the working structure.
- Milestone 0 planning and audit document created.
- Phase 3 planning docs copied into the Godot repository on the Phase 3 branch.
- `Project-CrystalMaiden` set up as the clean Phase 3 local clone.
- Phase 3 docs cleaned to the handoff and planning set.
- Current-state audit completed for Milestone 0.
- Focused playback, HUD, recap, Training Room combat view, and Balance Lab
  baseline checks passed.
- Milestone 1 tasking document created.

Remaining:

- None.

## Milestone Status Tracking

Milestone status should be updated as Phase 3 progresses. This table is the
phase sanity check: before starting new work, confirm the active milestone and
whether any earlier milestone still has unresolved tasks.

Status values:

- Not Started: approved or proposed, but no work has begun.
- In Progress: active work is happening now.
- Review: implementation is complete enough for user review, testing, or
  approval.
- Complete: reviewed, accepted, documented, and no planned tasks remain.
- Deferred: intentionally moved out of Phase 3 or postponed to a later
  milestone.
- Rescoped: changed from the original plan and needs its task list updated.

| Milestone | Name | Status | Notes |
|---:|---|---|---|
| 0 | Planning And Phase Setup | Complete | Git setup, plan approval, clean clone, audit, baseline checks, and Milestone 1 tasking setup are done. |
| 1 | Combat Playback Juice | In Progress | M1:T0 through M1:T12 complete; M1:T13 has partial progress. Rogue animation, Tavern enemy sprite mappings, Rogue skill icon mapping, cast language, timing, cast windup/macro-fill alignment, start-of-fight readability, hit/crit contact feedback, poison stack/tick feedback, combat-window current defense values plus poison/Shred/Decay iconography, proc/min-cast readability, Legendary feedback, victory/defeat reveal timing, integrated combat-window victory transition, macro highlight/fill playback, and focused playback/HUD/Training Room checks are covered in the Milestone 1 document. |
| 2 | Combat Recap And Failure Clarity | Not Started | May stay separate from Milestone 1 or merge after review. |
| 3 | Build Screen And Rotation UX Polish | Not Started |  |
| 4 | Gear, Rewards, Shop, And Legendary Presentation | Not Started |  |
| 5 | Adventure Flow And Transition Polish | Not Started |  |
| 6 | Training Room Usability Pass | Not Started |  |
| 7 | Testing Suite And Balance Lab Hardening | Not Started | External mechanics testing package needs review and polish. |
| 8 | Audio, Feedback, And Polish Sweep | Not Started | Placeholder audio still needs approval. |
| 9 | Regression, Export, And Phase 3 Closeout | Not Started |  |

## Phase Scope

Phase 3 should improve the existing game in its current state.

In scope:

- Combat animation timing and readability.
- Hit, crit, proc, poison, armor-shred, victory, and defeat feedback.
- Skill popup polish.
- UI layout polish and clearer information hierarchy.
- Better hover, focus, disabled, selected, and comparison states.
- Better transitions between major adventure states.
- Training Room usability and visualization improvements.
- Testing-suite and Balance Lab hardening for future mechanics and balance work.
- Lightweight placeholder audio if it supports interaction clarity.
- Documentation and UX checklists for future art, animation, and mechanics work.

Out of scope unless explicitly rescoped:

- New playable classes.
- New contracts.
- Broad enemy roster expansion.
- Monster or encounter-system redesign.
- Procedural map systems.
- Meta-progression systems.
- Major combat-engine redesign.
- Full production art pass.

## Milestone 0: Planning And Phase Setup

Goal: establish the Phase 3 working structure, scope, priorities, and review
process.

Tasks:

- Preserve the Phase 2 closeout state with a Git tag.
- Create the Phase 3 working branch.
- Add or update Phase 3 planning documentation.
- Audit the current playable flow.
- Identify all major moments where the player waits, watches, chooses, fails,
  or wins.
- Decide the first implementation target.
- Define what "Phase 3 complete" means.

Expected outputs:

- Phase 3 branch.
- Phase 3 milestone plan.
- Screen and state audit checklist.
- Prioritized polish backlog.
- Initial definition of done for the phase.

## Milestone 1: Combat Playback Juice

Goal: make automated combat feel more readable, punchy, and satisfying while
remaining faithful to the resolved combat timeline.

Tasks:

- Improve cast timing presentation.
- Improve normal hit feedback.
- Improve crit feedback.
- Improve poison stack visualization.
- Improve poison tick visualization.
- Show armor reduction as a persistent enemy state.
- Show poison resistance reduction as a distinct persistent enemy state.
- Make triggered skills and procs visually connected to their source cast.
- Make minimum-cast procs read as timing events.
- Improve victory and defeat combat-end moments.

Expected outputs:

- Clearer combat event language.
- More satisfying combat playback.
- Better visual distinction between major combat mechanics.
- Regression confidence that presentation changes did not alter combat math.

## Milestone 2: Combat Recap And Failure Clarity

Goal: make wins feel earned and losses teach the player what happened.

Tasks:

- Improve post-fight recap hierarchy.
- Show damage dealt versus damage required more clearly.
- Surface DPS, biggest hit, poison contribution, and relevant mitigation data.
- Clarify retry, do-over, restart, and contract-failure options.
- Improve combat log readability.
- Make defeat states informative rather than only punitive.

Expected outputs:

- Clearer fight summaries.
- More useful failure feedback.
- Better bridge from combat result to the player's next decision.

## Milestone 3: Build Screen And Rotation UX Polish

Goal: make buildcraft easier to understand and more pleasant to manipulate.

Tasks:

- Polish the available-skills panel.
- Polish rotation editing and lock-in states.
- Improve selected, disabled, and invalid skill states.
- Improve talent hover and prerequisite clarity.
- Improve character stat panel readability.
- Clarify what changed after gear, talent, and route choices.
- Improve comparison language where useful.

Expected outputs:

- More legible build decisions.
- Faster rotation editing.
- Clearer talent and stat feedback.
- Better player confidence in why a build works or fails.

## Milestone 4: Gear, Rewards, Shop, And Legendary Presentation

Goal: make gear and reward decisions more exciting, readable, and easy to
compare.

Tasks:

- Improve gear card hierarchy.
- Polish rarity visuals without turning the milestone into a full art pass.
- Make Legendary gear feel special in rewards, shop, inventory, equipped slots,
  and combat moments.
- Improve shop offer readability.
- Improve gear comparison states.
- Improve reward-choice moments.
- Reduce ambiguity around equip, buy, reroll, skip, and continue actions.

Expected outputs:

- Stronger reward moments.
- Clearer gear comparisons.
- More satisfying Legendary presentation.
- Easier shop and inventory decisions.

## Milestone 5: Adventure Flow And Transition Polish

Goal: make the full Rogue adventure feel more coherent and game-like from start
to finish.

Tasks:

- Polish title-to-adventure flow.
- Improve subclass selection presentation.
- Improve tavern ladder, map, and route transitions.
- Improve contract offer and route-choice moments.
- Polish the Knives Legendary reward moment.
- Polish the Vyra climax presentation.
- Improve victory, failure, restart, and resume states.
- Add small transitions where they improve clarity or momentum.

Expected outputs:

- Smoother adventure flow.
- Clearer route and contract beats.
- Better major story and reward moments.
- Less friction between screens and states.

## Milestone 6: Training Room Usability Pass

Goal: make the Training Room a better tool for testing builds, animation,
combat reads, and future balance work.

Tasks:

- Improve target controls.
- Improve gear editor clarity.
- Improve direct Legendary selection flow.
- Improve talent and rotation setup speed.
- Improve combat playback testing controls.
- Improve combat log and recap usefulness in practice mode.
- Confirm Training Room remains isolated from Adventure state and save data.

Expected outputs:

- Faster build testing.
- Better controlled combat review.
- Clearer Training Room controls.
- Preserved separation between practice mode and Adventure mode.

## Milestone 7: Testing Suite And Balance Lab Hardening

Goal: make the external mechanics testing and balance-analysis tools more
trustworthy, maintainable, and useful before the project moves into deeper
mechanics expansion.

Tasks:

- Audit the testing package added near the end of Phase 2.
- Identify which mechanics are currently covered by external tests.
- Identify mechanics that have weak, missing, or misleading coverage.
- Improve test structure, naming, setup, and failure messages.
- Add focused tests for critical combat, build-resolution, gear, and proc
  behavior.
- Improve Balance Lab output clarity where it helps future analysis.
- Document how to run the suite, interpret failures, and use results during
  balance work.
- Confirm deterministic scenarios remain reproducible across repeated runs.

Expected outputs:

- More reliable external mechanics test coverage.
- Clearer Balance Lab and test documentation.
- Better confidence that future mechanics changes can be tested safely.
- A stronger foundation for Phase 4 balance and system-depth work.

## Milestone 8: Audio, Feedback, And Polish Sweep

Goal: apply a consistency pass across interaction feedback, presentation
details, and rough edges.

Tasks:

- Add replaceable sound placeholders where they improve clarity.
- Review button, hover, focus, selected, and disabled states.
- Review spacing, typography, contrast, and information hierarchy.
- Remove obvious rough edges from repeated panels.
- Check all major states at the target resolution.
- Ensure no major UI state feels unfinished.

Expected outputs:

- More consistent UI feedback.
- Stronger overall game feel.
- A cleaner baseline for later production art and audio.

## Milestone 9: Regression, Export, And Phase 3 Closeout

Goal: verify that Project CrystalMaiden is stable, documented, and ready to
hand off to the next phase.

Tasks:

- Run the Godot regression suite.
- Run Balance Lab where relevant.
- Smoke test the exported Windows build if gameplay, UI resources, or assets
  changed.
- Update Phase 3 documentation.
- Capture final screenshots or video.
- Tag the Phase 3 closeout state.
- Write Phase 4 handoff notes for deeper mechanics work.

Expected outputs:

- Passing regression checks.
- Balance Lab results where relevant.
- Fresh export if needed.
- Phase 3 closeout tag.
- Phase 4 handoff notes.

## Suggested First Implementation Milestone

Milestone 1, Combat Playback Juice, is the recommended first implementation
milestone.

Reasons:

- Combat is the most visible proof step for every build.
- Combat playback already exists, so improvements can build on current
  infrastructure.
- Better combat event language will inform the rest of the UI polish.
- The Training Room can be used to test combat presentation in controlled
  scenarios.

## Open Approval Questions

- Is this the right number of milestones for Phase 3?
- Should Milestone 2 be merged into Milestone 1, or kept separate as a recap
  and failure-clarity pass?
- Should placeholder audio be included in Phase 3, or deferred entirely?
- What should count as the minimum acceptable definition of done for Phase 3?
