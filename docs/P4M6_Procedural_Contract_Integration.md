# P4M6: Procedural Contract Integration

## Purpose

P4M6 connects generated procedural contract routes to the Adventure loop.

P4M5 created deterministic generated route graphs, generated encounter payloads,
biome presentation identity, sparse route previews, validation, tests, and an
isolated inspector. P4M6 completed the Adventure-loop integration: generated
contracts can be offered, accepted, routed through, committed into combat,
saved/loaded according to policy, retried or failed through normal Adventure
rules, and completed without regressing authored Gilded Serpent behavior.

This milestone is about integration and lifecycle policy. Full reward economy
tuning, route resource pacing, content breadth, modifiers, and long-term
anti-snowball balance remain later milestones unless a minimal placeholder is
required to make generated contracts playable.

## Milestone Goal

Make generated contract routes playable through Adventure mode while preserving
authored Gilded Serpent behavior.

By milestone close, Adventure should be able to create or present a generated
contract offer, accept it, display the generated route map, commit to generated
route nodes, start deterministic combat from generated encounter state, handle
failure/retry/restart/completion behavior, and save/load or explicitly reject
active generated route state according to a documented policy.

## Scope Notes

- Generated contracts should reuse the P4M5 `ContractDef` and
  `ContractRouteNode` generated-state fields rather than adding a competing
  route model.
- Authored contracts must continue to work with authored `Monster`, duration,
  reward, and fallback map-preview behavior.
- Generated contract map previews should remain sparse: biome, generated
  monster name, Normal/Elite/Boss encounter level, and visible archetype tags.
- Combat-facing and debug generated preview data should remain out of the route
  map, but available for combat setup, Balance Lab, reports, and tests.
- Generated route state should be materialized at a clear Adventure lifecycle
  point and should not silently change because a later generator version changes.
- Reward economy and final pressure tuning belong to P4M7. P4M6 may use
  conservative placeholder rewards/durations only where needed for integration.

## Current Focus

P4M6 is complete. Generated routes now have the core Adventure-loop integration:
generated offers, authored/generated coexistence, route-node commit, combat
setup, active generated save/load, failure/retry/restart/completion behavior,
real combat-screen route previews, and authored Gilded Serpent regression
coverage.

P4M7 is next: replace placeholder generated route rewards with tuned reward
tables, route resources, pressure scaling, and anti-snowball/dead-run checks.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M6-T1: Integration Requirements And Save Policy | Complete | Define the generated contract lifecycle before runtime wiring begins. | This doc records when generated contracts are created, when route choices commit, what active generated state is saved, how version mismatches are handled, and what behavior is deferred. |
| P4M6-T2: Contract Offer Source Abstraction | Complete | Remove the direct hardcoded dependency on one authored contract offer path. | Adventure can request contract offers through a small source/helper while Gilded Serpent still loads exactly as before. |
| P4M6-T3: Generated Contract Offer Creation | Complete | Create generated `ContractDef` offers for Adventure from seed/settings. | Entering the contract-offer flow can produce at least one deterministic generated contract with route metadata, previewable route nodes, selected biome, difficulty, and offer text. |
| P4M6-T4: Authored And Generated Offer Coexistence | Complete | Let generated contracts integrate without losing the authored regression baseline. | Gilded Serpent remains available and regression-protected while generated contract offers can be displayed, selected, or reached through the chosen transition path. |
| P4M6-T5: Generated Route Commit Flow | Complete | Allow players to commit to generated route nodes. | `BuildState` route selection accepts valid generated fight/elite/boss nodes using generated encounter state while preserving authored node validation. |
| P4M6-T6: Generated Combat Setup | Complete | Turn selected generated encounter payloads into deterministic combat encounters. | A selected generated route node can start combat with the expected generated monster identity, defenses, duration, preview data, and debug/report payload preservation. |
| P4M6-T7: Save/Load Active Generated Contract State | Complete | Preserve or reject generated contract state consistently across save boundaries. | Tests cover saving/loading during generated contract offer, accepted route, selected node/planning, and version-mismatch policy behavior. |
| P4M6-T8: Failure, Retry, Restart, And Completion Behavior | Complete | Make generated contracts follow Adventure outcome rules cleanly. | Generated normal/elite/boss fights support win progression, allowed retry, final loss, restart, and contract completion without corrupting route state. |
| P4M6-T9: Generated Route UI And Preview Verification | Complete | Verify generated route choices are readable in the real Adventure route UI. | The contract map displays generated biome, monster name, encounter level, archetype tags, branch choices, and selection state without exposing combat/debug internals. |
| P4M6-T10: Authored Contract Regression Gate | Complete | Protect Gilded Serpent and existing authored contract behavior from integration regressions. | Authored contract offer flow, route choices, combat setup, map fallback display, save/load, failure, retry, and completion tests still pass. |
| P4M6-T11: Documentation And Handoff To P4M7 | Complete | Close P4M6 with implementation notes and remaining economy/content work. | This doc and `docs/P4_DawnBringer_Overview.md` are updated with final status, verification results, known gaps, and P4M7 reward/economy handoff items. |

