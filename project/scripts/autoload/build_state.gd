extends Node
## Shared in-progress build state for the P2:M3 Build Planner screens.
## Holds only data + signals per docs/Conventions.md's UI architecture
## principle -- screens read/write this instead of holding game state
## themselves.

signal build_changed
signal lock_changed
signal run_state_changed

enum RunPhase {
	PLANNING,
	FIGHTING,
	RESULT,
	CONTRACT_OFFER,
	CONTRACT_ROUTE,
	RUN_ENDED,
}

enum RunOutcome {
	NONE,
	FIGHT_WIN,
	FIGHT_LOSS_RETRY,
	ADVENTURE_RESTART_REQUIRED,
	CONTRACT_FAILED,
	CONTRACT_VICTORY,
}

const INVENTORY_CAPACITY := 3
const SELL_VALUE_RATIO := 0.5
const GILDED_SERPENT_CONTRACT_PATH := "res://data/contracts/the_gilded_serpent.tres"
const DEFAULT_ADVENTURE_SEED := 1
const RunRngSystem = preload("res://scripts/systems/run_rng.gd")

var selected_class: ClassDef = null
var selected_trees: Array[SubclassTree] = []
var selected_talents: Array[Talent] = []
var rotation: Array[Skill] = []
var adventure_seed: int = DEFAULT_ADVENTURE_SEED
var gold: int = 0
var earned_talent_points: int = 0
var inventory: Array[GearItem] = []
var claimed_reward_encounter_indices: Array[int] = []
var shop_unlocked: bool = false
var shop_round_pending: bool = false
var shop_reroll_used: bool = false
var shop_round_index: int = 0
var shop_offers: Array[GearItem] = []
const SHOP_OFFER_COUNT := 6
const CONTRACT_SHOP_BASIC_WEIGHT := 64
const CONTRACT_SHOP_MASTER_WEIGHT := 25
const CONTRACT_SHOP_CURSED_WEIGHT := 10
const CONTRACT_SHOP_LEGENDARY_WEIGHT := 1
const SHOP_UNIQUE_ROLL_ATTEMPTS := 80
var pending_reward_choices: Array[GearItem] = []
var equipped_weapon: GearItem = null
var equipped_trinket: GearItem = null
var equipped_charm: GearItem = null
var active_contract: ContractDef = null
var current_route_node: ContractRouteNode = null
var claimed_route_reward_ids: Array[String] = []
var current_encounter_index: int = 0
var encounter_failure_counts: Dictionary = {}
var run_phase: int = RunPhase.PLANNING
var run_outcome: int = RunOutcome.NONE
var last_fight_won: bool = false
var tavern_map_choice_made: bool = false
## "Ready" flag: locking the build enables the FIGHT button. Any build
## mutation (talents, macro, gear, ...) automatically clears it, since the
## lock refers to the build as it was when locked -- see _ready().
var build_locked: bool = false


func _ready() -> void:
	build_changed.connect(_clear_lock_on_change)


func _clear_lock_on_change() -> void:
	if build_locked:
		build_locked = false
		lock_changed.emit()


func set_locked(locked: bool) -> void:
	if build_locked == locked:
		return
	build_locked = locked
	lock_changed.emit()


func reset(preserve_adventure_seed: bool = false) -> void:
	var kept_seed := adventure_seed
	selected_class = null
	selected_trees = []
	selected_talents = []
	rotation = []
	adventure_seed = kept_seed if preserve_adventure_seed else DEFAULT_ADVENTURE_SEED
	gold = 0
	earned_talent_points = 0
	inventory = []
	claimed_reward_encounter_indices = []
	shop_unlocked = false
	shop_round_pending = false
	shop_reroll_used = false
	shop_round_index = 0
	shop_offers = []
	pending_reward_choices = []
	equipped_weapon = null
	equipped_trinket = null
	equipped_charm = null
	active_contract = null
	current_route_node = null
	claimed_route_reward_ids = []
	current_encounter_index = 0
	encounter_failure_counts = {}
	run_phase = RunPhase.PLANNING
	run_outcome = RunOutcome.NONE
	last_fight_won = false
	tavern_map_choice_made = false
	build_changed.emit()
	run_state_changed.emit()


