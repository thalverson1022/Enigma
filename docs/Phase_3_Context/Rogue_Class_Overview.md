# Rogue Class Overview

## Purpose

This document summarizes the current Rogue implementation for Phase 3 UX,
animation, and presentation work.

For raw source of truth, inspect:

- `project/data/classes/rogue.tres`
- `project/data/subclass_trees/*.tres`
- `project/data/talents/*/*.tres`
- `project/data/skills/*.tres`
- `project/data/gear/*.tres`

## Rogue Identity

Rogue is the only fully playable class at Phase 2 closeout. Mage and Crusader
remain non-playable future classes.

The Rogue fantasy in the current build is fast, opportunistic, and sharp:

- Small rotation choices matter.
- Poison can turn modest hits into reliable damage.
- Armor shred enables physical builds against armored targets.
- Proc and retrigger effects create burst and variance.
- Gear can push builds toward crit, poison, armor reduction, speed, or gold
  scaling.

## Base Rogue

Base skills:

| Skill | ID | Cast | Min Cast | Effects |
|---|---|---:|---:|---|
| Stab | `skill.stab` | 1500 ms | 700 ms | 18 physical |
| Heavy Slash | `skill.heavy_slash` | 2200 ms | 900 ms | 30 physical |

Base stats come from `project/data/player/rogue_starter.tres`.

Known base values used by tests and tooltips:

- Crit chance: 15%.
- Crit multiplier: 200%.
- Physical damage multiplier: 1.0.
- Poison damage: 8.0 per tick.
- Poison tick interval multiplier: 1.0.

## Subclass Trees

The Rogue has three subclass trees:

- Assassin
- Thief
- Shadow

Adventure starts with one primary tree. Later, The Gilded Serpent flow grants
a secondary Rogue tree choice.

## Assassin

Assassin leans into poison and critical scaling.

Talents:

| Talent | Cost | Effect |
|---|---:|---|
| Venom Edge | 1 | +4 poison damage, unlocks Venom Jab |
| Precise Cuts | 1 | +5% crit chance |
| Lethal Intent | 1 | +25% crit multiplier, requires Venom Edge or Precise Cuts |
| Toxic Technique | 2 | +2 poison stacks applied, unlocks Poison Strike, requires Lethal Intent |
| Perfect Toxin | 3 | x1.20 poison damage, requires Toxic Technique |

Skills commonly associated with Assassin:

| Skill | ID | Cast | Min Cast | Effects |
|---|---|---:|---:|---|
| Venom Jab | `skill.venom_jab` | 1000 ms | 500 ms | 4 physical, applies 8 poison stacks |
| Poison Strike | `skill.poison_strike` | 1500 ms | 700 ms | 15 physical, applies 1 poison stack |

## Thief

Thief leans into speed, physical scaling, armor reduction, and opportunistic
procs.

Tree unlock:

- Quick Cut is unlocked by selecting Thief.

Talents:

| Talent | Cost | Effect |
|---|---:|---|
| Quick Hands | 1 | +5% attack speed |
| Piercing Blades | 1 | x1.08 physical damage, unlocks Rending Slash |
| Practiced Rhythm | 1 | +10% attack speed and x1.10 physical damage, requires Quick Hands or Piercing Blades |
| Opportunity Strikes | 2 | Quick Cut has 20% chance to trigger Rending Slash, requires Practiced Rhythm |
| Sunder | 3 | +20 bonus armor reduction, requires Opportunity Strikes |

Skills commonly associated with Thief:

| Skill | ID | Cast | Min Cast | Effects |
|---|---|---:|---:|---|
| Quick Cut | `skill.quick_cut` | 850 ms | 500 ms | 12 physical |
| Rending Slash | `skill.rending_thrust` | 1400 ms | 650 ms | 14 physical, -20 armor |

## Shadow

Shadow leans into poison, poison vulnerability, and stack-aware finishers.

Intrinsic:

- Stab and Heavy Slash apply +1 poison stack that ticks for poison damage.

Talents:

| Talent | Cost | Effect |
|---|---:|---|
| Lingering Venom | 1 | +2 poison damage |
| Exposed Weakness | 1 | Unlocks Beguiling Strike |
| Black Lotus | 1 | +5% crit chance and x1.10 physical damage, requires Lingering Venom or Exposed Weakness |
| Nightblade Rhythm | 2 | +2 poison stacks applied, requires Black Lotus |
| Umbral Pressure | 3 | Unlocks Death Strike, requires Nightblade Rhythm |

Skills commonly associated with Shadow:

| Skill | ID | Cast | Min Cast | Effects |
|---|---|---:|---:|---|
| Beguiling Strike | `skill.toxic_flurry` | 1700 ms | 650 ms | 4 physical, reduces poison resistance by 50% |
| Death Strike | `skill.killers_mark` | 1500 ms | 650 ms | 20 physical plus 1 physical per active poison stack |

## Legendary Rogue Gear

All 5 Phase 1 Rogue Legendaries are implemented.

| Gear | Slot | Core Effects | Flavor Text |
|---|---|---|---|
| Mithril Karambit | Weapon | +20% attack speed, +10% crit chance, Stab and Heavy Slash each have their own 20% retrigger | Stab/Heavy Slash have a 20% chance to retrigger |
| Bandit Blade | Weapon | x1.20 physical damage, +20% crit chance, +1 physical damage per 10 gold | +1 physical damage per 10 gold in stash |
| Wyvern Kriss | Weapon | +2 poison stacks, x1.40 poison damage, poison tick interval x0.5 | Poison ticks twice as fast |
| Umbral Stiletto | Weapon | +10% crit chance, +100% crit multiplier, unlocks Death Strike | Unlocks Death Strike |
| Bejeweled Push Dagger | Weapon | x1.20 physical damage, +40% crit chance, 20% min-cast proc | 20% chance for skills to cast lightning fast |

Other seeded named gear:

- Lucky Coin: Trinket, Basic, +5% crit chance.

## Rogue Gear Slots

The implemented gear model currently uses:

- Weapon
- Trinket
- Charm

Rogue display names map those to:

- Dagger
- Ring
- Necklace

There is also visual equipment-doll language for Rogue gear art. Be careful
not to assume all visual slot labels are fully generalized for future classes.

## UX Notes For Phase 3

Rogue is already mechanically dense enough for Phase 3 animation work. The
best presentation improvements will make the existing mechanics easier to
read:

- Show poison stacks and ticks clearly.
- Distinguish crits from normal hits.
- Distinguish triggered skills from ordinary casts.
- Make armor reduction feel persistent and cumulative.
- Make poison resistance reduction visibly different from armor reduction.
- Make min-cast procs read as a timing event, not only a bigger DPS number.
- Make Legendary gear feel special in reward, inventory, equipped, and combat
  moments.

## Scope Notes

Do not add Mage or Crusader in Phase 3 unless the user explicitly changes the
scope. They are class-select placeholders and belong to later content work.

Do not overhaul monster/encounter design in this phase. Use Rogue presentation
needs to inform Phase 4 notes, but keep the current enemy roster stable unless
a change is required to test animation or UI behavior.

