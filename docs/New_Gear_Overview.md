# New Gear Overview

## Purpose

This document defines the Phase 5 gear redesign for Project Enigma. It is the
design reference for the new item model, including equipment slots, Rogue item
names, rarity rules, stat pools, weapon-damage scaling, special effects, Lucky
Coin handling, and open questions for later tuning.

Phase 5 treats gear as the main player-facing answer to generated enemy
pressure. Generated routes can now ask the player to care about armor, dodge,
block, absorb, cleanse, suppress, crit negation, slows, stuns, interrupts, and
resistance. The new gear model should give players readable ways to specialize,
hedge, or gamble against those problems without exposing raw generator internals.

## Design Goals

- Expand equipment from three functional slots to five universal slots.
- Keep universal equipment slots stable across future classes.
- Use class-specific item names and sprites inside those universal slots.
- Replace the old gear model except for Lucky Coin.
- Make item rarity change both power and decision texture.
- Separate general power, matchup answers, and high-risk drawbacks.
- Preserve deterministic generation, save/load behavior, and sparse previews.
- Let Shop Lab, Practice Room, and Balance Lab validate item feel before broad
  Adventure balance tuning.

## Universal Slots

All classes use the same five equipment slots:

- `Weapon`
- `Helm`
- `Armor`
- `Trinket`
- `Charm`

Rogue currently fills those slots with:

| Slot | Rogue Item Name |
| --- | --- |
| Weapon | Dagger |
| Helm | Hood |
| Armor | Doublet |
| Trinket | Ring |
| Charm | Necklace |

The Rogue names are display names and item-family identities. They do not imply
that future classes need separate stat rules. The long-term goal is for all
non-legendary gear rules to remain broadly generic across classes.

## Rarity Tiers

| Rarity | Color | Rule |
| --- | --- | --- |
| Crude | Gray | Placeholder rarity for the starting weapon only. No Crude items should generate beyond the starting Crude Dagger. |
| Basic | Green | 1 Basic stat. |
| Master | Blue | 2 Basic stats with increased values. |
| Epic | White | 3 Basic stats and 1 Rare stat with increased values. Epic should receive a visual treatment, such as shimmer, so it feels distinct despite using white. |
| Cursed | Purple | 2 Basic stats and 1 Rare stat with massive values, plus 1 negative Basic-stat drawback. |
| Chaos | Black | 5 stats from the Basic or Rare pools. Each stat may be a massive increase or a drawback. There are no constraints; Chaos should feel like a true gamble. |
| Unique | Yellow | 3 Basic stats and 1 Rare stat with increased values, plus 1 Special stat. |
| Legendary | Orange | 2 Basic stats and 1 Rare stat, plus a build-defining class-specific legendary effect. |

Special stats are currently Unique-only. This may change after testing.

Legendaries are handcrafted class-specific items. Existing Rogue legendaries
should be retained during Phase 5, but their fixed stats must be adjusted to the
new gear model. A deeper legendary redesign is deferred until the later
talent-tree rework.

## Stat Categories

### Basic Stats

- Base Damage
- Percent Damage
- Increased Attack Speed
- Crit Chance
- Crit Damage
- Base Elemental Damage
- Percent Elemental Damage
- Increased Shred Stacks
- Increased Decay Stacks
- Increased Elemental Stacks
- Increased Gold

Base Damage adds directly to the weapon's base damage before physical skill
scaling is calculated.

Base Elemental Damage adds flat elemental damage. In Phase 5, Rogue only uses
poison as its elemental damage type, but the stat should remain generic enough
to support future class elements.

Percent Elemental Damage increases all elemental damage types. In Phase 5 this
effectively means poison damage for Rogue.

Increased Shred Stacks, Increased Decay Stacks, and Increased Elemental Stacks
are distinct stat rolls. Increased Elemental Stacks currently means poison
stacks for Rogue.

Increased Gold applies when gold is added to the player's stash. It does not
create shop discounts.

