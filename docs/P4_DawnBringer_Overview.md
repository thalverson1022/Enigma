# Project DawnBringer Overview

## Purpose

This is the lean Phase 4 overview and milestone tracker. Keep detailed task
history in milestone docs so this file remains efficient onboarding context.

Phase 4 goal: make procedurally generated contracts and contract routes a core
Adventure-loop system. Players should read enemy defenses, choose routes based
on build matchups, earn resources/rewards, improve synergies, and push toward
harder fights.

## Current State

P4M0-P4M9 are complete. P4M9 closed generated contract shape and map
presentation expansion: route topology, node/edge readability, contract copy,
Captain role vocabulary, blended scaling, renderer-side biome mood themes,
matrix/inspector/save-load/UI coverage, and the final playtest loop smoke pass.
P4M10 is active for regression, export, final handoff documentation, commit,
push, and promoting DawnBringer so the finished Phase 4 code becomes the
repository main branch. P4M10-T1 locked the closeout scope and branch-promotion
plan on 2026-09-01. P4M10-T2 completed the repo/documentation/export audit on
2026-09-01 and handed the expanded regression list to T3. P4M10-T3 completed
the expanded scripted regression pass and standalone Balance Lab report on
2026-09-01 with no code fixes required. P4M10-T4 completed the focused
player-facing smoke pass on 2026-09-01, fixing Practice Room seed/layout
regressions and stale authored-route smoke expectations. P4M10-T5 produced the
Windows playtest export candidate on 2026-09-01, bundled the runtime archetype
library into project resources, and smoke-launched the exported runtime.
P4M10-T6 completed the release blocker pass on 2026-09-01 with no remaining
release blockers and no code fixes required. P4M10-T7 created the lean Phase 5
handoff at `docs/P5_Minimum_Handoff_From_Phase_4.md` on 2026-09-01. P4M10-T8
completed final closeout documentation on 2026-09-01. Phase 4 is functionally
complete for verification/export/handoff purposes, with only T9 final
commit/push/GitHub main-branch promotion still pending.

P4M5 delivered the procedural contract route generator infrastructure:
deterministic seeded route graphs, start/boss anchors, branching templates,
route pacing validation, generated encounter assignment, biome presentation
identity, sparse route previews, generated combat/debug payload preservation,
an isolated route inspector, matrix coverage, and authored Gilded Serpent
regression guards.

P4M6 connected those generated routes to Adventure mode: contract offers,
route acceptance, route-node commit, generated combat setup, save/load policy,
failure/retry/restart/completion behavior, and authored/generated coexistence.
T1 documented the generated contract lifecycle and active generated save/load
policy. T2 added the small contract offer source/helper while preserving
Gilded Serpent behavior. T3 added opt-in generated `ContractDef` offer creation
from seed/settings. T4 added pending authored/generated offer coexistence and
opt-in generated offer selection while preserving Gilded Serpent as the default
regression baseline. T5 added generated route-node commit eligibility while
preserving authored route validation. T6 added generated combat setup from
committed route-node payloads. T7 added active generated contract save/load for
materialized generated state, including generated offer, accepted route,
selected node/planning, supported mismatch notices, and clean unsupported-load
rejection. T8 verified generated contract failure, retry, restart, route
reward claiming, route continuation, and boss victory behavior. T9 verified
generated route UI previews in the real Adventure combat/map UI. T10 kept the
authored Gilded Serpent regression gate passing after generated integration.
T11 closed the milestone documentation and handed reward/economy work to P4M7.

## Milestones

