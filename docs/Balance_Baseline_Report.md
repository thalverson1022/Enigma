# Balance Baseline Report

Verified against code state: `a4c6825`

## Purpose

This document preserves the clean pre-Phase-2 balance baseline. It summarizes
the current DPS simulations, encounter tuning, route intent, and balance
watchpoints without carrying the full investigation history forward.

Primary sources:

- `scripts/baseline-dps.ts`
- `src/content/monsters.ts`
- `src/run/encounters.ts`
- `src/run/contracts.ts`
- `docs/Fight_Path_Reference.md`

Simulation settings:

- sample count: `1000`
- seeds: `1` through `1000`
- baseline target: Training Dummy
- baseline window: `20s`

## Basic Build Baselines

These are no-gear, one-talent Rogue subclass baselines.

| Build | Talent | Gear | Rotation |
|---|---|---|---|
| Basic Thief | Piercing Blades | None | Rending Slash, Quick Cut |
| Basic Assassin | Venom Edge | None | Venom Jab, Heavy Slash, Heavy Slash |
| Basic Shadow | Lingering Venom | None | Stab |

20-second Training Dummy results:

| Build | Avg Damage | Damage SD | Damage Variance | Avg DPS | DPS SD | Median DPS | P05 DPS | P95 DPS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Basic Thief | `360.14` | `27.74` | `769.52` | `18.01` | `1.39` | `17.69` | `15.69` | `20.48` |
| Basic Assassin | `486.96` | `29.19` | `852.00` | `24.35` | `1.46` | `24.20` | `22.70` | `27.20` |
| Basic Shadow | `398.42` | `23.84` | `568.30` | `19.92` | `1.19` | `20.00` | `18.20` | `21.80` |

Interpretation:

- Basic Assassin is the strongest no-gear baseline because Venom Jab applies a
  large deterministic poison package.
- Basic Thief is lower average but scales well into armored targets because
  Rending Slash reduces armor.
- Basic Shadow is stable and simple, with innate poison from choosing Shadow.

## Midgame Build Baselines

These are the post-Tavern, pre-contract loadouts used to tune the contract.

| Build | Talents | Gear | Rotation |
|---|---|---|---|
| Geared Up Thief | Piercing Blades, Quick Hands, Practiced Rhythm | Brutal Dagger, Lucky Coin, Bloody Necklace | Rending Slash, Quick Cut, Quick Cut |
| Geared Up Assassin | Venom Edge, Precise Cuts, Lethal Intent | Sharp Dagger, Lucky Coin, Lethal Necklace | Venom Jab, Heavy Slash, Heavy Slash, Heavy Slash |
| Geared Up Shadow | Lingering Venom, Exposed Weakness, Black Lotus | Swift Dagger, Poison Ring, Lethal Necklace | Heavy Slash |

20-second Training Dummy results:

| Build | Avg Damage | Damage SD | Damage Variance | Avg DPS | DPS SD | Median DPS | P05 DPS | P95 DPS |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Geared Up Thief | `551.96` | `41.22` | `1699.13` | `27.60` | `2.06` | `27.48` | `24.21` | `30.98` |
| Geared Up Assassin | `608.88` | `47.59` | `2265.22` | `30.44` | `2.38` | `30.30` | `26.55` | `34.30` |
| Geared Up Shadow | `606.92` | `39.72` | `1577.33` | `30.35` | `1.99` | `30.75` | `27.45` | `34.05` |

Interpretation:

- All three midgame builds are close enough to support route tuning.
- Assassin and Shadow are very strong on unmitigated targets.
- Thief becomes comparatively important against armored targets because it can
  push armor down over the fight.

## Tavern Encounter Tuning

| Encounter | HP | Window | Required DPS | Armor | Poison Resist |
|---|---:|---:|---:|---:|---:|
| Mouthy drunk | `150` | `12s` | `12.50` | `0` | `0%` |
| Drunk Buddy | `155` | `18s` | `8.61` | `160` | `10%` |
| Tavern Bouncer | `305` | `24s` | `12.71` | `20` | `65%` |
| Hired Goon | `360` | `30s` | `12.00` | `160` | `10%` |

Basic-build win rates from the baseline script:

| Encounter | Basic Thief | Basic Assassin | Basic Shadow |
|---|---:|---:|---:|
| Mouthy drunk | `100%` | `100%` | `100%` |
| Drunk Buddy | `100%` | `100%` | `100%` |
| Tavern Bouncer | `100%` | `100%` | `91.7%` |
| Hired Goon | `73.8%` | `100%` | `100%` |

