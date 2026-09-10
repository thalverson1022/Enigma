# P5M11: Practice Room, Balance, And Readability Tracker

## Status

Complete as of 2026-09-10.

P5M11 started as Practice Room and Balance Lab validation for the completed
Phase 5 gear surface. During hands-on playtest tuning it expanded into a
targeted readability, economy, Practice Room, Tavern, contract-scaling, combat
log, menu-feel, and reward-feel pass. The milestone is complete for the next
round of external playtesting. It is still not a full final balance closeout;
the later talent-tree remake is expected to reopen balance questions, and P5M12
remains responsible for the final Phase 5 regression/smoke handoff.

Primary design documents:

- `docs/New_Gear_Overview.md`
- `docs/P5_Gear_Redesign_Overview.md`

## Milestone Goal

Make the current Phase 5 gear and generated-contract baseline easier to inspect,
tune, and playtest. Practice Room should expose current gear behavior cleanly,
Adventure item tooltips should be readable enough to make decisions quickly, and
generated contracts should feel more substantial without pretending the whole
game is finally tuned.

## Completed Progress

| Area | Status | Notes |
| --- | --- | --- |
| Practice Room gear defaults | Complete | Choosing a rarity or changing a stat seeds the selected affix to that slot/stat/category/rarity's max rolled value while preserving manual edits. |
| Practice Room active rarity support | Complete | Crude Dagger, Basic, Master, Epic, Cursed, Chaos, Unique, Legendary weapon selection, None clearing, all five slots, and Chaos duplicate-stat editing are covered. |
| Economy stats | Complete | Shop Discount and Increased Magic Find were added to Basic and Rare stat pools, Increased Gold can roll as Rare, and character-sheet display includes Increased Gold, Shop Discount, and Magic Find above poison stats. |
| Gold math | Complete | Increased Gold aggregates from gear and multiplies with talent multipliers such as Thief Sticky Fingers. |
| Tooltip stat readability | Complete | Gear stats display in fixed order except Chaos roll order; Basic, Rare, Special, and drawback stats have distinct colors; max rolled values render bold and two font sizes larger in Adventure and Practice Room rich tooltips. |
| Practice Room value entry | Complete | Percent/chance stat value fields display whole percents such as `21` instead of `0.21`; flat Base Damage, Base Elemental Damage, and stack values display as whole integers while storing the normal internal values. |
| Practice Room generated target controls | Complete | Generated target rolls now expose Contract Level above Difficulty/Type, and the Seed control has a Random toggle that switches between deterministic seed reuse and fresh seeds for generated target rolls and practice fights. |
| Inventory item actions | Complete | Right-click item actions include Destroy with a confirmation prompt. |
| Tavern gear flow | Complete | Buying a replacement dagger moves the Crude Dagger into inventory instead of deleting it, and Crude Dagger sell value is 5g. |
| Tavern opening tuning | Complete | Mouthy Drunk HP is 145 so the opening fight target is less tightly tuned for low-roll Assassin outcomes. |
| Contract scaling pass | Complete | Generated route HP scaling now ramps sharply across contracts 1-30, with normal/captain/elite path enemies heavier and bosses slightly less spiky relative to the path. |
| Overkill Gold | Complete | Winning combat grants 10g per full 100 overkill damage, capped at 50g before Increased Gold modifiers are applied. |
| Combat attempt readability | Complete | The Enemy window now shows a compact boxed fight-icon attempt badge in the upper-right title row, with standard fights showing `2/2` or `1/2`, the opener showing `∞`, and tooltip copy such as `2/2 Attempts Left`. |
| Character sheet contract badge | Complete | The Character Stats window now shows a compact boxed contract-icon badge in the upper-right title row, starting at `0` in the Tavern and updating from completed contract count after boss completion advances. |
| Retrigger Interrupt pressure | Complete | Retriggered direct-attack procs now share the enemy Interrupt repeat counter with normal casts, so proc chains can trigger Interrupt and consume follow-up skip locks. |
| Skill tooltip scaling | Complete | Rending Slash now applies 2 baseline Shred stacks, and skill/macro tooltips use resolved stats so poison, Shred, Decay, and Steal gold amounts update with Bonus Stacks and Increased Gold. |
| Enemy role readability | Complete | Normal, Captain, Elite, and Boss generated enemies now use role-based sprite scales so escalation reads visually during combat. |
| Reward reveal readability | Complete | Generated reward choices open as empty slots, reveal one at a time, show each Magic Find rarity upgrade step, and wait briefly before the first item appears so players can parse the sequence. |
| Menu transition feel | Complete | Top-level screen swaps use a subtle fade-only transition with input blocking during the short fade, replacing instant menu pops without slowing combat actions. |
| Combat log readability | Complete | Retrigger procs log as `RETRIGGER`, Quick Cut into Rending Slash logs as `Opportunity Strike`, and dodged attacks log as `X was DODGED` instead of `connects, to no effect`. |

