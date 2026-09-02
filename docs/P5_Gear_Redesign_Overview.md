# P5: Gear Redesign Overview

## Current Status

P5M0 is complete. P5M1-P5M12 are planned.

Project Enigma is beginning from the completed Phase 4 generated-contract
foundation. Phase 4 made the generated Adventure loop playable; Phase 5 makes
gear strong and readable enough for players to answer the matchup pressure that
generated enemies and routes now create.

The first implementation step is to pull a fresh GitHub copy so this phase is
worked in a separate Project Enigma workspace rather than continuing directly in
the previous DawnBringer closeout workspace.

## Milestone Goal

Replace the old gear model with a five-slot gear system that supports clear
buildcraft, deterministic item generation, slot-specific stat pools, new rarity
rules, Rogue weapon-damage scaling, reward/shop integration, readable item UI,
and validation through Shop Lab, Practice Room, and Balance Lab.

Phase 5 is not a final balance pass. Numbers can remain provisional as long as
the gear model is coherent, testable, deterministic, and ready for later tuning.

## Scope

In scope:

- Fresh Project Enigma repo bootstrap from GitHub.
- Gear design and milestone documentation.
- Five universal gear slots: Weapon, Helm, Armor, Trinket, Charm.
- Rogue item identities: Dagger, Hood, Doublet, Ring, Necklace.
- New rarity tiers: Crude, Basic, Master, Epic, Cursed, Chaos, Unique,
  Legendary.
- Slot-specific Basic, Rare, and Special stat pools.
- Cursed and Chaos drawback behavior.
- Lucky Coin preservation as a Basic Crit Chance item.
- Deterministic procedural item generation.
- Rogue weapon-damage ranges and physical skill scaling.
- Reward and between-contract shop integration.
- Shop Lab simulation for rolling and tuning new gear offers.
- Inventory/equipment UI support for Helm and Armor.
- New sprites for Hood and Doublet.
- Legendary stat adjustment with fixed legendary stat packages.
- Practice Room and Balance Lab validation.
- Regression, smoke testing, docs, and closeout.

Out of scope unless explicitly promoted into scope:

- Broad talent-tree redesign.
- New playable classes.
- Full legendary redesign beyond fixed stat adjustment.
- New route-node systems.
- New route-local resources.
- New hidden economy systems.
- Consumables, crafting, transmutation, boss bargains, scout/reveal nodes, or
  hidden events.
- Full final balance tuning before the new gear model exists.
- Optional Web/itch export.

## Key References

