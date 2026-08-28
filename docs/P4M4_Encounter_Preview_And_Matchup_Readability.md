# P4M4: Encounter Preview And Matchup Readability

## Purpose

P4M4 turns generated monster metadata into readable encounter previews and
matchup language before procedural routes become a main-loop dependency.

P4M3 proved deterministic runtime monster generation. P4M4 should prove that
generated monsters can be inspected, felt, and understood in-game before P4M5
adds full procedural contract route graphs.

This milestone starts in Practice Room because generated monster feel and
readability should be tested in isolation before route choice multiplies the
decision space.

## Milestone Goal

Create a focused readability layer for generated encounters. Testers should be
able to roll generated monsters in Practice Room, inspect their generated stats
and metadata, fight them immediately, and compare the preview language against
combat feel.

The milestone should not attempt final numerical balance. Player mechanics,
route rewards, contract economy, and later build revisions are not ready for
that. P4M4 should instead validate structure, clarity, deterministic
reproduction, and preview usefulness.

## Primary Outputs

- Practice Room runtime monster roller for testing-only generated encounters.
- Generated monster metadata display in Practice Room.
- Seed and reroll controls for reproducing useful generated monsters.
- Shared encounter preview formatter for generated and authored encounters.
- Player-facing defense and matchup language pass.
- Enemy panel and route-preview surface integration where appropriate.
- Focused generated-monster readability tests and verification notes.

## Current Focus

P4M4 Encounter Preview And Matchup Readability is complete. The milestone
proved the generated encounter readability layer in Practice Room, route
preview preparation, Balance Lab reporting, and focused regression coverage.

Immediate next step:

- Start P4M5 Procedural Contract Route Generator planning, using the P4M4
  preview formatter and route-preview handoff notes below.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M4-T1: Practice Room Runtime Monster Roller | Complete | Add a testing-only Practice Room flow for rolling generated monsters by difficulty. | Practice Room can open a generator menu, choose difficulty, roll a generated monster, and load it as the current target while preserving existing authored/preset target behavior. |
| P4M4-T2: Generated Monster Metadata Display | Complete | Show the generated monster's stats and metadata clearly in Practice Room. | Practice Room displays generated name, HP, duration, archetypes, kind, tempo, selected mechanics, defense values, seed, pressure label, and structural notices. |
| P4M4-T3: Practice Room Seed And Reroll Controls | Complete | Make generated monsters reproducible for debugging and future test fixtures. | Testers can reroll, see the seed, optionally enter or reuse a seed, and reproduce the same generated monster from the same settings. |
| P4M4-T4: Define Preview Readability Requirements | Complete | Decide what a player or tester must understand before fighting a generated monster. | A short spec records required preview fields, debug-only fields, compact route-preview needs, and what remains deferred until rewards/routes exist. |
| P4M4-T5: Shared Encounter Preview Formatter | Complete | Avoid duplicating preview language across Practice Room, enemy panel, map overlay, and Balance Lab. | A shared Godot formatter converts generated monster metadata into contract-map identity fields, combat-facing detail fields, and debug/testing sections. |
| P4M4-T6: Archetype And Matchup Language Pass | Complete | Make visible archetype tags and combat-facing detail language understandable without exposing full stats on the contract map. | Supported archetypes have readable names/tags, likely mechanics remain learnable, and detailed defense/matchup language is reserved for combat UI and testing surfaces. |
| P4M4-T7: Enemy HUD Effect Indicator Integration | Complete | Keep combat-window enemy information HUD-first with effect indicators instead of preview prose. | The combat HUD shows enemy effect indicators above the HP bar, does not expose seed/archetype/debug metadata, and preserves existing authored enemy panel behavior. |
| P4M4-T8: Route Preview Surface Preparation | Complete | Prepare map/route UI to compare generated encounters before full procedural routes exist. | Map overlay or route-node preview can show compact generated encounter fields: biome, monster name, Normal/Elite/Boss level, and archetype tags without requiring P4M5 route generation. |
| P4M4-T9: Generated Monster Readability Matrix | Complete | Test representative generated monsters across difficulty, archetypes, kinds, and tempos. | Focused tests or fixtures cover representative generated outputs and assert preview metadata is present, stable, and not empty. |
| P4M4-T10: Balance Lab Preview Preservation Check | Complete | Ensure generated preview data survives reporting and validation paths. | Balance Lab generated samples preserve preview metadata, selected mechanics, pressure metadata, and notices in reports. |
| P4M4-T11: Verification And Regression Gate | Complete | Confirm preview/readability work does not break combat or existing Adventure/Practice flows. | Relevant Godot tests pass: generated monster tests, Practice Room tests, enemy panel/map overlay tests where touched, Balance Lab, and combat baseline. |
| P4M4-T12: Documentation And Closeout | Complete | Record what was built and hand off cleanly to route generation. | This doc and the Phase 4 overview are updated with implementation notes, verification results, known gaps, and P4M5 handoff notes. |

