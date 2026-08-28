# P4M5: Procedural Contract Route Generator

## Purpose

P4M5 creates the seeded procedural contract route generator that Phase 4 needs
before generated contracts can become part of the Adventure loop.

P4M3 proved deterministic runtime monster generation. P4M4 proved that
generated encounters can be previewed with separate route-map, combat-facing,
and debug/report data. P4M5 should now use those pieces to generate readable
branching route graphs with meaningful strategic choices.

This milestone is about route structure and generated route state. Full
Adventure contract integration, save/load policy, reward economy tuning, and
long-term anti-snowball pacing remain later milestones.

## Milestone Goal

Create a deterministic route generation system that produces valid contract
graphs from seed and route settings. Generated routes should have start and boss
anchors, branching paths, controlled node pacing, biome and monster-type
presentation identity, generated encounter payloads for fight nodes, sparse
route previews for comparison, and focused tests that prove determinism and
structural validity.

The milestone should preserve the current authored Gilded Serpent contract flow
while adding generated route support behind isolated tests or debug inspection
surfaces.

## Scope Notes

- Generated route graphs are the primary output.
- Generated fight nodes should use the existing runtime monster generator.
- Route-map previews should remain sparse: biome, monster name, encounter
  level, and visible archetype tags.
- Combat-facing and debug preview sections should be preserved in generated
  route state, but not exposed on the contract map.
- Biome and monster type are presentation identity. They should not replace or
  hide mechanical archetype tags.
- Final reward economy, contract-offer integration, save/load compatibility,
  failure/restart behavior, and route economy tuning are deferred to P4M6 and
  P4M7 unless a small placeholder is required for route inspection.

## Current Focus

P4M5 is complete. The next milestone is P4M6: Procedural Contract Integration,
which should connect generated routes to the Adventure contract loop.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M5-T1: Route Generator Requirements And Shape Spec | Complete | Define what a valid generated contract route is before runtime code lands. | This doc records node types, graph shape, shortest/longest path expectations, start/boss anchors, branch rules, elite placement, biome rules, seed policy, generated-state boundaries, and deferred scope. |
| P4M5-T2: Contract Route Data Model Extension | Complete | Add the runtime data needed for generated route graphs without breaking authored routes. | Route graph/node data can store generated IDs, node type, depth/lane, connected node IDs, encounter payloads, route preview, biome, presentation identity, and debug metadata while authored route nodes keep existing fallback behavior. |
| P4M5-T3: Seeded Route Graph Generator Skeleton | Complete | Create the deterministic generator entry point and first valid graph output. | Same seed/settings produce the same route graph; different seeds vary; generator returns a valid start-to-boss graph with at least one meaningful branch. |
| P4M5-T4: Route Shape And Pacing Rules | Complete | Make generated routes strategically useful rather than arbitrary node blobs. | Generated graphs obey path length bounds, branching constraints, no dead ends except terminal nodes, no impossible choices, controlled normal/elite/boss placement, and readable pacing from start to boss. |
| P4M5-T5: Encounter Assignment For Fight Nodes | Complete | Attach runtime-generated monsters to generated fight nodes. | Normal, elite, and boss fight nodes receive deterministic generated monsters with seed, difficulty, kind, tempo, archetypes, selected mechanics, defense overrides, pressure metadata, notices, and preview payloads preserved. |
| P4M5-T6: Biome And Monster Presentation Layer | Complete | Add the first seeded fiction layer while keeping mechanics separate. | Generated contracts/routes choose biome context; fight nodes get biome-appropriate monster type/name context; mechanical archetypes remain visible, reproducible, and independent from presentation identity. |
| P4M5-T7: Route Preview Population | Complete | Use the P4M4 preview handoff for generated route-node comparison. | Generated route nodes populate `ContractRouteNode.route_preview` from `EncounterPreviewFormatter.contract_map`; detailed combat/debug previews are preserved in generated state but omitted from route-map display. |
| P4M5-T8: Isolated Generated Route Inspection Surface | Complete | Provide a lab bench for inspecting generated routes before Adventure integration. | A focused test path, debug fixture, or lightweight inspection surface can generate a seeded route and inspect graph nodes, previews, encounter payloads, and notices without mutating Adventure state. |
| P4M5-T9: Deterministic And Constraint Test Matrix | Complete | Lock down generated route behavior with focused tests. | Tests cover same-seed reproduction, seed variation, graph validity, path reachability, node constraints, elite/boss placement, biome assignment, preview sparsity, and generated monster metadata preservation. |
| P4M5-T10: Regression Gate Against Authored Contracts | Complete | Ensure generated-route support does not damage existing authored contract behavior. | Current authored Gilded Serpent contract route tests, map overlay fallback behavior, and contract offer flow tests still pass. |
| P4M5-T11: Documentation And Handoff To P4M6 | Complete | Record the implemented route generator and hand off integration work cleanly. | This doc and the Phase 4 overview are updated with implementation notes, verification results, known gaps, and clear P4M6 handoff items for Adventure-loop integration and save/load policy. |

