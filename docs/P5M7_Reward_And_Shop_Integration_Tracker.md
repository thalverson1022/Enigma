# P5M7: Reward And Shop Integration Tracker

## Status

Complete.

P5M7 connects the Phase 5 gear generator to the live Adventure reward and
between-contract shop loop. The milestone is complete: generated gear is now
the main buildcraft reward during contracts, and shop access is constrained to
between-contract or other explicitly allowed non-route transitions.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone documents:

- `docs/P5_Gear_Redesign_Overview.md`
- `docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md`
- `docs/P5M6_Shop_Lab_Gear_Simulation_Tracker.md`

## Milestone Goal

Use the new five-slot gear model in the live Adventure loop. Contract rewards
should always present a choice of two generated gear items, and each choice
should have a low, deterministic chance to upgrade through the rarity ladder
before the item is generated. Between-contract shops should use the Phase 5
rarity set and remain the only shop access point during generated contracts.

P5M7 is not the final item-card presentation pass, Hood/Doublet art pass,
retained Legendary tuning pass, Practice Room expansion, or full balance
validation pass. Those remain assigned to P5M8-P5M11.

## Current Live Reward Structure Audit

Current generated contract rewards are metadata-first:

- `ContractRouteGenerator._assign_generated_reward()` assigns reward metadata
  to route nodes.
- `EncounterReward` stores `generated_gear_choice_count`,
  `generated_gear_tier`, and `generated_gear_slots`.
- `BuildState._gear_choices_for_reward()` materializes actual generated items
  only when the reward is claimed.
- Reward item generation is deterministic from the Adventure seed, reward
  context, tier, choice index, attempt, and slot.

Current node-role behavior after P5M7-T2:

| Node Role | Current Gear Choice Count | Current Slot Pool | Other Rewards |
| --- | ---: | --- | --- |
| Normal | 2 | 1 seeded slot | Gold |
| Captain | 2 | 1 seeded slot | More gold |
| Elite | 2 | 2 seeded slots | More gold, possible talent point at depth 4+ |
| Boss | 2 | All five slots | Highest gold, 1 talent point |

Current tier behavior:

- Rewards use a deterministic baseline tier from encounter difficulty plus role
  bonus.
- Normal and Captain add no role bonus.
- Elite adds +1.
- Boss adds +2.
- Effective score 0-3 grants Basic.
- Effective score 4-5 grants Master.
- Effective score 6+ grants Cursed.
- P5M7-T3 preserves this baseline tier as reward metadata, then applies
  independent per-choice upgrade rolls during reward materialization.
- Epic, Chaos, and Unique can now appear through the P5M7 reward upgrade chain.
- New Legendary reward upgrades remain deferred to P5M10.

Current shop behavior:

- Between-contract shops are already generated through `BuildState`.
- Shop offers use deterministic seed contexts and duplicate-signature guards.
- The live shop now uses the P5M7 Phase 5 Early rarity curve across Basic,
  Master, Epic, Cursed, Chaos, and Unique.
- Procedural Legendary shop rolls remain forbidden; fixed Legendary shop
  handling stays explicit through the existing catalog helper path.

## New P5M7 Reward Decisions

- Every generated gear reward should present exactly two choices.
- Reward choice items upgrade independently. One choice may stay Basic while
  the other climbs to a higher rarity.
- The current deterministic reward tier remains the baseline rarity before
  upgrade rolls.
- Upgrade rolls should be low percentage and deterministic from visible run
  context.
- The promotion chain is:
  - Basic can upgrade to Master.
  - Master can upgrade to Epic.
  - Epic can upgrade into a high-tier result.
  - High-tier results can include Cursed, Chaos, and Unique.
- Procedural Legendary stat packages remain forbidden.
- New Legendary reward upgrades are deferred to P5M10.
- Existing fixed Legendary catalog paths remain explicit compatibility and
  regression paths only.
- No shop should open while the player is still traversing an active generated
  contract route.
- `Increased Gold` affects gold added to the stash, not shop prices, sell
  values, or reroll costs.

## Initial Tuning Proposal

These are implementation starting values, not final balance commitments:

| Upgrade Step | Starting Chance |
| --- | ---: |
| Basic to Master | 15% |
| Master to Epic | 8% |
| Epic to high-tier | 3% |

The first-pass high-tier split is Cursed 50%, Chaos 30%, and Unique 20%.
Legendary reward upgrades are deferred to P5M10.

