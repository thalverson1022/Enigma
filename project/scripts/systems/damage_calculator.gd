class_name DamageCalculator
extends RefCounted


static func physical_mitigation_multiplier(armor: int) -> float:
	if armor >= 0:
		var reduction: float = (0.75 * armor) / (armor + 100.0)
		return 1.0 - reduction
	var vulnerability: float = (0.75 * absf(armor)) / (absf(armor) + 100.0)
	return 1.0 + vulnerability


static func magical_mitigation_multiplier(resistance: float) -> float:
	return 1.0 - clampf(resistance, 0.0, 1.0)


static func poison_mitigation_multiplier(poison_resistance: float) -> float:
	return magical_mitigation_multiplier(poison_resistance)


## Resolves one direct-hit physical damage effect: crit roll, crit negation,
## armor mitigation, then block. Dodge is handled by CombatResolver so the
## whole attack can skip attached effects.
## Returns {"amount": float, "is_crit": bool, "blocked_amount": float,
## "crit_negation_applied": float, "crit_negation_damage_prevented": float}.
static func resolve_physical_hit(raw_amount: float, armor: int, crit_chance: float, crit_multiplier: float, rng: RandomNumberGenerator, physical_damage_multiplier: float = 1.0, crit_negation: float = 0.0, block: float = 0.0) -> Dictionary:
	var is_crit: bool = rng.randf() < clampf(crit_chance, 0.0, 1.0)
	var amount: float = raw_amount * (crit_multiplier if is_crit else 1.0)
	var before_negation_final := 0.0
	var crit_negation_applied := 0.0
	if is_crit and crit_negation > 0.0:
		var before_negation := amount
		amount *= 1.0 - clampf(crit_negation, 0.0, 1.0)
		crit_negation_applied = before_negation - amount
		before_negation_final = maxf(0.0, before_negation * physical_damage_multiplier * physical_mitigation_multiplier(armor) - maxf(block, 0.0))
	amount *= physical_damage_multiplier
	amount *= physical_mitigation_multiplier(armor)
	var before_block := amount
	amount = maxf(0.0, amount - maxf(block, 0.0))
	return {
		"amount": amount,
		"is_crit": is_crit,
		"blocked_amount": before_block - amount,
		"crit_negation_applied": crit_negation_applied,
		"crit_negation_damage_prevented": maxf(0.0, before_negation_final - amount),
	}


static func resolve_magical_damage(raw_amount: float, resistance: float, absorb: float = 0.0) -> Dictionary:
	var after_resistance := raw_amount * magical_mitigation_multiplier(resistance)
	var amount := maxf(0.0, after_resistance - maxf(absorb, 0.0))
	return {
		"amount": amount,
		"absorbed_amount": after_resistance - amount,
	}


## Poison ticks do not crit.
static func resolve_poison_tick(poison_damage_per_tick: float, poison_resistance: float) -> float:
	return resolve_magical_damage(poison_damage_per_tick, poison_resistance)["amount"]
