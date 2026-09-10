# P5M1: Gear Design Documents Tracker

## Status

Complete.

P5M1 finishes when the Phase 5 gear rules are documented clearly enough for
implementation to begin without hidden assumptions. Final balance numbers may
remain provisional, but the documents must define the systems, knobs,
calculation order, stacking behavior, and open questions that later milestones
will implement and tune.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone document:

- `docs/P5_Gear_Redesign_Overview.md`

## Exit Criteria

- Core gear model decisions are recorded.
- Lucky Coin behavior is codified.
- Stat roll weights and stat value scaling frameworks are documented.
- Cursed and Chaos drawback rules are documented.
- Damage calculation order is documented.
- Stack, status, special, and conflict rules are documented.
- Legendary handling boundary is documented.
- Deferred decisions are split into milestone-tagged tuning, presentation,
  validation, and future-design follow-up, with no P5M2 blockers remaining.
- `docs/P5_Gear_Redesign_Overview.md` reflects the expanded P5M1 scope.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M1-T1: Confirm Core Gear Model | Complete | Record the already-approved slot, Rogue item name, rarity, rarity stat-count, dagger damage, and Rogue weapon-scaling decisions. | Added a Core Model Decisions summary to `docs/New_Gear_Overview.md` anchoring slots, Rogue item names, rarity/stat-count boundaries, Crude starting Dagger handling, dagger damage ranges, and Rogue weapon-scaling scope. |
| P5M1-T2: Codify Lucky Coin | Complete | Define Lucky Coin as the Tavern gear intro reward and exclude it from normal shop generation. | Lucky Coin is now documented as a fixed Basic Trinket/Ring with +5% Crit Chance, awarded after the second Tavern enemy, used as the first gear introduction reward, and excluded from procedural gear, reward, and shop pools. |
| P5M1-T3: Define Stat Roll Weight Structure | Complete | Define how weighted stat selection is represented for each slot and category. | Added a Stat Roll Weight Structure section describing weighted entries, `weight: 0` disabled tuning entries, deterministic selection, no duplicate stat identifiers on generated items, and Shop Lab/Balance Lab validation expectations. |
| P5M1-T4: Draft Provisional Stat Weights | Complete | Create first-pass Basic, Rare, and Special stat weights by slot for Shop Lab implementation. | Added provisional Basic, Rare, and Special weight tables using the 0/5/10/15/20 scale, with all eligible stats active, slot-specific weighting, larger-advantage stats slightly rarer, and enemy-denial specials split into individual weighted entries. |
| P5M1-T5: Define Stat Value Scaling Framework | Complete | Define base ranges, rarity multipliers, slot modifiers, contract-depth scaling hooks, and rounding rules. | Added stat value scaling framework with slot/stat baseline ranges, rarity multipliers, no slot value multipliers, deterministic contract-depth hook defaulting to 1.00x, rounding/display rules, fixed Special handling, and Lucky Coin's fixed +5% Crit Chance exception. |
| P5M1-T6: Define Cursed And Chaos Drawback Rules | Complete | Codify negative stat eligibility, magnitude, duplicate interactions, and Chaos gamble behavior. | Added Cursed and Chaos drawback rules to `docs/New_Gear_Overview.md`: all slot-eligible Basic stats can roll negative, Cursed drawbacks use -1.80x, Chaos drawbacks use -2.25x, Chaos can roll all drawbacks, same-stat positive/negative duplicates are forbidden, final aggregate stats floor at 0, and Rare-stat drawbacks are deferred. |
| P5M1-T7: Codify Damage Calculation Order | Complete | Define the full order of operations for physical and elemental damage. | Added a Damage Calculation Order section to `docs/New_Gear_Overview.md` covering bucketed modifiers, physical and elemental pipelines, crit timing, conversion timing, double mitigation when both conversion specials are active, current mitigation order, final rounding, 1-damage floor, Death Strike stack damage, and recursive retrigger behavior. |
| P5M1-T8: Codify Stack And Status Interactions | Complete | Define stack increases, stack doubling, crit-poison application, cleanse denial, and stun/slow/interrupt denial or immunity. | `docs/New_Gear_Overview.md` now reflects the current baseline: Bonus Stacks improves existing poison, shred, and decay stack applications; Chance for Crits to Apply Poison adds 1 poison stack on successful crit procs and receives normal stack bonuses; doubling applies once after flat increases; dodge prevents attached stacks; block/absorb do not prevent stacks; suppress/cleanse denial preserve current behavior boundaries; and stun/slow/interrupt immunities are separate binary Specials. |
| P5M1-T9: Define Stat Stacking Rules | Complete | Decide which duplicate stats stack additively and which effects are binary or capped. | Added Stat Stacking Rules to `docs/New_Gear_Overview.md`: Basic and Rare stats stack additively across equipped items, drawbacks add into the same aggregate stat before floors/caps, chance stats cap at 100% with no overflow behavior, Chance for Retrigger should be tuned below 100%, stack increases add before one doubling effect, duplicate Specials are binary and non-stacking, different Specials combine, and `All stats are increased by 20%` applies once to the final stat sheet rather than items. |
| P5M1-T10: Define Special Conflict Rules | Complete | Define outcomes for incompatible or overlapping Special effects. | Added Special Conflict Rules to `docs/New_Gear_Overview.md`: duplicate Specials are binary, different Specials combine, enemy denial and immunity effects stack by coverage, conversion uses final damage type for mitigation, dual conversion causes physical then elemental mitigation, ignore effects apply to matching mitigation passes, ignore armor fixes armor and shred stacks at 0, ignore resistance penalizes original physical damage after damage calculation but before conversion, All Stats does not modify Special constants, and odd Special combinations are allowed for Shop Lab testing. |
| P5M1-T11: Codify Legendary Boundary | Complete | Define what M1 must say about existing Rogue legendaries and what waits for P5M10. | Added Legendary Boundary to `docs/New_Gear_Overview.md`: Legendary items are handcrafted fixed packages selected from a catalog, not procedurally rolled; current retained Rogue legendaries are all unique-name Weapon-slot daggers; Lucky Coin is explicitly not Legendary; P5M10 owns implementation, tuning, and Practice Room/Balance Lab validation; new Legendary drop/shop behavior is deferred except existing regression content; and Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril Karambit, and Bejeweled Push Dagger target packages are listed. |
| P5M1-T12: Update Deferred Decisions | Complete | Separate tuning questions from implementation-blocking rules. | Replaced the flat Deferred Decisions list in `docs/New_Gear_Overview.md` with milestone-tagged categories for P5M6 Shop Lab tuning, P5M7 Adventure integration tuning, P5M8 item presentation, P5M10 Legendary revisit, P5M11 validation, and future design; recorded that no remaining deferred decision blocks P5M2. |
| P5M1-T13: Revise Phase 5 Milestone Tracker | Complete | Update P5M1 purpose and exit criteria to match the expanded design scope. | Updated `docs/P5_Gear_Redesign_Overview.md`: P5M1 is now In Progress, the P5M1 row and section reflect the full Tasks 1-12 design scope, downstream milestones reference the documented drawback, damage, stacking, Special conflict, deferred tuning, and Legendary boundaries, and the overview records that no remaining deferred decision blocks P5M2. |
| P5M1-T14: M1 Review Pass | Complete | Verify the docs are coherent, complete enough for implementation, and not hiding rules in chat history. | P5M1 reviewed and marked complete. `docs/New_Gear_Overview.md`, `docs/P5_Gear_Redesign_Overview.md`, and this tracker now agree that P5M1 is complete, P5M2 can begin, and remaining deferred topics are non-blocking tuning, presentation, validation, or future-design work. |

