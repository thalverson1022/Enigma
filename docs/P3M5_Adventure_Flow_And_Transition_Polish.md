# Phase 3 Milestone 5: Adventure Flow And Transition Polish

## Purpose

Milestone 5 reduces clunky transitions and adventure-flow friction in the
current Rogue Adventure while avoiding heavy bespoke polish for contract
systems that are planned for a future redesign.

This is the single tasking and status document for Milestone 5. It follows the
project hierarchy:

- Phase: 3, Project CrystalMaiden
- Milestone: 5, Adventure Flow And Transition Polish
- Task: milestone-sized work item
- Step: implementation-sized action inside a task

## Status

Complete.

## Milestone Goal

Make the current Rogue Adventure easier to move through by reducing transition
friction, clarifying immediate next actions, and establishing reusable flow
patterns that can support the future town-map and procedural-contract redesign.
Preserve the Tavern and first-contract path as useful tutorial scaffolding,
while avoiding heavy polish on contract-specific structures likely to be
replaced in the next phase.

## Design Direction

The next phase is expected to substantially revamp the contract engine. The
current Tavern and possibly the first contract may remain as a mini-tutorial,
but later contract structure is expected to move toward procedurally generated
contracts, a town map, and a more open-world-feeling introduction.

Milestone 5 should therefore focus on durable flow clarity rather than treating
the current linear contract arc as a final adventure format.

Prioritize:

- Reusable transition patterns.
- Clear adventure state names and next-action language.
- Smooth entry into a new or resumed run.
- Tutorial-facing polish for the Tavern and first contract path.
- Friction fixes between combat, reward, shop, build, talent, route, and result
  states.
- Adventure-level failure, restart, resume, and victory clarity.

Avoid by default:

- Bespoke cinematic polish for the current late-contract structure.
- Deep route-map redesign for the current contract ladder.
- Heavy Vyra, Knives, or Gilded Serpent-specific presentation work.
- Lore-heavy rewrites for flow that is likely to be replaced.
- New contracts, procedural systems, town-map implementation, or broader
  adventure redesign.

## Constraints

- Do not redesign the contract engine in this milestone.
- Do not add the future town map or procedural contract generation.
- Do not change combat math, reward economy, gear generation, enemy balance, or
  build-resolution behavior unless a narrow user-approved bug fix requires it.
- Keep transitions lightweight enough for repeated play.
- Prefer reusable UI/state-flow conventions over one-off polish.
- Preserve existing Adventure state and save behavior unless a task explicitly
  identifies a safe correction.
- Treat late current-contract content as triage-only unless the user explicitly
  rescopes it.

## Current Baseline To Audit

Milestone 5 should begin with an audit of the current Adventure flow and code
paths instead of assuming which transitions need work.

Known or expected baseline:

- The playable adventure currently flows through title, Adventure Mode, Rogue
  class selection, primary subclass selection, Tavern encounter ladder, combat,
  rewards, shop offers, gear decisions, talent spending, contract offer,
  secondary subclass choice, contract routes, Knives Legendary reward, Vyra
  climax, and victory/failure/restart states.
- Milestones 1 through 4 improved combat playback, recap/failure clarity, build
  and rotation UX, and shop/inventory management.
- Those improved systems may still feel like separate UI islands when the
  player moves between them.
- The current contract arc is serviceable but not the long-term contract
  architecture.

Open audit questions:

- Which transitions currently feel abrupt, ambiguous, or repetitive?
- Which state changes need a visible transition, and which only need clearer
  copy or button language?
- Which early Adventure beats are likely to remain useful as tutorial
  scaffolding in the next phase?
- Which late Adventure beats should be fixed only for friction or dead-end
  clarity?
- Which reusable transition or header pattern can be introduced without
  overfitting to the current contract ladder?
