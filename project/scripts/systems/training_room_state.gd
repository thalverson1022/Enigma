class_name TrainingRoomState
extends RefCounted
## P2:R10 Practice Room's own build state -- deliberately NOT an autoload
## and never touching the real `BuildState` singleton, so a practice session
## can never read or mutate a real Adventure run. Mirrors the minimal slice
## of `BuildState`'s shape/behavior that the reused dashboard panels
## (`talent_panel.gd`, `available_skills_panel.gd`, `skill_build_panel.gd`,
## `character_stats_panel.gd`) actually need -- same signals, same method
## names/semantics -- so those panels can take either object interchangeably
## via their new `state` property (default `BuildState`).
##
## Talent points are granted in full immediately (`PassiveAllocator.
## POINT_BUDGET`) rather than earned -- Practice Room is meant for freely
## testing a fully-built practice character, not replaying Adventure's
## earn-as-you-go pacing.

signal build_changed
signal lock_changed
signal fight_setup_changed
signal fight_finished

const DEFAULT_DURATION_MS := 20000
const DEFAULT_FIGHT_SEED := 1
const DEFAULT_TARGET_ARMOR := 0
const DEFAULT_TARGET_POISON_RESIST := 0.0
## Practice Room only measures damage dealt in a fixed window -- it never
## checks win/loss -- but CombatResolver.resolve()/CombatResultFormatter
## still read Monster.hp (for the shared CombatResult.is_win flag), so the
## practice target needs *some* value here even though nothing in Training
## Room's own UI ever displays or depends on it. Deliberately huge so is_win
## never trips.
const PRACTICE_TARGET_HP := 999999

var selected_class: ClassDef = null
var selected_trees: Array[SubclassTree] = []
var selected_talents: Array[Talent] = []
var earned_talent_points: int = PassiveAllocator.POINT_BUDGET
var rotation: Array[Skill] = []
var build_locked: bool = false
var gold: int = 0
var equipped_weapon: GearItem = null
var equipped_trinket: GearItem = null
var equipped_charm: GearItem = null

## P2:R10:T4 -- freeform, hand-editable practice gear, one per slot.
## Practice Room starts with no gear equipped; choosing Basic/Master/Cursed
## equips the corresponding practice item, and choosing None unequips it.
## `equip_legendary()` points the weapon slot at a fixed catalog item instead
## (read-only in the UI), and `use_custom_weapon()` points it back to the
## editable practice weapon. Trinket/charm have no Legendary items today, so
## they are only controlled by the rarity dropdown.
var practice_weapon: GearItem
var practice_trinket: GearItem
var practice_charm: GearItem

## P2:R10:T5 -- freeform fight-setup, independent of any real Adventure
## encounter/seed. `fight_seed` is deliberately separate from
## `BuildState.adventure_seed` so a Practice Room result is reproducible on
## its own terms, per the P2:R10 scope decision.
var selected_target: Monster
var duration_ms: int = DEFAULT_DURATION_MS
var fight_seed: int = DEFAULT_FIGHT_SEED

## P2:R10:T6 -- the most recent practice fight's raw result, for the reused
## CombatResultFormatter/CombatRecap presentation to render. Never written
## anywhere but here -- unlike a real Adventure fight, running one in
## Practice Room never calls `BuildState.finish_fight()` or advances any
## encounter/route state.
var last_result: CombatResolver.CombatResult = null


func _init() -> void:
	build_changed.connect(_clear_lock_on_change)
	practice_weapon = _make_practice_item(GearItem.SlotType.WEAPON, "Custom Weapon")
	practice_trinket = _make_practice_item(GearItem.SlotType.TRINKET, "Custom Trinket")
	practice_charm = _make_practice_item(GearItem.SlotType.CHARM, "Custom Charm")
	# Not a seeded roster entry (P2:R10:T5 reworked this into adjustable
	# Armor/Poison Resist values, post-R10 UI-feedback pass) -- a plain
	# in-memory Monster this state owns and mutates directly, never a .tres.
	selected_target = Monster.new()
	selected_target.display_name = "Practice Target"
	selected_target.hp = PRACTICE_TARGET_HP
	selected_target.armor = DEFAULT_TARGET_ARMOR
	selected_target.poison_resistance = DEFAULT_TARGET_POISON_RESIST
	# Practice items begin as empty shells so entering Practice Room has no
	# equipped gear. The rarity-first invariant still applies once a player
	# picks Basic/Master/Cursed: that choice equips the item and fills the
	# real GearGenerator-shaped affix count.


