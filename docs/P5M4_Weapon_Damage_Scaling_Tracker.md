# P5M4: Weapon Damage Scaling Tracker

## Status

Complete.

P5M4 finishes when Rogue physical skill damage has moved from fixed skill
numbers onto deterministic weapon damage rolls and the first Phase 5 combat
damage order is implemented. This milestone should make the Weapon slot matter
in combat while preserving seeded replay, combat playback, save/load stability,
and the completed P5M3 stat foundation.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone document:

- `docs/P5_Gear_Redesign_Overview.md`

Previous milestone tracker:

- `docs/P5M3_Stat_System_Foundation_Tracker.md`

## Exit Criteria

- Current Rogue damage, crit, mitigation, RNG, retrigger, and combat playback
  paths have been audited and mapped.
- Dagger damage ranges are represented in code for Crude, Basic, Master, Epic,
  Cursed, Chaos, Unique, and Legendary.
- Combat can resolve the active player's weapon damage range from equipped gear,
  including safe fallback behavior for missing or invalid weapons.
- Each physical Rogue skill cast rolls weapon damage once from a deterministic
  combat-safe seed path.
- Retriggers behave as full new casts, with new weapon rolls, new crit rolls,
  the full damage pipeline, and recursive retrigger compatibility.
- Rogue physical skills use the documented weapon-scaling percentages.
- Flat `Base Damage` applies before physical skill scaling.
- Death Strike adds 1 flat physical damage per active poison stack before
  weapon scaling.
- Gear `Percent Physical Damage` and talent physical damage remain separate
  multiplicative buckets.
- Damage calculation uses floating point through the pipeline, applies crit
  before conversion, applies conversion before mitigation, preserves the
  current mitigation order, floors damaging hits at 1 unless fully prevented,
  and rounds once at the end.
- Combat consumes the P5M3 Special hooks needed by this milestone: damage
  conversion, armor/resistance ignore, and enemy denial behavior that directly
  affects the damage pipeline.
- Existing authored gear, Lucky Coin, retained Legendaries, generated gear,
  Practice Room combat setup, save/load, and combat playback remain compatible.
- Focused regression checks cover deterministic weapon rolls, physical skill
  scaling, Death Strike handling, retriggers, damage order, mitigation, and
  relevant Special hooks.
- Phase 5 milestone docs are updated with M4 completion notes and remaining
  handoff items for P5M5+.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M4-T1: Audit Current Combat Damage Flow | Complete | Find every active Rogue damage, RNG, crit, mitigation, retrigger, replay, and test path before changing combat math. | Completed 2026-09-04. Audit notes map `Skill`, `CombatResolver`, `DamageCalculator`, `PlayerStats`, `StatSheet`, talents, gear, enemy defenses, combat RNG, playback, Practice Room, and focused tests, with each finding classified for M4 implementation or later deferral. |
| P5M4-T2: Define Weapon Damage Runtime Data | Complete | Represent dagger damage ranges and active weapon lookup cleanly. | Completed 2026-09-04. `WeaponDamageCatalog` exposes Rogue dagger rarity ranges; `BuildResolver` resolves equipped Weapon gear into `PlayerStats`; missing, invalid, or non-weapon data uses an explicit Crude fallback; retained Legendaries use the Legendary range unless a handcrafted override is later scoped. |
| P5M4-T3: Implement Deterministic Weapon Rolls | Complete | Roll weapon damage once per physical skill cast without breaking replay or seeded validation. | Completed 2026-09-04. Physical skill casts now record deterministic weapon rolls from the combat RNG after dodge and before crit; identical seeded combat sequences reproduce the same roll signature; separate physical casts roll independently; fixed skill damage remains unchanged until T4. |
| P5M4-T4: Convert Rogue Physical Skills To Weapon Scaling | Complete | Move Rogue physical skills onto the documented weapon-scaling percentages. | Completed 2026-09-04. Authored Rogue physical skills now use deterministic weapon rolls plus flat `Base Damage`/Bandit Blade bonus as their primary physical base, scaled by the documented skill percentages; unlisted physical effects retain fixed-damage compatibility. |
| P5M4-T5: Apply Base Damage And Physical Buckets | Complete | Consume the P5M3 stat bridge in the physical damage pipeline. | Completed 2026-09-04. Flat `Base Damage` remains a pre-physical-bucket flat value; gear `Percent Physical Damage` now resolves into its own additive bucket; talent/class physical damage resolves into a separate bucket; the legacy total multiplier is preserved for compatibility. |
| P5M4-T6: Implement Death Strike Stack Bonus Order | Complete | Preserve Death Strike's Phase 5 special physical scaling rule. | Completed 2026-09-04. Death Strike now resolves as one weapon-scaled physical packet: one weapon roll, active poison stacks as flat pre-scaling damage, flat `Base Damage`/Bandit Blade bonus once, the 111% skill scalar, then the shared physical bucket, crit, and mitigation pipeline. |
| P5M4-T7: Implement Damage Conversion And Ignore Hooks | Complete | Apply the combat-facing Special hooks exposed by P5M3. | Completed 2026-09-04. Damage packets now consume conversion Specials, ignore armor/no-shred, and ignore resistance/original-physical penalty from `PlayerStats.special_effects`; dual conversion mitigates physical first, then magical. |
| P5M4-T8: Apply Enemy Denial Hooks Relevant To Damage | Complete | Let equipped Special stats disable matching enemy defensive behavior during player damage resolution. | Completed 2026-09-04. Combat now resolves effective dodge, block, absorb, suppress, and cleanse values from `PlayerStats.special_effects["enemy_denial"]`; `Stacks you apply are doubled` applies after flat stack bonuses. |
| P5M4-T9: Preserve Retrigger Semantics | Complete | Keep existing retrigger and Legendary behavior compatible with weapon scaling. | Completed 2026-09-04. Retriggered skills now resolve as separate instant proc casts with fresh weapon rolls, fresh crit rolls, full damage/state processing, recursive retrigger support, source filtering, and a hard recursion cap. |
| P5M4-T10: Lock Rounding, Floors, And Mitigation Order | Complete | Make arithmetic behavior deterministic and testable. | Completed 2026-09-04. `DamageCalculator` now applies the shared final damage policy after mitigation: non-prevented damaging packets floor at 1 and round once to whole damage; dodge/full block/full absorb/prevention paths remain 0. |
| P5M4-T11: Add Focused Regression And Smoke Checks | Complete | Prove M4 behavior in isolated math and real combat setup. | Completed 2026-09-04. Focused tests now cover weapon ranges, seeded rolls, scaling percentages, stat buckets, Death Strike, conversion/ignore/denial hooks, retriggers, rounding/mitigation, and an integrated Practice Room combat smoke path. |
| P5M4-T12: Update Milestone Docs And Review | Complete | Record M4 completion and prepare the handoff to P5M5. | Completed 2026-09-04. This tracker, `docs/P5_Gear_Redesign_Overview.md`, and onboarding context now record M4 completion notes, verification evidence, known non-blockers, and P5M5+ handoff items. |

