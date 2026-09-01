# P4M9: Contract Shape And Map Presentation

## Purpose

P4M9 makes generated contracts feel more replayable and presentable before the
final Phase 4 closeout.

P4M5 through P4M8 built the generated-contract spine: deterministic route
graphs, generated encounter identity, sparse previews, Adventure integration,
materialized save/load, deterministic rewards, pressure scaling, repeatable
contracts, content breadth, modifiers, elite variants, boss variants, and
lifecycle coverage. The remaining gap is the feel of the contract map itself.
Generated contracts need more meaningful route shapes and stronger visual
readability so outside playtesters can understand the loop quickly and give
useful feedback on routing, enemy mechanics, pressure, rewards, and build
growth.

This milestone should add the first layer of endless replayability: repeatable
generated contracts with different routing questions, readable pressure and
reward tradeoffs, clear map presentation, and scaling that eventually produces
a fail state. The deeper gear chase belongs to the next phase.

## Milestone Goal

Make generated contract maps feel intentionally varied, readable, and ready for
external playtesting while preserving deterministic combat, sparse previews,
materialized route state, deterministic rewards, and authored Gilded Serpent
regression behavior.

By milestone close, generated contracts should ask visibly different route
questions across seeds, such as safe versus risky paths, elite detours, wide
matchup-choice maps, fork-and-rejoin decisions, pressure gauntlets, and
distinct boss approach lanes. The map UI should communicate branch identity,
available choices, danger, reward, biome/contract mood, elite presence, and boss
stakes without exposing combat/debug internals.

## Scope Notes

- P4M9 is about generated route topology variety and map presentation polish.
- Add a modest batch of route templates rather than an unconstrained graph
  generator rewrite.
- Every new route shape should answer a clear player question: avoid a bad
  matchup, chase a better reward, take an elite risk, shorten the route, accept
  pressure, or choose a boss approach.
- Preserve deterministic generation. Same seed/settings/version should produce
  the same template, node IDs, layout coordinates, rewards, previews, variants,
  and generated encounter payloads.
- Preserve materialized state and save/load behavior. Generated route shape,
  layout, node identity, previews, rewards, modifiers, variants, and accepted
  route progress must survive load.
- Keep sparse route-card boundaries. Map cards may become clearer, but they
  should still avoid raw seeds, raw IDs, defense tables, detailed mechanics,
  pressure internals, budget metadata, and debug payloads.
- Use existing signals first: node role, route depth, reward preview, pressure
  axis, modifier label, elite variant label, boss variant label, biome, and
  generated presentation identity.
- Visual juice should support readability. Avoid decorative changes that make
  route choices harder to scan.
- Keep non-combat route nodes, route-local resources, consumables, route shop
  nodes, mystic upgrades, crafting/transmutation, boss bargains,
  scout/reveal nodes, and hidden events deferred. The existing
  between-contract shop remains outside the contract map.
- Do not add reward/economy, combat, or route-node-system effects to P4M8
  metadata-only modifiers or variant overlays.
- Authored Gilded Serpent remains the authored regression baseline.
- P4M10 owns final regression, export, smoke testing, closeout docs, and
  external playtest build readiness after P4M9 stabilizes the map experience.

## Current Focus

P4M9 is complete. It closed route-shape audit, shape vocabulary/spec,
deterministic template metadata, safe/risky reward weighting,
elite-detour/pressure-gauntlet coverage, wide/fork-rejoin coverage, boss
approach lane variation, route layout/edge readability, generated node visual
identity polish, biome/contract mood presentation, matrix/inspector/save-load/UI
coverage, and the final playtest loop smoke/documentation pass. Continue with
P4M10 regression, export, and Phase 4 closeout.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M9-T1: Route Shape And Map Readability Audit | Complete | Compare current generated templates and map presentation against authored contract feel and repeated-play needs. | Current template count, repeated topology pain points, map readability issues, authored-contract comparison notes, and accepted P4M9 target shapes are recorded below. |
| P4M9-T2: Shape Vocabulary And Template Spec | Complete | Define the route shapes before touching generator code. | A bounded set of generated route templates is documented with player questions, path length bounds, branch rules, Captain/Elite/Boss placement rules, reward/pressure intent, layout intent, and deferred scope. |
| P4M9-T3: Route Template Selection And Metadata | Complete | Make template identity deterministic and inspectable. | Generated routes materialize a stable template ID/display label, template selection varies by seed/settings, save/load preserves template identity, and inspector/matrix output reports template coverage. |
| P4M9-T4: Safe/Risky And Reward-Weighted Branches | Complete | Add route shapes where the player chooses between lower-risk paths and higher-reward or higher-pressure paths. | At least one generated template creates a readable safe/risky branch using existing fight/elite/reward/pressure signals, with deterministic rewards and sparse preview coverage. |
| P4M9-T5: Elite Detour And Pressure Gauntlet Shapes | Complete | Add routes that make optional elite pressure and narrow high-pressure paths feel distinct. | At least one elite-detour template and one gauntlet-style template generate valid reachable graphs, preserve reward/pressure guardrails, and avoid forced dead-run structures. |
| P4M9-T6: Wide Matchup-Choice And Fork-Rejoin Shapes | Complete | Add routes that emphasize build matchup avoidance and branch comparison. | At least one wide-choice template and one fork-and-rejoin template expose multiple meaningful encounter previews while staying compact and readable in the map UI. |
| P4M9-T7: Boss Approach Lane Variation | Complete | Make the final approach to generated bosses feel more intentional. | Boss-adjacent route shapes can offer distinct pre-boss lanes or preparation paths without changing boss variant mechanics or adding new route systems. |
| P4M9-T8: Route Layout And Edge Readability Pass | Complete | Improve generated map spacing, node placement, and path legibility across the expanded template set. | Generated map edges use deterministic curved/organic paths instead of rigid right-angle rails; generated node positions receive small deterministic visual offsets while remaining inside bounds, non-overlapping, and readable across common desktop/window sizes. |
| P4M9-T9: Node Visual Identity And Interaction Polish | Complete | Make normal, Captain, elite, boss, available, completed, locked, high-pressure, and reward-heavy nodes easier to scan. | Existing node states receive clearer visual treatment, hover/selection feedback can highlight relevant generated edges, archetype/reward text is more readable, redundant biome text is reduced where safe, and visual cues use existing materialized route data rather than hidden mechanics. |
| P4M9-T10: Biome And Contract Mood Presentation | Complete | Add visual variety to generated contract maps without tying fiction to mechanical truth. | Generated maps use renderer-side biome theme definitions for background tint, route/accent colors, themed route-edge colors, and subtle boss-end mood treatment across Swamp, Cave, Graveyard, Haunted Forest, Ruined Keep, and Ancient Ruins without adding gameplay effects or serialized route data. |
| P4M9-T11: Matrix, Inspector, Save/Load, And UI Coverage | Complete | Extend verification so new shapes and presentation remain deterministic and readable. | Generated route matrix, route inspector, generated save/load, map overlay preview, route UI preview, Balance Lab, and authored contract regression coverage account for every new template, map-preview boundary, deterministic visual layout, biome theme, and visual-state rule. |
| P4M9-T12: Playtest Loop Smoke Pass And Documentation | Complete | Close the milestone with the repeated generated-contract loop in a presentable state. | Normal Adventure and diagnostic Contract Test coverage repeatedly complete generated contracts through shops, route maps remain readable across sampled templates, known gaps are documented, overview/onboarding are updated, and P4M10 closeout handoff is clear. |

