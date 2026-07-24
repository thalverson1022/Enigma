class_name GearIcons
extends RefCounted
## Maps a GearItem to its icon texture for display in the shop, inventory,
## and equipment slots (P2:R7 gear-art pass). Named items (the 5 Rogue
## Legendaries, Lucky Coin) get their own hand-authored icon; everything
## else -- procedurally generated Basic/Master/Cursed rolls, which share one
## look per slot+tier rather than having unique art -- falls back to a
## generic icon for its slot+tier. All are transparent-background PNGs
## meant to sit on top of the existing tier-colored slot background, not
## replace it.

const BANDIT_BLADE_ICON := preload("res://assets/Items/Rogue/Bandit_Blade.png")
const BEJEWELED_PUSH_DAGGER_ICON := preload("res://assets/Items/Rogue/Bejeweled_Push_Dagger.png")
const MITHRIL_KARAMBIT_ICON := preload("res://assets/Items/Rogue/Mithril_Karambit.png")
const UMBRAL_STILETTO_ICON := preload("res://assets/Items/Rogue/Umbral_Stiletto.png")
const WYVERN_KRISS_ICON := preload("res://assets/Items/Rogue/Wyvern_Kriss.png")
const LUCKY_COIN_ICON := preload("res://assets/Items/Rogue/Lucky_Coin.png")

const BASIC_WEAPON_ICON := preload("res://assets/Items/Rogue/Basic Weapon.png")
const MASTER_WEAPON_ICON := preload("res://assets/Items/Rogue/Master_Weapon.png")
const CURSED_WEAPON_ICON := preload("res://assets/Items/Rogue/Cursed_Weapon.png")
const BASIC_TRINKET_ICON := preload("res://assets/Items/Rogue/Basic_Trinket.png")
const MASTER_TRINKET_ICON := preload("res://assets/Items/Rogue/Master_Trinket.png")
const CURSED_TRINKET_ICON := preload("res://assets/Items/Rogue/Cursed_Trinket.png")
const BASIC_CHARM_ICON := preload("res://assets/Items/Rogue/Basic_Charm.png")
const MASTER_CHARM_ICON := preload("res://assets/Items/Rogue/Master_Charm.png")
const CURSED_CHARM_ICON := preload("res://assets/Items/Rogue/Cursed_Charm.png")

## Keyed by GearItem.id -- only items with real, hand-authored art. Procedurally
## generated gear never matches one of these (its id is generated per-roll),
## so it always falls through to GENERIC_ICONS below.
const NAMED_ICONS := {
	"gear.legendary.bandit_blade": BANDIT_BLADE_ICON,
	"gear.legendary.bejeweled_push_dagger": BEJEWELED_PUSH_DAGGER_ICON,
	"gear.legendary.mithril_karambit": MITHRIL_KARAMBIT_ICON,
	"gear.legendary.umbral_stiletto": UMBRAL_STILETTO_ICON,
	"gear.legendary.wyvern_kriss": WYVERN_KRISS_ICON,
	"gear.lucky_coin": LUCKY_COIN_ICON,
}

## [slot][tier] -> icon, for any item without its own named art above.
## No Legendary entries here -- every Legendary is a named item.
const GENERIC_ICONS := {
	GearItem.SlotType.WEAPON: {
		GearItem.Tier.BASIC: BASIC_WEAPON_ICON,
		GearItem.Tier.MASTER: MASTER_WEAPON_ICON,
		GearItem.Tier.CURSED: CURSED_WEAPON_ICON,
	},
	GearItem.SlotType.TRINKET: {
		GearItem.Tier.BASIC: BASIC_TRINKET_ICON,
		GearItem.Tier.MASTER: MASTER_TRINKET_ICON,
		GearItem.Tier.CURSED: CURSED_TRINKET_ICON,
	},
	GearItem.SlotType.CHARM: {
		GearItem.Tier.BASIC: BASIC_CHARM_ICON,
		GearItem.Tier.MASTER: MASTER_CHARM_ICON,
		GearItem.Tier.CURSED: CURSED_CHARM_ICON,
	},
}


## Returns null for anything unmapped (e.g. a Legendary trinket/charm, which
## doesn't exist yet, or a future non-Rogue item) -- callers should keep the
## plain tier-colored square as a safe fallback in that case, same as before
## this icon pass existed.
static func icon_for(gear: GearItem) -> Texture2D:
	if gear == null:
		return null
	if NAMED_ICONS.has(gear.id):
		return NAMED_ICONS[gear.id]
	var slot_icons: Dictionary = GENERIC_ICONS.get(gear.slot, {})
	return slot_icons.get(gear.tier, null)
