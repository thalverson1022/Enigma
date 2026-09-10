# Project Onboarding Context

## Start Here

This document is the lightweight starting point for the current Project Enigma
workflow. It assumes Phase 4 is complete; P5M1, P5M2, P5M3, P5M4, P5M5,
P5M6, P5M7, P5M8, P5M9, P5M10, P5M11, and P5M12 are complete; Phase 5 is
closed; and the current playtest baseline includes the post-P5M12 combat, gear,
Legendary, Practice Room, Balance Lab, economy, contract-scaling, readability,
reward-feel, and Rogue talent updates recorded below.

Read these documents in order:

1. `docs/Project_Overview.md`
2. `docs/P5_Minimum_Handoff_From_Phase_4.md`
3. `docs/New_Gear_Overview.md`
4. `docs/P5_Gear_Redesign_Overview.md`
5. `docs/P5M1_Gear_Design_Documents_Tracker.md`
6. `docs/P5M2_Gear_Data_Model_And_Migration_Boundary_Tracker.md`
7. `docs/P5M3_Stat_System_Foundation_Tracker.md`
8. `docs/P5M4_Weapon_Damage_Scaling_Tracker.md`
9. `docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md`
10. `docs/P5M6_Shop_Lab_Gear_Simulation_Tracker.md`
11. `docs/P5M7_Reward_And_Shop_Integration_Tracker.md`
12. `docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`
13. `docs/P5M9_Art_And_Sprite_Pass_Tracker.md`
14. `docs/P5M10_Legendary_Revisit_And_Fixed_Legendary_Stats_Tracker.md`
15. `docs/P5M11_Practice_Room_Balance_And_Readability_Tracker.md`
16. `docs/P5M12_Phase_5_Regression_Smoke_And_Closeout_Tracker.md`
17. `docs/P5_Phase_5_Closeout_Handoff.md`

Use `docs/Project_Overview.md` for the executive summary and current state. Use
`docs/P5_Minimum_Handoff_From_Phase_4.md` as the practical Phase 5 handoff. Use
`docs/New_Gear_Overview.md` as the current gear design spec. Use
`docs/P5_Gear_Redesign_Overview.md` as the Phase 5 milestone tracker. Use
`docs/P5M1_Gear_Design_Documents_Tracker.md` as the completed task tracker for
P5M1's gear design documentation, including stat weights, scaling, damage
calculations, stacking rules, special conflicts, Lucky Coin handling, Legendary
boundaries, and deferred tuning decisions. Use
`docs/P5M2_Gear_Data_Model_And_Migration_Boundary_Tracker.md` as the completed
closeout tracker for P5M2's gear data model, five-slot equipment foundation,
Rogue item family mapping, Lucky Coin preservation, old gear migration
boundary, save/load compatibility, minimal UI/tool updates, and focused
regression checks. Use
`docs/P5M3_Stat_System_Foundation_Tracker.md` as the completed closeout tracker
for Project Enigma identity cleanup, stat vocabulary, slot-specific stat
eligibility, stat-sheet aggregation, drawback/floor/cap behavior,
Special-effect hooks, focused regression, and M3 closeout. Use
`docs/P5M4_Weapon_Damage_Scaling_Tracker.md` as the completed closeout tracker
for weapon rolls, Rogue physical skill scaling, damage-order integration,
conversion/ignore hooks, enemy-denial hooks, retrigger behavior, focused combat
regression, Practice Room smoke coverage, and M4 closeout. Use
`docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md` as the completed
closeout tracker for procedural item generation, rarity stat-count rules,
slot-aware weighted stat selection, value scaling, Cursed/Chaos drawbacks,
Unique Special rolls, Lucky Coin exclusion, the Legendary fixed-catalog
boundary, consolidated generator regression coverage, and the P5M6+ handoff.
Use `docs/P5M6_Shop_Lab_Gear_Simulation_Tracker.md` as the completed closeout
tracker for Shop Lab simulation, including the browser-lab audit, simulation
inputs, Phase 5 generator model port, deterministic offer rolling, depth rarity
curves, value scaling visibility, item readability, distribution readouts,
Cursed/Chaos tuning, Unique Special frequency, retrigger cap-risk visibility,
presets, regression checks, current tuning baseline, and closeout handoff to
P5M7. Use `docs/P5M7_Reward_And_Shop_Integration_Tracker.md` as the completed
closeout tracker for live reward/shop integration, including choice-of-two
contract gear rewards, deterministic rarity upgrade chains, no-mid-contract
shop access, Phase 5 shop rarity integration, gold-gain behavior, and the
Legendary fixed-catalog boundary. Use
`docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md` as the
completed closeout tracker for P5M8 item-card presentation and equipment UI
readability, including the locked right-side equipment layout where
Charm/Necklace appears above Trinket/Ring, shared item-card/stat readability,
rarity presentation, all-five-slot comparison behavior, focused UI regression
coverage, and the placeholder-art handoff for Hood/Doublet. Use
`docs/P5M9_Art_And_Sprite_Pass_Tracker.md` as the completed closeout tracker
for P5M9's final Rogue generated-gear sprite catalog, including
slot-and-rarity mappings for Dagger, Hood, Doublet, Ring, and Necklace,
project-owned asset import, `GearIcons.icon_for()` mapping, Lucky Coin and
Legendary override preservation, live UI sprite readability checks, icon
regression coverage, and closeout documentation. Use
`docs/P5M10_Legendary_Revisit_And_Fixed_Legendary_Stats_Tracker.md` as the
completed closeout tracker for P5M10's retained Rogue Legendary audit, fixed
stat packages, effect validation, presentation/equip checks, focused
regression, Practice Room and Balance Lab hooks, closeout verification, and
deferred Legendary redesign notes. Use
`docs/P5M11_Practice_Room_Balance_And_Readability_Tracker.md` as the completed
closeout tracker for Practice Room gear editing, balance readability,
economy-affix behavior, Tavern tuning, contract HP scaling, Overkill Gold,
reward reveal readability, combat log labels, and P5M11 validation.
The full Phase 4 closeout archive remains available in the DawnBringer
repository history at commit
`df940053bda8f8b1369d10754828b69120b00b0d` when deeper evidence is needed.

