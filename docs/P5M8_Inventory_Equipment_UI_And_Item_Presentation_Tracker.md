# P5M8: Inventory, Equipment UI, And Item Presentation Tracker

## Status

Complete.

P5M8 makes the redesigned Phase 5 gear visible, equippable, comparable, and
understandable in the live player UI. P5M2-P5M7 built the five-slot data model,
stat system, weapon scaling, procedural generator, Shop Lab simulation, and live
reward/shop integration. P5M8 is the readability pass that lets players make
confident gear decisions from those systems.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone documents:

- `docs/P5_Gear_Redesign_Overview.md`
- `docs/P5M6_Shop_Lab_Gear_Simulation_Tracker.md`
- `docs/P5M7_Reward_And_Shop_Integration_Tracker.md`

## Milestone Goal

Make Phase 5 gear readable and actionable in the live UI: players can equip all
five slots, compare generated rewards and shop items against current gear,
understand rarity, slot, Rogue item family, stats, drawbacks, and Specials at a
glance, and do so without seeing debug generator metadata.

P5M8 is not the Hood/Doublet final art pass, retained Legendary stat tuning,
Practice Room expansion, Balance Lab validation, or full balance pass. Those
remain assigned to P5M9-P5M11.

## Locked M8 Presentation Decisions

Equipment layout:

- Five equipment slots remain Weapon, Helm, Armor, Trinket, and Charm.
- Rogue display families remain Dagger, Hood, Doublet, Ring, and Necklace.
- The right-side equipment column should present neck above finger: the upper
  right slot is Charm/Necklace, and the lower right slot is Trinket/Ring.
- If the current live UI has Trinket above Charm on the right side, P5M8 should
  correct the ordering and add focused coverage so it does not drift again.

Original placeholder art boundary:

- P5M9 owned final Hood and Doublet sprites and has since completed the
  generated Rogue item-art pass.
- During P5M8, generated Hood and Doublet items could use the existing generic
  tier placeholder icons from `project/assets/ui/icons/gear_drop_helm_*.png`.
- Existing Dagger, Ring, Necklace, Lucky Coin, and retained Rogue Legendary art
  should continue to be used where already available.
- M8 should rely on text, slot labels, rarity treatment, and comparison
  structure to carry item identity where placeholder art is still temporary.

Player-facing text boundary:

- Item cards should show player-meaningful rarity, slot, Rogue item family,
  stat, drawback, and Special information.
- Raw stat IDs, deterministic keys, source seeds, generator contexts, validation
  internals, and other debug metadata should stay hidden from normal player UI.
- Sparse text is preferred, but sparse should not mean ambiguous.

## Current Presentation Baseline

Current UI/tool surfaces tolerate the Phase 5 gear model after P5M7, but they
are not yet the final player-facing presentation:

- Live generated contract rewards offer two generated gear choices.
- Between-contract shops roll Phase 5 Basic, Master, Epic, Cursed, Chaos, and
  Unique gear.
- Existing generic gear-box rendering handles expanded rarity labels, colors,
  prices, icons, and comparison tooltips well enough for compatibility.
- `GearIcons.icon_for()` uses hand-authored icons for named Rogue Legendaries
  and Lucky Coin, slot/tier icons for existing Weapon, Trinket, and Charm art,
  and generic tier fallback icons for newer or unmapped slot/tier combinations.
- Helm/Hood and Armor/Doublet currently depend on generic placeholder art until
  P5M9.

## Exit Criteria

- Weapon, Helm, Armor, Charm, and Trinket are all visible and usable in the
  equipment UI.
- The right-side equipment column presents Charm/Necklace above Trinket/Ring.
- Inventory, reward, shop, sell, and equip flows route each item to the correct
  slot and compare against the correct equipped item.
- Item cards consistently show rarity, slot, Rogue item family, item name,
  weapon damage when relevant, positive stats, drawbacks, and Specials.
- Rarity colors and treatments are represented across inventory, rewards,
  shops, and tooltips, including an Epic treatment that reads as distinct even
  though Epic's documented color is white.
- Player-facing item text stays clear, sparse, and non-debug.
- Placeholder art usage for Hood and Doublet is explicit and does not block
  P5M8 closeout.
- Focused regression coverage records five-slot rendering, Charm-over-Trinket
  ordering, item-card content, rarity display, comparison slot matching, and
  hidden debug metadata.
