# P4M7: Rewards, Resources, And Route Economy

## Purpose

P4M7 turns generated contract routes from playable combat paths into a
meaningful Adventure economy.

P4M6 completed generated contract integration: generated contracts can be
offered, accepted, routed through, committed into deterministic combat,
saved/loaded as materialized route state, retried or failed through normal
Adventure rules, and completed without regressing authored Gilded Serpent
behavior.

This milestone replaces conservative placeholder generated rewards and
durations with tuned route reward tables, combat-route pressure scaling, and
anti-snowball/dead-run checks. The goal is to make route choices matter as
economic decisions as well as matchup decisions without adding non-combat node
systems before the core combat balance is stable.

## Milestone Goal

Make generated contract routes provide readable, deterministic, and tunable
risk/reward progression.

By milestone close, generated combat route nodes should grant rewards from a
real route economy model, preview those rewards clearly in the route map, scale
pressure and reward value across route depth and Adventure progress, and avoid
obvious runaway or hopeless route states.

## Scope Notes

- Generated reward and route economy work should build on the P4M5/P4M6
  generated route state model rather than adding a competing contract system.
- Authored Gilded Serpent behavior remains the regression baseline.
- Generated route previews should stay sparse and player-readable. Reward
  summaries may be visible on the route map, but detailed combat/debug
  generated data should remain out of map previews.
- Reward generation must be deterministic for a materialized generated
  contract route and stable across save/load.
- Balance Lab should be treated as the verification gate for reward pacing,
  route pressure, generated combat outcomes, and matchup-path viability.
- Broad content expansion, biome/theme breadth, new elite/boss families, and
  modifier variety belong to P4M8 unless a minimal addition is required for
  economy validation.
- Non-combat nodes, route-local resources, consumables, mystic upgrades,
  crafting/transmutation, shop/event nodes, and hidden encounters are deferred
  until later phases after monster/contract balance, gear attributes, character
  talent trees, and shop/run-upgrade systems are more mature.

## Current Focus

P4M7-T1 through P4M7-T10 are complete. The milestone now has economy
vocabulary, combat-node reward definitions, pressure rules, failure-mode
definitions, verification gates, a deterministic generated reward table,
player-facing reward preview language, and a documented deferral for
non-combat nodes and route-local resources. Generated route pressure now scales
across node depth, node role, route difficulty, and completed-contract count,
with raw over-Nightmare pressure preserved separately from capped Monster
Difficulty. Generated combat nodes now also materialize pressure-axis metadata
for dead-run route checks, and Balance Lab now reports generated route economy
health across deterministic route samples. Generated reward claims, duplicate
claim guards, pending generated gear choices, retries, failures, restarts, boss
victories, and active generated save/load now have focused lifecycle regression
coverage. P4M7 is closed and handed off to P4M8 content expansion.

## Status Key

