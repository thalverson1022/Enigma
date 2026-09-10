# P5M5: Gear Generator And Rarity Rules Tracker

## Status

Complete.

P5M5 finishes when the Phase 5 gear model can produce valid deterministic
procedural items from the documented rarity, slot-pool, stat-count, value
scaling, drawback, Unique Special, and Legendary-boundary rules. This milestone
turns the completed P5M2 gear data model, P5M3 stat foundation, and P5M4 weapon
damage ranges into the generator baseline that Shop Lab, Adventure rewards,
shops, item presentation, Legendary revisit, and full validation will build on.

P5M5 is not the final shop economy, reward integration, item-card presentation,
art pass, final Legendary tuning, or full balance pass. Those remain assigned to
later Phase 5 milestones.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone document:

- `docs/P5_Gear_Redesign_Overview.md`

Previous milestone tracker:

- `docs/P5M4_Weapon_Damage_Scaling_Tracker.md`

## Exit Criteria

- Current gear generator behavior, callers, tests, and old Basic/Master/Cursed
  assumptions have been audited and mapped.
- Procedural gear generation has an explicit deterministic input and output
  contract for slot, rarity, seed/key, optional contract-depth scaling, source
  metadata, and generated item metadata.
- Crude remains reserved for the starting dagger and is not produced by normal
  procedural generation.
- Basic, Master, Epic, Cursed, Chaos, and Unique items use the documented
  stat-count rules.
- Slot-aware weighted stat selection uses `StatCatalog` Basic, Rare, Special,
  and drawback pools for Weapon, Helm, Armor, Trinket, and Charm.
- Generated items select only positive-weight entries and never select disabled
  `weight: 0` entries.
- Generated non-Chaos items cannot roll duplicate `stat_id` values on the same
  item, including positive/drawback collisions and Special rolls. Chaos is the
  current deliberate exception and may duplicate stat IDs across all four rolls.
- Impossible unique-roll requests fail loudly through validation or an explicit
  invalid-result path instead of silently duplicating stats.
- Numeric stat values roll from documented slot/stat baseline ranges, apply
  rarity value multipliers, apply the deterministic contract-depth scaling hook,
  and round once according to stat value kind.
- Special stats remain fixed binary effects unless their text defines a fixed
  constant.
- Cursed items roll 2 Basic stats, 1 Rare stat, and 1 slot-eligible Basic-stat
  drawback at the documented drawback multiplier.
- Chaos items roll 5 outcomes that may be positive Basic/Rare stats or
  slot-eligible Basic-stat drawbacks, including all-positive, all-drawback, and
  repeated-same-stat outcomes.
- Unique items roll 3 Basic stats, 1 Rare stat, and exactly 1 slot-eligible
  Special stat.
- Legendary generation is bounded to fixed catalog selection or a clear P5M10
  stub; Legendary stats are never procedurally rolled.
- Lucky Coin and fixed compatibility gear remain excluded from procedural gear,
  reward, and shop pools unless a later milestone creates an explicit source.
- Focused generator regression checks cover determinism, rarity counts, slot
  eligibility, weights, value scaling, drawbacks, Chaos outcomes, Unique
  Specials, Crude exclusion, Legendary boundary, Lucky Coin exclusion,
  save/load metadata, and compatibility callers.
- Phase 5 milestone docs are updated with P5M5 completion notes and handoff
  items for P5M6+.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M5-T1: Audit Current Gear Generator | Complete | Map current `GearGenerator`, tests, save/load expectations, reward/shop callers, Practice Room custom gear, and old Basic/Master/Cursed assumptions before changing generator behavior. | Completed 2026-09-04. Audit notes below classify active generator assumptions as Keep, Migrate, Defer, or Open Decision and identify the code/test surfaces each later P5M5 task must touch. |
| P5M5-T2: Define Generator Inputs And Output Contract | Complete | Lock the public API for deterministic item generation before expanding rarity behavior. | Completed 2026-09-04. `GearGenerator.generate_from_request()` now accepts slot, rarity/tier, RNG or seed, deterministic key/id, optional contract depth/value scale, and source metadata, returning a structured result while the legacy `generate()` wrapper remains compatible. |
| P5M5-T3: Implement Rarity Stat-Count Rules | Complete | Encode the documented Basic, Master, Epic, Cursed, Chaos, and Unique roll structures while keeping Crude starter-only. | Completed 2026-09-04. `GearGenerator.rarity_roll_plan()` now defines fixed procedural roll shapes for Basic, Master, Epic, Cursed, and Unique plus variable Chaos metadata; generated Crude and Legendary requests remain rejected through the request contract. |
| P5M5-T4: Implement Slot-Aware Weighted Stat Selection | Complete | Replace the old global affix pool with `StatCatalog` slot/category pools and weights. | Completed 2026-09-04. `StatCatalog` now carries the documented provisional slot/category weights and `GearGenerator` uses deterministic cumulative weighted selection while excluding zero-weight and already-used entries. |
| P5M5-T5: Enforce Unique Stat IDs Per Item | Complete | Prevent duplicate stat identities from making generated items ambiguous or invalid. | Completed 2026-09-04. Generation now preflights roll plans against canonical positive-weight stat IDs, reserves one ID per roll, rejects impossible plans before item construction, and keeps the picker canonicalized against already-used IDs. |
| P5M5-T6: Implement Stat Value Rolling And Scaling | Complete | Generate numeric values from documented ranges and multipliers. | Completed 2026-09-04. Numeric Basic/Rare affixes now roll from slot/stat baselines, apply rarity and request scaling, keep the contract-depth hook, round once by value kind, and leave Specials as fixed binary values. |
| P5M5-T7: Implement Cursed Drawbacks | Complete | Make Cursed items follow the high-power-plus-drawback model. | Completed 2026-09-04. Cursed generation now has a named roll plan and focused validation proving 2 Basic positives, 1 Rare positive, and 1 valid negative Basic-stat drawback with no stat collision across every slot. |
| P5M5-T8: Implement Chaos Gamble Rules | Complete | Make Chaos items behave like the documented unsafe gamble. | Completed 2026-09-04 and updated after playtesting. Chaos items now roll four seeded valid outcomes from positive Basic/Rare or Basic drawback options, exclude Specials, may duplicate stat IDs, and can produce all-positive, mixed, all-drawback, or repeated-same-stat results. |
| P5M5-T9: Implement Unique Special Rolls | Complete | Add Unique-only Special stat generation on top of normal positive rolls. | Completed 2026-09-04. Unique generation now has a named roll plan, always includes 3 Basic positives, 1 Rare positive, and exactly 1 eligible binary Special, and focused tests verify slot eligibility, determinism, stat-sheet bridging, and impossible-plan failures. |
| P5M5-T10: Define Legendary Generator Boundary | Complete | Prevent procedural Legendary stat packages from entering the item model early. | Completed 2026-09-04. Legendary is now explicitly fixed-catalog-only for generator contracts: procedural requests fail loudly, fixed catalog/shop/reward paths remain valid, and generated offers never roll Legendary stat packages. |
| P5M5-T11: Preserve Lucky Coin And Fixed Gear Exclusions | Complete | Keep scripted and compatibility gear out of random item pools. | Completed 2026-09-04. Focused coverage now proves Lucky Coin, placeholder compatibility gear, retained Legendaries, and fixed authored rewards stay out of procedural generation while their explicit fixed/catalog reward paths remain valid. |
| P5M5-T12: Add Focused Generator Regression Tests | Complete | Prove the full P5M5 generator surface before Shop Lab and Adventure depend on it. | Completed 2026-09-04. Added consolidated generator regression coverage for deterministic output, rarity counts, slot eligibility, no duplicates, value scaling, Cursed, Chaos, Unique, Crude/Legendary/source boundaries, Lucky Coin/fixed gear exclusion, save/load metadata, and shop/reward callers. |
| P5M5-T13: Update Milestone Docs And Review | Complete | Record the completed generator baseline and hand off cleanly to P5M6. | Completed 2026-09-04. This tracker and `docs/P5_Gear_Redesign_Overview.md` now record the P5M5 completion baseline, final verification evidence, known non-blockers, resolved/deferred decisions, and remaining P5M6+ handoff items. |

