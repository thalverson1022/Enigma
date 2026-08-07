# Project DawnBringer Milestone Tracker

## Purpose

This is the living Phase 4 tracker. Update it at the start and close of each
milestone, and whenever scope meaningfully changes.

Phase 4 goal: make procedurally generated contracts and contract routes a core,
repeatable main-loop system. Players should read enemy defenses, choose routes
based on build matchups, collect resources, improve synergies, and push toward
harder fights.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Milestones

| Milestone | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M0: Setup And Procedural Contracts Plan | Complete | Stand up DawnBringer as a standalone project and establish the Phase 4 spine. | Standalone repo, DawnBringer identity, compact docs, Task 0 plan, and default branch setup complete. |
| P4M1: Enemy Defense Vocabulary | Not Started | Define and implement the enemy defensive mechanics that make routing decisions meaningful. | Defense IDs/rules/UI language are documented, implemented, tested, and exposed in Monster Lab where relevant. |
| P4M2: Monster Lab Defense And Generation Prototype | Not Started | Use Monster Lab as the sandbox for generated monster composition before runtime integration. | Monster archetypes, defense packages, difficulty bands, validation warnings, and export/preview flow work in Monster Lab. |
| P4M3: Runtime Monster Generator | Not Started | Move the proven generation model into deterministic Godot runtime code. | Seeded generator produces repeatable monsters with tests for difficulty bands and combat compatibility. |
| P4M4: Encounter Preview And Matchup Readability | Not Started | Make enemy defenses and route choices readable before the player commits. | Encounter previews show threat, defenses, reward, and relevant combat state clearly in route/combat UI. |
| P4M5: Procedural Contract Route Generator | Not Started | Generate route maps that create real strategic choices. | Seeded route graphs support branching paths, node type constraints, pacing rules, and deterministic tests. |
| P4M6: Procedural Contract Integration | Not Started | Connect generated contracts to the Adventure loop. | Contract offers, route commit flow, generated state, save/load policy, failure/restart behavior, and regressions are covered. |
| P4M7: Rewards, Resources, And Route Economy | Not Started | Make routing matter through resource, gear, talent, and risk/reward pacing. | Reward tables and route economy are tuned with Balance Lab gates and anti-snowball/dead-run checks. |
| P4M8: Contract Variety And Content Expansion | Not Started | Add enough encounter/theme variety that contracts feel repeatable. | Additional archetypes, modifiers, elite/boss variants, and contract themes work without nonsense combinations. |
| P4M9: Regression, Export, And Phase 4 Closeout | Not Started | Stabilize, verify, export, and document the Phase 4 result. | Focused regression, Balance Lab final pass, web export smoke test, closeout doc, and next-phase notes are complete. |

## Current Focus

Next milestone: P4M1 Enemy Defense Vocabulary.

Immediate next step:

- Turn the user's enemy defense list into a mechanics spec with IDs, display
  names, player-facing descriptions, exact combat rules, counterplay/build
  affinities, stacking rules, UI needs, and Balance Lab expectations.

## Verification Gates

Run Godot 4.7 from:

`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`

Run Balance Lab when changes touch:

- combat timing or event ordering;
- build resolution;
- skill, talent, gear, monster, or enemy data;
- generated encounter difficulty;
- route reward pressure;
- poison, proc, duration, or DPS behavior.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

## Repo Notes

- Repo root: `F:\Data\Claude Projects\Project-DawnBringer`
- Godot project: `F:\Data\Claude Projects\Project-DawnBringer\project\project.godot`
- Active/default branch: `phase-4-dawnbringer`
- Origin: `https://github.com/thalverson1022/DawnBringer.git`
- Historical upstream: `https://github.com/thalverson1022/Bane.git`
- Imported baseline tag: `dawnbringer-start`
