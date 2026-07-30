# Phase 3 Milestone 1: Combat Playback Juice

## Purpose

Milestone 1 improves automated combat playback feel, readability, and
mechanical clarity without changing combat resolution math.

This is the single tasking and status document for Milestone 1. It replaces the
earlier per-task notes.

## Status

In Progress.

## Milestone Goal

Make combat feel readable, punchy, and satisfying while staying faithful to the
already-resolved combat timeline.

## Constraints

- Presentation changes must not alter combat math, timeline order, damage,
  poison, armor, proc behavior, Adventure state, or Training Room state.
- Animation can add feel, anticipation, and readability, but it must not become
  a second combat simulator.
- Training Room should stay useful as the controlled scenario surface for
  combat feedback.

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Plan the combat playback pass | Complete | Defined scope, constraints, key scenarios, implementation surfaces, and definition of done. |
| 1. Build controlled playback scenarios | Complete | Added resolver-driven fixtures covering 12 major presentation event types. |
| 2. Add a combat stage and actor layer | Complete | Added shared Adventure/Training actor anchors, sprite slots, contact anchors, and fallback actor cards. |
| 3. Import and configure placeholder combat sprites | Complete | Copied/imported RogueBandit and Townsfolk placeholder assets and configured expected paths. |
| 4. Prototype Rogue vs. Mouthy Drunk animation | Complete | Added first shared actor presentation language, enemy recoil, tick pulse, and outcome poses. |
| 5. Map cast events to attack animation language | Complete | Physical casts use `attack1`; poison-damage/poison-themed casts use `attack2`; poison ticks remain enemy-side pulses. |
| 6. Fit attack timing to animation duration | Complete | Attack presentation now lasts long enough for selected Rogue attack frames to finish. |
| 7. Improve start-of-fight readability | Complete | Added a shared visual fight-intro beat before the resolved combat timeline advances in Adventure and Training Room. |
| 8. Improve hit and crit feedback | Complete | Enemy reaction starts on the second-to-last Rogue attack frame; shared contact flashes now distinguish regular hits from larger gold crits, and Training Room crit popups use Adventure's gold emphasis. |
| 9. Improve poison feedback | Complete | Poison stacks now deepen the enemy's green tint and remain tracked in the HUD; damaging poison ticks use smaller enemy-centered green damage-over-time text. |
| 10. Improve persistent enemy state feedback | Complete | Combat-window HP, current armor, current resistance, poison stacks, Shred stacks, and Decay stacks now use persistent icon/value language; floating combat text is unchanged. |
| 11. Improve Legendary combat feedback | Complete | Triggered skills now read as a normal attack plus a fast follow-up, minimum-cast procs compress the source attack animation, damage popups wait for contact timing, the Skill Build strip highlights/fills each macro slot from cast start through contact, Bandit Blade adds a subtle coin spray, and Wyvern Kriss shrinks poison tick text. |
| 12. Improve victory and defeat reveals | Complete | Natural playback now lands on an outcome pose/flash before reveal UI, skip still reveals instantly, and Adventure/Training Room ending beats are covered by focused checks. |
| 13. Identify useful additional placeholder assets | In Progress | Tavern enemy sprite mappings are being expanded as useful assets are identified; Rogue skill icons from the RPG Icon Pack are now mapped into skill data and the build panels. |
| 14. Verify and document | Ongoing | Run focused playback/HUD/Training Room checks after each presentation change. |

## Completed Work

### Playback Scenarios

- Added `res://tests/helpers/combat_playback_scenarios.gd` as the controlled
  scenario catalog.
- Covered physical hit, guaranteed crit, poison stack/tick, armor reduction,
  poison resistance reduction, triggered skill, minimum-cast proc, slow cast,
  fast cast, poison cast, victory reveal, and defeat reveal.
- Kept scenarios resolver-driven and presentation-only.

### Combat Stage

- Added a shared `CombatStage` presentation layer.
- Added stable actor anchors, contact/effect anchors, floating text anchors,
  and status anchors.