## Project Goal

Create a replayable fantasy roguelite deck-and-build RPG. The game should let
players build a hero, read enemy defenses, choose contract routes, win rewards,
adapt their build, and push through escalating generated contracts.

The core fun target is meaningful buildcraft under pressure. Players should feel
that route choices, gear choices, talents, skills, and reward decisions all
matter because enemies and contract maps ask different questions.

## Current Baseline

Project Enigma continues from the completed Phase 4 DawnBringer generated-loop
baseline. GitHub `main` was promoted from the finished Phase 4 branch after the
final closeout commit, and Phase 5 work now proceeds in the Project Enigma
workspace.

The current playable Adventure path is:

- Title menu.
- New Adventure.
- Rogue class/subclass setup.
- Tavern encounter ladder.
- Ghit's generated-contract materials pitch.
- Three random generated biome contract offers.
- Generated route-map preview and route-node choice.
- Generated combat.
- Reward claim.
- Between-contract shop.
- Repeated generated contracts.
- Failure, retry, restart, contract victory, and all-bosses victory handling.

The generated-contract loop is the foundation for Phase 5. Do not restart from
earlier milestone assumptions unless the closeout docs explicitly say a system
is provisional or deferred.

## Phase 5 Current Point

Phase 5 is in the gear redesign. P5M1 gear design documentation, P5M2 gear data
model/migration boundary work, P5M3 stat system foundation work, P5M4 weapon
damage scaling work, P5M5 gear generator and rarity rules, P5M6 Shop Lab gear
simulation, P5M7 Reward And Shop Integration, P5M8 Inventory, Equipment UI, And
Item Presentation, P5M9 Art And Sprite Pass, and P5M10 Legendary Revisit And
Fixed Legendary Stats are complete.

Generated enemies now create matchup pressure, but the old item model was not
built to answer that pressure clearly. Phase 5 should define gear slots, affix
vocabulary, item tiers, reward/shop behavior, and preview language so players
can make readable decisions against generated enemy defenses.

The active Phase 5 plan began by pulling a fresh GitHub copy so Project Enigma
work is separated from the previous DawnBringer closeout workspace. After that
bootstrap, the phase focuses on a full gear overhaul:

- P5M1 gear design documentation, completed and tracked in
  `docs/P5M1_Gear_Design_Documents_Tracker.md`.
- P5M2 gear data model and migration boundary, completed and tracked in
  `docs/P5M2_Gear_Data_Model_And_Migration_Boundary_Tracker.md`.
- P5M3 stat system foundation, completed and tracked in
  `docs/P5M3_Stat_System_Foundation_Tracker.md`. Project Enigma identity
  cleanup, canonical stat vocabulary, slot eligibility, stat-sheet aggregation,
  Special-effect hooks, all-stats scaling, canonical save/load bridging, and
  focused regression work are complete.