## Route Shape Requirements

Initial route graphs should be compact enough to read and broad enough to
create real choices. The first implementation should prefer a small fixed
template family with seeded variation over a fully unconstrained graph
algorithm.

T1 decisions:

- Use a compact directed acyclic graph ordered by integer `depth` from start to
  boss and by integer `lane` within each depth.
- Generate from a small fixed template family first, then apply seeded node
  identity and encounter variation inside those templates.
- Store outgoing connections on each node for traversal. Tests may also derive
  an edge list, but the runtime data model does not need two competing sources
  of truth.
- Keep graph layout deterministic: node IDs, node order, depth/lane assignment,
  and outgoing IDs must be stable for the same seed/settings/version tuple.

Required structure:

- One start anchor.
- One boss or contract-goal anchor.
- Multiple valid start-to-boss paths.
- At least one branch where the player chooses between meaningfully different
  encounter previews.
- No unreachable nodes.
- No dead ends except the terminal boss/goal node.
- No duplicate node IDs within a graph.
- Stable node ordering for deterministic tests and UI traversal.
- All non-terminal nodes have at least one outgoing connection.
- All outgoing IDs point to existing nodes at a greater depth.
- Boss has no outgoing connections.

Initial node types:

- `start`: route entry anchor, not a fight.
- `fight`: normal generated encounter.
- `elite`: higher-risk generated encounter, optional in early graphs unless
  later settings explicitly request a forced elite route.
- `boss`: terminal generated encounter.
- `reward`: placeholder route reward or rest/resource node if needed for
  graph readability tests.
- `event`: placeholder non-combat node only if an existing route surface already
  handles it cleanly.

Implementation should start with `start`, `fight`, `elite`, and `boss`. Add
`reward` or `event` only if they are needed to test route shape without dragging
P4M7 reward economy into this milestone.

Node IDs should be generated from stable route-local identity rather than from
display names. First-pass IDs should use a predictable form such as
`start`, `d1_l0`, `d2_l1`, and `boss`, so later presentation changes do not
invalidate deterministic tests.

The first template family should support at least:

- a split-and-merge route with two mid-route lanes;
- a route with one optional elite branch;
- a route with one longer low-risk branch and one shorter higher-risk branch.

## Pacing Rules

Initial pacing should be structural rather than balance-authoritative.

First-pass constraints:

- Shortest valid path: 3 to 4 committed nodes after start.
- Longest valid path: 5 to 6 committed nodes after start.
- Boss appears only at the terminal depth.
- Early route choices should avoid immediate forced elite fights.
- Elite nodes should be optional or clearly previewed as riskier.
- Avoid more than one elite on the shortest path.
- Avoid back-to-back elite nodes unless a later task explicitly designs that
  pressure.
