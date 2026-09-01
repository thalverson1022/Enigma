# P4M10: Regression, Export, And Phase 4 Closeout

## Purpose

P4M10 closes Project DawnBringer's Phase 4 generated-contract work by verifying
the current playable loop, preparing an external playtest build, recording the
minimum handoff context for Phase 5, and pushing DawnBringer to GitHub as the
finished Phase 4 mainline.

This is intentionally a closeout milestone. New design work is out of scope
unless it fixes a crash, export blocker, save/load break, unreadable player
flow, or another issue that would prevent useful playtest feedback.

## Status

Complete as of 2026-09-01.

P4M10-T1 is complete as of 2026-09-01. The closeout boundary is locked, the
source branch is confirmed as `phase-4-dawnbringer`, and the intended final
GitHub result remains promoting the finished Phase 4 code to the repository
main branch after regression, export smoke, final docs, commit, and push.

P4M10-T2 is complete as of 2026-09-01. The repo/documentation/export audit is
recorded below, with the dirty tree understood at a closeout level and the
known generated-contract/export risks captured without expanding scope.

P4M10-T3 is complete as of 2026-09-01. The expanded Phase 4 regression pass
and standalone Balance Lab report passed outside the sandbox. No code fixes
were required during T3.

P4M10-T4 is complete as of 2026-09-01. The player-facing smoke pass was run as
a focused headless/scripted adjunct in this environment, with manual inspection
of the title/menu and smoke coverage paths. It found and fixed Practice Room
seed/layout regressions plus stale authored-route test expectations. Exported
runtime launch smoke was completed in T5.

P4M10-T5 is complete as of 2026-09-01. The Windows playtest export candidate
was produced at `project/export/windows/DawnBringer.exe`, its sibling `.pck`
was produced, the exported runtime launched headless with exit code 0, and the
runtime archetype library export risk was resolved by bundling the archetype
JSON under `project/data/runtime_monster_generator/`.

P4M10-T6 is complete as of 2026-09-01. The release blocker pass found no
remaining crash, stuck-state, save/load corruption, export packaging, missing
critical asset, unreadable route-map, or player-facing debug leak blocker. No
code fixes were required during T6.

P4M10-T7 is complete as of 2026-09-01. The lean Phase 5 handoff document now
exists at `docs/P5_Minimum_Handoff_From_Phase_4.md`, covering the current
playable flow, generated-contract ownership, provisional balance/gear caveats,
Phase 5 gear priorities, deferred systems, key files/tests, verification
results, and the Windows playtest export artifact.

P4M10-T8 is complete as of 2026-09-01. Final closeout documentation is synced
across this doc, `docs/P4_DawnBringer_Overview.md`,
`docs/P4_DawnBringer_Onboarding_Context.md`, and
`docs/P5_Minimum_Handoff_From_Phase_4.md`. Phase 4 is functionally complete
for closeout purposes.

P4M10-T9 is complete as of 2026-09-01. The final closeout content commit is
`0bfa140bb672e593852d25a93bd65bdcc43f3735` (`Complete Phase 4 DawnBringer
closeout`). It was pushed to `origin/phase-4-dawnbringer`, and GitHub `main`
was promoted by direct push from `phase-4-dawnbringer` to `main` because no
remote `main` branch was advertised during the pre-promotion branch-head check.

## Milestone Goal

Make the current Phase 4 build stable enough for external playtesting,
documented for the next phase, committed, pushed to GitHub, and promoted so
DawnBringer becomes the main branch of the code.

Balance is not a closeout goal. The current balance can remain rough because
Phase 5 is expected to redesign gear heavily before playtesting, and the later
skill-tree overhaul will reset major build-balance assumptions again.

## Scope Lock

In scope:

- Regression fixes.
- Export/build fixes.
- Save/load fixes.
- Crash and stuck-state fixes.
- Player-facing UI issues that block readable playtest feedback.
- Missing or broken exported assets.
- Documentation, handoff notes, final commit, push, and branch promotion.

Out of scope:

- Broad balance tuning.
- Gear redesign.
- Skill-tree redesign.
- New route-node systems.
- New route-local resources or economy systems.
- New monster mechanics, unless required to fix a blocking regression.
- Production art, audio, or content expansion beyond blocker fixes.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M10-T1: Closeout Scope And Branch Plan | Complete | Lock the closeout rules, final branch target, and GitHub promotion path. | This doc records the no-new-design boundary, current source branch, intended main branch result, and whether promotion happens by PR/merge or direct branch update. |
| P4M10-T2: Repo And Documentation Audit | Complete | Confirm the current P4 state before regression/export work. | Dirty tree is understood, milestone docs agree on P4M10, export preset/state is checked, and known generated-contract gaps are recorded without expanding scope. |
| P4M10-T3: Full Phase 4 Regression Pass | Complete | Prove the generated-contract Adventure loop and supporting tools still work. | Focused Godot regression suites and Balance Lab run successfully, or any failures are fixed or documented as non-blocking runner noise. |
| P4M10-T4: Manual Playtest Smoke Pass | Complete | Verify the player-facing loop feels coherent outside unit tests. | A fresh Adventure reaches Ghit's generated-contract offers, completes generated route/combat/reward/shop/boss flow, covers save/load, failure/restart, overlays, Monster Manual/checklist, and Practice Room sanity. |
| P4M10-T5: Export Build Candidate | Complete | Produce the external playtest build from the current player-facing Adventure path. | Export preset is confirmed or updated, a build artifact is produced, and exported build launch/smoke behavior is recorded. |
| P4M10-T6: Release Blocker Fix Pass | Complete | Fix only issues that would make the playtest invalid or noisy. | Crashes, stuck states, broken exports, save/load corruption, unreadable route maps, missing critical assets, and player-facing debug leaks are resolved or explicitly accepted. |
| P4M10-T7: Phase 5 Minimum Handoff Docs | Complete | Give the next phase enough context without dragging full P4 history forward. | A lean Phase 5 handoff document records current playable flow, known rough balance, gear-redesign priorities, deferred systems, verification commands, and key files. |
| P4M10-T8: Final Closeout Docs | Complete | Mark Phase 4 functionally complete in the living project docs before final GitHub closeout. | This doc, overview, onboarding context, and handoff docs record verification results, export artifact, known caveats, T9 boundary, and Phase 5 entry point. |
| P4M10-T9: Commit, Push, And Promote Main | Complete | Finish DawnBringer on GitHub. | Final closeout commit is created, pushed to GitHub, and DawnBringer is promoted so the finished Phase 4 code is the repository main branch. |

## P4M10-T2 Repo And Documentation Audit

Status: Complete on 2026-09-01.

Branch and remotes:

- Current branch is `phase-4-dawnbringer`, tracking
  `origin/phase-4-dawnbringer`.
- `origin` points to `https://github.com/thalverson1022/DawnBringer.git`.
- `upstream` points to `https://github.com/thalverson1022/Bane.git` as a
  historical fetch-only reference; push is disabled.

Dirty tree summary:

- `git status --porcelain` reported 120 changed entries: 74 modified, 5
  deleted, 41 untracked, and no renames.
- The dirty tree is not just T1/T2 documentation. It includes P4M9 closeout
  docs, P4M10 docs, Rogue/Thief/Bladedancer data, generated-route/combat/UI
  scripts, Balance Lab reports, tests, new audio, new enemy art, new skill and
  subclass icons, Monster Manual UI, Hold/Steal resources, and Bladedancer/Thief
  talent resources.
- The five deleted Thief talent files now have matching untracked Bladedancer
  replacements under `project/data/talents/bladedancer/`. Current references
  found by static search point to the Bladedancer paths.
- `docs/~$fensive mechanics.docx` is an untracked temporary Word lock file and
  should not be included in the final closeout commit.
- Git reports CRLF-to-LF normalization warnings for many touched `.gd`, `.tres`,
  and test files. Treat this as commit-review noise to inspect during final
  staging, not a design issue.

Documentation agreement:

- `docs/P4M9_Contract_Shape_And_Map_Presentation.md` records P4M9 complete and
  hands regression/export/closeout to P4M10.
