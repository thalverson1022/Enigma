class_name TriggeredSkillEffect
extends Resource

@export var skill: Skill
@export_range(0.0, 1.0, 0.01) var chance: float = 0.0
@export var source_skill_ids: PackedStringArray = []
