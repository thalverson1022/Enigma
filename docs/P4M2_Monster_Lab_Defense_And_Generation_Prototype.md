# P4M2: Monster Lab Defense And Generation Prototype

## Purpose

P4M2 turns Monster Lab into the design sandbox for generated enemy composition.
The milestone uses the P4M1 defense vocabulary to prototype monster archetypes,
defense packages, difficulty bands, validation warnings, and export/preview
flows before runtime procedural generation begins.

This milestone should prove the shape of generated monsters in tooling first.
P4M3 will move the proven model into deterministic runtime generation.

## Milestone Goal

Create a Monster Lab workflow that can compose readable enemy defensive
identities from archetypes and difficulty bands. Generated monster drafts should
communicate their matchup pressure clearly, avoid nonsensical combinations, and
export enough structured data for Balance Lab validation.

## Primary Outputs

- Monster Lab support for viewing and composing Phase 4 defense packages.
- Initial monster archetype/tag model and difficulty-band budget rules.
- Validation notices for structural readiness, runtime support, export
  compatibility, and prototype pressure drift.
- Preview text and exported values that make generated monsters readable in
  Balance Lab and later route previews.
- Focused implementation notes and verification results recorded in this
  milestone document.

## Current Focus

Active task: P4M2 complete. Next milestone is P4M3 Runtime Monster Generator.

Immediate next step:

- Start P4M3 by moving the proven Monster Lab archetype, budget, validation,
  preview, and Balance Lab bridge shapes into deterministic Godot runtime
  generation.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M2-T1: Audit Monster Lab Surface | Complete | Find or establish the Monster Lab entry point and identify the clean integration points with `Monster`, Balance Lab, existing monster resources, and enemy preview UI. | Relevant scenes, scripts, data files, and gaps are identified, and implementation notes record the intended Monster Lab architecture before feature work begins. |
| P4M2-T2: Import Defense Vocabulary Into Monster Lab | Complete | Bring the P4M1 defense fields, IDs, labels, and formatting into Monster Lab so generated enemies use the approved vocabulary. | Monster Lab can display and edit the implemented defense fields with stable names and defaults that preserve current monster behavior. |
| P4M2-T3: Define Monster Archetype Model | Complete | Create the first archetype/tag model for enemy identities such as tanky, evasive, blocker, mage-resistant, cleanser, suppressor, slower, and poison-hostile. | Archetypes have names, tags, defense ranges, matchup notes, and combination rules that can drive package composition. |
| P4M2-T4: Define Difficulty Bands And Budgets | Complete | Establish initial difficulty bands and budget rules for scaling HP, defensive values, and package complexity without maxing every defense. | Each band has value ranges, budget limits, and guardrails for how many major defenses can appear together. |
| P4M2-T5: Prototype Package Composition | Complete | Add a Monster Lab flow that composes archetypes plus difficulty band into a concrete monster draft. | A designer can select or randomize archetype/band combinations and see the resulting HP, defenses, tags, and summary text. |
| P4M2-T6: Add Validation Warnings | Complete | Add lightweight structural notices before drafts reach Balance Lab or runtime generation. | Monster Lab notices missing/empty drafts, runtime-preview-only mechanics, export compatibility gaps, obvious readability load, and prototype pressure drift without judging final balance. |
| P4M2-T7: Add Matchup Preview Language | Complete | Show what each generated monster pressures and what build styles can answer it. | Monster Lab previews identify the enemy's defensive identity, pressured player strategies, useful counterplay, and later route-preview implications. |
| P4M2-T8: Export Bridge To Balance Lab | Complete | Let Monster Lab prototypes flow into Balance Lab checks without manually copying values. | At least a few Monster Lab packages can be exported or converted into Balance Lab scenario overrides and run through existing defense metrics. |
| P4M2-T9: Focused Tests And Balance Lab Gate | Complete | Cover composition rules, difficulty budgets, validation warnings, and export shape with focused tests and Balance Lab verification. | Relevant Godot tests pass, Balance Lab remains green, and any known failures are documented with scope and follow-up. |
| P4M2-T10: Verify And Document Closeout | Complete | Close the milestone by updating docs, overview status, verification notes, and follow-ups for runtime generation. | `docs/P4_DawnBringer_Overview.md` reflects P4M2 status, this document records verification results, and P4M3 handoff notes are clear. |

## Implementation Notes

Record notable design or code decisions here as implementation proceeds.

### P4M2-T1 Audit Notes

Complete.

Monster Lab entry point:

- Monster Lab already exists as a standalone browser tool under
  `tools/monster-lab`. It is not a Godot scene. The entry point is
  `tools/monster-lab/index.html`, with behavior in `tools/monster-lab/app.js`
  and data globals in `tools/monster-lab/data/mechanics.js`,
  `tools/monster-lab/data/archetypes.js`, and
  `tools/monster-lab/data/difficulty.js`.
- The current tool already supports two-archetype generation, deterministic
  seed rolls, difficulty budgets, bespoke stat tuning, warnings, build-pressure
  cards, sprite preview, and JSON export. P4M2 should extend this surface
  rather than creating a second Monster Lab inside Godot.
- `tools/monster-lab/README.md` explicitly keeps Monster Lab separate from
  Sprite Lab and Balance Lab, and notes the future bridge should mirror the
  dependency-free Balance Lab browser/server pattern.

Godot monster data surface:

- The runtime monster resource is `project/scripts/resources/monster.gd`.
  P4M1 added the currently approved defense fields: `armor`,
  `poison_resistance`, `dodge_chance`, `crit_negation`, `block`, `absorb`,
  `cleanse_threshold`, `suppress`, `slow`, `stun_duration_ms`, and
  `interrupt_skip_count`.
- Existing authored monster resources live in `project/data/monsters/*.tres`
  and are referenced by encounters and route nodes. P4M2 prototypes can stay
  JSON/browser-only, but any export meant for Godot must map cleanly to a
  `Monster` resource or a `monster_overrides` dictionary.
- `project/scripts/resources/contract_route_node.gd` is the route-side consumer:
  it carries a `Monster`, `duration_ms`, reward, difficulty label, reward
  quality label, and preview text. Runtime procedural route work should target
  this shape later, but P4M2 only needs enough export data for Balance Lab and
  preview review.

Vocabulary and data-model gaps:

- Monster Lab currently uses a mixed vocabulary. `armor`, `resistance`,
  `evasion`, and `poison_cleanse` overlap conceptually with P4M1, but the
  approved Godot field names are `armor`, `poison_resistance`, `dodge_chance`,
  and `cleanse_threshold`.
- Monster Lab also contains placeholder/future mechanics such as `thorns`,
  `regeneration`, `shielded_hide`, and `enrage`. These do not exist on the
  P4M1 `Monster` resource and should either be removed from the P4M2 active
  pool, marked explicitly as future-only, or mapped only to preview-only model
  fields that cannot be exported as Godot defenses.
- T2 should make `tools/monster-lab/data/mechanics.js` the first integration
  target. The active mechanic IDs should match the canonical vocabulary in
  `docs/Enemy_Defense_Mechanics.md`, with display labels and descriptions that
  mirror that document.
- Unit scales need explicit conversion rules: Godot stores
  `poison_resistance`, `dodge_chance`, and `crit_negation` as `0.0` to `1.0`
  fractions, while Monster Lab currently displays several values as whole
  percentages. Export should include Godot-ready values rather than only
  display values.

Balance Lab integration path:

- The Godot Balance Lab runner is `project/scripts/tools/balance_lab.gd`, with
  the CLI entry point `project/scripts/tools/run_balance_suite.gd` and focused
  test `project/tests/balance_lab_test.gd`.
- Balance Lab already supports scenario-level `monster_overrides`, applied by
  `_monster_with_overrides()`. This is the cleanest P4M2 bridge: Monster Lab
  export can produce a `monster_overrides` dictionary plus `hp`, `duration_ms`,
  label, archetype tags, and notes without creating `.tres` files.
- Existing defense scenarios already exercise `block`, `dodge_chance`,
  `crit_negation`, `poison_resistance`, `absorb`, `suppress`,
  `cleanse_threshold`, and `slow`. That makes Balance Lab ready to validate most
  generated packages as soon as Monster Lab emits the same field names.
- `stun_duration_ms` and `interrupt_skip_count` exist on `Monster` and are
  accepted by `_monster_with_overrides()`, but their runtime behavior is
  deferred in P4M1. Monster Lab should label these as timing-disruption preview
  fields until a dedicated timing pass makes them Balance Lab-verifiable.

Enemy preview and route-preview surfaces:

- `project/scenes/combat/enemy_panel.gd` is the current pre-fight enemy readout.
  It shows HP, armor, poison resistance, fight window, reward preview, and a
  simple pressure line derived from armor and poison resistance.
- `project/scenes/combat/map_overlay.gd` is the route preview surface. Its
  `_route_node_button_text()` and `_route_pressure_score()` also use HP, armor,
  poison resistance, duration, difficulty label, and reward quality. The current
  pressure score does not yet account for dodge, block, absorb, cleanse,
  suppress, slow, stun, or interrupt.