- Added named `PlayerSprite` and `EnemySprite` slots.
- Preserved fallback actor cards when sprites are missing or not imported.
- Removed the Training Room debug grid after sprite placement tuning, keeping
  the shared actor anchors and sprite slots available without showing debug
  artifacts in normal play.

### Rogue Animation

- Replaced earlier trimmed RogueBandit frames with fixed-size 48x48 Sprite Lab
  frames under `project/assets/placeholder_combat_sprites/rogue_bandit/animations/`.
- Wired Rogue manifests into `CombatStage`.
- Physical casts select `attack1`.
- Poison-damage and poison-themed casts select `attack2`.
- Idle loops through fixed-size idle frames and was slowed from 100ms to 150ms
  per frame.
- Attack presentation duration now respects the selected animation length:
  `attack1` is at least 0.6s, and `attack2` is at least 1.2s.
- Enemy hit reaction starts at the second-to-last Rogue attack frame:
  `attack1` contact at 0.4s and `attack2` contact at 1.0s.

### Enemy Placeholder Sprites

All current enemy mappings use existing imported 32x32 sheet regions and first
frames from their relevant rows:

| Enemy | Sheet | Idle | Hurt | Defeat |
|---|---|---|---|---|
| Mouthy Drunk | `peasants_sprite_sheet.png` | row 1, `Rect2(Vector2(0, 0), Vector2(32, 32))` | row 3, `Rect2(Vector2(0, 64), Vector2(32, 32))` | row 4, `Rect2(Vector2(0, 96), Vector2(32, 32))` |
| Drunk Buddy | `peasants_sprite_sheet.png` | row 9, `Rect2(Vector2(0, 256), Vector2(32, 32))` | row 11, `Rect2(Vector2(0, 320), Vector2(32, 32))` | row 12, `Rect2(Vector2(0, 352), Vector2(32, 32))` |
| Tavern Bouncer | `medieval_townsfolk_sprite_sheet.png` | row 11, `Rect2(Vector2(0, 320), Vector2(32, 32))` | row 13, `Rect2(Vector2(0, 384), Vector2(32, 32))` | row 15, `Rect2(Vector2(0, 448), Vector2(32, 32))` |
| Hired Goon and current generic enemies | `medieval_townsfolk_2_sprite_sheet.png` | row 11, `Rect2(Vector2(0, 320), Vector2(32, 32))` | row 13, `Rect2(Vector2(0, 384), Vector2(32, 32))` | row 15, `Rect2(Vector2(0, 448), Vector2(32, 32))` |
| Vyra | `medieval_townsfolk_3_sprite_sheet.png` | row 11, `Rect2(Vector2(0, 320), Vector2(32, 32))` | row 13, `Rect2(Vector2(0, 384), Vector2(32, 32))` | row 15, `Rect2(Vector2(0, 448), Vector2(32, 32))` |
| Knives | `medieval_thief_sprite_sheet.png` | row 1, `Rect2(Vector2(0, 0), Vector2(32, 32))` | row 6, `Rect2(Vector2(0, 160), Vector2(32, 32))` | row 8, `Rect2(Vector2(0, 224), Vector2(32, 32))` |

Practice Target currently aliases the Mouthy Drunk placeholder visual. Door
Guard, Cloaked Watchmen, Armored Guard, Sleeping Henchman, Portly Cook,
Patrolling Guard, Lazy Henchman, Venom-Resistant Slime, Training Dummy, and
Placeholder Dummy currently reuse the Hired Goon visual so every existing fight
has a configured sprite while bespoke enemy art remains deferred.

### Rogue Skill Icons

- Copied the selected RPG Icon Pack skill icons into
  `project/assets/skill_icons/rogue/` with semantic filenames.
- Added optional `Skill.icon` texture data while preserving `Skill.icon_letter`
  as the fallback for unassigned or placeholder skills.
