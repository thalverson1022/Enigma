# Project DawnBringer Onboarding Context

## Read First

This is the lean handoff for Project DawnBringer, the standalone Phase 4 repo.
Use it to orient a new conversation quickly. For detailed milestone status, read
`docs/P4_DawnBringer_Overview.md`. For the active P4M9 task plan, read
`docs/P4M9_Contract_Shape_And_Map_Presentation.md`. For the P4M8 closeout
record, read `docs/P4M8_Contract_Variety_And_Content_Expansion.md`.

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

P4M5 completed procedural route generator infrastructure. P4M6 connected
generated contracts to Adventure offers, route flow, combat setup, save/load,
outcomes, and route UI. P4M7 completed generated rewards, reward previews,
route pressure scaling, anti-snowball/dead-run checks, Balance Lab economy
coverage, and generated reward lifecycle regressions.

P4M8 is complete: contract variety and content expansion added breadth to the
generated-contract spine without rewriting it:
runtime archetypes, mechanic combinations, biome/name/theme pools, modifiers,
elite variants, and boss variants. P4M8-T1 completed the baseline content
audit and accepted expansion targets. P4M8-T2 added the first runtime
archetype batch: `aegis`, `nullify`, `spiteful`, and `riftbound`. P4M8-T3
preserved the two-archetype method, added a 20% overlap-emphasis rule when both
rolled archetypes enable the same selected mechanic, and documented curated
pair identities for `aegis` + `fortified`, `nullify` + `warded`, `spiteful` +
`hexed`, `nimble` + `devious`, and `aegis` + `nullify`. P4M8-T4 expanded
existing biome presentation only: no new biomes, elite/boss pools are now 5/5
per biome, generated offers use a deterministic 12-template snarky Rogue voice
pack, and normal-name expansion is deferred. P4M8-T5 added a deterministic
metadata-only generated modifier model with `pressure_emphasis`,
`elite_spotlight`, `biome_hazard`, and `volatile_pacing`; modifier state is
materialized, save/load-covered, inspector/audit-visible, and sparse previews
show only compact modifier labels when appropriate. P4M8-T6 added elite branch
variants: `shieldbreaker_captain`, `null_priest`, `venom_speaker`,
`phase_duelist`, and `riftbound_marauder`; elite variant state is
materialized, save/load-covered, inspector/audit-visible, and sparse previews
show only compact elite labels. P4M8-T7 added boss endpoint variants:
`apex_bulwark`, `void_regent`, `plague_court`, and `chrono_tyrant`; boss
variant state is materialized, save/load-covered, inspector/audit-visible, and
sparse previews show only compact boss labels. P4M8-T8 completed the preview
readability pass: generated route cards now combine modifier and variant labels
into one compact identity line and keep sparse cards to a five-line shape while
hiding generated internals. P4M8-T9 broadened Balance Lab, matrix, and audit
coverage so deterministic samples must cover every route template, route
modifier, elite variant, boss variant, pressure axis, and P4M8 expanded
archetype. P4M8-T10 completed the repeatable contract loop: normal Adventure
continues from Vyra into generated contracts, Contract Test starts directly in
generated contracts, and both paths provide between-contract shops. P4M8-T11
completed the Adventure lifecycle regression pass across normal Adventure,
Contract Test, generated routing, repeated completions, save/load,
failure/restart, route UI, matrix, inspector, and Balance Lab gates. P4M8-T12
closed the milestone documentation and handed remaining Phase 4 work forward.
P4M9 is active for generated contract shape and map presentation expansion.
P4M10 owns regression, export, stabilization, and Phase 4 closeout.

## Current Milestones

Use `docs/P4_DawnBringer_Overview.md` as the source of truth.

- P4M0: Setup And Procedural Contracts Plan. Complete.
- P4M1: Enemy Defense Vocabulary. Complete.
- P4M2: Monster Lab Defense And Generation Prototype. Complete.
- P4M3: Runtime Monster Generator. Complete.
- P4M4: Encounter Preview And Matchup Readability. Complete.
- P4M5: Procedural Contract Route Generator. Complete.
- P4M6: Procedural Contract Integration. Complete.
- P4M7: Rewards, Resources, And Route Economy. Complete.
- P4M8: Contract Variety And Content Expansion. Complete.
- P4M9: Contract Shape And Map Presentation. In Progress.
- P4M10: Regression, Export, And Phase 4 Closeout. Not Started.