- Which tests already cover Adventure state transitions, resume, restart,
  failure, victory, rewards, shop handoffs, and contract progression?

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Plan and audit the current Adventure flow | Complete | Revised milestone direction, future contract-engine context, scope boundaries, task structure, triage-only late-contract approach, and verification expectations are documented. |
| 1. Define reusable Adventure flow language | Complete | Added a shared `AdventureFlowText` script for durable phase, action, next-step, tooltip, and short status language; title entry now uses action-forward New/Resume wording. |
| 2. Add a lightweight transition pattern | Complete | Added modest reusable choice-state visual language for Tavern and contract maps/choices, moved second-subclass choice into Talent Trees, tightened combat-window result/log layering and no-target presentation, and later pulled matching Practice Room combat-window alignment into M5. |
| 3. Clean up title and Adventure entry | Complete | Added title background art, New/Resume/Practice ordering, default-random seed controls, and focused save/entry checks. |
| 4. Polish Rogue selection and early tutorial flow | Complete | Completed as an audit/check; user review confirmed the Rogue class and subclass selection screens are already in a good state, with no new gameplay/UI changes needed. |
| 5. Polish Tavern and first-contract tutorial flow | Complete | Completed as an audit/check after prior M5 work; Tavern ladder, first-loop returns, and first contract offer flow are covered by existing transition/UI checks, with no new gameplay/UI changes needed. |
| 6. Clean up reward, shop, build, and talent handoffs | Complete | Cleaned result/reward/shop/build/talent adjacent handoffs, including shop overlay layering, compact result/reward language, contract reward-row clarity, generated contract reward choice rolling, and focused regression coverage. |
| 7. Clean up adventure failure, restart, resume, and victory states | Complete | Terminal/resume outcome presentation is clearer, save/restart behavior is preserved, and natural/skipped losses now play the imported Rogue death-animation beat before defeated or adventure-over info appears. |
| 8. Triage late current-contract flow only | Complete | Audited secondary subclass, late route, Knives Legendary reward, Vyra, and terminal contract states; fixed route-commit copy/status clarity by changing the contract route commit action to `Mark Route` with selected-route story/tooltip feedback; final contract-victory body text visibility is covered by outcome presentation checks. |
| 9. Run focused tests and regression checks | Complete | Core M5 transition/state checks and adjacent Practice Room/combat playback checks passed; `combat_playback_test.gd` reproduced the known sandbox autosave caveat, then passed outside the sandbox. Balance Lab was skipped because M5:T8/T9 did not change combat math, reward data, gear resources, build resolution, or balance-relevant behavior. |
| 10. Verify, document, and close Milestone 5 | Complete | Final M5 status, T9 verification results, reusable Phase 4 flow patterns, deferred contract/town-map work, Phase 3 overview, and onboarding handoff are recorded. |

## Task Details

### P3:M5:T0 - Plan And Audit The Current Adventure Flow

Status: Complete.

Goal: turn the revised Milestone 5 direction into an executable transition and
friction-removal plan.

Steps:

- P3:M5:T0:S1 - Audit the current Adventure flow from title through terminal
  states.
- P3:M5:T0:S2 - List every major transition between title, Adventure Mode,
  selection, Tavern, combat, reward, shop, build, talent, contract, route,
  Legendary, climax, victory, failure, restart, and resume states.
- P3:M5:T0:S3 - Identify abrupt jumps, unclear next actions, dead-end feeling,
  repeated-play friction, and inconsistent labels.
- P3:M5:T0:S4 - Classify each issue as `fix now`, `reusable pattern`, `defer
  to Phase 4`, or `do not polish`.
- P3:M5:T0:S5 - Identify the scenes, scripts, and tests that own each
  transition or state.
- P3:M5:T0:S6 - Update this document if the audit changes task order or scope.

Expected output:

- A current Adventure transition map.
- A prioritized friction list.
- Confirmed implementation surfaces and verification plan.
- Updated task notes if the safest implementation order changes.

Notes:

- The milestone was rescoped during planning to account for the expected
  next-phase contract-engine redesign.
- The durable goal is transition friction cleanup, clearer next-action
  language, and reusable flow patterns rather than bespoke polish for the
  current late contract arc.
- The Tavern and first contract path are treated as likely tutorial scaffolding
  worth preserving and lightly polishing.
- Late current-contract beats are explicitly triage-only unless the user
  rescopes them.
- No implementation checks were run for T0 because this task was
  documentation and planning only.

### P3:M5:T1 - Define Reusable Adventure Flow Language

Status: Complete.

Goal: establish consistent language for where the player is, what they are
choosing, and what happens next.

Steps:

- P3:M5:T1:S1 - Audit current headers, subtitles, objective text, buttons,
  tooltips, disabled-state messages, and result-state labels.
- P3:M5:T1:S2 - Define reusable naming for major Adventure phases.
- P3:M5:T1:S3 - Standardize primary and secondary action copy where practical.
- P3:M5:T1:S4 - Clarify disabled actions with short reason-forward copy.
- P3:M5:T1:S5 - Clarify restart, resume, failure, victory, and continue labels.
- P3:M5:T1:S6 - Add focused assertions for key text if the project already has
  suitable UI tests nearby.

Expected output:

- More consistent Adventure screen language.
- Clearer primary actions and blocked-action reasons.
- A reusable copy pattern for future town-map and contract flows.

Implementation notes:

- Added `project/scripts/ui/adventure_flow_text.gd` as the shared home for
  durable Adventure action labels, phase labels, next-action labels, tooltip
  copy, and short status builders.
