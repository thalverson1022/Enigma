# P5M10: Legendary Revisit And Fixed Legendary Stats Tracker

## Status

Complete.

P5M10 brings the retained Rogue Legendaries into the completed Phase 5 gear
framework. The milestone should preserve each Legendary's current item identity
and build-defining effect while replacing old or provisional stat assumptions
with explicit fixed Phase 5 stat packages.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone documents:

- `docs/P5_Gear_Redesign_Overview.md`
- `docs/P5M4_Weapon_Damage_Scaling_Tracker.md`
- `docs/P5M7_Reward_And_Shop_Integration_Tracker.md`
- `docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`
- `docs/P5M9_Art_And_Sprite_Pass_Tracker.md`

## Milestone Goal

Retain the five current Rogue Legendaries as named Weapon-slot dagger items,
assign handcrafted fixed stat packages using the Phase 5 stat vocabulary, keep
their existing Legendary effects functional, and validate that they equip,
display, save/load, and behave in combat without re-opening the broader
Legendary redesign.

P5M10 is not a new Legendary ecosystem, new Legendary reward/shop behavior, new
class work, broad talent-tree redesign, or final whole-game balance pass. A
deeper Legendary redesign remains deferred until the later talent-tree phase.

## Retained Rogue Legendary Targets

| Legendary | Slot | Fixed Stats | Legendary Effect |
| --- | --- | --- | --- |
| Wyvern Kriss | Weapon | 21-27 Base Damage; +8 Base Elemental Damage; +40% Percent Elemental Damage; +12% Chance to Decay | Poison damage ticks twice as fast. |
| Bandit Blade | Weapon | 21-27 Base Damage; +20% Percent Physical Damage; +12% Crit Chance; +30% Increased Gold | +1 physical damage for every 10 gold in your stash. |
| Umbral Stiletto | Weapon | 21-27 Base Damage; +10% Crit Chance; +100% Crit Damage; +100% Chance for Crits to Apply Poison | Unlock Death Strike. |
| Mithril Karambit | Weapon | 21-27 Base Damage; +15% Increased Attack Speed; +15% Crit Chance; +20% Chance to Shred | Stab and Heavy Slash have a 50% chance to retrigger. |
| Bejeweled Push Dagger | Weapon | 21-27 Base Damage; +8 Base Damage; +20% Percent Physical Damage; +10% Crit Chance | 20% chance to reduce a skill to its minimum attack time. |

These target packages are the starting implementation contract. P5M10 may make
small value adjustments only if audit or validation shows a package is clearly
outside the new gear paradigm. Any broader item redesign should be documented as
deferred work.

## Exit Criteria

- Existing Rogue Legendary resources and effect hooks are audited.
- Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril Karambit, and Bejeweled
  Push Dagger are confirmed as named Legendary Weapon-slot Rogue dagger items.
- Each retained Legendary has an explicit fixed stat package using canonical
  Phase 5 stat IDs and the Legendary 21-27 weapon damage range.
- Existing Legendary effects still function through the current combat and
  talent/skill systems.
- Legendary item cards, comparison tooltips, inventory, equipment UI, and
  Practice Room surfaces present named authored Legendaries clearly.
- Lucky Coin and generated Rogue icon mappings remain unaffected by Legendary
  changes.
- Save/load compatibility preserves retained Legendary identity, stats, effects,
  slot, rarity, and equipment state.
- Generator, shop, and reward boundaries still prevent procedural Legendary stat
  rolling.
- Focused regression or validation coverage exists for fixed stats, effects,
  presentation, save/load, and boundary behavior.
- Deferred Legendary redesign notes are recorded for the later talent-tree
  phase.
