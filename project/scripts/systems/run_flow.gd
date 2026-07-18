class_name RunFlow
extends RefCounted
## Owns the fixed, ordered encounter ladder for the P2:M5 vertical slice --
## the real Tavern Encounters (Mouthy Drunk -> Drunk Buddy -> Tavern Bouncer
## -> Hired Goon) from Content_Library_Reference.md, ending in Vyra as the
## single boss. No branching: the full Contract Route (Door Guard/Knives/
## route choice) is explicitly Phase 3's "Contract Run" scope, not P2:M5's.

const ENCOUNTER_PATHS: Array[String] = [
	"res://data/encounters/01_mouthy_drunk.tres",
	"res://data/encounters/02_drunk_buddy.tres",
	"res://data/encounters/03_tavern_bouncer.tres",
	"res://data/encounters/04_hired_goon.tres",
	"res://data/encounters/05_vyra_boss.tres",
]

const TAVERN_ENCOUNTER_COUNT := 4


static func encounter_count() -> int:
	return ENCOUNTER_PATHS.size()


static func tavern_encounter_count() -> int:
	return TAVERN_ENCOUNTER_COUNT


static func load_encounter(index: int) -> Encounter:
	if index < 0 or index >= ENCOUNTER_PATHS.size():
		return null
	return load(ENCOUNTER_PATHS[index])
