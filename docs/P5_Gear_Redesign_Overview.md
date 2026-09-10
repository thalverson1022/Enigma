# P5: Gear Redesign Overview

## Current Status

P5M0, P5M1, P5M2, P5M3, P5M4, P5M5, P5M6, P5M7, P5M8, P5M9, P5M10, and
P5M11 and P5M12 are complete. Phase 5 is closed with a stable gear baseline,
GitHub closeout, and itch.io-ready web package.

Project Enigma continues from the completed Phase 4 generated-contract
foundation. Phase 4 made the generated Adventure loop playable; Phase 5 makes
gear strong and readable enough for players to answer the matchup pressure that
generated enemies and routes now create.

The initial implementation step pulled a fresh GitHub copy so this phase is
worked in a separate Project Enigma workspace rather than continuing directly in
the previous DawnBringer closeout workspace.

## Milestone Goal

Replace the old gear model with a five-slot gear system that supports clear
buildcraft, deterministic item generation, slot-specific stat pools, new rarity
rules, Rogue weapon-damage scaling, reward/shop integration, readable item UI,
and validation through Shop Lab, Practice Room, and Balance Lab.

Phase 5 is not a final balance pass. Numbers can remain provisional as long as
the gear model is coherent, testable, deterministic, and ready for later tuning.

## Scope

In scope:

- Fresh Project Enigma repo bootstrap from GitHub.
- Gear design and milestone documentation.
- Five universal gear slots: Weapon, Helm, Armor, Trinket, Charm.
- Rogue item identities: Dagger, Hood, Doublet, Ring, Necklace.
- New rarity tiers: Crude, Basic, Master, Epic, Cursed, Chaos, Unique,
  Legendary.
- Slot-specific Basic, Rare, and Special stat pools.
- Cursed and Chaos drawback behavior.
- Lucky Coin preservation as a Basic Crit Chance item.
- Deterministic procedural item generation.
- Rogue weapon-damage ranges and physical skill scaling.
- Reward and between-contract shop integration.
- Shop Lab simulation for rolling and tuning new gear offers.
- Inventory/equipment UI support for Helm and Armor.
- New sprites for Hood and Doublet.
- Legendary stat adjustment with fixed legendary stat packages.
- Practice Room and Balance Lab validation.
- Regression, smoke testing, web/itch.io packaging, GitHub push, docs, and
  closeout.

Out of scope unless explicitly promoted into scope:

- Broad talent-tree redesign beyond the targeted Rogue playtest changes already
  in the current baseline.
- New playable classes.
- Full legendary redesign beyond fixed stat adjustment.
- New route-node systems.
- New route-local resources.
- New hidden economy systems.
- Consumables, crafting, transmutation, boss bargains, scout/reveal nodes, or
  hidden events.
- Full final balance tuning before the new gear model exists.
- Additional store/platform publishing beyond the scoped itch.io-ready Phase 5
  web package.

## Key References

- `docs/Project_Onboarding_Context.md`
- `docs/Project_Overview.md`
- `docs/P5_Minimum_Handoff_From_Phase_4.md`
- `docs/New_Gear_Overview.md`
- `docs/P5M1_Gear_Design_Documents_Tracker.md`
- `docs/P5M2_Gear_Data_Model_And_Migration_Boundary_Tracker.md`
- `docs/P5M3_Stat_System_Foundation_Tracker.md`
- `docs/P5M4_Weapon_Damage_Scaling_Tracker.md`
- `docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md`
- `docs/P5M6_Shop_Lab_Gear_Simulation_Tracker.md`
- `docs/P5M7_Reward_And_Shop_Integration_Tracker.md`
- `docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`
- `docs/P5M9_Art_And_Sprite_Pass_Tracker.md`
- `docs/P5M10_Legendary_Revisit_And_Fixed_Legendary_Stats_Tracker.md`
- `docs/P5M11_Practice_Room_Balance_And_Readability_Tracker.md`

## Tasks

