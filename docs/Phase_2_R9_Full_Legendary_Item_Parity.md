# P2:R9 - Full Legendary Item Parity

## Purpose

Track the work for **P2:R9 - Full Legendary Item Parity**.

Added 2026-07-21 as a deliberate second Phase 2 scope revision, after
`P2:R8:T6` smoke testing raised the question of why only two Legendaries
(Wyvern Kriss, Mithril Karambit) ever appear. The prior scope decision
(`docs/Phase_2_Milestones.md`'s 2026-07-17 `P2:R5` scope-update note) had
deliberately deferred Bandit Blade, Umbral Stiletto, and Bejeweled Push
Dagger to Phase 3+ "unless route reward scope is deliberately expanded." The
user has now deliberately expanded it: all 5 Phase 1 Rogue Legendaries
should exist, and Project Bane should go beyond literal Phase 1 parity by
also making all 5 reachable through the Adventure loop, not just Training
Room (`P2:R10`).

This is not a reversal made lightly -- it is recorded here, explicitly, per
the project's working agreement to classify scope changes rather than build
them silently.

## Scope Decisions (locked in 2026-07-21)

- All 5 Legendaries (Wyvern Kriss, Mithril Karambit, Bandit Blade, Umbral
  Stiletto, Bejeweled Push Dagger) get real `GearItem` data with their exact
  Phase 1 effects from `Content_Library_Reference.md`.
- Knives' reward changes from a fixed 2-item choice to a **seeded random
  choice of 2 of the 5** Legendaries.
- The Tavern shop's existing low-chance Legendary drop (`build_state.gd`'s
  `CONTRACT_SHOP_LEGENDARY_WEIGHT`, currently `1` in `100`, i.e. 1%) extends
  from its current 2-item `SHOP_LEGENDARY_PATHS` pool to all 5. The 1% weight
  is kept as-is unless playtesting suggests otherwise.
- The shop should not offer a Legendary the player already owns/has equipped
  (a real gap today with 2 items that becomes more visible with 5).
- All 5 are also directly selectable in Training Room (`P2:R10`), independent
  of Adventure drop/reward RNG.

## Exit Criteria

P2:R9 is complete when:

- All 5 Legendaries exist as real `GearItem` resources with correct,
  hand-verified effects.
- Knives offers a seeded-random choice of 2 of the 5 on every playthrough.
- The shop can roll any of the 5 (still gated at the existing low weight),
  excluding ones already owned/equipped.
- Every new mechanic a Legendary depends on (gear-granted skill unlock,
  gold-scaling physical damage, minimum-cast-time proc) is implemented and
  covered by a focused test.
- The full regression suite passes, including a rewritten
  `legendary_reward_test.gd` that no longer assumes a fixed pair.