- Normal fights should carry most of the route body.
- Every depth with a choice should show preview differences that matter: biome,
  encounter level, monster name, or archetype tags.

Branch quality rules:

- Every generated graph must contain at least one player-visible branch.
- A branch is meaningful only if the available next nodes differ in at least one
  sparse preview dimension: biome, monster name, encounter level, node type, or
  archetype tags.
- If an elite is on a branch, at least one non-elite alternative should exist
  before the boss in the same decision region.
- A shorter path may be riskier than a longer path, but the risk must be visible
  through node type or route preview data.
- Template validation should reject routes that force all paths through the same
  sequence before the boss unless the branch reconverges after a visible choice.

These numbers are placeholders for route readability. Final risk/reward pacing
belongs to P4M7.

## Seed And Determinism Policy

Generated route output should be reproducible from:

- route seed;
- route generator version;
- route settings;
- route biome/presentation table version;
- runtime monster generator version;
- runtime monster archetype library version.

The route generator should derive child seeds for node encounters from the route
seed and stable node IDs rather than consuming a shared RNG stream in a way that
makes later node insertions silently rewrite unrelated encounters.

Required child-seed contexts:

- graph shape;
- biome/presentation roll;
- node encounter roll;
- optional future reward roll.

Seed derivation should combine route seed, generator version, context name, and
stable node ID when node-specific. Graph-level rolls omit node ID. The exact hash
helper can be chosen during implementation, but it must produce stable integers
across Godot runs and platforms.

Changing a downstream node, biome name, or future reward table should not alter
encounters assigned to unrelated existing node IDs. If a generator version or
table version intentionally changes output, tests should make that versioned
change explicit.

Player-facing route state may later store route seed/settings plus resolved
preview identity. P4M6 should decide the final Adventure save/load policy.

## Generated Route State

Generated route nodes should preserve enough data for later integration without
forcing the map overlay to know generation internals.

Required route-level fields:

- generated route ID;
- source seed;
- generator version;
- route difficulty or contract pressure input;
- allowed or selected biome context;
- biome/presentation table version;
- runtime monster generator version;
- runtime monster archetype library version;
- route settings snapshot;
- route notices;
- node list;
- per-node outgoing IDs.

Required node-level fields:

- generated node ID;
- node type;
- depth and lane;
- outgoing node IDs;
- biome;
- monster presentation type;
- route preview;
- generated encounter payload for fight/elite/boss nodes;
- combat preview;
- debug preview;
- generation notices.

State boundary rules:

- `ContractRouteNode.route_preview` is the only generated preview data the
  contract map should need for comparison display.
- Combat-facing and debug preview payloads stay with generated route state for
  later combat UI, Balance Lab, reports, and tests.
- Authored route nodes must continue to work when generated fields are empty.
- Generated route state should be serializable through plain dictionaries and
  arrays so P4M6 can define save/load policy without reshaping the data.
- Reward and event payloads remain placeholders unless T2/T3 need a minimal
  non-combat node to prove graph shape.

## Presentation Identity Notes

Biome and monster type should provide flavor, not hidden mechanics. The same
mechanical archetype can appear under different presentation identities.

Presentation identity rules:

- Biome and monster type must not replace archetype IDs, archetype tags, defense
  overrides, selected mechanics, pressure metadata, or generation notices.
- Sparse route previews may show biome, generated monster name, encounter level,
  node type, and visible archetype tags.
- Detailed armor, resist, defensive mechanics, pressure metadata, and debug
  budget information stay out of the route map.
- First-pass biome selection chooses one route-wide biome from the allowed set.
  Node-level biome is still stored for previews and future world-map templates,
  but generated contracts currently keep every node in the selected biome.
- Monster names/types should be derived from biome presentation tables and node
  kind, while combat mechanics remain derived from runtime monster archetypes.

First-pass biome pools:

- Swamp: Giant Slime, Bog Rat, Giant Leech, Poison Frog, Swamp Goblin; elites
  Troll, Bog Witch, Hydra Spawn; bosses Swamp Hydra, Ancient Troll, Slime
  Queen.
