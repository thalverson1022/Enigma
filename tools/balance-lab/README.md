# Balance Lab

Phase 5 quarantine note (2026-09-03): this README still contains historical
DawnBringer paths, commands, and report baselines. The active Godot Balance Lab
report metadata now uses Project Enigma; full Phase 5 Balance Lab validation
remains P5M11 scope.

Balance Lab is a local browser tool for running and reading DawnBringer balance reports.

Start the local bridge server from the repository root:

```powershell
node tools\balance-lab\server.js
```

Then open:

```text
http://127.0.0.1:8787
```

## Current Scope

- Provides a stable Balance Lab dashboard home under `tools/balance-lab`.
- Serves the app through a small dependency-free Node bridge.
- Runs the existing Godot balance suite from the `Run Balance` button.
- Blocks duplicate runs while the balance suite is already running.
- Reports idle, running, success, and failure states with captured output.
- Exposes latest `results.json`, `scenario_summary.csv`, and `godot_run.log`.
- Renders the latest `results.json` suite health, scenario summaries, and mechanics checks inside the app.
- Points at the current Godot report output location: `project/reports/balance/latest`.
- Uses first-class report metadata such as `project`, `tool`, `status`, `status_counts`, `scenario_count`, `mechanics_count`, `seed_count`, and `status_semantics`.

## Report Views

- Suite Health shows pass/warn/fail totals, scenario count, total seeds, generated timestamp, and overall status.
- Scenario Summary shows scenario labels, monsters, rotations, status, mean DPS, p05/p95 DPS, win rate, poison contribution, min-cast proc rate, seed count, and thresholds/notes.
- Mechanics Checks shows check labels, status, observed value, expected value, tolerance, and note.
- Report Files links expose the raw JSON, CSV, and Godot run log through the local bridge.

## Status Semantics

- `pass`: expected mechanics checks or scenario thresholds are within accepted bounds.
- `warn`: balance-review signal, usually threshold drift, not necessarily a broken test.
- `fail`: mechanics, resource, runner, or hard correctness failure that needs investigation.

## Workflow

1. Start the bridge from the repository root:

```powershell
node tools\balance-lab\server.js
```

2. Open the app:

```text
http://127.0.0.1:8787
```

3. Click `Run Balance`.

4. Read Suite Health first:

- `pass` means expected mechanics checks or scenario thresholds are within accepted bounds.
- `warn` means a balance-review threshold drifted and should be reviewed by design.
- `fail` means mechanics, resource loading, runner setup, or hard correctness failed.

5. Use the Scenario Summary and Mechanics Checks tables to find the row that moved.

6. Use Report Files for raw artifacts:

- `project/reports/balance/latest/results.json`
- `project/reports/balance/latest/scenario_summary.csv`
- `project/reports/balance/latest/godot_run.log`

## Verification Commands

Run the Balance Lab suite directly:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-DawnBringer\project' --log-file 'F:\Data\Claude Projects\Project-DawnBringer\project\reports\balance\latest\godot_run.log' -s res://scripts/tools/run_balance_suite.gd
```

Run the focused Balance Lab schema test:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-DawnBringer\project' --log-file 'F:\Data\Claude Projects\Project-DawnBringer\project\reports\balance\test\balance_lab_test.log' -s res://tests/balance_lab_test.gd
```

Use absolute `--log-file` paths. Relative log paths can be interpreted under `user://` by Godot and fail before a test script loads.

Known successful M7 closeout baseline:

- Balance Lab repeatability: deterministic normalized signatures matched across two consecutive runs.
- Latest expected aggregate: `19 pass, 0 warn, 0 fail`, 6 scenarios, 13 mechanics checks, 1200 seeds.
- Godot may still print Windows root-certificate-store and ObjectDB/resource cleanup warnings while exiting with code 0.

## Configuration

The bridge defaults to this command:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-DawnBringer\project' --log-file 'F:\Data\Claude Projects\Project-DawnBringer\project\reports\balance\latest\godot_run.log' -s res://scripts/tools/run_balance_suite.gd
```

Optional environment variables:

- `BALANCE_LAB_HOST`: defaults to `127.0.0.1`.
- `BALANCE_LAB_PORT`: defaults to `8787`.
- `GODOT_PATH`: overrides the Godot executable path.

## Endpoints

- `GET /api/status`: current bridge/run status plus latest report summary.
- `POST /api/run-balance`: starts the Godot balance suite.
- `GET /api/report/results`: latest `results.json`.
- `GET /api/report/scenario-summary`: latest `scenario_summary.csv`.
- `GET /api/report/godot-log`: latest Godot log for bridge-launched runs.
