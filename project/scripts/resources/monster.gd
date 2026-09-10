class_name Monster
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var combat_role: String = "normal"
@export var hp: int = 0
@export var armor: int = 0
@export var poison_resistance: float = 0.0
@export_range(0.0, 1.0, 0.01) var dodge_chance: float = 0.0
@export_range(0.0, 1.0, 0.01) var crit_negation: float = 0.0
@export var block: float = 0.0
@export var absorb: float = 0.0
@export var cleanse_threshold: int = 0
@export_range(0.0, 10.0, 0.01) var suppress: float = 0.0
@export_range(0.0, 10.0, 0.01) var slow: float = 0.0
@export var stun_duration_ms: int = 0
@export var interrupt_skip_count: int = 0
