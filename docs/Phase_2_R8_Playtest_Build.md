# P2:R8 - Playtest Build

## Purpose

Track the work for **P2:R8 - Playtest Build**.

The goal is to make the revised Phase 2 Rogue Adventure shareable with a
non-developer. This milestone is about bug fixing, export readiness, minimum
legibility, and collecting useful feedback.

Scope note from 2026-07-17: a compact **Training Room Lite** may be added near
the end of this milestone if the Rogue Adventure path is already stable. This
is playtest support, not a new Phase 2 parity blocker. Full Phase 1 Training
Room mode remains Phase 3+.

## Exit Criteria

P2:R8 is complete when:

- A Windows desktop build can be exported and launched outside the editor.
- A non-developer can play the Rogue Adventure unassisted.
- The run can proceed from character creation through Tavern, contract route,
  Knives, and Vyra.
- Save/load works in the exported build.
- Known critical bugs are fixed or documented.
- Feedback collection prompts are ready.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R8:T1 | Define Playtest Scope | What testers should and should not judge | Complete |
| P2:R8:T2 | Run Full Regression Pass | Current automated tests and manual playthrough results | Complete |
| P2:R8:T3 | Fix Critical Bugs | Blocking issues resolved | Complete |
| P2:R8:T4 | Prepare Export Settings | Windows export preset and output folder ready | Complete |
| P2:R8:T5 | Export Build | Shareable build artifact produced | Complete |
| P2:R8:T6 | Smoke Test Export | Exported build launched and played through key path | Complete |
| P2:R8:T7 | Prepare Playtest Notes | Tester instructions and feedback prompts | Complete |
| P2:R8:T8 | Record Known Issues | Non-blocking issues documented | Complete |
| P2:R8:T9 | Add Training Room Lite (Optional) | Compact practice mode if low-risk after Adventure/export stability | Superseded |
| P2:R8:T10 | Update Docs | Phase 2 playtest readiness recorded | Complete |

## P2:R8:T1 - Define Playtest Scope

Tell testers what feedback is useful:

- Buildcraft clarity.
- UI comprehension.
- Encounter pressure.
- Reward/shop decision quality.
- Route choice clarity.
- Bugs and confusing states.

Also state what is not the focus:

- Final art.
- Final animation.
- Full content breadth.
- Balance perfection.
- Full Training Room/freeform lab parity.

Completed 2026-07-19. The R8 playtest target is the current Rogue Adventure
build, not the full imagined game. Testers should be asked to play a complete
run from the title screen through Rogue class/subclass selection, Tavern
encounters, rewards, shop decisions, The Gilded Serpent contract route,
Knives, the Legendary reward choice, and Vyra. A useful playtest can still
end in failure if the tester can explain where the run failed and whether the
game made the reason clear.

Feedback should focus on:

- Whether the player understands what to do next on each screen.
- Whether class, subclass, talent, rotation, gear, enemy, reward, shop, and
  route-choice information is readable without outside explanation.
- Whether combat results explain why a build won or lost.
- Whether reward, shop, and Legendary choices feel understandable and
  consequential.
- Whether Tavern do-over, Adventure restart, contract failure, contract
  victory, save/quit, resume, and abandon-run states are clear.
- Whether any bug, crash, dead-end UI state, save/load issue, text overlap, or
  confusing control blocks progress.
- Whether encounter pressure and route difficulty feel legible enough for a
  first playtest, even if balance is not final.

Testers should be told not to judge:

- Final art, final animation, sound, VFX, or content-complete production
  polish.
- Full class breadth beyond Rogue.
- Additional contracts beyond The Gilded Serpent.
- Broad procedural meta-progression or campaign structure.
- Perfect combat balance or final item/talent tuning.
- Full Phase 1 Training Room/freeform lab parity.

Issue reports should include enough run context to reproduce or interpret the
problem:

- Adventure seed.
- Primary and secondary Rogue subclass choices.
- Important talent and rotation choices.
- Route path taken through The Gilded Serpent.
- Gear or Legendary choice if relevant.
- Whether the issue happened before or after save/load/resume.
- Screenshot or exact text of any confusing state when possible.

Training Room Lite remains part of R8 only as the optional `P2:R8:T9` task.
It should be attempted after the Adventure/export path is stable, and skipped
or documented as a known issue if it risks delaying the shareable Rogue
Adventure build.

## P2:R8:T2 - Run Full Regression Pass

Run:

- All headless tests.
- Manual editor/player click-through.
- At least one full route to victory.
- At least one loss/failure path.
- Save/load mid-run.

Record exact failures.

## P2:R8:T3 - Fix Critical Bugs

