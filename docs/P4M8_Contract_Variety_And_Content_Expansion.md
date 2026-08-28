# P4M8: Contract Variety And Content Expansion

## Purpose

P4M8 turns the generated contract system from a working deterministic route,
combat, reward, and save/load pipeline into a broader content experience.

P4M5 through P4M7 built the generated-contract spine: deterministic route
graphs, sparse route previews, Adventure integration, generated combat setup,
materialized save/load, generated rewards, route pressure scaling,
anti-snowball/dead-run checks, Balance Lab coverage, and authored Gilded
Serpent regression protection.

This milestone should expand the content that flows through that spine:
runtime monster archetypes, mechanic combinations, biome presentation pools,
monster names, contract themes, modifiers, elite variants, and boss variants.
The goal is more readable variety, not a new contract-system rewrite.

## Milestone Goal

Make generated contracts produce a wider range of readable, thematic,
mechanically distinct routes and fights while preserving deterministic combat,
sparse route previews, materialized rewards, and authored contract regression
coverage.

By milestone close, generated contracts should feel less repetitive across
seeds and biomes, route choices should expose more matchup variety, elites and
bosses should have clearer identities, and Balance Lab/focused tests should
cover the expanded content set.

## Scope Notes

- Content expansion should build on the existing runtime monster generator,
  contract route generator, offer source, route preview, reward, pressure, and
  save/load surfaces.
- Generated monster mechanics remain separate from presentation identity.
  Archetype IDs, mechanics, defenses, pressure axes, and notices are mechanical
  truth; biome names, monster names, and contract themes are fiction.
- Generated route previews remain sparse and player-readable: biome,
  generated monster name, Normal/Elite/Boss level, archetype tags, and compact
  reward preview only.
- Detailed defenses, selected mechanics, seeds, budget metadata, pressure
  metadata, validation notices, and debug payloads remain combat/debug/report
  surfaces after route commitment.
- Rewards remain deterministic and materialized. P4M8 may note where reward
  variety feels thin, but broad reward-family expansion should wait until the
  larger content set reveals real needs.
- Authored Gilded Serpent behavior remains the regression baseline.
- The repeatable contract loop is in scope for playtesting: Adventure mode
  should run Tavern -> authored Vyra contract -> generated random contract loop,
  with a shop opportunity after each completed contract. Contract Test should
  skip Tavern/Vyra setup and enter the generated contract loop directly, also
  granting a shop opportunity after each completed contract.
- Non-combat route nodes, route-local resources, consumables, shop nodes,
  mystic upgrades, crafting/transmutation, boss bargains, scout/reveal nodes,
  and hidden events remain deferred unless a very small data hook is required
  to support content validation. This does not block the between-contract shop
  used by the repeatable playtest loop.

## Current Focus

P4M8 is complete. P4M8-T1 completed the initial content audit and target
definition, P4M8-T2 added the first runtime archetype expansion batch,
P4M8-T3 completed bounded two-archetype overlap emphasis plus curated pair
identity coverage, and P4M8-T4 expanded elite/boss presentation pools plus
Rogue-voiced generated contract text. P4M8-T5 added the generated modifier
model: deterministic metadata-only route modifiers, sparse modifier labels when
appropriate, materialized save/load state, validation guards, inspector/audit
coverage, and Balance Lab sparse-preview checks. P4M8-T6 added elite branch
variants with deterministic archetype identity, materialized state, sparse
elite labels, inspector/audit coverage, and Balance Lab coverage. P4M8-T7
added boss endpoint variants with deterministic archetype identity,
materialized state, sparse boss labels, inspector/audit coverage, and Balance
Lab coverage. P4M8-T8 completed the preview readability pass by keeping
generated route cards to compact player-facing lines, combining modifier and
variant labels into one identity line, and expanding UI checks for sparse
preview boundaries. P4M8-T9 broadened Balance Lab, matrix, and audit coverage
so generated-route samples must cover every route template, route modifier,
elite variant, boss variant, pressure axis, and P4M8 expanded archetype.
P4M8-T10 completed the repeatable contract loop, so playtesting now moves from
the authored Vyra contract into generated contracts with between-contract
shops. P4M8-T11 completed the Adventure lifecycle regression pass across
normal Adventure, Contract Test, generated routing, rewards, repeated
completions, save/load, failure/restart, route UI, matrix, inspector, and
Balance Lab gates. P4M8-T12 closed the milestone documentation and handed
remaining Phase 4 work forward. P4M9 now owns generated contract shape and map
presentation expansion; P4M10 owns stabilization, export, and Phase 4 closeout.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M8-T1: Content Audit And Targets | Complete | Establish the baseline content set and define measurable expansion goals. | This doc records current archetype, mechanic, biome, name, modifier, elite, boss, and theme coverage; thin spots are identified; target counts and variety rules are accepted. |
| P4M8-T2: Runtime Archetype Expansion | Complete | Add new generated monster archetypes with distinct defensive identities. | New archetypes produce deterministic monsters, readable tags, pressure-axis metadata, matchup-preview metadata, and generator/test coverage without regressing existing archetypes. |
| P4M8-T3: Mechanic Combination Expansion | Complete | Broaden mechanic pairings and compatibility rules. | New mechanic combinations create distinct fights, avoid unreadable or unfair build-denial stacks, preserve deterministic generation, and are covered by focused compatibility tests. |
| P4M8-T4: Presentation Pool Expansion | Complete | Expand biome pools, monster names, and contract theme text. | Generated contracts have broader biome/name/theme variety while presentation identity remains decoupled from mechanical truth and sparse previews stay clean. |
| P4M8-T5: Generated Modifier Model | Complete | Add a small set of generated modifiers that vary contract or encounter texture. | Modifiers are deterministic, previewed only at the appropriate sparse level, saved in materialized route state, and validated so they do not become hidden economy or combat-system rewrites. |
| P4M8-T6: Elite Variant Expansion | Complete | Make elite nodes feel mechanically distinct from scaled normal fights. | Elite variants have clear identity, bounded pressure, reward consistency, route-validation coverage, and Adventure outcome/save-load regression coverage. |
| P4M8-T7: Boss Variant Expansion | Complete | Expand generated boss endpoint identities. | Boss variants create readable final-route pressure, preserve deterministic combat setup, expose appropriate sparse route information, and pass generated outcome and Balance Lab checks. |
| P4M8-T8: Preview Readability Pass | Complete | Verify the expanded content remains understandable before route commitment. | Route map cards remain sparse, compact, non-debug, and useful for matchup decisions across new archetypes, modifiers, elites, bosses, biomes, and reward previews. |
| P4M8-T9: Balance Lab And Matrix Coverage | Complete | Broaden automated coverage for the expanded content set. | Balance Lab and generated route matrix samples cover new archetypes, mechanics, modifiers, elite variants, boss variants, biomes, pressure axes, snowball warnings, dead-run warnings, and reward pacing. |
| P4M8-T10: Repeatable Contract Loop | Complete | Turn contract completion into the playtestable main loop. | Adventure mode flows Tavern -> authored Vyra contract -> generated random contract loop; Contract Test starts directly at the generated contract loop; each completed contract increments completed-contract state, preserves build/economy state, opens a between-contract shop opportunity, then offers the next generated contract deterministically. |
| P4M8-T11: Adventure Lifecycle Regression | Complete | Verify expanded content and the repeatable loop through the real generated-contract lifecycle. | Generated offers, route acceptance, route UI, combat setup, rewards, between-contract shops, repeated completions, retries, failures, restarts, save/load, boss victory, Contract Test flow, and Gilded Serpent regression tests pass. |
| P4M8-T12: Documentation And Handoff To P4M9 | Complete | Close the milestone and prepare the remaining Phase 4 work. | This doc, `docs/P4_DawnBringer_Overview.md`, and onboarding context are updated with final status, verification results, known content/balance gaps, the P4M9 route shape/presentation pass, and the P4M10 closeout handoff. |

