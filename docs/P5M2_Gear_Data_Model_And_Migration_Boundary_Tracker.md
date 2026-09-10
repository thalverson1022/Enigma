# P5M2: Gear Data Model And Migration Boundary Tracker

## Status

Complete.

P5M2 finishes when the old gear assumptions have been replaced by the new
five-slot Phase 5 gear foundation. This milestone should establish the item data
shape, universal equipment slots, Rogue display families, Lucky Coin handling,
Legendary identity boundary, and save/load compatibility boundary before later
milestones implement full stat effects, procedural generation, weapon damage
scaling, shop simulation, Adventure tuning, and final item presentation.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone document:

- `docs/P5_Gear_Redesign_Overview.md`

## Exit Criteria

- Current gear implementation has been audited and mapped.
- The new Phase 5 gear data shape exists and can represent rarity, slot, item
  family, stat entries, generated/fixed identity, and source metadata.
- Equipment supports five universal slots: Weapon, Helm, Armor, Trinket, and
  Charm.
- Rogue non-Legendary gear displays as Dagger, Hood, Doublet, Ring, and
  Necklace according to slot.
- Existing named Rogue Legendaries remain unique Weapon-slot items rather than
  generic Dagger display items.
- Old active gear assumptions are removed, migrated, or explicitly quarantined.
- Lucky Coin is retained as fixed authored gear with +5% Crit Chance and remains
  excluded from normal generated/shop pools.
- Save/load writes the new gear structure and handles old or partial save data
  safely.
- Minimal UI, Practice Room, and debug/test surfaces tolerate the new five-slot
  model.
- Focused regression checks prove the new data model boundary works.
- Phase 5 milestone docs are updated with M2 completion notes and remaining
  handoff items for P5M3+.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M2-T1: Audit Current Gear Implementation | Complete | Find every active old gear assumption before changing the data model. | Completed 2026-09-03. Audit findings recorded below. T2, T3, and T6 may proceed from the mapped old gear assumptions. |
| P5M2-T2: Define New Gear Data Shape | Complete | Create the canonical Phase 5 item structure without implementing every stat effect yet. | Completed 2026-09-03. Extended `GearItem` with Phase 5 slots, rarity vocabulary, Rogue family identity, source metadata, and deterministic metadata; extended `StatModifier` with stat-entry metadata; preserved old active enum values for compatibility; save/load now round-trips new runtime gear fields. |
| P5M2-T3: Implement Five Equipment Slots | Complete | Replace old slot assumptions with Weapon, Helm, Armor, Trinket, and Charm. | Completed 2026-09-03. Adventure state, Practice Room state, generated slot pools, save/load fields, combat gear panel, and simple shop equipment rows now support Weapon, Helm, Armor, Trinket, and Charm. |
| P5M2-T4: Add Rogue Item Family Mapping | Complete | Separate universal slot rules from Rogue-flavored item display identity. | Completed 2026-09-03. Canonical helpers now distinguish universal slot labels from Rogue item-family names; generated Rogue gear, Practice Room items, tooltips, and runtime save/load fallback use the mapping while named Legendaries retain unique display identity. |
| P5M2-T5: Preserve Lucky Coin | Complete | Carry Lucky Coin through the gear overhaul as the scripted first gear reward. | Completed 2026-09-03 and updated after playtesting. Lucky Coin is now a fixed Basic Trinket/Ring with +5% Crit Chance, still awarded by Drunk Buddy, still not Legendary, and still excluded from generated/shop pools. |
| P5M2-T6: Remove Or Quarantine Old Gear | Complete | Prevent old gear definitions, slots, stat names, and generation assumptions from remaining active accidentally. | Completed 2026-09-03. Active five-slot generation uses the canonical slot order; the remaining Basic/Master/Cursed generated-tier subset and Practice Room custom rarity subset are explicitly named as M2-limited compatibility boundaries; active Balance Lab metadata uses Project Enigma; old browser-lab docs are quarantined. |
| P5M2-T7: Define And Implement Save/Load Boundary | Complete | Make the gear schema transition safe for new, old, and partial saves. | Completed 2026-09-03. New saves write five equipped gear fields; old and partial saves load without Helm/Armor fields; Lucky Coin and retained authored gear migrate to canonical resources; obsolete old runtime-generated gear is quarantined from active inventory, shop, reward, and equipped surfaces. |
| P5M2-T8: Update Minimal UI And Tool Surfaces | Complete | Keep inventory, equipment, Practice Room, and debug/test paths functional enough to verify M2. | Completed 2026-09-03. Minimal gear UI/tool surfaces now use safe Phase 5 tier labels/colors, five-slot-safe icon fallbacks, Rogue family display names, and generated-route reward metadata; final item presentation remains P5M8/P5M9 scope. |
| P5M2-T9: Add Focused Regression Checks | Complete | Prove the data model and migration boundary are stable before M3 builds on them. | Completed 2026-09-03. The final M2 regression bundle is recorded below; focused checks now cover data shape, five-slot equipment, Rogue family mapping, Lucky Coin migration, old gear quarantine, save/load boundary, minimal UI/tool surfaces, and all-rarity route reward visuals. |
| P5M2-T10: Update Milestone Docs And Review | Complete | Record the completed M2 boundary and hand off cleanly to P5M3. | Completed 2026-09-03. This tracker and `docs/P5_Gear_Redesign_Overview.md` now record the P5M2 closeout, compatibility decisions, verification evidence, and remaining P5M3+ handoff items. |

