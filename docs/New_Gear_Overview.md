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

## Core Model Decisions

Phase 5 replaces the old gear model with five universal equipment slots:
Weapon, Helm, Armor, Trinket, and Charm. Rogue items use class-flavored display
families for those slots: Dagger, Hood, Doublet, Ring, and Necklace.

Generated gear uses the Crude, Basic, Master, Epic, Cursed, Chaos, Unique, and
Legendary rarity tiers. Crude is reserved for the starting Dagger only. Other
rarities define how many Basic, Rare, Special, and drawback stats an item
carries; exact stat weights and value scaling are handled in later P5M1 tasks.

Rogue physical skills scale from deterministic weapon damage rolls. Dagger
damage ranges are defined by rarity, and each physical Rogue skill has a fixed
weapon-scaling percentage. Elemental damage does not scale from weapon damage.

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
| Epic | White | 2 Basic stats and 1 Rare stat with increased values. Epic should receive a visual treatment, such as shimmer, so it feels distinct despite using white. |
| Cursed | Purple | 2 Basic stats and 1 Rare stat with massive values, plus 1 negative Basic-stat drawback. |
| Chaos | Black | 4 stat rolls. Each roll may be a massive positive Basic or Rare stat, or a massive Basic-stat drawback. There is no safety guarantee; Chaos should feel like a true slot-machine gamble. |
| Unique | Yellow | 3 Basic stats and 1 Rare stat with increased values, plus 1 Special stat. |
| Legendary | Orange | Fixed handcrafted stat package, plus a build-defining class-specific legendary effect. |

Special stats are currently Unique-only. This may change after testing.

Legendaries are handcrafted class-specific items. Existing Rogue legendaries
should be retained during Phase 5, but their fixed stats must be adjusted to the
new gear model. A deeper legendary redesign is deferred until the later
talent-tree rework.

## Legendary Boundary

P5M1 defines the Legendary boundary and target upgraded stat packages. P5M10
implemented and validated the retained Rogue Legendary resources against those
target packages. Legendary items do not use random stat rolls, rarity value
multipliers, Cursed or Chaos drawback rules, or Unique Special rolls. A
generator or reward system may choose a fixed Legendary from a catalog, but it
must not procedurally roll Legendary stats.

Current Phase 5 Rogue legendaries are all Weapon-slot items with unique display
names. They should not display as generic Dagger-family items, though they remain
Rogue dagger weapons mechanically. Legendary effects are allowed to break normal
gear rules as long as each exception is explicit in the handcrafted definition.

Existing Rogue legendary effects are retained for Phase 5 with upgraded stats.
After the later talent-tree redesign, new legendaries can be created around
talent synergies.

Lucky Coin is not Legendary. It remains a scripted Basic Trinket reward and does
not belong to the Legendary catalog.

P5M10 includes Practice Room and Balance Lab validation for each retained
Legendary. The validation confirms the fixed stat package, the legendary effect,
save/load compatibility, reward/equip behavior, and combat behavior.

Normal Phase 5 implementation should not introduce new procedural Legendary
drops or shop behavior beyond the fixed-catalog retained Legendary boundary,
except where existing authored content must remain available as a regression
baseline.

### Current Rogue Legendary Targets

| Legendary | Slot | Fixed Stats | Legendary Effect |
| --- | --- | --- | --- |
| Wyvern Kriss | Weapon | 21-27 Base Damage; +8 Base Elemental Damage; +40% Percent Elemental Damage; +12% Chance to Decay | Poison damage ticks twice as fast. |
| Bandit Blade | Weapon | 21-27 Base Damage; +20% Percent Physical Damage; +12% Crit Chance; +30% Increased Gold | +1 physical damage for every 10 gold in your stash. |
| Umbral Stiletto | Weapon | 21-27 Base Damage; +10% Crit Chance; +100% Crit Damage; +100% Chance for Crits to Apply Poison | Unlock Death Strike. |
| Mithril Karambit | Weapon | 21-27 Base Damage; +15% Increased Attack Speed; +15% Crit Chance; +20% Chance to Shred | Stab and Heavy Slash have a 50% chance to retrigger. |
| Bejeweled Push Dagger | Weapon | 21-27 Base Damage; +8 Base Damage; +20% Percent Physical Damage; +10% Crit Chance | 20% chance to reduce a skill to its minimum attack time. |

These target packages are allowed to bend the non-legendary stat-count model.
For example, a Legendary may have more or fewer Basic/Rare-equivalent stats than
the normal rarity table would imply, and its effect may use a bespoke mechanic.
P5M10 preserved the identity of each existing item and shipped these exact
values without additional retuning.

## Stat Categories

### Basic Stats

- Base Damage
- Percent Physical Damage
- Increased Attack Speed
- Crit Chance
- Crit Damage
- Base Elemental Damage
- Percent Elemental Damage
- Bonus Stacks
- Increased Gold
- Shop Discount
- Increased Magic Find

Base Damage adds directly to the weapon's base damage before physical skill
scaling is calculated.

Base Elemental Damage adds flat elemental damage. In Phase 5, Rogue only uses
poison as its elemental damage type, but the stat should remain generic enough
to support future class elements.

Percent Physical Damage increases physical damage only. It does not increase
elemental damage.

Percent Elemental Damage increases all elemental damage types. In Phase 5 this
effectively means poison damage for Rogue, and it does not increase physical
damage.

Bonus Stacks increases every player-applied stack type that currently exists:
poison, shred, and decay. It is one shared stat rather than separate poison,
shred, or decay stack rolls.

Increased Gold applies when gold is added to the player's stash. It does not
create shop discounts.

Shop Discount reduces generated shop item purchase prices only. It does not
reduce shop reroll costs, and purchase prices cannot drop below 1 gold for an
item that normally has a nonzero price.

Increased Magic Find improves item rarity-upgrade checks when rewards or shop
offers are generated. The currently equipped gear is evaluated before the new
item is created, so an item cannot improve its own rarity roll.

### Rare Stats

- Chance for Retrigger
- Chance to Shred
- Chance to Decay
- Chance for Crits to Apply Poison
- Increased Gold
- Shop Discount
- Increased Magic Find