- Phase 5 docs are updated with P5M8 completion notes and the P5M9 handoff.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M8-T1: Audit Current Inventory And Equipment UI | Complete | Identify every player-facing place that renders gear slots, equipped items, item boxes, item tooltips, reward choices, shop offers, and comparisons. | Audit notes list the relevant scenes/scripts/tests and current gaps for five-slot presentation. |
| P5M8-T2: Lock Equipment Slot Layout Rules | Complete | Record the intended equipment layout before code edits. | Equipment UI source of truth says right-side upper slot is Charm/Necklace and right-side lower slot is Trinket/Ring. |
| P5M8-T3: Fix Five-Slot Equipment Panel | Complete | Make Weapon, Helm, Armor, Charm, and Trinket behave clearly in the equipment UI. | Helm and Armor are fully usable; Charm and Trinket appear in the locked right-side order; equipment controls remain stable. |
| P5M8-T4: Standardize Item Card Content | Complete | Make item cards the shared readable representation for inventory, rewards, shops, and tooltips. | Shared item cards now show item name, rarity/slot/family, weapon damage when relevant, positive stats, drawbacks, Specials, and Legendary effects without debug metadata. |
| P5M8-T5: Improve Stat And Drawback Readability | Complete | Format generated stat lines as player-facing language. | Positive stats, negative drawbacks, percentage values, stack values, binary Specials, and legacy multiplier bonuses now read clearly without raw IDs or ambiguous `xN%` shorthand. |
| P5M8-T6: Apply Rarity Presentation Rules | Complete | Make rarities visually scannable across live surfaces. | Rarity colors are consistent; Epic now uses documented white/light color with a stronger border/glow treatment; Cursed, Chaos, Unique, and Legendary keep distinct shared styling. |
| P5M8-T7: Improve Gear Comparison Tooltips | Complete | Help players compare a candidate item against the currently equipped item for the same slot. | Reward, shop, and inventory comparisons use correct slot matching for all five slots. |
| P5M8-T8: Verify Equip, Unequip, Buy, Sell, And Reward Flows | Complete | Confirm presentation work did not disturb live item flow. | Focused automated checks cover all five slots through direct equip, inventory equip, replacement, unequip, reward choice claim, shop purchase, inventory/equipped sell flow, full-inventory blocking, save/load, and Adventure continuation. |
| P5M8-T9: Add Focused UI Regression Coverage | Complete | Protect the M8 presentation contract. | Regression tests now cover five-slot equipment rendering, Charm-over-Trinket ordering, item-card content, rarity display, all-slot comparison matching, live Epic styling, and hidden debug metadata. |
| P5M8-T10: Update Docs And Closeout | Complete | Record implemented behavior and remaining caveats. | This tracker, onboarding, Phase 5 overview, and relevant gear docs record P5M8 completion and hand off Hood/Doublet art to P5M9. |

## P5M8-T1 Audit Notes

Status: Complete.

Audited player-facing gear presentation surfaces:

- `project/scenes/combat/gear_panel.gd` owns the live dashboard Gear panel:
  gold stash badge, equipment paper doll, inventory grid, inventory/equipped
  action menus, equip/unequip motion, shop-gated sell flow, item tooltips, and
  inventory comparison tooltips.
- `project/scenes/combat/combat_screen.gd` owns reward-choice button creation,
  reward-choice selection flow, shop overlay show/hide timing, reward claim
  flow, and shop buy/reroll callbacks.
- `project/scenes/combat/shop_overlay.gd` owns between-contract shop offer
  rows, price badges, affordability state, reroll affordance, shop offer
  tooltip text, and offer comparison tooltip construction.
- `project/scenes/combat/reward_choice_overlay.gd` owns the reward-choice modal
  shell and options container; `combat_screen.gd` still builds the actual gear
  choice buttons.
- `project/scripts/ui/card_style.gd` is the shared item-box and tooltip helper
  for inventory slots, equipped slots, shop offers, reward choices, and
  comparison tooltip boxes.
- `project/scripts/ui/gear_compare_button.gd` provides the custom tooltip hook
  used by inventory, shop, and reward gear buttons.
- `project/scripts/ui/gear_icons.gd` maps named Rogue Legendaries and Lucky Coin
  to authored icons, maps Weapon/Trinket/Charm Basic/Master/Cursed to existing
  slot art, and falls back to generic tier icons for other slot/tier
  combinations, including current Hood/Doublet placeholders.
- `project/scripts/ui/stat_modifier_formatter.gd` is the shared text formatter
  for gear affixes, talent modifiers, and tooltip lines.
- `project/scripts/ui/ui_colors.gd` defines current rarity colors consumed by
  `CardStyle`, `GearPanel`, shop/reward buttons, and Practice Room gear slots.
- `project/scripts/autoload/build_state.gd` owns the five equipped slots,
  inventory, generated reward choices, shop offers, equip/unequip/sell
  behavior, same-slot equipment lookup, and generated shop/reward item routing.
- `project/scenes/training_room/training_room.gd` owns the Practice Room gear
  paper doll and editor. This is not the live Adventure inventory, but it is a
  player-facing validation surface that currently renders and edits all five
  slots.

Current behavior observed:

- Live Adventure equipment state supports Weapon, Helm, Armor, Trinket, and
  Charm via `BuildState.equipped_weapon`, `equipped_helm`, `equipped_armor`,
  `equipped_trinket`, `equipped_charm`, `equip()`, `unequip()`,
  `sell_equipped_item()`, and `equipped_item_for_slot()`.
- Inventory, shop, and reward comparison tooltips already match candidates to
  the currently equipped item by `gear.slot` through
  `BuildState.equipped_item_for_slot(gear.slot)` or
  `BuildState.equipped_item_for_slot(offer.slot)`.
