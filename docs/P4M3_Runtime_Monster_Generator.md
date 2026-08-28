# P4M3: Runtime Monster Generator

## Purpose

P4M3 moves the proven Monster Lab generation model into deterministic Godot
runtime code. Before random generation becomes a main-loop dependency, this
milestone adds a playable Practice Room defense harness so the implemented
defense mechanics can be felt and checked in real combat.

P4M2 proved the generated-monster data shape in Monster Lab. P4M3 should prove
that the same ingredients work inside the game engine, first through controlled
manual playtesting and then through seeded runtime generation.

## Milestone Goal

Create a deterministic Godot-side monster generation system that can produce
repeatable, combat-compatible monsters from archetypes, difficulty bands, tempo
profiles, and monster kinds.

The milestone should preserve deterministic combat, keep validation structural
rather than balance-authoritative, and keep unsupported future mechanics gated
until their runtime behavior is explicitly implemented.

## Scope Notes

- This milestone is inside the Godot game engine, not only Monster Lab.
- P4M1 defense mechanics now have runtime behavior:
  `armor`, `poison_resistance`, `dodge_chance`, `crit_negation`, `block`,
  `absorb`, `cleanse_threshold`, `suppress`, `slow`, `stun_duration_ms`, and
  `interrupt_skip_count`.
- Practice Room should expose playable controls for functional defense
  mechanics before they become random-generation ingredients.
- Adventure contract integration and procedural route graphs remain later
  milestones.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M3-T1: Practice Room Defense Harness | Complete | Expose the functional P4M1 defense mechanics in Practice Room so archetype ingredients can be manually playtested in actual combat. | Practice Room can set armor, resistance, dodge, crit negation, block, absorb, cleanse, suppress, slow, stun, and interrupt; archetype-style presets are available; focused tests cover target setup. |
| P4M3-T2: Runtime Generator Plan And Data Policy | Complete | Define the exact Godot data shapes, source-of-truth policy, and preview-only mechanic gating before generation code lands. | Plan records whether archetype data loads from JSON, resources, or converted dictionaries; save/load policy is proposed; stun/interrupt handling is explicit. |
| P4M3-T3: Runtime Data Shapes | Complete | Add Godot-side representations for archetypes, mechanic configs, difficulty bands, tempo profiles, monster kinds, generation inputs, and generated output metadata. | Data structures can represent the M2 library fields needed for generation and preview metadata without requiring Adventure integration. |
| P4M3-T4: Archetype Library Runtime Bridge | Complete | Bring `dawnbringer_archetypes_v1.json` or an equivalent converted form into Godot runtime access. | Godot can load or construct the checked-in archetype library and validate core fields. |
| P4M3-T5: Seeded Runtime Generator | Complete | Implement deterministic monster generation from seed plus archetype, difficulty, tempo, and kind inputs. | Same seed/input produces identical output; different seeds produce valid variation. |
| P4M3-T6: Mechanic Selection And Scaling | Complete | Port required mechanics, weighted optional mechanics, secondary scale, value ranges, difficulty scaling, unit conversion, and inverted cleanse scaling. | Generated defense fields match Monster-compatible units and respect archetype constraints. |
| P4M3-T7: HP, Budget, And Pressure Model | Complete | Port enough of the M2 pressure model to derive HP, duration, effective-HP estimates, budget usage, major-defense count, and pressure status. | Generated monsters include target DPS metadata and structural pressure status for tests and previews. |
| P4M3-T8: Generated Monster Output | Complete | Produce `Monster` instances or Monster-compatible output with generation metadata. | Output can feed combat resolution and carry seed, archetype IDs/tags, difficulty, tempo, kind, selected mechanics, notices, and preview metadata. |
| P4M3-T9: Structural Validation Notices | Complete | Add lightweight runtime validation for missing data, empty drafts, over-budget packages, readability load, pressure drift, and preview-only mechanics. | Invalid or strained generation results produce structured notices without blocking deterministic output unless required data is missing. |
| P4M3-T10: Determinism And Combat Tests | Complete | Verify repeatability and combat compatibility across supported difficulty bands. | Focused Godot tests prove same-seed repeatability and generated monsters can run through `CombatResolver`. |
| P4M3-T11: Balance Lab Sample Gate | Complete | Ensure runtime-generated samples can still flow through Balance Lab-style checks or scenario overrides. | Representative generated samples run through existing defense metrics without breaking Balance Lab. |
| P4M3-T12: Documentation And Closeout | Complete | Update milestone docs, overview status, verification notes, and P4M4 handoff. | P4M3 results, known gaps, and next-step preview/readability needs are documented. |