| Task | Status | Purpose | Exit Criteria |
| --- | --- | --- | --- |
| P5M0: Project Enigma Repo Bootstrap | Complete | Create a separate working copy from GitHub so Phase 5 work is isolated from the previous project workspace. | Fresh repo copy is pulled or cloned from GitHub, project identity is confirmed, branch strategy is chosen, Godot project opens or runs, baseline smoke checks pass, and docs confirm this is the Phase 5 Project Enigma workspace. |
| P5M1: Gear Design Documents | Complete | Codify the new gear model before implementation. | `docs/New_Gear_Overview.md` defines slots, Rogue names, rarities, stat pools, stat weights, value scaling, Cursed/Chaos drawbacks, damage calculation order, stacking, status interactions, Special conflicts, Lucky Coin, Legendary boundaries, and milestone-tagged deferred tuning. `docs/P5M1_Gear_Design_Documents_Tracker.md` records all P5M1 design tasks as complete. This Phase 5 overview records updated milestone dependencies and scope. |
| P5M2: Gear Data Model And Migration Boundary | Complete | Replace old item assumptions with the new five-slot framework. | Completed 2026-09-03. Gear supports Weapon, Helm, Armor, Trinket, and Charm; Rogue non-Legendary gear displays as Dagger, Hood, Doublet, Ring, and Necklace; named Rogue Legendaries remain unique Weapon-slot items; Lucky Coin is preserved as fixed authored gear and has since moved to Trinket/Ring; old runtime gear is migrated or quarantined at the save/load boundary. |
| P5M3: Stat System Foundation | Complete | Implement the new gear stat vocabulary and finish Godot-visible Enigma identity cleanup. | Completed 2026-09-04. Godot/editor/export labels identify the project as Project Enigma; `StatCatalog` defines Basic, Rare, Special, drawback, and compatibility stat IDs; slot-specific eligibility is queryable; `StatSheet` aggregates equipped gear with positives, drawbacks, floors, caps, additive Basic/Rare stacking, all-stats scaling, deduplicated Specials, and `PlayerStats` bridge hooks; existing authored gear, generated gear, Lucky Coin, Practice Room custom gear, save/load, and minimal formatter paths tolerate canonical IDs. |
| P5M4: Weapon Damage Scaling | Complete | Move Rogue physical skill damage onto deterministic weapon rolls. | Completed 2026-09-04. Weapon damage rolls once per cast; retriggers are full new casts and can recursively retrigger; Rogue physical skills use the documented weapon percentages; flat Base Damage applies before scaling; Death Strike adds 1 damage per poison stack before scaling; damage uses the documented bucket, crit, conversion, mitigation, floor, and rounding order. |
| P5M5: Gear Generator And Rarity Rules | Complete | Build the procedural item generator around the new rarity structure. | Completed 2026-09-04. Crude remains starter-only; Basic, Master, Epic, Cursed, Chaos, and Unique use the documented stat-count rules; slot-aware weighted selection uses `StatCatalog`; Epic rolls 2 Basic and 1 Rare; Cursed rolls 2 Basic, 1 Rare, and 1 Basic-stat drawback; Chaos rolls 4 positive Basic/Rare stats or Basic-stat drawbacks; Unique rolls 3 Basic, 1 Rare, and 1 Special; Legendary selection uses fixed catalog paths and never procedurally rolls stats. |
| P5M6: Shop Lab Gear Simulation | Complete | Let us test shop feel before final Adventure integration. | Completed 2026-09-05. Shop Lab repeatedly rolls new gear offers with five slots, Rogue families, rarity curves, Cursed drawbacks, Chaos outcomes, Unique Specials, contract-depth value scaling, random/manual seed support, cleaner item-card readability, aggregate tuning readouts, retrigger cap-risk visibility, and one-command regression coverage. |
| P5M7: Reward And Shop Integration | Complete | Use the new gear model in the live Adventure loop. | Completed 2026-09-05. Contract rewards always offer two generated gear choices; each reward choice can independently upgrade through a low-percentage deterministic rarity chain; between-contract shops generate Phase 5 gear deterministically; rarity odds improve with contract depth; no shop opens while traversing a generated contract route. P5M11 extends this with economy affixes: Increased Gold affects stash gains, Shop Discount affects purchase prices only, and Magic Find multiplies generated-item rarity upgrade chances. |
| P5M8: Inventory, Equipment UI, And Item Presentation | Complete | Make the new gear readable and equippable. | Completed 2026-09-06. Helm and Armor function in inventory and equipment UI; the right-side equipment column presents Charm/Necklace above Trinket/Ring; item cards show rarity, slot, Rogue item type, weapon damage, stats, drawbacks, Specials, and Legendary effects; comparison tooltips match all five slots correctly; rarity colors and Epic treatment are applied without exposing debug or raw generator data. |
| P5M9: Art And Sprite Pass | Complete | Add item identity for the expanded gear system. | Completed 2026-09-06. Project-owned generated Rogue sprites exist for Dagger, Hood, Doublet, Ring, and Necklace across supported rarities; icon mapping uses those sprites; Lucky Coin and retained Rogue Legendary authored overrides remain intact; live UI screenshot checks and icon regressions passed. |
| P5M10: Legendary Revisit And Fixed Legendary Stats | Complete | Retain current Rogue legendaries while fitting them into the new gear structure. | Completed 2026-09-06. Wyvern Kriss, Bandit Blade, Umbral Stiletto, Mithril Karambit, and Bejeweled Push Dagger now use fixed canonical Phase 5 stat packages, retain their current Legendary effects, keep authored icons and 21-27 weapon damage, and have documented regression, Practice Room, Balance Lab, save/load, and deferred redesign coverage. |
| P5M11: Practice Room And Balance Lab Validation | Complete | Validate gear behavior outside normal Adventure runs and tune the current playtest baseline. | Completed 2026-09-10. Practice Room supports the new slots and stat effects; P5M11 covered max-value gear defaults, tooltip stat order/color/max-roll readability, economy stats, Tavern tuning, generated target controls, sharper generated contract HP scaling, Overkill Gold, attempt/contract badges, reward reveal readability, combat log labels, menu fade feel, role-scale enemy sprites, focused regression, and broad Practice Room/Balance Lab/Adventure validation. One Balance Lab warning for `bladedancer_contract_watchmen` remains an accepted future talent-tree balance watch. |
| P5M12: Phase 5 Regression, Smoke, And Closeout | Complete | Make the new gear system the next stable baseline. | Completed 2026-09-10. Adventure loop, generated contracts, route previews, rewards, shop, save/load, Practice Room, Shop Lab, Balance Lab, and export-sensitive paths passed regression; an itch.io-ready web package was created; docs were updated; known tuning caveats were recorded; closeout changes were prepared for GitHub; final Phase 5 handoff was written. |

