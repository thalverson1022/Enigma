# Phase 3 Milestone 7: Testing Suite And Balance Lab Hardening

## Purpose

Milestone 7 turns the current mechanics testing and balance-analysis work into
a more usable, trustworthy toolchain for future systems and balance work.

This is the single tasking and status document for Milestone 7. It follows the
project hierarchy:

- Phase: 3, Project CrystalMaiden
- Milestone: 7, Testing Suite And Balance Lab Hardening
- Task: milestone-sized work item
- Step: implementation-sized action inside a task

## Status

In Progress.

## Milestone Goal

Make Balance Lab feel like a real CrystalMaiden tool app alongside Shop Lab,
Sprite Lab, and the planned Monster Lab, while also tightening the surrounding
mechanics test suite enough that future combat, gear, monster, and balance
changes can be checked with confidence.

## Design Direction

Balance Lab should move from "generated static report" to "small local balance
app." The first version does not need sliders, scenario editing, monster
selection, or build editing. It should do one important thing well:

1. Open the Balance Lab app.
2. Click `Run Balance`.
3. Run the existing Godot balance suite.
4. Render the latest report in the app.

This app-shell direction gives the project a durable place to add later
interactivity without overbuilding now. Future extensions may include scenario
selection, seed-count controls, Monster Lab handoff, build/gear presets,
threshold editing, and comparison against a previous report.

Balance Lab should remain separate from the playable Godot runtime by default,
matching the current `tools/shop-lab` and `tools/sprite-lab` pattern. The Godot
project remains the source of truth for combat resolution, resources, and the
headless balance runner.

Prioritize:

- A local tool-app workflow that is easy to run repeatedly.
- Clear pass/warn/fail status and concise scenario summaries.
- Report output that helps future balance work rather than only proving the
  script did not crash.
- Deterministic scenarios and explicit seed reporting.
- Test organization and failure messages that make regressions easy to
  diagnose.

Avoid by default:

- Balance changes.
- New combat mechanics.
- New monsters or contracts.
- Broad test-framework rewrites.
- Sliders and scenario editors in the first app version.
- Pulling Balance Lab into the player-facing game UI.

## Current Baseline

Balance Lab currently lives in `project/scripts/tools/balance_lab.gd` and is
run by `project/scripts/tools/run_balance_suite.gd`.

Current behavior:

- Runs authored mechanics checks for important Rogue Legendary/gear behavior.
- Runs six seeded combat scenarios across 200 seeds each.
- Aggregates DPS, total damage, physical damage, poison damage, poison tick
  count, min-cast proc rate, and win rate.
- Marks mechanics checks as `pass` or `fail`.
- Marks scenario threshold misses as `warn`.
- Writes `results.json`, `scenario_summary.csv`, and `index.html` under
  `project/reports/balance/latest`.
- Has a focused smoke test in `project/tests/balance_lab_test.gd`.

Latest observed run:

- `19 pass, 0 warn, 0 fail`.
- Known Godot certificate/resource cleanup warnings appeared at exit but the
  command returned exit code 0.
- The generated HTML and report metadata now use CrystalMaiden Balance Lab
  identity.

## Tasking

| Task | Status | Notes |
|---|---|---|
| 0. Plan and re-scope M7 around Balance Lab as a tool app | Complete | Created this plan, recorded the app-shell direction, and identified the focused M7 task sequence. |
| 1. Create the Balance Lab app shell | Complete | Added `tools/balance-lab` as a local browser tool with a stable dashboard shell and a `Run Balance` button placeholder. |
| 2. Add the local run bridge | Complete | Added a dependency-free Node server that serves the app, runs the Godot balance suite, blocks duplicate active runs, and returns status plus latest report data. |
| 3. Render current Balance Lab output in the app | Complete | Replaced reliance on generated HTML with app-rendered `results.json` views for suite health, scenario summary, mechanics checks, and file links. |
| 4. Clean up Balance Lab report identity and structure | Complete | Updated CrystalMaiden branding, report metadata, status language, and JSON/report shape without changing combat math. |
| 5. Audit and map the current test suite | Complete | Mapped the current Godot test suite by coverage area, focused run set, caveat, and T6 hardening opportunity. |
| 6. Harden critical mechanics tests and failure messages | Complete | Replaced opaque bare assertions in the highest-value mechanics/proc/replay tests with context-rich failure helpers and verified the focused set. |
| 7. Verify repeatability and document the workflow | Complete | Repeated Balance Lab, confirmed deterministic normalized signatures, reran focused tests, checked the bridge status endpoint, and documented the workflow. |
| 8. Verify, document, and close Milestone 7 | Complete | Closed M7 with final verification notes, updated overview/onboarding docs, and deferred deeper Balance Lab interactivity plus Monster Lab handoff. |