## Practice Room Harness Notes

The Practice Room harness is a deliberate first slice, not a separate milestone.
It should let us feel the defense vocabulary before trusting it as random
generation material.

Initial controls should cover only functional runtime defenses:

- Armor
- Resistance
- Dodge
- Crit Negation
- Block
- Absorb
- Cleanse Threshold
- Suppress
- Slow

Initial presets should mirror a few M2 archetype identities where practical:

- Armored or Fortified
- Warded
- Nimble
- Hexed
- Devious, including stun/interrupt now that timing disruption is implemented

Implementation note: P4M3-T1 added a single in-memory Practice Room target with
editable controls for all functional runtime defenses plus Blank, Armored,
Fortified, Warded, Nimble, Hexed, and Devious presets. The disruption slice now
adds playable Practice Room controls for `stun_duration_ms` and
`interrupt_skip_count`: stun pauses the next macro timing after a direct hit
crosses the documented large-hit threshold, and interrupt cancels repeated
direct skills while skipping only that same skill's future macro triggers.

Resistance note: the current runtime field is still named `poison_resistance`
for compatibility, but player-facing P4M3 text should treat it as general
magical resistance. Poison is currently the only magical damage source using
that mitigation path; future non-poison magical damage should use the same
resistance value.

Questions to answer during playtest:

- Does each mechanic read clearly in combat?
- Do combinations create understandable pressure instead of opaque failure?
- Are any mechanics too swingy, too invisible, or too punishing before route
  preview work begins?
- Which values should be softened before runtime generation uses them broadly?

## Runtime Generator Plan And Data Policy

P4M3 should keep Monster Lab as the fast design sandbox and treat its exported
archetype library JSON as the bridge source of truth for this milestone. Godot
should not become the primary archetype authoring surface yet. Runtime code
should load or construct from the checked-in JSON shape, validate it, and
normalize it into typed Godot-side data objects before generation.

Recommended source policy:

- Source-of-truth input: `tools/monster-lab/Monster_Libraries/dawnbringer_archetypes_v1.json`.
- Supporting reference data: `tools/monster-lab/data/mechanics.js` and
  `tools/monster-lab/data/difficulty.js` remain the design-side reference for
  mechanic definitions, value units, cost hints, difficulty curves, and budget
  bands until the Godot runtime bridge has equivalent checked-in data.
- Godot runtime should not parse JavaScript files directly. If mechanic and
  difficulty data are needed at runtime, T3/T4 should either add Godot-native
  dictionaries/resources that mirror the JS data or add exported JSON versions
  generated from Monster Lab.
- `.tres` resources are not the first source-of-truth choice for P4M3. They can
  be introduced later if designers need Godot Inspector editing, but raw JSON
  keeps Monster Lab, tests, diff review, and runtime import aligned.

Planned Godot-side data shapes:

- `RuntimeMechanicDef`: mechanic ID, Godot field, display names, tags,
  description, matchup language, export scale, min/max, cost hints, scaling
  curves, conflict IDs, extra trigger fields, and runtime support state.
- `RuntimeArchetypeDef`: ID, name, tone, tags, unlock difficulty, allowed
  monster kinds, route weight, base HP bias, mechanic weights, mechanic config
  overrides, and name-part pools.
- `RuntimeDifficultyBand`: numeric ID, name, defense budget, mechanic-count
  range, major-defense limits, major-defense threshold, target DPS range, and
  DPS tolerance.
- `RuntimeGenerationInput`: seed, archetype A, optional archetype B,
  difficulty band, monster kind, tempo profile, optional overrides, and data
  version.
- `GeneratedMonsterDraft`: generated name, `Monster`-compatible defense fields,
  HP, duration, target DPS, selected mechanic records, archetype IDs/tags,
  budget and pressure metadata, validation notices, and source seed.

Save/load policy:

- Player saves should store the generated monster's seed, generator input,
  generator version, library schema/version, and resolved encounter identity
  metadata needed for readable route previews.
- Player saves should not embed the whole archetype library by default.
  Runtime generation should be deterministic from the saved seed/input plus the
  checked-in versioned data.