- P5M4 weapon damage scaling, completed and tracked in
  `docs/P5M4_Weapon_Damage_Scaling_Tracker.md`. Deterministic dagger damage
  rolls, Rogue physical skill weapon scaling, Death Strike poison-stack damage,
  relevant Special combat hooks, retrigger correctness, final rounding/floor
  behavior, and focused combat regression are complete.
- P5M5 gear generator and rarity rules, completed and tracked in
  `docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md`. The generator now
  builds on `StatCatalog`, `StatSheet`, `WeaponDamageCatalog`, and the current
  `PlayerStats` bridge to provide deterministic procedural rarity/stat rolling,
  slot-aware weighted selection, value scaling, Unique Special rolls,
  Cursed/Chaos drawback generation, Lucky Coin exclusion, the Legendary
  fixed-catalog boundary, and consolidated generator regression coverage.
- P5M6 Shop Lab gear simulation, completed and tracked in
  `docs/P5M6_Shop_Lab_Gear_Simulation_Tracker.md`. The milestone replaced the
  quarantined old browser Shop Lab with a Phase 5 tuning surface for repeated
  shop offer rolls, depth rarity curves, value scaling, generated item
  readability, Cursed/Chaos/Unique frequency inspection, retrigger cap-risk
  visibility, random/manual seed support, one-command regression checks, and a
  concrete live reward/shop integration baseline.
- P5M7 Reward And Shop Integration, completed and tracked in
  `docs/P5M7_Reward_And_Shop_Integration_Tracker.md`. Live Adventure
  reward/shop wiring is complete: every generated contract gear reward presents
  two choices, each choice can independently upgrade through a low percentage
  deterministic rarity chain, between-contract shops use the Phase 5 rarity
  set, shops do not open while traversing a contract, and Increased Gold affects
  stash gains rather than shop discounts.
- P5M8 Inventory, Equipment UI, And Item Presentation, completed and tracked in
  `docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`. The live
  UI now exposes all five equipment slots, locks the right-side equipment
  column as Charm/Necklace above Trinket/Ring, uses shared readable item cards
  and stat language, compares gear against the correct equipped slot, hides raw
  generator/debug metadata, and covers the presentation contract with focused
  regression tests. P5M9 has since replaced the Hood and Doublet placeholders
  with final generated Rogue sprites.
- P5M9 Art And Sprite Pass, completed and tracked in
  `docs/P5M9_Art_And_Sprite_Pass_Tracker.md`. The selected purchased RPG icon
  pack sprites for Rogue generated Dagger, Hood, Doublet, Ring, and Necklace
  slot-and-rarity art are imported under `project/assets/Items/Rogue/Generated/`.
  `GearIcons.icon_for()` resolves all supported Rogue generated slot/rarity
  pairs, while Lucky Coin and retained Rogue Legendary overrides remain intact.
- P5M10 Legendary Revisit And Fixed Legendary Stats, completed and tracked in
  `docs/P5M10_Legendary_Revisit_And_Fixed_Legendary_Stats_Tracker.md`. This
  milestone retains Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril
  Karambit, and Bejeweled Push Dagger as named Legendary Weapon-slot Rogue
  daggers, assigns fixed Phase 5 stat packages, preserves their existing
  Legendary effects, validates presentation/equip/save/load/combat behavior,
  and records deferred redesign notes for the later talent-tree phase.
- P5M11 Practice Room And Balance Lab Validation, completed and tracked in
  `docs/P5M11_Practice_Room_Balance_And_Readability_Tracker.md`. This
  milestone closes the current external-playtest readiness pass: Practice Room
  exposes the current gear/rules surface, Balance Lab and Adventure validation
  passed with one accepted balance-watch warning, reward/menu/combat-log
  readability polish is recorded, and final Phase 5 regression moves to P5M12.

Current P5M11 playtest baseline:

- Players start with a Crude Dagger. If no weapon is equipped, physical weapon
  damage falls back to 1 unarmed damage.
- Lucky Coin is a fixed Basic Trinket/Ring with +5% Crit Chance, awarded by the
  scripted Tavern path and excluded from procedural pools.
- Chaos items may repeat the same stat ID across all four rolls. Chaos positive
  Rare outcomes are weighted 20% lower than positive Basic and drawback
  outcomes.
- Item tooltips use a fixed stat order for non-Chaos gear and preserve actual
  roll order for Chaos. Stat lines are category-colored without reusing exact
  rarity colors: Basic off-white, Rare light blue, Special yellow, and
  drawbacks light purple. Max rolled values use the same rounded value shown to
  the player and render bold at two font sizes above the normal tooltip stat
  text in Adventure and Practice Room rich tooltips.