- P4M2 should avoid duplicating preview language in several places. The likely
  Godot follow-up is a small shared formatter for defense summaries and matchup
  pressure, consumed later by `enemy_panel.gd`, `map_overlay.gd`, Balance Lab
  report text, and any Monster Lab import/export preview.

Intended P4M2 architecture:

- Keep Monster Lab as the fast browser sandbox for generated enemy design.
- Treat the P4M1 `Monster` fields and `docs/Enemy_Defense_Mechanics.md` as the
  canonical runtime vocabulary.
- Update Monster Lab's mechanic data to use canonical IDs, labels, value ranges,
  and export names before expanding archetypes or difficulty bands.
- Keep archetypes and difficulty budgets in Monster Lab data files for P4M2.
  Move only the proven model into deterministic Godot runtime code in P4M3.
- Export a structured JSON payload with both design metadata and a Godot-ready
  section, especially `monster_overrides`, `hp`, `duration_ms`, archetype tags,
  difficulty band, validation warnings, and matchup preview text.
- Use Balance Lab's existing `monster_overrides` pathway as the first bridge.
  A local Monster Lab server can come later if direct one-click evaluation is
  needed; it is not required for T2.

Next implementation order:

1. Replace or gate Monster Lab mechanics so the active set matches P4M1:
   `armor`, `dodge_chance`, `crit_negation`, `block`, `poison_resistance`,
   `absorb`, `cleanse_threshold`, `suppress`, `slow`, `stun_duration_ms`, and
   `interrupt_skip_count`.
2. Update built-in archetypes to use the canonical IDs and remove unmapped
   placeholder mechanics from generated output.
3. Update Monster Lab export to include a Godot-ready `monster_overrides`
   dictionary with correct numeric units.
4. Expand warnings and pressure cards against the approved vocabulary.
5. Add a focused browser/tool test or lightweight static validation for
   canonical IDs and export shape before building the Balance Lab bridge.

### P4M2-T2 Defense Vocabulary Import Notes

Complete.

Monster Lab mechanics now use the canonical P4M1 `Monster` defense vocabulary
in `tools/monster-lab/data/mechanics.js`:

- `armor`
- `dodge_chance`
- `crit_negation`
- `block`
- `poison_resistance`
- `absorb`
- `cleanse_threshold`
- `suppress`
- `slow`
- `stun_duration_ms`
- `interrupt_skip_count`

The old active prototype IDs (`resistance`, `evasion`, `poison_cleanse`,
`shielded_hide`, `regeneration`, `thorns`, and `enrage`) were removed from
active mechanic and archetype generation. `Resistance` remains only as the
player-facing display name for the canonical `poison_resistance` field.

Implementation details:

- `tools/monster-lab/data/mechanics.js` now records each mechanic's
  `godotField`, UI labels, tags, P4M1 description, export scale, cost hints,
  pressure modifiers, and difficulty curves.
- `tools/monster-lab/data/archetypes.js` now uses only canonical mechanic IDs
  in the built-in archetype weights.
- `tools/monster-lab/app.js` validates mechanic and archetype IDs during setup,
  rejects unknown Godot export fields, formats mechanic values consistently in
  cards and tuning sliders, and exports a Godot-ready `monster.godot` block.
- Monster Lab export now includes `monster.godot.monster_overrides`, with `hp`
  plus selected defense fields. Percent-style UI values export in Godot runtime
  units, so values such as `25` display as `25 resistance %` but export as
  `0.25` for `poison_resistance`.
- `stun_duration_ms` and `interrupt_skip_count` are marked `preview_only` in
  export because P4M1 added data fields but deferred runtime timing-disruption
  behavior.
- `tools/monster-lab/validate.js` provides a lightweight static validation
  check for canonical IDs, archetype references, difficulty curves, and export
  unit conversion.

Deferred to later P4M2 tasks:

- T3 should refine archetype names, tags, ranges, matchup notes, and
  combination rules now that the raw field vocabulary is stable.
- T4/T6 should tune budgets and warnings with real Balance Lab output rather
  than treating the current heuristic costs as final.
- T8 should connect exported `monster_overrides` into Balance Lab scenarios
  instead of relying on manual JSON inspection.

### P4M2-T3 Archetype Model Notes

Complete.

Monster Lab's main workflow now starts as a three-column assembly line:

- Build Archetype: name a custom archetype and define its mechanic stubset,
  weights, value ranges, and scaling profiles.
