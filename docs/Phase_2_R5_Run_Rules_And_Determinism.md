# P2:R5 - Run Rules And Determinism

## Purpose

Track the work for **P2:R5 - Run Rules And Determinism**.

The goal is to restore the run-level rules that made Phase 1 testable and
reproducible: visible Adventure seed, deterministic combat/shop/reward RNG,
failure/do-over behavior, contract failure, and final run-state transitions.

Scope expansion confirmed 2026-07-17: R5 also includes Rogue tree/proc parity
work that directly affects deterministic run behavior. Shadow should be seeded
and enabled as the third Rogue subclass, and the missing Thief
`Opportunity Strikes` trigger should be implemented before the deterministic
RNG audit is closed. This keeps the Phase 2 target aligned with Phase 1 Rogue
adventure parity instead of shipping R5 with known build-path gaps.

## Exit Criteria

P2:R5 is complete when:

- A run has a visible seed.
- Combat RNG, generated gear, reward/shop offers, and proc behavior derive
  from deterministic run context.
- Replaying the same seed/build/path produces reproducible outcomes.
- First-failure do-over behavior is implemented or a documented Project Bane
  revision replaces it.
- Second failure / contract failure / victory transitions are represented.
- Shadow is available as a Rogue primary/secondary tree with its required
  innate poison and talent mechanics.
- Opportunity Strikes uses the same triggered-skill system as other procs.
- Headless tests cover deterministic replay and failure-state transitions.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R5:T1 | Confirm Rule Scope | Phase 1 run rules translated into Project Bane decisions | Complete |
| P2:R5:T2 | Add Shadow Tree Parity | Shadow data, innate poison, talents, skills/effects, and UI availability | Complete |
| P2:R5:T3 | Implement Opportunity Strikes Proc | Thief trigger behavior uses generic triggered-skill support | Complete |
| P2:R5:T4 | Add Adventure Seed State | Seed visible and stored in run state | Complete |
| P2:R5:T5 | Define RNG Contexts | Combat, shop, reward, proc RNG derive from stable context | Complete |
| P2:R5:T6 | Implement Failure Tracking | Per-encounter failure/do-over state | Complete |
| P2:R5:T7 | Implement Run Outcomes | Contract failed, adventure restart, and contract victory states | Complete |
| P2:R5:T8 | Wire UI Feedback | Loss/victory/do-over/failed-run states are clear to player | Complete |
| P2:R5:T9 | Audit Proc Determinism | Triggered skills and special gear use deterministic RNG | Complete |
| P2:R5:T10 | Add/Update Tests | Shadow parity, deterministic replay, proc RNG, and failure transitions verified | Complete |
| P2:R5:T11 | Update Docs | Final Rogue parity/run-rule decisions documented | Complete |

## P2:R5:T1 - Confirm Rule Scope

Default Phase 1 parity rules:

- Adventure seed displayed during the run.
- Crit rolls deterministic for a given seed.
- Generated gear deterministic from run/route/shop context.
- Special procs deterministic for a given seed/context.
- First failure for an Adventure encounter gives a do-over.
- Failing the same encounter again restarts Adventure from class selection
  while preserving seed.
- Contract route failures mark the contract as failed.
- Defeating Vyra marks contract victory.

If any rule is revised for Project Bane, document the reason.

Rogue parity scope added to R5:

- Shadow is now explicitly in R5 because Phase 1 Rogue Adventure allowed
  Assassin, Thief, or Shadow as primary and secondary subclass choices.
- Shadow should be implemented only to the extent needed for Phase 1 Rogue
  Adventure parity: tree data, talents, innate poison, required skills/effects,
  primary/secondary choice availability, build resolution, and tests.
- Opportunity Strikes should no longer remain a deliberate content gap now
  that R4 added generic triggered-skill support for Mithril Karambit.
- R5 should audit deterministic behavior for Opportunity Strikes and the
  existing Knives Legendary pair.
- Wyvern Kriss and Mithril Karambit remain the required Phase 2 Legendary
  items because they are the authored Knives reward choices.