- Updated Title entry copy from mode nouns to action verbs:
  `New Adventure` and `Resume Adventure`.
- Reused shared action/status language across story, map, contract, reward,
  shop, and combat-dashboard flow surfaces where the copy was generic.
- Left authored Tavern flavor, contract story copy, route tradeoff text, and
  outcome body text with their owning scenes/resources because they are
  context-specific rather than durable flow language.
- Preserved Adventure state transitions, save behavior, combat math, rewards,
  shop rules, route logic, and contract structure.

Verification notes:

- Focused checks passed on 2026-08-03:
  `res://tests/save_load_ui_test.gd` (passed outside sandbox after the known
  Godot user-data save caveat reproduced inside the sandbox),
  `res://tests/dashboard_header_test.gd`,
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/run_outcome_presentation_test.gd`, and
  `res://tests/combat_screen_test.gd`.

### P3:M5:T2 - Add A Lightweight Transition Pattern

Status: Complete.

Goal: add or standardize a modest transition treatment for important Adventure
state changes without slowing repeated play.

Steps:

- P3:M5:T2:S1 - Audit existing transition, overlay, fade, banner, and screen
  swap code.
- P3:M5:T2:S2 - Choose the smallest reusable pattern that matches existing
  Godot UI architecture.
- P3:M5:T2:S3 - Apply the transition only to state changes where it improves
  clarity or momentum.
- P3:M5:T2:S4 - Ensure transitions can be skipped, shortened, or kept brief
  enough for repeated runs.
- P3:M5:T2:S5 - Avoid content-specific transition assets for late current
  contract beats.
- P3:M5:T2:S6 - Add focused tests or instrumentation where feasible.

Expected output:

- A lightweight reusable transition convention.
- Clearer state changes for important Adventure moments.
- Infrastructure that can support Phase 4 town-map and procedural-contract
  flow.

Implementation notes:

- Added a reusable "available choice" language for Tavern and contract route
  maps: pulsing gold/brown available borders, blue selected state, red defeated
  markers for cleared Tavern nodes, explicit Proceed gating, deselect support,
  and switchable route choices.
- Applied the same selection language to the first contract card: vertical
  choice-list placement, pulsing available outline, blue selected state,
  deselect support, and Proceed gating before the contract detail/accept step.
- Moved the second-subclass choice out of the first contract popup flow and
  into the Talent Trees window, so contract decisions and build decisions stay
  separated during the intro contract path.
- Tightened the Adventure combat window as part of transition clarity: removed
  non-combat status text from the stage, extended the combat window to contain
  the Fight/Combat Log row, removed the transparent stage box, added actor
  contact shadows, and kept the Fight/Combat Log row above result dimming only
  while the result overlay is visible.
- Prevented misleading presentation during no-target and resolved-but-still-
  animating states: initial/map states no longer show actor placeholder boxes,
  enemy info does not jump to generic "Run Complete" status, terminal contract
  states keep enemy info, and combat backgrounds remain visible in run-ended
  states.
- Pulled the matching Practice Room combat-window layout change into M5 after
  user feedback: Practice now uses the same larger combat-window direction and
  keeps the Fight/Combat Log row inside the combat panel. Broader Practice
  gear-editor layout work remains deferred to the dedicated usability pass.
- Preserved combat math, reward data, shop economy, route structure, save model,
  and current contract content.

Verification notes:

- User playtest approved the T2 interaction/presentation direction before docs
  were updated.
- Focused and adjacent checks passed on 2026-08-03:
  `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/dashboard_header_test.gd`,
  `res://tests/enemy_panel_test.gd`,
  `res://tests/combat_hud_test.gd`, and
  `res://tests/reward_shop_route_ui_test.gd`.
- `res://tests/combat_playback_test.gd` passed on 2026-08-03 when rerun
  outside the sandbox. The sandbox run reproduced the known Godot `user://`
  save caveat, where `SaveSystem.has_save()` can remain false at the autosave
  assertion.

### P3:M5:T3 - Clean Up Title And Adventure Entry

Status: Complete.

Goal: make starting or resuming an Adventure clearer and less abrupt.

Steps:

- P3:M5:T3:S1 - Audit title screen, Adventure Mode entry, new-run entry, and
  resume behavior.
- P3:M5:T3:S2 - Clarify new run versus resume language.
- P3:M5:T3:S3 - Ensure the first visible objective is clear after entering
  Adventure Mode.
- P3:M5:T3:S4 - Smooth the handoff into class or subclass selection.
- P3:M5:T3:S5 - Confirm save/resume behavior remains unchanged unless a
  specific bug is found.
