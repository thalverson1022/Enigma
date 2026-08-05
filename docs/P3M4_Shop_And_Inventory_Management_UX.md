# Phase 3 Milestone 4: Shop And Inventory Management UX

## Purpose

Milestone 4 makes shop-phase gear and inventory management clearer, more
deliberate, and easier to operate without redesigning the underlying gear
system ahead of the planned future gear overhaul.

This is the single tasking and status document for Milestone 4. It follows the
project hierarchy:

- Phase: 3, Project CrystalMaiden
- Milestone: 4, Shop And Inventory Management UX
- Task: milestone-sized work item
- Step: implementation-sized action inside a task

## Status

Complete.

## Milestone Goal

Make the shop phase the clear home for gear management. The player should be
able to buy, sell, equip, unequip, compare, and reroll shop offers with clear
costs, destinations, disabled states, and consequences, while inventory
capacity remains an intentional strategic constraint.

## Design Direction

Inventory management is part of the core Adventure game. Unlike talent
respecs, which should not become an every-fight optimization chore, gear
management should ask the player to make meaningful tradeoffs about what to
carry, what to equip, what to sell, and what to save for future enemies.

Milestone 4 should therefore reduce ambiguity and friction without removing
inventory pressure:

- Selling is available only during shop phases.
- Buying sends items to inventory.
- The player is responsible for making inventory space before buying or
  claiming gear rewards.
- Equipping and unequipping should be possible while the shop is open.
- Rerolling should cost gold instead of consuming a separate reroll count.
- Drag-and-drop item movement is deferred to the future gear-system overhaul.

## Constraints

- Do not redesign gear generation, affixes, item identity, rarity math, reward
  economy, enemy balance, or combat math unless a narrow user-approved bug fix
  requires it.
- Preserve existing gear type icons, rarity iconography, rarity color language,
  and Legendary-specific icons unless a specific UI readability issue requires
  a small adjustment.
- Keep buying simple: `Buy` sends the item to inventory. Do not add a separate
  `Buy & Equip` flow in this milestone.
- Keep selling scoped to the shop phase. Do not add general inventory selling
  outside shop interactions.
- Keep drag-and-drop out of this milestone. Revisit it during the future gear
  overhaul when final inventory rules, slot behavior, and comparison needs are
  clearer.
- Prefer clear click-based flows, explicit action states, and focused feedback
  over broad visual-system or full art-direction work.

## Current Baseline To Audit

Milestone 4 should begin by auditing the current code and UI instead of
assuming which pieces are already complete.

Known or expected baseline:

- Gear has item type icons.
- Gear rarity has color and icon language.
- Legendary items have specific icons.
- Shop rerolling exists, but currently reads as underwhelming and uses a count
  rather than scaling gold cost.
- Buying currently needs clearer destination/capacity behavior.
- Shop-phase equip and unequip behavior is not currently available.
- Selling from inventory during shop phase needs to be added or clarified.
- Full inventory can block collecting a gear reward from a contract kill; this
  should be communicated clearly before it feels like a surprise.

Open audit questions:

- Which screen or panel owns shop offers, inventory items, equipped gear slots,
  and selected item details?
- How is inventory capacity represented in state and UI?
- What happens today when the player tries to buy with full inventory?
- What happens today when a gear reward is offered while inventory is full?
- Are equipped items stored separately from inventory, or do they occupy
  inventory capacity?
- What item value/sell-price rule exists today, if any?
- Does reroll cost need to reset per shop encounter, per route step, or per
  Adventure run?