- Cave: Giant Bat, Cave Spider, Goblin, Giant Centipede, Cave Slime; elites
  Ogre, Basilisk, Cave Troll; bosses Cave Wyrm, Goblin King, Ancient Basilisk.
- Graveyard: Skeleton, Zombie, Ghoul, Giant Rat, Restless Spirit; elites Wight,
  Necromancer, Grave Golem; bosses Bone Colossus, Lich, Headless Knight.
- Haunted Forest: Wolf, Giant Spider, Treant Sapling, Wisp, Feral Goblin; elites
  Werewolf, Hag, Corrupted Treant; bosses Ancient Treant, Forest Witch, Great
  Werewolf.
- Ruined Keep: Bandit, Cultist, Guard Construct, Rat, Animated Armor; elites
  Dark Knight, Gargoyle, Warlock; bosses Fallen King, Iron Golem, Castellan.
- Ancient Ruins: Cultist, Animated Statue, Scarab, Arcane Wisp; elites Guardian
  Construct, Minotaur, Arcane Golem; bosses Ancient Guardian, Sphinx, Runic
  Colossus.

P4M5 only needs a small first-pass pool. P4M8 can expand biome variety, visual
identity, modifiers, elite variants, boss variants, and richer theme rules.

## Deferred From T1

The following are intentionally outside the T1 shape spec and should not block
T2/T3:

- Adventure contract-offer integration.
- Save/load compatibility and migration policy.
- Final route reward economy, rest/resource nodes, and anti-snowball pacing.
- Failure, restart, and abandoned-contract behavior.
- Large biome content pools, art identity, modifiers, elite variants, and boss
  variants.
- Final UI polish for committing to generated routes.

## Existing Integration Surfaces

- `project/scripts/systems/runtime_monster_generator/` contains the deterministic
  runtime monster generator and generated output wrapper.
- `EncounterPreviewFormatter.format_generated()` returns `contract_map`,
  `combat`, and `debug` preview sections for generated encounters.
- `ContractRouteNode.route_preview` is already prepared for sparse generated
  route-map comparison.
- `project/scenes/combat/map_overlay.gd` consumes route-preview fields when
  present and falls back to authored route display when absent.
- Balance Lab preserves generated encounter preview data and should remain the
  verification gate for later route pressure and reward-economy changes.

## Implementation Notes

P4M5-T2 extended the current route resources without changing authored
traversal:

- `ContractRouteNode.NodeType.START` was appended after existing enum values so
  serialized authored node types keep their previous numeric values.
- `ContractRouteNode` now stores optional generated node fields:
  `generated_node_id`, `depth`, `lane`, `outgoing_node_ids`, `biome`,
  `monster_presentation_type`, `generated_encounter_payload`,
  `combat_preview`, `debug_preview`, and `generation_notices`.
- `ContractRouteNode.route_preview` remains the sparse contract-map preview
  surface created in P4M4.
- `ContractRouteNode.next_nodes` remains the traversal source for authored
  Adventure flow. Generated code can call `sync_outgoing_node_ids_from_next_nodes`
  when it needs serializable outgoing IDs.
- `ContractRouteNode` includes `has_generated_state`,
  `generated_state`, and `apply_generated_state` helpers for plain
  dictionary/array-friendly generated node state.
- `ContractDef` now stores optional generated route-level metadata:
  `generated_route_id`, `source_seed`, `generator_version`,
  `route_difficulty`, `selected_biome`, `allowed_biomes`,
  `biome_table_version`, `runtime_monster_generator_version`,
  `runtime_monster_archetype_library_version`, `route_settings`, and
  `route_notices`.
- `ContractDef` includes `has_generated_route_state`,
  `generated_route_state`, and `apply_generated_route_state` helpers.
- Authored contracts keep existing fallback behavior when generated fields are
  empty.