## P5M5-T1 Audit Steps

P5M5-T1 should produce a concrete generator assumption map before implementation
begins.

1. Confirm current workspace identity, active branch, and that P5M4 is the
   current implementation baseline.
2. Inventory active gear generation code, including `GearGenerator`,
   `StatCatalog`, `GearItem`, `StatModifier`, `WeaponDamageCatalog`, and helper
   formatting or metadata paths.
3. Trace every generator caller, including rewards, shops, generated route
   previews, save/load restored runtime gear, Practice Room custom gear, tests,
   and debug/tool paths.
4. Identify all remaining old global-affix-pool behavior, old rarity subset
   behavior, old price/tier assumptions, and any Basic/Master/Cursed-only test
   assumptions.
5. Trace how generated item identity, source metadata, deterministic keys,
   source seeds, item family, slot, rarity, and stat metadata are serialized.
6. Confirm how slot/category eligibility, weights, value kinds, floors, caps,
   drawback pools, and Special IDs are exposed by `StatCatalog`.
7. Trace how weapon rarity maps to `WeaponDamageCatalog` so generated weapon
   rarity produces the expected combat-facing range.
8. Identify validation behavior needed for impossible unique-roll requests,
   zero-total pools, disabled-stat selection, invalid slot/category pairings,
   and duplicate stat IDs.
9. Trace Lucky Coin, placeholder dagger, retained Rogue Legendaries, and fixed
   authored gear so P5M5 does not accidentally add them to random pools.
10. Classify every finding as Keep, Migrate, Defer, or Open Decision, with the
    downstream P5M5 task each finding affects.

## P5M5-T1 Audit Findings

Completed 2026-09-04.

Current workspace identity:

- Local path: `F:\Data\Claude Projects\Project-Enigma`.
- Branch: `phase-5-gear-redesign`, tracking `origin/phase-5-gear-redesign`.
- Remote: `https://github.com/thalverson1022/Enigma.git`.
- Baseline: P5M4 is documented complete and the workspace contains the P5M2
  gear model, P5M3 `StatCatalog`/`StatSheet` foundation, and P5M4
  `WeaponDamageCatalog` weapon ranges needed for P5M5.
- Worktree note: the repo already contains many modified and untracked Phase 5
  files from the completed P5M1-P5M4 work. Treat them as the current working
  baseline unless a later task proves a direct conflict.