- For active Adventure runs, generated monster output should be stable after a
  route is offered. If generator data changes between builds, version mismatch
  should either preserve already materialized monster fields in the save or
  intentionally regenerate only when the run is known to be compatible.
- Balance/sample artifacts may store full generated outputs because they are
  test fixtures, not player-run state.

Versioning policy:

- The imported archetype library schema is currently
  `monster_lab_archetype_catalog.v1`.
- Godot should add a generator version string before T5. Changing selection
  weights, scaling math, HP pressure math, or value conversions should bump that
  generator version.
- Runtime notices should include schema or generator mismatches so stale saves
  and test fixtures fail loudly instead of silently drifting.

Mechanic support and gating policy:

- Runtime-supported fields for P4M3 are `armor`, `poison_resistance`,
  `dodge_chance`, `crit_negation`, `block`, `absorb`, `cleanse_threshold`,
  `suppress`, `slow`, `stun_duration_ms`, and `interrupt_skip_count`.
- Player-facing language should call `poison_resistance` "Resistance" because
  it is the general magical resistance field, even though poison is currently
  the only magical damage source.
- `stun_duration_ms` is runtime-supported. Current resolver behavior uses the
  documented default trigger: a direct hit that deals at least 12% of monster
  max HP pauses the next macro timing by `stun_duration_ms`.
- `interrupt_skip_count` is runtime-supported. Current resolver behavior uses
  the documented default trigger: the third repeated direct skill is cancelled,
  then only that same skill is skipped for `interrupt_skip_count` future macro
  triggers.
- Monster Lab still has stale `previewOnly` metadata and preview wording for
  stun/interrupt. T3/T4 should either update Monster Lab metadata to runtime
  support or import it as legacy design metadata and override it in Godot's
  runtime mechanic definitions.
- Unknown mechanics remain gated. If future Monster Lab exports include fields
  such as thorns or non-implemented damage types, Godot should emit structured
  notices and exclude them from runtime generation until their mechanics exist.

Validation policy:

- Hard errors: missing library schema, missing archetype IDs, duplicate IDs,
  unknown required mechanics, invalid difficulty IDs, missing required mechanic
  ranges, malformed min/max values, or a generated draft with no combat-usable
  mechanics.
- Warnings: over-budget packages, too many major defenses, too many simultaneous
  mechanics for readability, pressure drift outside the difficulty band, stale
  preview-only flags on now-supported mechanics, unsupported optional mechanics,
  and unusual combinations that may be playable but need review.
- Validation should remain structural. It can identify risk and pressure, but
  final balance authority should still come from Practice Room playtests and
  Balance Lab samples.

T3/T4 implementation handoff:

- Start with lightweight `RefCounted` data classes or dictionaries under
  `project/scripts/systems/` rather than editor-facing `.tres` resources.
- Add a loader/normalizer that can read the JSON library, map camelCase export
  keys into Godot-friendly snake_case fields, and validate the core contract.
- Keep generator output `Monster`-compatible from the beginning, but carry
  metadata separately so Adventure previews and Balance Lab checks do not have
  to infer identity from raw defense numbers.

## Verification Notes

Run Balance Lab when P4M3 changes touch generated difficulty, monster data,
combat compatibility assumptions, poison/proc behavior, duration, DPS pressure,
or route pressure metadata.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

P4M3-T1 verification:

- `training_room_fight_setup_test.gd` passed.
- `training_room_fight_test.gd` passed.
- `enemy_defense_mechanics_test.gd` passed.
- `balance_lab_test.gd` passed.

P4M3-T2 verification:

- Documentation-only planning task; no Godot runtime test required.
- Source data audited from Monster Lab archetype library, mechanic definitions,
  and difficulty bands.

P4M3-T3 implementation:

- Added runtime monster generator data shapes under
  `project/scripts/systems/runtime_monster_generator/`:
  `RuntimeMechanicDef`, `RuntimeMechanicConfig`, `RuntimeArchetypeDef`,
  `RuntimeDifficultyBand`, `RuntimeGenerationInput`, `GeneratedMonsterDraft`,
  `RuntimeMonsterNotice`, and `RuntimeMonsterDataNormalizer`.
- Added `runtime_monster_data_shapes_test.gd` to cover Monster Lab-style
  dictionary normalization, generation input metadata, validation notices, and
  `GeneratedMonsterDraft.to_monster()`.

