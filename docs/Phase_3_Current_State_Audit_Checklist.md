# Phase 3 Current State Audit Checklist

## Purpose

This checklist closes the Milestone 0 audit pass for Project CrystalMaiden.

The audit was a planning-level review of the current Godot project, Phase 3
handoff docs, key UI/combat scripts, and focused headless tests. It was not a
full visual playtest capture pass. Visual review should happen during each
milestone's Task 0 and implementation review.

## Audit Summary

Overall status: Complete for Milestone 0.

The current build already has a functional Phase 2 presentation layer:

- Persistent Adventure dashboard.
- Combat HUD with HP bar and status chips.
- Real-time combat playback using a deterministic event timeline.
- Skill popups for hits, crits, poison ticks, and procs.
- Playback speed controls and skip.
- Victory and loss recap presentation.
- Training Room combat playback.
- Focused tests for playback, HUD, recap, Training Room combat view, and
  Balance Lab.

The Phase 3 opportunity is not to invent these systems from nothing. It is to
make their visual language clearer, stronger, more consistent, and more
satisfying.

## Baseline Verification

Before closing Milestone 0, the fresh `Project-CrystalMaiden` clone required a
one-time Godot import pass to generate local `.godot/imported` cache files.
After that import, focused checks passed:

| Check | Command Target | Result | Notes |
|---|---|---|---|
| Combat playback | `res://tests/combat_playback_test.gd` | Pass | Verifies deterministic timeline, speed, skip, full-window playback, deferred reveal, and speed persistence. |
| Combat recap | `res://tests/combat_recap_test.gd` | Pass | Verifies recap helper output and live win/loss recap display. |
| Combat HUD | `res://tests/combat_hud_test.gd` | Pass | Verifies pre-fight, win, loss, retry, armor, resist, and poison HUD behavior. |
| Training Room combat view | `res://tests/training_room_combat_view_test.gd` | Pass | Verifies damage readout, live status readout, zero-tick popup filtering, proc highlighting, and Adventure-state isolation. |
| Balance Lab | `res://tests/balance_lab_test.gd` | Pass | Verifies report generation and key scenario coverage. |

Known test-output caveat:

- Godot prints ObjectDB/resource cleanup warnings at exit even when focused
  checks pass with exit code 0. This matches the Phase 2 closeout caveat.

Fresh-clone setup note:

- A new clone may need one headless editor/import run before tests can resolve
  imported fonts and global script classes.

## Major State Checklist