P4M5-T3 added the seeded route graph generator skeleton:

- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`
  provides `ContractRouteGenerator.generate(seed, settings = {})`.
- The generator returns a generated `ContractDef` with a `START` offer node,
  fight/elite body nodes, one terminal boss node, generated route metadata, and
  route-local node IDs.
- First-pass graph shape comes from three deterministic templates:
  `split_merge`, `optional_elite`, and `short_risk_long_safe`.
- `RunRng` is reused for graph-shape, biome, node presentation, and preview tag
  rolls so same seed/settings reproduce the same graph signature.
- Generated nodes populate `next_nodes` for existing traversal and
  `outgoing_node_ids` for serializable generated state.
- Sparse placeholder `route_preview` data was populated with biome, monster
  name, encounter level, and archetype tags until real generated monster
  assignment replaced it in P4M5-T5.
- `ContractRouteGenerator.validate(contract)` checks the skeleton graph for one
  start, one boss, forward edges, no invalid dead ends, at least one branch, and
  multiple start-to-boss paths.
- `ContractRouteGenerator.graph_signature(contract)` supports deterministic
  same-seed and variation tests.

P4M5-T4 tightened route shape and pacing:

- `ContractRouteGenerator.GENERATOR_VERSION` advanced to `p4m5.t4.v1` because
  template shapes and placeholder preview tags intentionally changed.
- Default route settings now include `shortest_path_max` and
  `longest_path_min` alongside `min_path_length` and `max_path_length`.
- Built-in templates were stretched so each generated graph keeps at least one
  shorter route of 3 to 4 committed nodes after start and at least one longer
  route of 5 or more committed nodes after start.
- Template metadata now records a `pacing_profile` in route settings and route
  notices.
- Validation now enumerates all start-to-boss paths and reports path pacing
  issues with codes such as `path_too_short`, `path_too_long`,
  `shortest_path_too_long`, and `longest_path_too_short`.
- Validation enforces elite placement with codes such as
  `forced_elite_opener`, `back_to_back_elites`,
  `elite_shortest_path_over_limit`, and
  `elite_branch_without_alternative`.
- Validation compares sparse branch previews and reports
  `branch_preview_not_distinct` when sibling choices are not visibly different.
- Placeholder archetype tag selection varied by seeded depth plus lane so
  sibling branch previews remained meaningfully distinct before real encounter
  assignment replaced those tags in P4M5-T5.

P4M5-T5 assigned runtime-generated encounters to generated combat nodes:

- `ContractRouteGenerator.GENERATOR_VERSION` advanced to `p4m5.t5.v1` because
  generated node payloads and preview signatures intentionally changed.
- `ContractRouteGenerator.generate()` now loads the default runtime archetype
  library and assigns a `GeneratedMonsterDraft` to each fight, elite, and boss
  node. Start nodes remain non-combat and do not receive encounter payloads.
- Node encounter seeds are derived from route seed, route generator version,
  `node_encounter`, runtime monster generator version, archetype library schema,
  and stable generated node ID. This keeps per-node encounters reproducible
  without depending on a shared route RNG stream.
- Generated encounter inputs derive node kind from node type, difficulty from
  route difficulty plus depth/kind pressure, seeded tempo from node ID, and
  primary/secondary archetypes from the runtime archetype library's availability
  rules.
- Nodes preserve the full `GeneratedMonsterDraft.to_dictionary()` payload in
  `generated_encounter_payload`, including seed, source input, kind, HP,
  duration, archetype IDs/tags, selected mechanics, defense overrides, budget
  metadata, pressure metadata, and notices.
- `EncounterPreviewFormatter.format_generated()` now populates sparse
  `route_preview` from `contract_map`, while preserving detailed `combat` and
  `debug` preview sections on the node for later combat UI, Balance Lab, and
  inspection surfaces.
- `ContractRouteGenerator.graph_signature()` now includes encounter payload
  identity, source seed, kind, difficulty, tempo, and selected mechanics so
  same-seed/variation tests cover generated encounters as well as graph shape.
- `contract_route_generator_test.gd` now verifies generated encounter payload
  presence, metadata preservation, preview sparsity, preview section alignment,
  per-node child seed uniqueness, same-seed determinism, and authored-route
  regression coverage.

P4M5-T6 replaced placeholder presentation pools with seeded biome identity:

- `ContractRouteGenerator.GENERATOR_VERSION` advanced to `p4m5.t6.v1` and
  `PRESENTATION_TABLE_VERSION` advanced to `p4m5.presentation.v2` because
  generated biome/name output intentionally changed.
- Default generated routes now draw from Swamp, Cave, Graveyard, Haunted
  Forest, Ruined Keep, and Ancient Ruins presentation pools.
- Each biome has normal, elite, and boss monster name pools based on the T6
  content table while preserving runtime archetypes, mechanics, defense
  overrides, pressure metadata, and notices as the mechanical source of truth.
- Node-level biome now matches `ContractDef.selected_biome` for generated
  contracts, so settings such as `["Swamp", "Cave"]` pick one biome for the
  whole route instead of mixing biome identities across nodes.
- Presentation names populate `monster_presentation_type`, `display_name`, and
  formatted `route_preview.monster_name`; generated encounter payloads remain
  mechanically identical for the same seed/settings except presentation biome
  when only the allowed biome changes.
- `contract_route_generator_test.gd` now verifies presentation names come from
  the selected biome/kind pools, allowed-biome restrictions are respected, and
  biome presentation changes do not alter generated mechanical payloads.

P4M5-T8 added an isolated generated route inspection surface:

- `project/scripts/tools/generated_route_inspector.gd` provides
  `GeneratedRouteInspector.inspect(seed, settings)` for pure generate-and-report
  inspection without mutating Adventure state, save data, route choices,
  rewards, or contract offers.
- Inspection reports include route metadata, generator/runtime versions,
  selected and allowed biomes, template and pacing profile, validation notices,
  graph node summaries, sparse route previews, generated encounter summaries,
  combat previews, debug previews, generation notices, and payload/previews
  completeness checks.
- `project/scripts/tools/inspect_generated_route.gd` is a headless CLI runner
  for readable text or JSON reports.
- Example command:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://scripts/tools/inspect_generated_route.gd -- --seed=4242 --difficulty=medium --biomes=Swamp,Cave`
- Add `--json=true` to print the structured report as JSON.
- `project/tests/generated_route_inspector_test.gd` verifies same-seed report
  repeatability, seed variation, graph/preview/encounter/report shape, sparse
  route-map previews, preserved combat/debug previews, and useful text output.

