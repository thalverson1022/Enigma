param(
    [string]$GodotExe = "F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe",
    [string]$ProjectPath = "project",
    [string]$LogRoot = ".godot_user\logs\p5m12"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $GodotExe)) {
    throw "Godot executable not found: $GodotExe"
}

$resolvedLogRoot = $LogRoot
if (-not [System.IO.Path]::IsPathRooted($resolvedLogRoot)) {
    $resolvedLogRoot = Join-Path (Get-Location).Path $resolvedLogRoot
}

New-Item -ItemType Directory -Force -Path $resolvedLogRoot | Out-Null

$tests = @(
    "training_room_entry_test.gd",
    "training_room_build_test.gd",
    "training_room_gear_editor_test.gd",
    "training_room_fight_setup_test.gd",
    "training_room_fight_test.gd",
    "training_room_combat_view_test.gd",
    "p5m4_practice_room_combat_smoke_test.gd",
    "p5m8_stat_readability_test.gd",
    "p5m8_ui_regression_test.gd",
    "p5m9_icon_regression_test.gd",
    "p5m9_special_icon_overrides_test.gd",
    "p5m10_legendary_regression_test.gd",
    "p5m10_legendary_presentation_equip_test.gd",
    "p5m10_legendary_combat_effects_test.gd",
    "p5m11_economy_stats_test.gd",
    "p5m11_overkill_gold_test.gd",
    "p5m7_gold_gain_economy_test.gd",
    "gear_generator_test.gd",
    "p5m5_generator_regression_test.gd",
    "contract_route_generator_test.gd",
    "runtime_monster_generator_test.gd",
    "generated_route_matrix_test.gd",
    "generated_contract_save_load_test.gd",
    "deterministic_replay_test.gd",
    "reward_shop_route_ui_test.gd",
    "route_reward_choice_ui_test.gd",
    "combat_hud_test.gd",
    "combat_screen_test.gd",
    "combat_recap_test.gd",
    "enemy_defense_mechanics_test.gd",
    "opportunity_strikes_test.gd",
    "save_load_ui_test.gd",
    "save_load_test.gd",
    "class_select_export_scan_test.gd"
)

$failures = @()

foreach ($test in $tests) {
    $name = [System.IO.Path]::GetFileNameWithoutExtension($test)
    $logPath = Join-Path $resolvedLogRoot "$name.log"
    Write-Host "Running $test"
    & $GodotExe --headless --log-file $logPath --path $ProjectPath -s "res://tests/$test"
    if ($LASTEXITCODE -ne 0) {
        $failures += $test
    }
}

$balanceLog = Join-Path $resolvedLogRoot "run_balance_suite.log"
Write-Host "Running Balance Lab suite"
& $GodotExe --headless --log-file $balanceLog --path $ProjectPath -s "res://scripts/tools/run_balance_suite.gd"
if ($LASTEXITCODE -ne 0) {
    $failures += "run_balance_suite.gd"
}

Write-Host "Running Shop Lab checks"
node tools/shop-lab/run_checks.js
if ($LASTEXITCODE -ne 0) {
    $failures += "tools/shop-lab/run_checks.js"
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "P5M12 regression failures:"
    foreach ($failure in $failures) {
        Write-Host " - $failure"
    }
    exit 1
}

Write-Host ""
Write-Host "P5M12 regression checks passed."
