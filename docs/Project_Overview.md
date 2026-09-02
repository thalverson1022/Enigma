# Project Overview

## Executive Summary

Project Enigma continues the DawnBringer game project from the completed Phase 4
foundation. The goal is to create a replayable fantasy roguelite deck-and-build
RPG where players take a hero through dangerous contracts, read enemy defenses,
choose routes based on build matchups, earn rewards, improve synergies, and
push toward harder fights.

The current game is already playable as a Phase 4 build. It supports the core
Adventure path from title menu into Rogue class/subclass setup, Tavern
progression, generated contract offers, generated route-map choices, generated
combat, reward claiming, between-contract shops, repeated generated contracts,
failure/retry/restart states, contract victory, and all-bosses victory handling.
Phase 4 closed by promoting DawnBringer's finished code to GitHub `main`.

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

Phase 4 is complete. The game now has a working generated-contract Adventure
loop and a Windows playtest build candidate.

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

Gear is the main next design priority. The current item model predates the full
generated-contract pressure system, so it does not yet provide enough readable
answers to the problems generated enemies can present.

Skill trees are functional but not final. A later overhaul is expected, so early
Phase 5 should avoid treating current build balance as a settled design target.

Generated route rewards and between-contract shops are working playtest
scaffolding, not final economy design. Non-combat route nodes, route-local
resources, consumables, shop nodes inside routes, mystic upgrades, crafting,
transmutation, boss bargains, scout/reveal nodes, and hidden events remain
deferred.

The current build candidate is Windows. Optional Web/itch export was not
produced during Phase 4 closeout.

## Next Phase Direction

Project Enigma should begin with the Phase 5 gear redesign. The first design
question is not "how do we add more content?" but "how should gear let players
respond to generated matchup pressure?"

Recommended early focus:

- Define the purpose of each gear slot.
- Create affix and item-tier vocabulary that maps cleanly to generated enemy
  defenses and route-preview language.
- Separate general-purpose power from matchup-specific answers.
- Decide how often gear should solve a route problem versus merely improve the
  odds.
- Revisit reward tables and shop offers after gear has a clearer vocabulary.
- Keep deterministic generation and save/load behavior intact.
- Use Practice Room and Balance Lab as the first validation loop.

## Key References

- `docs/P5_Minimum_Handoff_From_Phase_4.md`: the main starting point for Phase 5.
- DawnBringer repository history at
  `df940053bda8f8b1369d10754828b69120b00b0d`: final Phase 4 closeout record,
  verification evidence, export artifact, commit hash, and GitHub promotion
  method.