Increased Gold, Shop Discount, and Increased Magic Find can also appear as Rare
stats. Their Rare baseline ranges are 10% stronger than the matching Basic
baseline ranges, rounded to whole displayed percentages.

In Phase 5, `Chance for Crits to Apply Poison` rolls only after a crit and
applies 1 normal poison stack before Bonus Stacks and stack-doubling effects.
Future classes may split this into element-specific versions.

### Special Stats

- Enemies can no longer dodge.
- Enemies can no longer block.
- Enemies can no longer absorb.
- Enemies can no longer suppress.
- Enemies can no longer cleanse.
- You ignore armor, but can no longer apply shred.
- You ignore resistance, but your physical damage is reduced by 50%.
- Stacks you apply are doubled.
- All of your damage is now physical.
- All of your damage is now magical.
- All stats are increased by 20%.
- You are immune to stun.
- You are immune to slow.
- You are immune to interrupt.

Enemy-denial specials choose one denied behavior. For example, an item may roll
`Enemies can no longer dodge`, causing the player's attacks to behave as if enemy
dodge were 0% while the item is equipped.

Player immunity specials are separate effects. Each one disables the matching
enemy stat while the item is equipped; for example, `You are immune to
interrupt` causes enemy interrupt to behave as if it were 0.

Ignoring armor means player physical damage behaves as if enemy armor were 0,
and enemy shred stacks are fixed at 0 while the item is equipped. This prevents
the player from creating negative armor while bypassing armor.

Ignoring resistance means player elemental damage behaves as if enemy resistance
were 0, with the drawback that original physical damage is reduced by 50% at
the end of damage calculation before conversion.

Stacks doubled applies after flat stack increases. For example, if a skill
normally applies 1 poison and gear adds +1 poison stack, the doubled result is 4
poison stacks.

Damage conversion changes the final damage type that reaches enemy mitigation.
Damage converted to physical is mitigated by armor and block instead of
resistance and absorb. Damage converted to magical is mitigated by resistance
and absorb instead of armor and block.

All stats increased by 20% applies once as a multiplicative boost to the final
non-negative stat sheet, except for the base weapon damage range. This needs
testing because its power level is uncertain.

## Slot Stat Pools

Economy stats are universal. Increased Gold, Shop Discount, and Increased Magic
Find are eligible on every slot's Basic and Rare pools; Rare versions use their
category-specific +10% baseline ranges.

### Weapon

Rogue item name: Dagger.

Basic stats:

- Base Damage
- Percent Physical Damage
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

- Percent Physical Damage
- Crit Chance
- Increased Attack Speed
- Base Elemental Damage
- Percent Elemental Damage
- Bonus Stacks
- Increased Gold

Rare stats:

- Chance to Shred
- Chance to Decay
- Chance for Crits to Apply Poison

Special stats:

- Stacks you apply are doubled.
- You ignore armor, but can no longer apply shred.
- You ignore resistance, but your physical damage is reduced by 50%.

### Armor

Rogue item name: Doublet.

Basic stats:

- Percent Physical Damage
- Crit Chance
- Percent Elemental Damage
- Increased Gold
- Bonus Stacks

Rare stats:

- Chance to Shred
- Chance to Decay
- Chance for Crits to Apply Poison

Special stats:

- All stats are increased by 20%.
- Enemies can no longer dodge, block, absorb, suppress, or cleanse.
- You are immune to stun.
- You are immune to slow.
- You are immune to interrupt.

### Trinket

Rogue item name: Ring.

Basic stats:

- Base Damage
- Percent Physical Damage
- Crit Chance
- Increased Attack Speed
- Base Elemental Damage
- Percent Elemental Damage
- Increased Gold

Rare stats:

- Chance for Retrigger
- Chance to Shred
- Chance to Decay
- Chance for Crits to Apply Poison

Special stats:

- Stacks you apply are doubled.
- Enemies can no longer dodge, block, absorb, suppress, or cleanse.
- All of your damage is now physical.
- All of your damage is now magical.

### Charm

Rogue item name: Necklace.

Basic stats:

- Percent Physical Damage
- Crit Chance
- Increased Attack Speed
- Crit Damage
- Base Elemental Damage
- Percent Elemental Damage
- Increased Gold
- Bonus Stacks

Rare stats:

- Chance to Shred
- Chance to Decay
- Chance for Crits to Apply Poison

Special stats:

- You ignore armor, but can no longer apply shred.
- You ignore resistance, but your physical damage is reduced by 50%.
- Stacks you apply are doubled.
- Enemies can no longer dodge, block, absorb, suppress, or cleanse.

## Stat Roll Weight Structure

Procedural gear uses weighted stat pools to choose item stats. Each equipment
slot has separate weighted pools for Basic, Rare, and Special stats. A weighted
entry contains a stat identifier and a non-negative weight:

```gdscript
{ "stat_id": "crit_chance", "weight": 10 }
```

Weights are relative inside one slot and stat category. For example, a Basic
Weapon stat with weight 20 is twice as likely to roll as another Basic Weapon
stat with weight 10, before any later rarity or tuning modifiers are applied. A
weight of 0 means the stat is valid for that slot and category but temporarily
disabled for random generation. Disabled entries should remain visible to Shop
Lab and Balance Lab so tuning can distinguish intentionally disabled stats from
missing or invalid definitions.

The item generator first determines slot and rarity, then uses rarity to decide
how many Basic, Rare, Special, and drawback stats the item requires. Each
positive stat is selected from that item's slot/category weighted pool. Cursed
and Chaos drawbacks use eligible Basic stats as negative rolls.

Generated non-Chaos items cannot roll duplicate stat identifiers on the same
item. This applies to Basic, Rare, Special, and drawback rolls. A stat that has
already rolled positive on a non-Chaos item cannot also roll as a drawback, and
a drawback stat cannot later roll positive on that same item. If a slot/category
pool cannot satisfy the required number of unique stats with positive-weight
entries, validation should fail loudly rather than silently duplicating stats or
selecting disabled entries.

Chaos is the intentional exception. Each of its four outcomes rolls from the
slot-eligible Basic positive, Rare positive, or Basic drawback pools without
same-item stat-ID exclusion. A perfect or cursed Chaos item can therefore roll
the same stat four times. Chaos positive Rare outcomes are weighted 20% lower
than positive Basic and drawback outcomes.