## P5M0 Project Enigma Repo Bootstrap

Status: Complete.

P5M0 creates the clean project boundary for Phase 5. The new workspace should be
pulled from GitHub rather than continuing from the current local closeout copy.

Exit notes:

- GitHub source: `https://github.com/thalverson1022/Enigma.git`.
- Local workspace path: `F:\Data\Claude Projects\Project-Enigma`.
- Baseline source: `https://github.com/thalverson1022/DawnBringer.git`,
  `dawnbringer/main` at `df940053bda8f8b1369d10754828b69120b00b0d`.
- Branch strategy: `main` preserves the promoted Phase 4 baseline plus Enigma
  project docs; Phase 5 implementation continues on `phase-5-gear-redesign`.
- Baseline Godot smoke: after a first-time headless import pass, Godot 4.7
  headless launch exited with code 0 using
  `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project --quit-after 3`.
- Known local setup caveats: a fresh clone needs the Godot import cache built
  before the clean launch smoke; the CSV locale warning and Godot
  ObjectDB/resource cleanup warnings remain accepted non-blockers from Phase 4.

## P5M1 Gear Design Documents

Status: Complete.

P5M1 locks the initial design target before implementation. The gear design can
still evolve during testing, but the first pass is now explicit enough that
implementation milestones do not have to rediscover rules from chat history.
Final balance can remain provisional; the rules, knobs, calculation order,
stacking behavior, conflict behavior, and deferred tuning ownership must be
documented.

Exit notes:

- `docs/New_Gear_Overview.md` defines the core gear model, Lucky Coin, stat roll
  weights, stat value scaling, Cursed and Chaos drawbacks, damage calculation
  order, stack/status interactions, stat stacking rules, Special conflicts,
  Legendary boundaries, and milestone-tagged deferred decisions.
- `docs/P5M1_Gear_Design_Documents_Tracker.md` records all P5M1 design tasks as
  complete and preserves current known decisions.
- No remaining deferred decision blocks P5M2. Remaining topics are tuning,
  presentation, validation, or future-design follow-up.
- The design review pass found no remaining P5M1 blockers.

## P5M2 Gear Data Model And Migration Boundary

Status: Complete.

P5M2 replaces the old gear assumptions with the new five-slot model. This should
establish the data structures, save/load shape, and compatibility boundary
before individual stat effects are layered in.

Active task tracker:

- `docs/P5M2_Gear_Data_Model_And_Migration_Boundary_Tracker.md`

Exit notes:

- New slot model implemented: Weapon, Helm, Armor, Trinket, and Charm are now
  represented in gear data, BuildState equipment, Practice Room state,
  save/load fields, generated slot pools, and minimal UI/tool surfaces.
- Rogue display item families implemented: non-Legendary Rogue gear uses
  Dagger, Hood, Doublet, Ring, and Necklace display families while universal
  slot labels remain class-neutral.
- Gear data shape implemented in the existing `GearItem` and `StatModifier`
  resources, including expanded Phase 5 rarity vocabulary, item family,
  class/source metadata, deterministic metadata, stat ids, stat categories,
  drawback flags, and display labels.
- Lucky Coin retained as fixed authored gear with +5% Crit Chance, still
  awarded after Drunk Buddy and excluded from generated/shop/Legendary pools.
  It has since moved to Trinket/Ring in the current playtest baseline.
- Retained Rogue Legendaries remain named Weapon-slot Dagger items. Their final
  fixed stat packages and focused validation were completed in P5M10.
- Save/load behavior verified: new saves write five equipped fields; old or
  partial saves load safely; Lucky Coin and retained authored gear migrate by
  canonical id; obsolete old runtime-generated gear is quarantined from active
  inventory, shop, reward, and equipped surfaces.
- Minimal UI/tool surfaces are M2-safe: inventory/equipment, reward rows,
  route/shop previews, Practice Room, Balance Lab, and generated-route
  inspector paths tolerate the five-slot model. P5M8 has since completed final
  player-facing item presentation, and P5M9 has since supplied generated Rogue
  Hood/Doublet sprites.
