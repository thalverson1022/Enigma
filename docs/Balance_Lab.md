# Balance Lab

Balance Lab is a headless Godot tool for checking Project Bane combat mechanics and balance distributions against the real authored resources.

It is intended to answer two different questions:

- Did a mechanic wire correctly? These are deterministic checks for stats, unlocks, proc configuration, and other exact expectations.
- Did a build stay within the current balance envelope? These are seeded statistical scenarios that report DPS, win rate, poison damage, proc rates, and percentile ranges.

Run it from the project root:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-Bane\project' -s 'res://scripts/tools/run_balance_suite.gd'
```

Outputs are written to:

- `project/reports/balance/latest/results.json`
- `project/reports/balance/latest/scenario_summary.csv`
- `project/reports/balance/latest/index.html`

The dashboard is static and self-contained. Open `index.html` directly in a browser to inspect suite health, scenario DPS distributions, win rates, poison damage, proc rates, and deterministic mechanics checks.

The regression test for the lab itself is:

```powershell
& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --path 'F:\Data\Claude Projects\Project-Bane\project' -s 'res://tests/balance_lab_test.gd'
```

The MVP suite includes:

- Legendary stat wiring checks for Bandit Blade, Wyvern Kriss, Mithril Karambit, Umbral Stiletto, and Bejeweled Push Dagger.
- Seeded combat distributions for baseline Rogue, Shadow intrinsic poison, Wyvern poison, Bandit Blade gold scaling, Bejeweled proc rate, and a late-contract Thief build.

When new mechanics are added, add one deterministic mechanics check and at least one seeded scenario that exercises the mechanic over many seeds.

As of 2026-07-25, the latest generated suite result is `19 pass, 0 warn, 0 fail`.