## Initial Design Direction

P4M6 should start conservatively:

- Keep Gilded Serpent as the authored regression baseline.
- Add generated contracts through a small offer source/helper rather than a
  large contract-content framework.
- Materialize generated route state when the contract offer is created, then
  keep that materialized state stable for the active run.
- Save both seed/settings/version provenance and materialized generated route
  node state for active generated contracts.
- Treat generator-version mismatches as an explicit policy case rather than
  silently regenerating active player state.
- Convert generated encounter payloads into combat-ready encounters at a clear
  point: route-node commit or combat setup.
- Defer reward economy depth to P4M7 unless minimal rewards/durations are
  necessary to make integration testable.

## Contract Lifecycle Questions

T1 answers:

- A generated contract is created when Adventure enters `CONTRACT_OFFER`, not
  earlier during Tavern progression. Offer creation materializes the full
  generated `ContractDef` route graph and generated encounter payloads.
- P4M6 starts with the authored Gilded Serpent baseline plus a generated-offer
  path behind the new offer source/helper. The helper should support multiple
  offers without introducing a broad content framework, but early tests may
  exercise one authored and one generated offer.
- Generated contract seeds derive from `BuildState.adventure_seed` plus a
  dedicated contract-offer roll key. The roll key must include a stable offer
  index or contract count and the route generator version. Tests may pass an
  explicit debug seed override, but production Adventure flow should not depend
  on ad hoc global randomness.
- Generated route difficulty derives from Adventure progress, starting with the
  first post-Tavern contract as `medium`. Later contracts can map completed
  contract count or Tavern round pressure to higher route difficulty, but deep
  route economy pressure remains P4M7.
- P4M6 may assign conservative placeholder durations and rewards only where
  generated fights need to be selectable, combat-ready, and reward-claimable.
  The placeholders should be deterministic and clearly marked as P4M7 handoff
  work.
- Active generated saves store both provenance and materialized state:
  seed/settings/version data from `ContractDef.generated_route_state()` and the
  full generated node graph state from each reachable
  `ContractRouteNode.generated_state()`.
- Saves must never silently regenerate active generated route state on load.
  Version mismatches are an explicit policy case: load materialized state when
  the saved schema is supported, annotate/report mismatches for UI/tests, and
  reject the generated active contract if the materialized state cannot be
  safely reconstructed.
- Restart behavior follows existing authored Adventure behavior: a terminal
  failed generated contract ends the run, and Restart Adventure starts fresh
  from pre-run state rather than preserving the failed generated offer.
- Failure and retry behavior mirrors authored contracts: each generated fight
  uses the normal one-retry policy, final failure ends the run as
  `CONTRACT_FAILED`, and a retry preserves the same active contract, route node,
  generated monster payload, and fight key.

## Generated Contract Lifecycle And Save Policy

### Existing Runtime Baseline

`BuildState.start_contract_offer()` currently hardcodes
`res://data/contracts/the_gilded_serpent.tres`, assigns it to
`active_contract`, sets `current_route_node` to the authored offer node, and
enters `RunPhase.CONTRACT_OFFER`.