- Bandit Blade, Umbral Stiletto, and Bejeweled Push Dagger remain deferred
  unless route reward scope is explicitly expanded. Bejeweled Push Dagger's
  minimum-time proc should be covered by the deterministic RNG model if it is
  implemented later.

Confirmed 2026-07-17:

- R5 keeps the Phase 1 failure baseline rather than revising it: first failure
  on an Adventure encounter gives one do-over, failing the same encounter
  again restarts Adventure from class selection while preserving the seed,
  contract route failure marks the contract failed, and Vyra victory marks
  contract victory.

**Revised 2026-07-19 (combat-playback adjustment round 2 + retry bug pass) --
the first Tavern encounter gets unlimited retries:** the Phase 1/R5 baseline
above now applies to every other fight, including contract route nodes: every
other Tavern encounter and every contract fight gets exactly one do-over. A
second loss on a Tavern encounter forces an Adventure restart from class
selection with the seed preserved; a second loss on a contract route node
(Vyra included) resolves to `RunOutcome.CONTRACT_FAILED`. The very first
Tavern encounter (Mouthy Drunk, encounter index 0) is exempted from the
one-do-over limit: a loss there always resolves to
`RunOutcome.FIGHT_LOSS_RETRY` (never `ADVENTURE_RESTART_REQUIRED`), no matter
how many times it's already been attempted, so the player can keep retrying it
indefinitely without being forced back to class selection. Reason: it's the
very first fight of the Adventure, and giving new players extra leeway to
learn the combat/build loop right at the start -- rather than at the endgame
Vyra boss fight -- is where that leeway is actually useful. Implemented in
`BuildState.finish_fight()`/`is_unlimited_retry_encounter()` (checks
`current_encounter_index == 0` and that the fight is a genuine Tavern
encounter, not a contract route node). `encounter_failure_counts` is still
incremented for the first encounter on every loss for bookkeeping/telemetry
-- it's just never consulted to force a restart for that specific encounter.
This was revised during the R8 exported-build smoke pass after playtesting
confirmed that contract route fights should use the same one-retry allowance
as non-initial Tavern fights, with contract failure only on the second loss.
See `docs/Phase_2_R8_Playtest_Build.md` for the export smoke verification.
- R5 keeps the Phase 1 seed baseline: Adventure has a visible run seed, combat
  rolls and proc rolls derive from deterministic run context, and generated
  shop/reward gear derives from stable run/contract/route/slot/tier/option
  context.
- Shadow is not Phase 3 scope. It is Phase 1 Rogue Adventure parity and should
  be implemented before R5's deterministic replay audit is considered done.
- Opportunity Strikes is not deferred anymore. It should use the same generic
  triggered-skill model added for Mithril Karambit in R4.
- Legendary scope remains intentionally narrow for R5: Wyvern Kriss and
  Mithril Karambit are required because they are the authored Knives reward
  choices. Bandit Blade, Umbral Stiletto, and Bejeweled Push Dagger remain
  deferred unless route reward scope is deliberately expanded.

Recommended implementation order after T1:

1. `P2:R5:T2` - Add Shadow tree parity.
2. `P2:R5:T3` - Implement Opportunity Strikes proc.
3. `P2:R5:T4` - Add visible Adventure seed state.
4. `P2:R5:T5` - Define deterministic RNG contexts for combat, proc, shop, and
   reward generation.
5. `P2:R5:T6` through `P2:R5:T8` - Implement failure tracking, explicit run
   outcomes, and player-facing feedback.
6. `P2:R5:T9` - Audit proc determinism across Opportunity Strikes and the
   existing Knives Legendary pair.
7. `P2:R5:T10` - Add/refresh focused and dashboard tests.
8. `P2:R5:T11` - Close out docs and roadmap status.

## P2:R5:T2 - Add Shadow Tree Parity

Seed and enable Shadow as the third Rogue tree:

- Add Shadow subclass data and talents.
- Enable Shadow in primary subclass selection.
- Enable Shadow as a valid post-Tavern secondary tree choice.
- Add Shadow innate poison: if Shadow is one of the selected trees, Stab and
  Heavy Slash apply `+1` poison stack.
- Add required Shadow skills/effects for the Phase 1 talent set, including
  poison resistance reduction if needed by seeded talents.
- Preserve existing Assassin/Thief behavior and two-tree allocation rules.

## P2:R5:T3 - Implement Opportunity Strikes Proc

Replace the remaining Thief content gap:

- Opportunity Strikes should give Quick Cut a `20%` chance to trigger Rending
  Slash.
- The triggered Rending Slash should resolve immediately and consume no cast
  time, matching the generic triggered-skill behavior added in R4.
- The trigger roll should be routed through the same deterministic proc RNG
  context used by special gear.

## P2:R5:T4 - Add Adventure Seed State

Add run seed state that can be:

- Created for a new run.
- Displayed to the player.
- Reused on restart where appropriate.
- Saved later by P2:R6.

Decide whether seed entry belongs on the title/adventure setup screen or a
future run setup overlay.

## P2:R5:T5 - Define RNG Contexts

Avoid ad hoc `randomize()` in player-facing Adventure behavior.

Define stable RNG context inputs for:

- Combat crits.
- Triggered skills.
- Minimum-time procs.
- Shop offer generation.
- Reward gear generation.
- Route reward choices.

The same seed/path/context should produce the same outputs.

Implemented 2026-07-17:

- Added `RunRng`, a named-context RNG helper that derives stable seeds from
  the visible Adventure seed, a context name, and explicit stable parts.
- Current contexts:
  - `combat`: Adventure seed plus current encounter or route fight key.
  - `shop_offer`: Adventure seed plus reward source, shop round, and
    initial/reroll state.
  - `reward_choice`: Adventure seed plus current encounter or route node,
    reward tier, and generated option context.
- Dashboard combat now resolves with `BuildState.current_combat_rng_seed()`
  instead of the raw Adventure seed.
- Tavern shop offers and generated reward choices now derive from the visible
  Adventure seed instead of local hardcoded seed formulas.
- `GearGenerator.generate()` accepts an optional stable generated item ID so
  shop and reward items can be reproduced by context. Existing direct
  generator calls keep their previous random-ID behavior.

## P2:R5:T6 - Implement Failure Tracking

Track failures at the right granularity:

- Current encounter or route node.
- Whether the do-over has already been used.
- Whether the run is still active, failed, or restarting.

The UI should return the player to build editing after the first loss where
the do-over rule applies.

## P2:R5:T7 - Implement Run Outcomes

Represent outcomes explicitly:

- Fight win.
- Fight loss with do-over available.
- Fight loss with run restart.
- Contract failed.
- Contract victory.
- New run/restart from class select.

Avoid encoding these only as label text in a panel.

## P2:R5:T8 - Wire UI Feedback

The player should immediately understand:

- Why they lost.
- Whether they can edit and retry.
- Whether the run/contract is over.
- Which action continues the run.
- Whether seed is preserved.

## P2:R5:T9 - Audit Proc Determinism

If P2:R4 added proc/special item mechanics, make sure they use deterministic
RNG:

- Opportunity Strikes.
- Mithril Karambit triggers.
- Bejeweled Push Dagger minimum-time proc, if implemented.
- Other Legendary effects as needed.

## P2:R5:T10 - Add/Update Tests

Tests should cover:

- Shadow can be selected as a primary and secondary Rogue tree.
- Shadow innate poison affects Stab and Heavy Slash only when Shadow is active.
- Shadow talents and required skills/effects resolve through the normal build
  and combat systems.
- Opportunity Strikes can trigger Rending Slash.
- Same seed/build/path produces same combat result.
- Different seed can produce different crit/proc outcomes where expected.
- Shop/reward offers are reproducible.
- First failure returns to build editing.
- Second failure or contract failure routes to correct run outcome.
- Vyra victory marks contract victory.

## P2:R5:T11 - Update Docs