## Implementation Notes

Record notable design or code decisions here as implementation proceeds.

### P4M4-T1 Practice Room Runtime Monster Roller

Implemented a testing-only generated target roller inside Practice Room:

- `TrainingRoomState.roll_generated_target()` loads the default runtime
  archetype library, chooses available archetypes for the selected difficulty,
  uses first-slice defaults of Normal kind and Standard tempo, generates a
  `GeneratedMonsterDraft`, and swaps the resulting `Monster` into the isolated
  Practice Room state.
- Generated monsters update the Practice Room target, combat duration, and
  fight seed from the draft, without reading or mutating Adventure contract or
  save state.
- `TrainingTargetPanel` now exposes a generated-target difficulty selector,
  Roll button, and compact generated readout showing name, HP, duration,
  archetypes, kind, pressure label, seed, tags, mechanics, and notices.
- Existing authored/preset target behavior remains available; manual defense
  edits and preset selection clear the generated readout so stale metadata is
  not shown after hand-editing.
- `training_room_fight_setup_test.gd` now covers a fixed-seed generated target
  roll, verifies target/duration/seed/readout updates, and then exercises the
  existing manual and preset flows.

### P4M4-T2 Generated Monster Metadata Display

Expanded the Practice Room generated-target readout from a compact summary into
a sectioned metadata display:

- Identity: generated name, HP, duration, difficulty, kind, tempo, seed, target
  DPS, archetypes, and tags.
- Pressure: pressure status, required DPS, effective HP, target DPS range, and
  poison/burst/sustained matchup scores.
- Defenses: final Monster-compatible defense values for every Practice Room
  defense field, including zero-valued fields for easy scanning.
- Selected mechanics: short name, raw generated value, exported combat value,
  mapped Godot defense field, and structural cost.
- Budget and notices: budget/total/delta/major-defense counts plus warnings or
  `None` when no notices are present.

The display remains Practice Room-only and still clears when a tester manually
edits defenses or chooses an authored/preset target. The focused Practice Room
setup test now asserts that the generated metadata sections and fields are
present after a fixed-seed roll.

### P4M4-T3 Practice Room Seed And Reroll Controls

Added reproducibility controls to the Practice Room generated-target panel:

- The generated target controls now include a visible `Gen Seed` field synced
  from the current generated draft seed.
- `Reroll` creates a fresh random generated target for the selected difficulty
  and writes the resulting seed back to the panel.
- `From Seed` regenerates the selected difficulty from the entered seed, making
  useful monsters reproducible for debugging and future fixture capture.
- Same difficulty plus same seed reproduces the same generated draft; changing
  difficulty with the same seed produces a different valid draft.
- Existing manual defense edits and preset selection still clear stale
  generated metadata.

The focused Practice Room setup test now exercises reroll seed changes,
same-settings reproduction, difficulty-plus-seed variation, seed field syncing,
and the prior generated metadata/defense/preset behavior.

### P4M4-T4 Preview Readability Requirements

Defined the preview readability target for contract-map and testing surfaces.
For now, player-facing contract previews should stay intentionally sparse and
learnable. Detailed defensive mechanics belong in combat UI once the player
commits to the fight and once the visual language for armor, resist, and other
defenses is ready.