| Milestone | Status | Focus |
| --- | --- | --- |
| P4M0: Setup And Procedural Contracts Plan | Complete | Standalone DawnBringer repo and Phase 4 spine. |
| P4M1: Enemy Defense Vocabulary | Complete | Defensive mechanics that make routing decisions meaningful. |
| P4M2: Monster Lab Defense And Generation Prototype | Complete | Monster Lab archetype, defense, difficulty, validation, and preview sandbox. |
| P4M3: Runtime Monster Generator | Complete | Deterministic runtime-generated monsters and compatibility tests. |
| P4M4: Encounter Preview And Matchup Readability | Complete | Sparse route previews plus combat/debug generated encounter previews. |
| P4M5: Procedural Contract Route Generator | Complete | Deterministic generated route graphs with encounters, presentation, validation, and regression coverage. |
| P4M6: Procedural Contract Integration | Complete | Generated contracts are wired into Adventure offers, route flow, combat setup, save/load, outcomes, route UI, and authored regression coverage. |
| P4M7: Rewards, Resources, And Route Economy | Complete | Generated combat rewards, risk/reward pacing, route pressure, anti-snowball checks, and lifecycle regressions are covered. |
| P4M8: Contract Variety And Content Expansion | Complete | Expanded archetypes, biome pools, modifiers, elite/boss variants, contract themes, repeatable generated-contract playtesting, and lifecycle coverage. |
| P4M9: Contract Shape And Map Presentation | Complete | Add meaningful generated route topology variety and improve contract-map readability/visual polish without adding new route systems. |
| P4M10: Regression, Export, And Phase 4 Closeout | In Progress | Stabilize, verify, export, document the Phase 5 handoff, commit, push, and promote DawnBringer as the repository main branch. |

## P4M6 Closeout

Source doc: `docs/P4M6_Procedural_Contract_Integration.md`.

Completed task order:

1. `P4M6-T1`: define integration requirements and save/load policy. Complete.
2. `P4M6-T2`: add a small contract offer source/helper so Adventure no longer
   hardcodes one authored contract path. Complete.
3. `P4M6-T3`: create generated `ContractDef` offers from seed/settings.
   Complete.
4. `P4M6-T4`: let authored and generated offers coexist while preserving
   Gilded Serpent as the regression baseline. Complete.
5. `P4M6-T5`: allow generated route nodes to be committed in `BuildState`.
   Complete.
6. `P4M6-T6`: convert selected generated encounter payloads into deterministic
   combat-ready encounters. Complete.
7. `P4M6-T7`: save/load active generated contract state according to the
   documented policy. Complete.
8. `P4M6-T8`: verify failure, retry, restart, and completion behavior.
   Complete.
9. `P4M6-T9`: verify real Adventure route UI previews for generated routes.
   Complete.
10. `P4M6-T10`: keep authored contract regression coverage passing. Complete.
11. `P4M6-T11`: update docs and hand off reward/economy work to P4M7.
    Complete.

## P4M7 Closeout

- P4M7-T1 completed the generated route economy model and acceptance criteria.
- P4M7-T2 replaced placeholder generated node rewards with deterministic
  normal/elite/boss reward tables and save/load/test coverage.
- P4M7-T3 added compact generated reward preview language to route map cards
  without exposing combat/debug internals.
- P4M7-T4 deferred non-combat nodes and route-local resources until monster
  and contract balance, route size, gear attributes, character talent trees,
  shop economy, consumables, and mystic/run-upgrade systems are more mature.
- P4M7-T5 added bounded completed-contract pressure scaling for generated
  encounters and rewards, plus focused coverage for depth, role, and later
  contract pressure.
- P4M7-T6 materialized the three-scale model: Monster Level, capped Monster
  Difficulty, and overflow Contract Pressure beyond Nightmare, with validation
  guardrails for pressure/reward mismatches.
- P4M7-T7 materialized pressure-axis metadata and added dead-run route
  validation for same-axis branches, all-path axis domination, and low-prep
  shortest paths before high-pressure bosses.
- P4M7-T8 broadened Balance Lab economy coverage for generated route notices,
  sparse preview boundaries, rewards, overflow pressure, completed-contract
  pressure changes, and pressure-axis diversity.
- P4M7-T9 verified generated economy state through Adventure reward claims,
  retries, failures, restarts, boss victories, duplicate-claim guards, pending
  generated gear choices, and save/load lifecycle regressions.
- P4M7-T10 closed the milestone documentation and handed content-expansion work
  to P4M8.

P4M8 handoff:

- P4M8-T1 completed the current generated-content audit and accepted expansion
  targets: add 4-6 runtime archetypes, 6-10 curated mechanic-combination
  patterns, larger biome/name/theme pools, 3-5 scoped modifiers if useful,
  3-5 elite variants, and 3-4 boss variants while preserving sparse previews
  and deterministic materialized state.