## P5M4-T1 Audit Steps

P5M4-T1 should produce a concrete combat-damage assumption map before any
damage rewrite begins.

1. Confirm current workspace identity, active branch, and that P5M3 is the
   current implementation baseline.
2. Inventory Rogue skill resources and scripts that define physical damage,
   elemental or poison damage, stack application, costs, cooldowns, and
   triggered effects.
3. Trace player stat resolution from equipped gear through `StatSheet`,
   `BuildResolver`, and `PlayerStats`.
4. Trace combat damage execution through the resolver, damage calculator, enemy
   defenses, crit logic, mitigation, floors, rounding, status application, and
   combat event output.
5. Trace combat RNG ownership, including seeded fights, playback expectations,
   generated combat, Practice Room fights, and any deterministic test helpers.
6. Trace retrigger behavior, including retained Legendary side channels and
   any safeguards against runaway loops.
7. Trace current Death Strike behavior and active poison-stack lookup.
8. Trace enemy defense fields and generated monster pressure stats that M4
   Specials need to deny, bypass, or preserve.
9. Trace save/load and playback data enough to ensure weapon rolls do not add
   non-materialized or non-deterministic state.
10. Trace existing tests that should be extended, rewritten, or retired for the
    M4 combat boundary.
11. Classify every finding as Keep, Migrate, Defer, or Open Decision, with the
    downstream P5M4 task each finding affects.

## P5M4-T1 Audit Findings

Completed 2026-09-04.

Current workspace identity:

- Local path: `F:\Data\Claude Projects\Project-Enigma`.
- Branch: `phase-5-gear-redesign`, tracking `origin/phase-5-gear-redesign`.
- Baseline: P5M3 is documented complete and its new `StatCatalog`,
  `StatSheet`, `PlayerStats` Special hooks, P5M2 compatibility tests, and P5M3
  regression tests are present in the workspace.
- Worktree note: the repo contains many Phase 5/P5M2/P5M3 edits and new tracker
  or test files. Treat them as the current implementation baseline for P5M4
  unless a later implementation task proves a direct conflict.