- Not Started: planned, no implementation work yet.
- In Progress: active design or implementation work.
- Blocked: cannot proceed without a decision or external fix.
- Complete: implemented, verified, documented, and committed.

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P4M7-T1: Economy Design And Acceptance Criteria | Complete | Define route economy goals before implementation. | This doc records reward categories, deferred route resources, node economy roles, pressure rules, anti-snowball/dead-run definitions, tuning targets, and verification gates. |
| P4M7-T2: Generated Reward Table Model | Complete | Replace placeholder generated node rewards with deterministic tuned reward tables. | Generated normal, elite, and boss nodes receive rewards from tunable tables based on node type, route difficulty, route depth, pressure, and route context. |
| P4M7-T3: Reward Preview Language | Complete | Make generated route rewards readable before commitment. | Route map previews summarize expected reward value and type without exposing combat/debug internals or overcrowding the sparse preview model. |
| P4M7-T4: Non-Combat Node Deferral And Economy Boundaries | Complete | Document why route-local resources and non-combat nodes are deferred. | This doc records the deferral decision, future candidate node types, dependency gates, and the updated P4M7 scope so implementation can continue with combat-node pressure and reward scaling. |
| P4M7-T5: Pressure Scaling Across Route Depth | Complete | Tune pressure and reward value across generated routes and Adventure progress. | Later route nodes and later contracts create meaningfully higher pressure and reward stakes without breaking deterministic combat resolution. |
| P4M7-T6: Anti-Snowball Checks | Complete | Prevent strong generated runs from compounding into trivial contracts too quickly. | Generated routes materialize raw difficulty, capped Monster Difficulty, and overflow Contract Pressure metadata, and validation notices flag obvious pressure/reward mismatches before rewards outpace route pressure. |
| P4M7-T7: Dead-Run Route Checks | Complete | Prevent weak or mismatched generated runs from being forced into hopeless routes. | Generated nodes materialize pressure axes, and route validation can flag identical-axis branches, all-path pressure-axis domination, and low-prep shortest paths before high-pressure bosses. |
| P4M7-T8: Balance Lab Economy Coverage | Complete | Add automated verification for route economy and pressure behavior. | Balance Lab now samples generated contract routes and fails on blocking economy notices, debug preview leaks, missing rewards, missing overflow pressure, unchanged completed-contract pressure, or missing pressure-axis diversity. |
| P4M7-T9: Adventure Outcome And Save/Load Regression | Complete | Verify economy state survives normal generated contract lifecycle events. | Generated reward claims, retries, failures, restarts, boss victories, and save/load behavior remain deterministic and do not regress authored Gilded Serpent behavior. |
| P4M7-T10: Documentation And Handoff To P4M8 | Complete | Close the milestone with implementation notes and content-expansion handoff. | This doc and `docs/P4_DawnBringer_Overview.md` are updated with final status, verification results, known tuning gaps, and P4M8 content-expansion handoff items. |

## Initial Design Direction

P4M7 should start from explicit balance targets:

- Define the reward economy vocabulary before implementing reward tables.
- Treat normal fights, elite fights, and boss fights as distinct route economy
  roles for P4M7. Defer non-combat economy roles until later systems give them
  enough design surface.
- Keep generated rewards deterministic from materialized route state.
- Prefer data-driven or table-like reward definitions that can be tuned without
  rewriting route-generation logic.
- Preserve route readability: players should understand broad reward tradeoffs
  from the map before committing.
- Use route validation and Balance Lab checks to catch pressure spikes,
  runaway snowballing, and dead-run states.
- Keep Gilded Serpent authored behavior protected throughout tuning.

## P4M7-T1 Economy Model

Generated contract economy should make route choices read as "take pressure now
for a better reward or better matchup position later" rather than "always
choose the highest payout." The route map should support three readable
decisions:

- Fight a safer normal node for steady growth.
- Take an elite or shorter path for higher value with higher pressure.
- Choose branches with different defensive matchups and reward profiles before
  a spike or boss.

P4M7 should initially reuse `EncounterReward` for claimable rewards and add only
the smallest generated-route metadata needed to describe economy roles,
preview labels, and materialized reward identity. Existing fields on
`ContractRouteNode` (`reward`, `reward_quality_label`, `reward_summary`, and
`route_preview`) are the preferred preview and claim surfaces. New state should
be materialized into generated route state and saved/loaded; rewards must not be
silently regenerated from only the original seed after acceptance.

### Reward Categories

Generated nodes may grant these P4M7 reward categories:

- Gold: immediate spendable currency, lowest risk to add, useful for shops and
  bounded route payouts.
- Talent points: scarce build acceleration; should appear mostly on bosses,
  selected elites, or late/high-pressure route nodes.
- Generated gear choices: primary build-shaping reward. Use tier and slot pools
  rather than fixed generated items in the route table, then generate choice
  items through the existing reward-claim path.
- Fixed authored gear: allowed only for regression/authored content in P4M7,
  not as the default generated economy tool.
- Shop access: a later economy reward, not a routine P4M7 payout. It should be
  used sparingly once shop, consumable, and run-upgrade systems are ready to
  absorb it.
- Route resources: deferred contract-local counters such as supplies or
  pressure debt. These are not inventory rewards and should not be implemented
  until later non-combat nodes have clear balance dependencies.

Generated rewards should avoid broad new reward families in P4M7 unless Balance
Lab coverage requires them. Legendary choices remain boss/climax-tier rewards,
not normal route filler.

### Immediate, Choice, And Pressure Rewards

Immediate rewards are gold and talent points that apply when the reward is
claimed. Choice rewards are generated gear choices and later legendary choices.
Shop access, route resources, and non-combat pressure-affecting rewards are
deferred until the systems around shops, consumables, run upgrades, and
crafting are mature enough to make those choices meaningful.