| Finding | Evidence | Classification | Downstream |
| --- | --- | --- | --- |
| `GearGenerator` is still the right implementation home for P5M5; no separate generator class is required by the audit. | `project/scripts/systems/gear_generator.gd` already owns generated item construction, tier/slot display helpers, prices, source metadata, and seeded offer helpers. | Keep/Migrate | P5M5-T2+ |
| The current generator entrypoint is too narrow for the P5M5 contract. | `GearGenerator.generate(tier, slot, rng, stable_id)` accepts only tier, slot, RNG, and optional stable id; it does not accept source context, source seed, contract depth/value scale, or return validation status. | Migrate | P5M5-T2 |
| Generated item metadata is partially present but under-filled. | Generated items stamp `source_kind = GENERATED`, `deterministic_key = stable_id`, Rogue `item_family`, and generated id, but leave `source_context` empty and `source_seed = 0`. | Migrate | P5M5-T2, T12 |
| Five universal slots are active and should remain the generator slot surface. | `GearGenerator.ALL_SLOTS`, `GearGenerator.PHASE5_ALL_SLOTS`, and `GearItem.universal_slot_order()` contain Weapon, Helm, Armor, Trinket, and Charm. | Keep | P5M5-T2, T4 |
| Full Phase 5 rarity vocabulary exists, but active rolling remains a Basic/Master/Cursed compatibility subset. | `GearItem.Tier` and `GearGenerator.PHASE5_ALL_TIERS` include Crude, Basic, Master, Epic, Cursed, Chaos, Unique, Legendary; `ACTIVE_GENERATED_TIERS` contains only Basic, Master, Cursed. | Migrate | P5M5-T3, T10 |
| Crude is only vocabulary today, not actively generated by offer pools. | `ACTIVE_GENERATED_TIERS` excludes Crude; `WeaponDamageCatalog` has a Crude fallback and range. Direct calls to `GearGenerator.generate(CRUDE, ...)` currently produce an empty-affix item instead of rejecting it. | Migrate | P5M5-T3, T10, T12 |
| Legendary gear is fixed authored data today, but the live shop can still roll Legendaries before P5M10. | `BuildState._shop_tier_for_current_phase()` has a Legendary weight and `_shop_offer_for_tier()` loads from `LegendaryCatalog`; docs say new Legendary shop/drop behavior should wait for P5M10 except regression content. | Open Decision | P5M5-T10, T11, P5M7 |
| Current rarity stat-count behavior is old: Basic 1 Basic, Master 2 Basic, Cursed 2 positive Basic plus 1 drawback. | `GearGenerator._affixes_for_tier()` has branches only for Basic/Master/Cursed and returns no affixes for Epic/Chaos/Unique/Legendary/Crude. | Migrate | P5M5-T3, T7, T8, T9 |
| Cursed shape is close in count but wrong in category/value rules. | Current Cursed uses one amplified Basic, one Master-value Basic, and one old downside; P5M5 requires 2 Basic positives, 1 Rare positive, and 1 Basic-stat drawback with documented multipliers. | Migrate | P5M5-T3, T6, T7 |
| Current generator uses old global enum pools rather than slot/category pools. | `AFFIX_POOL` and `DOWNSIDE_POOL` are arrays of legacy `StatModifier.StatType`; slot is ignored while rolling affixes. | Migrate | P5M5-T4, T5 |
| `StatCatalog` is ready to be the authoritative pool source, but its weights are still placeholders. | `StatCatalog.SLOT_CATEGORY_POOLS` exposes Basic/Rare/Special pools per slot, `pool_for_slot()`, `weight_for_slot()`, `is_stat_enabled_for_slot()`, and drawback helpers; every current pool entry uses `DEFAULT_POOL_WEIGHT = 1` rather than the documented 5/10/15/20 weights. | Migrate | P5M5-T4, T6, T12 |
| Disabled `weight: 0` behavior is supported by API shape but has no active test through generation. | `pool_for_slot()` clamps weights to non-negative values and `is_stat_enabled_for_slot()` checks `weight > 0`; generator never reads these APIs yet. | Migrate | P5M5-T4, T12 |
| Same-item duplicate prevention currently exists only inside individual old-category picks. | `_pick_distinct()` prevents duplicate legacy stats within one pool draw; no shared canonical `stat_id` exclusion spans Basic/Rare/Special/drawback rolls or Chaos mixed outcomes. | Migrate | P5M5-T5, T7, T8, T9 |
| Impossible unique-roll, zero-total-pool, invalid slot/category, and disabled-stat failure modes are currently silent or unreachable. | `_pick_distinct()` returns fewer entries if the pool is too small; `_affixes_for_tier()` assumes enough stats in Basic/Master/Cursed paths; no validation object or invalid-result path exists. | Open Decision | P5M5-T2, T4, T5, T12 |
| Numeric stat values are fixed tables, not deterministic range rolls. | `BASIC_VALUE`, `MASTER_VALUE`, `CURSED_AMPLIFIED_VALUE`, and `CURSED_DOWNSIDE_VALUE` store one value per legacy enum stat; P5M5 requires slot/stat baseline ranges, rarity multipliers, depth scaling, and one final rounding rule. | Migrate | P5M5-T6 |
| Current generated `StatModifier` output still depends on legacy enum operation semantics. | `_make_modifier()` stamps canonical `stat_id` through `StatCatalog.legacy_stat_id()`, but also sets legacy `stat`, `operation`, and values such as physical damage multiplier `1.08`/`0.92`. | Migrate | P5M5-T6, T12 |
| `StatModifier` can carry P5M5 metadata without a new resource type. | `StatModifier` has `stat_id`, `category`, `is_drawback`, and `display_label`, and `StatSheet` consumes canonical IDs and drawback flags. | Keep | P5M5-T2, T6 |
| `GearItem` can carry generated item contract metadata without a new item type. | `GearItem` already has slot, tier, item family, class family, source kind/context/seed, deterministic key, and affixes. | Keep | P5M5-T2 |
| Save/load already serializes runtime generated gear metadata needed by P5M5. | `SaveSystem._gear_entry_to_data()` writes id, slot, tier, family, source kind/context/seed, deterministic key, and affix `stat_id`, category, operation, value, `is_drawback`, and display label. | Keep/Migrate | P5M5-T2, T6, T12 |
| Save/load has an explicit old-runtime-gear quarantine boundary that P5M5 should preserve. | `SaveSystem._gear_from_save_entry()` drops obsolete runtime gear without `source_kind`, validates slot/tier/source kind, and migrates canonical authored gear by id. | Keep | P5M5-T11, T12 |
| Generated route rewards are metadata-only until claimed. | `ContractRouteGenerator._assign_generated_reward()` stores `generated_gear_choice_count`, `generated_gear_tier`, and `generated_gear_slots`; `BuildState._gear_choices_for_reward()` materializes actual items later. | Keep/Migrate | P5M5-T2, P5M7 |
| Generated route reward tiers still use only Basic/Master/Cursed. | `_reward_gear_tier_for_difficulty()` returns Basic, Master, or Cursed based on difficulty/role. | Defer | P5M7 |
| Reward slot selection already uses the five-slot generator pool. | `_reward_gear_slots()` builds its pool from `GearGenerator.ALL_SLOTS`; bosses expose all five slots, elites two, normal nodes one. | Keep | P5M5-T4, P5M7 |
| Reward and shop uniqueness signatures are legacy-stat based. | `BuildState._shop_offer_signature()` and `_generated_reward_stat_signature()` serialize `affix.stat`, `affix.operation`, and value, not canonical `stat_id`, category, drawback flag, or Special identity. | Migrate | P5M5-T5, T8, T9, T12 |
| Shop determinism and reward determinism have good seed hooks to keep. | `BuildState._generate_tavern_shop_offers()` and `_generate_reward_choice_item()` derive stable IDs from `RunRng` contexts using adventure seed, reward/shop context, roll key, choice index, attempt, and slot. | Keep/Migrate | P5M5-T2, T12 |
| `GearGenerator.generate_offers()` is a legacy standalone helper. | It seeds a local RNG and rolls active Basic/Master/Cursed tiers with no run/reward/shop context; current live shops use `BuildState` instead. | Migrate/Defer | P5M5-T2, T12 |
| Practice Room custom gear is intentionally still Basic/Master/Cursed and old-pool editable. | `TrainingRoomState._affix_slot_count()`, `_pool_for_slot()`, and `_tier_value()` depend on `GearGenerator.AFFIX_POOL`, `DOWNSIDE_POOL`, and fixed value tables. | Open Decision | P5M5-T3, T4, T6, P5M11 |
| Practice Room Legendary equip bypasses generation and should remain fixed-catalog behavior. | `TrainingRoomState.equip_legendary()` equips a selected `LegendaryCatalog` item into the weapon slot. | Keep | P5M5-T10, P5M11 |
| Weapon rarity integration is ready once generated weapon tiers are correct. | `WeaponDamageCatalog` defines ranges for every Phase 5 rarity and `BuildResolver` bridges equipped weapon range into `PlayerStats`; P5M5 only needs to emit the intended Weapon-slot rarity. | Keep | P5M5-T3, T10, T12 |
| Lucky Coin is fixed authored gear, not a generated item. | `project/data/gear/lucky_coin.tres` is `source_kind = FIXED`; Drunk Buddy grants it as a fixed reward; post-P5M9 playtest rules make it a Basic Trinket/Ring with canonical Crit Chance. | Keep | P5M5-T11, T12 |
| Placeholder dagger is compatibility/starter gear, not normal procedural output. | `project/data/gear/placeholder_dagger.tres` uses `source_kind = COMPATIBILITY`; Crude should remain reserved for the starting dagger path. | Keep/Migrate | P5M5-T3, T11 |
| Retained Rogue Legendaries are fixed authored resources. | `LegendaryCatalog.all_paths()` lists Wyvern Kriss, Mithril Karambit, Bandit Blade, Umbral Stiletto, and Bejeweled Push Dagger; each resource has `source_kind = LEGENDARY`. | Keep | P5M5-T10, T11 |
| UI/tool helpers are rarity-safe but not final item presentation. | `GearGenerator.tier_name()`/`tier_color()`, `gear_icons.gd`, overlays, and generated route inspector tolerate all Phase 5 rarity labels/icons. | Keep/Defer | P5M5-T12, P5M8 |
| Browser Shop Lab remains quarantined and still reflects old standalone logic. | `tools/shop-lab/README.md` marks it as quarantined until P5M6; `tools/shop-lab/app.js` has its own simulation separate from Godot `GearGenerator`. | Defer | P5M6 |
| Existing generator tests mostly assert the old compatibility model. | `gear_generator_test.gd`, `training_room_gear_editor_test.gd`, `run_rng_context_test.gd`, reward/shop UI tests, and P5M2 quarantine tests assert Basic/Master/Cursed counts, old pools/tables, prices, deterministic shop/reward signatures, and the active tier subset. | Migrate | P5M5-T12 |