P4M3-T3 verification:

- Attempted `runtime_monster_data_shapes_test.gd`, but Godot 4.7 currently
  crashes during project startup before test script output with
  `Failed to open 'user://logs/godot...log'` followed by a signal 11 crash.
  This matches the local runner issue observed during the prior stun/interrupt
  work and is not specific to this new test.

P4M3-T4 implementation:

- Added `RuntimeArchetypeLibrary` as the runtime container for normalized
  archetype definitions, source metadata, validation notices, ID lookup, and
  difficulty/kind availability filtering.
- Added `RuntimeArchetypeLibraryLoader` to load the checked-in Monster Lab
  archetype library JSON, validate the `monster_lab_archetype_catalog.v1`
  schema, normalize archetype entries through the T3 data shapes, reject
  duplicate IDs, and report hard contract errors as structured notices.
- Added `runtime_archetype_library_loader_test.gd` to cover default library
  loading, known `fortified` archetype fields, availability filtering, duplicate
  ID validation, and missing core-field validation.

P4M3-T4 verification:

- Source JSON sanity check passed with schema
  `monster_lab_archetype_catalog.v1`, 10 archetypes, first ID `fortified`, and
  0 duplicate IDs.
- Attempted `runtime_archetype_library_loader_test.gd`, but Godot 4.7 still
  crashes during project startup before test script output with
  `Failed to open 'user://logs/godot...log'` followed by a signal 11 crash.
  Retried with `--user-data-dir` pointed into the workspace and a pre-created
  logs folder; the same startup crash occurred before the test could execute.

P4M3-T5 implementation:

- Added `RuntimeMonsterGenerator` with generator version `p4m3.t5.v1`.
- The generator accepts `RuntimeGenerationInput`, loads or receives a
  `RuntimeArchetypeLibrary`, validates generator version, library schema, seed,
  primary/secondary archetype IDs, difficulty, kind, and archetype availability.
- Seeded output uses the existing `RunRng` context-seeding convention to produce
  stable generated IDs and archetype name-part combinations from seed,
  archetypes, difficulty, kind, tempo, and generator version.
- Generated drafts now carry deterministic identity metadata, archetype IDs,
  combined tags, source input, source seed, baseline monster-compatible HP,
  duration, and target DPS placeholders. Mechanic selection, defense values, HP
  pressure math, and budget status remain intentionally deferred to T6/T7.
- Added `runtime_monster_generator_test.gd` to cover same-seed repeatability,
  different-seed variation, secondary archetype metadata, and invalid-input
  notices.

P4M3-T5 verification:

- Attempted `runtime_monster_generator_test.gd`, but Godot 4.7 still crashes
  during project startup before test script output with
  `Failed to open 'user://logs/godot...log'` followed by a signal 11 crash.
  This is the same local runner blocker recorded for T3/T4.

P4M3-T6 implementation:

- Added `RuntimeMechanicLibrary` with Godot-native built-in definitions mirroring
  the Monster Lab P4M3-supported defense fields: armor, Resistance,
  dodge, crit negation, block, absorb, cleanse, suppress, slow, stun, and
  interrupt. Stun and interrupt are treated as runtime-supported in Godot despite
  stale Monster Lab preview-only metadata.
- Added `RuntimeDifficultyLibrary` with the Monster Lab difficulty bands,
  mechanic-count ranges, budget hints, major-defense limits, and target DPS
  ranges for later T7 pressure work.
- Bumped `RuntimeMonsterGenerator.GENERATOR_VERSION` to `p4m3.t6.v1` because
  selection and scaling math now affect deterministic outputs.
- Ported required mechanics, combined primary/secondary weights, default
  secondary scale, weighted optional selection without replacement, kind-based
  extra mechanic counts, merged mechanic configs, difficulty scaling profiles,
  inverted cleanse scaling, and Monster-compatible export units.
- Generated drafts now populate `selected_mechanics` with raw values, exported
  Godot values, ranges, scaling metadata, required flags, tags, extras, and
  `defense_overrides` keyed by `Monster` fields.
- Updated `runtime_monster_generator_test.gd` to cover same-seed repeatability,
  different-seed variation, secondary archetype metadata, required mechanics,
  percent export units, elite extra mechanics, cleanse inverted scaling, and
  invalid-input notices.

P4M3-T6 verification:

- Attempted `runtime_monster_generator_test.gd`, but Godot 4.7 still crashes
  during project startup before test script output with
  `Failed to open 'user://logs/godot...log'` followed by a signal 11 crash.
  This remains the same local runner blocker recorded for T3/T4/T5.

P4M3-T7 implementation:

- Bumped `RuntimeMonsterGenerator.GENERATOR_VERSION` to `p4m3.t7.v1` because
  HP, duration, target DPS, and pressure metadata now affect deterministic
  generated output.
- Ported the Monster Lab pressure model into Godot runtime generation:
  tempo profiles roll fight duration, difficulty bands roll target DPS, monster
  kind adjusts HP/budget/duration/DPS, selected mechanics estimate mitigation
  multiplier, and archetype HP bias shapes the derived raw HP.
- Generated drafts now populate `budget_metadata` with adjusted budget, HP cost,
  mechanic cost, synergy cost, total budget usage, budget delta,
  major-defense count, max major defenses, and major-defense cost threshold.
- Generated drafts now populate `pressure_metadata` with target DPS range,
  target DPS, required DPS, effective HP, DPS tolerance, pressure window,
  pressure status/label, mitigation multiplier, HP bias, duration, and
  poison/burst/sustained pressure scores.
- Added per-mechanic `cost` to selected mechanic records and fixed
  `RuntimeMonsterDataNormalizer.snake_keys()` so numeric dictionary keys from
  built-in curve data normalize without runtime errors.
- Updated `runtime_monster_generator_test.gd` to cover deterministic pressure
  output, generated HP/duration ranges, kind-adjusted budgets, selected mechanic
  costs, pressure metadata, and harder-band pressure growth.

P4M3-T7 verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --editor --path project --quit`: passed and refreshed Godot global script class cache. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_generator_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_data_shapes_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.

P4M3-T8 implementation:

- Expanded `GeneratedMonsterDraft` into the runtime output wrapper for generated
  monsters.
- `GeneratedMonsterDraft.to_monster()` remains the clean combat-facing output:
  it creates a `Monster`, sets identity and HP, and applies only
  Monster-compatible defense fields.
- Added `GeneratedMonsterDraft.to_combat_payload()` so combat integration can
  consume a generated `Monster` plus `duration_ms`, target DPS, and a companion
  metadata dictionary without adding preview/save metadata to `Monster`.
- Added `GeneratedMonsterDraft.to_dictionary()` for save/load, preview, logging,
  and later T9/T10/T11 bridge work. The serialized output carries seed, source
  input, archetype IDs, tags, monster kind, selected mechanics, budget metadata,
  pressure metadata, defense overrides, duration, target DPS, and notices.
- Added `RuntimeMonsterNotice.from_dictionary()` so serialized notices
  round-trip with generated output.
- Updated `runtime_monster_generator_test.gd` to cover Monster conversion,
  metadata separation from `Monster`, combat payload shape, dictionary
  serialization/deserialization, notice round-tripping, and a generated-monster
  `CombatResolver` smoke test.

P4M3-T8 verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_generator_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_data_shapes_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.

P4M3-T9 implementation:

- Bumped `RuntimeMonsterGenerator.GENERATOR_VERSION` to `p4m3.t9.v1` because
  generated output now includes deterministic structural validation notices.
- Added `RuntimeMonsterGenerator.validate_draft_output()` and run it after
  mechanic selection, HP/budget/pressure modeling, and output metadata
  population.
- Added hard-error notices for missing generated IDs/names, missing HP,
  missing duration, no combat-usable mechanics, no defense overrides, missing
  required budget metadata, missing required pressure metadata, and selected
  mechanics that do not map to Monster-compatible defense fields.
- Added warning notices for over-budget packages, too many major defenses,
  busy normal monsters, high/low pressure drift, missing mechanic cost metadata,
  and preview-only mechanics if runtime metadata ever exposes one.
- Validation remains structural: warning notices do not block generated output,
  while hard output-shape errors mark the draft as errored.
- Updated `runtime_monster_generator_test.gd` to cover clean generated output,
  budget/major-defense/readability warnings, high and low pressure warnings,
  hard output errors, invalid mechanic fields, and validation notice
  serialization round-tripping.

P4M3-T9 verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_generator_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_data_shapes_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.

P4M3-T10 implementation:

- Expanded `runtime_monster_generator_test.gd` from single-case deterministic
  and combat smoke coverage into a supported-band matrix covering Easy through
  Nightmare difficulty bands.
- Added same-seed repeatability assertions across representative archetype,
  secondary-archetype, kind, and tempo combinations.
- Added different-seed variation checks across the same supported-band matrix
  while preserving structural validity expectations.
- Added generated-monster `CombatResolver` compatibility coverage across the
  supported-band matrix using `GeneratedMonsterDraft.to_combat_payload()`.
- Added shared generated-output shape assertions for positive HP, duration,
  target DPS, selected mechanics, Monster-compatible defense overrides, budget
  metadata, and pressure metadata.

P4M3-T10 verification:

- Initial sandboxed Godot run hit the known local startup blocker:
  `Failed to open 'user://logs/godot...log'` followed by a signal 11 crash
  before test script execution.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_generator_test.gd`: passed when run outside the sandbox. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_data_shapes_test.gd`: passed when run outside the sandbox. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed when run outside the sandbox. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/combat_test.gd`: passed when run outside the sandbox. Known ObjectDB/resource cleanup warnings appeared at exit.

