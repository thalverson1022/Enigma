# CrystalMaiden Onboarding Context

## Purpose

Read this document first at the start of a new Project CrystalMaiden
conversation.

This is the compact working handoff for Phase 3. It should give a future agent
enough context to choose the right repo, understand the current direction, and
know which detailed docs to open next. Detailed task history belongs in the
milestone docs, not here.

## Current Next Step

Milestone 6 is complete locally. Milestone 7 is the next formal milestone.

Current next implementation step:

- Start Milestone 7 with Task 0 planning for Testing Suite And Balance Lab
  Hardening.
- Use the Phase 3 overview for the current roadmap:
  `docs/P3_CrystalMaiden_Overview.md`.
- Use the just-closed Milestone 6 tasking doc for Practice Room handoff and
  final verification notes: `docs/P3M6_Practice_Room_Usability_Pass.md`.

## Project Identity

Project CrystalMaiden is Phase 3 of the game project.

Phase naming follows Dota 2 heroes by first letter:

- Phase 1: Project Abaddon
- Phase 2: Project Bane
- Phase 3: Project CrystalMaiden

Phase 1 was the React alpha/prototype. Phase 2 rebuilt the validated Rogue
adventure loop in Godot 4.x. Phase 3 continues from the Godot codebase and is
focused on juice, clarity, animation, usability, and presentation polish before
deeper mechanics work begins in a later phase.

## Repository And Folder Setup

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

Do not use the Phase 2 clone for active Phase 3 implementation unless the user
explicitly asks for historical comparison.

## Current Phase Status

Milestone status:

- Milestone 0: Complete
- Milestone 1: Complete
- Milestone 2: Complete locally
- Milestone 3: Complete locally
- Milestone 4: Complete locally
- Milestone 5: Complete locally
- Milestone 6: Complete locally
- Milestone 7: Not started

Latest known state:

- Milestone 1 closeout was committed and pushed on `phase-3-crystalmaiden`.
- Milestones 2, 3, 4, 5, and 6 are complete locally according to the current
  docs.
- Milestone 5 has been planned and rescoped around transition friction cleanup,
  reusable flow patterns, and tutorial-facing Tavern/first-contract polish
  rather than bespoke late-contract presentation. M5:T1 added shared reusable
  Adventure flow language for phase labels, action labels, next-step text,
  tooltips, and short status copy. M5:T2 added lightweight choice-state and
  transition presentation patterns for Tavern/contract maps, contract choices,
  second-subclass handoff, combat-window result/log layering, actor grounding,
  and no-target/result-state presentation cleanup. M5:T3 cleaned up title
  entry with the main-menu background art, `New Adventure`/`Resume Adventure`/
  `Practice Room` ordering, default-random Adventure seed controls, and focused
  save/entry tests. M5:T4 was completed as an audit/check after user review
  confirmed the Rogue class and subclass selection screens are already in a
  good state. M5:T5 was completed as an audit/check after prior M5 work and
  verified Tavern/first-contract tutorial flow without new gameplay/UI
  changes. M5:T6 cleaned reward/shop/build/talent handoffs with shop overlay
  layering, compact result/reward presentation, contract reward-row clarity,
  and generated contract reward choice slot/stat rolling. Practice Room
  naming, combat-window parity, and the compact
  paper-doll gear editor were pulled forward after user feedback; the gear
  editor now opens focused slot popups instead of stacking every affix control
  in the right column. M5:T7 added clearer terminal/resume outcome
  presentation and the imported Rogue death-animation failure beat: natural and
  skipped losses play the authored death animation at neutral color, hold the
  final pose for one second, then reveal defeated/adventure-over info. M5:T8
  completed late current-contract triage by auditing secondary subclass,
  route, Knives, Vyra, and final contract states; route-map commit copy now
  uses `Mark Route` with selected-route story and tooltip feedback, and larger
  late-contract presentation work remains deferred to the future
  contract-engine redesign. M5:T9 ran the focused transition/state-flow
  regression suite plus adjacent Practice Room and combat playback checks;
  the known sandbox autosave caveat reproduced for `combat_playback_test.gd`,
  and the same test passed outside the sandbox. M5:T10 closed the milestone
  by recording reusable Phase 4 flow patterns, deferred contract/town-map
  redesign work, final verification notes, and updated overview/onboarding
  handoff.
- Milestone 6 closed as a low-effort Practice Room audit and finish pass after
  the largest usability slice was pulled forward during M5. M6:T1 replaced the
  Practice Room subtitle with `Where questionable builds go to become slightly
  less questionable.` M6:T2 lowered and slightly shrank the Practice Target
  sprite while keeping its contact shadow on the existing floor line, and user
  playtest confirmed the result. M6:T3 and M6:T4 closed as audit-only tasks
  after user review confirmed setup, gear/Legendary, talents, rotation,
  playback, recap, and Combat Log surfaces are in a good place. M6:T5/T6 ran
  the final focused Practice Room and adjacent shared checks, updated overview
  and onboarding docs, and skipped Balance Lab because M6 did not change combat
  math, build resolution, skill/talent/gear resources, or balance-relevant
  data.