T1 implementation guidance:

- Preserve the existing `GearItem` and `StatModifier` data resources. The audit
  found enough metadata support for P5M5 without creating a parallel item type.
- Expand `GearGenerator.generate()` into a deterministic request/result contract
  before changing rarity behavior. Include slot, rarity, seed/key, optional
  contract depth or value scale, source metadata, and a loud invalid-result path
  for impossible generation.
- Move stat selection to `StatCatalog` pools first, then replace the placeholder
  weights with the documented P5M1 weight values.
- Build one canonical `stat_id` exclusion set per generated item and use it
  across Basic, Rare, Special, drawback, and Chaos rolls.
- Replace fixed legacy value tables with slot/stat baseline range rolls plus
  rarity multiplier, depth multiplier, and one final rounding point.
- Preserve live reward/shop seed contexts and stable IDs, but update uniqueness
  signatures to canonical stat metadata.
- Keep Lucky Coin, placeholder dagger, and retained Rogue Legendaries outside
  procedural stat rolling. Legendary requests should route to fixed catalog
  selection or an explicit P5M10 stub.
- Decide during P5M5-T2 whether Practice Room custom rarity editing should be
  migrated now to the new generator request contract or left as a named
  compatibility editor until P5M11.

## P5M5-T2 Generator Contract Notes

Completed 2026-09-04.

Implemented generator request/result contract:

- Added `GearGenerator.generate_from_request(request: Dictionary)`, returning a
  structured result with `ok`, `item`, `errors`, and normalized `request`.
- The request accepts `slot`, `tier` or `rarity`, either `rng` or deterministic
  `seed`, optional `id`, optional `deterministic_key`, `source_context`,
  `source_seed`, `contract_depth`, and `value_scale`.
- `GearGenerator.generate()` remains as the compatibility wrapper for existing
  tests and callers that still pass `(tier, slot, rng, stable_id)`.
- Added `GearGenerator.stat_roll_key(deterministic_key, roll_index, purpose)`
  as the stable per-stat key format for later P5M5 value/stat rolling tasks.
- Generated item metadata is now stamped consistently with id, slot, tier,
  Rogue item family, class family, generated source kind, source context,
  source seed, and deterministic key.

Implemented validation boundary:

- Invalid slot and invalid rarity requests return `ok = false` and no item.
- Procedural Crude requests return `crude_is_starter_only`.
- Procedural Legendary requests return `legendary_requires_fixed_catalog`.
- Non-generated `source_kind` requests return `procedural_source_kind_required`.
- Non-positive `value_scale` requests return `invalid_value_scale`.
- T2 does not yet validate zero-total stat pools or impossible unique stat
  requests because full slot-aware stat selection begins in T4/T5. The new
  result contract gives those tasks a loud failure path.

Updated live callers without changing final rarity tuning:

- `BuildState._shop_offer_for_tier()` now calls the request API for generated
  shop items and stamps `shop_offer:<reward_context>` source context plus the
  Adventure seed.
- Generated shop Legendary fallback still creates a Cursed item, now through
  the request API with explicit fallback source context.
- `BuildState._generate_reward_choice_item()` now calls the request API and
  stamps `reward_choice:<reward_context>` source context plus the Adventure
  seed.
- Shop/reward duplicate signatures now use canonical `stat_id`, category,
  operation, drawback flag, and value rather than only legacy enum/value
  triples.
- `GearGenerator.generate_offers()` remains a legacy standalone helper, but now
  uses the request API and stamps standalone offer metadata.

Compatibility and scope notes:

- The active rarity behavior is intentionally unchanged in T2: Basic, Master,
  and Cursed still use the old compatibility affix counts and fixed values
  until P5M5-T3/T6.
- Practice Room custom gear remains on the named Basic/Master/Cursed
  compatibility editor for now. It still uses `GearGenerator.AFFIX_POOL`,
  `DOWNSIDE_POOL`, and fixed value tables; full Practice Room migration remains
  an implementation choice for P5M5 later tasks or P5M11.
- Legendary fixed catalog selection remains in `LegendaryCatalog` and the
  existing live shop path. P5M5-T10 formalizes that this path may select fixed
  authored Legendaries, while procedural Legendary stat rolling remains
  rejected.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_generator_contract_test.gd`
  passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/p5m2_gear_data_shape_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T3 Rarity Stat-Count Notes

Completed 2026-09-04.

Implemented procedural rarity count rules:

- Added `GearGenerator.rarity_roll_plan(tier)` as the explicit source of truth
  for P5M5 procedural rarity shape.
- Expanded `GearGenerator.ACTIVE_GENERATED_TIERS` to Basic, Master, Epic,
  Cursed, Chaos, and Unique. Crude remains starter-only and Legendary remains
  fixed-catalog-only.
- Basic rolls 1 Basic stat.
- Master rolls 2 Basic stats.
- Epic rolls 2 Basic stats and 1 Rare stat.
- Cursed rolls 2 Basic positives, 1 Rare positive, and 1 Basic-stat drawback.
- Chaos exposes variable roll metadata; P5M5-T8 owns item-specific outcome
  selection so generated Chaos items can produce all-positive, mixed, or
  all-drawback results.
- Unique rolls 3 Basic stats, 1 Rare stat, and 1 Special stat.

Implementation notes:

- `GearGenerator.generate_from_request()` now builds affixes from the roll plan
  and slot/category pools exposed by `StatCatalog`.
- Generated affixes stamp canonical `stat_id`, P5M5 category, drawback flag, and
  display label. P5M5-T6 replaces the temporary T3 numeric placeholders with
  documented ranges, rarity multipliers, request scaling, and rounding.
- A shared per-item `stat_id` exclusion set is already used while satisfying the
  roll plan so T5 can formalize impossible-roll validation without changing the
  public shape again.
- Practice Room custom gear remains the named compatibility editor for now. Its
  Basic/Master/Cursed custom affix counts are intentionally unchanged by T3.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_rarity_stat_count_test.gd`
  passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T4 Slot-Aware Weighted Selection Notes

