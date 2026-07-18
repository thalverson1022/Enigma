# P2:R1 - Adventure Parity Audit

## Purpose

Track the work for **P2:R1 - Adventure Parity Audit**, the first milestone in
the revised Phase 2 roadmap.

The goal is to compare the validated Phase 1 React prototype against the
current Godot implementation and produce a concrete, buildable parity plan.
This milestone is an audit milestone, not an implementation milestone.

## Exit Criteria

P2:R1 is complete when the project has a written answer to:

> What exactly remains to make Godot match the Phase 1 Rogue adventure, what
> is intentionally different in Project Bane, what is deferred, and what order
> should the next revised milestones build it in?

The audit should classify every meaningful Phase 1 feature as one of:

- **Active** - ported and active in the current dashboard.
- **Dormant** - ported or partially ported, but not currently reachable after
  the dashboard restructure.
- **Partial** - implemented in some form, but missing important behavior,
  content, rules, or UI.
- **Missing** - present in Phase 1 but not yet present in Godot.
- **Revised** - intentionally changed for Project Bane.
- **Deferred** - too large or inappropriate for Phase 2; move to
  `phase3_ideas.md`.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R1:T1 | Establish Phase 1 Baseline | Summary of the shipped Phase 1 prototype experience | Complete |
| P2:R1:T2 | Map Current Godot State | Inventory of active, dormant, and missing Godot systems/screens/data | Complete |
| P2:R1:T3 | Build Feature Parity Matrix | Table comparing Phase 1 vs. current Godot by feature | Complete |
| P2:R1:T4 | Identify Mechanics Gaps | Separate list of missing/incomplete rules and engine behaviors | Complete |
| P2:R1:T5 | Identify Content Gaps | Comparison of Phase 1 content references vs. Godot data resources | Complete |
| P2:R1:T6 | Identify UI/Flow Gaps | List of missing screens, panels, run-flow transitions, and dashboard needs | Complete |
| P2:R1:T7 | Decide Revised/Cut Items | Classification of mismatches as parity, revised, cut, or deferred | Complete |
| P2:R1:T8 | Produce Implementation Roadmap | Ordered task plan for P2:R2 onward | Complete |
| P2:R1:T9 | Update Docs | Final audit findings recorded here and cross-linked from milestone docs | Complete |

## P2:R1:T1 - Establish Phase 1 Baseline

Review the Phase 1 reference docs:

- `docs/Phase 1 Context Docs/Phase_1_Design_Recap.md`
- `docs/Phase 1 Context Docs/Current_Mechanics_Reference.md`
- `docs/Phase 1 Context Docs/Content_Library_Reference.md`
- `docs/Phase 1 Context Docs/Balance_Baseline_Report.md`

Capture the Phase 1 player experience across:

- Adventure mode flow.
- Training Room behavior.
- Rogue class and subclass identity.
- Tavern encounter sequence.
- First contract route.
- Rewards, shop, gear, and gold.
- Talent point timing and build editing.
- Combat/build mechanics.
- Deterministic seed behavior.
- Failure and retry rules.
- Balance intent and known watchpoints.

### P2:R1:T1 Output - Phase 1 Baseline

Phase 1, Project Abaddon, shipped as a deterministic Rogue-only DPS-build
roguelike prototype with two playable modes: Adventure and Training Room. The
core player fantasy was building a Rogue damage engine, reading the next
target's HP, armor, poison resistance, and combat window, then tuning passives,
gear, and rotation to clear a fixed-window DPS check.

Adventure mode flow:

- The player chose Adventure, selected Rogue, then chose one primary Rogue
  subclass from Assassin, Thief, or Shadow.
- The run opened with four linear Tavern encounters: Mouthy drunk, Drunk
  Buddy, Tavern Bouncer, and Hired Goon.
- Tavern progression introduced fight results, rewards, talents, shop access,
  gear management, and the contract hook.
- After the Tavern, the player accepted The Gilded Serpent Contract, chose a
  secondary Rogue subclass, chose a route opener, progressed through route
  fights, defeated Knives, then fought Vyra as the contract boss.
- The Adventure header displayed the active run seed. The default seed was `1`.
- A completed or failed contract returned the player to restart flow.

Training Room behavior:

- Training Room was a freeform mechanics lab using the same build resolver and
  combat simulator as Adventure.
- It exposed controls for active Rogue trees, passives, gear quality and
  affixes, Legendary weapon choice, rotation, target, combat duration, seed,
  and practice gold.
- It had separate seed control from Adventure, allowing players and testers to
  reproduce combat outcomes independently of the active Adventure seed.
- Training Room kept the same active-tree mental model as Adventure, but
  reduced friction for experimentation: up to two active trees, only active-tree
  passives selectable, and invalid passives/rotation skills removed when active
  trees changed.

Rogue class and subclass identity:

- Rogue was the only playable Adventure class. Mage and Crusader existed only
  as unavailable class options.
- The starter Rogue baseline was `0` attack speed, `15%` crit chance, `2x`
  crit multiplier, and `8` poison damage per tick.
- Assassin focused on poison setup and critical payoff for single-target
  pressure. Its talents included Venom Edge, Precise Cuts, Lethal Intent, Toxic
  Technique, and Perfect Toxin.
- Thief focused on fast attacks, armor pressure, and efficient
  physical/hybrid damage. Its talents included Quick Hands, Piercing Blades,
  Practiced Rhythm, Opportunity Strikes, and Sunder.
- Shadow focused on innate poison pressure, resistance pressure, and delayed
  payoff. Its talents included Lingering Venom, Exposed Weakness, Black Lotus,
  Nightblade Rhythm, and Umbral Pressure.
- Shadow also granted an innate poison source: Stab and Heavy Slash applied
  `+1` poison stack when Shadow was one of the chosen trees.
- Adventure builds had a `7` point passive budget, could use at most two trees,
  rejected duplicate nodes and missing prerequisites, supported prerequisite
  option groups, and prevented removing passives with selected dependents.

Tavern encounter sequence:

| Encounter | Window | Reward | Purpose |
|---|---:|---|---|
| Mouthy drunk | `12s` | `12g`, `1` talent point | Opener that confirms rotation entry and fight resolution. |
| Drunk Buddy | `18s` | `18g`, Lucky Coin | Introduces armor and unlocks shop/gear management. |
| Tavern Bouncer | `24s` | `24g`, `1` talent point | Introduces high poison resistance. |
| Hired Goon | `30s` | `36g`, `1` talent point | Final Tavern check before secondary tree and contract access. |

First contract route:

- The first contract was The Gilded Serpent Contract, targeting Vyra.
- The route started with Door Guard or Portly Cook.
- Door Guard was the harder opener and gave better reward quality: a Master
  weapon or trinket choice. It led to Sleeping Henchman or Cloaked Watchmen.
- Portly Cook was the easier opener and gave lower reward quality: a Basic
  weapon or charm choice. It led to Lazy Henchman or Patrolling Guard.
- All second-layer fights led to Knives.
- Knives was the elite fight, rewarded `42g` and a Legendary weapon choice
  between Wyvern Kriss and Mithril Karambit, then led to Vyra.
- Vyra was the boss, with `600` HP, `160` armor, `35%` poison resistance, and a
  `30s` window. Defeating Vyra marked contract victory.

Rewards, shop, gear, and gold:

- Encounter rewards could grant gold, talent points, and fixed gear item IDs.
- Gold rewards were affected by equipped Gold Rewards modifiers. Multiple Gold
  Rewards modifiers compounded multiplicatively, then the final award was
  rounded and clamped to `0` or higher.
- The Tavern shop unlocked after the second Tavern fight.
- Each shop round presented four generated items and allowed one reroll.
- Tavern shop gear was Basic before contract selection. Contract shop gear
  could roll Master and Cursed based on route depth.
- Generated gear tiers were Basic, Master, and Cursed. Basic had one positive
  affix; Master had two positive affixes; Cursed had one amplified positive
  affix, one Master positive affix, and one downside.
- Shop prices were Basic `18`, Master `32`, and Cursed `40`.
- Gear slots were weapon, trinket, and charm.
- Gear could modify player stats, physical skill damage, poison stack
  application, armor reduction, skill triggers, unlocked skills, poison tick
  cadence, minimum execution time proc chance, and claimed gold rewards.
- Authored Legendary weapons existed as major build pivots: Wyvern Kriss,
  Bandit Blade, Umbral Stiletto, Mithril Karambit, and Bejeweled Push Dagger.

Talent point timing and build editing:

- Tavern rewards granted talent points on Mouthy drunk, Tavern Bouncer, and
  Hired Goon.
- Contract route nodes could also grant talent points depending on path.
- Build resolution used chosen primary and secondary trees, selected passives,
  equipped gear, rotation, and current gold when required by gear.
- Resolution order was base Rogue stats, unlocked skills, triggered skill IDs,
  cloned available skills, tree innate modifiers, passive modifiers, gear
  modifiers in weapon/trinket/charm order, then rotation filtering to unlocked
  skills.
- Failed fights returned to build editing on the first failure for that
  encounter, giving the player one do-over before the harsher failure result.

Combat and build mechanics:

- Combat was a deterministic fixed-window DPS simulation.
- Each fight had an authored duration in milliseconds.
- The player supplied a rotation of skill IDs. Skills cast in order and looped
  until the window ended.
- If a cast would finish after the combat window, it was skipped and did not
  apply effects.
- Combat ended at the fixed duration even if poison remained.
- Victory was based on total final damage versus target starting HP.
- DPS was total final damage divided by combat duration in seconds.
- Skill execution used
  `ceil(max(minExecutionMs, baseExecutionMs / (1 + attackSpeed)))`.
- Direct physical hits could crit. Poison ticks did not crit.
- Armor mitigated only physical damage, using the Phase 1 armor curve for both
  positive armor mitigation and negative armor vulnerability. Armor reduction
  could push armor below zero and persisted for the rest of the fight.
