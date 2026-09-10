# P5M3: Stat System Foundation Tracker

## Status

Complete.

P5M3 finishes when Project Enigma has a canonical gear stat vocabulary and a
deterministic stat-sheet aggregation pipeline that can express the Phase 5 gear
design. This milestone should turn the P5M2 five-slot item data into usable
player stat sheets before P5M4 weapon damage scaling, P5M5 procedural rarity
rules, P5M7 Adventure reward/shop integration, P5M8 final item presentation,
and P5M11 full validation build on it.

P5M3 also owns the remaining Godot-visible Project Enigma identity cleanup from
the P5M2 audit. Editor-facing and export-facing active project labels should
stop presenting as DawnBringer before the stat-system implementation becomes
the new working baseline.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone document:

- `docs/P5_Gear_Redesign_Overview.md`

Previous milestone tracker:

- `docs/P5M2_Gear_Data_Model_And_Migration_Boundary_Tracker.md`

## Exit Criteria

- Current stat usage has been audited and mapped.
- Godot-visible project and export identity labels identify the project as
  Project Enigma.
- Canonical Basic, Rare, Special, and drawback stat definitions exist in code.
- Slot-specific stat eligibility is encoded and queryable for Weapon, Helm,
  Armor, Trinket, and Charm.
- Stat-sheet aggregation reads equipped gear and supports positive and negative
  stat values.
- Basic and Rare stats stack additively across equipped gear.
- Drawbacks add into the same aggregate stat as positives before final floors
  and caps.
- Final aggregate stat values floor at 0 where appropriate.
- Chance stats cap at 100% with no overflow behavior.
- Percent physical damage, percent elemental damage, attack speed, crit chance,
  crit damage, gold gain, stack increases, and rare chance procs are represented
  in deterministic stat sheets.
- Special effects are represented as binary flags or structured hooks,
  including denial, conversion, ignore, stack doubling, all-stats scaling, and
  stun/slow/interrupt immunity behavior.
- Duplicate Special stats collapse to one active effect while different
  Specials combine.
- `All stats are increased by 20%` applies once at the stat-sheet level after
  aggregation and non-negative floors, does not affect base weapon damage
  ranges, does not multiply fixed Special constants, and respects final caps.
- Existing authored gear, Lucky Coin, retained Legendary resources, save/load,
  Practice Room custom gear, and minimal UI/tool paths tolerate the new stat
  system without pulling forward later-milestone scope.
- Focused regression checks cover the P5M3 stat foundation and preserve the
  relevant P5M2 compatibility guarantees.
- Phase 5 milestone docs are updated with M3 completion notes and remaining
  handoff items for P5M4+.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M3-T1: Audit Current Stat Usage | Complete | Find every active stat path before changing behavior. | Completed 2026-09-03. Audit notes identify current `StatModifier`, `GearItem`, `BuildState`, combat, skill, talent, Lucky Coin, Legendary, Practice Room, UI formatter, save/load, and test dependencies, with each finding classified as Keep, Migrate, Quarantine, Defer, or Open Decision. |
| P5M3-T2: Project Enigma Identity Cleanup | Complete | Close the remaining active DawnBringer-facing Godot/editor/export labels. | Completed 2026-09-03. `project.godot`, export preset names, product/file descriptions, Windows output path, active Balance Lab labels, and active runtime archetype catalog metadata present as Project Enigma; historical/quarantined DawnBringer references remain intentionally archival. |
| P5M3-T3: Define Canonical Stat IDs | Complete | Create one authoritative code source for the Phase 5 stat vocabulary. | Completed 2026-09-03. `StatCatalog` defines Basic, Rare, Special, and compatibility stat IDs with labels, categories, value kinds, floor/cap rules, aggregation behavior, binary/numeric classification, all-stats scaling metadata, fixed Special constants, and legacy `StatModifier.StatType` aliases. |
| P5M3-T4: Implement Slot Stat Eligibility | Complete | Encode the P5M1 slot/category stat pools without implementing the full generator yet. | Completed 2026-09-03. `StatCatalog` exposes slot/category stat pools for Weapon, Helm, Armor, Trinket, and Charm; pool entries carry tunable weights, grouped enemy-denial Specials are expanded into separate IDs, drawback pools derive from eligible Basic entries, and focused validation covers invalid combinations. |
| P5M3-T5: Build Stat Sheet Aggregation | Complete | Reduce equipped gear into a deterministic player stat sheet. | Completed 2026-09-03. `StatSheet` aggregates equipped gear affixes by canonical stat ID, Basic/Rare numeric stats stack additively, drawbacks merge before floors/caps, chance stats cap at 100%, legacy enum-only gear maps through compatibility rules, and `BuildResolver` bridges the sheet into current `PlayerStats`. |
| P5M3-T6: Add Special Effect Aggregation | Complete | Represent Special stats as binary flags or structured effect hooks. | Completed 2026-09-03. `StatSheet` exposes deduplicated Special IDs, source counts, named accessors, fixed Special constants, and a structured summary for enemy denial, ignore, conversion, stack doubling, all-stats flagging, and player immunities; `PlayerStats` carries the same hooks without changing combat behavior yet. |
| P5M3-T7: Apply All-Stats Scaling | Complete | Implement `All stats are increased by 20%` at the stat-sheet level. | Completed 2026-09-03. `StatSheet.finalize()` applies the all-stats multiplier once after additive aggregation and non-negative floors, only to stats marked `scales_with_all_stats`, then reapplies caps; base damage, binary Specials, and fixed Special constants remain unscaled. |
| P5M3-T8: Wire Existing Gear To New Aggregation | Complete | Make current authored gear and tool-created gear feed the new stat system. | Completed 2026-09-04. Generated gear and Practice Room custom gear now stamp canonical stat IDs, save/load canonicalizes runtime affix IDs, formatter paths tolerate canonical Rare/Special IDs, and Lucky Coin, placeholder dagger, retained Legendaries, restored gear, and generated gear resolve through the `StatSheet` path. |
| P5M3-T9: Add Focused Regression Checks | Complete | Prove the M3 foundation works and does not break the M2 boundary. | Completed 2026-09-04. Added a milestone-level foundation regression and reran the focused P5M3, P5M2 compatibility, save/load, Practice Room, gear generator, and Legendary checks that cover stat definitions, slot eligibility, aggregation, drawbacks/floors, chance caps, Specials, all-stats scaling, existing gear, and canonical save/load. |
| P5M3-T10: Update Milestone Docs And Review | Complete | Record M3 completion and hand off cleanly to later milestones. | Completed 2026-09-04. This tracker, `docs/P5_Gear_Redesign_Overview.md`, and `docs/Project_Onboarding_Context.md` record M3 completion, final verification evidence, known non-blockers, resolved implementation choices, and handoff items for P5M4, P5M5, P5M8, and P5M11. |

