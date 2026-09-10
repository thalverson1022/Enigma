extends SceneTree
## Samples generated contract bosses and replays benchmark rogue builds into them.
## Run with:
##   godot --headless --path project -s res://scripts/tools/generated_balance_investigation.gd

const ROUTE_GENERATOR := preload("res://scripts/systems/contract_route_generator/contract_route_generator.gd")

const OUTPUT_DIR := "res://reports/balance/latest"
const DEFAULT_ROUTE_DIFFICULTY := "medium"
const DEFAULT_SAMPLE_COUNT := 80
const DEFAULT_MAX_COMPLETED_CONTRACTS := 6
const FIXED_WINDOW_MS := 30000


func _initialize() -> void:
	var options := _parse_options(OS.get_cmdline_user_args())
	var sample_count := int(options.get("samples", DEFAULT_SAMPLE_COUNT))
	var max_completed_contracts := int(options.get("max-completed", DEFAULT_MAX_COMPLETED_CONTRACTS))
	var route_difficulty := String(options.get("difficulty", DEFAULT_ROUTE_DIFFICULTY)).to_lower()
	var seed_base := int(options.get("seed-base", 91001))
	var report := _run_investigation(route_difficulty, sample_count, max_completed_contracts, seed_base)
	_write_report(report, ProjectSettings.globalize_path(OUTPUT_DIR))
	print("Generated balance investigation complete.")
	print("Markdown: %s/generated_balance_investigation.md" % ProjectSettings.globalize_path(OUTPUT_DIR))
	print("JSON: %s/generated_balance_investigation.json" % ProjectSettings.globalize_path(OUTPUT_DIR))
	quit()


func _run_investigation(route_difficulty: String, sample_count: int, max_completed_contracts: int, seed_base: int) -> Dictionary:
	var builds := _benchmark_builds()
	var report := {
		"version": "generated-balance-investigation.v1",
		"generated_at": Time.get_datetime_string_from_system(),
		"settings": {
			"route_difficulty": route_difficulty,
			"samples_per_contract_count": sample_count,
			"max_completed_contracts": max_completed_contracts,
			"seed_base": seed_base,
			"fixed_window_ms": FIXED_WINDOW_MS,
		},
		"builds": _build_specs_for_report(builds),
		"encounter_samples": [],
		"boss_samples": [],
		"combat_samples": [],
		"aggregates": [],
		"mechanic_pressure": [],
		"archetype_pressure": [],
	}
	for completed_count in range(max_completed_contracts + 1):
		for sample_index in range(sample_count):
			var seed := seed_base + completed_count * 10000 + sample_index
			var contract: ContractDef = ROUTE_GENERATOR.generate(seed, {
				"route_difficulty": route_difficulty,
				"completed_contract_count": completed_count,
			})
			for node in _collect_nodes(contract.offer_node):
				if node.generated_encounter_payload.is_empty():
					continue
				var node_draft := GeneratedMonsterDraft.from_dictionary(node.generated_encounter_payload)
				report["encounter_samples"].append(_encounter_sample_row(contract, node, node_draft, completed_count, seed, sample_index))
			var boss := _first_node_of_type(contract.offer_node, ContractRouteNode.NodeType.BOSS)
			if boss == null or boss.generated_encounter_payload.is_empty():
				continue
			var draft := GeneratedMonsterDraft.from_dictionary(boss.generated_encounter_payload)
			var monster := draft.to_monster()
			var boss_row := _boss_sample_row(contract, boss, draft, completed_count, seed, sample_index)
			report["boss_samples"].append(boss_row)
			for build in builds:
				report["combat_samples"].append(_combat_sample_row(build, boss_row, monster, draft, seed, false))
				report["combat_samples"].append(_combat_sample_row(build, boss_row, monster, draft, seed, true))
	report["aggregates"] = _aggregate_builds(report["combat_samples"])
	report["mechanic_pressure"] = _aggregate_mechanics(report["combat_samples"], "mechanic_ids")
	report["archetype_pressure"] = _aggregate_mechanics(report["combat_samples"], "archetype_ids")
	return report


