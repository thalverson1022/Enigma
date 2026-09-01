extends SceneTree
## Headless check for PassiveAllocator's OR-group dependent-lock rule, using
## the real Bladedancer tree (Quick Hands / Piercing Blades / Practiced Rhythm --
## Practiced Rhythm requires "Quick Hands or Piercing Blades"). Covers the
## bug reported live: swapping which tier-0 talent satisfies a tier-1
## OR-prerequisite used to force removing the entire upper chain first.
## Run with:
##   godot --headless -s res://tests/passive_allocator_test.gd


func _initialize() -> void:
	var quick_hands: Talent = load("res://data/talents/bladedancer/quick_hands.tres")
	var piercing_blades: Talent = load("res://data/talents/bladedancer/piercing_blades.tres")
	var practiced_rhythm: Talent = load("res://data/talents/bladedancer/practiced_rhythm.tres")

	# -- Baseline: Piercing Blades alone satisfies Practiced Rhythm's OR-group --
	var selected: Array[Talent] = [piercing_blades, practiced_rhythm]
	print("can deselect Piercing Blades with no alternative selected (expect false): %s" % (
		PassiveAllocator.can_deselect_talent(selected, piercing_blades)
	))
	assert(not PassiveAllocator.can_deselect_talent(selected, piercing_blades))

	# -- The fix: select the OTHER tier-0 option first (both now satisfy the
	# same OR-group), THEN the original one becomes safe to remove without
	# touching Practiced Rhythm at all. --
	selected.append(quick_hands)
	print("can deselect Piercing Blades once Quick Hands also selected (expect true): %s" % (
		PassiveAllocator.can_deselect_talent(selected, piercing_blades)
	))
	assert(PassiveAllocator.can_deselect_talent(selected, piercing_blades))

	selected.erase(piercing_blades)
	print("Practiced Rhythm still satisfied via Quick Hands alone (expect true): %s" % (
		PassiveAllocator.prerequisites_satisfied(selected, practiced_rhythm)
	))
	assert(PassiveAllocator.prerequisites_satisfied(selected, practiced_rhythm))
	assert(selected.has(practiced_rhythm))

	# -- Now Quick Hands is the sole support -- removing it should be
	# blocked again, same as Piercing Blades was at the start. --
	print("can deselect Quick Hands now that it's the sole support (expect false): %s" % (
		PassiveAllocator.can_deselect_talent(selected, quick_hands)
	))
	assert(not PassiveAllocator.can_deselect_talent(selected, quick_hands))

	# -- Unrelated talent with no dependents is always removable. --
	var unrelated: Array[Talent] = [quick_hands]
	print("can deselect a talent with no dependents at all (expect true): %s" % (
		PassiveAllocator.can_deselect_talent(unrelated, quick_hands)
	))
	assert(PassiveAllocator.can_deselect_talent(unrelated, quick_hands))

	print("")
	print("PassiveAllocator OR-group dependent-lock check: OK")
	quit()
