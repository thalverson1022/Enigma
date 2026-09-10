class_name LegendaryCatalog
extends RefCounted
## Single source of truth for the full set of Phase 1 Rogue Legendary gear
## paths (P2:R9). Both the Tavern shop's low-chance Legendary roll
## (`build_state.gd`'s `SHOP_LEGENDARY_PATHS`) and Practice Room's direct
## Legendary-equip control (`P2:R10:T3`) need "all 5 Legendaries" -- this
## exists so that list is authored once, not duplicated in two places.

const WeaponDamageCatalog := preload("res://scripts/systems/weapon_damage_catalog.gd")

static func all_paths() -> Array[String]:
	return [
		"res://data/gear/wyvern_kriss.tres",
		"res://data/gear/mithril_karambit.tres",
		"res://data/gear/bandit_blade.tres",
		"res://data/gear/umbral_stiletto.tres",
		"res://data/gear/bejeweled_push_dagger.tres",
	]


static func all_items() -> Array[GearItem]:
	var items: Array[GearItem] = []
	for path in all_paths():
		items.append(load(path))
	return items


static func effect_text(item: GearItem) -> String:
	if item == null:
		return ""
	match item.id:
		"gear.legendary.mithril_karambit":
			return "Stab/Heavy Slash have a 50% chance to retrigger"
		"gear.legendary.bandit_blade":
			return "+1 physical damage per 10 gold in stash"
		"gear.legendary.wyvern_kriss":
			return "Poison ticks twice as fast"
		"gear.legendary.umbral_stiletto":
			return "Unlocks Death Strike"
		"gear.legendary.bejeweled_push_dagger":
			return "20% chance for skills to cast lightning fast"
	return ""


static func tooltip_lines(item: GearItem) -> PackedStringArray:
	var lines: PackedStringArray = []
	if item == null:
		return lines
	lines.append(item.display_name)
	lines.append("%s %s / %s" % [
		GearGenerator.tier_name(item.tier),
		GearGenerator.universal_slot_label(item.slot),
		GearGenerator.item_family_for(item),
	])
	var damage_range := WeaponDamageCatalog.damage_range_for_weapon(item)
	lines.append("Weapon Damage: %d-%d" % [int(damage_range["min"]), int(damage_range["max"])])
	var stat_lines: PackedStringArray = []
	for affix in item.affixes:
		if affix.stat == StatModifier.StatType.POISON_TICK_INTERVAL:
			continue
		stat_lines.append(StatModifierFormatter.format(affix))
	if not stat_lines.is_empty():
		lines.append("Stats:")
		lines.append_array(stat_lines)
	var text := effect_text(item)
	if text != "":
		lines.append("Legendary:")
		lines.append(text)
	return lines