- Poison used individual stack sources, ticked every `1000ms` by default, had a
  default cap of `20` stacks, consumed one stack per tick, and stopped at the
  fixed combat-window end.
- Poison resistance mitigated only poison damage, clamped between `0` and `1`.
  Poison resistance reduction reduced the current resistance for later ticks;
  negative poison resistance did not increase poison damage.
- Triggered skills resolved immediately and did not consume cast time.

Deterministic seed behavior:

- Crit rolls were deterministic for a given seed.
- Bejeweled Push Dagger minimum-time procs were deterministic for a given seed.
- Adventure used the Adventure seed selected on the mode screen.
- Training Room used its own seed.
- Generated shop and reward gear were seeded from run, contract, route, slot,
  tier, and option context.
- Seeded reproducibility was a tester-facing success criterion: reports should
  include build, route, seed, and target issues cleanly.

Failure and retry rules:

- On first failure for a given Adventure encounter, the player received a
  do-over and returned to build editing for that fight.
- Failing the same encounter again restarted the Adventure from class selection
  while preserving the run seed.
- Contract route failures marked the contract as failed.
- Victory over Vyra marked contract victory.

Balance intent and watchpoints:

- The Tavern was tuned as a sequence of lessons: basic rotation execution,
  armor, high poison resistance, then a final pre-contract check.
- The contract route was intentionally not flat. The easy path was Portly Cook
  -> Lazy Henchman -> Knives -> Vyra. Door Guard was a harder opener, and Door
  Guard -> Cloaked Watchmen -> Knives -> Vyra was the hardest reward path.
- Poison resistance spread was deliberate. Tavern Bouncer was the early
  extreme poison-resistance lesson; contract armored targets used `25%` to
  `40%` poison resistance to pressure poison-heavy builds without removing
  poison's good matchups against unmitigated targets.
- Baseline simulations showed Basic Assassin strongest on the 20s Training
  Dummy, Basic Thief lower average but better positioned against armor, and
  Basic Shadow stable and simple.
- Midgame Training Dummy baselines were close enough to support route tuning,
  but armored and poison-resistant contract targets heavily favored Thief's
  armor-pressure style.
- Known watchpoints: Basic Thief could fail Hired Goon; Door Guard's practical
  difficulty varied by build; Cloaked Watchmen was a severe hard-path gate;
  Knives and Vyra punished poison-heavy midgame builds; Legendary reward timing
  before Vyra could materially change boss odds; and future route expansion
  needed to vary armor pressure, poison resistance, short burst checks, and
  long ramp checks.

## P2:R1:T2 - Map Current Godot State

Inventory the current Godot project:

- Active main flow: title, class select, subclass select, combat dashboard.
- Active dashboard panels and interactions.
- Active combat/build systems.
- Active data resources.
- Dormant M5 systems such as `RunFlow`, encounters, shop, and run end.
- Tests that currently define expected behavior.
- Known limitations from headless-only verification.

### P2:R1:T2 Output - Current Godot State

Working-tree note:

- The current implementation is mostly uncommitted working-tree state. Treat
  the working tree as the source of truth for this audit, matching
  `docs/Codex_Onboarding_Context.md`.
- `project/project.godot` launches `res://scenes/game_root.tscn` and autoloads
  `BuildState`.

Active main flow:

- `game_root.gd` drives the reachable flow:
  `Title -> Class Select -> Subclass Select -> Combat Dashboard`.
- `title.gd` exposes Adventure Mode, disabled Training Room, and Exit.
- `class_select.gd` scans `data/classes/` for real class data. Rogue is active;
  Mage and Crusader are static disabled UI cards.
- `subclass_select.gd` presents the selected class's data-backed trees as
  single-choice cards. Assassin and Thief are active; Shadow is a static
  disabled UI card.
- `combat_screen.gd` is the active persistent dashboard. Returning to main menu
  resets `BuildState`.

Active dashboard panels and interactions:

- `character_stats_panel.gd` displays resolved build stats live, including
  physical damage bonus, attack speed, crit chance, crit multiplier, bonus
  armor reduction, poison damage, and bonus poison stacks.
- `talent_panel.gd` renders the selected subclass tree from data, including
  talent tiers derived from prerequisites, point-cost circles, prerequisite
  locking, dependent-lock removal rules, tooltips, intrinsic text, and
  remaining point count.
- `available_skills_panel.gd` displays currently unlocked skills; clicking a
  skill appends it to the rotation.
- `skill_build_panel.gd` displays the rotation as removable skill slots and
  owns the `LOCK` / `UNLOCK` readiness control. Empty rotations cannot be
  locked.
- `enemy_panel.gd` displays a fixed Mouthy Drunk target and a fixed `12s`
  combat window. FIGHT is gated by the build lock.
- `gear_panel.gd` auto-rolls weapon, trinket, and charm when entering the
  dashboard, supports rerolling all three, and displays helm/armor as empty
  dummy UI slots. Gear is currently unseeded/randomized in this panel.
- `combat_screen.gd` resolves combat through `BuildResolver` and
  `CombatResolver`, shows a status line, enables a dismissible combat log, and
  shows a victory recap overlay with total damage, DPS, biggest hit, and
  physical/poison split.

Active systems:

- `BuildState` stores selected class, selected trees, selected talents,
  rotation, gold, equipped weapon/trinket/charm, current encounter index, and
  lock state. Build mutations clear the lock.
- `BuildResolver` applies base class stats, tree innate modifiers, talent
  modifiers, equipped gear modifiers, and filters the rotation to unlocked
  skills. `GOLD_REWARDS` is intentionally not applied as a combat stat.
- `PassiveAllocator` enforces the `7` point budget, max `2` selected trees,
  selected-tree membership, OR-prerequisite groups, and dependent-lock
  deselection.
- `CombatResolver`, `CombatTiming`, and `DamageCalculator` implement the
  fixed-window looping rotation, attack-speed execution timing, physical
  mitigation/crit, poison ticking, poison stack cap, and persistent armor
  reduction.
- `CombatRecap` and `CombatResultFormatter` support dashboard recap/log
  presentation.
- `GearGenerator` implements Basic/Master/Cursed affix counts, real per-tier
  affix magnitudes, real tier prices, seeded offer generation, and generated
  item creation for weapon/trinket/charm.

Active data resources:

- Class/player data: `rogue.tres`, `rogue_starter.tres`, and placeholder
  player data.
- Subclass trees: Assassin and Thief are seeded as data resources. Shadow is
  not seeded.
- Talents: five Assassin talents and five Thief talents are seeded.
- Skills: real Rogue skills include Stab, Quick Cut, Heavy Slash, Venom Jab,
  Poison Strike, and Rending Slash. Placeholder Strike and Placeholder Quick
  Cut remain for tests.
- Monsters: Mouthy Drunk, Drunk Buddy, Tavern Bouncer, Hired Goon, Vyra, and
  Placeholder Dummy exist as data resources.
- Encounters: five linear M5 encounter resources exist:
  Mouthy Drunk, Drunk Buddy, Tavern Bouncer, Hired Goon, and Vyra.
- Gear: `placeholder_dagger.tres` exists; generated gear is produced in code
  by `GearGenerator`. Legendary authored gear is not seeded.

Dormant or disconnected systems/screens/data:

- `RunFlow` still stores the five-encounter ladder from M5, and `BuildState`
  still has `current_encounter()`, `advance_encounter()`, and
  `current_encounter_index`, but the active dashboard does not consume them.
- Encounter resources for the M5 Tavern-to-Vyra ladder are present but not
  reached by the active dashboard flow.
- `scenes/tavern/shop.gd` / `.tscn` still implement a simple shop with gold,
  equipped slots, three generated offers, buying, unequipping, and Continue,
  but no active screen currently instantiates the shop.
- `scenes/build_planner/run_end.gd` / `.tscn` still implement a basic
  Victory/Defeat + Restart screen, but the active dashboard uses overlays and
  does not route to this scene.
- The earlier wizard-style build planner scenes were deleted during the UI
  restructure; only `run_end` remains under `scenes/build_planner/`.

Known current limitations:

- The active dashboard only fights fixed Mouthy Drunk. It does not progress
  through the Tavern ladder, rewards, shop, contract route, Knives, or Vyra.
- Active subclass selection is single-tree only. `BuildState.toggle_tree()` and
  `PassiveAllocator.MAX_TREES = 2` still support two-tree rules, but the active
  UI does not expose secondary subclass timing.
- Talent points are currently an upfront `7` point budget in the dashboard,
  not earned at Phase 1 Tavern/contract reward timings.
- Gear in the dashboard is auto-rolled/rerollable equipment, not Phase 1
  reward choices, inventory, shop purchase flow, or deterministic
  run-context generation.
- Gold exists in `BuildState` and the dormant shop, but it is not part of the
  active dashboard loop.
- Training Room is visible only as a disabled title-screen button.
- Failure/retry rules, run victory/defeat state transitions, save/load, and
  Adventure seed UI are not active.
- Headless tests verify logic and scene wiring, but no rendered native Godot
  click-through or pixel/layout verification has been performed.

Current verification pass:

- First bare Godot test run crashed while opening `user://logs`, matching the
  known log-collision issue. Re-ran tests with explicit `--log-file` paths.
- Passing headless tests:
  `combat_test.gd`, `engine_mechanics_test.gd`, `gear_generator_test.gd`,
  `passive_allocator_test.gd`, and `combat_screen_test.gd`.
- Passing runs still print known Godot cleanup warnings about leaked
  ObjectDB/resource instances after successful assertions and exit code `0`.

## P2:R1:T3 - Build Feature Parity Matrix

Create a matrix with these columns:

| Feature | Phase 1 Behavior | Current Godot State | Classification | Notes / Required Work |
|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD |

Recommended feature groups:

- Mode structure.
- Class/subclass selection.
- Talent allocation.
- Slotted Actions / rotation editing.
- Combat simulation.
- Combat presentation and recap.
- Tavern encounters.
- Rewards.
- Shop.
- Gear generation/equipment.
- Contract route.
- Boss/elite fights.
- Run failure/retry.
- Seeds/determinism.
- Save/load.
- Training Room.
- UI clarity and onboarding.

### P2:R1:T3 Output - Feature Parity Matrix

| Feature | Phase 1 Behavior | Current Godot State | Classification | Notes / Required Work |
|---|---|---|---|---|
| Mode structure | Adventure and Training Room are both playable modes. | Title screen exposes Adventure Mode; Training Room is visible but disabled. | Partial | Keep Adventure as the main Phase 2 path. Decide whether Training Room returns in Phase 2 as parity support or stays deferred. |
| Adventure entry | Player chooses Adventure, Rogue, then a primary Rogue subclass. | Active flow is Title -> Class Select -> Subclass Select -> Combat Dashboard. | Active | Core entry flow is present, but downstream Adventure progression is not connected. |
| Class availability | Rogue is playable; Mage and Crusader are unavailable options. | Rogue is data-backed and active; Mage and Crusader are disabled static cards. | Active | Matches Phase 1 availability and Project Bane scope. |
| Primary subclass selection | Assassin, Thief, and Shadow are selectable Rogue primary trees. | Assassin and Thief are active; Shadow is shown disabled. | Partial | Seed Shadow data, talents, innate poison behavior, and enable selection if Shadow parity remains in Phase 2. |
| Secondary subclass timing | After the Tavern, the player chooses a second Rogue tree before contract routing. | `BuildState` and `PassiveAllocator` support two selected trees, but UI only chooses one tree up front. | Partial | Reintroduce secondary tree choice at the post-Tavern/contract hook without returning to the retired wizard flow. |
| Passive budget and rules | Adventure uses a 7 point budget, max two trees, duplicate/prereq/dependent rules. | `PassiveAllocator` enforces budget, tree cap, OR prereqs, and dependent-lock removal. | Active | Rules are implemented, but active UI currently exercises only one selected tree. |
| Talent point timing | Talent points are earned from specific Tavern and contract rewards. | Dashboard starts with an upfront 7 point budget. | Partial | Replace or revise upfront budget with reward-timed talent point gains for Adventure parity. |
| Talent tree UI | Player edits passives between fights using active trees and prerequisites. | Dashboard talent panel is data-driven, live, and enforces prerequisite/removal rules. | Active | Needs multi-tree and earned-point timing before it fully matches Adventure flow. |
| Skill unlocks | Base, tree, passive, and gear sources determine available skills. | Base/tree/talent skill unlocks are active; gear skill unlocks are not seeded. | Partial | Preserve resolver order and add gear-unlocked skills when authored gear/Legendary items return. |
| Rotation editing | Player builds a slotted rotation; invalid skills are filtered from resolved combat. | Dashboard has available skills and removable rotation slots; empty rotations cannot lock. | Active | Good parity foundation. Needs route/fight context so players tune rotation against each next target. |
| Build lock and fight gating | Player commits a build/rotation before resolving each fixed-window fight. | Dashboard `LOCK`/`UNLOCK` gates FIGHT; build mutations clear the lock. | Active | Matches the intended Project Bane dashboard direction. |
| Combat simulation core | Fixed-window deterministic looping rotation, cast cutoff, physical/poison damage, crits, armor, poison stacks, DPS and win/loss. | Combat systems implement fixed windows, timing, mitigation/vulnerability, crits, poison stack/tick rules, stack cap, and armor reduction. | Active | Core DPS engine is the strongest parity area. |
| Combat RNG | Crits and proc effects are deterministic for a run seed. | Combat uses deterministic test coverage, but active Adventure seed UI/state is absent. | Partial | Add Adventure seed state/UI and route-context RNG wiring; proc RNG depends on missing proc mechanics. |
| Triggered skills and procs | Triggered skills resolve immediately and do not consume cast time. | Opportunity Strikes, Mithril Karambit triggers, and related proc behaviors are not active. | Missing | Add triggered skill support before claiming full gear/talent parity. |
| Poison resistance reduction | Beguiling Strike and related effects can reduce current poison resistance for later ticks. | Poison resistance mitigation exists; resistance reduction effects are not represented in active data/systems. | Missing | Add effect schema and resolver behavior, then seed Shadow/Beguiling Strike content. |
| Poison tick cadence changes | Wyvern Kriss can make poison tick twice as fast. | Default 1000ms poison cadence exists; cadence-changing gear behavior is absent. | Missing | Needed for authored Legendary parity. |
| Minimum execution time procs | Bejeweled Push Dagger can make normal casts use minimum execution time based on seeded RNG. | Timing formula respects minimum cast time; min-time proc behavior is absent. | Missing | Needed for authored Legendary parity and seed reproducibility. |
| Combat presentation | Phase 1 shows fight results and enough detail to understand damage output. | Dashboard shows status, combat log overlay, and victory recap with total damage, DPS, biggest hit, and damage split. | Active | Presentation is usable, but defeat/route/reward transitions are not yet connected. |
| Tavern encounter ladder | Mouthy Drunk -> Drunk Buddy -> Tavern Bouncer -> Hired Goon, with authored windows/rewards. | Five M5 encounter resources and `RunFlow` exist, but dashboard fights fixed Mouthy Drunk only. | Dormant | Reconnect `RunFlow` to the dashboard as P2:R2's first major implementation target. |
| Tavern rewards | Tavern wins grant gold, talent points, Lucky Coin, and shop/gear unlocks at authored timings. | Gold state exists; active dashboard does not claim rewards or unlock shop/gear progression. | Partial | Restore reward claim flow in dashboard, including fixed items and talent point awards. |
| Shop unlock and rounds | Shop unlocks after Drunk Buddy, shows four generated items, and allows one reroll per round. | Dormant shop scene exists with generated offers, buying, unequipping, and Continue, but uses three offers and is not connected. | Dormant | Rebuild as dashboard overlay/panel, use four offers, add one reroll, and trigger from correct progression points. |
| Gear generation | Basic, Master, and Cursed tiers use real affix counts, magnitudes, prices, and seeded generation. | `GearGenerator` has real tiers, magnitudes, prices, and seeded offer APIs; dashboard gear panel rolls random gear directly. | Partial | Route all Adventure gear through seeded run/reward/shop contexts instead of unseeded dashboard rerolls. |
| Gear equipment slots | Weapon, trinket, and charm are equipped, retained, and affect later fights. | Weapon/trinket/charm equipment affects resolved stats; dashboard shows dummy helm/armor slots too. | Partial | Add inventory/retained choices and remove or justify non-Phase-1 dummy slots in Adventure UI. |
| Gold economy | Gold is earned, modified by Gold Rewards affixes, spent in shop, and can affect gear. | Gold helpers and dormant shop spending exist; active dashboard does not use gold. | Partial | Connect gold to reward/shop loop and implement claimed reward modifiers. |
| Authored starter gear | Fixed starter/reward gear includes Lucky Coin and other named Basic items. | Only `placeholder_dagger.tres` exists; generated gear is active. | Missing | Seed authored starter/fixed reward items as data resources. |
| Authored Legendary gear | Knives rewards a Legendary choice; Legendary weapons provide major build pivots. | No authored Legendary gear items or special behaviors are seeded. | Missing | Seed Legendary resources and implement missing special mechanics before Knives/Vyra parity. |
| Inventory and reward choices | Player chooses and retains items from rewards/shop across the run. | Equipped slots exist, but no Adventure inventory or reward-choice flow is active. | Missing | Add minimal inventory/reward-choice model needed for first Rogue adventure. |
| Contract hook | After Hired Goon, player accepts The Gilded Serpent Contract and chooses secondary tree. | No active contract hook exists; current dormant ladder jumps from Hired Goon to Vyra. | Missing | Add dashboard-native contract transition after Tavern completion. |
| Contract route choice | Player chooses Door Guard or Portly Cook, then a second-layer route choice. | Door/route/second-layer contract nodes are not present in Godot data or flow. | Missing | Seed contract node monsters/encounters and implement route state/choice UI. |
| Elite fight | Knives is an elite before Vyra and rewards Legendary weapon choice. | Knives monster/encounter/reward is absent. | Missing | Add Knives data, route convergence, reward handling, and Legendary choice. |
| Boss fight | Vyra is the contract boss reached through route progression. | Vyra monster and an M5 Vyra encounter exist, but active dashboard only fights Mouthy Drunk. | Dormant | Reconnect Vyra as the route climax, not a direct Tavern ladder endpoint. |
| Run victory/defeat | Contract victory/failure returns player to restart flow. | Run end scene exists, but active dashboard uses overlays and no full run-state transition. | Dormant | Decide whether to reuse, replace, or fold run end into dashboard shell. |
| Failure and retry rules | First failure on an encounter gives one do-over; second failure restarts Adventure preserving seed; contract failures mark contract failed. | No active failure/do-over/restart rules in dashboard. | Missing | Implement per-encounter failure tracking and seed-preserving restart behavior. |
| Adventure seed | Adventure seed defaults to `1`, is displayed, and makes reports reproducible. | No Adventure seed display/input/state in active UI. | Missing | Add seed state to `BuildState` or run state and display it in the Adventure dashboard/header. |
| Deterministic generated rewards | Shop/reward gear generation is seeded from run, contract, route, slot, tier, and option context. | Seeded `GearGenerator.generate_offers()` exists; active gear panel uses unseeded randomize/reroll. | Partial | Replace active random gear panel behavior with deterministic run-context generation. |
| Save/load | Phase 1 restart flow exists; revised Phase 2 requires run persistence later. | No save/load persistence exists. | Missing | Leave implementation for P2:R6, but preserve run-state structure during R2-R5. |
| Training Room | Freeform mechanics lab controls trees, passives, gear, target, duration, seed, and practice gold. | Training Room button is disabled; no Godot Training Room scene exists. | Missing | Decide during R1 whether this is Phase 2 parity support or Phase 3+; if Phase 2, scope a compact version. |
| UI architecture direction | Phase 1 React UI was tool-like; Project Bane should be more game-like. | Dashboard direction intentionally replaces retired wizard screens. | Revised | Keep dashboard as Project Bane's UI direction; reconnect flow into it instead of restoring the old wizard. |
| UI clarity/onboarding | Player can read next target, build state, rewards, and next action without outside explanation. | Dashboard has core panels but no full progression/reward/route context and default styling remains. | Partial | P2:R7 should polish layout, hierarchy, copy, and onboarding after flow parity is restored. |
| Larger game scope | Phase 1 parity covers first Rogue adventure only. | Additional classes/contracts/procedural meta-run are not implemented. | Deferred | Keep additional classes, extra contracts, broad procedural map, and full art/polish in Phase 3+. |

