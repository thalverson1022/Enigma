# Mechanics And Balance Glossary

## Purpose

This document defines the current mechanics vocabulary and balance tools for
Phase 3. It is written for animation, UX/UI, and future balance work.

For implementation details, inspect:

- `project/scripts/systems/combat_resolver.gd`
- `project/scripts/systems/build_resolver.gd`
- `project/scripts/systems/damage_calculator.gd`
- `project/scripts/systems/combat_timing.gd`
- `project/scripts/systems/gear_generator.gd`
- `project/scripts/tools/balance_lab.gd`

## Combat Model

Combat is an automated fixed-window DPS check.

Inputs:

- A resolved player stat block.
- A legal skill rotation.
- A monster with HP, armor, and poison resistance.
- A duration in milliseconds.
- A seed.

Output:

- Total damage.
- DPS.
- Win or loss.
- Cast events.
- Poison tick events.
- Combat log and recap data.

The player does not manually control combat after pressing Fight. The UI and
animation should present what the already-resolved timeline did.

## Build Resolution

`BuildResolver.resolve_stats()` applies combat stats in this order:

1. Class base stats.
2. Selected tree innate modifiers.
3. Selected talent modifiers.
4. Equipped gear affixes and special gear fields.

`BuildResolver.resolve_unlocked_skills()` collects:

1. Class base skills.
2. Tree unlocked skills.
3. Talent unlocked skills.
4. Gear unlocked skills.
5. Tree skill augments.

`BuildResolver.resolve_rotation()` filters the requested rotation to skills
the current build has actually unlocked and caps the rotation at 10 skills.

## Skill Timing

Each skill has:

- `base_execution_ms`
- `min_execution_ms`

Attack speed modifies normal execution timing through `CombatTiming`.
Minimum-cast procs can force a skill to use `min_execution_ms`.

UX implication: a min-cast proc is a timing event. It should be visually
distinct from a crit or retrigger.

## Damage Types

## Physical Damage

Physical hits are affected by:

- Raw skill physical amount.
- `bonus_physical_damage`.
- Monster armor.
- Crit chance.
- Crit multiplier.
- Physical damage multiplier.

Physical damage appears on cast events.

## Poison Damage

Poison is stack based.

Skills or augments apply poison stacks. On each poison tick:

- One active stack is consumed.
- Damage is based on `poison_damage_per_tick`.
- Monster poison resistance reduces poison damage.

Current default poison tick cadence is 1000 ms, multiplied by
`poison_tick_interval_multiplier`.

Important Phase 2 clarification: Shadow intrinsic does not deal instant point
damage. It adds poison stacks to Stab and Heavy Slash, and those stacks tick
later for poison damage.

## Armor

Armor mitigates physical hits. Armor can be reduced during combat by
`ArmorReductionEffect`.

Armor reduction persists for the rest of the fight. If a skill both hits and
reduces armor, effect order matters: a physical effect before an armor
reduction effect uses the old armor value, while later casts benefit from the
reduction.

UX implication: persistent armor reduction should be shown as a lasting enemy
state, not as a one-frame hit effect.

## Poison Resistance

Poison resistance reduces poison tick damage. It can be reduced by
`PoisonResistanceReductionEffect`.

Beguiling Strike currently reduces poison resistance by 50%.

UX implication: poison resistance reduction should not look identical to armor
reduction, because it affects a different damage channel.

## Crits

Crits use:

- `crit_chance`
- `crit_multiplier`

Crits apply to physical hit resolution. Poison ticks do not crit in the
current model.

## Triggered Skills And Procs

Triggered skill effects can fire during cast resolution without adding cast
time.

Examples:

- Opportunity Strikes: Quick Cut has a 20% chance to trigger Rending Slash.
- Mithril Karambit: Stab and Heavy Slash each have a 20% chance to retrigger
  their own skill.

Triggered effects use the same seeded fight RNG as crits and min-cast procs.

UX implication: triggered skills should appear connected to the source cast
but still read as an extra event.

## Minimum-Cast Proc

Bejeweled Push Dagger adds a 20% chance for a skill to use its minimum cast
time. This changes timing and can add more casts inside the same combat
window.