## P5M3-T1 Audit Steps

P5M3-T1 should produce a concrete stat-system assumption map before any
behavioral rewrite begins.

1. Confirm current workspace identity, active branch, Godot `config/name`, and
   export-facing DawnBringer labels that P5M3-T2 should migrate.
2. Inventory current stat resources and helpers, including `StatModifier`,
   `GearItem`, formatter helpers, gear icon/color helpers, and any stat strings
   embedded in resources.
3. Trace equipped-gear stat access through `BuildState`, including default gear,
   Lucky Coin, inventory/equipment helpers, and save/load-restored gear.
4. Trace combat stat consumers, including current physical damage, elemental or
   poison damage, crit, attack speed, proc, status, mitigation, and Legendary
   effect paths.
5. Trace skill and talent stat sources so M3 can distinguish gear stat-sheet
   ownership from later skill-tree or combat rewrites.
6. Trace Practice Room custom gear and state setup so M3 keeps it compatible
   without pulling forward full P5M11 validation scope.
7. Trace generated gear and reward/shop paths enough to preserve the P5M2
   boundary, while leaving full P5M5/P5M7 generator and Adventure tuning for
   their milestones.
8. Trace UI and tool surfaces that format or summarize stats so M3 can avoid
   breaking minimal presentation while leaving final item-card work for P5M8.
9. Trace current tests that should be extended, rewritten, or retired as M3
   gives stat entries real behavior.
10. Classify every finding as Keep, Migrate, Quarantine, Defer, or Open
   Decision, with the downstream P5M3 task each finding affects.

## P5M3-T1 Audit Findings

Completed 2026-09-03.

Current workspace identity:

- Local path: `F:\Data\Claude Projects\Project-Enigma`.
- Branch: `phase-5-gear-redesign`, tracking `origin/phase-5-gear-redesign`.
- Remote: `https://github.com/thalverson1022/Enigma.git`.
- Worktree note: the repo already contains many Phase 5/P5M2 edits and new
  trackers/tests. Treat them as current baseline unless a later task proves a
  conflict.

