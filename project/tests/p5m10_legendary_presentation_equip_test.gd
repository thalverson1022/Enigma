extends SceneTree
## Focused P5M10-T5 checks for retained Legendary item presentation, icon
## overrides, reward auto-equip behavior, and Practice Room equip routing.

var _failed := false


func _initialize() -> void:
	print("-- P5M10 Legendary presentation/equip --")
	var build_state = root.get_node("BuildState")
	build_state.reset(true)

	_check_all_legendary_cards()
	_check_named_icon_overrides()
	_check_inventory_and_direct_equip(build_state)
	_check_reward_auto_equip(build_state)
	_check_practice_room_legendary_equip()

	build_state.reset(true)
	if _failed:
		print("P5M10 Legendary presentation/equip: FAILED")
		quit(1)
	print("P5M10 Legendary presentation/equip: OK")
	quit(0)


func _check_all_legendary_cards() -> void:
	for spec in _legendary_specs():
		var item: GearItem = load(String(spec["path"]))
		_require("%s loads" % spec["name"], item != null)
		var lines := CardStyle.gear_tooltip_lines(item)
		var text := "\n".join(lines)
		_require("%s card starts with name" % spec["name"], text.begins_with(String(spec["name"])))
		_require("%s card shows Legendary Weapon / Dagger" % spec["name"], text.contains("Legendary Weapon / Dagger"))
		_require("%s card shows weapon damage" % spec["name"], text.contains("Weapon Damage: 21-27"))
		_require("%s card shows Stats heading" % spec["name"], text.contains("Stats:"))
		_require("%s card shows Legendary heading" % spec["name"], text.contains("Legendary:"))
		_require("%s card shows effect text" % spec["name"], text.contains(String(spec["effect"])))
		for stat_line in spec["stat_lines"]:
			_require("%s card shows %s" % [spec["name"], stat_line], text.contains(String(stat_line)))
		_require("%s card hides metadata" % spec["name"], _hides_metadata(text, item))
		if item.id == "gear.legendary.wyvern_kriss":
			_require("Wyvern hides implementation cadence affix", not text.contains("Poison Tick Interval"))


func _check_named_icon_overrides() -> void:
	for spec in _legendary_specs():
		var item: GearItem = load(String(spec["path"]))
		_require("%s icon override" % spec["name"], _icon_path(item) == String(spec["icon"]))
	var lucky_coin: GearItem = load("res://data/gear/lucky_coin.tres")
	_require("Lucky Coin icon remains named override", _icon_path(lucky_coin) == "res://assets/Items/Rogue/Lucky_Coin.png")
	var generated := GearItem.new()
	generated.id = "gear.test.p5m10.generated_legendary"
	generated.display_name = "Generated Legendary"
	generated.slot = GearItem.SlotType.WEAPON
	generated.tier = GearItem.Tier.LEGENDARY
	generated.item_family = "Dagger"
	generated.class_family = GearItem.ClassFamily.ROGUE
	_require("Generated Legendary-like gear uses fallback", _icon_path(generated) == "res://assets/ui/icons/gear_drop_helm_legendary.png")


func _check_inventory_and_direct_equip(build_state) -> void:
	for spec in _legendary_specs():
		build_state.reset(true)
		var item: GearItem = load(String(spec["path"]))
		_require("Inventory add %s" % spec["name"], build_state.add_inventory_item(item))
		_require("Inventory equip %s" % spec["name"], build_state.equip_from_inventory(item))
		_require("Equipped weapon is %s" % spec["name"], build_state.equipped_weapon == item)
		_require("Legendary leaves inventory on equip %s" % spec["name"], not build_state.has_inventory_item(item))
		var replacement: GearItem = load("res://data/gear/crude_dagger.tres")
		build_state.equip(replacement)
		_require("Replacing %s moves it to inventory" % spec["name"], build_state.has_inventory_item(item))