- P4M8-T2 added four runtime archetypes: `aegis` for block-led physical
  mitigation without armor, `nullify` for absorb-led magical mitigation without
  poison resistance, `spiteful` for cleanse/suppress debuff-poison disruption,
  and `riftbound` for controlled mixed elite/boss pressure. Runtime generator, preview
  vocabulary, route pressure-axis mapping, route reachability, generated route
  matrix, and Balance Lab checks passed outside the sandbox.
- P4M8-T3 started with a bounded two-archetype overlap-emphasis rule: when both
  rolled archetypes enable the same selected mechanic, the merged mechanic
  receives a 20% range emphasis inside the existing merge path. The mechanic
  still appears once, and no separate combo engine was added. It also locked
  curated pair identities for `aegis` + `fortified`, `nullify` + `warded`,
  `spiteful` + `hexed`, `nimble` + `devious`, and `aegis` + `nullify`.
- P4M8-T4 expanded existing biome presentation only: no new biomes, elite and
  boss pools are now 5/5 per biome, generated offer text uses a deterministic
  12-template snarky Rogue voice pack, unique sampled presentation names rose
  to 88, and route validation notices stayed empty. Normal-name expansion is
  deferred unless later audits show it is the highest-value repetition issue.
- P4M8-T5 added a deterministic metadata-only generated modifier model with
  four route textures: `pressure_emphasis`, `elite_spotlight`,
  `biome_hazard`, and `volatile_pacing`. Modifier IDs and dictionaries are
  materialized in generated route state, node labels are saved/loaded, sparse
  previews may show only compact `modifier_label` text, validation rejects
  hidden reward/economy/combat modifier payloads, and inspector/audit/Balance
  Lab coverage now reports modifier distribution. The 240-route audit sampled
  all four modifiers with no route validation notices.
- P4M8-T6 added five deterministic elite branch variants:
  `shieldbreaker_captain`, `null_priest`, `venom_speaker`, `phase_duelist`,
  and `riftbound_marauder`. Variants force readable elite archetype pairs,
  materialize elite variant state, expose only compact `elite_variant_label`
  text in sparse previews, keep raw IDs/debug payloads out of route cards, and
  preserve presentation-vs-mechanics separation. The 240-route audit sampled
  all five variants with no route validation notices.
- P4M8-T7 added four deterministic boss endpoint variants:
  `apex_bulwark`, `void_regent`, `plague_court`, and `chrono_tyrant`.
  Variants force readable boss archetype pairs, materialize boss variant state,
  expose only compact `boss_variant_label` text in sparse previews, and keep
  raw variant IDs/debug payloads out of route cards. The 240-route audit
  sampled all four variants with no route validation notices.
- P4M8-T8 completed the preview readability pass. Generated route cards now
  keep biome, colored monster name, archetype tags, one combined
  modifier/variant identity line, and compact reward summary within a five-line
  shape while continuing to hide seeds, raw IDs, mechanics, defenses, pressure
  metadata, and debug payloads. The 240-route audit remained clean.
- P4M8-T9 broadened Balance Lab, matrix, and audit coverage. Generated-route
  coverage gates now require all route templates, all pressure axes, all route
  modifiers, all elite variants, all boss variants, and all P4M8 expanded
  archetypes to appear in deterministic samples. The 240-route audit reported
  all coverage targets met with no missing IDs and no route validation notices.
- P4M8-T10 completed the repeatable contract loop for playtesting: normal
  Adventure remains Tavern -> authored Vyra contract, then continues into
  generated random contracts with a shop after each completed contract;
  Contract Test starts directly at that generated contract loop and also
  provides a shop after each completion. Completed-contract and offer counters
  now persist through save/load and feed deterministic generated offer pressure.
- P4M8-T11 completed the Adventure lifecycle regression pass. A stitched
  lifecycle test now covers normal Adventure -> Vyra -> generated contracts,
  Contract Test -> repeated generated contracts, between-contract shops,
  repeated completions, save/load states, and deterministic offer advancement;
  focused generated outcome, generated save/load, route UI, matrix, inspector,
  Balance Lab, authored offer flow, failure/restart, and header/presentation
  checks also passed outside the sandbox.
- P4M8-T12 closed the milestone documentation and originally handed regression,
  export, stabilization, and Phase 4 closeout work forward. Final closeout gates
  passed outside the sandbox: P4M8 Adventure lifecycle regression, generated
  contract outcome, generated contract save/load, Contract Test entry,
  generated route matrix, Balance Lab, authored contract offer flow, and run
  failure state.