## Task Details

### P3:M7:T0 - Plan And Re-Scope M7 Around Balance Lab As A Tool App

Status: Complete.

Goal: turn M7 from a generic testing hardening milestone into a tool-centered
milestone with Balance Lab as the immediate usable output.

Steps:

- P3:M7:T0:S1 - Review the current M7 roadmap entry.
- P3:M7:T0:S2 - Review the current Balance Lab implementation and output.
- P3:M7:T0:S3 - Review the existing `tools/shop-lab` pattern.
- P3:M7:T0:S4 - Record the decision that Balance Lab should become a small
  local app with a `Run Balance` button before adding deeper interactivity.
- P3:M7:T0:S5 - Define the M7 task sequence and documentation handoff.

Expected output:

- Current M7 tasking document.
- Updated Phase 3 overview notes.
- Updated onboarding next-step handoff.

Notes:

- Balance Lab should initially be a run-and-read app, not a full scenario
  editor.
- The app should render the latest JSON report rather than generating a whole
  disposable HTML dashboard on every run.
- The generated `index.html` report can remain temporarily as a compatibility
  artifact until the new app workflow replaces it.

### P3:M7:T1 - Create The Balance Lab App Shell

Status: Complete.

Goal: create a stable browser-tool home for Balance Lab.

Direction:

- Add `tools/balance-lab`.
- Match the project-tool convention used by `tools/shop-lab` and
  `tools/sprite-lab`.
- Use a clear app header, status area, primary `Run Balance` button, summary
  panels, and report tables.
- Keep the first view dense and tool-like rather than marketing-like.

Expected output:

- `tools/balance-lab/README.md`.
- App shell HTML/CSS/JS.
- Clear local run instructions.

Completed output:

- Added `tools/balance-lab/README.md`.
- Added `tools/balance-lab/index.html`, `styles.css`, and `app.js`.
- The shell includes a CrystalMaiden tool header, status area, primary
  `Run Balance` button, summary metrics, suite health panel, scenario summary
  table, mechanics checks table, and latest report file links.
- The `Run Balance` button is intentionally a Task 2 placeholder because static
  browser HTML cannot launch the Godot balance runner directly.

### P3:M7:T2 - Add The Local Run Bridge

Status: Complete.

Goal: allow the Balance Lab app to run the Godot balance suite from a button.

Direction:

- Use a small local server or runner process because static `file://` HTML
  cannot launch Godot directly.
- The server should expose an endpoint that runs
  `project/scripts/tools/run_balance_suite.gd`.
- The endpoint should report running, success, failure, stdout/stderr/log
  output, and the path to the latest report.
- Keep command paths configurable enough for this machine while avoiding broad
  project rewrites.

Expected output:

- A local run command for the app.
- A `Run Balance` button that triggers the current suite.
- Basic error handling when Godot is missing or the suite fails.

Completed output:

- Added `tools/balance-lab/server.js` as a dependency-free local Node bridge.
- Added the local app command:

```powershell
node tools\balance-lab\server.js
```

- The app is served at:

```text
http://127.0.0.1:8787
```

- Added bridge endpoints:
  - `GET /api/status`
  - `POST /api/run-balance`
  - `GET /api/report/results`
  - `GET /api/report/scenario-summary`
  - `GET /api/report/godot-log`
- Wired the `Run Balance` button to `POST /api/run-balance`, status polling,
  run-output display, and latest report summary counts.
- The bridge uses `GODOT_PATH`, `BALANCE_LAB_HOST`, and `BALANCE_LAB_PORT`
  environment variables when overrides are needed.
- The bridge launched the existing Godot balance suite successfully on
  2026-08-05 at 21:52 local time with `19 pass, 0 warn, 0 fail`.

Verification:

- `node --check tools\balance-lab\server.js` passed.
- `node --check tools\balance-lab\app.js` passed.
- `GET /` returned 200.
- `GET /api/status` returned the latest report summary.
- `POST /api/run-balance` launched the Godot suite and completed with exit
  code 0.
