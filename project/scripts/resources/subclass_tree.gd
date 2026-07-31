class_name SubclassTree
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var icon: Texture2D
@export_multiline var intrinsic_text: String = ""
@export var talents: Array[Talent] = []
@export var innate_modifiers: Array[StatModifier] = []
## Skills granted just by having this tree selected (no talent required),
## e.g. Quick Cut for Thief.
@export var unlocked_skills: Array[Skill] = []
## Data-driven skill changes granted by selecting this tree, e.g. Shadow's
## innate poison on Stab and Heavy Slash.
@export var skill_augments: Array[SkillAugment] = []
