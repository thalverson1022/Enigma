# P2:R3 - Reward, Shop, And Gear Parity

## Purpose

Track the work for **P2:R3 - Reward, Shop, And Gear Parity**.

The goal is to restore the Phase 1 Adventure reward loop inside the
dashboard-era UI: gold, talent points, fixed gear rewards, generated gear
offers, shop rounds, inventory/equipment decisions, and reward modifiers.

This milestone should replace the current Adventure-facing free gear reroll
behavior with earned gear and shop decisions.

## Exit Criteria

P2:R3 is complete when:

- Encounter rewards can grant gold, talent points, and gear where authored.
- The active run flow includes reward acknowledgement/choice after fights.
- Shop access follows the intended Tavern progression.
- Shop offers are generated through run-context state, not free dashboard
  rerolls.
- Weapon/trinket/charm equipment affects later fights.
- Gold spending and equip/unequip are reachable from the dashboard flow.
- Headless tests prove rewards and gear change later combat output.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R3:T1 | Confirm Reward Scope | R1/R2 reward gaps translated into implementation targets | Complete |
| P2:R3:T2 | Extend Encounter Reward Data | Encounter resources can represent required rewards | Complete |
| P2:R3:T3 | Add Reward Claim Flow | Dashboard-era reward view or overlay | Complete |
| P2:R3:T4 | Implement Inventory Model | Run state can retain acquired gear before/after equip | Complete |
| P2:R3:T5 | Refit Shop UI | Shop becomes dashboard-compatible and parity-oriented | Complete |
| P2:R3:T6 | Replace Free Gear Reroll | Adventure gear comes from rewards/shop, not free rerolls | Complete |
| P2:R3:T7 | Implement Gold Reward Modifiers | Gold Rewards affix affects claimed rewards | Complete |
| P2:R3:T8 | Add/Update Tests | Reward/shop/gear loop verified headlessly | Complete |
| P2:R3:T9 | Update Docs | Completed behavior and deferrals documented | Complete |

## P2:R3:T1 - Confirm Reward Scope

Use the R1 audit to decide the P2:R3 reward target. Default Phase 1 parity
targets:

- Tavern rewards.
- Gold rewards.
- Talent point rewards.
- Lucky Coin or other fixed item rewards where Phase 1 specifies them.
- Shop unlock after the second Tavern fight.
- Generated shop offers.
- One shop reroll per shop round.
- Basic/Master/Cursed generation rules where reachable.

Legendary rewards from Knives belong to P2:R4 unless P2:R3 needs a shared
reward-choice foundation.

## P2:R3:T2 - Extend Encounter Reward Data

Audit `Encounter` and related data needs:

- Gold reward.
- Talent point reward.
- Fixed gear reward.
- Gear choice reward.
- Shop unlock flag, if needed.
- Reward quality/tier hints, if needed.

Keep content data in `.tres` resources. Avoid hardcoded encounter reward
tables in UI scripts.

## P2:R3:T3 - Add Reward Claim Flow

Add a dashboard-compatible reward interaction:

- Clearly show what was earned.
- Let the player claim or choose rewards.
- Apply rewards to `BuildState` or appropriate run state.
- Transition back to planning, shop, or next encounter.

Do not make reward text a wall of tutorial copy. The action should be obvious.

## P2:R3:T4 - Implement Inventory Model

Decide where acquired but unequipped gear lives.

Needed behaviors:

- Store gear acquired from rewards/shop.
- Equip weapon/trinket/charm.
- Unequip without deleting unless explicitly intended.
- Compare or at least inspect item affixes.
- Keep generated items serializable for P2:R6.

## P2:R3:T5 - Refit Shop UI

The existing `scenes/tavern/shop.*` can be reused, replaced, or refit.
P2:R3 should make the shop fit the dashboard-era flow:

- Show current gold.
- Show generated offers.
- Show prices.
- Buy if affordable.
- Allow one reroll when appropriate.
- Equip or store purchased gear.
- Continue back to run flow.

## P2:R3:T6 - Replace Free Gear Reroll

Remove free Adventure power from `gear_panel.gd`:

- No free random full equipment on entering the dashboard.
- No free reroll in the player-facing Adventure path.
- Keep hidden/dev-only test support only if explicitly useful and clearly not
  reachable in normal Adventure flow.

The gear panel should reflect equipment/inventory state earned through the run.

## P2:R3:T7 - Implement Gold Reward Modifiers

Phase 1 Gold Rewards affixes are reward-only:

- They should not affect combat stats.
- They should modify claimed gold rewards.
- Multiple modifiers compound multiplicatively.
- Final award is rounded and clamped at `0` or higher.

Document any temporary limitations if full parity is deferred.

## P2:R3:T8 - Add/Update Tests

Tests should prove:

- Rewards are granted after fights.
- Gold changes correctly.
- Talent points can be awarded and spent if in scope.
- Shop offers can be bought with gold.
- Equipping purchased or rewarded gear changes resolved stats.
- Later combat output can change because of acquired gear.

## P2:R3:T9 - Update Docs

When complete:

- Update this checklist.
- Record any reward/shop differences from Phase 1.
- Update `docs/Phase_2_Milestones.md`.
- Add future reward ideas to `phase3_ideas.md` if deferred.

## Implementation Notes

2026-07-16:

- `P2:R3:T1` is complete. R3's confirmed target is the Phase 1 Tavern
  reward/shop/gear loop, restored inside the active dashboard-era flow.
- R2 left a deliberate reward stub: the victory banner previews the current
  encounter's authored reward gold, but does not apply gold, talent points,
  fixed items, inventory changes, shop access, or equipment decisions.
- Current Godot state relevant to R3:
  - `Encounter` now represents `monster`, `duration_ms`, `reward`, and
    `is_boss`.
  - `EncounterReward` now represents authored gold, talent points, fixed gear
    rewards, shop unlocks, and generated gear-choice hooks for later R3/R4
    work.
  - Tavern encounter resources now encode gold, Tavern talent-point timing,
    Drunk Buddy's Lucky Coin fixed gear reward, and the post-Drunk Buddy shop
    unlock.
  - `BuildState` has `gold`, equipped weapon/trinket/charm, gold helpers,
    inventory, earned talent-point state, claimed reward tracking, and a
    basic shop-unlocked flag. It still has no shop-round state.
  - `gear_panel.gd` still grants Adventure-facing free generated equipment on
    dashboard entry and exposes a free reroll button. This is temporary R2-era
    behavior that R3 must remove from the normal Adventure path.
  - `scenes/tavern/shop.*` exists as a dormant/simple shop, but is not yet
    dashboard-native and is not connected to the active run flow.
- Confirmed Tavern reward targets from the Phase 1 references:
  - Mouthy Drunk: `12g` and `1` talent point.
  - Drunk Buddy: `18g` and Lucky Coin.
  - Tavern Bouncer: `24g` and `1` talent point.
  - Hired Goon: `36g` and `1` talent point.
  - Shop/gear management unlocks after Drunk Buddy.
  - Tavern shop rounds show four generated Basic gear offers.
  - Each shop round allows one reroll.
  - Weapon, trinket, and charm equipment must affect later fights.
  - Gold Rewards affixes modify claimed gold rewards only; they do not affect
    combat stats. Multiple modifiers compound multiplicatively, then the final
    gold award is rounded and clamped to `0` or higher.
- R3 implementation boundaries:
  - In scope: Tavern reward acknowledgement, gold, talent-point rewards,
    Lucky Coin or other Tavern fixed gear where authored, inventory,
    dashboard-compatible shop access, generated Basic shop offers, one shop
    reroll, equipment decisions, removal of free Adventure rerolls, and Gold
    Rewards reward math.
  - Out of scope until `P2:R4`: contract route branching, secondary subclass
    timing, Knives, Legendary rewards, route gear choices beyond the Tavern
    foundation, and Vyra route parity.
  - Out of scope until `P2:R5`: Adventure seed UI, full run-context
    deterministic RNG, do-over/failure rules, and final victory/defeat rule
    polish.