| Finding | Evidence | Classification | Downstream |
| --- | --- | --- | --- |
| Godot/editor-facing project name still presents as DawnBringer. | `project/project.godot` has `config/name="Project DawnBringer"`. | Migrate | P5M3-T2 |
| Export-facing active labels still present as DawnBringer. | `project/export_presets.cfg` has `DawnBringer Windows Playtest`, `export/windows/DawnBringer.exe`, `Project DawnBringer`, `DawnBringer Playtest`, and `DawnBringer Web Itch`. | Migrate | P5M3-T2 |
| Active Godot Balance Lab identity already presents as Project Enigma. | `project/scripts/tools/balance_lab.gd` uses `PROJECT_NAME := "Project Enigma"` and generated HTML titles use Project Enigma. | Keep | P5M3-T2, P5M11 |
| Runtime monster archetype catalog still carries DawnBringer metadata. | `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json` has DawnBringer `project` and `library_name`. This catalog is active runtime data, but generated route compatibility may depend on its path/version identity. | Open Decision | P5M3-T2 |
| Browser-lab tooling still carries DawnBringer labels and old paths. | `tools/enemy-lab`, `tools/monster-lab`, `tools/audio-preview`, and quarantined README text reference DawnBringer; some `tools/balance-lab` docs include old Project-DawnBringer commands. | Quarantine | P5M3-T2, P5M11 |
| `StatModifier` is the current shared stat entry shape for class, talent, and gear modifiers. | `project/scripts/resources/stat_modifier.gd` defines legacy `StatType`, `OperationType`, newer `stat_id`, `category`, `is_drawback`, and `display_label`. | Migrate | P5M3-T3, T5 |
| `StatModifier.stat_id` exists but is not authoritative yet. | Generated modifiers stamp `stat_id` from the enum key; Lucky Coin has explicit `crit_chance`; most retained authored gear/talent resources still rely on numeric `stat` enum values. | Migrate | P5M3-T3, T8 |
| Current legacy stat enum covers only the old Phase 4/early Phase 5 vocabulary. | Enum covers attack speed, crit chance/multiplier, poison damage, physical damage, poison stacks, armor reduction, gold rewards, poison tick interval, and two gold-scaling crit stats. It does not cover Phase 5 base damage, base elemental damage, percent elemental damage, rare chance procs, or Specials. | Migrate | P5M3-T3, T6 |
| `GearItem` already has the P5M2 five-slot/tier/source-family foundation. | `project/scripts/resources/gear_item.gd` defines Weapon/Helm/Armor/Trinket/Charm, Crude through Legendary rarity order, Rogue class family, source kind, affixes, triggered effects, unlocked skills, and Legendary shim fields. | Keep | P5M3-T3, T8 |
| Gear generation still uses one global stat pool, not slot/category eligibility. | `GearGenerator.AFFIX_POOL` and `DOWNSIDE_POOL` are global enum lists; `_affixes_for_tier()` rolls Basic/Master/Cursed only. | Migrate | P5M3-T4, T5 |
| Active generated tiers are intentionally limited to Basic, Master, and Cursed. | `GearGenerator.ACTIVE_GENERATED_TIERS` is the P5M2-limited pool; Epic/Chaos/Unique/Legendary remain present in vocabulary but not active procedural output. | Defer | P5M5 |
| Current generated Cursed drawbacks are already marked as negative affixes, but physical damage drawbacks use a multiplier value rather than additive percent-bucket math. | `GearGenerator.CURSED_DOWNSIDE_VALUE` includes negative additive values and `PHYSICAL_DAMAGE: 0.92`; `_make_modifier()` stamps `is_drawback`. | Migrate | P5M3-T5 |
| `BuildResolver.resolve_stats()` is the current stat aggregation chokepoint. | It copies class base stats, applies tree innate modifiers, selected talent modifiers, gear affixes, triggered skill effects, unlocked skill effects, physical-damage-per-gold, and min-cast proc chance. | Migrate | P5M3-T5, T8 |
| Current aggregation writes directly into `PlayerStats`, not a canonical gear stat sheet. | `PlayerStats` exposes old combat-facing fields: attack speed, crit, poison, physical multiplier, bonus stacks, armor reduction, triggered effects, gold multipliers, and Legendary shims. | Migrate | P5M3-T5 |
| Skill and talent stat sources share `StatModifier` with gear and should remain compatible but not become gear-owned. | Talent resources use `stat_modifiers`; subclass trees use `skill_augments`; `BuildResolver.resolve_unlocked_skills()` applies class/tree/talent/gear unlocks. | Keep/Migrate | P5M3-T5, P5M4 |
| Combat consumes `PlayerStats` directly. | `CombatResolver.resolve()` reads min-cast proc chance, attack speed, triggered effects, poison damage, crit chance, crit multiplier, bonus physical damage, physical damage multiplier, bonus armor reduction, gold reward multiplier, and bonus poison stacks. | Migrate | P5M3-T5, P5M6/P5M4 |
| Damage mitigation and enemy defenses are currently enemy-owned runtime fields. | `Monster` owns armor, poison resistance, dodge, crit negation, block, absorb, cleanse, suppress, slow, stun, and interrupt; `DamageCalculator` handles armor/resistance, crit negation, block, and absorb. | Keep/Migrate | P5M3-T6, P5M4 |
| Current Special-like Legendary effects are bespoke fields/resources rather than canonical Specials. | Wyvern uses `POISON_TICK_INTERVAL`; Mithril uses `triggered_skill_effects`; Bandit uses `physical_damage_per_gold`; Umbral uses `unlocked_skills`; Bejeweled uses `min_cast_time_proc_chance`; UI flavor is centralized in `LegendaryCatalog.effect_text()`. | Migrate | P5M3-T6, T8 |
| Lucky Coin is already preserved as fixed authored gear with Crit Chance. | `project/data/gear/lucky_coin.tres` has `id="gear.lucky_coin"`, `tier=BASIC`, `source_kind=FIXED`, and `stat_id="crit_chance"`; post-P5M9 playtest rules make it Trinket/Ring. | Keep | P5M3-T8 |
| Placeholder dagger remains compatibility starter gear. | `project/data/gear/placeholder_dagger.tres` is a Weapon/Dagger with `source_kind=COMPATIBILITY` and one legacy attack-speed affix. | Migrate | P5M3-T8 |
| Save/load already serializes the newer gear/stat metadata for runtime gear. | `SaveSystem._gear_entry_to_data()` writes `stat_id`, `category`, `is_drawback`, `display_label`, source metadata, and five equipped slot fields; `_gear_from_entry()` restores them. | Keep/Migrate | P5M3-T8, T9 |
| Save/load has a deliberate old-gear quarantine boundary. | `_gear_from_save_entry()` canonicalizes known authored gear, drops obsolete runtime gear without `source_kind`, validates slot/tier/source kind, and migrates Lucky Coin out of old trinket saves. | Keep | P5M3-T8, T9 |
| Practice Room uses the same resolver and legacy generator pools. | `TrainingRoomState` creates five custom practice items, changes rarity into Basic/Master/Cursed affix counts, edits enum stat/value fields, can equip retained Legendaries, and resolves fights through `BuildResolver.resolve_stats()`. | Migrate | P5M3-T4, T8, T9 |
| UI stat presentation is split between stat panel lines and item tooltip formatting. | `character_stats_panel.gd` formats `PlayerStats`; `StatModifierFormatter` formats enum modifiers; `CardStyle.gear_tooltip_lines()` and `LegendaryCatalog.tooltip_lines()` format gear affixes/effects. | Migrate | P5M3-T8, P5M8 |
| Reward and shop paths materialize generated gear through `GearGenerator` and preserve deterministic signatures using enum stat/operation/value. | `BuildState` creates shop offers and reward choices via `GearGenerator.generate()`, samples Legendaries from `LegendaryCatalog`, excludes owned Legendaries from shops, and signatures compare legacy affix fields. | Migrate | P5M3-T8, P5M5, P5M7 |
| Existing tests heavily depend on `BuildResolver`, `PlayerStats`, legacy enum affixes, five-slot compatibility, Lucky Coin, save/load, Practice Room gear editing, Legendary mechanics, and UI tooltip text. | Relevant suites include `gear_generator_test.gd`, `inventory_model_test.gd`, `legendary_reward_test.gd`, `legendary_mechanics_test.gd`, `save_load_test.gd`, `training_room_gear_editor_test.gd`, `p5m2_*`, combat/recap/HUD tests, and route/shop UI tests. | Migrate | P5M3-T9 |