`BuildState.accept_contract_offer()` advances from the offer node to the first
route node and enters `RunPhase.CONTRACT_ROUTE`. The current authored flow
expects an offer/intro node before the real branch map is shown.

`BuildState.choose_contract_route_node()` currently commits only direct
children of `current_route_node`, requires `node.monster != null` and
`node.duration_ms > 0`, then enters `RunPhase.PLANNING`. This is the boundary
where generated fight/elite/boss nodes must either already have combat-ready
`Monster`/duration/reward fields or be converted in a small deterministic
combat setup step before validation.

`SaveSystem` currently persists authored contracts and route nodes by
`resource_path`. Runtime-generated `ContractDef` and `ContractRouteNode`
instances do not have stable `.tres` paths, so P4M6-T7 must add generated
contract serialization rather than relying on the authored resource-path fields.

### Offer Creation And Materialization

Generated route state is materialized when the Adventure contract-offer flow
requests offers. This is the earliest point where the player can inspect or
accept a generated contract, so the route must be stable from that point
forward.

Materialization means calling `ContractRouteGenerator.generate(seed, settings)`
once for the offer and retaining the returned `ContractDef`, `offer_node`, all
reachable `ContractRouteNode` instances, generated encounter payloads,
`route_preview`, `combat_preview`, and `debug_preview`.

Generated contracts should not be regenerated on accept, route selection,
combat setup, retry, save/load, or UI refresh. Later generator changes must not
rewrite an active player's materialized route.

### Offer Source Shape

P4M6-T2 should introduce a small offer source/helper used by Adventure instead
of having `BuildState` load only `GILDED_SERPENT_CONTRACT_PATH`.

The helper should keep authored and generated construction separate:

- Authored offer entries load existing `ContractDef` resources by path.
- Generated offer entries call the route generator with deterministic seed and
  settings, then return the materialized `ContractDef`.
- The helper should expose enough metadata for UI offer cards, but it should not
  become a general content framework in P4M6.

Gilded Serpent remains available and regression-protected throughout P4M6.
Generated offers may be introduced beside it or through a debug/test transition
first, but the helper should not remove the authored baseline.

The title-screen Contract Test mode is an explicit P4M6 test bed. It skips the
Tavern setup, calls the same `BuildState.start_contract_offer()` and
`BuildState.accept_contract_offer()` path as the normal Adventure transition,
and lands in the contract-choice phase with a prepared Rogue baseline. Generated
offer, route UI, commit, combat setup, failure/retry/restart, and save/load work
should keep this shortcut updated alongside the normal Tavern-to-contract path.

### Seed, Settings, And Difficulty

Production generated contract seeds derive from:

- `BuildState.adventure_seed`;
- a dedicated contract-offer roll context;
- an offer index or completed-contract count;
- the route generator version;
- route difficulty/settings.

Tests may pass an explicit debug seed override to make route fixtures readable
and focused. Debug overrides should be part of helper input, not hidden global
state.

The first integrated generated contract should use `route_difficulty: "medium"`
unless a test explicitly supplies another setting. Future contracts can map
completed-contract count or route-economy pressure to `hard`, `ultra`, and
`nightmare`, but that tuning is P4M7/P4M8 work.

### Route Commit And Combat Setup Boundary

Route-node commit remains a `BuildState` responsibility. Generated nodes must
pass the same adjacency rule as authored nodes: only a direct child of
`current_route_node` can be committed.

Generated `START` nodes are map anchors and cannot be committed as fights.
Generated `FIGHT`, `ELITE`, and `BOSS` nodes are valid commit targets when they
have generated encounter payloads and can be converted to combat-ready state.

P4M6-T5/T6 should decide whether conversion happens just before commit or inside
combat setup. The policy requirement is that conversion is deterministic,
idempotent for the same materialized node, and preserves the original
generated payload plus combat/debug preview dictionaries for reports and tests.

### Minimal Rewards And Durations