- Official closeout regression bundle is recorded in
  `docs/P5M2_Gear_Data_Model_And_Migration_Boundary_Tracker.md` and passed.
  Known non-blockers remain: `save_load_test.gd` intentionally logs a corrupt
  JSON parse while testing corrupt saves, and Godot headless scripts still emit
  ObjectDB/RID/resource cleanup warnings on process exit.

Current downstream state:

- P5M7, P5M8, P5M9, and P5M10 are complete. P5M11 owns broad Practice Room and
  Balance Lab validation on top of the live reward/shop, readable five-slot UI,
  generated Rogue item-art baseline, and fixed retained Legendary packages.

## P5M3 Stat System Foundation

Status: Complete.

P5M3 gives gear a shared stat vocabulary. The milestone is complete: the
foundation now expresses the new item design through canonical stat IDs, slot
eligibility, and deterministic stat-sheet aggregation without hardcoding each
item as a one-off.

P5M3 also closed the remaining Project Enigma identity cleanup from the P5M2
audit. Godot's project name, export preset names, product/file descriptions,
and output paths now present as Project Enigma.

The stat foundation should follow the P5M1 stacking rules: Basic and Rare stats
stack additively, drawbacks add into the same aggregate stat as positives,
chance stats cap at 100%, final aggregate stat values floor at 0, duplicate
Specials are binary, and `All stats are increased by 20%` applies once to the
final non-negative stat sheet.

Completed task tracker:

- `docs/P5M3_Stat_System_Foundation_Tracker.md`

Exit notes:

- Godot-visible project and export identity updated to Project Enigma.
- Local Godot Project Manager registration updated on 2026-09-04 so
  `F:/Data/Claude Projects/Project-Enigma/project` appears as Project Enigma
  after reopening the Project Manager.
- `StatCatalog` defines the canonical Basic, Rare, Special, drawback, and
  compatibility stat vocabulary with labels, categories, value kinds,
  floor/cap rules, all-stats scaling metadata, and legacy aliases.
- Slot/category eligibility is encoded for Weapon, Helm, Armor, Trinket, and
  Charm; drawback pools derive from eligible Basic stat pools.
- `StatSheet` aggregates equipped gear by canonical stat ID, supports positive
  and negative values, applies floors and chance caps, and bridges into current
  `PlayerStats`.
- Special effects are represented as deduplicated IDs, source counts, named
  accessors, and structured summaries for denial, ignore, conversion, stack
  doubling, all-stats scaling, and stun/slow/interrupt immunity hooks.
- Existing authored gear, retained Legendaries, Lucky Coin, generated gear,
  Practice Room custom gear, save/load, and minimal formatter paths tolerate
  canonical IDs.
- Focused regression coverage is recorded in the P5M3 tracker. Known
  non-blockers remain accepted Godot ObjectDB/resource cleanup warnings and the
  intentional corrupt-save JSON parse logged by `save_load_test.gd`.

Handoff:

- P5M4 delivered weapon rolls, Rogue physical skill scaling,
  conversion/mitigation application, armor/resistance ignore behavior, and
  final damage-order integration.
- P5M5 delivered full procedural rarity/stat rolling, Unique Special rolls, and
  first-pass Cursed/Chaos drawback generation.
- P5M8 delivered final player-facing item card presentation.
- P5M10 has since delivered retained Legendary fixed packages; P5M11 owns full
  Practice Room and Balance Lab validation across the completed gear surface.

## P5M4 Weapon Damage Scaling

Status: Complete.

Completed tracker:

- `docs/P5M4_Weapon_Damage_Scaling_Tracker.md`

P5M4 moved Rogue physical skill damage onto deterministic weapon rolls. Weapons
now have combat-facing rarity ranges, and authored Rogue physical skills use the
documented weapon-scaling percentages.

Exit notes:

- `WeaponDamageCatalog` defines Rogue dagger ranges for Crude, Basic, Master,
  Epic, Cursed, Chaos, Unique, and Legendary, with explicit fallback behavior.
- `BuildResolver` bridges the active equipped Weapon into `PlayerStats` so
  combat can consume weapon range data at the existing resolver boundary.
- Physical Rogue casts roll weapon damage once after dodge and before crit, and
  record roll metadata on resolved cast events.
- Flat `Base Damage` and Bandit Blade's gold-scaled flat physical bonus apply
  before skill scaling.
- Gear Percent Physical Damage and class/talent physical damage are separated
  into distinct multiplicative buckets.
- Death Strike resolves as one weapon-scaled packet, adding 1 flat damage per
  active poison stack before its 111% skill scaling.
- Damage conversion, armor/resistance ignore, and enemy denial hooks are
  consumed by combat where they affect the damage pipeline.
- Retriggers resolve as separate same-timestamp proc casts with fresh weapon
  rolls, fresh crit rolls, full state processing, source filtering, recursive
  compatibility, and a hard chain cap.