- Shop offers and reward choices already use `GearCompareButton`,
  `CardStyle.style_shop_item_box()`, `CardStyle.build_gear_box_content()`, and
  `CardStyle.gear_tooltip_lines()` for shared presentation.
- Inventory filled slots use `GearCompareButton`; empty inventory slots remain
  plain disabled buttons.
- Live shop offers show an always-visible price badge, affordability state, and
  tooltip footer. Reward choices show a click hint or inventory-full blocker.
- `CardStyle.gear_tooltip_lines()` currently shows item name,
  rarity/slot/family, weapon damage for weapons, grouped generated stat lines,
  and triggered-skill effects. Legendary tooltips delegate to
  `LegendaryCatalog.tooltip_lines()`, which now follows the same header shape.
- Raw generated metadata fields on `GearItem` (`source_context`,
  `source_seed`, `deterministic_key`) are not rendered by the shared card or
  tooltip helpers found in this audit.
- Practice Room has all five gear slot buttons and supports rarity-driven
  editing for Helm, Armor, Trinket, and Charm, with Legendary selection limited
  to Weapon.

Current gaps and follow-up targets:

- T1 found that `gear_panel.gd` constructed the right-side stack as
  Trinket/Ring above Charm/Necklace, which conflicted with the locked P5M8
  rule. P5M8-T3 corrected the live Gear panel order and added focused coverage.
- T1 found that `training_room.gd` also rendered the Practice Room right-side
  stack as Trinket above Charm. P5M8-T3 aligned Practice Room with the locked
  live equipment layout.
- T1 found that item family identity was implicit in the shared item-card path.
  P5M8-T4 resolved this by adding the explicit `Rarity Slot / Rogue Family`
  header line.
- T1 found that weapon damage was missing from the shared item-card path.
  P5M8-T4 resolved this by adding a weapon-only damage range line.
- Drawbacks and Specials now receive shared section headers, and P5M8-T5
  tightened the shared stat formatter so generated flat, percent, chance,
  stack, drawback, binary Special, and legacy multiplier values use clear
  player-facing signs and labels.
- Rarity rendering is visually available through shared slot/button colors and
  text. P5M8-T6 reconciled Epic with `docs/New_Gear_Overview.md`: Epic now uses
  a white/light rarity color plus a stronger border/glow treatment so it does
  not collapse into Basic, empty, or disabled states.
- Existing icons cover named Rogue Legendaries, Lucky Coin, and older
  Weapon/Trinket/Charm Basic/Master/Cursed art. Helm/Hood, Armor/Doublet, Epic,
  Chaos, and Unique currently rely on fallback tier icons, which is acceptable
  under the P5M8 placeholder-art boundary but should remain explicit.

Existing focused coverage relevant to this audit:

- `project/tests/p5m2_five_slot_equipment_test.gd` verifies five-slot generated
  pools, BuildState equip/unequip/sell paths, save/load roundtrip, and Practice
  Room state.
- `project/tests/build_panels_test.gd` verifies the Gear panel exists, equipped
  and inventory visual differences, inventory item icons, inventory comparison
  tooltip shape, inventory equip, equipped action menus, and equipped-slot
  unequip behavior.
- `project/tests/reward_shop_route_ui_test.gd` verifies shop offer rendering,
  price badges, affordability state, two-box comparison tooltips, reward-row
  summary text, and several Phase 5 rarity rendering helper paths.
- `project/tests/route_reward_choice_ui_test.gd` verifies generated reward
  choice count, reward-choice tooltip basics, full-inventory blocking, skip
  flow, successful choice flow, and Legendary reward tooltip/equip behavior.
- `project/tests/training_room_gear_editor_test.gd` verifies Practice Room
  five-slot gear editor state, Helm/Armor usability, Cursed affix counts,
  Legendary weapon behavior, compact overflow behavior, and isolation from live
  Adventure `BuildState`.

Resolved P5M8-T9 regression coverage:

- `project/tests/p5m8_item_card_content_test.gd` locks the core T4 card
  contract for generated Master weapons, Cursed drawbacks, Unique Specials,
  Legendary effects, and hidden metadata.
- `project/tests/p5m8_stat_readability_test.gd` locks the core T5 stat wording
  contract for generated positives, drawbacks, Rare chances, binary Specials,
  hidden stat ids, and legacy multiplier text.
- `project/tests/p5m8_rarity_presentation_test.gd` locks the core T6 rarity
  presentation contract for all rarity colors, shared item-box style derivation,
  disabled-state muting, and Epic's distinct treatment.
- `project/tests/p5m8_flow_verification_test.gd` locks the core T8 flow
  contract for all five slots across equip, unequip, replacement, reward choice,
  shop buy, inventory/equipped sell, full-inventory blocking, and save/load.
- `project/tests/p5m8_ui_regression_test.gd` closes the remaining T9 gap by
  checking all five slots through live inventory, shop, and reward comparison
  tooltip routing; each comparison must use the same-slot equipped item, ignore
  different-slot equipped items, hide generator metadata, and preserve Epic's
  stronger live style across equipped, inventory, shop, and reward surfaces.