## Initial Design Direction

P4M9 should treat route templates as the authored-feeling layer of procedural
contracts. The generator can remain simple if the template vocabulary is
expressive.

Accepted route shape vocabulary:

- `braided_sideboard`: three-wide opener with crossing follow-ups and an
  optional elite sideboard.
- `split_spill_rejoin`: four-wide opener that spills into two shared gates
  before a final rejoin.
- `elite_orbit`: three-wide opener with an elite route orbit that connects
  multiple entry lanes to an alternate boss approach.
- `five_way_market`: five-wide matchup/reward market that compresses into two
  late approaches.
- `hourglass_detour`: three-wide opener into one pinch point, then three-wide
  exit choices into boss.
- `woven_boss_approach`: three-wide opener that braids into four boss approach
  lanes.

T2 locks these as the first P4M9 implementation targets. The older
`safe_risky_split`, `elite_detour`, `wide_matchup`, `fork_rejoin`,
`pressure_gauntlet`, and `boss_approach_lanes` names remain design ancestry,
but the implementation spec below should drive T3-T7.

## Contract Map Visual Upgrade Guidance

Status: Accepted as design input for P4M9-T8 through P4M9-T10 on 2026-08-25.

The external visual brief should be treated as guidance for the existing P4M9
presentation tasks, not as a separate milestone or parallel task list. It maps
onto the current architecture because generated contracts already separate route
data from map rendering: `ContractDef` and `ContractRouteNode` materialize route
state, while `map_overlay.gd` interprets that state visually.

In scope for the first visual pass:

- Replace generated-map right-angle rails with deterministic curved/organic
  route edges.
- Add small deterministic visual offsets to generated node positions so maps
  feel less grid-like while preserving logical depth/lane structure.
- Keep boss placement visually dominant and near the far-right side.
- Improve hover/selection feedback so available or selected generated edges are
  easier to follow without hiding unrelated routes entirely.
- Define renderer-side biome visual themes for Swamp, Cave, Graveyard, Haunted
  Forest, Ruined Keep, and Ancient Ruins.
- Use subtle biome background tints, route colors, and accent colors before
  adding art-heavy background assets.
- Improve generated node card readability by emphasizing enemy name,
  Normal/Captain/Elite/Boss color, archetype tags, modifier/variant labels, and
  reward summary.
- Remove or reduce redundant biome labels on generated cards because generated
  contracts currently stay within one selected biome; keep node-level biome data
  available for future world-map crossover scope.

Deferred or optional polish:

- Decorative biome props are allowed only if implemented with reusable,
  deterministic, non-obstructing assets or simple shapes.
- Ambient particles are optional and should stay low-density, behind cards, and
  easy to disable if performance or readability suffers.
- Biome-specific route art, textures, bespoke icons, and painted backgrounds
  remain deferred until the lightweight renderer-side treatment proves useful.

Architectural constraints:

- Do not redesign contract generation for visual polish.
- Do not mix biome-art generation into encounter or reward generation.
- Keep visual layout deterministic for the same materialized contract state.
- Preserve sparse route-card boundaries: no raw seeds, raw IDs, detailed
  mechanics, pressure internals, budget metadata, or debug payloads in
  player-facing map cards.
- Prefer renderer-side dictionaries/resources for visual themes before adding
  new serialized route data.

## P4M9-T1 Route Shape And Map Readability Audit

Status: Complete on 2026-08-25.

Audit inputs:

- Read `project/scripts/systems/contract_route_generator/contract_route_generator.gd`,
  `project/scenes/combat/map_overlay.gd`,
  `project/scripts/resources/contract_def.gd`,
  `project/scripts/resources/contract_route_node.gd`,
  `project/scripts/tools/generated_route_inspector.gd`,
  `project/scripts/tools/inspect_generated_route.gd`,
  `project/tests/generated_route_matrix_test.gd`,
  `project/tests/generated_route_ui_preview_test.gd`, and
  `project/tests/map_overlay_route_preview_test.gd`.
- Sampled generated routes with
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://scripts/tools/inspect_generated_route.gd`
  outside the sandbox because the documented sandbox `user://logs` crash
  occurred before script execution.
- Sample seeds included `3000`, `3002`, `3003`, `3004`, and `3005`, plus a
  seed sweep from `3000` through `3025` to confirm current template rotation.

Current generated template count:

- The generator currently has 3 route templates in `TEMPLATES`.
- `split_merge`: 9 nodes including start and boss. Two normal opener lanes
  split immediately. One lane reaches the boss through three fights, the other
  reaches the boss through four fights.
- `optional_elite`: 9 nodes including start and boss. Same split/merge skeleton
  as `split_merge`, but the upper opener branch is an elite and the lower
  opener branch is a normal fight.
- `short_risk_long_safe`: 8 nodes including start and boss. One branch starts
  with an elite and reaches the boss after two combat nodes; the other branch
  takes four normal fights before the boss.
- The seed sweep from `3000` through `3025` produced all 3 current templates,
  so deterministic selection and matrix-visible coverage already exist.

Current validation and coverage strengths:

- Generated routes already materialize route identity through
  `route_settings["template_id"]`, `pacing_profile`, generated route IDs,
  node IDs, node depth/lane, outgoing IDs, previews, rewards, modifiers, elite
  variants, boss variants, and generated encounter payloads.