- Damage calculation preserves floating-point math through the pipeline, applies
  crit before conversion, conversion before mitigation, the current mitigation
  order, a 1-damage floor unless fully prevented, and one final rounding point.
- Focused P5M4 regressions and adjacent combat/presentation smoke checks passed;
  accepted Godot ObjectDB/RID/resource cleanup warnings remain non-blocking.

Handoff:

- P5M5 delivered full procedural rarity/stat rolling, Unique Special rolls,
  Cursed and Chaos drawback generation, and generator-side use of the completed
  weapon damage ranges.
- P5M6 owns Shop Lab simulation and tuning visibility for rarity odds,
  contract-depth scaling, Special frequency, and retrigger-cap risk.
- P5M7 delivered live reward/shop integration.
- P5M8 delivered final item-card presentation, and P5M9 delivered generated
  Rogue item art.
- P5M10 delivered fixed Legendary stat packages and retained Legendary
  validation. P5M11 owns broad Practice Room and Balance Lab validation across
  the completed gear surface.

## P5M5 Gear Generator And Rarity Rules

Status: Complete.

Completed tracker:

- `docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md`

P5M5 built the procedural generator for the new item model. The generator now
produces readable, deterministic gear from rarity rules, slot pools, and stat
categories while keeping authored/fixed gear outside random pools.

Exit notes:

- `GearGenerator.generate_from_request()` is the explicit deterministic
  request/result contract for generated gear, with slot, rarity, RNG/seed,
  deterministic key/id, source metadata, value scaling, and validation errors.
- Crude is rejected by procedural generation and remains reserved for starter
  gear.
- Basic, Master, Epic, Cursed, Chaos, and Unique are the active procedural
  rarities.
- Slot-aware weighted stat selection uses `StatCatalog` Basic, Rare, Special,
  and drawback pools and excludes disabled or already-used stat IDs.
- Generated non-Chaos items cannot roll duplicate canonical stat IDs on the same
  item, including positive/drawback and Special collisions. Chaos has since
  become the deliberate exception and may duplicate stat IDs across all four
  rolls.
- Numeric Basic/Rare values roll from slot/stat ranges, apply rarity scaling,
  preserve the contract-depth scaling hook, and round by value kind.
- Cursed items roll 2 Basic positives, 1 Rare positive, and 1 slot-eligible
  Basic-stat drawback at the documented drawback multiplier.
- Chaos items roll four seeded outcomes from positive Basic/Rare or Basic-stat
  drawback options at the documented Chaos magnitude and exclude Specials.
- Unique items roll 3 Basic positives, 1 Rare positive, and exactly 1
  slot-eligible binary Special.
- Legendary procedural requests fail loudly; live Legendary shop/reward paths
  remain fixed-catalog selections, with retained Legendary package validation
  completed in P5M10.
- Lucky Coin, placeholder compatibility gear, retained Rogue Legendaries, and
  fixed authored reward paths remain excluded from procedural generation.
- Consolidated regression coverage now validates the full generator surface,
  live shop/reward callers, save/load metadata, and adjacent Phase 5 stat,
  weapon, shop/reward UI, training-room, and encounter-reward checks.
- Known non-blockers remain accepted: Godot headless ObjectDB/RID/resource
  cleanup warnings on process exit and the intentional corrupt-save JSON parse
  output from `save_load_test.gd`.

Handoff:

- P5M6 owns Shop Lab simulation, rarity-odds tuning, contract-depth scaling
  visibility, Special frequency inspection, Chaos outcome tuning, and retrigger
  cap risk visibility.
- P5M7 delivered final live Adventure reward/shop rarity distributions and the
  additional deterministic context needed by those flows.
- P5M8 delivered final item presentation, and P5M9 delivered generated Rogue
  item art.
- P5M10 delivered final fixed Legendary stat packages and per-Legendary
  validation. P5M11 owns broad Practice Room and Balance Lab validation across
  the completed shop, reward, presentation, art, and Legendary surfaces.

## P5M6 Shop Lab Gear Simulation

Status: Complete.

P5M6 updated Shop Lab as the first feel-testing surface for the new item
economy. The lab rolls many shops quickly and lets tuning work inspect whether
item offers create interesting decisions before wiring every result into
Adventure.

P5M6 owns the first deferred tuning pass for contract-depth item value scaling,
rarity odds by depth, provisional stat ranges, Special frequency, whether
Rare-stat drawbacks are needed, and whether Chance for Retrigger can approach
dangerous cap values in legal builds.

Exit notes:

- Shop Lab rolls five-slot Rogue gear offers for Weapon, Helm, Armor, Trinket,
  and Charm, displaying Dagger, Hood, Doublet, Ring, and Necklace identities.
- Contract-depth rarity scaling and value scaling can be simulated.
- Cursed, Chaos, Unique, Special, drawback, Legendary-boundary, Lucky Coin, and
  retrigger-risk behavior is visible through item cards and aggregate readouts.