- Which focused tests already cover shop, reward, gear, and inventory state?

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Plan and audit the shop/inventory pass | Complete | Initial milestone direction, scope boundaries, task structure, deferred drag-and-drop decision, buy-to-inventory rule, shop-only selling rule, and reroll-cost direction are documented. |
| 1. Confirm inventory slot readability and shop-phase context | Complete | The three visible inventory slots are intentionally treated as the capacity affordance; no persistent count label or near-full warning treatment was added. Full-inventory buying is explained at the blocked offer. |
| 2. Enable equip and unequip while the shop is open | Complete | Inventory and equipped gear now use consistent primary-click movement plus right-click action menus; Sell is shop-gated. User playtest approved the interaction and ghost-card movement feedback. |
| 3. Add shop-phase selling from inventory | Complete | User playtest approved the shop-phase selling, gold readability, reward-row currency icon, and reward-claim flyout polish. Gear panel gold is the primary icon + value stash readout, shop offer cards show compact price badges, sell menus show `Sell for Xg`, and reward/sale/talent currency flyouts reinforce where rewards land. |
| 4. Clarify buy flow and item destination | Complete | Verified as covered by prior T2/T3 work: shop offers have one click-to-buy action, bought gear goes to inventory, buy/claim gear animates into inventory, price badges show cost, and disabled/full-inventory affordance text explains blocked buys. |
| 5. Replace reroll count with scaling gold reroll cost | Complete | Reroll now costs gold, starts at 5g, increases by 5g after each reroll in the current shop, resets per shop, disables when unaffordable, animates spent gold from the stash to the reroll action, and refreshes offers with stronger card motion. User playtest approved the flow. |
| 6. Clarify full-inventory gear reward blocking | Complete | Full-inventory gear rewards now block safely before claiming/clearing state; non-Legendary reward choices require inventory space; Legendary choices remain the documented auto-equip exception; inventory-full shop/reward actions use a warning pulse instead of the gray unaffordable state. |
| 7. Verify, document, and close Milestone 4 | Complete | Final focused and adjacent checks passed on 2026-08-03. Balance Lab was not run because the milestone did not change combat math, build resolution, gear resources, reward data, or enemy balance. Deferred gear-overhaul notes are recorded below. |

## Task Details

### P3:M4:T0 - Plan And Audit The Shop/Inventory Pass

Status: Complete.

Goal: turn Milestone 4 from the approved direction into an executable UI and
state-change plan.

Steps:

- P3:M4:T0:S1 - Audit current shop, inventory, equipped gear, reward, and
  reroll code paths.
- P3:M4:T0:S2 - Identify the scenes/scripts that own shop offers, inventory
  display, equipped slots, item detail panels, buy actions, reward choices,
  and reroll actions.
- P3:M4:T0:S3 - Confirm inventory capacity behavior, equipped-item storage
  behavior, sell-price rules, and reward-blocking behavior.
- P3:M4:T0:S4 - Identify existing focused tests and missing coverage for shop,
  inventory, gear rewards, reroll cost, and Adventure state safety.
- P3:M4:T0:S5 - Update this document with any scope corrections discovered in
  the audit.

Expected output:

- A current interaction map for shop/inventory/reward gear operations.
- Confirmed implementation surfaces and verification plan.
- Updated task notes if the current code changes the safest task order.

### P3:M4:T1 - Confirm Inventory Slot Readability And Shop-Phase Context

Status: Complete.

Goal: confirm the three-slot inventory already communicates capacity clearly,
and only add clarification where the current shop flow creates ambiguity.

Steps:

- P3:M4:T1:S1 - Audit the current three-slot inventory presentation.
- P3:M4:T1:S2 - Confirm empty slots read as available space.
- P3:M4:T1:S3 - Confirm occupied slots read as inventory pressure.
- P3:M4:T1:S4 - Review blocked-action messaging tied to full inventory.
- P3:M4:T1:S5 - Clarify shop-phase management context only where needed.
- P3:M4:T1:S6 - Avoid near-full/full warning treatments by default.
- P3:M4:T1:S7 - Add focused assertions only if there is a clean UI state to
  test.

Notes:

- The inventory panel already renders exactly three slots from
  `BuildState.INVENTORY_CAPACITY`.
- Empty slots already render as disabled slot buttons with `Empty inventory
  slot` tooltip copy.
- The `Inventory` header stays lean; no `2 / 3` style capacity label was added.
- No near-full or full warning banner/color treatment was added because the
  three-slot grid makes capacity visible enough.
- Shop offers now stay clickable when inventory is full, then pulse and explain
  `Inventory full -- make space first.` at the blocked action point.