| Finding | Evidence | Classification | Downstream |
| --- | --- | --- | --- |
| Rogue physical skill damage still comes from fixed `PhysicalDamageEffect.amount` values that match the P5M1 reference table. | `stab.tres` 18, `heavy_slash.tres` 30, `quick_cut.tres` 12, `steal.tres` 19, `venom_jab.tres` 4, `poison_strike.tres` 15, `rending_slash.tres` 14, and `beguiling_strike.tres` 4. | Migrate | P5M4-T4 |
| Death Strike currently has two independent physical effects instead of one weapon-scaled base packet. | `death_strike.tres` has a 20-damage `PhysicalDamageEffect` plus `StackScalingPhysicalDamageEffect.damage_per_stack = 1.0`; `CombatResolver._apply_skill_effects()` resolves each as a separate physical hit with its own crit roll. | Migrate | P5M4-T6, T10 |
| `Skill` resources do not yet carry weapon-scaling metadata. | `skill.gd` exposes id, display, timing, poison stacks, and `effects`, but no weapon-scaling percent or damage-type packet data. | Open Decision | P5M4-T4 |
| `GearItem` has slot and rarity data but no intrinsic weapon damage range fields. | `gear_item.gd` exposes `slot`, `tier`, item family, affixes, Legendary side channels, and metadata; dagger rarity ranges exist only in docs. | Migrate | P5M4-T2 |
| Active weapon lookup currently ends at `BuildState.equipped_weapon`; combat receives only resolved `PlayerStats`. | `BuildState.equipped_gear()` includes five slots and `BuildResolver.resolve_stats()` receives gear, but `CombatResolver.resolve()` only accepts `rotation`, `player`, `monster`, `duration_ms`, and `rng_seed`. | Migrate | P5M4-T2, T3 |
| P5M3's flat `Base Damage` bridge already lands in `PlayerStats.bonus_physical_damage`. | `StatSheet.apply_to_player_stats()` adds `base_damage()` to `stats.bonus_physical_damage`, and `CombatResolver._apply_skill_effects()` adds that bonus to every physical effect. | Migrate | P5M4-T5 |
| Gear percent physical damage is currently merged into the old `PlayerStats.physical_damage_multiplier`, not kept as a separate gear bucket. | `StatSheet.apply_to_player_stats()` adds `percent_physical_damage()` to `physical_damage_multiplier`; talent/class physical modifiers also use `_apply_modifier()` on the same field. | Migrate | P5M4-T5 |
| Talent physical damage and gear physical damage need bucket separation before the new order is trustworthy. | `BuildResolver.resolve_stats()` applies class/tree/talent modifiers before `StatSheet`, but both paths ultimately mutate `PlayerStats.physical_damage_multiplier`. | Migrate | P5M4-T5, T10 |
| Current direct physical damage order is crit, crit negation, physical multiplier, armor, then block. | `DamageCalculator.resolve_physical_hit()` rolls crit, applies crit negation, multiplies by `physical_damage_multiplier`, applies `physical_mitigation_multiplier(armor)`, then subtracts block. | Keep/Migrate | P5M4-T7, T10 |
| Current damage math keeps floats through resolver/calculator but does not apply the Phase 5 1-damage floor or final rounding policy. | `DamageCalculator` returns float `amount`; block and absorb clamp to 0, and UI formats rounded numbers, but combat totals remain floats with no damaging-hit floor. | Migrate | P5M4-T10 |
| Current poison/elemental tick damage order is flat poison tick value, resistance, then absorb, with no crit. | `CombatResolver._resolve_poison_tick()` calls `DamageCalculator.resolve_magical_damage(player.poison_damage_per_tick, current_poison_resistance, monster.absorb)`; `resolve_poison_tick()` notes poison ticks do not crit. | Keep/Migrate | P5M4-T7, T10 |
| Combat RNG is deterministic and centralized inside one resolver stream. | `CombatResolver.resolve()` creates `RandomNumberGenerator`, seeds it from `rng_seed`, and uses it for min-cast-time procs, dodge, crit, and triggered-skill proc rolls. | Keep/Migrate | P5M4-T3, T9, T11 |
| Adventure combat seed derives from the Adventure seed plus fight identity. | `BuildState.current_combat_rng_seed()` uses `RunRng.seed_for_context(adventure_seed, RunRng.CONTEXT_COMBAT, [_current_fight_key()])`; contract fights use route node id and Tavern fights use encounter index. | Keep | P5M4-T3 |
| Practice Room combat uses a separate explicit fight seed. | `TrainingRoomState.fight_seed` is separate from `BuildState.adventure_seed`; `run_fight()` calls `CombatResolver.resolve(..., fight_seed)`. | Keep | P5M4-T3, T11 |
| Combat playback is presentation-only and replays already-resolved cast/tick events. | `CombatPlayback.start()` merges `CombatResult.cast_events` and `tick_events`; it performs no game-rule logic and tracks damage from recorded event values. | Keep/Migrate | P5M4-T3, T11 |
| Save/load does not materialize mid-fight state and deliberately normalizes fighting saves back to planning. | `SaveSystem._serialize()` writes run/build/generated route data, but comments state combat resolves synchronously and `run_phase == FIGHTING` is saved as planning. | Keep | P5M4-T3 |
| Generated contract monster state is materialized through generated payloads and restored to `Monster` fields. | `GeneratedMonsterDraft.MONSTER_DEFENSE_FIELDS` includes all active defense fields, `to_monster()` applies `defense_overrides`, and `SaveSystem` restores generated nodes from payloads. | Keep | P5M4-T8 |
| Enemy defense fields relevant to M4 are concentrated on `Monster`. | `monster.gd` exposes armor, poison resistance, dodge, crit negation, block, absorb, cleanse threshold, suppress, slow, stun duration, and interrupt skip count. | Keep/Migrate | P5M4-T7, T8, T10 |
| Runtime monster generation already maps generated pressure mechanics to the same `Monster` fields. | `RuntimeMechanicLibrary.SUPPORTED_GODOT_FIELDS` and built-in mechanics cover armor, dodge, crit negation, block, poison resistance, absorb, cleanse, suppress, slow, stun, and interrupt. | Keep | P5M4-T8 |
| Dodge currently happens before any attached effects and can prevent both damage and stack/status application. | `CombatResolver._apply_skill_effects()` returns immediately on dodge before iterating skill effects; `enemy_defense_mechanics_test.gd` asserts attached poison is skipped. | Keep/Migrate | P5M4-T8, T10 |
| Block and absorb can fully prevent damage today by reducing final amounts to 0. | `resolve_physical_hit()` subtracts block after armor and clamps to 0; `resolve_magical_damage()` subtracts absorb after resistance and clamps to 0. | Keep/Migrate | P5M4-T8, T10 |
| Cleanse currently resets poison stacks, current armor, and current poison resistance after a hit-count threshold. | `CombatResolver.resolve()` increments `cleanse_counter` for non-Hold mechanics, resets stacks/armor/resistance when threshold is reached, and records `cleanse_triggered`. | Keep/Migrate | P5M4-T8 |
| Suppress currently changes poison tick cadence at fight start, not per tick. | `CombatResolver.resolve()` computes `tick_interval_ms` once from player poison tick multiplier and `monster.suppress`. | Keep/Migrate | P5M4-T8 |
| Player Special hooks exist on `PlayerStats` but are not consumed by combat yet. | `StatSheet.special_effect_summary()` exposes enemy denial, ignore armor/no shred, ignore resistance/physical penalty, double stacks, damage conversion, all-stats, and immunities; `CombatResolver` never reads `player.special_effects`. | Migrate | P5M4-T7, T8 |
| `Chance for Retrigger`, `Chance to Shred`, `Chance to Decay`, and the old `Crit Applies Element` concept existed in `StatSheet` but were not bridged to combat fields during the original P5M4 audit. | Post-P5M9 playtest updates bridge these as combat-facing proc chances, with `Chance for Crits to Apply Poison` replacing the old Rogue crit-element name. | Superseded | P5M4-T8, P5M9, P5M11 |
| Current retriggers are immediate extra effect applications folded into the source `CastEvent`. | `CombatResolver.resolve()` loops `player.triggered_skill_effects` after a non-dodged cast and calls `_apply_skill_effects(trigger.skill, event, ..., "proc")`; damage contributes to the same event and `triggered_skill_names` records presentation names. | Migrate | P5M4-T9 |
| Current retriggers roll fresh crits but are not full timeline casts and are not recursive. | Triggered skills call `_apply_skill_effects()` with the same event and current state, so each physical effect rolls crit via `DamageCalculator`; there is no nested trigger scan for triggered skill casts. | Migrate | P5M4-T9, T11 |
| Mithril Karambit depends on source-filtered triggered skills. | `mithril_karambit.tres` has two `TriggeredSkillEffect`s; `legendary_mechanics_test.gd` forces them to 100% and asserts Stab retriggers only Stab and Heavy Slash only Heavy Slash. | Keep/Migrate | P5M4-T9 |
| Bejeweled Push Dagger consumes combat RNG before cast timing when its chance is positive. | `CombatResolver.resolve()` rolls `player.min_cast_time_proc_chance` before computing execution time; `legendary_mechanics_test.gd` asserts zero chance short-circuits the RNG. | Keep/Migrate | P5M4-T3, T9 |
| Bandit Blade's flat gold damage currently adds through `bonus_physical_damage` and applies to every physical effect, including stack-scaling effects. | `BuildResolver.resolve_stats()` adds `gear.physical_damage_per_gold * current_gold`; `legendary_mechanics_test.gd` asserts both normal and stack-scaling physical hits receive the bonus. | Migrate | P5M4-T5, T6 |
| Umbral Stiletto unlocks Death Strike through the existing gear skill unlock path. | `umbral_stiletto.tres` has `unlocked_skills`; `BuildResolver.resolve_unlocked_skills()` appends gear skills. | Keep/Migrate | P5M4-T6 |
| Wyvern Kriss modifies poison tick interval through a legacy multiplier, outside the new Special system. | `StatSheet` preserves legacy poison tick interval multipliers and bridges them into `PlayerStats.poison_tick_interval_multiplier`. | Keep | P5M4-T10 |
| Combat UI and recap assume physical cast damage and poison tick damage as the two displayed damage families. | `CombatPlayback` uses `cast.physical_damage` and `tick.damage`; `CombatRecap` summarizes `physical_damage`, `poison_damage`, biggest hit, crit count, armor reduction, and final resistance from current event fields. | Migrate | P5M4-T7, T10, T11 |
| Existing tests cover deterministic replay, enemy defenses, combat playback, Practice Room combat, Legendary mechanics, stat-sheet aggregation, and save/load compatibility, but no test yet covers weapon rolls or Phase 5 damage packets. | Relevant suites include `deterministic_replay_test.gd`, `enemy_defense_mechanics_test.gd`, `combat_playback_test.gd`, `training_room_fight_test.gd`, `training_room_fight_setup_test.gd`, `legendary_mechanics_test.gd`, `p5m3_*`, and `save_load_test.gd`. | Migrate | P5M4-T11 |

T1 implementation guidance:

- Keep `CombatResolver.resolve()` as the deterministic fight boundary unless
  T3/T9 prove a stronger packet/cast abstraction is necessary.
- Add weapon range lookup close to combat-facing gear/stat resolution, with an
  explicit fallback for missing or invalid weapons. `GearItem.tier` is enough
  to select the documented first-pass dagger range; no procedural generator
  expansion is needed for M4.
