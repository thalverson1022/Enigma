# Current Mechanics Reference

Verified against code state: `a4c6825`

## Purpose

This is the Phase 2 clean rules reference. It describes the mechanics currently
implemented in code, not every historical idea from the MVP milestone docs.

Primary source files:

- `src/engine/simulateCombat.ts`
- `src/build/resolveBuild.ts`
- `src/build/passiveAllocation.ts`
- `src/run/phaseFlow.ts`
- `src/run/contractRouteFlow.ts`
- `src/run/rewards.ts`
- `src/run/shop.ts`
- `src/training/trainingRoom.ts`

## Combat Model

Combat is a deterministic fixed-window DPS simulation.

- Each fight has an authored duration in milliseconds.
- The player supplies a rotation of skill IDs.
- Skills cast in order and loop until the combat window ends.
- If a cast would finish after the combat window, it is skipped and does not
  apply its effects.
- Combat ends at the fixed duration even if poison remains.
- Victory is determined by total final damage dealt versus target starting HP.
- DPS is `total final damage / combat duration in seconds`.

## Randomness And Seeds

Combat uses seeded RNG.

- Crit rolls are deterministic for a given seed.
- Bejeweled Push Dagger minimum-time procs are deterministic for a given seed.
- Adventure uses the Adventure seed selected on the mode screen.
- Training Room has its own separate seed control.
- Generated shop and reward gear are also seeded from run, contract, route, slot,
  tier, and option context.

## Skill Timing

Skill execution time is calculated as:

```text
executionMs = ceil(max(minExecutionMs, baseExecutionMs / (1 + attackSpeed)))
```

Attack speed is additive in the resolved player stat. Minimum execution time is
always respected unless a mechanic explicitly uses that minimum as the chosen
cast time.

## Damage Types

Current damage types:

- `physical`
- `poison`

Direct skill hits can crit. Poison ticks do not crit.

## Critical Hits

For each direct damage effect:

- roll against `player.critChance`
- if the roll succeeds, multiply direct damage by `player.critMultiplier`
- crits are tracked in result summaries and combat events

The starter Rogue baseline is:

- attack speed: `0`
- crit chance: `15%`
- crit multiplier: `2x`
- poison damage per tick: `8`

## Armor

Armor mitigates physical damage only.

Positive armor uses:

```text
armorReduction = (0.75 * armor) / (armor + 100)
finalDamage = rawDamage * (1 - armorReduction)
```

Negative armor increases physical damage using the same curve:

```text
armorVulnerability = (0.75 * abs(armor)) / (abs(armor) + 100)
finalDamage = rawDamage * (1 + armorVulnerability)
```

Armor can be reduced below zero. Current armor reductions persist for the rest
of the fight.

## Poison

Poison uses individual stack sources.

- Default poison tick interval is `1000ms`.
- Default maximum poison stacks is `20`.
- Each poison tick consumes one poison stack.
- Tick damage uses `player.poisonDamagePerTick`.
- Poison stack application is capped by open stack slots.
- Excess applied stacks are lost.
- Poison expiration is logged when the final stack is consumed.

Shadow has an innate poison source:

- if Shadow is one of the chosen trees, `Stab` and `Heavy Slash` gain `+1`
  poison application.

## Poison Resistance

Poison resistance mitigates poison damage only.

```text
finalPoisonDamage = rawPoisonDamage * (1 - clamp(poisonResistance, 0, 1))
```

Poison resistance reduction effects multiply the current resistance by the
remaining portion. For example, a `50%` reduction turns `40%` resistance into
`20%` resistance for later poison ticks.

Negative poison resistance does not increase poison damage because mitigation
clamps resistance between `0` and `1`.

## Build Resolution

A resolved build is created from:

- chosen primary and secondary trees
- selected passive nodes
- equipped gear
- rotation
- current gold when needed by gear

Resolution order:

1. Start with the base Rogue player stats.
2. Determine unlocked skills from base skills, trees, passives, and gear.
3. Add triggered skill IDs required by modifiers.
4. Clone the available skills.
5. Apply tree innate modifiers.
6. Apply selected passive modifiers.
7. Apply gear modifiers in slot order: weapon, trinket, charm.
8. Filter the rotation to unlocked skills.

## Passive Allocation

Adventure passive rules:

- point budget: `7`
- maximum trees per build: `2`
- selected passives must belong to chosen trees
- duplicate nodes are rejected
- missing prerequisites are rejected
- prerequisite option groups require at least one option
- nodes with selected dependents cannot be removed

Training Room relaxes some Adventure friction but still uses active tree access:

- up to two active trees
- only active-tree passives can be selected
- changing active trees removes no-longer-valid passives and rotation skills

## Gear Rules

Current gear slots:

- weapon
- trinket
- charm

Gear can modify:

- player stats
- physical skill damage
- poison stack application
- armor reduction
- skill triggers
- unlocked skills
- poison tick cadence
- minimum execution time proc chance
- claimed gold rewards

Gold Reward affixes are reward-only and do not affect combat damage.

## Generated Gear Tiers

Generated reward and shop gear currently supports:

- Basic: one positive affix
- Master: two positive affixes
- Cursed: one amplified positive affix, one Master positive affix, one downside

Cursed downside affixes are combat downsides when possible.

## Legendary Gear Rules

Current authored Legendary weapons:

- Wyvern Kriss: poison stack and poison damage support, plus poison ticks twice
  as fast.
- Bandit Blade: physical damage, crit chance, and `+1` physical damage per `10`
  current gold.
- Umbral Stiletto: crit payoff and unlocks Death Strike.
- Mithril Karambit: attack speed, crit chance, and chances to trigger Stab or
  Heavy Slash.
- Bejeweled Push Dagger: physical damage, high crit chance, and a `20%` chance
  for normal casts to use minimum execution time.

Triggered skills resolve immediately and do not consume cast time.

## Rewards

Encounter rewards can grant:

- gold
- talent points
- fixed gear item IDs

Gold rewards are modified by equipped Gold Rewards affixes. Multiple Gold
Rewards modifiers compound multiplicatively, then the final award is rounded and
clamped at `0` or higher.

## Shop

The Tavern shop unlocks after the second Tavern fight.

- The shop presents four generated items per shop round.
- A shop reroll can be used once per Tavern/shop round.
- Tavern shop generated gear is Basic before contract selection.
- Contract shop generation can roll Master and Cursed based on route depth.
- Current generated shop prices are Basic `18`, Master `32`, Cursed `40`.

## Adventure Failure

If the player fails an Adventure fight:

- the first failure for a given encounter gives a do-over and returns to build
  editing for that fight
- failing the same encounter again restarts the Adventure from class selection
  while preserving the run seed

Contract route failures mark the contract as failed.

## Contract Routing

The current contract is The Gilded Serpent Contract.

- The route starts with Door Guard or Portly Cook.
- Door Guard is the harder opener and has better reward quality.
- Portly Cook is the easier opener.
- Door Guard can lead to Sleeping Henchman or Cloaked Watchmen.
- Portly Cook can lead to Lazy Henchman or Patrolling Guard.
- All second-layer fights lead to Knives.
- Knives leads to Vyra.
- Defeating Vyra marks contract victory.

## Training Room

Training Room is a freeform mechanics lab.

Controls include:

- active Rogue trees
- passives
- gear quality and affixes
- Legendary weapon choice
- rotation
- target
- combat duration
- seed
- practice gold

Training Room uses the same build resolver and combat simulator as Adventure.