- `docs/P4_DawnBringer_Overview.md` records P4M0-P4M9 complete, P4M10 active,
  and T1/T2 complete.
- `docs/P4_DawnBringer_Onboarding_Context.md` records P4M10 in progress with
  T1/T2 complete and points new conversations at this P4M10 closeout doc.
- The current player-facing Adventure flow is consistently recorded as Tavern
  into Ghit's generated-contract materials pitch and three generated biome
  offers, with the authored Vyra/Gilded Serpent path kept in data/regression
  but temporarily skipped by the player-facing path.

Export preset/state:

- `project/export_presets.cfg` exists.
- Preset 0 is `DawnBringer Windows Playtest`, platform `Windows Desktop`,
  runnable, `export_filter="all_resources"`, output
  `export/windows/DawnBringer.exe`.
- Preset 1 is `DawnBringer Web Itch`, platform `Web`, runnable,
  `export_filter="all_resources"`, output `export/web/itch/index.html`.
- No export artifacts currently exist at either configured output path. T5 must
  create and smoke-test the build artifact.

Static resource audit:

- New closeout resources referenced by code/data were present in the working
  tree for Hold, Steal, Bladedancer, Monster Manual, hideout map frames,
  footsteps audio, and the new forest/graveyard/keep/ruins enemy art paths.
- Static `res://` scanning also found expected intentionally missing test
  fixtures and placeholder paths used by negative-path tests.
- Release blocker candidate: `RuntimeArchetypeLibraryLoader` first looks for
  `res://data/runtime_monster_generator/dawnbringer_archetypes_v1.json`, but
  no matching file exists under `project/data`. Local/editor runs can fall back
  to `res://../tools/monster-lab/Monster_Libraries/dawnbringer_archetypes_v1.json`,
  which exists, but that external fallback is suspicious for exported builds.
  T3 should include the runtime archetype loader/generator coverage, and T5/T6
  should either prove the export can load the library or move/copy the library
  into exported project resources.

Known closeout gaps from audit:

- No regression tests were run during T2; T3 owns execution.
- No manual smoke pass was run during T2; T4 owns player-facing verification.
- No export artifact exists yet; T5 owns export production and launch smoke.
- The dirty tree must be reviewed carefully during T8/T9 staging so temporary
  files and generated-only noise are not committed accidentally.

## Regression Plan

Run the full closeout suite around the current external playtest path:

- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_contract_outcome_test.gd`
- `res://tests/p4m8_adventure_lifecycle_regression_test.gd`
- `res://tests/run_failure_state_test.gd`
- `res://tests/contract_offer_flow_test.gd`
- `res://tests/contract_test_entry_test.gd`
- `res://tests/dashboard_header_test.gd`
- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_fight_setup_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/hold_skill_test.gd`
- `res://tests/generated_boss_checklist_test.gd`
- `res://tests/monster_manual_overlay_test.gd`
- `res://tests/thief_subclass_test.gd`
- `res://tests/combat_playback_test.gd`
- `res://tests/balance_lab_test.gd`

T2 audit additions for changed systems and export risk:

- `res://tests/runtime_archetype_library_loader_test.gd`
- `res://tests/runtime_monster_generator_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/build_panels_test.gd`
- `res://tests/passive_allocator_test.gd`
- `res://tests/opportunity_strikes_test.gd`
- `res://tests/combat_hud_test.gd`
- `res://tests/combat_screen_test.gd`
- `res://tests/save_load_test.gd`
- `res://tests/save_load_ui_test.gd`
- `res://tests/attack_sfx_audio_test.gd`
- `res://tests/biome_contract_audio_test.gd`
- `res://tests/menu_rain_audio_test.gd`

Broaden further only if T3 failures or T4/T5 smoke findings point to a
specific closeout risk.

## P4M10-T3 Full Phase 4 Regression Pass

Status: Complete on 2026-09-01.

Runner note:

- The first sandboxed Godot attempt crashed before script execution on the
  known `user://logs/godot2026-09-01T11.52.39.log` startup issue. The same
  suite was rerun outside the sandbox, which matches recent milestone
  verification practice for this project.