## P5M2-T1 Audit Steps

P5M2-T1 should produce a concrete old-gear assumption map before any data model
rewrite begins.

1. Confirm Project Enigma workspace identity, including Git remote, active
   branch, local path, Godot `config/name`, and export product labels. The repo
   should remain the separate Enigma workspace, while old DawnBringer-facing
   labels should be renamed or explicitly tracked.
2. Inventory current gear resources, item scripts, stat modifier scripts,
   catalogs, icon helpers, formatter helpers, and Legendary resources.
3. Trace equipment and inventory state through `BuildState`, including default
   gear, equipped fields, inventory arrays, grant/equip/unequip behavior, reward
   claims, and any old three-slot assumptions.
4. Trace generated, authored, fixed, and shop reward paths, including Lucky Coin,
   Gilded Serpent rewards, generated route reward metadata, and integer slot
   assumptions.
5. Trace save/load fields and compatibility behavior for equipped gear,
   inventory gear, missing fields, partial saves, and obsolete old gear data.
6. Trace minimal UI surfaces that must tolerate M2, including inventory,
   equipment, combat rewards, route reward previews, shop offers, and item
   descriptions.
7. Trace Practice Room, Balance Lab, Shop Lab, debug tools, and tests for
   hardcoded old slots, old rarity tiers, old stat names, and old Rogue gear
   references.
8. Trace hardcoded Rogue item identity and special cases, including Dagger,
   Ring, Necklace, Lucky Coin, and retained Rogue Legendaries.
9. Classify every finding as Keep, Migrate, Quarantine, Delete/Retire, or Open
   Decision, with the downstream P5M2 task each finding affects.
10. Record the completed audit findings in this tracker, then mark P5M2-T1
   complete only when P5M2-T2, P5M2-T3, and P5M2-T6 are unblocked.

## P5M2-T1 Audit Findings

Completed 2026-09-03.

### Workspace Identity

| Finding | Evidence | Disposition | Affects |
| --- | --- | --- | --- |
| Project Enigma is a separate workspace and repo, not the old DawnBringer closeout workspace. | Local path `F:\Data\Claude Projects\Project-Enigma`; branch `phase-5-gear-redesign`; remote `https://github.com/thalverson1022/Enigma.git`. | Keep | T2+ implementation should continue here. |
| Godot/editor/export labels still say DawnBringer. | `project/project.godot` has `config/name="Project DawnBringer"`; `project/export_presets.cfg` has DawnBringer preset, product, file description, and export path labels. | Migrate | Rename or explicitly defer project-facing labels before final M2 closeout. |
| Tooling docs and generated reports still contain DawnBringer names and some old local paths. | `tools/balance-lab/README.md`, `tools/shop-lab/README.md`, `tools/*/index.html`, `project/scripts/tools/balance_lab.gd`, generated balance reports, Monster Lab bridge fixtures/catalog metadata. | Migrate/Quarantine | Rename active tooling labels when touched; quarantine generated report artifacts unless regenerated. |

### Data Model And Resources