When complete:

- Update this checklist.
- Document Shadow implementation decisions and any revised mechanics.
- Document Opportunity Strikes behavior.
- Document run seed model and RNG contexts.
- Document failure/retry behavior.
- Update `docs/Phase_2_Milestones.md`.

## Implementation Notes

2026-07-17:

- `P2:R5:T1` is complete. The expanded R5 scope is confirmed against:
  - `docs/Phase_2_R1_Adventure_Parity_Audit.md`
  - `docs/Phase 1 Context Docs/Content_Library_Reference.md`
  - `docs/Phase 1 Context Docs/Current_Mechanics_Reference.md`
  - `docs/Phase_2_R4_Contract_Route_Parity.md`
- Confirmed R5 now starts with Rogue parity completion before seed/failure
  implementation: Shadow, then Opportunity Strikes.
- Confirmed no new Legendary reward scope is added by R5 beyond deterministic
  auditing of the current Knives pair.

2026-07-17:

- `P2:R5:T2` is complete. Shadow is now seeded and enabled as the third Rogue
  subclass tree.
- Added generic `SkillAugment` support on `SubclassTree` so tree-level skill
  changes can be data-driven. Shadow uses this to give Stab and Heavy Slash
  `+1` poison stack when Shadow is one of the selected trees.
- `BuildResolver.resolve_unlocked_skills()` now clones unlocked skills and
  applies selected-tree augments before rotation filtering. Rotation filtering
  now compares skills by stable `id` so cloned/augmented skills still match
  the player's stored rotation choices.
- Added generic `PoisonResistanceReductionEffect` and
  `StackScalingPhysicalDamageEffect` support. Combat now tracks active poison
  stacks and current poison resistance through the fight timeline so Beguiling
  Strike and Death Strike can resolve through normal skill effects.
- Added Shadow content:
  - `project/data/subclass_trees/shadow.tres`.
  - Shadow talents under `project/data/talents/shadow/`.
  - Beguiling Strike and Death Strike under `project/data/skills/`.
- Enabled Shadow in primary subclass selection by adding it to
  `project/data/classes/rogue.tres` and removing the disabled Shadow card.
- Shadow is also available as a post-Tavern secondary tree through the
  existing secondary subclass modal.
- Updated talent-panel intrinsic text so tree skill augments are visible to
  the player.

2026-07-17:

- `P2:R5:T3` is complete. Thief's Opportunity Strikes now uses the generic
  `TriggeredSkillEffect` path added in R4.
- `Talent` resources can now contribute triggered skills through
  `triggered_skill_effects`, and `BuildResolver.resolve_stats()` routes
  selected talent triggers into `PlayerStats.triggered_skill_effects`
  alongside gear triggers.
- `TriggeredSkillEffect` now has optional `source_skill_ids`. Empty source
  filters preserve existing gear behavior, while Opportunity Strikes limits
  its roll to `skill.quick_cut`.
- `project/data/talents/thief/opportunity_strikes.tres` now gives Quick Cut a
  `20%` chance to immediately trigger Rending Slash with no cast-time cost.
  Rending Slash's existing physical damage and armor reduction resolve through
  the normal triggered-skill effect path.

2026-07-17:

- `P2:R5:T4` is complete. Adventure seed state now lives in `BuildState` as
  `adventure_seed`, defaults to the Phase 1 baseline seed `1`, and can be set
  through `set_adventure_seed()`.
- `BuildState.reset()` now accepts an optional preserve flag so later
  seed-preserving restart/failure behavior can keep the Adventure seed while
  resetting run progress.
- The active dashboard top bar displays the current seed as `Seed: n`.
- At T4 closeout, dashboard combat passed `BuildState.adventure_seed` directly
  into `CombatResolver.resolve()`, leaving full shop/reward/proc context
  derivation open for `P2:R5:T5`.

2026-07-17:

- `P2:R5:T5` is complete. Stable RNG context derivation now lives in
  `project/scripts/systems/run_rng.gd`.
