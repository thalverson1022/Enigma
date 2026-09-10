# Project Overview

## Executive Summary

Project Enigma continues the DawnBringer game project from the completed Phase 4
foundation. The goal is to create a replayable fantasy roguelite deck-and-build
RPG where players take a hero through dangerous contracts, read enemy defenses,
choose routes based on build matchups, earn rewards, improve synergies, and
push toward harder fights.

The current game is playable on the Phase 5 gear-redesign baseline. It supports the core
Adventure path from title menu into Rogue class/subclass setup, Tavern
progression, generated contract offers, generated route-map choices, generated
combat, reward claiming, between-contract shops, repeated generated contracts,
failure/retry/restart states, contract victory, and all-bosses victory handling.
Phase 4 closed by promoting DawnBringer's finished code to GitHub `main`; P5M1
through P5M11 have since added the five-slot gear model, procedural rarity
rules, weapon scaling, reward/shop integration, readable item UI, Rogue
generated gear sprites, fixed retained Rogue Legendary packages, Practice Room
validation, Balance Lab validation, and current external-playtest readiness
tuning.

Project Enigma should treat that Phase 4 state as the starting point for the
next major design pass, not as a finished commercial game. The systems now exist
to create matchup pressure through generated enemies and routes; the next work
is to make player build choices, especially gear, strong enough and readable
enough to answer that pressure.

## Product Goal

The long-term goal is to create a satisfying, replayable combat-and-routing game
with these pillars:

- Buildcraft: players shape a hero through class, subclass, talents, skills,
  gear, and rewards.
- Matchup reading: enemies advertise defensive problems such as armor, dodge,
  block, absorb, cleanse, suppress, crit negation, slows, stuns, and interrupts.
- Route choice: generated contract maps ask players to choose between safer
  lines, riskier rewards, elite detours, boss approaches, and pressure tradeoffs.
- Determinism: generated routes, monsters, rewards, and saves should be stable
  enough for testing, debugging, and fair replay.
- Readability: previews should give players useful decisions without exposing
  raw seeds, internal IDs, or debug payloads.
- Momentum: after each contract, rewards and shops should create a clear reason
  to continue into the next escalating contract.

## Current State

Phase 4 is complete, and Phase 5 is complete through P5M12. The game now has a
working generated-contract Adventure loop,
five-slot generated gear, live reward and shop gear choices, Practice Room gear
testing, readable Rogue gear art for Dagger, Hood, Doublet, Ring, and Necklace,
fixed retained Rogue Legendary Weapon daggers, and current P5M11 balance and
readability tuning ready for the next external playtest round.

Current player-facing flow:

1. Title menu.
2. New Adventure.
3. Rogue class selection and subclass/talent setup.
4. Tavern encounter ladder.
5. Ghit's generated-contract materials pitch.
6. Three random generated biome contract offers.
7. Generated contract acceptance.
8. Generated route map preview and route-node choice.
9. Generated combat.
10. Reward claim.
11. Between-contract shop.
12. Repeated generated contracts with escalating pressure.
13. Failure/retry/restart states.
14. Contract victory and all-bosses victory handling.

The authored Vyra/Gilded Serpent contract remains in data and regression
coverage, but the normal Adventure path currently skips it so players reach the
generated-contract loop faster. Contract Test is hidden from the title menu and
kept as a diagnostic/test path.

## Phase 4 Foundation

Phase 4 delivered these major systems:

- Runtime monster archetype loading from the export-bundled archetype catalog.
- Deterministic runtime monster generation.
- Generated contract offers and biome contract themes.
- Generated route graphs with template identity, branch variety, Captain/elite
  roles, boss anchors, and map presentation polish.
- Sparse route previews for player-facing decision support.
- Generated rewards, pressure scaling, and duplicate reward-claim guards.
- Materialized generated route state through save/load.
- Generated combat setup and generated fight outcome handling.
- Monster Manual and generated boss checklist support.
- Practice Room support for isolated Rogue build testing, generated target
  setup, fight seed control, gear setup, and combat playback.
- Balance Lab and regression coverage for generated contract systems.

## Known Caveats

Balance is intentionally provisional. Current numbers should not be treated as
final tuning targets.

Phase 5 gear redesign is closed. The current item model now has a readable
five-slot UI, generated rewards, between-contract shop integration, Rogue
generated gear sprites, Practice Room editing for current rarities, retained
Rogue Legendary fixed stat packages, and playtest-tuned combat stats. P5M11
closed broad Practice Room, Balance Lab, and Adventure validation for the next
external playtest round; P5M12 completed final Phase 5 regression closeout,
including GitHub push preparation and itch.io-ready web packaging.