- `GET /api/report/results` returned 13 mechanics checks, 6 scenarios, version
  `0.1.0`, and generated timestamp `2026-08-05T21:52:30`.
- `GET /api/report/scenario-summary` returned 200.
- `GET /api/report/godot-log` returned 200.
- Godot printed the known Windows root-certificate-store and ObjectDB/resource
  cleanup warnings while still exiting successfully.

### P3:M7:T3 - Render Current Balance Lab Output In The App

Status: Complete.

Goal: make the app the readable Balance Lab surface.

Direction:

- Read and render `project/reports/balance/latest/results.json`.
- Show suite health counts.
- Show scenario rows with status, mean DPS, p05/p95 DPS, win rate, poison
  contribution, proc rate, seed count, and notes.
- Show mechanics rows with observed, expected, tolerance, and note fields.
- Link to or expose `results.json`, `scenario_summary.csv`, and the run log.

Expected output:

- Current Balance Lab report is readable inside the app after a run.
- The older generated HTML is no longer the main user workflow.

Completed output:

- The app now fetches `GET /api/report/results` after bridge status confirms a
  latest report exists and again after a successful bridge-launched run.
- Suite Health renders pass/warn/fail totals, scenario count, total seed count,
  generated timestamp, and overall pass/warn/fail status.
- Scenario Summary renders scenario labels, monsters, rotations, status, mean
  DPS, p05/p95 DPS, win rate, poison contribution, min-cast proc rate, seed
  count, thresholds, and notes.
- Mechanics Checks renders check labels/ids, status, observed value, expected
  value, tolerance, and note.
- Added formatting helpers for status badges, percentages, numeric precision,
  missing-value fallbacks, threshold display, list display, and HTML escaping.
- Added compact status-badge and numeric-table styling.
- Updated `tools/balance-lab/README.md` with the report views.

Verification:

- `node --check tools\balance-lab\app.js` passed.
- `node --check tools\balance-lab\server.js` passed.
- `GET /api/status` returned `19 pass, 0 warn, 0 fail`, 6 scenarios, and 1200
  total seeds.
- `GET /api/report/results` returned 13 mechanics checks and 6 scenarios.
- A bridge-launched run completed with exit code 0 and refreshed the report to
  `2026-08-05T21:56:42`.
- Browser smoke check at `http://127.0.0.1:8787` rendered 6 scenario rows, 13
  mechanics rows, `19` pass, `0` warn, `0` fail, and no browser console errors.

### P3:M7:T4 - Clean Up Balance Lab Report Identity And Structure

Status: Complete.

Goal: make the generated data and report metadata fit CrystalMaiden and future
tooling.

Direction:

- Replace stale `Project Bane Balance Lab` labels.
- Include report version, generated timestamp, scenario count, seed count, and
  source command metadata.
- Clarify `pass`, `warn`, and `fail` semantics.
- Keep scenario threshold warnings as designer-review signals unless a true
  resource or mechanics failure occurs.

Expected output:

- Cleaner report metadata.
- Better future compatibility for app rendering and comparison views.

Completed output:

- Replaced stale generated-report `Project Bane Balance Lab` labels with
  `CrystalMaiden Balance Lab`.
- Added first-class report fields: `project`, `tool`, `status`,
  `status_counts`, `scenario_count`, `mechanics_count`, `seed_count`,
  `status_semantics`, `source`, and `metadata`.
- Clarified `pass`, `warn`, and `fail` semantics in generated report data and
  Balance Lab README.
- Updated `run_balance_suite.gd` console output to use CrystalMaiden identity
  and print status/scenario/mechanics/seed metadata.
- Updated the app bridge and renderer to prefer the new metadata while keeping
  fallback computation for older report shapes.
- Extended `balance_lab_test.gd` to assert the metadata shape.

Verification:

- `node --check tools\balance-lab\server.js` passed.
- `node --check tools\balance-lab\app.js` passed.
- `res://tests/balance_lab_test.gd` passed with exit code 0.
- The restarted local bridge ran Balance Lab with exit code 0.
- Latest report status: `pass`; `19 pass, 0 warn, 0 fail`; 6 scenarios; 13
  mechanics checks; 1200 seeds.
- `GET /api/report/results` returned `project=CrystalMaiden`,
  `tool=Balance Lab`, status semantics for `pass`, `warn`, and `fail`, and
  source metadata for `res://scripts/tools/run_balance_suite.gd`.