- Phase 5 docs are updated with P5M10 completion notes and the P5M11 handoff.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M10-T1: Audit Existing Legendary Resources | Complete | Locate current retained Rogue Legendary data, authored icons, save/load paths, reward/equip paths, and effect hooks before editing. | Completed 2026-09-06. Tracker records current IDs, file/resource locations, stats, slots, rarity values, icon overrides, and effect implementation points. |
| P5M10-T2: Lock Fixed Stat Packages | Complete | Compare the `New_Gear_Overview` target packages against current implementation and decide whether exact targets or small tuning adjustments should ship. | Completed 2026-09-06. Final per-Legendary stat package table is recorded before resource updates; P5M10 will ship the documented target values exactly. |
| P5M10-T3: Update Legendary Item Definitions | Complete | Apply the fixed packages to the retained Legendary item definitions using canonical Phase 5 data. | Completed 2026-09-06. Each retained Legendary is a Legendary Weapon-slot Rogue dagger with 21-27 weapon damage, fixed canonical stats, authored identity, and retained effect metadata. |
| P5M10-T4: Verify Legendary Effects In Combat | Complete | Confirm each retained Legendary effect still works with the P5M4 damage pipeline and post-P5M9 Rogue tuning. | Completed 2026-09-06. Focused checks cover Wyvern poison tick speed, Bandit gold damage, Umbral Death Strike unlock/use, Mithril retriggers, and Bejeweled minimum attack time. |
| P5M10-T5: Verify Presentation And Equip Behavior | Complete | Confirm player-facing Legendary display and equipment behavior after the stat updates. | Completed 2026-09-06. Inventory/equipment UI, item cards, comparison tooltips, reward/equip flows, Practice Room, icons, and rarity presentation remain correct. |
| P5M10-T6: Add Focused Regression Coverage | Complete | Protect retained Legendary stat packages, effects, save/load compatibility, icon overrides, and procedural-generation boundaries. | Completed 2026-09-06. Added focused all-five Legendary regression coverage, updated Balance Lab fixed-package expectations, and refreshed stale Balance Lab control thresholds/assertions. |
| P5M10-T7: Practice Room And Balance Lab Hooks | Complete | Ensure retained Legendaries can be selected, inspected, or validated through the appropriate validation surfaces without broad P5M11 expansion. | Completed 2026-09-06. Practice Room dropdown selection/inspection and Balance Lab P5M10 mechanic IDs are explicitly covered; wider validation remains deferred to P5M11. |
| P5M10-T8: Update Docs And Closeout | Complete | Record implementation, verification, tuning caveats, and the future Legendary redesign boundary. | Completed 2026-09-06. This tracker, onboarding, Phase 5 overview, Project Overview, and gear overview now mark P5M10 complete and hand off cleanly to P5M11. |

## P5M10-T1 Audit Notes

Status: Complete.

Completed 2026-09-06. The five retained Rogue Legendaries are authored
resources in `project/data/gear/` and are listed by
`project/scripts/systems/legendary_catalog.gd`. All five currently load as
named Rogue `Weapon` / `Dagger` items with `tier = GearItem.Tier.LEGENDARY`
and `source_kind = GearItem.SourceKind.LEGENDARY`. Their 21-27 weapon damage
range comes from `WeaponDamageCatalog.damage_range_for_weapon()` via the shared
Legendary dagger tier, not per-resource min/max fields.

| Item | Resource | ID | Current Stats / Metadata | Effect Hook | P5M10 Audit Finding |
| --- | --- | --- | --- | --- | --- |
| Wyvern Kriss | `project/data/gear/wyvern_kriss.tres` | `gear.legendary.wyvern_kriss` | Legacy enum modifiers: +2 `POISON_STACKS_APPLIED`, x1.4 `POISON_DAMAGE`, x0.5 `POISON_TICK_INTERVAL`; no explicit canonical `stat_id` fields. | Poison tick speed is preserved by `StatSheet.legacy_poison_tick_interval_multiplier` and applied to `PlayerStats.poison_tick_interval_multiplier`; tooltip hides the tick-interval affix and shows `LegendaryCatalog.effect_text()`. | Identity, slot, rarity, source kind, catalog entry, icon, and effect hook are present. Fixed stats do not match the P5M10 target package yet: needs canonical `base_elemental_damage`, `percent_elemental_damage`, and `chance_to_decay`; legacy +stacks is not in the target package. |
| Bandit Blade | `project/data/gear/bandit_blade.tres` | `gear.legendary.bandit_blade` | Legacy enum modifiers: x1.2 `PHYSICAL_DAMAGE`, +20% `CRIT_CHANCE`; `physical_damage_per_gold = 0.1`; no explicit canonical `stat_id` fields. | `BuildResolver.resolve_stats()` adds `gear.physical_damage_per_gold * current_gold` into flat physical damage. | Identity, slot, rarity, source kind, catalog entry, icon, and gold-scaling effect hook are present. Target package needs canonical +20% `percent_physical_damage`, +12% `crit_chance`, and +30% `increased_gold`; current crit is +20% and no Increased Gold affix exists. |
| Umbral Stiletto | `project/data/gear/umbral_stiletto.tres` | `gear.legendary.umbral_stiletto` | Legacy enum modifiers: +10% `CRIT_CHANCE`, +100% `CRIT_MULTIPLIER`; `unlocked_skills` points at `res://data/skills/death_strike.tres`; no explicit canonical `stat_id` fields. | `BuildResolver.resolve_unlocked_skills()` appends gear-granted skills. Current tests look for `skill.killers_mark`, so the skill resource ID/name should be rechecked during T4/T6. | Identity, slot, rarity, source kind, catalog entry, icon, and skill-unlock hook are present. Target package additionally needs canonical +10% `crit_applies_element`; current crit and crit damage values match the target numerically. |
| Mithril Karambit | `project/data/gear/mithril_karambit.tres` | `gear.legendary.mithril_karambit` | Legacy enum modifiers: +20% `ATTACK_SPEED`, +10% `CRIT_CHANCE`; two `TriggeredSkillEffect`s at 20%, filtered to `skill.stab` and `skill.heavy_slash`; no explicit canonical `stat_id` fields. | `BuildResolver.resolve_stats()` appends gear `triggered_skill_effects`; `CombatResolver` resolves retrigger casts with source-skill filtering. | Identity, slot, rarity, source kind, catalog entry, icon, and retrigger hooks are present. Target package needs canonical +15% `increased_attack_speed`, +15% `crit_chance`, and +8% `chance_to_shred`; current speed/crit values differ and no Shred chance affix exists. |
| Bejeweled Push Dagger | `project/data/gear/bejeweled_push_dagger.tres` | `gear.legendary.bejeweled_push_dagger` | Legacy enum modifiers: x1.2 `PHYSICAL_DAMAGE`, +40% `CRIT_CHANCE`; `min_cast_time_proc_chance = 0.2`; no explicit canonical `stat_id` fields. | `BuildResolver.resolve_stats()` adds `min_cast_time_proc_chance`; `CombatResolver.resolve()` rolls it before cast timing and clamps proc casts to minimum attack time. | Identity, slot, rarity, source kind, catalog entry, icon, and minimum-cast-time hook are present. Target package needs canonical +8 `base_damage`, +20% `percent_physical_damage`, and +10% `crit_chance`; current crit is +40% and no Base Damage affix exists. |

