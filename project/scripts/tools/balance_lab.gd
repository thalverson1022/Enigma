class_name BalanceLab
extends RefCounted

const VERSION := "0.1.0"
const PROJECT_NAME := "DawnBringer"
const TOOL_NAME := "Balance Lab"
const DEFAULT_SEED_COUNT := 200
const STATUS_SEMANTICS := {
	"pass": "Expected mechanics checks or scenario thresholds are within accepted bounds.",
	"warn": "Balance-review signal, usually threshold drift, not necessarily a broken test.",
	"fail": "Mechanics, resource, runner, or hard correctness failure that needs investigation.",
}


static func run_suite() -> Dictionary:
	var report := {
		"version": VERSION,
		"project": PROJECT_NAME,
		"tool": TOOL_NAME,
		"generated_at": Time.get_datetime_string_from_system(),
		"status_semantics": STATUS_SEMANTICS,
		"source": {
			"runner_script": "res://scripts/tools/run_balance_suite.gd",
			"report_writer": "res://scripts/tools/balance_lab.gd",
			"source_command": "godot --headless --path project -s res://scripts/tools/run_balance_suite.gd",
		},
		"mechanics": _run_mechanics_checks(),
		"scenarios": [],
	}
	for spec in _scenario_specs():
		report["scenarios"].append(_run_scenario(spec))
	_finalize_report_metadata(report)
	return report


static func _finalize_report_metadata(report: Dictionary) -> void:
	var counts := status_counts(report)
	var scenario_count: int = report.get("scenarios", []).size()
	var mechanics_count: int = report.get("mechanics", []).size()
	var seed_count := 0
	for scenario in report.get("scenarios", []):
		seed_count += int(scenario.get("seed_count", 0))
	var overall_status := "pass"
	if int(counts.get("fail", 0)) > 0:
		overall_status = "fail"
	elif int(counts.get("warn", 0)) > 0:
		overall_status = "warn"
	report["status"] = overall_status
	report["status_counts"] = counts
	report["scenario_count"] = scenario_count
	report["mechanics_count"] = mechanics_count
	report["seed_count"] = seed_count
	report["metadata"] = {
		"project": PROJECT_NAME,
		"tool": TOOL_NAME,
		"version": VERSION,
		"generated_at": report.get("generated_at", ""),
		"status": overall_status,
		"status_counts": counts,
		"scenario_count": scenario_count,
		"mechanics_count": mechanics_count,
		"seed_count": seed_count,
		"status_semantics": STATUS_SEMANTICS,
		"source": report.get("source", {}),
	}


static func write_report(report: Dictionary, output_dir: String) -> bool:
	DirAccess.make_dir_recursive_absolute(output_dir)
	var json_path := output_dir + "/results.json"
	var csv_path := output_dir + "/scenario_summary.csv"
	var html_path := output_dir + "/index.html"
	return (
		_write_text(json_path, JSON.stringify(report, "\t"))
		and _write_text(csv_path, _scenario_csv(report))
		and _write_text(html_path, _dashboard_html(report))
	)


static func status_counts(report: Dictionary) -> Dictionary:
	var counts := {"pass": 0, "warn": 0, "fail": 0}
	for mechanic in report.get("mechanics", []):
		counts[mechanic.get("status", "fail")] = counts.get(mechanic.get("status", "fail"), 0) + 1
	for scenario in report.get("scenarios", []):
		counts[scenario.get("status", "fail")] = counts.get(scenario.get("status", "fail"), 0) + 1
	return counts


## Each Legendary's checks are gated behind their own resource-load guard, so
## one missing/renamed .tres reports as a single failed check for that item
## instead of crashing the whole suite -- the exact regression Balance Lab
## exists to catch.
static func _run_mechanics_checks() -> Array:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	if rogue == null:
		return [_check_result("rogue_resource", "Rogue class resource loads", "fail", "Missing res://data/classes/rogue.tres", {})]

	var results := []
	results.append_array(_bandit_blade_checks(rogue))
	results.append_array(_wyvern_kriss_checks(rogue))
	results.append_array(_mithril_karambit_checks(rogue))
	results.append_array(_umbral_stiletto_checks(rogue))
	results.append_array(_bejeweled_push_dagger_checks(rogue))
	return results