## Initial Design Direction

P4M8 should proceed from breadth with guardrails:

- Start with a content audit before adding data so the expansion targets are
  visible and measurable.
- Prefer adding several clear archetype and variant identities over many tiny
  indistinct stat permutations.
- Keep pressure axes useful for route readability and dead-run validation.
- Keep modifiers small and legible. A modifier should change texture or
  emphasis, not introduce a hidden subsystem.
- Treat elites and bosses as the highest-impact variety layer because they are
  route decision spikes and endpoints.
- Expand biome, name, and theme pools after or alongside mechanical content,
  but do not tie fiction labels to required mechanics.
- Add tests at the same layer as each expansion: runtime generator tests for
  archetypes/mechanics, route generator tests for route materialization,
  Balance Lab for broad health, and Adventure tests for lifecycle behavior.

## Content Questions

T1 should answer:

- How many runtime archetypes exist today, and which pressure axes are thin?
- Which defensive mechanics are overused, underused, or risky in combination?
- Which generated biomes, monster names, and contract themes repeat too often?
- What is the smallest useful modifier model for P4M8?
- What should distinguish an elite variant from a normal generated fight?
- What should distinguish a boss variant from a high-pressure elite?
- Which expanded-content details belong on route previews, combat previews,
  debug previews, reports, Balance Lab, or nowhere?
- What sample size should Balance Lab and generated route matrix tests use to
  prove the content set is varied without making tests brittle?

## P4M8-T1 Content Audit Results

Audit date: 2026-08-23.

Audit surfaces:

- Runtime archetype catalog:
  `tools/monster-lab/Monster_Libraries/dawnbringer_archetypes_v1.json`.
- Runtime mechanics:
  `project/scripts/systems/runtime_monster_generator/runtime_mechanic_library.gd`.
- Route presentation, route templates, pressure axes, rewards, and generated
  encounter assignment:
  `project/scripts/systems/contract_route_generator/contract_route_generator.gd`.
- Offer identity:
  `project/scripts/systems/contract_offer_source.gd`.
- Sample tool:
  `project/scripts/tools/p4m8_content_audit.gd`.

Static baseline:

| Area | Current Coverage |
| --- | --- |
| Runtime archetypes | 10 total: `arcane`, `armored`, `devious`, `fortified`, `hexed`, `nimble`, `relentless`, `resistant`, `unstable`, `warded`. |
| Normal-capable archetypes | 8. `relentless` and `unstable` are elite/boss only. |
| Elite-capable archetypes | 8. `armored` and `resistant` are normal only. |
| Boss-capable archetypes | 8. `armored` and `resistant` are normal only. |
| Runtime mechanics | 11: `absorb`, `armor`, `block`, `cleanse_threshold`, `crit_negation`, `dodge_chance`, `interrupt_skip_count`, `poison_resistance`, `slow`, `stun_duration_ms`, `suppress`. |
| Route pressure axes | 6: physical mitigation, magical/poison mitigation, debuff/poison disruption, timing control, reliability/evasion, mixed. |
| Route templates | 3: `split_merge`, `optional_elite`, `short_risk_long_safe`. |
| Biomes | 6: Swamp, Cave, Graveyard, Haunted Forest, Ruined Keep, Ancient Ruins. |
| Presentation names | 64 total: each biome has 4-5 normal names, 3 elite names, and 3 boss names. |
| Preview tag sets | 6 hardcoded sets: five single-axis tags plus `fortified` + `warded`. |
| Contract themes | 1 generic generated offer pattern per biome/difficulty: `<Difficulty> generated route through <Biome> territory...`. |
| Generated modifiers | None. |
| Elite variants | Role scaling only: `elite` gets HP/budget/duration/target-DPS multipliers and one extra mechanic. |
| Boss variants | Role scaling only: `boss` gets HP/budget/duration/target-DPS multipliers and two extra mechanics. |

Sample baseline:

- Sampled 240 generated routes across default medium, hard, nightmare, and
  later-contract-pressure settings.
- Sampled 1,838 generated combat nodes.
- All sampled routes passed `ContractRouteGenerator.validate()` with no
  validation notices.
- Template distribution was balanced: `split_merge` 81, `optional_elite` 77,
  `short_risk_long_safe` 82.
- Route-biome distribution was balanced: Ancient Ruins 41, Cave 41,
  Graveyard 37, Haunted Forest 42, Ruined Keep 37, Swamp 42.
- Node-biome distribution was also broad: Ancient Ruins 353, Cave 354,
  Graveyard 334, Haunted Forest 370, Ruined Keep 316, Swamp 351.
- Combat roles sampled as 1,439 normal fights, 159 elites, and 240 bosses.
- Unique archetype pairs sampled: 49.
- Unique mechanic sets sampled: 265.

Sampled archetype frequency:

| Archetype | Count |
| --- | ---: |
| `devious` | 382 |
| `nimble` | 369 |
| `hexed` | 365 |
| `warded` | 359 |
| `fortified` | 347 |
| `arcane` | 304 |
| `resistant` | 272 |
| `armored` | 266 |
| `relentless` | 103 |
| `unstable` | 95 |

Sampled pressure-axis frequency:

| Pressure Axis | Count |
| --- | ---: |
| Timing control | 440 |
| Magical/poison mitigation | 422 |
| Physical mitigation | 395 |
| Debuff/poison disruption | 249 |
| Reliability/evasion | 235 |
| Mixed | 97 |

Sampled mechanic frequency:

| Mechanic | Count |
| --- | ---: |
| `armor` | 705 |
| `cleanse_threshold` | 697 |
| `poison_resistance` | 692 |
| `suppress` | 634 |
| `crit_negation` | 606 |
| `stun_duration_ms` | 564 |
| `interrupt_skip_count` | 545 |
| `slow` | 434 |
| `dodge_chance` | 404 |
| `block` | 317 |
| `absorb` | 294 |

Most repeated sampled mechanic sets:

| Mechanic Set | Count |
| --- | ---: |
| `cleanse_threshold` + `suppress` | 113 |
| `absorb` + `poison_resistance` + `suppress` | 107 |
| `armor` + `block` + `crit_negation` | 107 |
| `crit_negation` + `dodge_chance` | 106 |
| `poison_resistance` | 100 |
| `armor` | 98 |
| `cleanse_threshold` + `interrupt_skip_count` + `slow` + `stun_duration_ms` | 93 |
| `interrupt_skip_count` + `stun_duration_ms` | 79 |

Thin spots and risks:

- The mechanical baseline has breadth, but the highest-readability archetypes
  are still mostly broad labels rather than distinct authored-feeling enemy
  identities. `relentless` and `unstable` appear much less often because they
  are elite/boss only.
- `mixed` pressure is thin in sampled routes, and reliability/evasion plus
  debuff/poison disruption trail physical, magical, and timing axes.
- Timing-control output is common because `arcane` and `devious` feed
  `slow`, `stun_duration_ms`, and `interrupt_skip_count`; stacked timing sets
  need readability checks before further expansion.