P4M6 may use simple deterministic placeholder durations and rewards for
generated nodes so the route can be played end to end:

- Normal generated fights should receive a conservative duration and modest
  reward.
- Elite nodes may receive a slightly stronger placeholder reward.
- Boss nodes may receive a completion reward sufficient to exercise victory and
  reward-claim flow.

These placeholders must be documented in code/tests as P4M7 handoff items.
They should not attempt to solve route economy, anti-snowball checks, rest
nodes, pressure tuning, or reward preview language.

### Active Generated Save Format

P4M6-T7 should extend `SaveSystem` so an active generated contract can be saved
without requiring `.tres` resource paths.

The generated save payload should include:

- generated contract identity, display fields, offer text, and
  `generated_route_state()`;
- every reachable generated node's authored-compatible fields needed for route
  display and combat setup: `id`, `display_name`, `node_type`, `duration_ms`,
  reward placeholder data or reward provenance, and `generated_state()`;
- graph edges by generated node ID or stable node ID, using
  `outgoing_node_ids`;
- the current route node ID;
- claimed generated route reward IDs;
- active generated save schema version;
- saved route generator version, presentation table version, runtime monster
  generator version, and archetype library schema.

Authored contracts continue using resource-path persistence. Generated active
contracts should be stored in a separate field or tagged union so authored load
behavior stays unchanged.

### Save/Load Version Mismatch Policy

Generated active contract load has three outcomes:

- Compatible: reconstruct the materialized generated `ContractDef` and node
  graph from saved state, restore `active_contract`, restore
  `current_route_node` by saved node ID, and preserve combat/debug payloads.
- Supported mismatch: load materialized state because the saved schema can still
  be reconstructed, but record a mismatch notice/report so tests and debug UI
  can see that generator or table versions differ from current code.
- Unsupported mismatch: reject load cleanly and leave live `BuildState`
  untouched, matching `SaveSystem.load_run()`'s existing corrupt/incompatible
  save contract.

Unsupported mismatches include missing node graph data, missing selected current
node, generated encounter payloads that cannot be converted to combat-ready
state, or a generated save schema version newer than the running code supports.

Silent regeneration from seed/settings is not allowed for an active generated
contract save. Seed/settings are provenance and debugging aids; materialized
state is the player's run.

T7 implementation notes:

- `SaveSystem` keeps authored contract persistence on the existing
  resource-path fields.
- Active generated contracts use a separate `generated_active_contract` payload
  with schema version, current route node ID, claimed route reward IDs, contract
  identity/display fields, `generated_route_state()`, and all reachable route
  nodes.
- Pending contract offers are serialized as authored resource-path entries or
  generated materialized entries so a generated offer screen can survive a
  save/load boundary.
- Generated route nodes are reconstructed, reconnected from `outgoing_node_ids`,
  validated for combat-ready encounter payload support, and the selected
  fight/elite/boss node restores its deterministic `Monster` and duration.
- Supported generator/table/runtime/library version mismatches load the saved
  materialized state and append `generated_save_supported_mismatch:*` notices.
  Unsupported generated save schemas, missing graph data, missing current node,
  or invalid generated encounter payloads reject the load before mutating
  `BuildState`.

### Failure, Retry, Restart, And Completion

Generated contract fights follow authored contract outcome behavior unless a
later task explicitly changes the rule:

- First loss on a generated fight produces `FIGHT_LOSS_RETRY` and returns to
  planning through `retry_current_encounter()`.
- Retry keeps the same materialized contract, route node, fight key, generated
  encounter payload, and combat-ready monster.
- Second loss produces `CONTRACT_FAILED` and `RUN_ENDED`.
- Winning a generated node claims rewards through the same reward path and
  returns to `CONTRACT_ROUTE` when outgoing nodes remain.
- Winning a generated boss with no outgoing nodes produces `CONTRACT_VICTORY`.
- Restart Adventure after a terminal generated failure starts a new run and does
  not preserve the failed generated offer.

### Deferred Behavior

The following are intentionally deferred:

- tuned generated route rewards and resource economy;
- rest/resource nodes and route pressure tuning;
- long-term difficulty escalation across repeated generated contracts;
- expanded biome, modifier, elite, boss, and contract theme content;
- richer generated offer writing beyond the minimal copy needed for readable
  UI tests.

### T1 Verification

P4M6-T1 was verified by inspecting the current authored contract flow in
`BuildState`, existing generated-state helpers in `ContractDef` and
`ContractRouteNode`, the deterministic route generator output, generated route
preview tests, authored contract offer flow tests, and the current
resource-path-based `SaveSystem` behavior.

No Godot test run is required for T1 because it is a documentation and policy
task only. Balance Lab is not required until generated route state enters real
combat setup, reward pressure, reports, or timing-sensitive paths.

## P4M6-T2 Implementation Notes

`project/scripts/systems/contract_offer_source.gd` is now the small Adventure
contract offer source. In T2 it is intentionally authored-only: it loads the
Gilded Serpent `ContractDef` by path and exposes the same authored contract
resource to Adventure.

`BuildState.start_contract_offer()` now builds a stable offer context from
`adventure_seed` and asks `ContractOfferSource.first_contract_offer()` for the
active offer instead of directly loading the Gilded Serpent resource path. The
state transition remains unchanged: `active_contract` is assigned, the current
route node becomes `contract.offer_node`, the run enters `CONTRACT_OFFER`, and
lock/outcome/story flags are reset as before.

`ContractOfferSource.offer_context()` already carries future-facing fields for
T3 generated offers: source version, Adventure seed, offer index, completed
contract count, debug seed override, and settings. T2 does not consume those
fields beyond preserving them as stable helper input.

The source helper is the planned T3 insertion point for generated `ContractDef`
offer creation. Gilded Serpent remains the authored regression baseline and
should continue to load exactly as before.

Focused T2 verification:

- `project/tests/contract_offer_source_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_test_entry_test.gd`
- `project/tests/contract_route_data_test.gd`

## P4M6-T3 Implementation Notes

`ContractOfferSource.contract_offers(context)` now supports generated offers
when `include_generated` is true. The default `offer_context(adventure_seed)`
still returns authored Gilded Serpent only, preserving the normal Adventure and
Contract Test behavior until P4M6-T4 wires generated/authored coexistence into
the player-facing offer UI.

Generated offers are materialized by
`ContractRouteGenerator.generate(seed, settings)` through
`ContractOfferSource.generated_contract_offer()`. The generated offer seed is
deterministic from the Adventure seed, source version, route generator version,
offer index, completed contract count, generated offer index, and route
settings. A single generated offer can use `debug_seed_override` as its exact
route seed for focused tests and future Contract Test workflows.

T3 adds minimal generated offer identity after route materialization:

- `display_name` uses the selected biome, such as `Graveyard Contract`.
- `target_display_name` uses the generated boss route preview when available.
- `offer_text` includes the route difficulty and selected biome.

T3 does not change the contract overlay card list or force generated offers into
the live Adventure path. That authored/generated coexistence work is P4M6-T4.

Focused T3 verification:

- `project/tests/contract_offer_source_test.gd`
- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_test_entry_test.gd`

## P4M6-T4 Implementation Notes

`BuildState.start_contract_offer(context)` now materializes the full pending
offer list returned by `ContractOfferSource.contract_offers(context)`. The first
offer remains active by default, so the default authored-only Adventure and
Contract Test flows still start on The Gilded Serpent exactly as before.

`BuildState.pending_contract_offers`, `select_pending_contract_offer()`, and the
optional `accept_contract_offer(contract_id)` argument allow an opt-in generated
offer to coexist with authored offers and become the active accepted contract.
Pending offers remain available after acceptance so the player can preview a
route and return to the offer list before combat commitment.

`contract_overlay.gd` keeps the single-offer authored story path unchanged. When
multiple pending offers exist, the pitch step now opens an offer-choice card
list. Generated cards show the generated contract name, target, and route
difficulty summary; selecting one and proceeding accepts that contract. Authored
selection continues into the existing Vyra contract-card flow, while generated
selection can reach the route-map fallback with sparse generated route previews.
Generated route-node commit and generated combat conversion remain P4M6-T5/T6.

Focused T4 verification:

- `project/tests/contract_offer_source_test.gd`
- `project/tests/contract_offer_coexistence_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_test_entry_test.gd`

## P4M6-T5 Implementation Notes

`BuildState.accept_contract_offer()` now preserves the authored Gilded Serpent
transition to its secondary-choice hub while accepting generated contracts at
their generated `START` node. This lets the first generated branch choices be
previewed and committed rather than silently skipping the start of the generated
route graph.

`BuildState.can_commit_contract_route_node()` centralizes route commit
eligibility. Authored nodes still require an authored monster and positive
duration. Generated nodes are commit-eligible when the active contract has
generated route state, the candidate is an adjacent fight/elite/boss node, and
the candidate preserves a generated encounter payload. Selecting a generated
node enters `PLANNING`, but `can_start_current_fight()` still blocks combat
until P4M6-T6 converts that payload into a combat-ready monster/duration setup.

`map_overlay.gd` now uses the same `BuildState.can_commit_contract_route_node()`
helper for route-node selectability, keeping UI clicks and state mutation in
sync for authored and generated routes.

Focused T5 verification:

- `project/tests/generated_route_commit_flow_test.gd`
- `project/tests/contract_offer_coexistence_test.gd`
- `project/tests/contract_offer_source_test.gd`
- `project/tests/map_overlay_route_preview_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_test_entry_test.gd`

## P4M6-T6 Implementation Notes

`BuildState.choose_contract_route_node()` now prepares a generated route node
for combat at the commit point. Authored nodes pass through unchanged. Generated
nodes deserialize `generated_encounter_payload` with
`GeneratedMonsterDraft.from_dictionary()`, convert the draft with
`to_monster()`, assign the deterministic draft duration to `duration_ms`, and
use the combat/route preview monster name for player-facing combat identity.

The original `generated_encounter_payload`, `combat_preview`, `debug_preview`,
and sparse `route_preview` dictionaries remain on the route node after
conversion. This keeps combat setup deterministic while preserving the detailed
generated payloads needed by later Balance Lab/report/save-load work.

After commit, a generated route node can satisfy `can_start_current_fight()`
once the player has a non-empty rotation and locked build. Reward economy depth
remains deferred to P4M7; active generated save/load is now covered by P4M6-T7.

The title-screen Contract Test shortcut now starts a generated-only offer
context with two generated contracts and opens directly on the contract-card
choice list. Normal Adventure remains authored-first unless a generated offer
context is explicitly requested.

Contract offers remain pending while a player previews an accepted contract's
route map and its initial planning state. The map exposes a Back to Contracts
action before the first fight starts, allowing the player to inspect generated
routing risk, try the first combat node choice, and return to the offer cards.

Focused T7 verification:

- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/save_load_test.gd`
- `project/tests/generated_route_commit_flow_test.gd`
- `project/tests/generated_combat_setup_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_offer_coexistence_test.gd`

## P4M6-T8 Implementation Notes

`BuildState`'s existing authored outcome rules already apply to generated
contract route fights because generated route commits materialize a normal
combat-ready `current_route_node` with stable `id`, `Monster`, duration, and
payload metadata.

Focused T8 coverage now verifies:

- first generated route loss produces `FIGHT_LOSS_RETRY`;
- `retry_current_encounter()` preserves the materialized generated
  `ContractDef`, route node, fight key, generated encounter payload, monster,
  duration, and combat RNG seed;
- second generated route loss produces `CONTRACT_FAILED` and `RUN_ENDED`;
- `reset(true)`, the existing Adventure restart path, clears failed generated
  offers, contract state, route node state, claimed route rewards, and failure
  counts while preserving the Adventure seed;
- generated normal route wins can claim through `claim_current_reward()` and
  return to `CONTRACT_ROUTE` through `continue_after_win()` when outgoing nodes
  remain;
- generated boss wins can claim through the same reward path and then end the
  run with `CONTRACT_VICTORY`.

