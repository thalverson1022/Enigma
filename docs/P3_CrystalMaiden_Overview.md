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
- Focused playback, HUD, recap, Practice Room combat view, and Balance Lab
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
| 1 | Combat Playback Juice | Complete | M1:T0 through M1:T14 are complete. Rogue animation, Tavern/contract enemy sprite mappings, Rogue skill icons, subclass icons, stable misc UI icons, cast language, timing, cast windup/macro-fill alignment, start-of-fight readability, hit/crit contact feedback, poison stack/tick feedback, combat-window current defense values plus poison/Shred/Decay iconography, proc/min-cast readability, Legendary feedback, victory/defeat reveal timing, integrated combat-window victory transition, macro highlight/fill playback, final verification, and documentation closeout are covered in the Milestone 1 document. |
| 2 | Combat Recap And Failure Clarity | Complete | M2:T0 through M2:T9 are complete in `P3M2_Combat_Recap_And_Failure_Clarity.md`; the shared recap model, first-pass Combat Log inspector, victory/defeat result overlay parity, retry fix, non-modal result overlays that leave dashboard controls usable, clearer retry/restart/action-state copy, readable structured Combat Log text, Practice Room practice-result invalidation, focused tests, and final verification are covered. |
| 3 | Build Screen And Rotation UX Polish | Complete | M3:T0 through M3:T7 are complete in `P3M3_Build_Screen_And_Rotation_UX_Polish.md`; the 10-slot Skill Build cap/count layout, fixed lock lane geometry, lock-as-ready empty-rotation guard, available-skill readability audit, talent dependency blocked-deselect pulse, character-stats/change-feedback audit, shared Adventure/Practice Room build-language audit, focused tests, final verification, and documentation closeout are covered. |
| 4 | Shop And Inventory Management UX | Complete | M4T0 through M4T7 are complete in `P3M4_Shop_And_Inventory_Management_UX.md`. Shop-phase buying, selling, equipping, unequipping, rerolling, and full-inventory reward clarity are covered without redesigning the underlying gear system. |
| 5 | Adventure Flow And Transition Polish | Complete | M5:T0 through M5:T10 are complete in `P3M5_Adventure_Flow_And_Transition_Polish.md`; reusable Adventure flow language, lightweight select-then-commit patterns, title/entry cleanup, tutorial-path audits, reward/shop/build/talent handoffs, terminal-state clarity, late current-contract triage, focused regression checks, deferred Phase 4 notes, and final closeout are recorded. |
| 6 | Practice Room Usability Pass | Complete | M6:T0 through M6:T6 are complete in `P3M6_Practice_Room_Usability_Pass.md`. The low-effort finish pass replaced Practice Room framing copy, fixed Practice Target floor/scale presentation, closed setup/playback/log audits with no extra redesign, verified Practice Room isolation, and recorded final focused checks. |
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
- Practice Room usability and visualization improvements.
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
- Improve build/rotation-relevant visual-state consistency for selected,
  disabled, unavailable, capped, locked, hover, focus, active, and fight-ready
  states using native Godot styling where possible.
- Improve talent hover and prerequisite clarity.
- Improve character stat panel readability.
- Clarify what changed after gear, talent, and route choices.
- Improve comparison language where useful.

Expected outputs:

- More legible build decisions.
- Faster rotation editing.
- Clearer talent and stat feedback.
- Better player confidence in why a build works or fails.

## Milestone 4: Shop And Inventory Management UX

Goal: make the shop phase the clear home for gear management. The player should
be able to buy, sell, equip, unequip, compare, and reroll shop offers with clear
costs, destinations, disabled states, and consequences, while inventory
capacity remains an intentional strategic constraint.

Status: Complete.

Tasks:

- Audit current shop, inventory, equipped gear, reward, and reroll flows.
- Improve inventory capacity and shop-phase management readability.
- Allow equip and unequip while the shop is open.
- Add shop-phase selling from inventory.
- Clarify that `Buy` sends items to inventory, with clear affordability and
  capacity states.
- Replace reroll count with a scaling gold cost that starts at 5 gold and
  increases by 5 after each reroll in the current shop phase.
- Improve reroll refresh feedback.
- Clarify full-inventory gear reward blocking, especially for contract kill
  rewards, with distinct full-inventory feedback instead of the unaffordable
  gray state.
- Verify, document, and close the milestone.

Expected outputs:

- Clearer shop-phase gear management.
- Shop-only selling from inventory.
- Click-based equip and unequip during shop phases.
- Predictable buy-to-inventory behavior.
- Rerolling that uses scaling gold costs and has clearer payment/refresh
  feedback.
- Clearer inventory-capacity consequences with safe reward blocking.

## Milestone 5: Adventure Flow And Transition Polish