- Known non-blocking ObjectDB/RID/resource cleanup warnings appeared at process
  exit. All listed test scripts returned exit code 0 outside the sandbox.

Godot scripted tests passed:

- `res://tests/generated_route_matrix_test.gd`
- `res://tests/generated_route_inspector_test.gd`
- `res://tests/generated_route_ui_preview_test.gd`
- `res://tests/map_overlay_route_preview_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/generated_contract_outcome_test.gd`
- `res://tests/p4m8_adventure_lifecycle_regression_test.gd`
- `res://tests/run_failure_state_test.gd`
- `res://tests/contract_offer_flow_test.gd`
- `res://tests/contract_test_entry_test.gd`
- `res://tests/dashboard_header_test.gd`
- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_fight_setup_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/hold_skill_test.gd`
- `res://tests/generated_boss_checklist_test.gd`
- `res://tests/monster_manual_overlay_test.gd`
- `res://tests/thief_subclass_test.gd`
- `res://tests/combat_playback_test.gd`
- `res://tests/balance_lab_test.gd`
- `res://tests/runtime_archetype_library_loader_test.gd`
- `res://tests/runtime_monster_generator_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/build_panels_test.gd`
- `res://tests/passive_allocator_test.gd`
- `res://tests/opportunity_strikes_test.gd`
- `res://tests/combat_hud_test.gd`
- `res://tests/combat_screen_test.gd`
- `res://tests/save_load_test.gd`
- `res://tests/save_load_ui_test.gd`
- `res://tests/attack_sfx_audio_test.gd`
- `res://tests/biome_contract_audio_test.gd`
- `res://tests/menu_rain_audio_test.gd`

Standalone Balance Lab passed:

- Command:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://scripts/tools/run_balance_suite.gd`
- Output path:
  `project/reports/balance/latest`
- Status: `pass`
- Scenarios: 17
- Mechanics: 44
- Seeds: 2600
- Checks: 61 pass, 0 warn, 0 fail

T3 outcome:

- No crashes, stuck states, save/load breaks, generated-contract failures,
  missing-asset test failures, or player-facing debug leaks were found by the
  automated regression pass.
- The T2 runtime archetype library export concern was still open at this point
  because editor/headless tests can still use the external `tools/monster-lab`
  fallback; exported build smoke must prove or fix bundled runtime library
  availability. T5 later resolved this by adding the library under
  `project/data/runtime_monster_generator/` and confirming it was packed into
  the Windows export `.pck`.

## Manual Smoke Checklist

- Start a fresh Adventure from the title menu.
- Confirm Contract Test is hidden from the player-facing title menu.
- Select Rogue and the intended playtest subclass path.
- Reach Tavern, then Ghit's generated-contract materials pitch.
- Inspect three generated biome contract offers.
- Accept a generated contract and preview the route map.
- Choose route nodes through normal, Captain, elite, and boss content where
  available.
- Complete combat, claim rewards, visit the between-contract shop, and continue
  to the next generated contract.
- Save/load from offer, map, combat, reward, and shop states.
- Trigger failure/restart behavior.
- Confirm Monster Manual, boss checklist, overlays, Hold, Steal/Thief clarity,
  and Practice Room sanity.
- Confirm all-bosses victory behavior still resolves cleanly.

## P4M10-T4 Manual Playtest Smoke Pass

Status: Complete on 2026-09-01.

Environment note:

- This pass used focused Godot headless/scripted smoke checks plus direct
  source/UI inspection because the current tool context does not provide a
  true mouse-driven PlayGodot session or visual screen capture. T5 must still
  launch and smoke-test the exported build artifact.
- Known non-blocking ObjectDB/RID/resource cleanup warnings appeared at
  process exit. All listed smoke and adjunct regression scripts returned exit
  code 0 outside the sandbox after fixes.

Smoke fixes made during T4:

- Restored Practice Room fight seed controls by adding `FightSeedSpin` and
  wiring `_on_fight_seed_changed()` to `TrainingRoomState.fight_seed`.