Upgrade chance may scale modestly with completed contract count, route depth,
or pressure tier, but early rewards should still mostly remain Basic/Master.

## Locked P5M7-T1 Integration Rules

Completed 2026-09-05.

P5M7 uses the following live reward and shop rules for implementation. These
are first-pass integration rules, not final Phase 5 balance commitments.

Reward choice count:

- Every generated contract gear reward presents exactly two gear choices.
- Normal, Captain, Elite, and Boss generated gear rewards all use the two-choice
  structure.
- Fixed rewards, non-gear rewards, scripted rewards, and Lucky Coin remain
  outside the generated gear choice-count rule.

Reward rarity upgrade chain:

- The existing deterministic generated reward tier remains the baseline rarity.
- Each offered reward item rolls its own independent deterministic upgrade
  chain before the item is generated.
- The first-pass upgrade chances are:
  - Basic to Master: 15%.
  - Master to Epic: 8%.
  - Epic to high-tier: 3%.
- Upgrade RNG must include stable visible run context plus reward context,
  choice index, and upgrade step so repeated saves, reloads, and reward-claim
  attempts reproduce the same choices.
- One reward choice may remain at its baseline rarity while the other upgrades.

High-tier and Legendary boundary:

- P5M7 defers new Legendary reward upgrades to P5M10.
- Procedural Legendary stat generation remains forbidden.
- The P5M7 high-tier reward split uses only Cursed, Chaos, and Unique.
- The first-pass high-tier split is Cursed 50%, Chaos 30%, Unique 20%.
- Existing fixed Legendary catalog paths remain valid only where already
  explicitly used, such as current shop fixed-catalog handling or authored
  regression content.

Contract-depth hooks:

- P5M7 uses live contract depth as the shared reward/shop scaling input, clamped
  to the same 1-12 range used by Shop Lab.
- Contract depth should be derived from current generated-contract progression,
  with early contracts resolving near depth 1 and later repeated contracts
  moving toward depth 12.
- Reward upgrade odds may receive only a modest depth bonus in P5M7. The
  implementation should preserve the locked base chances above and avoid making
  early rewards commonly jump multiple tiers.
- Reward item value scaling should use the same depth-value candidate from the
  P5M6 handoff: 1.00x at depth 1, rising linearly to 1.35x at depth 12.

Reward role behavior:

- Boss rewards use the same two-choice upgrade chain as other generated gear
  rewards.
- Boss and Elite excitement continues to come from the existing baseline tier
  role bonus, not from a separate P5M7-only upgrade chance table.

Shop rarity integration:

- Between-contract shops use the Phase 5 procedural rarity set: Basic, Master,
  Epic, Cursed, Chaos, and Unique.
- The first live shop rarity curve starts from the P5M6 Early curve:
  - Depth 1: Basic 65%, Master 23%, Epic 6%, Cursed 2%, Chaos 3%, Unique 1%.
  - Depth 6: Basic 54%, Master 26%, Epic 10%, Cursed 4%, Chaos 4%, Unique 2%.
  - Depth 12: Basic 41%, Master 29%, Epic 15%, Cursed 7%, Chaos 5%, Unique 3%.
- Crude remains starter-only. Lucky Coin remains a fixed Tavern reward.
  Compatibility gear and procedural Legendary stat packages stay out of normal
  generated shop pools.
- Existing fixed-catalog Legendary shop handling may remain explicit, but it
  must not become procedural Legendary stat generation.

Shop timing:

- Shops open only between completed generated contracts or from another
  explicitly non-route transition.
- Shops must not open while the player is traversing an active generated
  contract route.

Gold behavior:

- `Increased Gold` applies when gold is added to the stash.
- `Increased Gold` does not reduce shop prices, reroll costs, sell values, or
  any other outgoing economy cost.

Presentation boundary:

- P5M7 should preserve enough reward metadata for later presentation work, but
  it does not need final rarity-upgrade reveal animations, item-card polish, or
  new art hooks.
- Existing reward and shop UI only needs to tolerate mixed-rarity reward pairs
  and expanded shop rarities until P5M8.

## Exit Criteria

- Contract rewards always offer two gear choices when a generated gear reward
  exists.
- Each reward choice performs its own deterministic rarity upgrade chain before
  item generation.
- Reward upgrade outcomes can include the Phase 5 procedural rarities through
  the documented boundary.
