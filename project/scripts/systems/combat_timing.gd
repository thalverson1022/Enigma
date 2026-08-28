class_name CombatTiming
extends RefCounted


static func execution_time_ms(skill: Skill, attack_speed: float) -> int:
	var scaled_ms: float = float(skill.base_execution_ms) / (1.0 + attack_speed)
	return int(ceil(max(float(skill.min_execution_ms), scaled_ms)))


static func execution_time_ms_with_slow(skill: Skill, attack_speed: float, slow: float) -> int:
	var slowed_ms: float = float(execution_time_ms(skill, attack_speed)) * (1.0 + maxf(slow, 0.0))
	return int(ceil(max(float(skill.min_execution_ms), slowed_ms)))