- Phase 1-4 of the cross-cutting technical-debt cleanup are complete locally;
  Phases 5-7 remain deliberately deferred behind their own triggers.
- Documentation filenames were cleaned up during Milestone 4 planning to use
  the `P<X>_...` and `P<X>M<Y>_...` naming convention.

Before committing or pushing, check `git status` and preserve unrelated user
changes.

## Completed Milestones

### P3M0 Planning And Phase Setup

Status: Complete.

Set up the Phase 3 branch and workspace, preserved the Phase 2 historical clone
and closeout tag, cleaned the Phase 3 docs, approved the milestone structure,
completed the current-state audit, and created the first milestone tasking doc.

Details: `docs/P3M0_Planning_And_Phase_Setup.md`

### P3M1 Combat Playback Juice

Status: Complete, committed/pushed.

Added the combat stage presentation layer, sprite configuration, attack timing,
start-of-fight readability, hit/crit/poison/proc feedback, persistent enemy
state feedback, outcome reveal timing, cast windup alignment, and placeholder
asset mapping. This milestone was presentation-focused and did not intentionally
change combat math.

Details: `docs/P3M1_Combat_Playback_Juice.md`

### P3M2 Combat Recap And Failure Clarity

Status: Complete locally.

Added the shared structured recap model, Combat Log inspector, clearer result
and retry/restart copy, readable structured event logs, Practice Room combat
log review, practice-safe wording, stale result invalidation, and focused
assertions. The defeat-help direction was intentionally kept light after design
review.

Details: `docs/P3M2_Combat_Recap_And_Failure_Clarity.md`

### P3M3 Build Screen And Rotation UX Polish

Status: Complete locally.

Added the 10-slot Skill Build cap/count layout, fixed lock-lane geometry,
lock-as-ready behavior, empty-rotation guardrails, selected-talent dependency
feedback, shared Adventure/Practice Room build-language checks, and focused
geometry/build tests. Broader comparison UI, stat-change presentation, Training
Room workflow improvements, and whole-game art direction remain deferred.

Details: `docs/P3M3_Build_Screen_And_Rotation_UX_Polish.md`

### P3M4 Shop And Inventory Management UX

Status: Complete locally.

Added shop-phase buying, selling, equipping, unequipping, rerolling, and
inventory-capacity/reward clarity without redesigning the underlying gear
system.

Details: `docs/P3M4_Shop_And_Inventory_Management_UX.md`

### P3M5 Adventure Flow And Transition Polish

Status: Complete locally.

Closed the Adventure-flow polish pass with reusable flow language, lightweight
select-then-commit patterns, title/entry cleanup, reward/shop/build/talent
handoff cleanup, terminal-state clarity, late current-contract triage, focused
regression checks, and deferred Phase 4 flow notes.

Details: `docs/P3M5_Adventure_Flow_And_Transition_Polish.md`

### P3M6 Practice Room Usability Pass

Status: Complete locally.

Closed the low-effort Practice Room finish pass with learning-oriented framing
copy, Practice Target floor/scale alignment, audit-only setup/playback/log
closeouts, final Practice Room isolation checks, and updated handoff docs.

Details: `docs/P3M6_Practice_Room_Usability_Pass.md`

## Current Game Context

The playable build centers on the Rogue Adventure.

Main flow:

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

The Practice Room is also important. It supports freeform Rogue tree/talent
setup, rotation editing, rarity-first gear editing, direct Legendary selection,
target controls, animated combat playback, and combat log review without
mutating Adventure state.

## Phase 3 Scope

Phase 3 is a presentation, game-feel, and usability phase.

In scope:

- Combat animation timing and readability.
- Hit, crit, proc, poison, armor-shred, victory, and defeat feedback.
- Skill popup polish.
- UI layout polish and clearer information hierarchy.
- Better hover, focus, disabled, selected, and comparison states.
- Better transitions between major adventure states.
- Practice Room usability and visualization improvements.
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

- Enemies are fixed-duration DPS checks with personality and defensive profiles.
- HP, armor, poison resistance, duration, rewards, and route pressure should be
  clear before the player commits.

Failure Should Teach:

- Failed fights should show what happened and what the next allowed action is.
- Damage dealt, damage needed, biggest hit, poison contribution, armor behavior,
  and retry/restart rules should be clear.

## Read Next By Task Type

- Phase status and milestone roadmap:
  `docs/P3_CrystalMaiden_Overview.md`
- Milestone 4 planning:
  `docs/P3M4_Shop_And_Inventory_Management_UX.md`