No `BuildState` code changes were required for T8.

Focused T8 verification:

- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/run_failure_state_test.gd`
- `project/tests/generated_route_commit_flow_test.gd`
- `project/tests/generated_combat_setup_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_offer_coexistence_test.gd`

Additional check:

- `project/tests/route_reward_choice_ui_test.gd` was run because T8 touches
  reward/continue surfaces. It still exits `0`, but it printed an existing
  masked assertion failure for authored Vyra selected-story text. This appears
  unrelated to generated outcome behavior and should be handled separately,
  ideally with that test's `_require` exit-code masking fixed.

## P4M6-T9 Implementation Notes

The existing `map_overlay.gd` generated preview path already renders
`ContractRouteNode.route_preview` as the sparse route-map view:

- biome;
- generated monster presentation name;
- Normal/Elite/Boss encounter level;
- archetype tags joined as a compact tag line.

T9 added a generic generated route schematic in `map_overlay.gd`. Generated
contracts now show the full reachable non-start route graph using each node's
`depth` and `lane`, draw graph edges between visible nodes, keep only immediate
next choices selectable, and leave future route nodes visible but disabled.

The real `combat_screen.tscn` coverage starts a generated-only contract offer,
accepts it, opens the real map overlay, validates full-route button coverage,
generated branch button text and selectability, selected route story/proceed
state, hidden combat/debug internals, Proceed-button commit, and Adventure
planning with a combat-ready generated route node and stable route fight label.

Focused T9 verification:

- `project/tests/generated_route_ui_preview_test.gd`
- `project/tests/map_overlay_route_preview_test.gd`
- `project/tests/generated_route_commit_flow_test.gd`
- `project/tests/contract_offer_coexistence_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/generated_combat_setup_test.gd`

## P4M6-T10 Implementation Notes

P4M6-T10 ran the authored Gilded Serpent regression gate after the generated
contract integration work from T1-T9. No runtime authored-contract code changes
were required.

`project/tests/contract_offer_flow_test.gd` had one stale assertion block for
the Portly Cook enemy panel. The current authored UI contract, already guarded
by `project/tests/combat_screen_test.gd`, keeps route pressure and reward
summary text out of the enemy detail panel while preserving HP, fight window,
armor, resistance, route-map reward labels, and outcome reward surfaces. The
test now matches that behavior.

Focused T10 verification passed outside the sandbox:

- `project/tests/contract_route_data_test.gd`
- `project/tests/map_overlay_route_preview_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_offer_source_test.gd`
- `project/tests/contract_offer_coexistence_test.gd`
- `project/tests/contract_test_entry_test.gd`
- `project/tests/save_load_test.gd`
- `project/tests/run_failure_state_test.gd`

## P4M6-T11 Closeout Notes

P4M6 closes with the generated contract integration path playable through the
core Adventure loop. Generated contracts can now be materialized by the offer
source, presented alongside authored offers when requested, accepted into the
route map, committed through valid generated fight/elite/boss nodes, converted
into deterministic combat-ready monsters, persisted as materialized generated
state, and resolved through win, retry, failure, restart, and completion flows.

The authored Gilded Serpent path remains the regression baseline. Its authored
route data stays generated-state-free, the route map still falls back to
authored display fields, and the existing Contract Window/Vyra flow still
enters Portly Cook/Door Guard planning correctly.

Final P4M6-T11 closeout verification passed outside the sandbox:

- `project/tests/generated_route_ui_preview_test.gd`
- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_route_data_test.gd`
- `project/tests/run_failure_state_test.gd`

Known non-blocking output remains unchanged: sandboxed Godot can hit the
`user://logs` startup crash before script execution, and successful
outside-sandbox runs still print Godot exit cleanup warnings.

P4M7 should take over reward and economy design. The generated integration still
uses conservative placeholder rewards/durations where needed to make routes
playable and testable; P4M7 should replace those placeholders with tuned reward
tables, route resources, pressure scaling, rest/resource nodes, anti-snowball
checks, dead-run recovery checks, and final reward preview language.

