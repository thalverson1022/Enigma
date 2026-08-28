# Enemy Defense Mechanics

## Purpose

This document is the canonical Phase 4 reference for enemy defensive mechanics.
These rules define how generated enemies resist, delay, negate, or disrupt the
player's damage output during procedurally generated contracts.

The goal is to create readable enemy identities that make route choices matter.
Players should learn what archetype tags imply, avoid bad matchups when
possible, and seek fights that favor their current build.

## Damage Types

Every damage instance has exactly one damage type:

- `Physical`
- `Magical`

There is no enemy-side `true` damage type for this phase. Future player-side
mechanics may bypass or convert defenses, but enemy defensive rules should treat
damage as either physical or magical.

Damage-over-time effects can be either physical or magical. Poison is currently
magical. Future effects such as burn, bleed, or other periodic mechanics may use
either damage type, and future player mechanics may convert damage types.

## Physical Damage Resolution

Physical damage uses this order of operations:

```text
Dodge check
-> Crit check / crit negation if crit
-> Armor mitigation
-> Block flat reduction
-> Final physical damage
```

Physical defenses are intended to create distinct readable identities:

- `Dodge` makes attacks unreliable.
- `Armor` reduces physical damage through the existing armor formula.
- `Block` blunts repeated smaller physical hits.
- `Crit Negation` reduces the payoff of crit-focused builds.

## Magical Damage Resolution

Magical damage uses this order of operations:

```text
Resistance mitigation
-> Absorb flat reduction
-> Final magical damage
```

Magical defenses are intended to pressure spell, poison, burn, and other
magical damage builds without changing debuff application rules.

## Defense Vocabulary

| ID | Display Name | Type | Rules Summary | Player-Facing Description |
| --- | --- | --- | --- | --- |
| `armor` | Armor | Physical mitigation | Uses the existing armor system. Armor is an integer value, mitigates physical damage, and can be negative, causing bonus physical damage. | Reduces physical damage. Negative armor increases physical damage taken. |
| `dodge` | Dodge | Physical negation | Percent chance to negate a full physical attack. Dodge only applies to physical attacks. If a dodged physical attack would apply a magical debuff, that debuff also fails to apply. | Chance to avoid physical attacks completely. |
| `crit_negation` | Crit Negation | Crit mitigation | Reduces crit damage magnitude, not crit chance. Magical attacks currently cannot crit. | Critical hits still happen, but deal less bonus damage. |
| `block` | Block | Physical flat reduction | Subtracts a fixed amount from physical damage after armor mitigation. | Reduces incoming physical damage by a flat amount. |
| `resistance` | Resistance | Magical mitigation | Uses the existing resistance behavior. Resistance is a fixed percentage reduction to magical damage. A creature with 50% resistance takes half magical damage. | Reduces magical damage by a percentage. |
| `absorb` | Absorb | Magical flat reduction | Subtracts a fixed amount from magical damage after resistance mitigation. | Reduces incoming magical damage by a flat amount. |
| `cleanse` | Cleanse | Debuff removal | Enemy-side only. A cleanse counter increments when the enemy is attacked, excluding DOT ticks. When the counter reaches the enemy's cleanse threshold, all enemy debuff stacks are set to `0`, including poison, burn, bleed, shred, decay, and future debuffs. | Periodically clears all debuff stacks after enough attacks. |
| `suppress` | Suppress | DOT timing mitigation | Increases the tick interval of periodic damage effects by a fixed percentage. It affects tick timing only, not stack application, damage per tick, or duration. | Damage-over-time effects tick less often. |
| `stun` | Stun | Anti-burst timing disruption | Enemy applies stun when a single direct hit is too large. Stun pauses the player's attack macro for a fixed duration. If the player is halfway through a cast, that cast resumes halfway through when stun ends. | Pauses the player's current attack sequence after a large hit. |
| `slow` | Slow | Player timing disruption | Enemy applies a fixed attack-speed penalty, similar to an anti-attack-speed effect. There are no slow stacks; the enemy applies a percentage value such as a frost aura. | Slows the player's attack speed. |
| `interrupt` | Interrupt | Direct attack disruption | Cancels a specific direct attack skill cast and causes only that same skill to be skipped for a number of future times it would trigger in the macro. Other skills can still cast normally. This is very strong and should be used sparingly. | Cancels and delays one direct attack skill. |

## Detailed Rules

### Armor

Armor should keep the current in-game behavior. It mitigates physical damage and
uses integer values. Negative armor is valid and causes the enemy to take bonus
physical damage.

Do not replace the current armor formula as part of P4M1 unless implementation
audit shows the existing behavior is incompatible with the documented order of
operations.

### Dodge

Dodge is a percent chance to negate an incoming physical attack. It does not
apply to magical attacks.

If a physical attack is dodged, the attack's attached debuff application also
fails, even if that debuff would later deal magical damage.

### Crit Negation

Crit negation reduces crit damage magnitude only. It does not reduce crit
chance, and it does not prevent the combat system from recognizing that a crit
occurred.

Magical attacks currently cannot crit.

The intended behavior is multiplicative reduction of crit damage before armor
mitigation. For example, an enemy with 50% crit negation halves the crit-modified
damage before armor is applied.

### Block

Block subtracts a fixed amount from physical damage after armor mitigation. It
is the physical counterpart to `Absorb`.

Final damage should be clamped to `0` unless a future mechanic explicitly uses
over-blocked damage.

### Resistance

Resistance keeps the current in-game behavior. It reduces magical damage by a
fixed percentage.

Resistance affects each magical damage instance directly, including magical
damage-over-time ticks such as poison. It does not affect debuff application
chance or debuff stack values.

### Absorb

Absorb subtracts a fixed amount from magical damage after resistance mitigation.
It is the magical counterpart to `Block`.