Goal: make the current Rogue Adventure easier to move through by reducing
transition friction, clarifying immediate next actions, and establishing
reusable flow patterns that can support the future town-map and
procedural-contract redesign. Preserve the Tavern and first-contract path as
useful tutorial scaffolding, while avoiding heavy polish on contract-specific
structures likely to be replaced in the next phase.

Status: Complete. M5:T0 planning, M5:T1 reusable flow language, M5:T2 lightweight transition pattern, M5:T3 title/Adventure entry cleanup, M5:T4 Rogue selection/early tutorial flow audit, M5:T5 Tavern/first-contract tutorial flow audit, M5:T6 reward/shop/build/talent handoff cleanup, M5:T7 failure/restart/resume/victory state cleanup, M5:T8 late current-contract triage, M5:T9 focused tests/regression checks, and M5:T10 closeout are complete. T7 includes the imported Rogue death-animation loss beat for both natural and skipped defeats. T8 kept the late contract path serviceable with clearer route commit copy/status feedback while leaving larger late-contract presentation work deferred. T9 verified the core M5 state-flow suite plus adjacent Practice Room and combat playback checks. T10 recorded reusable Phase 4 flow patterns and deferred contract/town-map redesign work.

Design direction:

- The next phase is expected to substantially revamp the contract engine.
- The Tavern and possibly the first contract may remain as a mini-tutorial.
- Later contract structure is expected to move toward procedurally generated
  contracts, a town map, and a more open-world-feeling introduction.
- Milestone 5 should focus on durable flow clarity rather than treating the
  current linear contract arc as a final adventure format.

Tasks:

- Plan and audit the current Adventure flow. Status: Complete.
- Define reusable Adventure flow language. Status: Complete.
- Add a lightweight transition pattern. Status: Complete.
- Clean up title and Adventure entry. Status: Complete.
- Polish Rogue selection and early tutorial flow. Status: Complete as
  audit/check.
- Polish Tavern and first-contract tutorial flow. Status: Complete as
  audit/check.
- Clean up reward, shop, build, and talent handoffs. Status: Complete.
- Clean up adventure failure, restart, resume, and victory states. Status:
  Complete.
- Triage late current-contract flow only. Status: Complete.
- Run focused tests and regression checks. Status: Complete.
- Verify, document, and close the milestone. Status: Complete.

Expected outputs:

- Smoother Adventure flow without over-investing in soon-to-change contract
  structure.
- Clearer route, tutorial, restart, resume, failure, and victory beats.
- Reusable flow language and transition patterns for the Phase 4 town-map and
  procedural-contract redesign.
- Less friction between combat, reward, shop, build, talent, route, and result
  states.

## Milestone 6: Practice Room Usability Pass

Goal: make the Practice Room a better tool for learning mechanics through
experimentation with builds, animation, combat reads, and future balance work.

Status: Complete. M6:T0 planning, M6:T1 Practice Room framing copy, M6:T2
training dummy floor/scale alignment, M6:T3 setup-friction audit, M6:T4
playback/recap/Combat Log audit, M6:T5 focused isolation/regression checks, and
M6:T6 closeout are complete. Because the largest Practice Room improvements
were already pulled forward during M5, M6 closed as a low-effort audit and
finish pass rather than a broad new feature milestone.

Tasks:

- Audit the pulled-forward Practice Room slice and mark what is already
  complete. Status: Complete.
- Replace the current post-failure subtitle with learning-oriented Practice
  Room copy. Status: Complete.
- Fix the training dummy floor read by keeping the shadow in place, lowering
  the dummy sprite to meet it, and slightly reducing dummy scale if needed.
  Status: Complete.
- Audit remaining target, Legendary, talent, rotation, gear-editor, playback,
  recap, and Combat Log friction. Status: Complete as audit/check.
- Confirm Practice Room remains isolated from Adventure state and save data.
  Status: Complete.
- Verify, document, and close the milestone. Status: Complete.

Expected outputs:

- Faster build testing.
- Better controlled combat review.
- Clearer Practice Room controls.
- Practice Room combat presentation intentionally aligned with Adventure where
  useful, instead of drifting because Adventure received earlier layout polish.
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

Note: Milestone 8 is the right Phase 3 home for broader whole-game UI skin
consistency. Full mock-up-quality fantasy UI production, including ornate frame
sets, custom panel textures, bespoke backgrounds, portraits, and a complete art
direction pass, is intentionally deferred to a later phase where the total art
direction and asset strategy can be assessed together.

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
- The Practice Room can be used to test combat presentation in controlled
  scenarios.

## Open Approval Questions

- Is this the right number of milestones for Phase 3?
- Should Milestone 2 be merged into Milestone 1, or kept separate as a recap
  and failure-clarity pass?
- Should placeholder audio be included in Phase 3, or deferred entirely?
- What should count as the minimum acceptable definition of done for Phase 3?