P4M5-T9 added a deterministic and constraint matrix:

- `project/tests/generated_route_matrix_test.gd` runs generated route checks
  across default, single-biome, two-biome hard, and wider nightmare settings.
- The matrix samples same-seed reproduction and seed variation across multiple
  seed ranges, and asserts that changing route settings changes the graph
  signature for the same seed.
- Graph checks cover unique generated node IDs, one start, one boss, forward
  edges, outgoing-ID synchronization, no invalid dead ends, at least one
  branch, multiple start-to-boss paths, path length bounds, shortest/longest
  pacing, no forced elite opener, no back-to-back elites, optional elite branch
  alternatives, and terminal boss placement.
- Biome/presentation checks cover selected and node biome membership in
  `allowed_biomes`, presentation names coming from the biome/kind pool, and
  branch sibling preview distinctness.
- Preview checks enforce sparse route-map fields and forbid source seed, budget
  metadata, pressure metadata, defense overrides, selected mechanics,
  combat-preview, and debug-preview data from `ContractRouteNode.route_preview`.
- Encounter checks cover unique per-node child seeds, kind/difficulty/tempo
  source input, archetype IDs, selected mechanics, defense overrides, budget
  metadata, pressure metadata, notices, and combat/debug preview preservation.
- Inspector matrix checks confirm `GeneratedRouteInspector.inspect()` reports
  route metadata, previews, combat/debug payloads, and encounter source seeds
  matching the generated contract.