- `docs/Project_Onboarding_Context.md`
- `docs/Project_Overview.md`
- `docs/P5_Minimum_Handoff_From_Phase_4.md`
- `docs/New_Gear_Overview.md`

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P5M0: Project Enigma Repo Bootstrap | Complete | Create a separate working copy from GitHub so Phase 5 work is isolated from the previous project workspace. | Fresh repo copy is pulled or cloned from GitHub, project identity is confirmed, branch strategy is chosen, Godot project opens or runs, baseline smoke checks pass, and docs confirm this is the Phase 5 Project Enigma workspace. |
| P5M1: Gear Design Documents | Planned | Codify the new gear model before implementation. | `docs/New_Gear_Overview.md` defines slots, Rogue item names, rarities, stat pools, weapon damage rules, Lucky Coin handling, specials, legendaries, open questions, and deferred tuning. This Phase 5 overview records milestones and scope. |
| P5M2: Gear Data Model And Migration Boundary | Planned | Replace old item assumptions with the new five-slot framework. | Gear supports Weapon, Helm, Armor, Trinket, and Charm; Rogue displays Dagger, Hood, Doublet, Ring, and Necklace; old gear is removed except Lucky Coin; save/load handles the new structure safely. |
| P5M3: Stat System Foundation | Planned | Implement the new gear stat vocabulary. | Basic, Rare, Special, and drawback stats exist; slot-specific stat eligibility is enforced; stat-sheet aggregation supports flat damage, percent damage, crit, attack speed, elemental damage, stack increases, gold gain, denial effects, conversion effects, ignore effects, immunity, and stat-sheet scaling. |
| P5M4: Weapon Damage Scaling | Planned | Move Rogue physical skill damage onto deterministic weapon rolls. | Weapon damage rolls once per cast; retriggers roll as new casts; Rogue physical skills use the documented weapon percentages; flat Base Damage applies before scaling; Death Strike's poison-stack bonus is added into weapon damage; old physical base damage is removed where appropriate. |
| P5M5: Gear Generator And Rarity Rules | Planned | Build the procedural item generator around the new rarity structure. | Crude only creates the starting dagger; Basic, Master, Epic, Cursed, Chaos, Unique, and Legendary rules use exact stat counts; Cursed uses 2 Basic, 1 Rare, and 1 negative Basic drawback; Chaos rolls 5 unconstrained Basic or Rare stats; Unique rolls 3 Basic, 1 Rare, and 1 Special. |
| P5M6: Shop Lab Gear Simulation | Planned | Let us test shop feel before final Adventure integration. | Shop Lab can repeatedly roll new gear offers with slot pools, rarity weights, drawbacks, Unique specials, and contract-depth scaling, with readable output for judging whether shops feel exciting, noisy, or too deterministic. |
| P5M7: Reward And Shop Integration | Planned | Use the new gear model in the live Adventure loop. | Contract rewards and between-contract shops generate new gear deterministically; rarity odds improve with contract depth; lower-rarity targeted rolls can remain useful; gold-gain stats affect stash gains but not shop discounts. |
| P5M8: Inventory, Equipment UI, And Item Presentation | Planned | Make the new gear readable and equippable. | Helm and Armor function in inventory and equipment UI; item cards show rarity, slot, Rogue item type, stats, drawbacks, and specials; rarity colors and effects are applied without exposing debug or raw generator data. |
| P5M9: Art And Sprite Pass | Planned | Add item identity for the expanded gear system. | Hood and Doublet sprites exist; Dagger, Ring, Necklace, Lucky Coin, rarity presentation, and item placeholders are cleaned up as needed. |
| P5M10: Legendary Revisit And Fixed Legendary Stats | Planned | Retain current Rogue legendaries while fitting them into the new gear structure. | Existing Rogue legendaries have fixed stats, adjusted values, class-specific legendary effects, and documented deferred redesign notes for the later talent-tree phase. |
| P5M11: Practice Room And Balance Lab Validation | Planned | Validate gear behavior outside normal Adventure runs. | Practice Room supports the new slots and stat effects; Balance Lab covers item generation, stat aggregation, weapon rolls, specials, save/load, generated combat compatibility, and deterministic replay expectations. |
| P5M12: Phase 5 Regression, Smoke, And Closeout | Planned | Make the new gear system the next stable baseline. | Adventure loop, generated contracts, route previews, rewards, shop, save/load, Practice Room, Shop Lab, Balance Lab, and export-sensitive paths pass regression; docs are updated; known tuning caveats are recorded; final Phase 5 handoff is written. |

## P5M0 Project Enigma Repo Bootstrap

Status: Complete.

P5M0 creates the clean project boundary for Phase 5. The new workspace should be
pulled from GitHub rather than continuing from the current local closeout copy.

Exit notes:

- GitHub source: `https://github.com/thalverson1022/Enigma.git`.
- Local workspace path: `F:\Data\Claude Projects\Project-Enigma`.
- Baseline source: `https://github.com/thalverson1022/DawnBringer.git`,
  `dawnbringer/main` at `df940053bda8f8b1369d10754828b69120b00b0d`.
- Branch strategy: `main` preserves the promoted Phase 4 baseline plus Enigma
  project docs; Phase 5 implementation continues on `phase-5-gear-redesign`.