- Assigned the approved icon mapping:
  - Stab: `stab.png` from `Skills/Rogue/3.png`
  - Heavy Slash: `heavy_slash.png` from `Skills/Rogue/4.png`
  - Venom Jab: `venom_jab.png` from `Skills/Rogue/2.png`
  - Poison Strike: `poison_strike.png` from `Skills/Rogue/29.png`
  - Quick Cut: `quick_cut.png` from `Skills/Rogue/5.png`
  - Rending Slash: `rending_slash.png` from `Skills/Rogue/1.png`
  - Beguiling Strike: `beguiling_strike.png` from `Skills/Rogue/21.png`
  - Death Strike: `death_strike.png` from `Skills/Mage/17.png`
- Available Skills now shows each assigned skill icon next to the skill name.
- Skill Build macro slots now render icon-backed skills as compact icon boxes
  while retaining the existing order badge, remove badge, combat highlight,
  pulse, and cast-progress fill behavior.
- The change is presentation-only and does not alter combat math, resolved
  timing, rotation ids, or skill effects.

### Start-Of-Fight Readability

- Added a shared `CombatStage.play_fight_intro()` presentation beat.
- Adventure and Training Room now reset actors to idle and play a short
  pre-roll before advancing the already-resolved combat timeline.
- The combat clock and HUD remain at pre-fight values during the intro, so the
  countdown stays faithful to the authored DPS window.
- Skip collapses both the intro and the remaining timeline, preserving the
  existing deferred outcome reveal behavior.
- Instant/headless playback bypasses the wait while still using the same reset
  path for deterministic checks.

### Hit And Crit Feedback

- Added a shared contact flash to `CombatStage` so hits now produce a visible
  impact beat at the same contact timing as enemy recoil.
- Regular hits use a compact warm flash and short recoil.
- Crits use a larger gold flash, stronger enemy recoil distance, and slightly
  longer hurt timing.
- The shared feedback stays presentation-only and is driven by resolved
  `CastEvent` data.
- Training Room cast popups now mirror Adventure's crit language with gold,
  larger crit text while preserving magic-colored proc popups.

### Poison Feedback

- Added shared poison-stack tinting to `CombatStage`.
- Poison-applying casts update the enemy's persistent green tint based on the
  current active stack count; stack counts remain tracked in the HUD/status
  chips rather than spawning floating text.
- Damaging poison ticks continue to use the existing enemy-side pulse, now
  paired with smaller green damage-over-time text centered near the enemy.
- Zero-damage cadence ticks still do not spawn poison popups.
- The feedback is driven only by resolved `CastEvent.poison_stacks_applied` and
  `TickEvent.damage` data; combat math and event order are unchanged.

### Persistent Enemy State Feedback

- Added combat-window icon language for persistent enemy state readouts.
- Copied/cropped the selected placeholder icons into
  `project/assets/combat_ui_icons/`: heart for enemy HP, metal shield for
  current armor, Mage resistance icon for current poison resistance, green skull
  for poison stacks, Rogue shred icon for Shred stacks, and Mage decay icon for
  Decay stacks.
- Adventure combat HUD now uses icon/value readouts: heart plus HP value,
  shield plus current armor value, resistance icon plus current poison
  resistance value, and compact icon/value chips for poison stacks, Shred
  application count, and Decay application count.
- In Adventure, HP, armor, and resistance are grouped in the top-right HUD row;
  the Poison/Shred/Decay counters are right-aligned below the health bar.
- Poison, Shred, and Decay counters are always visible and display `x0` before
  any stack/application is active, keeping the combat status area stable while
  the fight runs.
- Training Room combat playback mirrors the combat-window status chip language
  for poison stacks, Shred stacks, and Decay stacks.
- Shred and Decay are presentation keywords for now, matching planned future
  mechanics language without changing combat math.
- Floating combat text and popup wording were intentionally left unchanged.

### Proc And Minimum-Cast Feedback

- Added `CastEvent.cast_start_ms` and `CastEvent.rotation_index` as
  presentation metadata so playback can point at the exact Skill Build macro
  slot when that cast starts.
- The Adventure and Training Room Skill Build strips now expose a combat
  highlight API. During playback, the highlight moves left-to-right through
  the macro at cast-start timing rather than waiting for the cast-end damage
  event.
