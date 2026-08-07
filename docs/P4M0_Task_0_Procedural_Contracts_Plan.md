# P4M0 Task 0: Setup And Procedural Contracts Plan

## Purpose

P4M0 records the setup and planning work that made Project DawnBringer ready
for Phase 4 implementation.

It is not the phase-wide tracker. Use `P4_DawnBringer_Overview.md` for current
milestone status and ongoing Phase 4 scope.

## Phase Goal

DawnBringer will rework procedurally generated contracts and contract routes as
a core main-loop system. Players should read enemy defenses, choose routes
based on matchup risk, collect resources, improve gear and synergies, and push
toward harder fights.

## Completed Setup

- Created DawnBringer as a standalone repository.
- Preserved `https://github.com/thalverson1022/Bane.git` as historical upstream.
- Set `phase-4-dawnbringer` as the active/default branch.
- Tagged the inherited CrystalMaiden baseline as `dawnbringer-start`.
- Renamed project/tooling identity to DawnBringer.
- Imported and verified the Godot project locally.
- Added compact DawnBringer onboarding context.
- Added the living Phase 4 overview/tracker.

## Key Decisions

- CrystalMaiden remains the hosted playtest baseline.
- DawnBringer is the working project for larger Phase 4 systems changes.
- The first implementation milestone is P4M1 Enemy Defense Vocabulary.
- Monster Lab should be used as the sandbox for generated enemy design.
- Balance Lab remains the gate for combat, balance, reward, and route-pressure
  changes.

## Initial Phase Spine

The planned experience is:

1. Generate readable enemy encounters with distinct defensive identities.
2. Present multiple contract-route paths with useful preview information.
3. Let players avoid bad matchups and seek favorable fights for their build.
4. Reward routing with resources, gear, talents, and synergies.
5. Scale toward harder fights while preserving deterministic combat resolution.

## Open Questions Carried Into P4M1

- What is the final defense list and which defenses are core versus experimental?
- How much encounter information should the player see before committing to a route?
- Should generated contracts reuse the Gilded Serpent framing at first or introduce new contract identities immediately?
- What resources should procedural encounters award before the broader economy is redesigned?
- When should the save version bump occur?

## Next Step

Start P4M1 by turning the user's enemy defense list into a mechanics spec:

- ID and display name;
- short player-facing description;
- exact combat rule;
- counterplay or build affinity;
- stacking or incompatibility rules;
- UI icon/state needs;
- Balance Lab expectations.