Final damage should be clamped to `0` unless a future mechanic explicitly uses
over-absorbed damage.

### Cleanse

Cleanse is enemy-side only. It does not affect the player.

Enemies with cleanse have a cleanse threshold. Each attack against the enemy
increments that enemy's cleanse counter. DOT ticks do not increment the counter.
When the counter reaches the threshold, all enemy debuff stacks are set to `0`.

For tracking and display, all possible debuffs can remain present with a stack
value of `0`. This is the default debuff state.

Cleanse removes all enemy debuffs, including:

- poison
- burn
- bleed
- shred
- decay
- future enemy debuffs

Lower cleanse thresholds represent harder enemies because they cleanse more
often.

### Suppress

Suppress affects periodic tick timing only. Each DOT has an internal tick rate.
Poison currently has a base tick rate of `1.0` second.

Suppress increases that tick interval by a fixed percentage:

```text
final_tick_interval = base_tick_interval * (1 + suppress_percent)
```

Example: if poison ticks every `1.0` second and an enemy has 50% suppress,
poison ticks every `1.5` seconds.

Suppress does not change:

- stack application rate
- stack values
- damage per tick
- debuff duration
- non-periodic effects

Cleanse and suppress can appear together on the same enemy.

### Stun

Stun is the anti-burst timing disruption. It triggers when one direct hit deals
at least the monster's configured `stun_trigger_hit_percent` of the monster's
maximum HP. For example, if `stun_trigger_hit_percent = 12`, a single direct hit
for at least 12% of max HP triggers the stun.

When stun triggers, it pauses the player's attack macro for
`stun_duration_ms`.

If stun lands while the player is partway through a cast or attack windup, that
cast pauses in place and resumes from the same point after stun ends.

Stun does not reduce the triggering hit. The player still gets the large damage
event, but the monster answers with tempo disruption.

### Slow

Slow is applied by enemies to the player. It acts as the opposite of attack
speed by increasing the time required for player skills to complete.

Slow does not stack. It is represented as a percentage value applied by the
enemy, such as a frost aura.

### Interrupt

Interrupt is a strong enemy mechanic and should be used sparingly.

Interrupt is the anti-repetition timing disruption. It affects direct attacks
only and triggers when the same direct skill is used
`interrupt_repeat_threshold` times in a row. It cancels that specific direct
attack skill cast and attaches the skip effect to that interrupted skill. When
that same skill would trigger again in the player's macro, it is skipped until
the monster's `interrupt_skip_count` has been consumed.

Other skills in the macro can still cast normally. For example, if a Rogue's
`Stab` is used three times in a row against a monster with
`interrupt_repeat_threshold = 3` and `interrupt_skip_count = 2`, `Stab` is
interrupted. The next two times `Stab` would trigger are skipped, but other
skills such as `Poison Strike` or `Rending Slash` can still trigger on their
normal macro turns.

The strength of interrupt is controlled by the number of future triggers skipped
for the interrupted skill.

Interrupt does not stop DOT ticks.

## Archetypes And Generated Enemies

Enemy defenses should be grouped into archetypes. Monster Lab will be used to
build and tune these archetypes before runtime generation.

Generated monsters are expected to combine two archetypes. Each archetype has a
pool of possible mechanics, and the generated enemy draws mechanics from the
selected archetype pools.

Monster difficulty is controlled by:

- the selected archetypes
- the number of mechanics added
- the values assigned to those mechanics
- the mechanic combinations produced by the archetype pair

Contract previews should emphasize archetype tags rather than exact stat-sheet
disclosure. For example, a tag such as `Tanky Thief` should imply a possible
combination of physical mitigation and evasive mechanics. The goal is for
players to learn what those tags mean over time.

Early contracts should introduce simpler defensive packages. Later contracts can
increase difficulty through stronger values, additional mechanics, harder
archetype pairings, and eventually legendary or boss-specific mechanics.

## Balance Notes

The current class ecosystem is expected to be close to having natural strengths
and weaknesses, but monster design comes first in Phase 4. Class redesign and
fine balance should be treated as iterative follow-up work after enemy
archetypes and defensive pressure are testable.

No defense should be treated as a permanent hard counter by default. The target
is soft pressure: some fights should be inefficient, dangerous, or awkward for a
build, but route choice, player scaling, rewards, and future player-side bypass
mechanics can create answers.

## Implementation Questions To Resolve

These points should be confirmed during implementation or Monster Lab tuning:

- Whether the cleanse counter increments from future magical direct attacks.
- Whether future player skills can gain immunity or resistance to timing
  disruption.

Resolved in the P4M1-T4 implementation:

- A dodged physical cast still increments the cleanse counter because it is an
  attack attempt.
- Final damage clamps to `0` after `Block` and `Absorb`.
- Slow uses `execution_time * (1 + slow)`.
- Stun is triggered by a large direct hit crossing
  `stun_trigger_hit_percent` of monster max HP.
- Interrupt is skill-specific: it skips future macro triggers of the interrupted
  direct attack skill only. It triggers from repeated use of the same direct
  skill and does not stop unrelated skills in the macro.
- Stun and interrupt have enemy data fields, but their runtime behavior is
  deferred until a dedicated timing-disruption pass.

## Balance Lab Expectations

Balance Lab should eventually allow test enemies to expose and exercise:

- physical mitigation packages: `armor`, `dodge`, `crit_negation`, `block`
- magical mitigation packages: `resistance`, `absorb`
- debuff pressure packages: `cleanse`, `suppress`
- timing disruption packages: `stun`, `slow`, `interrupt`

Balance Lab output should make the relevant defense behavior visible enough to
verify deterministic combat outcomes, damage order of operations, debuff state,
DOT timing, and attack macro disruption.