- Focused assertions were added to `res://tests/combat_screen_test.gd` for the
  empty-slot tooltip, lean inventory header, full-inventory shop-offer block
  pulse, and full-inventory offer tooltip.
- Verification passed on 2026-08-02:
  `res://tests/combat_screen_test.gd` and `res://tests/build_panels_test.gd`.
  Godot printed the known Windows root-certificate-store and ObjectDB/resource
  cleanup warnings at exit.

Expected output:

- The three-slot inventory remains visually simple.
- Capacity labels and warning treatments are intentionally avoided.
- Full-inventory buy confusion is handled at the blocked shop offer.

### P3:M4:T2 - Enable Equip And Unequip While The Shop Is Open

Status: Complete.

Goal: let the player rearrange gear during shop phases so shop visits become
the natural inventory-management moment.

Steps:

- P3:M4:T2:S1 - Audit current equip/unequip functions and whether they are
  Adventure-safe from the shop state.
- P3:M4:T2:S2 - Expose equip actions for valid inventory items while the shop
  is open.
- P3:M4:T2:S3 - Expose unequip actions for equipped items while the shop is
  open, respecting inventory capacity.
- P3:M4:T2:S4 - Show replacement, destination, or blocked-state feedback when
  equip/unequip cannot complete.
- P3:M4:T2:S5 - Add focused tests for shop-phase equip/unequip and inventory
  capacity edge cases.

Notes:

- The inventory primary click rule was revised during implementation review:
  left-clicking an inventory item now equips it regardless of whether the shop
  is open.
- Inventory items now support a right-click action menu with `Equip` and
  `Sell`.
- Equipped items now mirror that interaction model: left-click unequips to
  inventory when allowed, and right-click opens a menu with `Unequip` and
  `Sell`.
- Successful gear movement now has lightweight visual feedback: temporary
  ghost cards animate between inventory and equipped slots, from shop/reward
  cards into inventory, and from sold items toward the gold readout. Landing
  slots pulse so same-slot swaps and new item arrivals are easier to read.
- `Sell` remains visible in the menu outside shops, but is disabled there.
- During shop phases, right-click `Sell` reuses the existing sell confirmation
  dialog before removing the item and granting gold.
- User playtest confirmed the flow on 2026-08-02.
- Verification passed on 2026-08-02:
  `res://tests/build_panels_test.gd` and
  `res://tests/combat_screen_test.gd`.
  Godot printed the known Windows root-certificate-store and ObjectDB/resource
  cleanup warnings at exit.

Expected output:

- Shop-phase gear rearrangement works through clear click-based controls.
- The player can make space and adjust equipment before buying or selling.

### P3:M4:T3 - Add Shop-Phase Selling From Inventory

Status: Complete.

Goal: let the player convert unwanted inventory gear into gold during shop
phases without making accidental item loss likely.

Steps:

- P3:M4:T3:S1 - Confirm or define the current sell-value rule.
- P3:M4:T3:S2 - Add a sell action for eligible inventory items while the shop
  is open.
- P3:M4:T3:S3 - Keep equipped-item selling safe; prefer requiring unequip
  before sell unless user review chooses direct selling.
- P3:M4:T3:S4 - Show sell value before the action is taken.
- P3:M4:T3:S5 - Add concise feedback after selling, including gold gained and
  inventory update.
- P3:M4:T3:S6 - Add focused tests for selling eligibility, gold changes,
  inventory removal, and equipped-item protection.

Notes:

- Selling remains shop-only through right-click item menus; the menu action now
  reads `Sell for Xg` when enabled during a shop and remains visible but
  disabled outside shops.
- The sell-value rule was left unchanged: `BuildState.sell_value_for()` returns
  50% of the tier price, floored, with a minimum of 1g.
- The Gear panel is now the primary gold stash readout: gold icon plus larger
  outlined value text with the `g` suffix.
- The duplicate shop-local `Gold:` row was removed.
- Shop offer cards now show compact always-visible price badges with a gold
  icon and `Xg`, while detailed stats stay in the hover tooltip; the badge
  value was enlarged and the icon reduced after playtest review.