func _benchmark_builds() -> Array:
	return [
		_make_build(
			"blade_dancer",
			"Blade Dancer",
			"res://data/subclass_trees/bladedancer.tres",
			[
				"res://data/talents/bladedancer/piercing_blades.tres",
				"res://data/talents/bladedancer/quick_hands.tres",
				"res://data/talents/bladedancer/practiced_rhythm.tres",
			],
			[
				_item(GearItem.SlotType.WEAPON, "Dagger", "Weapon +4 Base Damage", StatCatalog.BASE_DAMAGE, 4.0),
				_item(GearItem.SlotType.HELM, "", "Helm +6% Crit Chance", StatCatalog.CRIT_CHANCE, 0.06),
				_item(GearItem.SlotType.ARMOR, "", "Chest +1 Bonus Stacks", StatCatalog.INCREASED_ALL_STACKS, 1.0),
				_item(GearItem.SlotType.TRINKET, "", "Trinket +9% Attack Speed", StatCatalog.INCREASED_ATTACK_SPEED, 0.09),
				_item(GearItem.SlotType.CHARM, "", "Charm +50% Crit Damage", StatCatalog.CRIT_DAMAGE, 0.50),
			],
			["res://data/skills/rending_slash.tres", "res://data/skills/quick_cut.tres", "res://data/skills/quick_cut.tres"]
		),
		_make_build(
			"assassin",
			"Assassin",
			"res://data/subclass_trees/assassin.tres",
			[
				"res://data/talents/assassin/venom_edge.tres",
				"res://data/talents/assassin/precise_cuts.tres",
				"res://data/talents/assassin/lethal_intent.tres",
			],
			[
				_item(GearItem.SlotType.WEAPON, "Dagger", "Weapon +5 Base Elemental Damage", StatCatalog.BASE_ELEMENTAL_DAMAGE, 5.0),
				_item(GearItem.SlotType.HELM, "", "Helm +6 Base Elemental Damage", StatCatalog.BASE_ELEMENTAL_DAMAGE, 6.0),
				_item(GearItem.SlotType.ARMOR, "", "Chest +4% Crit Chance", StatCatalog.CRIT_CHANCE, 0.04),
				_item(GearItem.SlotType.TRINKET, "", "Trinket +7 Base Elemental Damage", StatCatalog.BASE_ELEMENTAL_DAMAGE, 7.0),
				_item(GearItem.SlotType.CHARM, "", "Charm +12% Attack Speed", StatCatalog.INCREASED_ATTACK_SPEED, 0.12),
			],
			["res://data/skills/venom_jab.tres", "res://data/skills/heavy_slash.tres", "res://data/skills/heavy_slash.tres", "res://data/skills/heavy_slash.tres"]
		),
		_make_build(
			"shadow",
			"Shadow",
			"res://data/subclass_trees/shadow.tres",
			[
				"res://data/talents/shadow/lingering_venom.tres",
				"res://data/talents/shadow/exposed_weakness.tres",
				"res://data/talents/shadow/black_lotus.tres",
			],
			[
				_item(GearItem.SlotType.WEAPON, "Dagger", "Weapon +23% Physical Damage", StatCatalog.PERCENT_PHYSICAL_DAMAGE, 0.23),
				_item(GearItem.SlotType.HELM, "", "Helm +5% Crit Chance", StatCatalog.CRIT_CHANCE, 0.05),
				_item(GearItem.SlotType.ARMOR, "", "Chest +2 Bonus Stacks", StatCatalog.INCREASED_ALL_STACKS, 2.0),
				_item(GearItem.SlotType.TRINKET, "", "Trinket +5 Base Damage", StatCatalog.BASE_DAMAGE, 5.0),
				_item(GearItem.SlotType.CHARM, "", "Charm +12% Attack Speed", StatCatalog.INCREASED_ATTACK_SPEED, 0.12),
			],
			["res://data/skills/stab.tres", "res://data/skills/death_strike.tres"]
		),
		_make_build(
			"thief",
			"Thief",
			"res://data/subclass_trees/thief.tres",
			[
				"res://data/talents/thief/keen_eye.tres",
				"res://data/talents/thief/sticky_fingers.tres",
				"res://data/talents/thief/silvered_blade.tres",
			],
			[
				_item(GearItem.SlotType.WEAPON, "Dagger", "Weapon +4 Base Damage", StatCatalog.BASE_DAMAGE, 4.0),
				_item(GearItem.SlotType.HELM, "", "Helm +5% Crit Chance", StatCatalog.CRIT_CHANCE, 0.05),
				_item(GearItem.SlotType.ARMOR, "", "Chest +5% Crit Chance", StatCatalog.CRIT_CHANCE, 0.05),
				_item(GearItem.SlotType.TRINKET, "", "Trinket +5 Base Damage", StatCatalog.BASE_DAMAGE, 5.0),
				_item(GearItem.SlotType.CHARM, "", "Charm +12% Attack Speed", StatCatalog.INCREASED_ATTACK_SPEED, 0.12),
			],
			["res://data/skills/steal.tres"]
		),
	]


func _make_build(id: String, label: String, tree_path: String, talent_paths: Array, gear_input: Array, rotation_paths: Array) -> Dictionary:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var tree: SubclassTree = load(tree_path)
	var talents: Array[Talent] = []
	for path in talent_paths:
		talents.append(load(String(path)))
	var gear: Array[GearItem] = []
	for item in gear_input:
		gear.append(item as GearItem)
	var rotation_input: Array[Skill] = []
	for path in rotation_paths:
		rotation_input.append(load(String(path)))
	var selected_trees: Array[SubclassTree] = [tree]
	var stats := BuildResolver.resolve_stats(rogue, selected_trees, talents, gear, 0)
	var unlocked := BuildResolver.resolve_unlocked_skills(rogue, selected_trees, talents, gear)
	var rotation := BuildResolver.resolve_rotation(rotation_input, unlocked)
	return {
		"id": id,
		"label": label,
		"talent_paths": talent_paths.duplicate(true),
		"gear_labels": _gear_labels(gear),
		"rotation_skill_ids": _skill_ids(rotation),
		"stats": stats,
		"rotation": rotation,
	}