## P2:R1:T4 - Identify Mechanics Gaps

Track missing or incomplete rule/system behavior separately from UI work.

### P2:R1:T4 Output - Mechanics Gaps

Mechanics already active enough to treat as parity foundations:

- Fixed-window combat resolution is active: looping rotations, cast cutoff,
  attack-speed timing, win/loss by total damage, DPS calculation, and poison
  ending at the combat window are implemented in `CombatResolver` and
  `CombatTiming`.
- Physical damage, crit rolls, armor mitigation/vulnerability, poison damage,
  poison resistance mitigation, poison stack cap, and persistent armor
  reduction are implemented in `DamageCalculator` and `CombatResolver`.
- Adventure passive allocation rules are implemented in `PassiveAllocator`:
  `7` point budget, max `2` trees, duplicate rejection, selected-tree
  membership, OR-prerequisite groups, and dependent-lock removal.
- Build resolution applies class stats, tree innate modifiers, selected
  talent modifiers, and gear modifiers in weapon/trinket/charm order, then
  filters rotation to unlocked skills.
- Generated Basic/Master/Cursed gear affix counts, current combat affix
  magnitudes, and tier prices are implemented in `GearGenerator`.

Mechanics gaps to carry into the revised roadmap:

| Gap | Phase 1 Expected Behavior | Current Godot State | Classification | Likely Owner | Notes / Required Work |
|---|---|---|---|---|---|
| Run-level encounter progression | Adventure advances through Tavern fights, contract route choices, Knives, then Vyra. | `RunFlow` and `BuildState.current_encounter_index` exist, but the active dashboard always fights fixed Mouthy Drunk. | Dormant / Partial | P2:R2, P2:R4 | Reconnect run state to the dashboard, then replace the old five-fight ladder with Tavern plus first contract route state. |
| Reward claim rules | Encounter rewards grant gold, talent points, fixed item IDs, generated gear choices, and Legendary choices at authored timings. | `Encounter` only stores `gold_reward` and `is_boss`; active dashboard has no reward-claim state machine. | Partial | P2:R3, P2:R4 | Add data/resource support for reward types and a single claim path so later UI can present rewards without encoding rules in controls. |
| Earned talent point timing | Talent points are awarded by specific Tavern and contract rewards. | `PassiveAllocator` supports a fixed `7` point budget; the dashboard exposes that full budget up front. | Partial | P2:R2 / P2:R3 | Keep the final budget cap, but add run-owned available talent points and award them from encounters. |
| Secondary subclass timing | Player chooses a primary tree at Adventure start and a secondary Rogue tree after Hired Goon before the contract. | `BuildState.toggle_tree()` and `PassiveAllocator.MAX_TREES = 2` support two trees; active flow uses `select_tree()` for exactly one tree. | Partial | P2:R2 | Add a run milestone flag and mechanics for unlocking the second tree after Tavern completion. |
| Failure/do-over/restart rules | First failure on a given encounter returns to build editing; second failure restarts Adventure from class selection while preserving seed. Contract route failures mark contract failed. | Active dashboard resolves a fight but does not track per-encounter failures, do-overs, seed-preserving restart, or contract failure state. | Missing | P2:R5 | Add failure counters keyed by run encounter/route node, plus restart semantics that reset build/run progress while keeping the Adventure seed. |
| Adventure seed state | Adventure seed defaults to `1`, is displayed, and drives combat/reward reproducibility. | `CombatResolver.resolve()` accepts `rng_seed`, defaulting to `1`, but `BuildState` has no Adventure seed and UI does not pass a run seed through active fights. | Partial | P2:R5 | Store Adventure seed in run state and thread it through combat, reward generation, shop generation, and reports. |
| Contextual seeded gear generation | Shop and reward gear are seeded from run, contract, route, slot, tier, and option context. | `GearGenerator.generate_offers(count, rng_seed)` supports deterministic batches, but the dashboard gear panel uses unseeded random gear and the seed has no run/route context. | Partial | P2:R3, P2:R5 | Define stable seed derivation for shop round, reward choice, route node, tier, slot, and option index. |
| Shop round rules | Shop unlocks after Drunk Buddy, shows four offers, and allows one reroll per round. | Dormant shop exists, but mechanics are not active in the dashboard; generator API can produce any count but old shop used three offers. | Dormant / Partial | P2:R3 | Add shop-round state: unlocked flag, four offer slots, reroll-used flag, deterministic offer seed, buy/equip/continue rules. |
| Gold reward modifiers | Equipped Gold Rewards affixes compound multiplicatively, then rewards are rounded and clamped to `0+`. | `StatModifier.GOLD_REWARDS` exists but is intentionally ignored by `BuildResolver`; `GearGenerator` excludes it from generated affixes. | Missing | P2:R3 | Keep it out of combat stats, but add reward-resolution logic and include Gold Rewards in eligible generated gear affixes where appropriate. |
| Inventory and retained item choice | Gear choices and shop purchases persist across the run; equipped slots are a subset of owned/available gear. | `BuildState` stores only equipped weapon/trinket/charm, with no inventory or pending reward choice state. | Missing | P2:R3 | Add minimal run inventory and reward-choice mechanics before wiring fixed/Legendary rewards. |
| Triggered skills | Triggered skills resolve immediately and do not consume cast time. Opportunity Strikes and Mithril Karambit use this rule. | No trigger effect schema or combat resolver branch exists. | Missing | P2:R3 / P2:R4 | Add data-driven trigger definitions, deterministic trigger RNG, immediate resolution, and event logging without advancing cast time. |
| Poison resistance reduction | Effects can reduce current poison resistance for later poison ticks; negative resistance does not increase damage. | Poison resistance mitigation exists, but combat has no mutable current resistance or resistance-reduction effect schema. | Missing | P2:R4 | Add a poison-resistance-reduction `SkillEffect`, track current resistance during combat, and apply reductions before later ticks. |
| Poison tick cadence modifiers | Wyvern Kriss can make poison tick twice as fast. | `CombatResolver.POISON_TICK_INTERVAL_MS` is a fixed `1000ms` constant. | Missing | P2:R4 | Move tick cadence into resolved combat stats or gear-derived combat config so Legendary gear can alter it. |
| Minimum execution time proc | Bejeweled Push Dagger gives normal casts a seeded chance to use minimum execution time. | Timing formula respects `min_execution_ms`, but no proc can choose minimum execution time before the normal attack-speed formula. | Missing | P2:R4 / P2:R5 | Add gear/proc schema and deterministic per-cast RNG, then log proc outcomes for reproducibility. |
| Gold-scaled physical damage | Bandit Blade adds physical damage based on current gold. | Build resolution does not pass current gold into gear modifier resolution, and `StatModifier` cannot express gold-scaling formulas. | Missing | P2:R4 | Add a data-driven special modifier or gear behavior that can read current gold without hardcoding the item in combat logic. |
| Skill unlocks from gear | Gear can unlock skills, such as Umbral Stiletto unlocking Death Strike. | `BuildState.unlocked_skills()` checks class, trees, and talents only; `GearItem` has no unlocked-skill field. | Missing | P2:R4 | Extend gear schema and unlocked-skill resolution so equipment can add usable skills and rotation filtering sees them. |
| Shadow innate poison | If Shadow is one of the chosen trees, Stab and Heavy Slash apply `+1` poison stack. | Tree innate stat modifiers exist, but there is no mechanic for tree-specific skill-effect augmentation. Shadow data is not seeded. | Missing | P2:R4 | Shadow is Phase 2 parity per T7. Add data-driven conditional skill modifiers or innate tree effects. |
| Death Strike poison-stack scaling | Death Strike deals bonus physical damage per current poison stack. | Combat effects are static physical, poison application, or armor reduction; no effect can read active poison stacks at cast time. | Missing | P2:R4 | Needed for Shadow and Umbral Stiletto parity, both retained for Phase 2's first Rogue Adventure. |
| Contract route mechanics | Door Guard/Portly Cook branch into second-layer choices, converge at Knives, then Vyra; route choice affects reward quality. | `RunFlow` is a fixed linear path and old comments still mark branching as Phase 3 historical scope. | Missing / Revised | P2:R4 | Under the 2026-07-15 revision, the first Phase 1 route is Phase 2 scope; implement authored route state without expanding into a procedural map. |
| Contract victory/failure state | Defeating Vyra marks contract victory; route failure marks contract failed. | `Encounter.is_boss` exists, but active dashboard has no full run outcome state beyond overlays. | Missing | P2:R4 / P2:R5 | Add explicit run outcome enum/state for tavern in progress, contract in progress, contract failed, and contract victory. |
| Training Room mechanics | Training Room uses the same resolver/simulator with freeform active trees, passives, gear, target, duration, seed, and practice gold controls. | Title button is disabled and no separate training run state or target/duration/gear controls exist. | Missing | Phase 3+ | Full Training Room mode is deferred by T7. Keep shared resolver/simulator test coverage in Phase 2, but do not build the player-facing lab unless scope is explicitly revised. |
| Save/load-ready run state | Revised Phase 2 later requires run persistence across sessions. | State is stored in `BuildState` as object references and transient values; no serialization contract exists. | Missing | P2:R6, but shaped by P2:R2-R5 | When adding run/reward/route/failure mechanics, prefer stable resource IDs and plain serializable state so P2:R6 does not require a state rewrite. |