- `GeneratedRouteInspector.inspect()` reports template ID, pacing profile,
  route settings, validation notices, node previews, reward summaries, modifier
  labels, elite variant labels, boss variant labels, and debug payloads for
  internal audit use.
- `generated_route_matrix_test.gd` already checks determinism, route validity,
  path length bounds, branch count, sparse previews, generated payload shape,
  template coverage, biome coverage, modifier coverage, elite/boss variant
  coverage, and expanded archetype coverage.
- Sampled routes validated cleanly. The only live-run output was the known
  non-blocking ObjectDB/RID/resource cleanup noise at exit.

Repeated topology pain points:

- The current shape vocabulary is narrow. All 3 templates begin with the same
  immediate two-choice fork and resolve into either parallel lanes or one
  short risky lane versus one long normal lane.
- There are no true wide matchup-choice maps, late boss approach lanes,
  mid-route fork-and-rejoin decisions, or focused pressure gauntlets yet.
- Branching is front-loaded. Once the first route node is chosen, most current
  generated routes become a mostly linear chain until boss or near-boss merge.
- `split_merge` can feel like two copies of the same decision because both
  openers are normal fights and can roll the same biome, monster name, and
  archetype tag. Seed `3000` showed both opener choices as Swamp Goblins with
  `aegis`, so the first decision looked less distinct than the underlying
  generated payloads and rewards.
- `optional_elite` is the most readable current route question because the
  opener choice clearly contrasts normal fight versus elite risk and reward.
  It still reuses the same parallel-lane skeleton as `split_merge`.
- `short_risk_long_safe` clearly expresses route length versus elite risk, but
  the short branch jumps from depth 2 to the boss while the long branch stays
  linear. It needs stronger map treatment so the player reads it as an
  intentional shortcut rather than a missing middle route.

Map readability issues:

- Authored Gilded Serpent uses hand-tuned node positions. Generated maps use a
  generic depth/lane layout derived at render time in `map_overlay.gd`, with
  no route-template-specific layout metadata materialized on the contract or
  route nodes.
- Generated map positions exclude the start node and stretch visible nodes
  across a fixed `1040 x 500` canvas using min/max depth and lane. This works
  for the current two-lane maps, but it will not be expressive enough for
  wider or more irregular P4M9 templates without additional layout rules or
  materialized placement metadata.
- Generated edges are rendered as simple orthogonal rails from card edge to
  card edge. They do not encode state, danger, reward, elite detours, boss
  approach lanes, or available path emphasis.
- Current UI tests prove generated cards do not overlap and preserve a compact
  `148 x 116` five-line sparse preview, but they do not check edge crossings,
  ambiguous merges, boss endpoint emphasis, or readable multi-lane spacing.
- Available, selected, and locked states exist, but generated normal, elite,
  boss, reward-heavy, and high-pressure nodes mostly rely on card text and
  existing color treatment. Elite/boss labels are present in sparse previews,
  but the full map does not yet give them strong board-level silhouette.
- Biome and contract mood are visible as text on cards, not as map-level
  presentation. This preserves mechanical clarity but leaves generated maps
  feeling more like debug graphs than contract boards.

Authored Gilded Serpent comparison notes:

- Gilded Serpent has a readable authored structure: an initial easy-versus-hard
  opener, a second branch choice inside each lane, convergence into Knives,
  then Vyra as the boss endpoint.
- Authored route nodes carry explicit difficulty and reward-language labels
  such as `Hard Opener`, `Easy Opener`, `Reward Opportunity`,
  `Elite Pressure`, and `Contract Boss`. Generated nodes currently carry
  deterministic role/reward/preview data, but not equivalent route-shape
  language.
- Authored map presentation uses hand-tuned spacing and convergence lines that
  make branch shape legible even before reading card details. Generated map
  presentation has deterministic spacing, but the layout is generic and does
  not yet communicate branch intent by shape.
- Authored route story text helps the player understand the route decision.
  Generated story text has a generic branch tradeoff comparison for two
  immediate choices, but no template-specific framing for elite detours, boss
  approach lanes, gauntlets, or wide matchup selection.

Accepted P4M9 target shapes from T1:

- `safe_risky_split`: keep as a first implementation target, using existing
  fight/elite, pressure, and reward signals to make lower-risk versus
  higher-reward branches obvious.
- `elite_detour`: keep as a first implementation target, distinct from the
  current opener-only `optional_elite` by making the elite feel like an
  optional side branch or detour rather than merely the first lane choice.
- `wide_matchup`: keep as a first implementation target for replayability,
  giving the player a broader middle layer of readable encounter previews for
  build matchup avoidance.
- `fork_rejoin`: keep as a first implementation target, using early branch
  identity followed by convergence without bloating total route length.
- `pressure_gauntlet`: keep as a first implementation target, using a narrow
  escalation path with explicit pressure/reward presentation while preserving
  existing no-dead-run validation boundaries.
- `boss_approach_lanes`: keep as a first implementation target for late-route
  variety, offering two readable pre-boss approaches into the same generated
  boss without changing boss variant mechanics.
- T2 supersedes these initial names with the wider Captain-aware template
  vocabulary below. These T1 shapes remain useful as design ancestry and
  intent labels, not final implementation IDs.

Accepted constraints for T2:

- Keep the template list bounded and authored-feeling. Prefer a modest batch
  of explicit templates over an unconstrained graph rewrite.
- Define path length bounds, branch rules, elite placement, boss placement,
  reward/pressure intent, and layout intent per template before implementation.
- Preserve sparse route-card boundaries and keep raw generated internals in
  inspector/debug surfaces only.
- Use existing route data first. If map readability needs more than depth/lane,
  add deterministic layout metadata as materialized generated state rather
  than deriving fragile UI-only positions.
- Keep non-combat route nodes, route-local currencies, route shops, scout
  nodes, hidden events, consumables, and modifier gameplay effects deferred.

## P4M9-T2 Shape Vocabulary And Template Spec

Status: Complete on 2026-08-25.

Design premise:

- Generated maps may vary between 1, 2, 3, 4, and 5 options at different route
  layers.
- Every generated template in the P4M9 shape vocabulary must contain at least
  one decision layer that is 3 or more options wide.
- Width means the number of immediately available route choices from a single
  route node. A template can narrow, rejoin, braid, split again, or offer
  optional sideboards after satisfying the 3+ width requirement.
- Avoid pure two-lane templates as new P4M9 targets. Two-choice moments are
  allowed inside a larger template, but should not be the main identity of the
  generated map.