- New Legendary reward upgrades are explicitly deferred to P5M10; existing
  fixed Legendary catalog paths remain explicit compatibility paths only.
- Reward item value scaling receives the chosen live contract-depth hook.
- Between-contract shops use the Phase 5 rarity set and P5M6-informed tuning
  baseline.
- Shops do not open during active generated contract route traversal.
- `Increased Gold` modifies stash gains and does not discount shop prices,
  reroll costs, or sell values.
- Save/load, duplicate reward guards, fixed reward paths, Lucky Coin handling,
  and fixed Legendary catalog paths remain stable.
- Focused regression coverage records deterministic reward upgrades, choice
  count, rarity boundaries, shop rarity generation, gold-gain behavior, and
  no-mid-contract-shop behavior.
- Phase 5 docs are updated with P5M7 completion notes and the P5M8 handoff.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M7-T1: Lock Reward/Shop Integration Rules | Complete | Record the live economy rules before implementation. | Completed 2026-09-05. Locked the two-choice reward rule, deterministic upgrade chain values, high-tier split, Legendary deferral, depth/value hooks, shop rarity curve, no-mid-contract-shop rule, gold behavior, and presentation boundary. |
| P5M7-T2: Update Contract Reward Choice Counts | Complete | Make every generated gear reward present two options. | Completed 2026-09-05. Normal and Captain generated reward metadata now uses two choices like Elite and Boss; fixed/non-gear rewards remain unchanged. Focused test expectations were updated and passed. |
| P5M7-T3: Implement Reward Upgrade Chain | Complete | Add independent per-choice promotion rolls before item generation. | Completed 2026-09-05. Reward choices now roll deterministic per-choice upgrades from Basic to Master to Epic to Cursed/Chaos/Unique before item generation. Focused RNG tests were added and passed. |
| P5M7-T4: Define High-Tier And Legendary Boundary | Complete | Implement high-tier upgrade outcomes safely. | Completed 2026-09-05. Cursed, Chaos, and Unique are the only generated reward high-tier upgrade outputs; Crude and Legendary are excluded, and fixed Legendary reward/shop paths remain separate. |
| P5M7-T5: Add Contract-Depth Upgrade Scaling | Complete | Let reward excitement improve modestly deeper into contracts. | Completed 2026-09-05. Reward upgrade odds now scale from live contract depth 1-12, using the current contract number and a conservative +50% relative max bonus while preserving deterministic replay. |
| P5M7-T6: Apply Live Reward Value Scaling | Complete | Bring reward item magnitudes in line with the P5M6 handoff. | Completed 2026-09-05. `GearGenerator` now applies the 1.00x-to-1.35x contract-depth value curve, and generated reward requests pass live contract depth into item generation. |
| P5M7-T7: Update Between-Contract Shop Rarity Selection | Complete | Move live shops from old rarity weights to the Phase 5 set. | Completed 2026-09-05. Between-contract shops now use the Phase 5 Early depth curve across Basic, Master, Epic, Cursed, Chaos, and Unique; procedural Legendary is excluded while fixed Legendary handling remains explicit. |
| P5M7-T8: Enforce No Mid-Contract Shop Access | Complete | Align shop timing with the contract-loop design. | Completed 2026-09-05. Active contract route rewards no longer open shops even if `shop_unlocked` is still true; shops remain available only after terminal contract completion or allowed Tavern transitions. |
| P5M7-T9: Verify Gold-Gain Stat Behavior | Complete | Ensure economy stats affect rewards, not prices. | Completed 2026-09-05. `Increased Gold` is verified to scale incoming reward gold only; shop prices, reroll costs, purchase spend, and sell values stay fixed. |
| P5M7-T10: Reward And Shop UI Compatibility Pass | Complete | Make current UI tolerate mixed-rarity reward pairs and expanded shop rarities. | Completed 2026-09-05. Reward-choice and shop surfaces now have focused regression coverage for mixed rarity pairs, Phase 5 shop rarities, icons, colors, price badges, and comparison tooltips. |
| P5M7-T11: Add Focused Regression Coverage | Complete | Protect the live economy integration. | Completed 2026-09-05. Focused regression coverage was audited and hardened across reward choice count, deterministic upgrades, rarity bounds, Legendary boundary, save/load, duplicate guards, shop rolls, UI compatibility, and gold behavior. |
| P5M7-T12: Update Docs And Closeout | Complete | Record the implemented behavior and remaining caveats. | Completed 2026-09-05. This tracker, onboarding, Phase 5 overview, and New Gear Overview now record P5M7 completion and the P5M8 handoff. |