- Regenerated legacy `project/reports/balance/latest/index.html` uses
  `CrystalMaiden Balance Lab` and no longer contains `Project Bane Balance Lab`.
- Known Godot Windows root-certificate-store and ObjectDB/resource cleanup
  warnings appeared while checks still exited successfully.

### P3:M7:T5 - Audit And Map The Current Test Suite

Status: Complete.

Goal: make the existing tests understandable before adding more.

Direction:

- Create a compact test map in this document or a linked support doc.
- Classify tests by purpose: mechanics, UI/presentation, flow/state, save/load,
  RNG/determinism, Balance Lab, export/resource probes.
- Record known caveats, especially Godot warnings and the `combat_playback`
  sandbox autosave issue.

Expected output:

- Clear coverage map.
- Easier choice of focused checks for future work.

Completed output:

- Audited the current `project/tests` suite inventory: 42 top-level `.gd`
  checks plus `project/tests/helpers/combat_playback_scenarios.gd`.
- Classified the suite by mechanics/combat, build resolution, gear/shop/reward,
  UI/presentation, Adventure flow/state, Practice Room, save/load,
  RNG/determinism, Balance Lab/reporting, and resource/export probes.
- Identified focused run sets for likely future work.
- Recorded caveats and T6 hardening opportunities.

Current coverage map:

| Area | Files | Coverage | Run when | Caveats / T6 notes |
|---|---|---|---|---|
| Balance Lab and reporting | `balance_lab_test.gd`; `scripts/tools/run_balance_suite.gd`; `tools/balance-lab` bridge/app smoke | Report schema, CrystalMaiden metadata, pass/warn/fail counts, scenario/mechanics output shape, app-rendered report data. | Balance report shape, scenario thresholds, bridge/app workflow, or report identity changes. | Writes generated reports under `project/reports/balance/latest` and `project/reports/balance/test`. Keep warnings as designer-review signals unless true mechanics/resource failures occur. |
| Combat mechanics | `engine_mechanics_test.gd`; `legendary_mechanics_test.gd`; `opportunity_strikes_test.gd`; `shadow_parity_test.gd`; `deterministic_replay_test.gd`; `passive_allocator_test.gd` | Armor reduction, poison resistance reduction, poison cadence/stacks, physical multipliers, triggered skills, min-cast procs, Legendary effects, source-restricted procs, Shadow tree parity, talent dependency behavior, combat determinism. | Combat resolver, build resolver, proc, talent, Legendary, or Shadow mechanics changes. | Best T6 target. Standardize scenario helpers and make failure output include scenario id, seed, rotation, gear, monster, expected, and actual values. |
| Combat diagnostics / legacy smoke | `combat_test.gd` | Headless combat-resolution smoke/diagnostic output for casts, ticks, and summaries. | Manual investigation of raw combat output. | Mostly diagnostic print coverage rather than strong assertions. Candidate either to harden or explicitly keep as a probe. |
| Combat UI and presentation | `combat_hud_test.gd`; `combat_playback_test.gd`; `combat_recap_test.gd`; `combat_screen_test.gd`; `combat_stage_visual_reset_test.gd`; `enemy_panel_test.gd`; `overlay_centering_test.gd`; `skill_build_geometry_test.gd` | HUD chips/readouts, playback timeline, event ordering, skip/reveal timing, recap text/model, combat log, enemy panel, result overlays, visual reset, overlay centering, 10-slot build geometry. | Combat screen, playback, recap, log, HUD, result overlay, or layout changes. | `combat_playback_test.gd` is large and has the known sandbox/user-data autosave caveat; run it focused when touching playback or Adventure combat state. |
| Build screen and build resolution UI | `build_panels_test.gd`; `rotation_cap_test.gd`; `skill_build_geometry_test.gd`; `passive_allocator_test.gd`; `shadow_parity_test.gd` | Talent panel, available skills, rotation/macro slots, lock states, stats panel, gear panel, selected/disabled states, cap geometry, talent prerequisite behavior, Shadow build selection. | Talent, rotation, build panel, stat summary, or build resolver UI changes. | Some overlap with mechanics tests is intentional. T6 can extract shared build setup helpers if mechanics tests become noisy. |
| Gear, inventory, rewards, shop, and routes | `gear_generator_test.gd`; `inventory_model_test.gd`; `encounter_reward_test.gd`; `legendary_reward_test.gd`; `reward_shop_route_ui_test.gd`; `route_reward_choice_ui_test.gd`; `contract_route_data_test.gd`; `run_rng_context_test.gd`; `run_seed_state_test.gd` | Gear tier/affix generation, inventory/equip/sell constraints, encounter and Legendary rewards, reward/shop/route UI handoffs, route data, seed/RNG context isolation. | Gear generation, reward rolling, inventory/shop, route choice, or seeded reward changes. | Good T6 target for clearer seed/context labels and expected-vs-actual output around deterministic reward/shop choices. |
| Adventure flow and state | `contract_offer_flow_test.gd`; `dashboard_header_test.gd`; `run_failure_state_test.gd`; `run_outcome_presentation_test.gd`; `save_load_ui_test.gd`; `combat_screen_test.gd`; `reward_shop_route_ui_test.gd`; `route_reward_choice_ui_test.gd` | Title/adventure entry, contract offers, dashboard header state, failure/retry/restart/resume, victory/defeat presentation, save/load UI, reward/shop/route state transitions. | Adventure flow, state transitions, terminal states, save/load UI, or route/shop handoffs. | Run a narrow subset around the changed state instead of the whole UI suite unless shared flow code moved. |
| Practice Room | `training_room_entry_test.gd`; `training_room_build_test.gd`; `training_room_fight_setup_test.gd`; `training_room_fight_test.gd`; `training_room_combat_view_test.gd`; `training_room_gear_editor_test.gd` | Entry/exit isolation, freeform tree/talent/rotation setup, target/duration/seed/gold setup, deterministic practice fights, Practice Room combat view/playback/status chips/popups, paper-doll gear editor. | Practice Room setup, gear editor, target controls, playback, combat view, or Adventure-state isolation changes. | These are focused and useful. Keep verifying Practice Room never mutates real `BuildState` or save data. |
| Save/load and persistence | `save_load_test.gd`; `save_load_ui_test.gd`; `combat_playback_test.gd` | Save data model, UI resume/load behavior, and combat playback's immediate state/autosave invariant. | Save schema, title resume, Adventure state persistence, or fight-result state mutation changes. | Save/load plus playback can touch local user-data; watch sandbox behavior and avoid assuming generated user-data is clean. |
| Resource/export probes | `class_select_export_scan_test.gd`; `export_shadow_probe.gd`; `shadow_combat_screen_diag_test.gd` | Export remap loading, class selection resources, Shadow export/resource visibility and diagnostics. | Export/resource-loading changes or missing-resource investigations. | Probe-style tests should either remain clearly diagnostic or gain stronger pass/fail messages during T6/T7. |
| Shared fixtures/helpers | `helpers/combat_playback_scenarios.gd` | Controlled combat playback scenarios for presentation event coverage. | Playback scenario additions or fixture updates. | Consider similar helper extraction for mechanics scenarios during T6. |