func set_adventure_seed(seed: int) -> void:
	adventure_seed = max(0, seed)
	run_state_changed.emit()


func current_encounter() -> Encounter:
	return RunFlow.load_encounter(current_encounter_index)


func is_contract_fight_active() -> bool:
	return (
		active_contract != null
		and current_route_node != null
		and current_route_node.monster != null
		and (
			run_phase == RunPhase.PLANNING
			or run_phase == RunPhase.FIGHTING
			or run_phase == RunPhase.RESULT
		)
	)


func current_target_monster() -> Monster:
	if is_contract_fight_active():
		return current_route_node.monster
	var encounter := current_encounter()
	return encounter.monster if encounter != null else null


func current_target_duration_ms() -> int:
	if is_contract_fight_active():
		return current_route_node.duration_ms
	var encounter := current_encounter()
	return encounter.duration_ms if encounter != null else 0


func current_reward() -> EncounterReward:
	if is_contract_fight_active():
		return current_route_node.reward
	var encounter := current_encounter()
	return encounter.reward if encounter != null else null


func current_fight_label() -> String:
	if is_contract_fight_active():
		return current_route_node.display_name
	var encounter := current_encounter()
	return encounter.monster.display_name if encounter != null and encounter.monster != null else ""


func current_combat_rng_seed() -> int:
	return RunRngSystem.seed_for_context(adventure_seed, RunRngSystem.CONTEXT_COMBAT, [_current_fight_key()])


func can_start_current_fight() -> bool:
	return (
		build_locked
		and run_phase == RunPhase.PLANNING
		and current_target_monster() != null
		and current_target_duration_ms() > 0
		and not needs_tavern_map_choice()
	)


func is_tavern_planning() -> bool:
	return (
		run_phase == RunPhase.PLANNING
		and not is_contract_fight_active()
		and current_encounter_index < RunFlow.tavern_encounter_count()
	)


func needs_tavern_map_choice() -> bool:
	return is_tavern_planning() and not tavern_map_choice_made


func choose_current_tavern_encounter() -> bool:
	if not is_tavern_planning():
		return false
	tavern_map_choice_made = true
	run_state_changed.emit()
	return true


func pending_contract_offer() -> bool:
	return run_phase == RunPhase.CONTRACT_OFFER and active_contract != null and current_route_node != null


func start_contract_offer() -> bool:
	var contract: ContractDef = load(GILDED_SERPENT_CONTRACT_PATH)
	if contract == null or contract.offer_node == null:
		return false
	active_contract = contract
	current_route_node = contract.offer_node
	run_phase = RunPhase.CONTRACT_OFFER
	run_outcome = RunOutcome.NONE
	last_fight_won = false
	tavern_map_choice_made = false
	set_locked(false)
	run_state_changed.emit()
	return true


func accept_contract_offer() -> bool:
	if not pending_contract_offer():
		return false
	if current_route_node.next_nodes.is_empty():
		return false
	current_route_node = current_route_node.next_nodes[0]
	run_phase = RunPhase.CONTRACT_ROUTE
	run_outcome = RunOutcome.NONE
	set_locked(false)
	run_state_changed.emit()
	return true


func needs_secondary_subclass_choice() -> bool:
	return (
		run_phase == RunPhase.CONTRACT_ROUTE
		and current_route_node != null
		and current_route_node.node_type == ContractRouteNode.NodeType.SUBCLASS_CHOICE
		and selected_trees.size() < PassiveAllocator.MAX_TREES
	)