## Status Definitions

- `Ready`: The task can be worked now.
- `Blocked`: The task needs a design decision, brainstorming pass, or prior task
  output before it can be completed.
- `In Progress`: The task is actively being edited or reviewed.
- `Complete`: The task output has been added to the relevant document and
  reviewed.

## Current Known Decisions

- Five universal equipment slots are final for Phase 5: Weapon, Helm, Armor,
  Trinket, Charm.
- Rogue item names are final for Phase 5: Dagger, Hood, Doublet, Ring,
  Necklace.
- Rarity tiers are final for Phase 5: Crude, Basic, Master, Epic, Cursed,
  Chaos, Unique, Legendary.
- Rarity stat-count rules are final for Phase 5.
- Legendary items are handcrafted fixed packages, not procedurally rolled stat
  packages. A generator or reward system may choose from a fixed Legendary
  catalog, but it must not roll Legendary stats.
- Current Phase 5 Rogue legendaries are all unique-name Weapon-slot daggers:
  Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril Karambit, and Bejeweled
  Push Dagger.
- Existing Rogue legendary effects are retained with upgraded stats for Phase 5.
  A deeper Legendary redesign waits for the later talent-tree rework.
- P5M10 owns Legendary implementation, tuning, and Practice Room/Balance Lab
  validation for each retained Legendary.