- Generator: choose the two archetypes, difficulty band, monster kind, and
  batch size.
- Candidate Queue: review a generated batch from the current settings, compare
  average score/EHP/DPS, and select one monster for detailed inspection,
  bespoke tuning, sprite preview, warnings, and export.

This keeps archetype authoring, generator controls, and generated monster review
visibly separate while preserving the existing deterministic seed workflow.
T3 intentionally defers explicit matchup-preview prose and hard combination
rules. The current design goal is for players to learn archetype tags through
play and later Practice Room testing, while Monster Lab uses reasonable guess
values until the new gear and talent baselines are available.

Follow-up UI adjustment:

- Replaced the temporary Custom A/Custom B authoring slots with a single
  editable archetype catalog in the Build Archetype column.
- The archetype selector now loads any catalog entry into the mechanic editor.
  Designers can create a new archetype, edit mechanic weights/ranges/scaling,
  save it into the catalog, or delete the selected archetype.
- Generator Archetype A/B dropdowns now draw from the same current catalog, so
  saved archetypes are immediately available for batch generation.
- Saved archetype catalog changes persist in browser local storage; Reset
  restores the built-in archetype list.
- The Generator column now shows the mechanics available from the current
  Archetype A/B pair, ranked by combined selection weight.
- Added a Secondary Scale control from `1` to `10`: at `10`, Archetype B
  contributes at full weight; at `1`, Archetype B contributes at 10% weight.
  The scale affects B's mechanic selection weights, shared-mechanic range
  blending, and HP-bias blending.
- Archetype B can now be set to `None`, producing A-only generation with no
  secondary weights, range blending, HP-bias blending, or B name parts.
- Added a per-mechanic Required flag in the archetype editor. Required
  mechanics are always inserted into generated monsters that use the archetype;
  remaining mechanic slots are filled by weighted random selection. Required
  status is shown in the Generator mechanic preview and exported with generated
  monster JSON.
- Split fight-window length out of difficulty with a Generator Tempo profile.
  Difficulty still controls HP range, budget, mechanic count, and target DPS
  expectation. Tempo now controls duration: Burst is a fixed short window,
  Standard uses the difficulty baseline, Extended uses 130% of that baseline,
  and Endurance uses 160%. Monster Kind still applies its existing duration
  modifier after the selected tempo profile.
- Renamed the prototype difficulty ladder to Easy, Medium, Hard, Ultra, and
  Nightmare. Custom archetype Low/High values now act as the base roll range for a
  mechanic, while the Scaling setting applies a post-roll difficulty multiplier.
  Flat never exceeds the base range, Gentle and Standard grow upward with
  difficulty, and Steep grows aggressively at Ultra/Nightmare to support later
  pseudo-infinite scaling. Inverted mechanics such as Cleanse Threshold scale
  downward because lower values are stronger.
- Added archetype generation metadata: tags, unlock difficulty, allowed monster
  kinds, and route weight. The Build Archetype editor can inspect all catalog
  entries, while the Generator dropdowns filter archetypes by the selected
  difficulty and monster kind so late-game archetypes do not appear early.
- Added archetype library import/export. Import Library appears at the start of
  the Build Archetype flow and replaces the current local library. Export
  Library appears at the end of the flow and emits a
  `monster_lab_archetype_catalog.v1` JSON payload with full mechanic configs
  and generation metadata, giving Monster Lab a backup format and a likely
  bridge shape for later runtime import/conversion work.
- Added a Library Name field. Exported archetype libraries use this name for
  the downloaded JSON filename and store it as `library_name` in the payload so
  several monster libraries can be swapped in testing without losing their
  identity.
- Added `tools/monster-lab/Monster_Libraries` as the central local storage
  folder for test archetype libraries. Export Library now uses the browser save
  picker when available so designers can choose that folder or another testing
  location; unsupported browsers fall back to a normal JSON download.
- Added the first exported archetype library at
  `tools/monster-lab/Monster_Libraries/dawnbringer_archetypes_v1.json`.
- Changed Monster Lab startup to an empty working library. The tool no longer
  auto-loads built-in archetypes or a previous imported library; designers
  import the library they want to test or create a new archetype from the empty
  state.
- Clarified interrupt semantics in the defense vocabulary and Monster Lab data:
  interrupt is skill-specific. It cancels one direct attack skill and skips only
  that same skill's future macro triggers; unrelated skills continue normally.
- Clarified timing-disruption trigger identities. Stun is anti-burst and
  triggers when a single direct hit crosses `stun_trigger_hit_percent` of
  monster max HP. Interrupt is anti-repetition and triggers when the same direct
  skill is used `interrupt_repeat_threshold` times in a row.