- Prefer braided and sideboarded graphs over flat parallel lanes, as long as
  path readability remains high.

Combat node vocabulary:

- `Normal`: baseline generated combat node. Uses normal monster kind, normal
  presentation pools, normal reward table, and green difficulty name treatment.
- `Captain`: new planned combat node between Normal and Elite. It should use
  normal monster kind and normal archetype/name pools, but add a node-level
  difficulty bump and a reward table between Normal and Elite. It should not
  use elite variants, boss variants, or elite reward counts.
- `Elite`: high-risk combat node. Uses elite monster kind, elite presentation
  pools, elite variants, elite reward table, and orange difficulty name
  treatment.
- `Boss`: single endpoint combat node. Uses boss monster kind, boss
  presentation pools, boss variants, boss reward table, and red difficulty
  name treatment.

Difficulty color-name rule:

- Route-card monster names should visually communicate combat role by color:
  green for Normal, blue for Hard, orange for Elite, and red for Boss.
- The color should apply to the monster/name emphasis, not replace the text
  role. The map must remain readable for color-blind players through labels,
  node role text, shape, or icon/state treatment.
- This is a presentation rule only. Color does not change combat payloads,
  rewards, pressure, variants, or validation.

Captain implementation intent for later tasks:

- Add first-class generated-route support for Captain if implementation needs a
  saved node role. The safest likely path is a `ContractRouteNode.NodeType.CAPTAIN`
  enum value that maps to runtime `monster_kind = "normal"`.
- Captain should report route preview level `Hard`, receive a `+1` node-level
  difficulty bump, and use a `hard` reward role/table.
- Captain should count as non-elite for elite pacing checks, elite variant
  assignment, boss variant assignment, and all no-forced-elite validation.
- Captain should count as combat pressure for route-shape intent, branch
  comparison, reward tuning, and sparse map readability.

Template specs:

### `braided_sideboard`

Player question: choose a starting matchup, then decide whether to follow the
braid toward pressure, take a shared gate, or detour into an elite sideboard.

Graph sketch:

```text
Start -> N low road  -> H toll fight     -> N rejoin -> Boss
      -> H main road -> H toll fight
                     -> H pressure fight -> N rejoin
                     -> E sideboard      -> N rejoin
      -> N high road -> H pressure fight
```

Shape rules:

- Required wide layer: `Start` has 3 outgoing choices.
- Recommended visible node count: 8 combat nodes plus start.
- Recommended path length bounds: shortest 3 combat nodes before boss, longest
  4 combat nodes before boss.
- Branching may cross from neighboring lanes, but edges should avoid ambiguous
  overdraw.
- The elite sideboard should be optional and reachable from the central lane,
  not a forced opener.

Node role rules:

- Start choices: `N`, `H`, `N`.
- Middle gates: mostly `H`, with one optional `E`.
- Boss: exactly one `B`.
- No back-to-back elites.

Reward/pressure intent:

- Low/high normal roads are safer openers.
- Main road and toll/pressure fights carry the Hard premium.
- Elite sideboard offers the largest non-boss reward but should cost route
  pressure and/or matchup danger.

Layout intent:

- Read as a woven route board, not three separate lanes.
- Keep the optional elite slightly off the main flow so it visibly feels like a
  sideboard.

### `split_spill_rejoin`

Player question: draft one of four openers, then watch those choices spill into
two shared gates before a final route convergence.

Graph sketch:

```text
Start -> N safe start  -> H shared gate A -> H final gate -> Boss
      -> N odd matchup -> H shared gate A
      -> H hard start  -> N recovery      -> H final gate
      -> N long start  -> N recovery
```

Shape rules:

- Required wide layer: `Start` has 4 outgoing choices.
- Recommended visible node count: 7 combat nodes plus start.
- Recommended path length bounds: 3 combat nodes before boss on every path.
- The first layer should include at least two distinct preview axes so the
  four choices are not just cosmetic.

Node role rules:

- Start choices: `N`, `N`, `H`, `N`.
- Shared gates: one `H`, one `N`, then one late `H`.
- No elite required in this template.
- Boss: exactly one `B`.

Reward/pressure intent:

- Captain start and Captain gate routes pay modestly better than pure normal routes.
- This is a clean matchup-choice template, not an elite-risk template.

Layout intent:

- Read as a wide fan that compresses into two columns, then one final gate.
- Shared gates should make convergence obvious rather than look like missing
  route branches.

### `elite_orbit`

Player question: choose a main route, or loop through a tempting elite orbit
that changes the late approach.

Graph sketch:

```text
Start -> N main      -> N merge A -> Boss
      -> H hard      -> N merge A
      -> N alternate -> H merge B -> Boss
N main      -> E elite orbit -> H merge B
N alternate -> E elite orbit
```

Shape rules:

- Required wide layer: `Start` has 3 outgoing choices.
- Recommended visible node count: 6 combat nodes plus start.
- Recommended path length bounds: shortest 2 combat nodes before boss, longest
  3 combat nodes before boss.
- The elite orbit should be reachable from at least two non-elite branches and
  exit into a different late approach than the default merge.

Node role rules:

- Start choices: `N`, `H`, `N`.
- Orbit: exactly one optional `E`.
- Merge nodes: one `N`, one `H`.
- Boss: exactly one `B`.

Reward/pressure intent:

- Main/hard/alternate choices provide matchup variety.
- Elite orbit should have clear high reward and should affect the late path
  without changing boss mechanics.

Layout intent:

- Draw the elite orbit as a curved or offset side path if layout metadata makes
  that possible.
- Avoid making the orbit look like the mandatory center line.

### `five_way_market`

Player question: pick from a large market of matchup/reward options, including
one elite prize, then resolve into one of two boss approaches.

Graph sketch:

```text
Start -> N armor path  -> H left merge   -> Boss
      -> N poison path -> H left merge
      -> H evasion     -> N center merge -> Boss
      -> H warded      -> N center merge
      -> E elite prize -> N center merge
```

Shape rules:

- Required wide layer: `Start` has 5 outgoing choices.
- Recommended visible node count: 7 combat nodes plus start.
- Recommended path length bounds: 2 combat nodes before boss on every path.
- This is the widest planned P4M9 template and should be sampled carefully for
  map-card spacing before additional five-wide templates are added.

Node role rules:

- Start choices: `N`, `N`, `H`, `H`, `E`.
- Merge nodes: one `H`, one `N`.
- Boss: exactly one `B`.
- The elite has non-elite alternatives in the same choice layer.

Reward/pressure intent:

- Normal choices are safer matchup picks.
- Captain choices offer better rewards or stronger preparation.
- Elite prize is the high-variance option.

Layout intent:

- Needs deterministic layout metadata or a template-aware layout pass so five
  opener cards stay legible.
- The two merge lanes should be visually distinct as late approaches.

### `hourglass_detour`

Player question: choose among three openers, survive a shared pinch point, then
choose among three exits with different risk/reward profiles.

Graph sketch:

```text
Start -> N safe  -> H pinch point -> N low exit    -> Boss
      -> H hard  -> H pinch point -> H hard exit   -> Boss
      -> N weird -> H pinch point -> E elite exit  -> Boss
```

Shape rules:

- Required wide layers: `Start` has 3 outgoing choices and the pinch point has
  3 outgoing choices.
- Recommended visible node count: 7 combat nodes plus start.
- Recommended path length bounds: 3 combat nodes before boss on every path.
- The pinch point must not become a hidden failure point. It should be
  presented as the template identity.

Node role rules:

- Start choices: `N`, `H`, `N`.
- Pinch point: one `H`.
- Exit choices: `N`, `H`, `E`.
- Boss: exactly one `B`.

Reward/pressure intent:

- The pinch point is shared route pressure.
- Exit choices decide whether the player cashes out safely, accepts a Hard
  reward bump, or takes the elite spike before boss.

Layout intent:

- Read as an hourglass: wide, narrow, wide, boss.
- The second wide choice layer should be as visually clear as the opener.

### `woven_boss_approach`

Player question: choose an opener, then move through interwoven preparation
nodes that create four distinct boss approach lanes.

Graph sketch:

```text
Start -> N entry A -> H prep D -> Boss
                 -> N prep E -> Boss
      -> H entry B -> N prep E
                 -> E prep F -> Boss
      -> N entry C -> E prep F
                 -> H prep G -> Boss
```

Shape rules:

- Required wide layer: `Start` has 3 outgoing choices.
- Secondary width: the prep layer has 4 distinct boss approach nodes.
- Recommended visible node count: 7 combat nodes plus start.
- Recommended path length bounds: 2 combat nodes before boss on every path.
- Cross-lane edges are part of the identity, but every approach should still
  read as a legal, reachable preparation lane.

Node role rules:

- Start choices: `N`, `H`, `N`.
- Prep layer: `H`, `N`, `E`, `H`.
- Boss: exactly one `B`.
- Elite prep is optional and reachable from two opener lanes.

Reward/pressure intent:

- This template should make the boss endpoint feel more intentional by giving
  the player distinct last-step preparation choices.
- Captain prep lanes provide middle rewards; elite prep is the high-risk route.

Layout intent:

- Read as a braid that opens into boss approaches, with the boss visually
  emphasized as the shared endpoint.
- Edge readability is critical; this template should drive T8 edge polish.

Validation requirements for T3-T7:

- Every generated template must have exactly one start and one boss endpoint.
- Every non-boss node must have at least one outgoing edge.
- Boss must have no outgoing edges.
- All edges must move forward in depth.
- No unreachable nodes.
- No unintended dead ends.
- No back-to-back elites.
- No all-elite opener layer.
- Any branch containing an elite must also offer a non-elite alternative from
  the same decision point or from the preceding route structure.
- Every template must have at least one decision point with 3 or more outgoing
  choices.
- Captain nodes should be covered by matrix, inspector, save/load, route UI, map
  overlay, and Balance Lab checks once implemented.
- Sparse route previews must remain limited to player-facing biome, monster
  name, role/difficulty name, archetype tags, compact modifier/variant labels,
  and compact reward summary.

Deferred scope:

- No route shops, route-local resources, consumables, mystic upgrades,
  crafting/transmutation, boss bargains, scout/reveal nodes, hidden events, or
  non-combat route nodes in P4M9 templates.
- No gameplay effects from biome mood, modifier labels, elite variant labels,
  boss variant labels, or color treatment.
- No boss mechanic rewrites. Boss approach lanes may alter the pre-boss route,
  but boss variants remain metadata/presentation overlays as defined in P4M8.

## Map Presentation Direction

The map should feel more like a playable contract board and less like a debug
graph.

Presentation targets:

- Clearer node spacing and deterministic layout per template.
- More legible route edges, especially around splits and rejoins.
- Stronger available-node, selected-node, completed-node, locked-node, hard,
  elite, and boss visual states.
- Compact danger/reward cues from existing preview metadata.
- Light biome or contract-mood treatment that supports scanability.
- Stronger boss endpoint presence.
- No debug metadata on route cards.
- No new gameplay effects from purely visual labels or moods.

## Expected Implementation Surfaces

- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`:
  template selection, route topology, node depth/lane, graph validity,
  pressure/reward shape rules, and generated layout metadata if needed.
- `project/scripts/resources/contract_def.gd`: generated route-level template
  state and serialization helpers if template identity is not already stored.
- `project/scripts/resources/contract_route_node.gd`: node layout/preview state
  if the UI needs more deterministic map presentation data.
- `project/scripts/tools/generated_route_inspector.gd` and
  `project/scripts/tools/inspect_generated_route.gd`: template/layout/preview
  inspection output.
- `project/scenes/combat/map_overlay.gd`: route card display, node/edge layout,
  node state styling, available-choice readability, and hard/elite/boss
  emphasis.
- `project/tests/generated_route_matrix_test.gd`: route template coverage,
  validity, deterministic layout, and route-shape sampling.
- `project/tests/generated_route_inspector_test.gd`: inspector coverage for
  template IDs, layout metadata, previews, notices, modifiers, elites, and
  bosses.
- `project/tests/generated_contract_save_load_test.gd`: materialized template
  and layout state survives save/load.
- `project/tests/generated_route_ui_preview_test.gd` and
  `project/tests/map_overlay_route_preview_test.gd`: sparse route-card and map
  presentation boundaries.
- `project/tests/balance_lab_test.gd`: broad generated route health, route
  viability, pressure/reward pacing, snowball warnings, dead-run warnings, and
  coverage gates.
- `project/tests/p4m8_adventure_lifecycle_regression_test.gd` or successor:
  repeated generated-contract lifecycle smoke coverage after map changes.

## P4M9-T3 Route Template Selection And Metadata

Status: Complete on 2026-08-25.

Implementation summary:

- `ContractDef` now materializes generated route template identity as stable
  top-level state: `template_id`, `template_display_label`, and
  `template_width_summary`.
- Generated route state and save/load preserve template identity, width
  summary, outgoing node IDs, previews, rewards, modifiers, variants, and
  generated encounter payloads without regenerating.
- `ContractRouteNode.NodeType.CAPTAIN` was added after the existing generated
  enum values so authored/generated numeric compatibility for Fight, Elite,
  Boss, and Start remains stable.
- Captain nodes are first-class route nodes but use runtime `monster_kind =
  "normal"` presentation/combat pools. Their encounter level is `Hard`, their
  rewards sit between Normal and Elite, and their pressure/prep score is higher
  than Normal but below Elite.
- Deterministic template selection now rotates across the six locked T2
  templates: `braided_sideboard`, `split_spill_rejoin`, `elite_orbit`,
  `five_way_market`, `hourglass_detour`, and `woven_boss_approach`.
- Each generated template reports a width summary with `max_width`,
  `wide_node_ids`, `branch_node_ids`, and `requires_wide_choice`; validation
  requires at least one three-plus-wide choice point.
- The route inspector reports template ID, display label, width summary, Hard
  node count, and the existing modifier/variant/reward/payload details.
- Balance Lab generated-route checks now require Captain node coverage alongside
  template, archetype, modifier, elite-variant, and boss-variant coverage.
- Map preview presentation treats Captain names as blue via the existing master
  tier color, Elite as orange/legendary, Boss as red/warning, and Normal as
  green/poison. The difficulty color is presentation-only; sparse cards still
  avoid raw debug/combat internals.

T3 tuning notes:

- Elite talent rewards moved from depth 3 to depth 4 so depth-3 elite exits do
  not violate the existing early-talent pressure guard.
- Reward pressure validation now compares pressure-scaled elite/boss gold
  against a pressure-scaled normal baseline.
- Captain nodes add a small path-prep score bonus, matching their intended role as
  a meaningful step between Normal and Elite.

Focused verification passed:

- `res://tests/generated_contract_route_data_shape_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/balance_lab_test.gd`

## P4M9-T4 Safe/Risky And Reward-Weighted Branches

Status: Complete on 2026-08-25.

Implementation summary:

- Generated route nodes now materialize branch intent as internal route state:
  `branch_intent` plus `branch_intent_tags`.
- The six P4M9 templates annotate non-boss combat options with reusable intent
  tags such as `safe`, `risky`, `high_reward`, `captain_gate`, `recovery`,
  `elite_detour`, `boss_prep`, `matchup_choice`, and `long_safe`.
- Branch intent is saved and loaded through generated node state. It is also
  available in debug/encounter payloads and inspector output.
- Sparse route cards remain clean: branch intent is not added to
  `route_preview` and is not shown as another gameplay text line.
- Reward-weighted options receive a modest deterministic gold bonus through the
  existing reward table path. `high_reward` branches gain more than plain
  risky branches, and both remain inside existing pressure/reward guardrails.
- Generated route validation now requires at least one readable safe/risky or
  safe/high-reward branch tradeoff, backed by role risk or visible reward
  spread.
- The route inspector reports branch intent per node and summary counts for
  safe, risky, and high-reward intent coverage.
- Balance Lab now includes `generated_route_branch_intent_coverage` to ensure
  sampled generated routes cover safe, risky, and reward-weighted branch intent.

Focused verification passed:

- `res://tests/generated_contract_route_data_shape_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/balance_lab_test.gd`

## P4M9-T5 Elite Detour And Pressure Gauntlet Shapes

Status: Complete on 2026-08-25.

Implementation summary:

- `elite_orbit` remains the primary optional elite-detour template. Its elite
  route is tagged `elite_detour` and `high_reward`, while normal/hard routes
  can bypass it.
- `braided_sideboard`, `five_way_market`, `hourglass_detour`, and
  `woven_boss_approach` also expose elite-detour intent where their route
  shapes include an optional elite payoff.
- `split_spill_rejoin` and `hourglass_detour` now explicitly mark Captain-heavy
  lanes with `pressure_gauntlet` intent.
- Generator validation now checks elite-detour routes have both a detour path
  and a bypass path.
- Generator validation now checks pressure-gauntlet routes include a Captain-heavy
  path and a safe/recovery alternative.
- Inspector checks report `elite_detour_node_count`,
  `pressure_gauntlet_node_count`, `has_elite_detour_intent`, and
  `has_pressure_gauntlet_intent`.
- Matrix coverage now requires sampled routes to include elite-detour intent,
  pressure-gauntlet intent, and at least one Captain-heavy path.
- Balance Lab now includes `generated_route_t5_detour_gauntlet_coverage` so
  generated-route health checks include the T5 shape concepts.
- Sparse route-card boundaries remain unchanged. The player-facing map still
  communicates danger and reward through role color, monster name, archetype
  tags, modifier/variant labels, and reward summary rather than raw intent
  tags.

Focused verification passed:

- `res://tests/generated_contract_route_data_shape_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/balance_lab_test.gd`

## P4M9-T6 Wide Matchup-Choice And Fork-Rejoin Shapes

Status: Complete on 2026-08-25.

Implementation summary:

- `five_way_market` now explicitly marks its five opener choices with
  `wide_matchup_choice` intent, giving the generator a clear three-plus-wide
  matchup comparison template.
- `split_spill_rejoin`, `five_way_market`, and `woven_boss_approach` now mark
  their split/merge structure with `fork_rejoin` intent.
- Generator validation now checks wide matchup-choice routes have a branch with
  at least three marked matchup options.
- Generator validation now checks fork/rejoin routes actually split into
  branches that meet again before the boss, rather than only meeting at the
  boss endpoint.
- Inspector checks report `wide_matchup_choice_node_count`,
  `fork_rejoin_node_count`, `has_wide_matchup_choice_intent`, and
  `has_fork_rejoin_intent`.
- Matrix coverage now requires sampled routes to include wide-matchup intent
  and structural fork/rejoin behavior.
- Balance Lab now includes `generated_route_t6_wide_fork_coverage` so the broad
  generated-route health report includes T6 shape coverage.
- Sparse route-card boundaries remain unchanged. Wide/fork intent stays in
  internal route metadata, debug payloads, inspector output, and validation,
  while player-facing cards continue to show biome, monster name, role color,
  archetype tags, modifier/variant labels, and reward summary.