Mechanics deliberately left for T5/T6/T7 instead of this task:

- Missing Shadow, contract monsters, Knives, Legendary items, authored starter
  gear, fixed reward items, and Training Room targets are content gaps for
  `P2:R1:T5`.
- Dashboard placement for rewards, shop, route choice, failure, run end, and
  Training Room is UI/flow work for `P2:R1:T6`.
- `P2:R1:T7` decided that Shadow remains Phase 2 parity while full Training
  Room mode is deferred to Phase 3+.

## P2:R1:T5 - Identify Content Gaps

Compare Phase 1 content references against Godot data:

- Rogue starter stats.
- Skills.
- Assassin, Thief, and Shadow talents.
- Tree innate modifiers and unlocked skills.
- Generated gear affixes.
- Authored starter gear.
- Legendary gear.
- Monsters.
- Tavern encounters.
- Contract nodes and rewards.
- Training Room targets.

### P2:R1:T5 Output - Content Gaps

Content already active enough to treat as parity foundations:

- Rogue exists as the only playable class data resource, with Mage and
  Crusader intentionally represented only as disabled UI options.
- Rogue starter stats match the Phase 1 baseline: `0` attack speed, `15%`
  crit chance, `2x` crit multiplier, and `8` poison damage per tick.
- Six Phase 1 Rogue skills exist as data resources with matching timing and
  basic effects: Stab, Quick Cut, Heavy Slash, Venom Jab, Poison Strike, and
  Rending Slash. Rending Slash uses the historical Phase 1 internal ID
  `skill.rending_thrust`.
- Assassin and Thief subclass tree resources exist, with all five Phase 1
  talents for each tree seeded as data resources.
- Thief's tree-level Quick Cut unlock and the talent-based Venom Jab,
  Poison Strike, and Rending Slash unlocks are represented in data.
- Tavern monsters exist with Phase 1 stat blocks: Mouthy Drunk, Drunk Buddy,
  Tavern Bouncer, and Hired Goon.
- Tavern encounter resources exist with Phase 1 combat windows and gold
  rewards.
- Vyra exists as a monster resource and as a boss encounter resource with the
  Phase 1 stat block, window, and `120g` reward.
- Generated Basic/Master/Cursed gear tier structure, affix magnitudes, and
  prices match the Phase 1 generated gear table for combat-relevant affixes.

Content gaps to carry into the revised roadmap:

| Content Area | Phase 1 Expected Content | Current Godot Data | Classification | Likely Owner | Notes / Required Work |
|---|---|---|---|---|---|
| Playable classes | Rogue playable; Mage and Crusader unavailable. | Rogue is seeded and active; Mage/Crusader are disabled static UI options, not data resources. | Active / Revised | None for Phase 2 | This matches the revised Phase 2 boundary; do not seed additional classes in Phase 2 unless scope changes. |
| Rogue starter stats | `0` attack speed, `15%` crit, `2x` crit multiplier, `8` poison damage per tick. | `rogue_starter.tres` matches these values. `placeholder_player.tres` also remains for tests. | Active | None | Placeholder data is acceptable as test support, but implementation should use `rogue_starter.tres` for Adventure. |
| Base Rogue skills | Stab and Heavy Slash are base class skills. | `rogue.tres` grants Stab and Heavy Slash. | Active | None | Matches the current active one-tree dashboard model. |
| Assassin skills and talents | Assassin has Venom Edge, Precise Cuts, Lethal Intent, Toxic Technique, Perfect Toxin; unlocks Venom Jab and Poison Strike through talents. | All five talents are seeded with costs, prerequisites, modifiers, and unlocks. | Active | None | Content is present. Any remaining issues are mechanics/UI timing rather than content inventory. |
| Thief skills and talents | Thief has Quick Hands, Piercing Blades, Practiced Rhythm, Opportunity Strikes, Sunder; tree grants Quick Cut; Piercing Blades unlocks Rending Slash. | Tree and all five talents are seeded. Quick Hands, Piercing Blades, Practiced Rhythm, and Sunder have data-backed stat effects. | Partial | P2:R3 / P2:R4 | Opportunity Strikes exists as a talent shell but has no trigger payload because triggered-skill mechanics and trigger schema are missing. |
| Shadow tree | Shadow tree, five talents, Beguiling Strike, Death Strike, and innate poison behavior. | No Shadow tree resource, talent resources, Beguiling Strike, or Death Strike data. Shadow appears only as a disabled static UI option. | Missing | P2:R4 | T7 keeps Shadow in Phase 2 parity. Seed content after mechanics for poison resistance reduction, stack-scaling damage, and tree-specific skill augmentation are scoped. |
| Tree innate modifiers | Shadow grants Stab and Heavy Slash `+1` poison stack; other tree identities come from unlocks/talents. | `SubclassTree` supports `innate_modifiers`, but no data expresses Shadow's skill-effect augmentation. Assassin and Thief do not need special innate stat modifiers for current parity content. | Missing / Partial | P2:R4 | Shadow innate cannot be represented as a simple stat modifier without changing skill effects globally. Needs a data-driven conditional skill modifier. |
| Generated gear affixes | Basic/Master/Cursed table includes attack speed, crit chance, crit multiplier, poison damage, physical damage, poison stacks, armor reduction, and Gold Rewards. | Generator includes all listed combat affixes with correct tier magnitudes and prices, but excludes Gold Rewards from the affix pool. | Partial | P2:R3 | Add reward-only Gold Rewards affixes once reward resolution supports them. Keep them out of combat stat resolution. |
| Authored starter gear | Swift Dagger, Keen Stiletto, Venom Knife, Lucky Coin, Razor Token, Quicksilver Charm, Toxic Vial, Cutthroat Seal, Fleet Wrap. | Only `placeholder_dagger.tres` exists as a test/placeholder gear resource. No Phase 1 authored starter gear is seeded. | Missing | P2:R3 | Seed these as authored `GearItem` resources or explicit reward/shop entries once inventory and reward choice flow are restored. Lucky Coin is specifically needed by Drunk Buddy reward parity. |
| Legendary gear | Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril Karambit, Bejeweled Push Dagger. | No authored Legendary gear resources exist, and `GearItem.Tier` has no Legendary enum value. | Missing | P2:R4 | Requires schema support for Legendary tier and special behaviors: tick cadence, gold-scaled damage, gear skill unlocks, triggered skills, and minimum-cast procs. |
| Tavern monsters | Mouthy Drunk, Drunk Buddy, Tavern Bouncer, Hired Goon. | All four exist with matching HP, armor, and poison resistance. | Active | P2:R2 | Data is present, but active dashboard only consumes fixed Mouthy Drunk until run flow is reconnected. |
| Tavern encounters | Four Tavern encounters with windows, gold, talent point rewards, Lucky Coin reward, shop unlock, and secondary-tree/contract hook. | Five encounter resources exist: the four Tavern fights plus direct Vyra. Encounter schema only stores monster, duration, gold reward, and boss flag. | Partial | P2:R2 / P2:R3 | Windows and gold are seeded. Talent point rewards, fixed item rewards, shop unlocks, secondary-tree unlock, and contract hook are not representable in encounter data yet. |
| Contract route monsters | Door Guard, Portly Cook, Sleeping Henchman, Cloaked Watchmen, Lazy Henchman, Patrolling Guard, Knives, Vyra. | Vyra exists. Door Guard, Portly Cook, Sleeping Henchman, Cloaked Watchmen, Lazy Henchman, Patrolling Guard, and Knives are missing. | Missing | P2:R4 | Seed authored monsters with Phase 1 stat blocks when first contract route data is added. |
| Contract route nodes | The Gilded Serpent route choices with authored windows, rewards, gear-choice qualities, convergence at Knives, then Vyra. | No contract resource, route-node resources, branch definitions, or contract encounter resources exist. Vyra is currently a direct boss encounter from the old linear ladder. | Missing | P2:R4 | Add an authored first-contract route model without expanding into a broad procedural contract system. |
| Contract rewards | Route rewards include gold, talent points, Basic/Master/Cursed generated gear choices, and Knives Legendary choice. | No data representation for reward choices, gear-choice slots/tiers, Legendary choices, or route-depth reward quality. | Missing | P2:R3 / P2:R4 | Define reward payload data before seeding route nodes so rewards do not live in UI logic. |
| Training Room targets | Training Dummy, Armored Guard, Venom-Resistant Slime. | Placeholder Dummy exists with Training Dummy-like stats but Phase 1 target IDs/names are not seeded. Armored Guard and Venom-Resistant Slime are missing. | Missing / Partial | Phase 3+ | T7 defers full Training Room mode. Keep placeholder/test targets where useful, but do not seed the player-facing Training Room target set for Phase 2. |
| Placeholder/test content | Phase 1 content reference has no placeholder class/skills/gear/monster. | Placeholder Dummy, Placeholder Strike, Placeholder Quick Cut, Placeholder Dagger, and Placeholder Player remain. | Revised | None | Keep as test fixtures where useful, but avoid exposing placeholder content in the active Adventure flow. |

Content items deliberately left for later R1 tasks instead of this task:

- T7 decided Shadow is Phase 2 parity and full Training Room mode is Phase 3+.
- Where rewards, inventory, contract route choice, Legendary selection, and
  Training Room controls live in the dashboard is T6 UI/flow work.
- The order for seeding missing content is T8 roadmap work, after T6 and T7
  settle flow and scope decisions.

## P2:R1:T6 - Identify UI/Flow Gaps