| Finding | Evidence | Disposition | Affects |
| --- | --- | --- | --- |
| `GearItem` supports only three slots: Weapon, Trinket, Charm. | `project/scripts/resources/gear_item.gd` `SlotType` enum. | Migrate | T2, T3 |
| `GearItem` supports only Basic, Master, Cursed, Legendary tiers. | `project/scripts/resources/gear_item.gd` `Tier` enum. | Migrate | T2, T5 |
| Gear resources are authored as seven `.tres` files: placeholder dagger, Lucky Coin, and five Rogue Legendaries. | `project/data/gear/*.tres`. | Migrate/Keep | T2, T5, T6, T10 |
| Lucky Coin was a Basic Trinket with +5% Crit Chance before the Phase 5 migration. | Pre-T5 `project/data/gear/lucky_coin.tres` used `slot = 1`, `tier = 0`, Crit Chance affix. | Migrated | T5 |
| Retained Rogue Legendaries are already authored as Weapon-slot Legendary items with unique names/effects. | `project/data/gear/wyvern_kriss.tres`, `mithril_karambit.tres`, `bandit_blade.tres`, `umbral_stiletto.tres`, `bejeweled_push_dagger.tres`; `project/scripts/systems/legendary_catalog.gd`. | Keep/Migrate | T2, T4, T10 |
| Current stat modifiers are a flat old affix enum and operation/value triple. | `project/scripts/resources/stat_modifier.gd`. | Migrate | T2, T3 |
| Current stat effects include old direct fields on `GearItem` for Legendary behavior. | `triggered_skill_effects`, `unlocked_skills`, `physical_damage_per_gold`, `min_cast_time_proc_chance` in `gear_item.gd`. | Keep/Quarantine | T2, T3, T10 |

### Generation, Rewards, And Shop

| Finding | Evidence | Disposition | Affects |
| --- | --- | --- | --- |
| `GearGenerator` is the active old procedural model and uses one shared stat pool for all slots. | `project/scripts/systems/gear_generator.gd` `AFFIX_POOL`, `DOWNSIDE_POOL`, fixed value tables. | Migrate | T2, T5, T6 |
| Generated gear only rolls Weapon, Trinket, Charm and Basic/Master/Cursed. | `GearGenerator.ALL_SLOTS`, `GearGenerator.ALL_TIERS`. | Migrate | T3, T5 |
| Generated display names hardcode Rogue old families: Dagger, Ring, Necklace. | `GearGenerator.SLOT_NAMES` and `_display_name_for()`. | Migrate | T4 |
| Shop pricing and shop tier weights are tied to old tiers, with Legendaries still available in between-contract shops. | `GearGenerator.PRICE_BY_TIER`; `BuildState` contract shop weights and `_shop_tier_for_current_phase()`. | Migrate/Defer | T5, T6, T7, P5M7 |
| Reward data stores generated gear as `generated_gear_tier` plus integer `generated_gear_slots`. | `project/scripts/resources/encounter_reward.gd`; `SaveSystem` reward serialization. | Migrate | T2, T7 |
| Generated route rewards choose from the old three-slot pool. | `project/scripts/systems/contract_route_generator/contract_route_generator.gd` `_reward_gear_slots()`. | Migrate | T3, T6, P5M7 |
| Authored Gilded Serpent route rewards have old slot/tier summaries and integer slot arrays. | `project/data/contract_routes/gilded_serpent/*.tres`. | Migrate/Quarantine | T6, T8 |
| Lucky Coin is awarded as a fixed gear reward after the second Tavern enemy. | `project/data/encounters/02_drunk_buddy.tres`. | Migrate | T5 |

### Equipment, Inventory, And Save/Load

| Finding | Evidence | Disposition | Affects |
| --- | --- | --- | --- |
| `BuildState` stores three explicit equipped fields. | `equipped_weapon`, `equipped_trinket`, `equipped_charm`. | Migrate | T3, T7 |
| Equip, unequip, sell, and lookup logic uses three-slot `match` blocks. | `BuildState.equip()`, `unequip()`, `sell_equipped_item()`, `equipped_item_for_slot()`, `equipped_gear()`. | Migrate | T3 |
| Inventory is a flat `Array[GearItem]` and can likely remain. | `BuildState.inventory`. | Keep | T2, T3 |
| Save files serialize `equipped_weapon`, `equipped_trinket`, and `equipped_charm` as top-level fields. | `SaveSystem._serialize()` and `_deserialize()`. | Migrate | T7 |
| Runtime gear save entries store `id`, `display_name`, integer `slot`, integer `tier`, and old `affixes`. | `SaveSystem._gear_entry_to_data()` and `_gear_from_entry()`. | Migrate | T2, T7 |
| Save load drops unresolved resource gear but has no explicit schema migration for obsolete valid gear. | `SaveSystem` class comments and gear loading helpers. | Open Decision | T7 |

### UI, Practice Room, Tools, And Tests