static func _bandit_blade_checks(rogue: ClassDef) -> Array:
	var bandit: GearItem = load("res://data/gear/bandit_blade.tres")
	if bandit == null:
		return [_missing_resource_check("bandit_blade_resource", "Bandit Blade resource loads", "res://data/gear/bandit_blade.tres")]
	var bandit_stats := BuildResolver.resolve_stats(rogue, [], [], [bandit], 100)
	return [
		_numeric_check("bandit_physical_multiplier", "Bandit Blade physical multiplier", bandit_stats.physical_damage_multiplier, 1.2, 0.001),
		_numeric_check("bandit_crit_chance", "Bandit Blade crit chance", bandit_stats.crit_chance, 0.35, 0.001),
		_numeric_check("bandit_gold_scaling", "Bandit Blade gold scaling at 100g", bandit_stats.bonus_physical_damage, 10.0, 0.001),
	]


static func _wyvern_kriss_checks(rogue: ClassDef) -> Array:
	var wyvern: GearItem = load("res://data/gear/wyvern_kriss.tres")
	if wyvern == null:
		return [_missing_resource_check("wyvern_kriss_resource", "Wyvern Kriss resource loads", "res://data/gear/wyvern_kriss.tres")]
	var wyvern_stats := BuildResolver.resolve_stats(rogue, [], [], [wyvern])
	return [
		_numeric_check("wyvern_bonus_poison_stacks", "Wyvern Kriss bonus poison stacks", float(wyvern_stats.bonus_poison_stacks), 2.0, 0.001),
		_numeric_check("wyvern_poison_damage", "Wyvern Kriss poison damage multiplier", wyvern_stats.poison_damage_per_tick, 11.2, 0.001),
		_numeric_check("wyvern_tick_interval", "Wyvern Kriss poison tick interval", wyvern_stats.poison_tick_interval_multiplier, 0.5, 0.001),
	]


static func _mithril_karambit_checks(rogue: ClassDef) -> Array:
	var mithril: GearItem = load("res://data/gear/mithril_karambit.tres")
	if mithril == null:
		return [_missing_resource_check("mithril_karambit_resource", "Mithril Karambit resource loads", "res://data/gear/mithril_karambit.tres")]
	var mithril_stats := BuildResolver.resolve_stats(rogue, [], [], [mithril])
	var results := [
		_numeric_check("mithril_trigger_count", "Mithril Karambit trigger count", float(mithril_stats.triggered_skill_effects.size()), 2.0, 0.001),
	]
	if mithril_stats.triggered_skill_effects.size() >= 2:
		results.append(_numeric_check("mithril_trigger_chance_stab", "Mithril Karambit Stab retrigger chance", mithril_stats.triggered_skill_effects[0].chance, 0.2, 0.001))
		results.append(_numeric_check("mithril_trigger_chance_heavy", "Mithril Karambit Heavy Slash retrigger chance", mithril_stats.triggered_skill_effects[1].chance, 0.2, 0.001))
	return results


static func _umbral_stiletto_checks(rogue: ClassDef) -> Array:
	var umbral: GearItem = load("res://data/gear/umbral_stiletto.tres")
	if umbral == null:
		return [_missing_resource_check("umbral_stiletto_resource", "Umbral Stiletto resource loads", "res://data/gear/umbral_stiletto.tres")]
	var umbral_skills := BuildResolver.resolve_unlocked_skills(rogue, [], [], [umbral])
	var unlocks_death_strike := false
	for skill in umbral_skills:
		if skill.id == "skill.killers_mark":
			unlocks_death_strike = true
	return [_boolean_check("umbral_unlocks_death_strike", "Umbral Stiletto unlocks Death Strike", unlocks_death_strike)]