- Recommended R3 build order:
  1. `P2:R3:T2` - complete: extend encounter/reward data so authored resources can
     represent gold, talent points, fixed gear rewards, shop unlocks, and
     future gear choices without hardcoded UI tables.
  2. `P2:R3:T4` - add the run inventory and earned progression state needed
     before the claim UI can apply anything safely. Complete.
  3. `P2:R3:T3` - complete: replace the R2 reward preview with a
     dashboard-native claim flow that applies rewards and routes back to
     planning. Shop routing is flagged in state and remains `P2:R3:T5`.
  4. `P2:R3:T5` - refit the shop into the dashboard flow with gold display,
     four offers, prices, buying, one reroll, and continue behavior.
     Complete.
  5. `P2:R3:T6` - remove free player-facing dashboard gear auto-roll/reroll
     once rewards/shop/inventory can supply equipment.
     Complete.
  6. `P2:R3:T7` - implement Gold Rewards modifiers against claimed gold.
     Complete.
  7. `P2:R3:T8` - add/update headless tests for rewards, shop purchases,
     equipment changes, and later combat output changes. Complete.
  8. `P2:R3:T9` - close out docs and record any intentional parity
     differences or deferrals. Complete.

## Verification Notes

2026-07-16:

- Documentation-only scope confirmation. No Godot tests were run because
  `P2:R3:T1` does not change runtime behavior.
- `P2:R3:T2` verification:
  - Added `EncounterReward` and `Encounter.reward`.
  - Seeded `data/gear/lucky_coin.tres` as a Basic trinket with `+5%` crit
    chance.
  - Updated Tavern encounter resources with authored gold, talent points,
    fixed Lucky Coin reward, and shop unlock timing.
  - Added `tests/encounter_reward_test.gd` to load the encounter resources and
    assert the authored reward data.
  - Refreshed Godot's global class cache via headless editor scan after adding
    the new global class.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_r3_t2.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r3_t2.log -s res://tests/combat_screen_test.gd`
  - The first sandboxed Godot run crashed during startup/log handling, matching
    the known local issue. The passing checks above used escalated filesystem
    access and still printed the known ObjectDB/resource cleanup warnings after
    assertions passed.
- `P2:R3:T4` verification:
  - Added `BuildState.inventory` for acquired but unequipped gear.
  - Added `BuildState.earned_talent_points` and a helper for later reward
    claim flow.
  - Added inventory/equipment helpers:
    `add_inventory_item()`, `remove_inventory_item()`,
    `has_inventory_item()`, `grant_gear()`, and `equip_from_inventory()`.
  - Updated `equip()` so equipping from inventory removes the item from
    inventory, and replacing a slot returns the previous item to inventory.
  - Updated `unequip()` so unequipping weapon/trinket/charm returns the item
    to inventory instead of deleting it.
  - Added `tests/inventory_model_test.gd` to prove reward/shop-style grants,
    equip from inventory, unequip, slot replacement, item removal, talent
    point tracking, and continued `BuildResolver` stat impact from equipped
    gear.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r3_t4.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r3_t4.log -s res://tests/gear_generator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r3_t4.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_r3_t4.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r3_t4.log -s res://tests/combat_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r3_t4.log -s res://tests/engine_mechanics_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r3_t4.log -s res://tests/passive_allocator_test.gd`
  - The first sandboxed Godot run again crashed during startup/log handling.
    The passing checks above used escalated filesystem access and still printed
    the known ObjectDB/resource cleanup warnings after assertions passed.
- `P2:R3:T7`/`T8`/`T9` verification:
  - Added `BuildState.modified_gold_reward()` and changed reward claiming so
    authored encounter gold is modified by equipped `GOLD_REWARDS` affixes
    before being granted.
  - Gold Rewards remain reward-only. `BuildResolver` still ignores
    `GOLD_REWARDS`, and `tests/inventory_model_test.gd` now asserts that
    reward-only gear does not change resolved combat stats.
  - Multiple equipped Gold Rewards modifiers compound multiplicatively by
    applying each `1.0 + value` factor. The final award is rounded and clamped
    to `0` or higher.
  - Unequipped inventory gear does not affect claimed gold rewards.
  - No new Phase 3 reward/shop deferrals were added during R3 closeout.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r3_t7.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r3_t7.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_r3_t7.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r3_t7.log -s res://tests/gear_generator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r3_t7.log -s res://tests/combat_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r3_t7.log -s res://tests/engine_mechanics_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r3_t7.log -s res://tests/passive_allocator_test.gd`
  - The first sandboxed focused test crashed during startup/log handling, as
    expected from the known local issue. The passing checks above used
    escalated filesystem access and still printed the known ObjectDB/resource
    cleanup warnings after assertions passed.