Prioritize:

- Crashes.
- Dead-end UI states.
- Save/load corruption.
- Cannot complete run.
- Impossible/default losing path if not intended.
- Text overlap that blocks critical interaction.

Non-blocking polish can go to known issues.

## P2:R8:T4 - Prepare Export Settings

Set up Windows export:

- Export preset.
- Output directory.
- Icon/name if available.
- Include required resources.
- Confirm `.godot/` and build artifacts are ignored appropriately.

Web export is optional only if low-effort.

## P2:R8:T5 - Export Build

Produce the build artifact in a clear local folder.

Do not treat export as complete until the exported executable launches.

## P2:R8:T6 - Smoke Test Export

In the exported build:

- Start new run.
- Choose Rogue/subclass.
- Fight at least one Tavern encounter.
- Visit reward/shop if available.
- Save/quit/resume.
- Continue to a later encounter or boss path.

Record results.

### Smoke Test Protocol (P2:R8:T6)

Run this as one sitting where possible. Stop and report immediately if you
hit anything in the "blocker" tier below -- don't try to play around it.
Everything else, keep playing and note it for the log at the end.

**0. Launch check**
- [ ] Confirm both files exist: `project/export/windows/ProjectBane.exe` and
      `project/export/windows/ProjectBane.pck`.
- [ ] Double-click `ProjectBane.exe` directly (not through the editor).
- [ ] Window opens within a few seconds, no crash dialog, no console errors
      visible.

**1. Title screen**
- [ ] Buttons present: `Training Room` (should be disabled/grayed),
      `Adventure Mode`, `Continue Adventure` (disabled if no save exists
      yet), `Exit`.
- [ ] A `Seed` field is visible and editable before starting Adventure Mode.
- [ ] Note the seed you use for this run (default or one you typed) -- you
      need it for the report below.

**2. Class / subclass select**
- [ ] Click `Adventure Mode`. Rogue is a real, selectable class card; Mage
      and Crusader show as disabled "coming soon" cards.
- [ ] Pick Rogue, proceed to subclass select. Note which subclasses are
      selectable and pick one as primary.

**3. Build panels (talents / skills / rotation)**
- [ ] Spend talent points; the panel updates and locked talents show a
      reason.
- [ ] Add skills to your rotation. Character stats panel reflects your
      choices (e.g. a physical-damage-% talent visibly changes a stat).

**4. First Tavern fight (Mouthy Drunk)**
- [ ] Fight resolves, combat playback runs, a result (win/loss) is shown
      with a recap.
- [ ] If you lose here, confirm you can retry with no limit (this is the
      one unlimited-retry fight).
- [ ] On a win, claim the reward.

**5. Second Tavern fight + shop**
- [ ] Fight Drunk Buddy (or whichever is next). On a loss here, confirm you
      get exactly **one** retry, not unlimited.
- [ ] After a win unlocks the shop, open it: buy at least one item, try the
      reroll, equip something from inventory, confirm the gear panel and
      character stats reflect the change.

**6. Save / quit / resume (do this mid-run, after at least one fight is
resolved)**
- [ ] From the dashboard, use `Save & Quit`.
- [ ] Fully close and relaunch `ProjectBane.exe`.
- [ ] From the title screen, `Continue Adventure` should now be enabled.
      Click it and confirm your seed, gold, gear, talents, and current
      encounter position all match where you left off.

**7. Contract route through Knives and Vyra**
- [ ] Continue until The Gilded Serpent contract offer appears; accept it.
- [ ] Make the secondary-subclass choice when offered.
- [ ] Make at least one route branch choice; note which path you took (this
      matters for reporting).
- [ ] Reach Knives, make the Legendary reward choice, confirm the Legendary
      item is usable.
- [ ] Reach and fight Vyra (win or lose both count as completing this step
      -- see "loss path" below).