| Finding | Evidence | Disposition | Affects |
| --- | --- | --- | --- |
| Combat gear panel visually includes Hood and Doublet placeholders, but active gear is still Dagger/Ring/Necklace. | `project/scenes/combat/gear_panel.gd` updates Hood/Doublet with `null`, then Weapon/Trinket/Charm from `BuildState`. | Migrate | T3, T8 |
| Practice Room shows Helm and Armor as disabled future slots. | `project/scenes/training_room/training_room.gd` HelmSlot and ArmorSlot are disabled with future-slot tooltips. | Migrate | T3, T8 |
| Practice Room state supports only weapon/trinket/charm practice items and only Basic/Master/Cursed custom tiers. | `project/scripts/systems/training_room_state.gd`; `training_room.gd` rarity editor. | Migrate | T3, T8, T9 |
| UI formatting and icon maps know only old tiers and old generated slot icons. | `project/scripts/ui/card_style.gd`, `gear_icons.gd`, `stat_modifier_formatter.gd`, `ui_colors.gd`. | Migrate | T2, T4, T8, T9 |
| Shop Lab exists outside Godot and explicitly documents the old three-slot/four-tier model. | `tools/shop-lab/README.md`. | Migrate/Defer | P5M6 |
| Balance Lab consumes gear arrays and currently reports DawnBringer project identity. | `project/scripts/tools/balance_lab.gd`, `tools/balance-lab/*`, `tools/monster-lab/export_to_balance_lab.js`. | Migrate/Quarantine | T8, T9, P5M11 |
| Tests heavily encode old slots, old tiers, Lucky Coin as Trinket, and old generated reward signatures. | `project/tests/gear_generator_test.gd`, `inventory_model_test.gd`, `save_load_test.gd`, `combat_screen_test.gd`, `contract_route_*`, `run_rng_context_test.gd`, `training_room_*`, `reward_shop_route_ui_test.gd`, `route_reward_choice_ui_test.gd`. | Migrate/Retire | T9 |

### Open Decisions After Audit

- Save/load compatibility is explicit as of P5M2-T7: Lucky Coin migrates to
  the canonical Charm resource, retained authored Legendary Weapon resources are
  preserved, the placeholder dagger resource is preserved, and obsolete old
  runtime-generated gear is quarantined instead of migrated item-by-item.
- The Phase 5 gear shape can extend the existing `GearItem` resource, but T2
  should decide whether stat entries remain `StatModifier` or move to a new
  gear-specific stat entry shape.
- Project identity labels should be renamed in active project/tooling files
  before M2 closeout, while generated reports should be regenerated or left as
  historical artifacts.

## P5M2-T2 Data Shape Notes

Completed 2026-09-03.

- The Phase 5 data shape extends the existing `GearItem` resource rather than
  introducing a parallel item model. This keeps authored gear, generated gear,
  rewards, UI helpers, and save/load on one shared type for M2.
- `GearItem.SlotType` now includes Weapon, Helm, Armor, Trinket, and Charm.
  Existing numeric values for Weapon, Trinket, and Charm were preserved so
  current authored resources and old saves do not silently shift meaning.
- `GearItem.Tier` now includes Crude, Basic, Master, Epic, Cursed, Chaos,
  Unique, and Legendary. Existing numeric values for Basic, Master, Cursed, and
  Legendary were preserved for compatibility.
- `GearItem` now has `item_family`, `class_family`, `source_kind`,
  `source_context`, `source_seed`, and `deterministic_key` fields.
- `StatModifier` now has `stat_id`, `category`, `is_drawback`, and
  `display_label` fields so M2 can represent Phase 5 stat entries before P5M3
  implements full stat aggregation.
- `GearGenerator` now knows Phase 5 slot and rarity names, placeholder prices,
  and source/family metadata. Its active random generation arrays still use the
  old live-safe Weapon/Trinket/Charm and Basic/Master/Cursed subset until T3/T5
  intentionally expand generated outputs.
- Authored fixed and Legendary gear resources now carry Rogue item-family and
  source-kind metadata. Lucky Coin carries Necklace family metadata for the
  Phase 5 Charm target, but the actual old-slot-to-Charm migration remains T5.
- Runtime-generated gear save entries now write and restore the new item and
  stat-entry metadata fields. T7 now quarantines old runtime-generated entries
  that lack the Phase 5 `source_kind` metadata.

Verification:

- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/gear_generator_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/save_load_test.gd`
  passed with the known intentional corrupt-save parse output.

## P5M2-T3 Five-Slot Equipment Notes

Completed 2026-09-03.

- `BuildState` now has explicit `equipped_helm` and `equipped_armor` fields in
  addition to Weapon, Trinket, and Charm. Reset, equip, unequip, equipped sale,
  equipped lookup, and `equipped_gear()` all understand the full universal slot
  order.
- Save/load now writes and restores `equipped_helm` and `equipped_armor`.
  Missing fields still load as empty slots, so older partial saves do not crash
  the loader. T7 now owns the explicit obsolete-gear quarantine policy.
- `GearGenerator.ALL_SLOTS` now uses the five universal slots. Generated route
  reward slot pools also use the active five-slot pool; authored Gilded Serpent
  route resources remain their existing explicit slot lists until their own
  migration pass.
- Combat gear panel Hood and Doublet boxes now read from BuildState and support
  equipped-slot click/unequip/sell behavior. The simple Tavern shop equipment
  summary now lists Helm and Armor rows.
- Practice Room state now owns editable Hood and Doublet practice items, and the
  Practice Room paper doll opens the same rarity/stat editor for Helm and Armor
  instead of showing disabled future slots.

Verification:

- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_five_slot_equipment_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/training_room_gear_editor_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/inventory_model_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/save_load_test.gd`
  passed with the known intentional corrupt-save parse output.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/gear_generator_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/contract_route_generator_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/build_panels_test.gd`
  passed.

## P5M2-T4 Rogue Item Family Mapping Notes

Completed 2026-09-03.

- `GearGenerator` now exposes explicit helpers for the two naming layers:
  `universal_slot_label()` for equipment slots and
  `rogue_item_family_for_slot()` / `item_family_for()` for Rogue item identity.
- Generated non-Legendary Rogue gear now stamps `item_family` through the Rogue
  family helper and builds display names from the item-family layer, so the
  universal slots remain Weapon, Helm, Armor, Trinket, and Charm while Rogue
  items display as Dagger, Hood, Doublet, Ring, and Necklace.
- Shared gear tooltip headers and Legendary tooltip headers now use the
  universal slot-label helper. Legendary resources remain named Weapon-slot
  items with Dagger family metadata rather than becoming generic generated
  Dagger display items.
- Practice Room gear metadata now uses the same Rogue family helper for its
  editable practice items.
- Runtime gear load now fills missing Rogue `item_family` metadata from the
  canonical mapping as a narrow presentation fallback. T7 applies the active
  save-boundary policy when admitting saved gear into run state.
- Added `p5m2_rogue_item_family_mapping_test.gd` to cover canonical slot/family
  mapping, generated display names and tooltips, Legendary identity, Practice
  Room metadata, and runtime save/load family preservation/fallback.

Verification:

- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_rogue_item_family_mapping_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/gear_generator_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_five_slot_equipment_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/save_load_test.gd`
  passed with the known intentional corrupt-save parse output.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/combat_screen_test.gd`
  passed.

## P5M2-T5 Lucky Coin Preservation Notes

Completed 2026-09-03.

- `lucky_coin.tres` now uses the Phase 5 Charm slot while keeping its authored
  `gear.lucky_coin` id, `Lucky Coin` display name, Basic tier, Rogue Necklace
  item family, fixed source kind, and +5% Crit Chance stat.
- The Lucky Coin stat subresource now carries the new stat-entry metadata:
  `stat_id = "crit_chance"`, Basic category, and `is_drawback = false`.
- Drunk Buddy still grants Lucky Coin as the scripted fixed gear reward and
  still unlocks shop access after the second Tavern fight.
- Reward/inventory UI expectations now equip Lucky Coin into Charm, not
  Trinket. Tooltip expectations now use `Charm - Lucky Coin`.
- Lucky Coin remains outside `LegendaryCatalog` and is not produced by generated
  item creation or shop offers.
- T5 did not implement old-save slot migration. T7 now migrates old Lucky Coin
  entries to the canonical Charm resource at load time.

Verification:

- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_lucky_coin_charm_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/inventory_model_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/encounter_reward_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_rogue_item_family_mapping_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/build_panels_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/combat_screen_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/save_load_test.gd`
  passed with the known intentional corrupt-save parse output.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_five_slot_equipment_test.gd`
  passed.

## P5M2-T6 Old Gear Quarantine Notes

Completed 2026-09-03.

- `GearGenerator.ALL_SLOTS` now represents the active five-slot universal pool
  and matches `GearItem.universal_slot_order()`. Old inline
  Weapon/Trinket/Charm generation pools are not active in `GearGenerator` or the
  generated contract route generator.
- The active procedural tier pool was renamed to
  `GearGenerator.ACTIVE_GENERATED_TIERS` and documented as an M2-limited
  Basic/Master/Cursed compatibility boundary. The full Phase 5 rarity vocabulary
  remains available through `GearGenerator.PHASE5_ALL_TIERS` and
  `GearItem.rarity_order()` for P5M5.
- Practice Room custom rarity editing now uses the named
  `PRACTICE_CUSTOM_TIERS` subset, with a note that P5M5 owns expansion to the
  full non-Legendary rarity rules.
- The combat gear panel no longer describes inventory as "three slots"; its
  tooltip now describes generic unequipped gear storage.
- Active Balance Lab Godot report metadata and generated HTML labels now use
  `Project Enigma` instead of `DawnBringer`.
- `tools/shop-lab/README.md` and `tools/balance-lab/README.md` now begin with
  Phase 5 quarantine notes. They are historical Phase 4/DawnBringer browser-lab
  references until P5M6 and P5M11, respectively.
- Generated balance report artifacts and broader project identity labels such
  as `project.godot`, export presets, Monster Lab fixtures, and historical docs
  were not bulk-edited in T6. They remain explicit follow-up/deferred identity
  or tooling work rather than hidden active gear assumptions.
- Added `p5m2_old_gear_quarantine_test.gd` to cover five-slot generated pools,
  the named active tier boundary, Lucky Coin exclusion from generated/Legendary
  pools, active-source old three-slot pool absence, and Project Enigma Balance
  Lab metadata.

Verification:

- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_old_gear_quarantine_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_five_slot_equipment_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_rogue_item_family_mapping_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_lucky_coin_charm_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/gear_generator_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/contract_route_generator_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/inventory_model_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/encounter_reward_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/save_load_test.gd`
  passed with the known intentional corrupt-save parse output.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/build_panels_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/combat_screen_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`
  passed.

## P5M2-T7 Save/Load Boundary Notes

Completed 2026-09-03.

- `SaveSystem` now applies an explicit Phase 5 gear compatibility boundary at
  load time. The low-level gear entry parser can still reconstruct runtime gear
  entries for narrow helper/tests, but the run loader now decides which parsed
  entries are safe to admit into active state.
- New saves continue to write all five equipped fields:
  `equipped_weapon`, `equipped_helm`, `equipped_armor`, `equipped_trinket`, and
  `equipped_charm`.
- Partial old saves that only contain the old Weapon/Trinket/Charm fields still
  load. Missing Helm and Armor fields resolve to empty slots.
- Lucky Coin is migrated by canonical item ID. An old save that stores
  `gear.lucky_coin` in the Trinket field now loads the current fixed Lucky Coin
  resource into Charm and leaves Trinket empty.
- Known authored gear is migrated by canonical item ID where possible. The
  retained Rogue Legendary resources and `gear.placeholder_dagger` survive old
  runtime-style entries by loading the current authored resources.
- Runtime-generated gear entries without Phase 5 `source_kind` metadata are
  treated as obsolete old gear and are dropped from inventory, shop offers,
  pending reward choices, and equipped gear instead of being silently kept with
  stale assumptions.
- Runtime gear with invalid slot, rarity, or source-kind values is dropped
  during load. Dropped or migrated gear paths add entries to
  `SaveSystem.last_gear_load_notices` for focused regression visibility.
- Reward save data continues to tolerate old generated reward slot arrays, with
  the numeric Weapon/Trinket/Charm values preserved for compatibility. Full
  generated reward/shop rarity tuning remains P5M7 scope.

Verification:

- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_save_load_boundary_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/save_load_test.gd`
  passed with the known intentional corrupt-save parse output.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_five_slot_equipment_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_lucky_coin_charm_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_rogue_item_family_mapping_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/inventory_model_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/encounter_reward_test.gd`
  passed.

## P5M2-T8 Minimal UI And Tool Surface Notes

Completed 2026-09-03.

- `GearGenerator` now exposes safe `tier_name()` and `tier_color()` helpers for
  display/tooling code that may see any Phase 5 rarity, including Crude, Epic,
  Chaos, Unique, and unknown fallback data.
- Shared gear tooltip formatting and generated reward choice text now use the
  safe tier helper instead of direct tier dictionary indexing.
- Gear icon lookup now has a visible fallback for every Phase 5 rarity and slot
  by reusing the existing small gear-drop art. P5M9 has since supplied final
  generated Rogue sprites for current generated item families.
- Contract and map reward visuals now accept every Phase 5 rarity for reward
  pill colors and gear-drop icons. Generated route reward/tradeoff text uses
  safe tier labels.
- Practice Room custom items now use Rogue display families for all five slots:
  Custom Weapon, Custom Hood, Custom Doublet, Custom Ring, and Custom Necklace.
- `GeneratedRouteInspector` now reports generated reward tier labels, universal
  slot labels, and Rogue item families alongside the raw numeric tier/slot
  fields so debug/tool output is readable during M2 and later milestones.
- `tools/shop-lab/README.md` remains the explicit Phase 5 quarantine boundary;
  P5M6 still owns the browser Shop Lab rewrite and repeated shop-offer tuning.
- Added `p5m2_minimal_ui_tool_surfaces_test.gd` and extended the Practice Room
  and generated-route inspector regressions to cover the Task 8 surface
  contracts.

Verification:

- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_minimal_ui_tool_surfaces_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/generated_route_inspector_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/training_room_gear_editor_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/reward_shop_route_ui_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/route_reward_choice_ui_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_rogue_item_family_mapping_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_gear_data_shape_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_five_slot_equipment_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_save_load_boundary_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/save_load_test.gd`
  passed with the known intentional corrupt-save parse output.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/build_panels_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/combat_screen_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/generated_contract_save_load_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/gear_generator_test.gd`
  passed.
- `Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/contract_route_data_test.gd`
  passed.

## P5M2-T9 Focused Regression Notes

Completed 2026-09-03.

- The focused P5M2 regression set now covers each M2 boundary directly:
  data-shape vocabulary, five-slot equipment, Rogue item-family mapping, Lucky
  Coin preservation, old gear quarantine, save/load compatibility, and minimal
  UI/tool display safety.
- The existing reward/shop/route UI regression now verifies that both map and
  contract overlays can produce a visible gear-drop icon and the shared tier
  color for every Phase 5 rarity. This closes the remaining T8-adjacent gap
  without preloading autoload-dependent overlay scripts in isolation.
- The official M2 closeout regression bundle is:
  `p5m2_gear_data_shape_test.gd`,
  `p5m2_five_slot_equipment_test.gd`,
  `p5m2_rogue_item_family_mapping_test.gd`,
  `p5m2_lucky_coin_charm_test.gd`,
  `p5m2_old_gear_quarantine_test.gd`,
  `p5m2_save_load_boundary_test.gd`,
  `p5m2_minimal_ui_tool_surfaces_test.gd`,
  `save_load_test.gd`,
  `gear_generator_test.gd`,
  `inventory_model_test.gd`,
  `encounter_reward_test.gd`,
  `build_panels_test.gd`,
  `combat_screen_test.gd`,
  `reward_shop_route_ui_test.gd`,
  `route_reward_choice_ui_test.gd`,
  `contract_route_generator_test.gd`,
  `generated_route_inspector_test.gd`,
  `generated_contract_save_load_test.gd`,
  `contract_route_data_test.gd`, and
  `balance_lab_test.gd`.
- T9 did not pull forward later-milestone coverage for full stat aggregation,
  final procedural rarity/stat rolling, Shop Lab simulation, final inventory
  presentation, Hood/Doublet sprites, or full Practice Room/Balance Lab
  validation. Those remain assigned to P5M3, P5M5, P5M6, P5M8, P5M9, and
  P5M11 respectively.

Verification:

- Every test in the official M2 closeout regression bundle listed above passed
  via `Godot_v4.7-stable_win64_console.exe --headless --path project -s
  res://tests/<test>.gd`.