func _check_reward_auto_equip(build_state) -> void:
	for spec in _legendary_specs():
		build_state.reset(true)
		var item: GearItem = load(String(spec["path"]))
		build_state.pending_reward_choices.clear()
		build_state.pending_reward_choices.append(item)
		_require("Reward can choose %s" % spec["name"], build_state.can_choose_pending_reward_gear(item))
		_require("Reward chooses %s" % spec["name"], build_state.choose_pending_reward_gear(item))
		_require("Reward auto-equips %s" % spec["name"], build_state.equipped_weapon == item)
		_require("Reward clears pending %s" % spec["name"], not build_state.has_pending_reward_choice())
		_require("Reward does not store %s" % spec["name"], not build_state.has_inventory_item(item))


func _check_practice_room_legendary_equip() -> void:
	var state := TrainingRoomState.new()
	for spec in _legendary_specs():
		var item: GearItem = load(String(spec["path"]))
		state.equip_legendary(item)
		_require("Practice Room equips %s" % spec["name"], state.equipped_weapon == item)
		_require("Practice Room reports Legendary for %s" % spec["name"], state.is_weapon_legendary())
		_require("Practice Room icon resolves for %s" % spec["name"], GearIcons.icon_for(state.equipped_weapon) != null)
	state.use_custom_weapon()
	_require("Practice Room returns to editable weapon", not state.is_weapon_legendary())


func _legendary_specs() -> Array[Dictionary]:
	return [
		{
			"name": "Wyvern Kriss",
			"path": "res://data/gear/wyvern_kriss.tres",
			"icon": "res://assets/Items/Rogue/Wyvern_Kriss.png",
			"effect": "Poison ticks twice as fast",
			"stat_lines": ["+8 Base Elemental Damage", "+40% Percent Elemental Damage", "+12% Chance to Decay"],
		},
		{
			"name": "Bandit Blade",
			"path": "res://data/gear/bandit_blade.tres",
			"icon": "res://assets/Items/Rogue/Bandit_Blade.png",
			"effect": "+1 physical damage per 10 gold in stash",
			"stat_lines": ["+20% Percent Physical Damage", "+12% Crit Chance", "+30% Increased Gold"],
		},
		{
			"name": "Umbral Stiletto",
			"path": "res://data/gear/umbral_stiletto.tres",
			"icon": "res://assets/Items/Rogue/Umbral_Stiletto.png",
			"effect": "Unlocks Death Strike",
			"stat_lines": ["+10% Crit Chance", "+100% Crit Damage", "+100% Chance for Crits to Apply Poison"],
		},
		{
			"name": "Mithril Karambit",
			"path": "res://data/gear/mithril_karambit.tres",
			"icon": "res://assets/Items/Rogue/Mithril_Karambit.png",
			"effect": "Stab/Heavy Slash have a 50% chance to retrigger",
			"stat_lines": ["+15% Increased Attack Speed", "+15% Crit Chance", "+20% Chance to Shred"],
		},
		{
			"name": "Bejeweled Push Dagger",
			"path": "res://data/gear/bejeweled_push_dagger.tres",
			"icon": "res://assets/Items/Rogue/Bejeweled_Push_Dagger.png",
			"effect": "20% chance for skills to cast lightning fast",
			"stat_lines": ["+8 Base Damage", "+20% Percent Physical Damage", "+10% Crit Chance"],
		},
	]


func _icon_path(item: GearItem) -> String:
	var texture := GearIcons.icon_for(item)
	_require("Icon texture exists", texture != null)
	return texture.resource_path if texture != null else ""


func _hides_metadata(text: String, item: GearItem) -> bool:
	return (
		not text.contains(item.id)
		and not text.contains(item.resource_path)
		and not text.contains("source_kind")
		and not text.contains("deterministic_key")
		and not text.contains("source_context")
		and not text.contains("source_seed")
	)


func _require(label: String, condition: bool) -> void:
	if condition:
		return
	_failed = true
	print("FAILED: %s" % label)