- `absorb` and `block` are the least-used mechanics in the sample; they should
  get at least one clearer identity each instead of only appearing as support
  mechanics.
- Route-card tag previews use six hardcoded tag sets and can diverge from the
  actual generated archetype IDs selected for combat. This is acceptable as a
  sparse preview boundary today, but P4M8 should tighten preview vocabulary as
  content expands.
- Presentation pools are balanced by biome, but shallow by role. Elite and
  boss pools repeat quickly at three names per biome, and Ancient Ruins has
  only four normal names.
- Generated contract theme text is effectively one template, so routes can
  feel repeated even when biome and encounter data vary.
- Generated elite and boss identities are role multipliers, not variants.
  They are deterministic and functional, but they do not yet express named
  elite/boss behaviors.
- There is no generated modifier model yet.
- The old Monster Lab browser prototype has six flavorful archetype concepts
  (`stonewall`, `venomproof`, `duelist`, `suppressor`, `warden`, `bogborn`)
  that are not the runtime catalog. They are useful inspiration, not a direct
  import target.

Accepted P4M8 expansion targets:

| Area | Target |
| --- | --- |
| Runtime archetypes | Add 4-6 new runtime archetypes before closeout, prioritizing distinct identities over stat permutations. At least 2 should be normal-capable, at least 2 elite/boss-capable, and at least 1 should foreground `absorb` or `block`. |
| Pressure axes | After expansion, every non-mixed pressure axis should have at least 2 clear runtime archetypes or variants that can present it as primary identity. Mixed should have at least 2 controlled identities rather than relying mostly on `unstable`. |
| Mechanic combinations | Add 6-10 curated, readable combination patterns. Include at least one absorb-led, one block-led, one reliability/evasion, one debuff/poison, and one mixed-pressure pattern. |
| Presentation pools | Keep the current six biomes for P4M8, raise each biome to at least 5 elite names and 5 boss names, and leave normal-name expansion deferred unless later audits show it is the highest-value repetition problem. New biomes are deferred for later reconsideration. |
| Contract themes | Add 8-12 generated offer/theme templates that can vary by biome, difficulty, and boss presentation without exposing mechanics. |
| Modifiers | Add 3-5 deterministic modifiers only if they are small, previewable texture. Good first candidates: route pressure emphasis, elite density flavor, and biome hazard flavor that changes labels/validation metadata before it changes combat. |
| Elite variants | Add 3-5 deterministic elite variant identities. Variants should alter archetype selection, mechanic weighting, or preview label, not create new reward/economy systems. |
| Boss variants | Add 3-4 deterministic boss variant identities. Boss variants should make route endpoints readable and distinct from high-pressure elites through archetype/axis emphasis and preview language. |
| Sample coverage | Keep focused route-matrix tests small, but use an audit/Balance Lab sample of at least 240 routes and roughly 1,800 combat nodes for content-health reporting. |

Accepted variety rules:

- Preserve deterministic combat, materialized route state, deterministic
  rewards, save/load policy, and authored Gilded Serpent regression behavior.
- Keep presentation separate from mechanics. Biome, monster names, and theme
  text are fiction; archetype IDs, mechanics, pressure axes, defenses, budget
  metadata, and notices are mechanical truth.
- Expand identity in layers: archetypes first, then mechanic combinations,
  presentation pools, modifiers, elite variants, and boss variants.
- Do not add non-combat nodes, route-local resources, consumables, shops,
  crafting, mystic upgrades, scout/reveal nodes, hidden events, or boss
  bargains in P4M8.
- Avoid unreadable normal fights. Normal generated monsters should remain
  sparse enough that four-plus simultaneous mechanics is exceptional and
  warning-worthy.
- Treat stacked timing-control mechanics carefully. Slow, stun, and interrupt
  can make fights distinctive, but they should not become default build denial.
- Modifiers must be explicit generated state, deterministic, saved when
  materialized, and visible only at the appropriate preview/report layer.
- Elite and boss variants should be identity overlays with bounded pressure,
  not hidden economy or combat rewrites.

Preview and report boundaries:

| Surface | Belongs There |
| --- | --- |
| Route card preview | Biome, generated monster name, Normal/Elite/Boss level, compact archetype tags, compact reward summary, and later a short modifier/variant label only if it is player-actionable before commitment. |
| Combat preview | Exact defense summary, selected mechanics in readable terms, matchup summaries, generated monster presentation, and committed encounter identity. |
| Debug preview/inspector | Seeds, raw archetype IDs, selected mechanic IDs and values, defense overrides, budget metadata, pressure metadata, route pressure scale, pressure axes, generator versions, validation notices, modifier IDs, variant IDs. |
| Balance Lab/reporting | Aggregate counts, pressure-axis diversity, mechanic/archetype coverage, snowball/dead-run notices, reward pacing, modifier/elite/boss coverage, and deterministic signatures. |
| Nowhere in P4M8 | Hidden economy effects, undisclosed combat modifiers, non-combat event payloads, route-local currency/resource math, shop/crafting/mystic upgrade state. |

P4M8-T1 verification:

- Ran `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless
  --path project -s res://scripts/tools/p4m8_content_audit.gd` outside the
  sandbox on 2026-08-23.
- The sandboxed run hit the known `user://logs` startup crash before script
  execution.
- The outside-sandbox audit completed and reported no validation notices across
  the 240 sampled routes.
- Known non-blocking Godot exit output appeared: ObjectDB/resource cleanup
  warnings.

## P4M8-T2 Runtime Archetype Expansion Results

Implementation date: 2026-08-23.

Added four runtime archetypes to
`tools/monster-lab/Monster_Libraries/dawnbringer_archetypes_v1.json`:

| Archetype | Kind Availability | Pressure Axis | Identity |
| --- | --- | --- | --- |
| `aegis` | Normal, elite, boss | Physical mitigation | Block-led flat physical reduction, with optional crit negation and no armor package. |
| `nullify` | Normal, elite, boss | Magical/poison mitigation | Absorb-led flat magical reduction, with optional suppress and no poison resistance package. |
| `spiteful` | Normal, elite, boss | Debuff/poison disruption | Cleanse-led poison/debuff setup denial, with suppress and light resistance/slow support. |
| `riftbound` | Elite, boss | Mixed | Controlled mixed pressure across mitigation, absorption, light evasion, resistance, and tempo friction. |

Runtime integration:

- Added preview vocabulary for all four new IDs in
  `project/scripts/systems/runtime_monster_generator/encounter_archetype_vocabulary.gd`.
- Added route pressure-axis mappings in
  `project/scripts/systems/contract_route_generator/contract_route_generator.gd`.
- Expanded the route preview tag-set pool from 6 to 10 entries so the new
  archetype language can appear in sparse route previews.
- Added focused loader, runtime generator, and route reachability coverage in:
  `project/tests/runtime_archetype_library_loader_test.gd`,
  `project/tests/runtime_monster_generator_test.gd`, and
  `project/tests/contract_route_generator_test.gd`.

Post-expansion sample:

- Sampled 240 generated routes and 1,838 combat nodes with
  `project/scripts/tools/p4m8_content_audit.gd`.
- Static runtime archetypes increased from 10 to 14.
- Normal-capable archetypes increased from 8 to 11.
- Elite-capable archetypes increased from 8 to 12.
- Boss-capable archetypes increased from 8 to 12.
- Unique sampled archetype pairs increased from 49 to 96.
- Unique sampled mechanic sets increased from 265 to 307.
- Sampled route validation notices remained empty.

