class_name RunRng
extends RefCounted

const CONTEXT_COMBAT := "combat"
const CONTEXT_SHOP_OFFER := "shop_offer"
const CONTEXT_REWARD_CHOICE := "reward_choice"

const _FNV_OFFSET := 2166136261
const _FNV_PRIME := 16777619
const _UINT32_MOD := 4294967296


static func rng_for_context(adventure_seed: int, context: String, parts: Array = []) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_for_context(adventure_seed, context, parts)
	return rng


static func seed_for_context(adventure_seed: int, context: String, parts: Array = []) -> int:
	var key := "%d|%s" % [adventure_seed, context]
	for part in parts:
		key += "|%s" % _stable_part(part)
	return _stable_hash(key)


static func id_for_context(prefix: String, adventure_seed: int, context: String, parts: Array = []) -> String:
	return "%s_%d" % [prefix, seed_for_context(adventure_seed, context, parts)]


static func _stable_hash(text: String) -> int:
	var value := _FNV_OFFSET
	for i in text.length():
		value = int((value ^ text.unicode_at(i)) * _FNV_PRIME) % _UINT32_MOD
	return max(1, value)


static func _stable_part(part: Variant) -> String:
	match typeof(part):
		TYPE_NIL:
			return "null"
		TYPE_BOOL:
			return "true" if part else "false"
		TYPE_FLOAT:
			return "%.9f" % part
		_:
			return str(part)
