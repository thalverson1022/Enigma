# P2:R7 - Game-Like UI Pass

## Purpose

Track the work for **P2:R7 - Game-Like UI Pass**.

The goal is to make the revised Phase 2 Rogue Adventure understandable and
pleasant enough for a new player to play unassisted. This is a clarity,
layout, and interaction pass, not a full art/animation production pass.

Scope addition (2026-07-17): R7 also includes applying the game's visual
style foundations - the "Road to Peak Deeps" UI palette, the four-role font
system, and a project-wide Godot Theme resource. The palette/font decisions,
code audit, and phased implementation plan are recorded in
`docs/Phase_2_R7_Style_Implementation_Notes.md`. Icon-pack integration and
full art production remain out of scope unless separately added.

**2026-07-24 update:** icon integration was separately added once real gear
art existed, tracked as `docs/Phase_2_R12_Gear_Icon_Art_Integration.md`
(complete) -- gear boxes across the shop, reward-choice, inventory, and
equipped Equipment-doll slots now show real icon art over their existing
tier-colored backgrounds. Full production art/animation beyond gear icons
remains out of scope. Separately, `docs/
Phase_2_R11_Training_Room_UI_Polish.md` (complete 2026-07-23) fixed a bug in
this pass's shop/reward-choice overlays: they grew their parent container
instead of rendering as true full-rect overlays, pushing sibling panels
off-screen -- found while comparing Training Room's new overlay patterns
against these existing ones, not by a dedicated R7 pass.

## Exit Criteria

P2:R7 is complete when:

- A new player can identify their class, subclass, talents, rotation, gear,
  enemy, rewards, and next action without outside explanation.
- The UI palette and font system from
  `docs/Phase_2_R7_Style_Implementation_Notes.md` are applied through a
  project-wide Theme resource, with no hardcoded ad hoc colors left in
  screen scripts.
- The dashboard supports Tavern, shop, route, combat, reward, failure, and
  victory states coherently.
- Important disabled/locked states explain themselves.
- Combat results help the player understand why a build worked or failed.
- UI text fits across target desktop view sizes.
- Manual click-through is completed in addition to headless tests.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R7:T1 | Define UI Evaluation Pass | Screens/states to review listed | Complete |
| P2:R7:T2 | Apply Visual Style Foundations | Palette, fonts, and project-wide Theme per the style notes doc | Complete |
| P2:R7:T3 | Improve Run Header/Status | Seed, phase, gold, current node, and next action visible | Complete |
| P2:R7:T4 | Improve Build Panels | Talents, skills, stats, and gear clearer and more ergonomic | Complete |
| P2:R7:T5 | Improve Enemy/Encounter Presentation | Target pressure and DPS window readable before fight | Complete |
| P2:R7:T6 | Improve Reward/Shop/Route UI | Choices communicate cost, value, and consequences | Complete |
| P2:R7:T7 | Improve Combat Recap | Win/loss recap explains damage, DPS, and key interactions | Complete |
| P2:R7:T8 | Polish Navigation/Confirmations | Main menu, abandon, resume, continue, retry, restart are coherent | Complete |
| P2:R7:T9 | Verify Layout And Tests | Headless tests plus manual click-through notes | Complete |
| P2:R7:T10 | Update Docs | Remaining UI polish deferred or documented | Complete |

## P2:R7:T1 - Define UI Evaluation Pass

List every reachable state after P2:R6:

- Title / resume / new run / save & quit / abandon run confirmation.
- Class select (Rogue active, Mage/Crusader disabled).
- Primary subclass select (Assassin/Thief/Shadow, all active as of R5).
- Tavern planning (dashboard: talents, skills/rotation, stats, enemy, gear).
- Fight result (win).
- Fight loss with do-over (Tavern, first failure).
- Adventure restart required (Tavern, second failure on same encounter).
- Reward claim.
- Shop (buy/reroll, gold-gated afford state).
- Contract offer (post-Tavern).
- Secondary subclass select.
- Route choice (easy/harder branch).
- Elite/Legendary reward choice.
- Boss (Vyra).
- Contract failed (route loss).
- Contract victory (Vyra defeated).

Implementation note (2026-07-17): this list was cross-checked against the
current active flow in `game_root.gd`/`combat_screen.gd` after R5/R6 and
found already complete/accurate as drafted; no undocumented reachable state
was found. It is the reference list for `P2:R7:T3` through `P2:R7:T8`.

## P2:R7:T2 - Apply Visual Style Foundations

Apply the palette/font/theme plan from
`docs/Phase_2_R7_Style_Implementation_Notes.md`:

- Resolve the palette fork (master palette doc vs. style guide mockup)
  before any hex value goes into code.
- Download and commit the four OFL fonts (Pirata One, MedievalSharp,
  Press Start 2P, VT323) with their license files.
- Add a `UIColors` constants script and a project-wide Theme resource
  registered via `gui/theme/custom`.
- Rewrite `CardStyle` to read from `UIColors`, then replace the bypass
  colors in screen scripts (audited list in the style notes doc).
- Apply semantic text colors (gold, poison, warning, magic, disabled)
  where mechanics show through; align with whatever `P2:R5:T8` already
  shipped rather than duplicating it.

Doing this before T3-T8 means those tasks iterate on styled screens
instead of restyling their own work afterward.

## P2:R7:T3 - Improve Run Header/Status

Add or refine always-visible context:

- Current run phase.
- Current seed.
- Gold.
- Current encounter/route node.
- Next expected action.
- Build locked/unlocked state.

## P2:R7:T4 - Improve Build Panels

Make build controls easier to scan:

- Talent availability and prerequisites.
- Remaining/spent talent points.
- Skill tooltips and effects.
- Rotation order and removal.
- Stat changes from gear/talents.
- Equipped vs inventory items.

## P2:R7:T5 - Improve Enemy/Encounter Presentation

Enemy panel should help players reason:

- HP and required DPS.
- Armor and poison resistance.
- Combat window.
- Known reward.
- Why this target pressures certain builds, if concise.

Avoid overexplaining with walls of text.

## P2:R7:T6 - Improve Reward/Shop/Route UI

Choices should show:

- Price or reward tier.
- Slot.
- Affixes.
- Whether the item can be equipped.
- Current gold.
- Route difficulty/reward tradeoff.
- Clear continue/back/confirm behavior.

## P2:R7:T7 - Improve Combat Recap

Recap should support buildcraft learning:

- Total damage.
- DPS.
- Required damage/DPS.
- Biggest hit.
- Physical/poison split.
- Crit count if available.
- Armor reduction contribution if useful.
- Poison stack/tick summary if useful.

## P2:R7:T8 - Polish Navigation/Confirmations

Review confusing or destructive actions:

- Return to main menu.
- Save and quit.
- Abandon run.
- Retry fight.
- Continue after win.
- Restart after failure/victory.

Confirmations should be used where state loss is real.

## P2:R7:T9 - Verify Layout And Tests

Verification should include:

- Existing headless tests.
- New tests for important state transitions if needed.
- Manual Godot editor/player click-through.
- Desktop viewport sanity.
- Text fitting and no obvious overlap.

## P2:R7:T10 - Update Docs

When complete:

- Update this checklist.
- Record manual click-through caveats.
- Move full art/animation ideas to `phase3_ideas.md`.
- Update `docs/Phase_2_Milestones.md`.

## Implementation Notes

2026-07-19 (P2:R7:T9 - Verify Layout And Tests, P2:R7:T10 - Update Docs --
milestone closeout, after nine-plus prior passes above):

Closeout pass covering T9's four parts (full regression suite, systematic
16-state walkthrough, resolving/consolidating outstanding flagged items, and
a structural read-through of `combat_screen.gd`) and T10's doc updates. Full
command-level detail is in the Verification Notes entry immediately below;
this entry records findings and decisions.