Compare the Phase 1 play experience and the intended game-like dashboard:

- How Tavern/shop/rewards fit into the dashboard.
- How route choice should be presented.
- How fight results and reward choices should flow.
- How build editing between fights should work.
- What enemy/build information must be visible before locking a fight.
- What a new player needs to understand without outside explanation.
- Which dormant wizard-era screens should be deleted, reconnected, or
  replaced.

### P2:R1:T6 Output - UI/Flow Gaps

Current UI direction to preserve:

- The persistent combat dashboard is the intended Project Bane presentation
  layer. It should remain the primary play surface for build editing, enemy
  reading, fight launching, combat feedback, gear decisions, rewards, and run
  progression.
- The old wizard flow should not be restored as the main structure. Dormant
  pieces from that flow should be mined for behavior and state transitions,
  then re-expressed as dashboard panels, overlays, or focused route/reward
  choice views.
- Full-screen transitions are still appropriate for major run boundaries:
  title, class selection, first subclass selection, contract offer/acceptance,
  secondary subclass selection if it needs extra ceremony, and final run
  victory/defeat.

Active dashboard flow gaps:

| Flow Area | Phase 1 / Revised Phase 2 Need | Current Godot UI State | Classification | Likely Owner | Notes / Required Work |
|---|---|---|---|---|---|
| Adventure header and run context | Adventure displays the active run seed and communicates the current run/phase. | `game_root.gd` routes title -> class -> subclass -> dashboard. `combat_screen.gd` has only a Return to Main Menu top bar. No seed, phase, encounter number, gold, contract, or route status is visible globally. | Missing | P2:R5 / P2:R7 | Add a compact run header/status strip once seed/run state exists: seed, current phase, encounter, gold, and next decision. |
| Encounter progression | Tavern fights progress Mouthy Drunk -> Drunk Buddy -> Tavern Bouncer -> Hired Goon before contract. | `enemy_panel.gd` hardcodes Mouthy Drunk and `12s`; `RunFlow`, encounter resources, and `BuildState.current_encounter()` are dormant. | Dormant / Missing | P2:R2 | Replace fixed enemy panel data with current encounter state. Show upcoming fight identity, HP, armor, poison resist, window, and reward preview before lock/fight. |
| Fight readiness | Player edits build, locks it, then fights the currently selected encounter. | `skill_build_panel.gd` supports lock/unlock and empty-rotation gating. Fight button is gated by lock. Build changes clear the lock. | Active / Partial | P2:R2 | Preserve this interaction, but make the lock refer to the current encounter. Unlock automatically after fight resolution and after reward/shop changes. |
| Fight result flow | Fight result leads to reward claim, do-over, run failure, contract failure, or victory depending on encounter state. | `combat_screen.gd` updates a status line, enables combat log, and shows a victory recap overlay. Loss only writes `LOSS`; victory overlay Continue only dismisses the overlay. | Partial | P2:R2 / P2:R5 | Add explicit post-fight states. Continue should advance to reward/failure/route outcome, not just hide the banner. Loss needs do-over/retry messaging and later restart/contract-failed routing. |
| Combat log and recap | Players can inspect deterministic combat details and understand why the build passed or failed. | Log overlay and victory recap overlay exist. No loss recap overlay, no reward preview, and no comparison to required DPS or target pressure. | Partial | P2:R2 / P2:R7 | Keep log overlay. Add a loss/near-miss recap and target pressure hints such as required DPS, damage split, biggest hit, casts completed, and mitigation profile. |
| Reward claim | Encounter rewards can grant gold, talent points, fixed gear, and gear choices. Rewards should be claimed before the next planning step. | No active reward UI. `BuildState.add_gold()` exists. Current victory overlay has no reward claim semantics. | Missing | P2:R3 | Add a reward overlay/panel after winning fights. It should display gold, talent points, fixed item rewards, and any gear-choice payloads before returning to planning. |
| Talent point timing | Talent points are earned during the run, especially Tavern rewards and contract nodes. | Talent panel always uses the full `7` point budget via `PassiveAllocator.POINT_BUDGET`; no earned point display or reward-timed unlock exists. | Partial | P2:R2 / P2:R3 | UI needs available/spent/earned talent point state, not only remaining out of 7. Talent panel should support growing budget between fights. |
| Build editing between fights | Player can revise talents, rotation, and equipment after rewards and before the next fight. | Dashboard supports live talent, rotation, stats, and gear changes, but the only active enemy is fixed and gear is auto-rerolled. | Active / Partial | P2:R2 / P2:R3 | This is the right surface for between-fight planning. Reconnect it to encounter progression and remove free reroll behavior once rewards/shop/inventory own item acquisition. |
| Gear equipment and inventory | Gear is retained, equipped/unequipped, bought in shop, and chosen from rewards. | `gear_panel.gd` shows a paper doll and empty inventory placeholder, but auto-rolls weapon/trinket/charm on dashboard entry and exposes a free Reroll Gear button. | Partial / Revised | P2:R3 | Keep the paper-doll direction. Replace auto-roll/reroll with inventory, equip/unequip, reward choices, shop purchases, and item tooltips. Helm/armor dummy slots should remain disabled/future-facing or be hidden if they confuse Phase 2. |
| Tavern shop | Shop unlocks after Drunk Buddy, shows four generated items, one reroll, prices, buying, and gear management. | `scenes/tavern/shop.gd` is dormant, full-screen, shows three offers, fixed seed, buy/equip, unequip, Continue, and no one-reroll rule. | Dormant / Partial | P2:R3 | Rebuild as a dashboard overlay or right-side shop mode rather than reviving it as a full-screen replacement. Use four offers, one reroll, seeded generation, price visibility, buy-to-inventory or buy-and-equip choice, and Continue back to dashboard. |
| Gold visibility and spend feedback | Gold is a run currency affected by rewards, shop, and Gold Rewards affixes. | `BuildState.gold` exists but active dashboard does not show gold. Dormant shop shows gold locally. | Missing / Dormant | P2:R3 / P2:R7 | Add gold to the run header and shop/reward UI. Later show modified reward calculation when Gold Rewards gear is equipped. |
| Secondary subclass selection | After Hired Goon, player chooses a secondary Rogue subclass before the contract. Adventure builds support up to two active trees. | `subclass_select.gd` chooses exactly one tree before dashboard. `BuildState.toggle_tree()` and `PassiveAllocator.MAX_TREES = 2` exist, but no active UI exposes second-tree timing. | Dormant capability / Missing flow | P2:R4 | T7 keeps secondary-tree choice as Phase 2 parity. Add a post-Tavern choice moment without making initial character creation imply both trees are chosen at start. |
| Contract offer and hook | After Tavern, player accepts The Gilded Serpent Contract and understands the target is Vyra. | No contract offer UI. Current dormant `RunFlow` jumps from Hired Goon directly to Vyra, reflecting older M5 scope. | Missing | P2:R4 | Add contract offer/acceptance state with target, stakes, and first route choice preview. This is a good full-screen or large dashboard overlay moment. |
| Route choice presentation | Contract starts with Door Guard or Portly Cook, then second-layer choices, then Knives, then Vyra. Route choices communicate difficulty and reward quality. | No route UI or route-node resources. Active dashboard has no choice state. | Missing | P2:R4 | Add route choice views that show enemy stats, window, route label, and reward quality side by side. Keep it authored for the first contract rather than a general procedural map. |
| Elite and Legendary reward moment | Knives rewards a Legendary weapon choice before Vyra. | No Legendary gear tier/UI and no reward-choice UI. | Missing | P2:R4 | Treat Knives reward as a major choice overlay with clear item behavior text and equip impact. This should feel more important than a normal shop offer. |
| Run end states | Vyra victory marks contract victory; repeated failure or contract failure ends/restarts the run. | `scenes/build_planner/run_end.gd` is dormant and minimal. Active dashboard has no final victory/defeat routing. | Dormant / Missing | P2:R5 / P2:R8 | Replace or restyle `run_end` for the dashboard era. It needs contract victory, contract failed, adventure restarted, and restart/new run actions. |
| Failure and retry | First failure on an Adventure encounter gives a do-over; second failure restarts while preserving seed. Contract route failures mark contract failed. | No active failure state beyond dashboard status text. No failure count per encounter. | Missing | P2:R5 | UI must explain "do-over available" versus "run failed" clearly. This should be visible immediately after a loss and before returning to build editing. |
| Adventure seed controls | Adventure seed is displayed and controls combat/shop/reward determinism. | No seed UI or Adventure seed state. Gear panel uses unseeded `randomize()`. Dormant shop uses fixed placeholder seed `1`. | Missing | P2:R5 | Add seed display/input before run start or in title/adventure setup. Header should display active seed during run. |
| Save/load affordance | Later Phase 2 requires quitting and resuming mid-run. | Return to Main Menu warns current build will be lost. State uses transient resource references. | Missing | P2:R6 | Once persistence exists, menu text and actions should distinguish abandon run, save and quit, resume, and new run. |
| Training Room | Phase 1 has a freeform mechanics lab with target/window/gear/seed controls. | Title screen shows Training Room as disabled; no active training UI exists. | Deferred | Phase 3+ | T7 defers full Training Room mode. Preserve shared engine tests and leave the disabled title affordance only if it does not confuse the Phase 2 playtest. |
| New-player guidance | Player should understand class, subclass, talents, skills, enemy, gear, rewards, and next action without developer explanation. | Dashboard has functional labels and tooltips, but no run-phase guidance, reward previews, target-pressure explanation, or disabled-state explanation beyond some tooltips. | Partial | P2:R7 | Add concise contextual status/next-action copy inside existing panels. Avoid tutorial walls; use panel headers, disabled-button tooltips, reward previews, and combat recap cues. |

Dormant screen decisions:

- `RunFlow` and encounter resources should be reconnected for P2:R2, but the
  old fixed `Mouthy Drunk -> Drunk Buddy -> Tavern Bouncer -> Hired Goon ->
  Vyra` ladder must be revised before P2:R4 because the revised scope requires
  the authored first contract route rather than direct Tavern-to-Vyra flow.
- `scenes/tavern/shop.gd` should be replaced or heavily refit as a dashboard
  shop overlay/panel. Its buy/equip/gold mechanics are useful, but its
  full-screen presentation, three-offer count, fixed seed, and no-reroll rule
  do not match Phase 1 parity.
- `scenes/build_planner/run_end.gd` should be replaced or restyled. It is too
  thin for revised run outcomes, but its restart signal pattern can inform the
  dashboard-era run-end view.
- Deleted wizard-era class/talent/rotation/pre-fight screens should stay
  retired. Their responsibilities now belong to the active title/class/
  subclass/dashboard structure.

Recommended UI/flow build order implied by this audit:

1. P2:R2 should reconnect the dashboard to current encounter progression:
   active encounter panel, post-fight state, Continue behavior, reward stub,
   next-fight planning, and basic run end routing.
2. P2:R3 should replace free gear rerolling with reward, inventory, shop,
   gold, and equipment decisions in dashboard-native overlays/panels.
3. P2:R4 should add the contract offer, secondary subclass moment if kept,
   authored route choices, Knives, Legendary reward choice, and Vyra through
   the same dashboard progression model.
4. P2:R5 should layer seed UI, deterministic run-context RNG, failure/do-over,
   contract failure, and final victory/defeat state transitions over that
   flow.
5. P2:R7 should be the main clarity and presentation pass after the flow is
   real, not before; otherwise polish work will chase moving targets.

## P2:R1:T7 - Decide Revised/Cut Items

For each mismatch, decide one of:

- Port as Phase 2 parity.
- Keep but revise for Project Bane.
- Cut from Project Bane.
- Defer to Phase 3+ and record in `phase3_ideas.md`.

Document the reason for each revision or deferral.

### P2:R1:T7 Output - Revised/Cut/Deferred Decisions

Scope principle for these decisions:

- Phase 2 should restore the **Phase 1 Rogue Adventure** from character
  creation through Tavern, The Gilded Serpent route, Knives, and Vyra.
- Phase 2 should not restore every Phase 1 support surface if it is not needed
  for the downloadable Adventure playtest.
- Project Bane may change presentation and interaction flow where the Godot
  dashboard is the better game UI, as long as the underlying Adventure
  decisions and rules remain legible and testable.

| Item | Decision | Phase 2 Owner | Reason |
|---|---|---|---|
| Persistent dashboard replacing Phase 1's tool-like/wizard presentation | Keep as Project Bane revision | P2:R2-R7 | The dashboard is the intended game-like UI direction. Reconnect flow into it instead of restoring the old React/wizard sequence. |
| Rogue as the only playable class | Phase 2 parity | Existing / P2:R7 polish | Phase 1 Adventure was Rogue-only. Rogue remains the complete Phase 2 class target. |
| Mage and Crusader | Defer to Phase 3+ | None in Phase 2 | They were unavailable in Phase 1 and are outside the first Rogue Adventure parity target. Keep them disabled/future-facing only if useful for menu context. |
| Assassin and Thief | Phase 2 parity | Existing / P2:R2-R5 | Both are already seeded enough to support the Adventure loop, with remaining gaps tied to run flow, rewards, and triggered-skill behavior. |
| Shadow subclass | Phase 2 parity, but later than dashboard reconnection | P2:R4 | Shadow was a real Phase 1 Rogue tree and part of primary/secondary tree choice. Keep it in Phase 2, but implement after prerequisite mechanics are scoped: poison resistance reduction, conditional skill poison application, Death Strike-style stack scaling, and multi-tree UI. |
| Secondary subclass selection after Tavern | Phase 2 parity | P2:R4 | The contract hook depends on choosing a second Rogue tree after Hired Goon. This should be restored as a dashboard-era choice moment, not moved to initial character creation. |
| Upfront full `7` talent point budget | Revise back toward Adventure reward timing | P2:R2-R3 | The upfront budget is useful for current dashboard testing, but Adventure parity needs earned talent points from Tavern and contract rewards. Training/test tooling may keep full-budget shortcuts later. |
| Current fixed Mouthy Drunk dashboard fight | Temporary implementation state, replace for parity | P2:R2 | The active dashboard must consume run encounter state and progress through the Tavern instead of fighting one hardcoded target. |
| Dormant `RunFlow` five-encounter ladder | Reconnect, then revise | P2:R2 / P2:R4 | Reuse it to restore Tavern progression first, then replace the direct Tavern-to-Vyra path with the authored contract route. |
| Reward claim flow, inventory, shop, and gear decisions | Phase 2 parity | P2:R3 | These are core Adventure loop decisions, not optional polish. Present them in dashboard-native overlays/panels rather than the dormant full-screen shop. |
| Free dashboard gear auto-roll/reroll | Cut from Adventure; keep only as possible test/dev affordance | P2:R3 | Free gear rerolling bypasses rewards, shop, gold, and inventory. Adventure should acquire gear through rewards and shops. |
| Authored starter gear and fixed rewards | Phase 2 parity | P2:R3 | Lucky Coin and starter gear choices are part of Tavern progression and are needed before the contract route feels like the Phase 1 run. |
| Generated Basic/Master/Cursed gear and Gold Rewards affix | Phase 2 parity | P2:R3 | Generated gear already has a foundation. Gold Rewards should be restored as a reward modifier, not a combat stat. |
| Authored Legendary weapons | Phase 2 parity for Knives reward set | P2:R4 | The Legendary choice before Vyra is a major contract payoff and balance pivot. Implement only the Phase 1 Legendary set needed for this route. |
| Triggered skills, gear skill unlocks, poison cadence changes, minimum-time procs, gold-scaled damage | Phase 2 parity where required by Phase 1 Rogue Adventure items | P2:R4-R5 | These mechanics are needed for Opportunity Strikes and Legendary parity. Implement them generically/data-driven, not as hardcoded item exceptions. |
| The Gilded Serpent contract route | Phase 2 parity | P2:R4 | The first contract route is now explicitly in revised Phase 2 scope. Keep it authored and narrow rather than turning it into a procedural map. |
| Additional contracts beyond The Gilded Serpent | Defer to Phase 3+ | None in Phase 2 | Additional contracts expand content breadth beyond the first proven run. Record in `phase3_ideas.md`. |
| Broader procedural/meta Contract Run system | Defer to Phase 3+ | None in Phase 2 | Phase 2 needs the authored first route, not a general route-generation/meta-progression layer. Record in `phase3_ideas.md`. |
| Failure/do-over/restart rules | Phase 2 parity | P2:R5 | These rules are part of Adventure pacing and seeded reproducibility. Restore first-failure do-over and second-failure restart/contract-fail behavior. |
| Adventure seed UI and deterministic run-context RNG | Phase 2 parity | P2:R5 | Seeded Adventure reports were a Phase 1 success criterion. Active combat, shop, rewards, and proc RNG should derive from visible run context. |
| Save/load persistence | Project Bane addition beyond Phase 1, keep in Phase 2 | P2:R6 | Revised Phase 2 still requires a shareable build that can quit and resume. R2-R5 should shape state so persistence is not a rewrite. |
| Training Room | Defer full mode to Phase 3+; allow optional Training Room Lite in P2:R8 if low-risk | Optional P2:R8 stretch/support task only | Training Room was useful in Phase 1, but the revised Phase 2 definition of done is the complete Rogue Adventure. A full freeform lab would compete with Adventure, reward, route, seed, and UI work. A compact practice mode may be added late for playtest support if it does not delay the Adventure build. Record full Training Room in `phase3_ideas.md`. |
| Training Room targets | Defer with Training Room | None in Phase 2 | Training Dummy-like placeholder content may remain for tests, but Armored Guard and Venom-Resistant Slime do not need player-facing Phase 2 Adventure UI. |
| Placeholder/test resources | Keep as hidden test fixtures | Existing tests | Placeholder content should not appear in the Adventure path, but it remains useful for focused engine tests. |
| Full art/animation/polish production | Defer to Phase 3+ | None in Phase 2 | P2:R7 should improve clarity, hierarchy, and playtest readability, not become a full production art pass. Record in `phase3_ideas.md`. |
| Extra platform breadth beyond Windows desktop | Defer to Phase 3+ unless low-effort | P2:R8 only if cheap | Windows desktop is the minimum shareable target. Web or additional platforms should not delay the Rogue Adventure build. |

No items are currently cut from Project Bane entirely. The main cuts are from
the **Phase 2 Adventure path**: free dashboard gear rerolling as player power,
the old wizard/full-screen flow as the primary UI structure, and full Training
Room scope.

## P2:R1:T8 - Produce Implementation Roadmap

Turn the audit findings into a build order for the revised roadmap:

- P2:R2 - Dashboard Loop Reconnection.
- P2:R3 - Reward, Shop, And Gear Parity.
- P2:R4 - Contract Route Parity.
- P2:R5 - Run Rules And Determinism.
- P2:R6 - Save/Load Persistence.
- P2:R7 - Game-Like UI Pass.
- P2:R8 - Playtest Build.

The output should be specific enough that implementation can begin without
re-litigating scope.

### P2:R1:T8 Output - Revised Implementation Roadmap

This audit does not require new tracking documents. The milestone-specific
task files for `P2:R2` through `P2:R8` already exist and should remain the
working plans for implementation. The build order below is the compact
roadmap distilled from the parity matrix, gap lists, and revised/cut
decisions above.

1. `P2:R2 - Dashboard Loop Reconnection`
   - Reconnect the active dashboard to run encounter state instead of the
     hardcoded Mouthy Drunk panel.
   - Use the existing Tavern encounter resources and dormant `RunFlow` /
     `BuildState.current_encounter()` foundation to prove dashboard-era
     progression.
   - Add post-fight states, Continue behavior, a temporary reward
     acknowledgement if needed, and a simple run-end path.
   - Keep rewards/shop/gear parity deliberately stubbed; that belongs to
     `P2:R3`.