- Prefer adding weapon-roll and scaling metadata in code rather than editing
  every skill resource destructively at the start. The fixed resource amounts
  are useful as migration reference values and regression fixtures.
- Separate gear and talent physical percent buckets before final M4 math is
  locked. The current `PlayerStats.physical_damage_multiplier` field is too
  coarse to prove the documented bucket order.
- Treat Death Strike as a special physical skill rule during M4: active poison
  stacks add to the weapon roll before scaling, and it should no longer be two
  separately critting physical effects.
- Preserve Adventure and Practice Room seed entry points, then add tests that
  prove weapon rolls are stable for the same seed and change only as expected
  when cast order, retriggers, or seed changes.
- Rework retriggers carefully. Existing Legendary behavior needs to remain
  source-filtered, but the M4 design wants retriggers to be full new casts with
  their own weapon roll, crit roll, full pipeline, and recursive compatibility.
- Implement Special hooks at the point they affect damage: dodge denial before
  dodge, block/absorb denial during mitigation, suppress denial before tick
  interval calculation, cleanse denial before cleanse threshold handling,
  armor/resistance ignore during mitigation, and conversion between crit and
  mitigation.
- Leave full procedural rarity generation, final item-card presentation, final
  Legendary stat packages, and broader Practice Room/Balance Lab validation to
  later Phase 5 tasks.

## P5M4-T2 Weapon Damage Runtime Data Notes

Completed 2026-09-04.

Implemented runtime data:

- Added `project/scripts/systems/weapon_damage_catalog.gd` as the combat-facing
  source for Rogue dagger damage ranges.
- Encoded the P5M4 dagger ranges by `GearItem.Tier`: Crude 16-20, Basic 17-19,
  Master 17-21, Epic 18-20, Cursed 17-23, Chaos 16-25, Unique 19-25, and
  Legendary 21-27.
- Added explicit range lookup helpers for a tier, a single weapon, or an
  equipped gear collection.
- Missing weapons, non-Weapon items passed as weapons, and unknown tiers resolve
  to the Crude 16-20 fallback with a fallback reason.
- Retained Rogue Legendaries resolve through their existing Weapon slot and
  Legendary tier metadata, so they use the Legendary 21-27 range.

Implemented bridge:

- Added weapon damage range fields and `weapon_damage_range()` to `PlayerStats`
  so current combat-facing callers can read the resolved active range without
  receiving raw gear.
- Added `BuildResolver.resolve_weapon_damage_range()` and wired
  `resolve_stats()` to populate the active weapon range from equipped gear.

Scope boundary:

- T2 does not roll weapon damage, alter physical skill damage, consume the range
  in combat, or change item generation. T3 owns deterministic weapon rolls and
  T4+ own physical skill conversion.
- The range data currently derives from rarity only. Handcrafted Legendary range
  overrides remain deferred unless a later P5M10 Legendary pass promotes them.

Verification:

- Focused T2 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_weapon_damage_runtime_data_test.gd`.
- P5M3 compatibility regression passed:
  `res://tests/p5m3_foundation_regression_test.gd`.
- P5M2 gear data compatibility regression passed:
  `res://tests/p5m2_gear_data_shape_test.gd`.
- All Godot commands emitted the accepted ObjectDB/resource cleanup warnings at
  process exit.

## P5M4-T3 Deterministic Weapon Roll Notes

Completed 2026-09-04.

Implemented weapon-roll observability:

- Added weapon roll fields to `CombatResolver.CastEvent`: primary roll, active
  min/max range, and a per-contribution roll list.
- `CombatResolver._apply_skill_effects()` now rolls weapon damage once for each
  non-dodged physical skill application, before resolving physical damage.
- Roll records include contribution kind, skill id/name, roll, range, tier,
  weapon id, and fallback metadata from `PlayerStats`.
- Pure poison/utility casts do not roll weapon damage.
- Current fixed `PhysicalDamageEffect` and `StackScalingPhysicalDamageEffect`
  damage values remain unchanged. T4 owns consuming the roll for Rogue physical
  skill scaling.

Deterministic order:

- Positive min-cast-time procs still roll before cast timing.
- Interrupt skips/triggers still happen before skill effects.
- Dodge is checked before weapon damage rolls.
- Weapon damage rolls happen before crit rolls for the physical skill
  application.
- Current retrigger side-channel applications receive their own roll record
  because they call `_apply_skill_effects()` separately. Full retrigger-as-new-
  cast behavior remains P5M4-T9.

Verification:

- Focused T3 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_deterministic_weapon_rolls_test.gd`.
- T2 runtime data regression passed:
  `res://tests/p5m4_weapon_damage_runtime_data_test.gd`.
- Deterministic replay regression passed:
  `res://tests/deterministic_replay_test.gd`.
- Enemy-defense regression passed:
  `res://tests/enemy_defense_mechanics_test.gd`.
- Combat smoke passed:
  `res://tests/combat_test.gd`.
- Legendary mechanics regression passed:
  `res://tests/legendary_mechanics_test.gd`.
- All Godot commands emitted the accepted ObjectDB/resource cleanup warnings at
  process exit.

## P5M4-T4 Weapon Scaling Percentage Notes

Completed 2026-09-04.

Implemented runtime scaling:

- `CombatResolver` now owns the first-pass M4 weapon-scaling metadata for
  authored Rogue physical skills:
  Stab `100%`, Heavy Slash `166%`, Quick Cut `66%`, Steal `106%`, Venom Jab
  `22%`, Poison Strike `83%`, Rending Slash `78%`, and Beguiling Strike `22%`.
- The authored skill resources keep their previous `PhysicalDamageEffect.amount`
  values as migration references and presentation compatibility data. Runtime
  physical damage for the listed Rogue skills now uses
  `(weapon roll + bonus_physical_damage) * skill scaling` instead of those fixed
  amounts.
- Unlisted physical effects, including placeholder fixtures and synthetic test
  skills, continue to use their fixed `PhysicalDamageEffect.amount` values.

Order notes:

- Weapon-scaled Rogue physical skills still roll weapon damage after dodge and
  before crit.
- Flat `Base Damage` and Bandit Blade's gold-scaling flat damage continue to
  enter through `bonus_physical_damage` and are added before skill scaling.
- P5M4-T5's separated physical buckets remain after skill scaling and before
  crit, crit negation, armor, and block.
- Attached effects remain attached to the same cast: Venom Jab and Poison Strike
  still apply poison stacks, Rending Slash still shreds armor, Beguiling Strike
  still reduces poison resistance, and Steal still steals gold from the scaled
  hit's crit result.
- Death Strike keeps the P5M4-T6 special packet path, using its documented
  `111%` scaling and active poison-stack bonus order.

Verification:

- Focused T4 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_weapon_scaling_percentages_test.gd`.
- T3 deterministic weapon-roll regression passed:
  `res://tests/p5m4_deterministic_weapon_rolls_test.gd`.