- Docs (`Phase_2_Milestones.md`, this doc,
  `Phase_2_R8_Playtest_Build.md`'s known-issues note) are updated.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R9:T1 | Add Gear-Granted Skill Unlock | `GearItem.unlocked_skills` wired into build resolution | Complete |
| P2:R9:T2 | Add Gold-Scaling Physical Damage | Dynamic per-gold flat damage bonus wired into build resolution and damage calc | Complete |
| P2:R9:T3 | Add Minimum-Cast-Time Proc | Seeded per-cast timing proc in `CombatResolver` | Complete |
| P2:R9:T4 | Author The 3 New Legendaries | `bandit_blade.tres`, `umbral_stiletto.tres`, `bejeweled_push_dagger.tres` | Complete |
| P2:R9:T5 | Randomize Knives' Legendary Choice | Knives offers a seeded 2-of-5 choice | Complete |
| P2:R9:T6 | Extend Shop Legendary Pool + Dedupe | Shop can roll any of the 5, never one already owned | Complete |
| P2:R9:T7 | Add/Update Tests | New mechanic tests, rewritten `legendary_reward_test.gd`, full suite green | Complete |
| P2:R9:T8 | Update Docs | This doc, Milestones.md, R8 known-issues note | Complete |

## P2:R9:T1 - Add Gear-Granted Skill Unlock

Needed for Umbral Stiletto ("unlocks Death Strike").

Today, `BuildResolver.resolve_unlocked_skills()` (`build_resolver.gd:44`)
only reads `SubclassTree.unlocked_skills` and `Talent.unlocked_skills`.
Add:

- `GearItem.unlocked_skills: Array[Skill] = []`, mirroring
  `Talent.unlocked_skills` (`talent.gd:9`).
- A new `equipped_gear` input to `resolve_unlocked_skills()` (or a
  follow-up call site change wherever it's invoked from `combat_screen.gd`)
  so equipped weapon/trinket/charm items contribute their unlocked skills
  the same way trees and talents do.

Death Strike (`data/skills/death_strike.tres`) already exists from Shadow's
`P2:R5` work and is normally unlocked via the `umbral_pressure.tres` Shadow
talent -- this task makes it *also* reachable via Umbral Stiletto regardless
of chosen trees/talents, exactly like Phase 1.

## P2:R9:T2 - Add Gold-Scaling Physical Damage

Needed for Bandit Blade ("+1 physical damage per 10 current gold").

Every other affix bakes a static value into a `.tres` file and is applied
the same way regardless of run state. This is the first affix that must
read a *live* value (current gold) at resolve time. Add:

- `GearItem.physical_damage_per_gold: float = 0.0` (Bandit Blade sets
  `0.1`, i.e. `+1` per `10` gold).
- `PlayerStats.bonus_physical_damage: float = 0.0`, a new flat (additive)
  field distinct from the existing `physical_damage_multiplier`.
- `BuildResolver.resolve_stats()` gains a `current_gold: int` parameter and
  computes `bonus_physical_damage = current_gold * physical_damage_per_gold`
  from equipped gear.
- `DamageCalculator.resolve_physical_hit()` adds `bonus_physical_damage` as
  flat bonus damage (before armor mitigation, consistent with how base
  skill damage is treated).
- Every call site of `resolve_stats()` (Adventure fights, Training Room)
  must pass the correct live gold value -- Adventure passes
  `BuildState.gold`; Training Room (`P2:R10`) passes its own transient
  practice-gold value, not real save-file gold.

## P2:R9:T3 - Add Minimum-Cast-Time Proc

Needed for Bejeweled Push Dagger ("20% chance normal casts use minimum
cast time").

`CombatTiming.execution_time_ms()` (`combat_timing.gd:5`) already computes
`max(skill.min_execution_ms, scaled_ms)` -- the floor exists, but nothing
ever forces a cast to hit that floor early. Add:

- `GearItem.min_cast_time_proc_chance: float = 0.0` and a matching
  `PlayerStats` field.
- A seeded per-cast roll in `CombatResolver`'s cast loop (same discipline as
  the existing Opportunity Strikes/Mithril Karambit proc rolls -- one shared
  per-fight seeded RNG, no ad hoc unseeded rolls) that, on success, uses
  `skill.min_execution_ms` directly instead of
  `CombatTiming.execution_time_ms()`'s scaled result for that cast.
- `CastEvent` should record whether the min-cast-time proc fired, mirroring
  how `armor_reduction_applied` is already logged, so it's hand-verifiable
  in test output.

## P2:R9:T4 - Author The 3 New Legendaries

Exact Phase 1 values from `Content_Library_Reference.md`:

- **Bandit Blade** -- `x1.2` physical damage, `+20%` crit chance, `+1`
  physical damage per `10` current gold.
- **Umbral Stiletto** -- `+10%` crit chance, `+1` crit multiplier, unlocks
  Death Strike.
- **Bejeweled Push Dagger** -- `x1.2` physical damage, `+40%` crit chance,
  `20%` chance normal casts use minimum cast time.

Follow the existing `wyvern_kriss.tres`/`mithril_karambit.tres` pattern:
`tier = LEGENDARY`, `slot = WEAPON`, standard affixes for the
non-mechanic-specific parts, plus the new field(s) from T1-T3 for the
mechanic-specific clause.

## P2:R9:T5 - Randomize Knives' Legendary Choice

Today `knives.tres` hardcodes
`gear_choice_rewards = [wyvern_kriss, mithril_karambit]`, and
`_gear_choices_for_reward()` (`build_state.gd:580`) just returns whatever is
in that static array, verbatim.

Add a new reward field -- e.g. `EncounterReward.legendary_choice_pool:
Array[GearItem]` plus `legendary_choice_count: int` -- and extend
`_gear_choices_for_reward()` to seed-sample `legendary_choice_count`
*distinct* items from the pool, using the same seeded-RNG discipline already
used for `generated_gear_choice_count`'s slot sampling in that same
function. `knives.tres` sets the pool to all 5 Legendaries and count to `2`.
Reproducibility matters here: the same Adventure seed must always produce
the same 2-of-5 choice.

## P2:R9:T6 - Extend Shop Legendary Pool + Dedupe

`build_state.gd`'s `SHOP_LEGENDARY_PATHS` (line 55) currently lists 2 paths;
`_shop_offer_for_tier()` (line 565) already picks a random entry from
whatever-length list is there, so extending the array to 5 paths needs no
other RNG-plumbing changes.

Add a dedupe check: when the shop rolls `Tier.LEGENDARY`, exclude any
Legendary already in `inventory`/equipped from the roll (re-roll the tier or
fall back to the next-lower tier if every Legendary is already owned).
This gap exists today with 2 items but is more likely to surface with 5.

## P2:R9:T7 - Add/Update Tests

- Rewrite `legendary_reward_test.gd`: it currently asserts
  `pending_reward_choices.size() == 2` and `.has(wyvern)`/`.has(mithril)`
  exactly (a fixed-pair assumption that no longer holds). Replace with:
  choices are 2 *distinct* items drawn from the 5-item pool, all
  `tier == LEGENDARY`, and the same seed reproduces the same 2 choices while
  a different seed can produce a different 2.
- New focused tests for each T1-T3 mechanic: gear-granted skill unlock
  (Umbral Stiletto unlocks Death Strike regardless of talents/trees),
  gold-scaling damage (varying `current_gold` changes resolved damage
  predictably), minimum-cast-time proc (seeded roll is deterministic and
  actually shortens a cast to `min_execution_ms` on success).
- Shop test coverage for the dedupe rule (already-owned Legendary never
  rolled) and for all 5 paths being reachable.
- Full `project/tests/*.gd` regression suite run serially per the project's
  established headless workflow.

## P2:R9:T8 - Update Docs

- Update `docs/Phase_2_Milestones.md`'s roadmap table and immediate-next-step
  note.
- Update `docs/Phase_2_R8_Playtest_Build.md`'s known-issues entry about "only
  two Legendaries" to point at this milestone instead of describing it as
  permanent intended scope.
- Close out this document's checklist and record final Implementation/
  Verification Notes.

## Implementation Notes

2026-07-21:

- `P2:R9:T1 - Add Gear-Granted Skill Unlock` is complete.
  `GearItem.unlocked_skills: Array[Skill] = []` added
  (`scripts/resources/gear_item.gd`).
  `BuildResolver.resolve_unlocked_skills()` gained an `equipped_gear`
  parameter (default `[]`) and a loop appending each equipped item's
  `unlocked_skills`, mirroring the existing tree/talent loops
  (`scripts/systems/build_resolver.gd`). The one real call site,
  `BuildState.unlocked_skills()`, now passes `equipped_gear()`
  (`scripts/autoload/build_state.gd`). No other production call site exists;
  the one test call site (`export_shadow_probe.gd`) is unaffected since the
  new parameter defaults to empty.
- `P2:R9:T2 - Add Gold-Scaling Physical Damage` is complete.
  `GearItem.physical_damage_per_gold: float = 0.0` and
  `PlayerStats.bonus_physical_damage: float = 0.0` added.
  `BuildResolver.resolve_stats()` gained a `current_gold: int = 0` parameter;
  its existing gear loop now accumulates
  `gear.physical_damage_per_gold * float(current_gold)` into
  `bonus_physical_damage`. `CombatResolver._apply_skill_effects()` adds
  `player.bonus_physical_damage` to the raw amount fed into
  `DamageCalculator.resolve_physical_hit()` for both the `PhysicalDamageEffect`
  and `StackScalingPhysicalDamageEffect` branches, so it crits/mitigates like
  base damage and applies to both physical-hit types, consistent with how
  `physical_damage_multiplier` already applies to both. The two real-play
  call sites now pass live gold: `combat_screen.gd`'s `_on_fight_pressed()`
  and `character_stats_panel.gd`'s `_refresh()` both pass `BuildState.gold`.
  Every other call site (tests, `character_stats_panel.gd`'s zero-bonus
  `base_stats` comparison) keeps the default `0`, so no existing build's
  resolved stats change.
- `P2:R9:T3 - Add Minimum-Cast-Time Proc` is complete.
  `GearItem.min_cast_time_proc_chance: float = 0.0` and a matching
  `PlayerStats` field added (summed across equipped gear in the same
  `resolve_stats()` gear loop as T2). `CombatResolver.resolve()`'s cast loop
  now rolls `player.min_cast_time_proc_chance` before computing `exec_ms`;
  on success it uses `skill.min_execution_ms` directly instead of
  `CombatTiming.execution_time_ms()`. `CastEvent.min_cast_time_proc_applied`
  records whether it fired, mirroring `armor_reduction_applied`. The roll
  uses `and` short-circuiting (`chance > 0.0 and rng.randf() <= chance`), so
  builds without this Legendary (`chance == 0.0`, the default) never consume
  the extra RNG draw -- every other seeded system (crit rolls, Opportunity
  Strikes, etc.) is provably unaffected for existing builds.
- Added `project/tests/legendary_mechanics_test.gd`, a new focused headless
  test covering all three mechanics with synthetic Skill/GearItem/PlayerStats
  objects (not real Legendary content), following the existing
  `engine_mechanics_test.gd` pattern. Caught one real bug while writing it:
  `resolve_stats()` (unlike `resolve_unlocked_skills()`) dereferences
  `class_def.base_stats` unconditionally and crashes on a `null` class_def --
  this is existing, correct production behavior (every real caller always
  has a real `ClassDef`), so the test was fixed to use a minimal synthetic
  `ClassDef` rather than changing production code to tolerate `null`.
- `P2:R9:T7` is partially complete: the three new-mechanic tests are done and
  passing. Rewriting `legendary_reward_test.gd` for the 2-of-5 Knives choice
  is still pending `P2:R9:T5`.
- `P2:R9:T4` (author the 3 new Legendary `.tres` files),
  `P2:R9:T5` (randomize Knives), and `P2:R9:T6` (extend shop pool + dedupe)
  are not yet started -- they depend on `GearItem`'s new fields (this pass)
  but are separate follow-up work.

2026-07-21 (continued):

- `P2:R9:T4 - Author The 3 New Legendaries` is complete. Added
  `project/data/gear/bandit_blade.tres`, `umbral_stiletto.tres`, and
  `bejeweled_push_dagger.tres`, following the exact `wyvern_kriss.tres`/
  `mithril_karambit.tres` format: `tier = LEGENDARY`, `slot = WEAPON`,
  standard `StatModifier` affixes for the non-mechanic-specific parts of
  each item's Phase 1 spec, plus the `P2:R9:T1`-`T3` dedicated fields for
  the mechanic-specific clause:
  - Bandit Blade: `PHYSICAL_DAMAGE` x1.2, `CRIT_CHANCE` +0.2,
    `physical_damage_per_gold = 0.1`.
  - Umbral Stiletto: `CRIT_CHANCE` +0.1, `CRIT_MULTIPLIER` +1.0,
    `unlocked_skills = [death_strike.tres]` (confirmed
    `id = "skill.killers_mark"`, the same Death Strike instance already
    used by the Shadow talent `umbral_pressure.tres` -- this item unlocks
    it independently of Shadow/talent choices, per T1's mechanism).
  - Bejeweled Push Dagger: `PHYSICAL_DAMAGE` x1.2, `CRIT_CHANCE` +0.4,
    `min_cast_time_proc_chance = 0.2`.
- Extended `legendary_reward_test.gd` (not a new file -- added to the
  existing focused Legendary test) with hand-verified assertions for all 3
  new items: tier, each affix's resolved value against Rogue's real base
  stats (`crit_chance = 0.15`, `crit_multiplier = 2.0`,
  `physical_damage_multiplier = 1.0`, confirmed by reading
  `rogue_starter.tres` directly rather than assumed), Bandit Blade's
  gold-scaling at both `100` and `0` gold, and Umbral Stiletto's unlock via
  `resolve_unlocked_skills()` returning a skill with
  `id == "skill.killers_mark"`. Deliberately left the existing fixed-pair
  Knives-choice assertions (`pending_reward_choices.size() == 2`, `.has(wyvern)`/
  `.has(mithril)`) untouched -- those are still correct today and are
  `P2:R9:T5`'s job to update, not `T4`'s.
- The next active tasks are `P2:R9:T5 - Randomize Knives' Legendary Choice`
  and `P2:R9:T6 - Extend Shop Legendary Pool + Dedupe`.

2026-07-21 (continued -- P2:R9:T5/T6/T7):

- `P2:R9:T5 - Randomize Knives' Legendary Choice` is complete.
  `EncounterReward` gained `legendary_choice_pool: Array[GearItem]` and
  `legendary_choice_count: int`. `BuildState._gear_choices_for_reward()`
  now seed-samples `legendary_choice_count` distinct items from the pool
  (new `_sample_distinct_gear()` helper: shuffle-by-removal without
  replacement) whenever the pool is non-empty, using the same
  `RunRngSystem.CONTEXT_REWARD_CHOICE` context discipline as the existing
  `generated_gear_choice_count` sampling in the same function -- reproducible
  per Adventure seed. `knives.tres` now declares `legendary_choice_pool` as
  all 5 Legendaries with `legendary_choice_count = 2`, replacing the old
  hardcoded `gear_choice_rewards = [wyvern, mithril]`; its `reward_summary`
  text changed to "42g and a choice of 2 of 5 possible Legendary weapons."
- `P2:R9:T6 - Extend Shop Legendary Pool + Dedupe` is complete.
  `SHOP_LEGENDARY_PATHS` now lists all 5 Legendary paths (the existing
  `rng.randi_range(0, SHOP_LEGENDARY_PATHS.size() - 1)` roll needed no
  change to handle the longer list). Added
  `_unowned_shop_legendary_paths()`, which filters the path list against
  everything in `inventory` plus `equipped_gear()` by `.id` (not object
  identity, consistent with `_shop_offer_signature()`'s existing
  property-based comparisons). `_shop_offer_for_tier()` now rolls only among
  unowned paths, and falls back to generating a `CURSED`-tier item instead
  if the player already owns every Legendary (rather than ever offering a
  duplicate the player can't meaningfully buy).
- `P2:R9:T7 - Add/Update Tests` is complete. Updated 4 existing test files
  for the new data shape rather than writing a parallel test suite:
  - `contract_route_data_test.gd`: replaced the stale
    `hard_knives.reward.gear_choice_rewards[0].tier` index (now out of
    bounds, since that array is empty) with
    `legendary_choice_pool[0].tier`, and replaced the fixed-pair
    `gear_choice_rewards.size()/ [0]/[1]` assertions with pool-membership
    checks for all 5 ids plus a `reward_summary.contains("2 of 5")` check.
  - `route_reward_choice_ui_test.gd`: the Knives section no longer assumes
    which 2 of 5 appear -- it asserts 2 distinct Legendary-tier choices,
    that each button's tooltip names its own choice
    (`tooltip_text.contains(choice.display_name)`), and that choosing the
    first button equips exactly that choice by id.
  - `legendary_reward_test.gd`: same treatment for the
    `claim_current_reward()`/`pending_reward_choices`/
    `choose_pending_reward_gear()` flow -- asserts 2 distinct Legendary
    choices drawn from `knives.reward.legendary_choice_pool`'s ids, then
    picks `pending_reward_choices[0]` and verifies it equips. The `T4`
    hand-verification of each item's own resolved stats (added earlier
    today) was untouched since it loads items directly, independent of the
    Knives choice flow.
  - `run_rng_context_test.gd`: added two new blocks rather than a new file,
    matching its existing charter (seeded-RNG reproducibility checks) --
    one proving the 2-of-5 Legendary choice is reproducible per seed and
    varies across seeds (same pattern as the pre-existing
    `generated_gear_choice_count` reproducibility block just above it), and
    one directly exercising `_unowned_shop_legendary_paths()`/
    `_shop_offer_for_tier()`'s dedupe and `CURSED`-fallback behavior
    (owning 0, then 1, then all 5 Legendaries).
- Ran the 4 touched tests individually first (all passed first try, no
  fixes needed), then the full 30-file regression suite: all 30 exited `0`,
  and every log was grepped for `SCRIPT ERROR`/`Assertion failed`/
  `ERROR: Expected` (none found). No stale Godot processes remained after
  either run.
- All of `P2:R9:T1`-`T7` are now complete. Only `P2:R9:T8 - Update Docs`
  remains, in progress as this note is written.

## Verification Notes

2026-07-21:

- Ran the new `legendary_mechanics_test.gd` in isolation first (headless,
  escalated filesystem access to avoid the known local sandboxed Godot
  startup crash): confirmed gear-unlock skill count (0 without gear, 1 with),
  gold-scaling `bonus_physical_damage` at 0 and 100 gold (0.0 and 10.0),
  the bonus applying to both a flat physical hit (10 base + 5 bonus = 15.0)
  and a stack-scaling hit (4.0 base + 5 bonus = 9.0), the min-cast-time proc
  resolving to the right chance (0.20), a guaranteed proc (chance 1.0)
  fitting 2 casts at the 500ms floor into a 1000ms window where 0 fit
  without it, and a 0.0-chance run reproducing the same 0-cast result as the
  no-proc baseline. All assertions passed; only the known benign
  ObjectDB/resource shutdown warnings printed.
- One first-attempt failure while writing the test: passing `null` as
  `class_def` to `resolve_stats()` (matching how `resolve_unlocked_skills()`
  tolerates `null`) crashed with `SCRIPT ERROR: Invalid access to property
  or key 'base_stats' on a base object of type 'Nil'` at
  `build_resolver.gd:15`, then hung (the known bare-`assert()`-never-
  reaches-`quit()` trap) rather than exiting non-zero. Diagnosed via
  `Get-Process`, force-killed the stuck `Godot_v4.7-stable_win64`/
  `..._console` processes, read the `--log-file` output directly to find the
  `SCRIPT ERROR`, and fixed the test (added a `_make_class_def()` helper)
  rather than changing production code -- this is correct existing behavior,
  not a bug.
- Ran the full regression suite: all 30 `project/tests/*.gd` files
  (29 pre-existing plus the new one), serially, each with a distinct
  `user://logs/r9_full_<test>.log`, escalated filesystem access. All 30
  exited `0`. Additionally grepped every log for
  `SCRIPT ERROR`/`Assertion failed`/`ERROR: Expected` (none found) and spot-
  checked the tail of every test whose call sites this pass touched
  (`combat_screen_test`, `save_load_test`, `gear_generator_test`,
  `inventory_model_test`, `legendary_reward_test`) to confirm each printed
  its real final success line rather than exiting early.
- No stale Godot processes remained after the suite (checked via
  `Get-Process` before and after).

2026-07-21 (continued -- P2:R9:T4):

- Ran the extended `legendary_reward_test.gd` in isolation first (headless,
  escalated filesystem access): all 3 new items loaded, all resolved to
  their expected values on the first attempt --
  `Bandit Blade: phys_mult=1.20 crit=0.35 bonus_phys=10.00`,
  `Umbral Stiletto: crit=0.25 crit_mult=3.00`, confirmed unlocking Death
  Strike, `Bejeweled Push Dagger: phys_mult=1.20 crit=0.55
  min_cast_proc=0.20` -- plus the pre-existing Wyvern Kriss/Mithril
  Karambit/Knives-choice assertions, all still passing unmodified. Only the
  known benign ObjectDB/resource shutdown warnings printed.
- Ran the full regression suite again: all 30 `project/tests/*.gd` files,
  serially, distinct `user://logs/r9_t4_full_<test>.log` per file, escalated
  filesystem access. All 30 exited `0`. Grepped every log for
  `SCRIPT ERROR`/`Assertion failed`/`ERROR: Expected` (none found) and
  confirmed `legendary_reward_test.gd`'s log tail shows the new assertions'
  print output followed by `Legendary reward check: OK`.
- No stale Godot processes remained after either run.

2026-07-21 (continued -- P2:R9:T5/T6/T7):

- Ran the 4 tests touched by the T5/T6 data/logic changes individually
  first (`legendary_reward_test`, `contract_route_data_test`,
  `route_reward_choice_ui_test`, `run_rng_context_test`): all 4 passed on
  the first attempt with no fixes needed, printing their real success
  lines (`Legendary reward check: OK`, `Contract route data check: OK`,
  `Route reward choice UI check: OK`, `Run RNG context check: OK`).
- Ran the full regression suite: all 30 `project/tests/*.gd` files,
  serially, distinct `user://logs/r9_t56_full_<test>.log` per file,
  escalated filesystem access. All 30 exited `0`. Grepped every log for
  `SCRIPT ERROR`/`Assertion failed`/`ERROR: Expected` (none found).
- No stale Godot processes remained after either run.