## Current Contract Scaling Baseline

Contract route HP scaling uses the `contract_hp_curve_v2` anchors:

| Contract | HP Multiplier |
| ---: | ---: |
| 1 | 1.0x |
| 5 | 1.4x |
| 10 | 2.3x |
| 15 | 3.8x |
| 20 | 6.0x |
| 25 | 9.0x |
| 30 | 13.0x |

Generated route role HP scales are:

| Role | Scale |
| --- | ---: |
| Normal/Fight | 1.00x |
| Captain | 1.10x |
| Elite | 1.25x |
| Boss | 1.25x |

Runtime generated monster kind HP multipliers are:

| Kind | HP Multiplier |
| --- | ---: |
| Normal | 1.12x |
| Captain | 1.18x |
| Elite | 1.28x |
| Boss | 1.32x |

The design intent is that path enemies stop feeling trivial, while bosses remain
important peaks without being the only meaningful durability checks.

## Current Tooltip Baseline

Non-Chaos generated gear displays stats in this order:

1. Base Damage
2. Percent Physical Damage
3. Increased Attack Speed
4. Crit Chance
5. Crit Damage
6. Base Elemental Damage
7. Percent Elemental Damage
8. Bonus stack stats
9. Increased Gold
10. Shop Discount
11. Increased Magic Find
12. Rare proc stats
13. Special stats

Chaos keeps the actual roll order. Tooltip colors are distinct from rarity
colors: Basic is off-white, Rare is light blue, Special is yellow, and drawbacks
are light purple. A max rolled value uses the same rounded stored value shown to
the player and renders bold at `TOOLTIP_RICH_FONT_SIZE + 2`.

## Verification Evidence

Recent P5M11-focused checks that have passed:

- `project/tests/training_room_gear_editor_test.gd`
- `project/tests/training_room_fight_setup_test.gd`
- `project/tests/skill_tooltip_formatter_test.gd`
- `project/tests/p5m8_stat_readability_test.gd`
- `project/tests/p5m8_ui_regression_test.gd`
- `project/tests/p5m11_economy_stats_test.gd`
- `project/tests/p5m11_overkill_gold_test.gd`
- `project/tests/p5m7_gold_gain_economy_test.gd`
- `project/tests/contract_route_generator_test.gd`
- `project/tests/runtime_monster_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/balance_lab_test.gd`
- `project/scripts/tools/run_balance_suite.gd`
- `project/tests/character_stats_contract_badge_test.gd`
- `project/tests/combat_hud_test.gd`

P5M11 closeout validation, 2026-09-10:

- `project/tests/training_room_gear_editor_test.gd` passed.
- `project/tests/training_room_fight_setup_test.gd` passed.
- `project/tests/skill_tooltip_formatter_test.gd` passed.
- `project/tests/p5m8_stat_readability_test.gd` passed.
- `project/tests/p5m8_ui_regression_test.gd` passed.
- `project/tests/p5m11_economy_stats_test.gd` passed.
- `project/tests/p5m11_overkill_gold_test.gd` passed.
- `project/tests/p5m7_gold_gain_economy_test.gd` passed.
- `project/tests/contract_route_generator_test.gd` passed.
- `project/tests/runtime_monster_generator_test.gd` passed.
- `project/tests/generated_route_matrix_test.gd` passed.
- `project/tests/balance_lab_test.gd` passed.
- `project/scripts/tools/run_balance_suite.gd` completed with 69 pass, 1
  accepted balance warning, and 0 fail.
- `project/tests/character_stats_contract_badge_test.gd` passed.
- `project/tests/combat_hud_test.gd` passed.
- `project/tests/reward_shop_route_ui_test.gd` passed.
- `project/tests/opportunity_strikes_test.gd` passed.
- `project/tests/enemy_defense_mechanics_test.gd` passed.
- `project/tests/combat_recap_test.gd` passed.
- `project/tests/combat_screen_test.gd` passed.
- `project/tests/save_load_ui_test.gd` passed.
- `project/tests/save_load_test.gd` passed, with the expected corrupt-save JSON
  parse output.
- `project/tests/training_room_combat_view_test.gd` passed.

Accepted non-blockers remain the known Godot root-certificate warning and
ObjectDB/RID/resource cleanup warnings during headless exit.

## Closeout Notes

- Hands-on playtest feedback accepts the current P5M11 combat, reward, economy,
  and generated-contract feel as strong enough for the next external playtest
  round.
- Balance Lab still reports one accepted balance-watch warning:
  `bladedancer_contract_watchmen` has a 100% win rate against Cloaked Watchmen,
  above the old 95% upper threshold. This is not an M11 blocker; it should be
  revisited with the broader talent-tree remake and future balance pass.
- Final Phase 5 regression, smoke, and handoff writing remain P5M12 scope.