- Combat, Tavern shop offers, generated reward choices, and generated
  shop/reward item IDs now derive from the visible Adventure seed plus stable
  context inputs.
- Combat proc rolls remain part of the combat RNG stream because triggered
  skills resolve inside `CombatResolver` with the same fight-context RNG as
  crits. `P2:R5:T9` should specifically audit Opportunity Strikes and the
  Knives Legendary pair against this model.
- The next active R5 task is `P2:R5:T8 - Wire UI Feedback`, followed by
  `P2:R5:T9 - Audit Proc Determinism`.

2026-07-17:

- `P2:R5:T6` is complete. Failure tracking is now keyed by stable fight
  context: Tavern encounters use `encounter:<index>`, and contract route
  fights use the route node id even after the run reaches a terminal state.
- First Tavern failure sets an explicit do-over outcome and returns the player
  to build editing through the existing retry action.
- Failing the same Tavern encounter a second time sets an explicit
  seed-preserving Adventure restart outcome and clears the build lock.
- Contract route fights now use the same one-retry allowance as non-initial
  Tavern encounters. The first loss returns to build editing through the retry
  action; the second loss sets an explicit contract-failed outcome while
  preserving the failed contract/node context for feedback.
- `P2:R5:T7` is complete at the state-model level. `BuildState` now has a
  `RunOutcome` enum for fight win, fight loss with retry, Adventure restart
  required, contract failed, and contract victory. Vyra victory routes through
  the contract-victory outcome instead of being inferred only from label text.
- The dashboard now exposes a `Restart Adventure` action for terminal failure
  states, and `game_root` handles that action by resetting run progress while
  preserving the visible Adventure seed and returning to class select.

2026-07-17:

- `P2:R5:T8` is complete. `combat_screen.gd` now has a single
  `_apply_outcome_presentation(outcome)` mapping from `BuildState.RunOutcome`
  to a headline label, body text, and button state, replacing the inline
  `if/elif` text assignments that previously lived separately in
  `_on_fight_pressed()` (immediate losses) and `_advance_after_reward_or_shop()`
  (terminal wins after claiming a reward).
- Added a dedicated `_outcome_title_label` above the status line: `DEFEATED`
  and `CONTRACT FAILED`/`ADVENTURE OVER` use a loss color, `CONTRACT COMPLETE`
  uses the existing accent color. Exactly one of retry/restart is visible per
  outcome, and the restart button's label changes to `Start New Adventure`
  after a victory outcome instead of reusing failure-flavored "Restart"
  wording.
- Fixed a real presentation bug found while auditing this: after defeating
  Vyra, `_show_victory_banner()` hides `_status_label`, and nothing restored
  it before `_advance_after_reward_or_shop()` set the "Contract complete."
  text -- the label stayed invisible, so the player never actually saw the
  contract-victory message. `_apply_outcome_presentation()` now explicitly
  sets `_status_label.visible = true`, closing that gap.
- Contract victory (and the legacy Tavern-ladder-exhausted-without-a-contract
  `FIGHT_WIN` terminal case, which is not reachable through the current
  Tavern -> contract-offer flow but is still handled defensively) now also
  gets an explicit next action via the existing `Restart Adventure`
  button/signal rather than leaving only the always-present header "Return to
  Main Menu" control as the way to continue.

2026-07-17:

- `P2:R5:T9` is complete. Audit scope was Opportunity Strikes and Mithril
  Karambit's two triggers -- the only two proc/trigger mechanics that exist in
  data (`grep` for `triggered_skill_effects` across `project/data/` returns
  only `talents/thief/opportunity_strikes.tres` and `gear/mithril_karambit.tres`).
  Wyvern Kriss is pure stat modifiers (bonus poison stacks, poison damage,
  tick-interval cadence) with no roll involved, so it is out of scope. Bejeweled
  Push Dagger's minimum-time proc remains unimplemented and stays out of scope
  per the R5:T1 Legendary decision.