Required player-facing contract-map fields:

- Biome or route-context presentation identity.
- Generated monster name.
- Visual encounter level: Normal, Elite, or Boss.
- Literal visible archetype tags, such as `armored + warded`.

Generated monster names may use flavorful presentation, but they should not hide
mechanical tags. For example, a map node can read as `Defensive Bogling` while
also showing `armored + warded` underneath. Players should learn the possible
mechanics associated with archetype tags over repeated contracts instead of
seeing full stat breakdowns before every fight.

Combat-facing information:

- Detailed armor, resist, defense values, and other generated mechanics should
  appear after entering combat, not on the contract map.
- P4M4 can use existing generated metadata and Practice Room readouts for
  testing, but final player-facing combat language is deferred until the combat
  UI visual language is designed.

Debug-only and testing fields:

- Seed and generation settings.
- Raw archetype IDs/tags and selected mechanics.
- Budget, structural cost, pressure metadata, target DPS, effective HP, notices,
  exported defense-field mappings, and generated raw values.
- These can remain visible in Practice Room, Monster Lab, Balance Lab, fixtures,
  and test reports, but should not become default route-map preview information.

Compact route-preview needs:

- Route nodes need enough space to compare biome, monster name, encounter level,
  and archetype tags at a glance.
- Normal fights should usually be manageable for a somewhat optimized build.
- Elite fights should be meaningful risk/reward pressure, especially when the
  player's build is weak or the enemy archetypes counter it.
- Boss fights sit at the contract goal and should be harder than normal or elite
  fights, requiring good build choices and smart use of resources gained along
  the route.
- Contract maps may include mostly normal fights, optional elites with better
  rewards, and possibly a mandatory elite guarding the only route to the boss.

Difficulty progression:

- Overall contract difficulty should rise as the player completes contracts.
- Difficulty should not be a simple ladder where contract 1 is Easy, contract 2
  is Hard, and so on.
- The player should not be able to farm easy contracts forever to reach
  unlimited power.
- Easier early fights with lower rewards, extra-gold gear, and risky elite
  detours should become route and economy tradeoffs.
- Difficulty tuning will need adjustment during balance work, but the current
  structural rule is completed-contract pressure rather than random encounter
  difficulty.

Biome and archetype relationship:

- Biome can influence presentation identity and may later bias archetype pools.
- Biome should not create fully obvious matchup solves, such as every swamp
  encounter being weak against one build.
- Mechanical archetypes remain visible and learnable; biome should add context
  and flavor without becoming a deterministic counter chart.

Deferred items:

- Final combat UI visual language for defenses, armor, resist, and generated
  mechanics.
- Full biome and monster-type presentation system, which belongs in P4M5/P4M8.
- Reward economy and final elite/boss risk tuning, which belongs mainly in P4M7.
- More granular encounter levels beyond Normal, Elite, and Boss.
- Final balance definitions for how completed-contract pressure maps to enemy
  generation budgets and available contract choices.

### P4M4-T5 Shared Encounter Preview Formatter

Added `EncounterPreviewFormatter` as the shared generated-encounter formatting
surface. The formatter accepts a `GeneratedMonsterDraft` plus optional
presentation context and returns separate sections for the current needs:

- `contract_map`: sparse player-facing map fields only: biome, monster name,
  Normal/Elite/Boss encounter level, literal archetype tags, and a joined
  archetype line.
- `combat`: generated monster details intended for after the player commits to
  combat, including HP, duration, encounter level, archetype tags, defense
  overrides, and selected mechanics.
- `debug`: testing and report metadata, including seed, difficulty, kind, tempo,
  raw archetype IDs, tags, selected mechanics, budget metadata, pressure
  metadata, and notices.

Practice Room generated-target text now uses the shared formatter rather than
hand-building generated monster metadata inside `TrainingTargetPanel`. The
visible Practice Room output remains debug/testing oriented and preserves the
existing seed, HP, difficulty, kind, tempo, archetype, tag, selected mechanic,
budget, and notice readout while keeping pressure and full defense sections out
of that compact label.

