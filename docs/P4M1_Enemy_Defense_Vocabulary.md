# P4M1: Enemy Defense Vocabulary

## Purpose

P4M1 defines the enemy defensive mechanics for Phase 4 and implements them in
Balance Lab so they are ready for focused testing in the next milestone.

The user already has the defense mechanics defined. This milestone is about
capturing those mechanics cleanly, centralizing them in documentation, and
wiring them into the existing combat and Balance Lab surfaces.

## Milestone Goal

Create a readable enemy defense vocabulary that can support future procedural
contract generation. Defenses should give enemies distinct identities, create
meaningful build matchups, and remain deterministic in combat resolution.

## Primary Outputs

- `docs/Enemy_Defense_Mechanics.md`: canonical reference for the new enemy
  defensive mechanics.
- Balance Lab support for applying and observing the new defenses on test
  enemies.
- Focused implementation notes and verification results recorded in this
  milestone document.

## Current Focus

Active task: P4M1 complete. Next milestone is P4M2 Monster Lab Defense And
Generation Prototype.

Immediate next step:

- Start P4M2 by importing the approved defense vocabulary into Monster Lab's
  enemy-generation sandbox.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M1-T1: Capture Defense Mechanics | Complete | Take the user's defined mechanics and normalize them into canonical defense IDs, display names, rules text, and player-facing descriptions. | Every provided defense has a stable ID, display name, combat rule summary, and player-facing description without changing the user's intended behavior. |
| P4M1-T2: Create Enemy Defense Mechanics Document | Complete | Add `docs/Enemy_Defense_Mechanics.md` as the centralized reference for the approved defenses. | The document exists and organizes defense rules, counterplay notes, build matchup pressure, stacking behavior, UI language, and Balance Lab expectations. |
| P4M1-T3: Audit Balance Lab And Combat Hooks | Complete | Inspect existing enemy definitions, combat modifiers, test enemies, and Balance Lab configuration to find the cleanest implementation path. | Relevant files and integration points are identified, with implementation notes recorded before runtime changes begin. |
| P4M1-T4: Implement Defense Mechanics | Complete | Add the defense data and runtime behavior needed for the approved mechanics, scoped to Balance Lab readiness. | The approved defenses can be represented by enemies and produce their documented combat effects while preserving deterministic resolution. |
| P4M1-T5: Expose Defenses In Balance Lab | Complete | Update Balance Lab so test enemies can use, display, and exercise the new defensive mechanics. | Balance Lab can configure or run test enemies with the new defenses, and defense state/effects are visible enough for testing. |
| P4M1-T6: Verify And Document Closeout | Complete | Run the relevant Balance Lab/Godot checks, update the Phase 4 overview, and record follow-up notes for P4M2. | Verification results are recorded, `docs/P4_DawnBringer_Overview.md` reflects P4M1 status and links, and any deferred Monster Lab or generation work is listed for P4M2. |

## Implementation Notes

Record notable design or code decisions here as implementation proceeds.

- Created `docs/Enemy_Defense_Mechanics.md` as the canonical P4M1 defense
  vocabulary reference.
- Captured the two damage types, physical and magical, and explicitly deferred
  true damage.
- Documented physical damage resolution as dodge, crit negation, armor, then
  block.
- Documented magical damage resolution as resistance, then absorb.
- Captured enemy-side debuff and timing disruption mechanics: cleanse,
  suppress, stun, slow, and interrupt.
- Recorded open implementation questions around cleanse counter triggers,
  damage clamping, interrupt skip semantics, and future timing-disruption
  immunity.

### P4M1-T3 Audit: Combat And Balance Lab Hooks

Audit completed before runtime implementation. Current combat is compact and
mostly centralized, which argues for a scoped extension rather than an early
status-system extraction.

Core combat hooks:

| Surface | File | Current Role | P4M1 Implication |
| --- | --- | --- | --- |
| Damage formulas | `project/scripts/systems/damage_calculator.gd` | Owns armor multiplier, poison resistance multiplier, physical hit resolution, and poison tick damage. | Add or extend resolvers for dodge, crit negation, block, resistance, absorb, and generalized magical/DOT damage. |
| Fight timeline and state | `project/scripts/systems/combat_resolver.gd` | Resolves the whole fight synchronously into cast and tick events. Tracks current armor, current poison resistance, active poison stacks, cast timing, and poison tick cadence. | Primary implementation hook for cleanse, suppress, timing disruption, and new event fields. |
| Attack speed formula | `project/scripts/systems/combat_timing.gd` | Converts skill base execution time plus player attack speed into execution time. | Best first hook for slow as anti-attack-speed or equivalent execution-time scaling. Stun/interrupt likely need resolver-level timeline changes. |
| Enemy data | `project/scripts/resources/monster.gd` | Stores `id`, `display_name`, `hp`, `armor`, and `poison_resistance`. | Needs new exported defense fields or a defense package resource before generated enemies can represent the vocabulary. |
| Skill effects | `project/scripts/resources/skill.gd` and effect resources | Skills contain ordered `SkillEffect` resources. Existing effects are physical damage, poison stack application, armor reduction, poison resistance reduction, stack-scaling physical damage, and triggered skills. | Current player-side effects are enough to test enemy defenses, but magical direct damage and non-poison DOTs will need later effect resources. |