Reward claims should continue flowing through `BuildState.claim_current_reward`
where possible so existing inventory, pending gear choice, gold, talent point,
and shop behavior remains the central authority.

### Deferred Route Resources And Non-Combat Nodes

P4M7 will not introduce generated contract-local resource state or non-combat
nodes. The earlier candidate resources remain useful future vocabulary, but
they are explicitly deferred because the current maps may not yet be long or
wide enough to make non-combat stops interesting, the player does not have
health to heal, and shops/consumables/mystic upgrades/crafting need better
balance foundations before they become route nodes.

Future route resources may include:

- Supplies: a recovery budget spent by rest/stabilization nodes.
- Pressure debt: an accumulated contract-local measure of risk taken, used by
  validation and Balance Lab to detect routes that spike too hard.
- Recovery charges: optional one-shot stabilization hooks if supplies are too
  broad for the first implementation.

If implemented later, route resources should belong to active generated
contract state, not global Adventure state. They should reset on generated
contract completion, failure, or restart unless a later task explicitly chooses
otherwise. Save/load must preserve current values, spent options, claimed
generated route rewards, and any selected economy-node effects.

### Node Economy Roles

Normal fight nodes provide baseline rewards and readable matchup decisions.
They should usually grant modest gold and sometimes a basic/generated gear
choice. They should not carry major talent point or legendary value.

Elite nodes are optional pressure spikes. They should pay above normal nodes
through better gear tier, extra gold, or talent points, but route validation
should keep them avoidable early and prevent back-to-back elite pressure on
mandatory paths.

Boss nodes close the generated contract. They should provide the best reward
package on the route, including higher-tier gear choices and possible talent
points or legendary choices, while remaining deterministic and compatible with
normal contract completion behavior.

Rest/resource nodes are deferred. If revisited later, they should not be simple
healing nodes because the player has no health resource. They should instead
create economy, information, crafting, shop, wager, or run-upgrade decisions.

Start nodes remain anchors and should not grant rewards.

### Scaling Rules

Generated reward value should scale from three inputs:

- Route difficulty: easy through nightmare maps to base reward tier, gold band,
  and expected pressure.
- Route depth: later nodes pay more than early nodes, with a larger increase on
  short risky paths and elite branches.
- Completed contract count: later Adventure contracts raise pressure and reward
  stakes, preventing indefinite farming of low-pressure generated contracts.

Initial target bands should be conservative:

- Normal early nodes: low gold or basic generated gear choices.
- Normal late nodes: moderate gold or basic/uncommon generated gear choices.
- Elite nodes: at least one reward step above a same-depth normal node.
- Boss nodes: highest generated gear tier available for the contract band plus
  the main completion payout.
- Future non-combat nodes: lower direct power value than fights, with value
  expressed through information, crafting, shop access, consumables, wagers, or
  run upgrades after those systems exist.

Depth and completed-contract scaling must never bypass deterministic combat
setup. Encounter difficulty and reward value can share pressure inputs, but
combat payloads and reward payloads must both be materialized for active
generated routes.

### Route Preview Rules

Generated route-map previews may show reward category and broad value, such as
gold, talent point, gear tier, or future shop/event/crafting language once
non-combat nodes exist. They should not show generated combat/debug internals,
exact pressure metadata, budget metadata, selected mechanics, seeds, or hidden
validation notices.

Preferred preview fields:

- `reward_quality_label`: broad value label such as `Steady`, `Risky`,
  `Elite`, or `Contract Victory`.
- `reward_summary`: short player-facing summary such as `Uncommon gear choice`
  or `Basic gear + 12g`.
- `route_preview`: sparse route identity plus any future economy preview keys
  that remain player-readable.

Existing sparse enemy preview rules remain intact: biome, monster name,
encounter level, and archetype tags are public; detailed defenses and debug
payloads are combat/debug surfaces.

### Snowball Definition

A snowball state exists when a strong generated run compounds rewards so fast
that later route decisions become trivial. P4M7 should flag likely snowballing
when any of these are true:

- Elite rewards outpace same-depth normal rewards by more than one planned
  reward tier without matching pressure.
- A route can claim multiple high-value rewards before the first meaningful
  pressure spike.
