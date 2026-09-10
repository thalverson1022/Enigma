# Project Enigma Phase 5 Closeout Handoff

Date: 2026-09-10

Phase 5 closes with the gear redesign promoted as the next stable Project
Enigma baseline.

## Baseline

The playable baseline includes the full generated-contract Adventure loop,
five-slot Rogue gear, deterministic generated rewards and shops, readable item
cards and comparison tooltips, Rogue generated gear sprites, fixed retained
Rogue Legendary daggers, Practice Room validation, Balance Lab validation, and
P5M11 playtest tuning.

The retained Rogue Legendary daggers are Wyvern Kriss, Bandit Blade, Umbral
Stiletto, Mithril Karambit, and Bejeweled Push Dagger. They use fixed Phase 5
stat packages and 21-27 Legendary weapon damage.

## Verification

Final closeout verification is recorded in
`docs/P5M12_Phase_5_Regression_Smoke_And_Closeout_Tracker.md`.

Passed:

- `tools/p5m12/run_regression.ps1`
- `project/scripts/tools/run_balance_suite.gd`, with 69 pass, 1 accepted
  warning, and 0 fail
- `tools/shop-lab/run_checks.js`, with 23 checks passed
- `tools/p5m12/export_itchio.ps1`

Accepted caveats:

- Godot headless ObjectDB/RID/resource cleanup warnings at process exit.
- Intentional corrupt-save parse output in `save_load_test.gd`.
- One Balance Lab warning for `bladedancer_contract_watchmen`, deferred to the
  later talent-tree balance pass.
- Godot editor settings save warning in the sandboxed Codex environment after a
  successful web export.

## Itch.io Package

The itch.io-ready web package is:

`release/itchio/project-enigma-phase5-itch.zip`

Package shape:

- 9 exported files.
- `index.html` at ZIP root.
- Extracted size: 194.73 MB.
- ZIP size: 172,267,345 bytes.
- Largest exported file: `index.pck`, 164,340,448 bytes.

Use `docs/Itch_IO_Release_Checklist.md` for itch.io page settings. Upload the
ZIP as an HTML game and enable SharedArrayBuffer/cross-origin isolation if
itch.io exposes that setting for the project page.

## GitHub

Closeout branch:

`phase-5-gear-redesign`

Remote:

`https://github.com/thalverson1022/Enigma.git`

The exact pushed closeout commit hash should be read from Git after the final
commit and push.

## Next Work

Future work should start from this Phase 5 baseline. Good next candidates are
external playtest feedback triage, the broader talent-tree remake, deeper
balance passes, and eventual platform/page polish after the itch.io package is
uploaded.