T1 implementation guidance:

- Add the canonical stat-definition layer alongside current resources first,
  then migrate resolver/generator/UI surfaces onto `stat_id` gradually.
- Keep `PlayerStats` as the combat compatibility output during P5M3 unless
  replacing it becomes clearly cheaper than adapting it; P5M4 can own deeper
  combat damage-order rewrites.
- Treat Skill/Talent modifiers as resolver inputs, not gear stat definitions,
  so P5M3 does not quietly become a skill-tree redesign.
- Keep `SaveSystem`'s P5M2 quarantine behavior and extend it only as needed
  for new canonical stat IDs and Special hooks.
- Leave full procedural rarity expansion, reward/shop tuning, final item-card
  presentation, and full Practice Room/Balance Lab validation to their later
  milestones.

## P5M3-T2 Identity Cleanup Notes

Completed 2026-09-03.

Changed active Godot/editor/export identity:

- `project/project.godot`: `config/name` now presents as `Project Enigma`.
- Local Godot Project Manager registration was added on 2026-09-04:
  `%APPDATA%\Godot\projects.cfg` now includes
  `F:/Data/Claude Projects/Project-Enigma/project`, and
  `%APPDATA%\Godot\recent_dirs` includes the same project directory for recent
  browsing.
- `project/export_presets.cfg`: Windows preset now presents as
  `Project Enigma Windows Playtest`.
- `project/export_presets.cfg`: Windows export path now writes to
  `export/windows/ProjectEnigma.exe`.
- `project/export_presets.cfg`: Windows product metadata now uses
  `Project Enigma` and `Project Enigma Playtest`.
- `project/export_presets.cfg`: Web preset now presents as
  `Project Enigma Web Itch`.

Changed active runtime catalog display metadata while keeping compatibility
path/version identity:

- `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json`:
  `project` is now `Project Enigma`.
- `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json`:
  `library_name` is now `Project Enigma Archetypes v1`.
- The filename remains `dawnbringer_archetypes_v1.json` because
  `RuntimeArchetypeLibraryLoader.DEFAULT_LIBRARY_PATHS` currently uses that
  path as the active bundled catalog location.

Intentional leftovers:

- Phase 4 history and closeout docs may continue to mention DawnBringer.
- Quarantined or legacy browser-lab tooling under `tools/` may continue to
  mention DawnBringer until a later tool-specific pass updates or retires
  those surfaces.

Verification:

- Text scan across active project identity surfaces found no remaining
  `DawnBringer`, `Project DawnBringer`, `DawnBringer.exe`,
  `DawnBringer Windows`, or `DawnBringer Web` references in
  `project/project.godot`, `project/export_presets.cfg`, `project/scripts`,
  `project/scenes`, or `project/data`.
- Positive identity scan confirmed `Project Enigma` labels in
  `project/project.godot`, `project/export_presets.cfg`,
  `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json`, and
  `project/scripts/tools/balance_lab.gd`.