Added `encounter_preview_formatter_test.gd` to cover the formatter split:
contract-map output stays sparse, combat output preserves generated details,
debug output preserves seed/budget/pressure/notices, and Practice Room debug
text remains stable enough for the current generated-target workflow.

Verification:

- `encounter_preview_formatter_test.gd`: passed outside the sandbox.
- `training_room_fight_setup_test.gd`: passed outside the sandbox.

Known non-blocking output during verification:

- ObjectDB/RID/resource cleanup warnings at exit.

### P4M4-T6 Archetype And Matchup Language Pass

Added `EncounterArchetypeVocabulary` as the shared source for visible generated
archetype tags and combat-facing matchup summaries. Contract-map previews still
show only sparse route-choice information, but the formatter can now provide
combat UI with learnable language for what each archetype is likely to do.

Visible archetype tags currently match runtime archetype IDs. This keeps the
route-map language literal and avoids collisions between similar concepts such
as `fortified` and `armored`.

| Archetype Tag | Likely Mechanics | Pressures | Rewards |
| --- | --- | --- | --- |
| `fortified` | Armor, Crit Negate, Block | Direct physical hits, crit-reliant damage, low-hit-count rotations. | Armor bypass, reliable damage, poison, magic, or many smaller hits. |
| `warded` | Resist, Absorb, Suppress | Poison, magical pressure, proc-heavy builds. | Physical damage, direct hits, and builds that do not depend on poison uptime. |
| `nimble` | Dodge, Crit Negate | Slow single-hit skills and crit-reliant burst. | Accuracy, repeated hits, steady damage, and non-crit scaling. |
| `hexed` | Cleanse, Suppress | Poison stacking, debuffs, and triggered effects. | Front-loaded damage and builds that can win without long debuff setup. |
| `relentless` | Armor, Resist, Cleanse, Slow | Mixed builds by combining durability with tempo friction. | Balanced damage plans and builds that keep output stable through slowdowns. |
| `unstable` | Mixed Defense, Control | Narrow builds because its exact defense package is less predictable. | Flexible builds, broad damage sources, and adaptation once combat reveals details. |
| `devious` | Cleanse, Slow, Stun, Interrupt | Timing-sensitive rotations, long casts, and debuff setup. | Shorter rotations, redundant skills, and builds that tolerate control. |
| `arcane` | Stun, Interrupt | Cast timing, long setup windows, and fragile rotations. | Quick skills, resilient sequencing, and builds with multiple useful actions. |
| `armored` | Armor | Basic physical damage. | Armor bypass, poison, magic, or scaling that is not mostly flat physical hits. |
| `resistant` | Resist | Poison and magical damage. | Physical damage or builds that do not depend on poison. |

Formatter changes:

- `contract_map.archetype_tags` now comes from the vocabulary layer, with a
  fallback to the literal raw archetype ID for unknown future archetypes.
- `combat.archetype_summaries` now provides per-archetype display tags, likely
  mechanics, pressure language, reward language, and a short combat summary.
- `debug.raw_archetype_ids` preserves the exact generated IDs, while
  `debug.archetype_language` mirrors the combat-facing vocabulary for testing
  and reports.

Tests now verify that the runtime archetype library has vocabulary entries for
every generated archetype, unknown archetypes fall back to literal tags, and the
contract-map output remains sparse.

Verification:

- `encounter_preview_formatter_test.gd`: passed outside the sandbox.
- `training_room_fight_setup_test.gd`: passed outside the sandbox.

Known non-blocking output during verification:

- ObjectDB/RID/resource cleanup warnings at exit.

### P4M4-T7 Enemy HUD Effect Indicator Integration

Reframed T7 around the combat window HUD rather than the side enemy stats
panel. The combat window should behave like a HUD: clean visual indicators,
not route-preview text, matchup prose, archetype tags, or debug metadata.

Added an `EnemyEffectRow` inside the Adventure combat HUD's existing top
values line, beside the HP, armor, and resistance values. This preserves the
HP bar's vertical placement while rendering compact icon/value chips for
nonzero secondary enemy effects:

- `dodge_chance`
- `crit_negation`
- `block`
- `absorb`
- `cleanse_threshold`
- `suppress`
- `slow`
- `stun_duration_ms`
- `interrupt_skip_count`

Armor and poison resistance remain in their existing always-visible value
slots instead of being duplicated as secondary effect chips.

The effect row intentionally does not show generated seed, archetype tags,
budget metadata, pressure prose, or other debug-only information. It also does
not consume route-map preview fields. This keeps the contract-map preview,
side enemy panel, and combat-window HUD as separate readability layers.

Current icon treatment uses the closest existing combat HUD icons as
placeholders: armor, resistance, poison, shred, and decay. Bespoke icons for
each enemy effect remain deferred, but the row already uses per-effect IDs and
tooltips so later art can replace the placeholder mapping without changing the
HUD data shape.

Existing side enemy panel behavior is preserved. It still shows authored
pre-fight stat/reward/pressure text and remains separate from the combat-window
HUD.

Verification:

- `combat_hud_test.gd`: passed outside the sandbox.
- `enemy_panel_test.gd`: passed outside the sandbox.

Known non-blocking output during verification:

- ObjectDB/RID/resource cleanup warnings at exit.

### P4M4-T8 Route Preview Surface Preparation

Added an optional compact route-preview surface for generated route nodes
without requiring full P4M5 procedural route generation.

`ContractRouteNode` now has an optional `route_preview` dictionary. When this
dictionary is present, `map_overlay.gd` adapts it into sparse player-facing
route text:

- biome
- monster name
- encounter level: Normal, Elite, or Boss
- literal archetype tags, joined as `tag + tag`

The route-preview adapter intentionally ignores full combat and debug fields
such as HP, armor, resistance, duration, seed, budget, pressure, defense
details, and selected mechanics. Those remain combat-facing or testing-only
data, not contract-map preview text.

Authored route nodes with an empty `route_preview` keep their existing fallback
presentation. This preserves the current Gilded Serpent contract schematic and
route selection behavior while giving future generated nodes a clean preview
shape to opt into.

Verification:

- `map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `contract_offer_flow_test.gd`: passed outside the sandbox.

Known non-blocking output during verification:

- ObjectDB/RID/resource cleanup warnings at exit.

### P4M4-T9 Generated Monster Readability Matrix

Added `generated_monster_readability_matrix_test.gd` as a focused readability
coverage gate for runtime-generated monsters.

The matrix generates representative fixed-seed monsters and formats each one
through `EncounterPreviewFormatter.format_generated()`. The cases cover:

- Difficulties: Easy, Medium, Hard, Ultra, and Nightmare.
- Kinds: Normal, Elite, and Boss.
- Tempos: Standard, Burst, Extended, and Endurance.
- Single-archetype samples, including `armored` and `resistant`.
- Paired-archetype samples, including `fortified + warded`, `nimble + hexed`,
  `relentless + arcane`, and `unstable + devious`.

For each generated sample, the test asserts:

- Contract-map preview has only sparse player-facing fields: biome, monster
  name, encounter level, archetype tags, and archetype line.
- Contract-map preview does not leak source seed, difficulty, budget metadata,
  pressure metadata, defense overrides, selected mechanics, archetype summaries,
  or HP.
- Combat preview preserves monster name, HP, duration, encounter level,
  archetype tags/summaries, selected mechanics, and defense overrides.
- Debug preview preserves seed, difficulty, kind, tempo, raw archetype IDs,
  tags, archetype language, selected mechanics, budget metadata, pressure
  metadata, and notices.
- Same seed plus same settings reproduces the same generated draft and preview
  output.

The test also loops over every archetype in the runtime archetype library and
proves that each one can generate a non-empty preview at its unlock difficulty
and first supported kind. This keeps future archetype additions from silently
missing readable preview language.

Verification:

- `generated_monster_readability_matrix_test.gd`: passed outside the sandbox.
- `encounter_preview_formatter_test.gd`: passed outside the sandbox.
- `runtime_monster_generator_test.gd`: passed outside the sandbox.
- `map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `balance_lab_test.gd`: passed outside the sandbox.

