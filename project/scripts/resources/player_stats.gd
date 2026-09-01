class_name PlayerStats
extends Resource

@export var attack_speed: float = 0.0
@export var crit_chance: float = 0.0
@export var crit_multiplier: float = 2.0
@export var poison_damage_per_tick: float = 0.0
@export var physical_damage_multiplier: float = 1.0
@export var bonus_poison_stacks: int = 0
@export var bonus_armor_reduction: int = 0
@export var poison_tick_interval_multiplier: float = 1.0
@export var triggered_skill_effects: Array[TriggeredSkillEffect] = []
@export var bonus_physical_damage: float = 0.0
@export var min_cast_time_proc_chance: float = 0.0
@export var gold_reward_multiplier: float = 1.0
@export var current_gold: int = 0
@export var crit_chance_per_stolen_gold: float = 0.0
@export var crit_multiplier_per_current_gold: float = 0.0