- Combat playback, animation, VFX, combat HUD:
  `docs/P3M1_Combat_Playback_Juice.md`
- Combat recap, Combat Log, result copy, failure clarity:
  `docs/P3M2_Combat_Recap_And_Failure_Clarity.md`
- Build screen, Skill Build strip, rotation cap, talent/build UX:
  `docs/P3M3_Build_Screen_And_Rotation_UX_Polish.md`
- Architecture cleanup and deferred refactor triggers:
  `docs/P3_Technical_Debt_Architecture_Cleanup.md`
- Phase 3 game/design background:
  `docs/Phase_3_Context/Game_Summary_And_Phase_3_Brief.md`
- Mechanics and balance reference:
  `docs/Phase_3_Context/Mechanics_And_Balance_Glossary.md`
- Rogue class reference:
  `docs/Phase_3_Context/Rogue_Class_Overview.md`
- Phase 2 closeout context:
  `docs/Phase_3_Context/Phase_2_Closeout_Review.md`

## Documentation Naming Convention

- Phase overview docs use `P<X>_<Phase_Name>_Overview.md`.
- Phase onboarding docs use `P<X>_<Phase_Name>_Onboarding_Context.md`.
- Milestone tasking docs use `P<X>M<Y>_<Milestone_Name>.md`.
- Cross-cutting Phase 3 support docs use `P3_<Topic>.md` unless they belong to
  a specific milestone.
- Keep detailed task history in the relevant milestone doc. Keep this
  onboarding doc compact and current.

## Important Files

Core screens:

- `project/scenes/game_root.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/training_room/training_room.gd`
- `project/scenes/training_room/training_room_combat_view.gd`

Combat and build systems:

- `project/scripts/systems/build_resolver.gd`
- `project/scripts/systems/combat_resolver.gd`
- `project/scripts/systems/combat_result_formatter.gd`
- `project/scripts/systems/combat_recap.gd`
- `project/scripts/systems/gear_generator.gd`
- `project/scripts/systems/run_rng.gd`
- `project/scripts/systems/save_system.gd`
- `project/scripts/tools/balance_lab.gd`

Combat presentation:

- `project/scripts/ui/combat_playback.gd`
- `project/scripts/ui/combat_playback_presenter.gd`
- `project/scripts/ui/combat_popup_layer.gd`
- `project/scripts/ui/playback_controls.gd`
- `project/scripts/ui/combat_stage.gd`
- `project/tests/helpers/combat_playback_scenarios.gd`

## Verification Baseline

Latest documented focused checks:

- P3M6 final focused checks passed on 2026-08-05:
  `res://tests/training_room_entry_test.gd`,
  `res://tests/training_room_combat_view_test.gd`,
  `res://tests/training_room_fight_test.gd`,
  `res://tests/training_room_fight_setup_test.gd`,
  `res://tests/training_room_build_test.gd`,
  `res://tests/training_room_gear_editor_test.gd`,
  `res://tests/combat_screen_test.gd`,
  `res://tests/rotation_cap_test.gd`,
  `res://tests/skill_build_geometry_test.gd`, and
  `res://tests/combat_recap_test.gd`.
- `res://tests/combat_playback_test.gd` may need to be rerun outside the
  sandbox for the known autosave/user-data assertion.
- Balance Lab was not run for P3M6 closeout because that work did not change
  combat math, event ordering, build-resolution rules, skill/talent/gear
  resources, or balance-relevant data.

Known Godot caveats on this machine:

- Use `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`.
- Prefer explicit workspace `--log-file` paths for headless checks.
- Godot may print Windows root-certificate-store warnings.
- Godot may print ObjectDB/resource cleanup warnings at exit even when tests
  pass with exit code 0.
- A fresh clone may need an import/editor pass before tests can resolve fonts
  and global classes.
- Godot 4.7 previously crashed with `--path project --import` in this shell;
  importing by passing the direct `project.godot` file worked.

Run focused tests after touching combat playback, HUD, Practice Room combat
playback, event formatting, recap behavior, build-resolution UI, or rotation
behavior. Run Balance Lab when changing combat timing, event ordering, build
resolution, skill/talent/gear resources, or balance-relevant data.

## Working Agreements

- Start each implementation milestone with Task 0 planning.
- Keep milestone/task/status docs updated as work progresses.
- Prefer conservative, scoped changes that match existing Godot patterns.
- Preserve determinism and avoid changing combat math during presentation work.
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

- Update the current milestone status in `docs/P3_CrystalMaiden_Overview.md`.
- Update this onboarding document with the latest milestone/task status.
- Add or update the relevant milestone/task planning doc.
- Record new baseline test results or known caveats in the relevant milestone
  doc, and keep only the short current verification summary here.
- Commit and push documentation updates with the related work when requested or
  when closing out a milestone.
