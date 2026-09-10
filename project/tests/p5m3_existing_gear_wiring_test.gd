extends SceneTree

const StatCatalog := preload("res://scripts/systems/stat_catalog.gd")
const StatSheet := preload("res://scripts/resources/stat_sheet.gd")
const SaveSystemScript := preload("res://scripts/systems/save_system.gd")
const TrainingRoomStateScript := preload("res://scripts/systems/training_room_state.gd")

const TEST_SAVE_PATH := "res://.test_p5m3_existing_gear_wiring.json"


func _initialize() -> void:
	print("-- P5M3 existing gear wiring --")
	_check_authored_gear_resolves_through_stat_sheet()
	_check_generated_gear_uses_canonical_stat_ids()
	_check_practice_room_state_uses_canonical_stat_ids()
	_check_save_load_canonicalizes_runtime_affixes()
	_check_formatter_tolerates_canonical_stat_ids()
	print("P5M3 existing gear wiring check: OK")
	quit(0)


func _check_authored_gear_resolves_through_stat_sheet() -> void:
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	var placeholder: GearItem = load("res://data/gear/placeholder_dagger.tres")
	var bandit: GearItem = load("res://data/gear/bandit_blade.tres")
	var wyvern: GearItem = load("res://data/gear/wyvern_kriss.tres")
	_require(lucky_coin != null and placeholder != null and bandit != null and wyvern != null, "Expected authored gear resources to load.")

	_require_approx(_sheet([lucky_coin]).crit_chance(), 0.05, "Expected Lucky Coin to aggregate through canonical crit_chance.")
	_require_approx(BuildResolver.resolve_stats(null, [], [], [placeholder]).attack_speed, 0.08, "Expected placeholder dagger to resolve through stat sheet.")

	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var bandit_stats := BuildResolver.resolve_stats(rogue, [], [], [bandit], 100)
	_require_approx(bandit_stats.physical_damage_multiplier, 1.2, "Expected Bandit Blade legacy physical affix compatibility.")
	_require_approx(bandit_stats.crit_chance, 0.25, "Expected Bandit Blade crit affix compatibility.")
	_require_approx(bandit_stats.bonus_physical_damage, 10.0, "Expected Bandit Blade side-channel physical damage per gold.")

	var wyvern_stats := BuildResolver.resolve_stats(rogue, [], [], [wyvern])
	_require(wyvern_stats.bonus_poison_stacks == 2, "Expected Wyvern legacy poison stacks compatibility.")
	_require_approx(wyvern_stats.poison_damage_per_tick, 11.2, "Expected Wyvern legacy poison damage multiplier compatibility.")
	_require_approx(wyvern_stats.poison_tick_interval_multiplier, 0.5, "Expected Wyvern legacy tick interval compatibility.")


func _check_generated_gear_uses_canonical_stat_ids() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 8808
	var item := GearGenerator.generate(GearItem.Tier.CURSED, GearItem.SlotType.ARMOR, rng, "gear.test.p5m3.generated")
	_require(item.affixes.size() == 4, "Expected generated Cursed gear to use the P5M5 affix count.")
	for modifier in item.affixes:
		_require(modifier.stat_id != "", "Expected generated affix to stamp stat_id.")
		_require(StatCatalog.has_stat(modifier.stat_id), "Expected generated stat_id to be canonical or compatible: %s." % modifier.stat_id)
		_require(modifier.stat_id == StatCatalog.canonical_id_for_modifier(modifier), "Expected generated stat_id to already be canonical.")
	var sheet = _sheet([item])
	_require(sheet.raw_values.size() > 0, "Expected generated gear to aggregate through StatSheet.")


func _check_practice_room_state_uses_canonical_stat_ids() -> void:
	var state = TrainingRoomStateScript.new()
	state.set_slot_rarity(state.practice_weapon, GearItem.Tier.CURSED)
	_require(state.practice_weapon.affixes.size() == 4, "Expected Practice Room Cursed weapon affixes.")
	for modifier in state.practice_weapon.affixes:
		_require(StatCatalog.has_stat(modifier.stat_id), "Expected Practice Room affix stat_id to be canonical or compatible.")
		_require(modifier.stat_id == StatCatalog.canonical_id_for_modifier(modifier), "Expected Practice Room affix stat_id to already be canonical.")
	_require(state.practice_weapon.affixes[3].is_drawback, "Expected Practice Room Cursed final affix to remain a drawback.")