- Baseline Godot smoke: after a first-time headless import pass, Godot 4.7
  headless launch exited with code 0 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project --quit-after 3`.
- Known local setup caveats: a fresh clone needs the Godot import cache built
  before the clean launch smoke; the CSV locale warning and Godot
  ObjectDB/resource cleanup warnings remain accepted non-blockers from Phase 4.

## P5M1 Gear Design Documents

Status: Planned.

P5M1 locks the initial design target before implementation. The gear design can
still evolve during testing, but the first pass should be explicit enough that
implementation milestones do not have to rediscover the rules.

Exit notes to record when complete:

- `docs/New_Gear_Overview.md` created and reviewed.
- This Phase 5 overview created and reviewed.
- Open questions recorded instead of hidden in chat history.

## P5M2 Gear Data Model And Migration Boundary

Status: Planned.

P5M2 replaces the old gear assumptions with the new five-slot model. This should
establish the data structures, save/load shape, and compatibility boundary
before individual stat effects are layered in.

Exit notes to record when complete:

- New slot model implemented.
- Rogue display item families implemented.
- Old gear removed or migrated.
- Lucky Coin retained.
- Save/load behavior verified.

## P5M3 Stat System Foundation

Status: Planned.

P5M3 gives gear a shared stat vocabulary. The goal is not perfect tuning yet;
the goal is a robust stat pipeline that can express the new item design without
hardcoding each item as a one-off.

Exit notes to record when complete:

- Stat definitions implemented.
- Slot eligibility enforced.
- Stat-sheet aggregation updated.
- Positive and negative stat values supported.
- Special-effect hooks identified or implemented.

## P5M4 Weapon Damage Scaling

Status: Planned.

P5M4 moves Rogue physical skill damage onto deterministic weapon rolls. This
gives weapons intrinsic scaling and lets item rarity matter even before other
stats are considered.

Exit notes to record when complete:

- Dagger rarity ranges implemented.
- Physical skill scaling implemented.
- Deterministic roll behavior verified.
- Retrigger behavior verified.
- Death Strike handling verified.

## P5M5 Gear Generator And Rarity Rules

Status: Planned.

P5M5 builds the procedural generator for the new item model. The generator
should produce readable, deterministic gear from rarity rules, slot pools, and
stat categories.

Exit notes to record when complete:

- Rarity rules implemented.
- Cursed drawback behavior implemented.
- Chaos positive/negative behavior implemented.
- Unique special stat behavior implemented.
- Legendary fixed-stat path identified or stubbed for P5M10.

## P5M6 Shop Lab Gear Simulation

Status: Planned.

P5M6 updates Shop Lab as the first feel-testing surface for the new item economy.
The goal is to roll many shops quickly and inspect whether item offers create
interesting decisions before wiring every result into Adventure.

Exit notes to record when complete:

- Shop Lab rolls new gear offers.
- Contract-depth rarity scaling can be simulated.
- Cursed, Chaos, Unique, and Legendary handling is visible.
- Output is readable enough for tuning discussions.

## P5M7 Reward And Shop Integration

Status: Planned.

P5M7 connects the new generator to the live Adventure loop. Generated rewards
and between-contract shops should use deterministic item generation while still
leaving room for later balance changes.

Exit notes to record when complete:

- Contract rewards generate new gear.
- Between-contract shops generate new gear.
- Gold-gain stat applies to stash gains.
- Save/load and duplicate reward guards still work.

## P5M8 Inventory, Equipment UI, And Item Presentation

Status: Planned.

P5M8 makes the redesigned gear visible and understandable to players. This is
where Helm and Armor become fully usable rather than empty inventory affordances.

Exit notes to record when complete:

- Five slots work in the equipment UI.
- Item cards describe stats and drawbacks clearly.
- Rarity colors and Epic treatment are represented.
- Player-facing text stays sparse and non-debug.

## P5M9 Art And Sprite Pass

Status: Planned.

P5M9 supplies item art for the expanded gear set. Hood and Doublet are required
new Rogue item sprites because those slots already exist in the inventory but
currently have no functionality.

Exit notes to record when complete:

- Hood sprite added.
- Doublet sprite added.
- Existing item sprites and placeholders reviewed.
- Rarity presentation reviewed in-game.

## P5M10 Legendary Revisit And Fixed Legendary Stats

Status: Planned.

P5M10 brings existing Rogue legendaries into the new gear rules. Legendary
effects remain class-specific and build-defining, but the larger legendary
redesign waits for the future talent-tree overhaul.

Exit notes to record when complete:

- Existing Rogue legendaries reviewed.
- Fixed stat packages assigned.
- Legendary effects still function.
- Deferred legendary redesign notes recorded.

## P5M11 Practice Room And Balance Lab Validation

Status: Planned.

P5M11 ensures the new gear system can be tested outside a full Adventure run.
Practice Room should support hands-on build checks, while Balance Lab should
provide repeatable deterministic validation.

Exit notes to record when complete:

- Practice Room supports new slots.
- Practice Room supports new stat effects.
- Balance Lab covers generator outputs.
- Balance Lab covers combat-relevant stat behavior.
- Deterministic replay expectations are verified.

## P5M12 Phase 5 Regression, Smoke, And Closeout

Status: Planned.

P5M12 closes the phase by proving that the new gear baseline works across the
Adventure loop, tools, saves, and player-facing surfaces.

Exit notes to record when complete:

- Regression pass recorded.
- Manual smoke pass recorded.
- Known non-blockers recorded.
- Overview, onboarding, and handoff docs updated.
- Final Phase 5 handoff written.