func _item(slot: int, family: String, label: String, stat_id: String, value: float) -> GearItem:
	var item := GearItem.new()
	item.id = "probe.%s.%s" % [str(slot), stat_id]
	item.display_name = label
	item.slot = slot
	item.item_family = family
	item.tier = GearItem.Tier.CRUDE
	item.source_kind = GearItem.SourceKind.GENERATED
	var modifier := StatModifier.new()
	modifier.stat_id = stat_id
	modifier.value = value
	modifier.operation = StatModifier.OperationType.ADD
	modifier.category = StatModifier.StatCategory.BASIC
	modifier.display_label = label
	item.affixes = [modifier]
	return item


func _boss_sample_row(contract: ContractDef, boss: ContractRouteNode, draft: GeneratedMonsterDraft, completed_count: int, seed: int, sample_index: int) -> Dictionary:
	var row := _encounter_sample_row(contract, boss, draft, completed_count, seed, sample_index)
	row["boss_variant_id"] = boss.boss_variant_id
	row["boss_variant_label"] = boss.boss_variant_label
	return row


func _encounter_sample_row(contract: ContractDef, node: ContractRouteNode, draft: GeneratedMonsterDraft, completed_count: int, seed: int, sample_index: int) -> Dictionary:
	var pressure: Dictionary = draft.pressure_metadata
	var budget: Dictionary = draft.budget_metadata
	var scale: Dictionary = boss_debug_pressure_scale(node)
	return {
		"contract_number": completed_count + 1,
		"completed_contract_count": completed_count,
		"sample_index": sample_index,
		"seed": seed,
		"route_difficulty": contract.route_difficulty,
		"template_id": contract.template_id,
		"node_id": node.generated_node_id,
		"node_type": _node_type_label(node.node_type),
		"node_depth": node.depth,
		"node_lane": node.lane,
		"boss_variant_id": "",
		"boss_variant_label": "",
		"monster_id": draft.id,
		"monster_name": draft.display_name,
		"hp": draft.hp,
		"duration_ms": draft.duration_ms,
		"duration_sec": float(draft.duration_ms) / 1000.0,
		"hp_budget_duration_sec": float(pressure.get("hp_budget_duration_sec", float(draft.duration_ms) / 1000.0)),
		"target_dps": draft.target_dps,
		"required_dps": float(pressure.get("required_dps", 0.0)),
		"effective_hp": int(pressure.get("effective_hp", 0)),
		"base_hp_before_contract_scaling": int(pressure.get("base_hp_before_contract_scaling", draft.hp)),
		"contract_hp_multiplier": float(pressure.get("contract_hp_multiplier", 1.0)),
		"contract_dps_multiplier": float(pressure.get("contract_dps_multiplier", 1.0)),
		"target_dps_range": pressure.get("target_dps_range", []),
		"mitigation_multiplier": float(pressure.get("mitigation_multiplier", 1.0)),
		"pressure_status": String(pressure.get("status", "")),
		"raw_difficulty_id": int(_payload_source_input(draft).get("difficulty_id", 0)),
		"route_pressure_scale": scale,
		"scale_raw_difficulty_id": int(scale.get("raw_difficulty_id", 0)),
		"scale_monster_difficulty_id": int(scale.get("monster_difficulty_id", 0)),
		"scale_content_difficulty_id": int(scale.get("content_difficulty_id", 0)),
		"depth_bonus": int(scale.get("depth_bonus", 0)),
		"node_level_bonus": int(scale.get("node_level_bonus", 0)),
		"completed_contract_pressure_bonus": int(scale.get("completed_contract_pressure_bonus", 0)),
		"archetype_ids": _array_from_packed(draft.archetype_ids),
		"mechanic_ids": _mechanic_ids(draft.selected_mechanics),
		"selected_mechanics": draft.selected_mechanics.duplicate(true),
		"defense_overrides": draft.defense_overrides.duplicate(true),
		"budget": int(budget.get("budget", 0)),
		"total_cost": int(budget.get("total_cost", 0)),
		"budget_delta": int(budget.get("budget_delta", 0)),
		"major_defense_count": int(budget.get("major_defense_count", 0)),
	}


