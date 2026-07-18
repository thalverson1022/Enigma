# Phase 2 (Project Bane) Milestones

## 2026-07-15 Scope Revision

The original Phase 2 plan intentionally aimed at a light Godot vertical slice:
prove the architecture, port the core DPS loop, wire one class/subclass/boss,
then move quickly to save/load and export. After deeper implementation and
comparison against the validated Phase 1 React prototype, that target is now
too small for what Project Bane needs.

Forward work should treat Phase 2 as **Phase 1 Rogue adventure parity in
Godot, plus a more game-like UI**, not merely a minimal engine port.

Revised Phase 2 goal:

> Rebuild the validated Project Abaddon Rogue adventure loop in Godot 4.x on
> a genuinely data-driven, production-quality architecture, while replacing
> the React prototype's tool-like presentation with a more game-like UI and
> interaction flow.

Revised definition of done:

> A stranger can download a build, play a complete Rogue adventure from
> character creation through the Tavern and the first contract climax,
> understand the build/fight/reward loop without the developer present, and
> give feedback on the actual game experience rather than only the combat
> math.

This revision does **not** mean "build the whole imagined game." It means the
Phase 1 prototype's proven first-run experience is now the Phase 2 parity
target. Additional classes, additional contracts, broad procedural
meta-progression, full art/animation production, multiplayer, mobile/platform
ports, and content-completion volume remain out of scope.

The original M0-M7 plan and notes remain below as historical record because
M0-M5 and the post-M5 dashboard restructure already happened. The revised
forward roadmap supersedes the original "M6 Save/Load, then M7 Export" path.

For future Codex sessions, start with `docs/Codex_Onboarding_Context.md`.

## Purpose

This is the Phase 2 goal and milestone record for Project Bane. The top
revision section and revised forward roadmap are the current source of truth
for forward work, alongside `docs/DPS_Engine_Phase2_Context.md` (working
agreements and technical foundation) and `docs/Conventions.md` (folder/naming
rules). The original milestone table remains as historical implementation
record.

Numbering convention: **Phase (P) → Milestone (M) → Task (T) → Step (S)**,
e.g. `P2:M1:T2:S3`.

## Relationship To Project Abaddon Docs

Current interpretation after the 2026-07-15 revision: the Phase 1 documents
are the design/content parity reference for revised Phase 2. Mechanics,
content shape, run flow, balance intent, and tester-facing experience should
be ported where they support the first Rogue adventure. They are still not an
implementation architecture to copy; Project Bane should remain Godot-native
and Resource-driven.

`Phase_1_Design_Recap.md`, `Current_Mechanics_Reference.md`,
`Content_Library_Reference.md`, and `Balance_Baseline_Report.md` describe the
earlier TypeScript/React MVP, codenamed **Project Abaddon** (Phase 1,
complete). They are **reference-only** for Project Bane: firewalled from this
project's own architecture and implementation, to be mined later as **seed
data** (skill numbers, gear affixes, monster stat tables, DPS baselines) once
the Godot architecture is proven with placeholder content in P2:M1/P2:M2 —
not before.

## Phase 2 (Project Bane) Goal

Current goal after the 2026-07-15 revision: rebuild the Phase 1 Rogue
adventure loop in Godot with a game-like UI. The original lightweight
vertical-slice goal below is historical context for M0-M5, not the current
forward target.

> Port the validated Project Abaddon core loop (Balatro-meets-ARPG-
> theorycrafting, automated DPS-window combat) into Godot 4.x on a genuinely
> data-driven, production-quality architecture, producing one real vertical
> slice — one class, one subclass-tree pair, one boss — playable start to
> finish with no editor intervention.

**Definition of done:** a stranger can download a build, play a complete run
from character creation to a single boss fight, and give feedback — without
the developer present to explain anything.