func _make_practice_item(slot: GearItem.SlotType, display_name: String) -> GearItem:
	var item := GearItem.new()
	item.id = "gear.training_room.practice_%s" % GearItem.SlotType.keys()[slot].to_lower()
	item.display_name = display_name
	item.slot = slot
	return item


func _clear_lock_on_change() -> void:
	if build_locked:
		build_locked = false
		lock_changed.emit()


func set_locked(locked: bool) -> void:
	if locked and rotation.is_empty():
		locked = false
	if build_locked == locked:
		return
	build_locked = locked
	lock_changed.emit()


func set_class(class_def: ClassDef) -> void:
	selected_class = class_def
	selected_trees = []
	selected_talents = []
	rotation = []
	build_changed.emit()


## Two independent dropdown slots (Primary/Secondary) rather than
## `BuildState.select_tree()`'s "pick exactly one" Adventure semantics --
## Practice Room lets the player freely choose either of the 3 real trees
## into either slot. `selected_trees` stays a plain compact array (no null
## entries) so every existing reader (`unlocked_skills()`, `BuildResolver`,
## etc.) is untouched; slot identity is just "index 0 = primary, index 1 =
## secondary" by convention, resolved fresh from the current array each call.
func set_primary_tree(tree: SubclassTree) -> bool:
	return _set_tree_at_slot(0, tree)


func set_secondary_tree(tree: SubclassTree) -> bool:
	return _set_tree_at_slot(1, tree)


func tree_at_slot(slot_index: int) -> SubclassTree:
	return selected_trees[slot_index] if slot_index < selected_trees.size() else null


func _set_tree_at_slot(slot_index: int, tree: SubclassTree) -> bool:
	var current_at_slot := tree_at_slot(slot_index)
	if current_at_slot == tree:
		return true
	var trees := selected_trees.duplicate()
	if current_at_slot != null:
		trees.erase(current_at_slot)
	if tree != null:
		if trees.has(tree) or not PassiveAllocator.can_select_tree(trees, tree):
			return false
		trees.insert(mini(slot_index, trees.size()), tree)
	selected_trees = trees
	var remaining: Array[Talent] = []
	for talent in selected_talents:
		for kept_tree in selected_trees:
			if kept_tree.talents.has(talent):
				remaining.append(talent)
				break
	selected_talents = remaining
	_prune_rotation_to_unlocked()
	build_changed.emit()
	return true


func select_talent(talent: Talent) -> bool:
	if not PassiveAllocator.can_select_talent(selected_trees, selected_talents, talent, earned_talent_points):
		return false
	selected_talents.append(talent)
	_prune_rotation_to_unlocked()
	build_changed.emit()
	return true


func deselect_talent(talent: Talent) -> bool:
	if not PassiveAllocator.can_deselect_talent(selected_talents, talent):
		return false
	selected_talents.erase(talent)
	_prune_rotation_to_unlocked()
	build_changed.emit()
	return true


func set_rotation(skills: Array[Skill]) -> void:
	rotation = BuildResolver.resolve_rotation(skills, unlocked_skills())
	build_changed.emit()


func unlocked_skills() -> Array[Skill]:
	return BuildResolver.resolve_unlocked_skills(selected_class, selected_trees, selected_talents, equipped_gear())


func can_run_fight() -> bool:
	return build_locked and not rotation.is_empty()


## Direct Legendary equip for Practice Room's Legendary-equip control
## (P2:R10:T3) -- bypasses reward/shop flow entirely. All 5 catalog
## Legendaries are weapon-slot items today, so this always fills
## `equipped_weapon`; revisit if a future Legendary uses a different slot.
func equip_legendary(item: GearItem) -> void:
	equipped_weapon = item
	build_changed.emit()


