# P4M0 Task 0: Procedural Contracts Plan

## Purpose

Task 0 establishes the Phase 4 implementation spine for Project DawnBringer:
procedurally generated contracts, contract routes, and monsters that create
meaningful build-routing decisions.

CrystalMaiden remains the hosted playtest baseline. DawnBringer is the
standalone project where larger contract, monster, and balance systems can move
without destabilizing that baseline.

## Phase 4 Spine

The core loop target is:

1. Generate readable enemy encounters with distinct defensive identities.
2. Present multiple contract-route paths with useful preview information.
3. Let players avoid bad matchups and seek favorable ones based on their build.
4. Reward successful routing with resources, gear, talents, and synergies.
5. Scale toward harder fights while preserving deterministic combat resolution.

## Milestone Order

### P4M1: Enemy Defense Vocabulary

Define and implement the new list of enemy defenses.

Deliverables:

- defense IDs, labels, descriptions, and combat rules;
- data representation on monsters and encounters;
- UI/readability language for encounter previews and combat state;
- focused tests for each defensive mechanic;
- Monster Lab visibility for defense packages.

Balance Lab should run when defenses affect DPS, duration, poison/proc behavior,
reward pressure, or route difficulty.

### P4M2: Monster Lab Generation

Use Monster Lab to build and inspect random-ish monsters from authored parts.

Deliverables:

- monster archetype model;
- defensive package composition rules;
- difficulty/risk/reward scoring;
- exportable generated monster payloads;
- validation cases for impossible or unfun combinations.

### P4M3: Procedural Monster Generation In Godot

Move the proven Monster Lab model into Godot runtime code.

Deliverables:

- deterministic seeded monster generator;
- generated monster resources or runtime dictionaries matching existing combat;
- tests for repeatability and difficulty bands;
- integration with existing combat resolver without changing unrelated mechanics.

### P4M4: Procedural Contract Route Generation

Generate route maps that create real strategic decisions.

Deliverables:

- route graph shape rules;
- node preview data;
- route pressure and reward pacing;
- authored constraints for boss, elite, shop, rest, and resource nodes;
- deterministic generation tests.

### P4M5: Adventure Integration

Replace or extend the current bespoke contract path with procedural contracts.

Deliverables:

- contract offer generation;
- route selection UI updates;
- save/load policy for generated contract state;
- failure/restart behavior;
- regression pass through Rogue adventure and Practice Room surfaces.

## Design Constraints

- Preserve deterministic combat unless a task explicitly changes mechanics.
- Keep generated enemies readable before they are surprising.
- Avoid over-generalizing until a second real use case exists.
- Commit one logical risky extraction or system change at a time.
- Keep CrystalMaiden history available as reference, but keep DawnBringer docs compact.

## Open Questions

- What is the final defense list and which defenses are core versus experimental?
- How much encounter information should the player see before committing to a route?
- Should generated contracts reuse the Gilded Serpent framing at first or introduce new contract identities immediately?
- What resources should procedural encounters award before the broader economy is redesigned?
- When should the save version bump occur?

## Immediate Next Step

Start P4M1 by turning the new enemy defense list into a mechanics spec:

- ID and display name;
- short player-facing description;
- exact combat rule;
- counterplay or build affinity;
- stacking or incompatibility rules;
- UI icon/state needs;
- Balance Lab expectations.