- Generated gear choice tiers advance faster than route difficulty and
  completed-contract pressure.
- Gold and shop access together allow repeated upgrades without taking harder
  fights.
- Balance Lab shows generated contract win outcomes staying above the intended
  band across hard/ultra/nightmare scenarios after reward claims are simulated.

Snowball checks may start in Balance Lab and focused reward-table tests, then
move into route/reward validation once the economy model stabilizes.

### Dead-Run Definition

A dead-run state exists when a weak or mismatched build is forced into a route
with no plausible matchup or reward path before a major spike or boss. P4M7
should flag likely dead-runs when any of these are true:

- Every available branch before a boss is an unfavorable high-pressure matchup.
- A mandatory path requires an elite or equivalent pressure spike before any
  meaningful reward opportunity.
- The shortest viable path has too little reward value to prepare for the boss.
- Branches do not offer enough defensive matchup diversity for representative
  builds to make a readable avoidance decision.
- Balance Lab shows generated normal-to-boss sequences falling below the
  intended win-rate, duration, or DPS band across representative Rogue builds.

Dead-run prevention belongs first in route validation and Balance Lab. Reward
generation can help by scaling rewards on safer or longer branches, but it
should not silently erase all risk.

### Check Ownership

Route generation owns graph shape, path length, elite pacing, and branch
distinctness.

Reward generation owns deterministic reward table lookup, reward tier/value,
reward preview labels, and reward materialization.

`BuildState` owns claiming rewards, pending gear choices, contract completion,
retry/failure/restart cleanup, and save/load behavior.

Balance Lab owns broad outcome checks: pressure bands, reward pacing, generated
combat outcomes, snowball warnings, and dead-run warnings.

Focused tests own lifecycle regressions: generated reward determinism,
generated active-contract save/load, route UI preview text/icons, authored
Gilded Serpent behavior, and generated contract completion/failure flow.

### Acceptance Criteria For T2-T9

- Generated normal, elite, and boss nodes receive rewards from deterministic
  table-like definitions.
- Reward payloads and preview labels are materialized on active generated
  routes and survive save/load.
- Route previews communicate reward category and broad value without exposing
  combat/debug internals.
- Reward value scales by route difficulty, route depth, node role, route
  pressure, and completed-contract count.
- Elite and boss rewards are meaningfully better than normal rewards but
  bounded by anti-snowball rules.
- Generated routes provide matchup diversity and enough reward opportunity
  before major mandatory pressure spikes.
- Generated reward claiming, retry, failure, restart, and boss victory behavior
  remain deterministic.
- Authored Gilded Serpent rewards and route behavior remain unchanged.
- Balance Lab or focused tests can fail on obvious rewardless pressure spikes,
  runaway reward curves, missing matchup diversity, or generated save/load
  mismatch.

## Economy Questions

T1 should answer:

- What reward categories can generated nodes grant in P4M7?
- Which rewards are immediate, which are choices, and which affect later route
  pressure?
- What route resources exist, if any, and where are they stored?
- What makes normal, elite, and boss nodes economically distinct, and which
  non-combat roles should be deferred?
- How should rewards scale by route difficulty, route depth, and completed
  contract count?
- What player-facing reward information belongs on route previews?
- What qualifies as a snowball state in generated contracts?
- What qualifies as a dead-run state in generated contracts?
- Which checks belong in route generation, which belong in reward generation,
  and which belong only in Balance Lab verification?
- What economy state must be saved for active generated contracts?

Answers: see `P4M7-T1 Economy Model` above. These decisions are now the working
contract for P4M7-T2 through P4M7-T9.

## P4M7-T2 Implementation Notes

Generated route nodes now receive materialized `EncounterReward` instances from
the versioned `REWARD_TABLE_VERSION` in
`project/scripts/systems/contract_route_generator/contract_route_generator.gd`.
The first table covers normal, elite, and boss combat nodes:

- Normal nodes grant modest gold and one generated gear choice.
- Elite nodes grant higher gold, two generated gear choices, and late-depth
  talent point pressure where applicable.
- Boss nodes grant the contract-victory package: higher gold, two generated
  gear choices, and one talent point.