Focused run sets:

| Change area | Suggested focused checks |
|---|---|
| Balance Lab/reporting | `balance_lab_test.gd`, then the Balance Lab bridge `Run Balance` workflow. |
| Core combat math | `engine_mechanics_test.gd`, `legendary_mechanics_test.gd`, `opportunity_strikes_test.gd`, `shadow_parity_test.gd`, `deterministic_replay_test.gd`. |
| Gear/rewards/RNG | `gear_generator_test.gd`, `inventory_model_test.gd`, `encounter_reward_test.gd`, `legendary_reward_test.gd`, `run_rng_context_test.gd`, `run_seed_state_test.gd`. |
| Combat presentation | `combat_playback_test.gd`, `combat_recap_test.gd`, `combat_hud_test.gd`, `combat_stage_visual_reset_test.gd`, `combat_screen_test.gd`. |
| Adventure flow | `contract_offer_flow_test.gd`, `reward_shop_route_ui_test.gd`, `route_reward_choice_ui_test.gd`, `run_failure_state_test.gd`, `run_outcome_presentation_test.gd`, `save_load_ui_test.gd`. |
| Practice Room | All `training_room_*_test.gd` files. |
| Export/resource confidence | `class_select_export_scan_test.gd`, `export_shadow_probe.gd`, `shadow_combat_screen_diag_test.gd`. |

Known caveats:

- Godot may print Windows root-certificate-store warnings and ObjectDB/resource
  cleanup warnings while still exiting with code 0.