## Status Definitions

- `Ready`: The task can be worked now.
- `Blocked`: The task needs a prior task output, implementation decision, or
  design clarification before it can be completed.
- `In Progress`: The task is actively being audited, edited, implemented, or
  reviewed.
- `Complete`: The task output has been added, verified, and recorded.

## Open Decisions

No P5M7-blocking design decisions remain. Live contract-depth derivation,
reward-upgrade depth scaling, and fixed-catalog Legendary boundaries were
implemented and covered by focused regression during T5-T11.

## Completion Notes

P5M7 is complete. P5M8 is the next Phase 5 milestone and owns final item
presentation, including player-facing item cards and any remaining rarity
presentation polish.

P5M7-T1 completed on 2026-09-05. The tracker now locks the implementation rules
for generated reward choice counts, independent deterministic reward upgrade
rolls, first-pass upgrade percentages, the non-Legendary high-tier split,
contract-depth value scaling, live shop rarity curves, no-mid-contract shop
access, `Increased Gold` behavior, and the P5M8 presentation boundary. No code
changes or test runs were required for this documentation-only task.

P5M7-T2 implementation completed on 2026-09-05. `ContractRouteGenerator.REWARD_TABLE` now
assigns two generated gear choices to Normal and Captain rewards, matching the
existing Elite and Boss count. `contract_route_generator_test.gd` now asserts
that Normal, Captain, Elite, and Boss generated rewards all use two choices,
and the former Elite-greater-than-Normal choice-count expectation now checks
that Elite keeps its reward advantage through gold/tier pressure while sharing
the two-choice structure.

Verification initially failed because `Godot_v4.7-stable_win64_console.exe`
was not available on PATH and the default Godot log path crashed while opening
`user://logs`. The working local invocation uses the documented full binary
path plus an explicit project-local `--log-file` path:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\contract_route_generator_test.log --path project -s res://tests/contract_route_generator_test.gd`

Verification passed with `Contract route generator check: OK`. Godot also
reported the accepted cleanup warnings already listed in the onboarding
baseline.

P5M7-T3 implementation completed on 2026-09-05. `BuildState` now applies an
independent deterministic reward rarity upgrade chain per generated reward
choice before calling `GearGenerator.generate_from_request()`. The chain uses
the locked P5M7 values: 15% Basic to Master, 8% Master to Epic, 3% Epic to
high-tier, then Cursed 50%, Chaos 30%, and Unique 20% for the high-tier split.
The deterministic upgrade key includes reward context, choice index, baseline
tier, and upgrade step. The route reward metadata remains the baseline tier,
while the materialized item receives the upgraded tier. New Legendary reward
upgrades remain deferred and are not produced by this chain.

Focused test coverage was added to `run_rng_context_test.gd` for deterministic
upgrade repeatability, searched seeds that exercise Basic-to-Master,
Master-to-Epic, and Epic-to-high-tier paths, independent choice outcomes,
materialized high-tier item generation, and Crude/Legendary exclusion from
reward upgrades.

Verification used the same full binary path plus explicit project-local
`--log-file` workaround:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\run_rng_context_test.log --path project -s res://tests/run_rng_context_test.gd`

Verification passed with `Run RNG context check: OK`. Godot also reported the
accepted cleanup warnings already listed in the onboarding baseline.

P5M7-T4 completed on 2026-09-05. `BuildState` now exposes the generated reward
high-tier upgrade option list through `_reward_upgrade_high_tier_options()` and
checks it through `_is_reward_upgrade_high_tier()`, making the P5M7 boundary
explicit in code: generated reward upgrades can produce Cursed, Chaos, or
Unique, but not Crude or Legendary. `run_rng_context_test.gd` now verifies each
allowed high-tier output is reachable through deterministic searched seeds.
`p5m5_legendary_generator_boundary_test.gd` now also verifies that generated
reward upgrades never produce Crude or Legendary while fixed Legendary reward
pools continue to use `legendary_choice_pool`/`LegendaryCatalog`.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\run_rng_context_test.log --path project -s res://tests/run_rng_context_test.gd` passed with `Run RNG context check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_legendary_generator_boundary_test.log --path project -s res://tests/p5m5_legendary_generator_boundary_test.gd` passed with `P5M5 Legendary generator boundary check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\contract_route_generator_test.log --path project -s res://tests/contract_route_generator_test.gd` passed with `Contract route generator check: OK`.