New archetype sample counts:

| Archetype | Count |
| --- | ---: |
| `spiteful` | 275 |
| `aegis` | 240 |
| `nullify` | 232 |
| `riftbound` | 74 |

2026-08-23 refinement:

- Removed `armor` from `aegis` so the archetype stays a cleaner block identity
  rather than adding another armor source.
- Renamed `nullbound` to `nullify` and removed `poison_resistance` so it reads
  as absorb-led magic denial instead of broad magical/poison resistance.
- Renamed `spitebloom` to `spiteful`; its cleanse/suppress poison-debuff
  denial shape is otherwise unchanged.

Notable pressure-axis movement:

- Physical mitigation increased from 395 to 439 sampled primary-axis nodes.
- Magical/poison mitigation increased from 422 to 447.
- Debuff/poison disruption increased from 249 to 354.
- Mixed increased from 97 to 108.
- Timing control decreased from 440 to 324, reducing the previous
  timing-control dominance risk.
- Reliability/evasion decreased from 235 to 166 and remains a thin spot for
  later mechanic-combination or archetype work.

Notable mechanic movement:

- `absorb` increased from 294 to 481 sampled appearances.
- `block` increased from 317 to 455 sampled appearances.
- `suppress` and `cleanse_threshold` increased because `nullify` and
  `spiteful` intentionally reinforce magical denial and debuff/poison
  identities.
- `stun_duration_ms` and `interrupt_skip_count` decreased, which helps keep
  timing-control stacks from becoming the default variety source.

P4M8-T2 verification:

- `project/tests/runtime_archetype_library_loader_test.gd`: passed outside the
  sandbox.
- `project/tests/runtime_monster_generator_test.gd`: passed outside the
  sandbox.
- `project/tests/encounter_preview_formatter_test.gd`: passed outside the
  sandbox.
- `project/tests/contract_route_generator_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/scripts/tools/p4m8_content_audit.gd`: completed outside the sandbox
  with no route validation notices across the 240-route sample.
- Sandboxed Godot still hit the known `user://logs` startup crash before
  script execution.
- Known non-blocking Godot exit output appeared on successful runs:
  ObjectDB/resource cleanup warnings.

## P4M8-T3 Mechanic Combination Notes

Implementation note, 2026-08-23:

- Preserved the existing two-archetype method. No new combo engine was added.
- Added a bounded overlap-emphasis rule in
  `project/scripts/systems/runtime_monster_generator/runtime_monster_generator.gd`.
- When both rolled archetypes enable the same selected mechanic, the merged
  mechanic config receives a 20% emphasis bonus before the usual difficulty
  scaling.
- Normal-cost mechanics move upward by 20% and stay clamped to the mechanic's
  global min/max.
- Inverted-cost mechanics, such as `cleanse_threshold`, move in the stronger
  direction by dividing the merged range by 1.2, then clamping to the global
  min/max.
- The mechanic still appears once in `selected_mechanics`, and
  `defense_overrides` still has one field for that mechanic.
- Selected mechanic extras record `overlap_emphasis_bonus: 0.2` so debug and
  tests can see why the range was emphasized.

Curated pair identities:

| Pair | Intended Read |
| --- | --- |
| `aegis` + `fortified` | Physical wall: block is emphasized when both archetypes point at it, while armor comes from `fortified` rather than `aegis`. |
| `nullify` + `warded` | Magical denial split: absorb is emphasized by overlap, while poison resistance remains owned by `warded`. |
| `spiteful` + `hexed` | Debuff/poison setup denial: cleanse and suppress can overlap into a stronger but still single-instance denial package. |
| `nimble` + `devious` | Reliability disruption: dodge/crit friction combines with timing-control pressure without a bespoke combo rule. |
| `aegis` + `nullify` | Flat reduction split: block and absorb create a broad but readable split defense without armor or poison resistance bleed. |

Avoided stacks:

- `aegis` no longer carries `armor`, so the block archetype does not make every
  physical identity feel armored.
- `nullify` no longer carries `poison_resistance`, so absorb-led magic denial
  does not collapse into the existing resistance identity.
- Pair behavior remains authored through archetype weights/ranges and the
  shared overlap rule. There are no pair-specific mechanic exceptions.

Verification for this T3 slice:

- `project/tests/runtime_monster_generator_test.gd`: passed outside the
  sandbox.
- `project/tests/contract_route_generator_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/scripts/tools/p4m8_content_audit.gd`: completed outside the sandbox
  with no route validation notices across the 240-route sample.
- Sandboxed Godot still hit the known `user://logs` startup crash before
  script execution.

Completion verification, 2026-08-23:

- Added runtime generator coverage for refined archetypes not emitting removed
  mechanics and for deterministic curated pair identities.
- Re-ran the P4M8 content audit after the refined library and pair coverage:
  240 routes, 1,838 combat nodes, 96 unique archetype pairs, 307 unique
  mechanic sets, and no route validation notices.

## P4M8-T4 Presentation Pool Expansion Results

Implementation date: 2026-08-23.

Scope decisions:

- Added no new biomes. The existing six biomes remain the generated-contract
  presentation set: Swamp, Cave, Graveyard, Haunted Forest, Ruined Keep, and
  Ancient Ruins.
- Expanded elite and boss presentation pools only. Normal-name expansion is
  deferred unless later audits show normal fight repetition is the highest-value
  presentation problem.
- Kept presentation separate from mechanics. New names do not imply armor,
  block, resistance, archetypes, pressure axes, route shape, or rewards.

Elite/boss name additions:

| Biome | New Elite Names | New Boss Names |
| --- | --- | --- |
| Swamp | Mire Alchemist, Reedbound Oracle | The Drowned Matriarch, Bogheart Colossus |
| Cave | Crystalback Brute, Echoing Seer | The Deep Maw, Gemvein Tyrant |
| Graveyard | Grave Cantor, Sepulcher Knight | The Bell-Tower Revenant, Ossuary Saint |
| Haunted Forest | Briarbound Stalker, Hollow-Eyed Witch | The Root-Crowned Widow, Moonless Huntmaster |
| Ruined Keep | Oathbroken Captain, Ashen Jailer | The Last Castellan, Crownless Executioner |
| Ancient Ruins | Runemark Sentinel, Dust-Veiled Hierophant | The First Idol, Archive of Teeth |

Post-T4 pool counts:

- Biomes: 6.
- Elite names: 5 per biome.
- Boss names: 5 per biome.
- Normal names: unchanged; Ancient Ruins remains at 4 and the other five
  biomes remain at 5.
- Presentation table version: `p4m8.presentation.v1`.

Generated contract text:

- Added 12 deterministic Rogue-voiced generated contract text templates in
  `project/scripts/systems/contract_offer_source.gd`.
- Added `OFFER_TEXT_VERSION = "p4m8.t4.rogue.v1"` so text selection has an
  explicit content version without changing generated route seeds.
- Text now uses a snarky, cocky Rogue voice and includes route biome and boss
  presentation name.
- Text remains mechanically neutral: no archetype IDs, selected mechanics,
  pressure axes, seeds, budget/debug data, route shape, or exact rewards.

Post-T4 audit:

- Sampled 240 generated routes and 1,838 combat nodes with
  `project/scripts/tools/p4m8_content_audit.gd`.
- Static biome count remained 6.
- Unique sampled presentation names increased from 64 to 88.
- Static elite/boss pool counts are now 5/5 for every existing biome.
- Sampled route validation notices remained empty.

