# P2:R4 - Contract Route Parity

## Purpose

Track the work for **P2:R4 - Contract Route Parity**.

The goal is to port the Phase 1 first contract route, The Gilded Serpent, into
the Godot dashboard flow without expanding into a broad procedural map system.

This milestone should include the contract offer, route choices, secondary
subclass moment, elite pressure, Legendary reward moment, and Vyra climax.

## Exit Criteria

P2:R4 is complete when:

- The player reaches The Gilded Serpent contract after the Tavern sequence.
- The player can choose the intended route branches through the UI.
- Route choices communicate enemy pressure and reward quality.
- The player can choose a secondary Rogue subclass at the intended moment.
- Knives and Vyra are reachable in the active dashboard flow.
- The Knives Legendary reward moment is represented.
- Headless tests cover at least one easy route and one harder route branch.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R4:T1 | Confirm Contract Scope | Authored Phase 1 route shape translated into Godot tasks | Complete |
| P2:R4:T2 | Add Contract/Route Data | Data resources for route nodes, choices, rewards, and next links | Complete |
| P2:R4:T3 | Add Contract Offer Flow | Player accepts The Gilded Serpent and sees target/stakes | Complete |
| P2:R4:T4 | Add Secondary Subclass Moment | Post-Tavern second tree selection works with existing allocator rules | Complete |
| P2:R4:T5 | Add Route Choice UI | Dashboard-compatible route choice presentation | Complete |
| P2:R4:T6 | Add Missing Contract Content | Monsters, encounters, rewards, and route data seeded | Complete |
| P2:R4:T7 | Add Legendary Reward Support | Knives reward choice and required Legendary item behavior | Complete |
| P2:R4:T8 | Add/Update Tests | Contract path and boss reachability verified headlessly | Complete |
| P2:R4:T9 | Update Docs | Contract parity decisions and deferrals documented | Complete |

## P2:R4:T1 - Confirm Contract Scope

Default Phase 1 route target:

- Contract: The Gilded Serpent.
- Opener choice: Door Guard or Portly Cook.
- Door Guard can lead to Sleeping Henchman or Cloaked Watchmen.
- Portly Cook can lead to Lazy Henchman or Patrolling Guard.
- Second-layer fights lead to Knives.
- Knives leads to Vyra.
- Vyra victory marks contract victory.

Do not generalize into a procedural route/map system unless the user explicitly
rescopes Phase 2 again.

Confirmed 2026-07-16:

- R4 starts after the completed Tavern sequence. Hired Goon's reward/hook
  should transition the player to the contract offer, not directly to Vyra.
- The contract is **The Gilded Serpent Contract** and the target is **Vyra**.
- The first tree remains the character-creation subclass choice. The second
  Rogue tree is chosen after Tavern completion and before the first contract
  route choice.
- The first route should be authored and narrow. It is not a procedural map,
  a route editor, a broader contract-run framework, or an additional-contract
  content pass.
- R4 should make Knives and Vyra reachable through the active dashboard flow.
  R5 will handle fuller seed determinism, failure/retry polish, and final
  run-state semantics.

Confirmed route graph:

| Step | Node | Type | Next |
|---|---|---|---|
| Contract offer | The Gilded Serpent | Offer | Secondary subclass choice |
| Secondary subclass | Second Rogue tree | Choice | Door Guard or Portly Cook |
| Opener A | Door Guard | Fight | Sleeping Henchman or Cloaked Watchmen |
| Opener B | Portly Cook | Fight | Lazy Henchman or Patrolling Guard |
| Door second layer A | Sleeping Henchman | Fight | Knives |
| Door second layer B | Cloaked Watchmen | Fight | Knives |
| Cook second layer A | Lazy Henchman | Fight | Knives |
| Cook second layer B | Patrolling Guard | Fight | Knives |
| Convergence | Knives | Elite | Legendary weapon choice, then Vyra |
| Boss | Vyra | Boss | Contract victory |

Confirmed monster stats and combat windows:

| Node | Monster id | HP | Armor | Poison Resist | Window |
|---|---|---:|---:|---:|---:|
| Door Guard | `monster.contract.door_guard` | `230` | `160` | `10%` | `16s` |
| Portly Cook | `monster.contract.portly_cook` | `360` | `0` | `0%` | `20s` |
| Sleeping Henchman | `monster.contract.sleeping_henchman` | `560` | `0` | `0%` | `26s` |
| Cloaked Watchmen | `monster.contract.cloaked_watchmen` | `525` | `160` | `40%` | `26s` |
| Lazy Henchman | `monster.contract.lazy_henchman` | `500` | `0` | `0%` | `26s` |
| Patrolling Guard | `monster.contract.patrolling_guard` | `460` | `160` | `25%` | `26s` |
| Knives | `monster.contract.knives_right_hand` | `540` | `160` | `30%` | `28s` |
| Vyra | `monster.contract.vyra` | `600` | `160` | `35%` | `30s` |

Confirmed route rewards:

| Node | Gold | Talent Points | Gear Choice | Next Reward State |
|---|---:|---:|---|---|
| Door Guard | `22g` | `0` | Master weapon or trinket | Second-layer route choice |
| Portly Cook | `26g` | `0` | Basic weapon or charm | Second-layer route choice |
| Sleeping Henchman | `30g` | `1` | Basic weapon or trinket | Knives |
| Cloaked Watchmen | `0g` | `1` | Cursed trinket or charm | Knives |
| Lazy Henchman | `0g` | `1` | Basic weapon or trinket | Knives |
| Patrolling Guard | `30g` | `1` | Master weapon or charm | Knives |
| Knives | `42g` | `0` | Wyvern Kriss or Mithril Karambit | Vyra |
| Vyra | `120g` | `0` | None | Contract victory |

Confirmed route difficulty intent:

- Easy path: Portly Cook -> Lazy Henchman -> Knives -> Vyra.
- Hard opener: Door Guard -> Sleeping Henchman or Cloaked Watchmen.
- Hardest reward path: Door Guard -> Cloaked Watchmen -> Knives -> Vyra.
- Door Guard should communicate harder opener / better Master reward quality.
- Portly Cook should communicate easier opener / lower Basic reward quality.
- Cloaked Watchmen should be presented as a dangerous Cursed-reward branch.
- Patrolling Guard should present an easier-branch Master reward opportunity.
- Knives and Vyra are armor/poison-resistance pressure checks and should not
  be flattened for parity unless later balance testing explicitly requires it.

Confirmed Legendary scope:

- Only the Knives reward pair is required for R4 route parity:
  Wyvern Kriss and Mithril Karambit.
- Wyvern Kriss requires existing stat support for poison stacks and poison
  damage, plus new generic support for poison tick cadence modifiers.
- Mithril Karambit requires existing stat support for attack speed and crit
  chance, plus new generic support for triggered skills that resolve without
  consuming cast time.
- Other authored Legendary weapons remain out of R4 unless route reward scope
  is explicitly expanded.

Confirmed R4 boundaries:

- In scope: contract offer, secondary Rogue subclass moment, authored route
  choices, missing contract monsters, route encounter/reward data, Knives,
  the Knives Legendary choice, and Vyra reachability through dashboard UI.
- Out of scope until R5: visible run seed UI, full run-context deterministic
  RNG, first-failure do-over polish, second-failure restart behavior, and
  durable contract-failed/contract-victory state machines beyond the minimal
  state needed to reach R4's route exit criteria.
- Out of scope until R6: save/load persistence for route state.
- Out of scope until R7: full game-like presentation polish for route choice,
  Legendary reward, and final victory screens.
- Out of scope for Phase 2: additional contracts and a broad procedural or
  meta-progression contract-run system.

## P2:R4:T2 - Add Contract/Route Data

Design data resources that can represent the authored first route:

- Contract id/display name/target.
- Route nodes.
- Node type: fight, elite, boss, reward, choice, etc. if needed.
- Monster and combat window.
- Rewards or reward choices.
- Next node choices.
- Difficulty/reward labels for UI.

Prefer a narrow model that can grow later, without blocking Phase 2 on a
general map editor.

