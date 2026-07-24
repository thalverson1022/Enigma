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