Focused verification passed:

- `res://tests/generated_contract_route_data_shape_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/balance_lab_test.gd`

## P4M9-T7 Boss Approach Lane Variation

Status: Complete on 2026-08-25.

Implementation summary:

- `elite_orbit`, `five_way_market`, `hourglass_detour`, and
  `woven_boss_approach` now mark selected boss-adjacent nodes with
  `boss_approach` intent.
- Boss approach lanes can now carry distinct role tags:
  `safe_boss_approach`, `captain_boss_approach`, `elite_boss_approach`, and
  `reward_boss_approach`.
- Generator validation checks tagged boss approach templates expose at least
  two direct pre-boss lanes and at least two distinct approach roles.
- Generator validation also catches tagged boss-approach nodes that do not
  directly connect to the generated boss node.
- Inspector checks now report boss-approach node count, approach roles, and
  whether boss approach lane variation is present.
- Matrix coverage now requires sampled templates to include boss approach
  variation plus safe, Captain, and Elite boss-approach role coverage.
- Balance Lab now includes `generated_route_t7_boss_approach_coverage`, keeping
  boss-approach shape coverage visible in the broader generated-route health
  report.
- Boss variant mechanics remain unchanged. T7 only clarifies pre-boss routing
  choices using existing node roles, rewards, route pressure, modifiers,
  variants, and sparse preview boundaries.

Focused verification passed:

- `res://tests/generated_contract_route_data_shape_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/balance_lab_test.gd`

## P4M9-T8 Route Layout And Edge Readability Pass

Status: Complete on 2026-08-25.

Implementation summary:

- Generated contract maps now use a taller renderer-side canvas sized for the
  current five-wide route layer while preserving compact generated route cards.
- Generated node positions still derive from materialized `depth` and `lane`,
  but receive small deterministic visual offsets from stable node IDs so maps
  feel less grid-locked without adding serialized layout state.
- Column normalization keeps generated cards inside bounds and non-overlapping,
  including five-wide opener layers such as `five_way_market`.
- Boss placement remains clamped near the far-right side with reduced offset
  drift so the endpoint stays visually dominant.
- Generated map edges now render as deterministic sampled Bezier `Line2D`
  curves with shadow/glint treatment instead of rigid right-angle rail
  segments.
- Generated edge color uses existing route state only: selected edges, current
  available edges, and the committed/current node get stronger readable
  emphasis without exposing branch-intent or debug metadata.
- Sparse route-card boundaries and generated route save/load state are
  unchanged; T8 is renderer-only.
- Focused UI tests now assert deterministic bounded positions, no generated
  card overlap, curved generated edges, edge metadata, and generated canvas
  sizing.

Focused verification passed outside the sandbox:

- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/generated_route_matrix_test.gd`
- `res://tests/balance_lab_test.gd`

## P4M9-T9 Node Visual Identity And Interaction Polish

Status: Complete on 2026-08-25.

Implementation summary:

- Generated route cards now derive a renderer-only visual state from existing
  materialized route state: `available`, `selected`, `completed`, or `locked`.
- Generated node fills, role-colored borders, shadows, and disabled treatment
  now vary by visual state while preserving the existing compact sparse card
  text.
- A screenshot feedback pass removed the ambiguous colored left-edge strips and
  corner-square cues; generated cards now rely on border/state treatment,
  monster-name color, reward text, and route-line emphasis instead of
  unexplained extra markers.
- Generated Start remains hidden as a card and no longer draws the far-left
  starter fan lines; generated map edges now connect only visible route nodes.
- Generated node-card text is limited to biome, color-coded enemy name,
  archetype tags, and rewards.
- The contract route back button now uses the compact `Back` label.
- The contract picker header now reads `Choose a Contract`, omits helper
  subtext, and renders each offer as boss name, `Location: <Biome>`, and boss
  reward with a larger contract icon and boss-name font; generated boss offers
  now expose their `+1 talent point` reward.
- Generated contract maps now use boss-objective titles such as
  `Defeat the Swamp Hydra` and biome-aware Ghit-flavored route text instead of
  generic contract-name/mechanical guidance copy.
- Generated route role vocabulary now separates node role from difficulty:
  `Hard` route nodes became `Captain` nodes while `hard` remains a difficulty
  band. New generated routes preserve the old enum slot for save compatibility
  but report role metadata, reward quality, and intent tags as Captain.
- Endless generated scaling now uses five-stage blended bands. As a medium
  loop scales, stage 3 promotes boss content to the next band, stage 4 promotes
  bosses plus elites, stage 5 promotes bosses, elites, and Captain nodes, and
  the next contract band makes all nodes use that next-band content. Stat
  pressure continues separately and can overflow past Nightmare.
- Generated route edges now expose visual-state metadata and use stronger
  width/color for available and selected edges, while locked routes remain
  subdued and completed/current paths remain readable.
- No branch-intent/debug/combat internals are added to player-facing cards, and
  no generated route data or save/load schema changed.
- Focused UI tests now assert generated node visual-state metadata, absence of
  ambiguous strip/corner cues, hidden modifier/variant labels, compact Back
  button text, curved edge state metadata, visible edge layer, and active edge
  width.

Focused verification passed outside the sandbox:

- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/generated_route_matrix_test.gd`
- `res://tests/balance_lab_test.gd`

## P4M9-T10 Biome And Contract Mood Presentation

Status: Complete on 2026-08-26.

Implementation summary:

- Generated contract maps now resolve a renderer-side biome theme from the
  active generated contract biome, with a fallback theme for unknown/legacy
  cases.
- Theme definitions cover Swamp, Cave, Graveyard, Haunted Forest, Ruined Keep,
  and Ancient Ruins.
- Each theme provides map background tint, soft wash, accent color, route-edge
  color, available/selected/completed edge colors, and a subtle boss-end mood
  wash.
- The generated map canvas draws noninteractive theme background layers behind
  route lines and node cards; these layers carry metadata for tests but do not
  enter generated contract state.
- Generated route edges inherit the active biome theme while preserving the
  existing selected, available, completed, and locked state model.
- Decorative treatment stays intentionally light: no art assets, particles,
  props, mechanics, rewards, combat effects, or route-node systems were added.
- Sparse node cards remain limited to biome, color-coded enemy name, archetype
  tags, and reward summary.
- Focused UI tests now assert all six biome themes, themed canvas metadata,
  noninteractive background layers, boss-end mood treatment, themed edge
  metadata, and contract-biome theme selection in the real generated map UI.