Reward value scales by route difficulty, node depth, node role, lane, and
`completed_contract_count` when generated offers are created through
`ContractOfferSource`. Reward slots are deterministic per seed/node, and the
route generator graph signature now includes reward identity so table changes
are visible in deterministic route coverage.

Save/load already serialized generated node rewards; T2 tightened generated
save/load test signatures so reward identity, quality labels, and summaries
must survive active generated contract round trips. Generated route inspector
reports now include reward summaries for tooling.

Known tuning gap for later work: T2 intentionally does not add rest/resource
node types or route-local resources. T4 later deferred those systems out of
P4M7 implementation so combat reward and pressure tuning can stabilize first.

## P4M7-T3 Implementation Notes

Generated route map cards now append compact reward language to the existing
sparse encounter preview without changing the generated `route_preview` payload.
Cards show the biome, generated monster name, archetype tags, and a short
reward line such as `Basic gear + 12g`,
`Master gear + 1 talent point + 28g`, or
`Cursed gear + 1 talent point + 58g`.

Normal/Elite/Boss no longer appears as a separate generated route-card line.
Instead, all generated monster names are larger and bolded: normal names use
green, elite names use orange, and boss names use red. Generated route cards
use a compact four-line layout tuned to avoid spilling below the node without
over-widening the generated route graph. Generated schematic buttons render
their visible text through `MapTextBlock` only; their native `Button.text` is
cleared so hidden BBCode/plain text cannot inflate the fixed node size.

The reward line is formatted in `project/scenes/combat/map_overlay.gd` from
materialized `EncounterReward`, `reward_quality_label`, and `reward_summary`
state. It deliberately does not expose seeds, pressure metadata, budget
metadata, generated payload IDs, defense overrides, combat previews, or debug
previews. Authored route cards without generated sparse previews continue to
use their existing fallback text.

Known tuning gap for future phases: reward preview language can now describe
direct combat-node rewards, but there are still no non-combat event nodes,
shop nodes, crafting nodes, mystic upgrades, consumables, or route-local
resource effects to preview.

## P4M7-T4 Decision Notes

P4M7-T4 intentionally defers non-combat nodes and route-local resources instead
of implementing rest/resource nodes immediately.

Reasons:

- Current generated maps may not be long or wide enough for non-combat nodes to
  add meaningful route decisions instead of replacing combat decisions.
- DawnBringer does not have a player health resource, so traditional rest or
  healing nodes do not fit the current Adventure economy.
- Hidden events, shops, consumables, mystic run upgrades, crafting, item
  transmutation, and boss-bargain nodes need stronger balance foundations from
  monster/contract tuning, gear attributes, character talent trees, and shop
  economy work.
- Adding non-combat nodes now could obscure the balance signals P4M7 still
  needs from generated monsters, generated rewards, route pressure, and boss
  readiness.

Future candidate non-combat nodes:

- Hidden encounter/event nodes that can resolve into shop, crafting, bargain,
  reward cache, or other economy events.
- Shop or consumable vendor nodes once one-time-use items exist.
- Mystic nodes that offer run upgrades such as more shop items, lower reroll
  costs, or additional contract visibility.
- Crafting/transmutation nodes that trade several lower-color items for a
  random higher-color item.
- Boss bargain nodes that add a boss mechanic or modifier in exchange for more
  gold, better gear, or other payout.
- Scout/reveal nodes that expose more route, reward, or contract information.
- Forge/reroll nodes that modify existing gear once item attributes are more
  mature.

Dependency gates before implementing those nodes:

- Generated monster and contract balance is stable enough that economy events
  do not mask combat tuning problems.
- Route length and width targets are known, and generated maps have enough
  decision space for non-combat stops.
- Gear attributes and character talent trees are far enough along for crafting,
  forge, and run-upgrade choices to matter.
- Shop economy, consumables, and mystic/run-upgrade systems exist or have a
  committed design.

P4M7 continues with combat-node economy work: pressure scaling across route
depth and completed-contract count, reward value tuning, anti-snowball checks,
dead-run route checks, Balance Lab coverage, and generated lifecycle
regression.

## P4M7-T5 Implementation Notes

Generated route pressure now has a bounded completed-contract pressure tier in
`project/scripts/systems/contract_route_generator/contract_route_generator.gd`.
The tier increases every two completed contracts, caps at two pressure steps,
and is materialized through generated encounter payloads and a route notice:
`pressure_scale:completed_contracts:<count>:tier:<tier>`.