Godot also reported the accepted root-certificate and cleanup warnings already
listed in the onboarding baseline.

P5M7-T7 completed on 2026-09-05. `BuildState` now uses the Phase 5 Early shop
rarity curve for live between-contract shop generation, clamped to contract
depth 1-12 with exact anchors at depths 1, 6, and 12:

| Depth | Basic | Master | Epic | Cursed | Chaos | Unique |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 65% | 23% | 6% | 2% | 3% | 1% |
| 6 | 54% | 26% | 10% | 4% | 4% | 2% |
| 12 | 41% | 29% | 15% | 7% | 5% | 3% |

Generated shop rarity rolls now iterate only over `GearGenerator.ACTIVE_GENERATED_TIERS`,
so Crude and procedural Legendary remain excluded from the live shop pool.
Pre-contract tavern shops remain Basic-only, and the explicit
`_shop_offer_for_tier(LEGENDARY, ...)` catalog path remains available for fixed
Legendary compatibility and regression coverage. Shop offer RNG and stable IDs
include clamped contract depth, and generated shop requests pass that depth into
`GearGenerator.generate_from_request()` for deterministic depth-aware values.

Focused tests now cover exact shop curve anchors, low/high depth clamping,
interpolation, reachability for every generated shop tier, pre-contract
Basic-only behavior, no procedural Legendary/Crude shop offers, duplicate
guards, and fixed Legendary catalog fallback behavior.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\run_rng_context_test.log --path project -s res://tests/run_rng_context_test.gd` passed with `Run RNG context check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_legendary_generator_boundary_test.log --path project -s res://tests/p5m5_legendary_generator_boundary_test.gd` passed with `P5M5 Legendary generator boundary check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_generator_contract_test.log --path project -s res://tests/p5m5_generator_contract_test.gd` passed with `P5M5 generator request contract check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_stat_value_scaling_test.log --path project -s res://tests/p5m5_stat_value_scaling_test.gd` passed with `P5M5 stat value scaling check: OK`.

Godot also reported the accepted root-certificate and cleanup warnings already
listed in the onboarding baseline.

P5M7-T8 completed on 2026-09-05. `BuildState.should_open_shop_after_current_reward()`
now rejects shop opening during active contract route traversal unless the
current win is a terminal contract victory. This prevents carried-over
`shop_unlocked` state from opening a mid-contract shop after ordinary generated
route rewards. Final generated-boss victory still skips the shop when all
generated bosses are defeated, while non-final contract completion continues to
open the between-contract shop before the next generated offer.

`generated_contract_outcome_test.gd` now explicitly leaves `shop_unlocked` true
during an ordinary generated route-node win and verifies that
`should_open_shop_after_current_reward()` and `open_shop_round()` both reject
the mid-contract shop path before continuing back to route choice.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\generated_contract_outcome_test.log --path project -s res://tests/generated_contract_outcome_test.gd` passed with `Generated contract outcome check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\generated_contract_save_load_test.log --path project -s res://tests/generated_contract_save_load_test.gd` passed with `Generated contract save/load check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\generated_boss_checklist_test.log --path project -s res://tests/generated_boss_checklist_test.gd` passed with `Generated boss checklist check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p4m8_adventure_lifecycle_regression_test.log --path project -s res://tests/p4m8_adventure_lifecycle_regression_test.gd` passed with `P4M8 adventure lifecycle regression: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\run_failure_state_test.log --path project -s res://tests/run_failure_state_test.gd` passed with `Run failure state check: OK`.

Godot also reported the accepted root-certificate and cleanup warnings already
listed in the onboarding baseline.

P5M7-T9 completed on 2026-09-05. The live gold flow was audited around
`BuildState.modified_gold_reward()`, `claim_current_reward()`,
`reroll_shop_offers()`, `buy_shop_offer()`, `sell_inventory_item()`, and
`sell_value_for()`. Incoming reward gold continues to use
`modified_gold_reward()`, which resolves `Increased Gold` through the current
build stats before adding gold to the stash. Outgoing economy paths continue
to use fixed costs and values: shop prices come from
`GearGenerator.price_for_tier()`, rerolls spend `shop_reroll_cost`, purchases
spend the fixed tier price, and sale payouts use `SELL_VALUE_RATIO`.