- P3:M5:T3:S6 - Add focused tests for entry/resume behavior where practical.

Expected output:

- Clearer first 30 seconds of a run.
- Less abrupt movement from title into Adventure decisions.
- Safer resume/restart communication.

Implementation notes:

- Replaced the flat title background with the user-provided main-menu art,
  copied into `project/assets/backgrounds/main_menu.jpg`; the title screen now
  draws it full-screen behind a light readability scrim.
- Changed the main menu labels/order to `New Adventure`, `Resume Adventure`,
  `Practice Room`, then `Exit`.
- Added a `Random` Adventure seed checkbox beside the seed field. It is enabled
  by default, generates a fresh seed for new runs, and disables the numeric seed
  field until unchecked.
- Preserved resume behavior and fixed the save-test path so focused tests can
  redirect saves to project-local temporary files instead of touching the real
  `user://` save.

Verification notes:

- Focused checks passed on 2026-08-04:
  `res://tests/save_load_ui_test.gd`,
  `res://tests/training_room_entry_test.gd`, and
  `res://tests/save_load_test.gd`.
- Godot still prints the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit even when these checks pass with
  exit code 0.

Pulled-forward Practice Room naming/parity note:

- Renamed player-facing and documentation references to `Practice Room`,
  while leaving internal `training_room` paths and
  `TrainingRoom*` implementation identifiers in place to avoid unnecessary
  churn.
- Reframed the Practice Room as a post-failure experimentation space rather
  than a tutorial/start destination.
- Brought Practice Room combat-window presentation closer to Adventure's M5
  layout by enlarging the combat panel and moving the Fight/Combat Log row
  inside the combat window.
- Replaced the generic Practice Target placeholder with imported training
  dummy sprites and added Practice-only randomized bounce/knock/spin reactions
  on damaging hits, reinforcing that Practice Room fights are test runs rather
  than Adventure encounters.
- Focused checks passed on 2026-08-04:
  `res://tests/training_room_entry_test.gd`,
  `res://tests/training_room_combat_view_test.gd`, and
  `res://tests/training_room_fight_test.gd`. After the dummy sprite/reaction
  addition, `res://tests/training_room_combat_view_test.gd` and
  `res://tests/combat_stage_visual_reset_test.gd` also passed.
- Godot still prints the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit even when these checks pass with
  exit code 0.

### P3:M5:T4 - Polish Rogue Selection And Early Tutorial Flow

Status: Complete.

Goal: treat class and early subclass selection as durable tutorial scaffolding
for the future game.

Steps:

- P3:M5:T4:S1 - Audit Rogue class selection and primary subclass selection.
- P3:M5:T4:S2 - Clarify selected, available, disabled, and confirmed states.
- P3:M5:T4:S3 - Improve short explanatory copy for what the player is choosing.
- P3:M5:T4:S4 - Smooth the confirmation and handoff into the Tavern.
- P3:M5:T4:S5 - Avoid heavy presentation polish for class select unless it
  directly improves tutorial clarity.
- P3:M5:T4:S6 - Add focused tests for selection and continue-state behavior
  where practical.

Expected output:

- Better player orientation before the first fight.
- Clearer selection and confirmation states.
- Early flow that can survive the future introduction redesign.

Audit notes:

- Treated T4 as a check rather than a change task per user direction, because
  the current Rogue class selection and primary subclass choice screens are
  already in a good state.
- Verified the Rogue class select keeps Rogue as the available class while
  Mage and Crusader remain clearly disabled/coming-soon.
- Verified primary subclass selection presents the three Rogue trees as
  selectable, icon-backed choices and hands off into the Tavern/story overlay
  cleanly.
- No class/subclass copy, selection behavior, confirmation behavior, save
  behavior, or Tavern handoff code was changed.

Verification notes:

- Focused and adjacent checks passed on 2026-08-04:
  `res://tests/class_select_export_scan_test.gd`,
  `res://tests/save_load_ui_test.gd`, and
  `res://tests/combat_screen_test.gd`.
- Godot still prints the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit even when these checks pass with
  exit code 0.

### P3:M5:T5 - Polish Tavern And First-Contract Tutorial Flow

Status: Complete.

Goal: improve the Tavern and first contract path as likely tutorial survivors
of the future adventure design.

Steps:

- P3:M5:T5:S1 - Audit Tavern ladder readability and first encounter selection.
- P3:M5:T5:S2 - Clarify next encounter, combat entry, and post-combat return
  behavior.
- P3:M5:T5:S3 - Improve handoffs among combat result, reward, shop, build, and
  talent decisions when they occur in the tutorial path.