- Basic, Rare, and Special stat lists are final enough for implementation.
- Slot-specific stat pools are final enough for implementation. Armor/Doublet
  includes Crit Chance as a Basic stat.
- Enemy-denial specials cover dodge, block, absorb, suppress, and cleanse.
  Player-immunity specials cover stun, slow, and interrupt.
- Weighted stat selection uses per-slot, per-category weighted entries.
  `weight: 0` keeps a stat valid but disabled for random rolling.
- Generated items cannot roll duplicate stat identifiers on the same item,
  including Chaos items.
- First-pass stat weights use a simple 0/5/10/15/20 scale. All eligible stats
  remain active for initial Shop Lab testing, and enemy-denial specials are
  separate weighted entries.
- Stat values roll from slot/stat Basic baseline ranges, then apply rarity
  scaling. First-pass rarity multipliers are Basic 1.00x, Master 1.25x, Epic
  1.50x, Cursed positive 2.00x, Cursed drawback -1.80x, Chaos positive 2.25x,
  Chaos drawback -2.25x, and Unique 1.60x.
- Cursed and Chaos drawbacks use slot-eligible Basic stats. All Basic stats can
  roll as drawbacks, including stack and gold stats.
- Chaos can roll any mix of positive stats and drawbacks, including all
  drawbacks. Chaos positive rolls can use Basic or Rare pools, but Chaos
  drawbacks use Basic pools only during P5M1.
- A generated item cannot roll the same `stat_id` as both positive and negative.
  Final aggregate stat values floor at 0 and cannot become negative.
- Slot identity uses slot-specific ranges and roll weights; there are no
  separate slot value multipliers in the first pass.
- Contract-depth value scaling exists as a deterministic hook after rarity
  scaling, defaulting to 1.00x until Shop Lab or Adventure tuning changes it.
- Percentage and chance stats are stored as decimals internally and displayed as
  percentages. Final values round once after scaling.
- Special stats are fixed binary effects unless their text defines a fixed
  value. Special stats do not stack with duplicate copies.
- Rogue dagger damage ranges are final.
- Rogue physical skill weapon-scaling percentages are final.
- Percent Damage has been renamed to Percent Physical Damage for clarity.
  Percent Physical Damage only affects physical damage, and Percent Elemental
  Damage only affects elemental damage.
- Damage modifiers use buckets. Modifiers in the same bucket add together, then
  buckets multiply against each other. Gear percent damage and talent percent
  damage are separate buckets.
- Damage is calculated before mitigation. Crit applies before conversion, and
  conversion applies before mitigation.
- If both physical and magical conversion specials are active, damage counts as
  both types and is mitigated twice: physical mitigation first, then elemental
  mitigation.
- Current mitigation order is preserved: physical direct hits use crit negation,
  armor, then block; elemental/poison damage uses resistance, then absorb.
- Damage uses floating point through calculation, floors damaging hits at 1
  unless fully prevented, and rounds once at the end.
- Retriggers are new casts that reroll weapon damage and crit, rerun the full
  damage pipeline, and can trigger additional retriggers.
- Stack increases only improve skills or effects that already apply that stack
  type. They do not create new stack application on their own.
- Rogue elemental stacks are poison stacks for Phase 5.
- Chance for Crits to Apply Poison lets crits apply 1 poison stack for Rogue.
  It is a normal poison application, so gear and talent stack bonuses apply to
  it.
- Stacks you apply are doubled after flat stack increases, applies once, and
  does not stack with duplicate copies.
- Dodge prevents attached stacks from applying. Block can reduce physical damage
  to 0 without preventing attached triggers or stacks. Absorb reduces elemental
  damage but does not prevent elemental stacks.
