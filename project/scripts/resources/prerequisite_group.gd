class_name PrerequisiteGroup
extends Resource
## Satisfied if any one of `options` is already selected -- models an
## OR-group prerequisite (e.g. "requires A or B"). See the P2:M1 note in
## docs/Phase_2_Milestones.md on why this replaced a flat Array[Talent].

@export var options: Array[Talent] = []