It is not a direct damage proc.

## Stack-Scaling Damage

Death Strike has base physical damage plus physical damage per active poison
stack. It reads current active poison stacks at the time of the hit.

UX implication: it benefits from showing active poison stacks clearly before
the cast resolves.

## Gear Generation

Generated gear tiers:

- Basic: 1 affix.
- Master: 2 affixes.
- Cursed: 2 positive affixes plus 1 downside affix.
- Legendary: authored named gear, not generated from the random affix table.

Shop price by tier:

- Basic: 18g.
- Master: 32g.
- Cursed: 40g.
- Legendary: 80g.

Generated combat affix pool:

- Attack speed.
- Crit chance.
- Crit multiplier.
- Poison damage.
- Physical damage.
- Poison stacks applied.
- Armor reduction.

Gold Rewards exists as a stat type but is reward-only in the current rules
and is excluded from generated combat gear.

## Shop And Legendary Availability

The shop offers six items.

After the Tavern phase, Master, Cursed, and Legendary gear all have non-zero
shop availability. Legendary shop chance is 1%.

The shop should not show duplicate items in the same offer set.

The shop's Legendary pool contains all five Rogue Legendaries and dedupes
against already-owned Legendaries where possible.

## Rewards

Rewards can include:

- Gold.
- Talent points.
- Fixed gear.
- Generated gear choice.
- Legendary choice.
- Shop unlock.
- Contract or route progression.

Knives offers a seeded random 2-of-5 Legendary choice.

## Run Rules

The first Tavern fight, Mouthy Drunk, is a learning fight with unlimited
retries.

Every other fight gives one do-over per encounter. A second loss after the
do-over requires Adventure restart or marks contract failure, depending on
where the run is.

Adventure restart preserves the current seed.

## Determinism

Adventure seed defaults to 1 unless changed by the player.

Seeded contexts are handled by `RunRng`, so combat, shop offers, reward
choices, and generated item IDs can be reproducible without all using one
shared global random stream.

When testing determinism, compare repeated runs with:

- Same seed.
- Same build.
- Same route.
- Same rotation.
- Same encounter context.

## Balance Lab

Balance Lab is the current balance verification tool.

Run:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-Bane\project' -s 'res://scripts/tools/run_balance_suite.gd'
```

Outputs:

- `project/reports/balance/latest/results.json`
- `project/reports/balance/latest/scenario_summary.csv`
- `project/reports/balance/latest/index.html`

Current checks:

- Deterministic Legendary wiring checks.
- Baseline Rogue DPS distribution.
- Shadow intrinsic poison distribution.
- Wyvern poison distribution.
- Bandit Blade gold-scaling distribution.
- Bejeweled min-cast proc-rate distribution.
- Late-contract Thief build distribution.

Current latest result as of 2026-07-25:

- 19 pass.
- 0 warn.
- 0 fail.

## How To Use Balance Data In Phase 3

Phase 3 is mostly presentation work, so balance should remain stable unless a
bug is discovered.

Use Balance Lab after:

- Changing combat playback if it touches event ordering.
- Changing combat log formatting if it depends on event data.
- Changing skill, talent, gear, or stat resources.
- Changing build resolution.
- Changing combat timing or animation timing that might accidentally affect
  combat timing.

Do not use Balance Lab as a final tuning authority yet. It is a regression
and drift detector. Balance judgment still needs hands-on playtesting and,
later, the Phase 4 monster/encounter overhaul.

## Phase 3 UX Translation Guide

Mechanic to visual language:

- Cast: readable skill name and timing.
- Crit: stronger impact and distinct text treatment.
- Poison stack application: stack marker added to the enemy.
- Poison tick: periodic damage pulse from the stack marker.
- Armor reduction: persistent cracked/shredded armor state.
- Poison resistance reduction: persistent toxic vulnerability state.
- Triggered skill: secondary event chained from the source skill.
- Minimum-cast proc: speed flash or compressed cast timing.
- Victory: resolved combat momentum and reward bridge.
- Defeat: clear shortfall, not just a red failure stamp.

Keep combat animation faithful to the resolved timeline. Animation can add
feel, anticipation, and readability, but it should not become a second combat
simulator.