- `save_load_test.gd` still emits its intentional corrupt-save JSON parse
  output before passing.
- Godot still reports the known process-exit ObjectDB/RID/resource warnings on
  these headless test scripts; no test exited nonzero.

## P5M2-T10 Milestone Closeout Notes

Completed 2026-09-03.

- P5M2 is complete. The old three-slot gear assumptions have been replaced by
  the Phase 5 foundation: universal Weapon, Helm, Armor, Trinket, and Charm
  slots; Rogue Dagger, Hood, Doublet, Ring, and Necklace item-family display;
  expanded rarity vocabulary; fixed/generated/Legendary source metadata; and
  stat-entry metadata needed by later milestones.
- The Phase 5 gear shape lives in the existing `GearItem` resource and extends
  the existing `StatModifier` resource. This keeps current authored resources,
  generated gear, save/load, rewards, and UI surfaces on one model through M2.
- New saves write five equipped gear fields. Old or partial saves that lack
  Helm/Armor load safely, Lucky Coin migrates by canonical id to the current
  Trinket/Ring resource, retained authored gear migrates by canonical id, and
  obsolete old runtime-generated gear is quarantined from active run state.
- Lucky Coin is preserved as a fixed Basic Trinket/Ring with +5% Crit Chance,
  still awarded after Drunk Buddy, still outside LegendaryCatalog, and still
  excluded from normal generated/shop pools.