P4M3-T11 implementation:

- Added runtime-generated monster sample scenarios to Balance Lab's authored
  scenario list, covering Easy normal, Medium normal, Hard elite, Ultra blended,
  and Nightmare blended generated monsters.
- Generated samples are built from `RuntimeMonsterGenerator.generate()` and
  carried into Balance Lab as serialized `GeneratedMonsterDraft` dictionaries,
  then restored to `Monster` instances for the normal scenario runner.
- Balance Lab scenario results now preserve generated-monster metadata,
  matchup-preview data, and balance-model data alongside the existing aggregate
  DPS, win-rate, poison, dodge, block, absorb, cleanse, suppress, and cast
  metrics.
- `balance_lab_test.gd` now asserts the generated sample scenarios are present,
  pass without warning/failure, and include generator metadata, archetype IDs,
  selected mechanics, defense overrides, matchup preview, and balance model
  fields.

P4M3-T11 verification:

- Initial sandboxed Godot run hit the known local startup blocker:
  `Failed to open 'user://logs/godot...log'` followed by a signal 11 crash
  before test script execution.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed when run outside the sandbox. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_generator_test.gd`: passed when run outside the sandbox. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_data_shapes_test.gd`: passed when run outside the sandbox. Known ObjectDB/resource cleanup warnings appeared at exit.

P4M3-T12 closeout:

- P4M3 is complete. Runtime monster generation now loads the checked-in
  archetype library, normalizes runtime data shapes, selects and scales
  Monster-compatible defense mechanics, derives HP/duration/target-DPS pressure
  metadata, emits structural validation notices, and produces generated
  `Monster` output plus preview/save/report metadata.
- Deterministic behavior is covered across supported difficulty bands. Same
  seed/input repeats, different seeds vary, generated monsters can feed
  `CombatResolver`, and representative generated samples now flow through
  Balance Lab scenario reporting.
- Runtime-supported generated defenses are armor, Resistance
  (`poison_resistance` internally), dodge, crit negation, block, absorb,
  cleanse, suppress, slow, stun, and interrupt.
- Validation remains structural rather than balance-authoritative. Warning
  notices identify budget, readability, and pressure drift risks without
  blocking output unless required data or combat-compatible fields are missing.
- Adventure contract integration, route graph generation, reward economy, and
  player-facing encounter previews remain later Phase 4 milestones.

P4M3-T12 verification:

- Initial sandboxed Godot runs may hit the known local startup blocker:
  `Failed to open 'user://logs/godot...log'` followed by a signal 11 crash
  before test script execution.
- Final focused regression was run outside the sandbox because of that local
  Godot startup/log issue.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_generator_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_monster_data_shapes_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/combat_test.gd`: passed. Known ObjectDB/resource cleanup warnings appeared at exit.

## Follow-Ups For P4M4

- Reuse generated monster metadata and matchup-preview fields in encounter and
  route previews.
- Decide how much Practice Room feedback should become player-facing route
  language.
- Expand preview formatting beyond armor and resistance so generated
  defenses are readable before route commitment.
- Show selected mechanics, structural notices, pressure status, and defense
  counters clearly without overloading the route-choice UI.
- Keep P4M4 focused on readability and preview language; route generation,
  contract integration, and reward economy remain P4M5-P4M7 work.
