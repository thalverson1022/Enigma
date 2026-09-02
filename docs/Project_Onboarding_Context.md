# Project Onboarding Context

## Start Here

This document is the lightweight starting point for the next phase of the game
project. It assumes Phase 4 is complete and Project Enigma is beginning from the
finished DawnBringer generated-contract foundation.

Read these documents in order:

1. `docs/Project_Overview.md`
2. `docs/P5_Minimum_Handoff_From_Phase_4.md`
3. `docs/New_Gear_Overview.md`
4. `docs/P5_Gear_Redesign_Overview.md`
5. `docs/P4M10_Regression_Export_And_Phase_4_Closeout.md`

Use `docs/Project_Overview.md` for the executive summary and current state. Use
`docs/P5_Minimum_Handoff_From_Phase_4.md` as the practical Phase 5 handoff. Use
`docs/New_Gear_Overview.md` as the current gear design spec. Use
`docs/P5_Gear_Redesign_Overview.md` as the Phase 5 milestone tracker. Use
`docs/P4M10_Regression_Export_And_Phase_4_Closeout.md` only when you need the
full closeout evidence, verification record, export details, or GitHub commit
history.

## Project Goal

Create a replayable fantasy roguelite deck-and-build RPG. The game should let
players build a hero, read enemy defenses, choose contract routes, win rewards,
adapt their build, and push through escalating generated contracts.

The core fun target is meaningful buildcraft under pressure. Players should feel
that route choices, gear choices, talents, skills, and reward decisions all
matter because enemies and contract maps ask different questions.

## Current Baseline

Phase 4 is complete for DawnBringer. GitHub `main` was promoted from the
finished Phase 4 branch after the final closeout commit.

The current playable Adventure path is:

- Title menu.
- New Adventure.
- Rogue class/subclass setup.
- Tavern encounter ladder.
- Ghit's generated-contract materials pitch.
- Three random generated biome contract offers.
- Generated route-map preview and route-node choice.
- Generated combat.
- Reward claim.
- Between-contract shop.
- Repeated generated contracts.
- Failure, retry, restart, contract victory, and all-bosses victory handling.

The generated-contract loop is the foundation for the next phase. Do not restart
from earlier milestone assumptions unless the closeout docs explicitly say a
system is provisional or deferred.

## Phase 5 Starting Point

Begin Phase 5 with gear redesign.

Generated enemies now create matchup pressure, but the old item model was not
built to answer that pressure clearly. Phase 5 should define gear slots, affix
vocabulary, item tiers, reward/shop behavior, and preview language so players
can make readable decisions against generated enemy defenses.

The active Phase 5 plan starts by pulling a fresh GitHub copy so Project Enigma
work is separated from the previous DawnBringer closeout workspace. After that
bootstrap, the phase focuses on a full gear overhaul:

- Five universal equipment slots: Weapon, Helm, Armor, Trinket, and Charm.
- Rogue item identities: Dagger, Hood, Doublet, Ring, and Necklace.
- New rarity tiers from Crude through Legendary.
- Slot-specific Basic, Rare, and Special stat pools.
- Deterministic weapon-damage scaling for Rogue physical skills.
- Procedural gear generation for rewards and between-contract shops.
- Shop Lab simulation for rolling and judging new gear offers before final
  Adventure tuning.
- Practice Room and Balance Lab validation for the new item model.

Early Phase 5 should preserve:

- Deterministic generation.
- Materialized save/load state.
- Sparse player-facing route previews.
- Generated route template identity.
- Generated rewards and pressure scaling boundaries.
- Practice Room and Balance Lab as validation tools.
- Authored Gilded Serpent data as a regression baseline even though normal
  Adventure currently skips it.

Avoid early Phase 5 scope drift into:

- Broad skill-tree redesign.
- New route-node systems.
- New combat mechanics unrelated to gear readability.
- New hidden economy systems.
- Full balance tuning before gear has been redesigned.
- Optional Web/itch export unless specifically scoped.

## Important Files And Systems

Use the handoff document for the full file list. The most important Phase 5
entry points are:

- `project/project.godot`
- `project/scripts/autoload/build_state.gd`
- `project/scripts/systems/contract_offer_source.gd`
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`
- `project/scripts/systems/runtime_monster_generator/runtime_monster_generator.gd`
- `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json`
- `project/scripts/systems/save_system.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/combat/contract_overlay.gd`
- `project/scenes/combat/map_overlay.gd`
- `project/scenes/combat/monster_manual_overlay.gd`
- `project/scenes/training_room/training_room.gd`
- `project/scripts/tools/balance_lab.gd`
- Shop Lab files, once identified during the Phase 5 repo/bootstrap audit.

## Verification Baseline

Phase 4 closeout passed the major generated-contract regression suite, focused
player-facing smoke pass, release blocker pass, and Windows export smoke. The
exact commands, warnings, artifact paths, sizes, hashes, and caveats are in:

- `docs/P5_Minimum_Handoff_From_Phase_4.md`
- `docs/P4M10_Regression_Export_And_Phase_4_Closeout.md`

Known accepted non-blockers:

- Godot editor/headless ObjectDB/RID/resource cleanup warnings at process exit.
- Intentional corrupt-save parse output in save/load testing.
- CSV locale warning from export/report tooling.
- Optional Web/itch export not produced in Phase 4.

## Final Phase 4 Evidence

Final closeout content commit:

`0bfa140bb672e593852d25a93bd65bdcc43f3735`

Commit message:

`Complete Phase 4 DawnBringer closeout`

Final evidence commit:

`df940053bda8f8b1369d10754828b69120b00b0d`

GitHub `main` and `phase-4-dawnbringer` both pointed to the final evidence
commit after closeout.

## Working Rule For New Conversations

When starting a new conversation for Project Enigma, paste or reference this
onboarding context first. Then ask the assistant to read
`docs/Project_Overview.md`, `docs/P5_Minimum_Handoff_From_Phase_4.md`,
`docs/New_Gear_Overview.md`, and `docs/P5_Gear_Redesign_Overview.md` before
planning or implementing Phase 5 work.