func choose_secondary_tree(tree: SubclassTree) -> bool:
	if not needs_secondary_subclass_choice() or tree == null:
		return false
	if selected_trees.has(tree):
		return false
	if not PassiveAllocator.can_select_tree(selected_trees, tree):
		return false
	selected_trees.append(tree)
	_prune_rotation_to_unlocked()
	build_changed.emit()
	run_state_changed.emit()
	return true


func choose_contract_route_node(node: ContractRouteNode) -> bool:
	if run_phase != RunPhase.CONTRACT_ROUTE:
		return false
	if node == null or current_route_node == null:
		return false
	if not current_route_node.next_nodes.has(node):
		return false
	if node.monster == null or node.duration_ms <= 0:
		return false
	current_route_node = node
	run_phase = RunPhase.PLANNING
	run_outcome = RunOutcome.NONE
	last_fight_won = false
	set_locked(false)
	run_state_changed.emit()
	return true


func start_fight() -> bool:
	if not can_start_current_fight():
		return false
	tavern_map_choice_made = false
	run_phase = RunPhase.FIGHTING
	run_outcome = RunOutcome.NONE
	run_state_changed.emit()
	return true


func finish_fight(won: bool) -> void:
	last_fight_won = won
	if won:
		run_outcome = RunOutcome.FIGHT_WIN
		run_phase = RunPhase.RESULT
	else:
		var key := _current_fight_key()
		encounter_failure_counts[key] = failure_count_for_current_encounter() + 1
		if is_unlimited_retry_encounter():
			# Project Bane revision to the R5/Phase 1 baseline rule (combat-
			# playback adjustment round 2 + retry bug, 2026-07-19, corrected
			# 2026-07-19; see docs/Phase_2_R5_Run_Rules_And_Determinism.md's
			# revision note): every other fight gets exactly one do-over
			# before a losing contract/Adventure forces a restart, but the
			# very first Tavern encounter (Mouthy Drunk, encounter index 0)
			# gets unlimited
			# retries instead, so a new player isn't forced back to class
			# selection while still getting comfortable at the very start of
			# the Adventure. A loss on the first encounter always resolves to
			# FIGHT_LOSS_RETRY, never ADVENTURE_RESTART_REQUIRED, regardless
			# of how many times it's already been attempted
			# (encounter_failure_counts is still incremented above for
			# bookkeeping/telemetry, it's just never consulted to force a
			# restart for that specific encounter).
			run_outcome = RunOutcome.FIGHT_LOSS_RETRY
			run_phase = RunPhase.RESULT
		elif failure_count_for_current_encounter() <= 1:
			run_outcome = RunOutcome.FIGHT_LOSS_RETRY
			run_phase = RunPhase.RESULT
		else:
			run_outcome = RunOutcome.CONTRACT_FAILED if is_contract_fight_active() else RunOutcome.ADVENTURE_RESTART_REQUIRED
			run_phase = RunPhase.RUN_ENDED
			set_locked(false)
	run_state_changed.emit()


func failure_count_for_current_encounter() -> int:
	return int(encounter_failure_counts.get(_current_fight_key(), 0))


## The very first Tavern encounter (Mouthy Drunk, encounter index 0 in
## RunFlow.ENCOUNTER_PATHS) -- see docs/Phase_2_R5_Run_Rules_And_Determinism.md
## for the unlimited-retry exception this identifies. Must be an actual
## Tavern encounter (not a contract route node -- route nodes never reuse
## current_encounter_index) so a contract fight can never accidentally match
## on a stale index 0.
func is_unlimited_retry_encounter() -> bool:
	return not is_contract_fight_active() and current_encounter_index == 0


func can_retry_current_encounter() -> bool:
	return (
		run_phase == RunPhase.RESULT
		and run_outcome == RunOutcome.FIGHT_LOSS_RETRY
		and not last_fight_won
	)


