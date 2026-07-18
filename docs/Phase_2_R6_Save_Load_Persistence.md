# P2:R6 - Save/Load Persistence

## Purpose

Track the work for **P2:R6 - Save/Load Persistence**.

The goal is to persist an in-progress Adventure run across sessions after the
run loop, rewards, contract route, and deterministic state have been shaped by
P2:R2 through P2:R5.

## Exit Criteria

P2:R6 is complete when:

- The player can save or auto-save an in-progress run.
- The player can quit, relaunch, and resume the same run state.
- Saved data restores class, trees, talents, rotation, inventory, equipment,
  gold, seed, current encounter/route node, rewards/shop state, and relevant
  failure state.
- Save/load handles missing/corrupt/incompatible data gracefully enough for a
  playtest build.
- Headless tests verify round-trip persistence.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R6:T1 | Define Save Scope | Exact state fields to persist | Complete |
| P2:R6:T2 | Choose Save Format | Resource paths/ids and generated item data represented safely | Complete |
| P2:R6:T3 | Implement Serialization | Save system converts run state to/from data | Complete |
| P2:R6:T4 | Add Save/Load UI Hooks | Resume/new/abandon/save-and-quit actions reachable | Complete |
| P2:R6:T5 | Handle Versioning/Errors | Missing/corrupt/incompatible save behavior | Complete |
| P2:R6:T6 | Integrate Auto-Save Points | Save after meaningful state transitions | Complete |
| P2:R6:T7 | Remove Contradictory UI Copy | Main-menu warning reflects persistence behavior | Complete |
| P2:R6:T8 | Add/Update Tests | Save/load round trip verified headlessly | Complete |
| P2:R6:T9 | Update Docs | Persistence model documented | Complete |

## P2:R6:T1 - Define Save Scope

Audit state from previous milestones:

- Selected class.
- Selected primary/secondary trees.
- Selected talents.
- Rotation.
- Gold.
- Talent points/remaining budget if separate.
- Inventory.
- Equipped weapon/trinket/charm.
- Generated gear details.
- Run seed.
- Current Tavern/contract/route state.
- Current encounter or node.
- Shop state and reroll usage.
- Reward choices pending or claimed.
- Failure/do-over state.
- Last result/log only if useful.

Completed 2026-07-17. Full field-by-field audit against
`project/scripts/autoload/build_state.gd` (the single source of run state):

