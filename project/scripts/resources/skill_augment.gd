class_name SkillAugment
extends Resource

@export var target_skill_ids: PackedStringArray = []
@export var extra_effects: Array[SkillEffect] = []
## Export-stable primitive fallback for augments that add poison stacks.
## Nested custom Resource arrays can be brittle in release exports; this
## field lets BuildResolver materialize the effect at runtime.
@export var poison_stacks_applied: int = 0