## Switches the weapon slot back to the freeform practice item after a
## Legendary was equipped (P2:R10:T4's Custom/Legendary toggle).
func use_custom_weapon() -> void:
	equipped_weapon = practice_weapon
	build_changed.emit()


## True while the weapon slot shows a fixed Legendary rather than the
## editable practice item -- the affix editor reads this to know whether to
## render itself as read-only.
func is_weapon_legendary() -> bool:
	return equipped_weapon != null and equipped_weapon != practice_weapon


## "None" rarity choice (user-requested) -- empties the slot entirely, no
## stats at all. Distinct from set_slot_rarity() since GearItem.Tier has no
## "no item" value to represent this; the UI reads an empty `affixes` array
## as "None" currently selected (see training_room.gd's _refresh_gear_slot()).
func clear_slot(item: GearItem) -> void:
	_unequip_practice_item(item)
	item.affixes.clear()
	build_changed.emit()


## Rarity-first gear editor (replaces the earlier freeform add/remove-any-
## affix editor): picking a rarity for a practice item's slot fixes its real
## GearGenerator affix-slot count (Basic=1, Master=2, Cursed=2 positive + 1
## curse=3) rather than letting the player add/remove arbitrary numbers of
## affixes. `item` must be one of practice_weapon/practice_trinket/
## practice_charm -- never a Legendary (those are handled entirely by
## equip_legendary()/use_custom_weapon(), never passed here).
func set_slot_rarity(item: GearItem, tier: GearItem.Tier) -> void:
	_equip_practice_item(item)
	item.tier = tier
	var target_count := _affix_slot_count(tier)
	while item.affixes.size() > target_count:
		item.affixes.remove_at(item.affixes.size() - 1)
	while item.affixes.size() < target_count:
		var slot_index := item.affixes.size()
		var pool := _pool_for_slot(tier, slot_index, target_count)
		var used: Array = []
		for existing in item.affixes:
			used.append(existing.stat)
		var stat: StatModifier.StatType = _first_unused_stat(pool, used)
		var modifier := StatModifier.new()
		modifier.stat = stat
		item.affixes.append(modifier)
	# Re-stamp every slot's operation/value to the current tier's real table
	# (a slot kept across a rarity change may otherwise carry a stale
	# magnitude from the tier it was created under).
	for i in item.affixes.size():
		var modifier: StatModifier = item.affixes[i]
		modifier.operation = GearGenerator.OPERATION[modifier.stat]
		modifier.value = _tier_value(modifier.stat, tier, i, target_count)
	build_changed.emit()


func _equip_practice_item(item: GearItem) -> void:
	match item.slot:
		GearItem.SlotType.WEAPON:
			equipped_weapon = item
		GearItem.SlotType.TRINKET:
			equipped_trinket = item
		GearItem.SlotType.CHARM:
			equipped_charm = item


func _unequip_practice_item(item: GearItem) -> void:
	match item.slot:
		GearItem.SlotType.WEAPON:
			if equipped_weapon == item:
				equipped_weapon = null
		GearItem.SlotType.TRINKET:
			if equipped_trinket == item:
				equipped_trinket = null
		GearItem.SlotType.CHARM:
			if equipped_charm == item:
				equipped_charm = null


## Re-picks one affix slot's stat (the player's dropdown choice) and
## auto-fills that stat's real tier value into the still-editable value
## field -- per the confirmed design, the value stays editable afterward,
## this just seeds a sensible real default instead of leaving it at
## whatever the previous stat's magnitude happened to be.
func set_affix_stat(item: GearItem, index: int, stat: StatModifier.StatType) -> void:
	if index < 0 or index >= item.affixes.size():
		return
	var modifier: StatModifier = item.affixes[index]
	modifier.stat = stat
	modifier.operation = GearGenerator.OPERATION[stat]
	modifier.value = _tier_value(stat, item.tier, index, item.affixes.size())
	build_changed.emit()