- Inventory item hover now omits the old action-instruction text block and
  uses the same item-plus-Equipped comparison tooltip style as shop and reward
  gear. Equipped item hover now also omits the action-instruction text block,
  leaving the item details as the tooltip content.
- Talent points now use the Sprite Lab star icon in the Active Talents panel,
  Talent Trees footer, and victory reward row, replacing the repeated
  `talent point` wording in those reward/point-spend surfaces. Victory reward
  rows now order reward pieces as item text, then star talent points, then gold
  so the claim animation can send stars left to Active Talents and gold right
  to Gear. The victory reward row no longer uses a `Rewards:` prefix; reward
  text and currency icons are enlarged so the row reads as the prize reveal.
- Reward gold and sale gold now animate toward the Gear panel stash readout,
  and the stash readout pulses on arrival. Reward-claim gold now finishes its
  flight before the next map/shop/reward-choice window appears; the reward
  claim path includes a short extra settle beat after the gold lands, and the
  motion targets the visible gold icon instead of the stretched gold row.
- Reward-claim talent points now animate from the reward-row star to the Active
  Talents star readout before the next map/shop/reward-choice window appears.
- Additional polish verification passed on 2026-08-02:
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/build_panels_test.gd`, and
  `res://tests/combat_screen_test.gd`.
- Verification passed on 2026-08-02:
  `res://tests/build_panels_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/combat_screen_test.gd`, and
  `res://tests/inventory_model_test.gd`.
  Godot printed the known Windows root-certificate-store and ObjectDB/resource
  cleanup warnings at exit.
- User confirmed the flow with a live playtest; Task 3 is complete.

Expected output:

- Selling is available only in the intended phase.
- The player can clean inventory and fund shop decisions with clear feedback.

### P3:M4:T4 - Clarify Buy Flow And Item Destination

Status: Complete.

Goal: keep buying simple and predictable.

Steps:

- P3:M4:T4:S1 - Confirm current buy behavior and state mutation path.
- P3:M4:T4:S2 - Ensure the shop exposes one clear `Buy` action.
- P3:M4:T4:S3 - Make `Buy` send the purchased item to inventory.
- P3:M4:T4:S4 - Disable or explain `Buy` when the player cannot afford the
  item or has no inventory space.
- P3:M4:T4:S5 - Show post-buy feedback for gold spent and inventory update.
- P3:M4:T4:S6 - Add focused tests for affordable buys, unaffordable buys,
  full-inventory blocking, and item destination.

Notes:

- No new code was required. The T4 audit confirmed T2/T3 already covered the
  intended behavior and player-facing clarity.
- Shop offer cards expose one primary action: click to buy.
- Successful buys route through `BuildState.buy_shop_offer()`, spend gold,
  remove the offer, add the item to inventory, and animate the item from the
  shop card into its inventory slot.
- Shop offer cards show compact price badges, explicit `Click to buy.`
  tooltip text when affordable, `Not enough gold.` when unaffordable, and
  `Inventory full -- make space first.` plus a blocked pulse when capacity
  blocks purchase.
- Verification passed on 2026-08-02:
  `res://tests/reward_shop_route_ui_test.gd` and
  `res://tests/combat_screen_test.gd`.

Expected output:

- The player understands that buying adds the item to inventory.
- No separate `Buy & Equip` action exists in this milestone.

### P3:M4:T5 - Replace Reroll Count With Scaling Gold Reroll Cost

Status: Complete.

Goal: make rerolling a readable gold sink and make the shop refresh feel more
noticeable.

Steps:

- P3:M4:T5:S1 - Audit current reroll count behavior and state ownership.
- P3:M4:T5:S2 - Replace reroll count spending with a gold cost that starts at
  5 gold.
- P3:M4:T5:S3 - Increase the reroll cost by 5 gold after each reroll in the
  current shop phase.
- P3:M4:T5:S4 - Confirm when the cost resets, with a per-shop reset as the
  default unless user review chooses otherwise.