P4M8-T4 verification:

- `project/tests/contract_route_generator_test.gd`: passed outside the sandbox.
- `project/tests/contract_offer_source_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_ui_preview_test.gd`: passed outside the
  sandbox.
- `project/scripts/tools/p4m8_content_audit.gd`: completed outside the sandbox
  with no route validation notices across the 240-route sample.
- Known non-blocking Godot exit output appeared on successful runs:
  ObjectDB/RID/resource cleanup warnings.

## P4M8-T5 Generated Modifier Model Results

Implementation date: 2026-08-23.

Added generated route modifier state to:

- `project/scripts/resources/contract_def.gd`: route-level modifier model
  version, modifier IDs, and materialized modifier dictionaries.
- `project/scripts/resources/contract_route_node.gd`: node-level modifier IDs
  and labels.
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`:
  deterministic modifier selection, node assignment, sparse preview labels,
  combat/debug payload threading, graph signatures, and validation.
- `project/scenes/combat/map_overlay.gd`: compact generated route cards now
  render allowed `modifier_label` text.
- `project/scripts/tools/generated_route_inspector.gd` and
  `project/scripts/tools/p4m8_content_audit.gd`: route/node modifier reporting
  and aggregate coverage.
- `project/scripts/tools/balance_lab.gd`: preview leak checks now treat raw
  modifier IDs as debug-only data.

Modifier model:

| Modifier | Preview Policy | Scope |
| --- | --- | --- |
| `pressure_emphasis` | Matching primary pressure axis only. | Adds a route emphasis label such as Bulwark Hunt, Null Hunt, Hex Hunt, Tempo Hunt, Evasion Hunt, or Mixed Hunt. |
| `elite_spotlight` | Existing elite and boss nodes. | Marks route spikes without adding fights or changing rewards. |
| `biome_hazard` | Nodes matching the selected route biome. | Adds biome hazard labels such as Mire Hazard, Echo Hazard, Grave Hazard, Briar Hazard, Ruin Hazard, or Rune Hazard. |
| `volatile_pacing` | Boss node only. | Marks the endpoint as the visible payoff for the route texture. |

Guardrails:

- Modifiers are explicit generated state, deterministic from route seed and
  settings, and materialized into generated save/load state.
- Modifiers are metadata-only in P4M8-T5. Validation rejects modifier payloads
  that try to carry reward, economy, combat, or node-system effects.
- Sparse route previews may show only the player-readable `modifier_label`.
  Raw `route_modifier_ids`, `node_modifier_ids`, modifier dictionaries, seeds,
  pressure metadata, selected mechanics, and defense data remain debug/report
  surfaces.
- Combat setup, reward math, pressure scaling, and route topology are unchanged
  by T5 modifiers.

Post-T5 audit:

- Sampled 240 generated routes and 1,856 combat nodes with
  `project/scripts/tools/p4m8_content_audit.gd`.
- Static modifier catalog count is 4: `pressure_emphasis`,
  `elite_spotlight`, `biome_hazard`, and `volatile_pacing`.
- Route modifier distribution: `volatile_pacing` 66,
  `elite_spotlight` 61, `pressure_emphasis` 61, `biome_hazard` 52.
- Node modifier labels appeared as intended by preview policy:
  `biome_hazard` 315, `elite_spotlight` 93, `pressure_emphasis` 79,
  `volatile_pacing` 66.
- Sampled route validation notices remained empty.

P4M8-T5 verification:

- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_inspector_test.gd`: passed outside the
  sandbox.
- `project/tests/map_overlay_route_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_ui_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_contract_save_load_test.gd`: passed outside the
  sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/scripts/tools/p4m8_content_audit.gd`: completed outside the sandbox
  with no route validation notices across the 240-route sample.
- Sandboxed Godot still hit the known `user://logs` startup crash before script
  execution. Known non-blocking Godot exit output appeared on successful
  outside-sandbox runs: ObjectDB/RID/resource cleanup warnings.

## P4M8-T6 Elite Variant Expansion Results

Implementation date: 2026-08-23.

Added generated elite variant state to:

- `project/scripts/resources/contract_route_node.gd`: elite variant model
  version, ID, and label.
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`:
  deterministic elite variant selection, elite archetype pairing,
  payload/debug state, sparse preview label, graph signatures, and validation.
- `project/scenes/combat/map_overlay.gd`: compact generated route cards can
  render allowed `elite_variant_label` text.
- `project/scripts/tools/generated_route_inspector.gd` and
  `project/scripts/tools/p4m8_content_audit.gd`: elite variant reporting and
  aggregate coverage.
- `project/scripts/tools/balance_lab.gd`: preview leak checks keep raw elite
  variant IDs debug-only, and generated-route checks require multi-variant
  elite coverage.

Elite variant model:

| Variant | Archetype Pair | Pressure Axis | Identity |
| --- | --- | --- | --- |
| `shieldbreaker_captain` | `aegis` + `fortified` | Physical mitigation | Block-led branch spike. |
| `null_priest` | `nullify` + `warded` | Magical/poison mitigation | Absorb/suppress branch spike. |
| `venom_speaker` | `spiteful` + `hexed` | Debuff/poison disruption | Cleanse/suppress poison and debuff branch spike. |
| `phase_duelist` | `nimble` + `devious` | Reliability/evasion | Evasion branch spike with light tempo pressure. |
| `riftbound_marauder` | `riftbound` + `unstable` | Mixed | Layered mixed-pressure branch spike. |

Guardrails:

- Elite variants are deterministic, elite-only, materialized on generated
  elite nodes, and save/load-covered.
- Variants influence elite archetype pairing and branch pressure identity.
  They do not alter rewards, economy, route topology, or non-combat systems.
- Variant RNG does not key off biome, preserving the existing boundary between
  presentation identity and mechanical truth.
- Sparse route previews may show only `elite_variant_label`. Raw
  `elite_variant_id`, model version, full variant dictionaries, pressure axes,
  seeds, mechanics, and defenses remain debug/report surfaces.
- Validation requires exactly one known variant on generated elite nodes,
  rejects variant state on non-elite nodes, checks metadata-only catalogs for
  forbidden economy/combat keys, and checks payload/debug/preview agreement.

Post-T6 audit:

- Sampled 240 generated routes and 1,837 combat nodes with
  `project/scripts/tools/p4m8_content_audit.gd`.
- Static elite variant catalog count is 5: `shieldbreaker_captain`,
  `null_priest`, `venom_speaker`, `phase_duelist`, and
  `riftbound_marauder`.
- Elite variant distribution: `venom_speaker` 36, `null_priest` 35,
  `shieldbreaker_captain` 32, `phase_duelist` 30, `riftbound_marauder` 27.
- Elite variant pressure-axis distribution: debuff/poison disruption 36,
  magical/poison mitigation 35, physical mitigation 32,
  reliability/evasion 30, mixed 27.
- Sampled route validation notices remained empty.

P4M8-T6 verification:

- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_inspector_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_contract_save_load_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_ui_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_contract_outcome_test.gd`: passed outside the
  sandbox.
- `project/tests/map_overlay_route_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/tests/contract_route_generator_test.gd`: passed outside the
  sandbox.
- `project/tests/contract_offer_source_test.gd`: passed outside the sandbox.
- `project/scripts/tools/p4m8_content_audit.gd`: completed outside the sandbox
  with all five elite variants sampled and no route validation notices.