func retry_current_encounter() -> bool:
	if not can_retry_current_encounter():
		return false
	run_phase = RunPhase.PLANNING
	run_outcome = RunOutcome.NONE
	last_fight_won = false
	# RETRY BUG FIX (combat-playback adjustment round 2 + retry bug,
	# 2026-07-19): Tavern retries must make the same encounter fightable
	# again without forcing a redundant map click. Contract retries do not
	# use tavern_map_choice_made, but setting it true here is harmless and
	# keeps the retry path uniform.
	tavern_map_choice_made = true
	set_locked(false)
	run_state_changed.emit()
	return true


func has_claimed_current_reward() -> bool:
	if is_contract_fight_active():
		return current_route_node != null and claimed_route_reward_ids.has(current_route_node.id)
	return claimed_reward_encounter_indices.has(current_encounter_index)


func claim_current_reward() -> bool:
	if run_phase != RunPhase.RESULT or not last_fight_won:
		return false
	if has_claimed_current_reward():
		return false
	var reward := current_reward()
	if is_contract_fight_active():
		claimed_route_reward_ids.append(current_route_node.id)
	else:
		var encounter := current_encounter()
		if encounter == null:
			return false
		claimed_reward_encounter_indices.append(current_encounter_index)
	if reward != null:
		add_gold(modified_gold_reward(reward.gold_amount))
		add_talent_points(reward.talent_points)
		for gear in reward.fixed_gear_rewards:
			grant_gear(gear)
		pending_reward_choices = _gear_choices_for_reward(reward)
		if reward.unlocks_shop:
			shop_unlocked = true
	build_changed.emit()
	run_state_changed.emit()
	return true


func has_pending_reward_choice() -> bool:
	return not pending_reward_choices.is_empty()


func choose_pending_reward_gear(gear: GearItem) -> bool:
	if gear == null or not pending_reward_choices.has(gear):
		return false
	var should_auto_equip := gear.tier == GearItem.Tier.LEGENDARY or not can_add_inventory_item()
	var granted := grant_gear(gear, should_auto_equip)
	if not granted:
		return false
	pending_reward_choices = []
	build_changed.emit()
	run_state_changed.emit()
	return true


func should_open_shop_after_current_reward() -> bool:
	if is_contract_fight_active():
		return shop_unlocked and current_route_node != null and not current_route_node.next_nodes.is_empty()
	return shop_unlocked and current_encounter_index + 1 < RunFlow.encounter_count()


## True right when claiming the current reward is what starts the Contract
## Offer -- the P2:R7 story pass's "skip the shop, head straight into the
## contract story" transition hooks off this. Mirrors continue_after_win()'s
## own "last tavern encounter" check exactly, evaluated before that call
## changes current_encounter_index, so the two stay in lockstep.
func is_last_tavern_reward() -> bool:
	return not is_contract_fight_active() and current_encounter_index + 1 >= RunFlow.tavern_encounter_count()


func open_shop_round() -> bool:
	if not should_open_shop_after_current_reward():
		return false
	shop_round_pending = true
	shop_reroll_used = false
	shop_offers = _generate_tavern_shop_offers(shop_round_index, false)
	build_changed.emit()
	run_state_changed.emit()
	return true


func reroll_shop_offers() -> bool:
	if not shop_round_pending or shop_reroll_used:
		return false
	shop_reroll_used = true
	shop_offers = _generate_tavern_shop_offers(shop_round_index, true)
	build_changed.emit()
	run_state_changed.emit()
	return true


func buy_shop_offer(offer: GearItem) -> bool:
	if not shop_round_pending or offer == null or not shop_offers.has(offer):
		return false
	if not can_store_shop_offer(offer):
		return false
	var price := GearGenerator.price_for_tier(offer.tier)
	if not spend_gold(price):
		return false
	shop_offers.erase(offer)
	grant_gear(offer)
	build_changed.emit()
	run_state_changed.emit()
	return true


func can_store_shop_offer(offer: GearItem) -> bool:
	return offer != null and can_add_inventory_item()