## Active P4M9 Focus

- Add meaningful generated route topology variety and improve generated
  contract-map readability/visual polish before export readiness.
- Preserve deterministic combat, materialized generated route state, sparse
  route previews, deterministic rewards, pressure metadata boundaries, and
  authored Gilded Serpent regression behavior.
- Treat this as the first layer of endless replayability: repeated generated
  contracts should create readable choices, escalating pressure, rewards, and
  an eventual fail state without depending on Phase 5 gear expansion.
- Prepare contracts for outside playtesters by making the generated loop feel
  presentable, readable, and intentionally varied.
- Keep presentation separate from mechanics: biome, monster names, and contract
  themes are fiction; archetype IDs, mechanics, defenses, pressure axes, and
  validation notices remain mechanical truth.
- Treat modifiers carefully. They should add readable texture, not become
  hidden economy systems, non-combat node systems, or combat rewrites.
- T5 modifiers are metadata-only route texture. Do not add reward/economy,
  combat, or route-node-system effects to them without a new scoped task.
- T6 elite variants are branch identity overlays. They force readable elite
  archetype pairs and labels, but they do not change rewards, economy, route
  topology, or non-combat systems.
- T7 boss variants are endpoint identity overlays. They force readable boss
  archetype pairs and labels, but they do not change rewards, economy, route
  topology, or non-combat systems.
- T8 preview readability keeps generated route cards sparse: biome, colored
  monster name, archetype tags, one combined modifier/variant identity line,
  and compact reward summary only.
- T9 coverage gates require generated-route samples to cover all templates,
  pressure axes, route modifiers, elite variants, boss variants, and P4M8
  expanded archetypes.
- P4M9-T8 completed the route layout and edge readability pass: generated maps
  now use deterministic renderer-side node offsets, non-overlap normalization,
  a five-wide-capable canvas, and curved generated route edges.
- P4M9-T9 completed node visual identity and interaction polish: generated
  cards now expose clearer available/selected/completed/locked treatment,
  role-colored borders, visible-node route lines, and a compact `Back` button
  without adding player-facing debug internals; ambiguous strip/corner marker
  cues and far-left starter fan lines were removed after screenshot feedback,
  and node-card text is limited to biome, color-coded enemy name, archetype
  tags, and rewards. The contract picker also now uses `Choose a Contract`,
  removes subtext, and limits offer cards to boss, location, and boss reward
  with larger contract iconography; generated boss cards show the `+1 talent
  point` reward. Generated contract maps use boss-objective titles and
  biome-aware Ghit-flavored route text instead of generic mechanical guidance.
  The generated route role formerly called `Hard` is now `Captain`, while
  `hard` remains a difficulty band. Endless generated contracts use five-stage
  blended scaling: later stages promote boss, elite, then Captain content to
  the next band before the full contract band advances, and stat pressure can
  overflow beyond Nightmare.
- P4M9-T10 completed renderer-side biome mood themes for generated contract
  maps. Swamp, Cave, Graveyard, Haunted Forest, Ruined Keep, and Ancient Ruins
  now have distinct map background tint, accent, themed route edges, and subtle
  boss-end mood treatment without adding gameplay effects or serialized route
  state.
- Generated contract text should use the current snarky, cocky Rogue voice for
  Rogue-focused playtesting; later classes can get class-specific voice packs.
- P4M8-T10 makes normal Adventure flow Tavern -> authored Vyra contract ->
  generated random contract loop, with a shop after each completed contract.
  Contract Test skips Tavern/Vyra and starts directly in the generated
  contract loop, also with a shop after each completed contract.
- P4M8-T11 adds a stitched lifecycle regression proving normal Adventure can
  move from Tavern/Vyra into generated contracts and Contract Test can repeat
  generated completions through shops, save/load, and deterministic next
  offers.
