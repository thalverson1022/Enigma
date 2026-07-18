class_name Talent
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var cost: int = 1
@export var prerequisites: Array[PrerequisiteGroup] = []
@export var stat_modifiers: Array[StatModifier] = []
@export var unlocked_skills: Array[Skill] = []
@export var triggered_skill_effects: Array[TriggeredSkillEffect] = []
