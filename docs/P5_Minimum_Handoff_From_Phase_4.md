# Phase 5 Minimum Handoff From Phase 4

## Purpose

This is the lean Phase 5 landing document for DawnBringer. It records the
current playable Phase 4 state, the generated-contract systems Phase 4 now
owns, the rough areas Phase 5 should expect, and the minimum verification/build
context needed before starting the gear redesign.

For deeper history, use:

- `docs/P4_DawnBringer_Overview.md`
- `docs/P4M10_Regression_Export_And_Phase_4_Closeout.md`

## Current Playable Flow

The current player-facing Adventure path is:

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

Player-facing title menu entries are New Adventure, Resume Adventure, Practice
Room, and Exit. Contract Test is hidden from the title menu and preserved as a
diagnostic signal/test path only.

The authored Vyra/Gilded Serpent contract remains in data and regression
coverage, but the normal Adventure path temporarily skips it during this phase
so players enter the generated-contract loop sooner.

## Phase 4 Generated-Contract Ownership

Phase 4 now owns these generated-contract systems:

- Runtime monster archetype library loading from
  `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json`.
- Deterministic runtime monster generation from archetypes, difficulty, kind,
  selected mechanics, defense overrides, budget metadata, pressure metadata,
  matchup preview metadata, and notices.
- Generated contract offer creation and the current Ghit materials pitch into
  three biome offers.
- Deterministic generated route graphs with route template identity, start and
  boss anchors, Captain/elite/boss roles, branch variety, and renderer-side
  map layout polish.
- Sparse route previews that expose presentation and build-relevant summaries
  without leaking raw seeds, raw IDs, defense tables, pressure internals, or
  validation/debug payloads.
- Generated route rewards, reward previews, route-depth pressure scaling,
  completed-contract pressure scaling, and duplicate reward-claim guards.
- Materialized generated route state through save/load, including active
  contract, accepted route, selected node/planning, generated encounter
  payloads, rewards, modifiers, elite variants, and boss variants.
- Generated combat setup and generated fight outcome handling through the
  normal Adventure failure, retry, restart, route continuation, boss victory,
  shop, and repeatable-offer paths.
- Monster Manual and generated boss checklist support for current generated
  contract playtesting.
- Practice Room support for isolated Rogue build testing, target defense
  editing, generated monster rolling, fight seed control, gear setup, and
  combat playback without mutating real Adventure state.

## Provisional Areas

- Balance is intentionally provisional. Do not treat the current numbers as a
  final tuning target.
- Gear is expected to be redesigned in Phase 5 before external playtesting
  feedback is treated as balance signal.
- Skill trees will receive a later major overhaul, so current build-balance
  conclusions should be handled carefully.
- Current Rogue/Bladedancer/Thief surfaces are good enough for generated-loop
  playtesting, but not a final class design.
- Generated route rewards and between-contract shop behavior are functional
  playtest scaffolding, not final economy design.
- The optional Web/itch export has not been produced in P4M10; the current
  build candidate is Windows.
- Godot editor/headless scripts continue to emit known non-blocking
  ObjectDB/RID/resource cleanup warnings at process exit.
- `save_load_test.gd` intentionally exercises a corrupt-save path and logs a
  JSON parse error before passing.

## Phase 5 Gear Priorities

Phase 5 should begin with gear because generated enemies now create matchup
pressure that the old item model was not built to answer.

Priority questions:

- Define what each gear slot is for in the generated-contract loop.
- Make affixes and item tiers create readable build decisions against armor,
  poison resistance, dodge, crit negation, block, absorb, cleanse, suppress,
  slow, stun, and interrupt.
- Separate general-purpose power from matchup-specific answers so generated
  route choices matter.
- Decide how often gear should solve a route problem versus merely improve the
  odds.
- Revisit reward tables and shop offers after the item model has a clearer
  vocabulary.
- Preserve deterministic generation and materialized save/load state.
- Keep route previews sparse; do not expose raw mechanical internals just
  because gear needs better matchup context.
- Use Practice Room and Balance Lab as the first validation loop before broad
  playtest tuning.

Avoid during early Phase 5 unless explicitly scoped:

- Broad skill-tree redesign.
- New route-node systems.
- New combat mechanics unrelated to gear readability.
- New hidden economy systems in generated modifiers or variants.
- Rebalancing every generated route template before the gear model changes.

## Deferred Systems

These remain intentionally out of Phase 4 and should stay deferred until their
supporting systems are ready:

- Non-combat route nodes.
- Route-local resources.
- Consumables.
- Shop nodes inside routes.
- Mystic upgrades.
- Crafting and transmutation.
- Boss bargains.
- Scout/reveal nodes.
- Hidden events.
- Production art/audio/content expansion beyond blocker fixes.

## Key Files

- `project/project.godot`: Godot project.
- `project/export_presets.cfg`: Windows and Web export presets.
- `project/scripts/autoload/build_state.gd`: Adventure state, generated
  contract flow, route commit, fight, outcome, retry, restart, and save/load
  integration points.
- `project/scripts/systems/contract_offer_source.gd`: authored/generated
  contract offer source.
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`:
  deterministic generated contract route creation.
- `project/scripts/systems/runtime_monster_generator/runtime_archetype_library_loader.gd`:
  runtime archetype library loading.
- `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json`:
  export-bundled runtime archetype catalog.
- `project/scripts/systems/runtime_monster_generator/runtime_monster_generator.gd`:
  deterministic runtime monster generation.
- `project/scripts/systems/save_system.gd`: generated contract and Adventure
  save/load persistence.
- `project/scenes/combat/combat_screen.gd`: main Adventure combat, rewards,
  generated contract flow, outcome, and overlays.
- `project/scenes/combat/contract_overlay.gd`: contract offer presentation.
- `project/scenes/combat/map_overlay.gd`: Tavern, contract offer, authored
  route, and generated route map presentation.
- `project/scenes/combat/monster_manual_overlay.gd`: Monster Manual.
- `project/scenes/training_room/training_room.gd`: Practice Room controls and
  generated target setup.
- `project/scenes/training_room/training_room_combat_view.gd`: Practice Room
  combat playback.
- `project/scripts/tools/balance_lab.gd`: Balance Lab checks and reports.
- `project/scripts/tools/generated_route_inspector.gd`: generated route
  inspection.
- `tools/monster-lab/Monster_Libraries/dawnbringer_archetypes_v1.json`:
  Monster Lab source copy of the archetype catalog.
- `project/data/contracts/the_gilded_serpent.tres`: authored contract
  regression baseline.

## Key Verification

P4M10-T3 full regression passed outside the sandbox:

- Generated route matrix, inspector, UI preview, and map overlay route preview.
- Generated contract save/load and outcome.
- P4M8 Adventure lifecycle regression.
- Run failure state and contract offer flow.
- Contract Test entry, dashboard header, and combat screen checks.
- Practice Room build, fight setup, combat view.
- Hold skill, generated boss checklist, Monster Manual, Thief subclass.
- Combat playback, combat HUD, save/load UI, audio, Balance Lab, and related
  generated-route/generator/resource checks.

P4M10-T4 focused smoke pass passed outside the sandbox:

- Practice Room entry/fight/gear/setup.
- Run outcome presentation.
- Contract offer coexistence/source.
- Route reward and shop UI.
- Combat biome background.
- Overlay centering.
- Class-select export remap behavior.

P4M10-T5 export candidate:

- Windows export produced with
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project --export-release "DawnBringer Windows Playtest" "export/windows/DawnBringer.exe"`.
- Exported runtime launched with exit code 0 using:
  `project/export/windows/DawnBringer.exe --headless --quit-after 3 --verbose`.
- `.pck` scan confirmed the runtime archetype catalog, expected schema, and
  P4M8 archetype IDs are bundled.

P4M10-T6 release blocker pass:

- No crash, stuck state, save/load corruption, export failure, missing critical
  asset, unreadable route map, or player-facing debug leak remained.
- No code fixes were required during T6.

## Build Artifact

Windows playtest candidate:

- `project/export/windows/DawnBringer.exe`
  - Size: 109,019,648 bytes.
  - SHA-256:
    `FA60A1A4761CC51B18900B4D0EB18FF8C191D0A4BECB990C6B2A47EF326E0AFF`
- `project/export/windows/DawnBringer.pck`
  - Size: 172,702,100 bytes.
  - SHA-256:
    `3E6EED6983A851401A64CC238D78572C0F48557C1A54B12A3A1752AA3F617B70`

## Final Closeout Record

P4M10 is complete as of 2026-09-01.

- Final closeout content commit:
  `0bfa140bb672e593852d25a93bd65bdcc43f3735`.
- Commit message: `Complete Phase 4 DawnBringer closeout`.
- The commit was pushed to `origin/phase-4-dawnbringer`.
- GitHub `main` was promoted by direct push from `phase-4-dawnbringer` after
  the pre-promotion branch-head check did not advertise a remote `main` branch.