- `project/tests/build_panels_test.gd`, `project/tests/reward_shop_route_ui_test.gd`,
  `project/tests/route_reward_choice_ui_test.gd`, and
  `project/tests/combat_screen_test.gd` remain part of the surrounding UI smoke
  net for Charm-over-Trinket layout, shop/reward surfaces, reward choice
  blocking, and Adventure continuation.

The original remaining work after P5M8 was the P5M9 art handoff. P5M9 has since
completed generated Rogue item sprites for Dagger, Hood, Doublet, Ring, and
Necklace.

## P5M8-T2 Equipment Slot Layout Source Of Truth

Status: Complete.

The intended live equipment paper-doll layout for P5M8 is locked as:

| Position | Universal Slot | Rogue Family |
| --- | --- | --- |
| Top center | Helm | Hood |
| Middle left | Weapon | Dagger |
| Middle center | Armor | Doublet |
| Middle right upper | Charm | Necklace |
| Middle right lower | Trinket | Ring |

This rule applies first to the live Adventure Gear panel in
`project/scenes/combat/gear_panel.gd`. Practice Room is also a player-facing
gear validation surface, so `project/scenes/training_room/training_room.gd`
should use the same right-side Charm-over-Trinket order unless a later task
explicitly records a reason to diverge.

Implementation note: P5M8-T3 moved the actual node creation so
Charm/Necklace is added before Trinket/Ring in both the live Gear panel and the
Practice Room paper doll, with focused checks now covering that order.

## P5M8-T3 Five-Slot Equipment Panel Notes

Status: Complete.

Implemented behavior:

- `project/scenes/combat/gear_panel.gd` now constructs the live Gear panel
  right stack with Charm/Necklace above Trinket/Ring.
- `project/scenes/training_room/training_room.gd` now mirrors the same
  Charm-over-Trinket order in the Practice Room paper doll.
- The live Gear panel keeps all five slot routing helpers intact:
  Weapon/Dagger, Helm/Hood, Armor/Doublet, Charm/Necklace, and Trinket/Ring
  still map by `GearItem.SlotType`, not by visual index.
- The live Gear panel refresh order now follows the locked layout for the
  right-side stack: Necklace before Ring.
- The Practice Room refresh order now follows the same right-side layout:
  Charm before Trinket.

Focused coverage added:

- `project/tests/build_panels_test.gd` now asserts the live Gear panel's right
  stack contains Charm first and Trinket second, and verifies the all-five-slot
  `_equipped_panel_for_slot()` routing for Helm, Armor, Charm, and Trinket.
- `project/tests/training_room_gear_editor_test.gd` now asserts the Practice
  Room right stack contains Charm first and Trinket second.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\build_panels_test.log --path project -s res://tests/build_panels_test.gd`
  passed with `P2:R7:T4 build panels test passed`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\training_room_gear_editor_test.log --path project -s res://tests/training_room_gear_editor_test.gd`
  passed with `Practice Room gear editor check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m2_five_slot_equipment_test.log --path project -s res://tests/p5m2_five_slot_equipment_test.gd`
  passed with `P5M2 five-slot equipment check: OK` when rerun outside the
  filesystem sandbox. The sandboxed run could not write the test save under
  Godot's `user://` path, so its save/load assertions were not treated as a
  code regression.

Known non-blockers observed during verification:

- Godot reported the accepted root-certificate warning during sandboxed
  headless UI runs.
- Godot reported the accepted ObjectDB/RID/resource cleanup warnings at process
  exit.

## P5M8-T4 Item Card Content Notes

Status: Complete.

Shared player-facing card order is now:

1. Item name.
2. `Rarity Slot / Rogue Family`.
3. `Weapon Damage: min-max` for weapons only.
4. `Stats:` for positive generated affixes.
5. `Drawbacks:` for negative generated affixes.
6. `Special:` for generated Specials.
7. `Legendary:` for named Legendary bespoke effects.
8. Surface-specific footer text such as shop price, click hint, inventory-full
   blocker, or reward choice hint.

Implemented behavior:

- `project/scripts/ui/card_style.gd` now exposes `gear_header_lines()` and uses
  a shared grouped tooltip path for inventory slots, equipped slots, shop
  offers, reward choices, and comparison boxes.
- Generated non-Legendary gear now shows the readable family line, for example
  `Master Weapon / Dagger` or `Cursed Charm / Necklace`.
- Generated and Legendary weapons now show their damage range via
  `WeaponDamageCatalog`.
- Generated positives, drawbacks, and Specials are grouped under stable
  player-facing section headers.
- `project/scripts/systems/legendary_catalog.gd` now aligns fixed Rogue
  Legendary card headers with generated gear while preserving named Legendary
  effect text.
- Item cards continue to hide generator/debug metadata such as `source_context`,
  `source_seed`, `deterministic_key`, and item ids.

Focused coverage added or updated:

- `project/tests/p5m8_item_card_content_test.gd` verifies generated Master,
  Cursed, Unique, and Legendary card content, weapon damage, grouped sections,
  Legendary text, and hidden metadata.