- Traced both in-scope triggers end to end: `Talent.triggered_skill_effects`
  and `GearItem.triggered_skill_effects` are collected into
  `PlayerStats.triggered_skill_effects` by `BuildResolver.resolve_stats()`,
  then rolled in `CombatResolver`'s per-cast trigger loop using the single
  `RandomNumberGenerator` created once per fight from the `rng_seed` argument.
  No trigger path constructs its own RNG or calls `randomize()`; `rng` is
  threaded as a parameter through `_apply_skill_effects()` for both the
  originating cast and any triggered follow-up cast.
- Confirmed the combat seed itself is applied consistently: the only
  non-test call site for `CombatResolver.resolve()` is
  `combat_screen.gd`'s dashboard fight handler, and it passes
  `BuildState.current_combat_rng_seed()`, which derives from the visible
  Adventure seed plus the stable fight-context key
  (`RunRng.CONTEXT_COMBAT` + `encounter:<index>` or the route node id). There
  is no code path where combat resolves against an ad hoc or unseeded RNG.
- Checked for RNG order-dependence: `PlayerStats.triggered_skill_effects` is a
  typed `Array` built by iterating `equipped_gear()` (fixed
  weapon/trinket/charm order, not equip-click order) and `selected_talents`
  in insertion order, so the sequence of `rng.randf()` trigger rolls is stable
  for a given final build config today. One latent (not currently active) risk
  was found: `selected_talents` reflects the order the player clicked
  talents, not a canonical order, so two playthroughs that reach the *same
  final talent selection* via a *different click order* could consume the
  RNG stream in a different sequence and diverge, if more than one
  talent-sourced trigger ever coexists. This cannot manifest today because
  Opportunity Strikes is the only talent-sourced trigger in the data set. No
  fix was made for this because it isn't reachable with current content and a
  speculative fix would be scope creep; flagged here so it's revisited if a
  second triggered talent is ever authored.
- Empirically verified with a throwaway (deleted after use) headless script
  running the same rotation/build through `CombatResolver.resolve()` at
  realistic (non-forced) trigger chances: identical seeds produced
  byte-identical cast-event signatures (timing, crit, damage, and which
  triggers fired), and differing seeds diverged, across both Opportunity
  Strikes and both Mithril Karambit triggers.
- Conclusion: no bug found. Proc determinism already holds by construction;
  this task closes as a confirm-and-document audit. `P2:R5:T10` should add a
  committed regression test for this (same-seed proc reproducibility), since
  no existing test currently exercises trigger chance at a non-1.0 value
  across a repeated seed.

2026-07-17:

- `P2:R5:T10` is complete. Shadow parity, Opportunity Strikes, RNG-context
  reproducibility (shop/reward), and failure/outcome transitions already had
  committed focused tests from `P2:R5:T2` through `P2:R5:T8`
  (`shadow_parity_test.gd`, `opportunity_strikes_test.gd`,
  `run_rng_context_test.gd`, `run_failure_state_test.gd`,
  `run_outcome_presentation_test.gd`). The one gap was the regression test
  flagged by the `P2:R5:T9` audit: nothing committed exercised full
  `CombatResolver.resolve()` same-seed/different-seed reproducibility at
  realistic (non-forced) crit and proc chance.
- Added `tests/deterministic_replay_test.gd` to close that gap. It checks two
  things:
  - A plain crit-chance-only replay (`placeholder_strike`/`placeholder_quick_cut`
    rotation against `placeholder_player`/`placeholder_dummy`, which has a
    nonzero unforced `crit_chance`): the same seed run twice produces an
    identical cast/tick signature, and five different seeds are not all
    identical.
  - A proc replay (Rogue/Thief with the unforced `0.2`-chance Opportunity
    Strikes talent, `skill.quick_cut` rotation, an 8000ms window matching the
    `P2:R5:T9` scratch check): the same seed run twice produces an identical
    signature (including which triggers fired), and five different seeds are
    not all identical.
  - The signature covers cast time, skill id, physical damage, crit flag,
    poison stacks applied, armor/poison-resistance reduction applied,
    triggered skill names, and all poison tick damage/stacks-remaining, so a
    divergence in ordering or trigger outcome fails the comparison even if
    total damage happened to match.