Weighted selection must be deterministic from the item generation seed path.
Random gear generation must not read upcoming route or enemy pressure directly;
the player should choose from generated options based on the visible route and
enemy information.

Shop Lab should expose rolled slot, rarity, stat category, stat identifier,
entry weight, and whether a stat is positive or a drawback. Balance Lab should
validate missing pools, zero-total pools, impossible unique-roll requests,
disabled-stat selection, and stat/category/slot mismatches.

## Provisional Stat Weights

These weights are first-pass Shop Lab inputs, not final balance targets. All
currently eligible stats are active. The initial weight scale is:

| Weight | Meaning |
| --- | --- |
| 0 | Valid but disabled for random rolling. |
| 5 | Niche or large-advantage stat. |
| 10 | Normal stat. |
| 15 | Favored stat for the slot. |
| 20 | Core slot identity stat. |

Weights are relative only within the same slot and stat category. Rarity decides
how many Basic, Rare, Special, and drawback rolls happen; these tables decide
which stat is selected for each required roll. Stats that create larger matchup
advantages are intentionally a little rarer even when they remain active.

### Basic Stat Weights

| Stat | Weapon | Helm | Armor | Trinket | Charm |
| --- | ---: | ---: | ---: | ---: | ---: |
| Base Damage | 20 | - | - | 15 | - |
| Percent Physical Damage | 15 | 10 | 15 | 15 | 10 |
| Increased Attack Speed | - | 15 | - | 15 | 15 |
| Crit Chance | - | 15 | 10 | 15 | 20 |
| Crit Damage | 15 | - | - | - | 15 |
| Base Elemental Damage | 10 | 10 | - | 10 | 10 |
| Percent Elemental Damage | 10 | 10 | 10 | 10 | 10 |
| Bonus Stacks | - | 10 | 10 | - | 10 |
| Increased Gold | 5 | 5 | 15 | 5 | 5 |
| Shop Discount | 5 | 5 | 5 | 5 | 5 |
| Increased Magic Find | 5 | 5 | 5 | 5 | 5 |

### Rare Stat Weights

| Stat | Weapon | Helm | Armor | Trinket | Charm |
| --- | ---: | ---: | ---: | ---: | ---: |
| Chance for Retrigger | 10 | - | - | 15 | - |
| Chance to Shred | 15 | 10 | 10 | 10 | 10 |
| Chance to Decay | 10 | 10 | 10 | 10 | 10 |
| Chance for Crits to Apply Poison | - | 10 | 10 | 10 | 15 |
| Increased Gold | 5 | 5 | 5 | 5 | 5 |
| Shop Discount | 5 | 5 | 5 | 5 | 5 |
| Increased Magic Find | 5 | 5 | 5 | 5 | 5 |

### Special Stat Weights

Enemy-denial specials are represented as individual weighted entries, not as one
combined stat.

| Stat | Weapon | Helm | Armor | Trinket | Charm |
| --- | ---: | ---: | ---: | ---: | ---: |
| Enemies can no longer dodge | - | - | 10 | 10 | 10 |
| Enemies can no longer block | - | - | 10 | 10 | 10 |
| Enemies can no longer absorb | - | - | 10 | 10 | 10 |
| Enemies can no longer suppress | - | - | 10 | 10 | 10 |
| Enemies can no longer cleanse | - | - | 10 | 10 | 10 |
| You ignore armor, but can no longer apply shred | - | 5 | - | - | 5 |
| You ignore resistance, but your physical damage is reduced by 50% | - | 5 | - | - | 5 |
| Stacks you apply are doubled | - | 5 | - | 5 | 5 |
| All of your damage is now physical | 5 | - | - | 5 | - |
| All of your damage is now magical | 5 | - | - | 5 | - |
| All stats are increased by 20% | 5 | - | 5 | - | - |
| You are immune to stun | - | - | 5 | - | - |
| You are immune to slow | - | - | 5 | - | - |
| You are immune to interrupt | - | - | 5 | - | - |

## Stat Value Scaling Framework

Procedural stats roll a base value from the item slot's Basic-rarity range,
then apply rarity scaling and any later contract-depth scaling. Slot identity is
expressed through slot-specific base ranges and roll weights, not through a
separate slot value multiplier.

The first-pass rarity multipliers are:

| Rarity | Value Multiplier |
| --- | ---: |
| Crude | Fixed starting weapon only. |
| Basic | 1.00x |
| Master | 1.75x |
| Epic | 2.00x |
| Cursed positive stat | 2.50x |
| Cursed drawback stat | -2.50x |
| Chaos positive stat | 3.00x |
| Chaos drawback stat | -3.00x |
| Unique | 2.00x |
| Legendary | Fixed handcrafted package. |

Cursed and Chaos drawbacks use Basic stats as negative rolls. Lucky Coin
bypasses normal value scaling and is always a Basic Trinket/Ring with +5% Crit
Chance.

Contract-depth value scaling should be represented as a deterministic hook after
rarity scaling, but the default P5M1 multiplier is 1.00x. Shop Lab and later
Adventure integration can tune depth scaling without changing the base item
model.

Value generation order:

1. Roll a base value from the slot/stat baseline range.
2. Apply the rarity value multiplier.
3. Apply the contract-depth value multiplier, defaulting to 1.00x.
4. Round once at the end.

Integer stats such as Base Damage, Base Elemental Damage, and stack increases
round to the nearest integer. Positive stack rolls should never round below +1.
Percentage and chance stats use decimal values internally and display as
percentages in the UI; for example, `0.05` displays as `+5%`. Percentage and
chance display values round to the nearest whole percentage unless a later UI
task decides a specific stat needs decimal display precision.

Special stats do not roll numeric magnitudes. They are fixed binary effects
unless the special text defines its own fixed value, such as `All stats are
increased by 20%` or `your physical damage is reduced by 50%`.

## Cursed And Chaos Drawbacks

Cursed and Chaos items use drawbacks to create high-risk gear decisions. A
drawback is a negative Basic stat from the item's slot-eligible Basic stat pool.
All Basic stats that can roll positively for that slot can also roll negatively
as drawbacks, including damage, attack speed, crit, elemental, stack, and gold
stats.