Skill trees are functional but not final. Assassin, Bladedancer, Shadow, and
Thief have received targeted playtest updates around poison, shred, decay,
retrigger, and Steal gold, but a broader overhaul is still expected later.

Generated route rewards and between-contract shops are working playtest
scaffolding, not final economy design. Non-combat route nodes, route-local
resources, consumables, shop nodes inside routes, mystic upgrades, crafting,
transmutation, boss bargains, scout/reveal nodes, and hidden events remain
deferred.

The current build candidate remains Windows-first, and P5M12 now additionally
owns an itch.io-ready Godot Web package for browser playtest hosting.

## Next Phase Direction

Project Enigma should continue from the completed Phase 5 gear baseline. P5M12
hands off a build considered strong enough for the next external playtest round;
the later talent-tree remake is expected to reopen balance questions.

Recommended next focus:

- Upload `release/itchio/project-enigma-phase5-itch.zip` to itch.io using
  `docs/Itch_IO_Release_Checklist.md`.
- Run external playtests from the closed Phase 5 baseline.
- Preserve the locked Charm-over-Trinket layout, generated Rogue icon mapping,
  retained Legendary icon overrides, and shared item-card language.
- Keep generated gear, reward choices, shop offers, save/load, Practice Room,
  and comparison behavior deterministic.
- Use `docs/P5_Phase_5_Closeout_Handoff.md` as the practical handoff for the
  next design pass.

## Current Playtest Baseline

- Crude Dagger is the starting weapon; unequipped weapon damage is 1 unarmed
  damage.
- Lucky Coin is now a fixed Basic Trinket/Ring with +5% Crit Chance.
- Chaos gear can roll duplicate stat IDs across its four outcomes, including
  four copies of the same stat.
- Non-Chaos item tooltips display stats in a fixed readable order; Chaos keeps
  its actual roll order. Tooltip stat lines are category-colored, and max rolls
  render bold and two font sizes larger in Adventure and Practice Room.
- Practice Room supports Crude Dagger, all active generated rarities, Legendary
  weapon selection, None clearing, Chaos duplicate-stat editing, max-value
  defaults, whole-percent/chance value entry, integer flat-damage and stack
  value entry, and current economy stat display.
- Increased Gold, Shop Discount, and Magic Find are active economy stats.
  Increased Gold affects stash gains and Overkill Gold after summing gear and
  multiplying talent bonuses; Shop Discount affects purchase prices only; Magic
  Find multiplies generated-item rarity upgrade checks.
- Tavern dagger purchases move the Crude Dagger into inventory, Crude Dagger
  sell value is 5g, and Mouthy Drunk HP is 145.
- Generated contract HP scaling now ramps sharply through contract 30 so path
  enemies feel weightier and late contracts become much harder.
- Overkill Gold grants 10g per full 100 overkill damage on combat wins, capped
  at 50g before Increased Gold modifiers.
- Bonus Stacks is a single stat for poison, shred, and decay stack increases.
- Shred is universal: each stack reduces armor by the player's shred value,
  starting at 10.
- Decay is universal: each stack multiplies current resistance by
  `(1 - decay_value)`, with base decay value 20%.
- `Chance for Crits to Apply Poison` applies normal poison stacks on crits;
  those stacks tick on the global poison timer.
- Character sheet and skill tooltips now reflect current damage, crit,
  proc-chance, poison, stack, and rounded range display rules.
- Retained Rogue Legendaries now use fixed Phase 5 stat packages while
  preserving bespoke effects, authored icons, 21-27 Legendary weapon damage,
  save/load compatibility, Practice Room selection, and Balance Lab coverage.
- P5M11 closeout accepts one Balance Lab watch item:
  `bladedancer_contract_watchmen` has a 100% win rate against Cloaked Watchmen,
  above the old 95% upper threshold. This is deferred to the later talent-tree
  remake/future balance pass.
- `docs/P5M11_Practice_Room_Balance_And_Readability_Tracker.md` is the
  completed tracker for current P5M11 validation and closeout evidence.

## Key References

- `docs/P5_Minimum_Handoff_From_Phase_4.md`: the main starting point for Phase 5.
- DawnBringer repository history at
  `df940053bda8f8b1369d10754828b69120b00b0d`: final Phase 4 closeout record,
  verification evidence, export artifact, commit hash, and GitHub promotion
  method.