- Reordered and compacted the Practice Room right column so the gear editor
  card remains visible in the initial 1600x900 smoke viewport.
- Updated stale smoke expectations for the current 64x64 generated contract
  offer icon size.
- Updated the authored-route Vyra smoke lookup to use `route_node_id` metadata
  and child label text instead of an obsolete fixed button index/text-only
  assumption.
- Normalized authored multiline route story assertions so CRLF resource text
  does not fail an otherwise correct UI state.

T4 smoke checks passed:

- `res://tests/training_room_entry_test.gd`
- `res://tests/training_room_fight_test.gd`
- `res://tests/training_room_gear_editor_test.gd`
- `res://tests/training_room_fight_setup_test.gd`
- `res://tests/run_outcome_presentation_test.gd`
- `res://tests/contract_offer_coexistence_test.gd`
- `res://tests/contract_offer_source_test.gd`
- `res://tests/route_reward_choice_ui_test.gd`
- `res://tests/reward_shop_route_ui_test.gd`
- `res://tests/combat_biome_background_test.gd`
- `res://tests/overlay_centering_test.gd`
- `res://tests/class_select_export_scan_test.gd`

Nearby regression checks rerun after T4 fixes:

- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/combat_screen_test.gd`
- `res://tests/contract_offer_flow_test.gd`

T4 outcome:

- Title/menu inspection confirms the player-facing menu exposes New Adventure,
  Resume Adventure, Practice Room, and Exit, while Contract Test remains hidden
  from the menu and available only as a diagnostic signal/test path.
- Scripted smoke coverage confirms Practice Room entry/fight/gear setup,
  generated contract offer coexistence/source behavior, generated reward/shop
  route presentation, authored Vyra regression behavior, combat biome
  background selection, overlay centering, class-select export remap behavior,
  failure/restart presentation, contract victory, and all-bosses victory.
- No new closeout blockers were found after the T4 fixes.
- The T2 runtime archetype library export concern was still open at this point
  because T4 did not produce or launch an exported build. T5 later resolved it
  for the Windows export candidate.

## P4M10-T5 Export Build Candidate

Status: Complete on 2026-09-01.

Export preset check:

- Preset 0 remains `DawnBringer Windows Playtest`, platform `Windows Desktop`,
  runnable, `export_filter="all_resources"`, output
  `export/windows/DawnBringer.exe`.
- Preset 1 remains `DawnBringer Web Itch`, platform `Web`, runnable,
  `export_filter="all_resources"`, output `export/web/itch/index.html`.
- T5 produced the Windows playtest candidate first. The Web/itch export was
  not produced during T5 because the closeout build candidate target is the
  Windows playtest artifact.

Export-risk fix:

- `RuntimeArchetypeLibraryLoader` already checks
  `res://data/runtime_monster_generator/dawnbringer_archetypes_v1.json` before
  the editor-only `res://../tools/monster-lab/...` fallback.
- T5 copied the checked-in Monster Lab archetype catalog into
  `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json` so
  `export_filter="all_resources"` can bundle it with the shipped project.
- Direct binary scan of `project/export/windows/DawnBringer.pck` found
  `data/runtime_monster_generator/dawnbringer_archetypes_v1.json`,
  `monster_lab_archetype_catalog.v1`, and P4M8 archetype IDs including
  `aegis` and `riftbound`.

Focused pre-export checks passed outside the sandbox:

- `res://tests/runtime_archetype_library_loader_test.gd`
- `res://tests/runtime_monster_generator_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/generated_contract_outcome_test.gd`
- `res://tests/contract_offer_flow_test.gd`