Cursed items roll 2 positive Basic stats, 1 positive Rare stat, and 1 Basic-stat
drawback. The positive stats use the Cursed positive multiplier of 2.50x. The
drawback uses the Cursed drawback multiplier of -2.50x. Cursed items should hurt:
the drawback is intentionally close to the positive stat magnitude, but remains
build-around rather than automatically run-ending.

Chaos items make 4 independent stat rolls. Each roll first determines whether it
is a positive Basic stat, positive Rare stat, or drawback. Positive Chaos rolls
may use Basic or Rare stat pools. Drawback Chaos rolls use only Basic stat pools
for the current baseline because negative Rare-stat mechanics need a separate
design pass. Chaos has no minimum positive roll guarantee, no maximum drawback
limit, and no same-item duplicate protection; an all-drawback Chaos item or a
four-copy same-stat Chaos item is valid. Positive and drawback Chaos stats both
use 3.00x magnitude, with drawbacks applying the negative sign. Rare positive
Chaos outcomes are weighted 20% lower than Basic positive and drawback outcomes.

Drawbacks follow the same deterministic base range, contract-depth hook, and
rounding rules as positive stats, then apply their negative rarity multiplier.
Integer drawbacks round once at the end. Stack drawbacks can reduce bonus stack
stats from other gear, but they cannot make a skill apply negative stacks.

After all equipped gear is aggregated, base stats are floored according to their
mechanical minimums, while percentage damage and speed bonuses may go negative
and reduce the final result below the unmodified baseline. Weapon damage plus
Bonus Physical Damage cannot fall below 1-1; Base Poison Damage cannot fall
below 1.0; Crit Chance cannot fall below 0%; Crit Damage cannot fall below
1.0x. Physical Damage Increase, Poison Damage Increase, and Attack Speed can be
negative and reduce the resulting damage or attack rate.

Generated non-Chaos items cannot contain the same `stat_id` more than once,
regardless of category or sign. A positive Base Damage roll and a Base Damage
drawback on the same non-Chaos item are invalid duplicates. Chaos intentionally
breaks this rule and can roll duplicate positives or drawbacks.

Rare-stat drawbacks are intentionally deferred. The current baseline does not
define negative versions of Chance for Retrigger, Chance to Shred, Chance to
Decay, or Chance for Crits to Apply Poison. They may be revisited after Shop Lab
exposes whether Basic-only drawbacks give Chaos enough volatility.

## Stack And Status Interactions

Bonus Stacks only improves skills or effects that already apply a stack type.
It increases every current player-applied stack type: poison, shred, and decay.
For Rogue in Phase 5, elemental stacks are poison stacks because poison is the
only current elemental damage/status type.

Bonus Stacks cannot create a new status on its own. A skill that applies 0
poison stacks still applies 0 poison stacks from Bonus Stacks unless another
effect, such as `Chance for Crits to Apply Poison`, causes that skill to apply
poison.

`Chance for Crits to Apply Poison` is the exception that lets non-elemental
skills create elemental pressure. In Phase 5, it rolls as a chance for a crit to
apply 1 poison stack. This poison stack is a normal poison application, so all
relevant gear and talent bonuses apply to it, including Bonus Stacks and
`Stacks you apply are doubled`. Poison applied this way ticks on the global
1.0-second poison timer.

Stack calculation order is:

1. Start with the skill or effect's base stacks.
2. Add Bonus Stacks from gear and matching flat stack increases from talents.
3. Apply `Stacks you apply are doubled` if active.
4. Floor the final stacks applied at 0.

`Stacks you apply are doubled` is a binary Special effect. Multiple copies do
not stack or multiply again. If any equipped item grants the effect, the
doubling applies once.

If a hit is dodged, attached damage and attached stacks do not apply. If the
player has `Enemies can no longer dodge`, enemy dodge behaves as 0 and the hit
can connect normally. If a hit connects but its physical damage is reduced to 0
by block, attached triggers and stacks still apply. Block reduces physical
damage; it does not undo the hit.

Absorb reduces elemental damage but does not prevent elemental stacks. Suppress
keeps its current combat behavior for P5M1; `Enemies can no longer suppress`
disables the enemy suppress mechanic while equipped. `Enemies can no longer
cleanse` disables all enemy cleanse behavior, including generated cleanse
thresholds, while equipped.

Player immunity specials are separate binary Special effects: `You are immune to
stun`, `You are immune to slow`, and `You are immune to interrupt`. Each one
disables only the matching enemy stat while equipped. For example, an enemy with
interrupt 2/3 behaves as if its interrupt stat were absent while `You are immune
to interrupt` is active, but its stun and slow mechanics still work unless those
immunities are also equipped.

Shred is now a universal debuff. Each application adds shred stacks, and each
stack reduces enemy armor by the player's current shred value. The base shred
value is 10 armor per stack. Bonus Armor Shred increases that per-stack armor
reduction; for example, +10 Bonus Armor Shred makes each shred stack reduce
armor by 20.

Decay is now a universal debuff. Each application adds decay stacks, and each
stack multiplies the enemy's current resistance by `(1 - decay_value)`. The base
decay value is 20%. For example, one base decay stack turns 50% resistance into
40%; if Bonus Resist Decay raises the decay value to 40%, one stack turns 50%
resistance into 30%.

Example stack application: a Rogue skill that normally applies 1 poison stack
has +1 Bonus Stacks and `Stacks you apply are doubled`. It applies
`(1 + 1) * 2 = 4` poison stacks.

Example crit application: a physical Rogue skill that normally applies no poison
crits while `Chance for Crits to Apply Poison` succeeds. The proc starts at 1
poison stack. With +1 Bonus Stacks and `Stacks you apply are doubled`, it
applies `(1 + 1) * 2 = 4` poison stacks.

## Stat Stacking Rules

Generated non-Chaos items cannot contain duplicate `stat_id` entries, but
different equipped items can grant the same stat. Chaos items may contain
duplicate `stat_id` entries by design. Equipped Basic and Rare stats stack
additively unless a stat explicitly says otherwise. Positive stats and drawbacks
for the same stat add into one aggregate value before floors, caps, and
stat-sheet multipliers are applied.