- P3:M5:T5:S4 - Clarify the first contract offer at tutorial level.
- P3:M5:T5:S5 - Confirm the first contract path teaches what contracts are
  without adding future procedural-contract features.
- P3:M5:T5:S6 - Add focused tests for tutorial-path state transitions where
  practical.

Expected output:

- Clearer Tavern ladder and first contract onboarding.
- Less friction in the first Adventure loop.
- Tutorial-facing flow that remains useful after the contract redesign.

Audit notes:

- Treated T5 as a check rather than a change task per user direction, because
  T1/T2/T3 and recent result-overlay fixes already covered the Tavern and first
  contract tutorial surfaces.
- Verified the Tavern ladder readability: available, selected, locked/unknown,
  defeated, Proceed-gated, and deselect states are already covered by the
  existing Tavern map checks.
- Verified first combat entry and post-combat return behavior: enemy panel
  pressure/reward/window text, lock-then-fight gating, compact victory recap,
  reward claim, Combat Log access, and return-to-map behavior are already
  covered.
- Verified reward/shop/build/talent handoffs in the tutorial path at audit
  level. Broader adjacent-system handoff polish remains scoped to T6.
- Verified the first contract offer and opening route choice teach the contract
  path at the current tutorial level: Ghit Gudd greeting/pitch, selectable Vyra
  contract card, Proceed gating, contract detail/Accept handoff, route map
  availability/pressure/reward labels, and second-tree handoff via Talent Trees.
- No procedural-contract, town-map, or future contract-engine features were
  added.

Verification notes:

- Focused and adjacent checks passed on 2026-08-04:
  `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/dashboard_header_test.gd`, and
  `res://tests/save_load_ui_test.gd`.
- Godot still prints the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit even when these checks pass with
  exit code 0.

### P3:M5:T6 - Clean Up Reward, Shop, Build, And Talent Handoffs

Status: Complete.

Goal: make adjacent decision screens feel connected now that combat recap,
build, talent, shop, and inventory surfaces have been individually polished.

Steps:

- P3:M5:T6:S1 - Audit post-combat result to reward, reward to shop, shop to
  build, build to talent, and talent to next encounter handoffs.
- P3:M5:T6:S2 - Clarify what changed because of the previous decision.
- P3:M5:T6:S3 - Clarify what decision is currently expected.
- P3:M5:T6:S4 - Clarify when the player can safely continue.
- P3:M5:T6:S5 - Remove inconsistent labels or duplicate competing prompts.
- P3:M5:T6:S6 - Add focused tests for modified handoff states where practical.

Expected output:

- Less friction between systems improved in Milestones 2 through 4.
- Clearer next-step language after rewards, shopping, build edits, and talent
  spending.
- Reduced feeling that each panel is an isolated mode.

Implementation notes:

- Audited the adjacent post-combat and decision-state handoffs after M2-M4
  polish: combat result to reward claim, reward claim to gear choice, reward to
  shop, shop to build/map, build/talent readiness, and contract route reward
  choice.
- Fixed Tavern Shop layering so combat-stage actor sprites and the raised
  Fight/Combat Log row no longer render over the shop card, while preserving
  the shop's non-modal behavior so Gear panel actions can still be used.
- Matched defeat result presentation to the cleaner victory result style by
  removing older explanatory body copy from the result overlay and using the
  compact proof recap shape for both win and loss states.
- Tightened contract reward-row presentation so route-preview prose no longer
  duplicates the actual reward row. Generated reward choices now render as
  compact tier labels such as `Choice of Master Gear`, with gold and talent
  rewards shown through the shared icon/value row.
- Updated generated contract reward choices so each choice rolls its slot from
  the configured slot pool, allows repeated slots, and avoids offering duplicate
  stat packages within the same generated choice set. The rolls remain
  adventure-seed and route-context deterministic.
- Preserved core state-flow behavior: combat math, shop prices, inventory
  capacity rules, reward claiming, route progression, talent spending, and save
  semantics were not intentionally redesigned.

Verification notes:

- Focused T6 checks passed on 2026-08-04:
  `res://tests/combat_screen_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`,
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/dashboard_header_test.gd`,
  `res://tests/build_panels_test.gd`,
  `res://tests/run_rng_context_test.gd`, and
  `res://tests/combat_recap_test.gd`.
- Godot still prints the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit even when these checks pass with
  exit code 0.

### P3:M5:T7 - Clean Up Adventure Failure, Restart, Resume, And Victory States

Status: Complete.

Goal: make Adventure-level terminal and continuation states clear, legal, and
low-friction.

Steps:

- P3:M5:T7:S1 - Audit failed fight, failed contract, failed run, victory,
  restart, and resume states.