- User verified the checked-in library imports correctly in Monster Lab and
  that generated batches across difficulty/kind settings behave as expected.

T3 closeout:

- The first archetype library exists at
  `tools/monster-lab/Monster_Libraries/dawnbringer_archetypes_v1.json`.
- Monster Lab can load a chosen archetype library, edit archetype metadata and
  mechanic stubs, generate A/B or A-only candidates, and export both individual
  monster JSON and full archetype-library JSON.
- Archetypes now carry the T3 model data needed for later runtime generation:
  name, tags, unlock difficulty, allowed monster kinds, route weight, HP bias,
  required mechanics, weighted optional mechanics, value ranges, scaling
  profiles, and timing-disruption trigger parameters.
- Deferred to later tasks: budget tuning, validation guardrails, Balance Lab
  bridge, runtime importer/converter, and player-facing tag learning tools.

### P4M2-T4 Difficulty Bands And Budgets Notes

Complete.

Monster Lab now uses a pressure-based difficulty model instead of independent
fixed HP and duration defaults:

- Difficulty bands define target DPS ranges, defense budget, mechanic count,
  major-defense limits, major-defense cost thresholds, and acceptable DPS
  tolerance.
- Tempo profiles define duration ranges: Burst 11-16 seconds, Standard 18-24,
  Extended 26-34, and Endurance 38-52.
- Candidate generation rolls selected mechanics first, estimates their
  effective-HP multiplier, rolls duration and target DPS, then derives raw HP
  from target DPS, duration, defense multiplier, archetype HP bias, and monster
  kind.
- The final model computes effective HP and required DPS, then classifies the
  result as in band, slightly under/over, or out of band.
- Monster Kind still modifies budget, duration, target DPS, HP shape, and
  mechanic count so elite/boss roles can remain heavier than normal monsters
  inside the same difficulty ladder.

Initial target DPS ranges:

- Easy: 6-10 DPS.
- Medium: 14-20 DPS.
- Hard: 21-28 DPS.
- Ultra: 30-40 DPS.
- Nightmare: 42-55 DPS.

Initial guardrails:

- Easy allows 1 major defense, with major defenses starting at cost 28.
- Medium allows 1 major defense, starting at cost 34.
- Hard allows 2 major defenses, starting at cost 42.
- Ultra allows 3 major defenses, starting at cost 52.
- Nightmare allows 4 major defenses, starting at cost 64.

Monster Lab UI now shows raw HP, effective HP, duration, target DPS range,
required DPS, budget usage, major-defense count, and band-fit pressure status.
Warnings flag over-budget candidates, too many major defenses, required DPS
above or below the selected pressure window, and the existing risky defense
combinations.

Exported monster JSON now includes `target_dps`, `target_dps_range`,
`dps_tolerance`, pressure-window metadata, pressure status, target DPS delta,
and major-defense budget fields in `balance_model`.

Deferred to later P4M2 tasks:

- T5 should use these fields to improve package composition rather than merely
  warning on strained candidates after generation.
- T6 should tune the cost thresholds and warning severity against Balance Lab
  output once representative packages exist.
- T8 should carry target DPS and pressure-status fields through the Balance Lab
  export bridge.

### P4M2-T5 Prototype Package Composition Notes

Complete.

T5 was intentionally narrowed to an MVP Monster Lab prototype instead of a
full automatic optimizer. The goal remains an in-game monster generation system,
not a final monster generator inside Monster Lab. Monster Lab should provide
inspectable drafts and export shape; actual balance authority belongs to
Godot-backed combat tests, Balance Lab, and later tuning after item and skill
tree revisions.

Implemented MVP behavior:

- Generator settings are now staged. Changing Archetype A/B, Secondary Scale,
  Difficulty, Tempo, Monster Kind, or Batch Size updates the generator preview
  controls only; the Candidate Queue changes only when `Generate Batch` is
  pressed.
- Importing, saving, deleting, or resetting archetype library data no longer
  auto-generates a candidate queue. Designers choose when to generate after
  staging settings.
- Candidate drafts keep the simple archetype + difficulty + tempo + kind model
  from T4. There is no multi-pass optimizer or hard composition scorer.
- Candidate cards use simple `Monster 1`, `Monster 2`, etc. names and show
  glanceable HP, selected defenses, duration, required DPS, and band-fit status.
- Detailed score, effective HP, budget bars, warnings, and export data remain
  in the selected monster panel for deeper inspection.

Design boundary:

- Monster Lab warnings and DPS fit are heuristic design signals only.
- T6 should keep warnings lightweight and obvious rather than trying to solve
  final balance.
- P4M3 should move the proven data shape into deterministic Godot runtime code.
- Later Balance Lab/runtime passes should decide actual DPS values after the
  reward, item, and skill-tree baselines are revised.

### P4M2-T6 Structural Validation Notice Notes

Complete.

T6 was narrowed from balance-combination validation to structural readiness
notices. Monster Lab no longer warns that specific defense pairings are bad
matchups, because final matchup pressure depends on later DPS tests, item
revisions, skill-tree revisions, runtime generation, and Balance Lab evidence.

Implemented notice categories:

- Export: missing archetype metadata, empty defense drafts, or mechanics that
  cannot map cleanly to the Godot `Monster` resource.
- Runtime: timing mechanics such as Stun and Interrupt are marked as
  preview-only until their runtime behavior is implemented.
- Pressure: required DPS above or below the prototype target window is reported
  as drift, not as a final balance failure.
- Readability: normal monsters with many mechanics or many major defenses are
  called out as potential route-preview readability issues.
- Budget: over-budget packages are called out as prototype review prompts.

Removed/deferred warning types:

- No armor/resistance, dodge/block, resistance/cleanse, absorb/suppress, poison
  pressure, or burst pressure warnings are treated as structural problems.
- Those judgments are deferred to Balance Lab/runtime testing after the broader
  build, item, reward, and skill-tree baselines are better established.

Monster Lab warning export now includes category, severity, and title metadata
instead of title-only strings.

### P4M2-T7 Matchup Preview Language Notes

Complete.

T7 adds lightweight matchup-preview language to Monster Lab without turning the
tool into final balance authority. Each canonical defense mechanic in
`tools/monster-lab/data/mechanics.js` now owns a small `matchup` block with:

- defensive identity language;
- build pressure language;
- useful counterplay language;
- later route-preview implication language.

Monster Lab composes those mechanic phrases with the selected archetype names,
archetype tones, generated pressure scores, difficulty band, tempo, and monster
kind. The selected monster panel now shows a Matchup Preview section with:

- Identity;
- Pressures;
- Counterplay;
- Route Implication;
- derived tags.

The exported monster JSON now includes `monster.matchup_preview` with the same
structured fields: `identity`, `pressures`, `counterplay`, `route_preview`,
`tags`, and `primary_mechanics`. This gives T8 a stable preview payload to carry
into Balance Lab scenario overrides or reports.

The static Monster Lab validator now requires every canonical mechanic to define
all matchup language fields so future defense additions cannot silently omit
route-preview text.

### P4M2-T8 Export Bridge To Balance Lab Notes

Complete.

T8 adds the first file-based bridge from Monster Lab exports to Balance Lab
scenario specs. The bridge intentionally avoids a local server or one-click
browser execution; it proves that exported monster packages can become
Godot-readable scenario data and run through existing Balance Lab metrics.

Implemented pieces:

- Added `tools/monster-lab/export_to_balance_lab.js`.
- Added a sample Monster Lab export fixture at
  `tools/monster-lab/fixtures/monster_lab_export_sample.json`.
- The converter turns one Monster Lab monster export into a
  `monster_lab_balance_scenarios.v1` catalog with three probe scenarios:
  Physical Stab, Shadow Poison, and Bandit Crit.
- Converted scenarios preserve `monster.godot.monster_overrides`,
  `duration_ms`, target DPS metadata, pressure status, validation notices, and
  `matchup_preview` text.
- Balance Lab now appends imported `.json` scenario catalogs from
  `res://data/balance_lab/imported` when that folder exists. Missing or empty
  import folders leave the authored suite unchanged.
- Added `BalanceLab.imported_scenario_specs_from_dir()` for focused import
  tests and `BalanceLab.run_scenario_spec()` for running a converted scenario
  through the normal scenario resolver path.
- Balance Lab reports now preserve imported scenario provenance:
  `source`, `source_file`, `source_monster_id`, `matchup_preview`, and
  `balance_model`.
- Added a focused Godot fixture at
  `project/tests/fixtures/balance_lab_imported/monster_1.balance_lab.json`.
- Added `project/tests/balance_lab_import_test.gd`, which imports the fixture
  and runs one converted scenario through existing defense metrics.

Usage:

```powershell
node tools\monster-lab\export_to_balance_lab.js --input path\to\monster.json
```

Default output path:

```text
project\data\balance_lab\imported\<monster_id>.balance_lab.json
```

Design boundary:

- T8 validates bridge shape and Godot compatibility.
- T8 does not tune generated monsters, harden thresholds, or implement a local
  Monster Lab server.
- Timing preview fields such as Stun and Interrupt can still be exported, but
  their runtime behavior remains deferred until the timing-disruption pass.

### P4M2-T9 Focused Tests And Balance Lab Gate Notes

Complete.

T9 hardened the existing Monster Lab and Balance Lab verification surface rather
than adding new generation behavior.

Implemented test/validation coverage:

- `tools/monster-lab/validate.js` now checks built-in archetype authoring
  metadata: IDs, names, tone language, positive HP bias, name-part pools, and
  positive canonical mechanic weights.
- The same validator now checks converted Balance Lab catalog metadata,
  pressure-status preservation, probe rotations, gear arrays, empty threshold
  policy, matchup preview preservation, and invalid Monster Lab export failures.
- `project/tests/balance_lab_import_test.gd` now checks all three imported
  probe scenarios from the fixture catalog, including namespaced IDs, source
  metadata, monster override units, duration, seed count, empty thresholds, and
  import notes.
- The import test also verifies report preservation of `source_file`,
  `matchup_preview`, and `balance_model` after running one imported scenario
  through normal Balance Lab combat metrics.
- Missing imported-scenario folders are still verified as a no-op.

Verification boundary:

- T9 ran the focused Monster Lab static/bridge checks and the Balance Lab import
  plus existing Balance Lab regression tests.
- Broader combat/runtime defense tests were not expanded because T9 did not
  change runtime defense mechanics or combat resolution.
- Godot emitted the known non-blocking ObjectDB/resource cleanup warnings.

### P4M2-T10 Closeout Notes

Complete.

P4M2 closes with Monster Lab established as the Phase 4 generated-monster design
sandbox. The milestone produced:

- canonical P4M1 defense vocabulary inside Monster Lab;
- editable/importable/exportable archetype libraries;
- difficulty bands, tempo profiles, HP derivation, budget estimates, and
  pressure-window metadata;
- staged batch generation and candidate review;
- structural validation notices;
- matchup preview language for identity, pressure, counterplay, and route
  implication;
- a file-based export bridge into Balance Lab scenario catalogs;
- focused Node and Godot verification for the data shape, bridge shape, and
  Balance Lab compatibility.

P4M3 should move only the proven pieces into deterministic Godot runtime code:

- archetype library shape: IDs, tags, unlock difficulty, allowed kinds, route
  weight, HP bias, required mechanics, mechanic weights, ranges, scaling, and
  timing-disruption trigger metadata;
- generation inputs: seed, primary archetype, optional secondary archetype,
  secondary scale, difficulty band, tempo profile, and monster kind;
- output shape: `Monster`-compatible values plus generation metadata useful for
  route previews and save/load;
- validation model: structural notices should remain lightweight and should not
  become final balance judgments;
- Balance Lab bridge: runtime-generated samples should continue to flow through
  `monster_overrides` scenario checks before broader integration.

Deferred beyond P4M2:

- final DPS/budget tuning after reward, item, and skill-tree baselines evolve;
- runtime behavior for timing-disruption preview fields such as Stun and
  Interrupt;
- one-click Monster Lab server/browser evaluation;
- route-level generated contract graph integration;
- shared Godot preview formatter reuse across enemy panel, map overlay, Balance
  Lab reports, and generated route previews.

## Verification Notes

Run Balance Lab when Monster Lab changes touch generated difficulty,
enemy/monster data, defense package values, combat compatibility assumptions,
or exported scenario overrides.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Verification results:

- `node tools\monster-lab\validate.js`: passed.
- `node --check tools\monster-lab\app.js`: passed.
- `node --check tools\monster-lab\data\mechanics.js`: passed.
- `node --check tools\monster-lab\data\archetypes.js`: passed.
- `node --check tools\monster-lab\validate.js`: passed.
- Opened `tools/monster-lab/index.html` in the Codex browser panel for local
  Monster Lab inspection.
- After the T3 assembly-line workflow update, `node --check
  tools\monster-lab\app.js` and `node tools\monster-lab\validate.js` passed.
- After the archetype metadata and catalog import/export update, `node --check
  tools\monster-lab\app.js`, `node --check tools\monster-lab\validate.js`, and
  `node tools\monster-lab\validate.js` passed.
- T3 closeout verification:
  - User confirmed `dawnbringer_archetypes_v1.json` imports correctly through
    Monster Lab's empty-start workflow.
  - User confirmed generated batches across difficulty/kind settings work as
    expected for the current archetype library.
  - `node --check tools\monster-lab\app.js`: passed.
  - `node tools\monster-lab\validate.js`: passed.