**Part A -- full regression suite, every file in `project/tests/`, not just
a prior pass's subset.** Listed all 27 `.gd` files in `project/tests/` (`ls
project/tests/*.gd`) -- 12 of them (`encounter_reward_test`,
`inventory_model_test`, `contract_route_data_test`, `legendary_reward_test`,
`route_reward_choice_ui_test`, `shadow_parity_test`, `opportunity_strikes_test`,
`run_rng_context_test`, `run_seed_state_test`, `passive_allocator_test`,
`gear_generator_test`, `deterministic_replay_test`) had never been run as
part of an `R7` task's own required list, only carried forward from older
R1-R6 sanity sweeps or not run in this milestone at all. Ran all 27 serially,
each with its own `--log-file`, then re-verified every log's actual printed
content (not exit code alone, per the project's documented `_require()`/bare-
`assert()` exit-code-masking caveat). **Found and fixed two real, genuine
regressions this pass -- both a gap in the 2026-07-19 "retry-exception
correction" entry's own test updates, not new bugs introduced by this
closeout pass itself:**

1. `project/tests/dashboard_header_test.gd`'s "second Tavern loss requires an
   Adventure restart" section drove two straight `finish_fight(false)` calls
   at `current_encounter_index == 0` (the fresh-reset default) expecting
   `RunOutcome.ADVENTURE_RESTART_REQUIRED` -- but the retry-exception
   correction pass (see the dated entry below in this same doc) retargeted
   the unlimited-retry exemption from Vyra to exactly this index (the first
   Tavern encounter), so a second loss there now correctly stays
   `FIGHT_LOSS_RETRY` forever. This test was never updated for that change
   (only `run_failure_state_test.gd` was, per that entry's own file list).
   Fixed by winning the first encounter first (`finish_fight(true)` +
   `continue_after_win()` + re-choosing/re-locking the now-current second
   encounter) so the "second loss -> Run Failed" header state is exercised
   against `current_encounter_index == 1`, where the standard one-do-over
   rule actually applies -- mirroring the same fix pattern
   `run_failure_state_test.gd` already used for its own equivalent block.
2. `project/tests/inventory_model_test.gd` had the identical gap: a bare
   `assert(not build_state.can_retry_current_encounter())` after two losses
   at encounter index 0, which is a hard `assert()` (not this project's
   deferred-`_failed` idiom), so it doesn't print a diagnosable error -- it
   hangs the headless `SceneTree` indefinitely instead of exiting (the same
   known trap documented at `P2:M5` and re-encountered several times across
   R5-R7; two stale `Godot_v4.7-stable_win64*.exe` processes had to be killed
   before rerunning). Fixed the assertion to match the intended unlimited-
   retry-on-first-encounter behavior (asserts a retry *is* still available
   and exercises it) with an explanatory comment pointing at
   `BuildState.is_unlimited_retry_encounter()` and the correction entry, so a
   future reader isn't left to rediscover the same gap a third time.

Both fixes are test-only; `git diff --stat -- project/scripts/systems
project/scripts/resources` stayed empty throughout (confirmed both before and
after). No other test file assumes two-losses-on-encounter-0 behavior --
grepped every test file for `ADVENTURE_RESTART_REQUIRED`/"Run Failed"/
"Restart your Adventure" and found only these two plus
`run_failure_state_test.gd` (already correct) and
`run_outcome_presentation_test.gd` (drives `_apply_outcome_presentation()`
directly with a hardcoded enum value, never through real `finish_fight()`
calls, so it was never exposed to this gap). After both fixes, **all 27 test
files pass, verified via their actual printed pass line/summary content, not
exit code alone.**

**Part B -- systematic 16-state walkthrough.** Reasoned through every state
from `P2:R7:T1`'s reference list against everything layered on top of it
since (header, build panels, enemy panel/HUD, reward/shop/route UI, combat
recap, navigation/confirmations, and the combat-playback system). Every
state's existing headless coverage (`dashboard_header_test.gd`,
`build_panels_test.gd`, `enemy_panel_test.gd`, `combat_hud_test.gd`,
`reward_shop_route_ui_test.gd`, `combat_recap_test.gd`,
`combat_playback_test.gd`, `run_failure_state_test.gd`,
`run_outcome_presentation_test.gd`, `contract_offer_flow_test.gd`,
`save_load_ui_test.gd`) was re-read to confirm it actually drives the real
scene tree for that state rather than only calling `BuildState` directly, and
all of it does. Points specifically re-confirmed per the task's own examples:
- **Tavern loss-with-do-over correctly plays back before the Retry button
  appears**, and the do-over status text is correct -- `combat_playback_test.gd`'s
  live loss-playback check (outcome/retry hidden mid-playback, revealed only
  after skip/finish) plus `run_failure_state_test.gd`'s retry-bug regression
  block both exercise this against the real scene.
- **A second contract-route loss goes to `CONTRACT_FAILED` with the playback
  speed control left in a clean state.** R8 smoke testing revised the rule so
  every contract-route fight now gets one retry; contract failure is the
  second-loss outcome. Traced
  `_on_playback_finished()` in `combat_screen.gd`: `_playback_active` is
  unconditionally set `false` there (before `_reveal_fight_outcome()` runs),
  and the speed-strip buttons are only visible while `_playback_active` is
  true (`_update_playback_controls_visibility()`'s existing gating), so a
  contract-route `CONTRACT_FAILED` reveal happens with the speed strip already
  hidden -- confirmed by code read, consistent with `combat_playback_test.gd`'s
  live win/loss playback checks which never leave the controls visible after a
  reveal.
- **Vyra's post-R8 one-retry contract rule presents correctly after
  playback.** The 2026-07-19 R8 smoke pass revised Vyra to the standard
  contract-route rule: first loss returns `FIGHT_LOSS_RETRY`, second loss
  resolves to `CONTRACT_FAILED`. `run_failure_state_test.gd` now pins that
  behavior; playback itself does not branch on which monster it is, so the
  same loss-playback path already verified above applies unchanged.
- Every other state (title/resume/new-run/save-and-quit/abandon-confirmation,
  class select, primary/secondary subclass select, Tavern planning, fight
  win, Adventure restart required, reward claim, shop, contract offer, route
  choice, elite/Legendary reward choice, contract victory) has direct live
  scene-tree coverage in the files listed above and all of it passed in Part
  A's rerun; no further code-level issue was found by this reasoning pass
  beyond the two Part A test bugs (which were state-transition test gaps, not
  presentation bugs -- the actual `BuildState`/`combat_screen.gd` behavior
  they exercise was already correct).
- **Nothing in this walkthrough could confirm actual pixel layout/spacing**
  for any state -- that remains the sandbox's standing limitation, carried
  into the consolidated visual-judgment-call list below rather than
  guessed at.

**Part C -- consolidating outstanding flagged items.** Every prior R7
entry's Implementation/Verification Notes was reread specifically for
"should be spot-checked," "deferred," "visual judgment call," or "awaiting
the user's next editor session" language (matching the grep for
`2026-07-1[89]` section headers earlier in this doc). None of the flagged
items were resolvable via a headless test or code inspection -- they are all
genuinely pixel/feel questions that need a real rendered Godot window, which
this sandbox has never had access to across any R7 task. None were found to
be superseded/already-fixed by a later pass beyond what each pass's own notes
already said (e.g. the button-fill contrast question was reasoned via WCAG
math, not resolved by rendering). **The full consolidated list is in the
final report; it is not duplicated here to avoid a second copy drifting out
of sync -- see this doc's closing summary in the same dated block as this
entry, immediately before "## Verification Notes."**

**Part D -- structural read-through of `combat_screen.gd` (2615 lines).**
Checked for three things:
- **Dead code from an earlier pass's revert/rework.** Grepped for every
  helper name the second playtest-feedback pass's notes said it deleted
  (`_gear_upgrade_comparison_text`, `_format_stat_delta_vs_equipped`,
  `_gear_compare_column`, the old `_build_gear_compare_tooltip` two-column
  Control) and for T3's pre-consolidation status-bar names (`status_bar`,
  `status_row`, `_current_node_text`, `_node_label`, `_header_gold_label`) --
  none appear anywhere in the file; the only `_hud_status_row` match is the
  unrelated, current enemy-HUD status-chip row from the combat-HUD addition,
  not leftover scaffolding. Cross-checked every top-level `func` name in the
  file against its own call sites (a name appearing exactly once means only
  its own definition exists) -- the only single-occurrence name is `_ready`,
  which is a Godot lifecycle callback invoked by the engine itself, not dead
  code. **No dead code was found; nothing needed removal.**
- **TODO/FIXME/XXX comments.** Grepped the file for all three markers --
  zero matches. No stale markers to clean up.
- **General internal consistency / duplicate logic.** The tuning-constant
  block at the top of the file (playback speed/tween/popup constants) is
  well-organized and matches what every prior playback-tuning entry claims;
  no duplicate stat-formatting or tooltip-building logic was found beyond
  what's already intentionally shared (`_gear_tooltip_lines()`,
  `_build_recap_lines()`, `CardStyle` statics). **No cleanup changes were made
  to `combat_screen.gd` itself this pass** -- the file already matches its own
  accumulated documentation with no orphaned remnants, so there was nothing
  small/safe to fix without doing exactly the "big refactor at milestone-close
  time" the task explicitly says to avoid.

**Confirmed-dead code outside `combat_screen.gd`, flagged but not touched
(systems-folder boundary, and not part of this file's own scope):**
`GearGenerator.generate_offers()` and `project/scenes/tavern/shop.gd` (the
dormant P2:M5-era shop scene) were already identified as unreachable dead
code by the 2026-07-19 item-4 gear-rarity investigation above; this pass
re-confirms that finding still holds (no later pass reconnected either) and
leaves them as a follow-up cleanup candidate rather than deleting them here,
consistent with the item-4 entry's own framing and this task's "flag larger
items rather than fixing them at milestone-close" instruction.

**Two smaller non-visual follow-ups already on record, restated once here
for completeness (not new findings):** a `Skill.speed_label` schema field
was tried and deliberately reverted in the "combat playback adjustment round
3" entry above (kept as an in-code lookup table instead to respect this
task's systems/resources boundary) -- a real follow-up if the user wants the
data-driven version later; and `CastEvent.triggered_skill_damages` (a
per-trigger damage figure for proc popups, currently folded into the source
cast's own damage total) was flagged in "combat playback adjustment round 1"
as a clean way to unlock per-proc damage numbers, requiring a
`combat_resolver.gd` event-schema change outside this pass's boundary.
Neither is a visual judgment call; both are optional systems-layer follow-ups
for a future session, not blocking this milestone's closeout.

**Exit Criteria, confirmed bullet by bullet against final state (see the
"## Exit Criteria" section near the top of this doc):**
- *"A new player can identify their class, subclass, talents, rotation,
  gear, enemy, rewards, and next action without outside explanation."* Met
  by construction across T3-T8 (header next-action text, build-panel
  captions/tooltips, enemy panel's pressure/reward/required-DPS lines, combat
  recap) and confirmed reachable/correct for every one of the 16 reference
  states in Part B above. The remaining risk is purely legibility/spacing at
  real pixel size, captured in the consolidated visual-judgment-call list,
  not missing information.
- *"The UI palette and font system... are applied through a project-wide
  Theme resource, with no hardcoded ad hoc colors left in screen scripts."*
  Met -- `P2:R7:T2`'s cleanup pass plus every subsequent task's discipline of
  adding new colors to `UIColors` rather than inlining `Color()` literals
  (confirmed again in Part D's read-through: no bypass colors found).
- *"The dashboard supports Tavern, shop, route, combat, reward, failure, and
  victory states coherently."* Met -- confirmed via Part B's walkthrough and
  the passing state-transition test suite.
- *"Important disabled/locked states explain themselves."* Met -- talent
  lock reasons, skill effect summaries, shop afford-state text, and Training
  Room/Resume tooltips all carry explanatory text per T4/T6/T8's entries.
- *"Combat results help the player understand why a build worked or
  failed."* Met -- `P2:R7:T7`'s recap (required DPS/damage, biggest hit,
  physical/poison split, crit count, armor/poison summaries) plus the
  combat-playback system's live event replay, both confirmed still passing.
- *"UI text fits across target desktop view sizes."* **Not independently
  verifiable in this sandbox** -- every task from `P2:R7:T2` onward has
  reasoned about height/width budgets (byte-accounted in the first
  playtest-feedback pass) but none could render a real `1600x900` window.
  This is the single largest item in the consolidated visual-judgment-call
  list below and should be the first thing checked in the next editor
  session.
- *"Manual click-through is completed in addition to headless tests."* **Not
  met by this pass, and not met by any prior `P2:R7` pass** -- this sandboxed
  environment has never had GUI automation for native Godot windows, a
  limitation documented consistently in every single R7 dated entry's
  Verification Notes since `P2:R7:T2`. Headless scene-tree tests driving the
  real `.tscn` files through real signal paths are this project's
  established, but incomplete, substitute. **This is the one Exit Criterion
  this pass cannot mark satisfied** -- it requires the user's own editor
  session, which is exactly what the consolidated visual-judgment-call list
  below is for.

Given the above, R7's Exit Criteria are satisfied except for the
click-through bullet, which structurally cannot be satisfied by an agent
running in a headless sandbox -- it is deliberately left open, not silently
waived, pending the user's next real editor/player session against the
consolidated list.

2026-07-19 (combat playback adjustment round 3 -- 3 small UI fixes plus a
rarity/tier investigation, after playing the round-2 build above; not a
numbered T-task):

The user gave three concrete presentation-layer fixes and asked for an
investigation into whether shop/reward gear rarity scales correctly with run
progression, to be fixed only if a real bug turned up. `CombatResolver` and
`project/scripts/systems/`/`project/scripts/resources/` remain untouched --
confirmed empty `git diff --stat -- project/scripts/systems
project/scripts/resources`, see Verification Notes.

**1. Poison tick popups now carry a "Poison" text label.** Adjustment round 1
added a damage number to cast popups ("SkillName -N"); poison ticks still
showed only a bare "-N". Fix: `combat_screen.gd`'s `_on_playback_event()`
tick branch now spawns `"Poison -%.0f" % event.tick.damage` instead of
`"-%.0f" % event.tick.damage` -- font size (`POPUP_TICK_FONT_SIZE`, 16) and
color (`POPUP_TICK_COLOR`/`UIColors.TEXT_POISON`) are untouched, per the
user's explicit note that those were already correct; only the label text
changed, matching the "name -N" pattern the physical popups already use.

**2. Physical Damage's "+" removed -- it's a multiplicative stat, not an
additive one.** `character_stats_panel.gd` displayed
`physical_damage_multiplier` (base `1.0`, e.g. `x1.08`) as `"+8%"` both in
the main value (`"%+d%%"` of `(multiplier - 1.0) * 100`) and in the
from-gear/talents hover delta (`_stat_delta_text()`'s `sign := "+" if delta >
0`), which reads as an additive bonus when the underlying stat is actually
multiplicative. Fix: `_stat_delta_text()` gained a `show_plus_sign: bool =
true` parameter (default preserves the old behavior for every other stat);
`_stat_line()` threads it through from a new same-named parameter; the
Physical Damage line's format string dropped its `+` (`"%d%%"` instead of
`"%+d%%"`) and passes `show_plus_sign = false`. Negative deltas/values are
unaffected either way -- `%d` of a negative int already renders its own
`-`, the sign variable only ever adds a `+` for positives. **Checked every
other displayed stat against player_stats.gd/build_resolver.gd/
stat_modifier.gd for the same bug and found none:** Attack Speed (base
`0.0`, additive -- `BuildResolver._apply_op()` typically `ADD`s to it, and
`CombatTiming.execution_time_ms()` divides by `1.0 + attack_speed`, i.e. the
stat itself is a genuine additive offset) correctly keeps its `+`. Crit
Chance is likewise additive off a `0.0` base. Crit Multiplier is shown as an
absolute percentage (`"200%"`, not `"+N%"`) with no `+` on the main value at
all -- only its hover delta carries `+`, which is a correct "percentage
points changed" framing regardless of the underlying stat's own mechanics
(the field itself isn't displayed as a bonus-above-baseline the way Physical
Damage was). There is no displayed "poison damage multiplier" -- Poison
Damage is a flat per-tick amount (additive, `POISON_DAMAGE` modifiers use
`ADD` in `gear_generator.gd`'s `OPERATION` table) and Bonus Poison Stacks is
an additive count; `poison_tick_interval_multiplier` is a genuine
multiplicative stat but isn't shown in this panel at all, so nothing to fix
there. `StatModifierFormatter.format()` (the separate per-affix formatter
used in gear/talent tooltips) was also checked: it already special-cases
`OperationType.MULTIPLY` as `"x%.2f Stat"` with no `+`, and every seeded
`PHYSICAL_DAMAGE` modifier in `data/talents/` uses `MULTIPLY` (confirmed by
grep), so that formatter had no equivalent bug.

**3. Skill tooltips show a flavor speed label instead of the exact cast-time
number.** `available_skills_panel.gd`'s `_tooltip_for()` showed `"Cast: %dms
(min %dms)"` (`skill.base_execution_ms`/`min_execution_ms`) -- the user wants
exact timing to stay a combat-log discovery, not a tooltip spoiler. Fix: a
new `SPEED_LABEL_BY_SKILL_ID` constant dictionary (keyed by `skill.id`, e.g.
`"skill.stab"`, not `display_name`, so a future rename can't silently break
the mapping) replaces that line with the user's exact fixed mapping (Stab/
Rending Slash/Poison Strike/Beguiling Strike/Death Strike -> "Speed: Normal",
Heavy Slash -> "Speed: Slow", Quick Cut/Venom Jab -> "Speed: Fast"); any
skill without an entry (the two placeholder skills) falls back to "Speed:
Normal". **Considered and reverted the more data-driven route first:** per
`docs/Conventions.md`'s data-driven-content preference, a `Skill.speed_label`
export populated per `.tres` file was tried first (adding the field to
`project/scripts/resources/skill.gd` and a `speed_label = "..."` line to
each of the 8 named skills' data files) since this task's own brief
explicitly preferred that route "if it's a clean, small change." It was a
clean, small change, but this task's working agreement separately requires
`git diff --stat -- project/scripts/systems project/scripts/resources` to be
empty for items 1-3 and reserves that folder exclusively for a justified
item-4 fix -- a `Skill` schema change would have violated that explicit,
verified boundary, so it was reverted in favor of the in-code lookup table
instead, which keeps the same fixed-content behavior without touching
`project/scripts/resources/`. Flagged here in case the user wants the
schema-field version as a deliberate follow-up outside this constraint.

**Files changed:** `project/scenes/combat/combat_screen.gd` (poison tick
popup text), `project/scenes/combat/character_stats_panel.gd`
(`_stat_delta_text()`/`_stat_line()` gained `show_plus_sign`, Physical Damage
line's format/call site), `project/scenes/combat/available_skills_panel.gd`
(`SPEED_LABEL_BY_SKILL_ID` + `_tooltip_for()` rewrite), `project/tests/
combat_screen_test.gd` (two `"Physical Damage: +8%"`/`"+0%"` assertions
updated to the no-plus text), `project/tests/build_panels_test.gd` (three
`"Physical Damage: +8%"`/hint assertions updated to the no-plus text; the
separate `_stat_delta_text(8.0, "%")` default-signature check at the end of
that block is intentionally unchanged -- it exercises the helper's own
default behavior, not the Physical Damage line specifically), this doc. No
changes to `project/scripts/systems/` or `project/scripts/resources/`
(confirmed empty `git diff --stat`, see Verification Notes).

**Item 4 findings (gear/shop rarity investigation) are written up in their
own section below, separately from this items-1-3 entry** since it's an
investigation, not a UI change -- see "2026-07-19 (item 4 investigation --
shop/reward gear rarity vs. run progression)" immediately following this
entry.

2026-07-19 (item 4 investigation -- shop/reward gear rarity vs. run
progression; not a numbered T-task, no code changed):

The user asked for verification that (a) the shop/reward system can roll
every rarity tier including Legendary, (b) higher rarity has lower
probability, and (c) Legendary probability specifically increases as the run
progresses (near-zero in the Tavern, higher approaching/at Vyra) -- to be
fixed only if a real bug against that intent was found.

**Verdict: not a bug. Gear tier is entirely authored/deterministic content,
not a weighted random roll, and it already matches the user's stated intent
by construction rather than by probability.** Full trace:

- **`GearGenerator.generate(tier, slot, rng, stable_id)`** (`project/scripts/
  systems/gear_generator.gd`) always takes `tier` as an explicit caller-
  supplied argument -- `_affixes_for_tier()` only rolls *which affixes* a
  given tier gets (via `_pick_distinct()` over `AFFIX_POOL`), never *which
  tier* to generate. There is no tier-weighting logic anywhere in
  `GearGenerator` for the tier itself.
- **The Tavern shop is always Basic, unconditionally.**
  `BuildState._generate_tavern_shop_offers()` (`project/scripts/autoload/
  build_state.gd`) calls `GearGenerator.generate(GearItem.Tier.BASIC, slot,
  rng, stable_id)` for all 4 offers, every round, every reroll -- `tier` is
  a hardcoded literal, not sampled from anything. This satisfies (a)'s
  "extremely low during the Tavern phase" for Legendary about as strongly as
  possible (exactly 0%, a subset of "extremely low") and is explicitly by
  design, not an oversight -- `docs/Phase_2_R3_Reward_Shop_Gear_Parity.md`'s
  Implementation Notes describe "four generated Basic gear offers" as the
  shipped R3 behavior, not a placeholder.
- **A second, unrelated tier-random code path exists but is dead in the
  live game.** `GearGenerator.generate_offers(count, rng_seed)` picks both
  slot AND tier uniformly at random from `ALL_TIERS = [BASIC, MASTER,
  CURSED]` (equal ~33% each, no weighting toward Basic, Legendary excluded
  entirely from the array). This looks like exactly the kind of
  weighted-tier bug the investigation was watching for -- except tracing its
  callers shows it is used only by `project/scenes/tavern/shop.gd` (a
  `dormant_tavern_shop` P2:M5-era scene, confirmed unreferenced by
  `game_root.gd`/`combat_screen.gd`, i.e. unreachable from the actual R5-R7
  dashboard flow) and by `gear_generator_test.gd`'s own unit test of that
  function. It does not affect what a player ever sees, so it isn't the "if
  reward/shop tier IS randomly weighted somewhere" case this investigation
  was told to fix -- flagged here as a piece of confirmed-dead code the user
  may want removed in a separate cleanup pass, not touched in this one since
  it's out of the item-4 systems-folder-only-if-a-bug scope and deleting
  dead code wasn't what was asked.
- **Contract-route reward tiers are per-node authored content, and they DO
  escalate toward Vyra -- by explicit design, not by weighted RNG.**
  `BuildState._gear_choices_for_reward()` passes `reward.generated_gear_tier`
  straight through to `GearGenerator.generate()` -- `generated_gear_tier` is
  an `@export` on `EncounterReward` (`project/scripts/resources/
  encounter_reward.gd`), authored per `.tres` route-node file, not rolled.
  Reading every Gilded Serpent route node's value (`GearItem.Tier` enum:
  `BASIC=0, MASTER=1, CURSED=2, LEGENDARY=3`): Portly Cook/Lazy Henchman/
  Sleeping Henchman = Basic(0); Door Guard/Patrolling Guard = Master(1);
  Cloaked Watchmen = Cursed(2) -- the harder of the two second-tier branches,
  matching `reward_shop_route_ui_test.gd`'s own "harder branch" tradeoff-text
  coverage. Every branch converges on **Knives**, which offers a guaranteed
  choice between two hand-authored Legendary weapons (`data/gear/
  wyvern_kriss.tres`, `data/gear/mithril_karambit.tres`, both `tier = 3`)
  passed via `gear_choice_rewards`, not `GearGenerator`-generated at all --
  confirming Legendary is exclusively the Knives reward-choice mechanic, per
  `docs/Phase_2_R4_Contract_Route_Parity.md`'s explicit scope ("Knives
  Legendary reward choice... other authored Legendary weapons remain out of
  R4 unless route reward scope [expands]"). Vyra itself (the final node)
  grants no gear reward. So tier does step up through the route
  (Basic -> Master -> Cursed on the harder branch) and Legendary probability
  goes from a flat 0% everywhere else in the run to a guaranteed 100% at the
  one node immediately before Vyra -- an even stronger form of (c)'s "higher
  approaching/at Vyra" than a gradually-increasing probability curve would
  be, and it's not incidental: `docs/Phase 1 Context Docs/
  Content_Library_Reference.md`'s original per-node reward table (Door
  Guard=Master, Portly Cook=Basic, Sleeping Henchman=Basic, Cloaked
  Watchmen=Cursed, Lazy Henchman=Basic, Patrolling Guard=Master, Knives=
  "Wyvern Kriss or Mithril Karambit") is byte-for-byte what the current
  `.tres` data implements, confirming this is a faithful, deliberate port of
  the Phase 1 design, not drift.
- **(b) "higher rarity has lower probability"** doesn't really apply as a
  probability question given the above -- there is no randomized tier roll
  in the live game to have a probability distribution at all (only which
  affixes/slot a fixed tier gets are randomized). To the extent it can be
  read as "do you encounter higher tiers less often," the answer is yes by
  construction: only 1 of the 6 mid-route nodes is Cursed vs. 3 Basic and 2
  Master, and Legendary exists at exactly 1 node in the entire run.

**Nothing was changed for item 4.** There is no weighted-random tier roll in
the live game that's supposed to scale with progression but doesn't, and no
hardcoded tier value that contradicts the user's stated intent -- the
authored escalation already matches (and slightly exceeds) what was asked
for. Per this task's explicit instruction not to invent a new weighted-
rarity mechanic where an authored/deterministic one is the actual working
design, `project/scripts/systems/gear_generator.gd` and `project/scripts/
autoload/build_state.gd` were read but not modified (confirmed empty `git
diff --stat -- project/scripts/systems project/scripts/resources`, see
Verification Notes). **If the user wants this changed anyway** -- e.g. gear
tier as a genuinely randomized, progression-weighted roll rather than fixed
per-node content, or removing the dead `generate_offers()`/`shop.gd` code
path, or adding more than one Legendary choice moment as routes grow beyond
the Gilded Serpent -- those are each a real, separate, deliberate design
task, not implied by anything found here.

2026-07-19 (combat playback adjustment round 2 + retry bug -- 4 user-reported
issues after playing the round-1 build above; not a numbered T-task):

The user played the round-1 build and reported three more issues, one of
which was a genuine regression bug rather than a tuning tweak.

**1. Button fill contrast fixed -- the wrong state was too light, not the
one first suspected.** Round 1 added `UIColors.BUTTON_FILL` (Gold Mid,
`#C89433`) for Button's normal state and `BUTTON_FILL_PRESSED` (Gold Shadow,
`#9C6A21`) for pressed. Measured WCAG relative-luminance contrast of each
against `TEXT_NORMAL` (`#F4E2C4`, the button label color in every state):
normal-vs-text was only ~2.14:1 -- below even the 3:1 floor WCAG recommends
for large/UI-component text -- while pressed-vs-text was already ~3.67:1 and
hover (`PANEL_HIGHLIGHT`, unchanged) was ~3.18:1. So the state a player looks
at for nearly all of a session -- the normal, at-rest, "this is live and
clickable" fill -- was the actual low-contrast offender, not the momentary
pressed state (Godot has no toggle-mode buttons anywhere in this project, so
"pressed" only ever applies for the instant the mouse is held down; the
playback speed strip's "active" speed indicator uses the separate `disabled`
stylebox, `PANEL_DISABLED`/`TEXT_DISABLED`, which already measured a healthy
~4.15:1 and was left untouched). Fix: swapped which gold tone each state
uses instead of introducing new master-palette colors --
`BUTTON_FILL` now uses Gold Shadow (`#9C6A21`, ~3.67:1) and
`BUTTON_FILL_PRESSED` becomes a new derived-darker tone, `#654515` ("Gold
Deep," ~6.82:1) -- the Gold family's three master-palette swatches (Shadow/
Mid/Highlight) have nothing darker than Shadow, so the pressed state needed a
new derived value, following the same "derived to stay in the family"
precedent `UIColors.PANEL_DEEP` already set for `PANEL`. The resulting state
ladder by luminance is Pressed (darkest) < Normal (now Gold Shadow) < Hover
(`PANEL_HIGHLIGHT`, unchanged, still lightest) -- every state now clears the
3:1 UI-component contrast floor against `TEXT_NORMAL`, and the two states
players see most (normal and pressed) both comfortably exceed it. Regenerated
`project/assets/ui_theme.tres` via the builder script, not hand-edited, per
the established preference. See Verification Notes for the exact luminance
math.

**2. RETRY BUG root cause: `retry_current_encounter()` never restored
`tavern_map_choice_made`.** The user reported Retry not working after a
fight loss -- pressing it appeared to do nothing useful, the player couldn't
fight again. Extensive tracing of the reported playback-lockout hypotheses
(a-d from the task brief) all checked out clean: `_apply_outcome_presentation()`
correctly shows/enables the Retry button for `FIGHT_LOSS_RETRY` in every
scenario tested (natural frame-driven playback finish, `_skip_playback()`,
manual `CombatPlayback.advance()`, and a fresh reloaded `combat_screen`
instance after Save & Quit mid-do-over) -- pressing Retry (via the real
`pressed` signal) always correctly returned `BuildState` to
`RunPhase.PLANNING`/`RunOutcome.NONE`. The actual break was one level
downstream: `BuildState.retry_current_encounter()` (in `build_state.gd`,
**pre-existing R5-era code, not part of the playback build itself**) clears
`run_phase`/`run_outcome`/`build_locked` but never restores
`tavern_map_choice_made`, which `start_fight()` had cleared when the
original (losing) attempt began. `needs_tavern_map_choice()` therefore
stayed `true` after every Tavern retry, so `can_start_current_fight()` --
and the real enemy panel's FIGHT! button -- stayed disabled no matter what
the player did to their build, until they rediscovered that they had to
reopen the Map overlay and re-click the SAME already-only encounter node.
Nothing in the retry status text ("Adjust your build, lock in, then fight
again.") hinted that step was required, and the existing test coverage
(`run_failure_state_test.gd`, `combat_hud_test.gd`) had baked the buggy
gating in as an *expected* assertion rather than catching it, so it shipped
silently. This is exactly what "Retry doesn't work, I can't try again" looks
like in play even though `retry_current_encounter()` itself returns `true`.
The user's report surfaced it now because the flashy new playback/HUD
experience puts full attention on the Retry button itself, where previously
the instant-resolve flow made a return trip through the Map feel more
routine. Fix (in `BuildState.retry_current_encounter()`): set
`tavern_map_choice_made = true` directly -- retrying is fighting the exact
same target, not making a new choice, so there is nothing to re-pick.
Harmless for contract fights (Vyra included): `needs_tavern_map_choice()`
requires `not is_contract_fight_active()`, so the flag is never consulted
for a contract-route retry regardless of its value.

**3. Retry rule correction -- see the dated revision note in
`docs/Phase_2_R5_Run_Rules_And_Determinism.md`** for the current rule text and
stated reason. The earlier Vyra-unlimited experiment was replaced by the
final R8 smoke-tested rule: the first Tavern encounter gets unlimited retries;
every other Tavern or contract-route fight gets exactly one retry; second
loss on a Tavern fight requires Adventure restart; second loss on a contract
route, including Vyra, marks the contract failed. `combat_screen.gd`'s
`_apply_outcome_presentation()` now keys the unlimited-retry copy on
`BuildState.is_unlimited_retry_encounter()`, which is true only for the first
Tavern fight.

**4. Playback speed persists across fights within a session.** New
`combat_screen.gd` instance var `_last_playback_speed` (defaults to
`PLAYBACK_SPEED_OPTIONS[0]`, i.e. 1x), updated inside `_set_playback_speed()`
on every call (both a real speed-button press and `_begin_playback()`'s own
initialization read from it), and `_begin_playback()` now seeds each new
playback from `_last_playback_speed` instead of hardcoding
`PLAYBACK_SPEED_OPTIONS[0]`. **In-session only, the required minimum per the
task brief** -- `combat_screen.tscn` is the persistent dashboard scene
(`game_root.gd`'s `_show_combat_screen()` is only ever called once per run,
confirmed by reading it), so a plain instance var already survives every
subsequent `_on_fight_pressed()` call for the rest of the session with no
`BuildState`/`SaveSystem` plumbing needed. Judged not worth extending to
cross-session/save-file persistence: the user's phrasing ("going into the
next fight") reads as same-session, and a loaded save resuming mid-Adventure
starting back at the readable 1x default was judged an acceptable,
easily-revisited tradeoff against adding save-schema churn for this ask.

**Files changed:** `project/scripts/ui/ui_colors.gd` (`BUTTON_FILL`/
`BUTTON_FILL_PRESSED` values swapped/redefined),
`project/scripts/tools/build_ui_theme.gd` (comment only, no stylebox-wiring
change -- same `UIColors` constants, new values), `project/assets/ui_theme.tres`
(regenerated), `project/scripts/autoload/build_state.gd`
(`retry_current_encounter()`'s `tavern_map_choice_made` fix,
`is_vyra_boss_fight()` + `finish_fight()`'s Vyra branch),
`project/scenes/combat/combat_screen.gd` (`_last_playback_speed` +
`_set_playback_speed()`/`_begin_playback()` wiring, `_apply_outcome_presentation()`'s
Vyra-aware status text), `project/tests/run_failure_state_test.gd` (retry-bug
regression block, Vyra-unlimited-retry block, non-Vyra control check, plus
the file's own `_require()`/`quit()` idiom fixed to the deferred-`_failed`
pattern so a failure can no longer be masked by the final unconditional
`quit()`), `project/tests/combat_playback_test.gd` (new
`_check_playback_speed_persists()` live check), `project/tests/combat_hud_test.gd`
(the retry-reset assertion updated from the old buggy-gating expectation to
the fixed behavior), `docs/Phase_2_R5_Run_Rules_And_Determinism.md` (Vyra
rule revision note), this doc. No changes to `project/scripts/systems/` or
`project/scripts/resources/` (confirmed empty `git diff --stat`, see
Verification Notes).

**Still a visual judgment call for the user (see Verification Notes for why
none of this could be pixel-verified in this sandbox):** whether Gold Shadow
(`#9C6A21`) as the new normal-state button fill reads as clearly "clickable"
against the warm-brown `PANEL`/`PANEL_HIGHLIGHT` backdrop at actual in-game
lighting -- it's darker than round 1's Gold Mid, which was the whole point,
but darker also risks reading as slightly less "gold-forward" at a glance;
easy to retune via `UIColors.BUTTON_FILL` alone if it reads as too muted in
practice.

2026-07-19 (user-requested combat-playback addition -- real-time combat
playback with comic-book skill popups; not a numbered T-task):

The user approved a major R7 addition: when Fight is pressed, the player
now watches the fight play out in real time in the black Combat panel --
the enemy HUD's health bar drains per hit, armor/resist/stack readouts
update as each event lands, skill names pop up comic-book style, and the
win/loss outcome is only revealed once playback ends (or is skipped).
Built as a first tunable draft with an explicit adjustment round to follow.

**Resolve first, play back second (the architecture, agreed up front):**
`CombatResolver.resolve()` is completely untouched -- combat still
resolves synchronously to a full `CombatResult` with its timestamped
cast/tick event log the moment Fight is pressed, exactly as before
(determinism/R5, seeds, and save/load/R6 all depend on it). A NEW
presentation-only playback layer then animates that pre-computed timeline:
the player experiences a real-time fight; the engine experiences nothing
new.

**State-vs-presentation timing invariant (verified, see Verification
Notes):** every state mutation happens instantly, identical to before --
`BuildState.start_fight()`, the resolve, `BuildState.finish_fight()`, and
the `_autosave()` all complete inside `_on_fight_pressed()` before the
first playback frame renders. ONLY the visual reveal waits. Killing the
process mid-playback and resuming therefore behaves identically to killing
it post-fight before this change. Because the run state has already
advanced while the player is still "watching the fight," two guards keep
the resolved outcome from leaking early: `_refresh_enemy_hud()` early
returns while `_playback_active` (signal-driven refreshes would otherwise
overwrite the animated bar with the post-fight state), and
`_update_header_status()` freezes the header on "Phase: Fighting" / "Next:
Watch the fight play out." until the reveal.

**The playback controller (`project/scripts/ui/combat_playback.gd`, new
`class_name CombatPlayback extends RefCounted`):** logic-only and
renderer-free so it is headless-testable. `start(result, kill_hp)` merges
the result's cast and tick arrays into one time-ordered timeline
(two-pointer merge; on a timestamp tie a tick fires BEFORE the cast,
matching the resolver's own `while next_tick_time_ms <= cast_end_ms`
order, so cumulative damage at any T matches the resolver exactly).
`advance(delta_seconds)` accumulates `delta * speed` and fires due events
through `event_callback`; `finished_callback` fires exactly once when the
timeline completes. `skip()` fires every remaining event instantly and
finishes -- the same path doubles as the instant mode. On a win the
timeline is truncated at the recorded kill moment (the first event whose
cumulative damage reaches the monster's HP) so playback ends when the
enemy dies; on a loss the full window plays so the timer visibly runs out
with HP remaining -- the player sees exactly why they lost.
`combat_screen.gd` drives `advance()` from `_process()` (enabled only
while a playback is active) and applies each fired event to the UI.

**HUD animation (`combat_screen.gd`):** playback opens the existing enemy
HUD (the 2026-07-19 combat-HUD addition -- no second HUD was built) at the
monster's full pre-fight values, then per event: HP drains with a short
per-hit tween (discrete chunks, not a smooth drain; poison ticks get a
slightly softer tween), and the info line + status chips update live by
replaying the recorded `CastEvent`/`TickEvent` fields (armor shred
subtraction, multiplicative resist reduction, stack count from
`stacks_remaining`/`poison_stacks_applied` capped at
`CombatResolver.MAX_POISON_STACKS`) -- the same event-replay reads the
existing post-fight `_hud_final_armor()`/`_hud_final_poison_resist()`
helpers use, no combat math reimplemented, per `docs/Conventions.md`. At
playback end `_show_enemy_hud_post_fight()` snaps the HUD to the exact
stored-result state, so the animated path and the instant path always
land on identical pixels.

**Comic-book popups:** spawned into a new full-panel, mouse-transparent
`_popup_layer` Control over the black Combat panel. Each popup is a
Pirata One Label that pops in, floats up, and fades (Godot 4 Tweens,
freed on completion). Language per the agreed design: normal cast = the
skill name in `TEXT_NORMAL`; crit = bigger, gold (`TEXT_GOLD`), with a
punch-scale snap and a trailing "!"; poison tick = a small low-key green
"-N" damage number (`TEXT_POISON`), tightly capped so the 1s cadence
doesn't spam; procs (Opportunity Strikes, Mithril Karambit triggers) =
magic purple (`TEXT_MAGIC`), one popup per triggered skill name.
Positions carry random horizontal/vertical jitter and never spawn above
`POPUP_TOP_MARGIN_PX`, keeping the HUD strip clear. Simultaneous popups
are capped (`POPUP_MAX_ACTIVE`, plus the tighter
`POPUP_MAX_TICK_ACTIVE`).

**Speed/skip controls and window indicator:** a compact control strip
under the HUD, visible only during playback: an elapsed/window readout
("12.0s / 30s" -- the denominator is always the full authored window even
when a win truncates the timeline) plus 1x/2x/4x speed buttons (the
active speed's button is disabled as its own indicator) and a Skip
button. Speed is a plain multiplier on `advance()`'s delta. On a loss the
readout ends at the cap with the HP bar still showing red.

**Deferred reveal and lockout:** during playback the status line, View
Combat Log (hidden AND disabled), retry/restart buttons, outcome title,
victory overlay, and the Map button are all hidden/locked; the build
panels are already locked (`build_locked` stays true through the fight)
and the enemy panel's FIGHT! button is already disabled because
`can_start_current_fight()` is false in the post-fight state -- both
verified rather than re-implemented. `_reveal_fight_outcome()` (extracted
from the old inline post-fight block, shared verbatim by both modes) then
shows everything at playback end: status line, log access, and the win
banner + T7 recap or the loss outcome title + retry/restart + inline
recap. Save & Quit and Abandon Run stay available mid-playback and are
safe by construction: the result is already resolved and autosaved, and
`game_root.gd` frees the whole screen on either action, so quitting
mid-playback is exactly the pre-existing quit-after-fight path.

**Instant mode for tests (the mechanism chosen):**
`combat_screen.gd`'s new `instant_playback` flag defaults to
`DisplayServer.get_name() == "headless"` -- every existing headless test
keeps driving `_on_fight_pressed()` and observing post-fight UI state
synchronously with ZERO assertion churn (no existing test file needed any
update), while the real game window gets 1x playback by default. The flag
is an explicit settable var, so playback-specific tests opt back in with
`instant_playback = false` and drive the controller manually, and a
future debug toggle could force instant mode in-game. The instant path
inside `_on_fight_pressed()` is byte-for-byte the old behavior (including
storing the HUD result before `finish_fight()` to avoid the pre-fight
flicker) with the win/loss block now living in the shared
`_reveal_fight_outcome()`.

**Tuning constants for the adjustment round** (all grouped at the top of
`combat_screen.gd` with comments): `PLAYBACK_SPEED_OPTIONS` ([1,2,4]),
`PLAYBACK_HP_TWEEN_SEC` (0.15), `PLAYBACK_TICK_HP_TWEEN_SEC` (0.3),
`POPUP_FONT` (Pirata One; swap to MedievalSharp here if it reads better),
`POPUP_DURATION_SEC` (0.9), `POPUP_RISE_PX` (48), `POPUP_FADE_DELAY_SEC`
(0.35), `POPUP_JITTER_X_PX` (90), `POPUP_JITTER_Y_PX` (24),
`POPUP_BASE_Y_FRACTION` (0.55), `POPUP_TOP_MARGIN_PX` (96),
`POPUP_FONT_SIZE` (26), `POPUP_CRIT_FONT_SIZE` (34),
`POPUP_TICK_FONT_SIZE` (16), `POPUP_PROC_FONT_SIZE` (28),
`POPUP_CRIT_PUNCH_SCALE` (1.35), `POPUP_CRIT_PUNCH_SEC` (0.12),
`POPUP_MAX_ACTIVE` (10), `POPUP_MAX_TICK_ACTIVE` (3), and the four
popup colors (`POPUP_NORMAL_COLOR`/`POPUP_CRIT_COLOR`/
`POPUP_TICK_COLOR`/`POPUP_PROC_COLOR`, all `UIColors` reads).

**Files changed:** new `project/scripts/ui/combat_playback.gd`, new
`project/tests/combat_playback_test.gd`, edits to
`project/scenes/combat/combat_screen.gd` only. No changes to
`project/scripts/systems/` or `project/scripts/resources/` (confirmed
empty `git diff --stat`, see Verification Notes), no new `UIColors`
constants (every popup/bar color already existed), no existing test file
was modified.

**Deliberately not done:** no changes to the resolver or its event
schema; no second HUD; no enemy sprite/animation work (the popups are the
only stage actors this phase, per the black-panel-reserved-for-art plan);
no persistence of a mid-playback state (playback is presentation only --
a resumed save shows the terminal outcome directly, matching how the
combat log/recap already behave across save/load); no confirmation dialog
on Skip (a skip loses nothing -- the outcome is already resolved).

2026-07-19 (combat playback adjustment round 1 -- 4 user-requested fixes
after playing the real-time combat playback system above; not a numbered
T-task):

The user played the combat-playback build from the entry above and gave
four concrete adjustments. All four are iteration on the existing system --
no new UI element was built, `CombatResolver` and `project/scripts/systems/`
and `project/scripts/resources/` remain untouched (confirmed empty
`git diff --stat`, see Verification Notes).

**1. Full window plays on a win, not just to the kill.** Previously
`CombatPlayback.start(result, kill_hp)` truncated a winning fight's
timeline at the first event whose cumulative damage reached the monster's
HP, so playback stopped the instant the enemy died. The user wants the
"overkill" feel of watching every remaining cast/tick in the window still
land on the corpse. Fix: `start()` dropped its `kill_hp` parameter entirely
and now always sets `_timeline_end_ms = result.duration_ms` -- the full
timeline plays on both a win and a loss, no truncation branch left in the
controller. The only place that ever needed the truncated end time was the
controller itself (`combat_screen.gd` never read `timeline_end_ms()`
directly, only `window_ms()` for the countdown readout, so no HUD/label
code needed touching for this). The HP bar already clamped at 0 via
`maxf(_playback_hp - damage, 0.0)` in both the tick and cast branches of
`_on_playback_event()` before this change, so no new clamping code was
needed -- the bar simply stays pinned at 0 while post-kill events keep
firing (chips/info line/popups all keep updating normally). Call site in
`_begin_playback()` updated from
`_playback.start(result, float(monster.hp) if result.is_win else 0.0)` to
plain `_playback.start(result)`.

**2. Outcome reveal now waits for the last popup to finish.** The user saw
the win/loss reveal (banner, recap, status line) pop up while a trailing
skill-name popup was still visibly floating/fading, which read as broken.
Fix: a new constant, `PLAYBACK_OUTCOME_REVEAL_DELAY_SEC := 0.75` (grouped
with the other playback tuning constants), and an
`await get_tree().create_timer(PLAYBACK_OUTCOME_REVEAL_DELAY_SEC).timeout`
inserted in `_on_playback_finished()` between `_show_enemy_hud_post_fight()`
(which still snaps immediately) and `_reveal_fight_outcome()`. 0.75s was
chosen as a little under `POPUP_DURATION_SEC`'s 0.9s full popup lifetime --
close enough that the last popup reads as fully done without tacking a
full extra second of dead air onto every fight. The await is gated
`if not instant_playback and not _playback_skipping:` -- `_playback_skipping`
is true for the full synchronous duration of a Skip-button press (set
before `CombatPlayback.skip()` is called and cleared only after it
returns, and `_on_playback_finished()` runs synchronously inside that
window as the `finished_callback`), so pressing Skip reveals the outcome
with no added delay, matching the existing behavior the live tests assert
against -- there's nothing to outlast on a skip anyway, since
`_spawn_skill_popup()` already no-ops while `_playback_skipping` is true.
The `instant_playback` check is kept alongside it for defensive
correctness even though `_on_playback_finished()` is only ever reached via
`_begin_playback()`, which itself only runs when `not instant_playback` --
headless tests never reach this function via the instant path at all, so
in practice `_playback_skipping` is the check doing the real work here.

**3. Damage numbers added to normal and crit popups.** Only poison-tick
popups showed a "-N" damage number before; normal/crit cast popups showed
only the skill name. Fix: `_on_playback_event()`'s cast branch now builds
a `damage_suffix` (`" -%.0f" % cast.physical_damage`, omitted entirely
when `physical_damage` is 0 so a pure poison/utility cast doesn't render
"-0") and appends it to the skill name before the existing crit/normal
branching, so normal casts read e.g. "Rending Slash -34" and crits read
"Rending Slash -68!" -- the crit's existing bigger/gold/punch-scale visual
treatment (`POPUP_CRIT_FONT_SIZE`, `POPUP_CRIT_COLOR`,
`POPUP_CRIT_PUNCH_SCALE`) is untouched, only the label text changed. The
number is read straight from the real `CastEvent.physical_damage` field,
no invented numbers. **Proc popups were deliberately left name-only**:
`CombatResolver._apply_skill_effects()` folds a triggered skill's damage
into the *same* `CastEvent.physical_damage` total as its source cast
rather than recording it separately (see `combat_resolver.gd`'s
`resolve()`, the `for trigger in player.triggered_skill_effects` loop),
so there is no per-trigger damage figure to attribute to the proc popup
without either double-counting the source cast's own number or changing
`project/scripts/systems/combat_resolver.gd`'s event schema to record a
separate per-trigger damage value -- both out of scope for a
presentation-only pass. Flagged for the user: a future systems-layer change
recording `CastEvent.triggered_skill_damages: Array[float]` (parallel to
`triggered_skill_names`) would unlock this cleanly.

**4. Buttons now get a solid, distinct fill.** The user wanted primary
clickable buttons (Lock, Fight!, Buy, Choose, Allocate, etc.) to visually
read as "this is a button," not blend into the panel they sit in.
Investigation: buttons are themed entirely through the project-wide
`Theme` built by `project/scripts/tools/build_ui_theme.gd` and saved to
`project/assets/ui_theme.tres` (registered via `gui/theme/custom` in
`project.godot`) -- no per-button `StyleBoxFlat` overrides exist anywhere
in the combat scenes, confirmed by grep. The bug: Button's "normal" state
stylebox used `UIColors.PANEL` as its fill -- the exact same color
`CardStyle.make_stylebox()` (and the theme's own default `Panel`/
`PanelContainer` stylebox) uses for card backgrounds, so a button at rest
was visually identical to the panel behind it. Fix: two new `UIColors`
constants from the master palette's Metals/Gold family (not one of the
ten adopted "UI" table colors -- none of those served this "actionable
control" role, so this borrows from the wider master palette the same way
`HEALTH_BAR_FILL` already does) -- `BUTTON_FILL := Color("C89433")` (Gold
Mid) and `BUTTON_FILL_PRESSED := Color("9C6A21")` (Gold Shadow).
`build_ui_theme.gd`'s Button styleboxes changed from
`_button_stylebox(UIColors.PANEL, ...)` / `_button_stylebox(UIColors.PANEL_DEEP, ...)`
to `_button_stylebox(UIColors.BUTTON_FILL, ...)` /
`_button_stylebox(UIColors.BUTTON_FILL_PRESSED, ...)` for normal/pressed;
hover deliberately kept its existing `UIColors.PANEL_HIGHLIGHT` fill
unchanged (swapping it for the lightest Gold tone, "Gold Highlight"
`#F2D16B`, was tried and rejected in reasoning -- its luminance sits too
close to `TEXT_NORMAL`'s cream `#F4E2C4` for the button label to read
clearly against it, whereas `PANEL_HIGHLIGHT` already has good contrast).
Border color (`PANEL_BORDER`) and the disabled state (`PANEL_DISABLED` fill
/ `TEXT_DISABLED` border) are unchanged. The generated
`project/assets/ui_theme.tres` was regenerated by re-running
`build_ui_theme.gd` (see Verification Notes) rather than hand-edited, per
this task's stated preference for editing the source-of-truth builder.
Applies everywhere a themed `Button` appears -- Lock, Fight!, shop Buy,
reward Choose, talent allocate, playback speed/Skip controls, retry/
restart, map/contract nodes that use the default button font, etc. -- with
zero per-screen changes needed.

**New/changed tuning constants:** `PLAYBACK_OUTCOME_REVEAL_DELAY_SEC`
(0.75, new, `combat_screen.gd`); `UIColors.BUTTON_FILL` (`#C89433`, new)
and `UIColors.BUTTON_FILL_PRESSED` (`#9C6A21`, new).
`CombatPlayback.start()`'s `kill_hp` parameter was removed (not renamed --
there is no replacement parameter).

**Files changed:** `project/scripts/ui/combat_playback.gd` (truncation
removed from `start()`, docstrings updated), `project/scenes/combat/combat_screen.gd`
(call site, popup text, reveal-delay constant + await, button-fill is
theme-only so no direct change here beyond the above), `project/scripts/ui/ui_colors.gd`
(two new constants), `project/scripts/tools/build_ui_theme.gd` (Button
stylebox colors), `project/assets/ui_theme.tres` (regenerated, not
hand-edited), `project/tests/combat_playback_test.gd` (win-truncation
test rewritten to assert full-window playback on a win; every other
`CombatPlayback.start()` call site in the file updated to drop the removed
`kill_hp` argument). No changes to `project/scripts/systems/` or
`project/scripts/resources/` (confirmed empty `git diff --stat`, see
Verification Notes).

**Still a visual judgment call for the user (see Verification Notes for
why none of this could be pixel-verified in this sandbox):**
- Whether 0.75s is the right reveal-delay length -- too short and the old
  bug might still peek through on a slow machine or a popup that spawned
  right at the final event; too long and the pause between "fight ends"
  and "outcome shown" starts to feel sluggish. Easy to retune via
  `PLAYBACK_OUTCOME_REVEAL_DELAY_SEC` alone.
- Whether "SkillName -N" and "SkillName -N!" read cleanly at
  `POPUP_FONT_SIZE`/`POPUP_CRIT_FONT_SIZE` (26/34pt Pirata One) without
  overflowing the popup's jittered spawn band, now that normal/crit
  popups carry more characters than before.
- Whether Gold Mid (`#C89433`) reads as clearly "clickable" against the
  warm-brown `PANEL`/`PANEL_HIGHLIGHT` backdrop at actual in-game contrast
  and lighting, and whether `TEXT_NORMAL` cream button labels stay legible
  on it (reasoned as acceptable contrast above, not measured against a
  real render).
- Whether the "overkill" full-window playback on a fast win (a fight that
  kills in the first second or two of a much longer window) drags on too
  long before the reveal, now that there is no early-exit -- the window
  length itself (an `_enemy_panel.duration_ms()` value, unrelated to this
  pass) is the only lever for that, not a playback constant.

2026-07-19 (user-requested combat-HUD addition -- enemy status HUD in the
black Combat panel; not a numbered T-task):

The user asked for a new UI element in the Combat panel (the box given the
solid `UIColors.PANEL_DEEP` near-black fill in the first playtest-feedback
pass, reserved for future fight-action animations): an enemy health bar, a
status bar area, and an enemy info box showing poison stacks, current
armor, and current poison resist. It will eventually appear alongside the
enemy animations; for now it is the HUD alone. Built as a first draft the
user explicitly plans to review and iterate on.

**What was built (`combat_screen.gd`):** a compact `_enemy_hud`
VBoxContainer inserted at the top of `_build_combat_window()`'s content
column, directly under the "Combat" panel title -- anchored to the top edge
so the black center of the panel stays clear for the future animation art
(same reasoning as the shopkeeper box). Four rows, roughly 80px tall in
total:
- Name row: enemy display name (left) + "HP N/M" text (right).
- Health bar: a 14px-tall `ProgressBar` (`show_percentage = false`),
  background `UIColors.PANEL_DISABLED` with a `SLOT_BORDER` 1px border,
  fill in the new `UIColors.HEALTH_BAR_FILL`.
- Status bar: an intentionally minimal placeholder `HBoxContainer` with a
  reserved 16px height (so the HUD doesn't jump when chips appear). Empty
  pre-fight; post-fight it carries small colored chip labels only for
  effects that actually occurred in the resolved fight -- "Poison xN"
  (peak stacks, `TEXT_POISON`), "Armor -N" (`TEXT_WARNING`), and
  "Resist -N%" (`TEXT_WARNING`). No invented status effects; it will grow
  with future mechanics.
- Info line: "Armor: N | Resist: N% | Poison Stacks: xN".

**Pre/post-fight display model (synchronous combat, handled honestly):**
combat resolves in one `CombatResolver.resolve()` call, so nothing can
animate live during a fight this phase. The HUD therefore has exactly two
display states. Pre-fight: full HP, base armor, base poison resist, zero
stacks, read from the current `Monster` via
`BuildState.current_target_monster()`; hidden whenever there is no
fightable target, mirroring `enemy_panel.gd::_refresh()`'s empty-state
gating exactly (RUN_ENDED, CONTRACT_OFFER, CONTRACT_ROUTE without an
active fight, pending Tavern map choice) and also while the shop or
reward-choice overlays own the combat window. Post-fight: the resolved
outcome, derived from the stored `CombatResult` (`_hud_result` /
`_hud_result_monster`, set in `_on_fight_pressed()` before
`finish_fight()` so the state-change refresh already renders post-fight):
HP bar empty on a win, remaining HP (`monster.hp - total_damage`, clamped)
on a loss, final armor after any shred, final poison resist after any
reduction, peak poison stacks. The stored result is cleared
(`_reset_enemy_hud()`) at every new-fight setup transition -- the same
call sites that clear the T7 recap label: `_on_map_node_pressed`,
`_on_contract_route_node_pressed`, `_on_retry_pressed`,
`_on_secondary_tree_pressed`, and the top of
`_advance_after_reward_or_shop()`. Not persisted across save/load,
matching `_log_label`'s existing behavior. Note: after a Tavern retry the
map choice is pending again (`start_fight()` clears
`tavern_map_choice_made`), so the HUD -- like the enemy panel -- shows
nothing until the encounter is re-chosen on the map.

**Helpers added (all pure, reading only recorded `CombatResult` events per
`docs/Conventions.md`'s UI architecture principle -- no combat math
reimplemented):** `_hud_post_fight_hp()`, `_hud_total_armor_reduction()`,
`_hud_final_armor()` (base armor minus every recorded
`armor_reduction_applied`, unclamped like the resolver),
`_hud_final_poison_resist()` (base resist with each recorded per-cast
fraction applied multiplicatively, mirroring the resolver; exact for every
authored skill since each applies at most one
`PoisonResistanceReductionEffect` per cast), and
`_hud_peak_poison_stacks()` (same `stacks_remaining + 1` read as T7's
`_poison_summary_text()`). Plus the non-pure plumbing:
`_build_enemy_hud()`, `_refresh_enemy_hud()`, `_hud_pre_fight_monster()`,
`_render_enemy_hud_post_fight()`, `_set_enemy_hud_display()`,
`_clear_hud_status_chips()` (removes children immediately rather than
relying on `queue_free()` alone, avoiding the stale-child class of bug
T4's notes document), `_add_hud_status_chip()`,
`_show_enemy_hud_post_fight()`, `_reset_enemy_hud()`. Refresh is wired to
the same signals the rest of the dashboard uses
(`_on_build_state_changed()`/`_on_run_state_changed()` plus an initial
call in `_ready()`).

**One new `UIColors` constant:** `HEALTH_BAR_FILL := Color("9E3535")` --
the master palette's Rogue "Crimson Accent," the palette's own deep
blood-red; `TEXT_WARNING`'s brighter `#D35C45` stays reserved for
warning/loss text rather than doubling as a bar fill. No other constants
were needed (bar background/border reuse `PANEL_DISABLED`/`SLOT_BORDER`).

**Deliberately not done:** no changes to `enemy_panel.gd`'s pre-fight
planning display (required DPS, reward preview, pressure line -- that
panel stays; some number overlap with the HUD is accepted for now per the
user's iterate-later framing); no changes to `project/scripts/systems/` or
`project/scripts/resources/` (confirmed empty `git diff --stat`, see
Verification Notes); no live HP animation (impossible under synchronous
resolution -- deferred to whenever a real-time fight loop exists); no
invented status effects.

2026-07-18 (P2:R7:T8 - Polish Navigation/Confirmations):

Read-first audit of every navigation/destructive control across `title.gd`,
`game_root.gd`, and `combat_screen.gd` against `SaveSystem`'s autosave call
sites (per `P2:R6:T6`'s autosave-point list) and the existing `ConfirmationDialog`s,
following the task's core principle: confirmations only where state loss is
real.

**Found already correct, no change needed:**
- **Abandon Run** (top bar): already has a `ConfirmationDialog` ("Are you
  sure you want to abandon this run? Any saved progress will be deleted.")
  from `P2:R6:T4`, and it genuinely is destructive -- it deletes the save and
  resets `BuildState` without persisting the in-progress build edit. Wording
  audited and already accurate.
- **Adventure Mode / New Game** (Title): already confirms via
  `_new_game_confirm_dialog` only when `SaveSystem.has_save()` is true
  (correctly skips the dialog on a fresh install / after abandon, where
  nothing would be discarded).
- **Save & Quit**: no dialog, correctly so -- it explicitly persists before
  returning to Title, so there's nothing to lose.
- **Resume/Continue Adventure**: no dialog, correctly so -- non-destructive,
  loads a save.
- **Retry Fight, Continue after Win (Claim Rewards), Restart Adventure /
  Start New Adventure** (all four `_apply_outcome_presentation()` /
  `_on_continue_pressed()` paths): none have a confirmation dialog, and per
  this task's own explicit guidance these should stay that way -- they're
  expected low-risk flow actions, and (for Restart/Start New Adventure
  specifically) they only ever appear in a terminal `RUN_ENDED` state, where
  the run has already concluded and there is nothing further to lose by
  moving on. Adding dialogs here would be the same over-built-friction
  mistake the two playtest-feedback passes already had to walk back
  elsewhere in R7 (the giant gear-comparison tooltip, the always-on captions).
- **Training Room** (Title): correctly disabled with an accurate "Coming
  soon" tooltip from the first playtest-feedback pass; not a state-loss
  control at all (does nothing when clicked, since it's disabled).
- **Exit** (Title): no dialog. Confirmed safe by tracing every path that
  reaches Title -- `game_root.gd` only shows Title from `_ready()` (fresh
  launch), `_on_save_and_quit_pressed()` (state already just persisted),
  `_on_continue_pressed()`'s failure branch (a corrupt/incompatible save was
  just deleted, nothing to lose), or after Abandon Run's confirm (save
  already deleted, `BuildState.reset()` already ran). There is no path that
  lands on Title with an active, unsaved run in memory, so Exit never
  discards anything.
- **class_select.gd / subclass_select.gd Back buttons**: audited and found
  non-destructive -- these screens are only reachable via the New Game path
  (a fresh `BuildState.reset()` with no autosave yet) or the Restart Adventure
  path (see below), never via Continue/Resume (which jumps straight to the
  combat dashboard). Going back has nothing meaningful to discard.

**Found and fixed -- a real bug, not just a wording gap:**
`game_root.gd`'s `_on_adventure_restart_pressed()` (wired to both the
"Restart Adventure" and "Start New Adventure" buttons via the shared
`adventure_restart_pressed` signal) called `BuildState.reset(true)` and
advanced to class select, but never called `SaveSystem.delete_save()` --
unlike `_on_new_game_pressed()` (Title's Adventure Mode), which does. Since
`_on_fight_pressed()`/`_advance_after_reward_or_shop()` already autosave the
terminal `RUN_ENDED` state right before the restart button becomes visible
(per `P2:R6:T6`'s "after fight result/failure state" autosave point), the
old save from the just-ended run was left on disk. If a player pressed
Restart/Start New Adventure and then quit before the next autosave point
(class/subclass select's own autosave), relaunching and pressing "Continue
Adventure" on Title would silently resume the OLD, already-concluded run
instead of the new one the player explicitly chose to start -- a real,
if narrow, state-confusion bug, not merely a missing confirmation. Fixed by
adding `SaveSystem.delete_save()` to `_on_adventure_restart_pressed()`,
mirroring `_on_new_game_pressed()`'s existing call. This is a UI-orchestrator
change in `game_root.gd`, not a change to `SaveSystem`'s own serialization
logic, consistent with this task's systems-folder boundary.

**Found and fixed -- a wording/dead-end mismatch (item 6's cross-check):**
`combat_screen.gd`'s `_next_action_text()` promised "Accept or decline the
contract on the map." at `RunPhase.CONTRACT_OFFER`, but
`_refresh_contract_offer_map()` only ever builds a single Accept button --
there is no decline control anywhere in the contract-offer map overlay (the
only Contract in Phase 2 scope is the Gilded Serpent, and declining it isn't
an implemented path). The header's "Next:" line was promising an action the
UI didn't actually offer, exactly the class of mismatch item 6 asks to check
against T3's header. Fixed the string to "Accept the contract on the map.",
with a matching update to `project/tests/dashboard_header_test.gd`'s exact-
string assertion.

**Button label audit (item 5):** "Restart Adventure" vs. "Start New
Adventure" still reads clearly and correctly split by outcome (loss-forced
restart vs. victory/run-complete) per `P2:R5:T8`'s original design, confirmed
by rereading `_apply_outcome_presentation()`. "Retry Encounter," "Save &
Quit," "Abandon Run," "Claim Rewards," "Continue Adventure," "Adventure
Mode," "Training Room," and "Exit" are all verb-first/clear and were left
unchanged. Training Room's "Coming soon -- practice builds against a target
dummy." tooltip and Resume's "No saved Adventure to resume." tooltip (both
from the first playtest-feedback pass) were reread and are accurate as-is.

**16-state walk (item 6):** cross-checked every `P2:R7:T1` reachable state's
actual visible controls against `_next_action_text()`'s corresponding branch
(the only mismatch found is the CONTRACT_OFFER fix above); every state has
exactly one clear primary action reachable and no dead end, matching
`dashboard_header_test.gd`'s existing per-state coverage plus this task's
CONTRACT_OFFER fix.

**No new `ConfirmationDialog`s were added** -- the two that already existed
(Abandon Run, New Game-with-existing-save) already cover every action this
task found to be genuinely destructive; nothing new qualified. Consequently
no new `UIColors`/`CardStyle` styling work was needed either (no new dialog
to style).

Deliberately deferred: no changes to `class_select.gd`/`subclass_select.gd`
beyond the read-only Back-button audit above (both already correct). No
T9/T10 scope touched (verification-pass formalization and doc-closeout
remain their own tasks). No repo-wide fix of the `_require()` exit-code-
masking pattern noted in prior R7 entries -- out of scope for T8, and this
task's own new test additions (`save_load_ui_test.gd`'s new section) don't
use the `_require()` helper at all (that file uses plain `assert()`, which
fails loudly and immediately rather than relying on a deferred `quit(1)`),
so they aren't at risk of the same masking bug.

2026-07-18 (P2:R7:T7 - Improve Combat Recap):

- Read-first found `project/scripts/systems/combat_recap.gd`'s
  `CombatRecap.summarize()` (total damage, DPS, biggest hit, physical/poison
  split) already wired into `combat_screen.gd::_show_victory_banner()`, and
  `project/scripts/systems/combat_result_formatter.gd`'s `format()` already
  producing the full per-event chronological log text (crit/poison-stack/
  armor-shred/trigger clauses per cast) shown via "View Combat Log" -- both
  pre-existing, from before `P2:R7`. The task's five new requirements
  (required DPS restated next to the actual result, biggest hit's crit flag,
  raw physical/poison amounts alongside the split percentages, a crit count,
  an armor-reduction summary, and a poison tick/stack summary) were not
  covered by either, and this task's working agreements explicitly forbid
  editing `project/scripts/systems/` (which `combat_recap.gd` sits under,
  despite the file itself being a presentation-only aggregator per its own
  docstring) -- so all new recap fields are new pure helper functions added
  directly to `combat_screen.gd` instead, per the task's own suggested
  helper names, working straight off `CombatResolver.CombatResult`'s
  `cast_events`/`tick_events` arrays: `_biggest_hit_text()` (now also names
  whether the largest cast crit, e.g. "Biggest Hit: Heavy Slash for 84.0
  (crit)"), `_damage_split_text()` (now shows raw amounts alongside percents,
  e.g. "Physical: 620 (74%) / Poison: 218 (26%)"), `_crit_count_text()`,
  `_armor_reduction_summary()` (returns `""`, omitted from the recap
  entirely, when no cast in the fight applied armor reduction), and
  `_poison_summary_text()` (same omit-when-unused rule for a fight with no
  poison ticks; "peak stacks" is read as `TickEvent.stacks_remaining + 1` for
  each damaging tick, since the field only records the count *after* that
  tick's own decrement). `_recap_required_dps()` mirrors
  `enemy_panel.gd::_required_dps_text()`'s HP/window-seconds calculation
  (P2:R7:T5) as a small local function rather than a cross-panel call to
  that panel's underscore-prefixed helper -- this file already only calls
  other panels' explicitly public methods (`monster()`/`duration_ms()`)
  across panel boundaries, and this keeps that convention. `CombatRecap` and
  `CombatResultFormatter` themselves are unmodified and still used exactly
  as before (`CombatResultFormatter.format()` for the full log;
  `CombatRecap` is no longer called from `combat_screen.gd` now that
  `result.total_damage`/`result.dps` are read directly and the richer local
  helpers replace its `biggest_hit`/`physical_pct`/`poison_pct` fields, but
  the class itself is untouched and has no other callers to break).
- A new shared `_build_recap_lines(result, monster) -> PackedStringArray`
  composes all of the above into the "needed X, did Y" headline (`"Total
  Damage: %.1f (needed %d)"` / `"DPS: %.1f (needed %.1f)"`) plus the
  secondary highlight lines (biggest hit, split, crit count always shown;
  armor reduction and poison summary only when that mechanic actually came
  up), used by both outcomes:
  - **Win**: `_show_victory_banner()` now passes the fight's `Monster` in
    (previously only `result`) and sets `_victory_recap_label.text` from
    `_build_recap_lines()`, inside the existing `_victory_overlay`.
  - **Loss**: the loss path had no recap block at all before this task --
    only the outcome title/status text from `_apply_outcome_presentation()`
    and the full log behind "View Combat Log." Added a new `_recap_label`
    Label, built in `_build_combat_window()` directly under `_status_label`
    (the same `_combat_content` column the loss outcome UI already lives
    in, since a loss has no overlay of its own the way a win does).
    `_on_fight_pressed()`'s loss branch now sets its text from the same
    `_build_recap_lines()` call and makes it visible. Hidden again (and its
    text cleared) at every "start planning the next fight" transition this
    file already has a `_status_label.visible = true/false` toggle for
    (`_on_map_node_pressed`, `_on_contract_route_node_pressed`,
    `_on_retry_pressed`, `_show_shop_overlay`, `_show_reward_choice_overlay`,
    `_on_secondary_tree_pressed`, and the top of `_show_victory_banner`), so
    a stale loss recap from a prior fight never lingers into an unrelated
    dashboard state. Not persisted across save/load, matching
    `_log_label`'s existing (pre-`P2:R7`) behavior -- neither the combat log
    nor the recap survives a resume, only the terminal outcome state does.
- Kept scannable per the task's explicit warning against a wall of text:
  the win/loss recap is 5-7 lines (2 always-visible headline lines, 3
  always-visible secondary lines, plus 0-2 conditional lines), matching the
  existing 5-line recap's rough size rather than growing it into every
  possible stat at once. No tooltip/expandable-section indirection was
  needed the way the playtest-fix passes required for T3/T4's *persistent,
  always-on-screen* dashboard bulk -- this recap only exists transiently
  after a fight resolves (inside the victory overlay for a win, or inline
  under the outcome title for a loss), not as permanent dashboard chrome
  competing with the three-column HUD's tight vertical budget documented in
  the playtest-fix pass's overflow-bug notes.
- No new `UIColors` constants were needed -- `_recap_label` and the extended
  `_victory_recap_label` text are plain, uncolored `Label`s, matching
  `_status_label`'s existing convention of carrying no color override.
- Updated `project/tests/combat_screen_test.gd`'s existing win-recap
  assertions (previously checking the old `"Physical Damage: 100%"` /
  `"Poison Damage: 0%"` format) to match the new headline/split format and
  added coverage for the new required-damage/required-DPS/crit-count
  content in that same live win check.
- Added `project/tests/combat_recap_test.gd`: direct calls to all six new
  helpers against a known deterministic `CombatResolver.resolve()` result
  (Poison Strike + Rending Slash rotation, `crit_chance = 1.0` for
  unambiguous crit assertions, seed 3) with expected values computed
  independently in the test (not by re-calling the code under test) for
  biggest hit/crit flag, crit count, physical/poison split, armor-reduction
  total and cast count, and poison tick count/peak stacks/tick damage; a
  second known fight (Stab only, no poison/armor skills) confirming the
  armor-reduction and poison-summary lines are omitted entirely rather than
  showing a zero/N/A line; and two live end-to-end checks driving the real
  `combat_screen.tscn` scene through an actual win (Quick Cut rotation
  against the Mouthy Drunk Tavern opener) and an actual loss (empty
  rotation, guaranteed zero damage), confirming `_victory_recap_label`/
  `_recap_label` respectively carry the full recap and that the inline loss
  label stays hidden on a win. While writing this test, found and fixed a
  latent masking bug in this file's own `_require()` helper (the same
  push_error-then-`quit(1)`-without-`return` idiom every other test file in
  this repo also uses): two of this test's checks call
  `fight_enemy_panel.fight_pressed.emit()` followed by `await
  process_frame`, and calling those `async`-implicit check functions from
  `_initialize()` *without* `await` let `_initialize()`'s own final
  unconditional `quit()` call run (and win, resetting the exit code to 0)
  before the awaited coroutines actually finished -- verified by
  deliberately breaking an assertion and observing the process still exit
  0. Fixed locally in this file only (in scope for this task) by awaiting
  both live check functions from `_initialize()` and having `_require()`
  record failures into a `_failed` flag instead of calling `quit(1)`
  immediately, with `_initialize()` choosing the final exit code from that
  flag once every check (including the awaited ones) has actually
  completed. This is a pre-existing pattern shared by every other test file
  in the repo (`run_failure_state_test.gd`, `run_outcome_presentation_test.gd`,
  etc., none of which `await` inside a function called without `await`) and
  was left unfixed there -- out of scope for a `P2:R7:T7` combat-recap task,
  but worth a follow-up note for whoever next touches this repo's test
  helpers, since it could currently be masking a real failure in any
  existing test that mixes `await` with the shared `_require()` idiom.
- Deliberately deferred: no tooltip/hover-only version of any recap line --
  the whole block stays always-visible per the "scannable, not a wall of
  text" sizing reasoning above, not hidden-until-hover the way T6's gear
  comparison ended up after its own playtest revision. No changes to
  `CombatRecap`/`CombatResultFormatter` themselves (systems-folder
  boundary, see above) and no attempt to route the new helpers through them
  -- a future pass could fold these into `CombatRecap.summarize()`'s
  dictionary if that folder boundary is ever relaxed for this specific
  presentation-aggregator file, but that's a judgment call for whoever owns
  that boundary decision, not something to do silently inside a `T7`-scoped
  task. No poison-resistance-reduction line was added (the task's item 7
  names armor reduction specifically, e.g. Rending Slash/Sunder; poison
  resistance reduction is a related but separate `PoisonResistanceReductionEffect`
  mechanic already visible per-cast in the full combat log via
  `CombatResultFormatter`, and adding a second conditional mechanic line
  beyond what the task asked for would work against the "keep it scannable"
  guidance). No T8-T10 scope touched.

2026-07-18 (second playtest feedback pass - revises T6, the first feedback
pass's gear tooltip, title menu, gear panel, and secondary tree chooser):

The user ran a second real editor play session after the first playtest
feedback pass and reported five more issues. Like the first pass, this is a
UI feedback/bugfix revision of existing R7 work, not a new numbered task.

1. **Main menu ordering and Resume gating.** `title.gd`: menu order is now
   Training Room, Adventure Mode, Continue Adventure (Resume), Exit
   (previously Continue sat first and Training Room second). The Training
   Room placeholder button already existed (disabled, stubbed since the
   original title screen -- Training Room Lite remains optional `P2:R8`
   scope and no functionality was built); it only moved to the top and
   gained a "Coming soon -- practice builds against a target dummy."
   tooltip. The Resume/Continue button is now ALWAYS visible and instead
   *disabled* when `SaveSystem.has_save()` is false (previously
   `visible = SaveSystem.has_save()` hid it entirely, making the menu shape
   shift between sessions), with a "No saved Adventure to resume." tooltip
   in the disabled state -- the same disabled-not-hidden convention
   class_select.gd's Mage/Crusader cards established, with the graying
   supplied by the project theme's existing disabled Button stylebox/
   `UIColors.TEXT_DISABLED` font color from `P2:R7:T2` (no per-button color
   overrides needed).
2. **Inventory items carry the shop-style slot/tier caption.** The user
   liked T6's two-line slot/tier caption on shop item boxes as a
   placeholder for future art, so inventory boxes now match:
   `_gear_box_label()` moved out of `combat_screen.gd` into two shared
   `CardStyle` statics -- `CardStyle.gear_box_label(gear)` (the "Weapon"/
   "Master" two-line string) and `CardStyle.style_gear_box_caption(button)`
   (the VT323-size-14 font plus normal/disabled `UIColors` font colors that
   caption needs inside an 88-112px box) -- rather than copy-pasted.
   `combat_screen.gd`'s `_make_shop_offer_row()`/`_make_reward_choice_button()`/
   `_style_shop_item_box()` now call the shared statics, and
   `gear_panel.gd`'s `_make_inventory_slot()` applies the same caption to
   occupied inventory slots (empty slots stay caption-free and disabled as
   before).
3. **Custom giant gear-comparison tooltip reverted.** The first feedback
   pass's `_build_gear_compare_tooltip()` -- a `CardStyle.make_stylebox()`
   panel holding two "This Item"/"Equipped" columns plus footer -- rendered
   as a huge window instead of a normal tooltip in real play and the user
   rejected it. That Control, `_gear_compare_column()`, and the T6-era
   stat-diff helpers `_gear_upgrade_comparison_text()`/
   `_format_stat_delta_vs_equipped()` are all deleted (not just bypassed):
   per item 4's design there is no stat-value diff text anywhere anymore,
   so `_shop_offer_text()`/`_reward_choice_text()` also no longer append a
   comparison line. Both plain-text helpers were refactored onto a shared
   `_gear_tooltip_lines(gear)` (slot/name, tier, affixes, triggered-skill
   lines) plus their respective footers, replacing the near-duplicate
   bodies and the now-folded-in `_shop_offer_title()`.
4. **New comparison design: a second "Equipped" tooltip box beside the
   regular one.** The `GearCompareButton` inner class (the
   `_make_custom_tooltip()` override host) is retained, but the Control it
   returns is rebuilt from scratch as `_build_gear_compare_tooltip(item_text,
   equipped)`: a plain `HBoxContainer` of two `_make_tooltip_box()` panels,
   each deliberately styled to be visually identical to a standard Godot
   tooltip -- the theme chain's own `TooltipPanel` stylebox via
   `get_theme_stylebox("panel", "TooltipPanel")`, `TooltipLabel` font color
   via `get_theme_color(...)`, default font/size (the project theme's VT323
   18), zero added padding/margins. The first box carries the hovered
   item's regular tooltip text verbatim (`_shop_offer_text()`/
   `_reward_choice_text()`, i.e. exactly what `tooltip_text` shows as the
   plain fallback); the second box is headed "Equipped" (one
   `CardStyle.ACCENT_COLOR` line) over the equipped item's own
   `_gear_tooltip_lines()` -- or "Nothing equipped." when the slot is
   empty. The equipped lookup now happens inside the `tooltip_builder`
   closure at hover time rather than captured at row-build time, so the
   box reflects mid-shop equip changes. Applied to both shop offers and
   reward/Legendary choices. Reasoned size (see Verification Notes): about
   two normal tooltips side by side, not a giant window.
5. **Secondary Rogue tree chooser matches the primary subclass select.**
   Extracted subclass_select.gd's card layout into
   `CardStyle.make_selection_card(title_text, body_text, action_button,
   card_width = 280)` (280px card, `CardStyle.make_stylebox()`, PanelHeader
   title at font size 24, autowrapped body at size 15, action button
   below); `subclass_select.gd::_build_card()` now delegates to it (its
   local `CARD_WIDTH`/`CARD_TITLE_FONT_SIZE`/`FLAVOR_FONT_SIZE` constants
   moved to `CardStyle` as the shared `SELECTION_CARD_*` values), and
   `combat_screen.gd`'s `_make_secondary_tree_button()` (one dense
   220x130 multi-line VT323 button per tree) is replaced by
   `_make_secondary_tree_card()`, which builds the same shared card with
   the tree's display name as the title, "Intrinsic: ..." (via the
   unchanged `_intrinsic_description_for_tree()`) as the body, and a
   "Choose" button. class_select.gd's own `_build_card()` was left as-is
   (identical layout, but flavor-dict lookup and Coming Soon handling are
   its own; consolidating it was not needed for this item's visual-match
   goal).

Test updates made alongside (updated to assert the new intended behavior,
not deleted, per this doc's working agreements):
- `save_load_ui_test.gd`: the three "Continue hidden without a save"
  assertions flipped to visible-but-disabled (and enabled after a save
  exists); added menu-order assertions (Training Room index < Adventure
  Mode index < Continue index) and Training Room disabled+tooltip checks.
- `reward_shop_route_ui_test.gd`: the direct
  `_gear_upgrade_comparison_text()` section is replaced by two-box tooltip
  checks -- calling the real `_make_custom_tooltip()` on a live shop offer
  button and asserting the returned Control is an HBox of exactly two
  `PanelContainer`s, the first carrying the offer's `tooltip_text`
  verbatim, the second headed "Equipped" with "Nothing equipped." for an
  empty slot; then, with a known weapon equipped, that the second box
  carries the equipped item's slot/name/tier/affix lines. Also asserts
  tooltips no longer contain any "vs. equipped"/"Upgrade --" diff text
  (including the Wyvern Kriss reward-claim text, which previously
  asserted the diff line's presence).
- `combat_screen_test.gd`/`contract_offer_flow_test.gd`: the
  secondary-chooser assertions now navigate the card structure
  (card -> vbox -> title/intrinsic/Choose) instead of reading one dense
  button's text, and press the per-card "Choose" button.
- `build_panels_test.gd`: added inventory-caption assertions (occupied
  slot text equals `CardStyle.gear_box_label()`'s Trinket/Basic caption
  for Lucky Coin; empty slots stay caption-free).

Deliberately deferred: no stat-diff/upgrade indicator in any form (user
wants none for now); no Training Room functionality (P2:R8); no
class_select.gd migration onto `make_selection_card()`; no T7-T10 scope.
No changes to `project/scripts/systems/` or `project/scripts/resources/`
-- confirmed via `git diff --stat` (see Verification Notes).

2026-07-18 (playtest feedback pass - revises T3/T4/T6):

The user ran the game in the Godot editor after T2-T6 landed and gave eight
concrete playtest issues. This is a UI feedback/bugfix pass over that
existing work, not a new numbered task.

1. **Title Resume/Load only when a save exists.** Read-first found this
   already correct: `title.gd`'s `continue_button.visible =
   SaveSystem.has_save()` and `_on_adventure_button_pressed()`'s
   `SaveSystem.has_save()` gate on the new-game confirm dialog were both
   already in place (from `P2:R6:T4`), and `save_load_ui_test.gd` already
   covers the no-save/has-save/abandon-clears-save states end to end. No
   code change was needed; verified by rereading `title.gd`/`game_root.gd`/
   `save_system.gd` and rerunning `save_load_ui_test.gd`.
2. **Dashboard overflow bug.** Root-caused as the cumulative vertical bulk
   T3 and T4 added: T3's separate full-width status-bar row (its own
   `PanelContainer` inserted between the top bar and the three-column HUD
   body) and T4's always-visible skill-effect captions, talent lock-reason
   captions, and inline stat-delta text all added height with no
   compensating removal anywhere, pushing `root_vbox`'s required minimum
   height past the `868`px available inside the `1600x900`
   (`project.godot`'s `viewport_width`/`viewport_height`) window after the
   `16`px `SCREEN_MARGIN` on each side. Fixed by doing items 3-6 below
   together (each removes or relocates exactly the bulk T3/T4 added) rather
   than patching this bug in isolation -- see the Verification Notes entry
   below for the reasoned height accounting, since this sandboxed
   environment can't pixel-verify a real Godot window.
3. **Status bar consolidated into the top bar.** `combat_screen.gd`'s
   `_ready()`: removed T3's separate `status_bar` `PanelContainer` (which
   held `status_row` -- Phase/Target/Build/Seed plus a right-aligned Gold
   label -- and a `next_action_label` line underneath) entirely. Phase,
   Build, and Seed now render directly in the existing top bar `HBoxContainer`,
   to the left of the Map/Save & Quit/Abandon Run buttons; the Next-action
   label moved there too, given `size_flags_horizontal = SIZE_EXPAND_FILL`
   and `clip_text = true` so a long instruction can't push the buttons off
   the right edge. Target and Gold were dropped rather than relocated -- the
   user flagged both as redundant (Target is restated by `enemy_panel.gd`'s
   own "Target:" line from `P2:R7:T5`; Gold appears in both
   `gear_panel.gd`'s own "Gold:" label and the T6 shop overlay's own gold
   label) -- satisfying "still save that area for some status information"
   while cutting the duplication and reclaiming the whole separate row's
   height. `_node_label`/`_header_gold_label` and the now-dead
   `_current_node_text()` helper were removed from `combat_screen.gd`
   entirely, not just hidden.
4. **Available-skills effect caption removed.** `available_skills_panel.gd`:
   reverted `_build_skill_button()`'s VBoxContainer-wrapper-plus-caption-Label
   structure back to a bare `Button` per skill (`_refresh()`'s stale-child
   force-update loop reverted to match). `_skill_effect_summary()` itself is
   unchanged and still feeds `_tooltip_for()`'s hover tooltip -- only the
   always-visible caption rendering was removed, per the user's note that it
   duplicated the tooltip.
5. **Talent lock-reason caption removed.** `talent_panel.gd`'s
   `_build_node()`: removed the `reason_label` child that rendered
   `_talent_lock_reason()`'s text under an unavailable talent node.
   `_talent_lock_reason()` itself is unchanged and still feeds
   `_talent_tooltip()`'s `lock_reason` parameter (already wired from T4),
   so the reason is still one hover away, just not always on screen.
6. **Stat deltas moved into a tooltip.** `character_stats_panel.gd`: added
   `_stat_line(label, value_text, delta, suffix, one_decimal, color)`,
   which renders `"Label: value"` (optionally colored for the poison
   lines, same as before) and, only when there's a non-trivial delta, wraps
   the whole line in a BBCode `[hint=...]...[/hint]` tag -- `RichTextLabel`
   already supports `[hint=...]` as a built-in hover-tooltip mechanism, so
   no new Control/signal wiring was needed, just a different place to put
   the same string. `_stat_delta_text()` itself is byte-for-byte unchanged
   (still directly unit-tested) since only where its output gets placed
   changed, not its format.
7. **Shop/reward gear tooltip -> side-by-side comparison (option (a)
   implemented, not deferred to (b)).** Added a `GearCompareButton` inner
   class in `combat_screen.gd` (`extends Button`) whose only job is to
   override `_make_custom_tooltip(for_text) -> Object` and delegate to a
   `Callable` set per-instance -- `Button.new()` can't have a virtual method
   overridden without subclassing, and this keeps the actual Control-building
   logic (which reads `GearItem`/`StatModifier` data) in the main script
   rather than duplicated inside the subclass. Added
   `_build_gear_compare_tooltip(item, equipped, footer_lines) ->
   Control` and `_gear_compare_column(heading, gear) -> Control`, which
   build a `PanelContainer` (styled via `CardStyle.make_stylebox()`) holding
   two side-by-side columns labeled "This Item" and "Equipped" (slot/name,
   tier, and affix lines per column, or a muted "Slot is empty"/"None" note
   when a column's `GearItem` is `null`), plus any footer lines (price/
   afford-state/click hint for shop offers, "Click to choose." for reward
   choices) below both columns. Both `_make_shop_offer_row()` and
   `_make_reward_choice_button()` now build `GearCompareButton`s and set
   `tooltip_builder` to a closure returning this comparison Control.
   `_shop_offer_text()`/`_reward_choice_text()` (T6's original plain-text
   tooltip helpers, including `_gear_upgrade_comparison_text()`'s appended
   diff line) are deliberately left unchanged and still assigned to
   `tooltip_text` -- Godot only uses `_make_custom_tooltip()`'s return value
   for the actual on-hover visual when it's non-null, so `tooltip_text`
   now serves only as a plain-text fallback/accessibility copy (and keeps
   every existing test that reads `.tooltip_text`/calls
   `_shop_offer_text()`/`_reward_choice_text()`/`_gear_upgrade_comparison_text()`
   directly passing unchanged). Extracted `_shop_offer_footer_lines()` out
   of `_shop_offer_text()` so the plain-text tail and the new tooltip's
   footer can't drift apart.
8. **Combat panel gets a solid near-black background.** `combat_screen.gd`'s
   `_build_combat_window()`: the panel's stylebox now sets
   `bg_color = UIColors.PANEL_DEEP`, the same constant the shop overlay's
   shopkeeper box already uses (`_build_shop_overlay()`'s `keeper_style.bg_color
   = UIColors.PANEL_DEEP`) -- reused rather than adding a new `UIColors`
   constant, since both panels serve the identical "reserved for future art"
   role (shopkeeper portrait now, fight-action animation later).

Test updates made alongside the above (existing T3/T4/T6 assertions that
checked the now-changed behavior, updated per this doc's working
agreements rather than deleted):
- `project/tests/dashboard_header_test.gd`: removed every assertion against
  the now-deleted `_node_label`/`_header_gold_label`; updated the header
  comment to record why (Target/Gold dropped as redundant, not relocated).
- `project/tests/build_panels_test.gd`: the skill-effect-summary check no
  longer looks for an always-visible caption Label -- it now asserts the
  skill button is a bare `Button` and that its `tooltip_text` contains the
  summary. Added an explicit assertion that no descendant `Label` under a
  locked talent node carries the lock-reason text (tooltip-only). The
  stat-delta check now asserts the raw `_stats_label.text` contains the
  delta wrapped as `[hint=...]`, and separately asserts
  `_stats_label.get_parsed_text()` (the rendered/visible text with BBCode
  stripped) does *not* contain the delta note, directly proving it's
  tooltip-only rather than just checking a substring that would have
  trivially matched either way.
- `project/tests/combat_screen_test.gd`: the post-lock available-skills
  disabled-state check reverted from `child.get_child(0).disabled` (T4's
  wrapper-column structure) back to `child.disabled` (bare `Button` again).

Deliberately deferred: no scroll/clip fallback (e.g. wrapping `root_vbox`
or the three-column HUD body in a `ScrollContainer`) was added on top of
the vertical-bulk reduction in items 3-6 -- the reasoned height accounting
in the Verification Notes entry below shows items 3-6 remove roughly the
same amount of height T3/T4 added in the first place, which is the root
cause per item 2's analysis. A future task that adds more always-visible
per-panel content should re-check this budget rather than assume headroom
exists. No changes to `project/scripts/systems/` or
`project/scripts/resources/` -- confirmed via `git diff --stat` (see
Verification Notes).

2026-07-18 (P2:R7:T6 - Improve Reward/Shop/Route UI):

- All changes live in `project/scenes/combat/combat_screen.gd`, which was
  confirmed via read-first to already own the shop overlay, reward-choice
  overlay, and route-choice map/schematic UI inline -- no dedicated overlay
  scenes exist under `project/scenes/combat/` for these three states, and
  none were added.
- Shop overlay (`_build_shop_overlay()`/`_refresh_shop_overlay()`): gold is
  now visibly shown inside the shop overlay itself, not only via `P2:R7:T3`'s
  header -- `_shop_gold_label` was previously built but left permanently
  hidden with empty text (`visible = false`, `text = ""`); it's now populated
  with `"Gold: %dg" % BuildState.gold` in `UIColors.TEXT_GOLD` and left
  visible, satisfying the task's explicit "confirm gold is visible inside the
  shop overlay itself" requirement.
- Shop offer boxes (`_make_shop_offer_row()`) and reward-choice boxes
  (`_make_reward_choice_button()`) previously rendered with empty `text = ""`
  and tooltip-only detail (an `P2:R3` shop/layout decision). Both now also
  show a short always-visible two-line slot/tier caption via the new
  `_gear_box_label(gear) -> String` helper (e.g. "Weapon" / "Master"), styled
  through the existing `DATA_BUTTON_FONT`/`_style_shop_item_box()` convention
  since Press Start 2P would overflow these 88-112px boxes -- satisfying the
  "price or reward tier" and "slot" requirements without a hover. The fuller
  affix/comparison/price/afford-state detail stays in the tooltip
  (`_shop_offer_text()`/`_reward_choice_text()`), both of which now also
  explicitly print the tier name (shop offers previously omitted an explicit
  tier line; reward choices already had one from `P2:R4`).
- Added `_gear_upgrade_comparison_text(item, equipped) -> String`, a pure
  presentation-only helper comparing a candidate `GearItem`'s `affixes`
  against whatever is currently equipped in the same slot (read via the new
  local `_equipped_item_for_slot(slot)`, since `BuildState`'s own version of
  that lookup is private) -- P2:R7:T6's "whether the item can be equipped /
  is an upgrade" requirement. For each stat present on either item it diffs
  the authored `StatModifier` values (treating an absent stat as the
  operation's neutral baseline: `0.0` for `ADD`, `1.0` for `MULTIPLY`) and
  formats the result via the new `_format_stat_delta_vs_equipped()`, which
  mirrors `StatModifierFormatter.format()`'s existing per-stat display
  convention so a comparison line reads consistently with every other affix
  line in the UI (e.g. "+5% Attack Speed vs. equipped."). No `StatModifier`/
  `GearItem` math is reimplemented -- only the already-authored affix values
  are diffed, per `docs/Conventions.md`'s UI architecture principle. Both
  `_shop_offer_text()` and `_reward_choice_text()` now append this line
  (or "Upgrade -- slot is currently empty." / "Currently equipped." / "Same
  stats as equipped." for the respective edge cases).
- `_shop_offer_text()` also now appends an explicit afford/inventory-space/
  click hint ("Not enough gold." / "Inventory full -- can't buy." / "Click to
  buy.") and `_reward_choice_text()` appends "Click to choose." -- satisfying
  the "clear continue/back/confirm behavior" requirement's "no dead-end
  states" guidance: a player reading either tooltip is told exactly what
  clicking does or why it's blocked, not left to infer it from a disabled
  box alone. Unaffordable shop offers already read as visually muted from
  `P2:R7:T2` (`_style_shop_item_box()`'s existing darkened/disabled-border
  treatment); this pass additionally wires the box's font color through
  `UIColors.TEXT_NORMAL`/`UIColors.TEXT_DISABLED` per state, since the boxes
  previously carried no visible text at all and so had no font color to set.
- Route choice/tradeoff: added three small pure `ContractRouteNode -> `
  helpers -- `_route_pressure_score(node) -> float` (armor + poison
  resistance, weighted, ranking-only, not shown as an absolute number, using
  the same real `Monster` fields `enemy_panel.gd`'s `_build_pressure_text()`
  (`P2:R7:T5`) already reads), `_route_reward_tier_rank(node) -> int`
  (ranks a route reward's gear tier across both the `gear_choice_rewards`
  path Knives uses and the `generated_gear_tier` path every other route
  reward uses, returning `-1` for a gear-less reward like Vyra's), and
  `_route_tradeoff_text(node_a, node_b) -> String`, which composes both into
  a one-line comparative sentence (e.g. "Door Guard is the harder branch.
  Door Guard reward: Master -- Portly Cook reward: Basic."). All three are
  derived entirely from real `Monster`/`EncounterReward` data, not authored
  per-branch flavor text, matching the same discipline `P2:R7:T5` established
  for `_build_pressure_text()` -- a newly authored branch pair reads
  correctly with zero additional authoring. Verified against all three
  authored Gilded Serpent branch pairs (Door Guard/Portly Cook, Sleeping
  Henchman/Cloaked Watchmen, Lazy Henchman/Patrolling Guard) and confirmed
  each result agrees with the branch's own authored `difficulty_label`/
  `reward_quality_label` intent from `P2:R4`'s route table (e.g. Cloaked
  Watchmen correctly ranks as the harder, better-reward-tier branch, matching
  its authored "Dangerous Branch"/"Cursed Ring or Necklace" labels).
- `_contract_route_story_text()` now appends `_route_tradeoff_text()`'s
  sentence to the map's story text whenever the current route node has
  exactly two `next_nodes` (every branch point in the authored graph, not
  only the opener choice) -- satisfying the "route difficulty/reward
  tradeoff" requirement for the schematic map view (which was already
  showing per-branch HP/armor/reward-tier text on each node button from
  `P2:R4`/`P2:R5`'s font-legibility pass, but had no single sentence
  comparing the two side by side) and for the older two-button fallback path
  still exercised by some tests. Also generalized the base story sentence
  from "Choose the first route into The Gilded Serpent..." to "Choose your
  next route into The Gilded Serpent..." since this function is reused for
  every branch point, not only the first one -- a pre-existing minor wording
  gap noticed while reading the function, fixed as part of this pass since it
  sits directly in the text this task edits.
- Affixes (bullet 3) and slot (bullet 2) were already present and correct
  from `P2:R3`/`P2:R4` (`GearGenerator.SLOT_TAGS`, `StatModifierFormatter`)
  and required no changes beyond the tier-line addition and visible-caption
  work described above.
- Deliberately deferred: no changes to the contract-offer overlay, the
  secondary-subclass overlay's own tree-choice cards, or the victory/reward
  banner text formatting (`_reward_text()`) -- none of these are shop/route/
  reward-*choice* UI in this task's scope (contract offer and secondary
  subclass are separate `P2:R7:T1` reachable states without a price/tier/
  slot/affix/upgrade decision to communicate; the victory banner's reward
  line formatting is a single test-asserted contiguous string, and
  restructuring it was already explicitly deferred by `P2:R7:T2`'s notes to
  avoid drifting into `P2:R7:T7`'s recap scope). No new `UIColors` constants
  were added -- every color used above (`TEXT_GOLD`, `TEXT_NORMAL`,
  `TEXT_DISABLED`) already existed. No changes to
  `project/scripts/systems/` or `project/scripts/resources/` -- confirmed via
  `git diff --stat` (see Verification Notes).

2026-07-18 (P2:R7:T5 - Improve Enemy/Encounter Presentation):

- `project/scenes/combat/enemy_panel.gd`: added four small pure helpers
  following the same pattern as T3's `combat_screen.gd` lookups and T4's
  `_stat_delta_text()`/`_talent_lock_reason()` -- `_required_dps_text(enemy,
  window_ms)` (HP / fight-window-seconds, so the target's kill-speed
  requirement can be eyeballed against the resolved DPS shown in
  `character_stats_panel.gd` without mental math), `_reward_preview_text(reward)`
  (a compact one-line preview of the encounter/route node's authored
  `EncounterReward` -- gold, talent points, fixed/choice gear names,
  generated-gear tier via `GearGenerator.TIER_NAMES`, shop-unlock -- shown
  before the fight, not only through the existing post-fight
  `combat_screen.gd::_reward_text()` claim UI), and `_build_pressure_text(enemy)`
  (a one-line "why this target pressures certain builds" sentence). All four
  are pure `Monster`/`EncounterReward -> String` functions with no
  `BuildState` writes, reading only the existing `Monster.hp/armor/
  poison_resistance` and `EncounterReward` fields already defined in
  `project/scripts/resources/monster.gd`/`encounter_reward.gd` -- no new
  game-rule logic, per `docs/Conventions.md`'s UI architecture principle.
  `_refresh()`'s existing HP/Armor/Poison Resist/Window lines (already
  present from earlier milestones, confirmed via read-first per the task's
  instruction not to duplicate T3's header) are unchanged; Required DPS,
  Reward, and Pressure are appended as three new lines, and the empty-state
  `_empty_stats_text()` grew matching "NONE" lines for all three so the
  panel's line count stays constant across states.
- Two new named constants added directly in `enemy_panel.gd` (not
  `UIColors`, since they're display thresholds, not colors):
  `ARMOR_HIGH_THRESHOLD := 100` and `POISON_RESIST_HIGH_THRESHOLD := 0.25`.
  Chosen from real data rather than per-monster authoring: armor 100 sits
  above the current roster's common 0/20 baseline and corresponds to
  roughly 35%+ physical damage reduction under
  `Current_Mechanics_Reference.md`'s `armorReduction = 0.75*armor/(armor+100)`
  curve (the roster's armored monsters all use exactly 160, well above this
  line); poison resistance 0.25 matches `Balance_Baseline_Report.md`'s noted
  "25% to 40%" band deliberately used to pressure poison-heavy Thief/Shadow
  builds. `_build_pressure_text()` compares a monster's real
  `armor`/`poison_resistance` against these two thresholds and returns one
  of four sentences (armor+poison, armor-only, poison-only, or "no notable
  defensive pressure") -- entirely threshold-driven, so a newly authored
  monster is flagged automatically with zero additional authoring, matching
  the task's explicit "not hardcoded per-monster flavor text" requirement.
- No new `UIColors` constants were needed -- the existing poison-tinted
  bbcode wrapping on the Poison Resist line (from `P2:R7:T2`) was left
  untouched; the three new lines (Required DPS, Reward, Pressure) are plain
  text, matching the task's "avoid overexplaining with walls of text"
  guidance by staying terse rather than adding more color emphasis than the
  existing lines already carry.
- Confirmed via read-first that the Combat window (Window: Xs) was already
  displayed in this exact panel from an earlier milestone, and that
  `combat_screen.gd`'s T3 header "Target" field already names the current
  encounter/route node -- per the task's explicit instruction, neither was
  duplicated; this panel's own pre-existing "Target: <monster name>" line
  was left as-is (it already existed before T5 and reads live `BuildState`
  data, same reasoning T3's verification notes gave for not touching it).
- Deliberately deferred: no comparison against the player's own resolved DPS
  was added to this panel (e.g. a "you need +X DPS" delta) -- the task asks
  for a Required DPS figure the player can compare "without doing mental
  math" against the DPS already shown in `character_stats_panel.gd`, not a
  cross-panel computed delta, and adding one would pull `BuildResolver`/
  `CombatResolver` math into a presentation panel that today only reads
  `Monster`/`EncounterReward` fields. No walls of text: the pressure line is
  capped at one sentence with four fixed outcomes rather than an
  auto-generated multi-clause explanation. No new gear/reward-choice
  interaction was added to this panel (choosing among `gear_choice_rewards`
  before a fight, etc.) -- that is `P2:R7:T6`'s scope, not T5's; this panel
  only previews the reward, it does not let the player act on it early.

2026-07-18 (P2:R7:T4 - Improve Build Panels):

- `project/scenes/combat/talent_panel.gd`: added `_talent_lock_reason(talent)
  -> String`, a pure helper reading `PassiveAllocator`/`BuildState` directly
  (no new game-rule logic) that explains *why* an unavailable talent is
  locked -- not in an active subclass tree, a specific unmet OR-group
  prerequisite (named, e.g. "Requires Practiced Rhythm"), or an insufficient
  point budget ("Needs N points (M available)"). `_build_node()` now shows
  this as a small always-visible caption under the talent name (colored
  `UIColors.TEXT_WARNING`, only rendered for unavailable talents) in addition
  to appending it to the existing hover tooltip via `_talent_tooltip()`'s new
  optional `lock_reason` parameter -- both were already presentation-only
  reads of the same `PassiveAllocator.prerequisites_satisfied()`/
  `points_spent()` functions the enable/disable check itself uses, so the
  reason text can't drift from the actual rule. Also reformatted the
  points-budget footer from the pre-T4 "remaining/earned" `%d/%d` string to
  an explicit "Points Spent: spent/earned" readout that counts *up* as
  points are spent, matching the task's "X/Y points spent" wording; this
  required updating two exact-string assertions in
  `project/tests/combat_screen_test.gd` (was `"0/0"`/`"0/1"`, now
  `"Points Spent: 0/0"`/`"Points Spent: 1/1"`).
- `project/scenes/combat/available_skills_panel.gd`: added
  `_skill_effect_summary(skill) -> String`, a pure helper that reads a
  skill's own `SkillEffect` resources (`PhysicalDamageEffect`,
  `PoisonDamageEffect`, `ArmorReductionEffect`,
  `PoisonResistanceReductionEffect`, `StackScalingPhysicalDamageEffect`) and
  formats a short comma-joined summary (e.g. "18 physical dmg"). This is now
  shown as an always-visible caption Label under each skill button (not just
  on hover) and is also reused as the tail of the existing hover tooltip via
  `_tooltip_for()`, so the two text sources can never drift apart. Each
  skill's clickable content changed from a bare `Button` child of
  `_skills_box` to a `VBoxContainer` (button + summary label); `_refresh()`
  had to be updated to force the *current* lock-disabled state onto any
  stale (`queue_free()`'d but not yet removed) child's inner button before
  freeing it, restoring behavior an earlier version of `_refresh()` already
  relied on for same-frame rapid signal chains (see Verification Notes for
  the hang this caused when first missed).
- `project/scenes/combat/skill_build_panel.gd`: each rotation slot now
  carries two small overlay badges (`mouse_filter = MOUSE_FILTER_IGNORE`,
  positioned via anchors so they don't intercept clicks, same overlay
  pattern already used elsewhere for the first-letter accent color) -- a
  cast-order number (top-left, `UIColors.TEXT_DISABLED`) making the
  left-to-right rotation order explicit rather than only positionally
  implied, and an explicit "x" remove badge (top-right,
  `UIColors.TEXT_WARNING`, hidden while the build is locked) so removing a
  skill reads as a discoverable UI action rather than only "click anywhere
  on the slot and hope." The whole slot still removes on click (unchanged,
  backward compatible), the badge is additive affordance, not a new control
  path. The tooltip was also expanded to state cast position ("cast position
  1 of 3") and both removal routes.
- `project/scenes/combat/character_stats_panel.gd`: added
  `_stat_delta_text(delta, suffix, one_decimal) -> String`, a pure formatter
  appending a trailing " (+N from gear/talents)" note to a stat line.
  `_refresh()` now calls `BuildResolver.resolve_stats()` a *second* time with
  empty trees/talents/gear as the class-only baseline, purely for comparison
  -- this is presentation-only (a second call to an existing pure system
  function, not new combat math in the panel script, per
  `docs/Conventions.md`'s UI architecture principle) and cheap since it's a
  small in-memory resource walk with no I/O. Every resolved stat line
  (Physical Damage, Attack Speed, Crit Chance, Crit Multiplier, Bonus Armor
  Shred, Poison Damage, Bonus Poison Stacks) now shows this delta note
  whenever the gear/talent-modified value differs from the class baseline by
  more than a small epsilon (0.05), so a player can trace why a stat moved
  without the delta note cluttering lines that haven't changed.
- `project/scenes/combat/gear_panel.gd`: equipped slots now render with a
  thicker, accent-colored border (`CardStyle.ACCENT_COLOR`, 3px) distinct
  from both empty slots and inventory items (which keep the neutral
  `SLOT_BORDER_COLOR`, 2px) -- "worn" now reads as visually distinct from
  "in the bag" beyond just the pre-existing "Equipment"/"Inventory" section
  labels. Tooltips were split into `_equipped_tooltip()` and
  `_inventory_tooltip()` (previously both reused the same
  `_gear_tooltip()` output with an ad hoc suffix), each stating which state
  the item is in and what clicking it does. Also closed a real UX gap found
  while reading the panel: outside a shop round, clicking an equipped slot
  was previously a no-op -- the only way to bench an equipped item was to
  equip a *different* item over it (which silently pushed the old one back
  to inventory via `BuildState.equip()`'s existing replace logic). Clicking
  an equipped slot now explicitly calls the existing `BuildState.unequip()`
  (no new game-rule logic added; this method already existed and was only
  reachable from the dormant `project/scenes/tavern/shop.gd` scene) when
  outside a shop round, unlocked, and the inventory has a free slot --
  making "send it back to the bag" its own discoverable action distinct
  from "buy a replacement," matching the task's equip/unequip clarity
  requirement.
- Deliberately deferred: no new `UIColors` constants were added -- every
  color used above (`TEXT_WARNING`, `TEXT_DISABLED`, `ACCENT`) already
  existed from `P2:R7:T2`. No new `BuildState` getters were needed either;
  every helper above reads existing `BuildState`/`PassiveAllocator`/
  `BuildResolver` surface. Did not touch `enemy_panel.gd` (T5 scope) or
  `combat_screen.gd`'s header (T3 scope, already complete). Did not build a
  drag-and-drop equip/reorder interaction for gear or rotation -- click-based
  equip/unequip/add/remove stays consistent with every other panel's existing
  interaction model, and drag-and-drop is a heavier interaction-design change
  than "make the existing actions discoverable," which is what this task
  asked for. Did not add a "reset to base" or side-by-side before/after
  comparison view for stats -- the inline delta note satisfies "trace why a
  stat moved" without a second display mode.

2026-07-18 (P2:R7:T3 - Improve Run Header/Status):

- Added an always-visible status bar in `project/scenes/combat/combat_screen.gd`,
  inserted into `root_vbox` between the existing top bar (Map/Save & Quit/
  Abandon Run) and the three-column HUD body. It replaces the previous
  bare top-bar `_seed_label` with a fuller row -- Phase, Target (current
  encounter/route node), Build (locked/unlocked), and Seed on the left,
  Gold on the right -- plus a prominent accent-colored "Next" line below it
  for the new next-expected-action text. Styled entirely through the
  existing `CardStyle.make_stylebox()`/`UIColors` constants from `P2:R7:T2`
  (`UIColors.TEXT_GOLD` for the gold label, `CardStyle.ACCENT_COLOR` for the
  next-action line) -- no new hardcoded colors were introduced.
- No new `BuildState` fields or getters were added. Every header field reads
  existing `BuildState` surface: `run_phase`, `run_outcome`,
  `shop_round_pending`, `has_pending_reward_choice()`,
  `needs_secondary_subclass_choice()`, `needs_tavern_map_choice()`,
  `is_contract_fight_active()`, `active_contract`, `current_route_node`,
  `current_encounter()`, `build_locked`, `can_start_current_fight()`,
  `adventure_seed`, and `gold` -- all of it already existed from
  `P2:R5`/`P2:R6`, confirming the doc's expectation that this task is a
  presentation-only pass.
- Added four small pure `BuildState -> String` lookup functions to
  `combat_screen.gd`, following the same established pattern as
  `_tavern_story_text()`/`_contract_route_story_text()`/
  `_apply_outcome_presentation()`: `_run_phase_text()` (phase label),
  `_current_node_text()` (current encounter/route target, falling back to
  `"NONE"` to match `enemy_panel.gd`'s existing empty-state wording),
  `_build_lock_text()` (`"Locked"`/`"Unlocked"`), and `_next_action_text()`
  (the new "what should the player do right now" instruction line). Both
  `_run_phase_text()` and `_next_action_text()` check `shop_round_pending` /
  `has_pending_reward_choice()` / `needs_secondary_subclass_choice()` before
  falling back to a `match` over `run_phase`, since those three overlay
  states don't change `run_phase` themselves (see
  `BuildState.open_shop_round()`/`claim_current_reward()`/
  `choose_secondary_tree()`) but are what the player actually sees on
  screen.
- `_current_node_text()` keys off `BuildState.active_contract != null`
  rather than `run_phase`, so the header keeps showing the last-fought route
  node (e.g. Vyra) through a terminal `RUN_ENDED` state after contract
  victory or contract failure, not just during `CONTRACT_OFFER`/
  `CONTRACT_ROUTE`/an active contract fight.
- A single `_update_header_status()` refreshes all five header fields at
  once and is wired to every signal the dashboard already listens to
  (`BuildState.build_changed`, `BuildState.run_state_changed`, and the
  newly-connected `BuildState.lock_changed`) plus an initial call at the end
  of `_ready()`, so no individual click handler needed a new call site --
  the header updates automatically wherever the rest of the dashboard
  already does.
- Deliberately deferred: no new state/plumbing was added for a distinct
  "FIGHTING" header display, since `BuildState.run_phase` only equals
  `FIGHTING` for the duration of a single synchronous
  `CombatResolver.resolve()` call inside `_on_fight_pressed()` (documented
  at `P2:R6:T6`) -- there's no frame in which a player could see it, so
  `_next_action_text()`'s `"Fighting..."` branch and `_run_phase_text()`'s
  `"Fighting"` branch are defensive/complete-for-testability rather than
  something reachable through real play. Also deferred: no changes to
  `enemy_panel.gd`'s own `"Target: ..."` line or `gear_panel.gd`'s own
  `"Gold: ..."` line -- both already read live `BuildState` data and are
  part of the persistent dashboard (not the shop overlay), so the R7:T3
  scope note about gold "not just inside the shop overlay" was already
  satisfied before this task; the header's own Gold field is additive for a
  single always-visible glance, not a replacement for the gear panel's.

2026-07-17 (P2:R7:T2 - Apply Visual Style Foundations):

- Resolved the palette fork: adopted the master palette (warm browns) over
  the darker style-guide-mockup alternative, per explicit user direction
  after a side-by-side comparison. Copied
  `F:\Data\Junk\DPS Game\The_Road_to_Peak_Deeps_Master_Palette.md` into
  `docs/The_Road_to_Peak_Deeps_Master_Palette.md` with a note recording the
  resolution, so the repo owns its own source of truth.
- Downloaded the four OFL Google Fonts (Pirata One, MedievalSharp, Press
  Start 2P, VT323) as TTFs plus their `OFL.txt` license files directly from
  the `google/fonts` GitHub mirror, and committed them to
  `project/assets/fonts/`.
- Added `project/scripts/ui/ui_colors.gd` (`class_name UIColors`): the ten
  palette constants from the master palette's "UI" table (Background,
  Panel, Panel Highlight, Panel Border, Normal/Disabled/Warning/Magic/
  Poison/Gold text), plus semantic extensions added during the cleanup pass
  below (`ACCENT`, `OVERLAY_BACKDROP`, `PANEL_DEEP`, `PANEL_DISABLED`,
  `STRUCTURE_LINE`/`STRUCTURE_LINE_LIGHT`, `MAP_NODE_CURRENT`/
  `MAP_NODE_INACTIVE`, `TIER_BASIC`/`TIER_MASTER`/`TIER_CURSED`/
  `TIER_LEGENDARY`, `SLOT_EMPTY`/`SLOT_BORDER`, `OUTCOME_LOSS`) so every ad
  hoc `Color()` literal found in the cleanup pass has a named home.
- Rewrote `project/scripts/ui/card_style.gd`'s `make_stylebox()` and
  `ACCENT_COLOR` to read from `UIColors` instead of hardcoded RGB floats.
  Because all nine screens/panels already route through `CardStyle`, this
  one edit restyled every card/panel in the active flow.
- Built `project/assets/ui_theme.tres` via a one-shot builder script
  (`project/scripts/tools/build_ui_theme.gd`, run once with
  `godot --headless -s res://scripts/tools/build_ui_theme.gd` -- kept in
  the repo as reusable tooling for future palette/font retunes rather than
  a throwaway script). The theme sets: default font VT323 (size 18) for
  the whole tree; a `PanelHeader` Label type variation (MedievalSharp,
  size 22, `UIColors.ACCENT` color) applied to every panel/section header
  across the dashboard, class/subclass select, and title screen; a
  `TitleHeading` Label type variation (Pirata One, size 48) used only for
  the title screen's main heading; a `Button` type styled with Press Start
  2P (size 12) and normal/hover/pressed/disabled/focus `StyleBoxFlat`s
  built from `UIColors`, with generous content margins since Press Start
  2P runs wide; and `Panel`/`PanelContainer` default styleboxes matching
  `CardStyle.make_stylebox()` so any bare panel not explicitly styled still
  matches. Registered project-wide via `gui/theme/custom` in
  `project/project.godot`.
- Cleanup pass: re-grepped `project/scenes/` and `project/scripts/ui/` for
  `Color(` literals (the style notes doc's audit list was from before
  R5/R6 landed and needed a refresh) and replaced every bypass color with a
  named `UIColors` constant, in `combat_screen.gd` (overlay backdrop,
  `CONTRACT_LINE_COLOR`, map/contract-route node and connector colors, the
  shopkeeper panel fill, per-button font color overrides, shop-offer tier
  colors, secondary-subclass-tree option panel fill), `talent_panel.gd`
  (connector color, talent-circle fill/outline), and `gear_panel.gd` (empty
  slot fill/border, gear tier colors, inventory tray fill).
- Applied semantic text colors where mechanics show through: gold text on
  `gear_panel.gd`'s gold label; poison text on `character_stats_panel.gd`'s
  poison-damage/poison-stack lines and `enemy_panel.gd`'s Poison Resist
  line (both panels converted from `Label` to `RichTextLabel` with
  `bbcode_enabled = true` so only those specific lines carry color, wrapped
  whole-line so existing test substring checks like
  `.text.contains("Poison Damage: 8.0/tick")` still match inside the
  bbcode tags); disabled text on locked talent names
  (`talent_panel.gd::_build_node`) in addition to the pre-existing
  modulate-alpha dimming; a visibly muted (darkened + disabled-colored
  border) disabled stylebox on unaffordable shop offers
  (`combat_screen.gd::_style_shop_item_box`), distinct from the normal tier
  color instead of reusing it. Warning/loss and victory/accent colors were
  already wired by `P2:R5:T8`'s `_apply_outcome_presentation()`
  (`OUTCOME_LOSS_COLOR`, `CardStyle.ACCENT_COLOR`) -- left that function's
  logic untouched and pointed its constants at `UIColors` instead of
  duplicating a second color system, per this task's explicit guidance.
- Legibility pass: map/contract-route/secondary-tree buttons carry
  multi-line, fixed-size, data-dense text (stats, difficulty, reward tags,
  intrinsic descriptions) rather than a short action label, so they
  override the theme's default Press Start 2P button font back to VT323
  (via the new `DATA_BUTTON_FONT` constant in `combat_screen.gd`) at a
  readable size instead of clipping/overflowing their fixed
  `custom_minimum_size` boxes. Short action buttons (Fight, Lock/Unlock,
  Map, Save & Quit, Retry Encounter, etc.) keep the default Press Start 2P
  and were checked to auto-size correctly since none of them use a fixed
  minimum width.
- Deliberately deferred: per-line semantic coloring inside composite
  sentences that tests check as one contiguous substring (e.g.
  `combat_screen.gd`'s `_reward_text()`, which interpolates gold amounts
  into "Rewards: 12g, 1 talent point." as a single formatted string) --
  inserting bbcode tags mid-sentence there would have split those
  test-asserted substrings. Left as plain text rather than restructuring
  `CombatRecap`/reward-text formatting, which would drift into `P2:R7:T7`'s
  scope. The dormant `project/scenes/tavern/shop.gd` and
  `project/scenes/build_planner/run_end.gd` scenes (unreachable in the
  current active flow per the `P2:R7:T1` audit) were left untouched --
  they have no `Color()` literals to clean up, and the project-wide Theme
  still cascades basic palette/font styling to them for free.

2026-07-17 (pre-R7 planning):

- Added `P2:R7:T2 - Apply Visual Style Foundations` and renumbered the
  later tasks (previously T2-T9, now T3-T10). No other doc referenced the
  old R7 task IDs, so the renumbering is safe.
- Created `docs/Phase_2_R7_Style_Implementation_Notes.md` holding the
  palette tables, the four-role font system (including the "Pirate Knight"
  to Pirata One correction and OFL license verification), the current-code
  audit (`CardStyle` centralization, bypass-color list in
  `combat_screen.gd`), and the phased implementation plan.
- One decision is deliberately left open for R7 start: the palette fork
  between the warm master palette doc and the darker style guide mockup.

2026-07-19 (retry-exception correction: first encounter, not Vyra):

The "combat playback adjustment round 2 + retry bug" pass above
misunderstood the user's unlimited-retry request and implemented it against
Vyra, the Gilded Serpent contract's boss fight. The user clarified the
exception was always meant for the FIRST encounter of the Adventure (the
opening Tavern encounter, Mouthy Drunk, encounter index 0) so new players get
more leeway right at the very start of the game, not at the endgame boss.

- Renamed/retargeted `BuildState.is_vyra_boss_fight()` to
  `is_unlimited_retry_encounter()`, now checking
  `not is_contract_fight_active() and current_encounter_index == 0` instead
  of the Vyra route node id. `finish_fight()`'s loss branch now calls this
  new check ahead of the existing `is_contract_fight_active()`/
  `failure_count_for_current_encounter()` logic, so a loss on the first
  Tavern encounter always resolves to `RunOutcome.FIGHT_LOSS_RETRY`
  regardless of failure count, exactly as the Vyra check used to do for
  Vyra.
- Vyra is restored to the standard contract-route rule: since Vyra is a
  contract route node, `finish_fight()` now follows the same one-retry path as
  every other route node. The first loss resolves to
  `RunOutcome.FIGHT_LOSS_RETRY`; the second loss resolves to
  `RunOutcome.CONTRACT_FAILED`.
- `combat_screen.gd`'s `_apply_outcome_presentation()` Vyra-aware status text
  branch (`"Vyra can be retried as many times..."`) is now a first-encounter-
  aware branch instead (`"You can retry as many times as you need..."`),
  gated on `BuildState.is_unlimited_retry_encounter()`.
- `run_failure_state_test.gd` was updated: the "Vyra losses grant unlimited
  retries" block (5 consecutive Vyra losses/retries) was replaced with an
  equivalent block against encounter index 0 (5 consecutive first-encounter
  losses, all `FIGHT_LOSS_RETRY`/retry-available, never
  `ADVENTURE_RESTART_REQUIRED`). A new block wins the first encounter and
  advances to encounter index 1 to add a non-first-Tavern-encounter control
  case (standard one-do-over-then-`ADVENTURE_RESTART_REQUIRED` rule). The old
  Vyra-unlimited-retry block was replaced with a Vyra control case confirming
  the restored standard rule (single loss immediately `CONTRACT_FAILED`, no
  do-over), alongside the existing non-Vyra Portly Cook control case.
- **Files changed:** `project/scripts/autoload/build_state.gd`
  (`is_vyra_boss_fight()` renamed/retargeted to
  `is_unlimited_retry_encounter()`, `finish_fight()`'s loss branch updated,
  `retry_current_encounter()`'s comment corrected), `project/scenes/combat/
  combat_screen.gd` (status text branch retargeted from Vyra to
  `is_unlimited_retry_encounter()`), `project/tests/run_failure_state_test.gd`
  (Vyra-unlimited-retry block replaced with first-encounter block, new
  second-Tavern-encounter control block, Vyra block retargeted to a standard-
  rule control case), `docs/Phase_2_R5_Run_Rules_And_Determinism.md` (revision
  note corrected), this doc. No changes to `project/scripts/systems/` or
  `project/scripts/resources/` (confirmed empty `git diff --stat`, see
  Verification Notes).

## Outstanding Visual Judgment Calls (consolidated at P2:R7:T9/T10 closeout)

Every item below was flagged across some prior R7 dated entry as a pixel/feel
judgment call that this sandboxed environment cannot render or click through
to verify (no GUI automation for native Godot windows has been available at
any point in `P2:R7`). None could be resolved by a headless test or code
read at closeout, so none are guessed at here -- this list exists so the next
real editor/player session has one place to check off, instead of re-reading
every dated entry above. Each item names the file/constant to adjust if a fix
turns out to be needed.

**Layout fit at 1600x900 (the highest-priority group -- this is the one
Exit Criteria bullet T9 could not independently confirm):**
1. Whether the consolidated top bar (Phase/Build/Seed/Next plus Map/Save &
   Quit/Abandon Run) reads as crowded at 1600px width, and whether
   `_next_action_label`'s `clip_text` ever actually triggers on a real long
   "Next:" string. (`combat_screen.gd`)
2. Whether the enemy panel's seven stacked info lines (HP/Armor/Poison
   Resist/Window/Required DPS/Reward/Pressure) still fit
   `PANEL_MIN_HEIGHT := 190` without clipping. (`enemy_panel.gd`)
3. Whether the win recap's now-longer text (up to 7 lines) still fits inside
   `_victory_overlay`'s `CenterContainer` without awkward growth, and
   whether the inline loss recap reads as a coherent block rather than
   crowding the loss state's retry/restart controls. (`combat_screen.gd`)
4. Whether the "(needed N)" / "(needed N.N)" parenthetical suffixes on the
   recap's Total Damage/DPS lines read clearly or as clutter.
   (`combat_screen.gd`)
5. Whether two 280px secondary-subclass selection cards fit comfortably
   inside the chooser modal without uneven card heights between trees with
   different intrinsic-text lengths (e.g. Assassin vs. Shadow).
   (`CardStyle.make_selection_card()`)
6. Whether the slot/tier caption is legible inside the tighter 88px shop/
   inventory boxes the same way it reads in the larger 112px reward-choice
   boxes. (`CardStyle.gear_box_label()`/`style_gear_box_caption()`)
7. Whether the talent lock-reason caption wraps acceptably without crowding
   neighboring talent nodes, and whether the skill effect-summary caption
   reads cleanly under narrower skill buttons. (`talent_panel.gd`,
   `available_skills_panel.gd`)
8. Whether the rotation slot's corner badges (cast-order number, "x" remove)
   are legible at actual pixel size, and whether the equipped-slot
   accent-border is visually obvious at a glance vs. only structurally
   distinct. (`skill_build_panel.gd`, `gear_panel.gd`)
9. Whether the reordered title menu (Training Room, Adventure Mode, Continue,
   Exit) and the grayed-out disabled Resume/Training Room states read
   correctly. (`title.gd`)
10. The two existing `ConfirmationDialog`s' (Abandon Run, New Game-with-
    existing-save) on-screen legibility/centering were only read, never
    rebuilt or pixel-checked, during `P2:R7`.

**Gear-comparison tooltip:**
11. Whether the two-box "This Item" / "Equipped" tooltip actually reads as
    two normal-sized tooltips side by side at real cursor position and pixel
    size (reasoned at roughly 380-540px wide by 100-140px tall, not
    measured). (`combat_screen.gd`'s `GearCompareButton`/
    `_build_gear_compare_tooltip()`)

**Combat playback and comic-book popups (the largest single group, since
none of this animation work could be visually verified at all):**
12. Whether the button fill's contrast (`UIColors.BUTTON_FILL` = Gold Shadow
    `#9C6A21`) reads as clearly "clickable" against the warm-brown
    `PANEL`/`PANEL_HIGHLIGHT` backdrop at real in-game lighting (reasoned via
    WCAG contrast math to ~3.67:1, not rendered).
13. Whether "SkillName -N" / "SkillName -N!" popup text overflows its
    jittered spawn band at `POPUP_FONT_SIZE`/`POPUP_CRIT_FONT_SIZE` (26/34pt
    Pirata One) now that damage numbers were appended to the skill name.
14. Whether the 0.75s outcome-reveal delay
    (`PLAYBACK_OUTCOME_REVEAL_DELAY_SEC`) is the right length -- too short
    risks a popup still visibly fading when the outcome reveals; too long
    feels sluggish.
15. Whether a fast win's full-window "overkill" playback (no early exit since
    round 1) drags on too long before the reveal on a short kill inside a
    much longer authored window.
16. Whether the 0.15s/0.3s HP tweens (`PLAYBACK_HP_TWEEN_SEC`/
    `PLAYBACK_TICK_HP_TWEEN_SEC`) read as punchy "chunks" at real frame
    rates, and whether the softer poison-tick tween visibly distinguishes
    itself.
17. Popup sizing/motion overall: the 48px rise, 0.9s lifetime, crit
    punch-scale (1.35x/0.12s), and whether the jitter ranges
    (`POPUP_JITTER_X_PX`/`POPUP_JITTER_Y_PX`) actually prevent pile-ups
    during fast rotations.
18. Whether the popup spawn band (55% panel height, 96px top margin) sits
    well between the HUD and the skill strips, and whether the active-popup
    caps (`POPUP_MAX_ACTIVE` 10 / `POPUP_MAX_TICK_ACTIVE` 3) are too tight or
    loose in long fights.
19. Whether 1x pacing feels right for a 12-30s window, and whether the
    elapsed/window text readout ("12.0s / 30s") is legible enough or should
    become a thin time bar.
20. Whether the "Phase: Fighting" header freeze plus hidden status line reads
    as intentional tension rather than the UI going quiet.

**Enemy HUD:**
21. Whether ~80px of HUD at the top of the Combat panel leaves enough clear
    black center for future animation art, and whether top-edge anchoring is
    the right choice at all.
22. Health bar height (14px) and the reserved 16px status-chip row height --
    whether the bar should stretch the panel's full inner width or be
    capped.
23. Whether the crimson `HEALTH_BAR_FILL` (`#9E3535`) reads well against the
    near-black `PANEL_DEEP` fill at real pixel size.
24. Whether the HUD staying visible (empty bar) behind/above the victory
    overlay reads as intentional, and whether the plain colored status chips
    are enough or should become small bordered chips.
25. The info line's single-line " | "-separated format vs. a small boxed
    multi-line readout -- chosen for compactness, easy to re-shape on
    feedback.

None of the 25 items above block the milestone close-out; they are first-draft
presentation judgment calls, each independently tunable via the named
constant/file, not open bugs. Resolving them is expected next-session editor
work, not required before `P2:R7` is marked complete.

## Verification Notes

2026-07-19 (P2:R7:T9/T10 closeout -- full regression suite, all 27
`project/tests/*.gd` files):

- Listed every test file: `ls project/tests/*.gd` (27 files, confirmed
  against `Glob` output). Ran all 27 serially, each with a distinct
  `--log-file`:
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless
  --path project --log-file user://logs/t9b_<name>.log -s
  res://tests/<name>.gd`.
- First full run (before this pass's two test fixes) surfaced the two real
  regressions described in the Implementation Notes entry above:
  `dashboard_header_test.gd` printed `ERROR: Expected run-failed phase text,
  got: Phase: Fight Result` / `ERROR: Expected restart next action, got:
  Next: Adjust your build, then retry the fight.` (a normal, non-hanging
  failure, since that file already uses the deferred-`_failed` `_require()`
  idiom) and `inventory_model_test.gd` hung indefinitely on a bare failed
  `assert()` with no diagnosable output (the known bare-`assert()`-never-
  reaches-`quit()` trap) -- confirmed via `Get-Process`/`tasklist` showing
  stale `Godot_v4.7-stable_win64_console.exe`/`Godot_v4.7-stable_win64.exe`
  processes still running well after the run should have returned; killed
  with `Stop-Process -Force`, confirmed zero Godot processes remained before
  rerunning.
- Root-caused both to the same gap: the 2026-07-19 "retry-exception
  correction" entry (elsewhere in this doc) retargeted the unlimited-retry
  exemption from Vyra to `current_encounter_index == 0` and updated
  `run_failure_state_test.gd` accordingly, but missed these two other test
  files, which also drive two consecutive losses at the (fresh-reset)
  default `current_encounter_index == 0` expecting the old
  `ADVENTURE_RESTART_REQUIRED`/no-retry behavior. Grepped every test file in
  `project/tests/` for `ADVENTURE_RESTART_REQUIRED`/`"Run Failed"`/`"Restart
  your Adventure"` to confirm no other file has the same latent gap --
  three matches total: the now-fixed `dashboard_header_test.gd`, the
  already-correct `run_failure_state_test.gd`, and
  `run_outcome_presentation_test.gd` (drives `_apply_outcome_presentation()`
  directly with a hardcoded `RunOutcome` enum value, never through real
  `finish_fight()` calls, so it was never exposed to this gap in the first
  place).
- Fixed both test files (see Implementation Notes for the exact changes),
  reran the full 27-file suite clean, and additionally grepped each of the
  two fixed files' resulting log for its actual pass content rather than
  trusting exit code 0 alone:
  - `t9b_dashboard_header_test.log`: prints "first loss on the second Tavern
    encounter shows retry next action", "second Tavern loss (on the second,
    non-first encounter) requires an Adventure restart", and "Dashboard
    header check: OK".
  - `t9b_inventory_model_test.log`: prints "retries are available after the
    first encounter failure" through to "Inventory model check: OK" with no
    `ERROR`/`SCRIPT ERROR` lines anywhere in the log.
- **Final result: 27/27 test files pass**, each verified by exit code 0 AND
  by grepping its log for `SCRIPT ERROR`/`ERROR: Expected`/`Assertion failed`
  (none found in the clean rerun) plus spot-checking several logs' actual
  tail content directly (`combat_test.gd`'s "Result: WIN" summary block,
  `save_load_test.gd`'s "Save/load round trip check: OK" alongside its
  expected/handled corrupt-save JSON-parse error print, `dashboard_header_test.gd`/
  `inventory_model_test.gd` as detailed above). Full pass list: `build_panels_test`,
  `combat_hud_test`, `combat_playback_test`, `combat_recap_test`,
  `combat_screen_test`, `combat_test`, `contract_offer_flow_test`,
  `contract_route_data_test`, `dashboard_header_test`,
  `deterministic_replay_test`, `encounter_reward_test`, `enemy_panel_test`,
  `engine_mechanics_test`, `gear_generator_test`, `inventory_model_test`,
  `legendary_reward_test`, `opportunity_strikes_test`,
  `passive_allocator_test`, `reward_shop_route_ui_test`,
  `route_reward_choice_ui_test`, `run_failure_state_test`,
  `run_outcome_presentation_test`, `run_rng_context_test`,
  `run_seed_state_test`, `save_load_test`, `save_load_ui_test`,
  `shadow_parity_test`.
- No stale Godot processes remained after the clean rerun (`tasklist`
  checked before and after).
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty both before and after this pass's two test fixes --
  confirmed via direct command, not assumed. The only files this closeout
  pass changed are `project/tests/dashboard_header_test.gd` and
  `project/tests/inventory_model_test.gd`; `combat_screen.gd` itself was read
  in full for Part D's structural check but not edited (no dead code, no
  TODO/FIXME markers, and no duplicate logic worth extracting were found --
  see the Implementation Notes entry for the specific greps run).
- Manual Godot editor/player click-through was **not** performed -- the same
  standing sandbox limitation as every prior `P2:R7` entry, carried forward
  explicitly rather than silently. See "## Outstanding Visual Judgment
  Calls" above for the full consolidated list this leaves open.

2026-07-19 (combat playback adjustment round 3 + item 4 investigation):

- No new `class_name` was added this pass (the `Skill.speed_label` schema
  addition was tried and reverted, see the Implementation Notes entry above),
  so no editor class-cache rescan was needed.
- `git diff --stat -- project/scripts/systems project/scripts/resources`:
  empty, both before and after the revert -- confirms items 1-3 stayed
  presentation-layer-only and item 4 made no code change at all.
- Ran the full requested suite serially, each with its own `--log-file`,
  using `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless
  --path project --log-file user://logs/<name>.log -s
  res://tests/<test>.gd`:
  - `combat_playback_test.gd` -- exit 0, "Combat playback check: OK".
  - `combat_screen_test.gd` -- exit 0, "P2 UI restructure end-to-end check:
    OK" (first run caught the expected `"Physical Damage: +0%"` assertion
    failure at line 217 pre-dating item 2's fix; updated the assertion to
    `"Physical Damage: 0%"` and reran clean, plus the same fix at the
    second `"Physical Damage: +8%"` assertion later in the file).
  - `combat_hud_test.gd` -- exit 0, "Combat HUD check: OK".
  - `build_panels_test.gd` -- exit 0, "P2:R7:T4 build panels test passed."
    (same class of pre-existing `+8%` assertions updated, 3 call sites; the
    unrelated `_stat_delta_text(8.0, "%")` default-signature check at the
    end of that block was left as-is since it tests the helper's own
    default, not the Physical Damage line).
  - `gear_generator_test.gd` -- exit 0, "GearGenerator tier structure check:
    OK".
  - `legendary_reward_test.gd` -- exit 0, "Legendary reward check: OK".
  - `reward_shop_route_ui_test.gd` -- exit 0, "Reward/shop/route UI check:
    OK" (prints the exact "Door Guard reward: Master -- Portly Cook reward:
    Basic" / "Sleeping Henchman reward: Basic -- Cloaked Watchmen reward:
    Cursed" tradeoff text quoted in the item-4 findings above).
  - `contract_route_data_test.gd` -- exit 0, "Contract route data check: OK"
    (prints both route walks: "Portly Cook -> Lazy Henchman -> Knives ->
    Vyra" and "Door Guard -> Cloaked Watchmen -> Knives -> Vyra").
  - `engine_mechanics_test.gd` -- exit 0, "P2:M5 T0 engine mechanics check:
    OK".
  - `combat_test.gd` -- exit 0, "Result: WIN" summary printed, no assertion
    failures.
- All ten runs printed Godot's benign end-of-process `WARNING: N ObjectDB
  instances were leaked at exit`/`ERROR: N resources still in use at exit`
  noise (pre-existing across this whole test suite, unrelated to this
  change) but no `SCRIPT ERROR`/`ERROR: Assertion failed` after the two
  test-file updates above.

2026-07-19 (combat playback adjustment round 2 + retry bug):

- No new `class_name` was added this pass, so no editor class-cache rescan
  was needed. `project/scripts/tools/build_ui_theme.gd` was re-run
  (`Godot_v4.7-stable_win64_console.exe --headless --path project -s
  res://scripts/tools/build_ui_theme.gd`, exit 0, printed
  "Saved res://assets/ui_theme.tres") to regenerate `ui_theme.tres` after
  `UIColors.BUTTON_FILL`/`BUTTON_FILL_PRESSED`'s value swap.
- **Item 1 (button contrast) -- reasoned via WCAG relative-luminance math,
  not pixel-verified (no GUI automation in this sandbox):** for each color
  `c` in sRGB, linearized channel `c_lin = (c<=0.03928) ? c/12.92 :
  ((c+0.055)/1.055)^2.4`, luminance `L = 0.2126*R_lin + 0.7152*G_lin +
  0.0722*B_lin`, contrast ratio `(L_lighter+0.05)/(L_darker+0.05)`.
  `TEXT_NORMAL` (`#F4E2C4`) -> `L ~= 0.776`.
  - Round 1's normal fill, Gold Mid `#C89433` -> `L ~= 0.336` ->
    **~2.14:1 against TEXT_NORMAL** -- below the 3:1 floor WCAG recommends
    for large/UI-component text. This is the state the user meant by
    "active" -- the button's default, at-rest, "this is live and clickable"
    appearance, seen for nearly all of a session (Godot's `pressed`
    stylebox only applies for the instant the mouse is held down; no button
    in this project uses `toggle_mode`, confirmed by grep, so it's never a
    persistent "activated" state the way the speed-strip's `disabled`
    styling is).
  - Round 1's pressed fill, Gold Shadow `#9C6A21` -> `L ~= 0.175` -> ~3.67:1
    against TEXT_NORMAL -- already better than the normal fill, ruling out
    "pressed" as the actual offender.
  - Hover fill (unchanged), `PANEL_HIGHLIGHT` `#B46D3C` -> `L ~= 0.209` ->
    ~3.18:1 against TEXT_NORMAL.
  - The playback speed strip's active-speed indicator uses the `disabled`
    stylebox (`PANEL_DISABLED` `#3A2E22` fill / `TEXT_DISABLED` `#A28D73`
    text, both unchanged) -> `L ~= 0.030` / `L ~= 0.280` -> ~4.15:1 --
    already comfortably above the floor, confirming this wasn't the
    low-contrast state either.
  - Fix: `BUTTON_FILL` -> Gold Shadow `#9C6A21` (~3.67:1, was the pressed
    value) and `BUTTON_FILL_PRESSED` -> a new derived tone `#654515`
    (`L ~= 0.071` -> **~6.82:1** against TEXT_NORMAL). Final ladder:
    Pressed (~6.82:1) < Normal (~3.67:1) < Hover (~3.18:1) by luminance
    (darkest to lightest), every state clearing the 3:1 floor.
- **Item 2 (retry bug) -- reproduced against the pre-fix code, then fixed
  and reverified.** Before adding the fix, `run_failure_state_test.gd`'s new
  "RETRY BUG regression" block was run against the unmodified
  `retry_current_encounter()` and failed exactly as expected:
  `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file
  user://logs/rfs_before_fix4.log -s res://tests/run_failure_state_test.gd`
  printed
  `ERROR: Expected retry to make the same Tavern encounter immediately
  fightable again, with no map re-choice required.` and
  `ERROR: Expected the retried encounter to be startable once the build is
  re-locked, with no other state to fix up.`, **exit code 1** (this required
  first fixing the file's own pre-existing `_require()`/`quit(1)` idiom,
  which silently masked failures the same way the known idiom bug already
  documented elsewhere in this project's test suite does -- confirmed by
  first seeing exit 0 despite the printed errors with the old idiom, then
  exit 1 with the idiom fixed, matching the same before/after confirmation
  pattern `combat_recap_test.gd`'s Implementation Notes entry used for the
  same class of bug). Also required fixing the test's own setup (the first
  Tavern fight wasn't actually being locked before `start_fight()`, so
  `start_fight()` was silently no-opping and never clearing
  `tavern_map_choice_made` in the first place -- which made the regression
  check vacuously pass regardless of the real fix, caught by re-running
  after the idiom fix still showed a pass with the unfixed `build_state.gd`
  and tracing why). After applying the `tavern_map_choice_made = true` fix
  to `retry_current_encounter()`, the identical run
  (`user://logs/rfs_after_fix.log`) passed clean, exit 0, "Run failure state
  check: OK". Investigation before landing on this root cause directly
  exercised and ruled out every hypothesis (a)-(d) from the task brief via
  live `combat_screen.tscn` scenes (not just direct `BuildState` calls):
  natural frame-driven playback completion (letting `_process()` drive
  `CombatPlayback.advance()` across real engine frames, not a single manual
  `advance()` jump), `_skip_playback()`, a full second-fight cycle ending in
  `ADVENTURE_RESTART_REQUIRED`, and a Save & Quit mid-do-over followed by
  reloading into a **freshly instantiated** `combat_screen` -- the Retry
  button's `pressed` signal correctly drove `BuildState` back to
  `RunPhase.PLANNING`/`RunOutcome.NONE` in every one of those, which is what
  narrowed the break down to the one thing none of them checked afterward:
  whether the *same encounter* was actually fightable again. (A raw
  `InputEventMouseButton` `push_input()` simulation was also tried directly
  on the real button's `get_global_rect()` and initially appeared to
  reproduce a click failure, but that turned out to be a sandbox-only
  artifact -- this headless environment's root `Window.size` is pinned to a
  tiny placeholder (confirmed via direct inspection, unaffected by setting
  `root.size` manually) rather than the project's real 1600x900, so
  `CombatScreen`'s own full-rect-anchored Control undersizes itself relative
  to its Container-driven, minimum-size-forced descendants and real click
  hit-testing can't reach into it reliably in this sandbox; the project's
  documented `.pressed.emit()` convention for headless button tests remains
  the right tool here, not raw input simulation.)
- **Item 3 (retry rule correction):** `run_failure_state_test.gd` now drives
  the first Tavern fight through repeated losses to prove unlimited retries,
  then checks representative non-initial Tavern and contract-route fights
  (including Vyra) for exactly one retry before their terminal second-loss
  outcome.
- **Item 4 (speed persistence):** `combat_playback_test.gd`'s new
  `_check_playback_speed_persists()` live check presses the real 4x speed
  button mid-playback on a first (losing) fight, retries through the
  now-fixed retry path, fights again, and asserts the second fight's
  `CombatPlayback.speed` starts at 4.0 (not reset to 1.0) with the 4x speed
  button already shown `disabled` (the "active speed" indicator) and the 1x
  button not.
- Passing checks (all exit code 0 AND their "check: OK"/equivalent pass line
  verified in captured stdout -- not exit code alone, per the documented
  `_require()` masking caveat; only the usual benign ObjectDB/resource
  cleanup warnings at shutdown, plus `save_load_test.gd`'s expected/handled
  corrupt-save JSON-parse error print), run serially with distinct
  `--log-file` paths (`user://logs/adj2_<name>.log` /
  `user://logs/adj2b_<name>.log`):
  `run_failure_state_test` ("Run failure state check: OK" -- the primary
  regression-proof for items 2 and 3, confirmed FAILED-then-OK as detailed
  above), `combat_playback_test` ("Combat playback check: OK"),
  `combat_screen_test` ("P2 UI restructure end-to-end check: OK"),
  `combat_hud_test` ("Combat HUD check: OK" -- required updating one stale
  assertion that had baked in the pre-fix buggy gating as "expected," see
  below), `combat_recap_test` ("Combat recap check: OK"),
  `dashboard_header_test` ("Dashboard header check: OK"),
  `run_outcome_presentation_test` ("Run outcome presentation check: OK"),
  `save_load_ui_test` ("P2:R6:T4 save/load UI hooks check: OK"),
  `engine_mechanics_test` ("P2:M5 T0 engine mechanics check: OK"),
  `combat_test` (assert-based, verified via its printed "Result: WIN" cast
  log line + exit 0), `deterministic_replay_test` ("Deterministic replay
  check: OK"), `build_panels_test` ("P2:R7:T4 build panels test passed."),
  `reward_shop_route_ui_test` ("Reward/shop/route UI check: OK"),
  `contract_offer_flow_test` ("Contract offer flow check: OK"),
  `save_load_test` ("Save/load round trip check: OK").
- `combat_hud_test.gd`'s pre-existing "Retry resets the HUD" section
  asserted `build_state.needs_tavern_map_choice()` true and the HUD hidden
  immediately after a real retry click -- that was asserting the bug itself
  as intended behavior (its own comment called it "the real flow"). Updated
  to assert the fixed behavior (`not needs_tavern_map_choice()`, HUD visible
  immediately, no `choose_current_tavern_encounter()` re-call needed) --
  confirmed this was the only other test file with a stale assertion of
  this kind by grepping every test file the task's required list touches
  for `needs_tavern_map_choice`/`tavern_map_choice_made` after the fix and
  re-running the full list above clean.
- No stale Godot processes were encountered this pass (checked via
  `Get-Process` before and after the full serial run).
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty: this pass stayed within `project/scripts/ui/`,
  `project/scripts/tools/`, `project/scripts/autoload/build_state.gd`
  (permitted per the task's working agreement -- run-state autoload, not a
  systems/resources combat-math file), `project/scenes/combat/combat_screen.gd`,
  `project/assets/ui_theme.tres`, the four test files listed above, and the
  two docs.
- Manual Godot editor/player click-through was **not** performed -- same
  documented sandbox limitation as every prior R7 entry. Item 1's contrast
  fix is a first-draft judgment call awaiting the user's next editor
  session (tunable via `UIColors.BUTTON_FILL` alone, see the Implementation
  Notes entry above); items 2-4 are logic/state fixes fully exercised
  through real `combat_screen.tscn` scene trees and signal paths (not just
  direct `BuildState` calls), which is as close to "played it" as this
  sandbox gets.

2026-07-19 (user-requested combat-playback addition):

- `combat_playback.gd` adds a new `class_name`, so the one-time editor
  class-cache rescan was run first
  (`Godot_v4.7-stable_win64_console.exe --headless --path project --editor --quit`,
  exit 0). No headless hangs were hit at any point this pass.
- New `project/tests/combat_playback_test.gd` (combat_recap_test.gd's
  direct-call-plus-live-scene pattern with the fixed `_require()`/`_failed`
  idiom -- single quit at the end so an awaited check can't be masked):
  - Controller timeline: against the same known deterministic loss fight
    combat_recap_test.gd uses (Poison Strike + Rending Slash, crit_chance
    1.0, 100000 HP, 8s window, seed 3), the events-fired count and
    cumulative damage at five checkpoint times (0.75s/1.5s/3.2s/5s/8s at
    1x, advanced in uneven chunks) each match counts/sums computed
    independently off the raw `cast_events`/`tick_events` arrays, so
    HP-remaining-at-T provably matches; the loss timeline spans the full
    window and ends with positive HP remaining.
  - Speed scaling: a fresh controller at 4x advanced 1 real second fires
    exactly the events through 4000ms and lands the clock on 4000ms.
  - Skip/finish semantics: skip fires every remaining event, jumps the
    clock to the timeline end, and the finished callback fires exactly
    once -- further `advance()`/`skip()` calls provably never re-fire it.
  - Event ordering: every fired event arrives time-sorted, ticks fire
    before casts sharing a timestamp (resolver order), and cast/tick
    payload counts match the result exactly.
  - Win truncation: a Stab-vs-30-HP fight's timeline ends at the
    independently located kill event's timestamp while `window_ms()` still
    reports the full window for the countdown readout.
  - Live win playback through the real `combat_screen.tscn`
    (`instant_playback = false`, no awaits between the fight press and the
    assertions so the engine's own `_process` can't advance the timeline
    under the test): immediately after the Fight press the state is
    already resolved and autosaved (`last_fight_won` true, run phase past
    FIGHTING, `SaveSystem.has_save()` true after an explicit pre-fight
    `delete_save()` -- the state-vs-presentation invariant asserted
    end-to-end, not just reasoned about) while the victory overlay,
    outcome title, recap, and status line are all still hidden, the
    playback controls are visible, the log/Map buttons are locked, the
    header reads "Phase: Fighting", and the HUD opens at full HP. A
    manual `advance(2.0)` fires events and the HUD HP text tracks the
    controller's damage bookkeeping with the outcome still hidden.
    Pressing the real Skip button reveals the victory banner + populated
    recap, hides the controls, unlocks log/Map, unfreezes the header, and
    snaps the HUD to "HP 0/N".
  - Live loss playback (empty rotation): outcome title/retry hidden
    mid-playback, timeline spans the full window; after skip the DEFEATED
    title, retry do-over, and inline recap are revealed, the enemy's HP
    bar ends still full, and the window readout ends at the cap
    ("12.0s / 12s").
- Full relevant suite run serially, distinct `--log-file` paths
  (`user://logs/pb_<name>.log`), all exit 0 with their "check: OK"-style
  pass line verified in output (not exit code alone, per the known
  `_require()` masking caveat; only the usual benign ObjectDB/resource
  cleanup warnings, plus save_load_test's expected/handled corrupt-save
  JSON-parse error print):
  combat_playback_test, combat_hud_test, combat_screen_test,
  combat_recap_test, enemy_panel_test, dashboard_header_test,
  run_outcome_presentation_test, run_failure_state_test,
  save_load_ui_test, save_load_test, reward_shop_route_ui_test,
  contract_offer_flow_test, engine_mechanics_test, combat_test
  (assert-based, verified via its printed cast log + exit 0),
  deterministic_replay_test, build_panels_test.
- **No existing test file needed any modification** -- the
  headless-default `instant_playback` flag means every pre-existing test
  observes the exact pre-playback synchronous behavior.
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty: presentation-layer only, the resolver and every result/
  event type untouched.
- Manual Godot editor/player click-through was **not** performed -- the
  same documented sandbox limitation as every prior R7 entry, and it
  matters MORE here than for any prior task: this is animation work, and
  none of the feel could be verified visually. Everything below is a
  first-draft judgment call awaiting the user's editor session, tunable
  via the constants listed in the Implementation Notes:
  - Whether 0.15s per-hit HP tweens read as punchy "chunks" at real frame
    rates, and whether poison ticks' softer 0.3s drain distinguishes
    itself.
  - Popup sizing/motion: Pirata One at 26/34/16/28pt, the 48px rise, the
    0.9s lifetime, the crit punch-scale, and whether the jitter ranges
    actually prevent pile-ups during fast rotations.
  - Whether the popup spawn band (55% panel height, 96px top margin)
    sits well between the HUD and the skill strips, and whether the
    caps (10 active / 3 ticks) are too tight or too loose in long fights.
  - Whether 1x pacing feels right for a 12-30s window at all, and whether
    the elapsed/window text readout is legible enough or should become a
    thin time bar.
  - Whether the "Phase: Fighting" header freeze plus hidden status line
    reads as intentional tension or as the UI going quiet.

2026-07-19 (combat playback adjustment round 1):

- No new `class_name` was added this pass, so no editor class-cache rescan
  was needed. `project/scripts/tools/build_ui_theme.gd` was re-run
  (`Godot_v4.7-stable_win64_console.exe --headless --path project -s
  res://scripts/tools/build_ui_theme.gd`, exit 0, printed
  "Saved res://assets/ui_theme.tres") to regenerate `ui_theme.tres` from
  the source-of-truth builder after its `UIColors.BUTTON_FILL`/
  `BUTTON_FILL_PRESSED` change, per the "prefer the builder script over
  hand-editing the .tres" instruction.
- `project/tests/combat_playback_test.gd` updated: the win-truncation
  check was rewritten (renamed in-file to "full-window playback") to
  assert a win's `timeline_end_ms()` equals the full `window_ms()` (was:
  equals the independently-located kill event's timestamp) and that
  `events_fired() == total_events` after skip (was: `<= kill_index + 1 +
  tick count`), with an added assertion that the fixture fight actually
  has more casts landing after the kill (so the full-window behavior is
  genuinely exercised, not vacuously true). Every other
  `CombatPlayback.start(result, ...)` call site in the file (and in
  `combat_screen.gd`) dropped the removed `kill_hp` argument.
- Full relevant suite run serially per fix's stated command form,
  distinct `--log-file` paths (`user://logs/adj1_<name>.log`), all exit 0
  with their "check: OK"-style pass line verified in the captured stdout
  (not exit code alone, per the known `_require()` masking caveat; only
  the usual benign ObjectDB/resource cleanup warnings at exit, present on
  every run before this pass too):
  `combat_playback_test` ("Combat playback check: OK"),
  `combat_screen_test` ("P2 UI restructure end-to-end check: OK"),
  `combat_hud_test` ("Combat HUD check: OK"),
  `combat_recap_test` ("Combat recap check: OK"),
  `enemy_panel_test` ("Enemy panel check: OK"),
  `dashboard_header_test` ("Dashboard header check: OK"),
  `run_outcome_presentation_test` ("Run outcome presentation check: OK"),
  `run_failure_state_test` ("Run failure state check: OK"),
  `save_load_ui_test` ("P2:R6:T4 save/load UI hooks check: OK"),
  `engine_mechanics_test` ("P2:M5 T0 engine mechanics check: OK"),
  `combat_test` (assert-based, verified via its printed "Result: WIN" cast
  log line + exit 0), `deterministic_replay_test` ("Deterministic replay
  check: OK"), `build_panels_test` ("P2:R7:T4 build panels test passed.").
  No headless hangs were hit -- the new `_on_playback_finished()` await is
  gated off in every headless path that matters (`instant_playback` is
  never reached via the awaited branch at all in the default headless
  case, and the live-playback tests hit the `_playback_skipping` gate
  instead via their Skip-button/`_skip_playback()` calls), so no test's
  synchronous flow ever actually awaits the new timer.
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty: this pass stayed presentation-layer only, exactly as
  the combat-playback addition above did.
- Manual Godot editor/player click-through was **not** performed -- same
  documented sandbox limitation as every prior R7 entry. This matters as
  much here as it did for the original combat-playback entry: the reveal-
  delay duration, the new popup text layout with damage numbers appended,
  and the button gold-fill's actual contrast/legibility in real lighting
  are all first-draft judgment calls awaiting the user's next editor
  session, listed in full at the end of the Implementation Notes entry
  above and each tunable via a single named constant
  (`PLAYBACK_OUTCOME_REVEAL_DELAY_SEC`, the popup font-size constants
  already listed in the original entry, or `UIColors.BUTTON_FILL`/
  `BUTTON_FILL_PRESSED`).

2026-07-19 (user-requested combat-HUD addition):

- No new global-class script was added (all changes are inside
  `combat_screen.gd`, `ui_colors.gd`'s existing class, and the new plain
  `SceneTree` test file), so no editor class-cache rescan was needed.
- New `project/tests/combat_hud_test.gd`, following
  `combat_recap_test.gd`'s direct-call-plus-live-scene pattern and its
  fixed `_require()`/`_failed` idiom (awaited live checks, single quit at
  the end, so a failure can't be masked by an early `quit()`):
  - Direct helper checks against a known deterministic
    `CombatResolver.resolve()` fight (Poison Strike + Rending Slash +
    Beguiling Strike, crit_chance 1.0, 100000 HP / 200 armor / 0.4 resist,
    seed 3) with expected values computed independently in the test:
    post-fight HP equals HP minus total damage and is positive on the
    loss; final armor equals base minus summed reductions; final resist
    applies each recorded reduction multiplicatively; peak stacks match;
    and a winning result clamps remaining HP to exactly zero.
  - Live checks through the real `combat_screen.tscn`: HUD hidden before
    the Tavern map choice; visible with full HP/base stats/no chips once
    Mouthy Drunk is chosen; empty bar ("HP 0/150") and still chip-free
    after a real Quick Cut win, visible under the victory banner; after a
    real loss (empty rotation) the bar reads monster HP minus the stored
    result's total damage; pressing the real Retry button clears the
    stored result, the HUD correctly hides while the retry's re-required
    map choice is pending (mirroring the enemy panel), and shows full HP
    again once the encounter is re-chosen.
  - One test expectation was corrected during development, not the code:
    the first draft expected the HUD visible immediately after Retry, but
    `start_fight()` clears `tavern_map_choice_made`, so the real flow
    requires re-choosing the encounter -- the enemy panel behaves the same
    way, and the test now asserts that real behavior.
- Passing checks (all exit code 0 AND "check: OK" printed -- exit code not
  trusted alone per the known `_require()` masking caveat in older test
  files; only the usual benign ObjectDB/resource cleanup warnings at
  shutdown), run serially with distinct `--log-file` paths:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/hud_combat_hud_test.log -s res://tests/combat_hud_test.gd`
  - `... --log-file user://logs/hud_combat_screen_test.log -s res://tests/combat_screen_test.gd`
  - `... --log-file user://logs/hud_enemy_panel_test.log -s res://tests/enemy_panel_test.gd`
  - `... --log-file user://logs/hud_combat_recap_test.log -s res://tests/combat_recap_test.gd`
  - `... --log-file user://logs/hud_dashboard_header_test.log -s res://tests/dashboard_header_test.gd`
  - `... --log-file user://logs/hud_run_outcome_presentation_test.log -s res://tests/run_outcome_presentation_test.gd`
  - `... --log-file user://logs/hud_combat_test.log -s res://tests/combat_test.gd`
  - `... --log-file user://logs/hud_engine_mechanics_test.log -s res://tests/engine_mechanics_test.gd`
  - Plus three flow tests exercising the overlay/transition call sites the
    HUD hooked into: `reward_shop_route_ui_test.gd`,
    `contract_offer_flow_test.gd`, `save_load_ui_test.gd`.
- No existing test needed updating -- no test indexes `_combat_content`'s
  children positionally, and the HUD's insertion point (after the "Combat"
  title) shifts no assertion any test makes.
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty: presentation-layer only.
- Manual Godot editor/player click-through was **not** performed -- same
  documented sandbox limitation as every prior R7 entry. Visual judgment
  calls awaiting the user's next editor session:
  - Whether ~80px of HUD at the top of the Combat panel leaves enough
    clear black center for the future animation art, and whether top-edge
    anchoring is the right choice at all (vs. bottom edge or a corner).
  - Health bar height (14px), the reserved 16px status-row height, and
    whether the bar should stretch the panel's full inner width or be
    capped.
  - Whether the crimson `HEALTH_BAR_FILL` reads well against the
    near-black `PANEL_DEEP` fill at real pixel size.
  - Whether the HUD staying visible (empty bar) behind/above the victory
    overlay reads as intentional, and whether plain colored chip labels
    are enough or should become small bordered chips.
  - The info line's " | "-separated single-line format vs. a small boxed
    multi-line readout (the user asked for an "info box"; a one-line
    readout was chosen to keep the HUD compact per the playtest-pass
    lessons -- easy to re-shape on feedback).

2026-07-18 (P2:R7:T8 - Polish Navigation/Confirmations):

- No new global-class script was added (only existing `game_root.gd`/
  `combat_screen.gd` were edited, plus test-file additions), so no editor
  class-cache rescan was needed.
- Extended `project/tests/save_load_ui_test.gd` with a new section covering
  the fixed bug directly: drives a second fresh Adventure Mode run through
  class/subclass select to the combat dashboard, forces
  `BuildState.run_outcome = CONTRACT_FAILED`, calls
  `_apply_outcome_presentation()` and `_autosave()` to mirror the real
  post-fight call sequence, confirms `SaveSystem.has_save()` is true (the
  save exists, matching real play), presses the real "Restart Adventure"
  button, and confirms `SaveSystem.has_save()` is now false. This is an
  end-to-end check through the real `game_root`/`title`/`combat_screen`
  scene tree and signal wiring, not a direct call into `SaveSystem`.
- Updated `project/tests/dashboard_header_test.gd`'s existing CONTRACT_OFFER
  exact-string assertion to match the corrected "Accept the contract on the
  map." wording.
- Passing checks (all exit code 0, no assertion failures beyond
  `save_load_test.gd`'s expected/handled corrupt-save JSON-parse error
  print, only the known benign ObjectDB/resource cleanup warnings at
  shutdown), run serially with distinct `--log-file` paths:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_save_load_ui.log -s res://tests/save_load_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_dashboard_header_test.log -s res://tests/dashboard_header_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_combat_screen_test.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_contract_offer_flow_test.log -s res://tests/contract_offer_flow_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_run_outcome_presentation_test.log -s res://tests/run_outcome_presentation_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_run_failure_state_test.log -s res://tests/run_failure_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_save_load_test.log -s res://tests/save_load_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_combat_recap_test.log -s res://tests/combat_recap_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_engine_mechanics_test.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/t8_combat_test.log -s res://tests/combat_test.gd`
- No stale Godot processes were encountered this pass (checked via
  `tasklist` before and after the full serial run).
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty, confirming no combat/economy resolver or resource-schema
  logic was touched. Every changed file this pass is `game_root.gd`,
  `combat_screen.gd` (one string literal), `project/tests/save_load_ui_test.gd`
  (new section), `project/tests/dashboard_header_test.gd` (one assertion
  update), or this doc. No `UIColors` additions were needed (no new dialog
  was built).
- Manual Godot editor/player click-through was **not** performed, the same
  documented limitation carried forward from every prior `P2:R7` task: this
  sandboxed environment has no GUI automation for native Godot windows. The
  headless scene-tree tests above, driving the real `title.tscn`/
  `game_root.tscn`/`combat_screen.tscn` scenes through the same signal/click
  paths a real session uses (including the new Restart Adventure ->
  save-deletion end-to-end check), are this project's established
  substitute. This task's own scope is mostly text/dialog-presence/save-file
  auditing rather than new layout, so the visual-judgment-call risk is lower
  than prior R7 tasks, but the existing `Abandon Run` and `New Game`
  `ConfirmationDialog`s' actual on-screen legibility/centering were not
  pixel-verified here (they predate this task and were only read, not
  rebuilt). Should be spot-checked in a real editor/player session along
  with every other outstanding R7 visual caveat already on record.

2026-07-18 (P2:R7:T7 - Improve Combat Recap):

- No new global-class script was added (`combat_recap_test.gd` is a plain
  `SceneTree` test script, not a global class; every other change is inside
  the existing `combat_screen.gd`), so no editor class-cache rescan was
  needed.
- Passing checks (all exit code 0, no assertion failures, only the known
  benign ObjectDB/resource cleanup warnings at shutdown), run serially with
  distinct `--log-file` paths:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_recap_test_t7.log -s res://tests/combat_recap_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_test_t7.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/dashboard_header_test_t7.log -s res://tests/dashboard_header_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/enemy_panel_test_t7.log -s res://tests/enemy_panel_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/build_panels_test_t7.log -s res://tests/build_panels_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/reward_shop_route_ui_test_t7.log -s res://tests/reward_shop_route_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/deterministic_replay_test_t7.log -s res://tests/deterministic_replay_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_outcome_presentation_test_t7.log -s res://tests/run_outcome_presentation_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_failure_state_test_t7.log -s res://tests/run_failure_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_test_t7.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_test_t7.log -s res://tests/combat_test.gd`
- Verified the four combat-outcome states this task's scope calls out
  directly: `combat_recap_test.gd`'s live checks cover a Tavern win (Quick
  Cut vs. Mouthy Drunk, real `_victory_recap_label` text) and a Tavern loss
  with do-over pending (empty rotation, real `_recap_label` text);
  `combat_screen_test.gd`'s existing end-to-end walk covers a contract-route
  win (Portly Cook) already exercising `_show_victory_banner()`'s recap
  path with the new fields; and `enemy_panel_test.gd`/`dashboard_header_test.gd`
  already cover the Vyra contract-victory state for the *pre-fight* enemy
  panel and header, which this task deliberately does not touch (T5/T3
  scope) -- the recap itself only needs a real win/loss to exercise, and
  Vyra is mechanically the same `CombatResolver.resolve()`/
  `_show_victory_banner()` path as any other monster, just with different
  authored HP/window/armor/poison values already covered by the direct
  helper checks' independent-expected-value assertions. No separate
  Vyra-specific recap test was added since nothing about the recap logic
  branches on which monster it is.
- Hit and fixed one real bug in the new test file's own `_require()` test
  helper while writing it (see the Implementation Notes entry above for the
  full root-cause explanation): calling an `await`-using check function
  without `await` let `_initialize()`'s own final `quit()` silently reset
  the exit code to 0 ahead of the awaited work finishing, masking a
  deliberately-broken assertion as a pass. Confirmed by breaking an
  assertion, observing `EXIT: 0` with the error still printed to the
  console, then confirming `EXIT: 1` with `_require()`/`_initialize()`
  fixed. This is a pattern shared by every other test file in the repo
  (see Implementation Notes for the follow-up note) and was fixed only in
  `combat_recap_test.gd`, not project-wide, since a blanket fix across every
  existing test file is outside this task's `P2:R7:T7` scope.
- No stale Godot processes were encountered this pass (checked via
  `tasklist` before and after the full serial run).
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty, confirming no combat/economy resolver or resource-schema
  logic was touched -- `combat_recap.gd` and `combat_result_formatter.gd`
  (both under `project/scripts/systems/`) were read for reference and used
  exactly as before, not edited. Every changed file is `combat_screen.gd`,
  `project/tests/combat_screen_test.gd` (recap-format assertion updates),
  the new `project/tests/combat_recap_test.gd`, or this doc. No `UIColors`
  additions were needed.
- Manual Godot editor/player click-through was **not** performed, the same
  documented limitation carried forward from every prior `P2:R7` task: this
  sandboxed environment has no GUI automation for native Godot windows. The
  headless scene-tree tests above, driving the real `combat_screen.tscn`
  through the same `BuildState`/`CombatResolver` code paths a real fight
  uses, are this project's established substitute. Visual judgment calls
  this task makes and cannot verify here: whether the new inline loss recap
  (`_recap_label`, stacked under `_status_label` and above the outcome
  title/retry controls in the same `_combat_content` column) reads as a
  coherent block rather than crowding the loss state's existing controls at
  actual pixel size, whether the win recap's now-longer text (up to 7 lines
  vs. the prior 5) still fits comfortably inside `_victory_overlay`'s
  `CenterContainer` without the overlay needing to grow awkwardly, and
  whether the "(needed N)" / "(needed N.N)" parenthetical suffixes on the
  headline lines read clearly at a glance rather than as visual clutter on
  the Total Damage/DPS lines. These should be spot-checked in a real
  editor/player session, same caveat as every prior `P2:R7` task.

2026-07-18 (second playtest feedback pass):

- No new global-class script was added (`CardStyle` gained statics but is a
  pre-existing global class; `GearCompareButton` remains a nested class),
  so no editor class-cache rescan was needed.
- Reasoned tooltip-size accounting for item 4 (this environment has no GUI
  automation for native Godot windows, so this is analysis, not a pixel
  measurement): each box is a default `TooltipPanel`-styled
  `PanelContainer` whose size is driven purely by its Label content at the
  theme's default VT323 size 18 (~19-20px line height, no font-size or
  padding overrides beyond the TooltipPanel stylebox's own small content
  margins). A typical shop-offer box is 5-6 lines (slot/name, tier, 1-2
  affixes, price, hint) at the widest line's width (~180-260px); the
  "Equipped" box is comparable or shorter ("Nothing equipped." collapses it
  to 2 lines). Total popup: roughly 380-540px wide by 100-140px tall --
  about two normal tooltips side by side, versus the rejected version's
  two 170px-min columns inside a 12px-margin, 2px-border `CardStyle` card
  plus separator plus footer. This should be spot-checked visually in the
  user's next editor session -- tooltip sizing is exactly the class of
  issue this sandbox cannot confirm, as the first feedback pass
  demonstrated.
- Passing checks (all exit code 0, no assertion failures beyond
  `save_load_test.gd`'s expected/handled corrupt-save JSON-parse error
  print, only the known benign ObjectDB/resource cleanup warnings at
  shutdown), run serially with distinct `--log-file` paths:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/reward_shop_route_ui_test_pt2.log -s res://tests/reward_shop_route_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_ui_test_pt2.log -s res://tests/save_load_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_test_pt2.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/build_panels_test_pt2.log -s res://tests/build_panels_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_offer_flow_test_pt2.log -s res://tests/contract_offer_flow_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/route_reward_choice_ui_test_pt2.log -s res://tests/route_reward_choice_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_test_pt2.log -s res://tests/save_load_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/dashboard_header_test_pt2.log -s res://tests/dashboard_header_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/enemy_panel_test_pt2.log -s res://tests/enemy_panel_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_test_pt2.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_test_pt2.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_test_pt2.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_test_pt2.log -s res://tests/inventory_model_test.gd`
    (extra sanity run since gear captions touched `gear_panel.gd`)
- No stale Godot processes were left running (checked via `Get-Process`
  after the full serial run), and no headless hang was hit this pass.
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty, confirming no combat/economy resolver or resource-schema
  logic was touched. Changed files this pass: `title.gd`,
  `combat_screen.gd`, `gear_panel.gd`, `subclass_select.gd`,
  `card_style.gd`, the four updated test files (`save_load_ui_test.gd`,
  `reward_shop_route_ui_test.gd`, `combat_screen_test.gd`,
  `contract_offer_flow_test.gd`) plus `build_panels_test.gd`'s added
  caption assertions, and this doc.
- Manual Godot editor/player click-through was **not** performed, the same
  documented limitation carried forward from every prior `P2:R7` entry:
  this sandboxed environment has no GUI automation for native Godot
  windows. Visual judgment calls this pass makes and cannot verify here,
  to spot-check next editor session: whether the two-box tooltip actually
  reads as two normal-sized tooltips at real pixel size and cursor
  position (the headline risk, per the size accounting above), whether
  the slot/tier caption is legible inside the 88px inventory boxes the
  same way it is in the shop boxes, whether the reordered title menu and
  grayed-out Resume/Training Room read correctly, and whether two 280px
  selection cards fit comfortably inside the secondary-chooser modal
  (640px content minimum -- 2x280 + 20 separation = 580, which fits, but
  intrinsic text length may make card heights uneven between Assassin and
  Shadow).

2026-07-18 (playtest feedback pass - revises T3/T4/T6):

- No new global-class script was added (`GearCompareButton` is a nested
  class inside `combat_screen.gd`, not a top-level `class_name`), so no
  editor class-cache rescan was needed.
- Reasoned overflow-bug height accounting for item 2 (this environment has
  no GUI automation for native Godot windows, so this is analysis, not a
  pixel measurement -- documented as such below): `project.godot` sets
  `viewport_width=1600`/`viewport_height=900`; `combat_screen.gd`'s
  `SCREEN_MARGIN := 16` on all four sides of the root `MarginContainer`
  leaves `root_vbox` a `900 - 32 = 868`px height budget. T3's removed
  status-bar row cost roughly `10`px content margin x2 + `4`px inner
  separation + two ~`24`px text lines + `2`px border x2 + the `16`px
  `PANEL_SEPARATION` gap that used to sit above/below it -- on the order of
  `95-100`px. T4's removed always-visible skill-effect caption cost roughly
  `30`px (the `_skills_box` strip's height is set by its tallest child, and
  a caption Label plus its `2`px separation added that much over a bare
  button). T4's removed talent lock-reason caption cost roughly `20-45`px
  depending on how many tiers of the currently-selected tree have an
  unavailable talent at a given moment (each affected tier's row grows by
  one wrapped caption line, not per-node, since a `HBoxContainer` row's
  height is its tallest child). T4's inline stat-delta text, now moved into
  a tooltip, previously risked wrapping the `RichTextLabel`'s "Attack
  Speed:"/"Physical Damage:" lines to two lines each inside the left
  column's `300`px `SIDE_COLUMN_WIDTH` once the appended `" (+N% from
  gear/talents)"` suffix pushed a line past the available width -- worth
  roughly `20-45`px depending on how many stat lines had an active delta at
  once. Summing the low end of each range (`95 + 30 + 20 + 20 = 165`px) to
  the high end (`100 + 30 + 45 + 45 = 220`px) gives the total height this
  pass removes. T3 and T4 are the only two `P2:R7` tasks that added height
  to this layout without a compensating removal, and the dashboard is not
  documented as having had an overflow problem before they landed -- so
  removing roughly the same amount they added (165-220px, against a
  budget that was apparently already tight enough for a mid-Adventure
  loaded-save state, per the reported bug, to tip over) should restore a
  fitting layout. This reasoning could not be pixel-verified in this sandbox;
  a real editor/player session should confirm no clipping remains,
  especially with a talent tree state that has several simultaneously
  locked talents across multiple tiers (the least-reduced case above).
- Passing checks (all exit code 0, no assertion failures beyond the one
  expected/handled JSON-parse error print inside `save_load_test.gd`'s
  corrupt-save case, only the known benign ObjectDB/resource cleanup
  warnings at shutdown), run serially with distinct `--log-file` paths:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_test_pt.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/dashboard_header_test_pt.log -s res://tests/dashboard_header_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/build_panels_test_pt.log -s res://tests/build_panels_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/enemy_panel_test_pt.log -s res://tests/enemy_panel_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/reward_shop_route_ui_test_pt.log -s res://tests/reward_shop_route_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_test_pt.log -s res://tests/save_load_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/save_load_ui_test_pt.log -s res://tests/save_load_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_test_pt.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_test_pt.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_test_pt.log -s res://tests/gear_generator_test.gd`
  - Extra sanity runs beyond the required list, since this pass touched
    widely-shared panels/`combat_screen.gd`: `contract_offer_flow_test.gd`,
    `route_reward_choice_ui_test.gd`, `passive_allocator_test.gd`,
    `run_outcome_presentation_test.gd`, `run_failure_state_test.gd`,
    `run_seed_state_test.gd`, `inventory_model_test.gd`,
    `legendary_reward_test.gd`, `contract_route_data_test.gd`,
    `shadow_parity_test.gd` -- all passed.
- No stale Godot processes were encountered this pass (checked via
  `tasklist` before and after the full run).
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty, confirming no combat/economy resolver or resource-schema
  logic was touched. Every changed file is one of the panel scripts
  (`combat_screen.gd`, `available_skills_panel.gd`, `talent_panel.gd`,
  `character_stats_panel.gd`), the two updated test files
  (`dashboard_header_test.gd`, `build_panels_test.gd`) plus one small
  `combat_screen_test.gd` assertion fix, or this doc. `title.gd`/
  `save_system.gd`/`game_root.gd` were read but not modified (item 1 was
  already correct). No `UIColors` additions were needed -- `PANEL_DEEP` for
  the Combat panel (item 8) already existed.
- Manual Godot editor/player click-through was **not** performed, the same
  documented limitation carried forward from every prior `P2:R7` task: this
  sandboxed environment has no GUI automation for native Godot windows.
  Beyond the overflow-bug reasoning above, other visual judgment calls this
  pass makes and cannot verify here: whether the new side-by-side gear
  comparison tooltip (item 7) is legible and well-proportioned at actual
  pixel size/mouse position (custom tooltips position relative to the
  cursor and this sandbox can't render that), whether the consolidated top
  bar (item 3) reads as visually crowded with five text fields plus three
  buttons on one row at `1600`px width, and whether `_next_action_label`'s
  `clip_text` ever actually triggers in practice (i.e. whether any real
  "Next:" string is long enough to need clipping at that width). These
  should be spot-checked in a real editor/player session.

2026-07-18 (P2:R7:T6 - Improve Reward/Shop/Route UI):

- No new global-class script was added (only `combat_screen.gd` was edited,
  plus the new plain `SceneTree` test script below, which isn't a global
  class), so no editor class-cache rescan was needed.
- Added `project/tests/reward_shop_route_ui_test.gd`, driving the real
  `combat_screen.tscn` scene against `BuildState` (same pattern as
  `enemy_panel_test.gd`/`route_reward_choice_ui_test.gd`). It covers: shop
  offer tier/slot/affix/afford-state rendering at a known gold value (`20g`,
  with one `32g` Master offer disabled/muted and one `18g` Basic offer
  enabled, both boxes' visible captions and full tooltip text checked, plus
  the shop overlay's own gold label reading `"Gold: 20g"`); the gear-upgrade
  comparison helper directly, for an empty slot, an identical-item slot, and
  a known Attack Speed delta pair (`+10%` candidate vs. `+5%` equipped ->
  `"+5% Attack Speed vs. equipped."`); the route-tradeoff helper directly for
  two different real Gilded Serpent branch pairs (Door Guard/Portly Cook and
  Sleeping Henchman/Cloaked Watchmen), asserting exact sentences and that
  they differ from each other, plus a live check that the route map's story
  text carries the same sentence at the real opener-choice state; and the
  Legendary reward-claim tooltip for the real Wyvern Kriss resource, checking
  slot/name, tier, an affix line, the upgrade-comparison line, and the
  explicit "Click to choose." hint.
- Fixed a stale pre-existing assertion in `project/tests/contract_offer_flow_test.gd`
  unrelated to this task's own changes: it asserted the enemy panel *omits*
  `"Pressure:"`/`"Reward:"` text at the Portly Cook route-planning state, which
  predates `P2:R7:T5` adding those lines as always-visible panel content (T5's
  own verification notes updated the equivalent assertions in
  `combat_screen_test.gd` but missed this second test file exercising the
  same state). Flipped to assert the real content instead (`"Pressure: No
  notable defensive pressure."`, `"Reward: 26g, Basic Gear"`), matching the
  values `combat_screen_test.gd` already asserts for the same Portly Cook
  state. This was caught while running this task's required verification
  list, not introduced by this task's own edits (`enemy_panel.gd` was not
  touched).
- Passing checks (all exit code 0, no assertion failures, only the known
  benign ObjectDB/resource cleanup warnings at shutdown), run serially with
  distinct `--log-file` paths:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/reward_shop_route_ui_test.log -s res://tests/reward_shop_route_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_test_t6.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/dashboard_header_test_t6.log -s res://tests/dashboard_header_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/build_panels_test_t6.log -s res://tests/build_panels_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/enemy_panel_test_t6.log -s res://tests/enemy_panel_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_test_t6.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_test_t6.log -s res://tests/inventory_model_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/legendary_reward_test_t6.log -s res://tests/legendary_reward_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_route_data_test_t6.log -s res://tests/contract_route_data_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/route_reward_choice_ui_test_t6.log -s res://tests/route_reward_choice_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_offer_flow_test_t6b.log -s res://tests/contract_offer_flow_test.gd` (after the stale-assertion fix above; failed once before the fix, matching the known local pattern of catching stale assertions via a normal non-hanging failure, not a hang)
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty, confirming no combat/economy resolver or resource-schema
  logic was touched; every changed file is `combat_screen.gd`, the two test
  files noted above (`contract_offer_flow_test.gd`'s stale-assertion fix and
  the new `reward_shop_route_ui_test.gd`), or this doc. No `UIColors`
  additions were needed.
- Manual Godot editor/player click-through was **not** performed, the same
  documented limitation carried forward from every prior `P2:R7` task: this
  sandboxed environment has no GUI automation for native Godot windows. The
  headless scene-tree tests above, driving the real `combat_screen.tscn`
  through the same `BuildState` reads real clicks use, are this project's
  established substitute. Visual judgment calls this task makes and cannot
  verify here: whether the new two-line slot/tier caption reads legibly at
  actual pixel size inside the 88px shop-offer boxes (vs. the larger 112px
  reward-choice boxes), whether the appended route-tradeoff sentence makes
  the map's story text too long/wrappy at 1600x900, and whether the shop
  overlay's newly-visible gold label creates any visual redundancy with the
  T3 header's own gold field now that both are on-screen simultaneously
  during a shop round. These should be spot-checked in a real editor/player
  session, same caveat as every prior `P2:R7` task.

2026-07-18 (P2:R7:T5 - Improve Enemy/Encounter Presentation):

- No new global-class script was added (only the existing `enemy_panel.gd`
  and the new plain `SceneTree` test script, which is not a global class),
  so no editor class-cache rescan was needed.
- Added `project/tests/enemy_panel_test.gd`, driving `combat_screen.tscn`
  against `BuildState` (same pattern as `dashboard_header_test.gd`). It
  covers: direct calls to `_required_dps_text()` confirming 150 HP / 12s =
  12.5 and 600 HP / 30s = 20.0 (Vyra's authored duration), plus `NONE` for a
  null monster and a zero-length window; direct calls to
  `_build_pressure_text()` confirming Mouthy Drunk (0 armor/0% resist) gets
  the no-pressure line, Vyra (160 armor/35% resist, both above threshold)
  gets the combined armor+poison line, and two synthetic single-stat
  `Monster.new()` instances get the armor-only and poison-only lines
  respectively; a live Tavern check that the Mouthy Drunk panel shows
  HP/Required DPS/Armor/Poison Resist/Window/Reward/Pressure together
  *before* the build is locked or any fight happens (asserting
  `not build_state.build_locked` alongside the reward text, directly
  covering the task's "before the fight happens, not only after" requirement);
  and a live Gilded Serpent contract-route check that sets
  `BuildState.active_contract`/`current_route_node` to the real
  `route.gilded_serpent.vyra` node (the same construction
  `dashboard_header_test.gd` uses for its contract-victory case) and
  confirms the panel reads Vyra's real 600 HP/160 armor/35% poison
  resist/30s window stat block and correctly renders the combined
  armor-and-poison pressure sentence -- directly satisfying this task's
  explicit Vyra verification requirement.
- Updated two pre-existing assertions in `project/tests/combat_screen_test.gd`
  that had been asserting the *absence* of `"Pressure:"`/`"Reward:"`
  substrings at the Portly Cook contract-route state (lines were originally
  written defensively against unrelated debug text, not specifically
  anticipating this task, but the labels this task landed on happen to
  match what those assertions were guarding against). Flipped them to
  assert the new content is present and correct: `"Required DPS: 18.0"`
  (360 HP / 20s), `"Pressure: No notable defensive pressure."` (Portly
  Cook has 0 armor/0% resist), and `"Reward: 26g, Basic Gear"` (read from
  `project/data/contract_routes/gilded_serpent/portly_cook.tres`'s
  `gold_amount = 26` plus `generated_gear_tier = 0` i.e. Basic). Also added
  matching Required DPS/Reward/Pressure assertions at the earlier Mouthy
  Drunk Tavern-encounter check (`"Required DPS: 12.5"`, `"Reward: 12g, 1
  talent point"`, `"Pressure: No notable defensive pressure."`), all
  cross-checked against the actual authored `.tres` reward/monster data
  rather than assumed values -- the first attempt at the Portly Cook reward
  assertion used the wrong exact string (`"Reward: Basic Gear"` instead of
  `"Reward: 26g, Basic Gear"`, missing the 26g the encounter also grants)
  and was caught by re-running the test, not by a hang -- a plain assertion
  failure with a normal non-zero-adjacent exit, no stale process cleanup
  needed this time.
- Passing checks (all exit code 0, no assertion failures, only the known
  benign ObjectDB/resource cleanup warnings at shutdown), run serially with
  distinct `--log-file` paths:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/enemy_panel_test.log -s res://tests/enemy_panel_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_test2.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/dashboard_header_test.log -s res://tests/dashboard_header_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/build_panels_test.log -s res://tests/build_panels_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_test.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_test.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_route_data_test.log -s res://tests/contract_route_data_test.gd`
- Hit one instance of the documented stale-process gotcha, unrelated to a
  code bug this time: two `Godot_v4.7-stable_win64.exe`/
  `_console.exe` processes were still running several minutes after their
  headless runs had already printed a normal `EXIT: 0`/assertion-failure
  and returned control. Confirmed via `Get-Process`, killed with
  `Stop-Process -Force`, and confirmed clean afterward -- did not affect any
  test's actual pass/fail result since each run's console output had
  already been captured before the process lingered.
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty, confirming no combat/economy resolver or resource-schema
  logic was touched; every changed file is `enemy_panel.gd`,
  `combat_screen_test.gd` (assertion updates only), the new
  `enemy_panel_test.gd`, or this doc. No `UIColors` additions were needed.
- Manual Godot editor/player click-through was **not** performed, the same
  documented limitation carried forward from every prior `P2:R7` task: this
  sandboxed environment has no GUI automation for native Godot windows. The
  headless scene-tree tests above, driving the real `combat_screen.tscn`/
  `enemy_panel.tscn` through the same `BuildState` reads real clicks use,
  are this project's established substitute. Visual judgment calls this
  task makes and cannot verify here: whether seven stacked info lines (up
  from four) still fit the panel's `PANEL_MIN_HEIGHT := 190` without
  clipping or forcing the panel to grow awkwardly relative to its
  dashboard-column neighbors, and whether the added lines read as a
  coherent group rather than a wall of text at actual pixel size. These
  should be spot-checked in a real editor/player session, same caveat as
  every prior `P2:R7` task.

2026-07-18 (P2:R7:T4 - Improve Build Panels):

- No new global-class script was added (only existing panel scripts and one
  new plain `SceneTree` test script were edited/added), so no editor
  class-cache rescan was needed.
- Added `project/tests/build_panels_test.gd`, driving the real
  `combat_screen.tscn` scene against `BuildState` (same pattern as
  `dashboard_header_test.gd`/`combat_screen_test.gd`) with a Rogue/Thief
  build. It exercises: a locked talent's named unmet-prerequisite reason
  (Opportunity Strikes requires Practiced Rhythm) vs. a budget-based reason
  for a no-prereq talent at 0 points, both directly and via the rendered
  tooltip; the "Points Spent: spent/earned" budget label counting up as
  Quick Hands is selected; a skill's visible effect-summary caption matching
  its `PhysicalDamageEffect.amount` exactly (Stab -> "18 physical dmg");
  rotation slot cast-order tooltip text and the explicit "x" remove badge
  appearing when unlocked and disappearing when locked, plus that clicking a
  slot still shrinks the rotation; the Physical Damage stat line carrying an
  explicit "(+8% from gear/talents)" delta note once Piercing Blades is
  selected, and the `_stat_delta_text()` helper directly for a zero-delta
  no-op case; and gear equipped-vs-inventory clarity (accent-colored,
  thicker border on the equipped weapon slot vs. the empty helm slot and the
  inventory item's plain border; the equipped/inventory tooltips stating
  "Equipped -- Unequip to inventory" vs. "In inventory -- Equip"; and a
  direct `gui_input` click simulation on the equipped weapon slot outside a
  shop round confirming it now unequips to inventory rather than being a
  no-op).
- Hit and fixed one real regression while writing tests, matching the class
  of pitfall already documented in the T3 verification notes: restructuring
  `available_skills_panel.gd`'s skill buttons from a bare `Button` per skill
  to a `VBoxContainer` (button + effect-summary label) broke an existing
  `combat_screen_test.gd` assertion (`for child in
  available_skills_panel._skills_box.get_children(): assert(child.disabled)`
  immediately after a lock toggle) two different ways: first, the assertion
  itself needed updating since `child` is no longer the `Button` directly
  (fixed to `child.get_child(0).disabled`); second, and less obviously,
  `_refresh()`'s loop that force-updates a stale (already `queue_free()`'d
  but not yet actually removed) child's disabled state to the *current*
  lock value before freeing it had been dropped during the refactor because
  its `if child is Button` check silently stopped matching the new
  `VBoxContainer` wrapper. Removing that force-update wasn't a hard crash --
  it just left the assertion checking a stale value from a still-present,
  about-to-be-freed child in a same-frame multi-refresh scenario (several
  rapid skill/rotation signals followed by a lock toggle with no intervening
  `await process_frame`, exactly what `combat_screen_test.gd` does) -- which
  is the same "headless process hangs instead of erroring cleanly" failure
  mode already called out in the T3 notes for a different root cause
  (assert() failing mid-`_initialize()` coroutine with no `quit()` reached
  leaves the SceneTree idle forever instead of exiting). Killed the stale
  `Godot_v4.7-stable_win64_console.exe` process this left running (confirmed
  via `tasklist`/`taskkill`, none left afterward), fixed `_refresh()` to walk
  into the wrapper's first child before setting `.disabled`, and reran clean.
- Passing checks (all exit code 0, no assertion failures, only the known
  benign ObjectDB/resource cleanup warnings at shutdown):
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/build_panels_test.log -s res://tests/build_panels_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_test.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_test.log -s res://tests/passive_allocator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/dashboard_header_test.log -s res://tests/dashboard_header_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_test.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_test.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_test.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_test.log -s res://tests/inventory_model_test.gd` (run because this task touched `gear_panel.gd`'s equip/unequip click handling)
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_outcome_presentation_test.log -s res://tests/run_outcome_presentation_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_failure_state_test.log -s res://tests/run_failure_state_test.gd`
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty, confirming no combat/economy resolver or resource-schema
  logic was touched; every changed file is one of the five build panel
  scripts, `project/tests/combat_screen_test.gd` (two label-format
  assertions updated to match the new "Points Spent:" text and the new
  wrapper-container structure), the new
  `project/tests/build_panels_test.gd`, or this doc. No `UIColors` or
  `BuildState` additions were needed for this task.
- Manual Godot editor/player click-through was **not** performed, the same
  documented limitation carried forward from every prior `P2:R7` task: this
  sandboxed environment has no GUI automation for native Godot windows. The
  headless scene-tree tests above, driving the real scenes through the same
  `BuildState`/panel code paths real clicks use, are this project's
  established substitute. Visual judgment calls this task makes and cannot
  verify here: whether the talent lock-reason caption text wraps acceptably
  at typical node-tree widths without crowding neighboring talent nodes,
  whether the skill effect-summary caption reads cleanly under narrower
  skill buttons, whether the rotation slot's corner badges are legible at
  actual pixel size against the slot's accent-colored glyph, and whether the
  equipped-slot border-color/width difference is visually obvious enough at
  a glance (vs. only confirmed structurally via the stylebox properties in
  `build_panels_test.gd`). These should be spot-checked in a real
  editor/player session, same caveat as every prior `P2:R7` task.

2026-07-18 (P2:R7:T3 - Improve Run Header/Status):

- No new global-class script was added by this task (only existing
  `combat_screen.gd` was edited, plus the new test script below, which
  isn't a global class), so no editor class-cache rescan was needed.
- Added `project/tests/dashboard_header_test.gd`, driving the real
  `combat_screen.tscn` scene against `BuildState` (following the same
  pattern as `run_outcome_presentation_test.gd`/`run_failure_state_test.gd`)
  across as many of the `P2:R7:T1` reachable dashboard states as apply to
  the header: fresh Tavern planning (before/after a map choice, before/
  after locking), first Tavern loss (do-over), second Tavern loss (Adventure
  restart required), contract offer, secondary subclass choice, contract
  route choice, an open shop round, a pending reward choice, and contract
  victory. Each state asserts the Phase/Target/Build/Next (and Seed/Gold at
  the fresh-planning state) header text reads correctly.
- Hit two real GDScript pitfalls while writing the test, both already
  documented as latent risks elsewhere in this codebase (see `P2:R6:T8`'s
  notes on the same `:=`/bare-array-literal pattern): `build_state.
  pending_reward_choices = [lucky_coin]` and `= []` are untyped `Array`
  literals assigned to a typed `Array[GearItem]` property, which fails at
  runtime with `Invalid assignment of property or key`. This didn't fail
  loudly -- the uncaught script error left the headless `SceneTree` process
  hung indefinitely instead of reaching `quit()`, matching the "known local
  headless startup/log crash" gotcha called out elsewhere in the R5/R6 docs.
  Killed the two stale `Godot_v4.7-stable_win64_console.exe`/
  `Godot_v4.7-stable_win64.exe` processes this left running, fixed both
  assignments to go through an explicitly `Array[GearItem]`-typed local
  first, and reran clean.
- Passing checks (all exit code 0, no assertion failures, only the known
  benign ObjectDB/resource cleanup warnings at shutdown):
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/dashboard_header_t3.log -s res://tests/dashboard_header_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_test_r7t3.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_outcome_presentation_test_r7t3.log -s res://tests/run_outcome_presentation_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_failure_state_test_r7t3.log -s res://tests/run_failure_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_seed_state_test_r7t3.log -s res://tests/run_seed_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_test_r7t3.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_test_r7t3.log -s res://tests/combat_test.gd`
- `git diff --stat -- project/scripts/systems project/scripts/resources`
  returned empty, confirming no combat/economy resolver logic was touched;
  every changed file is `combat_screen.gd`, the new test, or docs.
  `build_state.gd` itself was not touched -- every header field needed
  already existed on `BuildState`.
- Manual Godot editor/player click-through was **not** performed, the same
  documented limitation carried forward from `P2:R7:T1`/`T2` and every prior
  `P2:R5`/`P2:R6` milestone: this sandboxed environment has no GUI
  automation for native Godot windows. The headless scene-tree test above,
  driving the real scene through the same `BuildState` code paths real
  clicks use, is this project's established substitute. Visual judgment
  calls this task makes (status bar spacing/wrapping at 1600x900, whether
  the five header fields plus the next-action line fit on one/two lines
  without crowding the top bar) are unverified by this pass and should be
  spot-checked in a real editor/player session, same caveat as `P2:R7:T2`.

2026-07-17 (P2:R7:T2 - Apply Visual Style Foundations):

- One-time class-cache rescan (required after adding the new global-class
  `UIColors` script) and the initial font import were both done via:
  `& 'F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe' --headless --editor --quit --path project`
  -- confirmed `CardStyle` and `UIColors` both appear in the
  `update_scripts_classes` step output, and the four new TTFs appear in
  the `reimport` step output with no errors.
- Ran the following headless tests serially (not in parallel, per the
  known `user://logs` collision), each with its own `--log-file`. All
  passed with exit code 0 and no assertion failures:
  - `-s res://tests/combat_test.gd`
  - `-s res://tests/engine_mechanics_test.gd`
  - `-s res://tests/gear_generator_test.gd`
  - `-s res://tests/passive_allocator_test.gd`
  - `-s res://tests/combat_screen_test.gd`
  - `-s res://tests/save_load_ui_test.gd`
  - `-s res://tests/run_outcome_presentation_test.gd`
  - `-s res://tests/contract_offer_flow_test.gd`
  - `-s res://tests/route_reward_choice_ui_test.gd`
  - `-s res://tests/shadow_parity_test.gd`
  - The last five were included beyond the "known passing" list because
    they instantiate `combat_screen.tscn`/panel scenes directly and are
    the tests most likely to catch a styling change that accidentally
    broke presentation logic; none did.
  - `combat_screen_test.gd`'s printed panel text confirms the poison lines
    now carry `[color=#72b953]...[/color]` tags around the same text the
    test's `.contains(...)` assertions check, and every assertion in that
    test still passed.
- Manual Godot editor/player click-through was **not** performed -- this
  sandboxed environment has no GUI automation for native Godot windows,
  a documented limitation carried forward from prior milestones (see
  `P2:R7:T1`'s and earlier `P2:R*` docs' verification notes). The visual
  judgment calls this task makes (contrast, font legibility at 1600x900,
  Press Start 2P button padding, whether MedievalSharp/Pirata One render
  as intended) are unverified by this pass and should be spot-checked in
  a real editor/player session before `P2:R7:T9`'s formal verification
  pass.
- `git diff --stat` confirms no edits to any system/logic file
  (`build_resolver.gd`, `combat_resolver.gd`, `damage_calculator.gd`,
  `combat_timing.gd`, `gear_generator.gd`, `passive_allocator.gd`,
  `run_flow.gd`, or anything under `project/scripts/systems/` or
  `project/scripts/resources/`) -- every changed file is a scene script
  under `project/scenes/`, a UI helper under `project/scripts/ui/`, the
  new one-shot theme-builder tool, `project/project.godot`, or docs.

2026-07-19 (retry-exception correction: first encounter, not Vyra):

- `git diff --stat -- project/scripts/systems project/scripts/resources`
  confirmed empty before and after this correction -- only
  `project/scripts/autoload/build_state.gd` (run-state autoload),
  `project/scenes/combat/combat_screen.gd`, and
  `project/tests/run_failure_state_test.gd` changed in `project/`, plus this
  doc and `docs/Phase_2_R5_Run_Rules_And_Determinism.md`.
- `grep` confirmed `is_vyra_boss_fight` no longer appears anywhere in
  `project/` after the rename to `is_unlimited_retry_encounter()`, and that
  the only three files referencing it before the change
  (`build_state.gd`, `combat_screen.gd`, `run_failure_state_test.gd`) were
  the only ones that needed updating -- `enemy_panel_test.gd` and
  `dashboard_header_test.gd` only reference the
  `"route.gilded_serpent.vyra"` id string directly (for map-node lookups
  unrelated to the retry rule), not the renamed function, so they needed no
  changes.
- All ten requested checks run serially with distinct `--log-file` paths
  (`user://logs/retryfix_<name>.log`), each verified by its printed "...
  check: OK" pass line (not exit code alone, consistent with this project's
  documented `_require()` exit-code-masking caveat) in addition to exit code
  0:
  - `run_failure_state_test` -- "Run failure state check: OK". Printed
    section order confirms the new coverage: first-encounter unlimited
    retries (5 losses/retries on encounter index 0, all `FIGHT_LOSS_RETRY`),
    the pre-existing RETRY BUG regression block (still passing, unaffected),
    winning the first encounter to advance to encounter index 1, a
    second-Tavern-encounter control (one do-over then
    `ADVENTURE_RESTART_REQUIRED`), the Portly-Cook contract retry block, a
    Vyra control (one do-over, then `CONTRACT_FAILED` on second loss), the
    non-Vyra Portly Cook control repeated against the fresh contract instance,
    and contract victory.
  - `combat_screen_test` -- "P2 UI restructure end-to-end check: OK".
  - `run_outcome_presentation_test` -- "Run outcome presentation check: OK"
    (confirms `_apply_outcome_presentation()`'s retargeted status-text branch
    didn't break any of the four presented outcomes).
  - `combat_playback_test` -- "Combat playback check: OK".
  - `save_load_ui_test` -- "P2:R6:T4 save/load UI hooks check: OK".
  - `engine_mechanics_test` -- "P2:M5 T0 engine mechanics check: OK".
  - `combat_test` -- ends with `Result: WIN` and no printed errors (this
    file has no explicit "check: OK" line; its pass signal is the absence of
    `push_error` output plus the summary block, consistent with how prior
    R5 passes verified it).
  - `deterministic_replay_test` -- "Deterministic replay check: OK".
  - `contract_offer_flow_test` -- "Contract offer flow check: OK".
  - `contract_route_data_test` -- "Contract route data check: OK".
  - Every run's only extraneous output was the known benign
    ObjectDB/resource cleanup warnings at shutdown (`WARNING: 8 ObjectDB
    instances were leaked at exit` / `ERROR: 7 resources still in use at
    exit`), the same warnings every other test run in this project's history
    prints and treats as non-fatal.
- No new `class_name` was introduced (a rename, not a new class), so no
  editor class-cache rescan was needed.
