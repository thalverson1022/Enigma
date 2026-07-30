class_name Skill
extends Resource

@export var id: String = ""
@export var display_name: String = ""
## Preferred compact art for skill buttons and macro slot boxes.
@export var icon: Texture2D
## Short fallback glyph shown when no icon has been assigned yet.
@export var icon_letter: String = ""
@export var base_execution_ms: int = 0
@export var min_execution_ms: int = 0
@export var poison_stacks_applied: int = 0
@export var effects: Array[SkillEffect] = []