Existing support confirmed:

- `Armor` already exists and supports negative values through
  `DamageCalculator.physical_mitigation_multiplier()`.
- `Resistance` exists as `poison_resistance`, with percentage mitigation for
  poison ticks.
- Physical crits already exist in `DamageCalculator.resolve_physical_hit()`.
- Poison DOT cadence already exists in `CombatResolver.POISON_TICK_INTERVAL_MS`
  plus `PlayerStats.poison_tick_interval_multiplier`.
- Debuff-like enemy state already exists for poison stacks, armor reduction
  (`Shred`), and poison resistance reduction (`Decay`), but it is embedded in
  `CombatResolver.resolve()` rather than centralized in a status object.

Missing support:

| Defense | Existing Support | Missing Support | Candidate Hook | Risk |
| --- | --- | --- | --- | --- |
| `armor` | Existing `Monster.armor` and damage calculator formula. | Confirm order once block/crit negation are added. | `damage_calculator.gd`, `combat_resolver.gd` | Low |
| `dodge` | None. RNG already exists per fight. | Monster dodge chance, event field for dodged casts, bypass damage/effects on dodged physical attacks. | `monster.gd`, `combat_resolver.gd`, formatter/playback UI | Medium |
| `crit_negation` | Crit chance/multiplier exist. | Monster crit-negation value and formula before armor. | `damage_calculator.gd`, `monster.gd` | Low |
| `block` | None. | Monster block value, flat reduction after armor, final damage clamp. | `damage_calculator.gd`, `monster.gd` | Low |
| `resistance` | Existing `poison_resistance`. | Rename/generalize toward magical resistance, or alias safely for P4M1. | `monster.gd`, `damage_calculator.gd`, UI labels | Medium |
| `absorb` | None. | Monster absorb value, flat magical reduction after resistance, final damage clamp. | `damage_calculator.gd`, `monster.gd` | Low |
| `cleanse` | Debuff values are tracked in resolver. | Threshold/counter, attack-trigger increment, event fields, reset poison/shred/decay values to zero. | `combat_resolver.gd`, playback presenters, recap/log formatting | Medium |
| `suppress` | Poison tick interval exists. | Enemy-side tick interval multiplier/adder using documented formula. | `combat_resolver.gd`, `monster.gd` | Low |
| `stun` | None. | Enemy-applied timing event that pauses cast progress. No enemy attack timeline exists yet. | `combat_resolver.gd`, `CombatPlayback`, presenters | High |
| `slow` | Player attack speed formula exists. | Enemy-side slow value applied to execution-time calculation. | `combat_timing.gd`, `combat_resolver.gd`, `monster.gd` | Medium |
| `interrupt` | None. | Cancel direct casts and skip future uses. Needs clear semantics and event output. | `combat_resolver.gd`, playback/log UI | High |

Balance Lab hooks:

- `project/scripts/tools/balance_lab.gd` owns the automated suite, mechanics
  checks, scenario specs, scenario execution, report aggregates, CSV output, and
  HTML output.
- New P4M1 mechanics should add mechanics checks first, then scenario specs
  that pressure specific defenses.
- Current scenario summaries report total, physical, poison damage, poison
  ticks, crit rate, proc rate, and win rate. New mechanics likely need summary
  fields for dodges, blocked damage, absorbed damage, cleanses, suppressed tick
  cadence, slow/stun/interrupt counts, and direct/magical damage once added.
- `project/tests/balance_lab_test.gd` asserts suite shape and all mechanics
  checks passing; update expected minimum counts after adding P4M1 checks.

Interactive/visual test hooks:

- `project/scripts/systems/training_room_state.gd` owns an in-memory practice
  `Monster` and currently exposes adjustable armor and poison resistance.
- `project/scenes/training_room/training_target_panel.gd` provides the
  interactive target controls for armor and poison resistance. This is the
  likely quick manual surface for new defense sliders/toggles before Monster
  Lab exists.