- Enemies can no longer cleanse disables all enemy cleanse behavior, including
  generated cleanse thresholds. Enemies can no longer suppress preserves current
  suppress behavior except that enemy suppress is disabled while equipped.
- You are immune to stun, You are immune to slow, and You are immune to
  interrupt are three separate Special stats. Each disables the matching enemy
  stat while equipped.
- Different equipped items can grant the same Basic or Rare stat. Basic and Rare
  stats stack additively unless explicitly stated otherwise.
- Chance stats cap at 100% with no overflow behavior. Chance for Retrigger
  should be tuned so normal legal builds cannot reach 100%.
- Drawbacks add into the same aggregate stat as positives before floors and
  caps.
- Increased Attack Speed stacks additively inside the gear attack-speed bucket.
- All stats are increased by 20% applies once as a multiplicative boost to the
  final non-negative stat sheet, not to individual items, and does not affect the
  base weapon damage range.
- Duplicate copies of the same Special are allowed across equipped items but do
  not stack. Different Special stats combine, including multiple separate enemy
  denial effects.
- Special conflicts resolve silently in combat for P5M1; Practice Room and Shop
  Lab should expose the results rather than item UI warning about every
  combination.
- Damage conversion uses final damage type for mitigation. Dual physical/magical
  conversion causes physical mitigation first, then elemental mitigation.
- Ignore armor applies to physical mitigation passes and fixes enemy armor and
  shred stacks at 0 while equipped. Existing shred has no effect, and new shred
  applications are prevented.
- Ignore resistance applies to elemental mitigation passes. Its 50% physical
  damage penalty applies only to original physical damage after damage
  calculation but before conversion.
- All stats are increased by 20% does not multiply fixed Special text constants,
  including the 50% physical damage penalty.
- Special combinations are not blocked during item generation for P5M1 except
  for same-item duplicate `stat_id` rules.
- Lucky Coin is a Basic Trinket/Ring with +5% Crit Chance. It is awarded after defeating
  the second Tavern enemy as the first gear introduction and does not appear in
  shops.
- Exact tuning can be refined through Shop Lab, but the knobs and rule structure
  must be documented in M1.
- No remaining deferred decision blocks P5M2. Remaining open items are tuning,
  presentation, validation, or future-design follow-up.

## Open Design Threads

These are the remaining non-blocking deferred topics after P5M1-T12:

- P5M6/P5M7: contract-depth item value scaling, final rarity odds by contract
  depth, provisional stat ranges, lower-rarity usefulness, whether Specials
  should remain Unique-only, and whether Rare-stat drawbacks are needed.
- P5M8/P5M9: exact Epic visual treatment and any needed player-facing tooltip
  wording for confusing Special combinations.
- P5M10: final retained Rogue Legendary values, resources, reward/shop behavior,
  and per-Legendary validation.
- P5M11: final power tuning for `All stats are increased by 20%` and validation
  that Chance for Retrigger stays below 100% in normal legal builds.
- Future design: full Legendary redesign after the later talent-tree rework and
  future class elemental item behavior.

## Completion Notes

P5M1 is complete. The Phase 5 gear design rules are documented clearly enough
for P5M2 implementation work to begin without hidden chat-only assumptions.

Completed documentation:

- `docs/New_Gear_Overview.md` defines the five-slot model, Rogue item names,
  rarity tiers, stat categories, slot pools, stat weights, value scaling,
  Cursed/Chaos drawbacks, damage calculation order, stack/status interactions,
  stat stacking rules, Special conflict rules, Lucky Coin behavior, Legendary
  boundaries, and milestone-tagged deferred decisions.
- `docs/P5_Gear_Redesign_Overview.md` reflects the expanded P5M1 scope,
  downstream milestone dependencies, and P5M2 readiness.
- `docs/P5M1_Gear_Design_Documents_Tracker.md` records all P5M1 design tasks as
  complete and preserves the current known decisions.

P5M2 may begin. Remaining deferred topics are non-blocking and assigned to later
milestones: Shop Lab and Adventure tuning, item presentation, Legendary revisit,
Practice Room/Balance Lab validation, and future post-Phase-5 design.