Windows export command:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project --export-release "DawnBringer Windows Playtest" "export/windows/DawnBringer.exe"`

Build artifacts:

- `project/export/windows/DawnBringer.exe`
  - Size: 109,019,648 bytes.
  - SHA-256:
    `FA60A1A4761CC51B18900B4D0EB18FF8C191D0A4BECB990C6B2A47EF326E0AFF`
- `project/export/windows/DawnBringer.pck`
  - Size: 172,702,100 bytes.

Export launch smoke:

- Command:
  `project/export/windows/DawnBringer.exe --headless --quit-after 3 --verbose`
- Result: exit code 0.
- Startup output showed the exported runtime loading shipped resources from the
  `.pck`, including remapped UI theme resources and font assets.
- A separate attempt to run editor-style `--script res://tests/...` checks
  through the exported executable started the exported runtime cleanly, but did
  not execute project test scripts the same way the editor binary does. Treat
  editor-scripted smoke and exported-runtime launch smoke as separate checks.

Export warnings/notes:

- The export step reimported `scenario_summary.csv` and emitted the existing
  non-blocking warning: `Locale 'notes' does not contain any translation. This
  locale will be ignored.`
- Known non-blocking ObjectDB/resource cleanup warnings continue to appear on
  editor/headless scripted tests.
- No export failure, launch failure, missing critical asset error, or runtime
  archetype library packaging blocker was found in T5.

## P4M10-T6 Release Blocker Fix Pass

Status: Complete on 2026-09-01.

Blocker review:

- The T5 Windows export candidate still exists at
  `project/export/windows/DawnBringer.exe`, with sibling
  `project/export/windows/DawnBringer.pck`.
- The runtime archetype library export risk is resolved for the Windows
  candidate. `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json`
  exists and the T5 `.pck` scan confirmed the file, expected schema, and P4M8
  archetype IDs are bundled.
- `docs/~$fensive mechanics.docx` remains an untracked temporary Word lock
  file and must stay excluded from final staging.
- Static debug-leak review found no Contract Test title-menu exposure. The
  combat-stage `DebugGridOverlay` remains default-hidden, with Adventure and
  Practice Room tests asserting the grid is not visible in player-facing paths.

Blocker-focused checks passed outside the sandbox:

- `res://tests/runtime_archetype_library_loader_test.gd`
- `res://tests/runtime_monster_generator_test.gd`
- `res://tests/contract_route_generator_test.gd`
- `res://tests/generated_contract_save_load_test.gd`
- `res://tests/save_load_test.gd`
- `res://tests/save_load_ui_test.gd`
- `res://tests/generated_contract_outcome_test.gd`
- `res://tests/contract_offer_flow_test.gd`
- `res://tests/run_failure_state_test.gd`
- `res://tests/run_outcome_presentation_test.gd`
- `res://tests/training_room_entry_test.gd`
- `res://tests/training_room_fight_test.gd`
- `res://tests/training_room_gear_editor_test.gd`
- `res://tests/training_room_fight_setup_test.gd`
- `res://tests/training_room_build_test.gd`
- `res://tests/training_room_combat_view_test.gd`
- `res://tests/attack_sfx_audio_test.gd`
- `res://tests/biome_contract_audio_test.gd`
- `res://tests/menu_rain_audio_test.gd`
- `res://tests/combat_biome_background_test.gd`
- `res://tests/overlay_centering_test.gd`
- `res://tests/class_select_export_scan_test.gd`
- `res://tests/contract_offer_coexistence_test.gd`
- `res://tests/contract_offer_source_test.gd`
- `res://tests/reward_shop_route_ui_test.gd`
- `res://tests/route_reward_choice_ui_test.gd`
- `res://tests/monster_manual_overlay_test.gd`
- `res://tests/generated_boss_checklist_test.gd`
- `res://tests/combat_screen_test.gd`
- `res://tests/combat_hud_test.gd`

Export-runtime check:

- `project/export/windows/DawnBringer.exe --headless --quit-after 3 --verbose`
  returned exit code 0 during T6.
- Startup output showed the exported runtime loading shipped `.pck` resources,
  including the remapped UI theme and font assets.

Accepted non-blockers:

- Godot editor/headless scripts continue to emit ObjectDB/RID/resource cleanup
  warnings at process exit even when tests return exit code 0.
- `save_load_test.gd` intentionally exercises a corrupt-save path and logs a
  JSON parse error before reporting `Save/load round trip check: OK`.
- The T5 export emitted the existing non-blocking CSV translation warning for
  locale `notes`.