P2:R3 is complete as of 2026-07-16. The next revised milestone is
`P2:R4 - Contract Route Parity`.

2026-07-16 item naming follow-up:

- Clarified the distinction between generic equipment slots and Rogue item
  type names. Generic slots are weapon, trinket, helm, armor, and charm; Rogue
  item types are Dagger, Ring, Hood, Doublet, and Necklace.
- Updated the active generated gear naming table to use the Phase 1 affix
  name parts: Swift/Speed, Sharp/Sharpness, Savage/Savagery,
  Brutal/Brutality, Lethal/Lethality, Poison/Poisoning, Bloody/Rending, and
  Greedy/Avarice.
- Updated the dashboard gear panel labels so the future-facing armor slot
  reads Doublet and the active trinket/charm slots read Ring and Necklace.
- Updated item tooltip headers to use generic equipment slot tags rather than
  class-specific item type names, e.g. `Weapon - Swift Dagger` instead of
  `Dagger - Swift Dagger`.
- Updated equipment and inventory boxes to square proportions for future
  icon art. Equipment squares were enlarged within the current Gear panel
  footprint, and inventory/shop item boxes now use matching square cells.
- Split the post-fight win presentation into a Victory box above a separate
  Rewards box, so reward contents have their own visual area before item
  rewards become more complex.
- Passing focused checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_item_names.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_item_names.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_item_names.log -s res://tests/inventory_model_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_slot_tags.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_victory_rewards_boxes.log -s res://tests/combat_screen_test.gd`
- `P2:R3:T3` verification:
  - Replaced the R2 victory-banner reward preview with a real
    dashboard-native `Claim Rewards` action.
  - Added `BuildState.claimed_reward_encounter_indices` to prevent duplicate
    claims for the same encounter.
  - Added `BuildState.claim_current_reward()` to apply authored encounter
    rewards after a won fight: gold, earned talent points, fixed gear rewards
    through inventory, and the post-Drunk Buddy shop-unlocked flag.
  - Added `BuildState.shop_unlocked` as the minimal T3 handoff state for the
    later dashboard-native shop refit. Shop offers, shop rounds, rerolls, and
    shop routing remain `P2:R3:T5`.
  - Updated the victory banner to show concise earned reward text such as
    gold, talent points, Lucky Coin, and shop access.
  - Updated `tests/combat_screen_test.gd` so the active dashboard proves
    Mouthy Drunk grants `12g` and `1` earned talent point, Drunk Buddy grants
    `18g`, Lucky Coin, and shop access, and duplicate reward claims do not
    pay out again.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r3_t3.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_r3_t3.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r3_t3.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r3_t3.log -s res://tests/combat_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r3_t3.log -s res://tests/engine_mechanics_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r3_t3.log -s res://tests/gear_generator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r3_t3.log -s res://tests/passive_allocator_test.gd`
  - The first sandboxed Godot run again crashed during startup/log handling.
    The passing checks above used escalated filesystem access and still printed
    the known ObjectDB/resource cleanup warnings after assertions passed.
