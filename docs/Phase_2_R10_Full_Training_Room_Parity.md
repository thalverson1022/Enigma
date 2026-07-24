# P2:R10 - Full Training Room Parity

**2026-07-23 note:** `docs/Phase_2_R11_Training_Room_UI_Polish.md` (complete)
reworked several of this milestone's original scope decisions and UI
choices described below -- the raw per-slot affix editor became a
rarity-first flow, the toggle-button tree row became Primary/Secondary
dropdowns, and the static-text-only fight recap gained a real animated
combat-playback view. This document is kept as-is for historical accuracy
(it correctly describes what `P2:R10` itself shipped); read `P2:R11`'s doc
for what the Training Room actually looks like now.

## Purpose

Track the work for **P2:R10 - Full Training Room Parity**.

Added 2026-07-21 alongside `P2:R9`, as a deliberate second Phase 2 scope
revision. The prior scope decision (`docs/Phase_2_Milestones.md`'s
2026-07-17 note, and the `P2:R1` audit's Training Room classification) had
deferred full Training Room mode to Phase 3+, allowing only an optional,
low-risk "Training Room Lite" as a `P2:R8:T9` stretch task. The user has now
deliberately expanded scope to the full Phase 1 Training Room instead of the
Lite version; `P2:R8:T9` is superseded by this milestone (see
`docs/Phase_2_R8_Playtest_Build.md`).

Depends on `P2:R9` for its Legendary-selection control -- do `P2:R9` first,
or at minimum finish `P2:R9:T4` (all 5 Legendary resources authored) before
starting `P2:R10:T3`.

## Scope Decisions (locked in 2026-07-21)

- Full Training Room, not the Lite version: separate seed, up to 2 active
  trees + passives, gear editing, all 5 Legendaries selectable, rotation,
  target, combat duration, and practice gold -- the complete Phase 1 control
  set from `Phase_1_Design_Recap.md`/the `P2:R1` audit.
- Gear editing is a **raw affix editor** (pick slot, add/remove individual
  affixes with stat/operation/value), not a reuse of the tiered
  Basic/Master/Cursed generator. This is more engineering than the
  generator-reuse option, chosen deliberately over the lower-risk option.
- Practice gold is a transient value scoped to the Training Room session,
  never written to `BuildState.gold` or the save file.
- Reuse existing panels/systems (`PassiveAllocator`, skill/rotation panel,
  `CombatResolver`, `CombatResultFormatter`) instead of duplicating logic in
  new Training-Room-only scripts wherever the existing panel can be
  reasonably adapted.

## Exit Criteria

P2:R10 is complete when:

- The title-screen Training Room button is enabled and opens a real scene.
- A player can freely pick trees/passives, build a rotation, hand-edit gear
  affixes per slot, equip any of the 5 Legendaries, pick a target, set a
  combat duration, set a separate seed, and set practice gold.
- The 3 Phase 1 practice targets (Training Dummy, Armored Guard,
  Venom-Resistant Slime) exist as real seeded Monsters.
- Fighting in Training Room never mutates real Adventure/save state.
- Results are shown clearly (damage/DPS/win-loss, consistent with Adventure's
  existing recap presentation).
- The regression suite (existing + new Training Room coverage) passes.
- Docs are updated.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R10:T1 | Seed Practice Targets | 3 real Monster resources | Complete |
| P2:R10:T2 | Enable Title Button + Scene Skeleton | Reachable Training Room scene | Complete |
| P2:R10:T3 | Wire Tree/Passive/Rotation/Legendary Controls | Freeform build controls reusing existing panels | Complete |
| P2:R10:T4 | Build Raw Affix Editor | Per-slot freeform gear editing | Complete |
| P2:R10:T5 | Wire Target/Duration/Seed/Practice-Gold Controls | Freeform fight-setup controls | Complete |
| P2:R10:T6 | Wire Result/Log Output | Reused recap presentation for Training Room fights | Complete |
| P2:R10:T7 | Add/Update Tests | Headless coverage for the full Training Room flow | Complete |
| P2:R10:T8 | Update Docs | This doc, Milestones.md, R8 note | Complete |

## P2:R10:T1 - Seed Practice Targets

Exact Phase 1 stat blocks from `Content_Library_Reference.md`:

| Target | HP | Armor | Poison Resist |
|---|---:|---:|---:|
| Training Dummy | 150 | 0 | 0% |
| Armored Guard | 155 | 160 | 10% |
| Venom-Resistant Slime | 305 | 20 | 65% |

Seed as real `Monster` resources under `data/monsters/`, distinct from the
existing test-only `placeholder_dummy.tres`. `phase3_ideas.md`'s "Training
Room Target Set" entry documented these as deferred; update it once seeded.

## P2:R10:T2 - Enable Title Button + Scene Skeleton

- `title.gd` currently sets `training_room_button.disabled = true`
  (`title.gd:76`) with tooltip "Coming soon -- practice builds against a
  target dummy." Enable it and route to a new Training Room scene.
- New scene should NOT reuse `game_root.gd`'s Adventure flow routing
  (Title -> Class Select -> Subclass Select -> Combat Dashboard) since
  Training Room's build controls are freeform, not the locked-in Adventure
  sequence. Decide during implementation whether it's a new top-level scene
  or a Training-Room mode flag on the existing dashboard; either is fine as
  long as Training Room state and Adventure/save state stay fully separate.

## P2:R10:T3 - Wire Tree/Passive/Rotation/Legendary Controls

- Reuse `PassiveAllocator` for tree/passive selection -- it already supports
  the 2-tree cap and prerequisite/lock logic from `P2:M3`.
- Reuse the existing skill/rotation panel for rotation building.
- Add a direct Legendary-equip control (dropdown/list of all 5 from
  `P2:R9:T4`) that bypasses normal reward/shop flow entirely.
- All 3 active Rogue trees (Assassin, Thief, Shadow) are already real data,
  so no new tree content is needed here, only the freeform selection UI.

## P2:R10:T4 - Build Raw Affix Editor

Per slot (weapon/trinket/charm), let the player:

- Add an affix: pick `StatModifier.StatType`, `OperationType`, and a numeric
  value.
- Remove an affix.
- See the resulting `GearItem` reflected immediately in resolved
  `PlayerStats` (reuse the existing character-stats panel's live-refresh
  pattern).

This is the largest net-new UI in `P2:R10` since it has no existing panel to
adapt from (the shop/reward panels only ever *display* generated gear, they
don't let the player construct arbitrary affix combinations). Tier can
remain a simple label field for organization/display; it does not gate
anything since generation is bypassed entirely in this editor.

## P2:R10:T5 - Wire Target/Duration/Seed/Practice-Gold Controls

- Target picker: the 3 seeded practice targets from T1 (plus, optionally,
  existing Adventure/contract monsters if useful for testing -- not
  required for parity).
- Duration: a direct combat-window input instead of a fixed
  `Encounter.duration_ms`.
- Seed: a separate field from the Adventure seed, feeding its own `RunRng`
  context so Training Room results are independently reproducible.
- Practice gold: a transient value (not `BuildState.gold`) that feeds
  `P2:R9:T2`'s `current_gold` parameter into `resolve_stats()` for this
  session only, so Bandit Blade's gold-scaling can actually be tested here.

## P2:R10:T6 - Wire Result/Log Output

Reuse `CombatResultFormatter`/the existing combat recap presentation rather
than building new result UI from scratch, consistent with
`docs/Conventions.md`'s data-driven/no-duplicated-logic principle.

## P2:R10:T7 - Add/Update Tests

Headless coverage driving the real Training Room scene: tree/passive
selection, rotation build, raw affix editor round-trip (add affix -> stat
changes -> remove affix -> stat reverts), Legendary equip, target/duration/
seed/practice-gold changes affecting the resolved fight, and confirmation
that no Training Room action mutates `BuildState`'s real Adventure/save
fields.

## P2:R10:T8 - Update Docs

- Update `docs/Phase_2_Milestones.md`'s roadmap table and immediate-next-step
  note.
- Update `docs/Phase_2_R8_Playtest_Build.md`'s Training-Room-related
  known-issue note (currently describes it as a disabled Phase-3-deferred
  button) to reflect the real feature.
- Update `phase3_ideas.md`'s "Full Training Room Mode" and "Training Room
  Target Set" entries to record that they moved into Phase 2 scope via this
  milestone.
- Close out this document's checklist and record final Implementation/
  Verification Notes.

## Implementation Notes

2026-07-21:

- `P2:R10:T1 - Seed Practice Targets` is complete. Added
  `data/monsters/training_dummy.tres` (`monster.training_dummy`, 150 HP/0
  armor/0% poison resist), `data/monsters/armored_guard.tres`
  (`monster.armored_guard`, 155/160/10%), and
  `data/monsters/venom_resistant_slime.tres`
  (`monster.venom_resistant_slime`, 305/20/65%) -- exact Phase 1 values from
  `Content_Library_Reference.md`, following the existing `Monster` `.tres`
  format (e.g. `vyra.tres`). Confirmed no production code scans
  `data/monsters/` by directory listing (unlike `data/classes/`'s
  `class_select.gd` scan), so these are inert new data until something
  loads them by path -- no side effects on the existing Adventure path.
  Updated `phase3_ideas.md`'s "Training Room Target Set" entry to record
  they're seeded.
- `P2:R10:T2 - Enable Title Button + Scene Skeleton` is complete. Enabled
  `title.gd`'s previously-disabled Training Room button, added a
  `training_room_pressed` signal (mirroring the existing
  `adventure_pressed`/`continue_pressed` pattern), and updated its tooltip/
  docstring. Added `scenes/training_room/training_room.tscn`/`.gd`, a bare
  `Control` scene built programmatically in `_ready()` (matching
  `title.tscn`'s exact pattern) with a heading, a placeholder subtitle, and
  a `BackButton` emitting `back_pressed`. `game_root.gd` gained a
  `TRAINING_ROOM_SCENE` preload and a `_show_training_room()` handler,
  wired from `_show_title()`'s `training_room_pressed` connection -- unlike
  every other `_show_*()` handler in that file, it deliberately does not
  touch `BuildState` at all, so entering/leaving Training Room can never
  affect real Adventure/save state. This is the T2 scene skeleton only;
  real build/gear/target/fight controls are `P2:R10:T3`-`T6`.
- Added `project/tests/training_room_entry_test.gd`: verifies the 3
  monsters' stat blocks, that the title-screen button is enabled and
  reachable, that entering Training Room doesn't mutate `BuildState.gold`/
  `adventure_seed`, and that Back returns to a real Title screen without
  mutating them either. First attempt found and fixed a real bug in the
  test itself (not production code): it set `BuildState.gold`/
  `adventure_seed` *before* instantiating `game_root`, but `game_root.gd`'s
  own `_ready()` calls `BuildState.reset()` on startup, silently wiping
  those values before Training Room was ever entered -- fixed by moving the
  gold/seed setup to after `game_root` was already up and showing Title.
- The full regression suite caught a real, legitimate pre-existing test
  regression from enabling the button: `save_load_ui_test.gd` (`P2:R6:T4`
  coverage, untouched by this session before now) hardcoded
  `assert(training_button.disabled)` and
  `assert(training_button.tooltip_text.contains("Coming soon"))`, both true
  before `P2:R10:T2` and both false after. Fixed both assertions (now
  `assert(not training_button.disabled)` and a generic non-empty tooltip
  check, since the exact tooltip wording isn't this test's concern) and
  updated its stale docstring/comment wording. No other test referenced the
  old disabled-Training-Room behavior (confirmed via
  `grep -rln "Training Room\|Coming soon" project/tests/*.gd`).
- An earlier full-suite run was interrupted mid-way by a session/harness
  boundary and its background-task completion notification came back
  empty. Rather than trust that, the partial log files already on disk
  (29 of 31) were checked directly, which is exactly what surfaced the
  `save_load_ui_test.gd` failure above before assuming a clean pass. The
  rerun below used an incremental plain-text progress log (one line
  appended per test as it finished) specifically so a repeat interruption
  couldn't leave the actual pass/fail state ambiguous again.

2026-07-21 (continued -- P2:R10:T3):

- Investigated before implementing: every reusable dashboard panel
  (`talent_panel.gd`, `available_skills_panel.gd`, `skill_build_panel.gd`,
  `character_stats_panel.gd`, `gear_panel.gd`) reads/writes the global
  `BuildState` autoload directly (4-22 references each, confirmed via
  `grep -oE "BuildState\.[a-zA-Z_]+"` per file) -- literal unmodified reuse
  would leak Training Room mutations into a real in-progress Adventure,
  contradicting the isolation `P2:R10:T2`'s own test already proves. "Reuse
  existing panels" therefore means parameterizing them, not instancing them
  as-is.
- Added `project/scripts/systems/training_room_state.gd`
  (`class_name TrainingRoomState`, plain `RefCounted`, never an autoload)
  mirroring the minimal `BuildState` API surface those 4 panels actually
  call (found via the same grep, gear_panel.gd's inventory/shop/sell model
  excluded -- it doesn't fit Training Room's direct-equip/raw-edit model,
  see `T4` below): `build_changed`/`lock_changed` signals,
  `selected_class`/`selected_trees`/`selected_talents`/
  `earned_talent_points`/`rotation`/`build_locked`/`gold`/
  `equipped_weapon`/`equipped_trinket`/`equipped_charm`, and
  `select_talent()`/`deselect_talent()`/`set_rotation()`/`set_locked()`/
  `unlocked_skills()`/`equipped_gear()` with the same semantics as
  `BuildState`'s (confirmed by reading each method there first). Added
  `toggle_tree()` (up to 2 of 3, freeform) instead of mirroring
  `BuildState.select_tree()`'s "pick exactly one" Adventure semantics, since
  Training Room needs different cardinality.
  `PassiveAllocator`/`BuildResolver` needed zero changes -- already
  stateless static functions operating on whatever arrays are passed in.
  `earned_talent_points` defaults to `PassiveAllocator.POINT_BUDGET` (7,
  full) rather than earned, since Training Room is for testing a
  fully-built practice character, not replaying Adventure's pacing.
- Parameterized all 4 panels identically: added an untyped
  `var state = BuildState` property (untyped deliberately -- `BuildState`
  the autoload has no `class_name`, so no static type covers both it and
  `TrainingRoomState`) and replaced every `BuildState.` reference with
  `state.` via `sed -i '/^var state = BuildState$/!s/BuildState\./state./g'`,
  confirmed zero remaining `BuildState.` references per file afterward.
  Ran the full 31-file regression suite immediately after this step (before
  building anything else on top of it) specifically because this touches
  shared, load-bearing Adventure UI code -- all 31 passed clean, proving
  the real dashboard's behavior is provably unchanged (every real call site
  still gets the default `BuildState`).
- Considered adapting `combat_screen.gd`'s existing secondary-subclass
  overlay for the tree-selection control; rejected it after reading the
  code -- it's deeply embedded in `combat_screen.gd` (not a separable
  component) and assumes "exactly one remaining tree after the first is
  already fixed," a different cardinality than Training Room's "freely
  toggle up to 2 of 3." Built a small dedicated toggle-button row instead.
- Built `scenes/training_room/training_room.gd`'s real T3 content: a
  freeform tree-toggle row, the 4 parameterized panels instantiated with
  `.state` assigned before `add_child()` (so `_ready()` sees the right
  object), and a direct Legendary-equip button row. Added
  `project/scripts/systems/legendary_catalog.gd`
  (`class_name LegendaryCatalog`, `all_paths()`/`all_items()`) as the single
  shared source for "all 5 Legendaries" -- `build_state.gd`'s
  `SHOP_LEGENDARY_PATHS` constant was converted to a `shop_legendary_paths()`
  method delegating to it, since GDScript `const` can't be initialized from
  a function call; updated its 2 internal call sites and the 2 test
  references in `run_rng_context_test.gd` accordingly (that test still
  passed after the change).
- Added `project/tests/training_room_build_test.gd`: drives the real scene
  tree (title -> Training Room), toggles 2 trees, selects a talent through
  `talent_panel._on_node_pressed()` (the same private-method-call
  convention `combat_screen_test.gd` already uses), adds a skill to
  rotation through `available_skills_panel._on_skill_pressed()`, confirms
  `skill_build_panel` (a different panel instance, same injected state)
  reflects it, equips a Legendary, and confirms the real `BuildState`
  (class/trees/talents/rotation/weapon/gold/seed) is completely untouched
  throughout, including after returning to Title. One assertion was
  deliberately written as a before/after text diff rather than an exact
  expected string (see Verification Notes) to avoid coupling it to which
  trees happened to be selected.

2026-07-21 (continued -- P2:R10:T4):

- Extended `TrainingRoomState` with `practice_weapon`/`practice_trinket`/
  `practice_charm` (freeform `GearItem`s created in `_init()`,
  `equipped_weapon`/`trinket`/`charm` start pointed at them), plus
  `equip_legendary()`'s counterpart `use_custom_weapon()`,
  `is_weapon_legendary()` (true whenever `equipped_weapon != practice_weapon`),
  `add_affix()`/`remove_affix()`, and `notify_gear_edited()` (a thin
  `build_changed.emit()` wrapper for affix-row field edits, which mutate
  `StatModifier` fields directly -- consistent with how `gear_generator.gd`
  already treats `GearItem`/`StatModifier` as plain exported-field Resources
  with no encapsulation elsewhere in this codebase). Trinket/charm have no
  Legendary items today, so only the weapon slot needed a mode toggle.
  `StatModifierFormatter.STAT_NAMES` (already existed, used elsewhere for
  tooltips) was reused directly to populate the stat-type dropdown instead
  of a new name table.
  Added a "Gear Editor" section to `training_room.gd`: 3 slot columns, each
  an `OptionButton` (stat type) + `OptionButton` (Add/Multiply) +
  `SpinBox` (value) + remove button per existing affix row, plus an Add
  Affix button. The weapon column's "Custom Weapon" toggle was folded into
  the existing T3 Legendary-equip button row rather than a separate
  control.
- Two real bugs found and fixed while writing the dedicated test:
  1. Production bug: `_refresh_affix_columns()` always displayed
     `practice_weapon`'s affixes for the weapon column regardless of mode,
     so equipping a Legendary never actually showed its real fixed affixes
     read-only as designed -- fixed to display `state.equipped_weapon`
     (which is `practice_weapon` in Custom mode, the Legendary otherwise).
     The "Add Affix" button still only ever binds to `practice_weapon`
     (via a connect-once guard keyed off the first refresh, which always
     happens in Custom mode), which is correct since it's disabled whenever
     a Legendary is shown anyway.
  2. Test-only bug: `_build_affix_column()` returns the affix-rows
     `VBoxContainer` itself, not its parent -- the test's first attempt
     called `.find_child("AffixRows", ...)` on that already-returned
     container (looking for a child that doesn't exist inside itself) and
     got a null, crashing with "Cannot call method 'get_child_count' on a
     null value." Fixed by using the stored column reference directly.
- Investigated an elevated shutdown "leaked ObjectDB instances" count
  (147, vs. every other test's stable ~8) rather than dismissing it:
  confirmed it wasn't a `queue_free()` timing race by adding
  `await process_frame` between the test's rapid successive affix edits
  and rerunning -- identical count both times, ruling out that hypothesis.
  Confirmed `save_load_ui_test.gd` (already uses a `SpinBox` via
  `title.gd`, just one instance, never rebuilt) shows the normal ~8/7
  baseline, and `combat_screen_test.gd` (the most UI-rebuild-heavy existing
  test) also shows the normal baseline -- narrowing this to something
  specific to this test's much heavier use of `OptionButton` (which carries
  an internal `PopupMenu`) across many rebuild cycles, not a pattern any
  prior test exercised. Exit code stays `0` and every assertion passes
  regardless, so this is recorded as a known, environment-specific
  characteristic of this one test, not a production defect.

2026-07-21 (continued -- P2:R10:T5):

- Added `TrainingRoomState.selected_target`/`duration_ms`/`fight_seed`
  (fight-setup only, no effect on resolved stats) plus
  `set_target()`/`set_duration_ms()`/`set_fight_seed()`, all emitting a new
  `fight_setup_changed` signal distinct from `build_changed` -- these don't
  affect `character_stats_panel`'s resolved stats, unlike everything else
  in this state object so far. `gold` already existed (used by T4's
  gold-scaling verification); added `set_practice_gold()` as its proper
  setter, deliberately emitting the existing `build_changed` instead of the
  new signal, since gold genuinely feeds `BuildResolver.resolve_stats()`'s
  `current_gold` parameter and must trigger the same live-refresh
  `character_stats_panel` already listens for.
  `fight_seed` is deliberately separate from `BuildState.adventure_seed`
  per the scope decision, defaulting to `1`; `selected_target` defaults to
  `training_dummy.tres`; `duration_ms` defaults to `20000` (matching
  `Balance_Baseline_Report.md`'s own 20s Training Dummy baseline).
- Added the "Fight Setup" row to `training_room.gd`: a target `OptionButton`
  (the 3 `P2:R10:T1` practice Monsters), a duration `SpinBox` in seconds
  (converted to `duration_ms`), a seed `SpinBox`, and a practice-gold
  `SpinBox`. Built once (unlike the build/gear sections), since nothing
  external ever changes these values except the controls themselves.
- Writing the dedicated test surfaced a real, standing gap unrelated to
  this session's own prior work: `character_stats_panel.gd`'s `_refresh()`
  was never updated when `P2:R9:T2`/`T3` added `bonus_physical_damage`/
  `min_cast_time_proc_chance` to `PlayerStats` weeks-equivalent earlier in
  this same effort -- so a player equipping Bandit Blade has never been
  able to see its gold-scaling effect anywhere, in Training Room *or* the
  real Adventure dashboard, despite the underlying mechanic working
  correctly (per `P2:R9`'s own passing tests, which check
  `BuildResolver`/`CombatResolver` output directly, never this display
  panel). Since making that effect visible was the explicit point of this
  task's practice-gold control, this was fixed here rather than deferred:
  added "Bonus Physical Damage" and "Min-Cast Proc Chance" stat lines,
  following the file's existing delta-hint/formatting conventions exactly.
  This fix benefits the real Adventure dashboard equally, not just Training
  Room, since it's the same shared panel.
- Confirmed via `grep` that no test asserts an exact position/order of
  `character_stats_panel`'s stat lines (only `.contains()` substring
  checks), so appending the two new lines was safe without touching
  existing assertions.

2026-07-21 (continued -- P2:R10:T6):

- Investigated the reuse question before writing any code: both
  `CombatResultFormatter.format()` and `CombatRecap.summarize()` are pure,
  static, `RefCounted` classes with no scene-tree coupling -- exactly the
  "reused ... presentation" the scope decision names. `CombatPlayback` (the
  `P2:R7` real-time animated playback controller) is *also* a clean,
  reusable `RefCounted` class, but the actual popup/HUD rendering that
  consumes it lives directly in `combat_screen.gd`, not as a separable
  component -- pulling that in would mean rebuilding a chunk of that
  rendering, not reusing it. Scoped `T6` to the static text recap only,
  matching the doc's own wording; recorded the animated playback as a
  possible future enhancement, not part of finishing this task.
- Added `TrainingRoomState.last_result`/`fight_finished` and `run_fight()`:
  resolves stats via `BuildResolver.resolve_stats()` (same call every other
  T3-T5 feature already uses) and calls
  `CombatResolver.resolve(rotation, stats, selected_target, duration_ms,
  fight_seed)` -- `rotation` is already filtered to unlocked skills by
  `set_rotation()`/`_prune_rotation_to_unlocked()`, so no extra resolution
  step was needed before feeding it in.
  Added a "Fight" button to `training_room.gd` (disabled whenever
  `rotation` is empty, mirroring `skill_build_panel.gd`'s existing Lock-
  button guard for the identical reason -- an empty macro is a guaranteed
  zero-damage loss) and a `RichTextLabel` populated via
  `CombatResultFormatter.format(_state.last_result, _state.selected_target)`
  on `fight_finished`.
- Added `project/tests/training_room_fight_test.gd`: confirms the Fight
  button is disabled with an empty rotation and enabled once one exists;
  builds a real Thief/Piercing Blades/Stab practice build; confirms a run
  fight's `total_damage` exactly matches a direct
  `BuildResolver.resolve_stats()` + `CombatResolver.resolve()` call with
  the same inputs (not just "a result exists"); confirms the same seed
  reruns identically; confirms changing the seed changes the result log
  text; confirms switching the target from Training Dummy (0 armor) to
  Armored Guard (160 armor) measurably reduces damage at the same seed/
  build/duration; and confirms the real `BuildState`'s
  `current_encounter_index`/`run_phase`/`gold` are completely untouched
  throughout -- Training Room fights never call `finish_fight()` or
  advance any real encounter/route state.
- All of `P2:R10:T1`-`T8` are now complete. Every exit criterion in this
  doc's "Exit Criteria" section is met: the title button opens a real
  scene; a player can freely pick trees/passives, build a rotation,
  hand-edit gear per slot, equip any of the 5 Legendaries, pick a target,
  set duration/seed/practice gold, and run a real fight with a result
  shown via the same presentation logic the real Adventure dashboard uses;
  the 3 practice targets exist; nothing here ever mutates real Adventure/
  save state (verified by a dedicated isolation assertion in every one of
  the 5 Training Room test files); and the full regression suite passes
  clean throughout.

## Verification Notes

2026-07-21:

- Ran `training_room_entry_test.gd` in isolation first (headless, escalated
  filesystem access). First attempt hung (the known bare-`assert()`-never-
  reaches-`quit()` trap); the `--log-file` output showed
  `gold after entering Training Room=0 (expect 777)`, diagnosing the
  test-ordering bug described above before it ever reached an assert on a
  wrong value. Force-killed the stuck `Godot_v4.7-stable_win64`/
  `..._console` processes (confirmed via `Get-Process`), fixed the test,
  reran clean: `Training Room targets check: OK`,
  `Training Room button disabled=false (expect false)`,
  `gold after entering Training Room=777 (expect 777), seed=999 (expect 999)`,
  `Training Room entry/exit check: OK`. Only the known benign shutdown
  warnings printed.
- First full-suite attempt (`user://logs/r10_t12_full_<test>.log`) was
  interrupted mid-run by a session/harness boundary; its background-task
  completion notification came back empty rather than a real result.
  Checked the 29 log files that had actually been written directly instead
  of trusting that: 28 clean, one real failure --
  `r10_t12_full_save_load_ui_test.log` showed
  `SCRIPT ERROR: Assertion failed. at: _initialize
  (res://tests/save_load_ui_test.gd:53)`, a genuine pre-existing test
  regression from `P2:R10:T2` (see Implementation Notes). Fixed the test,
  reran it alone clean (`P2:R6:T4 save/load UI hooks check: OK`, all
  expected values, including the restored gold/seed after Continue).
- Reran the complete suite (31 files, `user://logs/r10_t12_full2_<test>.log`),
  serially, escalated filesystem access, this time also appending each
  test's name/exit code to a plain-text progress file as it finished so an
  interruption couldn't leave results ambiguous again. All 31 exited `0`,
  confirmed two ways (the results table and the progress file matched).
  Grepped every one of the 31 fresh logs for
  `SCRIPT ERROR`/`Assertion failed`/`ERROR: Expected` -- none found.
- No stale Godot processes remained after any of the runs above (checked
  via `Get-Process`, including a force-kill of two processes left running
  by the interrupted first attempt). Deleted the temporary progress file
  (not part of the repo) after confirming the results.

2026-07-21 (continued -- P2:R10:T3):

- After parameterizing all 4 panels, forced a Godot editor class-cache
  rescan (`--headless --editor --quit`) to register the new
  `TrainingRoomState` global class before running any test that references
  it by type -- the documented `P2:M2` gotcha (headless `-s` runs don't
  trigger `class_name` registration on their own).
- Ran the full 31-file suite immediately after the panel parameterization,
  before adding any new Training Room content on top of it: all 31 exited
  `0`. Grepped every log for `SCRIPT ERROR`/`Assertion failed`/
  `ERROR: Expected` -- none found. This specifically confirms the real
  Adventure dashboard is unaffected by giving 4 shared panels a
  `state` property that defaults to `BuildState`.
- Ran `training_room_build_test.gd` in isolation: first attempt hit a
  `SCRIPT ERROR: Parse Error: Cannot infer the type of "unlocked" variable`
  (the same `:=`-on-a-dynamically-typed-source gotcha seen earlier this
  session) -- fixed with an explicit `Array[Skill]` annotation. Second
  attempt passed clean: 2 trees selected, Piercing Blades selected, 1
  skill in rotation (confirmed via a *different* panel instance reading
  the same injected state), Wyvern Kriss equipped, and the real
  `BuildState`'s gold/seed/trees/talents/rotation/weapon all unchanged
  before and after, including after returning to Title.
- Reran the full 33-file suite (4 panels touched + `LegendaryCatalog` +
  2 new Training Room tests): all 33 exited `0`, confirmed via both the
  results table and an incremental progress file; grepped every log for
  the same error patterns -- none found. No stale processes remained.

2026-07-21 (continued -- P2:R10:T4):

- Reran `training_room_build_test.gd` first (unchanged file, new scene
  content) to confirm the gear editor's addition didn't disturb T3's
  existing behavior -- passed clean before writing any T4-specific test.
- Ran `training_room_gear_editor_test.gd`: first attempt crashed with
  `Cannot call method 'get_child_count' on a null value` at the
  `find_child("AffixRows", ...)` call (the test bug described above);
  second attempt (after fixing that) hung -- the known bare-`assert()`-
  never-reaches-`quit()` trap -- with the log showing
  `weapon affix rows while Legendary equipped=0 (expect 3...)`, which
  diagnosed the real production bug (weapon column always showing
  `practice_weapon`) before the process was force-killed
  (`Get-Process`/`Stop-Process`, confirmed via a second `Get-Process`
  afterward). Third attempt, after fixing the production code, passed
  clean: affix added (1), edited to `PHYSICAL_DAMAGE` x1.5 exactly,
  resolved `physical_damage_multiplier` confirmed at 1.50 via a direct
  `BuildResolver.resolve_stats()` call (not just reading the label text),
  the panel's displayed text changed, affix removed (back to 0), equipping
  Wyvern Kriss showed exactly 3 read-only rows matching its real affix
  count, switching back to Custom left the practice item still empty
  (proving equipping a Legendary never mutated it), the trinket slot
  stayed independently editable, and the real `BuildState`'s equipped
  weapon/inventory were untouched throughout.
- Investigated the elevated leak-count question with a real experiment
  (added `await process_frame` between each rapid mutation, reran): the
  count (147 ObjectDB instances, plus `RendererViewport`/`TextServerAdvanced`/
  `Canvas` RID leaks) was identical both with and without the extra frame
  yields, ruling out a deferred-`queue_free()` race as the cause. Confirmed
  via two comparison runs that no existing test shows this magnitude:
  `save_load_ui_test.gd` (uses one `SpinBox`) and `combat_screen_test.gd`
  (the heaviest existing UI-rebuild test) both showed the normal ~8/7
  baseline. Recorded as a known characteristic of this test's much heavier
  `OptionButton` usage, not a regression -- exit code `0` and every
  assertion passed in all attempts after the two real bugs were fixed.
- Ran the full 34-file suite (adding the new gear-editor test): all 34
  exited `0`, confirmed via the results table and an incremental progress
  file; grepped every log for `SCRIPT ERROR`/`Assertion failed`/
  `ERROR: Expected` -- none found. No stale Godot processes remained
  before or after.

2026-07-21 (continued -- P2:R10:T5):

- Reran `training_room_build_test.gd` first (T3's test, unchanged) to
  confirm the new Fight Setup row didn't disturb existing behavior --
  passed clean before writing any T5-specific test.
- Ran `training_room_fight_setup_test.gd`: first attempt hit
  `SCRIPT ERROR: Assertion failed` at the line checking that
  `character_stats_panel`'s text changed after setting practice gold to
  200 with Bandit Blade equipped -- the log showed every earlier assertion
  (default target/duration/seed/gold, target picker, duration, seed
  independence from the real Adventure seed, gold independence from real
  `BuildState.gold`) passing first, isolating the failure to display logic
  specifically, not the underlying gold-scaling mechanic. Read
  `character_stats_panel.gd`'s `_refresh()` and confirmed by direct
  inspection that it only ever rendered 7 stat lines, none of them
  `bonus_physical_damage` or `min_cast_time_proc_chance` -- the real gap
  described above. Fixed the panel, reran: all assertions passed, including
  a direct `BuildResolver.resolve_stats()` check confirming
  `bonus_physical_damage == 20.0` at 200 practice gold (Bandit Blade's
  `physical_damage_per_gold = 0.1`), not just that the label text changed.
- Ran the full 35-file suite (adding the new fight-setup test): all 35
  exited `0`, confirmed via the results table and an incremental progress
  file; grepped every log for `SCRIPT ERROR`/`Assertion failed`/
  `ERROR: Expected` -- none found. No stale Godot processes remained
  before or after.

2026-07-21 (continued -- P2:R10:T6):

- Reran `training_room_fight_setup_test.gd` first (T5's test, unchanged
  logic, new Fight button/result log added to the same scene) to confirm
  no disturbance -- passed clean before writing any T6-specific test.
- Ran `training_room_fight_test.gd`: passed on the first attempt --
  Fight button correctly disabled/enabled with empty/non-empty rotation,
  a real fight's `total_damage` matched a direct `CombatResolver.resolve()`
  call exactly (136.08 both ways), the same seed reproduced the same
  136.08 on a rerun, changing the seed changed the result log text,
  switching to Armored Guard reduced damage to 73.27 (vs. 136.08 against
  Training Dummy, same seed/build/duration -- consistent with its 160
  armor's mitigation), and the real `BuildState`'s encounter index/run
  phase/gold were unchanged throughout. Only the known benign shutdown
  warnings printed.
- Ran the full 36-file suite (adding the new fight test): all 36 exited
  `0`, confirmed via the results table and an incremental progress file;
  grepped every log for `SCRIPT ERROR`/`Assertion failed`/
  `ERROR: Expected` -- none found. No stale Godot processes remained
  before or after.
- `P2:R10` is complete: all 8 tasks done, every exit criterion met, full
  regression suite green (36 files, including 5 dedicated Training Room
  tests added across `T2`-`T6`).