## P2:R4:T3 - Add Contract Offer Flow

After the Tavern sequence:

- Present The Gilded Serpent contract.
- Communicate Vyra as target.
- Explain the transition from Tavern to contract in game-like terms.
- Let the player accept and move into route selection.

## P2:R4:T4 - Add Secondary Subclass Moment

Restore Phase 1's secondary tree timing:

- First tree chosen at character creation.
- Second tree chosen after Tavern / before contract.
- Passive allocation rules allow up to two active trees.
- Existing selected talents remain valid or are adjusted according to rules.

The UI should make the second-tree choice feel like a run milestone, not a
configuration menu.

## P2:R4:T5 - Add Route Choice UI

For route choices, show enough information for buildcraft decisions:

- Enemy name.
- HP/armor/poison resistance.
- Combat window.
- Reward quality.
- Difficulty/readable route label.
- Next action.

Avoid creating a full map screen if a focused choice overlay is enough.

## P2:R4:T6 - Add Missing Contract Content

Seed missing Phase 1 route content as data:

- Door Guard.
- Portly Cook.
- Sleeping Henchman.
- Cloaked Watchmen.
- Lazy Henchman.
- Patrolling Guard.
- Knives.
- Any missing reward data.

Vyra already exists but may need to move from the old M5 direct ladder into
contract route data.

## P2:R4:T7 - Add Legendary Reward Support

Knives should offer a Legendary weapon choice before Vyra.

Audit required Legendary behavior from Phase 1:

- Wyvern Kriss.
- Mithril Karambit.
- Any other Legendary included if the route offers expand.

Implement required mechanics generically where possible:

- Triggered skills.
- Poison tick cadence modifiers.
- Minimum execution time procs.
- Skill unlocks.
- Gold-scaled damage, if included.

## P2:R4:T8 - Add/Update Tests

Tests should cover:

- Tavern completion reaches contract offer.
- Secondary subclass can be selected.
- Easy opener route can reach Knives/Vyra.
- Harder branch can be chosen and progresses correctly.
- Legendary choice after Knives affects state.
- Vyra fight can produce final victory/defeat state.

## P2:R4:T9 - Update Docs

When complete:

- Update this checklist.
- Record exact route representation.
- Note Legendary mechanics implemented or deferred.
- Update `docs/Phase_2_Milestones.md`.

## Implementation Notes

2026-07-16:

- `P2:R4:T1` is complete. The Phase 1 Gilded Serpent route has been
  translated into concrete Godot tasks and R4 boundaries.
- Recommended `P2:R4:T2` data model:
  - Add a narrow `ContractDef` resource with stable id, display name, target
    monster/encounter reference, starting route node, and optional offer text.
  - Add a narrow `ContractRouteNode` resource with stable id, display name,
    node type, monster reference, combat window, reward reference, route
    choice links, difficulty label, reward-quality label, and optional UI
    summary text.
  - Reuse `EncounterReward` where it already fits gold, talent points, fixed
    gear, and generated gear choices. Extend it only for route reward choices
    and Legendary choice data that cannot be represented cleanly today.
  - Keep route choices as authored resource links, not a generated map.
  - Keep content under `project/data/` and schema under
    `project/scripts/resources/`, matching existing conventions.
- Recommended build order after T1:
  1. Add route/contract resource schema.
  2. Seed missing contract monsters.
  3. Seed route nodes and rewards for The Gilded Serpent.
  4. Add minimal `BuildState` route state and post-Tavern contract offer.
  5. Add secondary subclass choice flow.
  6. Add route choice UI inside the dashboard-era flow.
  7. Add Knives Legendary choice support and the required generic Legendary
     mechanics.
  8. Update headless dashboard tests for easy and harder branches.
- `P2:R4:T2` is complete. Added the narrow route data foundation:
  - `ContractDef` in `project/scripts/resources/contract_def.gd`.
  - `ContractRouteNode` in
    `project/scripts/resources/contract_route_node.gd`.
  - `project/data/contracts/the_gilded_serpent.tres`.
  - Authored route node resources under
    `project/data/contract_routes/gilded_serpent/`.
  - Contract monster resources for Door Guard, Portly Cook, Sleeping
    Henchman, Cloaked Watchmen, Lazy Henchman, Patrolling Guard, and Knives.