Catalog and fixed-boundary audit:

- `LegendaryCatalog.all_paths()` is the current catalog source for all five
  retained items. It is used by tests, Practice Room selection, and
  `BuildState.shop_legendary_paths()`.
- `LegendaryCatalog.tooltip_lines()` builds Legendary item-card text and uses
  `WeaponDamageCatalog.damage_range_for_weapon()` for the 21-27 displayed
  weapon damage line.
- `GearGenerator` rejects procedural Legendary generation; existing boundary
  tests assert `legendary_requires_fixed_catalog`.
- `BuildState._shop_offer_for_tier()` chooses unowned Legendary catalog items
  for Legendary shop offers and falls back to generated Cursed items only when
  every catalog Legendary is owned.
- `BuildState._gear_choices_for_reward()` can sample distinct fixed Legendary
  reward choices from `EncounterReward.legendary_choice_pool`; generated
  reward upgrade high-tier options exclude Legendary.

Presentation, icon, Practice Room, and save/load audit:

- `GearIcons.NAMED_ICONS` maps all five retained IDs to authored PNGs under
  `project/assets/Items/Rogue/`; Lucky Coin also remains a named override.
  `ROGUE_GENERATED_ICONS` intentionally has no Legendary slot/tier entries,
  so generated Legendary-like items fall back to the generic Legendary icon
  instead of reusing generated Unique dagger art.
- `CardStyle.gear_tooltip_lines()` delegates retained Legendaries to
  `LegendaryCatalog.tooltip_lines()`, while shop, reward, inventory, and
  equipment comparison tooltips route through `CardStyle.build_gear_compare_tooltip()`
  and compare against `BuildState.equipped_item_for_slot(gear.slot)`.
- `TrainingRoomState.equip_legendary()` directly equips a catalog Legendary to
  the weapon slot. `training_room.gd` exposes the `LegendaryOption` dropdown,
  treats catalog Legendaries as read-only weapon gear, and renders icons with
  `GearIcons.icon_for()`.
- `BalanceLab._run_mechanics_checks()` already has per-Legendary resource/effect
  checks, but its expected stat values are still the pre-P5M10 values and must
  be updated after fixed packages are locked.
- `SaveSystem._gear_entry_to_data()` saves authored `.tres` gear by
  `resource_path`; `SaveSystem._gear_from_save_entry()` reloads those resources
  through `load()`. It also has a canonical-authored-gear lookup by saved ID
  over fixed gear and `LegendaryCatalog.all_paths()`, preserving compatibility
  for old save entries that do not contain resource paths.

Follow-on implementation implications for T2/T3:

- Every retained Legendary should be re-authored with explicit canonical
  `stat_id`, `category`, and display labels where applicable instead of relying
  on blank `stat_id` legacy enum bridging for its fixed Phase 5 package.
- Existing bespoke fields should be preserved for Legendary effects:
  `physical_damage_per_gold`, `unlocked_skills`, `triggered_skill_effects`,
  `min_cast_time_proc_chance`, and the Wyvern legacy poison tick interval
  multiplier unless P5M10 chooses a new canonical representation for that
  effect.