Basic stat stacking rules:

- Base Damage adds across equipped gear before physical skill weapon scaling.
- Percent Physical Damage adds into the gear physical damage bucket.
- Increased Attack Speed adds inside the gear attack-speed bucket, then that
  bucket is applied against other future attack-speed buckets.
- Crit Chance adds across gear and other sources, then caps at 100%.
- Crit Damage adds into the crit multiplier stat.
- Base Elemental Damage adds across equipped gear before elemental percent
  damage buckets.
- Percent Elemental Damage adds into the gear elemental damage bucket.
- Bonus Stacks adds to poison, shred, and decay stack applications before
  `Stacks you apply are doubled`.
- Increased Gold adds across equipped gear and other sources, then floors at 0.

Rare chance stats stack additively, then cap at 100%. This applies to Chance for
Retrigger, Chance to Shred, Chance to Decay, and Chance for Crits to Apply Poison. Chance
overflow has no extra effect: 125% is treated as 100%, not as a guaranteed proc
plus a 25% secondary proc. In practice, Chance for Retrigger should be tuned so
normal legal builds cannot reach 100%, because guaranteed recursive retriggers
would risk breaking combat pacing.

Drawbacks add into the same aggregate stat as positives. For example, +25%
Percent Physical Damage and -18% Percent Physical Damage produce +7% Percent
Physical Damage in the gear physical damage bucket. Final aggregate stat values
floor at 0, as defined in the Cursed and Chaos drawback rules.

Special stats are binary. Multiple equipped copies of the same Special are
allowed, but duplicate copies do not stack, multiply, or improve the effect.
`Stacks you apply are doubled` only doubles once. `All stats are increased by
20%` only applies once.

Different Specials can combine. For example, one equipped item can disable enemy
dodge while another disables enemy block, and both denial effects apply. This
kind of multi-Special coverage is an intended endgame chase goal.

`All stats are increased by 20%` boosts the final stat sheet, not individual
items. First aggregate positive stats and drawbacks, apply floors and caps, then
apply the 20% stat-sheet multiplier once. It does not make item drawbacks more
negative, and it does not modify the base weapon damage range.

Example additive gear bucket: two equipped items grant +15% and +20% Percent
Physical Damage. The gear physical damage bucket is +35%, so that bucket applies
as a 1.35x multiplier in the damage calculation order.

Example binary Special: two equipped items grant `Enemies can no longer dodge`.
Enemy dodge is disabled once. There is no additional benefit from the duplicate
copy.

## Special Conflict Rules

Special effects are resolved silently in combat. The item UI does not need to
warn players about weak or punitive combinations during P5M1; Practice Room and
Shop Lab should make those interactions learnable through testing.

Duplicate copies of the same Special are allowed across equipped items, but the
effect is binary and applies once. Different Specials combine freely unless this
section defines a specific interaction.

Enemy-denial Specials combine freely. If one equipped item says enemies can no
longer dodge and another says enemies can no longer block, both enemy stats are
disabled. This is an intended endgame chase pattern. Player-immunity Specials
also combine freely: stun, slow, and interrupt immunity are separate binary
effects, and each disables only the matching enemy stat.

Damage conversion uses final damage type for mitigation. If damage is converted
to physical, `You ignore armor, but can no longer apply shred` applies to that
physical mitigation pass. If damage is converted to magical or elemental, `You
ignore resistance, but your physical damage is reduced by 50%` applies to that
elemental mitigation pass.

If both `All of your damage is now physical` and `All of your damage is now
magical` are active, the damage packet counts as both types and is mitigated
twice. The physical mitigation pass happens first, then the elemental mitigation
pass. If matching ignore effects are also active, each ignore effect applies to
its matching pass: ignore armor skips armor during the physical pass, and ignore
resistance skips resistance during the elemental pass.

`You ignore armor, but can no longer apply shred` sets enemy armor to 0 for
player damage and fixes enemy shred stacks at 0 while equipped. Existing shred
stacks have no effect. New shred applications from skills, Chance to Shred,
Bonus Stacks, or other future player sources are prevented while the Special is
active.

`You ignore resistance, but your physical damage is reduced by 50%` applies the
50% penalty to damage packets that began as physical. Apply the penalty at the
end of damage calculation after crit and damage buckets, but before conversion
and mitigation. If original physical damage is later converted to magical, it
still suffers this penalty. If original elemental damage is converted to
physical, it does not suffer this penalty because it did not begin as physical.

`All stats are increased by 20%` has no special conflict with other Specials. It
boosts the final stat sheet once after aggregation and before final caps. It
does not multiply fixed Special text constants such as `your physical damage is
reduced by 50%`, and it does not modify the base weapon damage range.

`Stacks you apply are doubled` has no conflict with stack increases or Chance
for Crits to Apply Poison. It applies once after all flat stack increases,
including stack bonuses applied to poison from Chance for Crits to Apply Poison.

Special combinations are not blocked during item generation, except for the
normal same-item duplicate `stat_id` rule on non-Chaos items. Odd, redundant,
or punitive combinations can roll and should be evaluated in Shop Lab before
any later pruning rules are added.

Example ignore/conversion interaction: elemental poison damage converted to
physical is checked by physical mitigation. If ignore armor is active, that
converted packet treats armor as 0. It does not take the ignore-resistance
physical penalty because the packet began as elemental.

Example double-conversion interaction: original physical damage with both
conversion Specials and both ignore Specials first takes the 50% physical
penalty, then counts as both physical and elemental. It skips armor during the
physical pass and skips resistance during the elemental pass, but still goes
through other active mitigation such as block and absorb.

### Basic Stat Baseline Ranges

These are Basic-rarity ranges before rarity or contract-depth scaling.