Added `p5m7_gold_gain_economy_test.gd` as focused regression coverage. The
test equips the live Sticky Fingers `Increased Gold` source, verifies 12g of
incoming reward gold becomes 15g, then verifies the same bonus does not
discount shop rerolls, discount shop purchases, or increase sell value.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m7_gold_gain_economy_test.log --path project -s res://tests/p5m7_gold_gain_economy_test.gd` passed with `P5M7 gold gain economy check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m2_lucky_coin_charm_test.log --path project -s res://tests/p5m2_lucky_coin_charm_test.gd` passed with `P5M2 Lucky Coin Charm boundary check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\save_load_test.log --path project -s res://tests/save_load_test.gd` passed with `Save/load round trip check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\gear_generator_test.log --path project -s res://tests/gear_generator_test.gd` passed with `GearGenerator tier structure check: OK`.

Observed adjacent legacy test drift:

- `thief_subclass_test.gd` currently fails older Steal damage expectations
  before reaching its later reward-gold assertions.
- `inventory_model_test.gd` currently fails the older multiple-Gold-Rewards
  compounding expectation at line 153. No Task 9 code change depends on that
  expectation.

Godot also reported the accepted root-certificate and cleanup warnings already
listed in the onboarding baseline.

P5M7-T10 completed on 2026-09-05. The reward and shop UI compatibility pass
confirmed that the existing generic gear-box rendering already supports the
expanded Phase 5 rarity set through `GearGenerator.tier_name()`,
`GearGenerator.tier_color()`, `CardStyle.style_shop_item_box()`,
`CardStyle.build_gear_box_content()`, and shared comparison tooltips.

`reward_shop_route_ui_test.gd` now adds focused coverage for:

- Shop rendering across Basic, Master, Epic, Cursed, Chaos, and Unique offers.
- Visible price badges, tooltip prices, affordability, icons, and tier-colored
  button backgrounds for every generated shop rarity.
- Mixed-rarity two-choice reward pairs, including stable 112x112 reward boxes,
  tooltip tier names, icons, tier colors, and the two-box equipped comparison
  tooltip.
- Existing fixed Legendary reward tooltip behavior.

`combat_screen_test.gd` was also updated so its broad post-contract reward
smoke now expects the Task 8 no-mid-contract-shop behavior: ordinary generated
route rewards return to the contract route instead of opening the shop.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\reward_shop_route_ui_test.log --path project -s res://tests/reward_shop_route_ui_test.gd` passed with `Reward/shop/route UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\route_reward_choice_ui_test.log --path project -s res://tests/route_reward_choice_ui_test.gd` passed with `Route reward choice UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\build_panels_test.log --path project -s res://tests/build_panels_test.gd` passed with `P2:R7:T4 build panels test passed`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\run_rng_context_test.log --path project -s res://tests/run_rng_context_test.gd` passed with `Run RNG context check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\combat_screen_test.log --path project -s res://tests/combat_screen_test.gd` passed with `P2 UI restructure end-to-end check: OK`.

Godot also reported the accepted root-certificate and headless rendering
cleanup warnings already listed in the onboarding baseline.

P5M7-T11 completed on 2026-09-05. Focused regression coverage was audited
against the live P5M7 economy integration. `generated_contract_save_load_test.gd`
now includes generated reward-choice and between-contract shop metadata in its
gear signatures, and explicitly verifies generated source kind, source seed,
source context, and deterministic key prefixes before and after save/load
round-trips.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\generated_contract_save_load_test.log --path project -s res://tests/generated_contract_save_load_test.gd` passed with `Generated contract save/load check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\contract_route_generator_test.gd.log --path project -s res://tests/contract_route_generator_test.gd` passed with `Contract route generator check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\run_rng_context_test.gd.log --path project -s res://tests/run_rng_context_test.gd` passed with `Run RNG context check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_legendary_generator_boundary_test.gd.log --path project -s res://tests/p5m5_legendary_generator_boundary_test.gd` passed with `P5M5 Legendary generator boundary check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_stat_value_scaling_test.gd.log --path project -s res://tests/p5m5_stat_value_scaling_test.gd` passed with `P5M5 stat value scaling check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\generated_contract_outcome_test.gd.log --path project -s res://tests/generated_contract_outcome_test.gd` passed with `Generated contract outcome check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m7_gold_gain_economy_test.gd.log --path project -s res://tests/p5m7_gold_gain_economy_test.gd` passed with `P5M7 gold gain economy check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\reward_shop_route_ui_test.gd.log --path project -s res://tests/reward_shop_route_ui_test.gd` passed with `Reward/shop/route UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\combat_screen_test.gd.log --path project -s res://tests/combat_screen_test.gd` passed with `P2 UI restructure end-to-end check: OK`.