- The optional Web/itch export was not produced during T5/T6.
- Balance remains provisional by scope lock.

T6 outcome:

- No crash, stuck state, save/load corruption, export failure, missing critical
  asset, unreadable route map, or player-facing debug leak remained after the
  T6 pass.
- No code fixes were required during T6.
- P4M10 proceeded to T7, the Phase 5 minimum handoff docs.

## Export Direction

Target build:

- Platform: Godot export target selected during T5 after checking
  `project/export_presets.cfg`.
- Source path: `project/project.godot`.
- Godot executable:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`.
- Build artifact: record exact output path and size in this doc during T5.
- Smoke test: launch the exported build, verify title/menu entry, generated
  contract offer flow, one generated combat, reward/shop transition, and no
  fresh blocking console/export errors.

## GitHub Closeout Direction

Current working branch:

- `phase-4-dawnbringer`
- Confirmed locally on 2026-09-01 with tracking branch
  `origin/phase-4-dawnbringer`.

Remotes:

- `origin`: `https://github.com/thalverson1022/DawnBringer.git`
- `upstream`: `https://github.com/thalverson1022/Bane.git` fetch-only
  historical reference; push is disabled.

Final GitHub result:

- Phase 4 closeout content commit is pushed:
  `0bfa140bb672e593852d25a93bd65bdcc43f3735`.
- DawnBringer `main` has been created/promoted from `phase-4-dawnbringer`.
- Branch-promotion method: direct push
  `git push origin phase-4-dawnbringer:main`, used after confirming the remote
  advertised `phase-4-dawnbringer` and did not advertise `main`.

Preferred promotion path:

- Push `phase-4-dawnbringer`.
- Promote through GitHub's normal branch/PR/default-branch workflow if
  available.
- If the repository already treats `phase-4-dawnbringer` as the source of
  truth, update the GitHub main branch only after the closeout commit and
  export smoke pass are complete.

Promotion lock:

- Do not promote `main` before the closeout regression pass, manual smoke pass,
  export build candidate, export smoke test, Phase 5 minimum handoff, final
  closeout docs, and final closeout commit are complete.
- Prefer a PR/merge/default-branch update when available so GitHub records the
  promotion clearly. Use a direct branch update only if repo management already
  treats `phase-4-dawnbringer` as the authoritative Phase 4 branch and the
  final closeout commit has already been pushed.

## Phase 5 Handoff Requirements

Status: Complete on 2026-09-01.

Create a lean Phase 5 handoff document that includes only:

- Current playable flow.
- What Phase 4 generated contracts now own.
- What is intentionally rough or provisional.
- Gear-redesign priorities for the next phase.
- Systems explicitly deferred out of P4.
- Key files and tests.
- Known non-blocking Godot runner/export output.
- The final P4 closeout commit and build artifact.

Do not copy full milestone history into the Phase 5 handoff. Link to the P4
overview and P4M10 closeout doc for deeper history.

T7 outcome:

- Added `docs/P5_Minimum_Handoff_From_Phase_4.md`.
- The handoff records the current playable flow, Phase 4 generated-contract
  ownership, provisional/rough areas, Phase 5 gear priorities, deferred
  systems, key files, key verification, and the Windows export artifact.
- P4M10 proceeded to T8, final closeout docs across the living project docs.

## P4M10-T8 Final Closeout Docs

Status: Complete on 2026-09-01.

Final documentation sync:

- `docs/P4M10_Regression_Export_And_Phase_4_Closeout.md` recorded T1-T8
  complete, accepted caveats, the Windows export artifact, the Phase 5 handoff
  document, and the T9 closeout boundary.
- `docs/P4_DawnBringer_Overview.md` recorded Phase 4 as functionally complete
  through verification/export/handoff, while keeping P4M10 open until T9
  commit/push/promotion.
- `docs/P4_DawnBringer_Onboarding_Context.md` recorded T1-T8 complete, pointed
  to `docs/P5_Minimum_Handoff_From_Phase_4.md`, and identified T9 as the final
  P4M10 task.
- `docs/P5_Minimum_Handoff_From_Phase_4.md` now serves as the Phase 5 entry
  point for gear redesign context.