- The active macro slot now fills left-to-right during the cast windup, giving
  the player a compact cast-clock readout. Minimum-cast proc fills use the
  purple proc tint so Bejeweled Push Dagger reads as a speed event in both the
  stage animation and macro strip.
- Triggered skills and retriggers pulse the source macro slot and present as a
  normal source attack followed by a fast follow-up attack. This keeps
  Mithril Karambit and Opportunity Strikes readable without changing the
  resolver's existing merged-damage event model.
- Minimum-cast procs now compress the source attack animation to the fastest
  presentation timing and use purple proc-styled damage text, so Bejeweled
  Push Dagger reads as a speed event rather than a second attack.
- Bandit Blade now has a first-pass always-on Legendary effect: while the
  weapon is equipped, physical-damage hits spawn a restrained spray of tiny
  Lucky Coin particles at contact timing. Normal hits use 3 coins; crits use
  5. The particles stay small, fade in under half a second, and do not change
  combat math.
- Wyvern Kriss now has a first-pass always-on Legendary effect: poison tick
  popups use smaller text while the weapon is equipped, matching the
  faster-ticking poison identity without adding extra particles or attack
  animation.
- Umbral Stiletto intentionally has no extra combat overlay in this pass
  because its Legendary identity is already visible through the Death Strike
  skill unlock.
- Playback resolves same-timestamp cast-end/proc presentation before the next
  cast-start highlight wins, so a Karambit retrigger pulse does not make the
  following macro slot look skipped.
- Adventure and Training Room cast damage popups now wait for the stage's
  contact timing instead of appearing immediately when the playback event
  fires. For triggered-skill events, the popup waits for the fast follow-up's
  hit beat.
- Skip still suppresses delayed popups so the result reveal remains instant.

### Cast Windup Alignment

- Split cast presentation into a cast-start Rogue windup and a cast-end impact
  beat.
- The Skill Build slot fill and Rogue attack now read as one action: the slot
  begins filling at `CastEvent.cast_start_ms`, the Rogue animation starts
  during that fill, and the animation's contact frame aligns with
  `CastEvent.time_ms` when the slot completes.
- Enemy recoil, contact feedback, Bandit Blade coin spray, HUD damage, and
  damage popups remain tied to the resolved cast event at `CastEvent.time_ms`.
- Triggered skills still use a fast follow-up after the source contact, with
  proc popup timing held until that follow-up hit beat.
- Minimum-cast procs compress the source windup so their contact still lands
  as the shortened macro fill completes.
- `CombatPlayback` now interleaves cast-start callbacks and resolved events by
  timestamp so a large frame advance still delivers a cast start before that
  same cast's end event; exact same-timestamp cast-end/next-cast-start
  boundaries still deliver the prior cast end before the next macro slot wins.
- The change remains presentation-only and does not alter combat math, resolved
  event timestamps, damage, poison, armor, BuildState mutation, or autosave
  timing.

### Victory And Defeat Reveals

- Added a shared terminal outcome flash to `CombatStage.play_outcome_pose()`.
- Victory outcomes now pair the configured enemy defeat frame with a restrained
  gold flash and settle before an integrated combat-window result state
  appears.
- Defeat outcomes now pair the Rogue hurt/defeat presentation with a restrained
  red flash and settle before the loss title, recap, and retry actions appear.
- Adventure natural playback keeps outcome UI, combat log access, and the Map
  button locked during the short outcome-pose hold, then unlocks them together
  when `_reveal_fight_outcome()` runs.
- The victory reveal now follows the Option 3 transition direction: the
  full-screen overlay still blocks clicks, but its visible backdrop is
  transparent and the combat window itself dims while `VICTORY!`, recap lines,
  rewards, and `Claim Rewards` fade/scale into the same combat-window area.
  The Rogue, defeated enemy, and combat stage remain visible behind the result
  content instead of being immediately covered by a separate two-card modal.
- Adventure skip still flushes the remaining timeline and reveals the result
  immediately, while snapping actors to the correct outcome pose without
  delayed popups.
- Training Room realtime playback now mirrors the end beat with a short
  outcome hold before emitting `finished`; its Skip button bypasses that hold
  and finishes immediately.
