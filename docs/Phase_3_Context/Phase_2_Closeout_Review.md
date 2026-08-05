# Phase 2 Closeout Review

## Purpose

This document summarizes what Phase 2 accomplished and what a Phase 3 session
should assume is already complete.

For detailed milestone history, use `docs/Phase_2_Milestones.md` and the
individual `docs/Phase_2_R*.md` files. This closeout is intentionally shorter
and more practical.

## Final Phase 2 Status

Phase 2 is complete.

The revised Phase 2 goal was:

> Rebuild the validated Project Abaddon Rogue adventure loop in Godot 4.x on
> a data-driven architecture, while replacing the React prototype's tool-like
> presentation with a more game-like UI and interaction flow.

That goal has been met.

Current verification as of 2026-07-25:

- Full Godot headless regression suite: 39 tests passing.
- Balance Lab: 19 pass, 0 warn, 0 fail.
- Windows export refreshed on 2026-07-25.
- Latest pushed commit at Phase 2 closeout: `cde6b4f`.

## What Phase 2 Built

## Core Architecture

Phase 2 established a Godot-native, Resource-driven architecture:

- Classes, subclass trees, talents, skills, gear, encounters, monsters, and
  contract routes live as `.tres` resources.
- `BuildResolver` resolves class base stats, tree effects, talents, gear, and
  rotation legality.
- `CombatResolver` resolves deterministic fixed-window combat.
- `RunRng` splits Adventure seed behavior into named deterministic contexts.
- `BuildState` owns Adventure run state.
- `TrainingRoomState` provides practice-mode state without mutating Adventure.
- `SaveSystem` serializes run state to JSON.

The practical rule remains: content belongs in resources, not hardcoded in
screen scripts.

## Rogue Adventure Parity

The current Adventure supports:

- Rogue class selection.
- Assassin, Thief, and Shadow subclass trees.
- Primary and secondary subclass selection.
- Talent allocation with prerequisites.
- Skill rotation building and lock-in.
- Tavern progression.
- Gold rewards, talent rewards, fixed gear rewards, shop unlocks, shop buys,
  shop rerolls, inventory, equip, unequip, and gear comparisons.
- The Gilded Serpent contract offer.
- Route choices through the first contract.
- Knives Legendary reward choice.
- Vyra climax.
- Contract victory, contract failure, retryable loss, and adventure restart
  outcomes.

## Determinism And Persistence

Phase 2 implemented:

- Adventure seed entry and display.
- Seeded combat, shop offers, generated rewards, and Legendary choices.
- One retry per non-first encounter, with the first Tavern fight remaining an
  unlimited retry learning fight.
- Save and resume.
- Save and quit.
- Abandon run.
- Autosave after meaningful state transitions.

## UI And Presentation

Phase 2 moved the project away from a wizard-like prototype flow into a
persistent dashboard:

- Header with phase, build lock, seed, and next action.
- Character stats panel.
- Talent panel.
- Combat panel with live HUD and playback.
- Available skill and rotation panels.
- Target panel.
- Gear panel with equipment and inventory.
- Map, shop, reward-choice, outcome, and combat-log overlays.
- The "Road to Peak Deeps" palette, fonts, and shared theme helpers.
- Gear icon art in shop, reward, inventory, and equipped slots.

This is usable and test-covered, but still a Phase 2 UI. Phase 3 should make
it feel better, clearer, and more animated.

## Full Practice Room

Practice Room is complete and should be preserved as a design and balance
tool:

- Freeform tree and talent setup.
- Rotation setup.
- Rarity-first gear editor.
- Direct Legendary selection.
- Target/duration/seed/gold controls.
- Combat playback and combat log.
- Isolation from real Adventure and save state.

This screen is important for Phase 3 because it lets animation and UI work be
tested against controlled scenarios.

## Balance Lab

Phase 2 added Balance Lab as a headless statistical checking system:

- Deterministic checks for Legendary stat wiring and unlocks.
- Seeded scenario distributions for DPS, win rate, poison damage, poison tick
  counts, and proc rates.
- JSON, CSV, and static HTML dashboard output.

Run:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-Bane\project' -s 'res://scripts/tools/run_balance_suite.gd'
```

Open:

`project/reports/balance/latest/index.html`

## Known Caveats For Phase 3

## Godot Test Warnings

Headless tests often print ObjectDB/resource cleanup warnings even when they
pass and exit code is 0. This is known and should not be treated as a failure
unless the exit code is nonzero or assertions fail.

## Export Hygiene

If Phase 3 changes gameplay code, assets, or UI resources and the user wants
to test the `.exe`, re-export the Windows build and smoke test it. Godot
editor behavior and exported behavior can differ when stale `.pck` files are
used.

## Current Art State

Some gear art and scene backgrounds are integrated, but Phase 3 is not a full
production art pass. Treat existing art as useful context and placeholder
quality unless the user explicitly promotes it to final.

## Combat Feel

Combat playback exists and is functional, but it is the most obvious Phase 3
improvement target. It can better communicate:

- Cast timing.
- Crits.
- Poison ticks.
- Armor reduction.
- Poison resistance reduction.
- Procs and retriggers.
- Victory or defeat momentum.

## Scope Guardrail

Phase 3 should not redesign the monster/encounter system. That is planned for
Phase 4. If UI work reveals that monster data needs different fields, document
the need and defer structural changes unless the user explicitly rescopes.