- P4M9 should add a modest batch of meaningfully different generated route
  templates, such as safe/risky branches, elite detours, wide matchup-choice
  maps, fork-and-rejoin routes, pressure gauntlets, and distinct boss approach
  lanes.
- P4M9 should improve map presentation using existing route state: stronger
  node spacing, path readability, biome/contract visual identity, elite/boss
  emphasis, danger/reward cues, and available-node polish.
- Keep non-combat route nodes, route-local resources, consumables, shop nodes,
  mystic upgrades, crafting/transmutation, boss bargains, scout/reveal nodes,
  and hidden events deferred until supporting systems are ready. The P4M8-T10
  shop is a between-contract playtest transition, not a route node.
- P4M10 should run the final Phase 4 regression/export closeout after P4M9
  stabilizes the generated contract map experience.

## Important Existing Surfaces

- Adventure mode is the main loop: title, class/subclass selection, Tavern
  ladder, rewards, shop, build/talent decisions, authored Vyra contract,
  generated contract loop, between-contract shops, route choices, boss victory,
  failure, and restart states.
- Practice Room is important for isolated Rogue build testing without mutating
  Adventure state.
- Monster Lab is the intended design sandbox for generated enemies.
- Balance Lab is the verification gate for combat, balance, route pressure,
  reward pacing, generated content coverage, and route viability changes.
- Runtime monster generation now produces deterministic `Monster` output plus
  seed, archetype IDs/tags, selected mechanics, defense overrides, budget
  metadata, pressure metadata, notices, and matchup-preview metadata.
- Practice Room can load archetype-style average defense presets, roll actual
  runtime-generated monsters by difficulty for isolated feel testing, replay a
  chosen generated seed, and show generated identity, pressure, defense,
  mechanic, budget, and notice metadata.
- Generated contract routes separate mechanical archetypes from presentation
  identity: biome and monster names are fiction; archetype IDs, mechanics,
  defenses, pressure metadata, and notices remain the mechanical source of
  truth.
- Generated contracts can now be materialized as Adventure offers, accepted
  into generated route maps, committed into deterministic generated combat,
  saved/loaded as materialized route state, and resolved through normal
  failure/retry/restart/completion behavior.
- Generated combat nodes now have deterministic materialized rewards, compact
  reward previews, route-depth and completed-contract pressure scaling,
  overflow Contract Pressure metadata, pressure-axis metadata, and lifecycle
  coverage for claims, duplicate-claim guards, pending gear choices, retries,
  failures, restarts, boss victories, and save/load.
- Generated routes now have deterministic materialized modifier state. Raw
  modifier IDs/dictionaries stay in debug/report surfaces; route cards may
  show only compact `modifier_label` text.
- Generated elites now have deterministic materialized elite variant state.
  Raw variant IDs/dictionaries stay in debug/report surfaces; route cards may
  show only compact `elite_variant_label` text.
- Generated bosses now have deterministic materialized boss variant state. Raw
  variant IDs/dictionaries stay in debug/report surfaces; route cards may show
  only compact `boss_variant_label` text.
- `GeneratedRouteInspector.inspect()` and
  `res://scripts/tools/inspect_generated_route.gd` can inspect seeded generated
  routes for content, pressure, preview, and validation work.

## Verification Notes

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Run Balance Lab when Phase 4 touches combat timing, event ordering, build
resolution, skill/talent/gear resources, enemy data, generated difficulty,
poison/proc behavior, rewards, route pressure, generated archetypes, generated
mechanic pools, modifiers, elites, bosses, or generated route previews.

Recent verification:

- P4M8-T12 passed P4M8 Adventure lifecycle regression, generated contract
  outcome, generated contract save/load, Contract Test entry, generated route
  matrix, Balance Lab, authored contract offer flow, and run failure state
  tests outside the sandbox.
- P4M8-T5 passed generated route matrix, generated route inspector, map overlay
  route preview, generated route UI preview, generated contract save/load,
  Balance Lab, and P4M8 content audit outside the sandbox. The audit sampled
  240 routes, 1,856 combat nodes, all four modifiers, and no route validation
  notices.
