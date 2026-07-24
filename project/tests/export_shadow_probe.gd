extends SceneTree


func _initialize() -> void:
	var rogue: ClassDef = load("res://data/classes/rogue.tres")
	var shadow: SubclassTree = load("res://data/subclass_trees/shadow.tres")
	var mouthy: Monster = load("res://data/monsters/mouthy_drunk.tres")
	var trees: Array[SubclassTree] = [shadow]
	var talents: Array[Talent] = []
	var skills: Array[Skill] = BuildResolver.resolve_unlocked_skills(rogue, trees, talents)
	var stab: Skill = null
	for skill in skills:
		if skill.id == "skill.stab":
			stab = skill
			break
	var poison_effects := 0
	if stab != null:
		for effect in stab.effects:
			if effect is PoisonDamageEffect:
				poison_effects += 1
	var rotation: Array[Skill] = [stab]
	var result: CombatResolver.CombatResult = CombatResolver.resolve(rotation, BuildResolver.resolve_stats(rogue, trees, talents), mouthy, 12000, 1)
	var poison_ticks := 0
	for tick in result.tick_events:
		if tick.damage > 0.0:
			poison_ticks += 1
	var file := FileAccess.open("user://export_shadow_probe.txt", FileAccess.WRITE)
	file.store_line("run_ticks_msec=%d" % Time.get_ticks_msec())
	file.store_line("poison_effects=%d" % poison_effects)
	file.store_line("first_cast_stacks=%d" % result.cast_events[0].poison_stacks_applied)
	file.store_line("poison_ticks=%d" % poison_ticks)
	file.store_line("total_damage=%.1f" % result.total_damage)
	quit(0 if poison_effects == 1 and result.cast_events[0].poison_stacks_applied == 1 and poison_ticks > 0 else 1)