- T4 pressure-based difficulty verification:
  - `node --check tools\monster-lab\app.js`: passed.
  - `node --check tools\monster-lab\data\difficulty.js`: passed.
  - `node --check tools\monster-lab\validate.js`: passed.
  - `node tools\monster-lab\validate.js`: passed.
- T5 MVP package composition verification:
  - `node --check tools\monster-lab\app.js`: passed.
  - `node tools\monster-lab\validate.js`: passed.
- T6 structural validation notice verification:
  - `node --check tools\monster-lab\app.js`: passed.
  - `node tools\monster-lab\validate.js`: passed.
- T7 matchup-preview verification:
  - `node --check tools\monster-lab\app.js`: passed.
  - `node --check tools\monster-lab\data\mechanics.js`: passed.
  - `node --check tools\monster-lab\validate.js`: passed.
  - `node tools\monster-lab\validate.js`: passed.
- T8 Balance Lab bridge verification:
  - `node --check tools\monster-lab\export_to_balance_lab.js`: passed.
  - `node --check tools\monster-lab\validate.js`: passed.
  - `node tools\monster-lab\validate.js`: passed.
  - `node tools\monster-lab\export_to_balance_lab.js --input tools\monster-lab\fixtures\monster_lab_export_sample.json --output C:\Users\tommh\.codex\visualizations\2026\08\11\019feeb4-8378-7840-b03e-e79c1f2e6829\monster_1.balance_lab.json --seed-count 3`: passed.
  - `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_import_test.gd`: passed.
  - `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed.
- T9 focused test and Balance Lab gate verification:
  - `node --check tools\monster-lab\app.js`: passed.
  - `node --check tools\monster-lab\data\mechanics.js`: passed.
  - `node --check tools\monster-lab\data\archetypes.js`: passed.
  - `node --check tools\monster-lab\data\difficulty.js`: passed.
  - `node --check tools\monster-lab\export_to_balance_lab.js`: passed.
  - `node --check tools\monster-lab\validate.js`: passed.
  - `node tools\monster-lab\validate.js`: passed.
  - `node tools\monster-lab\export_to_balance_lab.js --input tools\monster-lab\fixtures\monster_lab_export_sample.json --output C:\Users\tommh\.codex\visualizations\2026\08\11\019feeb4-8378-7840-b03e-e79c1f2e6829\monster_1_t9.balance_lab.json --seed-count 3`: passed.
  - `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_import_test.gd`: passed.
  - `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed.
- T10 closeout verification:
  - `node --check tools\monster-lab\app.js`: passed.
  - `node --check tools\monster-lab\data\mechanics.js`: passed.
  - `node --check tools\monster-lab\data\archetypes.js`: passed.
  - `node --check tools\monster-lab\data\difficulty.js`: passed.
  - `node --check tools\monster-lab\export_to_balance_lab.js`: passed.
  - `node --check tools\monster-lab\validate.js`: passed.
  - `node tools\monster-lab\validate.js`: passed.
  - `node tools\monster-lab\export_to_balance_lab.js --input tools\monster-lab\fixtures\monster_lab_export_sample.json --output C:\Users\tommh\.codex\visualizations\2026\08\11\019feeb4-8378-7840-b03e-e79c1f2e6829\monster_1_t10.balance_lab.json --seed-count 3`: passed.
  - `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_import_test.gd`: passed.
  - `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`: passed.

## Exit Criteria

P4M2 is complete when:

- Monster Lab can represent the approved P4M1 defense vocabulary.
- Initial archetype/tag pools can create readable defensive identities.
- Difficulty bands and budget rules generate scaled packages without nonsense
  combinations.
- Monster Lab shows validation warnings and matchup preview language.
- Prototype packages can bridge into Balance Lab or equivalent structured
  verification.
- Focused tests and relevant Balance Lab checks pass, or any failures are
  documented with follow-up tasks.
- `docs/P4_DawnBringer_Overview.md` reflects the final P4M2 status.

## Follow-Ups For P4M3

Use this section to collect items that should move into deterministic runtime
generation rather than expanding the Monster Lab prototype.

- Move the proven archetype, budget, and validation model into seeded Godot
  runtime code.
- Decide save/load policy for generated monsters that are not authored `.tres`
  resources.
- Add deterministic tests for repeated generation from the same seed.
- Verify generated monsters remain combat-compatible across supported
  difficulty bands.
- Decide how much Monster Lab preview language should be reused directly in
  encounter and route preview UI.