| Stat | Weapon | Helm | Armor | Trinket | Charm |
| --- | ---: | ---: | ---: | ---: | ---: |
| Base Damage | +2 to +5 | - | - | +4 to +6 | - |
| Percent Physical Damage | +6% to +12% | +12% to +15% | +6% to +12% | +9% to +15% | +9% to +15% |
| Increased Attack Speed | - | +3% to +7% | - | +5% to +6% | +6% to +9% |
| Crit Chance | - | +2% to +5% | +1% to +2% | +2% to +4% | +4% to +5% |
| Crit Damage | +30% to +45% | - | - | - | +24% to +36% |
| Base Elemental Damage | +3 to +6 | +4 to +10 | - | +5 to +8 | +6 to +10 |
| Percent Elemental Damage | +18% to +24% | +15% to +21% | +18% to +24% | +12% to +18% | +18% to +24% |
| Bonus Stacks | - | +1 to +2 | +1 to +2 | - | +1 to +2 |
| Increased Gold | +40% to +60% | +80% to +100% | +40% to +60% | +20% to +40% | +30% to +60% |
| Shop Discount | +5% to +10% | +5% to +10% | +5% to +10% | +5% to +10% | +5% to +10% |
| Increased Magic Find | +15% to +20% | +15% to +20% | +15% to +20% | +15% to +20% | +15% to +20% |

### Rare Stat Baseline Ranges

These are Basic-rarity-equivalent ranges before rarity or contract-depth
scaling. Rare stats appear only when an item's rarity rule grants a Rare stat.

| Stat | Weapon | Helm | Armor | Trinket | Charm |
| --- | ---: | ---: | ---: | ---: | ---: |
| Chance for Retrigger | +5% to +8% | - | - | +3% to +6% | - |
| Chance to Shred | +8% to +10% | +8% to +10% | +8% to +10% | +8% to +10% | +8% to +10% |
| Chance to Decay | +8% to +10% | +8% to +10% | +8% to +10% | +8% to +10% | +8% to +10% |
| Chance for Crits to Apply Poison | - | +20% to +30% | +10% to +20% | +10% to +15% | +12% to +18% |
| Increased Gold | +44% to +66% | +88% to +110% | +44% to +66% | +22% to +44% | +33% to +66% |
| Shop Discount | +6% to +11% | +6% to +11% | +6% to +11% | +6% to +11% | +6% to +11% |
| Increased Magic Find | +17% to +22% | +17% to +22% | +17% to +22% | +17% to +22% | +17% to +22% |

### Example Scaled Ranges

These examples show how Basic baseline values translate through the first-pass
rarity multipliers. They are included as tuning reference for Shop Lab, not as
separate hand-authored rarity tables.

| Stat | Slot | Basic | Master | Epic | Cursed | Chaos Positive | Unique |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Base Damage | Weapon | +2 to +5 | +4 to +9 | +4 to +10 | +5 to +13 | +6 to +15 | +4 to +10 |
| Crit Damage | Weapon | +30% to +45% | +53% to +79% | +60% to +90% | +75% to +113% | +90% to +135% | +60% to +90% |
| Increased Gold | Helm | +80% to +100% | +140% to +175% | +160% to +200% | +200% to +250% | +240% to +300% | +160% to +200% |
| Crit Chance | Armor | +1% to +2% | +2% to +4% | +2% to +5% | +3% to +6% | +4% to +7% | +2% to +5% |
| Chance for Retrigger | Trinket | +3% to +6% | +5% to +11% | +6% to +12% | +8% to +15% | +9% to +18% | +6% to +12% |
| Base Elemental Damage | Charm | +6 to +10 | +11 to +18 | +12 to +20 | +15 to +25 | +18 to +30 | +12 to +20 |

## Weapon Damage

Physical skill damage is tied to weapon damage. The weapon damage range is rolled
once per skill cast. If a skill retriggers, the retrigger is a new cast and rolls
weapon damage again.

The weapon roll must be deterministic from combat state so combat playback,
save/load, and seeded validation remain stable.

Flat Base Damage from gear adds directly to the weapon damage before skill
percentage scaling. Damage calculation should use floating point throughout and
round only once after mitigation.

Elemental damage does not scale from weapon damage. Elemental damage continues
to use flat elemental values and elemental percentage increases.

## Damage Calculation Order

Damage calculation uses explicit buckets. Modifiers inside the same bucket add
together, then each bucket multiplies the running damage total. The first Phase
5 buckets are:

1. Base damage bucket: skill base damage, weapon roll, flat Base Damage, flat
   Base Elemental Damage, and stack-based flat damage where defined.
2. Gear percent bucket: all gear-granted percent increases for the relevant
   damage type, added together.
3. Talent percent bucket: all talent-granted percent increases for the relevant
   damage type, added together.
4. Crit bucket: crit multiplier, if the hit crits.

Percent Physical Damage and Percent Elemental Damage are separate stat families.
Percent Physical Damage applies only to physical damage. Percent Elemental
Damage applies only to elemental damage. A generic future damage multiplier must
state which bucket and damage types it belongs to.

Physical direct-hit damage resolves in this order:

1. Roll weapon damage once for the skill cast.
2. Add flat Base Damage from gear to the weapon roll.
3. Add flat stack-based physical damage if the skill defines it. For Phase 5,
   Death Strike adds 1 flat damage per active poison stack to the weapon damage
   before skill scaling.
4. Apply the Rogue skill's weapon-scaling percentage.
5. Apply the gear Percent Physical Damage bucket.
6. Apply the talent physical damage bucket.
7. Roll crit and apply Crit Damage if the hit crits.
8. Apply enemy crit negation if the hit crits.
9. Resolve damage conversion effects.
10. Apply mitigation for the final damage type.
11. Floor damaging hits at 1 damage unless a defined avoidance, block, absorb,
    immunity, or prevention mechanic fully prevents the hit.
12. Round once at the end.

Elemental damage resolves in this order:

1. Start from the skill or effect's elemental base damage.
2. Add flat Base Elemental Damage from gear.
3. Apply the gear Percent Elemental Damage bucket.
4. Apply the talent elemental damage bucket.
5. Apply crit only if the skill or effect explicitly allows elemental crits.
   Poison damage-over-time ticks do not crit.
6. Resolve damage conversion effects.
7. Apply mitigation for the final damage type.
8. Floor damaging hits at 1 damage unless a defined absorb, immunity, or
   prevention mechanic fully prevents the hit.
9. Round once at the end.