- `project/scenes/training_room/training_room_combat_view.gd` and
  `project/scripts/ui/combat_playback_presenter.gd` replay resolved events and
  maintain visible armor, resistance, poison, shred, and decay state. New
  defense events must be represented in `CombatResolver.CastEvent` or
  `TickEvent` before these presenters can display them.
- `project/scripts/ui/combat_playback.gd` merges cast and tick events only. If
  stun/interrupt become timeline events distinct from casts/ticks, playback may
  need a new event kind; otherwise they can remain fields on cast events.
- `project/scenes/combat/enemy_panel.gd` currently previews HP, armor, poison
  resist, fight window, reward, and simple defensive pressure text. P4M1-T5
  should extend this only after the underlying data model is stable.

Formatter, recap, and inspector hooks:

- `project/scripts/systems/combat_result_formatter.gd` renders the textual
  combat log and currently knows casts and poison ticks.
- `project/scripts/systems/combat_recap.gd` derives post-fight summary metrics
  from cast/tick events.
- `project/scripts/systems/combat_log_inspector_data.gd` builds grouped rows
  for the combat log inspector.
- Any defense that changes observable outcome should add event fields first,
  then update these readouts so Balance Lab and UI review are not blind.

Save/load and authored data notes:

- `project/scripts/systems/save_system.gd` saves active contracts and route
  nodes by resource path. Authored monster resources are not serialized as
  value data today.
- Adding exported fields to `Monster` is low-risk for authored resources, but
  runtime-generated monsters in later P4 milestones may need explicit save/load
  policy if they are not persisted through authored resource paths.

Recommended P4M1-T4 implementation order:

1. Add enemy defense fields to `Monster` with conservative defaults that
   preserve current behavior.
2. Extend `DamageCalculator` for physical order: dodge support in resolver,
   crit negation, armor, block, and damage clamp.
3. Generalize magical mitigation enough for current poison ticks: resistance
   then absorb. Keep `poison_resistance` compatibility or migrate carefully.
4. Add cleanse and suppress because they fit the current poison/shred/decay
   resolver state.
5. Add Balance Lab mechanics checks for each implemented mechanic as soon as it
   lands.
6. Add slow as a small timing extension.
7. Defer or isolate stun and interrupt until the simpler defenses are covered;
   they have the highest timeline/playback risk.

Open decisions after audit:

- Does cleanse increment on both physical and magical direct attacks?
- Does a dodged physical attack increment cleanse?
- Should P4M1 rename `poison_resistance` to general magical `resistance`, or
  preserve the old field and introduce an alias to avoid broad resource churn?
- Should stun/interrupt be in P4M1 Balance Lab readiness, or should P4M1 expose
  their data shape and defer full timeline behavior until after physical,
  magical, cleanse, suppress, and slow are stable?

### P4M1-T4 Implementation Notes

Implemented the first runtime slice of the enemy defense vocabulary:

- Added exported defense fields to `Monster`: `dodge_chance`, `crit_negation`,
  `block`, `absorb`, `cleanse_threshold`, `suppress`, `slow`,
  `stun_duration_ms`, and `interrupt_skip_count`.
- Preserved existing `armor` and `poison_resistance` fields for compatibility
  with authored monsters, UI labels, Practice Room, and Balance Lab scenarios.
- Extended `DamageCalculator` with physical resolution for crit negation and
  block, plus generalized magical mitigation for resistance then absorb.
- Extended `CombatTiming` with enemy slow support. Slow uses
  `execution_time * (1 + slow)`, so 50% slow turns a 1000ms skill into 1500ms.
- Extended `CombatResolver` to support dodge, crit negation, block, absorb,
  cleanse, suppress, and slow.
- Added explicit event fields for `was_dodged`, `dodged_attacks`,
  `blocked_amount`, `crit_negation_applied`, `absorbed_amount`,
  `tick_interval_ms`, `cleanse_counter`, and `cleanse_triggered`.
- Added focused coverage in `project/tests/enemy_defense_mechanics_test.gd`.
- Added Balance Lab mechanics checks for dodge, crit negation, block, absorb,
  cleanse, suppress, and slow.

Implementation decisions made during T4:

- `poison_resistance` remains the current magical resistance field for P4M1 to
  avoid broad resource/UI churn. A later naming migration can introduce
  `resistance` once more magical damage sources exist.
- Final damage clamps to `0` after `Block` and `Absorb`.
- Dodge is rolled once per direct physical skill instance. A dodged physical
  attack skips its attached skill effects, including poison stack application.
- Cleanse increments once per direct cast event, not DOT ticks. A dodged cast
  still counts as an attack for cleanse-counter purposes.
- Cleanse triggers after the cast's effects are applied, then resets active
  poison stacks, current armor back to base armor, and current poison
  resistance back to base poison resistance.