- Shop Discount and Increased Magic Find are Basic/Rare economy stats that can
  roll on any slot. Increased Gold can now roll as Basic or Rare. Shop Discount
  affects purchase prices only; Magic Find multiplies generated-item rarity
  upgrade checks; Increased Gold sums across gear and then multiplies with
  talent multipliers such as Thief Sticky Fingers.
- Bonus Stacks is one gear stat that increases poison, shred, and decay stacks.
  `Stacks you apply are doubled` applies after bonus stacks and updates combat
  stack counts as well as mitigation values.
- `Chance for Crits to Apply Poison` rolls only on crits and applies normal
  poison stacks that tick on the global 1.0s poison timer.
- Shred is a universal debuff. Each stack reduces armor by the player's shred
  value, which starts at 10 and can be increased by Bonus Armor Shred.
- Decay is a universal debuff. Each stack multiplies current enemy resistance by
  `(1 - decay_value)`, with base decay value 20%.
- Hold is not an attack for proc purposes and should not create floating combat
  text.
- Adventure retry changes the encounter retry counter so the same route retry
  does not replay the exact same combat RNG.
- Practice Room supports Crude Dagger selection, all active generated rarities,
  Chaos duplicate-stat editing, max-value defaults when a rarity or stat is
  selected, whole-percent/chance value entry, integer flat-damage and stack
  value entry, economy stat display, shared rich tooltip readability, and
  responsive talent windows.
- Tavern dagger purchases move the starting Crude Dagger into inventory instead
  of deleting it. Crude Dagger sell value is 5g, and Mouthy Drunk HP is 145.
- Generated contract HP scaling now ramps sharply from contract 1 to 30 using
  the `contract_hp_curve_v2` anchors: 1.0x at C1, 1.4x at C5, 2.3x at C10,
  3.8x at C15, 6.0x at C20, 9.0x at C25, and 13.0x at C30. Path enemies are
  heavier, while bosses remain peaks without being the only meaningful
  durability checks.
- Overkill Gold grants 10g per full 100 overkill damage on combat wins, capped
  at 50g before Increased Gold modifiers are applied.
- Combat UI debuff/enemy-stat icons have mouseover tooltips for Shred, Poison,
  Decay, Interrupt, Armor, Resistance, Block, Dodge, Crit Negation, Absorb,
  Suppress, Slow, Cleanse, and Stun.
- Rogue playtest tuning has updated Assassin, Bladedancer, Shadow, and Thief;
  see `docs/New_Gear_Overview.md` for the current skill/talent baseline.
- Retained Rogue Legendaries now use fixed canonical Phase 5 stat packages:
  Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril Karambit, and Bejeweled
  Push Dagger remain authored Legendary Weapon-slot daggers with 21-27 weapon
  damage, bespoke effects, save/load compatibility, authored icons, Practice
  Room selection, and Balance Lab coverage.

Phase 5 now closes with P5M12 final Phase 5 regression, smoke, itch.io-ready
web packaging, GitHub push, and closeout.

Early Phase 5 should preserve:

- Deterministic generation.
- Materialized save/load state.
- Sparse player-facing route previews.
- Generated route template identity.
- Generated rewards and pressure scaling boundaries.
- P5M7's implemented choice-of-two reward structure, deterministic rarity
  upgrade chain, Phase 5 shop curve, and no-mid-contract-shop boundary.
- Practice Room and Balance Lab as validation tools.
- Authored Gilded Serpent data as a regression baseline even though normal
  Adventure currently skips it.

Avoid early Phase 5 scope drift into:

- Broad skill-tree redesign beyond the targeted Rogue playtest changes already
  recorded in the current baseline.
- New route-node systems.
- New combat mechanics unrelated to gear readability.
- New hidden economy systems.
- Full balance tuning before generated gear, shops, rewards, and validation
  surfaces are wired.
- Additional store/platform publishing beyond the scoped P5M12 itch.io-ready
  web package.

## Important Files And Systems

Use the handoff document for the full file list. The most important Phase 5
entry points are:

- `project/project.godot`
- `project/scripts/autoload/build_state.gd`
- `project/scripts/resources/gear_item.gd`
- `project/scripts/resources/stat_modifier.gd`
- `project/scripts/systems/stat_catalog.gd`
- `project/scripts/resources/stat_sheet.gd`
- `project/scripts/systems/weapon_damage_catalog.gd`
- `project/scripts/systems/gear_generator.gd`
- Combat damage, skill, RNG, and mitigation scripts completed during P5M4.
- `project/scripts/systems/contract_offer_source.gd`
- `project/scripts/systems/contract_route_generator/contract_route_generator.gd`
- `project/scripts/systems/runtime_monster_generator/runtime_monster_generator.gd`
- `project/data/runtime_monster_generator/dawnbringer_archetypes_v1.json`
- `project/scripts/systems/save_system.gd`
- `project/scenes/combat/combat_screen.gd`
- `project/scenes/combat/active_talents_panel.gd`
- `project/scenes/combat/talent_overlay.gd`
- `project/scenes/combat/contract_overlay.gd`
- `project/scenes/combat/map_overlay.gd`
- `project/scenes/combat/monster_manual_overlay.gd`
- `project/scenes/training_room/training_room.gd`
- `project/scripts/tools/balance_lab.gd`
- `tools/shop-lab/README.md`, `tools/shop-lab/index.html`,
  `tools/shop-lab/app.js`, `tools/shop-lab/styles.css`, and
  `tools/shop-lab/run_checks.js`, now the completed P5M6 browser simulation
  and regression surface for the Phase 5 gear generator.
- `docs/P5M7_Reward_And_Shop_Integration_Tracker.md`, the completed tracker
  for P5M7 live reward/shop integration.
- `docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`, the
  completed tracker for P5M8 item presentation and equipment UI readability.
- `docs/P5M9_Art_And_Sprite_Pass_Tracker.md`, the completed tracker for P5M9
  Rogue generated-gear sprite selection, import, icon mapping, override
  preservation, live UI readability verification, and regression coverage.
- `docs/P5M10_Legendary_Revisit_And_Fixed_Legendary_Stats_Tracker.md`, the
  completed tracker for retained Rogue Legendary stat packages, effect
  validation, presentation/equip behavior, regression coverage, validation
  hooks, closeout notes, and the P5M11 handoff.
- `docs/P5M11_Practice_Room_Balance_And_Readability_Tracker.md`, the completed
  tracker for Practice Room gear defaults, tooltip readability, economy stats,
  Tavern tuning, generated contract HP scaling, Overkill Gold, reward reveal
  readability, combat log labels, focused verification, accepted balance-watch
  notes, and P5M11 closeout.

## Verification Baseline

Phase 4 closeout passed the major generated-contract regression suite, focused
player-facing smoke pass, release blocker pass, and Windows export smoke. The
local summary is in:

- `docs/P5_Minimum_Handoff_From_Phase_4.md`

The complete closeout evidence remains in the DawnBringer repository history at
commit `df940053bda8f8b1369d10754828b69120b00b0d`.

Known accepted non-blockers:

- Godot editor/headless ObjectDB/RID/resource cleanup warnings at process exit.
- Intentional corrupt-save parse output in save/load testing.
- CSV locale warning from export/report tooling.
- Optional Web/itch export was not produced in Phase 4; P5M12 now scopes the
  Phase 5 itch.io-ready web package.

## Working Rule For New Conversations

When starting a new conversation for Project Enigma, paste or reference this
onboarding context first. Then ask the assistant to read
`docs/Project_Overview.md`, `docs/P5_Minimum_Handoff_From_Phase_4.md`,
`docs/New_Gear_Overview.md`, `docs/P5_Gear_Redesign_Overview.md`,
`docs/P5M1_Gear_Design_Documents_Tracker.md`,
`docs/P5M2_Gear_Data_Model_And_Migration_Boundary_Tracker.md`,
`docs/P5M3_Stat_System_Foundation_Tracker.md`,
`docs/P5M4_Weapon_Damage_Scaling_Tracker.md`,
`docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md`, and
`docs/P5M6_Shop_Lab_Gear_Simulation_Tracker.md`, and
`docs/P5M7_Reward_And_Shop_Integration_Tracker.md`, and
`docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`, and
`docs/P5M9_Art_And_Sprite_Pass_Tracker.md`, and
`docs/P5M10_Legendary_Revisit_And_Fixed_Legendary_Stats_Tracker.md`,
`docs/P5M11_Practice_Room_Balance_And_Readability_Tracker.md`,
`docs/P5M12_Phase_5_Regression_Smoke_And_Closeout_Tracker.md`, and
`docs/P5_Phase_5_Closeout_Handoff.md`; then use
`docs/P5_Gear_Redesign_Overview.md`, `docs/New_Gear_Overview.md`,
`docs/Project_Overview.md`, and the completed P5M12 tracker as the current
source of truth for the closed Phase 5 baseline.

For path-sensitive requests, paste file paths inside backticks so Markdown does
not treat backslashes before underscores or spaces as formatting escapes. Use
the current tracker as the working source of truth, then update it as each task
is completed and verified.