- `P2:R3:T5` verification:
  - Added dashboard-native Tavern shop state to `BuildState`: pending shop
    round, current offers, one-reroll tracking, round index, offer buying, and
    round close helpers.
  - Tavern shop rounds now generate four Basic gear offers through
    `GearGenerator` with deterministic placeholder seeds. Full Adventure seed
    context remains `P2:R5`.
  - Reward claim now opens a dashboard shop overlay when shop access is
    unlocked and another encounter remains. Leaving the shop advances to the
    next encounter and returns to planning.
  - Buying an offer spends gold, removes the offer, and grants the gear to
    inventory instead of forcing immediate equip.
  - The dashboard shop overlay shows current gold, offer price/details, a
    one-use reroll button, and a leave-shop action.
  - Updated `tests/combat_screen_test.gd` to prove Drunk Buddy opens the shop,
    shop offers are four Basic items, one reroll works once, buying spends
    gold into inventory, equipping purchased gear changes resolved stats, and
    leaving the shop advances to Tavern Bouncer.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r3_t5.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r3_t5.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_r3_t5.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r3_t5.log -s res://tests/gear_generator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r3_t5.log -s res://tests/combat_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r3_t5.log -s res://tests/engine_mechanics_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r3_t5.log -s res://tests/passive_allocator_test.gd`
  - The first sandboxed Godot run again crashed during startup/log handling.
    The passing checks above used escalated filesystem access and still printed
    the known ObjectDB/resource cleanup warnings after assertions passed.
- `P2:R3:T6` verification:
  - Removed the dashboard gear panel's free Adventure auto-roll on entry.
  - Removed the player-facing `Reroll Gear` button and unseeded random gear
    generation from the normal dashboard path.
  - Refit the gear panel inventory area from a placeholder into earned gear UI:
    empty state, item summaries/tooltips, and `Equip` actions backed by
    `BuildState.equip_from_inventory()`.
  - Follow-up gear/shop unification: equipment and inventory now use colored
    item boxes instead of text rows, inventory is a two-row by three-column
    grid with a six-item capacity, shop purchases fail without spending gold
    when inventory is full, and clicking inventory items during an open shop
    sells them for a temporary half-price tier value to free room.
  - Follow-up UI flow pass: the combat dashboard now starts with `0` talent
    points and spends only earned reward points, the combat window has a
    one-retry failure state per encounter, viewing the combat log from the
    victory banner leaves reward claiming available, the active gold total is
    shown in the gear panel, and the Tavern shop now replaces the combat
    window with a shopkeeper placeholder plus a two-by-two item-box offer
    grid instead of using a dimmed full-screen overlay.
  - Shop/equipment follow-up: buying a shop item equips it directly when the
    matching equipment slot is open, otherwise it stores the item in inventory
    if there is room. Selling from inventory or equipment during the shop
    requires confirmation.
  - Shop/layout follow-up: victory recap now appears centered inside the
    combat window, the shopkeeper placeholder takes more of the shop view, shop
    offers are clickable square item boxes with tooltip-only name/stat/price
    details, the visible shop gold/status text was removed, the reroll control
    moved to the shop header with a `Reroll (1)` / `Reroll (0)` counter, Leave
    Shop sits at the bottom right, purchases always go to inventory, inventory
    capacity was reduced to three items, and generated gear now uses
    prefix/suffix names derived from affixes.
  - Updated `tests/combat_screen_test.gd` to prove dashboard entry starts with
    no equipped gear, no free reroll button is reachable, Lucky Coin and shop
    purchases land in inventory, purchased gear can still change resolved
    stats, full inventory blocks additional shop purchases, shop-time inventory
    clicks sell items, and equipping earned inventory gear clears the build
    lock.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r3_t6.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r3_t6.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_r3_t6.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r3_t6.log -s res://tests/gear_generator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r3_t6.log -s res://tests/combat_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r3_t6.log -s res://tests/engine_mechanics_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r3_t6.log -s res://tests/passive_allocator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_inventory_grid.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_capacity.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_inventory_grid.log -s res://tests/gear_generator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_inventory_grid.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_inventory_grid.log -s res://tests/combat_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_inventory_grid.log -s res://tests/engine_mechanics_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_ui_flow.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_ui_flow.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_ui_flow.log -s res://tests/passive_allocator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_ui_flow.log -s res://tests/gear_generator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_ui_flow.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_ui_flow.log -s res://tests/combat_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_ui_flow.log -s res://tests/engine_mechanics_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_shop_layout.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_shop_layout.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_shop_layout.log -s res://tests/gear_generator_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_shop_layout.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_shop_layout.log -s res://tests/combat_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_shop_layout.log -s res://tests/engine_mechanics_test.gd`
  - The first sandboxed Godot run again crashed during startup/log handling.
    The passing checks above used escalated filesystem access and still printed
    the known ObjectDB/resource cleanup warnings after assertions passed.