## Affix value edits mutate the `StatModifier` field directly -- GearItem/
## StatModifier are plain exported-field Resources with no encapsulation
## elsewhere in the codebase (see gear_generator.gd) -- then call this to
## trigger the same live-refresh every other build_changed-driven panel
## already uses.
func notify_gear_edited() -> void:
	build_changed.emit()


func _affix_slot_count(tier: GearItem.Tier) -> int:
	match tier:
		GearItem.Tier.BASIC:
			return 1
		GearItem.Tier.MASTER:
			return 2
		GearItem.Tier.CURSED:
			return 3
	return 0


## The last slot of a Cursed item is always its downside -- everything else
## (Basic/Master's only slots, Cursed's first two) draws from the normal
## positive-affix pool.
func _pool_for_slot(tier: GearItem.Tier, slot_index: int, total_count: int) -> Array[StatModifier.StatType]:
	if tier == GearItem.Tier.CURSED and slot_index == total_count - 1:
		return GearGenerator.DOWNSIDE_POOL
	return GearGenerator.AFFIX_POOL


## Cursed's two positive slots aren't symmetric in GearGenerator's own table:
## slot 0 gets the amplified value, slot 1 gets the plain Master value (the
## "1 amplified + 1 more" shape from Content_Library_Reference.md).
func _tier_value(stat: StatModifier.StatType, tier: GearItem.Tier, slot_index: int, total_count: int) -> float:
	match tier:
		GearItem.Tier.BASIC:
			return GearGenerator.BASIC_VALUE[stat]
		GearItem.Tier.MASTER:
			return GearGenerator.MASTER_VALUE[stat]
		GearItem.Tier.CURSED:
			if slot_index == total_count - 1:
				return GearGenerator.CURSED_DOWNSIDE_VALUE[stat]
			elif slot_index == 0:
				return GearGenerator.CURSED_AMPLIFIED_VALUE[stat]
			return GearGenerator.MASTER_VALUE[stat]
	return 0.0


func _first_unused_stat(pool: Array[StatModifier.StatType], used: Array) -> StatModifier.StatType:
	for stat in pool:
		if not used.has(stat):
			return stat
	return pool[0]


func set_target_armor(value: int) -> void:
	selected_target.armor = maxi(0, value)
	fight_setup_changed.emit()


func set_target_poison_resistance(value: float) -> void:
	selected_target.poison_resistance = clampf(value, 0.0, 1.0)
	fight_setup_changed.emit()


func set_duration_ms(ms: int) -> void:
	duration_ms = maxi(1000, ms)
	fight_setup_changed.emit()


func set_fight_seed(value: int) -> void:
	fight_seed = value
	fight_setup_changed.emit()


## Practice gold rides on `build_changed`, not `fight_setup_changed` --
## unlike target/duration/seed, it genuinely affects resolved stats
## (Bandit Blade's gold-scaling physical damage) and must trigger the same
## live-refresh `character_stats_panel` already listens for.
func set_practice_gold(amount: int) -> void:
	gold = maxi(0, amount)
	build_changed.emit()


## Resolves the current practice build and runs one fight against
## `selected_target` over `duration_ms`, seeded by `fight_seed` --
## completely separate from any real Adventure encounter/seed/state.
## `rotation` is already filtered to unlocked skills (`set_rotation()`
## and `_prune_rotation_to_unlocked()` both route through
## `BuildResolver.resolve_rotation()`), so it's ready to feed directly into
## `CombatResolver.resolve()`.
func run_fight() -> void:
	if not can_run_fight():
		return
	var stats := BuildResolver.resolve_stats(selected_class, selected_trees, selected_talents, equipped_gear(), gold)
	last_result = CombatResolver.resolve(rotation, stats, selected_target, duration_ms, fight_seed)
	fight_finished.emit()


## Weapon -> trinket -> charm order, matching `BuildState.equipped_gear()`.
func equipped_gear() -> Array[GearItem]:
	var gear: Array[GearItem] = []
	for item in [equipped_weapon, equipped_trinket, equipped_charm]:
		if item != null:
			gear.append(item)
	return gear


func _prune_rotation_to_unlocked() -> void:
	rotation = BuildResolver.resolve_rotation(rotation, unlocked_skills())