func _combat_sample_row(build: Dictionary, boss_row: Dictionary, monster: Monster, draft: GeneratedMonsterDraft, route_seed: int, fixed_window: bool) -> Dictionary:
	var duration_ms := FIXED_WINDOW_MS if fixed_window else draft.duration_ms
	var combat_seed := route_seed * 17 + int(hash(build["id"])) + (31 if fixed_window else 0)
	var result := CombatResolver.resolve(build["rotation"], build["stats"], monster, duration_ms, combat_seed)
	var summary := _combat_summary(result)
	return {
		"window": "fixed_30s" if fixed_window else "generated_duration",
		"contract_number": int(boss_row["contract_number"]),
		"completed_contract_count": int(boss_row["completed_contract_count"]),
		"seed": int(boss_row["seed"]),
		"build_id": String(build["id"]),
		"build_label": String(build["label"]),
		"boss_variant_id": String(boss_row["boss_variant_id"]),
		"boss_variant_label": String(boss_row["boss_variant_label"]),
		"archetype_ids": (boss_row["archetype_ids"] as Array).duplicate(true),
		"mechanic_ids": (boss_row["mechanic_ids"] as Array).duplicate(true),
		"hp": int(boss_row["hp"]),
		"duration_ms": duration_ms,
		"generated_duration_ms": draft.duration_ms,
		"target_dps": float(boss_row["target_dps"]),
		"required_dps": float(boss_row["required_dps"]),
		"total_damage": result.total_damage,
		"dps": result.dps,
		"is_win": result.is_win,
		"damage_gap": result.total_damage - float(boss_row["hp"]),
		"required_dps_gap": result.dps - float(boss_row["required_dps"]),
		"summary": summary,
	}


func _combat_summary(result: CombatResolver.CombatResult) -> Dictionary:
	var physical := 0.0
	var blocked := 0.0
	var crit_prevented := 0.0
	var dodges := 0
	var cleanses := 0
	var interrupts := 0
	var stuns_ms := 0
	var casts := result.cast_events.size()
	for event in result.cast_events:
		physical += event.physical_damage
		blocked += event.blocked_amount
		crit_prevented += event.crit_negation_damage_prevented
		dodges += event.dodged_attacks
		cleanses += 1 if event.cleanse_triggered else 0
		interrupts += 1 if event.was_interrupted else 0
		stuns_ms += event.stun_duration_ms
	var poison := 0.0
	var absorbed := 0.0
	var poison_ticks := 0
	var max_stacks := 0
	var tick_interval_ms := 0
	for tick in result.tick_events:
		poison += tick.damage
		absorbed += tick.absorbed_amount
		poison_ticks += 1 if tick.had_active_stack else 0
		max_stacks = maxi(max_stacks, tick.stacks_remaining)
		tick_interval_ms = maxi(tick_interval_ms, tick.tick_interval_ms)
	return {
		"physical_damage": physical,
		"poison_damage": poison,
		"blocked_damage": blocked,
		"crit_negated_damage": crit_prevented,
		"absorbed_damage": absorbed,
		"dodges": dodges,
		"cleanses": cleanses,
		"interrupts": interrupts,
		"stuns_ms": stuns_ms,
		"casts": casts,
		"poison_ticks": poison_ticks,
		"max_poison_stacks": max_stacks,
		"tick_interval_ms": tick_interval_ms,
	}


func _aggregate_builds(rows: Array) -> Array:
	var groups := {}
	for row in rows:
		var key := "%s|%s|%d" % [String(row["window"]), String(row["build_id"]), int(row["contract_number"])]
		if not groups.has(key):
			groups[key] = _new_aggregate(row)
		_add_sample(groups[key], row)
	var result := []
	for key in groups:
		result.append(_finalize_aggregate(groups[key]))
	result.sort_custom(func(a: Dictionary, b: Dictionary): return int(a["contract_number"]) < int(b["contract_number"]) if int(a["contract_number"]) != int(b["contract_number"]) else String(a["build_label"]) < String(b["build_label"]) if String(a["build_label"]) != String(b["build_label"]) else String(a["window"]) < String(b["window"]))
	return result


func _aggregate_mechanics(rows: Array, field: String) -> Array:
	var groups := {}
	for row in rows:
		if String(row["window"]) != "generated_duration":
			continue
		for id in row[field]:
			var key := "%s|%d|%s|%s" % [field, int(row["contract_number"]), String(row["build_id"]), String(id)]
			if not groups.has(key):
				var group := _new_aggregate(row)
				group["pressure_id"] = String(id)
				group["field"] = field
				groups[key] = group
			_add_sample(groups[key], row)
	var result := []
	for key in groups:
		var finalized := _finalize_aggregate(groups[key])
		finalized["pressure_id"] = groups[key]["pressure_id"]
		finalized["field"] = groups[key]["field"]
		result.append(finalized)
	result.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["win_rate"]) < float(b["win_rate"]) if not is_equal_approx(float(a["win_rate"]), float(b["win_rate"])) else float(a["avg_required_dps_gap"]) < float(b["avg_required_dps_gap"]))
	return result


func _new_aggregate(row: Dictionary) -> Dictionary:
	return {
		"window": String(row["window"]),
		"contract_number": int(row["contract_number"]),
		"completed_contract_count": int(row["completed_contract_count"]),
		"build_id": String(row["build_id"]),
		"build_label": String(row["build_label"]),
		"samples": 0,
		"wins": 0,
		"damage_values": [],
		"dps_values": [],
		"required_dps_values": [],
		"required_dps_gaps": [],
		"damage_gaps": [],
		"blocked": 0.0,
		"absorbed": 0.0,
		"crit_prevented": 0.0,
		"dodges": 0,
		"cleanses": 0,
		"interrupts": 0,
		"stuns_ms": 0,
	}