Known non-blocking output during verification:

- ObjectDB/RID/resource cleanup warnings at exit.

### P4M4-T10 Balance Lab Preview Preservation Check

Balance Lab generated monster samples now preserve the shared generated
encounter preview payload through spec construction, scenario execution, and
JSON report writing.

For each runtime-generated Balance Lab sample, `balance_lab.gd` now stores:

- `encounter_preview`: the full shared formatter output, split into
  `contract_map`, `combat`, and `debug` sections.
- `matchup_preview.route_preview`: the sparse contract-map preview fields.
- `matchup_preview.combat_preview`: combat-facing generated details.
- `matchup_preview.debug_preview`: seed, difficulty, budget, pressure,
  selected mechanics, and notices.
- `generated_monster_metadata.encounter_preview`: the same formatter payload
  inside the generated metadata audit block.

The existing `matchup_preview` and `generated_monster_metadata` fields still
preserve selected mechanics, defense overrides, pressure metadata, budget
metadata, source seed, archetype IDs/tags, and notices. The sparse route
preview remains intentionally clean: biome, monster name, encounter level, and
archetype tags only.

`balance_lab_test.gd` now asserts that every generated Balance Lab scenario
preserves this data in memory and again after `results.json` is written and
parsed back from disk.

Verification:

- `balance_lab_test.gd`: passed outside the sandbox.
- `balance_lab_import_test.gd`: passed outside the sandbox.
- `runtime_monster_generator_test.gd`: passed outside the sandbox.
- `encounter_preview_formatter_test.gd`: passed outside the sandbox.

Known non-blocking output during verification:

- ObjectDB/RID/resource cleanup warnings at exit.

### P4M4-T11 Verification And Regression Gate

Ran the P4M4 verification gate across generated monster, Practice Room,
contract/route preview, Balance Lab, combat HUD, and combat baseline coverage.
Two existing regressions surfaced and were stabilized before marking the gate
complete:

- `combat_playback_test.gd` now mutates a retained `Monster` reference for
  impossible-HP loss fixtures, matching the older live-loss checks and ensuring
  the natural loss and speed-persistence sections really exercise defeat.
- `combat_screen_test.gd` now pins Drunk Buddy's fixture HP/armor for the
  second Tavern fight so the screen-level reward/shop handoff regression remains
  deterministic while balance values continue to move independently.

Verification:

- `runtime_monster_generator_test.gd`: passed outside the sandbox.
- `runtime_monster_data_shapes_test.gd`: passed outside the sandbox.
- `generated_monster_readability_matrix_test.gd`: passed outside the sandbox.
- `encounter_preview_formatter_test.gd`: passed outside the sandbox.
- `training_room_fight_setup_test.gd`: passed outside the sandbox.
- `training_room_fight_test.gd`: passed outside the sandbox.
- `training_room_build_test.gd`: passed outside the sandbox.
- `training_room_entry_test.gd`: passed outside the sandbox.
- `map_overlay_route_preview_test.gd`: passed outside the sandbox.
- `contract_offer_flow_test.gd`: passed outside the sandbox.
- `contract_test_entry_test.gd`: passed outside the sandbox.
- `contract_route_data_test.gd`: passed outside the sandbox.
- `combat_hud_test.gd`: passed outside the sandbox.
- `enemy_panel_test.gd`: passed outside the sandbox.
- `balance_lab_test.gd`: passed outside the sandbox.
- `balance_lab_import_test.gd`: passed outside the sandbox.
- `combat_test.gd`: passed outside the sandbox.
- `combat_recap_test.gd`: passed outside the sandbox.
- `combat_playback_test.gd`: passed outside the sandbox after the loss-fixture
  stabilization.
- `combat_screen_test.gd`: passed outside the sandbox after the second-fight
  fixture stabilization.

Known non-blocking output during verification:

- Running headless Godot in the sandbox still hits the known startup/log crash,
  so verification was run outside the sandbox.
- ObjectDB/RID/resource cleanup warnings still appear at process exit.

### P4M4-T12 Documentation And Closeout