func has_open_equipment_slot(slot: GearItem.SlotType) -> bool:
	return _equipped_item_for_slot(slot) == null


func close_shop_round() -> bool:
	if not shop_round_pending:
		return false
	shop_round_pending = false
	shop_round_index += 1
	shop_offers = []
	run_state_changed.emit()
	return true


func continue_after_win() -> bool:
	if run_phase != RunPhase.RESULT or not last_fight_won:
		return false
	if is_contract_fight_active():
		if current_route_node.next_nodes.is_empty():
			end_run(true, RunOutcome.CONTRACT_VICTORY)
			return false
		run_phase = RunPhase.CONTRACT_ROUTE
		run_outcome = RunOutcome.NONE
		last_fight_won = false
		set_locked(false)
		run_state_changed.emit()
		return true
	if current_encounter_index + 1 >= RunFlow.tavern_encounter_count():
		return start_contract_offer()
	var has_next := advance_encounter()
	if has_next:
		run_phase = RunPhase.PLANNING
		run_outcome = RunOutcome.NONE
		tavern_map_choice_made = false
	else:
		run_phase = RunPhase.RUN_ENDED
		run_outcome = RunOutcome.CONTRACT_VICTORY if active_contract != null else RunOutcome.FIGHT_WIN
	run_state_changed.emit()
	return has_next


func _generate_tavern_shop_offers(round_index: int, is_reroll: bool) -> Array[GearItem]:
	var shop_context := _current_reward_context_key()
	var rng := RunRngSystem.rng_for_context(
		adventure_seed,
		RunRngSystem.CONTEXT_SHOP_OFFER,
		[shop_context, round_index, "reroll" if is_reroll else "initial"]
	)
	var offers: Array[GearItem] = []
	var seen_signatures := {}
	for i in SHOP_OFFER_COUNT:
		var stable_id := RunRngSystem.id_for_context(
			"gear.generated.shop",
			adventure_seed,
			RunRngSystem.CONTEXT_SHOP_OFFER,
			[shop_context, round_index, "reroll" if is_reroll else "initial", i]
		)
		offers.append(_generate_unique_shop_offer(rng, stable_id, seen_signatures))
	return offers


func _generate_unique_shop_offer(rng: RandomNumberGenerator, stable_id: String, seen_signatures: Dictionary) -> GearItem:
	var fallback_offer: GearItem = null
	var fallback_signature := ""
	for attempt in SHOP_UNIQUE_ROLL_ATTEMPTS:
		var slot: GearItem.SlotType = GearGenerator.ALL_SLOTS[rng.randi_range(0, GearGenerator.ALL_SLOTS.size() - 1)]
		var tier := _shop_tier_for_current_phase(rng)
		var offer := _shop_offer_for_tier(tier, slot, rng, stable_id)
		var signature := _shop_offer_signature(offer)
		if fallback_offer == null:
			fallback_offer = offer
			fallback_signature = signature
		if not seen_signatures.has(signature):
			seen_signatures[signature] = true
			return offer
	# The visible item space is much larger than SHOP_OFFER_COUNT, so this is
	# a deterministic guardrail rather than an expected path.
	seen_signatures[fallback_signature] = true
	return fallback_offer


func _shop_tier_for_current_phase(rng: RandomNumberGenerator) -> GearItem.Tier:
	if active_contract == null:
		return GearItem.Tier.BASIC
	var total_weight := (
		CONTRACT_SHOP_BASIC_WEIGHT
		+ CONTRACT_SHOP_MASTER_WEIGHT
		+ CONTRACT_SHOP_CURSED_WEIGHT
		+ CONTRACT_SHOP_LEGENDARY_WEIGHT
	)
	var roll := rng.randi_range(1, total_weight)
	if roll <= CONTRACT_SHOP_BASIC_WEIGHT:
		return GearItem.Tier.BASIC
	if roll <= CONTRACT_SHOP_BASIC_WEIGHT + CONTRACT_SHOP_MASTER_WEIGHT:
		return GearItem.Tier.MASTER
	if roll <= CONTRACT_SHOP_BASIC_WEIGHT + CONTRACT_SHOP_MASTER_WEIGHT + CONTRACT_SHOP_CURSED_WEIGHT:
		return GearItem.Tier.CURSED
	return GearItem.Tier.LEGENDARY