- Default Early curve checkpoints for P5M7 discussion are depth 1:
  65/23/6/2/3/1, depth 6: 54/26/10/4/4/2, and depth 12:
  41/29/15/7/5/3 for Basic/Master/Epic/Cursed/Chaos/Unique.
- Output is readable enough for tuning discussions while final player-facing
  item presentation remains P5M8.
- `node tools/shop-lab/run_checks.js` passed with
  `shop-lab checks ok: 23 checks passed`.

## P5M7 Reward And Shop Integration

Status: Complete.

P5M7 connected the new generator to the live Adventure loop. Generated rewards
and between-contract shops now use deterministic item generation while still
leaving room for later balance changes.

Completed task tracker:

- `docs/P5M7_Reward_And_Shop_Integration_Tracker.md`

Exit notes:

- Every generated contract gear reward presents two gear choices.
- Each reward choice independently rolls a low-percentage deterministic upgrade
  chain before item generation: Basic to Master, Master to Epic, then Epic to
  Cursed, Chaos, or Unique.
- New procedural Legendary reward upgrades remain deferred beyond P5M10, and
  procedural Legendary stat packages remain forbidden.
- Reward upgrade odds and generated item values use live contract depth clamped
  from 1-12.
- Between-contract shops generate Phase 5 gear using the P5M6 Early curve
  across Basic, Master, Epic, Cursed, Chaos, and Unique.
- Shops do not open while the player is still traversing an active generated
  contract route.
- Increased Gold applies to stash gains. Shop Discount reduces generated shop
  purchase prices only; reroll costs and sell values stay fixed.
- Increased Magic Find multiplies each generated reward/shop rarity-upgrade
  check after the starting rarity roll; it does not upgrade fixed Legendary
  rolls.
- Focused regression covers reward choice count, deterministic upgrades, rarity
  bounds, Legendary boundaries, save/load, duplicate guards, shop rolls, UI
  compatibility, and gold behavior.

## P5M8 Inventory, Equipment UI, And Item Presentation

Status: Complete.

P5M8 made the redesigned gear visible, usable, comparable, and understandable
to players. Helm and Armor are now fully usable rather than empty inventory
affordances, and all live item surfaces use the shared presentation contract.

Completed task tracker:

- `docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`

Exit notes:

- Five slots work in the equipment UI: Weapon/Dagger, Helm/Hood,
  Armor/Doublet, Charm/Necklace, and Trinket/Ring.
- Charm/Necklace appears above Trinket/Ring on the right side of the equipment
  layout in live Adventure and Practice Room surfaces.
- Shared item cards describe name, rarity, slot, Rogue item family, weapon
  damage for weapons, positive stats, drawbacks, Specials, and Legendary
  effects clearly.
- Inventory, shop, and reward-choice comparison tooltips match candidates to
  the equipped item in the same slot for all five slots.
- Rarity colors and Epic's distinct light-fill plus border/glow treatment are
  represented across live surfaces.
- Player-facing item text stays sparse and hides raw stat IDs and
  generator/debug metadata.
- Hood and Doublet now use the P5M9 generated Rogue sprites.

## P5M9 Art And Sprite Pass

Status: Complete.

P5M9 supplied item art for the expanded gear set. Dagger, Hood, Doublet, Ring,
and Necklace now have project-owned generated Rogue sprites across supported
rarities, and live UI surfaces use those mappings.

Exit notes:

- 31 generated Rogue sprites were imported under
  `project/assets/Items/Rogue/Generated/`.
- `GearIcons.icon_for()` resolves generated Rogue slot-and-rarity pairs before
  generic fallbacks.
- Lucky Coin and retained Rogue Legendary icon overrides remain ahead of
  generated mappings.
- Comparison tooltips now render item icons for both candidate and equipped
  gear.
- Live UI sprite readability screenshots were captured for equipment,
  inventory, shop offers, reward choices, comparison tooltips, and Practice
  Room.
- `p5m9_icon_regression_test.gd`, `p5m9_special_icon_overrides_test.gd`, and
  `p5m9_ui_sprite_readability_test.gd` passed.

## Current Post-P5M11 Playtest Baseline

Status: Active baseline.

These updates happened during post-P5M9 hands-on tuning, the P5M10 Legendary
closeout, and P5M11 tuning, and should be treated as the current rule
baseline unless a later task explicitly supersedes them:

- Starting gear is a Crude Dagger; unarmed weapon damage falls back to 1.
- Character sheet order now includes Shred Chance, Decay Chance, Poison Proc
  Chance, Bonus Stacks, Increased Gold, Shop Discount, Magic Find, Base Poison
  Damage, and Poison Damage Increase. Crit Damage displays as a one-decimal
  multiplier.
- Crit Chance starts at 5%. Crit Damage starts at 2.0x and can be reduced to
  1.0x. Negative physical/poison damage increases and attack speed can reduce
  final results below the unmodified baseline while base damage values retain
  their minimum floors.