Completed 2026-09-04.

Implemented slot-aware weighted selection:

- Updated `StatCatalog.SLOT_CATEGORY_POOLS` from equal placeholder weights to
  the documented provisional 5/10/15/20 weight tables in
  `docs/New_Gear_Overview.md`.
- `GearGenerator._pick_stat_id_from_pool()` now performs deterministic
  cumulative weighted selection from eligible entries.
- Positive Basic, Rare, and Special rolls use the generated item's
  slot/category pool.
- Drawback rolls use the item's slot-specific Basic drawback pool.
- Entries with `weight <= 0` are excluded from random selection.
- Already-used `stat_id` values are excluded before computing total weight, so
  weighted selection respects the same-item uniqueness path that P5M5-T5 will
  formalize.
- Zero-total or fully exhausted pools return an empty selection, which flows
  through `generate_from_request()` as an `insufficient_<category>_pool:<slot>`
  error instead of silently selecting invalid stats.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_weighted_stat_selection_test.gd`
  passed. The focused deterministic sample selected a 99-weight entry 495 times
  and a 1-weight entry 5 times across 500 rolls.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/p5m3_slot_stat_eligibility_test.gd` passed.
- `res://tests/p5m3_stat_catalog_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T5 Unique Stat ID Notes

Completed 2026-09-04.

Implemented same-item unique stat validation:

- Added a preflight validation pass for generated roll plans before affixes are
  built.
- The preflight pass canonicalizes candidate `stat_id` values, filters disabled
  entries, respects already-reserved IDs, and reserves one unique stat for each
  required roll.
- `GearGenerator._pick_stat_id_from_pool()` now canonicalizes selected stat IDs
  before checking the used set, so aliases such as `physical_damage` collide
  correctly with `percent_physical_damage`.
- Positive Basic, Rare, Special, and drawback rolls share the same canonical
  same-item exclusion set.
- Cursed and Chaos drawbacks cannot roll a stat that has already rolled
  positive on the same item.
- Unique Specials cannot duplicate any other stat identity on the same item.
- Impossible roll plans return no partial affixes and emit
  `insufficient_<category>_pool:<Slot>` errors.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_unique_stat_ids_test.gd`
  passed.
- `res://tests/p5m5_weighted_stat_selection_test.gd` passed.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/p5m3_slot_stat_eligibility_test.gd` passed.
- `res://tests/p5m3_stat_catalog_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T6 Stat Value Rolling Notes

Completed 2026-09-04.

Implemented stat value rolling and scaling:

- Added `StatCatalog.SLOT_VALUE_RANGES` for the documented Basic and Rare
  baseline ranges in `docs/New_Gear_Overview.md`.
- Added `StatCatalog.value_range_for_slot(slot, stat_id)` so generator and
  validation code can query slot/stat baseline values from the catalog.
- Replaced generated numeric placeholder values with deterministic range rolls.
- Numeric generated affixes now roll a base value from the slot/stat baseline
  range, apply the rarity multiplier, apply request `value_scale`, apply the
  contract-depth scaling hook, and round once at the end.
- Rarity multipliers now follow the documented first-pass values: Basic 1.00x,
  Master 1.75x, Epic 2.00x, Cursed positive/drawback +/-2.50x,
  Chaos positive/drawback +/-3.00x, and Unique 2.00x.
- Contract-depth scaling is implemented as a deterministic hook returning
  1.00x until later tuning changes it.
- Flat and stack values round to whole numbers. Positive stack rolls are never
  below +1 after rounding.
- Percent and chance values remain decimal internally and round to whole
  percentage points.
- Specials remain fixed binary values of 1.0 and do not consume numeric range
  rolls or scaling.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_stat_value_scaling_test.gd`
  passed.
- `res://tests/p5m5_unique_stat_ids_test.gd` passed.
- `res://tests/p5m5_weighted_stat_selection_test.gd` passed.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/p5m3_slot_stat_eligibility_test.gd` passed.
- `res://tests/p5m3_stat_catalog_test.gd` passed.
- `res://tests/p5m3_stat_sheet_aggregation_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/p5m4_base_damage_physical_buckets_test.gd` passed.
- `res://tests/p5m4_weapon_scaling_percentages_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T7 Cursed Drawback Notes

Completed 2026-09-04.

Implemented and validated the Cursed drawback contract:

- Added `GearGenerator.cursed_roll_plan()` as the named source for Cursed item
  shape.
- `GearGenerator.rarity_roll_plan(GearItem.Tier.CURSED)` now delegates to that
  Cursed-specific plan.
- Cursed items roll exactly 2 Basic positive stats, 1 Rare positive stat, and 1
  Basic-stat drawback.
- The Cursed drawback uses `StatCatalog.drawback_pool_for_slot(slot)`, so it is
  always a slot-eligible Basic stat with drawback support.
- The drawback affix is stamped with `category = DRAWBACK` and
  `is_drawback = true`.
- Rare and Special stats are not eligible as Cursed drawbacks.
- The same-item stat ID preflight from P5M5-T5 prevents Cursed positive/drawback
  stat collisions.
- The T6 value path applies the documented Cursed drawback multiplier of
  `-2.50x`; focused coverage verifies drawback values are negative and inside
  the scaled slot/stat range.
- Exhausted drawback pools fail with `insufficient_drawback_pool:<Slot>` and no
  partial affixes.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_cursed_drawback_test.gd`
  passed.