- Known non-blocking Godot exit output appeared on successful outside-sandbox
  runs: ObjectDB/RID/resource cleanup warnings.

## P4M8-T7 Boss Variant Expansion Results

Implementation date: 2026-08-23.

Added generated boss variant state to:

- `project/scripts/resources/contract_route_node.gd`: boss variant model
  version, ID, and label.
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`:
  deterministic boss variant selection, boss archetype pairing, payload/debug
  state, sparse preview label, graph signatures, and validation.
- `project/scenes/combat/map_overlay.gd`: compact generated route cards can
  render allowed `boss_variant_label` text.
- `project/scripts/tools/generated_route_inspector.gd` and
  `project/scripts/tools/p4m8_content_audit.gd`: boss variant reporting and
  aggregate coverage.
- `project/scripts/tools/balance_lab.gd`: preview leak checks keep raw boss
  variant IDs debug-only, and generated-route checks require multi-variant
  boss coverage.

Boss variant model:

| Variant | Archetype Pair | Pressure Axis | Identity |
| --- | --- | --- | --- |
| `apex_bulwark` | `aegis` + `fortified` | Physical mitigation | Block-led physical endpoint. |
| `void_regent` | `nullify` + `warded` | Magical/poison mitigation | Absorb/suppress endpoint. |
| `plague_court` | `spiteful` + `hexed` | Debuff/poison disruption | Cleanse/suppress poison and debuff endpoint. |
| `chrono_tyrant` | `devious` + `arcane` | Timing control | Slow/stun/interrupt endpoint. |

Guardrails:

- Boss variants are deterministic, boss-only, materialized on the generated
  boss node, and save/load-covered.
- Variants influence boss archetype pairing and endpoint pressure identity.
  They do not alter rewards, economy, route topology, or non-combat systems.
- Sparse route previews may show only `boss_variant_label`. Raw
  `boss_variant_id`, model version, full variant dictionaries, pressure axes,
  seeds, mechanics, and defenses remain debug/report surfaces.
- Validation requires exactly one known variant on generated boss nodes,
  rejects variant state on non-boss nodes, and checks payload/debug/preview
  agreement.

Post-T7 audit:

- Sampled 240 generated routes and 1,837 combat nodes with
  `project/scripts/tools/p4m8_content_audit.gd`.
- Static boss variant catalog count is 4: `apex_bulwark`, `void_regent`,
  `plague_court`, and `chrono_tyrant`.
- Boss variant distribution: `apex_bulwark` 68, `plague_court` 65,
  `void_regent` 60, `chrono_tyrant` 47.
- Boss variant pressure-axis distribution: physical mitigation 68,
  debuff/poison disruption 65, magical/poison mitigation 60, timing control
  47.
- Sampled route validation notices remained empty.

P4M8-T7 verification:

- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_inspector_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_contract_save_load_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_ui_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_contract_outcome_test.gd`: passed outside the
  sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/tests/contract_route_generator_test.gd`: passed outside the
  sandbox.
- `project/tests/contract_offer_source_test.gd`: passed outside the sandbox.
- `project/scripts/tools/p4m8_content_audit.gd`: completed outside the sandbox
  with all four boss variants sampled and no route validation notices.
- Known non-blocking Godot exit output appeared on successful outside-sandbox
  runs: ObjectDB/RID/resource cleanup warnings.

## P4M8-T8 Preview Readability Pass Results

Implementation date: 2026-08-23.

Preview readability changes:

- Generated route cards now keep the full expanded-content preview to a compact
  shape: biome, colored monster name, archetype tags, one identity line, and
  reward summary.
- Modifier labels and elite/boss variant labels are combined into a single
  identity line, such as `Mire Hazard / Null Priest`, instead of stacking as
  separate card lines.
- Sparse route cards still hide generated internals: source seeds, raw
  archetype IDs, selected mechanics, defense overrides, pressure metadata,
  budget metadata, model versions, modifier IDs, and variant IDs.
- Route cards continue to show only player-facing compact labels:
  `modifier_label`, `elite_variant_label`, and `boss_variant_label`.

Coverage added or tightened:

- `project/tests/map_overlay_route_preview_test.gd` now covers combined
  modifier/variant labels, raw variant-ID leakage, and the five-line card
  ceiling.
- `project/tests/generated_route_ui_preview_test.gd` now checks real generated
  route cards for combined identity labels, hidden raw variant IDs, and the
  same five-line ceiling.
- Existing sparse-preview guards in the generated route matrix, inspector, and
  Balance Lab suites remained passing.

Post-T8 audit:

- Sampled 240 generated routes and 1,837 combat nodes with
  `project/scripts/tools/p4m8_content_audit.gd`.
- All four route modifiers, all five elite variants, and all four boss variants
  remained sampled.
- Sampled route validation notices remained empty.

P4M8-T8 verification:

- `project/tests/map_overlay_route_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_ui_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_inspector_test.gd`: passed outside the
  sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/scripts/tools/p4m8_content_audit.gd`: completed outside the sandbox
  with no route validation notices.
- Known non-blocking Godot exit output appeared on successful outside-sandbox
  runs: ObjectDB/RID/resource cleanup warnings.

## P4M8-T9 Balance Lab And Matrix Coverage Results

Implementation date: 2026-08-23.

Coverage gates added or tightened:

- `project/tests/generated_route_matrix_test.gd` now aggregates deterministic
  matrix samples and asserts coverage for all route templates, all route
  biomes, all node biomes, all pressure axes, all generated modifiers, all
  elite variants, all boss variants, and the P4M8 expanded archetypes
  `aegis`, `nullify`, `spiteful`, and `riftbound`.
- `project/scripts/tools/balance_lab.gd` now runs a larger bounded
  generated-route sample and reports dedicated pass/fail checks for template
  coverage, archetype coverage, modifier coverage, elite variant coverage,
  boss variant coverage, pressure-axis coverage, preview sparsity, reward
  presence, overflow pressure, completed-contract pressure changes, and
  blocking route notices.
- `project/tests/balance_lab_test.gd` now asserts those generated-route
  coverage check IDs are present and passing.
- `project/scripts/tools/p4m8_content_audit.gd` now prints a compact
  `coverage` summary with target counts and missing-ID lists for templates,
  route modifiers, elite variants, boss variants, pressure axes, and expanded
  archetypes.

Post-T9 audit:

- Sampled 240 generated routes and 1,837 combat nodes with
  `project/scripts/tools/p4m8_content_audit.gd`.
- Coverage summary hit every target: 3/3 route templates, 6/6 pressure axes,
  4/4 route modifiers, 5/5 elite variants, 4/4 boss variants, and 4/4 P4M8
  expanded archetypes.
- Missing coverage lists were empty for route modifiers, elite variants, boss
  variants, and expanded archetypes.
- Sampled route validation notices remained empty.

P4M8-T9 verification:

- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/tests/contract_route_generator_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_inspector_test.gd`: passed outside the
  sandbox.
- `project/scripts/tools/p4m8_content_audit.gd`: completed outside the sandbox
  with no route validation notices.
- Known non-blocking Godot exit output appeared on successful outside-sandbox
  runs: ObjectDB/RID/resource cleanup warnings.

## P4M8-T10 Repeatable Contract Loop Plan

Decision note, 2026-08-23:

The current game ends the run on contract boss victory. P4M8 now includes an
explicit playtesting task to replace that terminal generated-contract behavior
with a repeatable contract loop while preserving the authored opening cadence.

Required player flow:

- Adventure mode starts the same way it does now: Tavern sequence first.
- After Tavern, the authored Gilded Serpent/Vyra contract remains the first
  contract and the authored regression baseline.
- After completing Vyra's contract, the Adventure should continue into a
  generated random contract loop rather than ending the run.
- After each completed contract, the player gets a shop opportunity before the
  next generated contract offer.
- The player's build, gold, talent points, inventory, selected trees, selected
  talents, equipment, and other Adventure state persist across completed
  contracts unless a later economy task explicitly resets something.
- Each completed contract increments persistent completed-contract state, and
  generated offer creation must pass that count through
  `ContractOfferSource.offer_context()` so existing completed-contract pressure
  scaling actually applies during normal play.
- Contract failure still ends the current Adventure unless a later task changes
  failure rules. Restart should still begin a fresh Adventure.

Contract Test flow:

- Contract Test should skip the Tavern sequence and the authored Vyra contract.
- Contract Test should start directly at the generated random contract loop,
  using the selected Adventure seed/debug context.
- Contract Test should also grant a shop opportunity after each completed
  generated contract, then offer the next generated contract.

Expected implementation surfaces:

- `project/scripts/autoload/build_state.gd`: add persistent
  `completed_contract_count` and `contract_offer_index` state, convert final
  contract victory from terminal `RUN_ENDED` into a between-contract transition
  when repeat-loop play is active, and preserve current build/economy state.
- `project/scripts/systems/contract_offer_source.gd`: receive and use the
  persistent counters so repeated generated offers get distinct deterministic
  seeds and completed-contract pressure.
- `project/scenes/combat/combat_screen.gd`: present the post-contract action as
  a between-contract shop / next-contract flow instead of only "Start a new
  Adventure" when the repeat loop is active.
- `project/scenes/game_root.gd`: keep normal Adventure starting at Tavern, but
  make Contract Test enter the generated contract loop directly.
- `project/scripts/systems/save_system.gd`: persist and restore repeat-loop
  counters and any between-contract shop state.
- Focused tests: cover Adventure Tavern -> Vyra -> generated loop, Contract
  Test -> generated loop, shop-after-contract, completed-contract-count
  increment, deterministic next generated offer, save/load after completion,
  failure/restart behavior, and authored Gilded Serpent regression behavior.

## P4M8-T10 Repeatable Contract Loop Results

Implementation date: 2026-08-23.

Implemented repeatable contract loop behavior:

- `project/scripts/autoload/build_state.gd` now tracks persistent
  `completed_contract_count` and `contract_offer_index` state, feeds those
  counters through `ContractOfferSource.offer_context()`, and converts terminal
  contract boss victories into generated-only contract offers instead of
  ending the run.
- Completing Vyra increments the completed-contract and offer counters after
  the between-contract shop closes, then offers the next generated contract
  deterministically.
- Completing a generated boss repeats the same loop: claim reward, open a
  between-contract shop, close the shop, increment counters, clear prior route
  reward IDs, and offer the next generated contract.
- Contract Test now starts through the same generated-loop helper, skipping
  Tavern and Vyra while keeping its Rogue Assassin/Thief/Bandit Blade baseline
  and three generated offer choices.
- `project/scripts/systems/save_system.gd` persists and restores the repeat
  loop counters. Generated save/load coverage now includes a completed boss
  saved during the between-contract shop and the next generated offer saved
  after loop continuation.
- `project/scenes/combat/combat_screen.gd` clears stale terminal outcome chrome
  when the between-contract shop opens and reuses the generated-only contract
  picker when a loaded or continued run is in generated offer phase.

Guardrails:

- Failure and restart behavior remain unchanged: a second loss on a contract
  route still ends the Adventure as `CONTRACT_FAILED`, and restart begins fresh
  run state.
- Player build/economy state is preserved across completed contracts; only
  route-local claimed reward IDs are cleared for the next generated contract.
- The between-contract shop is a playtest transition between contracts, not a
  route node or hidden route/economy subsystem.

P4M8-T10 verification:

- `project/tests/generated_contract_outcome_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_contract_save_load_test.gd`: passed outside the
  sandbox.
- `project/tests/contract_test_entry_test.gd`: passed outside the sandbox.
- `project/tests/run_failure_state_test.gd`: passed outside the sandbox.
- `project/tests/run_outcome_presentation_test.gd`: passed outside the
  sandbox.
- `project/tests/dashboard_header_test.gd`: passed outside the sandbox.
- `project/tests/contract_offer_source_test.gd`: passed outside the sandbox.
- `project/tests/save_load_test.gd`: passed outside the sandbox.
- `project/tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before
  script execution. Known non-blocking Godot exit output appeared on successful
  outside-sandbox runs: ObjectDB/RID/resource cleanup warnings and occasional
  dummy renderer RID leak warnings in UI scene tests.

## P4M8-T11 Adventure Lifecycle Regression Results

Implementation date: 2026-08-23.

Added `project/tests/p4m8_adventure_lifecycle_regression_test.gd` as a stitched
Adventure lifecycle check. It verifies:

- Normal Adventure can move from final Tavern reward into the authored Gilded
  Serpent/Vyra contract, save/load the authored offer and accepted route,
  complete Vyra, save/load the between-contract shop, and continue into three
  generated offers.
- The generated loop can accept a generated contract, save/load the accepted
  route, materialize generated combat nodes, claim generated rewards, traverse
  to a generated boss, save/load the between-contract shop, and continue to a
  distinct deterministic next generated offer.
- Contract Test-style setup skips Tavern and Vyra, starts directly at generated
  offers, and repeats two generated contract completions while advancing
  `completed_contract_count` and `contract_offer_index`.
- Failure/restart semantics remain covered by focused run-failure tests: a
  second contract loss still ends the Adventure as `CONTRACT_FAILED`, and
  restart begins fresh run state.

Known design follow-up from playtesting:

- Generated maps need more interesting and meaningful route choices. The
  current regression pass preserves the existing route-system behavior; a later
  map/route-design task should improve branch identity, decision stakes, and
  path variety rather than hiding that work inside T11.

P4M8-T11 verification:

- `project/tests/p4m8_adventure_lifecycle_regression_test.gd`: passed outside
  the sandbox.
- `project/tests/generated_contract_outcome_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_contract_save_load_test.gd`: passed outside the
  sandbox.
- `project/tests/contract_test_entry_test.gd`: passed outside the sandbox.
- `project/tests/run_failure_state_test.gd`: passed outside the sandbox.
- `project/tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_ui_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/map_overlay_route_preview_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_inspector_test.gd`: passed outside the
  sandbox.
- `project/tests/contract_offer_source_test.gd`: passed outside the sandbox.
- `project/tests/save_load_test.gd`: passed outside the sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/tests/run_outcome_presentation_test.gd`: passed outside the
  sandbox.
- `project/tests/dashboard_header_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before
  script execution. Known non-blocking Godot exit output appeared on successful
  outside-sandbox runs: ObjectDB/RID/resource cleanup warnings and occasional
  dummy renderer RID leak warnings in UI scene tests.

## P4M8-T12 Documentation And Handoff To P4M9 Results

Implementation date: 2026-08-23.

P4M8 is closed. The milestone expanded generated-contract variety without
rewriting the Phase 4 spine:

- P4M8-T1 audited the baseline content set and accepted measurable expansion
  targets.
- P4M8-T2 added runtime archetypes: `aegis`, `nullify`, `spiteful`, and
  `riftbound`.