Encounter difficulty now scales from route difficulty, node depth, node role,
and completed-contract pressure. Reward gold uses the same completed-contract
pressure tier, while generated gear tier reads the already-scaled encounter
difficulty plus node-role bonus so completed-contract pressure is not counted
twice. This keeps later contracts and deeper route nodes meaningfully higher
stakes while preserving deterministic generated combat payloads and generated
reward identity across save/load.

Focused generator coverage now checks that:

- deeper normal nodes do not regress below earlier normal nodes in pressure or
  gold value;
- boss rewards outscale normal route nodes;
- elite nodes outscale comparable normal nodes when an elite appears;
- later completed-contract routes produce equal or higher materialized
  difficulty, gold, and gear tier for the same node IDs;
- completed-contract pressure changes generated graph signatures
  deterministically.

## P4M7-T6 Implementation Notes

Generated route difficulty is now documented and materialized as three separate
scales:

- Monster Level: `normal`, `elite`, or `boss`.
- Monster Difficulty: Easy through Nightmare, represented by runtime monster
  difficulty IDs `1..5`.
- Contract Pressure: overflow pressure above Nightmare when the raw calculated
  difficulty exceeds the Monster Difficulty cap.

`ContractRouteGenerator` now computes a `route_pressure_scale` dictionary for
each generated combat node. It records the raw calculated difficulty, the
clamped Monster Difficulty used by `RuntimeMonsterGenerator`, the overflow
`contract_pressure_tier`, route difficulty base, depth bonus, node-level bonus,
completed-contract pressure bonus, Monster Level, and Monster Difficulty cap.
This metadata is stored in `generated_encounter_payload` and mirrored into
`debug_preview`, but it remains out of sparse route-map previews.

The actual over-Nightmare stat scaling is intentionally deferred. Future work
can use `contract_pressure_tier` to scale numeric intensity such as HP, armor,
block, resist, absorb, structural budget, and target/required DPS without
adding more mechanics or making route previews unreadable. Dodge, crit
negation, cleanse, slow, suppress, and similar build-denial mechanics should be
scaled cautiously or capped.

T6 also adds validation guardrails that emit notices for:

- missing or inconsistent `route_pressure_scale` metadata;
- clamped Monster Difficulty values that do not match raw difficulty;
- overflow Contract Pressure values that do not match raw difficulty beyond the
  cap;
- generated reward gear tiers that exceed the materialized pressure scale;
- early non-boss talent payouts before overflow pressure appears;
- elite or boss gold payouts that outpace conservative same-depth normal
  baselines.

These checks inspect materialized route state and do not mutate generated
routes, preserving deterministic combat setup and save/load behavior.

## P4M7-T7 Implementation Notes

Generated combat nodes now materialize route pressure-axis metadata in
`generated_encounter_payload.route_pressure_axes` and mirror it into
`debug_preview.route_pressure_axes`. This metadata is intentionally excluded
from sparse route-map previews.

Current pressure axes:

- `physical_mitigation`: armor, block, and crit-negation pressure.
- `magical_poison_mitigation`: resistance, absorb, and poison mitigation.
- `debuff_poison_disruption`: cleanse/suppress pressure against poison or
  debuff plans.
- `timing_control`: slow, stun, interrupt, and other timing disruption.
- `reliability_evasion`: dodge and hit-reliability pressure.
- `mixed`: hybrid or wildcard archetype pressure.

Current archetype mapping:

- `fortified`, `armored`: `physical_mitigation`.
- `warded`, `resistant`: `magical_poison_mitigation`.
- `hexed`: `debuff_poison_disruption`.
- `nimble`: `reliability_evasion`.
- `devious`, `arcane`: `timing_control`.
- `relentless`, `unstable`: `mixed`.

Route validation now emits dead-run notices when materialized generated routes
show obvious no-sane-path patterns:

- `pressure_axis_missing` or related metadata notices when generated nodes do
  not preserve pressure-axis state.
- `branch_pressure_axis_not_distinct` when a non-start branch offers the same
  primary axis without meaningful level/reward/pressure tradeoff.
- `all_paths_pressure_axis_dominated` when every boss path is dominated by the
  boss axis and no path has enough prep score.