- Current tests and Balance Lab expectations still encode old stat values for
  Bandit Blade, Mithril Karambit, Bejeweled Push Dagger, and Wyvern Kriss; T6
  should update them after T2/T3.

## P5M10-T2 Fixed Package Notes

Status: Complete.

Completed 2026-09-06. T2 locks the `docs/New_Gear_Overview.md` and Retained
Rogue Legendary Targets values exactly as written. The T1 audit found legacy
resource drift and missing canonical stat IDs, but did not identify a reason to
make tuning adjustments before implementation. Any later balance concern should
be recorded as validation feedback after T3-T7 rather than changing this
pre-implementation contract.

Final fixed package implementation contract:

| Legendary | Fixed Stat Package | Canonical Stat IDs For T3 | Preserved Legendary Effect Metadata |
| --- | --- | --- | --- |
| Wyvern Kriss | Legendary Weapon damage range 21-27; +8 Base Elemental Damage; +40% Percent Elemental Damage; +12% Chance to Decay. | `base_elemental_damage = 8.0`; `percent_elemental_damage = 0.40`; `chance_to_decay = 0.12`. | Preserve poison tick interval multiplier effect as the Legendary effect: poison damage ticks twice as fast. |
| Bandit Blade | Legendary Weapon damage range 21-27; +20% Percent Physical Damage; +12% Crit Chance; +30% Increased Gold. | `percent_physical_damage = 0.20`; `crit_chance = 0.12`; `increased_gold = 0.30`. | Preserve `physical_damage_per_gold = 0.1`: +1 physical damage for every 10 gold in stash. |
| Umbral Stiletto | Legendary Weapon damage range 21-27; +10% Crit Chance; +100% Crit Damage; +100% Chance for Crits to Apply Poison. | `crit_chance = 0.10`; `crit_damage = 1.00`; `crit_applies_element = 1.00`. | Preserve `unlocked_skills` Death Strike unlock. |
| Mithril Karambit | Legendary Weapon damage range 21-27; +15% Increased Attack Speed; +15% Crit Chance; +20% Chance to Shred. | `increased_attack_speed = 0.15`; `crit_chance = 0.15`; `chance_to_shred = 0.20`. | Preserve the two 50% `TriggeredSkillEffect`s for source-filtered Stab and Heavy Slash retriggers. |
| Bejeweled Push Dagger | Legendary Weapon damage range 21-27; +8 Base Damage; +20% Percent Physical Damage; +10% Crit Chance. | `base_damage = 8.0`; `percent_physical_damage = 0.20`; `crit_chance = 0.10`. | Preserve `min_cast_time_proc_chance = 0.2`: 20% chance to reduce a skill to its minimum attack time. |

T3 resource-update rules:

- Keep all five retained items as named `GearItem.Tier.LEGENDARY`,
  `GearItem.SlotType.WEAPON`, Rogue `Dagger` items with
  `GearItem.SourceKind.LEGENDARY`.
- Treat the 21-27 weapon damage range as tier/catalog behavior from
  `WeaponDamageCatalog`, not a per-resource affix.
- Re-author fixed stats with explicit canonical `stat_id`, matching
  `StatModifier.StatCategory.BASIC` or `StatModifier.StatCategory.RARE` as
  defined by `StatCatalog`.
- Preserve bespoke Legendary effect fields separately from fixed stat affixes.
- Do not add procedural Legendary stat rolling, generated Legendary art
  mappings, new Legendary reward/shop behavior, or broader Legendary redesign
  work during T3.

## P5M10-T3 Definition Update Notes

Status: Complete.

Completed 2026-09-06. The five retained Rogue Legendary item resources were
updated to the locked T2 fixed stat packages with explicit canonical
`stat_id`, `StatModifier.StatCategory`, additive values, and display labels.
All five resources preserve their existing `id`, `display_name`, Legendary
tier, Weapon slot, Rogue class family, `Dagger` item family, and
`GearItem.SourceKind.LEGENDARY` identity. The Legendary 21-27 weapon damage
range remains catalog/tier-driven through `WeaponDamageCatalog`; no per-resource
weapon damage range field or affix was added.

Updated resource definitions:

| Legendary | Resource Update | Preserved Effect Metadata |
| --- | --- | --- |
| Wyvern Kriss | `project/data/gear/wyvern_kriss.tres` now has canonical `base_elemental_damage = 8.0`, `percent_elemental_damage = 0.40`, and `chance_to_decay = 0.12` affixes. The old +2 stack package stat was removed. | Preserved the hidden compatibility `POISON_TICK_INTERVAL` multiplier at x0.5 for "Poison ticks twice as fast." |
| Bandit Blade | `project/data/gear/bandit_blade.tres` now has canonical `percent_physical_damage = 0.20`, `crit_chance = 0.12`, and `increased_gold = 0.30` affixes. | Preserved `physical_damage_per_gold = 0.1` for +1 physical damage per 10 gold in stash. |
| Umbral Stiletto | `project/data/gear/umbral_stiletto.tres` now has canonical `crit_chance = 0.10`, `crit_damage = 1.00`, and `crit_applies_element = 1.00` affixes. | Preserved `unlocked_skills = res://data/skills/death_strike.tres`. |
| Mithril Karambit | `project/data/gear/mithril_karambit.tres` now has canonical `increased_attack_speed = 0.15`, `crit_chance = 0.15`, and `chance_to_shred = 0.20` affixes. | Preserved both 50% source-filtered `TriggeredSkillEffect`s for `skill.stab` and `skill.heavy_slash`. |
| Bejeweled Push Dagger | `project/data/gear/bejeweled_push_dagger.tres` now has canonical `base_damage = 8.0`, `percent_physical_damage = 0.20`, and `crit_chance = 0.10` affixes. | Preserved `min_cast_time_proc_chance = 0.2`. |

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_legendary_generator_boundary_test.gd` passed with `P5M5 Legendary generator boundary check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_weapon_damage_runtime_data_test.gd` passed with `P5M4 weapon damage runtime data check: OK`.
- The first sandboxed Godot run crashed before executing tests because Godot
  could not open `user://logs/...`; rerunning with normal filesystem access
  resolved it.
- Godot emitted the accepted ObjectDB/RID/resource cleanup warnings at process
  exit during the passing runs.

Expected follow-up:

- T4 should validate the preserved combat effects against the updated stat
  packages.
- T6 should update old fixed-value expectations in Legendary tests and
  Balance Lab checks to the P5M10 stat packages.

## P5M10-T4 Combat Effect Notes

Status: Complete.

Completed 2026-09-06. Added
`project/tests/p5m10_legendary_combat_effects_test.gd` as the direct P5M10
combat-effect validation for all five retained Rogue Legendaries after the T3
fixed stat rewrite. The test uses real authored Legendary resources and forces
probabilistic effects to deterministic values only where required to prove
combat behavior.

Validated effects:

- Wyvern Kriss: resolved stats preserve `poison_tick_interval_multiplier = 0.5`
  while the new fixed package contributes +8 Base Elemental Damage, +40%
  Percent Elemental Damage, and +12% Chance to Decay; combat poison ticks
  resolve at 500ms intervals.
- Bandit Blade: resolved stats preserve `physical_damage_per_gold = 0.1`, with
  100 stash gold adding +10 flat physical damage; a same-seed combat comparison
  deals more physical damage with 100 gold than with 0 gold.
- Umbral Stiletto: resolved stats preserve the Death Strike unlock, the skill
  appears through `BuildResolver.resolve_unlocked_skills()`, and a combat cast
  records a Legendary 21-27 weapon roll from `gear.legendary.umbral_stiletto`.
- Mithril Karambit: resolved stats preserve two triggered skill effects; when
  forced to 100% for validation, Stab procs Stab and Heavy Slash procs Heavy
  Slash through the source-filtered retrigger path.
- Bejeweled Push Dagger: resolved stats preserve
  `min_cast_time_proc_chance = 0.2`; when forced to 100% for validation, slow
  skills cast at their minimum attack time and each cast records
  `min_cast_time_proc_applied`.

Updated existing expectation coverage:

- `project/tests/legendary_reward_test.gd` now expects the T3 fixed stat values
  while preserving its existing reward/equip and Legendary effect assertions.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_combat_effects_test.gd` passed with `P5M10 Legendary combat effects: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/legendary_reward_test.gd` passed with `Legendary reward check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/legendary_mechanics_test.gd` passed with `P2:R9:T1-T3 legendary mechanics check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_practice_room_combat_smoke_test.gd` passed with `P5M4 Practice Room combat smoke: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_death_strike_stack_order_test.gd` passed with `P5M4 Death Strike stack order check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_crit_applies_poison_test.gd` passed with `P5M4 crit applies poison check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_retrigger_semantics_test.gd` passed with `P5M4 retrigger semantics check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/engine_mechanics_test.gd` passed with `P2:M5 T0 engine mechanics check: OK`.
- Godot emitted the accepted ObjectDB/RID/resource cleanup warnings at process
  exit during the passing runs.

## P5M10-T5 Presentation Notes

Status: Complete.

Completed 2026-09-06. Added
`project/tests/p5m10_legendary_presentation_equip_test.gd` as a focused
all-five retained Legendary presentation/equip check after the T3 fixed stat
rewrite.

Validated presentation and equip surfaces:

- Each retained Legendary item card starts with the authored item name, shows
  `Legendary Weapon / Dagger`, shows `Weapon Damage: 21-27`, includes a
  `Stats:` section with the new canonical fixed stat lines, includes a
  `Legendary:` section with the retained effect text, and hides resource IDs,
  paths, source fields, deterministic keys, and generator metadata.
- Wyvern Kriss still hides the implementation-only `Poison Tick Interval`
  affix from player-facing card text while presenting the Legendary effect as
  `Poison ticks twice as fast`.
- `GearIcons.icon_for()` still resolves all five retained Legendary IDs to
  their authored `project/assets/Items/Rogue/` PNGs. Lucky Coin remains a named
  override, and generated Legendary-like Rogue gear still uses the generic
  Legendary fallback icon rather than generated Unique dagger art.
- Direct inventory equip places each retained Legendary in the Weapon slot and
  removes it from inventory while equipped; replacing the equipped weapon moves
  the prior Legendary back to inventory.
- Reward choice selection still auto-equips each Legendary to Weapon, clears
  pending reward choices, and does not consume inventory capacity.
- Practice Room `TrainingRoomState.equip_legendary()` equips every catalog
  Legendary into the Weapon slot, reports the weapon as Legendary/read-only,
  resolves its authored icon, and can return to the editable custom weapon.
- Existing P5M8 UI regression coverage confirms inventory, shop, and reward
  comparison tooltips still compare against the currently equipped item in the
  matching slot.
- Existing Practice Room gear editor coverage confirms the live Legendary
  dropdown path, authored Wyvern icon display, hidden affix rows for Legendary
  weapons, and the return path back to editable generated practice weapon gear.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_presentation_equip_test.gd` passed with `P5M10 Legendary presentation/equip: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m8_item_card_content_test.gd` passed with `P5M8 item card content check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m8_flow_verification_test.gd` passed with `P5M8 flow verification check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m8_ui_regression_test.gd` passed with `P5M8 UI regression check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m9_icon_regression_test.gd` passed with `P5M9 icon regression coverage: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m9_special_icon_overrides_test.gd` passed with `P5M9 special icon overrides check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/training_room_gear_editor_test.gd` passed with `Practice Room gear editor check: OK`.
- Godot emitted the accepted ObjectDB/RID/resource cleanup warnings at process
  exit during the passing runs.

## P5M10-T6 Regression Notes

Status: Complete.

Completed 2026-09-06. Added
`project/tests/p5m10_legendary_regression_test.gd` as the direct T6 guard for
the retained Rogue Legendary fixed packages and integration boundaries.

Validated regression boundaries:

- All five retained Legendary resources load as named Rogue `Weapon` /
  `Dagger` items with `GearItem.Tier.LEGENDARY`,
  `GearItem.SourceKind.LEGENDARY`, and the tier-driven 21-27 Legendary weapon
  damage range.
- Each fixed package has the expected canonical stat IDs, category, operation,
  value, and authored display label. Wyvern Kriss additionally preserves the
  hidden compatibility poison tick interval effect affix.
- Bespoke effect metadata remains present: Bandit Blade gold-to-damage scaling,
  Umbral Stiletto Death Strike unlock, Mithril Karambit source-filtered Stab
  and Heavy Slash retriggers, and Bejeweled Push Dagger minimum-cast proc
  chance.
- Save/load restores retained Legendaries from current resource-path saves and
  from legacy ID-only authored gear entries via the canonical
  `LegendaryCatalog` lookup, preserving identity, stat packages, and effect
  metadata.
- `LegendaryCatalog`, `GearGenerator`, and `GearIcons.icon_for()` boundaries
  still keep retained Legendary stats fixed/authored, reject procedural
  Legendary generation, keep generated offers out of the `gear.legendary.*`
  namespace, retain authored icon overrides, and use the generic Legendary
  fallback only for generated Legendary-like test gear.

Updated existing regression surfaces:

- `project/scripts/tools/balance_lab.gd` now checks P5M10 fixed packages for
  Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril Karambit, and Bejeweled
  Push Dagger instead of pre-P5M10 Legendary values.
- Balance Lab control thresholds were refreshed for the current deterministic
  baseline Rogue Stab and Defense Block scenarios.