- The route graph is represented as authored `ContractRouteNode.next_nodes`
  links, not as a procedural map. The graph currently encodes:
  - Offer -> secondary Rogue tree choice.
  - Secondary tree choice -> Door Guard or Portly Cook.
  - Door Guard -> Sleeping Henchman or Cloaked Watchmen.
  - Portly Cook -> Lazy Henchman or Patrolling Guard.
  - Every second-layer fight -> Knives -> Vyra.
- Route nodes carry monster references, combat windows, `EncounterReward`
  resources where current reward data fits, difficulty labels, reward-quality
  labels, UI summary text, and reward summary text.
- Current limitation by design: route gear choices are represented as reward
  tier/count plus human-readable route reward labels. Slot-constrained choice
  generation, actual route reward claim UI, and Legendary item behavior remain
  later R4 work (`P2:R4:T5` through `P2:R4:T7`), not T2 schema/data loading.
- `P2:R4:T3` is complete. Added the first live contract handoff:
  - `BuildState` now has contract offer/route phases, active contract state,
    and current route-node state.
  - Tavern dashboard progression now stops after Hired Goon by using
    `RunFlow.tavern_encounter_count()` instead of treating the old direct
    Vyra ladder as the active next step.
  - Claiming Hired Goon's reward can open The Gilded Serpent contract offer
    in the dashboard combat window.
  - The offer panel reads the contract name, target, and body text from
    `project/data/contracts/the_gilded_serpent.tres` and the offer route node.
  - Accepting the offer advances `BuildState.current_route_node` to
    `route.gilded_serpent.secondary_rogue_tree`, intentionally handing off to
    `P2:R4:T4` rather than implementing the second-tree UI inside T3.
  - The enemy panel now shows Tavern encounters as `1/4` through `4/4`, then
    contract-offer/contract-route status text instead of direct Vyra.
- Follow-up map/UI pass:
  - The Tavern map now uses the dashboard card palette instead of the light
    schematic styling.
  - The map includes story/context text above the node row.
  - Tavern map nodes keep future fights hidden as `Unknown`, and selecting the
    current Tavern node gates fight availability.
  - The contract offer now appears inside the map, replacing the Tavern map
    after Hired Goon.
  - Selecting The Gilded Serpent from the map opens the second-subclass choice
    moment; after choosing the second tree, the map switches to the authored
    contract route choices.
- `P2:R4:T4` is complete in code. Added a dashboard modal for the second Rogue
  tree choice after contract acceptance:
  - The modal lists available Rogue trees not already selected.
  - Choosing a tree appends it through the existing `PassiveAllocator`
    two-tree rule instead of replacing the initial tree.
  - The talent panel now renders selected trees as separate stacked sections,
    each with its name and intrinsic text, and uses tighter spacing/font sizes
    when two trees are visible.
  - Current limitation: this hands off to the route-choice map, but route fight
    selection/combat wiring remains later R4 work.
- `P2:R4:T5` is complete in code. The dashboard route-choice UI now presents
  authored contract branches as fightable choices instead of placeholder map
  buttons:
  - Route choice buttons show enemy name, HP, armor, poison resistance, combat
    window, difficulty/pressure label, and reward-quality label from
    `ContractRouteNode` data.
  - Follow-up contract-map pass: replaced the temporary two-choice row with an
    authored schematic for The Gilded Serpent based on the supplied map
    mockup. The whole first-contract graph is visible at once
    (Door Guard/Portly Cook -> four second-layer routes -> Knives -> Vyra),
    while only currently reachable next nodes are enabled.
  - `BuildState` now exposes a current combat target/reward surface that can
    resolve either Tavern encounters or selected contract route nodes.
  - Selecting Door Guard or Portly Cook advances from the contract-route choice
    state into the normal dashboard planning/fight/result path.
  - The enemy panel displays selected route monster stats and reward quality,
    and the existing lock-build gate enables the route fight button.
  - Winning a contract route fight can claim the route node's basic reward data
    and return to the route map for the next authored branch; Tavern shop
    unlock state is intentionally ignored during contract rewards.
  - Current limitation by design: the contract-map schematic is deliberately
    authored/static for R4; procedural map generation remains Phase 3+.