- The changes are presentation-only and do not alter combat math, resolved
  event order, BuildState mutation timing, autosave timing, or Training Room
  damage accounting.

## Verification

Focused checks used during this milestone:

- `res://tests/combat_playback_test.gd`
- `res://tests/combat_hud_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/build_panels_test.gd`
- `res://tests/combat_screen_test.gd`

Latest T13 skill-icon verification:

- Skill icon import and focused checks passed on 2026-07-30 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths:
  - Direct `project.godot --import`: Pass; generated `.import` metadata for
    the eight new skill icon PNGs.
  - `res://tests/build_panels_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/rotation_cap_test.gd`: Pass.
  - `res://tests/training_room_build_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.

Earlier T12 verification:

- Cast windup alignment checks passed on 2026-07-29:
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.
  - `res://tests/training_room_combat_view_test.gd`: Pass.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/combat_screen_test.gd`: Pass.
- Integrated combat-window victory transition checks passed on 2026-07-29:
  - `res://tests/combat_screen_test.gd`: Pass.
  - `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
    sandbox for the known autosave/user-data assertion. The first sandboxed
    run failed only on that known assertion.
  - `res://tests/combat_hud_test.gd`: Pass.
  - `res://tests/run_outcome_presentation_test.gd`: Pass.
  - `res://tests/combat_recap_test.gd`: Pass.
- `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
  sandbox for the known autosave/user-data assertion. The first sandboxed run
  failed only on that known assertion.
- `res://tests/training_room_combat_view_test.gd`: Pass.
- `res://tests/combat_hud_test.gd`: Pass.
- `res://tests/combat_screen_test.gd`: Pass.
- Runs used `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with
  explicit workspace `--log-file` paths on 2026-07-29.

Earlier T11 verification:

- `res://tests/combat_playback_test.gd`: Pass after rerunning outside the
  sandbox for the known autosave/user-data assertion.
- `res://tests/combat_hud_test.gd`: Pass.
- `res://tests/training_room_combat_view_test.gd`: Pass.
- `res://tests/build_panels_test.gd`: Pass.
- `res://tests/combat_screen_test.gd`: Pass.
- `res://tests/legendary_mechanics_test.gd`: Pass.
- Final Bandit Blade coin-position/timing and Wyvern Kriss smaller-poison-tick
  checks passed in `combat_playback_test.gd`,
  `training_room_combat_view_test.gd`, and `combat_screen_test.gd`.

Earlier notes:

- M1:T11 focused checks passed on 2026-07-29 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths.
- The first sandboxed `combat_playback_test.gd` run failed only on the known
  autosave/user-data assertion; the escalated rerun passed.

Earlier T10 verification:

- `res://tests/combat_playback_test.gd`: Pass.
- `res://tests/combat_hud_test.gd`: Pass.
- `res://tests/training_room_combat_view_test.gd`: Pass.

Notes:

- M1:T10 focused checks passed on 2026-07-29 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths.
- A direct `project.godot --import` pass imported the new combat UI icon PNGs
  before the focused checks.
- M1:T9 focused checks passed on 2026-07-29 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` with explicit
  workspace `--log-file` paths.
- `res://tests/combat_hud_test.gd` needed a rerun outside the sandbox after the
  sandboxed `--path` invocation exited before creating its log file.
- The direct `project.godot` invocation was not a valid substitute for the HUD
  check because it did not load normal project autoloads.

Known caveats:

- Godot may print ObjectDB/resource cleanup warnings at exit even when checks
  pass.
- `combat_playback_test.gd` may need normal user-data access for its autosave
  assertion; when sandboxed runs fail on that assertion, rerun outside the
  sandbox.

## Definition Of Done

Milestone 1 is complete when:

- Major combat event types have distinct presentation language.
- Hit, crit, poison, armor/resist reduction, proc, victory, and defeat moments
  are readable at normal playback speed.
- Adventure and Training Room use consistent combat presentation language.
- Focused playback, HUD, and Training Room checks pass.
- Any remaining visual limitations are documented as future art/polish notes.