- P4M8-T6 passed generated route matrix, generated route inspector, generated
  contract save/load, generated route UI preview, generated contract outcome,
  map overlay route preview, Balance Lab, contract route generator, contract
  offer source, and P4M8 content audit outside the sandbox. The audit sampled
  240 routes, 1,837 combat nodes, all five elite variants, and no route
  validation notices.
- P4M8-T7 passed generated route matrix, generated route inspector, generated
  contract save/load, generated route UI preview, generated contract outcome,
  Balance Lab, contract route generator, contract offer source, and P4M8
  content audit outside the sandbox. The audit sampled 240 routes, 1,837 combat
  nodes, all four boss variants, and no route validation notices.
- P4M8-T8 passed map overlay route preview, generated route UI preview,
  generated route matrix, generated route inspector, Balance Lab, and P4M8
  content audit outside the sandbox. The audit sampled 240 routes, 1,837 combat
  nodes, all modifiers and variants, and no route validation notices.
- P4M8-T9 passed generated route matrix, Balance Lab, contract route generator,
  generated route inspector, and P4M8 content audit outside the sandbox. The
  audit sampled 240 routes, 1,837 combat nodes, all templates, all pressure
  axes, all route modifiers, all elite variants, all boss variants, all P4M8
  expanded archetypes, and no route validation notices.
- P4M8-T10 passed generated contract outcome, generated contract save/load,
  Contract Test entry, run failure state, run outcome presentation, dashboard
  header, contract offer source, save/load, and authored contract offer flow
  tests, plus Balance Lab, outside the sandbox.
- P4M8-T11 passed P4M8 Adventure lifecycle regression, generated contract
  outcome, generated contract save/load, Contract Test entry, run failure
  state, authored contract offer flow, generated route UI preview, map overlay
  route preview, generated route matrix, generated route inspector, contract
  offer source, save/load, Balance Lab, run outcome presentation, and dashboard
  header tests outside the sandbox.
- P4M7 closeout passed generated outcome, generated save/load, authored
  contract offer flow, authored route data, generated route UI preview, Balance
  Lab, route generator, generated route matrix, and contract offer source tests
  outside the sandbox.
- P4M6 closeout passed generated route UI preview, generated outcome,
  generated save/load, authored contract offer flow, authored route data, and
  run failure state tests outside the sandbox.
- P4M5 closeout passed generated route matrix, route generator, and contract
  offer flow tests outside the sandbox. See
  `docs/P4M5_Procedural_Contract_Route_Generator.md` for the full verification
  list.
- Sandboxed Godot runs may still hit the known `user://logs` startup crash
  before script execution.

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

- `docs/P4_DawnBringer_Overview.md`: living Phase 4 overview and tracker.
- `docs/P4M9_Contract_Shape_And_Map_Presentation.md`: active P4M9 route shape
  and map presentation task plan.
- `docs/P4M8_Contract_Variety_And_Content_Expansion.md`: P4M8 closeout record.
- `docs/P4M7_Rewards_Resources_And_Route_Economy.md`: P4M7 closeout and P4M8
  handoff.
- `docs/P4M6_Procedural_Contract_Integration.md`: generated contract
  integration closeout and P4M7 handoff.
- `docs/P4M5_Procedural_Contract_Route_Generator.md`: P4M5 closeout and
  generated route handoff.
- `docs/P4M4_Encounter_Preview_And_Matchup_Readability.md`: P4M4 closeout and
  P4M5 handoff notes.
- `docs/P4M3_Runtime_Monster_Generator.md`: P4M3 runtime generator closeout and P4M4 handoff.
- `docs/P4M2_Monster_Lab_Defense_And_Generation_Prototype.md`: Monster Lab
  prototype and archetype-library history.
- `docs/P4M1_Enemy_Defense_Vocabulary.md`: defense vocabulary implementation
  record.
- `docs/Enemy_Defense_Mechanics.md`: canonical defense mechanics reference.
- `docs/P4M0_Task_0_Procedural_Contracts_Plan.md`: P4M0 setup and planning record.
- `docs/P3_Technical_Debt_Architecture_Cleanup.md`: deferred technical triggers.
