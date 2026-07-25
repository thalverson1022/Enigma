class_name LegendaryCatalog
extends RefCounted
## Single source of truth for the full set of Phase 1 Rogue Legendary gear
## paths (P2:R9). Both the Tavern shop's low-chance Legendary roll
## (`build_state.gd`'s `SHOP_LEGENDARY_PATHS`) and Training Room's direct
## Legendary-equip control (`P2:R10:T3`) need "all 5 Legendaries" -- this
## exists so that list is authored once, not duplicated in two places.

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
			return "Stab/Heavy Slash have a 20% chance to retrigger"
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
	lines.append("%s - %s" % [GearGenerator.SLOT_TAGS[item.slot], item.display_name])
	for affix in item.affixes:
		if affix.stat == StatModifier.StatType.POISON_TICK_INTERVAL:
			continue
		lines.append(StatModifierFormatter.format(affix))
	var text := effect_text(item)
	if text != "":
		lines.append(text)
	return lines