- Focused check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/runtime_archetype_library_loader_test.gd`.
  It emitted the accepted Godot ObjectDB/resource cleanup warnings at process
  exit.

## P5M3-T3 Canonical Stat ID Notes

Completed 2026-09-03.

Code-home decision:

- Canonical stat definitions live in
  `project/scripts/systems/stat_catalog.gd`.
- The catalog is a static `RefCounted` helper rather than a resource-backed
  data file for this milestone, because P5M3 needs deterministic metadata and
  query helpers before P5M5 expands procedural generation.
- Existing `StatModifier` and `GearItem` resources remain the data carrier for
  current gear, talents, save/load, and UI compatibility.

Implemented vocabulary:

- Basic stat IDs: `base_damage`, `percent_physical_damage`,
  `increased_attack_speed`, `crit_chance`, `crit_damage`,
  `base_elemental_damage`, `percent_elemental_damage`,
  `increased_shred_stacks`, `increased_decay_stacks`,
  `increased_elemental_stacks`, and `increased_gold`.
- Rare stat IDs: `chance_for_retrigger`, `chance_to_shred`,
  `chance_to_decay`, and `crit_applies_element`.
- Special stat IDs: enemy dodge/block/absorb/suppress/cleanse denial,
  armor-ignore/no-shred, resistance-ignore/physical-penalty, stack doubling,
  physical conversion, magical conversion, all-stats increase, and
  stun/slow/interrupt immunity.
- Compatibility stat IDs: legacy poison tick interval, crit chance per stolen
  gold, and crit damage per current gold.

Implemented metadata and helpers:

- Definitions include label, category, value kind, aggregation behavior,
  floor, cap, numeric/binary classification, drawback eligibility, and
  all-stats scaling participation.
- `base_damage` explicitly opts out of all-stats scaling so T7 can preserve
  the weapon-damage exception.
- Chance stats expose a 100% cap through `cap_for()`.
- Basic stats allow drawbacks; Rare, Special, and compatibility stats do not.
- Special hooks aggregate as binary effects. `All stats are increased by 20%`
  carries a fixed `stat_sheet_multiplier` of `1.2`; the resistance-ignore
  Special carries a fixed `physical_damage_penalty` of `0.5`.
- Query helpers include `has_stat()`, `definition()`,
  `canonicalize_stat_id()`, `canonical_id_for_modifier()`,
  `legacy_stat_id()`, `ids_for_category()`, `label_for()`,
  `category_for()`, `value_kind_for()`, `aggregation_for()`, `floor_for()`,
  `cap_for()`, `is_chance_stat()`, `is_special()`,
  `is_drawback_allowed()`, `is_numeric()`, `is_binary()`, and
  `scales_with_all_stats()`.

Compatibility behavior:

- `StatCatalog.canonical_id_for_modifier()` maps old enum-only modifiers to
  canonical IDs.
- Old generated `stat_id` aliases such as `physical_damage`,
  `poison_damage`, `crit_multiplier`, `attack_speed`,
  `poison_stacks_applied`, `armor_reduction`, and `gold_rewards` resolve to
  canonical Phase 5 IDs.
- Lucky Coin's existing `crit_chance` `stat_id` resolves directly to the
  canonical Crit Chance ID.

Verification:

- Focused check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_stat_catalog_test.gd`.
- Compatibility regression passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`.
- Both commands emitted the accepted Godot ObjectDB/resource cleanup warnings at
  process exit.

## P5M3-T4 Slot Stat Eligibility Notes

Completed 2026-09-03.

Implemented eligibility layer:

- Slot/category stat pools live in
  `project/scripts/systems/stat_catalog.gd` as `SLOT_CATEGORY_POOLS`.
- Each pool entry is a dictionary with `stat_id` and `weight`, so later tuning
  can lower weights or set a valid entry to weight `0` without changing the
  public query shape.
- Weapon, Helm, Armor, Trinket, and Charm each expose Basic, Rare, and Special
  pools from `docs/New_Gear_Overview.md`.
- The grouped enemy-denial Special is represented as five independent IDs:
  dodge, block, absorb, suppress, and cleanse denial.
- Drawback eligibility is queryable per slot and derives from that slot's Basic
  pool filtered through the canonical `drawback_allowed` metadata. Rare,
  Special, and compatibility stats do not enter drawback pools.

Implemented helpers:

- `pool_for_slot()` returns normalized pool entries for a slot/category.
- `stat_ids_for_slot()` returns only canonical IDs for a slot/category.
- `is_stat_valid_for_slot()` answers whether a stat belongs to a slot/category
  even if a later weight disables it.
- `is_stat_enabled_for_slot()` and `weight_for_slot()` expose the future tuning
  weight behavior.
- `drawback_pool_for_slot()` and `drawback_stat_ids_for_slot()` expose the
  Cursed/drawback-safe subset without implementing generator behavior yet.

Scope boundary:

- `GearGenerator` still uses the existing P5M2-limited generation behavior.
  Full procedural rarity and slot-aware rolling remain P5M5 scope.

Verification:

- Focused check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_slot_stat_eligibility_test.gd`.
- Catalog regression passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_stat_catalog_test.gd`.
- Compatibility regression passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`.
- All commands emitted the accepted Godot ObjectDB/resource cleanup warnings at
  process exit.

## P5M3-T5 Stat Sheet Aggregation Notes

Completed 2026-09-03.

Implemented stat sheet:

- Added `project/scripts/resources/stat_sheet.gd` as the deterministic
  canonical gear-stat aggregate.
- `StatSheet` stores raw aggregate values, finalized floor/cap values, modifier
  counts, and a deduplicated list of binary Special IDs encountered on gear.
- Equipped gear affixes resolve through `StatCatalog.canonical_id_for_modifier()`
  before aggregation, so explicit Phase 5 `stat_id` values and old enum-only
  modifiers share the same canonical buckets.
- Numeric Basic and Rare stats stack additively across all supplied gear.
- Drawbacks add into the same raw aggregate as positive modifiers before final
  floors and caps.
- Final numeric values use catalog floors and caps. Chance stats such as Crit
  Chance and Rare proc chances cap at `1.0`.

Implemented accessors and bridge:

- `StatSheet` exposes named accessors for Phase 5 numeric buckets: base damage,
  percent physical damage, attack speed, crit chance, crit damage, base/percent
  elemental damage, Shred/Decay/elemental stack increases, gold increase, and
  Rare proc chances.
- `BuildResolver.resolve_gear_stat_sheet()` returns the canonical gear stat
  sheet for the supplied equipped gear.
- `BuildResolver.resolve_stats()` now applies class/tree/talent modifiers as
  before, then applies equipped gear affixes through `StatSheet`, preserving the
  current `PlayerStats` compatibility surface for combat and rewards.

Compatibility behavior:

- Legacy physical-damage `MULTIPLY` gear modifiers normalize to additive
  percent physical damage deltas. For example, `1.2` contributes `+0.2`, and a
  Cursed `0.92` drawback contributes `-0.08` before floors.
- Legacy poison damage and poison tick interval enum-only `MULTIPLY` modifiers
  retain their current multiplier semantics when bridged into `PlayerStats`,
  preserving authored Legendary behavior such as Wyvern Kriss.