- T5 physical bucket regression passed:
  `res://tests/p5m4_base_damage_physical_buckets_test.gd`.
- T6 Death Strike regression passed:
  `res://tests/p5m4_death_strike_stack_order_test.gd`.
- Combat smoke passed:
  `res://tests/combat_test.gd`.
- Legendary mechanics regression passed:
  `res://tests/legendary_mechanics_test.gd`.
- Enemy-defense regression passed:
  `res://tests/enemy_defense_mechanics_test.gd`.
- Deterministic replay regression passed:
  `res://tests/deterministic_replay_test.gd`.
- All Godot commands emitted the accepted ObjectDB/RID/resource cleanup warnings
  at process exit.

## P5M4-T5 Base Damage And Physical Bucket Notes

Completed 2026-09-04.

Implemented bucket separation:

- `PlayerStats` now carries explicit physical damage buckets:
  `gear_physical_damage_multiplier`, `talent_physical_damage_multiplier`, and
  `physical_damage_uses_buckets`.
- `physical_damage_multiplier` remains as a legacy total/readout so existing
  UI, tools, and tests that compare the total multiplier continue to work.
- `PlayerStats.physical_damage_buckets()` lets combat distinguish new bucketed
  stats from older hand-built `PlayerStats` fixtures that only set the legacy
  multiplier.

Implemented resolution order:

- `StatSheet.apply_to_player_stats()` applies flat `Base Damage` to
  `bonus_physical_damage` and gear `Percent Physical Damage` to the gear bucket.
- `BuildResolver` applies class/tree/talent `PHYSICAL_DAMAGE` modifiers to the
  talent bucket.
- `DamageCalculator.resolve_physical_hit()` now applies physical multipliers
  before crit in this order: legacy compatibility bucket, gear bucket, talent
  bucket, then crit, crit negation, armor, and block.
- After P5M4-T4, authored Rogue physical skills add `bonus_physical_damage` to
  the weapon roll before skill scaling. Unlisted physical fixtures still add
  that flat field to their fixed physical base for compatibility.

Compatibility notes:

- Bandit Blade's gold-scaling side channel still contributes to
  `bonus_physical_damage`, preserving existing behavior until a later
  Legendary-specific pass decides whether it needs bespoke ordering.
- Manual `PlayerStats` fixtures that set only `physical_damage_multiplier`
  still affect physical damage through the legacy compatibility bucket.
- Poison ticks continue to ignore flat `Base Damage` and physical damage
  buckets.

Verification:

- Focused T5 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_base_damage_physical_buckets_test.gd`.
- P5M3 foundation regression passed:
  `res://tests/p5m3_foundation_regression_test.gd`.
- P5M3 stat-sheet aggregation regression passed:
  `res://tests/p5m3_stat_sheet_aggregation_test.gd`.
- T3 deterministic weapon-roll regression passed:
  `res://tests/p5m4_deterministic_weapon_rolls_test.gd`.
- Deterministic replay regression passed:
  `res://tests/deterministic_replay_test.gd`.
- Legendary mechanics regression passed:
  `res://tests/legendary_mechanics_test.gd`.
- Enemy-defense regression passed:
  `res://tests/enemy_defense_mechanics_test.gd`.
- Practice Room gear editor regression passed:
  `res://tests/training_room_gear_editor_test.gd`.
- All Godot commands emitted the accepted ObjectDB/RID/resource cleanup warnings
  at process exit.

## P5M4-T6 Death Strike Stack Bonus Notes

Completed 2026-09-04.

Implemented runtime ordering:

- `CombatResolver` treats `skill.killers_mark` / Death Strike as a special
  Phase 5 physical packet while leaving the old two-effect resource shape in
  place for reference data and UI compatibility.
- Death Strike rolls weapon damage once, adds `1` flat damage per active poison
  stack, adds `bonus_physical_damage` once, applies the documented `111%`
  skill scalar, then enters the shared physical bucket pipeline from P5M4-T5.
- The resulting packet uses one crit roll and one mitigation pass, so the old
  separate base hit plus stack-scaling hit no longer double-crits or double
  applies flat bonus physical damage.

Compatibility notes:

- Generic `StackScalingPhysicalDamageEffect` behavior remains intact for older
  synthetic tests and non-Death Strike callers.
- Bandit Blade compatibility is preserved through `bonus_physical_damage`, but
  Death Strike now consumes that flat bonus only once inside its combined packet.
- Enemy dodge still prevents the full Death Strike packet before weapon rolling,
  matching the existing direct-attack avoidance rule.

Verification:

- Focused T6 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_death_strike_stack_order_test.gd`.
- T5 physical bucket regression passed:
  `res://tests/p5m4_base_damage_physical_buckets_test.gd`.
- T3 deterministic weapon-roll regression passed:
  `res://tests/p5m4_deterministic_weapon_rolls_test.gd`.
- Legendary mechanics regression passed:
  `res://tests/legendary_mechanics_test.gd`.
- Enemy-defense regression passed:
  `res://tests/enemy_defense_mechanics_test.gd`.
- Deterministic replay regression passed:
  `res://tests/deterministic_replay_test.gd`.
- All Godot commands emitted the accepted ObjectDB/RID/resource cleanup warnings
  at process exit.

## P5M4-T7 Conversion And Ignore Hook Notes

Completed 2026-09-04.

Implemented packet handling:

- `DamageCalculator.resolve_damage_packet()` now supports original damage type,
  conversion flags, ignore armor, ignore resistance, and original-physical
  damage penalty while preserving `resolve_physical_hit()` as the compatibility
  entry point for existing callers.
- Direct physical packets still roll crit through the combat RNG. Poison and
  magical tick packets can use conversion/mitigation without consuming RNG.
- Physical packets apply physical buckets and crit before Special conversion
  and mitigation. The ignore-resistance Special applies its `50%` penalty only
  to packets that began as physical, after crit/buckets and before mitigation.

Implemented Special behavior:

- `All of your damage is now magical` sends physical packets through resistance
  and absorb instead of armor and block.
- `All of your damage is now physical` sends poison/magical tick packets
  through armor and block instead of resistance and absorb.
- If both conversion Specials are active, packets mitigate through physical
  first, then magical.
- `You ignore armor, but can no longer apply shred` treats armor as `0` during
  physical mitigation and prevents player armor-reduction effects such as
  Rending Slash from applying.
- `You ignore resistance, but your physical damage is reduced by 50%` treats
  resistance as `0` during magical mitigation and halves only original physical
  packets.

Compatibility and deferrals:

- Existing `cast.physical_damage`, `tick.damage`, and contribution totals remain
  the display-facing damage fields, even when a packet is converted. Richer
  converted-type presentation is deferred to later review/UI work.
- Enemy dodge, block, absorb, suppress, and cleanse denial remain scoped to
  P5M4-T8. T7 only consumes ignore armor/resistance because they directly change
  the conversion mitigation pass.

Verification:

- Focused T7 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_conversion_ignore_hooks_test.gd`.
- T4 weapon-scaling regression passed:
  `res://tests/p5m4_weapon_scaling_percentages_test.gd`.
- T6 Death Strike regression passed:
  `res://tests/p5m4_death_strike_stack_order_test.gd`.
- T5 physical bucket regression passed:
  `res://tests/p5m4_base_damage_physical_buckets_test.gd`.
- Enemy-defense regression passed:
  `res://tests/enemy_defense_mechanics_test.gd`.
- Combat recap regression passed:
  `res://tests/combat_recap_test.gd`.
- Deterministic replay regression passed:
  `res://tests/deterministic_replay_test.gd`.
- All Godot commands emitted the accepted ObjectDB/RID/resource cleanup warnings
  at process exit.

## P5M4-T8 Enemy Denial Hook Notes

Completed 2026-09-04.

Implemented effective enemy values:

- `CombatResolver` now reads `PlayerStats.special_effects["enemy_denial"]` for
  dodge, block, absorb, suppress, and cleanse denial without mutating the
  authored `Monster` resource.
- Dodge denial treats enemy dodge as `0%` at the existing pre-packet dodge
  check. If denied, attached damage, weapon rolling, shred, decay, and stacks
  proceed normally.
- Block denial passes `0` effective block into physical mitigation, including
  converted magical-to-physical packets.
- Absorb denial passes `0` effective absorb into magical mitigation, including
  converted physical-to-magical packets and poison ticks.
- Suppress denial treats enemy suppress as `0` when the fight's poison tick
  interval is computed.
- Cleanse denial skips cleanse counter updates and cleanse resets, preserving
  active poison stacks, armor reductions, and resistance reductions.

Stack behavior:

- `Stacks you apply are doubled` is now consumed by combat. Applied poison
  stacks resolve as `(base stacks + flat stack bonus) * 2` while active.
- The doubling is binary and happens once, matching the P5M3 stat-sheet
  aggregation behavior.

Compatibility notes:

- Enemy HUD and recap inputs can continue to show authored monster defenses.
  Combat uses effective values only during resolution and records what actually
  happened: no dodge, no blocked amount, no absorbed amount, and no cleanse
  trigger when those mechanics are denied.
- Chance to Shred, Chance to Decay, Chance for Crits to Apply Poison, and the
  retrigger redesign were outside T8's original boundary but are now part of
  the post-P5M9 playtest baseline.

Verification:

- Focused T8 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_enemy_denial_hooks_test.gd`.
- Enemy-defense regression passed:
  `res://tests/enemy_defense_mechanics_test.gd`.
- T7 conversion/ignore regression passed:
  `res://tests/p5m4_conversion_ignore_hooks_test.gd`.
- T4 weapon-scaling regression passed:
  `res://tests/p5m4_weapon_scaling_percentages_test.gd`.
- Combat recap regression passed:
  `res://tests/combat_recap_test.gd`.
- Combat playback regression passed:
  `res://tests/combat_playback_test.gd`.
- Deterministic replay regression passed:
  `res://tests/deterministic_replay_test.gd`.
- P5M3 Special aggregation regression passed:
  `res://tests/p5m3_special_effect_aggregation_test.gd`.
- All Godot commands emitted the accepted ObjectDB/RID/resource cleanup warnings
  at process exit.

## P5M4-T9 Retrigger Semantics Notes

Completed 2026-09-04.

Implemented proc cast shape:

- `CombatResolver.CastEvent` now records whether an event is a normal macro
  `cast` or an instant `proc`, plus the triggering source skill id, retrigger
  depth, and whether the retrigger safety cap stopped further recursion.
- Triggered skills no longer fold their damage into the source cast. Each proc
  creates a separate same-timestamp `CastEvent`, resolves dodge, weapon roll,
  crit, conversion, mitigation, shred/decay-style state, poison stacks, gold,
  cleanse, and stun through the normal skill-effect pipeline, then contributes
  to `CombatResult.total_damage` independently.
- Source casts keep `triggered_skill_names` populated when a proc lands, so
  existing playback/HUD highlight paths can still surface follow-up triggers.
- Proc event damage contributions keep `kind = "proc"`, while source events
  keep source-only `kind = "cast"` contributions.

Implemented recursion and source filtering:

- Retriggers scan `PlayerStats.triggered_skill_effects` after any non-dodged
  cast or proc, preserving `TriggeredSkillEffect.source_skill_ids` filtering.
- Recursive retriggers are allowed, so Mithril Karambit-style self-retriggers
  continue to function with the same source skill restrictions.
- Guaranteed recursive loops stop at `MAX_RETRIGGER_CHAIN_DEPTH` and mark the
  capped event with `retrigger_cap_reached` for debugging and tests.

Compatibility notes:

- Proc casts remain instant and do not consume macro rotation time. They use
  the source cast's end timestamp and rotation index for stable timeline and
  playback ordering.
- Combat log formatting now treats proc events as their own hit lines instead
  of reinterpreting their proc contribution as a nested self-trigger line.
- Existing tests that intentionally asserted folded proc damage were updated to
  assert the new source/proc event split.

Verification:

- Focused T9 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_retrigger_semantics_test.gd`.
- Existing triggered-skill regressions passed:
  `res://tests/engine_mechanics_test.gd`,
  `res://tests/opportunity_strikes_test.gd`, and
  `res://tests/legendary_mechanics_test.gd`.
- Deterministic replay regression passed:
  `res://tests/deterministic_replay_test.gd`.
- Combat presentation regressions passed:
  `res://tests/combat_playback_test.gd` and
  `res://tests/combat_recap_test.gd`.
- P5M4 T2-T8 focused regressions passed:
  `res://tests/p5m4_weapon_damage_runtime_data_test.gd`,
  `res://tests/p5m4_deterministic_weapon_rolls_test.gd`,
  `res://tests/p5m4_weapon_scaling_percentages_test.gd`,
  `res://tests/p5m4_base_damage_physical_buckets_test.gd`,
  `res://tests/p5m4_death_strike_stack_order_test.gd`,
  `res://tests/p5m4_conversion_ignore_hooks_test.gd`, and
  `res://tests/p5m4_enemy_denial_hooks_test.gd`.
- Combat smoke passed:
  `res://tests/combat_test.gd`.
- All Godot commands emitted the accepted ObjectDB/RID/resource cleanup warnings
  at process exit.

## P5M4-T10 Rounding, Floors, And Mitigation Notes

Completed 2026-09-04.

Implemented final damage policy:

- `DamageCalculator.resolve_damage_packet()` now keeps floating-point damage
  through buckets, crit, conversion, and mitigation, then applies one shared
  finalization step.
- Non-prevented damaging packets floor to at least `1` and round once to whole
  damage at the end of the pipeline.
- Packets that never entered damage mitigation or were fully prevented remain
  `0`, preserving dodge, full block, full absorb, and prevention-style results.
