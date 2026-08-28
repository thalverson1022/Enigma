class_name EncounterArchetypeVocabulary
extends RefCounted

const UNKNOWN_ARCHETYPE := {
	"display_tag": "",
	"display_name": "",
	"likely_mechanics": [],
	"pressures": "Unknown matchup pressure.",
	"rewards": "Scout this enemy in combat before committing assumptions.",
	"combat_summary": "Unknown archetype. Read the combat UI for exact defenses.",
}

const ARCHETYPES := {
	"fortified": {
		"display_tag": "fortified",
		"display_name": "Fortified",
		"likely_mechanics": ["Armor", "Crit Negate", "Block"],
		"pressures": "Pressures direct physical hits, crit-reliant damage, and low-hit-count rotations.",
		"rewards": "Rewards armor bypass, reliable damage, poison, magic, or many smaller hits.",
		"combat_summary": "Expect physical mitigation such as armor, crit negation, or block.",
	},
	"warded": {
		"display_tag": "warded",
		"display_name": "Warded",
		"likely_mechanics": ["Resist", "Absorb", "Suppress"],
		"pressures": "Pressures poison, magical pressure, and proc-heavy builds.",
		"rewards": "Rewards physical damage, direct hits, and builds that do not depend on poison uptime.",
		"combat_summary": "Expect magical or poison mitigation such as resist, absorb, or suppress.",
	},
	"nimble": {
		"display_tag": "nimble",
		"display_name": "Nimble",
		"likely_mechanics": ["Dodge", "Crit Negate"],
		"pressures": "Pressures slow single-hit skills and crit-reliant burst.",
		"rewards": "Rewards accuracy, repeated hits, steady damage, and non-crit scaling.",
		"combat_summary": "Expect avoidance or crit disruption such as dodge or crit negation.",
	},
	"hexed": {
		"display_tag": "hexed",
		"display_name": "Hexed",
		"likely_mechanics": ["Cleanse", "Suppress"],
		"pressures": "Pressures poison stacking, debuffs, and triggered effects.",
		"rewards": "Rewards front-loaded damage and builds that can win without long debuff setup.",
		"combat_summary": "Expect debuff disruption such as cleanse thresholds or suppress.",
	},
	"relentless": {
		"display_tag": "relentless",
		"display_name": "Relentless",
		"likely_mechanics": ["Armor", "Resist", "Cleanse", "Slow"],
		"pressures": "Pressures mixed builds by combining durability with tempo friction.",
		"rewards": "Rewards balanced damage plans and builds that can keep output stable through slowdowns.",
		"combat_summary": "Expect mixed defenses and tempo pressure.",
	},
	"unstable": {
		"display_tag": "unstable",
		"display_name": "Unstable",
		"likely_mechanics": ["Mixed Defense", "Control"],
		"pressures": "Pressures narrow builds because its exact defense package is less predictable.",
		"rewards": "Rewards flexible builds, broad damage sources, and fast adaptation once combat reveals details.",
		"combat_summary": "Expect a less predictable mix of mitigation, avoidance, debuff disruption, or control.",
	},
	"devious": {
		"display_tag": "devious",
		"display_name": "Devious",
		"likely_mechanics": ["Cleanse", "Slow", "Stun", "Interrupt"],
		"pressures": "Pressures timing-sensitive rotations, long casts, and debuff setup.",
		"rewards": "Rewards shorter rotations, redundant skills, and builds that tolerate control.",
		"combat_summary": "Expect control or timing disruption such as slow, stun, interrupt, or cleanse.",
	},
	"arcane": {
		"display_tag": "arcane",
		"display_name": "Arcane",
		"likely_mechanics": ["Stun", "Interrupt"],
		"pressures": "Pressures cast timing, long setup windows, and fragile rotations.",
		"rewards": "Rewards quick skills, resilient sequencing, and builds with multiple useful actions.",
		"combat_summary": "Expect magical control pressure such as stun or interrupt.",
	},
	"armored": {
		"display_tag": "armored",
		"display_name": "Armored",
		"likely_mechanics": ["Armor"],
		"pressures": "Pressures basic physical damage.",
		"rewards": "Rewards armor bypass, poison, magic, or scaling that is not mostly flat physical hits.",
		"combat_summary": "Expect a simple armor check.",
	},
	"resistant": {
		"display_tag": "resistant",
		"display_name": "Resistant",
		"likely_mechanics": ["Resist"],
		"pressures": "Pressures poison and magical damage.",
		"rewards": "Rewards physical damage or builds that do not depend on poison.",
		"combat_summary": "Expect a simple poison or magic resistance check.",
	},
	"aegis": {
		"display_tag": "aegis",
		"display_name": "Aegis",
		"likely_mechanics": ["Block", "Crit Negation"],
		"pressures": "Pressures many small physical hits, low base-damage attacks, and crit-reliant plans.",
		"rewards": "Rewards heavier single hits, armor bypass, poison, magic, or builds that can punch through block.",
		"combat_summary": "Expect flat physical reduction led by block, sometimes backed by crit negation.",
	},
	"nullify": {
		"display_tag": "nullify",
		"display_name": "Nullify",
		"likely_mechanics": ["Absorb", "Suppress"],
		"pressures": "Pressures repeated magical effects and small packets that run into flat absorption.",
		"rewards": "Rewards physical damage, larger magic packets, or non-magical scaling.",
		"combat_summary": "Expect flat magical absorption led by absorb, sometimes backed by suppress.",
	},
	"spiteful": {
		"display_tag": "spiteful",
		"display_name": "Spiteful",
		"likely_mechanics": ["Cleanse", "Suppress", "Resist"],
		"pressures": "Pressures poison stacking, debuff setup, and long damage-over-time plans.",
		"rewards": "Rewards front-loaded damage, direct hits, quick debuff rebuilding, or mixed damage plans.",
		"combat_summary": "Expect debuff and poison disruption led by cleanse or suppress.",
	},
	"riftbound": {
		"display_tag": "riftbound",
		"display_name": "Riftbound",
		"likely_mechanics": ["Armor", "Absorb", "Slow", "Dodge", "Resist"],
		"pressures": "Pressures narrow builds with controlled mixed defenses and light tempo friction.",
		"rewards": "Rewards flexible damage sources, resilient rotations, and builds that can adapt after combat reveals exact defenses.",
		"combat_summary": "Expect a controlled mixed package across mitigation, avoidance, and tempo pressure.",
	},
}


