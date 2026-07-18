class_name EncounterReward
extends Resource

@export var gold_amount: int = 0
@export var talent_points: int = 0
@export var fixed_gear_rewards: Array[GearItem] = []
@export var gear_choice_rewards: Array[GearItem] = []
@export var unlocks_shop: bool = false
@export var generated_gear_choice_count: int = 0
@export var generated_gear_tier: GearItem.Tier = GearItem.Tier.BASIC
@export var generated_gear_slots: Array[int] = []