- `res://tests/p5m5_stat_value_scaling_test.gd` passed.
- `res://tests/p5m5_unique_stat_ids_test.gd` passed.
- `res://tests/p5m5_weighted_stat_selection_test.gd` passed.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/p5m3_slot_stat_eligibility_test.gd` passed.
- `res://tests/p5m3_stat_catalog_test.gd` passed.
- `res://tests/p5m3_stat_sheet_aggregation_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/p5m4_base_damage_physical_buckets_test.gd` passed.
- `res://tests/p5m4_weapon_scaling_percentages_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T8 Chaos Gamble Notes

Completed 2026-09-04.

Implemented and validated the Chaos gamble contract:

- Added Chaos outcome constants for positive Basic, positive Rare, and Basic
  drawback outcomes.
- `GearGenerator.rarity_roll_plan(GearItem.Tier.CHAOS)` now returns variable
  metadata instead of a fixed five-entry category plan.
- Chaos item generation now builds a seeded item-specific plan through
  `GearGenerator.chaos_roll_plan(slot, rng)`.
- Each Chaos roll first picks one eligible outcome from the current outcome
  pool, then selects a slot-aware weighted stat for that outcome.
- Chaos outcome selection excludes outcomes whose stat pool has already been
  exhausted by earlier same-item picks, so normal generated Chaos requests
  still return five valid unique affixes.
- The generated Chaos plan stores the selected stat ID for each outcome, then
  the standard affix path validates and materializes those forced stats. This
  keeps outcome selection deterministic while preserving the shared value
  rolling, category stamping, and duplicate-validation code.
- Chaos Specials remain excluded.
- Chaos drawbacks use slot-eligible Basic stat IDs and stamp
  `category = DRAWBACK`. Post-P5M9 playtest rules intentionally allow Chaos
  rolls to collide with positive stats or other drawbacks on the same item.
- The T6 value path applies the documented Chaos multiplier of `3.00x` for
  positives and `-3.00x` for drawbacks.
- Focused coverage originally verified all-positive, all-drawback, and mixed
  Chaos outputs, deterministic seeded output, slot/category validity, duplicate
  prevention, scaled values, and loud failure for impossible direct roll plans.
  Post-P5M9 playtest rules supersede the duplicate-prevention expectation for
  Chaos only.
- First-pass Chaos outcome weights were equal across Basic positive, Rare
  positive, and Basic drawback outcomes. Post-P5M9 playtest tuning makes Rare
  positive Chaos outcomes 20% lower weight than Basic positive and Basic
  drawback outcomes.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_chaos_gamble_test.gd`
  passed.
- `res://tests/p5m5_cursed_drawback_test.gd` passed.
- `res://tests/p5m5_stat_value_scaling_test.gd` passed.
- `res://tests/p5m5_unique_stat_ids_test.gd` passed.
- `res://tests/p5m5_weighted_stat_selection_test.gd` passed.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/p5m3_slot_stat_eligibility_test.gd` passed.
- `res://tests/p5m3_stat_catalog_test.gd` passed.
- `res://tests/p5m3_stat_sheet_aggregation_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/p5m4_base_damage_physical_buckets_test.gd` passed.
- `res://tests/p5m4_weapon_scaling_percentages_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T9 Unique Special Roll Notes

Completed 2026-09-04.

Implemented and validated the Unique Special contract:

- Added `GearGenerator.unique_roll_plan()` as the named source for Unique item
  shape.
- `GearGenerator.rarity_roll_plan(GearItem.Tier.UNIQUE)` now delegates to that
  Unique-specific plan.
- Unique items roll exactly 3 Basic positive stats, 1 Rare positive stat, and 1
  Special stat.
- Unique Specials use the generated item's slot-specific
  `StatCatalog.CATEGORY_SPECIAL` pool and the shared deterministic weighted
  picker.
- Unique Specials select only positive-weight enabled entries.
- Unique Specials stamp `category = SPECIAL`, never stamp `is_drawback = true`,
  and keep their fixed binary value of `1.0`.
- The shared T5 preflight prevents the Unique Special from duplicating any
  Basic/Rare stat identity on the same item.
- Generated Unique Specials bridge through `BuildResolver` into
  `PlayerStats.special_stat_ids`.
- Impossible Special plans fail with `insufficient_special_pool:<Slot>` and no
  partial affixes.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_unique_special_rolls_test.gd`
  passed.
- `res://tests/p5m5_unique_stat_ids_test.gd` passed.
- `res://tests/p5m5_stat_value_scaling_test.gd` passed.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/p5m3_special_effect_aggregation_test.gd` passed.
- `res://tests/p5m5_chaos_gamble_test.gd` passed.
- `res://tests/p5m5_cursed_drawback_test.gd` passed.
- `res://tests/p5m5_weighted_stat_selection_test.gd` passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/p5m3_slot_stat_eligibility_test.gd` passed.
- `res://tests/p5m3_stat_catalog_test.gd` passed.
- `res://tests/p5m3_stat_sheet_aggregation_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/p5m4_base_damage_physical_buckets_test.gd` passed.
- `res://tests/p5m4_weapon_scaling_percentages_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T10 Legendary Generator Boundary Notes

Completed 2026-09-04.

Implemented and validated the Legendary generator boundary:

- Added `GearGenerator.is_procedural_tier(tier)` to expose the active
  procedural rarity set without callers comparing raw arrays.
- Added `GearGenerator.requires_fixed_catalog(tier)` and routed Legendary
  request validation through it.
- Direct procedural Legendary requests still return `ok = false`, no item, and
  `legendary_requires_fixed_catalog`.
- The legacy `GearGenerator.generate(LEGENDARY, ...)` wrapper returns no item
  because it delegates to the same request validation boundary.
- `GearGenerator.rarity_roll_plan(GearItem.Tier.LEGENDARY)` remains unsupported,
  so no Legendary path can reach random stat-package generation.
- `GearGenerator.generate_offers()` remains limited to active procedural tiers
  and does not roll Legendary.
- Fixed authored Legendary items remain available through `LegendaryCatalog`.
- Shop Legendary rolls continue to select unowned fixed catalog Legendaries.
- If every shop Legendary is already owned, the shop keeps its existing Cursed
  generated fallback instead of duplicating fixed Legendaries or creating a
  procedural Legendary.
- Legendary reward choices continue to sample fixed catalog items from the
  reward's Legendary pool.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_legendary_generator_boundary_test.gd`
  passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/legendary_mechanics_test.gd` passed.
- `res://tests/legendary_reward_test.gd` passed.
- `res://tests/p5m5_unique_special_rolls_test.gd` passed.
- `res://tests/p5m5_chaos_gamble_test.gd` passed.
- `res://tests/p5m5_cursed_drawback_test.gd` passed.
- `res://tests/p5m5_stat_value_scaling_test.gd` passed.
- `res://tests/p5m5_unique_stat_ids_test.gd` passed.
- `res://tests/p5m5_weighted_stat_selection_test.gd` passed.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/p5m3_slot_stat_eligibility_test.gd` passed.
- `res://tests/p5m3_stat_catalog_test.gd` passed.
- `res://tests/p5m3_stat_sheet_aggregation_test.gd` passed.
- `res://tests/p5m3_special_effect_aggregation_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/p5m4_base_damage_physical_buckets_test.gd` passed.
- `res://tests/p5m4_weapon_scaling_percentages_test.gd` passed.
- `res://tests/run_rng_context_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T11 Fixed Gear Exclusion Notes

Completed 2026-09-04.

Implemented and validated fixed gear exclusion boundaries:

- Added focused T11 coverage for Lucky Coin, placeholder compatibility gear,
  retained Rogue Legendaries, generated offers, generated reward choices, and
  fixed reward claims.
- Lucky Coin remains fixed authored gear with `source_kind = FIXED`, Basic
  rarity, Trinket slot, Rogue Ring family, and its fixed +5% Crit Chance affix
  in the current post-P5M9 playtest baseline.
- Drunk Buddy still grants Lucky Coin through the explicit fixed reward path.
- Placeholder Dagger remains `source_kind = COMPATIBILITY` and stays out of
  generated item IDs.
- Retained Rogue Legendaries remain catalog-authored gear with
  `source_kind = LEGENDARY` and the `gear.legendary.*` ID namespace.
- Procedural generation rejects `FIXED`, `LEGENDARY`, and `COMPATIBILITY`
  source kinds with `procedural_source_kind_required`.
- `GearGenerator.generate_offers()` samples only clean generated items from
  active procedural tiers and never emits Lucky Coin, Placeholder Dagger, or a
  catalog Legendary ID.
- Generated reward choices likewise emit clean generated items and do not reuse
  fixed/catalog item identities.
- Explicit fixed/catalog paths remain valid; T11 guards random procedural pools,
  not authored reward or Legendary catalog selection.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_fixed_gear_exclusion_test.gd`
  passed.