static func _bejeweled_push_dagger_checks(rogue: ClassDef) -> Array:
	var bejeweled: GearItem = load("res://data/gear/bejeweled_push_dagger.tres")
	if bejeweled == null:
		return [_missing_resource_check("bejeweled_push_dagger_resource", "Bejeweled Push Dagger resource loads", "res://data/gear/bejeweled_push_dagger.tres")]
	var bejeweled_stats := BuildResolver.resolve_stats(rogue, [], [], [bejeweled])
	return [
		_numeric_check("bejeweled_physical_multiplier", "Bejeweled Push Dagger physical multiplier", bejeweled_stats.physical_damage_multiplier, 1.2, 0.001),
		_numeric_check("bejeweled_crit_chance", "Bejeweled Push Dagger crit chance", bejeweled_stats.crit_chance, 0.55, 0.001),
		_numeric_check("bejeweled_min_cast_proc", "Bejeweled Push Dagger min-cast proc chance", bejeweled_stats.min_cast_time_proc_chance, 0.2, 0.001),
	]


static func _scenario_specs() -> Array:
	return [
		{
			"id": "baseline_rogue_stab_mouthy",
			"label": "Baseline Rogue Stab vs Mouthy Drunk",
			"class": "res://data/classes/rogue.tres",
			"trees": [],
			"talents": [],
			"gear": [],
			"skills": ["res://data/skills/stab.tres"],
			"monster": "res://data/monsters/mouthy_drunk.tres",
			"duration_ms": 12000,
			"seed_start": 1,
			"seed_count": DEFAULT_SEED_COUNT,
			"gold": 0,
			"thresholds": {"min_mean_dps": 9.0, "max_mean_dps": 14.0},
		},
		{
			"id": "shadow_intrinsic_stab_mouthy",
			"label": "Shadow Intrinsic Stab vs Mouthy Drunk",
			"class": "res://data/classes/rogue.tres",
			"trees": ["res://data/subclass_trees/shadow.tres"],
			"talents": [],
			"gear": [],
			"skills": ["res://data/skills/stab.tres"],
			"monster": "res://data/monsters/mouthy_drunk.tres",
			"duration_ms": 12000,
			"seed_start": 1,
			"seed_count": DEFAULT_SEED_COUNT,
			"gold": 0,
			"thresholds": {"min_mean_poison_damage": 20.0, "min_mean_poison_ticks": 2.0},
		},
		{
			"id": "shadow_wyvern_poison_mouthy",
			"label": "Shadow + Wyvern Poison vs Mouthy Drunk",
			"class": "res://data/classes/rogue.tres",
			"trees": ["res://data/subclass_trees/shadow.tres"],
			"talents": [],
			"gear": ["res://data/gear/wyvern_kriss.tres"],
			"skills": ["res://data/skills/stab.tres", "res://data/skills/heavy_slash.tres"],
			"monster": "res://data/monsters/mouthy_drunk.tres",
			"duration_ms": 12000,
			"seed_start": 1,
			"seed_count": DEFAULT_SEED_COUNT,
			"gold": 0,
			"thresholds": {"min_mean_poison_damage": 60.0, "min_win_rate": 0.95},
		},
		{
			"id": "bandit_blade_gold_scaling",
			"label": "Bandit Blade at 100g vs Mouthy Drunk",
			"class": "res://data/classes/rogue.tres",
			"trees": [],
			"talents": [],
			"gear": ["res://data/gear/bandit_blade.tres"],
			"skills": ["res://data/skills/stab.tres", "res://data/skills/heavy_slash.tres"],
			"monster": "res://data/monsters/mouthy_drunk.tres",
			"duration_ms": 12000,
			"seed_start": 1,
			"seed_count": DEFAULT_SEED_COUNT,
			"gold": 100,
			"thresholds": {"min_mean_dps": 20.0, "min_win_rate": 0.98},
		},
		{
			"id": "bejeweled_proc_rate_training_dummy",
			"label": "Bejeweled Proc Rate vs Training Dummy",
			"class": "res://data/classes/rogue.tres",
			"trees": [],
			"talents": [],
			"gear": ["res://data/gear/bejeweled_push_dagger.tres"],
			"skills": ["res://data/skills/stab.tres", "res://data/skills/heavy_slash.tres"],
			"monster": "res://data/monsters/training_dummy.tres",
			"duration_ms": 30000,
			"seed_start": 1,
			"seed_count": DEFAULT_SEED_COUNT,
			"gold": 0,
			"thresholds": {"min_proc_rate": 0.14, "max_proc_rate": 0.26},
		},
		{
			"id": "thief_contract_watchmen",
			"label": "Thief Contract Build vs Cloaked Watchmen",
			"class": "res://data/classes/rogue.tres",
			"trees": ["res://data/subclass_trees/shadow.tres", "res://data/subclass_trees/thief.tres"],
			"talents": [
				"res://data/talents/shadow/lingering_venom.tres",
				"res://data/talents/shadow/exposed_weakness.tres",
				"res://data/talents/shadow/black_lotus.tres",
				"res://data/talents/thief/piercing_blades.tres",
				"res://data/talents/thief/practiced_rhythm.tres",
				"res://data/talents/thief/opportunity_strikes.tres"
			],
			"gear": ["res://data/gear/wyvern_kriss.tres"],
			"skills": [
				"res://data/skills/poison_strike.tres",
				"res://data/skills/heavy_slash.tres",
				"res://data/skills/quick_cut.tres",
				"res://data/skills/rending_slash.tres"
			],
			"monster": "res://data/monsters/cloaked_watchmen.tres",
			"duration_ms": 26000,
			"seed_start": 1,
			"seed_count": DEFAULT_SEED_COUNT,
			"gold": 67,
			"thresholds": {"min_win_rate": 0.30, "max_win_rate": 0.95},
		},
	]