## Verification Notes

2026-07-16:

- Documentation-only scope confirmation. No runtime behavior changed.
- Sources checked:
  - `docs/Phase_2_R1_Adventure_Parity_Audit.md`
  - `docs/Phase_2_R3_Reward_Shop_Gear_Parity.md`
  - `docs/Phase_2_Milestones.md`
  - `docs/Phase 1 Context Docs/Content_Library_Reference.md`
  - `docs/Phase 1 Context Docs/Current_Mechanics_Reference.md`
  - `docs/Phase 1 Context Docs/Balance_Baseline_Report.md`
- No Godot tests were run because `P2:R4:T1` only updates milestone scope and
  implementation planning.
- `P2:R4:T2` verification:
  - Added `tests/contract_route_data_test.gd`.
  - The test loads `The Gilded Serpent Contract`, verifies the offer and
    secondary subclass nodes, validates Door Guard and Portly Cook opener
    stats/reward tiers, walks the easy route
    `Portly Cook -> Lazy Henchman -> Knives -> Vyra`, and walks the harder
    branch `Door Guard -> Cloaked Watchmen -> Knives -> Vyra`.
  - Refreshed Godot's global class cache via a headless editor scan after
    adding `ContractDef` and `ContractRouteNode`.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_route_data_r4_t2.log -s res://tests/contract_route_data_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_r4_t2.log -s res://tests/encounter_reward_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r4_t2.log -s res://tests/combat_screen_test.gd`
  - The first sandboxed Godot run crashed during startup/log handling, matching
    the known local issue. The passing checks above used escalated filesystem
    access and still printed the known ObjectDB/resource cleanup warnings after
    assertions passed.
- `P2:R4:T3` verification:
  - Added `tests/contract_offer_flow_test.gd`.
  - The focused test simulates Hired Goon victory reward claim, verifies that
    The Gilded Serpent offer appears in the dashboard, confirms the UI names
    Vyra as the target, accepts the contract, and asserts the route state
    advances to the secondary Rogue tree node.
  - Updated `tests/combat_screen_test.gd` so the broad dashboard regression
    expects Tavern encounter numbering `1/4` and verifies the post-Hired Goon
    contract-offer handoff instead of the old run-end/direct-Vyra behavior.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_route_data_r4_t3.log -s res://tests/contract_route_data_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_offer_flow_r4_t3.log -s res://tests/contract_offer_flow_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r4_t3.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r4_t3.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/encounter_reward_r4_t3.log -s res://tests/encounter_reward_test.gd`
  - As in prior runs, the first sandboxed Godot executions crashed during
    startup/log handling. The passing checks above used escalated filesystem
    access and still printed the known ObjectDB/resource cleanup warnings
    after assertions passed.
- `P2:R4:T4` verification note:
  - Updated `tests/contract_offer_flow_test.gd` and
    `tests/combat_screen_test.gd` to reflect the map-driven contract offer,
    secondary subclass modal, and post-choice contract route map.
  - Runtime verification could not be completed in-session: sandboxed Godot
    hit the known startup/log crash, and the required escalated rerun was
    blocked by the account usage limit.
- `P2:R4:T5` verification:
  - Updated `tests/contract_offer_flow_test.gd` to assert that Door Guard and
    Portly Cook route choices show stats/pressure labels, selecting Portly
    Cook enters dashboard planning, and the route fight button unlocks only
    after the build is locked.
  - Updated `tests/combat_screen_test.gd` to assert the same route-choice
    presentation inside the full dashboard regression and to press FIGHT
    against Portly Cook, proving the combat log resolves against the selected
    route monster.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_offer_flow_r4_t5.log -s res://tests/contract_offer_flow_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r4_t5.log -s res://tests/combat_screen_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r4_t5.log -s res://tests/inventory_model_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_route_data_r4_t5.log -s res://tests/contract_route_data_test.gd`
  - The first sandboxed focused/dashboard Godot runs crashed during startup/log
    handling, matching the known local issue. The passing checks above used
    escalated filesystem access and still printed the known ObjectDB/resource
    cleanup warnings after assertions passed.