- `resolve_magical_damage()` now delegates to `resolve_damage_packet()` so
  compatibility callers and poison/magical packets share the same floor and
  rounding behavior.

Order locked:

- Physical packets preserve the established direct-hit mitigation order:
  crit negation, armor, then block.
- Magical and poison packets preserve resistance, then absorb.
- Conversion remains after crit and before mitigation.
- Dual conversion remains physical mitigation first, then magical mitigation.
- Blocked and absorbed amount reporting still records the pre-final-floor
  prevented amount, so combat logs and recaps can distinguish partial and full
  prevention.

Compatibility notes:

- Existing fractional expected values in focused combat tests were updated to
  assert the new final rounded damage while leaving the pre-round formula in
  each test body.
- Combat UI formatting remains presentation-only; combat totals now receive
  whole-damage values directly from the calculator.

Verification:

- Focused T10 check passed:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m4_rounding_floors_mitigation_order_test.gd`.
- P5M4 focused regressions passed:
  `res://tests/p5m4_weapon_damage_runtime_data_test.gd`,
  `res://tests/p5m4_deterministic_weapon_rolls_test.gd`,
  `res://tests/p5m4_weapon_scaling_percentages_test.gd`,
  `res://tests/p5m4_base_damage_physical_buckets_test.gd`,
  `res://tests/p5m4_death_strike_stack_order_test.gd`,
  `res://tests/p5m4_conversion_ignore_hooks_test.gd`,
  `res://tests/p5m4_enemy_denial_hooks_test.gd`, and
  `res://tests/p5m4_retrigger_semantics_test.gd`.
- Existing combat regressions passed:
  `res://tests/engine_mechanics_test.gd`,
  `res://tests/opportunity_strikes_test.gd`,
  `res://tests/enemy_defense_mechanics_test.gd`,
  `res://tests/legendary_mechanics_test.gd`,
  `res://tests/deterministic_replay_test.gd`,
  `res://tests/combat_recap_test.gd`,
  `res://tests/combat_playback_test.gd`, and
  `res://tests/combat_test.gd`.
- All Godot commands emitted the accepted ObjectDB/RID/resource cleanup warnings
  at process exit.

## P5M4-T11 Focused Regression And Smoke Notes

Completed 2026-09-04.

Added integrated smoke coverage:

- Added `project/tests/p5m4_practice_room_combat_smoke_test.gd`.
- The smoke builds a real Practice Room Rogue with Assassin and Bladedancer
  trees, satisfies real talent prerequisites, forces Opportunity Strikes through
  its existing trigger resource, equips Umbral Stiletto, adds a Practice Room
  physical-damage gear affix, configures a defended practice target, and runs a
  seeded fight.
- The smoke asserts the Practice Room fight signature matches a direct
  `CombatResolver.resolve()` call with the same resolved build, target,
  duration, and seed.
- It also asserts the M4 pieces are present together: Legendary weapon damage
  range 21-27 without fallback, separated gear and talent physical buckets,
  poison stacks/ticks, Death Strike weapon-roll data, Opportunity Strikes as a
  separate proc cast, source trigger presentation metadata, and whole-number
  final damage values.

Focused regression coverage now present:

- Weapon range lookup and fallback:
  `res://tests/p5m4_weapon_damage_runtime_data_test.gd`.
- Deterministic weapon-roll order:
  `res://tests/p5m4_deterministic_weapon_rolls_test.gd`.
- Rogue physical weapon-scaling percentages:
  `res://tests/p5m4_weapon_scaling_percentages_test.gd`.
- Flat base damage and separated physical buckets:
  `res://tests/p5m4_base_damage_physical_buckets_test.gd`.
- Death Strike stack/weapon scaling order:
  `res://tests/p5m4_death_strike_stack_order_test.gd`.
- Damage conversion and ignore hooks:
  `res://tests/p5m4_conversion_ignore_hooks_test.gd`.
- Enemy denial hooks:
  `res://tests/p5m4_enemy_denial_hooks_test.gd`.
- Retrigger-as-new-cast semantics:
  `res://tests/p5m4_retrigger_semantics_test.gd`.
- Final rounding, floors, and mitigation order:
  `res://tests/p5m4_rounding_floors_mitigation_order_test.gd`.

Verification:

- Full P5M4 focused regression band passed:
  `res://tests/p5m4_weapon_damage_runtime_data_test.gd`,
  `res://tests/p5m4_deterministic_weapon_rolls_test.gd`,
  `res://tests/p5m4_weapon_scaling_percentages_test.gd`,
  `res://tests/p5m4_base_damage_physical_buckets_test.gd`,
  `res://tests/p5m4_death_strike_stack_order_test.gd`,
  `res://tests/p5m4_conversion_ignore_hooks_test.gd`,
  `res://tests/p5m4_enemy_denial_hooks_test.gd`,
  `res://tests/p5m4_retrigger_semantics_test.gd`,
  `res://tests/p5m4_rounding_floors_mitigation_order_test.gd`, and
  `res://tests/p5m4_practice_room_combat_smoke_test.gd`.
- Adjacent combat and presentation smoke checks passed:
  `res://tests/engine_mechanics_test.gd`,
  `res://tests/opportunity_strikes_test.gd`,
  `res://tests/enemy_defense_mechanics_test.gd`,
  `res://tests/legendary_mechanics_test.gd`,
  `res://tests/deterministic_replay_test.gd`,
  `res://tests/combat_recap_test.gd`,
  `res://tests/combat_playback_test.gd`, and
  `res://tests/training_room_fight_test.gd`.
- All Godot commands emitted the accepted ObjectDB/RID/resource cleanup warnings
  at process exit while returning exit code 0 with each test's OK marker.

## Current Known Decisions

- P5M4 owns Rogue weapon damage rolls and physical skill scaling.
- P5M4 owns the first implementation of the documented Phase 5 damage
  calculation order.
- P5M4 should build on `StatCatalog`, `StatSheet`, and the current
  `PlayerStats` bridge rather than replacing the whole stat foundation.
- Rogue dagger damage ranges are final enough for implementation:
  Crude 16-20, Basic 17-19, Master 17-21, Epic 18-20, Cursed 17-23,
  Chaos 16-25, Unique 19-25, and Legendary 21-27.
- Rogue physical skill weapon-scaling percentages are final enough for
  implementation: Stab 100%, Heavy Slash 166%, Quick Cut 66%, Steal 106%,
  Venom Jab 22%, Poison Strike 83%, Rending Slash 78%, Beguiling Strike 22%,
  and Death Strike 111%.
- Weapon damage rolls once per skill cast. A retrigger is a new cast and rolls
  weapon damage again.
- Flat `Base Damage` adds directly to weapon damage before physical skill
  scaling.
- Death Strike adds 1 flat damage per active poison stack before weapon scaling.
- Elemental damage does not scale from weapon damage.
- Damage modifiers use buckets. Gear percent physical damage and talent
  physical damage are separate buckets.