P4M5-T10 guarded authored contracts against generated-route regressions:

- `contract_route_data_test.gd` now explicitly verifies The Gilded Serpent
  contract has no generated route-level state and that every authored route
  node keeps generated node ID, depth/lane, outgoing generated IDs, biome,
  presentation type, generated encounter payload, combat/debug previews,
  route preview, and generation notices empty.
- The same test still walks the authored easy and harder Gilded Serpent paths
  through Portly Cook/Lazy Henchman/Knives/Vyra and Door Guard/Cloaked
  Watchmen/Knives/Vyra, preserving existing monster, reward, and traversal
  assertions.
- `map_overlay_route_preview_test.gd` now explicitly asserts an authored route
  node with empty generated fields uses the existing fallback text path with
  authored monster stats, duration, difficulty, and reward labels.
- `contract_offer_flow_test.gd` continues to protect the authored Adventure
  contract offer, Ghit Gudd Contract Window, Vyra contract card, Gilded Serpent
  route schematic, route selection, and planning transition.

P4M5-T11 closed the milestone and handed off P4M6:

- Current route generator version: `ContractRouteGenerator.GENERATOR_VERSION`
  is `p4m5.t6.v1`.
- Current biome/presentation table version:
  `ContractRouteGenerator.PRESENTATION_TABLE_VERSION` is
  `p4m5.presentation.v2`.
- Supported first-pass route settings include `allowed_biomes`,
  `route_difficulty`, `min_path_length`, `max_path_length`,
  `shortest_path_max`, `longest_path_min`, `template_family`, and optional
  `encounter_difficulty_id`.
- Generated route graphs are deterministic from route seed, route generator
  version, route settings, presentation table version, runtime monster
  generator version, and runtime archetype library schema.
- Generated route state is stored on `ContractDef` and `ContractRouteNode` as
  plain dictionary/array-friendly metadata for later P4M6 save/load policy.
- Generated combat nodes preserve runtime monster payloads plus sparse
  `route_preview`, detailed `combat_preview`, detailed `debug_preview`, and
  generation notices.
- Authored Gilded Serpent contract data remains generated-state-free and
  continues to use authored traversal, monster stats, rewards, and map fallback
  display.
- The isolated inspector remains available for P4M6 debugging:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://scripts/tools/inspect_generated_route.gd -- --seed=4242 --difficulty=medium --biomes=Swamp,Cave`

## Verification Notes

Run Balance Lab when P4M5 changes touch generated monster data, generated
difficulty, route pressure, reward placeholders, combat compatibility, or report
preservation.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Known local runner issue:

- Sandboxed Godot runs may hit the `user://logs` startup crash before script
  execution. Recent P4M4 verification passed when run outside the sandbox.

Expected focused verification by milestone close:

- Generated route generator tests.
- Generated route data-shape tests.
- Generated route preview tests.
- Runtime monster generator tests where encounter assignment is touched.
- Encounter preview formatter tests where route preview population is touched.
- Map overlay route preview tests.
- Contract route data tests.
- Contract offer flow tests to protect authored contract behavior.
- Balance Lab tests if generated route state or generated monster payloads flow
  into reports.

P4M5-T2 verification:

- `res://tests/generated_contract_route_data_shape_test.gd`: passed outside the
  sandbox.
- `res://tests/contract_route_data_test.gd`: passed outside the sandbox.
- `res://tests/map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `res://tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

P4M5-T3 verification:

- `res://tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `res://tests/generated_contract_route_data_shape_test.gd`: passed outside the
  sandbox.
- `res://tests/contract_route_data_test.gd`: passed outside the sandbox.
- `res://tests/map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `res://tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

P4M5-T4 verification:

- `res://tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `res://tests/generated_contract_route_data_shape_test.gd`: passed outside the
  sandbox.
- `res://tests/contract_route_data_test.gd`: passed outside the sandbox.
- `res://tests/map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `res://tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

P4M5-T5 verification:

- `res://tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `res://tests/generated_contract_route_data_shape_test.gd`: passed outside the
  sandbox.
- `res://tests/encounter_preview_formatter_test.gd`: passed outside the
  sandbox.
- `res://tests/runtime_monster_generator_test.gd`: passed outside the sandbox.
- `res://tests/map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `res://tests/contract_route_data_test.gd`: passed outside the sandbox.
- `res://tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

P4M5-T6 verification:

- `res://tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `res://tests/generated_contract_route_data_shape_test.gd`: passed outside the
  sandbox.
- `res://tests/map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `res://tests/contract_route_data_test.gd`: passed outside the sandbox.
- `res://tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

P4M5-T8 verification:

- `res://tests/generated_route_inspector_test.gd`: passed outside the sandbox.
- `res://tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `res://scripts/tools/inspect_generated_route.gd -- --seed=4242
  --difficulty=medium --biomes=Swamp,Cave`: passed outside the sandbox and
  printed a readable generated route report.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

P4M5-T9 verification:

- `res://tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `res://tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `res://tests/generated_route_inspector_test.gd`: passed outside the sandbox.
- `res://tests/generated_contract_route_data_shape_test.gd`: passed outside the
  sandbox.
- `res://tests/map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `res://tests/contract_route_data_test.gd`: passed outside the sandbox.
- `res://tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- `res://tests/encounter_preview_formatter_test.gd`: passed outside the
  sandbox.
- `res://tests/runtime_monster_generator_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

P4M5-T10 verification:

- `res://tests/contract_route_data_test.gd`: passed outside the sandbox.
- `res://tests/map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `res://tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- `res://tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `res://tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `res://tests/generated_route_inspector_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

P4M5-T11 verification:

- `res://tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `res://tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `res://tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Outside-sandbox runs showed only the known Godot exit cleanup
  warnings.

## Exit Criteria

P4M5 is complete when:

- Seeded route graphs support branching paths with start and boss anchors.
- Route graph generation is deterministic from seed and settings.
- Generated graph constraints prevent unreachable nodes, invalid dead ends, and
  unreadable pacing.
- Normal, elite, and boss fight nodes can carry deterministic generated monster
  payloads.
- Generated route previews use `EncounterPreviewFormatter.contract_map` through
  `ContractRouteNode.route_preview`.
- Biome and monster-type presentation identity exists as a seeded layer separate
  from mechanical archetypes.
- Focused tests cover determinism, graph validity, route-preview sparsity, and
  generated encounter metadata preservation.
- Existing authored contract behavior remains intact.
- This doc and `docs/P4_DawnBringer_Overview.md` are updated with final status,
  verification, known gaps, and P4M6 handoff notes.

## Follow-Ups For P4M6

- Connect generated route graphs to the Adventure contract offer flow.
- Decide where generated contract state is materialized and when route choices
  become committed.
- Define save/load behavior for route seeds, node seeds, resolved previews,
  generated monster payloads, and generator version mismatches.
- Preserve or migrate active generated contract state across restarts and
  failures.
- Add player-facing route commit UI for generated contracts.
- Decide how authored contracts and generated contracts coexist during the
  transition.
- Wire selected generated combat nodes into combat setup using the preserved
  generated encounter payload and combat preview state.
- Decide whether generated route state is stored as seed/settings only,
  materialized node state, or both.
- Keep `ContractRouteNode.route_preview` as the map-facing sparse preview
  boundary; keep combat/debug payloads out of the route map.
- Use `GeneratedRouteInspector.inspect()` while integrating generated contracts
  to compare generated state before and after Adventure flow materialization.
- Keep reward economy and final route pressure tuning queued for P4M7 unless
  integration needs minimal placeholders.