Closed P4M4 as a documentation and handoff pass. No new runtime functionality
was required for T12; the task records the completed readability work and moves
the Phase 4 tracker to P4M5.

What P4M4 leaves ready:

- Practice Room can roll, reroll, seed-replay, inspect, and fight
  runtime-generated monsters by difficulty.
- Generated monster metadata is visible enough for manual feel testing:
  identity, HP, duration, difficulty, kind, tempo, archetypes/tags, pressure,
  defenses, selected mechanics, budget, seed, and notices.
- `EncounterPreviewFormatter` is the shared source for generated encounter
  preview sections: sparse `contract_map`, combat-facing `combat`, and
  testing/report `debug`.
- Archetype vocabulary gives generated encounters readable tags, likely
  mechanics, pressure language, reward language, and combat summaries.
- The Adventure combat HUD has compact enemy effect indicators for secondary
  defenses while keeping seed/archetype/debug metadata out of the fight window.
- `ContractRouteNode.route_preview` gives P4M5 a prepared shape for generated
  route-node previews without changing the current authored Gilded Serpent
  route behavior.
- Balance Lab preserves generated encounter preview metadata through generated
  sample specs, scenario execution, and JSON report output.
- Focused readability and regression tests cover representative generated
  outputs, formatter sparsity, route-preview consumption, Balance Lab
  preservation, Practice Room flows, and core combat/adventure regressions.

Known gaps intentionally handed off:

- P4M4 does not generate full procedural contract route graphs.
- P4M4 does not attach generated monsters to Adventure route nodes in the main
  loop beyond prepared preview surfaces and test fixtures.
- Biome and monster-type presentation identity remain design-ready but not
  implemented as a seeded route system.
- Final contract rewards, route economy, elite/boss reward pressure, and
  anti-snowball tuning remain deferred.
- Enemy effect HUD icons use existing placeholder icon mappings; bespoke icons
  can be added later without changing the current effect data shape.

Verification:

- T12 is documentation-only and relies on the P4M4-T11 verification gate.
- `docs/P4_DawnBringer_Overview.md` now marks P4M4 complete and points current
  focus to P4M5.
- `docs/P4_DawnBringer_Onboarding_Context.md` now summarizes P4M4 as complete
  and lists P4M5 as the active next milestone.

### Planning Notes

P4M4 is intentionally not a final balance milestone. The current player
mechanic, reward, route economy, and build-progression baselines are not ready
for authoritative tuning. Use generated monster combat feel to judge whether
defensive identities are distinct and readable, not whether their final numbers
are correct.

The first implementation slice should be a Practice Room testing tool, not a
player-facing contract feature:

- Difficulty selector: Easy, Medium, Hard, Ultra, Nightmare.
- First-roll defaults: random available archetypes, Normal kind, Standard tempo.
- Roll button: creates a runtime-generated monster and loads it as the current
  Practice Room target.
- Initial display: generated name, HP, duration, selected defenses, archetype
  IDs/tags, pressure label, seed, and notices.

Useful follow-up controls can be added after the first slice works:

- Monster kind selector.
- Tempo selector.
- Archetype A selector.
- Archetype B selector or Random/None.
- Seed input.
- Reroll and reuse-seed actions.

Keep this tool isolated from Adventure contract state. It is a lab bench for
manual feel testing and seed discovery, not the final route or contract UI.

### Presentation Identity Design Note

Generated monster readability should separate mechanical identity from
presentation identity:

- Mechanical archetypes define combat behavior and matchup pressure, such as
  fortified, warded, nimble, hexed, and devious.
- Contract/route context should eventually define presentation identity through
  a seeded biome and monster-type layer, such as city bandits/guards/clerics or
  swamp slimes/lizards/boglings.
- Generated names should not rely only on mechanical tags. The same mechanical
  output can read differently by biome: a fortified warded city encounter might
  become a shielded guard, while a fortified warded swamp encounter might become
  a shellback bogling.

For P4M4, keep generated naming and previews focused on testability. Do not
build the full biome system here. Capture route-facing needs so P4M5 can add
the biome/monster-type presentation layer alongside procedural route graphs.