- `res://tests/p5m2_lucky_coin_charm_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/p5m5_legendary_generator_boundary_test.gd` passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/p5m5_stat_value_scaling_test.gd` passed.
- `res://tests/p5m5_weighted_stat_selection_test.gd` passed.
- `res://tests/p5m5_unique_stat_ids_test.gd` passed.
- `res://tests/p5m5_chaos_gamble_test.gd` passed.
- `res://tests/p5m5_unique_special_rolls_test.gd` passed.
- `res://tests/p5m5_cursed_drawback_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- `res://tests/encounter_reward_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T12 Focused Generator Regression Notes

Completed 2026-09-04.

Added consolidated P5M5 generator regression coverage:

- Added `project/tests/p5m5_generator_regression_test.gd` as the broad
  generator safety net before Shop Lab and Adventure build on this surface.
- The regression matrix generates every active procedural rarity across every
  universal slot through `GearGenerator.generate_from_request()`.
- Matrix coverage validates generated source metadata, deterministic keys,
  Rogue item-family metadata, display names, active procedural tiers, and fixed
  gear/catalog ID exclusions.
- Matrix coverage also validates rarity/category shapes, canonical stat IDs,
  slot/category eligibility, same-item unique stat IDs, and scaled value ranges.
- Chaos is validated as a four-roll variable outcome item with no Special or
  compatibility affixes.
- Unique is validated as 3 Basic positives, 1 Rare positive, and 1 binary
  slot-eligible Special.
- Cursed is validated as 2 Basic positives, 1 Rare positive, and 1 drawback.
- Public seeded generation is checked for deterministic repeat output.
- Live shop and generated reward helper paths are checked for generated source
  metadata, requested slot/tier behavior, valid generated affixes, and duplicate
  reward stat-signature avoidance.
- Save/load regression now roundtrips both a Cursed item with a drawback and a
  Unique item with a Special, preserving item metadata and affix signatures.
- Boundary coverage confirms Crude, Legendary, and non-generated source
  requests fail loudly, impossible direct Special plans return no partial
  affixes, Lucky Coin and placeholder dagger remain authored/fixed boundaries,
  and standalone generated offers stay clean.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_generator_regression_test.gd`
  passed.
- `res://tests/p5m5_generator_contract_test.gd` passed.
- `res://tests/p5m5_rarity_stat_count_test.gd` passed.
- `res://tests/p5m5_weighted_stat_selection_test.gd` passed.
- `res://tests/p5m5_unique_stat_ids_test.gd` passed.
- `res://tests/p5m5_stat_value_scaling_test.gd` passed.
- `res://tests/p5m5_cursed_drawback_test.gd` passed.
- `res://tests/p5m5_chaos_gamble_test.gd` passed.
- `res://tests/p5m5_unique_special_rolls_test.gd` passed.
- `res://tests/p5m5_legendary_generator_boundary_test.gd` passed.
- `res://tests/p5m5_fixed_gear_exclusion_test.gd` passed.
- `res://tests/p5m2_lucky_coin_charm_test.gd` passed.
- `res://tests/p5m2_old_gear_quarantine_test.gd` passed.
- `res://tests/p5m3_slot_stat_eligibility_test.gd` passed.
- `res://tests/p5m3_stat_catalog_test.gd` passed.
- `res://tests/p5m3_stat_sheet_aggregation_test.gd` passed.
- `res://tests/p5m3_special_effect_aggregation_test.gd` passed.
- `res://tests/p5m3_existing_gear_wiring_test.gd` passed.
- `res://tests/p5m4_base_damage_physical_buckets_test.gd` passed.
- `res://tests/p5m4_weapon_scaling_percentages_test.gd` passed.
- `res://tests/gear_generator_test.gd` passed.
- `res://tests/save_load_test.gd` passed with the known intentional corrupt-save
  JSON parse output.
- `res://tests/reward_shop_route_ui_test.gd` passed.
- `res://tests/training_room_gear_editor_test.gd` passed.
- `res://tests/encounter_reward_test.gd` passed.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## P5M5-T13 Documentation And Review Notes

Completed 2026-09-04.

Final P5M5 documentation review:

- Marked P5M5 complete in this tracker and in
  `docs/P5_Gear_Redesign_Overview.md`.
- Recorded P5M5-T13 as complete in the task tracker.
- Updated the Phase 5 overview so P5M6 is now the next planned milestone.
- Replaced the overview's placeholder P5M5 exit notes with the completed
  generator baseline.
- Converted the remaining P5M5 implementation questions into resolved
  generator decisions or deferred P5M6/P5M7/P5M11 handoff items.
- Confirmed the final verification evidence includes the consolidated T12
  regression sweep and adjacent Phase 5 stat, weapon, save/load, shop/reward,
  training-room, and encounter-reward checks.
- Recorded known non-blockers: Godot headless ObjectDB/RID/resource cleanup
  warnings at process exit and the intentional corrupt-save JSON parse output
  from `save_load_test.gd`.

Verification:

- A stale-status scan for old P5M5/T13 milestone wording returned no actionable
  stale status matches after the documentation update.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m5_generator_regression_test.gd`
  passed after the documentation update.
- Godot headless tests emitted the accepted ObjectDB/RID/resource cleanup
  warnings at process exit.

## Current Known Decisions

- P5M5 owns the completed procedural rarity/stat rolling baseline, not final
  reward or shop tuning.
- P5M5 builds on the existing `GearGenerator`; no parallel generator type was
  needed.
- P5M5 uses `StatCatalog` as the authoritative source for stat IDs,
  categories, slot eligibility, weights, drawback pools, value kinds, floors,
  caps, and Special IDs.
- P5M5 uses the existing `GearItem` and `StatModifier` resources extended
  during P5M2 and wired into `StatSheet` during P5M3.
- P5M5 preserves the P5M4 `WeaponDamageCatalog` rarity ranges by generating
  Weapon-slot items with the correct Phase 5 rarity.
- Random gear generation must be deterministic from the item generation seed
  path and must not inspect upcoming route or enemy pressure directly.
- `GearGenerator.generate_from_request()` is the explicit high-level generator
  contract for production and test callers that need metadata and validation;
  the legacy `generate()` wrapper remains for compatibility.
- Impossible generation requests return structured failed results with no item,
  while impossible direct roll plans return errors and no partial affixes.
- Generated stat-roll key formatting is exposed through
  `GearGenerator.stat_roll_key()`.
- Crude is reserved for the starting dagger only.
- Basic rolls 1 Basic stat.
- Master rolls 2 Basic stats with Master value scaling.
- Epic rolls 2 Basic stats and 1 Rare stat with Epic value scaling.
- Cursed rolls 2 Basic stats, 1 Rare stat, and 1 Basic-stat drawback.
- Chaos rolls 4 outcomes; each outcome may be a massive positive Basic/Rare
  stat or a massive Basic-stat drawback, with no safety guarantee.
- Unique rolls 3 Basic stats, 1 Rare stat, and 1 Special stat.
- Legendary items are fixed handcrafted catalog items, not procedural stat
  packages; live shop and reward Legendary rolls must route through
  `LegendaryCatalog`.
- Generated non-Chaos items cannot roll duplicate stat IDs on the same item;
  Chaos can duplicate stat IDs by design.
- Drawbacks use slot-eligible Basic stats and cannot collide with positive
  stats on the same item.
- `weight: 0` means a stat is valid but disabled for random generation.
- Contract-depth value scaling remains a deterministic hook that defaults to
  `1.00x` until later tuning.
- Lucky Coin remains fixed authored gear with +5% Crit Chance, awarded by the
  scripted Tavern path and excluded from procedural generation.
- Placeholder Dagger remains compatibility/starter gear and is excluded from
  procedural generation.

## Remaining Handoff Items

- P5M6 owns Shop Lab simulation, repeated offer rolls, rarity odds by depth,
  Special frequency inspection, provisional range tuning, Chaos outcome weight
  tuning, Rare-stat drawback evaluation, and retrigger cap risk visibility.
- P5M7 owns live Adventure reward and between-contract shop integration,
  including final rarity distribution by contract depth and any additional
  deterministic key context needed by live reward/shop flows.
- P5M8 owns final inventory/equipment UI and player-facing item card
  presentation for the generated stats, drawbacks, and Specials.
- P5M9 completed Hood and Doublet sprites plus generated Rogue item-art cleanup.
- P5M10 owns retained Rogue Legendary fixed stat packages, final value tuning,
  resource updates, and per-Legendary validation.
- P5M11 owns broad Practice Room and Balance Lab validation after generator,
  shop, reward, presentation, art, and Legendary work land, including any
  migration of remaining compatibility-focused generator expectations.
- P5M12 owns full Phase 5 regression, smoke checks, export-sensitive checks,
  documentation updates, and closeout.

## Completion Notes

P5M5 is complete. P5M5-T1, P5M5-T2, P5M5-T3, P5M5-T4, P5M5-T5, P5M5-T6,
P5M5-T7, P5M5-T8, P5M5-T9, P5M5-T10, P5M5-T11, P5M5-T12, and P5M5-T13 are
complete as of 2026-09-04.

P5M5-T1 completed the generator audit and recorded the assumption map above.
No code changes or test runs were required for the audit-only task.

P5M5-T2 added the generator request/result contract, live caller source
metadata, canonical generated-item signatures, focused regression coverage, and
the verification evidence listed in the T2 notes above.

P5M5-T3 added the procedural rarity roll-plan source of truth, enabled the full
non-Crude/non-Legendary procedural rarity set, generated affixes according to the
documented stat-count categories, and added focused coverage for all slots and
active procedural rarities.

P5M5-T4 replaced equal placeholder pool selection with documented provisional
slot/category weights, deterministic cumulative weighted rolling, disabled-entry
exclusion, and focused weighted-selection regression coverage.

P5M5-T5 added explicit canonical same-item stat ID preflight validation,
positive/drawback/Special collision prevention, impossible-plan loud failures,
and focused regression coverage across all active procedural rarities.

P5M5-T6 added catalog-backed Basic/Rare value ranges, deterministic generated
value rolls, rarity/request/contract-depth scaling, value-kind rounding, binary
Special preservation, and focused stat value scaling coverage.

P5M5-T7 named and validated the Cursed drawback contract, including exact Cursed
affix shape, slot-eligible Basic-stat drawbacks, negative scaled values,
positive/drawback collision prevention, deterministic output, and exhausted-pool
loud failures.

P5M5-T8 added seeded Chaos outcome-first generation, variable roll-plan
metadata, eligible-outcome filtering, forced stat validation for item-specific
Chaos plans, all-positive/all-drawback/mixed coverage, Special exclusion, and
focused Chaos regression coverage.

P5M5-T9 named and validated the Unique Special contract, including exact Unique
affix shape, slot-eligible binary Specials, deterministic weighted Special
selection, Special-to-PlayerStats bridging, duplicate-stat prevention, and
impossible Special-plan loud failures.

P5M5-T10 named and validated the Legendary generator boundary, including
fixed-catalog-only request validation, catalog-backed shop/reward Legendary
selection, generated-offer Legendary exclusion, owned-shop Legendary fallback,
and preservation of retained Rogue Legendary catalog behavior.

P5M5-T11 validated that fixed authored gear, compatibility gear, and catalog
Legendaries stay excluded from procedural generation while Lucky Coin's fixed
reward path and other explicit fixed/catalog paths remain intact.

P5M5-T12 added the consolidated generator regression safety net and validated
the full P5M5 procedural surface across public requests, every active
rarity/slot combination, live shop/reward generation, save/load metadata,
fixed/catalog boundaries, and adjacent Phase 5 stat/weapon/shop/training-room
checks.

P5M5-T13 closed the milestone documentation by marking P5M5 complete in this
tracker and the Phase 5 overview, recording final verification evidence, naming
accepted non-blockers, resolving implementation questions, and preserving clear
handoff items for P5M6 and later milestones.