Tavern intent:

- The opener confirms the player can enter a rotation and resolve a fight.
- Drunk Buddy introduces armor as a mitigation lesson.
- Tavern Bouncer introduces high poison resistance.
- Hired Goon is the final Tavern check before secondary tree and contract
  access.

Watchpoint:

- Basic Thief has a meaningful fail rate into Hired Goon under this exact basic
  build. If testers choose weak rotations or miss gear/talents, this fight may
  become the first frustration point.

## Contract Encounter Tuning

| Encounter | HP | Window | Required DPS | Armor | Poison Resist |
|---|---:|---:|---:|---:|---:|
| Door Guard | `230` | `16s` | `14.38` | `160` | `10%` |
| Portly Cook | `360` | `20s` | `18.00` | `0` | `0%` |
| Sleeping Henchman | `560` | `26s` | `21.54` | `0` | `0%` |
| Cloaked Watchmen | `525` | `26s` | `20.19` | `160` | `40%` |
| Lazy Henchman | `500` | `26s` | `19.23` | `0` | `0%` |
| Patrolling Guard | `460` | `26s` | `17.69` | `160` | `25%` |
| Knives | `540` | `28s` | `19.29` | `160` | `30%` |
| Vyra | `600` | `30s` | `20.00` | `160` | `35%` |

Midgame-build win rates from the baseline script:

| Encounter | Geared Thief | Geared Assassin | Geared Shadow |
|---|---:|---:|---:|
| Door Guard | `72.0%` | `100%` | `100%` |
| Portly Cook | `100%` | `100%` | `100%` |
| Sleeping Henchman | `100%` | `100%` | `100%` |
| Cloaked Watchmen | `42.9%` | `5.5%` | `0.2%` |
| Lazy Henchman | `100%` | `100%` | `100%` |
| Patrolling Guard | `96.4%` | `100%` | `100%` |
| Knives | `80.6%` | `37.2%` | `24.7%` |
| Vyra | `92.4%` | `8.6%` | `3.9%` |

## Route Difficulty Intent

The contract is intentionally not a flat path.

Easy path:

```text
Portly Cook -> Lazy Henchman -> Knives -> Vyra
```

Hard opener:

```text
Door Guard -> Sleeping Henchman or Cloaked Watchmen
```

Hardest reward path:

```text
Door Guard -> Cloaked Watchmen -> Knives -> Vyra
```

Current reward logic:

- Door Guard gives a Master gear choice and is intended as the harder opener.
- Portly Cook gives a Basic gear choice and is intended as the easier opener.
- Cloaked Watchmen gives a Cursed gear choice and is intentionally dangerous.
- Patrolling Guard gives a Master gear choice on the easier opening branch.
- Knives gives a Legendary weapon choice before Vyra.

## Poison Resistance Philosophy

The current poison-resistance spread is deliberate:

- Tavern Bouncer uses `65%` poison resistance as the early extreme lesson.
- Contract armored targets use `25%` to `40%` poison resistance to pressure
  poison-heavy builds without fully invalidating poison.
- Unmitigated contract targets remain at `0%` resistance so poison builds still
  have strong matchups.

Current concern:

- Cloaked Watchmen, Knives, and Vyra currently punish the baseline poison-heavy
  midgame builds very hard. This may be acceptable if the hard path is meant to
  demand adaptation, but it should be tested carefully.

## Balance Watchpoints For Phase 2

- Door Guard is labeled hard, but Geared Assassin and Geared Shadow currently
  beat it reliably while Geared Thief has only `72%` win rate in the baseline.
- Cloaked Watchmen is a severe hard-path gate for the listed midgame builds.
- Knives and Vyra heavily favor the current Geared Thief baseline.
- Legendary reward timing matters: Knives gives a Legendary choice before Vyra,
  so actual boss win rates may be higher than pre-Legendary midgame baseline
  rates imply.
- If Phase 2 adds longer routes, enemy mitigation variety should rotate between
  armor pressure, poison resistance, short burst checks, and long ramp checks.

## Recommended Phase 2 Balance Questions

- Should the hard path be beatable by baseline midgame builds, or only by
  players who adapt after rewards?
- Should Cloaked Watchmen be a warning fight or a true run-killer?
- Should Vyra test the post-Knives Legendary reward more explicitly?
- Should poison resistance be paired with lower armor more often to avoid
  double-punishing poison builds?
- Should Phase 2 define target win-rate bands for easy, medium, hard, elite, and
  boss encounters?