func _shop_offer_for_tier(tier: GearItem.Tier, slot: GearItem.SlotType, rng: RandomNumberGenerator, stable_id: String) -> GearItem:
	if tier != GearItem.Tier.LEGENDARY:
		return GearGenerator.generate(tier, slot, rng, stable_id)
	var available_paths := _unowned_shop_legendary_paths()
	if available_paths.is_empty():
		# Every Legendary is already owned -- fall back to the next-lower
		# tier rather than offering a duplicate the player can't use.
		return GearGenerator.generate(GearItem.Tier.CURSED, slot, rng, stable_id)
	var path := available_paths[rng.randi_range(0, available_paths.size() - 1)]
	var offer: GearItem = load(path)
	return offer


## Excludes Legendaries already owned (inventory or equipped) from the
## shop's Legendary roll (P2:R9:T6) -- compares by `.id` rather than object
## identity, consistent with `_shop_offer_signature()`'s property-based
## comparison.
## The full Legendary path list, sourced from `LegendaryCatalog` (P2:R9/R10's
## single shared source) rather than a duplicated literal here.
func shop_legendary_paths() -> Array[String]:
	return LegendaryCatalog.all_paths()


func _unowned_shop_legendary_paths() -> Array[String]:
	var owned_ids := {}
	for gear in inventory:
		if gear != null:
			owned_ids[gear.id] = true
	for gear in equipped_gear():
		if gear != null:
			owned_ids[gear.id] = true
	var available: Array[String] = []
	for path in shop_legendary_paths():
		var candidate: GearItem = load(path)
		if not owned_ids.has(candidate.id):
			available.append(path)
	return available


func _shop_offer_signature(offer: GearItem) -> String:
	var affix_parts: PackedStringArray = []
	for affix in offer.affixes:
		affix_parts.append("%d:%d:%.4f" % [affix.stat, affix.operation, affix.value])
	return "%d|%d|%s" % [offer.tier, offer.slot, ",".join(affix_parts)]


func _gear_choices_for_reward(reward: EncounterReward) -> Array[GearItem]:
	var choices: Array[GearItem] = []
	for gear in reward.gear_choice_rewards:
		if gear != null:
			choices.append(gear)
	var reward_context := _current_reward_context_key()
	if reward.legendary_choice_count > 0 and not reward.legendary_choice_pool.is_empty():
		var legendary_rng := RunRngSystem.rng_for_context(
			adventure_seed,
			RunRngSystem.CONTEXT_REWARD_CHOICE,
			[reward_context, "legendary", reward.legendary_choice_count]
		)
		choices.append_array(_sample_distinct_gear(reward.legendary_choice_pool, reward.legendary_choice_count, legendary_rng))
	if reward.generated_gear_choice_count <= 0:
		return choices
	var rng := RunRngSystem.rng_for_context(
		adventure_seed,
		RunRngSystem.CONTEXT_REWARD_CHOICE,
		[reward_context, reward.generated_gear_tier, reward.generated_gear_choice_count]
	)
	var slots := reward.generated_gear_slots
	for i in reward.generated_gear_choice_count:
		var slot: GearItem.SlotType
		if i < slots.size():
			slot = slots[i]
		else:
			slot = GearGenerator.ALL_SLOTS[rng.randi_range(0, GearGenerator.ALL_SLOTS.size() - 1)]
		var stable_id := RunRngSystem.id_for_context(
			"gear.generated.reward",
			adventure_seed,
			RunRngSystem.CONTEXT_REWARD_CHOICE,
			[reward_context, reward.generated_gear_tier, i, slot]
		)
		choices.append(GearGenerator.generate(reward.generated_gear_tier, slot, rng, stable_id))
	return choices