- Next, take P4M10 through regression, export, Phase 5 minimum handoff
  documentation, final closeout docs, commit, push, and GitHub main-branch
  promotion.
- Preserve P4M7 route economy boundaries: rewards remain deterministic,
  generated route previews stay sparse, and combat/debug pressure metadata
  stays out of map cards.
- Revisit reward-table variety after the expanded content set reveals which
  reward families need more expression.
- Playtesting found generated maps need more interesting and meaningful route
  choices. P4M9 owns that scoped route/map design task before export closeout.
- P4M9-T11 completed the matrix, inspector, save/load, UI, authored-contract,
  lifecycle, outcome, generator, and Balance Lab coverage pass for generated
  route shapes and map presentation. Completed route edges now retain active
  path emphasis so the chosen route remains legible while selecting later
  nodes.
- P4M9-T12 closed the milestone on 2026-09-01. Normal Adventure now skips the
  authored Vyra contract for this phase and sends the player from Tavern into
  Ghit's generated-contract materials pitch and three generated biome offers;
  Vyra data remains for later restoration and regression. Contract Test is
  hidden from the title menu but remains available as a diagnostic signal/test
  path. The closeout pass also records the Monster Manual/checklist, all-bosses
  victory screen, Hold skill, Ancient Ruins sprites, top-menu overlay access,
  Practice Room cleanup, and Thief/Steal clarity fixes.
- Keep non-combat route nodes, route-local resources, consumables, shop nodes,
  mystic upgrades, crafting/transmutation, boss bargains, and scout/reveal
  nodes deferred until supporting systems are ready. The repeatable-loop shop
  is a between-contract playtest transition, not a route node.
- Keep Gilded Serpent as the authored regression baseline even while the player
  Adventure path temporarily skips Vyra.
- Run Balance Lab gates for route pressure, reward pacing, generated combat
  outcomes, snowball warnings, and dead-run warnings.

P4M9 task plan:

- Source doc: `docs/P4M9_Contract_Shape_And_Map_Presentation.md`.
- Start with a route shape and map readability audit, then lock the shape
  vocabulary before changing generator code.
- Implement deterministic template identity, safe/risky branches, elite
  detours, pressure gauntlets, wide matchup-choice routes, fork-and-rejoin
  routes, and boss approach lane variation as scoped templates.
- Generated map spacing, curved edge readability, generated node visual states,
  biome/contract mood presentation, and final smoke coverage are complete.
- P4M10 now owns the final Phase 4 regression/export closeout, external
  playtest build handoff, Phase 5 minimum context handoff, final closeout
  commit, GitHub push, and promoting DawnBringer to the repository main branch.

P4M10 task plan:

- Source doc: `docs/P4M10_Regression_Export_And_Phase_4_Closeout.md`.
- P4M10-T1 is complete: closeout scope and the branch-promotion plan are locked
  before running export work.
- P4M10-T2 is complete: repo/docs/export state is audited, the dirty tree is
  understood at closeout level, and the runtime archetype library export risk
  is recorded for T3/T5/T6.
- P4M10-T3 is complete: the expanded scripted regression pass and standalone
  Balance Lab report passed outside the sandbox.
- P4M10-T4 is complete: the focused player-facing smoke pass covered:
  Title -> class/subclass -> Tavern -> Ghit generated-contract pitch -> three
  generated offers -> route map -> combat -> rewards -> shop -> next generated
  contract.
- P4M10-T5 is complete: the Windows playtest export candidate exists at
  `project/export/windows/DawnBringer.exe`; its `.pck` bundles the runtime
  archetype library, and the exported runtime launched headless with exit code
  0.
- P4M10-T6 is complete: release blocker verification found no remaining
  crashes, stuck states, save/load corruption, broken exports, missing critical
  assets, unreadable route maps, or player-facing debug leaks.
- P4M10-T7 is complete: `docs/P5_Minimum_Handoff_From_Phase_4.md` records the
  current playable flow, generated-contract ownership, provisional balance and
  gear caveats, Phase 5 gear priorities, deferred systems, key files/tests,
  verification, and the Windows export artifact.