- Existing Legendary side channels on `GearItem`, including triggered skill
  effects, physical damage per gold, min-cast proc chance, and unlocked skills,
  remain outside T5's numeric stat-sheet rewrite.

Scope boundary:

- T5 records binary Special IDs but does not implement duplicate-special
  behavior, enemy-denial hooks, conversion hooks, or all-stats scaling. Those
  remain P5M3-T6 and P5M3-T7.
- `percent_elemental_damage`, Decay stack increases, and Rare proc chances are
  exposed on `StatSheet`; deeper combat consumption remains P5M4/P5M6 scope.

Verification:

- Focused check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_stat_sheet_aggregation_test.gd`.
- Catalog regression passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_stat_catalog_test.gd`.
- Slot eligibility regression passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_slot_stat_eligibility_test.gd`.
- P5M2 gear data compatibility regression passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`.
- Gear generator, Legendary reward, and Practice Room gear editor regressions
  passed:
  `res://tests/gear_generator_test.gd`,
  `res://tests/legendary_reward_test.gd`, and
  `res://tests/training_room_gear_editor_test.gd`.
- All commands emitted the accepted Godot ObjectDB/resource cleanup warnings at
  process exit.

## P5M3-T6 Special Effect Aggregation Notes

Completed 2026-09-03.

Implemented Special aggregation:

- `StatSheet` now treats binary Special stat IDs as a deduplicated active set.
- Duplicate copies of the same Special collapse to one active effect while
  `modifier_counts` preserves how many sources contributed that Special.
- Different Specials combine freely in the same sheet.
- `StatSheet.active_specials()` returns the canonical active Special IDs.
- `StatSheet.special_effect_summary()` returns structured hooks for enemy
  denial, damage conversion, ignore effects, stack doubling, all-stats flagging,
  and player immunities.

Implemented named Special accessors:

- Enemy denial: `denies_enemy_dodge()`, `denies_enemy_block()`,
  `denies_enemy_absorb()`, `denies_enemy_suppress()`, and
  `denies_enemy_cleanse()`.
- Ignore hooks: `ignores_armor_without_shred()` and
  `ignores_resistance_with_physical_penalty()`.
- Fixed constants: `physical_damage_penalty()` exposes `0.5` when the
  ignore-resistance Special is active; `all_stats_multiplier()` exposes `1.2`
  when the all-stats Special is active.
- Stack and conversion hooks: `doubles_applied_stacks()`,
  `converts_damage_to_physical()`, and `converts_damage_to_magical()`.
- Player immunities: `immune_to_stun()`, `immune_to_slow()`, and
  `immune_to_interrupt()`.
- All-stats flag: `has_all_stats_increased()`.

Compatibility behavior:

- `PlayerStats` now carries `special_stat_ids` and `special_effects` copied
  from the resolved gear `StatSheet`.
- Existing combat behavior is unchanged in T6. The new fields are hooks for
  later combat and presentation work rather than active combat rewrites.
- Numeric aggregation from T5 is unchanged: binary Specials do not create
  numeric stat values.

Scope boundary:

- T6 exposes the all-stats flag and fixed multiplier but does not apply the
  multiplier. Actual stat-sheet scaling remains P5M3-T7.
- Damage conversion, enemy defense bypass, stack-doubling combat application,
  and player immunity combat behavior remain later combat-system work.

Verification:

- Focused check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_special_effect_aggregation_test.gd`.
- P5M3 regressions passed:
  `res://tests/p5m3_stat_sheet_aggregation_test.gd`,
  `res://tests/p5m3_slot_stat_eligibility_test.gd`, and
  `res://tests/p5m3_stat_catalog_test.gd`.
- Compatibility regressions passed:
  `res://tests/legendary_reward_test.gd`,
  `res://tests/p5m2_gear_data_shape_test.gd`, and
  `res://tests/gear_generator_test.gd`.
- All commands emitted the accepted Godot ObjectDB/resource cleanup warnings at
  process exit.

## P5M3-T7 All-Stats Scaling Notes

Completed 2026-09-03.

Implemented all-stats scaling:

- `StatSheet.finalize()` now applies `All stats are increased by 20%` as a
  single stat-sheet multiplier when `all_stats_increased` is active.
- Scaling happens after raw additive aggregation and non-negative floors.
- Final caps are applied after scaling, so chance stats still cap at `1.0`.
- Scaling only affects canonical stats whose catalog metadata has
  `scales_with_all_stats = true`.
- `base_damage` remains unscaled, preserving the weapon damage range exception.
- Duplicate `all_stats_increased` Specials still collapse to one active effect,
  so the multiplier applies once.

Compatibility behavior:

- `StatSheet.all_stats_multiplier()` and `special_effect_summary()` still
  expose the fixed `1.2` constant for downstream consumers.
- Fixed Special constants such as the ignore-resistance physical damage penalty
  remain unchanged.
- Binary Special flags remain out of numeric values.
- `BuildResolver.resolve_stats()` uses the finalized, scaled gear sheet when
  bridging eligible numeric values into `PlayerStats`.

Scope boundary:

- T7 applies stat-sheet scaling only. Damage conversion, enemy defense bypass,
  stack-doubling combat application, and player immunity combat behavior remain
  later combat-system work.
- Existing authored gear wiring and broader UI/save/load presentation checks
  remain P5M3-T8 and P5M3-T9.

Verification:

- Focused check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_all_stats_scaling_test.gd`.
- P5M3 regressions passed:
  `res://tests/p5m3_special_effect_aggregation_test.gd`,
  `res://tests/p5m3_stat_sheet_aggregation_test.gd`,
  `res://tests/p5m3_slot_stat_eligibility_test.gd`, and
  `res://tests/p5m3_stat_catalog_test.gd`.
- Compatibility regressions passed:
  `res://tests/legendary_reward_test.gd`,
  `res://tests/gear_generator_test.gd`, and
  `res://tests/p5m2_gear_data_shape_test.gd`.
- All commands emitted the accepted Godot ObjectDB/resource cleanup warnings at
  process exit.

## P5M3-T8 Existing Gear Wiring Notes

Completed 2026-09-04.

Implemented current gear wiring:

- `GearGenerator._make_modifier()` now stamps generated affixes with canonical
  stat IDs through `StatCatalog.legacy_stat_id()`.
- `TrainingRoomState` now stamps Practice Room custom gear affixes with the
  same canonical IDs during rarity changes and manual stat changes.
- `SaveSystem._gear_entry_to_data()` writes canonical affix `stat_id` values
  for runtime gear.
- `SaveSystem._gear_from_entry()` canonicalizes restored runtime affix
  `stat_id` values, so older aliases such as `physical_damage` load into the
  current Phase 5 ID.
- `StatModifierFormatter` tolerates canonical IDs and binary Specials while
  preserving enum-only legacy wording for old talent/class modifiers.

Compatibility behavior:

- Lucky Coin continues to resolve as a fixed Basic Trinket/Ring with canonical
  `crit_chance`.
- Placeholder dagger continues to resolve through the current
  `BuildResolver`/`StatSheet` bridge.
- Retained Legendary resources continue to resolve through compatibility
  handling for enum-only affixes and side channels such as physical damage per
  gold, triggered skills, min-cast proc chance, and unlocked skills.
- Generated gear and Practice Room custom gear keep the P5M2 Basic/Master/
  Cursed behavior; full Phase 5 procedural rarity expansion remains P5M5.

Scope boundary:

- T8 makes existing gear sources feed the new stat foundation, but does not
  implement final item-card presentation, full slot-aware procedural rolling,
  or combat consumption for the new Special hooks.
- Broader regression consolidation was completed in P5M3-T9, and
  closeout/handoff docs were completed in P5M3-T10.

Verification:

- Focused check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m3_existing_gear_wiring_test.gd`.
- P5M3 regressions passed:
  `res://tests/p5m3_all_stats_scaling_test.gd`,
  `res://tests/p5m3_special_effect_aggregation_test.gd`,
  `res://tests/p5m3_stat_sheet_aggregation_test.gd`,
  `res://tests/p5m3_slot_stat_eligibility_test.gd`, and
  `res://tests/p5m3_stat_catalog_test.gd`.
- Compatibility regressions passed:
  `res://tests/save_load_test.gd`,
  `res://tests/training_room_gear_editor_test.gd`,
  `res://tests/gear_generator_test.gd`,
  `res://tests/legendary_reward_test.gd`,
  `res://tests/p5m2_save_load_boundary_test.gd`, and
  `res://tests/p5m2_gear_data_shape_test.gd`.
- All commands emitted the accepted Godot ObjectDB/resource cleanup warnings at
  process exit.

## P5M3-T9 Focused Regression Notes

Completed 2026-09-04.

Added milestone-level regression:

- Added `project/tests/p5m3_foundation_regression_test.gd`.
- The test exercises canonical stat IDs, slot eligibility, equipped gear
  aggregation, drawbacks, floors, chance caps, duplicate Special collapse,
  combined Specials, all-stats scaling, Lucky Coin compatibility, `PlayerStats`
  bridging, and save/load canonicalization in one end-to-end foundation check.

Regression coverage confirmed:

- Focused P5M3 tests cover:
  `p5m3_stat_catalog_test.gd`,
  `p5m3_slot_stat_eligibility_test.gd`,
  `p5m3_stat_sheet_aggregation_test.gd`,
  `p5m3_special_effect_aggregation_test.gd`,
  `p5m3_all_stats_scaling_test.gd`,
  `p5m3_existing_gear_wiring_test.gd`, and
  `p5m3_foundation_regression_test.gd`.
- P5M2 compatibility tests cover:
  `p5m2_gear_data_shape_test.gd`,
  `p5m2_save_load_boundary_test.gd`,
  `p5m2_old_gear_quarantine_test.gd`, and
  `p5m2_lucky_coin_charm_test.gd`.
- Touched-system regressions cover:
  `gear_generator_test.gd`,
  `save_load_test.gd`,
  `training_room_gear_editor_test.gd`, and
  `legendary_reward_test.gd`.

Verification:

- All focused P5M3 checks passed:
  `res://tests/p5m3_stat_catalog_test.gd`,
  `res://tests/p5m3_slot_stat_eligibility_test.gd`,
  `res://tests/p5m3_stat_sheet_aggregation_test.gd`,
  `res://tests/p5m3_special_effect_aggregation_test.gd`,
  `res://tests/p5m3_all_stats_scaling_test.gd`,
  `res://tests/p5m3_existing_gear_wiring_test.gd`, and
  `res://tests/p5m3_foundation_regression_test.gd`.
- All selected P5M2 compatibility checks passed:
  `res://tests/p5m2_gear_data_shape_test.gd`,
  `res://tests/p5m2_save_load_boundary_test.gd`,
  `res://tests/p5m2_old_gear_quarantine_test.gd`, and
  `res://tests/p5m2_lucky_coin_charm_test.gd`.