- `project/tests/p5m2_rogue_item_family_mapping_test.gd`,
  `project/tests/p5m2_minimal_ui_tool_surfaces_test.gd`,
  `project/tests/reward_shop_route_ui_test.gd`, and
  `project/tests/combat_screen_test.gd` now expect the shared name-first item
  card header.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_item_card_content_test.log --path project -s res://tests/p5m8_item_card_content_test.gd`
  passed with `P5M8 item card content check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m2_minimal_ui_tool_surfaces_test.log --path project -s res://tests/p5m2_minimal_ui_tool_surfaces_test.gd`
  passed with `P5M2 minimal UI/tool surfaces check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\combat_screen_test.log --path project -s res://tests/combat_screen_test.gd`
  passed with `P2 UI restructure end-to-end check: OK`.
- Earlier T4 verification also passed
  `project/tests/build_panels_test.gd`,
  `project/tests/reward_shop_route_ui_test.gd`,
  `project/tests/route_reward_choice_ui_test.gd`, and
  `project/tests/p5m2_rogue_item_family_mapping_test.gd`.

Known non-blockers observed during verification:

- Godot reported the accepted root-certificate warning during sandboxed
  headless UI runs.
- Godot reported the accepted ObjectDB/RID/resource cleanup warnings at process
  exit.

## P5M8-T5 Stat And Drawback Readability Notes

Status: Complete.

Implemented wording decisions:

- Catalog-backed percent and chance stats now render as signed percentages, for
  example `+18% Percent Physical Damage`, `+7% Crit Chance`, and
  `+10% Chance to Decay`.
- Catalog-backed flat and stack stats now render as signed whole numbers, for
  example `+4 Base Damage` and `+2 Bonus Stacks`.
- Generated drawbacks use the same value-kind rules with negative signs, for
  example `-12% Increased Attack Speed`, `-8 Base Elemental Damage`, and
  `-2 Bonus Stacks`.
- Binary Specials keep their authored sentence labels, for example
  `Stacks you apply are doubled`.
- Legacy multiplier modifiers now render as player-facing bonus or penalty
  percentages, for example `+10% Physical Damage` or `-8% Physical Damage`,
  instead of the ambiguous old `x10%` shorthand.
- The shared card path continues to hide raw stat ids such as `crit_chance` and
  `chance_to_decay`.

Implemented files:

- `project/scripts/ui/stat_modifier_formatter.gd` now uses
  `StatCatalog.value_kind_for()` for explicit catalog-backed affixes while
  preserving compatibility handling for older legacy modifiers.
- `project/tests/p5m8_stat_readability_test.gd` adds focused coverage for flat,
  percent, chance, stack, drawback, Rare chance, binary Special, legacy
  multiplier, and shared card text behavior.
- `project/tests/gear_generator_test.gd` and
  `project/tests/thief_subclass_test.gd` now expect `+N% Physical Damage`
  instead of the retired `xN% Physical Damage` tooltip text.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_stat_readability_test.log --path project -s res://tests/p5m8_stat_readability_test.gd`
  passed with `P5M8 stat readability check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_item_card_content_test.log --path project -s res://tests/p5m8_item_card_content_test.gd`
  passed with `P5M8 item card content check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\gear_generator_test.log --path project -s res://tests/gear_generator_test.gd`
  passed with `GearGenerator tier structure check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m3_existing_gear_wiring_test.log --path project -s res://tests/p5m3_existing_gear_wiring_test.gd`
  passed with `P5M3 existing gear wiring check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\reward_shop_route_ui_test.log --path project -s res://tests/reward_shop_route_ui_test.gd`
  passed with `Reward/shop/route UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m2_minimal_ui_tool_surfaces_test.log --path project -s res://tests/p5m2_minimal_ui_tool_surfaces_test.gd`
  passed with `P5M2 minimal UI/tool surfaces check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\combat_screen_test.log --path project -s res://tests/combat_screen_test.gd`
  passed with `P2 UI restructure end-to-end check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m3_stat_catalog_test.log --path project -s res://tests/p5m3_stat_catalog_test.gd`
  passed with `P5M3 stat catalog check: OK`.

Known non-blockers observed during verification:

- Godot reported the accepted root-certificate warning during sandboxed
  headless UI runs.
- Godot reported the accepted ObjectDB/RID/resource cleanup warnings at process
  exit.
- `project/tests/thief_subclass_test.gd` passed the updated formatter assertion
  but still fails later on existing Steal combat-damage expectations:
  `Expected Steal to deal 19 base damage before crit scaling` and
  `Expected current-gold crit damage scaling to affect Steal`. Those failures
  are outside the T5 formatter/card readability path.

## P5M8-T6 Rarity Presentation Notes

Status: Complete.

Final P5M8 rarity color/treatment rules:

- Crude remains gray: `UIColors.TIER_CRUDE = Color("8A8A7A")`.
- Basic remains green: `UIColors.TIER_BASIC = Color("72B953")`.
- Master remains blue: `UIColors.TIER_MASTER = Color("4E8AC5")`.
- Epic is now the documented white/light rarity:
  `UIColors.TIER_EPIC = Color("F5F1DD")`.
