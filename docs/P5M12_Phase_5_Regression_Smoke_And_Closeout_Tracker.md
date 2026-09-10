# P5M12 Phase 5 Regression, Smoke, And Closeout Tracker

Status: Complete.

P5M12 closes Phase 5 by making the completed gear redesign the next stable
baseline. This milestone owns the final regression pass, web/itch.io packaging,
GitHub push, closeout documentation, and final handoff.

## Scope

- Verify the Adventure loop, generated contracts, route previews, rewards,
  shops, save/load, Practice Room, Shop Lab, Balance Lab, and export-sensitive
  paths.
- Produce an itch.io-ready Godot Web package from the
  `Project Enigma Web Itch` export preset.
- Record known non-blockers and accepted caveats.
- Commit the Phase 5 closeout state and push it to GitHub.
- Update the overview, onboarding, and Phase 5 handoff docs.

## Regression Plan

Run:

- `tools/p5m12/run_regression.ps1`
- `tools/p5m12/export_itchio.ps1`

The regression script covers Practice Room, generated gear, item presentation,
Legendary behavior, economy affixes, generated routes/contracts, reward/shop UI,
combat HUD/screen/recap, save/load, export scanning, Balance Lab, and Shop Lab.

## Itch.io Package Requirements

- Godot export preset: `Project Enigma Web Itch`.
- Export output folder: `project/export/web/itch/`.
- Upload package: `release/itchio/project-enigma-phase5-itch.zip`.
- The ZIP must contain `index.html` at its root.
- The ZIP must contain all generated Godot web export files.
- Upload to itch.io as an HTML game.
- Use fullscreen launch or a 1600x900 embedded viewport.
- If itch.io shows SharedArrayBuffer or cross-origin isolation options, enable
  them for Godot 4 compatibility.

## Evidence

Completed 2026-09-10.

- `tools/p5m12/run_regression.ps1` passed.
- `project/scripts/tools/run_balance_suite.gd` completed with 69 pass, 1
  accepted warning, and 0 fail.
- `tools/shop-lab/run_checks.js` completed with 23 checks passed.
- `tools/p5m12/export_itchio.ps1` produced the itch.io-ready package at
  `release/itchio/project-enigma-phase5-itch.zip`.
- Exported web folder: `project/export/web/itch/`.
- Exported web files: 9.
- Extracted package size: 194.73 MB.
- ZIP size: 172,267,345 bytes.
- Largest exported file: `index.pck`, 164,340,448 bytes.
- ZIP root contains `index.html`.
- `project/export_presets.cfg` excludes `export/**`, `reports/**`, `tests/**`,
  `tmp/**`, and `tools/**` so development artifacts are not shipped inside the
  web package.
- `release/itchio/*.zip` is tracked through Git LFS to avoid normal GitHub blob
  size limits.
- Closeout branch: `phase-5-gear-redesign`.
- Closeout remote: `https://github.com/thalverson1022/Enigma.git`.
- Closeout commit hash: recorded after the GitHub push in the assistant
  closeout response.

## Known Non-Blockers

- Godot headless ObjectDB/RID/resource cleanup warnings at process exit remain
  accepted unless a regression command exits non-zero.
- `save_load_test.gd` intentionally logs corrupt-save parse output while
  testing corrupt save handling.
- `run_balance_suite.gd` may report one accepted Balance Lab warning for
  `bladedancer_contract_watchmen`; this remains a future talent-tree balance
  watch, not a Phase 5 closeout blocker.
- Godot headless export logs `Cannot save file
  C:/Users/tommh/AppData/Roaming/Godot/editor_settings-4.7.tres` in this
  sandboxed Codex environment after the export has completed; the package was
  still written and validated.
