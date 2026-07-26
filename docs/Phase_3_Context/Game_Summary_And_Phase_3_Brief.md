# Game Summary And Phase 3 Brief

## Purpose

This document is a handoff brief for Phase 3 of Project Bane.

Phase 2 is complete. Phase 3 should focus on animation, game feel, and UX/UI
clarity before Phase 4 begins the monster and encounter overhaul. Treat this
as a presentation and usability phase, not a content expansion phase.

## High Concept

Project Bane is a Godot 4.x tactics-and-buildcraft RPG about assembling a
character build, locking a skill rotation, and testing that build against
fixed-duration DPS checks. Its closest Phase 1 shorthand was
Balatro-meets-ARPG-theorycrafting: the player makes strategic build choices,
then combat resolves automatically against a target with specific defenses.

The player is not manually piloting attacks in real time. The fun is in:

- Reading enemy pressure.
- Choosing subclass trees and talents.
- Building a skill rotation.
- Equipping gear that changes the math.
- Watching the build perform.
- Adjusting after failure or carrying momentum after success.

## Current Playable Experience

The current playable build centers on the Rogue Adventure.

The main flow is:

1. Title screen.
2. Adventure Mode.
3. Rogue class select.
4. Primary subclass select.
5. Tavern encounter ladder.
6. Rewards, shop offers, gear decisions, and talent spending.
7. Contract offer for The Gilded Serpent.
8. Secondary subclass choice.
9. Contract route choices.
10. Knives Legendary reward choice.
11. Vyra climax.
12. Contract victory, contract failure, or adventure restart state.

The current build also includes a full Training Room:

- Freeform Rogue tree selection.
- Talent selection.
- Rotation editing.
- Rarity-first gear editor.
- Direct Legendary selection.
- Practice target, armor, poison resistance, duration, seed, and gold controls.
- Animated combat playback and combat log.
- Isolation from Adventure state and save data.

## Player-Facing Design Pillars

## Buildcraft First

The game should make it satisfying to understand why a build works. UI should
show the player what changed, what matters, and what the enemy is asking of
the build.

## Combat As Proof

Combat is the proof step for a build, not a reflex test. Animation should make
the automated result legible and emotionally punchy without implying direct
manual control that does not exist.

## Pressure Is A Readable Puzzle

Enemies are DPS checks with a personality and defensive profile. Armor,
poison resistance, HP, combat window, reward, and route pressure need to be
clear before the player commits.

## Failure Should Teach

A failed fight should tell the player what happened: damage dealt, damage
needed, biggest hit, poison contribution, armor/reduction behavior, and next
allowed action. Retry/restart rules must remain obvious.

## Phase 3 Scope

Phase 3 should improve how the existing game feels to play.

Good Phase 3 work:

- Combat animation timing and readability.
- Skill popup polish.
- Hit, crit, proc, poison, armor-shred, and victory/defeat feedback.
- UI layout polish and information hierarchy.
- Better transitions between title, build, fight, reward, shop, route, and
  outcome states.
- Better hover, focus, disabled, selected, and comparison states.
- Training Room usability and visualization improvements.
- Sound placeholders only if they support interaction clarity and are easy to
  replace later.
- Documentation and UX checklists for future art/animation passes.

Avoid in Phase 3 unless explicitly rescoped:

- New classes.
- New contracts.
- Broad enemy roster expansion.
- Monster/encounter system redesign.
- Procedural map or meta-progression systems.
- Major combat-engine redesign.
- Full production art pass.

## Phase 4 Boundary

Phase 4 is planned as the monster and encounter overhaul.

Do not pre-build Phase 4 during Phase 3. It is fine to identify UX needs that
will make the Phase 4 overhaul easier, but Phase 3 should mostly polish the
current Rogue Adventure and Training Room surfaces.

If Phase 3 uncovers a monster/encounter issue, classify it as:

- UI presentation issue: Phase 3 can address it.
- Data tuning issue: Phase 3 can adjust only if it is blocking UX testing.
- Structural encounter-system issue: save for Phase 4.

## Current Architecture Summary

Important roots:

- Repo root: `F:/Data/Claude Projects/Project-Bane`
- Godot project root: `project/`
- Main scene: `res://scenes/game_root.tscn`
- Main autoload: `BuildState`

Important screens:

- `project/scenes/game_root.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/training_room/training_room.gd`

Important shared panels:

- `project/scenes/combat/talent_panel.gd`
- `project/scenes/combat/available_skills_panel.gd`
- `project/scenes/combat/skill_build_panel.gd`
- `project/scenes/combat/character_stats_panel.gd`
- `project/scenes/combat/gear_panel.gd`

Important systems:

- `project/scripts/systems/build_resolver.gd`
- `project/scripts/systems/combat_resolver.gd`
- `project/scripts/systems/combat_playback.gd`
- `project/scripts/systems/combat_result_formatter.gd`
- `project/scripts/systems/gear_generator.gd`
- `project/scripts/systems/run_rng.gd`
- `project/scripts/systems/save_system.gd`
- `project/scripts/tools/balance_lab.gd`

## Phase 3 Starting Recommendation

Begin Phase 3 with an audit milestone:

1. Capture screenshots/video of all major states at the current export size.
2. List the moments where the player waits, watches, chooses, fails, or wins.
3. Decide which moments need animation versus clearer layout/copy.
4. Pick a small first milestone, probably combat playback polish, because it
   is the most emotionally visible part of the loop and already has reusable
   infrastructure.