2026-07-17:

- `P2:R5:T11` is complete. This document's task checklist and per-task
  Implementation Notes sections already capture the final Shadow, Opportunity
  Strikes, run-seed/RNG-context, and failure/outcome decisions as each task
  closed, so no further mechanic write-up was needed here.
- Updated `docs/Phase_2_Milestones.md` to mark `P2:R5` complete and record
  `P2:R6 - Save/Load Persistence` as the next active milestone.

## Verification Notes

2026-07-17:

- Documentation/scope task only. No Godot runtime behavior changed.
- No Godot tests were run.
- Follow-up doc scan found remaining historical/audit statements that describe
  Shadow as disabled or previously scheduled for R4; these are retained as
  historical audit/current-state context. Forward-looking docs now identify
  Shadow and Opportunity Strikes as explicit R5 work.

2026-07-17:

- A sandboxed Godot test run hit the known local headless startup/log crash;
  focused and regression tests were rerun with escalated filesystem access.
- A headless editor scan was run to refresh Godot global class metadata after
  adding `SkillAugment`, `PoisonResistanceReductionEffect`, and
  `StackScalingPhysicalDamageEffect`.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://shadow_parity_r5_t2.log -s res://tests/shadow_parity_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://engine_mechanics_r5_t2.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://passive_allocator_r5_t2.log -s res://tests/passive_allocator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://combat_r5_t2.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://contract_offer_flow_r5_t2.log -s res://tests/contract_offer_flow_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://combat_screen_r5_t2.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://gear_generator_r5_t2.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://inventory_model_r5_t2.log -s res://tests/inventory_model_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://legendary_reward_r5_t2.log -s res://tests/legendary_reward_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://contract_route_data_r5_t2.log -s res://tests/contract_route_data_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file res://route_reward_choice_ui_r5_t2.log -s res://tests/route_reward_choice_ui_test.gd`
- The project-local log files from those runs were removed after verification.
- Timed-out test processes left several console Godot runners alive while
  holding log handles; stale `Godot_v4.7-stable_win64_console.exe` processes
  were terminated after the passing runs completed. GUI Godot editor processes
  were left untouched.

2026-07-17:

- A sandboxed focused Godot run hit the known local headless startup/log
  crash. Reruns used escalated filesystem access.
- The first focused test attempt exposed test-window assumptions around crits
  and Stab's execution time; the test was corrected to pin crit chance to `0`
  and give Stab enough window time to cast.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/opportunity_strikes_r5_t3.log -s res://tests/opportunity_strikes_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r5_t3.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/legendary_reward_r5_t3.log -s res://tests/legendary_reward_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r5_t3.log -s res://tests/passive_allocator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r5_t3.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r5_t3.log -s res://tests/combat_screen_test.gd`
- The checks still print the known ObjectDB/resource cleanup warnings after
  passing assertions.

2026-07-17:

- A sandboxed focused Godot run hit the known local headless startup/log
  crash. Reruns used escalated filesystem access.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_seed_state_r5_t4.log -s res://tests/run_seed_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r5_t4.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r5_t4.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/opportunity_strikes_r5_t4.log -s res://tests/opportunity_strikes_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r5_t4.log -s res://tests/combat_test.gd`
- The checks still print the known ObjectDB/resource cleanup warnings after
  passing assertions.

2026-07-17:

- A sandboxed focused Godot run hit the known local headless startup/log
  crash. Reruns used escalated filesystem access.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_rng_context_r5_t5.log -s res://tests/run_rng_context_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_seed_state_r5_t5.log -s res://tests/run_seed_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/opportunity_strikes_r5_t5.log -s res://tests/opportunity_strikes_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/gear_generator_r5_t5.log -s res://tests/gear_generator_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/route_reward_choice_ui_r5_t5.log -s res://tests/route_reward_choice_ui_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/legendary_reward_r5_t5.log -s res://tests/legendary_reward_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r5_t5.log -s res://tests/combat_screen_test.gd`