- Bonus Stacks is one stat that increases poison, shred, and decay stack
  applications.
- `Chance for Crits to Apply Poison` replaces the old Crit Applies Element
  behavior for Rogue and applies normal poison stacks on crits.
- Shred and Decay are universal debuffs. Shred starts at 10 armor reduction per
  stack. Decay starts at 20% resistance decay per stack.
- Assassin, Bladedancer, Shadow, and Thief received targeted playtest tuning
  documented in `docs/New_Gear_Overview.md`.
- Practice Room supports Crude Dagger, active generated rarities, Chaos
  duplicate stat editing, max-value defaults, whole-percent/chance value entry,
  integer flat-damage and stack value entry, shared rich tooltip readability,
  and scroll-safe talent windows.
- Non-Chaos item tooltips display stat lines in a fixed physical, elemental,
  utility, economy, proc, then Special order. Chaos item tooltips preserve
  actual roll order. Basic, Rare, Special, and drawback stat lines use distinct
  category colors, and max rolls render bold and two font sizes larger in
  Adventure and Practice Room.
- Shop Discount and Magic Find are Basic/Rare economy stats available to every
  slot. Increased Gold can roll as Basic or Rare. Shop Discount affects
  purchase prices only; Magic Find multiplies generated-item rarity upgrade
  checks; Increased Gold sums from gear and multiplies talent bonuses.
- Tavern dagger purchases move the Crude Dagger into inventory, Crude Dagger
  sell value is 5g, and Mouthy Drunk HP is 145.
- Generated contract HP scaling uses a sharper contract 1-30 curve with path
  enemies made heavier and bosses slightly less dominant relative to the path.
- Overkill Gold grants 10g per full 100 overkill damage on combat wins, capped
  at 50g before Increased Gold modifiers.
- Combat UI tooltips now cover current stacking debuffs and enemy mechanics.
- Retained Rogue Legendaries now use fixed Phase 5 stat packages while
  preserving bespoke effects, authored icons, 21-27 Legendary weapon damage,
  save/load compatibility, Practice Room selection, and Balance Lab coverage.

## P5M10 Legendary Revisit And Fixed Legendary Stats

Status: Complete.

P5M10 brought existing Rogue legendaries into the new gear rules. Legendary
effects remain class-specific and build-defining, but the larger legendary
redesign waits for the future talent-tree overhaul.

The retained Legendary list is fixed for Phase 5: Wyvern Kriss, Bandit Blade,
Umbral Stiletto, Mithril Karambit, and Bejeweled Push Dagger. They are all
unique-name Weapon-slot daggers with handcrafted target packages documented in
`docs/New_Gear_Overview.md` and implemented in `project/data/gear/`.

Exit notes:

- Existing Rogue legendaries were audited for resource identity, icon overrides,
  save/load paths, reward/equip paths, Practice Room hooks, Balance Lab hooks,
  and combat effect wiring.
- Fixed canonical stat packages were assigned to all five retained Legendary
  resources exactly from the documented target values.
- Legendary effects still function through focused combat validation.
- Item cards, comparison tooltips, reward auto-equip, inventory/equipment,
  save/load compatibility, icon overrides, generator/catalog boundaries,
  Practice Room selection, and Balance Lab mechanics coverage are verified.
- Broader Legendary redesign remains deferred to the later talent-tree phase.

## P5M11 Practice Room And Balance Lab Validation

Status: Complete.

P5M11 ensures the new gear system can be tested outside a full Adventure run.
Practice Room should support hands-on build checks, while Balance Lab should
provide repeatable deterministic validation.

P5M11 should validate the newly documented rule surface, including stat
aggregation, floors and caps, damage order, stack/status interactions, Special
conflicts, Cursed/Chaos drawbacks, Legendary behavior, and the tuning watch item
that Chance for Retrigger must stay below 100% in normal legal builds.

Active progress tracker:

- `docs/P5M11_Practice_Room_Balance_And_Readability_Tracker.md`

Exit notes:

- Practice Room supports new slots, active generated rarities, Crude Dagger,
  Legendary weapon selection, None clearing, generated target controls, random
  seed behavior, max-value defaults, and current stat value entry rules.
- Practice Room supports current stat effects, combat playback readability, and
  Adventure-isolated practice gold/build state.
- Balance Lab covers generated route outputs, retained Legendary mechanics, and
  combat-relevant stat behavior.
- Adventure validation covers combat HUD, reward/shop/route UI, save/load, and
  the primary generated-contract loop.
- Deterministic replay expectations remain verified by the focused generator,
  route, save/load, and combat checks.
- One Balance Lab warning for `bladedancer_contract_watchmen` is accepted as a
  future talent-tree balance watch; it is not a P5M11 blocker.

Practice Room validation progress, 2026-09-07:

- Practice Room supports all five generated gear slots, Crude Dagger, all
  active generated rarities, editable Legendary weapon selection, and None
  clearing without mutating Adventure state.