func _check_save_load_canonicalizes_runtime_affixes() -> void:
	var build_state = root.get_node("BuildState")
	build_state.reset()
	SaveSystemScript.save_path = TEST_SAVE_PATH
	SaveSystemScript.delete_save()

	var old_alias_gear := {
		"id": "gear.test.p5m3.alias",
		"display_name": "Alias Gear",
		"slot": GearItem.SlotType.HELM,
		"tier": GearItem.Tier.BASIC,
		"source_kind": GearItem.SourceKind.GENERATED,
		"deterministic_key": "gear.test.p5m3.alias",
		"affixes": [{
			"stat_id": "physical_damage",
			"stat": StatModifier.StatType.PHYSICAL_DAMAGE,
			"category": StatModifier.StatCategory.BASIC,
			"operation": StatModifier.OperationType.MULTIPLY,
			"value": 1.2,
			"is_drawback": false,
		}],
	}
	_write_save({"save_version": SaveSystemScript.SAVE_VERSION, "equipped_helm": old_alias_gear})
	_require(SaveSystemScript.load_run(build_state), "Expected runtime gear with old stat_id alias to load.")
	_require(build_state.equipped_helm != null, "Expected canonicalized helm to equip.")
	_require(build_state.equipped_helm.affixes[0].stat_id == StatCatalog.PERCENT_PHYSICAL_DAMAGE, "Expected loaded affix stat_id to canonicalize.")
	_require_approx(BuildResolver.resolve_stats(null, [], [], build_state.equipped_gear()).physical_damage_multiplier, 1.2, "Expected canonicalized loaded gear to resolve.")

	_require(SaveSystemScript.save_run(build_state), "Expected canonicalized gear to save.")
	var saved := _read_save()
	_require(saved["equipped_helm"]["affixes"][0]["stat_id"] == StatCatalog.PERCENT_PHYSICAL_DAMAGE, "Expected saved affix stat_id to remain canonical.")

	SaveSystemScript.delete_save()
	SaveSystemScript.save_path = SaveSystemScript.SAVE_PATH
	build_state.reset()


func _check_formatter_tolerates_canonical_stat_ids() -> void:
	var modifier := StatModifier.new()
	modifier.stat_id = StatCatalog.CRIT_APPLIES_ELEMENT
	modifier.stat = StatModifier.StatType.CRIT_CHANCE
	modifier.operation = StatModifier.OperationType.ADD
	modifier.value = 0.25
	_require(StatModifierFormatter.format(modifier) == "+25% Chance for Crits to Apply Poison", "Expected formatter to use canonical Rare label.")

	var special := StatModifier.new()
	special.stat_id = StatCatalog.DOUBLE_APPLIED_STACKS
	special.stat = StatModifier.StatType.ATTACK_SPEED
	special.operation = StatModifier.OperationType.ADD
	special.value = 1.0
	_require(StatModifierFormatter.format(special) == "Stacks you apply are doubled", "Expected formatter to tolerate binary Special labels.")


func _sheet(equipped_gear: Array):
	var sheet = StatSheet.new()
	sheet.add_gear_collection(equipped_gear)
	sheet.finalize()
	return sheet


func _write_save(data: Dictionary) -> void:
	SaveSystemScript.delete_save()
	var file := FileAccess.open(SaveSystemScript.save_path, FileAccess.WRITE)
	_require(file != null, "Expected test save file to open for writing.")
	file.store_string(JSON.stringify(data))
	file.close()


func _read_save() -> Dictionary:
	var file := FileAccess.open(SaveSystemScript.save_path, FileAccess.READ)
	_require(file != null, "Expected test save file to open for reading.")
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	_require(typeof(parsed) == TYPE_DICTIONARY, "Expected saved JSON object.")
	return parsed


func _require(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	quit(1)


func _require_approx(actual: float, expected: float, message: String) -> void:
	_require(is_equal_approx(actual, expected), "%s Expected %.4f, got %.4f." % [message, expected, actual])
