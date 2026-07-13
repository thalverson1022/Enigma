# Phase 1 Design Recap (Project Abaddon)

Verified against code state: `a4c6825`

> **Note:** This document is legacy Project Abaddon (Phase 1) material. Every
> reference to "Phase 2" below is Project Abaddon's own internal next-iteration
> plan (deepening the existing TS/React Rogue loop) — it is **not** Project
> Bane's Phase 2. See `docs/DPS_Engine_Phase2_Context.md` and
> `docs/Phase_2_Milestones.md` for Project Bane's actual Phase 2 scope.

## Purpose

This document is the clean design entry point for Phase 2. It should describe
what the game is now, what Phase 2 should improve, and what decisions should be
made before new implementation work begins.

Older milestone documents remain useful history, but this document should be
treated as the Phase 2 design baseline.

## Current Game State

The Road to Peak Deeps is currently a deterministic DPS-build roguelike
prototype. The playable game has two modes:

- Adventure: a Rogue-only run through the Tavern phase and the first contract.
- Training Room: a freeform practice mode for testing builds, targets, gear,
  seeds, and combat windows.

The current Adventure loop is:

1. Choose Adventure.
2. Choose Rogue.
3. Choose a primary Rogue subclass: Assassin, Thief, or Shadow.
4. Fight four linear Tavern encounters.
5. Earn gold, talent points, starter gear, shop access, and build options.
6. Accept The Gilded Serpent Contract.
7. Choose a secondary Rogue subclass.
8. Choose an easy or hard route through the contract.
9. Defeat Knives and then Vyra.
10. Restart after contract victory or failure.

The game is fully deterministic for a given Adventure seed. The current default
seed is `1`, and the active seed is displayed in the Adventure header.

## Current Player Fantasy

The strongest current fantasy is not broad class variety yet. It is:

> Build a Rogue DPS engine, read the target, tune the rotation, and squeeze
> enough damage out of a fixed combat window to survive the next problem.

The parts that already support this fantasy well:

- subclass identity through passives and unlocked skills
- deterministic combat results that can be tested repeatedly
- gear that changes timing, crits, poison, armor pressure, and rewards
- route choice with easy and hard paths
- a Training Room that lets the player investigate why a build works

## Phase 2 Goal

Phase 2 should make the current loop more replayable and more strategically
interesting without burying the DPS engine under unrelated systems.

Recommended Phase 2 theme:

> Deepen the first playable run so route choice, build adaptation, and enemy
> matchups matter more from fight to fight.

Good Phase 2 outcomes:

- Players change rotations because the next encounter asks a different question.
- Hard routes feel riskier but clearly more rewarding.
- Gear choices create recognizable build pivots.
- The Training Room helps players understand Adventure outcomes.
- Testers can report build, route, seed, and target issues cleanly.

## Recommended Phase 2 Focus

The best next focus is to deepen Rogue and the first contract before adding a
new class.

Reasons:

- Rogue already has three subclass identities.
- Current balance work gives a usable baseline.
- Adding another class would multiply content and balance complexity before the
  first run is fully proven.
- Phase 2 can still add content variety through new encounters, gear, route
  nodes, and enemy mechanics.

## Non-Goals For Early Phase 2

These should wait unless Phase 2 is explicitly re-scoped:

- full multi-class implementation
- permanent save system
- large procedural map
- full story campaign
- complex animation overhaul
- multiplayer or accounts
- monetization or live-service systems

## Core Phase 2 Questions

Answer these before locking the Phase 2 roadmap:

- Should Phase 2 extend the current contract, add a second contract, or improve
  the Tavern-to-contract loop first?
- What is the target length of one full run?
- Should an average tester win on the easy path with a reasonable build?
- Should the hard path be tuned for optimized builds only?
- How much build editing should be expected between fights?
- Should boss fights stay single-window DPS checks or begin testing multi-phase
  windows?
- Should rewards favor immediate power, economy, or long-term build pivots?
- Which current systems are locked, and which are open to redesign?

## Design Risks To Watch

- Poison builds can dominate low-resistance targets unless poison resistance and
  fight windows are deliberately varied.
- High armor plus high poison resistance can punish every build if HP is not
  tuned carefully.
- Too many gear affixes without clear target pressure can make choices feel
  noisy.
- If route rewards are not obvious, players may not understand why hard paths
  are worth taking.
- If the Training Room and Adventure do not share mental models, tester feedback
  will be harder to interpret.

## Success Criteria

Phase 2 should be considered successful when:

- testers can complete the easy route without outside help after a few attempts
- the hard route creates real failure risk and better reward upside
- at least two different Rogue build styles feel viable
- players can explain why a target was hard after reading its HP, armor,
  resistance, and combat window
- seeded playtest reports are reproducible
- the docs and code agree on core mechanics, content, and balance baselines