- P3:M5:T7:S2 - Clarify the next legal action in each state.
- P3:M5:T7:S3 - Clarify when the player is continuing the same run versus
  starting over.
- P3:M5:T7:S4 - Ensure adventure-level failure does not duplicate or conflict
  with combat-level recap/failure clarity.
- P3:M5:T7:S5 - Preserve save behavior unless a narrow bug is found and
  approved for correction.
- P3:M5:T7:S6 - Add focused tests for restart/resume/failure/victory behavior
  where practical.

Expected output:

- Clearer terminal and continuation states.
- Reduced confusion around restart, resume, victory, and failure.
- Better bridge between combat-level results and adventure-level state.

Implementation notes:

- Added the Rogue death animation frames from
  `F:\Data\Junk\DPS Game\Rogue Animations\death` to the project animation
  asset tree and wired the player defeat pose to the authored five-frame death
  animation instead of reusing idle/hurt presentation.
- Player-loss playback now reveals the defeated info only after the death
  animation plays and the final pose holds for one second. Skip still cuts the
  combat timeline, but defeated skips preserve this death beat before showing
  defeated/adventure-over information. Headless instant playback still
  collapses the reveal immediately for tests and low-friction review.
- Removed the red player tint from the defeat pose so skipped losses no longer
  read as the old red idle/hurt state, and ran a Godot import pass so the new
  death PNGs have normal `.png.import` metadata.
- Strengthened playback regression coverage so skipped losses assert the
  displayed Rogue sprite starts on `death/frame_001.png`, advances to
  `death/frame_002.png`, and keeps the player actor at neutral color while the
  death beat plays.
- Terminal/resumed Adventure outcome presentation now restores the body text
  label for direct failure/victory states, so retry, restart, and new-Adventure
  consequences are visible when a run loads into or is forced into a terminal
  outcome. The live combat defeat overlay keeps the compact proof-recap shape
  from T6 and does not duplicate combat-level failure details.
- Save/restart behavior was preserved. Existing save/load UI coverage still
  verifies that `Resume Adventure` is disabled after abandon/restart and that
  terminal restart clears the saved run.

Verification notes:

- Focused T7 checks passed on 2026-08-05:
  `res://tests/combat_screen_test.gd`,
  `res://tests/run_failure_state_test.gd`,
  `res://tests/run_outcome_presentation_test.gd`, and
  `res://tests/save_load_ui_test.gd`.
- `res://tests/combat_playback_test.gd` was run and reached the updated natural
  and skipped loss timing/frame checks, but still fails the known
  autosave/user-data assertion before final success:
  `Expected the autosave to have fired before playback started.`
- Godot still prints the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit even when focused checks pass with
  exit code 0.

### P3:M5:T8 - Triage Late Current-Contract Flow Only

Status: Complete.

Goal: make late current-contract beats serviceable without investing heavily in
structure that is planned for replacement.

Steps:

- P3:M5:T8:S1 - Audit secondary subclass choice, late route choices, Knives
  Legendary reward, Vyra climax, and final contract states.
- P3:M5:T8:S2 - Fix unclear button copy, broken transitions, confusing labels,
  dead-end feeling, or inconsistent continue/restart behavior.
- P3:M5:T8:S3 - Avoid cinematic polish, deep route-map work, lore-heavy
  rewrites, or bespoke boss presentation unless explicitly rescoped.
- P3:M5:T8:S4 - Mark larger late-contract presentation issues as deferred to
  the future contract-engine redesign.
- P3:M5:T8:S5 - Add focused tests only for behavior that is actually changed.

Expected output:

- Late current-contract flow remains understandable and playable.
- Premium polish stays focused on durable flow patterns and tutorial-facing
  areas.
- Deferred late-contract redesign notes are captured for Phase 4.

Implementation notes:

- Audited the secondary-subclass handoff, late route choices, Knives Legendary
  reward choice, Vyra final fight, contract failure, and contract victory
  surfaces at code/test level.
- Kept the T8 pass deliberately narrow. No contract-engine redesign, route-map
  redesign, lore rewrite, boss cinematic, new route content, reward economy
  change, combat math change, or bespoke Vyra presentation was added.
- Clarified route-map commit behavior: contract route choices now use a
  `Mark Route` action instead of the generic Tavern-style `Proceed` label.
  Disabled route commit explains `Select a route first.`, and selected routes
  update the map story plus tooltip with the route being marked.
- Applied the same selected-route clarity to late current-contract beats,
  including the Knives-to-Vyra handoff after the Legendary reward choice.
- Verified that the final Vyra victory path surfaces `CONTRACT COMPLETE`
  body text and offers `Start New Adventure`, so it does not feel like a
  dead end after the victory reward claim.