static func _run_scenario(spec: Dictionary) -> Dictionary:
	var class_def: ClassDef = load(spec["class"])
	var monster: Monster = load(spec["monster"])
	if class_def == null or monster == null:
		var missing_path: String = spec["class"] if class_def == null else spec["monster"]
		return _failed_scenario_result(spec, "Missing resource: %s" % missing_path)

	var trees := _load_trees(spec.get("trees", []))
	var talents := _load_talents(spec.get("talents", []))
	var gear := _load_gear(spec.get("gear", []))
	var requested_skills := _load_skills(spec.get("skills", []))
	var stats := BuildResolver.resolve_stats(class_def, trees, talents, gear, int(spec.get("gold", 0)))
	var unlocked := BuildResolver.resolve_unlocked_skills(class_def, trees, talents, gear)
	var rotation := BuildResolver.resolve_rotation(requested_skills, unlocked)

	var outcomes := []
	var dps_values := []
	var total_values := []
	var poison_values := []
	var physical_values := []
	var poison_tick_counts := []
	var proc_rates := []
	var win_count := 0
	var seed_start := int(spec.get("seed_start", 1))
	var seed_count := int(spec.get("seed_count", DEFAULT_SEED_COUNT))
	for offset in range(seed_count):
		var seed := seed_start + offset
		var result := CombatResolver.resolve(rotation, stats, monster, int(spec["duration_ms"]), seed)
		var summary := _combat_summary(seed, result)
		outcomes.append(summary)
		dps_values.append(summary["dps"])
		total_values.append(summary["total_damage"])
		poison_values.append(summary["poison_damage"])
		physical_values.append(summary["physical_damage"])
		poison_tick_counts.append(summary["poison_damage_ticks"])
		proc_rates.append(summary["min_cast_proc_rate"])
		if result.is_win:
			win_count += 1

	var aggregate := {
		"dps": _distribution(dps_values),
		"total_damage": _distribution(total_values),
		"physical_damage": _distribution(physical_values),
		"poison_damage": _distribution(poison_values),
		"poison_damage_ticks": _distribution(poison_tick_counts),
		"min_cast_proc_rate": _distribution(proc_rates),
		"win_rate": float(win_count) / float(maxi(seed_count, 1)),
	}
	var status := _scenario_status(aggregate, spec.get("thresholds", {}))
	return {
		"id": spec["id"],
		"label": spec["label"],
		"status": status["status"],
		"notes": status["notes"],
		"seed_start": seed_start,
		"seed_count": seed_count,
		"duration_ms": spec["duration_ms"],
		"gold": spec.get("gold", 0),
		"monster": monster.display_name if monster != null else spec["monster"],
		"rotation": _skill_names(rotation),
		"gear": _gear_names(gear),
		"thresholds": spec.get("thresholds", {}),
		"aggregate": aggregate,
		"samples": outcomes.slice(0, mini(outcomes.size(), 24)),
	}


