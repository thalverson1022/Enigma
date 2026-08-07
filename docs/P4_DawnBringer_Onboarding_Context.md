# Project DawnBringer Onboarding Context

## Read First

This is the lean handoff for Project DawnBringer, the standalone Phase 4 repo.
Use it to orient a new conversation quickly. For detailed milestone status, read
`docs/P4_DawnBringer_Milestone_Tracker.md`.

## Project State

- Repo root: `F:\Data\Claude Projects\Project-DawnBringer`
- Godot project: `F:\Data\Claude Projects\Project-DawnBringer\project\project.godot`
- Godot version: 4.7
- Godot executable: `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`
- Active/default branch: `phase-4-dawnbringer`
- Origin: `https://github.com/thalverson1022/DawnBringer.git`
- Historical upstream: `https://github.com/thalverson1022/Bane.git`
- Imported baseline tag: `dawnbringer-start`

DawnBringer is standalone. CrystalMaiden remains the hosted playtest baseline.

## Phase 4 Goal

Rework and implement procedurally generated contracts and contract routes as a
core main-loop system.

Target experience:

1. Generate readable enemy encounters with distinct defensive identities.
2. Present multiple contract-route paths with useful preview information.
3. Let players avoid bad matchups and seek favorable fights for their build.
4. Reward routing with resources, gear, talents, and synergies.
5. Scale toward harder fights while preserving deterministic combat resolution.

The first real milestone is the enemy defense vocabulary. The user has worked
out the new defense list and will provide it during P4M1 planning.

## Current Milestones

Use `docs/P4_DawnBringer_Milestone_Tracker.md` as the source of truth.

- P4M0: Setup And Procedural Contracts Plan. Complete.
- P4M1: Enemy Defense Vocabulary. Next.
- P4M2: Monster Lab Defense And Generation Prototype.
- P4M3: Runtime Monster Generator.
- P4M4: Encounter Preview And Matchup Readability.
- P4M5: Procedural Contract Route Generator.
- P4M6: Procedural Contract Integration.
- P4M7: Rewards, Resources, And Route Economy.
- P4M8: Contract Variety And Content Expansion.
- P4M9: Regression, Export, And Phase 4 Closeout.

## Important Existing Surfaces

- Adventure mode is the main loop: title, class/subclass selection, Tavern
  ladder, rewards, shop, build/talent decisions, contract offer, route choices,
  Legendary reward, climax, and victory/failure/restart states.
- Practice Room is important for isolated Rogue build testing without mutating
  Adventure state.
- Monster Lab is the intended design sandbox for generated enemies.
- Balance Lab is the verification gate for combat, balance, route pressure, and
  reward pacing changes.

## Verification Notes

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Run Balance Lab when Phase 4 touches combat timing, event ordering, build
resolution, skill/talent/gear resources, enemy data, generated difficulty,
poison/proc behavior, rewards, or route pressure.

Recent setup verification:

- Godot project imported and opened as Project DawnBringer.
- Headless project load succeeded after Godot generated local import cache.
- `balance_lab_test.gd` passed after project identity rename.

## Working Agreements

- Start implementation milestones with planning.
- Keep docs current, but keep onboarding lean.
- Prefer conservative, scoped Godot changes that match existing patterns.
- Preserve deterministic combat unless a task explicitly changes mechanics.
- Do not over-generalize before the second real use case exists.
- Commit one logical risky extraction or system change at a time.
- Keep CrystalMaiden history available as reference, but do not let old context
  dominate DawnBringer planning.

## Reference Docs

- `docs/P4_DawnBringer_Milestone_Tracker.md`: living Phase 4 tracker.
- `docs/P4M0_Task_0_Procedural_Contracts_Plan.md`: initial Phase 4 plan.
- `docs/P3M9_Regression_Export_And_Phase_3_Closeout.md`: Phase 3 closeout.
- `docs/P3_Technical_Debt_Architecture_Cleanup.md`: deferred technical triggers.