Godot also reported the accepted root-certificate and headless cleanup warnings
already listed in the onboarding baseline.

P5M7-T12 completed on 2026-09-05. Documentation closeout updated this tracker,
`docs/Project_Onboarding_Context.md`, `docs/P5_Gear_Redesign_Overview.md`, and
`docs/New_Gear_Overview.md` so P5M7 is recorded as complete and P5M8 is the
next active Phase 5 handoff. The closeout records the implemented live behavior:
two-choice generated contract rewards, deterministic independent reward rarity
upgrades, Cursed/Chaos/Unique high-tier reward outcomes, deferred Legendary
reward upgrades, live contract-depth scaling, Phase 5 between-contract shop
rarity selection, no-mid-contract shop access, `Increased Gold` applying only
to stash gains, and focused regression coverage.

Verification:

- Documentation consistency search found no remaining stale P5M7 planning,
  ready, or implementation-source-of-truth language in the P5M7 tracker,
  onboarding context, Phase 5 overview, or New Gear Overview.
- No Godot tests were required for this documentation-only closeout task.

P5M7-T6 completed on 2026-09-05. `GearGenerator._contract_depth_value_scale()`
now implements the P5M6/P5M7 handoff curve: contract depth clamps to 1-12 and
scales generated stat values linearly from 1.00x at depth 1 to 1.35x at depth
12. `BuildState._gear_choices_for_reward()` already derives live reward depth
from `clampi(completed_contract_count + 1, 1, 12)`; it now passes that depth
through `_generate_reward_choice_item()` into `GearGenerator.generate_from_request()`
with `value_scale` left at 1.00x. Reward deterministic keys include the clamped
depth so depth-changing generated values are traceable and reproducible.

Focused tests now cover the value curve directly and live reward
materialization:

- `p5m5_stat_value_scaling_test.gd` checks low/high depth clamping, neutral
  depth 1, 1.35x depth 12, midpoint ordering, and larger positive stat values
  at higher contract depth.
- `run_rng_context_test.gd` checks that generated reward materialization changes
  when only `completed_contract_count` changes while keeping reward context and
  source seed stable.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_stat_value_scaling_test.log --path project -s res://tests/p5m5_stat_value_scaling_test.gd` passed with `P5M5 stat value scaling check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\run_rng_context_test.log --path project -s res://tests/run_rng_context_test.gd` passed with `Run RNG context check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_generator_contract_test.log --path project -s res://tests/p5m5_generator_contract_test.gd` passed with `P5M5 generator request contract check: OK`.

Godot also reported the accepted root-certificate and cleanup warnings already
listed in the onboarding baseline.

P5M7-T5 completed on 2026-09-05. Reward upgrade odds now use live contract
depth as a deterministic scaling input. `BuildState._current_contract_reward_depth()`
maps the current contract number to depth with
`clampi(completed_contract_count + 1, 1, 12)`, so the first live contract uses
depth 1 and the twelfth or later live contract uses depth 12. Upgrade rolls add
up to a conservative +50% relative bonus by depth 12 while preserving the
locked P5M7 base odds at depth 1:

| Upgrade Step | Depth 1 | Depth 12 |
| --- | ---: | ---: |
| Basic to Master | 15.0% | 22.5% |
| Master to Epic | 8.0% | 12.0% |
| Epic to high-tier | 3.0% | 4.5% |

The deterministic reward upgrade key now includes the clamped contract depth,
so the same seed, reward context, choice index, baseline tier, and depth
reproduce the same result, while changing only depth can intentionally change
the upgrade outcome. The high-tier and Legendary boundary remains unchanged:
scaled reward upgrades can still only produce Cursed, Chaos, or Unique.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\run_rng_context_test.log --path project -s res://tests/run_rng_context_test.gd` passed with `Run RNG context check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m5_legendary_generator_boundary_test.log --path project -s res://tests/p5m5_legendary_generator_boundary_test.gd` passed with `P5M5 Legendary generator boundary check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\contract_route_generator_test.log --path project -s res://tests/contract_route_generator_test.gd` passed with `Contract route generator check: OK`.

Godot also reported the accepted root-certificate and cleanup warnings already
listed in the onboarding baseline.