static func _combat_summary(seed: int, result: CombatResolver.CombatResult) -> Dictionary:
	var physical_damage := 0.0
	var poison_damage := 0.0
	var poison_damage_ticks := 0
	var cast_count := result.cast_events.size()
	var crit_count := 0
	var min_cast_proc_count := 0
	var trigger_count := 0
	var poison_stacks_applied := 0
	for event in result.cast_events:
		physical_damage += event.physical_damage
		if event.is_crit:
			crit_count += 1
		if event.min_cast_time_proc_applied:
			min_cast_proc_count += 1
		trigger_count += event.triggered_skill_names.size()
		poison_stacks_applied += event.poison_stacks_applied
	for tick in result.tick_events:
		if tick.damage > 0.0:
			poison_damage += tick.damage
			poison_damage_ticks += 1
	return {
		"seed": seed,
		"win": result.is_win,
		"total_damage": result.total_damage,
		"dps": result.dps,
		"physical_damage": physical_damage,
		"poison_damage": poison_damage,
		"poison_damage_ticks": poison_damage_ticks,
		"casts": cast_count,
		"crit_rate": float(crit_count) / float(maxi(cast_count, 1)),
		"min_cast_proc_rate": float(min_cast_proc_count) / float(maxi(cast_count, 1)),
		"trigger_count": trigger_count,
		"poison_stacks_applied": poison_stacks_applied,
	}


static func _scenario_status(aggregate: Dictionary, thresholds: Dictionary) -> Dictionary:
	var notes := []
	var status := "pass"
	_apply_min_threshold(notes, aggregate["dps"]["mean"], thresholds, "min_mean_dps", "mean DPS")
	_apply_max_threshold(notes, aggregate["dps"]["mean"], thresholds, "max_mean_dps", "mean DPS")
	_apply_min_threshold(notes, aggregate["win_rate"], thresholds, "min_win_rate", "win rate")
	_apply_max_threshold(notes, aggregate["win_rate"], thresholds, "max_win_rate", "win rate")
	_apply_min_threshold(notes, aggregate["poison_damage"]["mean"], thresholds, "min_mean_poison_damage", "mean poison damage")
	_apply_min_threshold(notes, aggregate["poison_damage_ticks"]["mean"], thresholds, "min_mean_poison_ticks", "mean poison damage ticks")
	_apply_min_threshold(notes, aggregate["min_cast_proc_rate"]["mean"], thresholds, "min_proc_rate", "mean min-cast proc rate")
	_apply_max_threshold(notes, aggregate["min_cast_proc_rate"]["mean"], thresholds, "max_proc_rate", "mean min-cast proc rate")
	if not notes.is_empty():
		status = "warn"
	return {"status": status, "notes": notes}


static func _apply_min_threshold(notes: Array, actual: float, thresholds: Dictionary, key: String, label: String) -> void:
	if not thresholds.has(key):
		return
	var expected := float(thresholds[key])
	if actual < expected:
		notes.append("%s %.3f is below %.3f" % [label, actual, expected])


static func _apply_max_threshold(notes: Array, actual: float, thresholds: Dictionary, key: String, label: String) -> void:
	if not thresholds.has(key):
		return
	var expected := float(thresholds[key])
	if actual > expected:
		notes.append("%s %.3f is above %.3f" % [label, actual, expected])