- Retained Rogue Legendaries remain named Weapon-slot Dagger items with their
  current identity/effects preserved. Their final fixed stat packages and value
  tuning remain P5M10 scope.
- Old active gear assumptions were either migrated into the five-slot model or
  explicitly quarantined. The active generated tier subset remains
  Basic/Master/Cursed until P5M5, Practice Room custom rarity editing remains
  Basic/Master/Cursed until P5M5/P5M11, and Shop Lab remains quarantined until
  P5M6.
- Minimal UI/tool surfaces are M2-safe but not final presentation. Inventory,
  equipment, rewards, route previews, shop offers, Practice Room, Balance Lab,
  and generated-route inspector paths tolerate the five-slot model; P5M8 and
  P5M9 still own final item readability and Hood/Doublet art.
- The official M2 closeout regression bundle is recorded in the P5M2-T9 notes
  and passed. `save_load_test.gd` intentionally emits a corrupt-save JSON parse
  message before passing, and Godot still reports known ObjectDB/RID/resource
  cleanup warnings on headless test exit.

Primary implementation areas changed during P5M2:

- Gear data/resources: `project/scripts/resources/gear_item.gd`,
  `project/scripts/resources/stat_modifier.gd`, `project/data/gear/*.tres`.
- Gear systems: `project/scripts/systems/gear_generator.gd`,
  `project/scripts/systems/save_system.gd`,
  `project/scripts/systems/legendary_catalog.gd`,
  `project/scripts/autoload/build_state.gd`,
  `project/scripts/systems/training_room_state.gd`, and generated-route reward
  summary paths.