- Contract-map schematic follow-up verification:
  - Updated `tests/contract_offer_flow_test.gd` and
    `tests/combat_screen_test.gd` so the route map now expects all eight
    Gilded Serpent nodes to be visible, with first-branch choices enabled and
    downstream nodes locked until reached.
  - Passing checks:
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_offer_flow_contract_map.log -s res://tests/contract_offer_flow_test.gd`
    - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_contract_map.log -s res://tests/combat_screen_test.gd`

2026-07-16 R4 closeout:

- `P2:R4:T6` is complete. The missing first-contract content is seeded as
  data: Door Guard, Portly Cook, Sleeping Henchman, Cloaked Watchmen, Lazy
  Henchman, Patrolling Guard, Knives, and Vyra are represented by authored
  route nodes under `project/data/contract_routes/gilded_serpent/`, with
  matching contract monsters under `project/data/monsters/`.
- Route rewards now carry the slot pairs needed for generated gear choices:
  weapon/ring, weapon/necklace, or ring/necklace according to the confirmed
  route table.
- `P2:R4:T7` is complete. Knives now opens a real reward choice before Vyra:
  - Added `GearItem.Tier.LEGENDARY`.
  - Added `Wyvern Kriss` and `Mithril Karambit` under `project/data/gear/`.
  - Added generic poison tick cadence support through
    `StatModifier.StatType.POISON_TICK_INTERVAL`.
  - Added generic `TriggeredSkillEffect` support so gear can trigger skills
    immediately without consuming cast time.
  - `Wyvern Kriss` grants `+2` poison stacks, `x1.4` poison damage, and
    `x0.5` poison tick interval.
  - `Mithril Karambit` grants `+20%` attack speed, `+10%` crit chance, and
    `20%` trigger chances for Stab and Heavy Slash.
  - Legendary choices auto-equip as weapons when selected, replacing the
    current weapon through existing equipment rules.
- `P2:R4:T8` is complete. Added focused coverage for route rewards,
  Legendary mechanics, and reward-choice UI while preserving the existing
  dashboard regressions.
- `P2:R4:T9` is complete. R4 closeout decisions and verification are recorded
  here and the revised roadmap now points to `P2:R5 - Run Rules And
  Determinism`.
- Added `tests/legendary_reward_test.gd` for the Knives reward choice and
  Legendary stat/effect behavior.
- Added `tests/route_reward_choice_ui_test.gd` for generated route reward
  choice UI and the Knives Legendary choice panel.
- Extended `tests/engine_mechanics_test.gd` for poison tick cadence modifiers
  and triggered skill resolution.
- Extended `tests/contract_route_data_test.gd` for route reward slot pairs and
  Knives' authored Legendary choices.
- Passing checks:
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/legendary_reward_r4_t7.log -s res://tests/legendary_reward_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_route_data_r4_t7.log -s res://tests/contract_route_data_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/engine_mechanics_r4_t7.log -s res://tests/engine_mechanics_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/inventory_model_r4_t7_full_inventory.log -s res://tests/inventory_model_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/contract_offer_flow_r4_t7.log -s res://tests/contract_offer_flow_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/combat_screen_r4_t7.log -s res://tests/combat_screen_test.gd`
  - `Godot_v4.7-stable_win64_console.exe --headless --path project --log-file user://logs/route_reward_choice_ui_r4_t7.log -s res://tests/route_reward_choice_ui_test.gd`
- A headless editor scan was run to refresh Godot global class metadata after
  adding `TriggeredSkillEffect` and new exported resource fields.
- As in earlier R4 verification, sandboxed Godot startup hit the known local
  crash. Passing checks above used escalated filesystem access and still
  printed the known ObjectDB/resource cleanup warnings after assertions
  passed.

P2:R4 is complete as of 2026-07-16. The next revised milestone is
`P2:R5 - Run Rules And Determinism`.
