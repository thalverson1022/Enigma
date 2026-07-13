# Content Library Reference

Verified against code state: `a4c6825`

## Purpose

This is the Phase 2 clean content index. It lists the current implemented
content in one place so future planning does not need to search old milestone
documents.

Primary source files:

- `src/content/starterContent.ts`
- `src/content/monsters.ts`
- `src/content/passiveTrees.ts`
- `src/content/gear.ts`
- `src/run/encounters.ts`
- `src/run/contracts.ts`

## Classes And Subclasses

Currently available Adventure class:

| Class | Status |
|---|---|
| Rogue | Playable |
| Mage | Not available |
| Crusader | Not available |

Current Rogue trees:

| Tree | Identity |
|---|---|
| Assassin | Poison setup and critical payoff for single-target pressure |
| Thief | Fast attacks, armor pressure, and efficient physical/hybrid damage |
| Shadow | Innate poison pressure, resistance pressure, and delayed payoff |

## Starter Player Stats

| Stat | Value |
|---|---:|
| Attack Speed | `0` |
| Crit Chance | `15%` |
| Crit Multiplier | `2x` |
| Poison Damage | `8` per tick |

## Skills

| Skill | ID | Cast | Min Cast | Effects |
|---|---|---:|---:|---|
| Stab | `skill.stab` | `1500ms` | `700ms` | `18` physical |
| Quick Cut | `skill.quick_cut` | `850ms` | `500ms` | `12` physical |
| Poison Strike | `skill.poison_strike` | `1500ms` | `700ms` | `15` physical, apply `1` poison |
| Venom Jab | `skill.venom_jab` | `1000ms` | `500ms` | `4` physical, apply `8` poison |
| Heavy Slash | `skill.heavy_slash` | `2200ms` | `900ms` | `30` physical |
| Rending Slash | `skill.rending_thrust` | `1400ms` | `650ms` | `14` physical, reduce armor by `20` |
| Beguiling Strike | `skill.toxic_flurry` | `1700ms` | `650ms` | `4` physical, reduce poison resistance by `50%` |
| Death Strike | `skill.killers_mark` | `1500ms` | `650ms` | `20` physical, plus `1` damage per current poison stack |

## Rogue Passives

### Assassin

| Talent | Cost | Requires | Effect |
|---|---:|---|---|
| Venom Edge | `1` | None | `+4` poison damage, unlocks Venom Jab |
| Precise Cuts | `1` | None | `+5%` crit chance |
| Lethal Intent | `1` | Venom Edge or Precise Cuts | `+0.25` crit multiplier |
| Toxic Technique | `2` | Lethal Intent | `+2` poison stacks applied, unlocks Poison Strike |
| Perfect Toxin | `3` | Toxic Technique | `x1.2` poison damage |

### Thief

| Talent | Cost | Requires | Effect |
|---|---:|---|---|
| Quick Hands | `1` | None | `+5%` attack speed |
| Piercing Blades | `1` | None | `x1.08` physical damage, unlocks Rending Slash |
| Practiced Rhythm | `1` | Quick Hands or Piercing Blades | `+10%` attack speed, `x1.1` physical damage |
| Opportunity Strikes | `2` | Practiced Rhythm | Quick Cut has `20%` chance to trigger Rending Slash |
| Sunder | `3` | Opportunity Strikes | Rending Slash armor reduction increases by `20` |

### Shadow

| Talent | Cost | Requires | Effect |
|---|---:|---|---|
| Lingering Venom | `1` | None | `+2` poison damage |
| Exposed Weakness | `1` | None | Unlocks Beguiling Strike |
| Black Lotus | `1` | Lingering Venom or Exposed Weakness | `+5%` crit chance, `x1.1` physical damage |
| Nightblade Rhythm | `2` | Black Lotus | `+2` poison stacks applied |
| Umbral Pressure | `3` | Nightblade Rhythm | Unlocks Death Strike |

Shadow also grants Innate Poison when chosen: Stab and Heavy Slash apply `1`
poison stack.

## Authored Starter Gear

| Item | Slot | Effect |
|---|---|---|
| Swift Dagger | Weapon | `+12%` attack speed |
| Keen Stiletto | Weapon | `+6%` crit chance |
| Venom Knife | Weapon | `+4` poison damage |
| Lucky Coin | Trinket | `+5%` crit chance |
| Razor Token | Trinket | `+0.25` crit multiplier |
| Quicksilver Charm | Trinket | `+8%` attack speed |
| Toxic Vial | Charm | `+6` poison damage |
| Cutthroat Seal | Charm | `+0.2` crit multiplier |
| Fleet Wrap | Charm | `+7%` attack speed |

## Authored Legendary Gear