- All touched-system regressions passed:
  `res://tests/gear_generator_test.gd`,
  `res://tests/save_load_test.gd`,
  `res://tests/training_room_gear_editor_test.gd`, and
  `res://tests/legendary_reward_test.gd`.
- `save_load_test.gd` intentionally emits a JSON parse error while checking
  corrupt-save handling; the test still exits successfully.
- All Godot commands emitted the accepted ObjectDB/resource cleanup warnings at
  process exit.

## P5M3-T10 Closeout Notes

Completed 2026-09-04.

P5M3 is complete. Project Enigma now has a canonical gear stat vocabulary,
slot/category eligibility rules, deterministic stat-sheet aggregation,
deduplicated Special-effect hooks, all-stats scaling, canonical save/load
bridging, and focused regression coverage over the completed M3 foundation.

Final closeout verification reran:

- `res://tests/p5m3_foundation_regression_test.gd`.

Known non-blockers:

- Godot headless test runs still emit accepted ObjectDB/resource cleanup
  warnings at process exit.
- `save_load_test.gd` intentionally logs a corrupt JSON parse error while
  verifying corrupt-save handling; this remains expected when that suite is
  run.
- Active generated gear remains limited to the P5M2 Basic, Master, and Cursed
  surface until P5M5 expands procedural rarity/stat rolling.
- P5M3 exposes Special hooks and stat buckets, but combat application and
  damage-order behavior remain P5M4/P5M6 scope.
- Final player-facing item card presentation remains P5M8 scope.
- P5M9 has since supplied generated Rogue Hood and Doublet sprites.
- Legendary catalog expansion and final fixed Legendary packages remain
  P5M10 scope.
- Full Practice Room and Balance Lab validation remains P5M11 scope.

## Status Definitions

- `Ready`: The task can be worked now.
- `Blocked`: The task needs a prior task output, implementation decision, or
  design clarification before it can be completed.
- `In Progress`: The task is actively being audited, edited, implemented, or
  reviewed.
- `Complete`: The task output has been added, verified, and recorded.

## Current Known Decisions

- P5M3 owns the stat-system foundation, not full final balance.
- P5M3 starts with Godot-visible Project Enigma identity cleanup before broad
  stat implementation.
- P5M3 should build on the existing `GearItem` and `StatModifier` resources
  extended during P5M2 unless the audit reveals a strong reason to split a new
  stat definition resource or helper.
- P5M3 should create a canonical stat-definition layer rather than continuing
  to rely on scattered stat strings.
- P5M3 should encode slot/category eligibility from `docs/New_Gear_Overview.md`
  but should not implement full procedural rarity/stat rolling; P5M5 owns that.
- P5M3 should aggregate equipped stats into a deterministic stat sheet that
  later systems can query.
- Basic and Rare stats stack additively across equipped items unless explicitly
  stated otherwise.
- Drawbacks add into the same aggregate stat as positives before final floors
  and caps.
- Final aggregate stat values floor at 0 where appropriate and cannot become
  negative.
- Chance stats cap at 100% with no overflow behavior.
- `All stats are increased by 20%` applies once to the final non-negative stat
  sheet and does not affect base weapon damage ranges or fixed Special
  constants.
- Duplicate copies of the same Special are allowed across equipped items but do
  not stack. Different Special stats combine.
- Enemy-denial Specials cover dodge, block, absorb, suppress, and cleanse.
- Player-immunity Specials cover stun, slow, and interrupt as separate binary
  effects.
- Damage conversion, armor/resistance ignore, mitigation order, weapon damage
  rolls, and Rogue physical skill scaling are fully resolved in P5M4 combat
  work; P5M3 should expose the flags and numeric buckets those systems need.
- Procedural rarity rules, Cursed/Chaos rolling behavior, Unique Special rolls,
  and Legendary catalog selection remain P5M5/P5M10 scope.
- Final player-facing item card presentation remains P5M8 scope, and Hood/
  Doublet sprites have since been supplied by P5M9.
- Full Practice Room and Balance Lab validation remains P5M11 scope, though M3
  should add focused tests for its own stat foundation.

## Resolved Implementation Questions

- Canonical stat definitions live in `StatCatalog`, a dedicated static script
  under `project/scripts/systems/`.
- Equipped gear resolves through `StatSheet`, a dedicated script class with
  raw/final dictionaries plus named accessors for current and later consumers.
- M3 bridges stat-sheet output into current `PlayerStats` through
  `BuildResolver` while leaving deeper combat rewrites and damage-order changes
  to P5M4/P5M6.
- M3 updates minimal formatter behavior for canonical Rare/Special IDs while
  leaving final item-card presentation and richer player-facing stat language
  to P5M8.

## Remaining Handoff Questions

- P5M4 should decide the exact combat consumption points for conversion,
  armor/resistance ignore, base weapon rolls, physical skill scaling, and final
  rounding order.
- P5M5 should decide final rarity odds, depth scaling, generated stat counts,
  Unique Special frequency, and Cursed/Chaos drawback tuning.
- P5M8 should decide the final item-card layout and player-facing stat wording
  once later milestones have completed the combat and generator behavior.
- P5M11 should decide the final Balance Lab and Practice Room validation matrix
  after P5M4-P5M10 have landed.

## Completion Notes

P5M3 is complete. P5M4 can begin from the completed stat foundation, using
`StatCatalog`, `StatSheet`, and the current `PlayerStats` bridge as the handoff
surface for weapon damage scaling and combat-order work.