### Existing Integration Surfaces

- `project/scripts/systems/runtime_monster_generator/` contains the P4M3
  runtime generator, data shapes, library loader, and generated output wrapper.
- Practice Room already supports isolated Rogue build testing without mutating
  Adventure state.
- Practice Room defense presets currently load average archetype-style target
  states, but do not yet roll actual generated monsters.
- `project/scenes/combat/enemy_panel.gd` is the current pre-fight enemy readout.
- `project/scenes/combat/map_overlay.gd` is the route preview surface.
- Balance Lab already preserves generated monster metadata for representative
  runtime-generated samples.

## Verification Notes

Run Balance Lab when P4M4 changes touch generated monster data, combat
compatibility assumptions, preview metadata, enemy display, route pressure, or
report preservation.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Known local runner issue:

- Sandboxed Godot runs may hit the `user://logs` startup crash before script
  execution. P4M3 closeout tests passed when run outside the sandbox.

Final verification coverage:

- `runtime_monster_generator_test.gd`.
- `runtime_monster_data_shapes_test.gd`.
- `generated_monster_readability_matrix_test.gd`.
- `encounter_preview_formatter_test.gd`.
- `training_room_fight_setup_test.gd`.
- `training_room_fight_test.gd`.
- `training_room_build_test.gd`.
- `training_room_entry_test.gd`.
- `map_overlay_route_preview_test.gd`.
- `contract_offer_flow_test.gd`.
- `contract_test_entry_test.gd`.
- `contract_route_data_test.gd`.
- `combat_hud_test.gd`.
- `enemy_panel_test.gd`.
- `balance_lab_test.gd`.
- `balance_lab_import_test.gd`.
- `combat_test.gd`.
- `combat_recap_test.gd`.
- `combat_playback_test.gd`.
- `combat_screen_test.gd`.

## Exit Criteria

P4M4 is complete when:

- Practice Room can roll and fight runtime-generated monsters by difficulty.
- Generated monster seed/settings can be reproduced for debugging.
- Generated monster stats, selected mechanics, pressure metadata, and notices
  are visible enough for manual feel testing.
- A shared preview formatter exists for generated encounter readability.
- Enemy panel and route-preview surfaces can consume generated preview language
  without duplicating formatter logic.
- Representative generated monster preview metadata is covered by focused
  tests or fixtures.
- Relevant Godot and Balance Lab checks pass, or failures are documented with
  follow-up scope.
- `docs/P4_DawnBringer_Overview.md` reflects the final P4M4 status.

## Follow-Ups For P4M5

Use this section to collect items that should move into procedural contract
route generation rather than expanding P4M4.

- Generate seeded contract route graphs with branching paths, start/boss
  anchors, node-type constraints, and deterministic tests.
- Define the first route-node pacing rules: how many fights, where optional
  elites can appear, where forced fights can appear, and what the shortest and
  longest valid paths look like.
- Attach runtime-generated monsters to generated route fight nodes, preserving
  source seed, difficulty, kind, tempo, archetypes, selected mechanics, defense
  overrides, pressure metadata, and generated preview payload.
- Add a seeded contract presentation layer: contracts choose allowed biomes,
  generated routes currently inherit one selected biome for all nodes, and
  generated encounters choose a biome-appropriate monster type for names and
  later visuals.
- Keep mechanical archetypes separate from presentation identity so generated
  defenses and matchups remain reproducible while names and fiction come from
  contract context.
- Use `EncounterPreviewFormatter.contract_map` through
  `ContractRouteNode.route_preview` when comparing generated route nodes.
- Keep detailed `combat` and `debug` preview sections out of the route map but
  preserve them in saved/generated route state for combat UI, reports, and
  tests.
- Decide how generated route graph seeds, generated monster seeds, and resolved
  preview metadata are serialized once procedural routes enter Adventure state.
- Preserve the current authored Gilded Serpent flow while adding generated
  route generation behind a focused test path or isolated switch.
- Keep reward economy, final route pressure tuning, and anti-snowball pacing
  deferred to P4M7 unless P4M5 needs small placeholder rewards to make route
  readability testable.