| Item | Slot | Effects |
|---|---|---|
| Wyvern Kriss | Weapon | `+2` poison stacks, `x1.4` poison damage, poison ticks twice as fast |
| Bandit Blade | Weapon | `x1.2` physical damage, `+20%` crit chance, `+1` physical damage per `10` current gold |
| Umbral Stiletto | Weapon | `+10%` crit chance, `+1` crit multiplier, unlocks Death Strike |
| Mithril Karambit | Weapon | `+20%` attack speed, `+10%` crit chance, `20%` Stab trigger, `20%` Heavy Slash trigger |
| Bejeweled Push Dagger | Weapon | `x1.2` physical damage, `+40%` crit chance, `20%` chance normal casts use minimum cast time |

## Generated Gear Affixes

| Affix | Basic | Master | Cursed Amplified | Cursed Downside |
|---|---:|---:|---:|---:|
| Attack Speed | `+0.08` | `+0.10` | `+0.20` | `-0.08` |
| Crit Chance | `+0.05` | `+0.06` | `+0.12` | `-0.05` |
| Crit Multiplier | `+0.20` | `+0.25` | `+0.50` | `-0.20` |
| Poison Damage | `+4` | `+6` | `+12` | `-4` |
| Phys Dmg | `x1.08` | `x1.10` | `x1.20` | `x0.92` |
| Poison Stacks Applied | `+1` | `+1` | `+2` | `-1` |
| Armor Reduction | `+10` | `+15` | `+30` | None |
| Gold Rewards | `x1.50` | `x1.75` | `x2.50` | `x0.50` |

## Monster Library

| Monster | ID | HP | Armor | Poison Resist |
|---|---|---:|---:|---:|
| Training Dummy | `monster.training_dummy` | `150` | `0` | `0%` |
| Armored Guard | `monster.armored_guard` | `155` | `160` | `10%` |
| Venom-Resistant Slime | `monster.venom_resistant_slime` | `305` | `20` | `65%` |
| Mouthy drunk | `monster.tavern.mouthy_drunk` | `150` | `0` | `0%` |
| Drunk Buddy | `monster.tavern.drunk_buddy` | `155` | `160` | `10%` |
| Tavern Bouncer | `monster.tavern.bouncer` | `305` | `20` | `65%` |
| Hired Goon | `monster.tavern.hired_goon` | `360` | `160` | `10%` |
| Door Guard | `monster.contract.door_guard` | `230` | `160` | `10%` |
| Portly Cook | `monster.contract.portly_cook` | `360` | `0` | `0%` |
| Sleeping Henchman | `monster.contract.sleeping_henchman` | `560` | `0` | `0%` |
| Cloaked Watchmen | `monster.contract.cloaked_watchmen` | `525` | `160` | `40%` |
| Lazy Henchman | `monster.contract.lazy_henchman` | `500` | `0` | `0%` |
| Patrolling Guard | `monster.contract.patrolling_guard` | `460` | `160` | `25%` |
| Knives | `monster.contract.knives_right_hand` | `540` | `160` | `30%` |
| Vyra | `monster.contract.vyra` | `600` | `160` | `35%` |

## Tavern Encounters

| Encounter | Window | Reward | Unlocks |
|---|---:|---|---|
| Mouthy drunk | `12s` | `12g`, `1` talent point | Fight results, rewards, talents |
| Drunk Buddy | `18s` | `18g`, Lucky Coin | Shop, gear management |
| Tavern Bouncer | `24s` | `24g`, `1` talent point | None |
| Hired Goon | `30s` | `36g`, `1` talent point | Secondary tree, contract hook |

## Contract Route

Contract: The Gilded Serpent Contract

Target: Vyra

| Node | Type | Window | Reward | Gear Choice | Next |
|---|---|---:|---|---|---|
| Door Guard | Fight | `16s` | `22g` | Master weapon or trinket | Sleeping Henchman or Cloaked Watchmen |
| Portly Cook | Fight | `20s` | `26g` | Basic weapon or charm | Lazy Henchman or Patrolling Guard |
| Sleeping Henchman | Fight | `26s` | `30g`, `1` talent point | Basic weapon or trinket | Knives |
| Cloaked Watchmen | Fight | `26s` | `1` talent point | Cursed trinket or charm | Knives |
| Lazy Henchman | Fight | `26s` | `1` talent point | Basic weapon or trinket | Knives |
| Patrolling Guard | Fight | `26s` | `30g`, `1` talent point | Master weapon or charm | Knives |
| Knives | Elite | `28s` | `42g` | Wyvern Kriss or Mithril Karambit | Vyra |
| Vyra | Boss | `30s` | `120g` | None | Contract victory |

## Training Room Targets

| Target | HP | Armor | Poison Resist |
|---|---:|---:|---:|
| Training Dummy | `150` | `0` | `0%` |
| Armored Guard | `155` | `160` | `10%` |
| Venom-Resistant Slime | `305` | `20` | `65%` |