### Rare Stats

- Chance for Retrigger
- Chance to Shred
- Chance to Decay
- Crit Applies Element

In Phase 5, `Crit Applies Element` can only roll as crits applying poison. The
wording should remain future-facing enough to support other class elements later.

### Special Stats

- Enemies can no longer dodge.
- Enemies can no longer block.
- Enemies can no longer cleanse.
- Enemies can no longer stun.
- Enemies can no longer slow.
- Enemies can no longer interrupt.
- You ignore armor, but can no longer apply shred.
- You ignore resistance, but your physical damage is reduced by 50%.
- Stacks you apply are doubled.
- All of your damage is now physical.
- All of your damage is now magical.
- All stats are increased by 20%.
- You are immune to stun, slow, and interrupt.

Enemy-denial specials choose one denied behavior. For example, an item may roll
`Enemies can no longer dodge`, causing the player's attacks to behave as if enemy
dodge were 0% while the item is equipped.

Enemy stun, slow, and interrupt denial prevents enemies from applying that
condition to the player. Player immunity prevents the listed conditions from
affecting the player while the item is equipped.

Ignoring armor means player physical damage behaves as if enemy armor were 0,
but shred has no effect. This prevents the player from creating negative armor
while the item is equipped.

Ignoring resistance means player elemental damage behaves as if enemy resistance
were 0, with the drawback that physical damage is reduced by 50%.

Stacks doubled applies after flat stack increases. For example, if a skill
normally applies 1 poison and gear adds +1 poison stack, the doubled result is 4
poison stacks.

Damage conversion changes the final damage type that reaches enemy mitigation.
Damage converted to physical is mitigated by armor and block instead of
resistance and absorb. Damage converted to magical is mitigated by resistance
and absorb instead of armor and block.

All stats increased by 20% affects the stat sheet except for the base weapon
damage range. This needs testing because its power level is uncertain.

## Slot Stat Pools

### Weapon

Rogue item name: Dagger.

Basic stats:

- Base Damage
- Percent Damage
- Crit Damage
- Base Elemental Damage
- Percent Elemental Damage
- Increased Gold

Rare stats:

- Chance to Shred
- Chance to Decay
- Chance for Retrigger

Special stats:

- All of your damage is now physical.
- All of your damage is now magical.
- All stats are increased by 20%.

### Helm

Rogue item name: Hood.

Basic stats:

- Percent Damage
- Crit Chance
- Increased Attack Speed
- Base Elemental Damage
- Percent Elemental Damage
- Increased Shred Stacks
- Increased Decay Stacks
- Increased Elemental Stacks
- Increased Gold

Rare stats:

- Chance to Shred
- Chance to Decay
- Crit Applies Element

Special stats:

- Stacks you apply are doubled.
- You ignore armor, but can no longer apply shred.
- You ignore resistance, but your physical damage is reduced by 50%.

### Armor

Rogue item name: Doublet.

Basic stats:

- Percent Damage
- Percent Elemental Damage
- Increased Gold
- Increased Shred Stacks
- Increased Decay Stacks
- Increased Elemental Stacks

Rare stats:

- Chance to Shred
- Chance to Decay
- Crit Applies Element

Special stats:

- All stats are increased by 20%.
- Enemies can no longer dodge, block, cleanse, stun, slow, or interrupt.
- You are immune to stun, slow, and interrupt.

### Trinket

Rogue item name: Ring.

Basic stats:

- Base Damage
- Percent Damage
- Crit Chance
- Increased Attack Speed
- Base Elemental Damage
- Percent Elemental Damage
- Increased Gold

Rare stats:

- Chance for Retrigger
- Chance to Shred
- Chance to Decay
- Crit Applies Element

Special stats:

- Stacks you apply are doubled.
- Enemies can no longer dodge, block, cleanse, stun, slow, or interrupt.
- All of your damage is now physical.
- All of your damage is now magical.