- P3:M4:T5:S5 - Show current reroll cost directly on or near the reroll
  action.
- P3:M4:T5:S6 - Disable or explain reroll when the player cannot afford it.
- P3:M4:T5:S7 - Add stronger visual feedback when offers refresh.
- P3:M4:T5:S8 - Animate spent gold from the player's stash readout toward the
  shop/reroll action so the payment clearly reads as gold leaving the player.
- P3:M4:T5:S9 - Refresh offer cards with a more noticeable sequence: old
  offers fade or shrink out, new offers arrive in a short stagger, and the new
  cards get a lightweight landing or rarity-border pulse.
- P3:M4:T5:S10 - Pulse the reroll cost label after it increases so the next
  price is noticeable.
- P3:M4:T5:S11 - Add focused tests for cost progression, gold spending,
  unaffordable state, reset behavior, and offer replacement.

Expected output:

- Rerolling uses gold, starts at 5, scales by 5 each reroll, and reads as a
  meaningful shop action.
- Rerolling has a clear payment-and-refresh beat: gold visibly leaves the
  player's stash, the shop offers refresh with noticeable motion, and the next
  reroll cost becomes easy to see.

Notes:

- The old one-use reroll count was replaced with a scaling gold cost stored on
  `BuildState`: rerolls start at 5g, increase by 5g after each reroll, and
  reset to 5g when a new shop round opens.
- Rerolls can continue while the player can afford the current cost; the
  action disables and explains the required gold when unaffordable.
- Save/load now persists the current shop reroll count and next reroll cost.
- The reroll button uses the shop gold icon and cost text, pulses after the
  next cost updates, and keeps tooltip copy focused on spending or blocked
  affordability.
- Successful rerolls animate `-Xg` from the Gear panel stash readout toward
  the shop/reroll action before old offers fade/shrink out and new offers
  arrive with a short staggered landing pulse.
- User playtest approved the flow on 2026-08-03.
- Verification passed on 2026-08-03:
  `res://tests/inventory_model_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/combat_screen_test.gd`,
  `res://tests/run_rng_context_test.gd`,
  `res://tests/build_panels_test.gd`, and
  `res://tests/save_load_test.gd`.
  `res://tests/save_load_test.gd` was rerun outside the sandbox because it
  writes to `user://save.json`. Godot printed the known Windows
  root-certificate-store and ObjectDB/resource cleanup warnings at exit.

### P3:M4:T6 - Clarify Full-Inventory Gear Reward Blocking

Status: Complete.

Goal: make inventory capacity consequences clear when gear rewards are offered,
especially after contract kills.

Steps:

- P3:M4:T6:S1 - Audit current gear reward collection behavior when inventory
  is full.
- P3:M4:T6:S2 - Identify which reward moments can be blocked by inventory
  capacity.
- P3:M4:T6:S3 - Add clear blocked-state copy or visual treatment when a gear
  reward cannot be collected.
- P3:M4:T6:S4 - Make the next available action clear when reward collection is
  blocked.
- P3:M4:T6:S5 - Add focused tests for full-inventory reward blocking and
  non-blocked reward collection.

Expected output:

- Full inventory remains a meaningful constraint, but the UI explains the
  consequence clearly.

Notes:

- Inventory-full and not-enough-gold states now use different visual language:
  unaffordable shop offers remain disabled/gray, while inventory-full offers
  stay clickable and play a warning pulse when the buy is blocked.
- The full-inventory blocked pulse reuses the talent-tree dependency-block
  language: a brief warning-color/scale pulse on the clicked control.
- Shop offer tooltip/status copy now says `Inventory full -- make space first.`
  when capacity, rather than gold, is the blocker.
- Fixed gear rewards now check inventory capacity before the reward is marked
  claimed; blocked claims keep the victory reward state intact and pulse the
  claim button.
- Non-Legendary reward choices require inventory space and pulse/show
  full-inventory status when blocked. Legendary reward choices remain the
  explicit auto-equip exception.
- Gear reward choice windows now include `Skip Reward`, which clears the
  pending gear choices without granting gear and then continues through the
  normal shop/map route flow.