func _add_sample(group: Dictionary, row: Dictionary) -> void:
	group["samples"] = int(group["samples"]) + 1
	group["wins"] = int(group["wins"]) + (1 if bool(row["is_win"]) else 0)
	group["damage_values"].append(float(row["total_damage"]))
	group["dps_values"].append(float(row["dps"]))
	group["required_dps_values"].append(float(row["required_dps"]))
	group["required_dps_gaps"].append(float(row["required_dps_gap"]))
	group["damage_gaps"].append(float(row["damage_gap"]))
	var summary: Dictionary = row["summary"]
	group["blocked"] = float(group["blocked"]) + float(summary.get("blocked_damage", 0.0))
	group["absorbed"] = float(group["absorbed"]) + float(summary.get("absorbed_damage", 0.0))
	group["crit_prevented"] = float(group["crit_prevented"]) + float(summary.get("crit_negated_damage", 0.0))
	group["dodges"] = int(group["dodges"]) + int(summary.get("dodges", 0))
	group["cleanses"] = int(group["cleanses"]) + int(summary.get("cleanses", 0))
	group["interrupts"] = int(group["interrupts"]) + int(summary.get("interrupts", 0))
	group["stuns_ms"] = int(group["stuns_ms"]) + int(summary.get("stuns_ms", 0))


func _finalize_aggregate(group: Dictionary) -> Dictionary:
	var samples := int(group["samples"])
	return {
		"window": String(group["window"]),
		"contract_number": int(group["contract_number"]),
		"completed_contract_count": int(group["completed_contract_count"]),
		"build_id": String(group["build_id"]),
		"build_label": String(group["build_label"]),
		"samples": samples,
		"wins": int(group["wins"]),
		"win_rate": _ratio(int(group["wins"]), samples),
		"avg_damage": _average(group["damage_values"]),
		"damage_variance": _variance(group["damage_values"]),
		"avg_dps": _average(group["dps_values"]),
		"dps_variance": _variance(group["dps_values"]),
		"avg_required_dps": _average(group["required_dps_values"]),
		"avg_required_dps_gap": _average(group["required_dps_gaps"]),
		"avg_damage_gap": _average(group["damage_gaps"]),
		"avg_blocked_damage": float(group["blocked"]) / maxf(1.0, float(samples)),
		"avg_absorbed_damage": float(group["absorbed"]) / maxf(1.0, float(samples)),
		"avg_crit_negated_damage": float(group["crit_prevented"]) / maxf(1.0, float(samples)),
		"avg_dodges": float(group["dodges"]) / maxf(1.0, float(samples)),
		"avg_cleanses": float(group["cleanses"]) / maxf(1.0, float(samples)),
		"avg_interrupts": float(group["interrupts"]) / maxf(1.0, float(samples)),
		"avg_stun_seconds": (float(group["stuns_ms"]) / 1000.0) / maxf(1.0, float(samples)),
	}