### Charm

Rogue item name: Necklace.

Basic stats:

- Percent Damage
- Crit Chance
- Increased Attack Speed
- Crit Damage
- Base Elemental Damage
- Percent Elemental Damage
- Increased Gold
- Increased Shred Stacks
- Increased Decay Stacks
- Increased Elemental Stacks

Rare stats:

- Chance to Shred
- Chance to Decay
- Crit Applies Element

Special stats:

- You ignore armor, but can no longer apply shred.
- You ignore resistance, but your physical damage is reduced by 50%.
- Stacks you apply are doubled.
- Enemies can no longer dodge, block, cleanse, stun, slow, or interrupt.

## Weapon Damage

Physical skill damage is tied to weapon damage. The weapon damage range is rolled
once per skill cast. If a skill retriggers, the retrigger is a new cast and rolls
weapon damage again.

The weapon roll must be deterministic from combat state so combat playback,
save/load, and seeded validation remain stable.

Flat Base Damage from gear adds directly to the weapon damage before skill
percentage scaling. The scaled value is rounded to the nearest integer.

Elemental damage does not scale from weapon damage. Elemental damage continues
to use flat elemental values and elemental percentage increases.

### Rogue Dagger Damage Ranges

| Rarity | Range | Average |
| --- | --- | --- |
| Crude | 16-20 | 18 |
| Basic | 17-19 | 18 |
| Master | 17-21 | 19 |
| Epic | 18-20 | 19 |
| Cursed | 17-23 | 20 |
| Chaos | 16-25 | 21 |
| Unique | 19-25 | 22 |
| Legendary | 20-26 | 23 |

### Rogue Skill Weapon Scaling

| Skill | Current Physical Damage Reference | Weapon Damage Scaling |
| --- | --- | --- |
| Stab | 18 | 100% |
| Heavy Slash | 30 | 166% |
| Quick Cut | 12 | 66% |
| Steal | 19 | 106% |
| Venom Jab | 4 | 22% |
| Poison Strike | 15 | 83% |
| Rending Slash | 14 | 78% |
| Beguiling Strike | 4 | 22% |
| Death Strike | 20 | 111% |

Any Rogue skill with physical damage should use weapon scaling. Death Strike's
bonus damage from poison stacks should be treated like base damage and added
directly to weapon damage before scaling.

## Lucky Coin

Lucky Coin survives the gear overhaul as a homage to the earliest stages of
development. It becomes a Basic item with one Basic stat. That stat is always
Crit Chance.

## Generation And Rewards

Random gear generation should not read upcoming route or enemy pressure directly.
The player should choose from generated options and decide which item answers the
route state best.

Shops and rewards should use the same underlying item model, but their weighting
can differ during tuning. The starting assumption is a decreasing probability of
higher rarity appearing in the shop, with rarer items becoming more likely as the
player gets deeper into contracts.

Lower rarity items can remain useful when they have clean, specific rolls.
Higher rarity should offer stronger possibilities, but drawbacks and stat
alignment should prevent rarity from being the only decision.

## Validation Surfaces

Shop Lab should be updated early in Phase 5 to simulate the new gear generator.
It should support repeated rolls of shop offers, rarity distributions, slot
pools, Cursed drawbacks, Chaos outcomes, Unique specials, and contract-depth
scaling.

Practice Room should support the new slots and stat effects so individual builds
can be tested without mutating Adventure state.

Balance Lab should support deterministic validation for item generation, stat
aggregation, weapon rolls, combat compatibility, and special-effect behavior.

## Deferred Decisions

- Exact stat value ranges by slot and rarity.
- Final rarity distribution by contract depth.
- Whether Special stats should remain Unique-only after testing.
- Exact Epic visual treatment.
- Final power level for `All stats are increased by 20%`.
- Full legendary redesign after the later talent-tree rework.
- Future class elemental types and possible cross-class elemental item behavior.
