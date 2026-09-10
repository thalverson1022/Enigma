class_name WeaponDamageCatalog
extends RefCounted

const FALLBACK_TIER := GearItem.Tier.CRUDE
const FALLBACK_REASON_MISSING := "missing_weapon"
const FALLBACK_REASON_INVALID_SLOT := "invalid_weapon_slot"
const FALLBACK_REASON_UNKNOWN_TIER := "unknown_weapon_tier"
const UNARMED_DAMAGE_RANGE := {"min": 1, "max": 1}

const DAGGER_DAMAGE_RANGES := {
	GearItem.Tier.CRUDE: {"min": 16, "max": 20},
	GearItem.Tier.BASIC: {"min": 17, "max": 19},
	GearItem.Tier.MASTER: {"min": 17, "max": 21},
	GearItem.Tier.EPIC: {"min": 18, "max": 20},
	GearItem.Tier.CURSED: {"min": 17, "max": 23},
	GearItem.Tier.CHAOS: {"min": 16, "max": 25},
	GearItem.Tier.UNIQUE: {"min": 19, "max": 25},
	GearItem.Tier.LEGENDARY: {"min": 21, "max": 27},
}


static func damage_range_for_tier(tier: int) -> Dictionary:
	if not DAGGER_DAMAGE_RANGES.has(tier):
		return _range_result(FALLBACK_TIER, "", true, FALLBACK_REASON_UNKNOWN_TIER)
	return _range_result(tier, "", false, "")


static func damage_range_for_weapon(weapon: GearItem) -> Dictionary:
	if weapon == null:
		return _fallback_range_result("", FALLBACK_REASON_MISSING)
	if weapon.slot != GearItem.SlotType.WEAPON:
		return _fallback_range_result(weapon.id, FALLBACK_REASON_INVALID_SLOT)
	if not DAGGER_DAMAGE_RANGES.has(weapon.tier):
		return _fallback_range_result(weapon.id, FALLBACK_REASON_UNKNOWN_TIER)
	return _range_result(weapon.tier, weapon.id, false, "")


static func damage_range_for_equipped_gear(equipped_gear: Array) -> Dictionary:
	for item in equipped_gear:
		if item is GearItem and item.slot == GearItem.SlotType.WEAPON:
			return damage_range_for_weapon(item)
	return damage_range_for_weapon(null)


static func _range_result(tier: int, weapon_id: String, uses_fallback: bool, fallback_reason: String) -> Dictionary:
	var range: Dictionary = DAGGER_DAMAGE_RANGES[FALLBACK_TIER if uses_fallback else tier]
	return {
		"min": int(range["min"]),
		"max": int(range["max"]),
		"tier": tier,
		"weapon_id": weapon_id,
		"uses_fallback": uses_fallback,
		"fallback_reason": fallback_reason,
	}


static func _fallback_range_result(weapon_id: String, fallback_reason: String) -> Dictionary:
	return {
		"min": int(UNARMED_DAMAGE_RANGE["min"]),
		"max": int(UNARMED_DAMAGE_RANGE["max"]),
		"tier": FALLBACK_TIER,
		"weapon_id": weapon_id,
		"uses_fallback": true,
		"fallback_reason": fallback_reason,
	}