Deferred notes for Phase 4:

- The Gilded Serpent route schematic remains a hardcoded, hand-positioned
  current-contract map. Keep it serviceable for now; replace or generalize it
  as part of the future town-map/procedural-contract redesign.
- Knives and Vyra would benefit from stronger boss/lieutenant presentation
  only if the current contract structure survives the next-phase contract
  redesign.
- Broader late-contract narrative pacing should be revisited with the future
  contract-engine plan rather than polished as standalone Phase 3 content.

Verification notes:

- Focused T8 checks passed on 2026-08-05:
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`, and
  `res://tests/run_outcome_presentation_test.gd`.
- Godot printed the known Windows root-certificate-store warning and
  ObjectDB/resource cleanup warnings at exit even though each focused check
  passed with exit code 0.

### P3:M5:T9 - Run Focused Tests And Regression Checks

Status: Complete.

Goal: verify that Adventure transition cleanup does not break run state,
selection, reward, shop, restart, resume, or terminal behavior.

Steps:

- P3:M5:T9:S1 - Identify focused test files affected by the implementation.
- P3:M5:T9:S2 - Add or update tests for modified transition and Adventure state
  behavior.
- P3:M5:T9:S3 - Run focused Godot tests for touched Adventure, combat screen,
  reward, shop, build, save, and UI surfaces.
- P3:M5:T9:S4 - Run adjacent checks if state transition changes touch shared
  Adventure or save behavior.
- P3:M5:T9:S5 - Record known Godot warnings separately from actual failures.
- P3:M5:T9:S6 - Run Balance Lab only if implementation changes combat timing,
  event ordering, build resolution, skill/talent/gear resources, reward data,
  or balance-relevant behavior.

Expected output:

- Focused transition and state-flow checks pass.
- Any known caveats are documented.
- Balance Lab is run only if relevant behavior changed.

Implementation notes:

- Identified the focused M5 state-flow suite from the transition surfaces
  touched across the milestone: Adventure combat screen, contract offer,
  route rewards, reward/shop/route handoffs, dashboard header state,
  terminal outcome presentation, failure/retry/restart rules, and save/resume
  behavior.
- Added no new tests during T9 itself because T8 had already added the missing
  route-commit assertions for the late current-contract handoff.
- Ran adjacent Practice Room checks because several Practice Room naming,
  combat-window, dummy, and fight setup improvements were pulled forward
  during M5 user-review work.
- Ran `combat_playback_test.gd` because M5 touched combat-window/result
  presentation and the loss death-animation beat.
- Skipped Balance Lab because T8/T9 changed only UI flow copy, route-map
  presentation, tests, and docs. No combat math, combat event ordering, build
  resolution, skill/talent/gear resources, reward data, or balance-relevant
  behavior was changed.

Verification notes:

- Core focused checks passed on 2026-08-05:
  `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/dashboard_header_test.gd`,
  `res://tests/run_outcome_presentation_test.gd`,
  `res://tests/run_failure_state_test.gd`, and
  `res://tests/save_load_ui_test.gd`.
- Adjacent checks passed on 2026-08-05:
  `res://tests/training_room_entry_test.gd`,
  `res://tests/training_room_combat_view_test.gd`,
  `res://tests/training_room_fight_test.gd`, and
  `res://tests/combat_playback_test.gd`.
- `res://tests/combat_playback_test.gd` reproduced the known sandbox/user-data
  autosave assertion first:
  `Expected the autosave to have fired before playback started.`
  The same test then passed when rerun outside the sandbox.
- Godot printed the known Windows root-certificate-store warning,
  image-load/export warnings for existing UI assets in some tests, and
  ObjectDB/resource cleanup warnings at exit. These warnings were recorded
  separately from test assertion results.

### P3:M5:T10 - Verify, Document, And Close Milestone 5

Status: Complete.

Goal: close the milestone with current documentation, verification notes, and
Phase 4 handoff value.

Steps:

- P3:M5:T10:S1 - Update this document with completed task notes and final
  verification results.
- P3:M5:T10:S2 - Update `docs/P3_CrystalMaiden_Overview.md` with the final
  Milestone 5 status.
- P3:M5:T10:S3 - Update `docs/P3_CrystalMaiden_Onboarding_Context.md` with the
  latest current next step.
- P3:M5:T10:S4 - Record reusable transition, copy, and flow patterns that
  should carry into the Phase 4 town-map and procedural-contract redesign.
- P3:M5:T10:S5 - Record deferred contract-engine, late-contract presentation,
  and town-introduction work for the next phase.

Expected output:

- Milestone 5 documentation is current.
- Final verification results are recorded.
- Durable Phase 4 flow-pattern notes are captured.
- Deferred redesign work is clearly separated from completed friction cleanup.

Implementation notes:

- Closed Milestone 5 as a transition-friction and Adventure-flow polish
  milestone. M5:T0 through M5:T10 are complete.
- Updated this document, the Phase 3 overview, and the onboarding context so
  the next project step is formal Milestone 6 planning/audit.
- Preserved the M5 boundary: no contract-engine redesign, procedural
  contracts, town-map implementation, late-contract cinematic pass, combat
  math change, reward economy change, gear-resource change, or balance change
  was added during closeout.

Reusable Phase 4 flow patterns:

- Keep `AdventureFlowText` as the shared home for durable Adventure phase
  labels, action labels, next-step text, tooltips, and short status copy.
- Preserve the select-then-commit pattern for meaningful Adventure choices:
  preview/select first, then commit with a clear action button such as
  `Proceed` or `Mark Route`.
- Keep route and encounter commitment language reason-forward: selected
  target/route copy should name what is being committed and what the player
  does next.
- Continue using compact result/reward language in the combat window, with
  deeper details available through Combat Log rather than bloating immediate
  result overlays.
- Maintain explicit terminal-state presentation: retry, restart, contract
  failure, contract victory, resume, and new-Adventure states should each have
  a clear headline, body, and legal next action.
- Preserve Adventure/Practice Room combat-window parity where it helps testing
  and player comprehension, while keeping Practice Room state isolated from
  Adventure saves.

Deferred Phase 4 / later-phase work:

- Replace or generalize the current hardcoded Gilded Serpent route schematic
  as part of the future town-map/procedural-contract redesign.
- Revisit the Tavern and first contract as tutorial scaffolding once the
  future Adventure introduction is designed.
- Rework late-contract narrative pacing, Knives/Vyra presentation, and boss
  buildup only if the current contract structure survives the next-phase
  contract-engine redesign.
- Keep broader whole-game UI skin, color scheme, spacing, typography, and
  presentation consistency in Milestone 8; keep full production art direction
  for a later phase.

Final verification summary:

- T9 core focused checks passed on 2026-08-05:
  `res://tests/combat_screen_test.gd`,
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/dashboard_header_test.gd`,
  `res://tests/run_outcome_presentation_test.gd`,
  `res://tests/run_failure_state_test.gd`, and
  `res://tests/save_load_ui_test.gd`.
- T9 adjacent checks passed on 2026-08-05:
  `res://tests/training_room_entry_test.gd`,
  `res://tests/training_room_combat_view_test.gd`,
  `res://tests/training_room_fight_test.gd`, and
  `res://tests/combat_playback_test.gd`.
- `res://tests/combat_playback_test.gd` reproduced the known sandbox/user-data
  autosave assertion, then passed when rerun outside the sandbox.
- Balance Lab was skipped because the final M5 passes changed only UI flow
  copy, route-map presentation, tests, and docs; no combat timing, combat
  event ordering, build resolution, skill/talent/gear resources, reward data,
  or balance-relevant behavior changed.

## Deferred Or Out-Of-Scope Notes

The following are intentionally out of scope for Milestone 5 unless explicitly
rescoped:

- Contract-engine redesign.
- Procedural contract generation.
- Town map or open-world-feeling introduction implementation.
- Broad encounter-system redesign.
- New routes, contracts, classes, or enemies.
- Heavy cinematic treatment for Gilded Serpent, Knives, Vyra, or other
  late-current-contract content.
- Full production art direction for Adventure screens.
- Combat math, enemy balance, gear economy, or reward-data changes.

## Verification Notes

M5:T1 focused checks passed on 2026-08-03:

- `res://tests/save_load_ui_test.gd`
- `res://tests/dashboard_header_test.gd`
- `res://tests/contract_offer_flow_test.gd`
- `res://tests/reward_shop_route_ui_test.gd`
- `res://tests/run_outcome_presentation_test.gd`
- `res://tests/combat_screen_test.gd`

The first `save_load_ui_test.gd` run reproduced the known Godot user-data
save caveat inside the sandbox: `SaveSystem.has_save()` stayed false at the
save point. The same check passed when rerun outside the sandbox.

Use `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` for focused
Godot checks. Prefer explicit workspace `--log-file` paths for headless test
runs.

Run focused tests after touching Adventure state transitions, title or resume
behavior, class/subclass selection, Tavern flow, reward/shop/build/talent
handoffs, contract route transitions, or failure/victory/restart behavior. Run
Balance Lab only if changing combat timing, event ordering, build resolution,
skill/talent/gear resources, reward data, or balance-relevant behavior.