- `low_reward_shortest_path` when the shortest route reaches an overflow
  pressure boss without enough pre-boss reward preparation.

These checks are diagnostic guardrails only. They do not guarantee every
contract is viable for every build, and they do not reroll generated routes.
Biome identity should remain allowed to skew routes toward certain axes. Future
content work can add soft biome weighting, such as Swamp leaning toward
magical/poison/debuff pressure, Haunted Forest toward timing/status/evasion,
and Ruined Keep toward physical mitigation, while validation prevents total
lockout rather than universal fairness.

## P4M7-T8 Implementation Notes

Balance Lab now includes generated route economy checks in its mechanics/check
section. These checks sample deterministic generated routes across:

- default medium routes;
- hard later-contract routes;
- nightmare overflow-pressure routes;
- single-biome Swamp routes;
- a completed-contract pressure comparison against an otherwise matching
  baseline.

For each sampled generated route, Balance Lab summarizes route validation
notices, max raw difficulty, max Contract Pressure tier, reward gold range,
highest gear tier, talent points, pressure axes present, missing combat-node
rewards, sparse-preview debug leaks, and whether completed-contract pressure
changed materialized route economy state.

The new Balance Lab check IDs are:

- `generated_route_economy_notices`
- `generated_route_preview_sparse`
- `generated_route_rewards_present`
- `generated_route_pressure_overflow`
- `generated_route_completed_pressure_changes`
- `generated_route_axis_diversity`

The checks fail on blocking snowball/dead-run notices, route preview exposure
of debug economy metadata, missing rewards on generated combat nodes, missing
overflow pressure in nightmare/later-contract samples, unchanged economy state
when completed-contract pressure changes, or insufficient pressure-axis
coverage across the sampled generated routes.

## P4M7-T9 Implementation Notes

Generated contract outcome coverage now verifies the Adventure reward path for
materialized generated node rewards. Focused tests assert that generated wins
apply gold and talent points through `BuildState.claim_current_reward`, create
the expected generated gear choices, reject duplicate reward claims, preserve
materialized rewards across retries, avoid claiming rewards on losses or
terminal failures, clear generated route economy state on restart, and resolve
boss victory through the normal contract-completion path.

Generated save/load coverage now round-trips active generated contracts after a
generated route reward has been claimed. The regression locks down claimed route
reward IDs, reward identity, reward summary and quality labels, current result
state, gold and talent totals, pending generated gear choices, duplicate-claim
rejection after load, and route continuation after loaded pending choices are
cleared.

## P4M7-T10 Closeout Notes

P4M7 is complete. Generated contracts now have deterministic combat-node reward
tables, sparse player-facing reward preview language, route-depth and
completed-contract pressure scaling, materialized overflow pressure metadata,
pressure-axis metadata, snowball/dead-run validation guardrails, Balance Lab
economy checks, and focused Adventure lifecycle coverage for generated reward
claims and save/load.

Known P4M7 tuning gaps are intentionally handed off rather than solved inside
the reward economy milestone:

- Generated reward families are intentionally narrow: gold, talent points, and
  generated gear choices.
- Over-Nightmare Contract Pressure is materialized as metadata, but numeric
  stat scaling beyond capped Monster Difficulty is deferred.
- Non-combat route nodes, route-local resources, consumables, shops, mystic
  upgrades, crafting/transmutation, boss bargains, and scout/reveal nodes are
  deferred until supporting systems are more mature.
- Route economy balance should be revisited after P4M8 adds more archetypes,
  biome pools, modifiers, and elite/boss variants.

P4M8 should expand content breadth while preserving the P4M7 boundaries:

- Add more runtime archetypes and mechanic combinations with readable pressure
  axes.
- Expand biome and monster presentation pools without coupling fiction names
  to mechanical truth.
- Add modifiers, elite variants, boss variants, and contract themes that
  produce varied but valid generated routes.
- Revisit reward-table variety once the larger content set reveals which
  reward families need more expression.
- Keep route previews sparse and keep combat/debug pressure metadata out of map
  cards.
- Keep authored Gilded Serpent behavior as the regression baseline while new
  generated content is added.

## Expected Implementation Surfaces

- `project/scripts/autoload/build_state.gd`: Adventure reward claiming,
  contract outcome, retry, restart, and completion behavior.