- `project/tests/balance_lab_test.gd` now allows the intentional
  `defense_block_stab` zero-DPS control scenario while still requiring all
  other scenario samples to produce damage.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_regression_test.gd` passed with `P5M10 Legendary regression: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_combat_effects_test.gd` passed with `P5M10 Legendary combat effects: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_presentation_equip_test.gd` passed with `P5M10 Legendary presentation/equip: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_legendary_generator_boundary_test.gd` passed with `P5M5 Legendary generator boundary check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_generator_regression_test.gd` passed with `P5M5 generator regression check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m9_icon_regression_test.gd` passed with `P5M9 icon regression coverage: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m9_special_icon_overrides_test.gd` passed with `P5M9 special icon overrides check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/save_load_test.gd` passed with `Save/load round trip check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/legendary_reward_test.gd` passed with `Legendary reward check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_import_test.gd` passed with `Balance Lab import test: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://scripts/tools/run_balance_suite.gd` passed with Balance Lab report status `pass`, `70 pass`, `0 warn`, and `0 fail`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd` passed with `Balance Lab test: OK`.
- The first sandboxed Godot run hit the known `user://logs` crash before test
  execution; rerunning with normal filesystem access resolved it.
- Godot emitted the accepted ObjectDB/RID/resource cleanup warnings at process
  exit during the passing runs.

## P5M10-T7 Validation Surface Notes

Status: Complete.

Completed 2026-09-06. T7 kept the validation-surface work scoped to existing
Practice Room and Balance Lab hooks instead of expanding the broader Legendary
or balance ecosystem.

Practice Room validation:

- `project/tests/training_room_gear_editor_test.gd` now verifies the live
  weapon Legendary dropdown exposes all five retained `LegendaryCatalog` items
  by authored display name.
- The same test selects each retained Legendary through the dropdown and
  confirms the weapon slot is Legendary/read-only, affix rows stay hidden, the
  dropdown tooltip and paper-doll tooltip expose the authored item name,
  `Legendary Weapon / Dagger` presentation, and the catalog effect text, and
  the paper-doll icon matches `GearIcons.icon_for()`.
- Existing Practice Room checks continue to validate direct state equip,
  switching back to editable custom weapon gear, Practice Room/Adventure state
  isolation, practice-gold handling for Bandit Blade, and Legendary-equipped
  practice combat smoke.

Balance Lab validation:

- `project/tests/balance_lab_test.gd` now asserts the report includes the
  P5M10 Legendary mechanics IDs for all five retained items: fixed Wyvern,
  Bandit, Umbral, Mithril, and Bejeweled stat checks plus preserved effect-hook
  checks.
- `project/scripts/tools/run_balance_suite.gd` produces a passing report with
  53 mechanics checks, 17 scenarios, 2600 sampled seeds, and no warnings or
  failures after the T6 stale-expectation refresh.
- No new Balance Lab scenario tuning or broader Legendary redesign was added;
  P5M11 remains responsible for wider validation and future item redesign.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/training_room_gear_editor_test.gd` passed with `Practice Room gear editor check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/training_room_build_test.gd` passed with `Practice Room build controls check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/training_room_fight_setup_test.gd` passed with `Practice Room fight setup check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_practice_room_combat_smoke_test.gd` passed with `P5M4 Practice Room combat smoke: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_presentation_equip_test.gd` passed with `P5M10 Legendary presentation/equip: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_regression_test.gd` passed with `P5M10 Legendary regression: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd` passed with `Balance Lab test: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://scripts/tools/run_balance_suite.gd` passed with Balance Lab report status `pass`, `70 pass`, `0 warn`, and `0 fail`.
- The first sandboxed Godot verification attempts hit the known `user://logs`
  crash before test execution; rerunning with normal filesystem access resolved
  them.
- Godot emitted the accepted ObjectDB/RID/resource cleanup warnings at process
  exit during the passing runs.

## P5M10-T8 Docs And Closeout Notes

Status: Complete.

Completed 2026-09-06. P5M10 is closed as the current retained Rogue Legendary
baseline for Phase 5.

Final implementation summary:

- Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril Karambit, and Bejeweled
  Push Dagger remain named Rogue `Weapon` / `Dagger` items with
  `GearItem.Tier.LEGENDARY`, `GearItem.SourceKind.LEGENDARY`, authored icons,
  catalog membership, and the tier-driven 21-27 Legendary weapon damage range.
- Each retained Legendary now uses explicit canonical Phase 5 fixed stats from
  the locked target packages in `docs/New_Gear_Overview.md`.
- Existing build-defining Legendary effects are preserved: Wyvern poison tick
  speed, Bandit gold-to-damage scaling, Umbral Death Strike unlock, Mithril
  source-filtered Stab/Heavy Slash retriggers, and Bejeweled minimum-cast-time
  proc chance.
- Player-facing item cards, comparison tooltips, inventory/equipment behavior,
  reward choice auto-equip, Practice Room selection, authored icon overrides,
  save/load compatibility, generator boundaries, and Balance Lab validation are
  covered by focused regression.