static func _distribution(values: Array) -> Dictionary:
	if values.is_empty():
		return {"count": 0, "mean": 0.0, "min": 0.0, "p05": 0.0, "p50": 0.0, "p95": 0.0, "max": 0.0}
	var sorted := values.duplicate()
	sorted.sort()
	var total := 0.0
	for value in sorted:
		total += float(value)
	return {
		"count": sorted.size(),
		"mean": total / float(sorted.size()),
		"min": sorted[0],
		"p05": _percentile(sorted, 0.05),
		"p50": _percentile(sorted, 0.50),
		"p95": _percentile(sorted, 0.95),
		"max": sorted[sorted.size() - 1],
	}


static func _percentile(sorted_values: Array, p: float) -> float:
	if sorted_values.is_empty():
		return 0.0
	var index := clampi(roundi(float(sorted_values.size() - 1) * p), 0, sorted_values.size() - 1)
	return float(sorted_values[index])


static func _numeric_check(id: String, label: String, actual: float, expected: float, tolerance: float) -> Dictionary:
	var passed := absf(actual - expected) <= tolerance
	return _check_result(id, label, "pass" if passed else "fail", "" if passed else "Expected %.4f, got %.4f" % [expected, actual], {
		"actual": actual,
		"expected": expected,
		"tolerance": tolerance,
	})


static func _boolean_check(id: String, label: String, passed: bool) -> Dictionary:
	return _check_result(id, label, "pass" if passed else "fail", "" if passed else "Expected true, got false", {"actual": passed, "expected": true})


static func _check_result(id: String, label: String, status: String, note: String, values: Dictionary) -> Dictionary:
	return {"id": id, "label": label, "status": status, "note": note, "values": values}


static func _missing_resource_check(id: String, label: String, path: String) -> Dictionary:
	return _check_result(id, label, "fail", "Missing %s" % path, {})


## Same dict shape _run_scenario() would otherwise return, so a missing
## class/monster resource surfaces as one reported "fail" scenario -- with a
## zeroed-out aggregate matching _distribution([])'s shape -- instead of
## crashing report generation or the CSV/HTML writers that read this shape.
static func _failed_scenario_result(spec: Dictionary, message: String) -> Dictionary:
	var empty_aggregate := {
		"dps": _distribution([]),
		"total_damage": _distribution([]),
		"physical_damage": _distribution([]),
		"poison_damage": _distribution([]),
		"poison_damage_ticks": _distribution([]),
		"min_cast_proc_rate": _distribution([]),
		"win_rate": 0.0,
	}
	return {
		"id": spec["id"],
		"label": spec["label"],
		"status": "fail",
		"notes": [message],
		"seed_start": int(spec.get("seed_start", 1)),
		"seed_count": 0,
		"duration_ms": spec.get("duration_ms", 0),
		"gold": spec.get("gold", 0),
		"monster": spec["monster"],
		"rotation": [],
		"gear": [],
		"thresholds": spec.get("thresholds", {}),
		"aggregate": empty_aggregate,
		"samples": [],
	}


static func _load_trees(paths: Array) -> Array[SubclassTree]:
	var resources: Array[SubclassTree] = []
	for path in paths:
		var resource: SubclassTree = load(path)
		if resource != null:
			resources.append(resource)
	return resources


static func _load_talents(paths: Array) -> Array[Talent]:
	var resources: Array[Talent] = []
	for path in paths:
		var resource: Talent = load(path)
		if resource != null:
			resources.append(resource)
	return resources


static func _load_gear(paths: Array) -> Array[GearItem]:
	var resources: Array[GearItem] = []
	for path in paths:
		var resource: GearItem = load(path)
		if resource != null:
			resources.append(resource)
	return resources


static func _load_skills(paths: Array) -> Array[Skill]:
	var resources: Array[Skill] = []
	for path in paths:
		var resource: Skill = load(path)
		if resource != null:
			resources.append(resource)
	return resources


static func _skill_names(skills: Array[Skill]) -> Array:
	var names := []
	for skill in skills:
		names.append(skill.display_name)
	return names