Damage conversion happens after crit and before mitigation. A damage packet
converted to physical uses physical mitigation. A damage packet converted to
magical or elemental uses elemental mitigation.

If both `All of your damage is now physical` and `All of your damage is now
magical` are active at the same time, the damage packet counts as both damage
types for P5M1. It is mitigated twice: first through the current physical
mitigation order, then through the current elemental mitigation order. This
interaction can be revisited in the Special conflict task if it proves too
punitive or too confusing.

The current mitigation order is preserved. Physical direct hits resolve crit
negation, then armor mitigation, then block. Elemental and poison damage resolve
resistance, then absorb. Dodge happens before the damage packet and can prevent
attached effects from applying.

Retriggers are new casts of the skill that retriggered. A retrigger rolls a new
weapon value, rolls crit independently, applies costs or cast-linked effects as
defined by that skill, and runs the full damage pipeline again. A retriggered
skill can itself trigger another retrigger.

Example physical hit: Stab rolls 18 weapon damage, has +4 Base Damage, and uses
100% weapon scaling. The base physical damage is 22. If equipped gear grants
+30% Percent Physical Damage and talents grant +20% physical damage, the
pre-crit damage is `22 * 1.30 * 1.20 = 34.32`. A 200% crit makes it 68.64 before
enemy crit negation, conversion, armor, block, final floor, and rounding.

Example converted mixed hit: a 40-damage post-crit packet is affected by both
`All of your damage is now physical` and `All of your damage is now magical`.
It first goes through physical mitigation, including crit negation if relevant,
armor, and block. The remaining damage then goes through elemental mitigation,
including resistance and absorb. The result floors at 1 if it is still a
damaging hit, then rounds once.

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
| Legendary | 21-27 | 24 |

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
development. It is a fixed Basic Trinket/Ring with one Basic stat: +5% Crit
Chance.

Lucky Coin is awarded after defeating the second Tavern enemy and serves as the
player's first gear introduction reward. It does not appear in normal shops and
should be excluded from procedural gear, reward, and shop pools unless a future
task creates an explicit special-case source for it.

## Generation And Rewards

Random gear generation should not read upcoming route or enemy pressure directly.
The player should choose from generated options and decide which item answers the
route state best.

Lucky Coin is a scripted Tavern reward, not a randomly generated item.

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

## Current Combat And UI Baseline

Character sheet order is:

1. Weapon Damage
2. Bonus Physical Damage
3. Physical Damage Increase
4. Attack Speed
5. Crit Chance
6. Crit Damage
7. Retrigger Chance
8. Shred Chance
9. Decay Chance
10. Poison Proc Chance
11. Bonus Stacks
12. Increased Gold
13. Shop Discount
14. Magic Find
15. Base Poison Damage
16. Poison Damage Increase

Crit Chance starts at 5%. Crit Damage starts at 2.0x, displays as a multiplier
with one decimal place, and can be reduced by drawbacks down to 1.0x. Skill
tooltips display rounded integer damage ranges instead of averages or visible
formula text. Poison damage display shows the resolved number, not the internal
math.

Practice Room currently supports Crude Dagger selection, all active generated
rarities, Chaos duplicate-stat editing, max-value defaults when a rarity or
stat is selected, whole-percent/chance value entry, integer flat-damage and
stack value entry, and character-sheet display for Increased Gold, Shop
Discount, and Magic Find. Practice Room rich tooltips share Adventure's current
stat ordering, category colors, and max-roll emphasis.

Non-Chaos generated item tooltips display stat lines in a stable order:
physical damage stats first, elemental damage stats second, utility stack stats
third, economy stats fourth, then Rare proc stats and Specials. Chaos item
tooltips preserve actual roll order. Basic stat lines are off-white, Rare lines
are light blue, Special lines are yellow, and drawbacks are light purple. A max
rolled value is determined from the same rounded stored value shown to the
player, then displayed bold and two font sizes larger than normal tooltip stat
text.

Combat UI stacking debuff tooltips should read from current combat stats:

- Poison: `Poison: Deals <x> damage every 1.0s`
- Shred: `Shred: Each stack reduces armor by <shred>`
- Decay: `Decay: Each stack reduces resistance by <x>%`
- Interrupt: `Interrupt: Casting <x> times prevents next <y> casts`

Enemy-stat combat UI tooltips use intentionally sparse language:

- Armor: `Armor: Reduces Physical Damage`
- Resistance: `Resistance: Reduces elemental damage`
- Block: `Block: Prevents <x> physical damage`
- Dodge: `Dodge: <x>% chance for cast to miss`
- Crit Negation: `Crit Negation: Reduces crits by <x>%`
- Absorb: `Absorb: Prevents <x> elemental damage`
- Suppress: `Damage over time ticks <x>% slower`
- Slow: `Slow: Reduces attack speed by <x>%`
- Cleanse: `Cleanse: Removes all debuffs after <x> casts`
- Stun: `Stun: Hitting for <y>% of total health in a single hit stuns for <x>s`

## Current Rogue Talent Baseline

Assassin:

- Intrinsic: x20% Poison Damage.
- Venom Edge: unlocks Venom Jab and grants +5 Poison Damage.
- Precise Cuts: +10% Crit Chance.
- Lethal Intent: +50% Crit Damage.
- Toxic Technique: +8 Poison Damage and unlocks Poison Strike.
- Perfect Toxin: x100% Poison Damage.
- Poison Strike: 83% Weapon Scaling, 1.2 base attack time, applies 1 stack of
  Poison, and uses Fast Attack Time.

Poison damage percent bonuses from Assassin talents are straight multiplicative
talent multipliers. The character sheet should represent elemental damage as
the sum of gear percent elemental bonuses multiplied by the product of relevant
talent bonuses.

Bladedancer:

- Intrinsic: unchanged from the existing baseline.
- Quick Hands: +10% Attack Speed.
- Piercing Blades: +20 Bonus Armor Shred and unlocks Rending Slash.
- Practiced Rhythm: x10% Physical Damage and +10% Retrigger Chance.
- Opportunity Strikes: Quick Cut can proc Rending Slash. The procced Rending
  Slash can retrigger, and retriggered Quick Cuts keep their normal proc and
  retrigger behavior.