- Crit happens before damage conversion. Damage conversion happens before
  mitigation.
- The current mitigation order is preserved: physical direct hits use crit
  negation, then armor, then block; elemental and poison damage use resistance,
  then absorb.
- If both physical and magical conversion Specials are active, the damage packet
  counts as both types and is mitigated through physical first, then elemental.
- `You ignore armor, but can no longer apply shred` treats armor as 0 for
  player physical mitigation and prevents player shred application while active.
- `You ignore resistance, but your physical damage is reduced by 50%` treats
  resistance as 0 for player elemental mitigation and applies the 50% penalty
  to original physical damage after damage calculation but before conversion.
- Damaging hits floor at 1 unless a defined avoidance, block, absorb, immunity,
  or prevention mechanic fully prevents the hit.
- Damage calculation should use floating point throughout and round once after
  mitigation.
- P5M4 should not implement full procedural rarity/stat rolling, Shop Lab
  tuning, final reward/shop integration, final item-card presentation, Hood or
  Doublet art, final Legendary fixed packages, or full Phase 5 validation.

## Resolved M4 Implementation Questions

- Weapon-roll state now lives on `CombatResolver.CastEvent` and contribution
  metadata. Combat playback remains presentation-only and replays resolved
  event data without rerolling combat.
- Weapon damage ranges live in the combat-facing `WeaponDamageCatalog`, with
  `BuildResolver` bridging the active equipped weapon range into `PlayerStats`.
- Focused calculator tests cover final floor, rounding, and mitigation order
  without adding player-facing debug fields.

## Remaining Handoff Items

- P5M5 owns full procedural rarity and stat-count rules for Basic, Master,
  Epic, Cursed, Chaos, and Unique gear.
- P5M5 owns generated Unique Special rolls and the final Cursed/Chaos drawback
  generator behavior. P5M4 only consumes the Special hooks that affect combat
  damage once those hooks exist on `PlayerStats`.
- P5M6 owns Shop Lab simulation for rarity odds, contract-depth scaling,
  provisional ranges, Special frequency, Rare-stat drawback needs, and
  retrigger-cap risk.
- P5M7 owns generated reward/shop integration in the live Adventure loop.
- P5M8/P5M9 own final item-card presentation, Helm/Armor usability polish, and
  Hood/Doublet art.
- P5M10 owns final fixed Legendary stat packages and value tuning. P5M4
  preserved retained Legendary behavior and uses the current Legendary weapon
  damage range.
- P5M11 owns full Practice Room and Balance Lab validation after generator,
  shop, reward, presentation, and Legendary milestones land.

## Completion Notes

Completed 2026-09-04.

P5M4 moved Rogue physical combat onto deterministic weapon damage rolls while
preserving the current synchronous combat boundary, seeded replay, Practice Room
fight setup, combat recap/playback presentation, save/load assumptions, and the
P5M3 stat foundation.

Implementation summary:

- `WeaponDamageCatalog` defines combat-facing Rogue dagger ranges for Crude,
  Basic, Master, Epic, Cursed, Chaos, Unique, and Legendary weapons, with
  explicit fallback behavior for missing or invalid weapons.
- `BuildResolver` resolves the active equipped Weapon into `PlayerStats`, so
  combat can consume weapon ranges without receiving raw gear.
- `CombatResolver.CastEvent` records weapon roll data and contribution
  metadata for deterministic replay and presentation.
- Authored Rogue physical skills use the documented weapon-scaling percentages;
  unlisted physical effects retain fixed-damage compatibility.
- Flat `Base Damage` and Bandit Blade's gold-scaled flat physical bonus add
  before physical skill scaling.
- Gear Percent Physical Damage and class/talent physical damage resolve into
  separated multiplicative buckets, while the legacy total multiplier remains
  synchronized for compatibility.
- Death Strike resolves as one weapon-scaled physical packet: one weapon roll,
  active poison stacks as flat pre-scaling damage, flat Base Damage/Bandit
  Blade bonus once, the 111% scalar, then the shared physical pipeline.
- Damage packets consume the P5M3 combat-facing Special hooks for conversion,
  armor/resistance ignore, and enemy denial of dodge, block, absorb, suppress,
  and cleanse.
- Retriggers resolve as separate same-timestamp proc casts with fresh weapon
  rolls, fresh crit rolls, full state processing, source filtering, recursion,
  and a hard chain cap.
- Damage calculation now keeps floating-point values through the pipeline,
  applies crit before conversion and conversion before mitigation, preserves
  physical and magical mitigation order, floors non-prevented damaging hits at
  1, and rounds once at the end.
- Focused P5M4 tests plus an integrated Practice Room combat smoke check cover
  the implemented weapon range, roll, scaling, bucket, Death Strike, Special,
  retrigger, rounding, and presentation-relevant behavior.

Final verification:

- Full P5M4 focused regression band passed:
  `res://tests/p5m4_weapon_damage_runtime_data_test.gd`,
  `res://tests/p5m4_deterministic_weapon_rolls_test.gd`,
  `res://tests/p5m4_weapon_scaling_percentages_test.gd`,
  `res://tests/p5m4_base_damage_physical_buckets_test.gd`,
  `res://tests/p5m4_death_strike_stack_order_test.gd`,
  `res://tests/p5m4_conversion_ignore_hooks_test.gd`,
  `res://tests/p5m4_enemy_denial_hooks_test.gd`,
  `res://tests/p5m4_retrigger_semantics_test.gd`,
  `res://tests/p5m4_rounding_floors_mitigation_order_test.gd`, and
  `res://tests/p5m4_practice_room_combat_smoke_test.gd`.
- Adjacent combat and presentation smoke checks passed:
  `res://tests/engine_mechanics_test.gd`,
  `res://tests/opportunity_strikes_test.gd`,
  `res://tests/enemy_defense_mechanics_test.gd`,
  `res://tests/legendary_mechanics_test.gd`,
  `res://tests/deterministic_replay_test.gd`,
  `res://tests/combat_recap_test.gd`,
  `res://tests/combat_playback_test.gd`,
  `res://tests/training_room_fight_test.gd`,
  `res://tests/p5m2_gear_data_shape_test.gd`,
  `res://tests/p5m3_foundation_regression_test.gd`, and
  `res://tests/save_load_test.gd`.

Known non-blockers:

- Godot headless scripts still emit accepted ObjectDB/RID/resource cleanup
  warnings at process exit while returning exit code 0 with OK markers.
- `save_load_test.gd` intentionally logs a corrupt JSON parse while testing
  corrupt-save handling.
- Full procedural rarity generation, reward/shop integration, final item-card
  presentation, art, Legendary fixed-stat tuning, Shop Lab tuning, and broad
  Balance Lab validation remain later Phase 5 work.

Next milestone:

- P5M5 is ready to begin Gear Generator And Rarity Rules on top of the completed
  P5M4 weapon damage baseline.