## Picks `count` distinct entries from `pool` using seeded `rng`, without
## replacement. Used for Knives' randomized Legendary choice (P2:R9:T5) so
## the same Adventure seed always produces the same 2-of-5 result.
func _sample_distinct_gear(pool: Array[GearItem], count: int, rng: RandomNumberGenerator) -> Array[GearItem]:
	var remaining: Array[GearItem] = pool.duplicate()
	var picked: Array[GearItem] = []
	var take := mini(count, remaining.size())
	for i in take:
		var index := rng.randi_range(0, remaining.size() - 1)
		picked.append(remaining[index])
		remaining.remove_at(index)
	return picked


func _current_reward_context_key() -> String:
	if is_contract_fight_active() and current_route_node != null:
		return "route:%s" % current_route_node.id
	return "encounter:%d" % current_encounter_index


func end_run(won: bool, outcome: int = RunOutcome.NONE) -> void:
	last_fight_won = won
	if outcome != RunOutcome.NONE:
		run_outcome = outcome
	elif won:
		run_outcome = RunOutcome.CONTRACT_VICTORY if active_contract != null else RunOutcome.FIGHT_WIN
	else:
		run_outcome = RunOutcome.CONTRACT_FAILED if active_contract != null else RunOutcome.ADVENTURE_RESTART_REQUIRED
	run_phase = RunPhase.RUN_ENDED
	run_state_changed.emit()


## Advances to the next encounter. Returns false when the ladder is
## exhausted (i.e. the just-fought encounter was the last one).
func advance_encounter() -> bool:
	current_encounter_index += 1
	build_changed.emit()
	return current_encounter_index < RunFlow.encounter_count()


func _current_fight_key() -> String:
	if active_contract != null and current_route_node != null and current_route_node.monster != null:
		return current_route_node.id
	return "encounter:%d" % current_encounter_index


func add_gold(amount: int) -> void:
	gold += amount
	build_changed.emit()


func modified_gold_reward(base_amount: int) -> int:
	var multiplier := 1.0
	for gear in equipped_gear():
		for modifier in gear.affixes:
			if modifier.stat == StatModifier.StatType.GOLD_REWARDS:
				multiplier *= 1.0 + modifier.value
	return max(0, roundi(float(base_amount) * multiplier))


func add_talent_points(amount: int) -> void:
	earned_talent_points += amount
	build_changed.emit()


func spend_gold(amount: int) -> bool:
	if amount > gold:
		return false
	gold -= amount
	build_changed.emit()
	return true


func add_inventory_item(gear: GearItem) -> bool:
	if gear == null or inventory.has(gear) or not can_add_inventory_item():
		return false
	inventory.append(gear)
	build_changed.emit()
	return true


func can_add_inventory_item() -> bool:
	return inventory.size() < INVENTORY_CAPACITY


func remove_inventory_item(gear: GearItem) -> bool:
	if gear == null or not inventory.has(gear):
		return false
	inventory.erase(gear)
	build_changed.emit()
	return true


func has_inventory_item(gear: GearItem) -> bool:
	return gear != null and inventory.has(gear)


func grant_gear(gear: GearItem, auto_equip: bool = false) -> bool:
	if gear == null:
		return false
	if auto_equip:
		equip(gear)
	else:
		return add_inventory_item(gear)
	return true


func sell_inventory_item(gear: GearItem) -> bool:
	if not has_inventory_item(gear):
		return false
	inventory.erase(gear)
	gold += sell_value_for(gear)
	build_changed.emit()
	run_state_changed.emit()
	return true