- Cursed remains purple: `UIColors.TIER_CURSED = Color("9D73D8")`.
- Chaos remains near-black: `UIColors.TIER_CHAOS = Color("2A292F")`.
- Unique remains yellow: `UIColors.TIER_UNIQUE = Color("D6C547")`.
- Legendary remains orange: `UIColors.TIER_LEGENDARY = Color("E3914C")`.
- Epic item boxes also receive a brighter border and stronger glow/shadow so
  Epic reads as distinct despite using a white/light fill.
- Disabled item boxes mute the same rarity fill and border so unaffordable shop
  offers and blocked reward choices still read as disabled.

Implemented files:

- `project/scripts/ui/ui_colors.gd` now uses the documented white/light Epic
  color.
- `project/scripts/ui/card_style.gd` now owns shared rarity fill, border, border
  width, and gear item stylebox helpers.
- `project/scenes/combat/gear_panel.gd` now uses the shared rarity style helper
  for equipped slots, inventory slots, and gear motion ghosts.
- `project/scenes/training_room/training_room.gd` now uses the same shared
  rarity style helper for Practice Room paper-doll slots.
- `project/tests/reward_shop_route_ui_test.gd` now expects the shared raised
  item-box fill and checks Epic's brighter shop-offer border.
- `project/tests/p5m8_rarity_presentation_test.gd` adds focused coverage for
  every rarity and Epic's distinct treatment.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_rarity_presentation_test.log --path project -s res://tests/p5m8_rarity_presentation_test.gd`
  passed with `P5M8 rarity presentation check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_item_card_content_test.log --path project -s res://tests/p5m8_item_card_content_test.gd`
  passed with `P5M8 item card content check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\reward_shop_route_ui_test.log --path project -s res://tests/reward_shop_route_ui_test.gd`
  passed with `Reward/shop/route UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\build_panels_test.log --path project -s res://tests/build_panels_test.gd`
  passed with `P2:R7:T4 build panels test passed`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\training_room_gear_editor_test.log --path project -s res://tests/training_room_gear_editor_test.gd`
  passed with `Practice Room gear editor check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m2_minimal_ui_tool_surfaces_test.log --path project -s res://tests/p5m2_minimal_ui_tool_surfaces_test.gd`
  passed with `P5M2 minimal UI/tool surfaces check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_stat_readability_test.log --path project -s res://tests/p5m8_stat_readability_test.gd`
  passed with `P5M8 stat readability check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\combat_screen_test.log --path project -s res://tests/combat_screen_test.gd`
  passed with `P2 UI restructure end-to-end check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\route_reward_choice_ui_test.log --path project -s res://tests/route_reward_choice_ui_test.gd`
  passed with `Route reward choice UI check: OK`.

Known non-blockers observed during verification:

- Godot reported the accepted root-certificate warning during sandboxed
  headless UI runs.
- Godot reported the accepted ObjectDB/RID/resource cleanup warnings at process
  exit.
- P5M9 has since supplied generated Rogue Hood and Doublet sprites; T6 only
  locked rarity color and treatment during the original P5M8 work.

## P5M8-T7 Gear Comparison Tooltip Notes

Status: Complete.

Final comparison behavior:

- Inventory, shop, and reward-choice gear buttons use `GearCompareButton` when
  they render real gear.
- Comparison tooltips render the candidate item beside the currently equipped
  item returned by `BuildState.equipped_item_for_slot(candidate.slot)`.
- Same-slot matching works for Weapon/Dagger, Helm/Hood, Armor/Doublet,
  Charm/Necklace, and Trinket/Ring.
- Different-slot equipped items are ignored by comparison tooltips, so a
  candidate Hood is compared to the equipped Hood, not the equipped Dagger,
  Ring, Necklace, or Doublet.
- Shared comparison tooltip content uses the final P5M8 item-card contract:
  item name, rarity/slot/family, weapon damage where relevant, grouped stats,
  drawbacks, Specials, Legendary effects, and no generator/debug metadata.

Verification:

- `project/tests/p5m8_ui_regression_test.gd` checks all five slots through
  live inventory, shop, and reward comparison tooltips, including same-slot
  matching and different-slot decoy rejection.
- `project/tests/reward_shop_route_ui_test.gd` preserves the existing shop and
  reward two-box comparison tooltip smoke coverage.
- `project/tests/build_panels_test.gd` preserves the existing live inventory
  comparison tooltip shape coverage.

## P5M8-T8 Equip, Unequip, Buy, Sell, And Reward Flow Notes

Status: Complete.

Verified flows:

- Direct `BuildState.equip()` routes Weapon/Dagger, Helm/Hood, Armor/Doublet,
  Charm/Necklace, and Trinket/Ring by `GearItem.SlotType`.
- Same-slot replacement moves the replaced item into inventory.
- `BuildState.unequip()` clears the correct slot and returns the item to
  inventory.