- `combat_playback_test.gd` is intentionally broad and includes state/autosave
  invariants; run it as a focused playback/state check and watch for sandbox or
  user-data side effects.
- Balance Lab tests and bridge runs update generated report files under
  `project/reports/balance`.
- `combat_test.gd`, `export_shadow_probe.gd`, and
  `shadow_combat_screen_diag_test.gd` are closer to smoke/probe coverage than
  modern assertion-heavy regression tests.

T6 gap list:

- Harden critical mechanics checks with shared scenario helpers and consistent
  `_require` output.
- Add or improve failure messages for scenario id, seed, rotation, gear,
  monster, expected values, and actual values.
- Decide whether `combat_test.gd` should become an assertion-backed regression
  test or remain a named diagnostic probe.
- Improve deterministic reward/shop/RNG failure messages around context and
  seed values.
- Keep Balance Lab scenario thresholds readable as report metadata, then
  assert the metadata shape where it protects future comparison tooling.

Verification:

- No Godot suite was run for T5 because this task only audited and documented
  the existing tests.

### P3:M7:T6 - Harden Critical Mechanics Tests And Failure Messages

Status: Complete.

Goal: improve trust in mechanics coverage without broad framework churn.

Likely coverage targets:

- Combat resolver order of operations.
- Build resolver stat aggregation and unlocked skill filtering.
- Proc source restrictions.
- Min-cast proc timing.
- Armor reduction and poison resistance reduction persistence.
- Gear generated affix ranges and slot/tier constraints.
- Reward and shop choice determinism by seed/context.

Direction:

- Prefer focused helper functions over duplicated setup.
- Replace opaque raw assertions where diagnostics matter.
- Include scenario ids, expected values, actual values, seeds, rotations, gear,
  and monster names in failure output.

Expected output:

- More useful mechanics failures.
- Stronger safety net for Phase 4 systems and balance work.

Completed output:

- Hardened `project/tests/engine_mechanics_test.gd` with named `_require`,
  `_require_equal`, and `_require_approx` checks for core combat mechanics:
  armor reduction persistence, physical multiplier, bonus poison stacks,
  primitive poison, poison cadence, triggered-skill contributions, poison
  resistance reduction persistence, and stack-scaling damage.
- Hardened `project/tests/opportunity_strikes_test.gd` so Opportunity Strikes
  failures now include fixture paths, trigger source ids, class/tree/talent
  context, rotation, monster, cast event summaries, contribution rows, and log
  text when relevant.
- Hardened `project/tests/deterministic_replay_test.gd` so same-seed and
  varied-seed replay failures include seed, rotation, monster, talent, and
  combat signatures.
- Hardened `project/tests/legendary_mechanics_test.gd` around gear-granted
  unlocks, gold scaling, minimum-cast proc timing, zero-chance regression, and
  Mithril Karambit source-skill restrictions. Failures now include gear,
  seed, rotation, monster, cast-event, expected, and actual context.
- Removed remaining bare `assert(...)` calls from the four touched focused
  mechanics tests.

Verification:

- `res://tests/engine_mechanics_test.gd` passed with exit code 0.
- `res://tests/opportunity_strikes_test.gd` passed with exit code 0.
- `res://tests/deterministic_replay_test.gd` passed with exit code 0.
- `res://tests/legendary_mechanics_test.gd` passed with exit code 0.
- Known Godot Windows root-certificate-store and ObjectDB/resource cleanup
  warnings appeared while checks still exited successfully.
- A first attempt using relative `--log-file project/reports/...` failed before
  test script load because Godot tried to create `user://project/reports`.
  Use absolute `--log-file` paths for T7 workflow documentation.

### P3:M7:T7 - Verify Repeatability And Document The Workflow

Status: Complete.

Goal: prove the new tool workflow and focused suite can be run reliably.

Direction:

- Run Balance Lab repeatedly and confirm deterministic aggregate results for
  fixed scenario definitions and seeds.
- Run `balance_lab_test.gd`.
- Run focused mechanics tests touched during the milestone.
- Document how to start the app, click `Run Balance`, find report outputs, and
  interpret warnings.

Expected output:

- Repeatable Balance Lab runs.
- Clear user-facing workflow documentation.
- Known caveats recorded in one place.

Completed output:

- Ran Balance Lab twice back-to-back with fixed scenario definitions and seeds.
- Compared normalized report signatures that intentionally ignore generated
  timestamps and include status counts, scenario aggregate metrics, mechanics
  rows, scenario count, mechanics count, and total seed count.
- Confirmed repeatability:
  - `repeatable=true`
  - `scenario_signature_equal=true`
  - `mechanics_signature_equal=true`
  - latest aggregate `19 pass, 0 warn, 0 fail`
  - 6 scenarios
  - 13 mechanics checks
  - 1200 seeds
- Reran the focused Balance Lab schema/report test.
- Reran the focused mechanics tests touched by T6.
- Checked the running local bridge with `GET /api/status`; it returned success,
  exit code 0, CrystalMaiden Balance Lab metadata, and latest report counts.
- Updated `tools/balance-lab/README.md` with the app workflow, direct
  verification commands, status interpretation, report artifact paths, and
  absolute `--log-file` caveat.

Verification:

- Two consecutive Balance Lab runs passed with exit code 0 and matching
  normalized signatures.
- `res://tests/balance_lab_test.gd` passed with exit code 0.
- `res://tests/engine_mechanics_test.gd` passed with exit code 0.
- `res://tests/opportunity_strikes_test.gd` passed with exit code 0.
- `res://tests/deterministic_replay_test.gd` passed with exit code 0.
- `res://tests/legendary_mechanics_test.gd` passed with exit code 0.
- `GET http://127.0.0.1:8787/api/status` returned bridge status `success`,
  exit code 0, and latest report counts.
- Known Godot Windows root-certificate-store and ObjectDB/resource cleanup
  warnings appeared while checks still exited successfully.

### P3:M7:T8 - Verify, Document, And Close Milestone 7

Status: Complete.

Goal: close the tooling milestone cleanly.

Expected output:

- Updated task statuses.
- Final verification notes.
- Updated `docs/P3_CrystalMaiden_Overview.md`.
- Updated `docs/P3_CrystalMaiden_Onboarding_Context.md`.
- Deferred notes for deeper Balance Lab interactivity and Monster Lab handoff.

Completed output:

- Marked all M7 tasks complete.
- Recorded final verification in this document.
- Updated the Phase 3 overview and onboarding handoff for M7 closeout.
- Left Balance Lab as a stable run-and-read local app:
  - app shell under `tools/balance-lab`
  - local Node bridge
  - `Run Balance` workflow
  - app-rendered latest report tables
  - CrystalMaiden report identity and metadata
  - repeatability verification
  - focused mechanics-test diagnostics

Deferred notes:

- Deeper Balance Lab interactivity remains deferred: sliders, scenario editing,
  monster selection, build editing, comparison history, and threshold editing.
- Monster Lab remains a future companion tool. It should reuse the same pattern:
  small local browser app, dependency-free bridge if Godot execution is needed,
  app-rendered JSON output, explicit metadata, and clear pass/warn/fail or
  design-review semantics.
- Future test hardening can extend the T6 `_require` pattern to reward/shop/RNG
  tests and older probe-style tests if those areas become active again.

Final verification:

- Balance Lab repeated successfully and produced deterministic normalized
  aggregate signatures.
- Focused report/mechanics checks passed:
  - `balance_lab_test.gd`
  - `engine_mechanics_test.gd`
  - `opportunity_strikes_test.gd`
  - `deterministic_replay_test.gd`
  - `legendary_mechanics_test.gd`
- Local bridge status endpoint returned the latest successful run and report
  metadata.
- Known Godot certificate/resource cleanup warnings remain documented caveats.

## Verification Notes

Use `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe` for Godot
checks. Prefer explicit workspace `--log-file` paths for headless test runs.

Current Balance Lab command:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-CrystalMaiden\project' --log-file 'F:\Data\Claude Projects\Project-CrystalMaiden\project\reports\balance\latest\godot_run.log' -s res://scripts/tools/run_balance_suite.gd
```

Current focused Balance Lab test:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-CrystalMaiden\project' --log-file 'F:\Data\Claude Projects\Project-CrystalMaiden\project\reports\balance\test\balance_lab_test.log' -s res://tests/balance_lab_test.gd
```

Known caveats:

- Godot may print Windows root-certificate-store warnings.
- Godot may print ObjectDB/resource cleanup warnings at exit even when checks
  pass with exit code 0.
- `res://tests/combat_playback_test.gd` may reproduce the known sandbox
  autosave/user-data assertion and pass outside the sandbox.
