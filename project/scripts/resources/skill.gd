class_name Skill
extends Resource

@export var id: String = ""
@export var display_name: String = ""
## Short glyph shown on macro slot boxes (stand-in until skills get icons).
@export var icon_letter: String = ""
@export var base_execution_ms: int = 0
@export var min_execution_ms: int = 0
@export var effects: Array[SkillEffect] = []