- P4M10-T8 is complete: final closeout docs are synced across the P4M10
  closeout doc, overview, onboarding context, and Phase 5 handoff, with T9
  still pending for final commit/push/promotion details.
- Next, perform the final staging review, commit the Phase 4 state, push it to
  GitHub, promote DawnBringer so the finished Phase 4 code is the repository
  main branch, and record the final commit hash/promotion method.

Recent P4M6 closeout verification passed outside the sandbox:

- `project/tests/generated_route_ui_preview_test.gd`
- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_route_data_test.gd`
- `project/tests/run_failure_state_test.gd`

Recent P4M7 closeout verification passed outside the sandbox:

- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_route_data_test.gd`
- `project/tests/generated_route_ui_preview_test.gd`
- `project/tests/balance_lab_test.gd`
- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/contract_offer_source_test.gd`

## Durable Design Rules

- Generated monster mechanics remain separate from presentation identity.
  Archetypes, defenses, pressure, mechanics, and notices are mechanical truth;
  biome and monster names are fiction/presentation.
- Contract-map previews show sparse learnable information only: biome,
  generated monster name, Normal/Elite/Boss level, and archetype tags.
- Detailed armor, resist, defense mechanics, pressure metadata, and budget data
  belong in combat/debug/report surfaces after route commitment.
- Contract difficulty should eventually rise through completed-contract pressure
  and route economy constraints, not an infinitely farmable easy ladder.

## Key Files

- `project/project.godot`: Godot project.
- `project/scripts/autoload/build_state.gd`: Adventure state, contract offer,
  route commit, fight, outcome, retry, and restart behavior.
- `project/scripts/resources/contract_def.gd`: contract identity plus generated
  route-level state helpers.
- `project/scripts/resources/contract_route_node.gd`: route graph node data plus
  generated node state helpers.
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`:
  deterministic generated contract route creation.
- `project/scripts/tools/generated_route_inspector.gd`: isolated generated route
  inspection.
- `project/scenes/game_root.gd`: includes the Contract Test shortcut; P4M8-T10
  should make it skip Tavern/Vyra and enter the generated contract loop
  directly for fast playtesting.
- `project/data/contracts/the_gilded_serpent.tres`: authored contract regression
  baseline.

## Verification Gates

Run Godot 4.7 from:

`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`

Run Balance Lab when changes touch:

- combat timing or event ordering;
- build resolution;
- skill, talent, gear, monster, or enemy data;
- generated encounter difficulty;
- generated combat setup or reports;
- route reward pressure;
- poison, proc, duration, or DPS behavior.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Known local runner issue:

- Sandboxed Godot runs may hit the known `user://logs` startup crash before
  script execution. Recent milestone verification passed outside the sandbox.

## Repo Notes

- Repo root: `F:\Data\Claude Projects\Project-DawnBringer`
- Godot project: `F:\Data\Claude Projects\Project-DawnBringer\project\project.godot`
- Godot executable: `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`
- Godot version: 4.7
- Active/default branch: `phase-4-dawnbringer`
- Origin: `https://github.com/thalverson1022/DawnBringer.git`
- Historical upstream: `https://github.com/thalverson1022/Bane.git`
- Imported baseline tag: `dawnbringer-start`

## Reference Docs

- `docs/P4M10_Regression_Export_And_Phase_4_Closeout.md`: active final Phase 4
  closeout plan.
- `docs/P4M8_Contract_Variety_And_Content_Expansion.md`: P4M8 closeout record.
- `docs/P4M9_Contract_Shape_And_Map_Presentation.md`: P4M9 route shape and map
  presentation task plan.
- `docs/P4M7_Rewards_Resources_And_Route_Economy.md`: P4M7 closeout and
  P4M8 content-expansion handoff.
- `docs/P4M6_Procedural_Contract_Integration.md`: P4M6 closeout and P4M7 handoff.
- `docs/P4M5_Procedural_Contract_Route_Generator.md`: P4M5 closeout and generated route handoff.
- `docs/P4_DawnBringer_Onboarding_Context.md`: lean conversation onboarding.
- `docs/Enemy_Defense_Mechanics.md`: defense mechanics reference.
- `docs/P3_Technical_Debt_Architecture_Cleanup.md`: deferred technical triggers.
