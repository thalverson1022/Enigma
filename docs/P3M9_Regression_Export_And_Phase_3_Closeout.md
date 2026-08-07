# Phase 3 Milestone 9: Regression, Export, And Phase 3 Closeout

## Purpose

Milestone 9 closes Project CrystalMaiden by verifying the current playable
build, preparing a web export for itch.io playtesting, committing and pushing
the Phase 3 state, and recording the handoff into the next phase.

This is intentionally a lightweight closeout checklist rather than a broad
implementation milestone. New features are out of scope unless they are needed
to fix a regression or export blocker found during verification.

## Status

Complete locally.

## Milestone Goal

Make the current Phase 3 build stable, documented, pushed to GitHub, and ready
for an itch.io browser playtest.

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Define closeout scope | Complete | M9 is a regression/export/hosting closeout, not a new feature milestone. |
| 1. Audit repo and documentation state | Complete | Confirmed local M7/M8/M9 delta, added the M9 doc, and added a CrystalMaiden Web export preset. |
| 2. Run focused regression and Balance Lab checks | Complete | Focused regression passed; Balance Lab reported 19 pass, 0 warn, 0 fail. |
| 3. Prepare web export for itch.io | Complete | Installed local Godot 4.7 export templates, exported Web build, and packaged the itch.io zip. |
| 4. Smoke test exported build | Complete | Local browser smoke test loaded `Project CrystalMaiden`, found the Godot canvas, and reported no fresh console errors. |
| 5. Commit and push Phase 3 closeout | Complete locally | Closeout commit created locally; push to GitHub follows this final doc update. |
| 6. Record closeout and itch.io handoff | Complete | Overview/onboarding handoff and itch.io upload notes are updated with final results. |

## Definition Of Done

- Required focused regression checks exit 0.
- Balance Lab is run as a final confidence pass or explicitly skipped with a
  recorded reason.
- A Godot Web export is produced for itch.io.
- The web export is packaged as a zip suitable for itch.io browser upload.
- The current Phase 3 state is committed and pushed to GitHub.
- Closeout documentation names the tested commit, export artifact, known
  caveats, and recommended itch.io upload settings.

## Verification Plan

Run a focused suite that covers the systems most likely to affect a public
playtest:

- Title, settings, and audio entry points.
- Adventure state flow, class/subclass selection, reward/shop/route UI, and
  save/load presentation.
- Combat screen, playback, HUD, recap, and result presentation.
- Practice Room setup, gear editor, build controls, fight setup, fight
  playback, and combat view.
- Build panel and rotation-cap geometry.
- Balance Lab report generation and report validation.

## Verification Results

Final focused regression, 2026-08-07:

- Passed with exit code 0:
  `settings_menu_layer_test.gd`, `menu_rain_audio_test.gd`,
  `attack_sfx_audio_test.gd`, `class_select_export_scan_test.gd`,
  `combat_screen_test.gd`, `combat_hud_test.gd`, `combat_recap_test.gd`,
  `reward_shop_route_ui_test.gd`, `route_reward_choice_ui_test.gd`,
  `contract_offer_flow_test.gd`, `save_load_ui_test.gd`,
  `run_failure_state_test.gd`, `run_outcome_presentation_test.gd`,
  `build_panels_test.gd`, `rotation_cap_test.gd`,
  `skill_build_geometry_test.gd`, `training_room_entry_test.gd`,
  `training_room_combat_view_test.gd`, `training_room_fight_test.gd`,
  `training_room_fight_setup_test.gd`, `training_room_build_test.gd`,
  and `training_room_gear_editor_test.gd`.
- `combat_playback_test.gd` reproduced the known sandbox autosave-sensitive
  failure when run inside the restricted filesystem, then passed with exit
  code 0 outside the sandbox.
- `export_shadow_probe.gd` could not write its `user://` probe file inside the
  restricted filesystem, then passed with exit code 0 outside the sandbox.
- Export icon fix follow-up checks passed with exit code 0:
  `settings_menu_layer_test.gd`, `combat_screen_test.gd`,
  `reward_shop_route_ui_test.gd`, `route_reward_choice_ui_test.gd`,
  `training_room_entry_test.gd`, `training_room_combat_view_test.gd`, and
  `attack_sfx_audio_test.gd`.
- Balance Lab final pass exited 0 with `19 pass, 0 warn, 0 fail`.
- `balance_lab_test.gd` passed with exit code 0.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.
- These did not prevent the listed checks from exiting 0.

## Export And Hosting Direction

Target export:

- Platform: Godot Web.
- Output folder: `project/export/web/itch`.
- Packaged artifact: `project/export/web/project-crystalmaiden-itch.zip`.
- Intended host: itch.io browser playtest.

Export results:

- Added export preset: `CrystalMaiden Web Itch`.
- Installed local Godot 4.7 export templates from the Phase 2 archive into
  Godot's user template directory on this machine.
- Fixed export-only icon loading issues by loading repeated UI PNGs as
  imported `Texture2D` resources instead of raw image files.
- Web export succeeded after the icon fixes.
- Final zip: `project/export/web/project-crystalmaiden-itch.zip`
  (`63,927,170` bytes).
- Export artifacts remain under `project/export/`, which is intentionally
  ignored by `project/.gitignore`.

Local browser smoke test:

- Served `project/export/web/itch` at `http://127.0.0.1:8791/index.html`.
- Fresh in-app browser tab loaded title `Project CrystalMaiden`.
- Godot canvas was present at `1280x720`.
- Fresh browser console error list was empty after the export icon fixes.

Recommended itch.io project settings after upload:

- Kind of project: HTML.
- Upload: the generated zip.
- Check: `This file will be played in the browser`.
- Viewport dimensions: `1600x900`.
- Enable fullscreen button if available.

## Known Caveats To Watch

- Godot may print Windows root-certificate-store warnings during headless runs.
- Godot may print ObjectDB/RID/resource cleanup warnings at process exit even
  when tests pass.
- Existing image-load export warnings may appear for current UI/logo image
  files if future UI code reintroduces raw `Image.load()` for imported assets.
- Web export requires installed Godot export templates for Godot 4.7.

## Phase 4 Handoff

- Keep deeper mechanics, new contract structure, broad enemy expansion,
  production art direction, and final audio sourcing out of this closeout.
- Use playtest feedback to identify whether the next phase should prioritize
  buildcraft clarity, contract/town-map structure, balance pacing, or
  production presentation.
- Retain Balance Lab as the confidence gate when future changes touch combat
  math, event ordering, build resolution, skill/talent/gear resources, enemy
  data, or balance-relevant data.