- P4M8-T3 added bounded overlap emphasis and curated pair identities for
  `aegis` + `fortified`, `nullify` + `warded`, `spiteful` + `hexed`,
  `nimble` + `devious`, and `aegis` + `nullify`.
- P4M8-T4 expanded presentation pools and generated Rogue-voice contract text.
- P4M8-T5 added metadata-only route modifiers: `pressure_emphasis`,
  `elite_spotlight`, `biome_hazard`, and `volatile_pacing`.
- P4M8-T6 added elite variants: `shieldbreaker_captain`, `null_priest`,
  `venom_speaker`, `phase_duelist`, and `riftbound_marauder`.
- P4M8-T7 added boss variants: `apex_bulwark`, `void_regent`,
  `plague_court`, and `chrono_tyrant`.
- P4M8-T8 completed sparse preview readability coverage for the expanded
  content set.
- P4M8-T9 broadened Balance Lab, matrix, and audit coverage across templates,
  pressure axes, modifiers, variants, and expanded archetypes.
- P4M8-T10 added the repeatable contract loop for playtesting.
- P4M8-T11 added the stitched Adventure lifecycle regression across normal
  Adventure, Contract Test, generated routing, repeated completions,
  save/load, failure/restart, route UI, matrix, inspector, and Balance Lab
  gates.

P4M8-T12 final verification:

- `project/tests/p4m8_adventure_lifecycle_regression_test.gd`: passed outside
  the sandbox.
- `project/tests/generated_contract_outcome_test.gd`: passed outside the
  sandbox.
- `project/tests/generated_contract_save_load_test.gd`: passed outside the
  sandbox.
- `project/tests/contract_test_entry_test.gd`: passed outside the sandbox.
- `project/tests/generated_route_matrix_test.gd`: passed outside the sandbox.
- `project/tests/balance_lab_test.gd`: passed outside the sandbox.
- `project/tests/contract_offer_flow_test.gd`: passed outside the sandbox.
- `project/tests/run_failure_state_test.gd`: passed outside the sandbox.
- Sandboxed Godot still hit the known `user://logs` startup crash before
  script execution. Known non-blocking Godot exit output appeared on successful
  outside-sandbox runs: ObjectDB/RID/resource cleanup warnings and occasional
  dummy renderer RID leak warnings in UI scene tests.

Known content and design gaps for P4M9 or later:

- Generated maps need more interesting and meaningful route choices. Branch
  identity, decision stakes, and path variety need a scoped route/map design
  pass.
- Route topology still feels repetitive under playtesting even though the
  lifecycle and generated-state regressions are stable.
- Reward-table variety may need another pass after more generated-loop
  playtesting.
- Non-combat route nodes, route-local resources, consumables, route shop
  nodes, mystic upgrades, crafting/transmutation, boss bargains,
  scout/reveal nodes, and hidden events remain deferred.

P4M9 handoff:

- Add meaningful generated route topology variety so contracts ask different
  routing questions across repeated play.
- Improve generated contract map readability and visual polish so the loop
  feels presentable for outside playtesters.
- Keep the new work scoped to route shape, branch identity, map readability,
  and existing preview/reward/pressure signals.
- Preserve authored Gilded Serpent regression behavior.
- Preserve deterministic generated contract save/load, route materialization,
  offer advancement, and repeated contract completion behavior.
- Keep non-combat nodes, route-local resources, route shops, consumables,
  mystic upgrades, crafting/transmutation, boss bargains, scout/reveal nodes,
  and hidden events deferred.
- Hand final stabilization, export, and Phase 4 closeout to P4M10 after the
  generated contract map experience is clean.

## Expected Implementation Surfaces

- `project/scripts/systems/runtime_monster_generator.gd`: runtime archetype,
  mechanic, pressure-axis, defense override, and generated monster output.
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`:
  route materialization, biome selection, node role assignment, generated
  encounter payloads, validation notices, pressure metadata, and rewards.
- `project/scripts/resources/contract_def.gd`: generated contract identity,
  route-level generated state, and serialization helpers.
- `project/scripts/resources/contract_route_node.gd`: generated node state,
  route preview data, combat/debug payloads, reward fields, and outgoing node
  data.
- `project/scripts/systems/contract_offer_source.gd`: generated offer context,
  generated contract offer creation, difficulty, completed-contract pressure,
  and offer text.
- `project/scripts/autoload/build_state.gd`: Adventure contract loop state,
  completed-contract counters, between-contract shop transition, contract
  outcome, retry, failure, restart, and completion behavior.
- `project/scenes/combat/map_overlay.gd`: sparse generated route-card display
  and selectability.
- `project/scenes/combat/combat_screen.gd`: between-contract shop/next-contract
  presentation and terminal outcome presentation.
- `project/scenes/practice_room*` and Monster Lab surfaces: isolated generated
  monster inspection and feel testing, where applicable.
- `project/tests/balance_lab_test.gd`: broad generated route, pressure,
  reward, and content health checks.
- Generated route, runtime monster, save/load, outcome, offer source, route UI,
  and matrix tests for focused regressions.

## Verification Notes

Run Godot 4.7 from:

`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`

Run Balance Lab when P4M8 changes:

- runtime monster archetypes or mechanic pools;
- generated enemy defenses, pressure axes, or generated difficulty;
- generated route validation or route pressure;
- generated rewards or reward previews;
- generated offer text, route UI previews, or sparse preview formatting;
- combat timing, event ordering, build resolution, poison, procs, duration, or
  DPS behavior.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Known local runner issue:

- Sandboxed Godot runs may hit the known `user://logs` startup crash before
  script execution. Recent milestone verification passed outside the sandbox.

## Exit Criteria

P4M8 is complete when:

- The current generated content set has been audited and expansion targets are
  documented.
- Runtime archetypes and mechanic combinations have enough breadth to produce
  distinct generated defensive identities across sampled routes.
- Biome, monster name, and contract theme pools have enough presentation
  variety to reduce obvious repetition.
- Modifiers, elite variants, and boss variants exist in a scoped, deterministic,
  saved/materialized form if the audit confirms they fit P4M8.
- Sparse route previews remain readable and do not leak combat/debug metadata.
- Expanded content preserves deterministic generated combat, reward, pressure,
  outcome, retry, restart, boss victory, and save/load behavior.
- Balance Lab and generated matrix coverage exercise the expanded content set
  and continue to catch pressure, reward, snowball, and dead-run issues.
- Authored Gilded Serpent behavior remains intact.
- This doc, `docs/P4_DawnBringer_Overview.md`, and onboarding context are
  updated with final status, verification results, known gaps, P4M9 route
  shape/presentation handoff notes, and P4M10 stabilization/export handoff
  notes.

## Follow-Ups For P4M9

- Add a modest batch of meaningfully different generated route templates, such
  as safe/risky branches, elite detours, wide matchup-choice maps,
  fork-and-rejoin routes, pressure gauntlets, and distinct boss approach lanes.
- Improve generated map quality. Playtesting found that routes need more
  interesting and meaningful choices, stronger branch identity, clearer
  decision stakes, and better visual readability.
- Preserve sparse route previews and deterministic materialized route state
  while improving presentation.
- Decide whether reward-table variety needs expansion after the larger content
  set is in place.
- Revisit deferred systems only after Phase 4 closeout priorities are clear:
  non-combat nodes, route-local resources, consumables, shops, mystic upgrades,
  crafting/transmutation, boss bargains, scout/reveal nodes, and hidden events.