- `project/scripts/resources/contract_def.gd`: generated route-level state and
  serialization helpers.
- `project/scripts/resources/contract_route_node.gd`: generated node state,
  reward fields, route preview data, and outgoing node data.
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`:
  generated route node creation, route validation, node typing, and route
  pacing.
- `project/scripts/systems/contract_offer_source.gd`: generated contract
  settings, offer context, difficulty, and completed-contract pressure inputs.
- `project/scenes/combat/map_overlay.gd`: generated route reward preview
  display and node selectability.
- `project/tests/balance_lab_test.gd`: economy, pressure, reward pacing, and
  generated combat verification.
- Generated contract save/load tests: active generated reward state must load
  from materialized state rather than silent regeneration.

## Verification Notes

Run Godot 4.7 from:

`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`

Run Balance Lab when changes touch:

- generated reward values or reward selection;
- generated route pressure;
- combat timing or event ordering;
- build resolution;
- skill, talent, gear, monster, or enemy data;
- generated encounter difficulty;
- generated combat setup or reports;
- poison, proc, duration, or DPS behavior.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Known local runner issue:

- Sandboxed Godot runs may hit the known `user://logs` startup crash before
  script execution. Recent milestone verification passed outside the sandbox.

Recent P4M7-T2 verification passed outside the sandbox:

- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_source_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/generated_route_ui_preview_test.gd`
- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/contract_route_data_test.gd`

Recent P4M7-T3 verification passed outside the sandbox:

- `project/tests/generated_route_ui_preview_test.gd`
- `project/tests/map_overlay_route_preview_test.gd`
- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/contract_route_data_test.gd`

Recent P4M7-T5 verification passed outside the sandbox:

- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_source_test.gd`
- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/contract_route_data_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/balance_lab_test.gd`

Recent P4M7-T6 verification passed outside the sandbox:

- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_source_test.gd`
- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/contract_route_data_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/balance_lab_test.gd`

Recent P4M7-T7 verification passed outside the sandbox:

- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_source_test.gd`
- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/contract_route_data_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/balance_lab_test.gd`

Recent P4M7-T8 verification passed outside the sandbox:

- `project/tests/balance_lab_test.gd`
- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/contract_route_data_test.gd`
- `project/tests/contract_offer_flow_test.gd`

Recent P4M7-T9 verification passed outside the sandbox:

- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/contract_offer_flow_test.gd`
- `project/tests/contract_route_data_test.gd`
- `project/tests/generated_route_ui_preview_test.gd`
- `project/tests/balance_lab_test.gd`
- `project/tests/contract_route_generator_test.gd`
- `project/tests/generated_route_matrix_test.gd`
- `project/tests/contract_offer_source_test.gd`

Recent P4M7-T10 verification passed outside the sandbox:

- `project/tests/generated_contract_outcome_test.gd`
- `project/tests/generated_contract_save_load_test.gd`
- `project/tests/balance_lab_test.gd`

## Exit Criteria

P4M7 is complete:

- Placeholder generated rewards are replaced by tuned deterministic route
  reward tables.
- Generated route rewards are saved and loaded from materialized active
  contract state.
- Generated route previews communicate reward tradeoffs clearly.
- Route pressure scales across route depth and Adventure progress.
- Generated routes provide matchup and reward-path alternatives before major
  mandatory pressure spikes.
- Anti-snowball and dead-run checks exist in generation, validation, Balance
  Lab, or focused tests.
- Generated contract reward claiming, retry, failure, restart, and boss victory
  behavior remains stable.
- Authored Gilded Serpent behavior remains intact.
- Balance Lab and focused generated contract tests pass.
- This doc and `docs/P4_DawnBringer_Overview.md` are updated with final status,
  verification results, known gaps, and P4M8 handoff notes.

## Follow-Ups For P4M8

- Expand generated contract content breadth after the economy model is stable.
- Add more archetypes, biome pools, monster presentation sets, modifiers,
  elite variants, boss variants, and contract themes.
- Expand generated offer writing once reward and route economy language is
  settled.
- Revisit reward table variety after P4M7 tuning identifies which reward
  families need more content.
- Revisit non-combat nodes after combat balance, map size, gear attributes,
  talent trees, shop economy, consumables, and mystic/run-upgrade systems are
  ready to support them.