static func _gear_names(gear_items: Array[GearItem]) -> Array:
	var names := []
	for item in gear_items:
		names.append(item.display_name)
	return names


static func _write_text(path: String, contents: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write %s: %s" % [path, error_string(FileAccess.get_open_error())])
		return false
	file.store_string(contents)
	return true


static func _scenario_csv(report: Dictionary) -> String:
	var rows := [[
		"id", "status", "seed_count", "monster", "rotation", "gear", "mean_dps", "p05_dps",
		"p50_dps", "p95_dps", "win_rate", "mean_physical_damage", "mean_poison_damage",
		"mean_poison_ticks", "mean_min_cast_proc_rate", "notes"
	]]
	for scenario in report.get("scenarios", []):
		var aggregate: Dictionary = scenario["aggregate"]
		rows.append([
			scenario["id"],
			scenario["status"],
			scenario["seed_count"],
			scenario["monster"],
			" > ".join(scenario["rotation"]),
			", ".join(scenario["gear"]),
			aggregate["dps"]["mean"],
			aggregate["dps"]["p05"],
			aggregate["dps"]["p50"],
			aggregate["dps"]["p95"],
			aggregate["win_rate"],
			aggregate["physical_damage"]["mean"],
			aggregate["poison_damage"]["mean"],
			aggregate["poison_damage_ticks"]["mean"],
			aggregate["min_cast_proc_rate"]["mean"],
			" | ".join(scenario["notes"]),
		])
	var lines := []
	for row in rows:
		var cells := []
		for cell in row:
			cells.append(_csv_cell(cell))
		lines.append(",".join(cells))
	return "\n".join(lines) + "\n"


static func _csv_cell(value) -> String:
	var text := str(value)
	if text.contains("\""):
		text = text.replace("\"", "\"\"")
	if text.contains(",") or text.contains("\n") or text.contains("\""):
		return "\"" + text + "\""
	return text


static func _dashboard_html(report: Dictionary) -> String:
	var data := JSON.stringify(report)
	var lines := [
		"<!doctype html>",
		"<html lang=\"en\">",
		"<head>",
		"<meta charset=\"utf-8\">",
		"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">",
		"<title>DawnBringer Balance Lab</title>",
		"<style>",
		":root{color-scheme:dark;--bg:#161514;--panel:#24211d;--ink:#f0e0c2;--muted:#b9aa8e;--line:#6f6047;--good:#72c05b;--warn:#d2a23e;--bad:#d85f4c;--accent:#e0a34f;}",
		"*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:14px/1.45 system-ui,Segoe UI,sans-serif;}header{padding:22px 28px;border-bottom:1px solid var(--line);background:#1d1b18;}h1{margin:0 0 4px;font-size:26px;}h2{margin:0 0 12px;font-size:18px;}main{padding:22px 28px;display:grid;gap:18px;}section{border:1px solid var(--line);background:var(--panel);border-radius:8px;padding:16px;}table{width:100%;border-collapse:collapse;}th,td{text-align:left;padding:8px 9px;border-bottom:1px solid rgba(255,255,255,.08);vertical-align:top;}th{color:var(--muted);font-weight:600}.status{font-weight:700;text-transform:uppercase}.pass{color:var(--good)}.warn{color:var(--warn)}.fail{color:var(--bad)}.cards{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:12px}.card{border:1px solid rgba(255,255,255,.10);border-radius:8px;padding:12px;background:#1b1916}.metric{font-size:24px;font-weight:750}.muted{color:var(--muted)}.bars{display:grid;gap:10px}.bar-row{display:grid;grid-template-columns:260px 1fr 90px;gap:12px;align-items:center}.bar-track{height:14px;background:#111;border:1px solid rgba(255,255,255,.1);border-radius:3px;overflow:hidden}.bar-fill{height:100%;background:linear-gradient(90deg,var(--accent),#73bd6b)}code{color:#f5c16c}",
		"</style>",
		"</head>",
		"<body>",
		"<header><h1>DawnBringer Balance Lab</h1><div class=\"muted\">Generated <code id=\"generated\"></code> | Version <code id=\"version\"></code></div></header>",
		"<main>",
		"<section><h2>Suite Health</h2><div class=\"cards\" id=\"health\"></div></section>",
		"<section><h2>Status Semantics</h2><table><thead><tr><th>Status</th><th>Meaning</th></tr></thead><tbody id=\"status-semantics\"></tbody></table></section>",
		"<section><h2>Scenario DPS</h2><div class=\"bars\" id=\"dps-bars\"></div></section>",
		"<section><h2>Scenarios</h2><table><thead><tr><th>Status</th><th>Scenario</th><th>Monster</th><th>Mean DPS</th><th>Win Rate</th><th>Poison</th><th>Notes</th></tr></thead><tbody id=\"scenario-table\"></tbody></table></section>",
		"<section><h2>Mechanics</h2><table><thead><tr><th>Status</th><th>Check</th><th>Observed</th><th>Expected</th><th>Note</th></tr></thead><tbody id=\"mechanics-table\"></tbody></table></section>",
		"</main>",
		"<script id=\"balance-data\" type=\"application/json\">" + data + "</script>",
		"<script>",
		"const report=JSON.parse(document.getElementById('balance-data').textContent);",
		"const fmt=n=>Number(n||0).toFixed(2); const pct=n=>(Number(n||0)*100).toFixed(1)+'%';",
		"document.getElementById('generated').textContent=report.generated_at; document.getElementById('version').textContent=report.version;",
		"const counts=report.status_counts||{pass:0,warn:0,fail:0}; if(!report.status_counts){[...report.mechanics,...report.scenarios].forEach(x=>counts[x.status]=(counts[x.status]||0)+1);}",
		"document.getElementById('health').innerHTML=['pass','warn','fail'].map(k=>`<div class=\"card\"><div class=\"muted\">${k.toUpperCase()}</div><div class=\"metric ${k}\">${counts[k]||0}</div></div>`).join('');",
		"document.getElementById('status-semantics').innerHTML=Object.entries(report.status_semantics||{}).map(([k,v])=>`<tr><td class=\"status ${k}\">${k}</td><td>${v}</td></tr>`).join('');",
		"const maxDps=Math.max(1,...report.scenarios.map(s=>s.aggregate.dps.mean));",
		"document.getElementById('dps-bars').innerHTML=report.scenarios.map(s=>`<div class=\"bar-row\"><div>${s.label}<div class=\"muted\">${s.seed_count} seeds</div></div><div class=\"bar-track\"><div class=\"bar-fill\" style=\"width:${Math.max(2,s.aggregate.dps.mean/maxDps*100)}%\"></div></div><div>${fmt(s.aggregate.dps.mean)}</div></div>`).join('');",
		"document.getElementById('scenario-table').innerHTML=report.scenarios.map(s=>`<tr><td class=\"status ${s.status}\">${s.status}</td><td>${s.label}<div class=\"muted\">${s.rotation.join(' > ')}</div></td><td>${s.monster}</td><td>${fmt(s.aggregate.dps.mean)}<div class=\"muted\">p05 ${fmt(s.aggregate.dps.p05)} | p95 ${fmt(s.aggregate.dps.p95)}</div></td><td>${pct(s.aggregate.win_rate)}</td><td>${fmt(s.aggregate.poison_damage.mean)} dmg<br><span class=\"muted\">${fmt(s.aggregate.poison_damage_ticks.mean)} ticks</span></td><td>${(s.notes||[]).join('<br>')||'<span class=\"muted\">Within thresholds</span>'}</td></tr>`).join('');",
		"document.getElementById('mechanics-table').innerHTML=report.mechanics.map(m=>`<tr><td class=\"status ${m.status}\">${m.status}</td><td>${m.label}</td><td>${m.values&&m.values.actual!==undefined?m.values.actual:''}</td><td>${m.values&&m.values.expected!==undefined?m.values.expected:''}</td><td>${m.note||''}</td></tr>`).join('');",
		"</script>",
		"</body></html>",
	]
	return "\n".join(lines)