- Choosing a generated rarity now seeds each stat slot at the maximum rolled
  value for that slot, rarity, stat category, and stat ID; subsequent stat
  dropdown changes do the same while preserving free manual value edits.
- Practice Room character-sheet coverage includes economy stat display for
  Increased Gold, Shop Discount, and Magic Find above the poison section.
- User playtest verification accepts the rarity-upgrade odds mechanics as
  working as intended for P5M11; remaining odds work should be light regression
  protection rather than a fresh probability audit.
- Item tooltip readability is implemented across Adventure and Practice Room:
  fixed stat order except Chaos, category colors for Basic/Rare/Special/drawback
  lines, and bold plus two-font-size max-roll emphasis.
- Economy-affix behavior is implemented: Shop Discount, Magic Find, and Rare
  Increased Gold rolls; Increased Gold aggregates with talent multipliers.
- Tavern tuning is implemented: bought daggers preserve the Crude Dagger in
  inventory, Crude Dagger sell value is 5g, and Mouthy Drunk HP is 145.
- Generated contract HP tuning is implemented with the sharper contract 1-30
  curve and heavier path enemies.
- Overkill Gold is implemented at 10g per full 100 overkill damage, capped at
  50g before Increased Gold reward modifiers.

Practice Room validation evidence, 2026-09-07:

- `project/tests/training_room_entry_test.gd` passed.
- `project/tests/training_room_build_test.gd` passed.
- `project/tests/training_room_gear_editor_test.gd` passed.
- `project/tests/training_room_fight_setup_test.gd` passed.
- `project/tests/training_room_fight_test.gd` passed.
- `project/tests/training_room_combat_view_test.gd` passed.
- `project/tests/p5m4_practice_room_combat_smoke_test.gd` passed.
- `project/tests/p5m11_economy_stats_test.gd` passed.
- `project/tests/p5m8_stat_readability_test.gd` passed.
- `project/tests/p5m8_ui_regression_test.gd` passed.
- `project/tests/p5m11_overkill_gold_test.gd` passed.
- `project/tests/p5m7_gold_gain_economy_test.gd` passed.
- `project/tests/contract_route_generator_test.gd` passed.
- `project/tests/runtime_monster_generator_test.gd` passed.
- `project/tests/generated_route_matrix_test.gd` passed.
- `project/tests/balance_lab_test.gd` passed.
- `project/scripts/tools/run_balance_suite.gd` completed with 69 pass, 1
  accepted balance warning, and 0 fail.

P5M11 closeout validation evidence, 2026-09-10:

- `project/tests/training_room_gear_editor_test.gd` passed.
- `project/tests/training_room_fight_setup_test.gd` passed.
- `project/tests/skill_tooltip_formatter_test.gd` passed.
- `project/tests/p5m8_stat_readability_test.gd` passed.
- `project/tests/p5m8_ui_regression_test.gd` passed.
- `project/tests/p5m11_economy_stats_test.gd` passed.
- `project/tests/p5m11_overkill_gold_test.gd` passed.
- `project/tests/p5m7_gold_gain_economy_test.gd` passed.
- `project/tests/contract_route_generator_test.gd` passed.
- `project/tests/runtime_monster_generator_test.gd` passed.
- `project/tests/generated_route_matrix_test.gd` passed.
- `project/tests/balance_lab_test.gd` passed.
- `project/scripts/tools/run_balance_suite.gd` completed with 69 pass, 1
  accepted balance warning, and 0 fail.
- `project/tests/character_stats_contract_badge_test.gd` passed.
- `project/tests/combat_hud_test.gd` passed.
- `project/tests/reward_shop_route_ui_test.gd` passed.
- `project/tests/opportunity_strikes_test.gd` passed.
- `project/tests/enemy_defense_mechanics_test.gd` passed.
- `project/tests/combat_recap_test.gd` passed.
- `project/tests/combat_screen_test.gd` passed.
- `project/tests/save_load_ui_test.gd` passed.
- `project/tests/save_load_test.gd` passed, with expected corrupt-save parse
  output.
- `project/tests/training_room_combat_view_test.gd` passed.

## P5M12 Phase 5 Regression, Smoke, And Closeout

Status: Complete.

P5M12 closes the phase by proving that the new gear baseline works across the
Adventure loop, tools, saves, player-facing surfaces, and web export packaging.

Exit notes:

- Regression pass recorded in
  `docs/P5M12_Phase_5_Regression_Smoke_And_Closeout_Tracker.md`.
- Scripted smoke coverage passed through the P5M12 regression script, Balance
  Lab, Shop Lab, export-sensitive class scan, and Godot Web export.
- Itch.io-ready web package created from the `Project Enigma Web Itch` export
  preset at `release/itchio/project-enigma-phase5-itch.zip`.
- Known non-blockers recorded.
- Overview, onboarding, checklist, tracker, and handoff docs updated.
- Final Phase 5 handoff written in `docs/P5_Phase_5_Closeout_Handoff.md`.
