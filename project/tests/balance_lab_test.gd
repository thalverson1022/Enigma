extends SceneTree

const BalanceLab = preload("res://scripts/tools/balance_lab.gd")


func _initialize() -> void:
	var report := BalanceLab.run_suite()
	assert(report["mechanics"].size() >= 10)
	assert(report["scenarios"].size() >= 6)
	for mechanic in report["mechanics"]:
		assert(mechanic["status"] == "pass")

	var scenario_ids := []
	for scenario in report["scenarios"]:
		scenario_ids.append(scenario["id"])
		assert(scenario["aggregate"]["dps"]["count"] == scenario["seed_count"])
		assert(scenario["aggregate"]["dps"]["mean"] > 0.0)
		assert(scenario["samples"].size() > 0)
	assert(scenario_ids.has("shadow_intrinsic_stab_mouthy"))
	assert(scenario_ids.has("bejeweled_proc_rate_training_dummy"))

	var output_dir := ProjectSettings.globalize_path("res://reports/balance/test")
	assert(BalanceLab.write_report(report, output_dir))
	assert(FileAccess.file_exists(output_dir + "/results.json"))
	assert(FileAccess.file_exists(output_dir + "/scenario_summary.csv"))
	assert(FileAccess.file_exists(output_dir + "/index.html"))
	print("Balance Lab test: OK")
	quit()