Focused verification passed outside the sandbox:

- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`

## P4M9-T11 Matrix, Inspector, Save/Load, And UI Coverage

Status: Complete on 2026-08-31.

Implementation summary:

- Generated route edge presentation now treats completed route segments as
  active path history: completed edges use the active route-line width and
  glint layer so the chosen route remains legible while selecting later nodes.
- `map_overlay_route_preview_test.gd` now explicitly covers selected forward
  path highlighting and completed-path preservation while a future node is
  pending.
- The focused matrix gate verifies deterministic generation, every P4M9 route
  template, route validity, route width, sparse previews, single-biome
  generated contracts, pressure/content promotion, modifier coverage, elite and
  boss variant coverage, Captain coverage, and expanded archetype coverage.
- The inspector gate verifies repeatable report signatures, route/template
  metadata, branch intent checks, modifier/variant reporting, sparse preview
  boundaries, and text report usefulness.
- The generated save/load gate verifies generated offer, accepted route,
  selected node/planning state, claimed rewards, between-contract shop state,
  repeated generated-contract progression, supported mismatch notices, and
  unsupported generated-state rejection.
- The generated route UI gate verifies real combat/map UI behavior including
  boss-objective titles, biome themes, curved route edges, fixed card sizing,
  sprite-frame cards, silhouette highlights, reward icon boxes, compact
  player-facing text, locked/available/selected states, and hidden debug
  internals.
- The authored contract regression keeps the Gilded Serpent/Vyra contract flow
  covered after the shared map renderer changes, including hideout frame art,
  curved paths, reward icon stacks, silhouette highlights, no old enemy
  markers, route selection/deselection, and second-subclass choice behavior.
- Balance Lab and lifecycle/outcome regressions still pass after the
  presentation verification pass.

Focused verification passed outside the sandbox:

- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/contract_offer_flow_test.gd`
- `res://tests/p4m8_adventure_lifecycle_regression_test.gd`
- `res://tests/balance_lab_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/generated_contract_route_data_shape_test.gd`
- `res://tests/generated_contract_outcome_test.gd`

Known non-blocking output:

- Sandboxed Godot still hit the known `user://logs` crash before script
  execution.
- Outside-sandbox runs passed and emitted the existing ObjectDB/RID/resource
  cleanup warnings at exit.

## P4M9-T12 Playtest Loop Smoke Pass And Documentation

Status: Complete on 2026-09-01.

Closeout summary:

- Normal Adventure now skips the authored Vyra contract for this phase: after
  Tavern, Ghit's generated-contract materials pitch sends the player to three
  generated biome contract offers. The authored Vyra contract data and handler
  remain in place for later restoration and regression use.
- Contract Test remains as a diagnostic signal and test path, but the title
  menu no longer exposes it to players.
- The late gameplay cleanup pass added the Monster Manual, boss checklist,
  all-bosses victory screen, Hold intrinsic skill, Ancient Ruins enemy sprites,
  top-menu access through overlay phases, Practice Room target/HUD cleanup,
  Practice Room 10-talent-point sandboxing, and Thief/Steal clarity fixes.
- Generated map and contract-card presentation stayed within the P4M9 scope:
  readable route shapes, sparse cards, larger contract offer iconography,
  preview-before-commit route flow, and no new route-node systems.
- P4M10 inherits regression/export closeout rather than additional generated
  route design work.

Focused verification passed outside the sandbox:

- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_contract_outcome_test.gd`
- `res://tests/p4m8_adventure_lifecycle_regression_test.gd`
- `res://tests/run_failure_state_test.gd`
- `res://tests/contract_offer_flow_test.gd`
- `res://tests/contract_test_entry_test.gd`
- `res://tests/dashboard_header_test.gd`
- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_fight_setup_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/hold_skill_test.gd`
- `res://tests/generated_boss_checklist_test.gd`
- `res://tests/monster_manual_overlay_test.gd`
- `res://tests/thief_subclass_test.gd`
- `res://tests/combat_playback_test.gd`
- `res://tests/balance_lab_test.gd`

Known non-blocking output:

- Outside-sandbox Godot runs still emit the existing ObjectDB/RID/resource
  cleanup warnings at exit.

## Verification Notes

Run Godot 4.7 from:

`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`

Run Balance Lab when P4M9 changes:

- generated route topology, template selection, or layout metadata;
- generated route validation or reachability;
- generated reward previews, reward pacing, route pressure, or dead-run checks;
- map overlay route cards, node state rendering, or sparse preview formatting;
- generated contract save/load state;
- Adventure generated-loop progression;
- combat setup payloads or generated encounter assignment.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Known local runner issue:

- Sandboxed Godot runs may hit the known `user://logs` startup crash before
  script execution. Recent milestone verification passed outside the sandbox.

## Exit Criteria

P4M9 is complete when:

- Current generated route shape and map presentation gaps are audited.
- A bounded route shape vocabulary is documented and implemented.
- Generated route template identity is deterministic, materialized,
  save/load-covered, inspector-visible, and matrix-visible.
- Generated contracts include meaningfully different route shapes across seeds.
- New shapes preserve valid directed start-to-boss graphs with no unreachable
  nodes, no invalid outgoing edges, no unintended dead ends, and readable path
  length bounds.
- Route choices expose clearer tradeoffs using existing matchup, reward,
  pressure, elite, boss, modifier, and biome signals.
- Map layout and node/edge visuals are readable enough for outside playtesters.
- Sparse route-card boundaries remain intact.
- No deferred route systems are introduced.
- Authored Gilded Serpent behavior remains intact.
- Balance Lab and focused route/save/load/UI/lifecycle regressions pass or
  have documented known non-blocking runner issues.
- This doc, `docs/P4_DawnBringer_Overview.md`, and onboarding context are
  updated with final status, verification results, known gaps, and P4M10
  closeout handoff notes.

## Follow-Ups For P4M10

- Run the full Phase 4 regression/export closeout pass.
- Stabilize any rough generated-route tuning found during P4M9.
- Prepare the external playtest build and export smoke test.
- Document the final Phase 4 state and the minimum Phase 5 gear-redesign
  handoff context.
- Commit the final Phase 4 closeout state, push it to GitHub, and promote
  DawnBringer so the finished Phase 4 code becomes the repository main branch.
- Keep deeper route systems deferred until there is enough playtester feedback
  to justify them.