func sell_equipped_item(slot: GearItem.SlotType) -> bool:
	var gear := _equipped_item_for_slot(slot)
	if gear == null:
		return false
	match slot:
		GearItem.SlotType.WEAPON:
			equipped_weapon = null
		GearItem.SlotType.TRINKET:
			equipped_trinket = null
		GearItem.SlotType.CHARM:
			equipped_charm = null
	gold += sell_value_for(gear)
	build_changed.emit()
	run_state_changed.emit()
	return true


func sell_value_for(gear: GearItem) -> int:
	if gear == null:
		return 0
	return max(1, int(floor(float(GearGenerator.price_for_tier(gear.tier)) * SELL_VALUE_RATIO)))


func equip_from_inventory(gear: GearItem) -> bool:
	if not has_inventory_item(gear):
		return false
	equip(gear)
	return true


func equip(gear: GearItem) -> void:
	if gear == null:
		return
	inventory.erase(gear)
	var replaced: GearItem = _equipped_item_for_slot(gear.slot)
	match gear.slot:
		GearItem.SlotType.WEAPON:
			equipped_weapon = gear
		GearItem.SlotType.TRINKET:
			equipped_trinket = gear
		GearItem.SlotType.CHARM:
			equipped_charm = gear
	if replaced != null and replaced != gear and not inventory.has(replaced):
		inventory.append(replaced)
	build_changed.emit()


func unequip(slot: GearItem.SlotType) -> void:
	var removed: GearItem = _equipped_item_for_slot(slot)
	if removed == null:
		return
	match slot:
		GearItem.SlotType.WEAPON:
			equipped_weapon = null
		GearItem.SlotType.TRINKET:
			equipped_trinket = null
		GearItem.SlotType.CHARM:
			equipped_charm = null
	if not inventory.has(removed):
		inventory.append(removed)
	build_changed.emit()


func _equipped_item_for_slot(slot: GearItem.SlotType) -> GearItem:
	match slot:
		GearItem.SlotType.WEAPON:
			return equipped_weapon
		GearItem.SlotType.TRINKET:
			return equipped_trinket
		GearItem.SlotType.CHARM:
			return equipped_charm
	return null


## Weapon -> trinket -> charm order, matching the gear-application order in
## docs/Phase 1 Context Docs/Current_Mechanics_Reference.md's Build
## Resolution section.
func equipped_gear() -> Array[GearItem]:
	var gear: Array[GearItem] = []
	for item in [equipped_weapon, equipped_trinket, equipped_charm]:
		if item != null:
			gear.append(item)
	return gear


func set_class(class_def: ClassDef) -> void:
	selected_class = class_def
	selected_trees = []
	selected_talents = []
	rotation = []
	build_changed.emit()


## Picks exactly one subclass tree, clearing any other selection -- distinct
## from toggle_tree()'s multi-select (up to PassiveAllocator.MAX_TREES)
## semantics, used by the single-choice subclass_select screen.
func select_tree(tree: SubclassTree) -> void:
	selected_trees = [tree]
	var remaining: Array[Talent] = []
	for talent in selected_talents:
		if tree.talents.has(talent):
			remaining.append(talent)
	selected_talents = remaining
	_prune_rotation_to_unlocked()
	build_changed.emit()


func toggle_tree(tree: SubclassTree) -> bool:
	if selected_trees.has(tree):
		selected_trees.erase(tree)
		var remaining: Array[Talent] = []
		for talent in selected_talents:
			for kept_tree in selected_trees:
				if kept_tree.talents.has(talent):
					remaining.append(talent)
					break
		selected_talents = remaining
	elif PassiveAllocator.can_select_tree(selected_trees, tree):
		selected_trees.append(tree)
	else:
		return false
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


func _prune_rotation_to_unlocked() -> void:
	var unlocked := unlocked_skills()
	var pruned := BuildResolver.resolve_rotation(rotation, unlocked)
	rotation = pruned