func _write_report(report: Dictionary, output_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(output_dir)
	_write_text(output_dir + "/generated_balance_investigation.json", JSON.stringify(report, "\t"))
	_write_text(output_dir + "/generated_balance_encounter_samples.csv", _encounter_csv(report["encounter_samples"]))
	_write_text(output_dir + "/generated_balance_boss_samples.csv", _boss_csv(report["boss_samples"]))
	_write_text(output_dir + "/generated_balance_combat_samples.csv", _combat_csv(report["combat_samples"]))
	_write_text(output_dir + "/generated_balance_build_matrix.csv", _aggregate_csv(report["aggregates"]))
	_write_text(output_dir + "/generated_balance_mechanic_pressure.csv", _pressure_csv(report["mechanic_pressure"]))
	_write_text(output_dir + "/generated_balance_archetype_pressure.csv", _pressure_csv(report["archetype_pressure"]))
	_write_text(output_dir + "/generated_balance_investigation.md", _markdown(report))


func _markdown(report: Dictionary) -> String:
	var settings: Dictionary = report["settings"]
	var lines := PackedStringArray()
	lines.append("# Generated Balance Investigation")
	lines.append("")
	lines.append("- Route difficulty: `%s`" % String(settings["route_difficulty"]))
	lines.append("- Samples per contract count: %d" % int(settings["samples_per_contract_count"]))
	lines.append("- Contract numbers covered: C1-C%d" % (int(settings["max_completed_contracts"]) + 1))
	lines.append("- Fixed comparison window: %.1fs" % (float(settings["fixed_window_ms"]) / 1000.0))
	lines.append("")
	lines.append("## Build Matrix")
	lines.append("")
	lines.append("| Window | Contract | Build | Samples | Avg DPS | Required DPS | DPS Gap | Avg Damage | Damage Gap | Win Rate |")
	lines.append("| --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
	for row in report["aggregates"]:
		lines.append("| %s | C%d | %s | %d | %.2f | %.2f | %.2f | %.2f | %.2f | %.1f%% |" % [
			String(row["window"]),
			int(row["contract_number"]),
			String(row["build_label"]),
			int(row["samples"]),
			float(row["avg_dps"]),
			float(row["avg_required_dps"]),
			float(row["avg_required_dps_gap"]),
			float(row["avg_damage"]),
			float(row["avg_damage_gap"]),
			float(row["win_rate"]) * 100.0,
		])
	lines.append("")
	lines.append("## Encounter Pressure")
	lines.append("")
	lines.append("| Contract | Type | Samples | Avg Required DPS | Min | Max | Avg HP | Avg Duration | Over Band |")
	lines.append("| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
	for row in _encounter_pressure_summary(report["encounter_samples"]):
		lines.append("| C%d | %s | %d | %.2f | %.2f | %.2f | %.1f | %.1fs | %.1f%% |" % [
			int(row["contract_number"]),
			String(row["node_type"]),
			int(row["samples"]),
			float(row["avg_required_dps"]),
			float(row["min_required_dps"]),
			float(row["max_required_dps"]),
			float(row["avg_hp"]),
			float(row["avg_duration_sec"]),
			float(row["over_band_rate"]) * 100.0,
		])
	lines.append("")
	lines.append("## Worst Mechanics")
	lines.append("")
	lines.append("| Contract | Build | Mechanic | Samples | Win Rate | DPS Gap | Blocked | Absorbed | Cleanses | Interrupts | Stun Sec |")
	lines.append("| ---: | --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |")
	var limit := mini(24, (report["mechanic_pressure"] as Array).size())
	for index in range(limit):
		var row: Dictionary = report["mechanic_pressure"][index]
		lines.append("| C%d | %s | `%s` | %d | %.1f%% | %.2f | %.1f | %.1f | %.2f | %.2f | %.2f |" % [
			int(row["contract_number"]),
			String(row["build_label"]),
			String(row["pressure_id"]),
			int(row["samples"]),
			float(row["win_rate"]) * 100.0,
			float(row["avg_required_dps_gap"]),
			float(row["avg_blocked_damage"]),
			float(row["avg_absorbed_damage"]),
			float(row["avg_cleanses"]),
			float(row["avg_interrupts"]),
			float(row["avg_stun_seconds"]),
		])
	lines.append("")
	lines.append("## Files")
	lines.append("")
	lines.append("- `generated_balance_investigation.json`")
	lines.append("- `generated_balance_encounter_samples.csv`")
	lines.append("- `generated_balance_boss_samples.csv`")
	lines.append("- `generated_balance_combat_samples.csv`")
	lines.append("- `generated_balance_build_matrix.csv`")
	lines.append("- `generated_balance_mechanic_pressure.csv`")
	lines.append("- `generated_balance_archetype_pressure.csv`")
	return "\n".join(lines)


func _boss_csv(rows: Array) -> String:
	var lines := PackedStringArray(["contract_number,completed_contract_count,seed,template_id,node_depth,boss_variant_id,boss_variant_label,monster_name,hp,base_hp_before_contract_scaling,contract_hp_multiplier,contract_dps_multiplier,duration_sec,hp_budget_duration_sec,target_dps,required_dps,effective_hp,mitigation_multiplier,pressure_status,archetype_ids,mechanic_ids,defense_overrides,budget,total_cost,budget_delta,major_defense_count"])
	for row in rows:
		lines.append(_csv([
			row["contract_number"], row["completed_contract_count"], row["seed"], row["template_id"], row["node_depth"],
			row["boss_variant_id"], row["boss_variant_label"], row["monster_name"], row["hp"],
			row["base_hp_before_contract_scaling"], row["contract_hp_multiplier"], row["contract_dps_multiplier"],
			row["duration_sec"], row["hp_budget_duration_sec"],
			row["target_dps"], row["required_dps"], row["effective_hp"], row["mitigation_multiplier"], row["pressure_status"],
			";".join(row["archetype_ids"]), ";".join(row["mechanic_ids"]), JSON.stringify(row["defense_overrides"]),
			row["budget"], row["total_cost"], row["budget_delta"], row["major_defense_count"],
		]))
	return "\n".join(lines)


func _encounter_csv(rows: Array) -> String:
	var lines := PackedStringArray(["contract_number,completed_contract_count,seed,template_id,node_id,node_type,node_depth,node_lane,monster_name,hp,base_hp_before_contract_scaling,contract_hp_multiplier,contract_dps_multiplier,duration_sec,hp_budget_duration_sec,target_dps,required_dps,effective_hp,mitigation_multiplier,pressure_status,raw_difficulty_id,scale_raw_difficulty_id,scale_monster_difficulty_id,scale_content_difficulty_id,depth_bonus,node_level_bonus,completed_contract_pressure_bonus,archetype_ids,mechanic_ids,defense_overrides,budget,total_cost,budget_delta,major_defense_count"])
	for row in rows:
		lines.append(_csv([
			row["contract_number"], row["completed_contract_count"], row["seed"], row["template_id"], row["node_id"], row["node_type"],
			row["node_depth"], row["node_lane"], row["monster_name"], row["hp"],
			row["base_hp_before_contract_scaling"], row["contract_hp_multiplier"], row["contract_dps_multiplier"],
			row["duration_sec"], row["hp_budget_duration_sec"], row["target_dps"],
			row["required_dps"], row["effective_hp"], row["mitigation_multiplier"], row["pressure_status"], row["raw_difficulty_id"],
			row["scale_raw_difficulty_id"], row["scale_monster_difficulty_id"], row["scale_content_difficulty_id"],
			row["depth_bonus"], row["node_level_bonus"], row["completed_contract_pressure_bonus"],
			";".join(row["archetype_ids"]), ";".join(row["mechanic_ids"]), JSON.stringify(row["defense_overrides"]),
			row["budget"], row["total_cost"], row["budget_delta"], row["major_defense_count"],
		]))
	return "\n".join(lines)


func _combat_csv(rows: Array) -> String:
	var lines := PackedStringArray(["window,contract_number,seed,build_id,build_label,boss_variant_id,archetype_ids,mechanic_ids,hp,duration_ms,target_dps,required_dps,total_damage,dps,is_win,damage_gap,required_dps_gap,blocked_damage,absorbed_damage,crit_negated_damage,dodges,cleanses,interrupts,stuns_ms"])
	for row in rows:
		var summary: Dictionary = row["summary"]
		lines.append(_csv([
			row["window"], row["contract_number"], row["seed"], row["build_id"], row["build_label"], row["boss_variant_id"],
			";".join(row["archetype_ids"]), ";".join(row["mechanic_ids"]), row["hp"], row["duration_ms"], row["target_dps"],
			row["required_dps"], row["total_damage"], row["dps"], row["is_win"], row["damage_gap"], row["required_dps_gap"],
			summary.get("blocked_damage", 0.0), summary.get("absorbed_damage", 0.0), summary.get("crit_negated_damage", 0.0),
			summary.get("dodges", 0), summary.get("cleanses", 0), summary.get("interrupts", 0), summary.get("stuns_ms", 0),
		]))
	return "\n".join(lines)


func _aggregate_csv(rows: Array) -> String:
	var lines := PackedStringArray(["window,contract_number,build_id,build_label,samples,wins,win_rate,avg_damage,damage_variance,avg_dps,dps_variance,avg_required_dps,avg_required_dps_gap,avg_damage_gap,avg_blocked_damage,avg_absorbed_damage,avg_crit_negated_damage,avg_dodges,avg_cleanses,avg_interrupts,avg_stun_seconds"])
	for row in rows:
		lines.append(_csv([
			row["window"], row["contract_number"], row["build_id"], row["build_label"], row["samples"], row["wins"], row["win_rate"],
			row["avg_damage"], row["damage_variance"], row["avg_dps"], row["dps_variance"], row["avg_required_dps"],
			row["avg_required_dps_gap"], row["avg_damage_gap"], row["avg_blocked_damage"], row["avg_absorbed_damage"],
			row["avg_crit_negated_damage"], row["avg_dodges"], row["avg_cleanses"], row["avg_interrupts"], row["avg_stun_seconds"],
		]))
	return "\n".join(lines)


func _pressure_csv(rows: Array) -> String:
	var lines := PackedStringArray(["field,pressure_id,contract_number,build_id,build_label,samples,wins,win_rate,avg_dps,avg_required_dps,avg_required_dps_gap,avg_damage_gap,avg_blocked_damage,avg_absorbed_damage,avg_crit_negated_damage,avg_dodges,avg_cleanses,avg_interrupts,avg_stun_seconds"])
	for row in rows:
		lines.append(_csv([
			row["field"], row["pressure_id"], row["contract_number"], row["build_id"], row["build_label"], row["samples"], row["wins"], row["win_rate"],
			row["avg_dps"], row["avg_required_dps"], row["avg_required_dps_gap"], row["avg_damage_gap"],
			row["avg_blocked_damage"], row["avg_absorbed_damage"], row["avg_crit_negated_damage"], row["avg_dodges"],
			row["avg_cleanses"], row["avg_interrupts"], row["avg_stun_seconds"],
		]))
	return "\n".join(lines)


func _first_node_of_type(node: ContractRouteNode, node_type: int, visited: Dictionary = {}) -> ContractRouteNode:
	if node == null:
		return null
	var key := node.generated_node_id if node.generated_node_id != "" else node.id
	if visited.has(key):
		return null
	visited[key] = true
	if node.node_type == node_type:
		return node
	for next in node.next_nodes:
		var found := _first_node_of_type(next, node_type, visited)
		if found != null:
			return found
	return null


func _collect_nodes(start: ContractRouteNode) -> Array[ContractRouteNode]:
	var result: Array[ContractRouteNode] = []
	var visited := {}
	_collect_nodes_recursive(start, visited, result)
	return result


func _collect_nodes_recursive(node: ContractRouteNode, visited: Dictionary, result: Array[ContractRouteNode]) -> void:
	if node == null:
		return
	var key := node.generated_node_id if node.generated_node_id != "" else node.id
	if visited.has(key):
		return
	visited[key] = true
	result.append(node)
	for next in node.next_nodes:
		_collect_nodes_recursive(next, visited, result)


func boss_debug_pressure_scale(node: ContractRouteNode) -> Dictionary:
	return (node.debug_preview.get("route_pressure_scale", {}) as Dictionary).duplicate(true)


func _node_type_label(node_type: int) -> String:
	match node_type:
		ContractRouteNode.NodeType.START:
			return "start"
		ContractRouteNode.NodeType.ELITE:
			return "elite"
		ContractRouteNode.NodeType.BOSS:
			return "boss"
		ContractRouteNode.NodeType.FIGHT:
			return "fight"
		ContractRouteNode.NodeType.CAPTAIN:
			return "captain"
		ContractRouteNode.NodeType.OFFER:
			return "offer"
		ContractRouteNode.NodeType.SUBCLASS_CHOICE:
			return "subclass_choice"
	return "unknown"


func _encounter_pressure_summary(rows: Array) -> Array:
	var groups := {}
	for row in rows:
		var key := "%d|%s" % [int(row["contract_number"]), String(row["node_type"])]
		if not groups.has(key):
			groups[key] = {
				"contract_number": int(row["contract_number"]),
				"node_type": String(row["node_type"]),
				"samples": 0,
				"over_band": 0,
				"required": [],
				"hp": [],
				"duration_sec": [],
			}
		var group: Dictionary = groups[key]
		group["samples"] = int(group["samples"]) + 1
		group["over_band"] = int(group["over_band"]) + (1 if String(row["pressure_status"]) == "over_band" else 0)
		group["required"].append(float(row["required_dps"]))
		group["hp"].append(float(row["hp"]))
		group["duration_sec"].append(float(row["duration_sec"]))
	var result := []
	for key in groups:
		var group: Dictionary = groups[key]
		result.append({
			"contract_number": group["contract_number"],
			"node_type": group["node_type"],
			"samples": group["samples"],
			"avg_required_dps": _average(group["required"]),
			"min_required_dps": _minimum(group["required"]),
			"max_required_dps": _maximum(group["required"]),
			"avg_hp": _average(group["hp"]),
			"avg_duration_sec": _average(group["duration_sec"]),
			"over_band_rate": _ratio(int(group["over_band"]), int(group["samples"])),
		})
	result.sort_custom(func(a: Dictionary, b: Dictionary): return int(a["contract_number"]) < int(b["contract_number"]) if int(a["contract_number"]) != int(b["contract_number"]) else String(a["node_type"]) < String(b["node_type"]))
	return result


func _build_specs_for_report(builds: Array) -> Array:
	var result := []
	for build in builds:
		result.append({
			"id": build["id"],
			"label": build["label"],
			"talent_paths": build["talent_paths"],
			"gear_labels": build["gear_labels"],
			"rotation_skill_ids": build["rotation_skill_ids"],
		})
	return result


func _payload_source_input(draft: GeneratedMonsterDraft) -> Dictionary:
	return draft.source_input.to_dictionary() if draft.source_input != null else {}


func _gear_labels(gear: Array) -> Array:
	var result := []
	for item in gear:
		result.append(item.display_name)
	return result


func _skill_ids(skills: Array) -> Array:
	var result := []
	for skill in skills:
		result.append(skill.id)
	return result


func _mechanic_ids(mechanics: Array) -> Array:
	var result := []
	for mechanic in mechanics:
		result.append(String(mechanic.get("id", "")))
	return result


func _array_from_packed(values: PackedStringArray) -> Array:
	var result := []
	for value in values:
		result.append(value)
	return result


func _average(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var total := 0.0
	for value in values:
		total += float(value)
	return total / float(values.size())


func _variance(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var avg := _average(values)
	var total := 0.0
	for value in values:
		var delta := float(value) - avg
		total += delta * delta
	return total / float(values.size())


func _minimum(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var result := float(values[0])
	for value in values:
		result = minf(result, float(value))
	return result


func _maximum(values: Array) -> float:
	if values.is_empty():
		return 0.0
	var result := float(values[0])
	for value in values:
		result = maxf(result, float(value))
	return result


func _ratio(numerator: int, denominator: int) -> float:
	if denominator <= 0:
		return 0.0
	return float(numerator) / float(denominator)


func _csv(values: Array) -> String:
	var cells := PackedStringArray()
	for value in values:
		cells.append(_csv_cell(value))
	return ",".join(cells)


func _csv_cell(value: Variant) -> String:
	var text := String.num(float(value), 4) if value is float else str(value)
	if text.contains("\""):
		text = text.replace("\"", "\"\"")
	if text.contains(",") or text.contains("\"") or text.contains("\n"):
		text = "\"%s\"" % text
	return text


func _write_text(path: String, text: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write %s: %s" % [path, FileAccess.get_open_error()])
		return
	file.store_string(text)


func _parse_options(args: PackedStringArray) -> Dictionary:
	var options := {}
	for arg in args:
		var text := String(arg)
		if not text.begins_with("--"):
			continue
		var body := text.substr(2)
		var split_at := body.find("=")
		if split_at == -1:
			options[body] = "true"
		else:
			options[body.substr(0, split_at)] = body.substr(split_at + 1)
	return options