Closeout evidence recorded:

- T3 expanded scripted regression and standalone Balance Lab passed outside
  the sandbox.
- T4 focused player-facing smoke passed outside the sandbox after Practice
  Room seed/layout and stale smoke-test expectation fixes.
- T5 produced the Windows playtest export candidate and bundled the runtime
  archetype catalog into project resources.
- T6 release blocker verification found no remaining closeout blockers.
- T7 created the lean Phase 5 handoff document.

Accepted caveats carried forward:

- Balance remains provisional and should be revisited after the Phase 5 gear
  redesign.
- Skill trees are not final and are expected to receive a later overhaul.
- The authored Vyra/Gilded Serpent contract remains in data/regression but is
  temporarily skipped by the player-facing Adventure path.
- Contract Test remains hidden from the title menu and available only as a
  diagnostic/test path.
- Optional Web/itch export has not been produced.
- Known Godot editor/headless ObjectDB/RID/resource cleanup warnings, the
  intentional corrupt-save parse output, and the CSV locale warning remain
  accepted non-blockers.
- `docs/~$fensive mechanics.docx` remains an untracked temporary Word lock
  file and must stay excluded from final staging.

T8 outcome:

- Phase 4 is functionally complete for closeout purposes.
- T9 was responsible for final staging review, commit, push, GitHub
  main-branch promotion, and recording the final commit hash/promotion method.

## P4M10-T9 Commit, Push, And Promote Main

Status: Complete on 2026-09-01.

Final staging review:

- Staged Phase 4 docs, project source, tests, reports, runtime archetype data,
  and required assets.
- Excluded `docs/~$fensive mechanics.docx`, the untracked temporary Word lock
  file.
- Left ignored export artifacts under `project/export/` out of Git; their path,
  size, and SHA-256 remain recorded in T5 and the Phase 5 handoff.

Final commit and push:

- Final closeout content commit:
  `0bfa140bb672e593852d25a93bd65bdcc43f3735`.
- Commit message: `Complete Phase 4 DawnBringer closeout`.
- Pushed `phase-4-dawnbringer` to `origin`.

Main promotion:

- Pre-promotion remote branch check showed
  `phase-4-dawnbringer` at
  `0bfa140bb672e593852d25a93bd65bdcc43f3735` and did not advertise a remote
  `main` branch.
- Promoted by direct branch push:
  `git push origin phase-4-dawnbringer:main`.
- GitHub created `origin/main` from the same final closeout content commit.

T9 outcome:

- P4M10 is complete.
- Phase 4 is closed for DawnBringer.
- DawnBringer `main` now contains the finished Phase 4 code.

## Known Closeout Caveats

- Balance is intentionally provisional.
- Gear will be redesigned in Phase 5 before external playtesting.
- Skill trees will receive a later major overhaul, so current build balance is
  not a final tuning target.
- The authored Vyra/Gilded Serpent contract remains in data and regression
  coverage but is temporarily skipped by the player-facing Adventure path.
- Contract Test remains available as a diagnostic/test path but hidden from the
  title menu.
- Non-combat route nodes, route-local resources, consumables, map shop nodes,
  mystic upgrades, crafting/transmutation, boss bargains, scout/reveal nodes,
  and hidden events remain deferred.
- Optional Web/itch export has not been produced; the current playtest build
  candidate is Windows.
- `docs/~$fensive mechanics.docx` is an untracked temporary Word lock file and
  must not be staged for T9.

## Definition Of Done

- Closeout scope is locked and followed.
- Required regression checks pass or have documented non-blocking runner notes.
- Manual playtest smoke pass confirms the external player path is coherent.
- Export build candidate is produced and smoke tested.
- Release blockers found during closeout are fixed or explicitly accepted.
- Phase 5 minimum handoff document exists.
- Overview and onboarding docs identify Phase 4 as complete and point to the
  Phase 5 handoff.
- Final closeout commit is created.
- Final closeout commit is pushed to GitHub.
- DawnBringer is promoted so the finished Phase 4 code is the repository main
  branch.