- UI/tool surfaces: combat gear panel, combat screen reward text, map and
  contract overlays, Tavern shop rows, Practice Room gear editor, gear icon and
  tooltip helpers, Balance Lab identity, generated-route inspector output, and
  quarantined browser-lab docs.
- Regression coverage: the focused `p5m2_*` tests plus the official M2
  closeout bundle listed under P5M2-T9.

Handoff to later milestones:

- P5M3 starts by closing the remaining Godot-visible Project Enigma identity
  cleanup: `project.godot` project name, export preset names, product/file
  descriptions, and output paths should stop presenting as DawnBringer.
- P5M3 then owns full stat aggregation, stat floors/caps, new Basic/Rare/Special
  vocabulary behavior, denial/conversion/ignore effects, and immunity fields.
- P5M4 owns Rogue weapon damage rolls and physical-skill scaling.
- P5M5 owns full procedural rarity/stat rolling, Cursed/Chaos/Unique rules, and
  Legendary selection boundaries.
- P5M6 owns Shop Lab gear simulation and repeated offer tuning.
- P5M7 owns live Adventure reward/shop integration and contract-depth tuning.
- P5M8 owns final inventory/equipment UI and player-facing item readability.
- P5M9 completed Hood/Doublet sprites and final generated Rogue item art
  cleanup.
- P5M10 owns retained Legendary fixed stat packages and value tuning.
- P5M11 owns full Practice Room and Balance Lab validation.
- P5M12 owns full Phase 5 regression, smoke, export-sensitive checks, and
  phase closeout.

## Status Definitions

- `Ready`: The task can be worked now.
- `Blocked`: The task needs a prior task output, implementation decision, or
  design clarification before it can be completed.
- `In Progress`: The task is actively being edited, implemented, or reviewed.
- `Complete`: The task output has been added, verified, and recorded.

## Current Known Decisions

- P5M2 owns the gear data model and migration boundary only. Godot-visible
  project/export identity cleanup and full stat aggregation belong to P5M3.
- Rogue weapon-damage scaling belongs to P5M4.
- Procedural rarity/stat rolling belongs to P5M5.
- Shop Lab tuning and repeated shop-offer simulation belong to P5M6.
- Live Adventure reward and shop integration belongs to P5M7.
- Final inventory/equipment presentation belongs to P5M8.
- Hood and Doublet sprites belong to P5M9 unless placeholder references are
  required for M2 functionality.
- Retained Rogue Legendary implementation and final fixed stat packages belong
  to P5M10, but M2 must preserve their identity boundary as named Weapon-slot
  items.
- Practice Room and Balance Lab full validation belongs to P5M11, but M2 should
  keep those surfaces from breaking and add focused checks for the data model.
- Lucky Coin is a fixed Basic Trinket/Ring with +5% Crit Chance, awarded after
  the second Tavern enemy, and excluded from normal procedural rewards and
  shops.
- P5M2 should prefer explicit compatibility behavior over silent partial use of
  old gear data.

## Open Implementation Questions

- Which old gear tests should be rewritten for the new boundary, and which
  should be retired as obsolete during later Phase 5 milestones?

## Completion Notes

P5M2 is complete as of 2026-09-03. The milestone closeout, compatibility
decision, old-gear migration/quarantine boundary, verification bundle, and
P5M3+ handoff items are recorded in the P5M2-T10 notes above.