**Explicitly not in Phase 2:** content-completion volume, a polish/marketing
pass, the Contract Run meta-layer (branching route nodes, minions, elites —
that's Phase 3, see `phase3_ideas.md`), multiplayer/mobile/platform-port, and
save/load beyond P2:M6's basic run-state persistence.

Current interpretation after the 2026-07-15 revision: the Phase 1 first
contract route is now in scope for Phase 2 parity. The older "Contract Run"
exclusion means a broader procedural/meta-progression route system, additional
contracts, or campaign-scale structure. The placeholder-only period described
in agreements 3 and 4 is complete. Forward work should use Phase 1 content
and mechanics when implementing parity, while preserving the data-driven Godot
architecture.

## Working Agreements

1. Milestone boundaries are hard — don't build M{n+1} content while executing
   M{n}.
2. Data-driven by default — skills/gear/talents/monsters are Godot `Resource`
   (`.tres`) files, never hardcoded in GDScript logic.
3. Placeholder content (one fake skill/gear/monster) is intentional through
   P2:M2, to isolate architecture bugs from content bugs.
4. Real content/numbers from the Project Abaddon docs are deferred until
   P2:M1/P2:M2 placeholders prove the architecture.
5. Propose before refactors spanning more than one milestone's systems.
6. Scope-creep ideas go to `phase3_ideas.md`, not built early.
7. Godot 4.x idioms only (no GD3 patterns).
8. State exit-criteria status explicitly when a milestone looks done.

## Revised Forward Roadmap

This roadmap supersedes the old forward assumption that Phase 2 only had
Save/Load and Playtest-Ready Build remaining. The original milestone table
below remains useful history, but new implementation work should use this
roadmap unless the scope is revised again.

| ID | Milestone | Objective | Exit Criteria | Status |
|---|---|---|---|---|
| P2:R0 | Scope Realignment | Update docs from "light port" to "Phase 1 parity plus game-like UI" | Docs clearly describe the revised Phase 2 target and Phase 3 boundary | Complete |
| P2:R1 | Adventure Parity Audit | Compare Phase 1 docs/prototype against current Godot implementation | Missing mechanics, screens, data, and flow rules are listed as concrete tasks | Complete |
| P2:R2 | Dashboard Loop Reconnection | Reconnect the game-like dashboard to the full Tavern/contract run flow | Player fights through the real sequence from the dashboard, not the retired wizard | Complete |
| P2:R3 | Reward, Shop, And Gear Parity | Restore Phase 1 reward/shop/equipment decisions in the dashboard UX | Gold, gear rewards, shop offers/reroll, equip/unequip, and reward modifiers affect later fights | Complete |
| P2:R4 | Contract Route Parity | Port the first contract route shape from Phase 1 without expanding into a broader procedural map | Player reaches route choices, elite pressure, and Vyra through UI alone | Complete |
| P2:R5 | Run Rules And Determinism | Add Shadow/proc parity, seed handling, failure/retry rules, and run-state transitions | Shadow and Opportunity Strikes are implemented; replaying the same seed/build path is reproducible; failure behavior matches the intended Phase 1 baseline or a documented revision | Complete |
| P2:R6 | Save/Load Persistence | Persist current run state across sessions | Quit mid-run, relaunch, and resume the same run/build/route state correctly | Complete |
| P2:R7 | Game-Like UI Pass | Make the current dashboard clear, coherent, and playtestable as a game screen | A new player can understand class, subclass, talents, skills, enemy, gear, rewards, and next action without explanation | Not started |
| P2:R8 | Playtest Build | Export and bug-fix the revised vertical slice, with optional Training Room Lite if low-risk | A non-developer can play the Rogue adventure unassisted and provide useful feedback; Training Room Lite is present only if it does not delay the Adventure build | Not started |

Tracking docs:

- `docs/Phase_2_R1_Adventure_Parity_Audit.md`
- `docs/Phase_2_R2_Dashboard_Loop_Reconnection.md`
- `docs/Phase_2_R3_Reward_Shop_Gear_Parity.md`
- `docs/Phase_2_R4_Contract_Route_Parity.md`
- `docs/Phase_2_R5_Run_Rules_And_Determinism.md`
- `docs/Phase_2_R6_Save_Load_Persistence.md`
- `docs/Phase_2_R7_Game_Like_UI_Pass.md`
  (style/palette/font planning detail:
  `docs/Phase_2_R7_Style_Implementation_Notes.md`)
- `docs/Phase_2_R8_Playtest_Build.md`

### Revised Phase 2 Boundary

Phase 2 should port the **first proven Rogue adventure** from Phase 1, not the
entire imagined full game. The Phase 1 contract route is in scope because it
was part of the validated prototype experience. A larger meta-progression
structure, additional contracts, additional classes, a procedural map layer,
and broad content expansion remain Phase 3+.

### Immediate Next Step

`P2:R6` is complete. The next implementation milestone is
`P2:R7 - Game-Like UI Pass`, tracked in
`docs/Phase_2_R7_Game_Like_UI_Pass.md`.

Run state now persists across sessions: `SaveSystem` (JSON at
`user://save.json`) round-trips class/trees/talents/rotation/gold/inventory/
equipment/seed/route/failure/outcome state, Resume/New Game/Save & Quit/
Abandon Run are all reachable from Title/dashboard, and autosave fires after
every meaningful state transition (build choices, encounter/route/reward/shop
decisions, fight results, retries) so a crash or unexpected quit loses at
most an in-progress build edit. Keep the full game-like UI pass scoped to
`P2:R7`. Training Room Lite remains an optional `P2:R8` playtest-support
task, not required Phase 1 Rogue Adventure parity.

## Milestone List

Status legend: ⬜ Not started · 🔄 In progress · ✅ Complete

| ID | Milestone | Objective | Exit Criteria | Status |
|---|---|---|---|---|
| P2:M0 | Project Foundation | Stand up the project shell | Empty Godot project runs, under git, folder/naming convention documented | ✅ Complete |
| P2:M1 | Data Architecture | Resource schema for Skills/Gear/Talents/Monsters | New skill or gear item addable via data file, zero code changes | ✅ Complete |
| P2:M2 | Core Combat Resolution | Port the DPS window/rotation engine | Scripted rotation vs. dummy monster produces hand-verifiable DPS numbers, no UI | ✅ Complete |
| P2:M3 | Build Planning UI | Class/subclass/talent/rotation screens | Player can assemble and lock a build through UI only | ✅ Complete |
| P2:M4 | Economy & Gear Loop | Affix-based gear gen, shop, gold | Gold from a fight buys gear that measurably changes P2:M2's output | ✅ Complete |
| P2:M5 | Full Loop Integration | Wire it all into one playable loop | Complete run playable start-to-finish through UI, one class/tree/boss | ✅ Complete |
| P2:M6 | Save/Load | Persist run state | Quit mid-run, relaunch, resume correctly | ⬜ Not started |
| P2:M7 | Playtest-Ready Build | Bug pass, minimal legibility, export | A non-developer plays unassisted and gives useful feedback | ⬜ Not started |

## Task Outline (high level — Steps drafted milestone by milestone)

### P2:M0 — Project Foundation
- T1: Git repo init at `Project-Bane/` root; scaffold `docs/`, `phase3_ideas.md`, `project/`
- T2: Godot 4.x project init (`project.godot`, `.gitignore`, empty runnable scene)
- T3: Document folder/naming convention (`docs/Conventions.md`)

### P2:M1 — Data Architecture
- T1: Skill `Resource` schema + one placeholder skill `.tres`
- T2: Gear `Resource` schema (affix structure) + one placeholder gear item
- T3: Talent `Resource` schema + one placeholder talent
- T4: Monster `Resource` schema + one placeholder monster
- T5: Validate exit criteria — add a second placeholder skill via data file only, zero code changes

### P2:M2 — Core Combat Resolution
- T1: Skill execution timing / attack-speed breakpoint logic
- T2: Damage calculation (physical/poison, armor mitigation, crit)
- T3: Fixed-duration DPS window resolution loop
- T4: Win/loss determination vs. target HP pool
- T5: Headless/console test harness for hand-verifiable DPS output

### P2:M3 — Build Planning UI
- T1: Class/subclass selection screen
- T2: Talent point allocation screen
- T3: Slotted Actions (rotation) builder screen
- T4: Lock-in build flow wired to P2:M2 combat engine

### P2:M4 — Economy & Gear Loop
- T1: Gear generation from affix system (Basic/Master/Cursed tiers)
- T2: Tavern shop skeleton
- T3: Gold economy (earn/spend)
- T4: Equip/unequip wired into build resolution

### P2:M5 — Full Loop Integration (Vertical Slice)
- T1: Wire P2:M1–P2:M4 into one continuous loop (build → fight → reward → tavern → repeat)
- T2: Single boss encounter
- T3: End-to-end playtest pass, one class/one subclass-tree pair

### P2:M6 — Save/Load & Persistence
- T1: Run-state serialization
- T2: Save/load UI hooks (quit mid-run, relaunch, resume)
- T3: Meta-progression state persistence (if any exists by this point)

### P2:M7 — Playtest-Ready Build
- T1: Bug-fixing pass
- T2: Minimum UI legibility polish
- T3: Exported build (Windows desktop min., web bonus)
- T4: External playtest feedback loop

## Notes

Protocol for this file: the `Status` column in the Milestone List is the
single source of truth for whether a milestone is done. It's updated in the
same commit that satisfies a milestone's last exit criterion — not as a
separate later pass. Exceptions or caveats worth remembering go here as dated
notes; this section is not a running restatement of overall progress.

- P2:R1 (2026-07-16): Adventure Parity Audit complete. The audit in
  `docs/Phase_2_R1_Adventure_Parity_Audit.md` classifies Phase 1 Rogue
  Adventure parity as active, dormant, partial, missing, revised, or deferred;
  records Phase 3+ deferrals already captured in `phase3_ideas.md`; and
  reduces the forward build order to the existing `P2:R2` through `P2:R8`
  tracking docs. The next implementation step is `P2:R2 - Dashboard Loop
  Reconnection`.

- P2:R2 (2026-07-16): Dashboard Loop Reconnection complete. The active
  dashboard now reads encounter state from `BuildState.current_encounter()`,
  advances through the seeded ladder with Continue behavior, shows a temporary
  reward preview without applying real reward systems, reaches a basic
  `RUN_ENDED` state when the ladder is exhausted, and has a headless
  dashboard progression test covering multiple encounters. Full reward, shop,
  inventory, gear, and gold parity remains the next milestone, `P2:R3`.

- P2:R3 (2026-07-16): Reward data extension, inventory model, and dashboard
  reward claim flow are complete through `P2:R3:T4` plus `P2:R3:T3`.
  `Encounter` now points at an `EncounterReward` resource, Tavern encounters
  encode authored gold, talent-point timing, Drunk Buddy's Lucky Coin fixed
  reward, and the shop unlock flag, and `Lucky Coin` is seeded as data.
  `BuildState` now stores acquired gear inventory, earned talent-point state,
  claimed reward indices, a basic shop-unlocked flag, and non-destructive
  equip/unequip/swap helpers while preserving weapon/trinket/charm equipment
  as the combat-facing input. The dashboard victory banner now claims rewards
  instead of previewing them. At that point, shop refit, free-reroll removal,
  and Gold Rewards application remained open R3 work.

- P2:R3 (2026-07-16): Dashboard-native Tavern shop refit is complete for
  `P2:R3:T5`. `BuildState` now owns shop-round state, four Basic offers,
  one-reroll tracking, buying into inventory, and closing the round. The active
  dashboard opens a shop overlay after shop access is unlocked by Drunk Buddy,
  lets the player buy or reroll, then advances to the next encounter when the
  player leaves the shop. Full Adventure seed-context generation remains
  `P2:R5`. At that point, free dashboard gear auto-roll/reroll removal, Gold
  Rewards reward math, tests for those remaining pieces, and R3 closeout docs
  remained open.

- P2:R3 (2026-07-16): Free dashboard gear auto-roll/reroll removal is
  complete for `P2:R3:T6`. The active Gear panel no longer grants random
  equipment on entry and no longer exposes a player-facing free reroll.
  Weapon, trinket, and charm slots now reflect only `BuildState` equipment
  earned through rewards/shop decisions, and the inventory area lists earned
  gear with equip actions. `combat_screen_test.gd` now asserts Adventure entry
  starts with no gear, Lucky Coin/shop purchases land in inventory, and
  equipping earned gear remains a build-changing decision. At that point, Gold
  Rewards reward math and R3 closeout docs remained open.

- P2:R3 (2026-07-16): Reward, Shop, And Gear Parity is complete. Gold Rewards
  reward math is implemented in `BuildState.modified_gold_reward()` and is
  applied only when claiming authored encounter gold; `BuildResolver` still
  ignores `GOLD_REWARDS` as a combat stat. `inventory_model_test.gd` now
  proves equipped-only reward modification, multiplicative stacking, clamp to
  `0`, and combat-stat isolation. The R3 regression set passed headlessly with
  explicit Godot log files. The next revised milestone is `P2:R4 - Contract
  Route Parity`.

- P2:R3 follow-up (2026-07-16): corrected Rogue equipment naming drift from
  the Phase 1 reference. Generic slots remain weapon, trinket, helm, armor,
  and charm; Rogue item type labels are Dagger, Ring, Hood, Doublet, and
  Necklace. Generated gear now uses the Phase 1 affix name parts
  Swift/Speed, Sharp/Sharpness, Savage/Savagery, Brutal/Brutality,
  Lethal/Lethality, Poison/Poisoning, Bloody/Rending, and Greedy/Avarice.
  Item tooltips now use generic slot tags such as `Weapon - Swift Dagger`,
  gear/inventory/shop item boxes use square proportions for future icons, and
  the post-fight Victory recap is visually separated from the Rewards box.

- P2:R4 (2026-07-16): Contract Route Parity is complete. The Gilded Serpent
  contract now covers the post-Tavern contract offer, secondary Rogue subclass
  moment, authored route schematic and branch selection, contract monsters,
  route reward choice data, Knives, the Knives Legendary reward choice, and
  Vyra reachability. `Wyvern Kriss` and `Mithril Karambit` are seeded as
  Legendary gear, with generic poison tick cadence and triggered-skill support
  added for their required behavior. Focused and dashboard tests cover route
  data, easy/harder path reachability, generated route reward choices,
  Legendary choice state, and the existing active dashboard flow. The next
  revised milestone is `P2:R5 - Run Rules And Determinism`.

- P2:R5 scope update (2026-07-17): R5 now explicitly includes Shadow and the
  missing Thief `Opportunity Strikes` trigger before the seed/failure-state
  work. Shadow is Phase 1 Rogue Adventure parity, not Phase 3 expansion:
  implement the tree, innate poison behavior, talents, required skills/effects,
  and primary/secondary selection availability. Opportunity Strikes should use
  the generic triggered-skill support added in R4 and then be covered by the
  deterministic proc RNG audit. The required Phase 2 Legendary scope remains
  the Knives pair, Wyvern Kriss and Mithril Karambit; Bandit Blade, Umbral
  Stiletto, and Bejeweled Push Dagger stay deferred unless route reward scope
  is deliberately expanded.

- P2:R5 (2026-07-17): `P2:R5:T2 - Add Shadow Tree Parity` is complete.
  Shadow is now seeded as the third Rogue tree, available in primary and
  secondary subclass selection, and represented by data-backed talents,
  Beguiling Strike, Death Strike, and innate poison on Stab/Heavy Slash.
  Generic support was added for tree skill augments, poison resistance
  reduction, and stack-scaling physical damage. The next R5 task is
  `P2:R5:T3 - Implement Opportunity Strikes Proc`.

- P2:R5 (2026-07-17): `P2:R5:T3 - Implement Opportunity Strikes Proc` is
  complete. `Talent` resources can now contribute generic
  `TriggeredSkillEffect` entries to resolved player stats, and triggered
  effects can optionally declare `source_skill_ids` so talent procs can be
  tied to specific casts without breaking existing gear-trigger behavior.
  Opportunity Strikes now gives Quick Cut a 20% chance to immediately trigger
  Rending Slash with no cast-time cost. The next R5 task is
  `P2:R5:T4 - Add Adventure Seed State`.

- P2:R5 (2026-07-17): `P2:R5:T4 - Add Adventure Seed State` is complete.
  Adventure seed state now lives in `BuildState`, defaults to the Phase 1
  seed `1`, displays in the active dashboard top bar, and is passed into
  active dashboard combat resolution. `BuildState.reset()` can preserve the
  Adventure seed for later failure/restart work. The next R5 task is
  `P2:R5:T5 - Define RNG Contexts`.

- P2:R5 (2026-07-17): `P2:R5:T5 - Define RNG Contexts` is complete. Added
  `RunRng` for Adventure-seed-derived named RNG contexts, routed active
  dashboard combat, Tavern shop offers, generated reward choices, and
  generated shop/reward item IDs through stable context inputs, and added a
  focused reproducibility test. The next R5 task is
  `P2:R5:T6 - Implement Failure Tracking`.

- P2:R5 (2026-07-17): `P2:R5:T6 - Implement Failure Tracking` and
  `P2:R5:T7 - Implement Run Outcomes` are complete. `BuildState` now tracks
  explicit run outcomes for fight win, retryable loss, seed-preserving
  Adventure restart, contract failure, and contract victory. Tavern failures
  allow one do-over per encounter, a second failure requires Adventure restart
  from class select with the visible seed preserved, and contract route
  failures mark the contract failed. The next R5 task is
  `P2:R5:T8 - Wire UI Feedback`.

- P2:R5 (2026-07-17): `P2:R5:T8 - Wire UI Feedback` and
  `P2:R5:T9 - Audit Proc Determinism` are complete. The active dashboard now
  maps every `BuildState.RunOutcome` to an explicit headline/body/button
  presentation, fixing a real bug where the contract-victory status text was
  set on a still-hidden label after the victory banner. The proc-determinism
  audit traced Opportunity Strikes and both Mithril Karambit triggers end to
  end and found no bug: all trigger rolls share the single per-fight seeded
  RNG, with no ad hoc/unseeded RNG path.

- P2:R5 (2026-07-17): `P2:R5:T10 - Add/Update Tests` and
  `P2:R5:T11 - Update Docs` are complete, closing out `P2:R5 - Run Rules And
  Determinism`. Added `tests/deterministic_replay_test.gd`, a committed
  regression test for the reproducibility gap the `P2:R5:T9` audit flagged:
  it confirms `CombatResolver.resolve()` is byte-identical across a repeated
  seed (including crit rolls and proc trigger names) and that varying the
  seed changes the outcome, both for a plain crit-chance rotation and for the
  unforced `0.2`-chance Opportunity Strikes proc. All other T10 coverage
  (Shadow parity, RNG-context shop/reward reproducibility, failure/outcome
  transitions) was already committed from earlier R5 tasks. The next
  implementation milestone is `P2:R6 - Save/Load Persistence`.

- P2:R7 planning note (2026-07-17): R7 now explicitly includes applying the
  game's visual style foundations - the "Road to Peak Deeps" UI palette, a
  four-role font system (Pirata One, MedievalSharp, Press Start 2P, VT323 -
  all verified OFL on Google Fonts; the style mockup's "Pirate Knight" font
  does not exist and Pirata One is its real equivalent), and a project-wide
  Godot Theme resource. Tracked as `P2:R7:T2` with planning detail in
  `docs/Phase_2_R7_Style_Implementation_Notes.md`; later R7 tasks were
  renumbered to make room. Icon-pack integration and full art production
  remain out of R7 scope unless separately added.

- P2:R6 (2026-07-17): Save/Load Persistence is complete. `P2:R6:T1`-`T5` and
  `T8` (save scope audit, JSON format, `SaveSystem` serialization/versioning/
  error handling, and the `save_load_test.gd`/`save_load_ui_test.gd`
  regression coverage) were already done from earlier in the session. This
  pass closed the remaining three tasks: `P2:R6:T6` added a shared
  `_autosave()` call in `combat_screen.gd` after every meaningful state
  transition (class/subclass selection, Tavern/contract/route choice,
  secondary tree choice, fight result, reward claim/choice, shop buy/reroll,
  post-shop/reward advancement, and retry), deliberately excluding mid-fight
  saves since `BuildState.run_phase` never holds `FIGHTING` by the time any
  handler reaches its autosave call. `P2:R6:T7` swept the active UI for
  contradictory save/quit copy and found nothing beyond the "Abandon Run"
  wording already fixed at `P2:R6:T4`. `P2:R6:T9` closed out this document's
  checklist. The next revised milestone is `P2:R7 - Game-Like UI Pass`.

- P2:R8 planning note (2026-07-17): Training Room Lite is added as an optional
  late playtest-support task. Phase 1 included a full Training Room, but it is
  not required for revised Phase 2 Rogue Adventure parity. Full freeform
  Training Room parity remains Phase 3+; the P2:R8 version should only be
  attempted if the exported Adventure build is already stable and the scope
  stays compact.

- P2:M0: the "empty Godot project runs" exit criterion required manual
  confirmation after Godot 4.7 was installed (this machine had no Godot
  install during the milestone's initial file scaffolding). Confirmed via the
  editor successfully opening and resaving `project/project.godot`.

- P2:M1 (2026-07-13): Godot 4.7 GDScript cannot parse a self-referential
  nested typed array where a class's own name appears as the inner type of
  an `Array[Array[T]]` export (e.g. `Talent.prerequisites: Array[Array[Talent]]`
  failed to parse; the same class used as a single-level self-reference,
  `Array[Talent]`, parses fine). `Talent.prerequisites` was implemented as a
  flat `Array[Talent]` (AND-list) instead of the originally planned
  OR-group structure (`Array[Array[Talent]]`, modeling "requires A or B").
  Prerequisite *resolution logic* is out of scope for P2:M1 regardless (that's
  P2:M3), so this doesn't block the milestone, but the OR-group question
  should be revisited when P2:M3 implements passive allocation — likely via a
  small wrapper resource (e.g. `PrerequisiteGroup.options: Array[Talent]`,
  then `Talent.prerequisites: Array[PrerequisiteGroup]`) rather than nested
  self-referential arrays.

- P2:M1 (2026-07-13): validated with placeholder content per Task Outline T1-T5
  — one Skill+SkillEffect pair (`skill.gd`/`skill_effect.gd`/
  `physical_damage_effect.gd`), one Gear item (`gear_item.gd` using the
  shared `stat_modifier.gd`, also reused by Talent), one Talent
  (`talent.gd`), one Monster (`monster.gd`), plus a second placeholder skill
  (`placeholder_quick_cut.tres`) added purely as a data file with zero script
  changes, confirming the exit criterion. All resources verified by
  headless-loading them via `godot --headless -s` (no editor UI involved).

Task-level breakdown above is a first pass for all milestones — not yet
Step-level detail. P2:M1 onward may shift once P2:M0/P2:M1 reveal real Godot
constraints, per working agreement 1 (milestone boundaries are hard, so
later milestones won't be pre-built regardless).

- P2:M2 (2026-07-13): headless `godot --headless -s <script>` runs do not
  themselves trigger Godot's global `class_name` registration — the engine
  reads `.godot/global_script_class_cache.cfg`, which is only rebuilt by an
  editor filesystem scan. New scripts (`PlayerStats`, `PoisonDamageEffect`,
  `CombatTiming`, `DamageCalculator`, `CombatResolver`) were invisible to
  `-s` scripts until a one-time `godot --headless --editor --quit` was run
  to force the rescan. Needed again any time new global classes are added
  and headless-tested without opening the editor UI first.

- P2:M2 (2026-07-13): validated per Task Outline T1-T5. Added
  `PoisonDamageEffect` (`scripts/resources/poison_damage_effect.gd`) as the
  poison sibling of `PhysicalDamageEffect`, and a new `PlayerStats` resource
  (`scripts/resources/player_stats.gd`) plus starter data file
  (`data/player/placeholder_player.tres`, values matching the Project
  Abaddon starter baseline: 0 attack speed, 15% crit chance, 2x crit
  multiplier, 8 poison damage/tick) since no player-stat data existed after
  P2:M1. `placeholder_strike.tres` gained a second (poison) effect so the
  harness exercises both damage types.
  Implemented `scripts/systems/combat_timing.gd` (attack-speed breakpoint
  formula), `scripts/systems/damage_calculator.gd` (armor mitigation/
  vulnerability curve, poison resistance clamp, crit roll+multiplier on
  direct hits only), and `scripts/systems/combat_resolver.gd` (loops the
  rotation until a cast would finish past the window, then resolves poison
  ticks on their own fixed 1000ms cadence against the stacks applied by
  those casts; produces total damage, DPS, and win/loss vs. monster HP).
  `project/tests/combat_test.gd` runs a `Placeholder Strike -> Placeholder
  Quick Cut` rotation against `placeholder_dummy.tres` over a 10s window and
  prints a full per-cast/per-tick log. Hand-traced against the formulas in
  `Current_Mechanics_Reference.md`: 8 casts landing at the expected
  timestamps, 9 poison ticks (the 1000ms tick fires before the first stack
  application lands and deals no damage), one crit (Quick Cut at t=7050ms,
  12 -> 24 physical), total damage 204.00, DPS 20.40, win vs. 150 HP — engine
  output matched the hand trace exactly. All five T1-T5 exit-relevant
  behaviors (timing, damage calc, window loop, win/loss, headless harness)
  are confirmed; the milestone's stated exit criterion is met.

- P2:M3 (2026-07-13): M1 only built Resource schemas for Skill/Gear/Talent/
  Monster, but M3:T1 ("Class/subclass selection screen") and T4 ("Lock-in
  build flow") need a Class/SubclassTree schema and a Build Resolution
  system that M1 didn't scope. This was flagged rather than resolved
  silently and closed as part of M3: added
  `scripts/resources/class_def.gd` (`ClassDef`) and
  `scripts/resources/subclass_tree.gd` (`SubclassTree`), plus one
  placeholder class (`data/classes/placeholder_class.tres`) and one
  placeholder tree (`data/subclass_trees/placeholder_tree.tres`) wired to
  the existing placeholder skills/talent -- placeholder-only, per working
  agreement 3's spirit, not a content-completion pass.
  Also resolved the OR-group prerequisite item flagged in the P2:M1 note
  above: added `scripts/resources/prerequisite_group.gd`
  (`PrerequisiteGroup.options: Array[Talent]`) and changed
  `Talent.prerequisites` from `Array[Talent]` to `Array[PrerequisiteGroup]`.
  Added `scripts/systems/passive_allocator.gd` (`PassiveAllocator`, point
  budget 7, max 2 trees, prerequisite-group and dependent-lock checks per
  `Current_Mechanics_Reference.md`) and `scripts/systems/build_resolver.gd`
  (`BuildResolver`, ports the Build Resolution order scoped to what exists
  at M3: base stats -> tree innate modifiers -> talent stat modifiers ->
  filter rotation to unlocked skills; gear modifiers are a documented no-op
  until P2:M4's equip system exists).
  `BuildResolver.resolve_stats()`/`resolve_rotation()` output feeds
  `CombatResolver.resolve()` unchanged -- confirmed no edits were made to
  any P2:M2 file (`combat_resolver.gd`, `combat_timing.gd`,
  `damage_calculator.gd`) in this milestone, keeping the milestone boundary
  intact.
  Built the four UI screens (`scenes/build_planner/class_select.tscn`,
  `talent_allocation.tscn`, `rotation_builder.tscn`, `build_planner.tscn`)
  plus a `BuildState` autoload (`scripts/autoload/build_state.gd`) holding
  the in-progress build as plain data + signals, per the UI architecture
  principle added to `docs/Conventions.md` this session (logic out of
  `Control` scripts). `build_planner.tscn` is now `project.godot`'s main
  scene, replacing the empty M0 placeholder `scenes/main.tscn` (left on
  disk, unused).
  Caught and fixed a real bug during verification:
  `container.add_child(x).y` doesn't work in Godot 4 (`add_child()` returns
  `void`, not the child), which had silently produced `null` labels and
  cascaded into script-load failures across the whole scene when first run
  as the actual game (`godot --headless --path <project>`, no `-s`) -- six
  occurrences across `class_select.gd` and `rotation_builder.gd`, all split
  into create-then-assign and confirmed fixed by the same run producing no
  script errors afterward.
  Verification note: this environment has no GUI automation tool for native
  Godot windows (only browser automation), so a literal rendered
  click-through wasn't possible. Instead, `project/tests/build_planner_test.gd`
  headlessly instantiates the real `build_planner.tscn`, drives it through
  all four screens exactly as button presses would (class -> tree -> talent
  -> rotation -> lock), and asserts a results panel renders -- confirmed the
  talent's +4 poison damage modifier flows correctly through
  `BuildResolver` into `CombatResolver` (poison ticks read `12.00`, i.e. the
  placeholder baseline of `8` plus the modifier, vs. M2's un-modified
  `8.00`-per-tick baseline), producing total damage `240.00`, DPS `24.00`,
  WIN vs. the 150 HP dummy. This exercises the full signal/state wiring
  end-to-end but does not verify pixel-level rendering or layout; a real
  editor click-through is recommended before this is shown to anyone
  outside this session.

- P2:M4 (2026-07-14): stayed placeholder-only per working agreement 3,
  confirmed explicitly with the user before starting -- real Rogue content
  (`Content_Library_Reference.md`'s actual affix values, gear, class/tree
  content) remains deferred to a dedicated content-seeding step scoped
  later, likely around P2:M5. Added `GearItem.tier`
  (`scripts/resources/gear_item.gd`) and
  `scripts/systems/gear_generator.gd` (`GearGenerator`), which implements
  the real *tier structure* from `Current_Mechanics_Reference.md` (Basic =
  1 affix, Master = 2, Cursed = 1 amplified + 1 more + 1 downside) but with
  deliberately-arbitrary placeholder magnitudes (e.g. `+0.05` attack speed)
  chosen to be visibly distinct from the reference doc's tuned values, so
  "architecture proven" and "content seeded" aren't confused later.
  Extended `scripts/autoload/build_state.gd` with `gold` and
  `equipped_weapon`/`equipped_trinket`/`equipped_charm` plus
  `add_gold`/`spend_gold`/`equip`/`unequip`/`equipped_gear()` -- gold and
  equipped gear are both already listed as build inputs in
  `Current_Mechanics_Reference.md`'s own Build Resolution section, so this
  extends `BuildState`'s existing role rather than introducing a new state
  concept.
  `BuildResolver.resolve_stats()` (`scripts/systems/build_resolver.gd`)
  gained a 4th `equipped_gear` parameter and now actually applies gear
  affixes (previously a documented no-op); still only the four
  PlayerStats-mapped `StatModifier` types are applied, same limitation as
  talent modifiers since P2:M3.
  Built `scenes/tavern/shop.tscn`/`shop.gd`: gold display, the 3 equip
  slots with per-slot Unequip, a seeded batch of 3 generated offers with
  Buy, and a "Fight Again" button that re-runs `BuildResolver` +
  `CombatResolver` (P2:M2's engine, still unmodified) against the same
  placeholder dummy/window. `build_planner.gd`'s lock-build results screen
  now has a "Claim Reward & Visit Shop" button (flat placeholder
  `+20` gold) that transitions into it. Extracted the cast/tick/summary
  text formatting shared by both results displays into
  `scripts/systems/combat_result_formatter.gd`
  (`CombatResultFormatter`) rather than duplicating it.
  Confirmed no edits were made to any P2:M2 file (`combat_resolver.gd`,
  `combat_timing.gd`, `damage_calculator.gd`) this milestone.
  Verification: `project/tests/gear_generator_test.gd` (tier affix counts,
  Cursed downside, `BuildResolver` applying gear) and
  `project/tests/gear_loop_test.gd` (full headless run of the actual scene
  tree -- lock build, fight, claim reward, buy all 3 shop offers, fight
  again -- asserting the resolved `PlayerStats` measurably differ before vs.
  after gear, which is the literal exit criterion) both pass. Same
  environment caveat as P2:M3: no native GUI automation available here, so
  this is headless-verified wiring, not a rendered click-through --
  recommend an editor click-through before this is shown to anyone outside
  this session.

- P2:M5 (2026-07-14): the milestone real content was seeded, confirmed
  explicitly with the user before starting. Three decisions locked in first:
  subclass pair **Assassin + Thief**; boss = **Vyra**'s real stat block
  (600 HP/160 armor/35% poison resist/30s window), no Contract Route
  branching (that's Phase 3's "Contract Run" scope); talent points stay
  **upfront-spend** (not earn-as-you-go), so the Tavern stop is shop-only --
  talent/rotation re-editing between fights was not built this milestone.

  **Investigation finding, resolved with the user before implementation:**
  real Thief talents depend on mechanics that didn't exist yet --
  physical-damage-% (`PHYSICAL_DAMAGE`), poison-stack bonuses
  (`POISON_STACKS_APPLIED`), and armor-reduction-over-time (a *skill*
  effect, with no schema representation at all). User chose to build these
  rather than pick an easier pairing or a reduced talent set. Proc-triggered
  skills (`Opportunity Strikes`' "20% chance to trigger Rending Slash")
  stayed deferred regardless -- seeded with real cost/prereq but no
  numeric/trigger effect, the one deliberate content gap in this milestone.

  **T0 (new engine mechanics, first edits to P2:M2 files since M2 itself):**
  `player_stats.gd` gained `physical_damage_multiplier`,
  `bonus_poison_stacks`, `bonus_armor_reduction` (all default to no-op
  values, so every prior `.tres` and test kept its exact prior behavior).
  Added `scripts/resources/armor_reduction_effect.gd`, a new `SkillEffect`
  subclass. `damage_calculator.gd`'s `resolve_physical_hit()` gained a
  `physical_damage_multiplier` parameter. `combat_resolver.gd` now tracks a
  mutable `current_armor` through the cast loop (starts at `monster.armor`,
  decremented by `ArmorReductionEffect.amount + player.bonus_armor_reduction`
  whenever one fires, persisting for the rest of the fight per
  `Current_Mechanics_Reference.md`); `CastEvent` gained
  `armor_reduction_applied` for hand-verifiable logging.
  `build_resolver.gd`'s `_apply_modifier()` gained `PHYSICAL_DAMAGE`/
  `POISON_STACKS_APPLIED`/`ARMOR_REDUCTION` cases (`GOLD_REWARDS` stays a
  documented no-op -- reward-only, not a combat stat, unused by any seeded
  content). Hand-verified in `project/tests/engine_mechanics_test.gd` with
  synthetic skills: a two-cast armor-reduction rotation confirmed cast 2's
  mitigation reflects cast 1's `-20` armor (62.5 -> 66.6667 damage on a
  100-damage hit, exact fractions), plus isolated checks of
  `physical_damage_multiplier` (100 -> 150 at x1.5) and
  `bonus_poison_stacks` (1 + 2 = 3 stacks applied).

  **T1 (real content):** `data/player/rogue_starter.tres`, six real
  `Skill`s (`stab`, `quick_cut`, `heavy_slash`, `venom_jab`,
  `poison_strike`, `rending_slash` -- the last now carrying a real
  `ArmorReductionEffect(amount=20)`), ten real `Talent`s across
  `data/talents/assassin/` and `data/talents/thief/` (using
  `PrerequisiteGroup` for `Lethal Intent`'s and `Practiced Rhythm`'s
  OR-prereqs -- exactly what `PrerequisiteGroup` was built for in P2:M3),
  `data/subclass_trees/assassin.tres` + `thief.tres`, and
  `data/classes/rogue.tres`. All existing `placeholder_*.tres` files are
  untouched, kept deliberately separate from this real content.
  `gear_generator.gd` was rewritten from M4's flat placeholder scaling to
  the real per-tier magnitudes in `Content_Library_Reference.md`'s
  Generated Gear Affixes table (Master isn't just "2x Basic" -- e.g. Attack
  Speed is `+0.08/+0.10/+0.20` across tiers), expanded to all 7
  combat-relevant `StatModifier` types now that T0 implements them, and
  real shop prices (`18`/`32`/`40`). Armor Reduction has no real downside
  value ("None" in the reference table) -- excluded from the
  downside-eligible pool specifically.

  **T2 (encounter ladder):** `scripts/resources/encounter.gd`, five real
  `Monster`s (Mouthy Drunk, Drunk Buddy, Tavern Bouncer, Hired Goon, Vyra)
  and five `Encounter`s pairing them with their real window/gold reward
  from the Tavern Encounters and Contract Route tables. `run_flow.gd`
  (`RunFlow`) owns the fixed, non-branching 5-encounter order. `BuildState`
  gained `current_encounter_index`/`current_encounter()`/
  `advance_encounter()`.

  **T3 (loop wiring):** new `pre_fight.tscn` (uniform per-encounter target
  info + Fight button, replacing M3/M4's bare "Lock Build" panel) and
  `run_end.tscn` (single Victory/Defeat screen with Restart).
  `build_planner.gd` was reworked into the real loop: rotation builder ->
  pre_fight -> fight -> results -> (loss: run_end immediately, no do-over --
  a deliberate simplification, Phase 1's do-over-on-first-failure rule
  wasn't required by the exit criterion) -> (boss win: run_end) -> (non-boss
  win: claim real gold reward -> shop). `shop.gd`'s M4 "Fight Again" (which
  re-fought a fixed dummy in place) was replaced with "Continue", which
  hands control back to `build_planner.gd` to advance to the next real
  encounter -- this obsoleted M4's `gear_loop_test.gd` and M3's
  `build_planner_test.gd` (both drove the old single-target/lock-build
  interface), so they were deleted and their coverage consolidated into the
  new `full_run_test.gd`.

  **Verification:** `project/tests/full_run_test.gd` headlessly drives the
  real scene tree through the entire slice -- Rogue, both trees selected,
  a 7/7-point talent build, a rotation, and all 5 encounters in order,
  buying gear at each shop stop. First attempt (an Assassin/Thief-split
  build) **lost to Vyra** (486.74 dmg vs. 600 HP needed) -- not a bug: this
  matches `Balance_Baseline_Report.md`'s own real win-rate data, which shows
  Vyra (160 armor, 35% poison resist) punishes poison/Assassin-flavored
  builds hard (Geared Assassin: 8.6%) and specifically rewards Thief's
  armor-pressure playstyle (Geared Thief: 92.4%) -- intentional
  boss-as-build-examiner design. Switched the test to a full Thief talent
  chain (Piercing Blades -> Practiced Rhythm -> Opportunity Strikes ->
  Sunder, 7/7 points) with a Rending Slash/Heavy Slash rotation, and the
  full run passed clean: all 5 encounters won, Vyra included, ending at the
  Victory screen. This also caught a real regression while re-running the
  full test suite: `gear_generator_test.gd`'s stats-changed check only
  compared 3 of the now-7 `PlayerStats` fields, so a randomly-generated
  affix landing on one of the 4 new T0 fields could read as "unchanged" --
  fixed to compare all 7. Also learned mid-session that a failed bare
  `assert()` in a `-s` custom-main-loop script doesn't terminate the Godot
  process (no crash, no `quit()`, just an idle hang) -- `full_run_test.gd`
  now prints diagnostics and calls `quit(1)` explicitly on any encounter
  loss instead of asserting, avoiding that trap for future iteration.
  Confirmed `combat_test.gd` (P2:M2) and `engine_mechanics_test.gd` still
  pass unmodified alongside the fixed `gear_generator_test.gd` and the new
  `full_run_test.gd`. Same environment caveat as every UI milestone so far:
  headless-verified wiring only, no rendered click-through available here --
  recommend an editor click-through before this is shown to anyone, more so
  than prior milestones since this is the first one meant to feel like an
  actual playable slice.

## UI/UX restructure (outside the M0-M7 numbering)

2026-07-14: after P2:M5, the user shared four UI mockups and requested a
structural rework of the game screens -- explicitly acknowledged as going
beyond this milestone table (M6 is Save/Load, M7 is bug-fixing/export;
visual/UX work was deferred as "a later phase" throughout M0-M5). Not given
its own M-number since it's cross-cutting UI work, not a discrete data/
system capability, but recorded here so the milestone table doesn't imply
the game still looks/flows the way P2:M5 left it.

Replaced the linear wizard (`class_select` -> `talent_allocation` ->
`rotation_builder` -> `pre_fight` -> results -> shop -> repeat, one screen
at a time via `build_planner.gd`) with: a real **Title** screen
(`scenes/title/`) -> **Class Select** (`scenes/class_select/`, real Rogue +
static disabled Mage/Crusader) -> **Subclass Select**
(`scenes/subclass_select/`, new screen, single-choice tree pick + static
disabled Shadow) -> a **persistent combat dashboard**
(`scenes/combat/combat_screen.tscn`) composing five live-refreshing panels
(`character_stats_panel`, `enemy_panel`, `talent_panel`, `skill_macro_panel`,
`gear_panel` stub) instead of separate sequential screens. A new
`scenes/game_root.tscn`/`.gd` replaces `build_planner.gd` as the top-level
screen orchestrator (`project.godot`'s main scene). Added
`BuildState.select_tree()` for "pick exactly one" semantics, distinct from
the existing multi-select `toggle_tree()` (kept, in case 2-tree selection
UI returns later).

Deliberately out of scope for this pass, confirmed with the user
beforehand: gear stays fixed/non-interactive (shop returns later as an
overlay on the dashboard, not a full-screen replacement); fights a single
fixed enemy (reused `data/monsters/mouthy_drunk.tres`, real M5 content)
instead of the 5-encounter ladder -- `RunFlow`/`Encounter`/
`BuildState.current_encounter*`/`scenes/tavern/shop.*`/
`scenes/build_planner/run_end.*` are kept dormant, not discarded, to be
reconnected once the dashboard is proven; and visual styling (colors/fonts/
theme matching the mockups) is a deliberate follow-up, not this pass --
everything here still uses default, unstyled Godot controls, same look as
P2:M3-M5, just restructured.

Retired (deleted, not left dormant, since their logic was absorbed into the
new panels and the screens became unreachable):
`scenes/build_planner/build_planner.*`,
`scenes/build_planner/class_select.*`,
`scenes/build_planner/talent_allocation.*`,
`scenes/build_planner/rotation_builder.*`,
`scenes/build_planner/pre_fight.*`, and `project/tests/full_run_test.gd`
(drove the retired wizard scenes end-to-end; the logic it exercised --
`RunFlow`/`Encounter`/`BuildResolver`/`CombatResolver` -- is untouched and
still covered by `combat_test.gd`/`engine_mechanics_test.gd`/
`gear_generator_test.gd`, none of which touch any UI scene).

Verification: new `project/tests/combat_screen_test.gd` headlessly drives
the real scene tree -- title -> Adventure Mode -> class select (confirms
exactly 2 disabled buttons: Mage, Crusader) -> subclass select (confirms
exactly 1 disabled button: Shadow) -> Thief chosen -> spends a real talent
point on Piercing Blades in `talent_panel` -> confirms `unlocked_skills()`
grows to 4 (3 base + Rending Slash) -> adds all 4 to the macro in
`skill_macro_panel` -> confirms `character_stats_panel`'s displayed text
reflects Piercing Blades' `x1.08` physical damage modifier ("Physical
Damage: 108%") -> presses Fight -> confirms the combat log contains
`Result:`. This exercises cross-panel reactivity (`BuildState.build_changed`
propagating to all three panels from a single talent selection), not just
each panel in isolation. `combat_test.gd`/`engine_mechanics_test.gd`/
`gear_generator_test.gd` confirmed passing unmodified. Same environment
caveat as every UI pass so far: headless-verified wiring only -- an editor
click-through is recommended before this is shown to anyone, especially
now that the structure is meant to resemble the actual envisioned layout
from the mockups (the mockups' visual styling itself -- colors, fonts,
theme -- was explicitly not attempted this pass).