- Sunder: +20 Bonus Armor Shred and +5 Shred Stacks.

Shadow:

- Intrinsic: Stab and Heavy Slash apply +1 poison stack.
- Lingering Venom: +5 Poison Damage and +20% Chance for Crits to Apply Poison.
- Exposed Weakness: +20% Bonus Resist Decay and unlocks Beguiling Strike.
- Black Lotus: +10% Crit Chance and unlocks Death Strike.
- Nightblade Rhythm: when applying Decay, also apply the same number of Shred
  stacks. Compute final Decay stacks first, then apply that same count as Shred
  without double dipping stack bonuses.
- Umbral Presence: Poison stack cap increased to 40.

Thief:

- Steal steals 3g.

## Deferred Decisions

No remaining deferred decision blocks P5M2 from beginning. P5M1 has enough
rule structure for implementation to start; the remaining items are tuning,
presentation, validation, or future-design follow-up.

### P5M6 Shop Lab Tuning

P5M6 is complete. Shop Lab now provides a browser tuning surface for repeated
Phase 5 gear-offer rolls, distribution inspection, Cursed/Chaos/Unique
frequency checks, Chance for Retrigger risk visibility, random/manual seed
comparison, and one-command regression coverage.

The current Shop Lab defaults became the P5M7 live Adventure starting curve;
they are implemented but still not final balance:

- Shop Lab's default shop size is 4 offers; live between-contract Adventure
  shops currently use the existing 6-offer shop surface.
- Default slot odds are even across Weapon, Helm, Armor, Trinket, and Charm.
- Manual value scale defaults to 1.00x, while the lab depth-value scale ranges
  from 1.00x at contract depth 1 to 1.35x at depth 12.
- The default Early rarity curve checkpoints are:
  - Depth 1: Basic 65%, Master 23%, Epic 6%, Cursed 2%, Chaos 3%, Unique 1%.
  - Depth 6: Basic 54%, Master 26%, Epic 10%, Cursed 4%, Chaos 4%, Unique 2%.
  - Depth 12: Basic 41%, Master 29%, Epic 15%, Cursed 7%, Chaos 5%, Unique 3%.
- Chaos has been raised enough in the default curve to make risk/reward
  judgment possible during live Adventure integration testing.
- Specials remain Unique-only for the current live integration pass unless
  Adventure testing shows the frequency is wrong.
- Drawbacks remain Basic-stat-only for the current live integration pass unless
  Cursed/Chaos risk feels too mild.

### P5M7 Adventure Integration Tuning

P5M7 is complete. Live generated contract rewards now offer two deterministic
gear choices, each reward choice can independently upgrade through the Basic to
Master to Epic to Cursed/Chaos/Unique chain, and generated reward item values
scale from 1.00x at contract depth 1 to 1.35x at depth 12. Between-contract
shops use the Phase 5 Early curve above across Basic, Master, Epic, Cursed,
Chaos, and Unique; procedural Legendary rolls remain forbidden, while fixed
Legendary catalog behavior has since been validated in P5M10. P5M11 adds
economy stats: Shop Discount affects purchase prices only, Increased Gold can
roll as either Basic or Rare, and Magic Find multiplies each generated-item
rarity-upgrade chance as `base upgrade chance * (1 + equipped Magic Find)`.

Overkill Gold is active in the Adventure combat reward flow. On a combat win,
the player earns 10g per full 100 overkill damage, capped at 50g before the
final Increased Gold reward modifier is applied.

Generated contract HP scaling has also received the P5M11 weight pass. The
current route HP curve uses anchors of 1.0x at contract 1, 1.4x at contract 5,
2.3x at contract 10, 3.8x at contract 15, 6.0x at contract 20, 9.0x at
contract 25, and 13.0x at contract 30. The intent is a sharper climb where
normal, captain, and elite path enemies are less trivial, while bosses remain
important peaks without carrying all durability pressure.

Future tuning should compare lower-rarity usefulness against high-rarity
excitement after P5M8 improves item readability.

### P5M8 Item Presentation

P5M8 is complete. The live item presentation contract is:

- Equipment UI exposes Weapon/Dagger, Helm/Hood, Armor/Doublet,
  Charm/Necklace, and Trinket/Ring.
- The right-side equipment layout presents Charm/Necklace above Trinket/Ring.
- Item cards and comparison tooltips show item name, rarity, universal slot,
  Rogue item family, weapon damage for weapons, grouped positive stats,
  drawbacks, Specials, and Legendary effects.
- Player-facing item text stays sparse and hides raw stat IDs, deterministic
  keys, source seeds, generator contexts, validation internals, and other debug
  metadata.
- Comparison tooltips match candidates against the currently equipped item in
  the same slot across inventory, shop, and reward-choice surfaces.
- Epic uses the documented white/light rarity color plus shared UI treatment:
  stronger border and glow/shadow, not new P5M8 art.
- P5M9 supplies final generated Rogue Dagger, Hood, Doublet, Ring, and Necklace
  sprites.

### P5M10 Legendary Revisit

- P5M10 is complete. Current Rogue legendaries keep their identities and now use
  fixed canonical target packages in their authored resources.
- New procedural Legendary reward or shop behavior remains out of scope except
  existing fixed-catalog authored regression content.

### P5M11 Validation

P5M11 is complete. Practice Room, Balance Lab, and Adventure validation cover
the current generated gear/stat/economy/readability surface closely enough for
the next external playtest round. One accepted Balance Lab watch item remains:
`bladedancer_contract_watchmen` wins 100% against Cloaked Watchmen, above the
old 95% upper watch threshold; final tuning is deferred to the later talent-tree
remake/future balance pass.

- Final power tuning for `All stats are increased by 20%` remains a future
  balance concern rather than a P5M11 blocker.
- Chance for Retrigger should stay below 100% in normal legal builds. This is a
  tuning and validation watch item, not an implementation blocker, because
  chance stats already cap at 100% with no overflow behavior.

### Future Design

- Full Legendary redesign waits until the later talent-tree rework.
- Future class elemental types and cross-class elemental item behavior are out
  of scope for Phase 5. Phase 5 wording should remain future-safe, but Rogue
  elemental gear means poison.