- `BuildState.equip_from_inventory()` equips all five slot types from inventory
  and removes the equipped item from inventory.
- Shop purchases spend the correct gold, remove the offer, and place the item
  into inventory for all five slots.
- Inventory and equipped sell flows add sell value gold, remove the sold item,
  and clear the correct equipped slot when selling equipped gear.
- Pending non-Legendary reward choices can be chosen for all five slots and
  land in inventory.
- Pending Legendary reward choices still auto-equip to Weapon and do not
  consume inventory space.
- Full inventory blocks non-Legendary reward choices without clearing the
  pending choice or granting gear.
- Full inventory blocks shop purchases without spending gold or removing the
  shop offer.
- Save/load roundtrips all five equipped slots, inventory gear, pending reward
  choices, shop-round state, shop offers, and gold after the flow changes.
- The full Adventure smoke test still covers reward claim, shop opening,
  reroll, buy, inventory-full blocked buy, sell-to-free-space, equip purchased
  gear, and Adventure continuation.

Implemented files:

- `project/tests/p5m8_flow_verification_test.gd` adds the focused T8 flow
  coverage.
- `project/tests/inventory_model_test.gd` had stale Gold Rewards expectations
  updated to current `StatSheet` semantics encountered during T8 verification:
  multiple Gold Rewards bonuses stack additively, and an extreme negative Gold
  Rewards modifier does not reduce the base reward below the unmodified amount.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_flow_verification_test.log --path project -s res://tests/p5m8_flow_verification_test.gd`
  passed with `P5M8 flow verification check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\inventory_model_test.log --path project -s res://tests/inventory_model_test.gd`
  passed with `Inventory model check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\save_load_test.log --path project -s res://tests/save_load_test.gd`
  passed with `Save/load round trip check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\generated_contract_save_load_test.log --path project -s res://tests/generated_contract_save_load_test.gd`
  passed with `Generated contract save/load check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\build_panels_test.log --path project -s res://tests/build_panels_test.gd`
  passed with `P2:R7:T4 build panels test passed`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\reward_shop_route_ui_test.log --path project -s res://tests/reward_shop_route_ui_test.gd`
  passed with `Reward/shop/route UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\route_reward_choice_ui_test.log --path project -s res://tests/route_reward_choice_ui_test.gd`
  passed with `Route reward choice UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m2_five_slot_equipment_test.log --path project -s res://tests/p5m2_five_slot_equipment_test.gd`
  passed with `P5M2 five-slot equipment check: OK` when rerun outside the
  filesystem sandbox.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\combat_screen_test.log --path project -s res://tests/combat_screen_test.gd`
  passed with `P2 UI restructure end-to-end check: OK`.

Known non-blockers observed during verification:

- Godot reported the accepted root-certificate warning during sandboxed
  headless UI runs.
- Godot reported the accepted ObjectDB/RID/resource cleanup warnings at process
  exit.
- `project/tests/p5m2_five_slot_equipment_test.gd` still writes its temporary
  save under Godot `user://`; the sandboxed run could not write that save, so
  the test was rerun outside the filesystem sandbox and passed.
- `project/tests/save_load_test.gd` intentionally exercises corrupt JSON and
  logs Godot's parse error before confirming load failure.

## P5M8-T9 Focused UI Regression Coverage Notes

Status: Complete.

Implemented files:

- `project/tests/p5m8_ui_regression_test.gd` adds the final focused P5M8 UI
  regression net. It instantiates the live combat screen and checks inventory,
  shop, and reward-choice `GearCompareButton` tooltips for Weapon/Dagger,
  Helm/Hood, Armor/Doublet, Charm/Necklace, and Trinket/Ring. Each candidate is
  compared against the currently equipped same-slot item and must ignore an
  equipped different-slot decoy.
- The same test also verifies that comparison tooltip text hides generated item
  metadata (`id`, `deterministic_key`, `source_context`, and `source_seed`) for
  both the candidate item and the equipped comparison item.
- The same test verifies that Epic's live style is applied on equipped,
  inventory, shop, and reward-choice surfaces with the documented light fill,
  stronger border, and glow/shadow treatment.

Final P5M8 regression suite:

- `project/tests/p5m8_item_card_content_test.gd`: T4 item-card content,
  weapon damage, family headers, Legendary effect presentation, and hidden
  metadata.
- `project/tests/p5m8_stat_readability_test.gd`: T5 positive stat, drawback,
  chance, stack, binary Special, hidden raw-id, and legacy multiplier wording.
- `project/tests/p5m8_rarity_presentation_test.gd`: T6 rarity colors,
  disabled-state muting, shared item-box styles, and Epic distinctness.
- `project/tests/p5m8_flow_verification_test.gd`: T8 all-five-slot equip,
  replacement, unequip, inventory equip, shop buy/sell, reward choice,
  full-inventory blocking, and save/load.
- `project/tests/p5m8_ui_regression_test.gd`: T9 all-five-slot comparison
  routing, hidden metadata in comparison boxes, and live Epic styling across
  inventory, shop, reward, and equipped surfaces.
