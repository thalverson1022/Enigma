extends RefCounted

const BASIC_HIT := "m1_t1_basic_hit"
const GUARANTEED_CRIT := "m1_t1_guaranteed_crit"
const POISON_STACK_TICK := "m1_t1_poison_stack_tick"
const ARMOR_REDUCTION := "m1_t1_armor_reduction"
const POISON_RESIST_REDUCTION := "m1_t1_poison_resist_reduction"
const TRIGGERED_SKILL := "m1_t1_triggered_skill"
const MIN_CAST_PROC := "m1_t1_min_cast_proc"
const SLOW_PHYSICAL_CAST := "m1_t1_slow_physical_cast"
const FAST_PHYSICAL_CAST := "m1_t1_fast_physical_cast"
const POISON_APPLYING_CAST := "m1_t1_poison_applying_cast"
const VICTORY_REVEAL := "m1_t1_victory_reveal"
const DEFEAT_REVEAL := "m1_t1_defeat_reveal"


static func ids() -> PackedStringArray:
	return PackedStringArray([
		BASIC_HIT,
		GUARANTEED_CRIT,
		POISON_STACK_TICK,
		ARMOR_REDUCTION,
		POISON_RESIST_REDUCTION,
		TRIGGERED_SKILL,
		MIN_CAST_PROC,
		SLOW_PHYSICAL_CAST,
		FAST_PHYSICAL_CAST,
		POISON_APPLYING_CAST,
		VICTORY_REVEAL,
		DEFEAT_REVEAL,
	])


static func build(id: String) -> Dictionary:
	match id:
		BASIC_HIT:
			return _scenario(
				id,
				"Basic physical hit",
				[_skill("stab")],
				_player(),
				_monster("Basic Hit Dummy", 100000, 0, 0.0),
				2200,
				PackedStringArray(["cast", "physical_hit"])
			)
		GUARANTEED_CRIT:
			var crit_player := _player()
			crit_player.crit_chance = 1.0
			return _scenario(
				id,
				"Guaranteed crit",
				[_skill("stab")],
				crit_player,
				_monster("Crit Dummy", 100000, 0, 0.0),
				2200,
				PackedStringArray(["cast", "physical_hit", "crit"])
			)
		POISON_STACK_TICK:
			var poison_player := _player()
			poison_player.poison_damage_per_tick = 5.0
			return _scenario(
				id,
				"Poison stack and tick",
				[_skill("poison_strike")],
				poison_player,
				_monster("Poison Dummy", 100000, 0, 0.0),
				4500,
				PackedStringArray(["cast", "physical_hit", "poison_stack", "poison_tick"])
			)
		ARMOR_REDUCTION:
			return _scenario(
				id,
				"Armor reduction",
				[_skill("rending_slash")],
				_player(),
				_monster("Armored Dummy", 100000, 120, 0.0),
				3200,
				PackedStringArray(["cast", "physical_hit", "armor_reduction"])
			)
		POISON_RESIST_REDUCTION:
			return _scenario(
				id,
				"Poison resistance reduction",
				[_skill("beguiling_strike")],
				_player(),
				_monster("Resistant Dummy", 100000, 0, 0.6),
				3600,
				PackedStringArray(["cast", "physical_hit", "poison_resist_reduction"])
			)
		TRIGGERED_SKILL:
			var trigger_player := _player()
			var trigger := TriggeredSkillEffect.new()
			trigger.skill = _skill("heavy_slash")
			trigger.chance = 1.0
			trigger.source_skill_ids = PackedStringArray(["skill.stab"])
			trigger_player.triggered_skill_effects = [trigger]
			return _scenario(
				id,
				"Triggered skill",
				[_skill("stab")],
				trigger_player,
				_monster("Triggered Dummy", 100000, 0, 0.0),
				2200,
				PackedStringArray(["cast", "physical_hit", "triggered_skill"])
			)
		MIN_CAST_PROC:
			var proc_player := _player()
			proc_player.min_cast_time_proc_chance = 1.0
			return _scenario(
				id,
				"Minimum-cast proc",
				[_skill("stab")],
				proc_player,
				_monster("Proc Dummy", 100000, 0, 0.0),
				1200,
				PackedStringArray(["cast", "physical_hit", "min_cast_proc", "fast_cast"])
			)
		SLOW_PHYSICAL_CAST:
			return _scenario(
				id,
				"Slow physical cast",
				[_skill("heavy_slash")],
				_player(),
				_monster("Slow Cast Dummy", 100000, 0, 0.0),
				2600,
				PackedStringArray(["cast", "physical_hit", "slow_cast"])
			)
		FAST_PHYSICAL_CAST:
			return _scenario(
				id,
				"Fast physical cast",
				[_skill("quick_cut")],
				_player(),
				_monster("Fast Cast Dummy", 100000, 0, 0.0),
				1200,
				PackedStringArray(["cast", "physical_hit", "fast_cast"])
			)
		POISON_APPLYING_CAST:
			var poison_cast_player := _player()
			poison_cast_player.poison_damage_per_tick = 5.0
			return _scenario(
				id,
				"Poison-applying cast",
				[_skill("poison_strike")],
				poison_cast_player,
				_monster("Poison Cast Dummy", 100000, 0, 0.0),
				2200,
				PackedStringArray(["cast", "physical_hit", "poison_stack", "poison_cast"])
			)
		VICTORY_REVEAL:
			return _scenario(
				id,
				"Victory reveal",
				[_skill("quick_cut")],
				_player(),
				_monster("Victory Dummy", 10, 0, 0.0),
				3000,
				PackedStringArray(["cast", "physical_hit", "victory"])
			)
		DEFEAT_REVEAL:
			return _scenario(
				id,
				"Defeat reveal",
				[_skill("stab")],
				_player(),
				_monster("Defeat Dummy", 100000, 0, 0.0),
				3000,
				PackedStringArray(["cast", "physical_hit", "defeat"])
			)
	return {}


static func _scenario(
	id: String,
	label: String,
	rotation: Array[Skill],
	player: PlayerStats,
	monster: Monster,
	duration_ms: int,
	tags: PackedStringArray
) -> Dictionary:
	var result := CombatResolver.resolve(rotation, player, monster, duration_ms, 3)
	return {
		"id": id,
		"label": label,
		"rotation": rotation,
		"player": player,
		"monster": monster,
		"duration_ms": duration_ms,
		"result": result,
		"tags": tags,
	}


static func _skill(path_name: String) -> Skill:
	return load("res://data/skills/%s.tres" % path_name)


static func _player() -> PlayerStats:
	var player := PlayerStats.new()
	player.attack_speed = 0.0
	player.crit_chance = 0.0
	player.crit_multiplier = 2.0
	player.poison_damage_per_tick = 0.0
	return player


static func _monster(display_name: String, hp: int, armor: int, poison_resistance: float) -> Monster:
	var monster := Monster.new()
	monster.display_name = display_name
	monster.hp = hp
	monster.armor = armor
	monster.poison_resistance = poison_resistance
	return monster