| `BuildState` field | Type | Category | Notes |
|---|---|---|---|
| `selected_class` | `ClassDef` | authored-ref | Always loaded from `res://data/classes/*.tres`; save `resource_path`. |
| `selected_trees` | `Array[SubclassTree]` | authored-ref | Save `resource_path` per entry. |
| `selected_talents` | `Array[Talent]` | authored-ref | Save `resource_path` per entry. |
| `rotation` | `Array[Skill]` | derived-ref (by id) | Entries are runtime clones from `BuildResolver.resolve_unlocked_skills()` (`skill.duplicate(true)`), so `resource_path` is empty and cannot be used. Save each skill's stable `id` string; restore by recomputing `unlocked_skills()` after class/trees/talents are restored and matching by id (same approach `BuildResolver.resolve_rotation()` already uses). |
| `adventure_seed` | `int` | primitive | |
| `gold` | `int` | primitive | |
| `earned_talent_points` | `int` | primitive | |
| `inventory` | `Array[GearItem]` | mixed authored-ref / generated-value | See gear rule below. |
| `claimed_reward_encounter_indices` | `Array[int]` | primitive | |
| `shop_unlocked` | `bool` | primitive | |
| `shop_round_pending` | `bool` | primitive | |
| `shop_reroll_used` | `bool` | primitive | |
| `shop_round_index` | `int` | primitive | |
| `shop_offers` | `Array[GearItem]` | generated-value | Always produced by `GearGenerator.generate()`, never authored; see gear rule. Only meaningful mid-shop-round (`shop_round_pending == true`). |
| `pending_reward_choices` | `Array[GearItem]` | mixed authored-ref / generated-value | Can contain authored fixed choices (e.g. Knives Legendary pair) and/or `GearGenerator`-produced entries in the same array; see gear rule. |
| `equipped_weapon` / `equipped_trinket` / `equipped_charm` | `GearItem` | mixed authored-ref / generated-value | See gear rule. |
| `active_contract` | `ContractDef` | authored-ref | Loaded from the fixed `GILDED_SERPENT_CONTRACT_PATH`; save `resource_path` (or just a bool/id, since only one contract exists today, but path is future-proof and free). |
| `current_route_node` | `ContractRouteNode` | authored-ref | Each route node is its own `.tres` file under `project/data/contract_routes/gilded_serpent/` with a real `resource_path` (confirmed on disk, not inline sub-resources) — save by path. |
| `claimed_route_reward_ids` | `Array[String]` | primitive | Already stable id strings (`ContractRouteNode.id`). |
| `current_encounter_index` | `int` | primitive | |
| `encounter_failure_counts` | `Dictionary[String, int]` | primitive | Already keyed by stable fight-key strings (`"encounter:%d"` or route node id); serializes directly. |
| `run_phase` | `int` (`RunPhase` enum) | primitive | Save as int; restoring mid-`FIGHTING` is meaningless (see autosave-point note below) so loads should normalize `FIGHTING` back to `PLANNING`. |
| `run_outcome` | `int` (`RunOutcome` enum) | primitive | |
| `last_fight_won` | `bool` | primitive | |
| `tavern_map_choice_made` | `bool` | primitive | |
| `build_locked` | `bool` | primitive | Derived from build state each time a mutation happens (`_clear_lock_on_change`); safe to restore as `false` rather than persist, since any load should require re-confirming the build lock before fighting. |

**Gear serialization rule** (applies to `inventory`, `shop_offers`,
`pending_reward_choices`, and the three equipped slots): Godot clears
`Resource.resource_path` to `""` on any resource created at runtime
(`GearItem.new()`, as `GearGenerator.generate()` does) and never sets it
for `.duplicate()` results, while `.tres` files loaded via `load()` always
carry their real path. `GearItem.resource_path != ""` is therefore a
reliable, already-available discriminator:

- If `resource_path != ""`: it's authored content (e.g. `lucky_coin.tres`,
  `wyvern_kriss.tres`, `mithril_karambit.tres`, `placeholder_dagger.tres`).
  Save `resource_path` only.