- `project/tests/build_panels_test.gd`: Gear panel presence, Charm-over-Trinket
  layout, equipped/inventory visual distinction, inventory comparison shape,
  equip, action menu, and unequip smoke coverage.
- `project/tests/reward_shop_route_ui_test.gd`: shop offers, reward rows,
  price/affordability presentation, two-box comparison tooltips, Legendary
  reward tooltips, and route reward text.
- `project/tests/route_reward_choice_ui_test.gd`: generated reward choice
  count, reward-choice tooltip basics, full-inventory blocking, skip flow, and
  Legendary reward behavior.
- `project/tests/combat_screen_test.gd`: broad Adventure UI smoke coverage
  including reward claim, shop opening, reroll, buy, inventory-full blocked buy,
  sell-to-free-space, equip purchased gear, and Adventure continuation.

Verification:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_ui_regression_test.log --path project -s res://tests/p5m8_ui_regression_test.gd`
  passed with `P5M8 UI regression check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_item_card_content_test.t9.log --path project -s res://tests/p5m8_item_card_content_test.gd`
  passed with `P5M8 item card content check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_stat_readability_test.t9.log --path project -s res://tests/p5m8_stat_readability_test.gd`
  passed with `P5M8 stat readability check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_rarity_presentation_test.t9.log --path project -s res://tests/p5m8_rarity_presentation_test.gd`
  passed with `P5M8 rarity presentation check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\p5m8_flow_verification_test.t9.log --path project -s res://tests/p5m8_flow_verification_test.gd`
  passed with `P5M8 flow verification check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\build_panels_test.t9.log --path project -s res://tests/build_panels_test.gd`
  passed with `P2:R7:T4 build panels test passed`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\reward_shop_route_ui_test.t9.log --path project -s res://tests/reward_shop_route_ui_test.gd`
  passed with `Reward/shop/route UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\route_reward_choice_ui_test.t9.log --path project -s res://tests/route_reward_choice_ui_test.gd`
  passed with `Route reward choice UI check: OK`.
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --log-file F:\Data\Claude Projects\Project-Enigma\.godot_user\logs\combat_screen_test.t9.log --path project -s res://tests/combat_screen_test.gd`
  passed with `P2 UI restructure end-to-end check: OK`.

Known non-blockers observed during verification:

- Godot reported the accepted root-certificate warning during sandboxed
  headless UI runs.
- Godot reported the accepted ObjectDB/RID/resource cleanup warnings at process
  exit.

## P5M8-T10 Docs And Closeout Notes

Status: Complete.

Closeout summary:

- P5M8 is complete. The live player UI now exposes Weapon/Dagger, Helm/Hood,
  Armor/Doublet, Charm/Necklace, and Trinket/Ring as visible, usable,
  comparable equipment.
- The right-side equipment column uses the locked P5M8 order:
  Charm/Necklace above Trinket/Ring.
- Shared item-card and tooltip presentation now shows item name, rarity, slot,
  Rogue item family, weapon damage for weapons, grouped positive stats,
  drawbacks, Specials, and Legendary effects without exposing raw stat IDs or
  generator/debug metadata.
- Rarity styling is shared across live item surfaces. Epic uses the documented
  white/light rarity color plus a stronger border and glow/shadow treatment so
  it remains distinct from Basic, empty, and disabled states.
- Inventory, reward choice, shop buy, sell, equip, unequip, replacement,
  full-inventory blocking, and save/load flows are covered by focused
  regression tests.
- Final generated Rogue sprites are now supplied by P5M9. Generic tier
  placeholder icons remain only as fallbacks for unmapped future gear.

Docs updated for closeout:

- `docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`
- `docs/Project_Onboarding_Context.md`
- `docs/P5_Gear_Redesign_Overview.md`
- `docs/New_Gear_Overview.md`
- `docs/Project_Overview.md`

Next milestone:

- P5M9 Art And Sprite Pass has since completed. P5M10 Legendary Revisit And
  Fixed Legendary Stats is the next Phase 5 milestone.

## Status Definitions

- `Ready`: The task can be worked now.
- `Blocked`: The task needs a prior task output, implementation decision, or
  design clarification before it can be completed.
- `In Progress`: The task is actively being audited, edited, implemented, or
  reviewed.
- `Complete`: The task output has been added, verified, and recorded.

## Open Decisions

No P5M8-blocking decisions remain. Epic's P5M8 presentation uses shared UI
styling, and P5M9 has since supplied final generated Rogue item sprites.

## Completion Notes

P5M8 is complete. Implementation started with the UI audit, locked the
Charm-over-Trinket equipment layout, standardized readable item cards and stat
language, applied shared rarity presentation, verified live item flows, added
focused UI regression coverage, and updated the Phase 5 docs for the P5M9 art
handoff.

Post-P5M9 UI updates: equipment slots now use recolored slot-type background
sprites that better match the UI, Practice Room item dropdowns use one decimal
place, Chaos stat dropdowns expose every slot-valid stat in every row, and the
combat and Practice Room talent windows use scroll-safe responsive layouts so
deep talent trees no longer push controls off the bottom of the screen.