- Focused verification passed on 2026-08-03:
  `res://tests/inventory_model_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/legendary_reward_test.gd`,
  `res://tests/build_panels_test.gd`, and
  `res://tests/combat_screen_test.gd`.
  Godot printed the known Windows root-certificate-store and ObjectDB/resource
  cleanup warnings at exit.

### P3:M4:T7 - Verify, Document, And Close Milestone 4

Status: Complete.

Goal: close the milestone with focused verification, updated docs, and clear
handoff notes.

Steps:

- P3:M4:T7:S1 - Run focused shop, inventory, gear reward, and reroll tests.
- P3:M4:T7:S2 - Run adjacent Adventure flow tests if shop/reward state
  mutation changed.
- P3:M4:T7:S3 - Run Balance Lab only if combat math, build resolution,
  skill/talent/gear resources, reward data, or balance-relevant economy data
  changed.
- P3:M4:T7:S4 - Record final checks and known caveats in this document.
- P3:M4:T7:S5 - Update `P3_CrystalMaiden_Overview.md` and
  `P3_CrystalMaiden_Onboarding_Context.md`.
- P3:M4:T7:S6 - Record deferred gear-overhaul notes, including drag-and-drop
  item movement and any deeper gear comparison or item identity work.

Expected output:

- Focused verification is complete.
- Documentation reflects the final P3M4 state.
- Future gear-overhaul candidates are clearly separated from this milestone's
  shipped UX work.

Notes:

- Final focused verification passed on 2026-08-03:
  `res://tests/inventory_model_test.gd`,
  `res://tests/route_reward_choice_ui_test.gd`,
  `res://tests/reward_shop_route_ui_test.gd`,
  `res://tests/legendary_reward_test.gd`,
  `res://tests/combat_screen_test.gd`,
  `res://tests/build_panels_test.gd`,
  `res://tests/run_rng_context_test.gd`, and
  `res://tests/save_load_test.gd`.
- Adjacent verification passed on 2026-08-03:
  `res://tests/contract_offer_flow_test.gd`,
  `res://tests/dashboard_header_test.gd`, and
  `res://tests/overlay_centering_test.gd`.
- `res://tests/save_load_test.gd` was rerun outside the sandbox because it
  writes to `user://save.json`.
- Balance Lab was not run for P3M4 closeout because this milestone did not
  change combat math, build resolution, skill/talent/gear resources, reward
  data, enemy stats, or balance-relevant combat data. The reroll cost behavior
  is a scoped shop UX/economy rule already covered by focused state/UI tests.
- Godot printed the known Windows root-certificate-store and ObjectDB/resource
  cleanup warnings at exit.
- Deferred gear-overhaul candidates remain: drag-and-drop item movement,
  deeper gear comparison and item identity presentation, `Buy & Equip` or
  other multi-destination buy flows, broader gear/economy rebalance, and a
  future production art pass for shop/inventory/reward item cards.

## Deferred Or Out Of Scope

- Drag-and-drop item movement.
- `Buy & Equip` or other multi-destination buy flows.
- General inventory selling outside shop phases.
- Gear affix redesign.
- Gear generation overhaul.
- New rarity tiers, item types, or Legendary mechanics.
- Broad economy rebalance beyond reroll cost behavior approved for this
  milestone.
- Full production art pass for shop, inventory, item cards, or rewards.

## Definition Of Done

Milestone 4 is complete when:

- Shop-phase gear management rules are documented and implemented.
- The player can equip and unequip gear while the shop is open.
- The player can sell eligible inventory gear while the shop is open.
- Buying uses one clear `Buy` action that sends items to inventory.
- Buying, selling, equipping, unequipping, and rerolling have clear disabled
  states and immediate feedback.
- Rerolling costs gold, starts at 5, increases by 5 after each reroll in the
  current shop phase, and has stronger refresh feedback.
- Full-inventory gear reward blocking is clear and test-covered.
- Focused tests pass, relevant docs are updated, and deferred gear-overhaul
  candidates are recorded.