- If `resource_path == ""`: it's a `GearGenerator`-produced item. Save its
  full value data instead: `id` (already a stable/deterministic string from
  `RunRng.id_for_context()` for shop/reward items), `slot`, `tier`, and
  `affixes` (each `StatModifier`'s `stat`/`operation`/`value`). Generated
  items never carry `triggered_skill_effects` today (only authored
  Legendary gear does), so that field only needs restoring for the
  authored-ref case, where it comes back automatically via `load()`.

**Explicitly excluded from save scope:** combat log / last cast-event
detail. Nothing in `BuildState` stores it (it lives transiently in
`combat_screen.gd`'s result display), and the doc's own T1 checklist marks
it "only if useful" — it isn't: resuming a session doesn't need the
previous fight's play-by-play, only the state that determines the next
fight.

**Mid-fight save note:** `run_phase == RunPhase.FIGHTING` is a transient
state with no persisted combat-tick data (`CombatResolver` runs
synchronously to completion within one call). `P2:R6:T6`'s autosave points
should never fire while `FIGHTING`, and `P2:R6:T3`'s load path should treat
a saved `FIGHTING` phase (e.g. from a hard crash) as `PLANNING` defensively.

## P2:R6:T2 - Choose Save Format

Prefer a format that is:

- Inspectable during development.
- Stable across resource reloads.
- Friendly to generated items.
- Versioned enough for playtest iteration.

Likely approach: store resource paths or stable ids for authored content, and
store generated item affixes as plain data.

Confirmed 2026-07-17 (with user): JSON at `user://save.json`, written/read
via `FileAccess`, chosen over `ConfigFile` (awkward for nested gear-affix
arrays) and a binary `Resource` save file (not human-inspectable, more
brittle across schema changes during dev iteration). Concretely:

- Top-level object carries `save_version: int` so `P2:R6:T5` has something
  to check.
- Authored resources (`selected_class`, `selected_trees`, `selected_talents`,
  `active_contract`, `current_route_node`, and any `GearItem` with a
  non-empty `resource_path`) are saved as their `resource_path` string and
  restored via `load()`.
- `rotation` skills are saved as their stable `id` strings only (per the
  `P2:R6:T1` audit, rotation entries are runtime clones with no
  `resource_path`) and restored by recomputing `unlocked_skills()` after
  class/trees/talents load, matching by id.
- Generated `GearItem`s (empty `resource_path`) are saved as plain data:
  `id`, `display_name`, `slot` (int), `tier` (int), `affixes` (array of
  `{stat: int, operation: int, value: float}`). `display_name` was added
  during `P2:R6:T3` implementation (not anticipated at T2 confirmation time)
  so a restored generated item shows its original rolled name instead of
  requiring `GearGenerator`'s private naming logic to be re-derived at load
  time.
- All other fields (`gold`, `adventure_seed`, `run_phase`, failure counts,
  etc.) are primitives and serialize directly.

## P2:R6:T3 - Implement Serialization

Add a small save/load system rather than spreading persistence through UI
scripts.

It should:

- Convert run state to serializable data.
- Restore authored resources by path/id.
- Reconstruct generated gear.
- Emit/trigger state refresh so panels update.

Complete 2026-07-17. Added `project/scripts/systems/save_system.gd`
(`SaveSystem`, static, `RefCounted`, matching the `GearGenerator`/
`BuildResolver`/`RunRng` system style):

- `has_save()`, `delete_save()`, `save_run(state)`, `load_run(state)`. `state`
  is passed explicitly (not read from the `BuildState` autoload global)
  purely for testability; production call sites pass the real autoload.
- `save_run()` walks every `BuildState` field per the `P2:R6:T1` scope table
  and writes JSON to `SaveSystem.SAVE_PATH` (`user://save.json`).
- `load_run()` resolves every field into locals first (loading authored
  resources, reconstructing generated gear, recomputing rotation skill
  matches) and only writes to `state` once the whole save is structurally
  valid, so a corrupt/incompatible save file leaves live state untouched and
  `load_run()` returns `false`. It emits `build_changed`, `run_state_changed`,
  and `lock_changed` once at the end so listening panels refresh from a
  single consistent state rather than firing per-field.
- A saved `run_phase == FIGHTING` is normalized back to `PLANNING` on load
  (see the `P2:R6:T1` mid-fight note); `build_locked` is always restored as
  `false` per the same T1 decision.
- Individual unresolved gear references (e.g. a deleted authored `.tres`)
  degrade gracefully by being dropped/cleared rather than failing the whole
  load; only top-level structural problems (bad JSON, wrong `save_version`,
  or an unloadable class/tree/talent/contract/route-node reference) abort
  the load entirely.
- Real bug caught during verification: Godot's `JSON.parse_string()` has no
  int/float distinction and always produces `float` for JSON numbers, so a
  first-pass implementation that round-tripped `encounter_failure_counts` via
  a plain `Dictionary.duplicate()` silently turned its int values into
  floats after a load. Harmless in practice (every read site already wraps
  values in `int()`), but not a faithful restore, so `load_run()` now
  explicitly re-casts failure-count dictionary values to `int` via a small
  `_int_dictionary()` helper.

## P2:R6:T4 - Add Save/Load UI Hooks

Add player-facing flows:

- Resume run if save exists.
- Start new run.
- Save and quit.
- Abandon run, with confirmation.

Keep UI minimal but clear enough for P2:R8 playtest.

Complete 2026-07-17. All four actions are reachable through the existing
Title/dashboard screens, reusing the confirm-dialog pattern already
established for destructive actions rather than introducing a new UI
concept:

- **Resume**: `scenes/title/title.gd` shows a "Continue Adventure" button,
  visible only when `SaveSystem.has_save()` is true. Pressing it emits a new
  `continue_pressed` signal; `game_root.gd`'s `_on_continue_pressed()` calls
  `SaveSystem.load_run(BuildState)` and, on success, jumps straight to
  `_show_combat_screen()` (skipping class/subclass select, since the loaded
  state already has those resolved). On a failed load (corrupt/incompatible
  save), it deletes the bad save file and stays on Title so Continue doesn't
  keep offering a load that will never succeed.
- **New Game**: "Adventure Mode" now routes through
  `_on_adventure_button_pressed()` in `title.gd`. If no save exists it
  proceeds immediately (unchanged behavior); if a save exists it pops a
  `ConfirmationDialog` ("Starting a new Adventure will discard your saved
  run.") before emitting `adventure_pressed`. `game_root.gd`'s
  `_on_new_game_pressed()` deletes any save and resets `BuildState` before
  advancing to class select -- this is also what makes it safe to reach
  Title via Save & Quit without a stale run leaking into a subsequent new
  game.
- **Save & Quit**: `combat_screen.gd` gained a "Save & Quit" button in the
  top bar next to the menu controls. It calls
  `SaveSystem.save_run(BuildState)` and emits a new `save_and_quit_pressed`
  signal; `game_root.gd` connects this to `_on_save_and_quit_pressed()`,
  which returns to Title (deliberately not resetting `BuildState`, since the
  in-memory state is already what was just written to disk).
- **Abandon Run**: the former "Return to Main Menu" button/dialog is renamed
  "Abandon Run" to describe what it now actually does. Its existing
  `ConfirmationDialog` (unchanged UX -- still requires confirmation before
  firing) now also calls `SaveSystem.delete_save()` on confirm, so abandoning
  a run doesn't leave a stale save behind that Continue would later offer.
- A resumed save can land directly in a terminal `RunOutcome` (e.g. a
  pending do-over, or a contract already failed/won at save time).
  `combat_screen.gd`'s `_ready()`-equivalent build sequence now calls the
  existing `_apply_outcome_presentation(BuildState.run_outcome)` once at the
  end, which already no-ops for `RunOutcome.NONE` (the normal fresh-run
  case), so this makes Continue restore an accurate banner/button state
  without adding a second code path.
- Added `tests/save_load_ui_test.gd`, driving the real Title/`game_root`
  scene tree: confirms Continue is hidden with no save, confirms Adventure
  Mode proceeds without a dialog when no save exists, confirms Save & Quit
  produces a loadable save and makes Continue visible, confirms Adventure
  Mode warns (and doesn't discard on cancel) when a save exists, confirms
  Continue restores gold/seed/class/tree state and returns straight to the
  dashboard, and confirms Abandon Run deletes the save and hides Continue
  again. Updated `tests/combat_screen_test.gd`'s existing menu-button lookup
  from `"Return to Main Menu"` to `"Abandon Run"` to match the rename.

## P2:R6:T5 - Handle Versioning/Errors

Handle:

- No save file.
- Corrupt save file.
- Save version mismatch.
- Missing resource path.
- Invalid generated item data.

The safest playtest fallback can be "discard save and start new run" if
explained clearly.

Complete 2026-07-17, delivered as part of `P2:R6:T3`'s `SaveSystem`
implementation rather than as separate follow-up work, since the format
chosen at `P2:R6:T2` made the error paths cheap to build in from the start:

- No save file: `load_run()` returns `false` immediately via `has_save()`.
- Corrupt save file: `JSON.parse_string()` returning anything other than a
  `Dictionary` (parse failure, or valid JSON that isn't an object) fails the
  load.
- Save version mismatch: `save_version` is checked against
  `SaveSystem.SAVE_VERSION` before any field is touched; any mismatch
  (including a save from a newer/older build) fails the load.
- Missing/invalid resource path or generated item data: authored references
  required for the game to make sense (class/trees/talents/contract/route
  node) fail the whole load if unresolvable; gear references (inventory,
  shop offers, pending reward choices, equipped slots) degrade gracefully by
  being dropped/cleared instead, since losing one item is recoverable in a
  way that losing your class/build isn't.
- All three failure paths (missing/corrupt/incompatible-version) are covered
  by `tests/save_load_test.gd`, per `P2:R6:T8`.
- The chosen playtest fallback is "discard and start new" per the doc's own
  suggestion: `load_run()` returning `false` leaves `state` untouched, so
  `P2:R6:T4`'s UI hooks can treat that as "no valid save, proceed to a new
  run" without extra handling.

## P2:R6:T6 - Integrate Auto-Save Points

Decide where to save:

- After character/subclass choices.
- After reward claim.
- After shop actions.
- After route choice.
- After fight result/failure state.
- On save-and-quit.

Avoid saving mid-transition if state would resume ambiguously.

Complete 2026-07-17. Added a shared `_autosave()` helper in `combat_screen.gd`
(`SaveSystem.save_run(BuildState)`, same call `Save & Quit` already used) and
called it after every meaningful state transition rather than only on
explicit Save & Quit:

- Class + subclass selection: `game_root.gd`'s `_on_subclass_select_advanced()`
  saves once both initial build choices are committed, before the dashboard
  even loads.
- Tavern encounter choice, contract offer acceptance, and contract route node
  choice (`_on_map_node_pressed()`, `_on_contract_map_pressed()`,
  `_on_contract_route_node_pressed()`).
- Secondary subclass tree choice (`_on_secondary_tree_pressed()`).
- Fight result, win or loss (`_on_fight_pressed()`, after
  `BuildState.finish_fight()` has already resolved the fight synchronously --
  see the mid-fight note below).
- Reward claim (`_on_continue_pressed()`), reward-choice gear pick
  (`_on_reward_choice_pressed()`), shop buy/reroll
  (`_on_shop_buy_pressed()`/`_on_shop_reroll_pressed()`), and encounter/route
  advancement after a shop or reward round closes -- the last one lives in
  `_advance_after_reward_or_shop()` itself (called from three different
  handlers) rather than being duplicated at each call site.
- Retry after a first Tavern loss (`_on_retry_pressed()`).

Deliberately not an autosave point: mid-fight. `BuildState.run_phase` only
ever equals `FIGHTING` for the duration of a single synchronous
`CombatResolver.resolve()` call inside `_on_fight_pressed()` -- by the time
any handler reaches its `_autosave()` call, `BuildState.finish_fight()` has
already moved `run_phase` to `RESULT`/`RUN_ENDED`, so there is no code path
where an autosave can capture the transient `FIGHTING` state. This matches
the `P2:R6:T1`/`T3` decision to normalize a saved `FIGHTING` phase back to
`PLANNING` defensively, which remains a hard-crash-only fallback rather than
something autosave is expected to produce in normal play.

## P2:R6:T7 - Remove Contradictory UI Copy

Update existing text such as "Your current build will be lost" once save/load
exists. Distinguish:

- Return to main menu.
- Save and quit.
- Abandon run.
- Resume.

Complete 2026-07-17. The one contradictory string this task originally
flagged -- the old "Return to Main Menu" button/dialog wording that implied
silently discarding progress -- was already fixed at `P2:R6:T4`: the button
and dialog were renamed to "Abandon Run" with dialog text that accurately
says saved progress will be deleted. A follow-up sweep for this task
(`grep` across `project/scenes` for "lost"/"discard"/"unsaved"/"Return to
Main Menu") found no other contradictory copy in any reachable screen.
`scenes/tavern/shop.gd` and `scenes/build_planner/run_end.gd` still contain
older button text, but both are dormant retired scenes per the UI-restructure
note in `docs/Phase_2_Milestones.md` -- unreachable through `game_root.gd`'s
current screen graph, so out of scope here. The four player-facing actions
are now clearly distinguished: **Resume** ("Continue Adventure" on Title,
only visible when a save exists), **Save and quit** (explicit button in the
dashboard top bar), **Abandon run** (destructive, confirmed, deletes the
save), and **New Game** ("Adventure Mode," which warns and confirms only if
a save would be discarded).

## P2:R6:T8 - Add/Update Tests

Tests should:

- Build a nontrivial run state.
- Save it.
- Reset state.
- Load it.
- Assert class/tree/talents/rotation/gear/gold/seed/current node/failure
  state are restored.
- Resolve a fight after loading.

Complete 2026-07-17. Added `project/tests/save_load_test.gd`:

- Builds a nontrivial run (Rogue/Thief, a talent, a rotation skill, gold,
  talent points, an authored inventory item (Lucky Coin), a generated
  equipped charm, adventure seed, a recorded Tavern loss/retry-available
  state, and an open shop round with generated offers), saves it, resets
  `BuildState` to prove the reset actually took effect, loads it back, and
  compares a full field-by-field signature string of every `P2:R6:T1`-scoped
  field before vs. after.
- Then proves the restored state is actually usable, not just structurally
  present: retries the recorded loss, re-confirms the Tavern map choice and
  build lock (both required again after a retry, matching the real UI flow),
  and resolves a real fight via `CombatResolver.resolve()` against the
  restored build/rotation/target.
- Also exercises all three `P2:R6:T5` failure paths: no save file present,
  corrupt (unparseable) JSON, and a save with a `save_version` newer than
  `SaveSystem.SAVE_VERSION` -- all three assert `load_run()` returns `false`.
- Two real GDScript pitfalls hit while writing this test (both already
  latent risks in this codebase's `:=`-with-untyped-source pattern, not new
  ones): `var x := some_untyped_variable.method_returning_typed_array()`
  fails to compile ("cannot infer the type") when the receiver itself is
  untyped (here, the `Node` returned by `root.get_node("BuildState")`) --
  both `save_system.gd` and the test needed an explicit `Array[Skill]`
  annotation instead of `:=`. Separately, `set_rotation([unlocked[0]])`
  fails at runtime with a typed-array mismatch because a bare `[...]`
  literal is an untyped `Array`, not `Array[Skill]` -- fixed by assigning to
  an explicitly `Array[Skill]`-typed local first.

## P2:R6:T9 - Update Docs

When complete:

- Update this checklist.
- Document save format/version.
- Document user-facing persistence behavior.
- Update `docs/Phase_2_Milestones.md`.

Complete 2026-07-17, closing out `P2:R6 - Save/Load Persistence`. This
checklist and the per-task sections above already capture the final save
format/version (`P2:R6:T2`), the field-by-field scope audit (`P2:R6:T1`),
the autosave point list and mid-fight exclusion (`P2:R6:T6`), and the
user-facing Resume/New Game/Save & Quit/Abandon Run distinction (`P2:R6:T4`,
`P2:R6:T7`), so no further mechanic write-up was needed here.
`docs/Phase_2_Milestones.md` is updated separately to mark `P2:R6` complete
and record `P2:R7 - Game-Like UI Pass` as the next active milestone.

## Implementation Notes

2026-07-17:

- `P2:R6:T1` and `P2:R6:T2` are complete. See their sections above for the
  full field-by-field scope audit and confirmed JSON format.
- `P2:R6:T3`, `P2:R6:T5`, and `P2:R6:T8` are complete, delivered together:
  `SaveSystem` (`project/scripts/systems/save_system.gd`) implements
  serialization with built-in graceful error/versioning handling, and
  `tests/save_load_test.gd` verifies the full round trip plus all three
  failure paths. See their sections above for details.
- Remaining R6 work: `P2:R6:T4` (save/load UI hooks), `P2:R6:T6` (autosave
  points), `P2:R6:T7` (contradictory UI copy), and `P2:R6:T9` (final docs
  pass once T4/T6/T7 land).

2026-07-17:

- `P2:R6:T4` is complete. See its section above for the full breakdown of
  Resume/New Game/Save & Quit/Abandon Run wiring across `title.gd`,
  `game_root.gd`, and `combat_screen.gd`, plus the new
  `tests/save_load_ui_test.gd`.
- Remaining R6 work: `P2:R6:T6` (autosave points), `P2:R6:T7` (contradictory
  UI copy -- the "Abandon Run" dialog text is now accurate, but the broader
  UI-copy sweep the task describes hasn't been done), and `P2:R6:T9` (final
  docs pass once T6/T7 land).

2026-07-17:

- `P2:R6:T6` is complete. Added `combat_screen.gd`'s shared `_autosave()`
  helper and called it after every meaningful state transition: class/
  subclass selection (`game_root.gd`), Tavern/contract/route choice,
  secondary tree choice, fight result, reward claim, reward-choice pick,
  shop buy/reroll, post-shop/reward advancement, and retry. See its section
  above for the full call-site list and the mid-fight exclusion reasoning.
- `P2:R6:T7` is complete. A grep sweep found no contradictory UI copy beyond
  the "Abandon Run" wording already fixed at `P2:R6:T4`; the dormant retired
  `tavern/shop.gd`/`build_planner/run_end.gd` scenes were left untouched
  since they're unreachable through the current screen graph.
- `P2:R6:T9` is complete, closing out `P2:R6 - Save/Load Persistence`. The
  next implementation milestone is `P2:R7 - Game-Like UI Pass`.

## Verification Notes

2026-07-17:

- Passing checks (log files removed after verification, no leftover
  `user://save.json`):
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_ui_r6_t6.log -s res://tests/save_load_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_r6_t6.log -s res://tests/save_load_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r6_t6.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_outcome_r6_t6.log -s res://tests/run_outcome_presentation_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_failure_r6_t6.log -s res://tests/run_failure_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/deterministic_replay_r6_t6.log -s res://tests/deterministic_replay_test.gd`
- The `save_load_test.gd` run intentionally prints a JSON parse error to
  stdout as part of its corrupt-save assertion (`load_run()` is expected to
  return `false`, not raise); this is expected test output, not a failure.
- No new global classes were added by `P2:R6:T6`/`T7` (only existing
  `combat_screen.gd`/`game_root.gd` methods were edited), so no editor
  class-cache rescan was needed before these runs.

## Verification Notes

2026-07-17:

- A sandboxed focused Godot run hit the known local headless startup/log
  issue on the first two attempts; reruns used escalated filesystem access
  and isolated two real script bugs (an untyped `:=` inference failure in
  `save_system.gd`, described under `P2:R6:T8` above) rather than an
  environment flake -- fixed before the passing run below.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_r6_t3.log -s res://tests/save_load_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r6_t3.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r6_t3.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r6_t3.log -s res://tests/gear_generator_test.gd`
- The checks still print the known ObjectDB/resource cleanup warnings after
  passing assertions.

2026-07-17:

- `P2:R6:T4` wires `SaveSystem` into scene scripts (`title.gd`, `game_root.gd`,
  `combat_screen.gd`) for the first time, so a one-time
  `Godot_v4.7-stable_win64_console.exe --headless --editor --path project --quit`
  rescan was run first to refresh the global class cache (the same
  `SaveSystem`-class-cache gotcha noted at `P2:R6:T3`'s implementation, now
  hit from the production side instead of a test script).
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_ui_r6_t4.log -s res://tests/save_load_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r6_t4.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_r6_t4.log -s res://tests/save_load_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r6_t4.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r6_t4.log -s res://tests/engine_mechanics_test.gd`
- The project-local log files and the `user://save.json` left behind by
  these runs were removed after verification. The checks still print the
  known ObjectDB/resource cleanup warnings after passing assertions.