| Area | State Or Screen | Status | Notes |
|---|---|---|---|
| Start | Title screen | Reviewed | Exists as its own scene. Needs later visual pass for transition polish. |
| Start | Adventure Mode entry | Reviewed | Current flow is functional. Phase 3 should smooth transition into the dashboard. |
| Start | Resume or restart state | Reviewed | Covered by save/load and outcome flow tests in the broader suite; visual clarity should be checked later. |
| Class | Class select | Reviewed | Rogue is playable; Mage and Crusader remain placeholders. Do not expand class content in Phase 3. |
| Class | Primary Rogue subclass select | Reviewed | Assassin, Thief, Shadow are implemented. Later polish target: selection presentation and comparison clarity. |
| Class | Secondary Rogue subclass select | Reviewed | Appears during The Gilded Serpent flow. Later polish target: make contract context and build implications clearer. |
| Build | Talent panel | Reviewed | Functional. Phase 3 should improve hover, prerequisite, selected, and unavailable-state readability. |
| Build | Available skills panel | Reviewed | Functional. Later polish should clarify newly unlocked and unusable skills. |
| Build | Rotation editor | Reviewed | Functional. Later polish should improve editing feedback, lock-in state, and invalid/empty rotation clarity. |
| Build | Character stats panel | Reviewed | Functional. Later polish should better show what changed after gear/talent decisions. |
| Combat | Target panel | Reviewed | Functional. Phase 3 should ensure HP, armor, poison resist, duration, and reward pressure are readable before Fight. |
| Combat | Fight start | Needs Work | Entry into playback exists. Milestone 1 should add anticipation and a clearer start-of-fight beat. |
| Combat | Cast playback | Needs Work | Deterministic playback exists. Milestone 1 should improve timing readability and skill identity. |
| Combat | Normal hit feedback | Needs Work | Popups exist. Needs stronger impact language and visual rhythm. |
| Combat | Crit feedback | Needs Work | Gold, larger crit popups exist. Needs visual review for punch, contrast, and hierarchy. |
| Combat | Poison stack application | Needs Work | Status chips update. Needs clearer stack-application feedback separate from poison tick damage. |
| Combat | Poison tick feedback | Needs Work | Poison tick popups exist and zero ticks are filtered in Training Room. Needs consistent Adventure/Training visual language. |
| Combat | Armor reduction feedback | Needs Work | Persistent chip exists. Needs stronger persistent enemy-state presentation. |
| Combat | Poison resistance reduction feedback | Needs Work | Persistent chip exists but shares warning language with armor reduction. Needs distinct visual identity. |
| Combat | Triggered skill or retrigger feedback | Needs Work | Proc popups exist. Needs clearer source-to-trigger relationship. |
| Combat | Minimum-cast proc feedback | Needs Work | Proc text/log coverage exists. Needs speed/timing emphasis rather than generic proc emphasis. |
| Combat | Victory moment | Needs Work | Victory overlay and recap exist. Needs more satisfying combat-end transition and reward bridge. |
| Combat | Defeat moment | Needs Work | Loss title, retry/restart text, and recap exist. Needs clearer emotional/teaching presentation. |
| Combat | Combat recap | Reviewed | Focused recap test passes. Milestone 2 should polish hierarchy and failure teaching. |
| Combat | Combat log | Reviewed | Formatter includes chronological event text and proc markers. Later polish should improve scanability. |
| Rewards | Gold reward | Reviewed | Implemented. Later polish target. |
| Rewards | Talent point reward | Reviewed | Implemented. Later polish target. |
| Rewards | Gear reward choice | Reviewed | Implemented. Later polish target. |
| Rewards | Legendary reward choice | Reviewed | Implemented, including Knives 2-of-5 choice. Later polish should make Legendary moments feel special. |
| Gear | Equipped gear slots | Reviewed | Weapon/trinket/charm with Rogue display labels. Later polish should keep labels class-aware. |
| Gear | Inventory | Reviewed | Implemented. Later polish target. |
| Gear | Gear comparison | Reviewed | Tooltip comparison approach exists. Later polish should check clarity and discoverability. |
| Gear | Legendary gear presentation | Needs Work | Mechanics and art exist. Phase 3 should add stronger presentation in reward, shop, inventory, equipped, and combat moments. |
| Shop | Shop offer set | Reviewed | Implemented. Later polish should improve offer hierarchy and rarity readability. |
| Shop | Buy, reroll, skip, and continue actions | Reviewed | Implemented. Later polish should reduce ambiguity around action priority. |
| Adventure | Tavern encounter ladder | Reviewed | Implemented. Later polish should improve map/route readability and transitions. |
| Adventure | Contract offer | Reviewed | Implemented as a multi-step contract conversation. Later polish should strengthen presentation. |
| Adventure | Contract route choice | Reviewed | Implemented. Later polish should make route pressure clearer. |
| Adventure | Vyra climax | Reviewed | Implemented. Later polish should make this feel like a climax. |
| Adventure | Contract victory | Reviewed | Implemented. Later polish target. |
| Adventure | Contract failure | Reviewed | Implemented. Later polish target, especially clarity of next action. |
| Adventure | Adventure restart | Reviewed | Implemented with seed preservation messaging. Later visual review needed. |
| Training Room | Tree and talent setup | Reviewed | Implemented. Milestone 6 should improve speed and clarity. |
| Training Room | Rotation setup | Reviewed | Implemented. Milestone 6 polish target. |
| Training Room | Rarity-first gear editor | Reviewed | Implemented. Milestone 6 polish target. |
| Training Room | Direct Legendary selection | Reviewed | Implemented. Milestone 6 polish target. |
| Training Room | Target controls | Reviewed | Implemented. Milestone 6 polish target. |
| Training Room | Combat playback controls | Reviewed | Focused Training Room combat-view test passes. Should stay aligned with Adventure playback language. |
| Training Room | Combat recap and log | Reviewed | Implemented. Later polish target. |
| Training Room | Adventure-state isolation | Reviewed | Focused test confirms combat view does not mutate real `BuildState.gold`; broader isolation should remain protected. |
| Testing | Godot regression suite | Reviewed | 39 test scripts exist. Full suite should be run at major milestone closeouts. |
| Testing | Balance Lab | Reviewed | Focused Balance Lab test passes. Milestone 7 should harden documentation, coverage, and output clarity. |
| Testing | External mechanics testing package | Reviewed | Exists enough to support focused checks. Needs dedicated audit and hardening in Milestone 7. |
| Export | Windows export smoke test | Deferred | Not required for Milestone 0. Revisit after gameplay/UI resource changes or before Phase 3 closeout. |

## Highest-Value Phase 3 Polish Targets

1. Combat playback event language: make hits, crits, poison, armor shred,
   poison vulnerability, procs, and min-cast timing immediately distinct.
2. Combat start and end beats: add anticipation before the first event and a
   more satisfying victory/defeat reveal.
3. Persistent enemy states: make armor reduction and poison resistance
   reduction read as ongoing enemy conditions, not just small text chips.
4. Source-to-trigger readability: make triggered skills feel chained to the
   source cast.
5. Training Room parity: use Training Room as the controlled scenario surface
   for testing combat feedback during Milestone 1.

## Deferred To Later Milestones

- Combat recap hierarchy and failure teaching belong primarily to Milestone 2.
- Build, rotation, and talent manipulation belong primarily to Milestone 3.
- Gear, shop, rewards, and Legendary presentation belong primarily to
  Milestone 4.
- Adventure transitions and major route/story beats belong primarily to
  Milestone 5.
- Training Room control ergonomics belong primarily to Milestone 6.
- Test-suite and Balance Lab hardening belong primarily to Milestone 7.
- Placeholder audio remains provisional until Milestone 8.

## Milestone 1 Task 0 Recommendation

Begin Milestone 1 by planning a focused combat playback pass around controlled
mechanic scenarios:

- Basic physical hit.
- Guaranteed crit.
- Poison stack application followed by poison ticks.
- Armor reduction.
- Poison resistance reduction.
- Triggered skill or retrigger.
- Minimum-cast proc.
- Victory reveal.
- Defeat reveal.

Use the Training Room and existing focused tests as the implementation safety
net. Avoid combat-engine changes unless the planning pass discovers a real
presentation-blocking data gap.