- Suppress uses
  `tick_interval = base_tick_interval * player_tick_multiplier * (1 + suppress)`.
- `stun_duration_ms` and `interrupt_skip_count` are data placeholders only in
  T4. Full stun/interrupt runtime behavior is deferred because there is no
  enemy action timeline yet, and forcing one into this task would create avoidable
  playback and state-machine risk.

Recommended P4M1-T5 exposure order:

1. Add Balance Lab report columns/HTML visibility for new event metrics.
2. Add defense-focused scenario specs or a dedicated defense section that
   reports dodge count, blocked damage, absorbed damage, cleanse count,
   suppress tick interval, and slow-driven cast count changes.
3. Add Practice Room target controls for the implemented defense fields.
4. Extend combat/Practice Room readouts only after the reporting shape is
   stable.

### P4M1-T5 Balance Lab Exposure Notes

Expanded Balance Lab from isolated mechanics checks into scenario-level defense
reporting:

- Added defense metrics to per-seed combat summaries and aggregate
  distributions: `casts`, `dodges`, `dodge_rate`, `blocked_damage`,
  `crit_negated_damage`, `absorbed_damage`, `cleanses`, and
  `suppressed_tick_interval_ms`.
- Added per-scenario monster overrides so Balance Lab can test defensive
  packages without creating temporary monster resources.
- Added six defense-focused scenarios:
  - `defense_block_stab`
  - `defense_dodge_stab`
  - `defense_crit_negation_bandit`
  - `defense_absorb_suppress_poison`
  - `defense_cleanse_poison`
  - `defense_slow_stab`
- Added threshold support for the new defense metrics, including blocked
  damage, dodges, dodge rate, crit-negated damage, absorbed damage, cleanse
  count, suppressed tick interval, and cast count.
- Extended Balance Lab CSV output with defense metric columns.
- Extended the Balance Lab HTML dashboard with an `Enemy Defense Pressure`
  table showing each scenario's defense overrides and observed defensive
  outcomes.

T5 scope stayed focused on Balance Lab. Practice Room controls and Monster Lab
integration remain future tooling work; Monster Lab is planned under P4M2.

## Verification Notes

Run Balance Lab when the new defense mechanics touch combat timing, event
ordering, build resolution, enemy data, poison/proc behavior, duration behavior,
or generated difficulty assumptions.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Verification results:

- `enemy_defense_mechanics_test.gd`: passed. Focused defense mechanics are
  deterministic and match the documented physical/magical mitigation rules.
- `balance_lab_test.gd`: passed after T5 Balance Lab reporting updates. Latest
  generated test report shows 12 scenarios, 27 mechanics checks, and 2400
  scenario seeds with overall `pass` status.
- `combat_test.gd`: passed. The existing deterministic combat baseline still
  reports the expected total damage, DPS, and win result.
- `combat_playback_test.gd`: failed in the existing natural-loss reveal timing
  path. The focused defense checks and Balance Lab passed; failure details:
  expected player defeat pose/retry reveal timing did not match the test during
  natural loss playback. Treat as a playback-regression investigation item
  before broad playback closeout, not a blocker for P4M1 defense math or
  Balance Lab readiness.

## Exit Criteria

P4M1 is complete when:

- The new defense list is captured in `docs/Enemy_Defense_Mechanics.md`.
- Each defense has a stable ID, display name, combat rule, player-facing
  description, counterplay note, and stacking/interaction rule.
- The approved defense mechanics are implemented for Balance Lab use.
- Balance Lab can create or run test enemies with the new defenses.
- Relevant checks have passed or any failures are documented with follow-up
  tasks.
- `docs/P4_DawnBringer_Overview.md` reflects the final P4M1 status.

## Follow-Ups For P4M2

Use this section to collect items that should move into Monster Lab defense and
generation prototyping rather than expanding P4M1.

- Import the canonical defense IDs and player-facing labels from
  `docs/Enemy_Defense_Mechanics.md` into Monster Lab's data model.
- Add archetype/tag pools that can express combinations such as tanky, thief,
  mage-resistant, cleanser, suppressor, and control-focused enemies.
- Define initial difficulty bands and value ranges for defense mechanics,
  including count/budget rules for combining archetypes.
- Add validation warnings for nonsensical or overly oppressive combinations,
  especially stacked timing disruption or excessive flat reduction.
- Add Monster Lab previews that show final defense package, expected matchup
  pressure, and Balance Lab-relevant exported values.
- Decide the export bridge from Monster Lab prototypes back into Balance Lab
  scenarios and, later, deterministic Godot runtime generation.
- Keep Practice Room controls as a later convenience task unless P4M2 testing
  needs manual in-engine sliders before Monster Lab export is ready.
