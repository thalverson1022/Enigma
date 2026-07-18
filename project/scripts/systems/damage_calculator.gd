class_name DamageCalculator
extends RefCounted


static func physical_mitigation_multiplier(armor: int) -> float:
	if armor >= 0:
		var reduction: float = (0.75 * armor) / (armor + 100.0)
		return 1.0 - reduction
	var vulnerability: float = (0.75 * absf(armor)) / (absf(armor) + 100.0)
	return 1.0 + vulnerability


static func poison_mitigation_multiplier(poison_resistance: float) -> float:
	return 1.0 - clampf(poison_resistance, 0.0, 1.0)


## Resolves one direct-hit physical damage effect: crit roll, then armor mitigation.
## Returns {"amount": float, "is_crit": bool}.
static func resolve_physical_hit(raw_amount: float, armor: int, crit_chance: float, crit_multiplier: float, rng: RandomNumberGenerator, physical_damage_multiplier: float = 1.0) -> Dictionary:
	var is_crit: bool = rng.randf() < crit_chance
	var amount: float = raw_amount * (crit_multiplier if is_crit else 1.0)
	amount *= physical_damage_multiplier
	amount *= physical_mitigation_multiplier(armor)
	return {"amount": amount, "is_crit": is_crit}


## Poison ticks do not crit.
static func resolve_poison_tick(poison_damage_per_tick: float, poison_resistance: float) -> float:
	return poison_damage_per_tick * poison_mitigation_multiplier(poison_resistance)
