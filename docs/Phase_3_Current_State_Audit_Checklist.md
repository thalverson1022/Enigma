# Phase 3 Current State Audit Checklist

## Purpose

This checklist supports Milestone 0 of Project CrystalMaiden.

Use it to review the current playable game before implementation begins. The
goal is to identify where Phase 3 should add juice, clarity, animation,
feedback, and usability polish without expanding core content or redesigning
mechanics.

## Audit Status Values

- Not Reviewed: the state has not been inspected yet.
- Reviewed: the state has been inspected and notes were captured.
- Needs Work: the state has clear Phase 3 polish needs.
- Good Enough: the state is acceptable for Phase 3 unless later work touches it.
- Deferred: the issue belongs to a later phase.

## Review Questions

For each state, answer:

- What is the player trying to understand or decide here?
- What should feel satisfying here?
- What is unclear, flat, slow, or visually under-emphasized?
- Does the screen clearly show the next action?
- Are hover, focus, selected, disabled, and comparison states clear?
- Does any issue belong to Phase 4 mechanics or encounter redesign instead?

## Major State Checklist

| Area | State Or Screen | Status | Notes |
|---|---|---|---|
| Start | Title screen | Not Reviewed |  |
| Start | Adventure Mode entry | Not Reviewed |  |
| Start | Resume or restart state | Not Reviewed |  |
| Class | Class select | Not Reviewed | Rogue is playable; Mage and Crusader are placeholders. |
| Class | Primary Rogue subclass select | Not Reviewed | Assassin, Thief, Shadow. |
| Class | Secondary Rogue subclass select | Not Reviewed | Appears during The Gilded Serpent flow. |
| Build | Talent panel | Not Reviewed | Include prerequisites, selected states, and unavailable states. |
| Build | Available skills panel | Not Reviewed | Include unlocked, locked, and newly unlocked skills. |
| Build | Rotation editor | Not Reviewed | Include editing, legal rotation, invalid state, and lock-in. |
| Build | Character stats panel | Not Reviewed | Check clarity before and after build changes. |
| Combat | Target panel | Not Reviewed | Include HP, armor, poison resistance, rewards, and duration. |
| Combat | Fight start | Not Reviewed | Check anticipation, button state, and transition into playback. |
| Combat | Cast playback | Not Reviewed | Include timing readability and skill identity. |
| Combat | Normal hit feedback | Not Reviewed |  |
| Combat | Crit feedback | Not Reviewed |  |
| Combat | Poison stack application | Not Reviewed |  |
| Combat | Poison tick feedback | Not Reviewed |  |
| Combat | Armor reduction feedback | Not Reviewed | Should read as persistent enemy state. |
| Combat | Poison resistance reduction feedback | Not Reviewed | Should be visually distinct from armor reduction. |
| Combat | Triggered skill or retrigger feedback | Not Reviewed | Should connect to the source cast. |
| Combat | Minimum-cast proc feedback | Not Reviewed | Should read as timing/speed, not direct damage. |
| Combat | Victory moment | Not Reviewed |  |
| Combat | Defeat moment | Not Reviewed |  |
| Combat | Combat recap | Not Reviewed | Include damage dealt, damage needed, DPS, poison contribution. |
| Combat | Combat log | Not Reviewed | Check scanability and mechanical explanation. |
| Rewards | Gold reward | Not Reviewed |  |
| Rewards | Talent point reward | Not Reviewed |  |
| Rewards | Gear reward choice | Not Reviewed |  |
| Rewards | Legendary reward choice | Not Reviewed | Include Knives 2-of-5 choice. |
| Gear | Equipped gear slots | Not Reviewed | Weapon, trinket, charm; Rogue labels dagger, ring, necklace. |
| Gear | Inventory | Not Reviewed |  |
| Gear | Gear comparison | Not Reviewed |  |
| Gear | Legendary gear presentation | Not Reviewed | Reward, shop, inventory, equipped, and combat moments. |
| Shop | Shop offer set | Not Reviewed | Include rarity readability and duplicate prevention. |
| Shop | Buy, reroll, skip, and continue actions | Not Reviewed |  |
| Adventure | Tavern encounter ladder | Not Reviewed |  |
| Adventure | Contract offer | Not Reviewed | The Gilded Serpent. |
| Adventure | Contract route choice | Not Reviewed |  |
| Adventure | Vyra climax | Not Reviewed |  |
| Adventure | Contract victory | Not Reviewed |  |
| Adventure | Contract failure | Not Reviewed |  |
| Adventure | Adventure restart | Not Reviewed | Confirm seed behavior remains clear. |
| Training Room | Tree and talent setup | Not Reviewed |  |
| Training Room | Rotation setup | Not Reviewed |  |
| Training Room | Rarity-first gear editor | Not Reviewed |  |
| Training Room | Direct Legendary selection | Not Reviewed |  |
| Training Room | Target controls | Not Reviewed | Practice target, armor, poison resistance, duration, seed, gold. |
| Training Room | Combat playback controls | Not Reviewed |  |
| Training Room | Combat recap and log | Not Reviewed |  |
| Training Room | Adventure-state isolation | Not Reviewed | Confirm practice does not mutate run/save state. |
| Testing | Godot regression suite | Not Reviewed | Confirm current command, pass/fail state, and known warnings. |
| Testing | Balance Lab | Not Reviewed | Confirm current command, outputs, and usefulness. |
| Testing | External mechanics testing package | Not Reviewed | Audit in Milestone 7, but identify obvious setup issues now. |
| Export | Windows export smoke test | Not Reviewed | Only required if export is refreshed during Phase 3. |

## Audit Outputs

At the end of the audit, capture:

- A short list of the highest-value Phase 3 polish targets.
- Any issues that should be deferred to Phase 4 mechanics or encounter work.
- Any testing or Balance Lab concerns discovered before Milestone 7.
- The recommended Task 0 scope for Milestone 1.