2. `P2:R3 - Reward, Shop, And Gear Parity`
   - Replace Adventure-facing free gear auto-roll/reroll with earned rewards,
     inventory, equipment, gold, and shop decisions.
   - Extend reward data to support gold, talent points, fixed items, generated
     gear choices, shop unlocks, and Gold Rewards modifiers.
   - Refit or replace the dormant shop as a dashboard-compatible flow with
     four offers, prices, one reroll, buying, equip/unequip, and continuation.
   - Restore reward-timed talent point growth enough for the Tavern loop.

3. `P2:R4 - Contract Route Parity`
   - Add The Gilded Serpent contract offer, secondary Rogue subclass moment,
     authored route choices, missing contract monsters, Knives, and Vyra route
     progression.
   - Keep the route authored and narrow; do not build a procedural or broader
     contract-run system.
   - Seed Shadow and the missing route/Legendary content only to the extent
     needed for Phase 1 Rogue Adventure parity.
   - Add Legendary reward choice support for the Knives payoff and implement
     required special mechanics generically where practical.

4. `P2:R5 - Run Rules And Determinism`
   - Add visible Adventure seed state and stable RNG contexts for combat,
     generated gear, rewards, shop offers, and special procs.
   - Restore or explicitly revise the Phase 1 first-failure do-over and
     second-failure restart/contract-failure rules.
   - Represent fight win, do-over, run restart, contract failure, and contract
     victory as explicit run states rather than label-only UI outcomes.

5. `P2:R6 - Save/Load Persistence`
   - Persist the shaped run state after `P2:R2` through `P2:R5`: class, trees,
     talents, rotation, gold, inventory, equipment, seed, current encounter or
     route node, rewards/shop state, and failure state.
   - Store authored content by stable resource path or id and generated gear
     as serializable affix data.
   - Add resume/new/abandon/save-and-quit affordances and round-trip tests.

6. `P2:R7 - Game-Like UI Pass`
   - Improve clarity after the real loop exists: run header, next action,
     reward/shop/route choice readability, encounter pressure, combat recap,
     loss feedback, and navigation confirmations.
   - Keep this as a playtest readability pass, not full art/animation
     production.
   - Include manual click-through verification in addition to headless tests.

7. `P2:R8 - Playtest Build`
   - Run regression and manual playthrough passes, fix critical blockers,
     prepare Windows export settings, export the build, smoke-test it outside
     the editor, and prepare playtest notes.
   - Treat Windows desktop as the required target; web or other platforms stay
     optional unless low-effort.

Dependency notes:

- `P2:R2` should start with the currently seeded Tavern progression because
  that is the smallest reconnectable loop. The direct Tavern-to-Vyra ladder is
  a temporary inherited shape and must be replaced by the authored contract
  route in `P2:R4`.
- `P2:R3` should happen before `P2:R4` because the contract route depends on
  reward choices, gear quality, gold, inventory, and shop/state foundations.
- `P2:R5` should happen after route and reward foundations exist so the seed
  model covers real combat, rewards, shops, route choices, and procs rather
  than being retrofitted around placeholders.
- `P2:R7` should follow the real run-state implementation; polishing before
  `P2:R2` through `P2:R6` would chase moving UI states.
- Phase 3+ deferrals are already recorded in `phase3_ideas.md`; no additional
  deferral document is needed for this audit.

## P2:R1:T9 - Update Docs

When the audit is complete:

- Mark completed tasks in this file.
- Link this file from `docs/Phase_2_Milestones.md`.
- Update the revised roadmap if the audit changes milestone boundaries.
- Add any deferred ideas to `phase3_ideas.md`.

### P2:R1:T9 Output - Documentation Closeout

Documentation closeout completed:

- This file now records the compact implementation roadmap for `P2:R2`
  through `P2:R8`.
- The task checklist above marks `P2:R1:T8` and `P2:R1:T9` complete.
- `docs/Phase_2_Milestones.md` now marks `P2:R1` complete and points the
  immediate next implementation step at `P2:R2 - Dashboard Loop Reconnection`.
- The existing `P2:R2` through `P2:R8` tracking docs remain the detailed
  implementation plans; this audit intentionally does not duplicate them.
- `phase3_ideas.md` already contains the deferrals identified by this audit:
  additional classes, additional contracts, broader procedural/meta contract
  run structure, full Training Room, Training Room targets, full art/animation
  production, and additional platform breadth.

## Audit Findings

Use this section as the working area for the actual audit.

### Already Ported And Active

- Project entrypoint and active UI flow:
  `project.godot` -> `game_root.tscn` -> title -> class select -> subclass
  select -> combat dashboard.
- Rogue class selection, with Mage and Crusader shown as disabled future
  options.
- Assassin and Thief subclass selection, with Shadow shown as a disabled
  future option.
- Dashboard-based build editing for one active subclass tree.
- Live character stats panel driven by resolved build state.
- Talent tree UI with data-driven layout, prerequisite enforcement, point
  budget display, selected/unselected state, and dependent-lock removal rules.
- Available skills and skill build/rotation editing panels.
- Build lock/unlock readiness flow and FIGHT gating.
- Fixed Mouthy Drunk enemy display and fight resolution from the dashboard.
- Combat log overlay and victory recap overlay.
- Core DPS-window combat: looping rotation, attack-speed timing, fixed window,
  physical mitigation, crits, poison stacks/ticks, poison stack cap, and
  armor reduction.
- Build resolution for base stats, tree innate modifiers, talents, gear
  modifiers, and rotation filtering.
- Generated Basic/Master/Cursed gear structure, real tier prices, real affix
  magnitudes, and weapon/trinket/charm equipment application.
- Headless tests for combat, added engine mechanics, gear generation,
  passive allocation, and active dashboard flow.

### Ported But Dormant

- `RunFlow` five-encounter ladder:
  Mouthy Drunk -> Drunk Buddy -> Tavern Bouncer -> Hired Goon -> Vyra.
- Encounter resources for the M5 ladder.
- `BuildState.current_encounter_index`, `current_encounter()`, and
  `advance_encounter()`.
- Tavern shop scene with gold display, equipped slots, generated offers,
  buying, unequipping, and Continue.
- Run end scene with Victory/Defeat and Restart.
- Gold state and spend/add helpers in `BuildState`.

### Partially Implemented

- Gear is mechanically active, but the dashboard uses random auto-roll/reroll
  equipment rather than Phase 1 shop/reward/inventory flow.
- Shop mechanics exist in a dormant full-screen scene, but not as a connected
  dashboard overlay or active progression step.
- Tavern encounters and Vyra exist as data, but only Mouthy Drunk is active in
  the dashboard.
- Multi-tree rules exist in state/allocation systems, but the active subclass
  screen only allows one selected tree.
- Talent budget exists as a full upfront `7` points, but reward-timed talent
  point gains are not active.
- Seeded offer generation exists in `GearGenerator.generate_offers()`, but the
  active gear panel uses unseeded `randomize()` and there is no Adventure seed
  UI/state.
- Combat supports armor reduction, bonus poison stacks, and physical damage
  multipliers, but triggered skills, poison resistance reduction, poison tick
  cadence changes, minimum-time procs, and gold reward modifiers are not active.
- Run end UI exists, but active fights only update dashboard status/overlays;
  defeat and boss victory flow are not wired into run-state transitions.

### Missing From Godot

- Training Room mode.
- Shadow subclass data, talents, innate poison behavior, and active UI option.
- First contract route data and flow: The Gilded Serpent Contract, Door Guard,
  Portly Cook, second-layer route choices, Knives, and route-to-Vyra
  progression.
- Reward claim flow for gold, talent points, fixed items, reward choices, and
  Legendary weapon choice.
- Authored Legendary gear items and their special behaviors.
- Inventory and retained item choice flow.
- Failure/do-over/restart rules from Phase 1.
- Save/load persistence.
- Adventure seed display/input and full run-context deterministic RNG.

### Intentionally Revised Or Cut

- The active dashboard replaces the old wizard-style screen sequence. This is
  an intentional Project Bane UI direction, though the dormant loop must still
  be reconnected into the dashboard.
- Mage and Crusader remain visible disabled/future options for Phase 2 rather
  than seeded playable content.
- Shadow should no longer be treated as a Phase 3 promise: it is Phase 2
  Adventure parity, but scheduled after dashboard reconnection and prerequisite
  mechanics.
- The current free dashboard gear auto-roll/reroll behavior should be removed
  from the Adventure path once reward/shop/inventory flow exists. It can remain
  only as hidden test/development support if still useful.
- Full Training Room mode is deferred out of Phase 2, while shared combat/build
  systems and tests continue to support deterministic experimentation. A
  compact Training Room Lite may be attempted as an optional P2:R8 playtest
  support task if the Adventure/export path is already stable.
- The current dashboard uses a victory overlay/log overlay presentation rather
  than the Phase 1 React presentation.

### Deferred To Phase 3+

- Additional playable classes beyond Rogue.
- Additional contracts beyond the first proven Rogue contract route.
- Broader procedural/meta Contract Run structure beyond Phase 1 first-route
  parity.
- Full Training Room mode, including freeform controls for trees, passives,
  gear quality/affixes, Legendary selection, target, combat duration, seed, and
  practice gold. P2:R8 may include only a compact Training Room Lite if it
  remains low-risk playtest support.
- Player-facing Training Room target set: Training Dummy, Armored Guard, and
  Venom-Resistant Slime.
- Full art/animation/polish production beyond what is needed for a readable
  Phase 2 playtest build.
- Additional platform/export breadth beyond the minimum Windows desktop
  playtest target, unless it proves low-effort during P2:R8.