Pending offers are cleared only when the player starts the first contract
combat, which is the current Adventure-side contract commitment boundary.

Focused T6 verification:

- `project/tests/generated_combat_setup_test.gd`
- `project/tests/generated_route_commit_flow_test.gd`
- `project/tests/runtime_monster_generator_test.gd`
- `project/tests/contract_route_generator_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_test_entry_test.gd`
- `project/tests/map_overlay_route_preview_test.gd`
- `project/tests/contract_offer_coexistence_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/balance_lab_test.gd`

## Existing Integration Surfaces

- `project/scripts/autoload/build_state.gd` owns Adventure run phase,
  `active_contract`, `current_route_node`, contract offer start/accept, route
  node choice, fight start, failure, retry, and run outcome behavior.
- `project/scenes/game_root.gd` owns the title-screen Contract Test shortcut,
  which skips Tavern setup and enters the current contract flow through
  `BuildState.start_contract_offer()` and `BuildState.accept_contract_offer()`.
- `project/scripts/resources/contract_def.gd` stores contract identity plus
  generated route-level metadata and serialization helpers.
- `project/scripts/resources/contract_route_node.gd` stores authored route node
  state plus generated node metadata, generated encounter payloads,
  combat/debug previews, sparse route previews, and outgoing generated IDs.
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`
  creates deterministic generated `ContractDef` route graphs from seed and
  settings.
- `EncounterPreviewFormatter.format_generated()` provides sparse
  `contract_map`, combat-facing, and debug preview sections for generated
  encounters.
- `project/scenes/combat/map_overlay.gd` already consumes
  `ContractRouteNode.route_preview` when present and falls back to authored
  route display when absent.
- `project/scripts/tools/generated_route_inspector.gd` and
  `res://scripts/tools/inspect_generated_route.gd` can inspect generated routes
  before and after Adventure materialization.

## Verification Notes

Run Godot 4.7 from:

`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`

Run Balance Lab when generated contract integration touches:

- combat setup or generated monster materialization;
- combat timing or event ordering;
- build resolution;
- skill, talent, gear, monster, or enemy data;
- generated encounter difficulty;
- route reward pressure;
- poison, proc, duration, or DPS behavior;
- reports or debug payload preservation.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Known local runner issue:

- Sandboxed Godot runs may hit the known `user://logs` startup crash before
  script execution. Recent milestone verification passed when run outside the
  sandbox.

Final focused verification covered:

- Generated contract offer integration tests.
- Generated route commit tests.
- Generated combat setup tests.
- Save/load generated active contract tests.
- Version-mismatch policy tests.
- Failure/retry/restart/completion tests for generated contracts.
- Map overlay generated route preview tests.
- Contract Test shortcut tests for generated and authored contract entry.
- Contract route generator and generated route matrix tests.
- Authored Gilded Serpent contract offer flow tests.
- Authored route data and map fallback regression tests.
- Balance Lab tests where generated route state entered real combat or reports.

## Exit Criteria

P4M6 is complete:

- Generated contract routes can enter Adventure contract offers through the
  chosen source/lifecycle path.
- Players can accept a generated contract and navigate its generated route map.
- Generated fight/elite/boss nodes can be selected and used to start
  deterministic combat.
- Active generated contract state has a documented and tested save/load policy.
- Generator/schema/version mismatch behavior is documented and tested.
- Generated contract failure, retry, restart, and completion behavior is covered.
- Authored Gilded Serpent behavior remains intact.
- Reward economy and content-expansion gaps are clearly handed off to P4M7/P4M8.
- This doc and `docs/P4_DawnBringer_Overview.md` are updated with final status,
  verification results, known gaps, and next-milestone handoff notes.

## Follow-Ups For P4M7

- Replace placeholder generated node rewards with tuned route reward tables.
- Add route economy pressure, resource pacing, rest/resource nodes, and
  anti-snowball/dead-run checks.
- Balance generated route difficulty against completed-contract pressure.
- Expand reward preview language once route economy decisions are real.
- Run Balance Lab gates for route pressure, reward pacing, and generated combat
  outcomes.