Tuning and scope notes:

- P5M10 shipped the documented target values exactly; no Legendary value
  retuning beyond replacing stale pre-P5M10 expectations was needed.
- Balance Lab control thresholds for the baseline Rogue Stab and Defense Block
  scenarios were refreshed to the current deterministic baseline after the
  Legendary package update.
- No new Legendary reward/drop/shop system was added. Existing fixed-catalog
  shop/reward behavior remains a regression boundary.
- Broad Legendary redesign, new Legendary identities, cross-class Legendary
  rules, and deeper talent-synergy Legendary work remain deferred to the later
  talent-tree redesign.
- P5M11 now owns broad Practice Room and Balance Lab validation of the whole
  Phase 5 gear rule surface, including generator outputs, stat aggregation,
  weapon rolls, drawbacks, damage order, stack/cap/floor behavior, Special
  conflicts, save/load replay, generated combat compatibility, retrigger risk,
  deterministic replay expectations, and remaining balance watch items.

Docs updated for closeout:

- `docs/P5M10_Legendary_Revisit_And_Fixed_Legendary_Stats_Tracker.md`
- `docs/Project_Onboarding_Context.md`
- `docs/P5_Gear_Redesign_Overview.md`
- `docs/Project_Overview.md`
- `docs/New_Gear_Overview.md`

Final verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_combat_effects_test.gd` passed with `P5M10 Legendary combat effects: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_presentation_equip_test.gd` passed with `P5M10 Legendary presentation/equip: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m10_legendary_regression_test.gd` passed with `P5M10 Legendary regression: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/training_room_gear_editor_test.gd` passed with `Practice Room gear editor check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/balance_lab_test.gd` passed with `Balance Lab test: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://scripts/tools/run_balance_suite.gd` passed with Balance Lab report status `pass`, `70 pass`, `0 warn`, and `0 fail`.
- Godot emitted the accepted ObjectDB/RID/resource cleanup warnings at process
  exit during the passing runs. Sandboxed Godot launches may still crash before
  test execution when they cannot open `user://logs`; rerun with normal
  filesystem access when that happens.

## Status Definitions

- `Ready`: The task can be worked now.
- `Blocked`: The task needs a prior task output, implementation decision, or
  design clarification before it can be completed.
- `In Progress`: The task is actively being audited, edited, implemented, or
  reviewed.
- `Complete`: The task output has been added, verified, and recorded.

## Open Decisions

- No P5M10 decisions remain open. The broader Legendary redesign and full
  validation/tuning pass remain deferred as explicit later-scope work.

## Completion Notes

- P5M10-T1 completed 2026-09-06. Existing Legendary resources, catalog
  membership, authored icon overrides, save/load paths, reward/shop boundaries,
  Practice Room hooks, Balance Lab hooks, and combat effect wiring were audited
  before item-definition changes.
- P5M10-T2 completed 2026-09-06. Fixed Rogue Legendary stat packages are locked
  to the documented target values exactly, with canonical stat IDs and preserved
  effect metadata recorded for T3 implementation.
- P5M10-T3 completed 2026-09-06. The five retained Rogue Legendary `.tres`
  resources now use fixed canonical Phase 5 stat packages while preserving
  named identity, authored icons, catalog membership, tier-driven 21-27 weapon
  damage, and existing bespoke Legendary effect metadata.
- P5M10-T4 completed 2026-09-06. Added focused all-five Legendary combat-effect
  validation, updated stale integrated Legendary reward expectations to the new
  fixed packages, and verified the preserved effect hooks through focused
  headless Godot tests.
- P5M10-T5 completed 2026-09-06. Added focused all-five Legendary
  presentation/equip validation and verified item-card text, authored icon
  overrides, reward auto-equip, inventory/equipment behavior, comparison
  tooltip routing, and Practice Room Legendary selection.
- P5M10-T6 completed 2026-09-06. Added focused all-five Legendary regression
  coverage for fixed stat packages, effect metadata, current and legacy
  save/load paths, catalog/generator boundaries, and icon overrides; refreshed
  Balance Lab Legendary expectations and stale control thresholds/assertions.
- P5M10-T7 completed 2026-09-06. Strengthened existing validation surfaces so
  Practice Room explicitly proves all-five retained Legendary dropdown
  selection/inspection and Balance Lab explicitly reports every P5M10
  Legendary mechanics check, with broader Legendary validation still deferred
  to P5M11.
- P5M10-T8 completed 2026-09-06. Closed the milestone docs, updated onboarding
  and Phase 5 overview state, recorded final verification and known
  non-blockers, and handed off the next work to P5M11 broad Practice Room and
  Balance Lab validation.