static func tag_for_id(archetype_id: String) -> String:
	return String(entry_for_id(archetype_id).get("display_tag", archetype_id))


static func tags_for_ids(archetype_ids: PackedStringArray) -> Array:
	var result := []
	for archetype_id in archetype_ids:
		result.append(tag_for_id(archetype_id))
	return result


static func combat_summaries_for_ids(archetype_ids: PackedStringArray) -> Array:
	var result := []
	for archetype_id in archetype_ids:
		var entry := entry_for_id(archetype_id)
		result.append({
			"id": archetype_id,
			"display_tag": String(entry.get("display_tag", archetype_id)),
			"display_name": String(entry.get("display_name", String(archetype_id).capitalize())),
			"likely_mechanics": (entry.get("likely_mechanics", []) as Array).duplicate(true),
			"pressures": String(entry.get("pressures", UNKNOWN_ARCHETYPE["pressures"])),
			"rewards": String(entry.get("rewards", UNKNOWN_ARCHETYPE["rewards"])),
			"combat_summary": String(entry.get("combat_summary", UNKNOWN_ARCHETYPE["combat_summary"])),
		})
	return result


static func entry_for_id(archetype_id: String) -> Dictionary:
	if ARCHETYPES.has(archetype_id):
		return (ARCHETYPES[archetype_id] as Dictionary).duplicate(true)
	var fallback := UNKNOWN_ARCHETYPE.duplicate(true)
	fallback["display_tag"] = archetype_id
	fallback["display_name"] = String(archetype_id).capitalize()
	return fallback