- The checks still print the known ObjectDB/resource cleanup warnings after
  passing assertions.

2026-07-17:

- A sandboxed focused Godot run hit the known local headless startup/log
  crash before assertions ran. Reruns used escalated filesystem access.
- Added `tests/run_failure_state_test.gd` for first-failure retry,
  second-failure Adventure restart requirement, seed-preserving reset,
  contract failure, and contract victory outcome state.
- Updated `tests/combat_screen_test.gd` to acknowledge that an intentionally
  losing contract-route fight now ends as `CONTRACT_FAILED` before the test
  manually restores a winning result surface for its existing reward/shop
  regression.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_failure_state_r5_t6.log -s res://tests/run_failure_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r5_t6.log -s res://tests/inventory_model_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_seed_state_r5_t6.log -s res://tests/run_seed_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_offer_flow_r5_t6.log -s res://tests/contract_offer_flow_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r5_t6.log -s res://tests/combat_screen_test.gd`
- The first dashboard regression attempt timed out and left stale Godot
  processes; those test-runner processes were terminated before the corrected
  rerun. Passing checks still print the known ObjectDB/resource cleanup
  warnings after assertions pass.

2026-07-17:

- Added `tests/run_outcome_presentation_test.gd` for `P2:R5:T8`. It drives the
  real `combat_screen.tscn` scene and covers all four presented outcomes:
  `FIGHT_LOSS_RETRY`, `CONTRACT_FAILED`, `ADVENTURE_RESTART_REQUIRED`, and
  `CONTRACT_VICTORY` (the last driven end-to-end through
  `_on_continue_pressed()` against the real Vyra route node, which is what
  caught and proves the fix for the `_status_label` visibility regression
  noted above).
- No rendered click-through was available in this sandboxed environment, same
  limitation already documented in `tests/combat_screen_test.gd`'s header
  comment; headless scene-tree tests driving the real scene through the same
  code paths real clicks use are this project's established substitute.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_outcome_presentation_r5_t8.log -s res://tests/run_outcome_presentation_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r5_t8.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_failure_state_r5_t8.log -s res://tests/run_failure_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/opportunity_strikes_r5_t8.log -s res://tests/opportunity_strikes_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r5_t8.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r5_t8.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/passive_allocator_r5_t8.log -s res://tests/passive_allocator_test.gd`
- The project-local log files from those runs were removed after verification.

2026-07-17:

- Added `tests/deterministic_replay_test.gd` for `P2:R5:T10`.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/deterministic_replay_r5_t10.log -s res://tests/deterministic_replay_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_r5_t10.log -s res://tests/combat_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/opportunity_strikes_r5_t10.log -s res://tests/opportunity_strikes_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r5_t10.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r5_t10.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_rng_context_r5_t10.log -s res://tests/run_rng_context_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_seed_state_r5_t10.log -s res://tests/run_seed_state_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/run_failure_state_r5_t10.log -s res://tests/run_failure_state_test.gd`
- The project-local log files from those runs were removed after verification.

2026-07-17:

- `P2:R5:T9` is a static-trace-plus-empirical-check audit; no production
  runtime code changed, so no full regression suite was rerun.
- A throwaway `scratch_proc_determinism_check.gd` script (never committed)
  ran `CombatResolver.resolve()` against a Rogue/Thief build with Opportunity
  Strikes and Mithril Karambit equipped, at their real (non-forced) trigger
  chances, across a fixed rotation and an 8000ms window:
  `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/scratch_proc_determinism.log -s res://scratch_proc_determinism_check.gd`
- Result: seed 1 run twice produced identical cast-event signatures (timing,
  crit, damage, and which trigger names fired); seed 42 run twice matched
  the same way; seed 2 diverged from seed 1, confirming both the "same seed
  reproduces" and "different seed can differ" halves of the exit criterion
  for procs specifically, not just crits.
- The scratch script and its log file were deleted after the check; `git
  status --short` was confirmed clean of both before moving on.