**8. Loss path (whichever comes first naturally, don't force it early)**
- [ ] On a second consecutive Tavern loss: confirm you're told your
      Adventure is restarting and your seed is preserved on the new class
      select screen.
- [ ] On a contract-route loss (including losing to Vyra): confirm you're
      told the contract failed, with a clear next action (not a dead end).

**9. Abandon Run (optional, if time allows)**
- [ ] From the dashboard, use `Abandon Run`, confirm the confirmation
      dialog, confirm it returns you to a state where you can start fresh.

### Blocker tier (stop and report right away)

- Crash, frozen/unresponsive window, or a screen with no visible way
  forward.
- Save/resume that loses or corrupts your build, gear, gold, or route
  position.
- A fight that cannot be won or retried when it should be (per the retry
  rules above).
- Text so overlapped/cut off that you can't read a required choice.

### Recording results

For anything you note (blocker or not), capture:

- The seed you played.
- Primary and secondary subclass choices.
- The route path taken.
- Gear/Legendary choice involved, if any.
- Whether it was before or after a save/load/resume.
- A screenshot or the exact on-screen text.

Report findings back in chat (or paste them as a dated entry under this
milestone's Implementation Notes) and they'll get triaged: blockers return
to `P2:R8:T3`, everything else goes into the `P2:R8:T8` known-issues log.

## P2:R8:T7 - Prepare Playtest Notes

Create concise notes for testers:

- What build they are playing.
- What the current goal is.
- What feedback is most useful.
- How to report seed/build/path issues.
- Known non-blocking rough edges.

### Tester Notes (P2:R8:T7)

Give testers this note alongside the build.

**What you're playing.** A Windows desktop smoke build of Project Bane's
Rogue Adventure at `project/export/windows/ProjectBane.exe` (plus its
`ProjectBane.pck`), built 2026-07-19. It includes fixes found during the
first hands-on export pass: a real selectable Rogue class card, a
title-screen Adventure seed field, corrected Tavern/contract retry rules
(unlimited retries on the very first fight, one retry on every other Tavern
or contract-route fight, an Adventure restart or contract failure after
that), clarified Shadow poison-stack wording, and verified enemy-panel data.
Training Room is visible on the title screen but intentionally disabled --
it is not part of this build.

**What to do.** Start a new Adventure, pick Rogue, choose a subclass, and
play through: Tavern encounters, claiming rewards, the shop when it unlocks,
The Gilded Serpent contract offer, a secondary subclass choice, route
picks, Knives and its Legendary choice, and Vyra. It is fine if the run
ends in failure -- a useful playtest can end in defeat as long as you can
say where and why the run ended.

**What feedback is most useful.**
- Whether each screen makes the next action obvious without being told.
- Whether class/subclass/talent/rotation/gear/enemy/reward/shop/route
  information reads clearly on its own.
- Whether a fight's outcome (win or loss) explains itself.
- Whether reward, shop, and Legendary choices feel meaningful.
- Whether retry, Adventure-restart, contract-failure, contract-victory,
  save/quit, resume, and abandon-run states are clear.
- Any bug, crash, dead end, save/load problem, overlapping text, or control
  that blocks progress.
- Whether encounter and route difficulty feel appropriately tense, even
  though balance isn't final.

**What not to judge.** Final art/animation/sound/VFX, classes beyond Rogue,
contracts beyond The Gilded Serpent, broad meta-progression, final balance
tuning, and Training Room (disabled in this build). See `P2:R8:T1` above for
the full scope statement.

**How to report an issue.** Include enough to reproduce it:
- The Adventure seed (shown on the title screen and the dashboard header).
- Primary and secondary Rogue subclass choices.
- Key talent and rotation choices.
- The route path taken through The Gilded Serpent.
- Any gear or Legendary choice involved.
- Whether it happened before or after a save/load/resume.
- A screenshot or the exact text of any confusing state, if possible.

**Known non-blocking rough edges to expect.** First-draft visual/feel
judgment calls (button contrast, combat-playback pacing, popup sizing,
panel fit at your screen resolution, tooltip sizing) have not had a
rendered pass yet and may look or feel slightly off; note anything that
actively bothers you, but don't expect final polish. See `P2:R8:T8` below
for the full internal list.

## P2:R8:T8 - Record Known Issues

Document:

- Bugs not fixed before playtest.
- Balance concerns.
- UI rough edges.
- Missing polish.
- Deferred Phase 3 items that testers may notice.

### Known Issues Log (P2:R8:T8)

**Bugs not fixed before playtest.** None open. `P2:R8:T2`/`T3` found no
blocking production bug in the automated regression pass, and every bug
found so far during hands-on export smoke testing (Rogue class-select
export-remap scan, retry-rule exception, Shadow poison wording, redundant
enemy-panel lines) was fixed in the same session it was found, per the
dated entries above. `P2:R8:T6 - Smoke Test Export` is still open, so a
full hands-on pass through every path (later encounters, boss path, later
save/resume points) has not yet happened; anything it finds should return
to `P2:R8:T3` before being logged here as accepted-for-playtest.

**Balance concerns.** Vyra (160 armor, 35% poison resist) is an intentional
build check, not a bug: `Balance_Baseline_Report.md`'s Phase 1 data and the
`P2:M5` full-run test both show she punishes poison/Assassin-leaning builds
far harder than Thief's armor-pressure playstyle. A tester losing to Vyra
with a poison-heavy build is expected difficulty signal, worth noting in
feedback, not evidence of a broken fight. Beyond that, no Phase-2-specific
numeric tuning pass has run yet; testers may find some Tavern/route fights
feel easier or harder than intended.

**UI rough edges.** `docs/Phase_2_R7_Game_Like_UI_Pass.md`'s "Outstanding
Visual Judgment Calls" section lists 25 first-draft presentation items this
sandboxed environment could never render or click through to verify --
layout fit at 1600x900 (top bar crowding, enemy-panel line count, victory/
loss recap growth, card/tooltip sizing), the gear-comparison tooltip's real
on-screen size, and the combat-playback/comic-book-popup system's timing,
contrast, and sizing (button fill contrast, popup overflow/jitter/pile-up,
outcome-reveal delay, HP-tween feel, enemy HUD sizing/color). None block
`P2:R8`; each is independently tunable via the named file/constant once a
real editor/player session can see it.

**Missing polish.** Full art, animation, sound, and VFX production remains
deferred (see `phase3_ideas.md`'s "Full Art, Animation, And Polish
Production"). The build uses the "Road to Peak Deeps" palette/font/Theme
system from `P2:R7`, not final production art. **Update 2026-07-24:** one
piece of real art has since landed -- `docs/
Phase_2_R12_Gear_Icon_Art_Integration.md` (complete) integrated user-supplied
gear icon art across the shop, reward-choice, inventory, and equipped-slot
gear boxes, replacing plain tier-colored squares. Everything else (character
art, environment art, animation, sound, VFX) remains deferred.

**Deferred Phase 3 items testers may notice.**
- Mage and Crusader appear as disabled class-select cards; only Rogue is
  playable.
- Training Room appears as a disabled title-screen button in this build.
  **Update 2026-07-21:** this is no longer permanent Phase 3+ deferral --
  the user expanded scope to a full Training Room, tracked as
  `docs/Phase_2_R10_Full_Training_Room_Parity.md`. It's just not built yet
  in this export. **Update 2026-07-23:** the full Training Room is now
  built and further polished to Adventure-dashboard look/feel, tracked as
  `docs/Phase_2_R11_Training_Room_UI_Polish.md` (complete) -- still not
  reflected in this specific exported build, since the export predates it.
- Only The Gilded Serpent contract route exists; additional contracts are
  Phase 3+.
- ~~Only two Legendary weapons exist (Wyvern Kriss, Mithril Karambit) in
  this build, and the Knives encounter always offers exactly this same
  fixed pair on every seed~~ -- **Resolved 2026-07-21.** This was never
  Phase 3+ deferral, it was a deliberate `P2:R5` scope decision that the
  user later chose to expand. `docs/Phase_2_R9_Full_Legendary_Item_Parity.md`
  is now fully complete (`P2:R9:T1`-`T8`): all 5 Phase 1 Legendaries
  (Wyvern Kriss, Mithril Karambit, Bandit Blade, Umbral Stiletto, Bejeweled
  Push Dagger) exist with hand-verified effects, Knives offers a seeded
  random choice of 2 of the 5, and the shop's existing low-chance Legendary
  roll (`build_state.gd`'s `CONTRACT_SHOP_LEGENDARY_WEIGHT`) now draws from
  all 5 with a dedupe check against already-owned items. The exported
  Windows build predates this change and still only has the old 2-item
  behavior; the next export/smoke-test pass should confirm the new
  behavior in a real build.
- No broader procedural Contract Run meta-progression, campaign structure,
  or additional-platform export (web, etc.) beyond the Windows desktop
  build exists yet.

## P2:R8:T9 - Add Training Room Lite (Optional) -- Superseded

**Superseded 2026-07-21.** After `P2:R8:T6` smoke testing, the user
deliberately expanded scope to the *full* Phase 1 Training Room (not the
compact Lite version originally scoped here), tracked at
`docs/Phase_2_R10_Full_Training_Room_Parity.md`. This task's original Lite
target is left below for history only; do not build it separately from
`P2:R10`.

Original Training Room Lite target (superseded):

- Enable the title-screen Training Room button.
- Reuse the existing combat dashboard/build resolver/combat resolver.
- Provide a compact practice flow for testing Rogue builds without mutating
  Adventure state.
- Include target and combat-window selection.
- Include visible seed/result/log output if seed work from R5 is available.
- Keep gear editing minimal: use current authored/generated gear systems only
  if they are easy to reuse safely.

Original out-of-scope list (superseded -- `P2:R10` now explicitly includes a
full freeform raw affix editor and the full practice-gold sandbox):

- Full freeform gear editor.
- All future classes/contracts.
- Full Phase 1 practice-gold sandbox.
- Player-facing Training Room target set beyond low-effort reusable targets.
- Any work that delays the Rogue Adventure playtest build.

## P2:R8:T10 - Update Docs

When complete:

- Update this checklist.
- Add playtest build notes to docs.
- Update `docs/Phase_2_Milestones.md`.
- Record feedback follow-up plan.

Completed 2026-07-21. This checklist is fully up to date (`P2:R8:T1`-`T8`
complete, `T9` superseded by `P2:R10`). Feedback follow-up plan: this
session's own hands-on smoke test (seed `123456`) is the only playtest
feedback so far and raised no blockers; the one substantive question it
raised (Legendary variety) became the trigger for the `P2:R9`/`P2:R10` scope
revision rather than a bug fix. Future real playtester feedback should be
triaged the same way this doc's `P2:R8:T8` log describes: blockers back to
whichever milestone owns the affected system, non-blocking notes added to
the known-issues log.

## Implementation Notes

2026-07-19:

- `P2:R8:T1` is complete. The playtest scope is now defined in this document:
  testers should judge the current Rogue Adventure path, build/reward/route
  comprehension, run-state clarity, save/load behavior, and blocking bugs;
  they should not judge final art/animation, full content breadth, broad
  meta-progression, perfect balance, or full Training Room parity.
- Training Room Lite is explicitly preserved as optional `P2:R8:T9` work only
  after the Adventure/export path is stable.
- The next active R8 task is `P2:R8:T2 - Run Full Regression Pass`.

2026-07-19:

- `P2:R8:T2` is complete. Ran the full current headless regression suite:
  all 27 `.gd` files under `project/tests/`, serially, with unique
  `user://logs/r8_t2_<test>.log` paths.
- The first sandboxed Godot run crashed during startup before the first test
  body ran, matching the known local headless startup/log issue already
  documented in earlier milestones. The suite was rerun with escalated
  filesystem access, which is the established workaround for this project.
- All 27 tests passed with exit code `0` after ignoring only the known benign
  ObjectDB/resource cleanup warnings printed at shutdown.
- Coverage notes:
  - `combat_screen_test.gd` drives the real dashboard scene through the
    Tavern, reward/shop, contract offer, secondary subclass, route choice,
    and route reward/shop surfaces.
  - `contract_route_data_test.gd` walks both an easy route
    `Portly Cook -> Lazy Henchman -> Knives -> Vyra` and a harder route
    `Door Guard -> Cloaked Watchmen -> Knives -> Vyra` through authored data.
  - `route_reward_choice_ui_test.gd` verifies generated route rewards, the
    Knives Legendary choice, Legendary equipment, and Vyra becoming selectable
    after Knives.
  - `run_failure_state_test.gd` covers the first-encounter unlimited retry,
    standard Tavern second-failure Adventure restart, contract failure,
    Vyra loss as contract failure, and Vyra victory as contract victory.
  - `run_outcome_presentation_test.gd`, `dashboard_header_test.gd`,
    `combat_playback_test.gd`, and the R7 panel tests cover player-facing
    presentation for failure/victory, header, playback, combat recap, build,
    enemy, reward, shop, and route states.
  - `save_load_test.gd` and `save_load_ui_test.gd` cover save serialization,
    corrupt/future save rejection, Save & Quit, Continue Adventure, discard
    confirmation, Abandon Run, and terminal restart save cleanup.
- Manual rendered Godot editor/player click-through was not performed in this
  environment. The headless scene-tree tests are the project's established
  substitute for interaction coverage, but pixel-level layout, actual font
  rendering, and hands-on play feel remain unverified until the next real
  local player/editor session.
- `P2:R8:T3` is complete for this pass. No blocking production bug was found
  in the automated regression pass. The only recorded issue from T2 is the
  already-known local sandboxed Godot startup crash/workaround. If export
  setup or smoke testing finds a blocker, return to T3 before continuing.
- The next active R8 task is `P2:R8:T4 - Prepare Export Settings`; `P2:R8:T3`
  has no critical bug to fix from this regression pass.

2026-07-19:

- `P2:R8:T4` is complete. Added a tracked Windows Desktop export preset at
  `project/export_presets.cfg` named `Project Bane Windows Playtest`.
- The preset exports all resources to
  `project/export/windows/ProjectBane.exe`, keeps the `.pck` separate from
  the executable, and uses simple `Project Bane` product metadata until a
  final icon/name pass exists.
- `project/.gitignore` now keeps generated `export/` artifacts ignored while
  allowing `export_presets.cfg` to be tracked, so the playtest preset is
  reproducible in future sessions.
- Created the local output folder `project/export/windows/`.
- Godot 4.7 recognized the preset, but export cannot proceed until Windows
  export templates are installed at:
  `C:/Users/tommh/AppData/Roaming/Godot/export_templates/4.7.stable/`.
  Missing files reported by Godot:
  `windows_debug_x86_64.exe` and `windows_release_x86_64.exe`.
- The next active R8 task is `P2:R8:T5 - Export Build`. Before or during T5,
  install the matching Godot 4.7 export templates, then rerun the export.

2026-07-19:

- `P2:R8:T5` is complete. Installed the official Godot 4.7 stable Windows
  x86_64 export templates into
  `C:/Users/tommh/AppData/Roaming/Godot/export_templates/4.7.stable/`.
- Exported the `Project Bane Windows Playtest` preset successfully to
  `project/export/windows/ProjectBane.exe`, with the separate pack at
  `project/export/windows/ProjectBane.pck`.
- Launched the exported executable outside the editor and confirmed Windows
  reported the process still running after startup.
- The next active R8 task is `P2:R8:T6 - Smoke Test Export`.

2026-07-19:

- First hands-on exported-build check found a blocking class-select issue:
  Adventure Mode showed only the coming-soon Mage and Crusader cards, with no
  selectable Rogue card. This was not intended design; Rogue is the only
  playable R8 class.
- Root cause: `class_select.gd` discovered playable classes by scanning
  `res://data/classes/` for filenames ending in `.tres`. In an exported build,
  Godot exposes remapped resources through directory entries such as
  `rogue.tres.remap`, while `load("res://data/classes/rogue.tres")` remains
  the correct load path.
- Fixed `class_select.gd` to treat `.tres.remap` directory entries as their
  original `.tres` resource filenames, added
  `class_select_export_scan_test.gd`, and rebuilt the Windows export.
- `P2:R8:T6 - Smoke Test Export` remains the active task because the full
  exported Adventure path still needs hands-on verification.

2026-07-19:

- Continued the exported-build smoke/fix pass from user playtest findings:
  Shadow's intrinsic was clarified as poison-stack damage over ticks, the title
  screen now exposes an Adventure seed input before class select, and the
  enemy information panel now titles itself with the current target name.
- Removed redundant `Target:` and `Encounter x/4` lines from the enemy panel;
  encounter position is available on the map, and the panel title now carries
  the target identity.
- Verified the Cloaked Watchmen data path was not intentionally blank and
  pinned the live panel state in `enemy_panel_test.gd`: the panel shows
  `Cloaked Watchmen`, HP `525`, Required DPS `20.2`, Armor `160`, Poison
  Resist `40%`, Window `26s`, and the Cursed Gear route reward.
- Corrected retry behavior to match the R8 smoke expectation: Mouthy Drunk,
  the first Tavern fight, has unlimited retries; every other Tavern or
  contract-route fight gets exactly one retry; a second Tavern loss requires
  an Adventure restart, and a second contract-route loss fails the contract.
- Verified post-Tavern Master, Cursed, and Legendary gear access is non-zero
  through authored route rewards: Master appears on guard routes, Cursed on
  Cloaked Watchmen, and Legendary from the Knives choice.
- Focused regressions passed for Shadow poison ticks, retry state, enemy panel
  rendering, contract route data, contract-offer flow, combat screen UI,
  save/load seed handling, and exported class-select resource scanning. The
  initial sandboxed Godot run hit the known local headless startup crash; the
  escalated focused suite passed with exit code `0` and only the known
  shutdown cleanup warnings.
- Rebuilt the Windows export successfully. Current smoke-build artifact:
  `project/export/windows/ProjectBane.exe` (`109019648` bytes) with
  `project/export/windows/ProjectBane.pck` (`664720` bytes), timestamped
  2026-07-19 21:20 local time.

2026-07-21:

- `P2:R8:T6 - Smoke Test Export` requires a real hands-on playthrough of the
  native Windows build (new run through Rogue/subclass, a Tavern fight,
  reward/shop, save/quit/resume, and a later encounter), which this sandboxed
  session cannot perform -- no native Windows GUI automation is available
  here, only browser automation, the same environment limitation recorded
  throughout `P2:R3`-`P2:R7`. Confirmed the existing 2026-07-19 export
  artifact still launches and stays running (`project/export/windows/
  ProjectBane.exe`, `Start-Process`/`Get-Process` check, 5s survival). The
  user chose to do the hands-on T6 pass themselves on their own schedule and
  report findings back, while this session prepared `P2:R8:T7`/`T8` in
  parallel so they don't block on T6's timing. `P2:R8:T6` is marked
  "In progress" rather than "Not started" to reflect the prior session's
  hands-on fixes plus this session's launch confirmation, but the full
  key-path playthrough is still outstanding.
- `P2:R8:T7 - Prepare Playtest Notes` is complete. Added a tester-facing note
  (build identity, current goal, useful feedback, not-in-scope items, issue
  report fields, and a rough-edges heads-up) sourced from the existing
  `P2:R8:T1` scope statement and the `P2:R8` Implementation Notes' bug-fix
  history.
- `P2:R8:T8 - Record Known Issues` is complete. Recorded: no open blocking
  bugs; Vyra's poison/armor build-check difficulty as intentional per
  `Balance_Baseline_Report.md` and the `P2:M5` full-run test; the 25-item
  `P2:R7` "Outstanding Visual Judgment Calls" list as the UI rough-edges
  source; full art/animation/polish production as deferred per
  `phase3_ideas.md`; and the Phase 3+ items testers will visibly encounter
  (disabled Mage/Crusader, disabled Training Room, single contract route, no
  broader meta-progression or additional export platforms).
- No code changed and no tests were run this pass; this was a documentation-
  only pass drawing on already-verified prior findings.

2026-07-21 (continued -- hands-on smoke test result):

- `P2:R8:T6 - Smoke Test Export` is complete. The user ran the full
  Smoke Test Protocol (steps 0-8) against the 2026-07-19 exported build on
  seed `123456`: launch, title screen, class/subclass select, build panels,
  first Tavern fight (unlimited retry), second fight plus shop, save/quit/
  resume, the full Gilded Serpent contract route through Knives and Vyra,
  and both loss-path states. No blockers, crashes, dead ends, save
  corruption, or unreadable text were found at any step.
- One question raised at step 5, investigated and resolved as intended
  behavior, not a bug: across many seeds, only two Legendaries ever appeared
  (a poison-stacking one and a Stab/Heavy-Slash double-trigger one). Read
  `project/data/contract_routes/gilded_serpent/knives.tres`,
  `project/data/gear/wyvern_kriss.tres`,
  `project/data/gear/mithril_karambit.tres`, and
  `project/scripts/systems/gear_generator.gd` to confirm: `knives.tres`
  hardcodes `gear_choice_rewards` to exactly `[Wyvern Kriss, Mithril
  Karambit]` on every seed (not a random draw from a larger pool), and
  `gear_generator.gd` has no Legendary-tier generation logic at all, so
  Legendaries never appear in the shop or in regular rewards. This matches
  the `P2:R5` scope-update note's decision to seed only the Knives pair and
  defer Bandit Blade/Umbral Stiletto/Bejeweled Push Dagger to Phase 3+.
  Logged in the `P2:R8:T8` known-issues list so it isn't re-reported.
- Task 9 (Abandon Run) in the protocol was optional and not explicitly
  reported on; nothing suggests it needs a follow-up, but it hasn't been
  explicitly confirmed by this hands-on pass either.
- With `P2:R8:T1`-`T8` all complete, the only remaining `P2:R8` tasks are
  `P2:R8:T9 - Add Training Room Lite (Optional)` and
  `P2:R8:T10 - Update Docs`.

## Verification Notes

2026-07-19:

- Documentation-only task. No runtime behavior changed.
- No Godot tests were run.

2026-07-19:

- Listed the current test suite: 27 headless scripts under `project/tests/`.
- Initial sandboxed run:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/r8_t2_build_panels_test.log -s res://tests/build_panels_test.gd`
  - Result: startup crash before test execution with `CrashHandlerException:
    Program crashed with signal 11`.
- Reran the suite serially with escalated filesystem access and unique
  `--log-file user://logs/r8_t2_<test>.log` values.
- Passing automated checks:
  - `build_panels_test.gd`
  - `combat_hud_test.gd`
  - `combat_playback_test.gd`
  - `combat_recap_test.gd`
  - `combat_screen_test.gd`
  - `combat_test.gd`
  - `contract_offer_flow_test.gd`
  - `contract_route_data_test.gd`
  - `dashboard_header_test.gd`
  - `deterministic_replay_test.gd`
  - `encounter_reward_test.gd`
  - `enemy_panel_test.gd`
  - `engine_mechanics_test.gd`
  - `gear_generator_test.gd`
  - `inventory_model_test.gd`
  - `legendary_reward_test.gd`
  - `opportunity_strikes_test.gd`
  - `passive_allocator_test.gd`
  - `reward_shop_route_ui_test.gd`
  - `route_reward_choice_ui_test.gd`
  - `run_failure_state_test.gd`
  - `run_outcome_presentation_test.gd`
  - `run_rng_context_test.gd`
  - `run_seed_state_test.gd`
  - `save_load_test.gd`
  - `save_load_ui_test.gd`
  - `shadow_parity_test.gd`
- `inventory_model_test.gd` and `run_failure_state_test.gd` were initially
  misclassified by the wrapper script because expected output text and the
  known shutdown cleanup warnings matched overly broad failure patterns.
  Both printed their explicit `... check: OK` lines and passed when rerun
  with the matcher tightened to actual script/assert/parser/crash failures.
- Confirmed no stale `Godot*` processes were left running after the suite.
- Manual rendered click-through was not performed; native Godot windows are
  not interactable from this sandboxed session. Remaining manual risk is
  visual/pixel/play-feel verification, not a known automated-test failure.

2026-07-19:

- Confirmed Godot version:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --version`
  prints `4.7.stable.official.5b4e0cb0f`.
- Confirmed `project/export_presets.cfg` did not exist before T4.
- Confirmed `project/.gitignore` ignored `.godot/`, `/android/`, and
  `export/`; removed the `export_presets.cfg` ignore so the preset can be
  committed.
- Created `project/export/windows/`; git status confirms the ignored export
  folder is not shown as an untracked artifact.
- Validation command:
  `Godot_v4.7-stable_win64_console.exe --headless --path project --export-release "Project Bane Windows Playtest" "export\windows\ProjectBane.exe"`.
- Sandboxed validation and escalated validation both recognized the preset
  and failed only on missing Windows export templates. The sandboxed run also
  could not save editor settings under AppData, matching the known local
  sandbox limitation, but the escalated rerun removed that as a blocker.

2026-07-19:

- Confirmed Godot version again:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --version`
  prints `4.7.stable.official.5b4e0cb0f`.
- Confirmed the Windows export preset still exists with export path
  `export/windows/ProjectBane.exe`.
- Downloaded the official Godot 4.7 stable export template package from the
  Godot GitHub release asset after the SourceForge mirror repeatedly dropped
  the large transfer.
- Installed these template files:
  - `windows_debug_x86_64.exe`
  - `windows_release_x86_64.exe`
  - `windows_debug_x86_64_console.exe`
  - `windows_release_x86_64_console.exe`
  - `version.txt`
- Export command:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path F:\Data\Claude Projects\Project-Bane\project --export-release "Project Bane Windows Playtest" export\windows\ProjectBane.exe`.
- Export result: exit code `0`. Godot printed only the already-known
  shutdown cleanup warnings about leaked ObjectDB/resource instances.
- Exported files:
  - `project/export/windows/ProjectBane.exe` (`109019648` bytes)
  - `project/export/windows/ProjectBane.pck` (`660108` bytes)
- Launch check:
  `Start-Process -FilePath F:\Data\Claude Projects\Project-Bane\project\export\windows\ProjectBane.exe -PassThru`;
  after 5 seconds, the exported build was still running as process `2468`.

2026-07-19:

- User-reported exported-build blocker: Adventure Mode showed Mage and
  Crusader only, with no Rogue class card, making the build unplayable.
- Added focused regression:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path F:\Data\Claude Projects\Project-Bane\project --log-file user://logs/r8_t5_class_select_export_scan.log -s res://tests/class_select_export_scan_test.gd`.
- Initial sandboxed run crashed during Godot startup with the known local
  signal 11 startup/log issue. Escalated rerun reached the script body.
- First escalated run found a test-only GDScript parse issue from inferred
  `Variant` typing; after adding an explicit `String` annotation, the focused
  regression passed with exit code `0`.
- Rebuilt the Windows export with:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path F:\Data\Claude Projects\Project-Bane\project --export-release "Project Bane Windows Playtest" export\windows\ProjectBane.exe`.
- Re-export result: exit code `0`, with only the known Godot shutdown cleanup
  warnings.

2026-07-21:

- Confirmed the existing exported artifact still exists and still launches:
  `project/export/windows/ProjectBane.exe` (`109019648` bytes) and
  `project/export/windows/ProjectBane.pck` (`5747776` bytes), both dated
  2026-07-19 23:23. `Start-Process`/`$p.Refresh()`/`$p.HasExited` after a 5s
  wait confirmed the process stayed running (pid `65924`), then the process
  was stopped cleanly. This is a launch check only, not a played-through
  smoke test.
- No Godot editor/headless test run was needed for this pass; `P2:R8:T7` and
  `P2:R8:T8` were documentation additions only, sourced from already-recorded
  `P2:R7` and `phase3_ideas.md` content plus the existing `P2:R8`
  Implementation Notes history, not new findings.
