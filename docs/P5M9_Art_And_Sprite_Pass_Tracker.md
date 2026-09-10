# P5M9: Art And Sprite Pass Tracker

## Status

Complete.

P5M9 supplies final item identity art for the expanded Phase 5 gear system.
P5M2-P5M8 made Weapon, Helm, Armor, Trinket, and Charm function in data,
generation, rewards, shops, inventory, equipment UI, comparison tooltips, and
Practice Room surfaces. This milestone replaces generic item placeholders with
the selected Rogue slot-and-rarity sprite set and verifies that the art remains
readable in the live UI.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone documents:

- `docs/P5_Gear_Redesign_Overview.md`
- `docs/P5M8_Inventory_Equipment_UI_And_Item_Presentation_Tracker.md`

## Milestone Goal

Integrate the final Rogue generated-gear sprite catalog so Dagger, Hood,
Doublet, Ring, and Necklace items have clear slot-and-rarity visual identity
across inventory, equipment, reward choices, shop offers, comparison tooltips,
and Practice Room.

P5M9 is not retained Legendary stat tuning, new Legendary reward/shop behavior,
new gear mechanics, broad balance tuning, Practice Room expansion, or Balance
Lab validation. Those remain assigned to P5M10-P5M11.

## Final Sprite Selection

Selected source assets are from the purchased RPG icon pack.

| Slot | Rogue Family | Rarity | Source |
| --- | --- | --- | --- |
| Weapon | Dagger | Crude | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Weapons\Daggers\12.png` |
| Weapon | Dagger | Basic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Weapons\Daggers\3.png` |
| Weapon | Dagger | Master | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Weapons\Daggers\2.png` |
| Weapon | Dagger | Epic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Weapons\Daggers\14.png` |
| Weapon | Dagger | Cursed | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Weapons\Daggers\22.png` |
| Weapon | Dagger | Chaos | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Weapons\Daggers\25.png` |
| Weapon | Dagger | Unique | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Weapons\Daggers\16.png` |
| Helm | Hood | Basic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Helmets\50.png` |
| Helm | Hood | Master | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Helmets\57.png` |
| Helm | Hood | Epic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Helmets\58.png` |
| Helm | Hood | Cursed | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Helmets\54.png` |
| Helm | Hood | Chaos | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Helmets\52.png` |
| Helm | Hood | Unique | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Helmets\63.png` |
| Armor | Doublet | Basic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Chests\13.png` |
| Armor | Doublet | Master | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Chests\28.png` |
| Armor | Doublet | Epic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Chests\38.png` |
| Armor | Doublet | Cursed | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Chests\54.png` |
| Armor | Doublet | Chaos | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Chests\40.png` |
| Armor | Doublet | Unique | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Chests\6.png` |
| Trinket | Ring | Basic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Rings\43.png` |
| Trinket | Ring | Master | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Rings\46.png` |
| Trinket | Ring | Epic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Rings\39.png` |
| Trinket | Ring | Cursed | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Rings\37.png` |
| Trinket | Ring | Chaos | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Rings\18.png` |
| Trinket | Ring | Unique | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Rings\27.png` |
| Charm | Necklace | Basic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Trinkets.Amulets\47.png` |
| Charm | Necklace | Master | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Trinkets.Amulets\46.png` |
| Charm | Necklace | Epic | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Trinkets.Amulets\54.png` |
| Charm | Necklace | Cursed | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Trinkets.Amulets\51.png` |
| Charm | Necklace | Chaos | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Trinkets.Amulets\62.png` |
| Charm | Necklace | Unique | `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Trinkets.Amulets\36.png` |

Selection note:

- Helm/Hood Master was corrected from the provided `57ng` text to `57.png`
  after source-file verification.

## Exit Criteria

- Final Dagger, Hood, Doublet, Ring, and Necklace generated-gear sprites are
  imported into a project-owned asset path.
- `GearIcons.icon_for()` resolves the intended slot-and-rarity sprite for all
  supported Rogue generated gear.
- Crude remains starter Dagger-only.
- Lucky Coin and retained Rogue Legendary icon overrides remain intact.
- Generic fallback icons still resolve for unmapped or unexpected future gear.
- Inventory, equipment, reward choice, shop offer, comparison tooltip, and
  Practice Room surfaces show readable item art at actual UI sizes.
- Rarity presentation is reviewed against real sprites, especially Epic,
  Cursed, Chaos, Unique, and disabled shop/reward states.
- Focused regression coverage records expected icon paths and fallback behavior.
- Phase 5 docs are updated with P5M9 completion notes and the P5M10 handoff.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M9-T1: Document Final Sprite Selection | Complete | Capture the exact source file chosen for each slot/rarity before implementation. | Tracker lists every Weapon, Helm, Armor, Trinket, and Charm sprite path; typo/ambiguity like Helm `57ng` is resolved. |
| P5M9-T2: Import Rogue Gear Sprites | Complete | Copy selected purchased sprites into the Godot project asset tree. | Sprites live under a project-owned path, use consistent names, and Godot import metadata is generated or recognized. |
| P5M9-T3: Update Generated Gear Icon Mapping | Complete | Make generated Rogue gear use slot-and-rarity-specific sprites. | `GearIcons.icon_for()` resolves Dagger, Hood, Doublet, Ring, and Necklace icons by rarity instead of using generic placeholders. |
| P5M9-T4: Preserve Special Icon Overrides | Complete | Avoid breaking authored special cases. | Lucky Coin and retained Rogue Legendary icons still resolve to their authored icons; Crude remains starter Dagger-only. |
| P5M9-T5: Review Existing Icon Consistency | Complete | Check older Dagger/Ring/Necklace/Lucky Coin/Legendary art against the full generated-gear set. | Existing item sprites either remain accepted or any needed cleanup is recorded and completed. |
| P5M9-T6: Verify Live UI Sprite Readability | Complete | Confirm sprites work at actual UI sizes. | Inventory, equipped slots, shop offers, reward choices, comparison tooltips, and Practice Room show correct readable art for all five slots. |
| P5M9-T7: Add Icon Regression Coverage | Complete | Prevent future accidental fallback or mapping drift. | Focused test asserts expected icon paths for supported slot/rarity combinations and confirms fallback still works for unknown cases. |
| P5M9-T8: Update Docs And Closeout | Complete | Record what changed and hand off cleanly to M10. | This tracker, onboarding, Phase 5 overview, and relevant gear docs mark M9 complete, record post-P5M9 playtest changes, and note M10 Legendary stats are next. |

## P5M9-T1 Sprite Selection Notes

Status: Complete.

Verified all selected purchased RPG icon pack source paths exist. Helm/Hood
Master was confirmed as `F:\Data\Junk\DPS Game\Purchased Sprites\Rpg Icon Pack\Armor\Helmets\57.png`;
the provided `57ng` text does not exist and has been recorded as a typo.

## P5M9-T2 Import Notes

Status: Complete.

Imported sprites live under
`project/assets/Items/Rogue/Generated/` rather than being loaded from the
purchased-asset source directory. Filenames use stable lowercase
`rogue_<family>_<rarity>.png` names.

Verified project-owned import catalog:

- Dagger: `rogue_dagger_crude.png`, `rogue_dagger_basic.png`,
  `rogue_dagger_master.png`, `rogue_dagger_epic.png`,
  `rogue_dagger_cursed.png`, `rogue_dagger_chaos.png`,
  `rogue_dagger_unique.png`.
- Hood: `rogue_hood_basic.png`, `rogue_hood_master.png`,
  `rogue_hood_epic.png`, `rogue_hood_cursed.png`, `rogue_hood_chaos.png`,
  `rogue_hood_unique.png`.
- Doublet: `rogue_doublet_basic.png`, `rogue_doublet_master.png`,
  `rogue_doublet_epic.png`, `rogue_doublet_cursed.png`,
  `rogue_doublet_chaos.png`, `rogue_doublet_unique.png`.
- Ring: `rogue_ring_basic.png`, `rogue_ring_master.png`,
  `rogue_ring_epic.png`, `rogue_ring_cursed.png`, `rogue_ring_chaos.png`,
  `rogue_ring_unique.png`.
- Necklace: `rogue_necklace_basic.png`, `rogue_necklace_master.png`,
  `rogue_necklace_epic.png`, `rogue_necklace_cursed.png`,
  `rogue_necklace_chaos.png`, `rogue_necklace_unique.png`.

Godot import metadata has been generated for all 31 generated Rogue sprites via
`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project --import`.
The command emitted the accepted ObjectDB/RID/resource cleanup warnings and the
existing CSV locale warning at process exit.

## P5M9-T3 Icon Mapping Notes

Status: Complete.

Generated Rogue gear should prefer explicit slot-and-rarity mappings for:

- Weapon/Dagger: Crude, Basic, Master, Epic, Cursed, Chaos, Unique.
- Helm/Hood: Basic, Master, Epic, Cursed, Chaos, Unique.
- Armor/Doublet: Basic, Master, Epic, Cursed, Chaos, Unique.
- Trinket/Ring: Basic, Master, Epic, Cursed, Chaos, Unique.
- Charm/Necklace: Basic, Master, Epic, Cursed, Chaos, Unique.

Legendary is excluded from generated slot-and-rarity art because retained Rogue
Legendaries remain named authored items.

`project/scripts/ui/gear_icons.gd` now preloads the P5M9 generated sprite
catalog from `res://assets/Items/Rogue/Generated/` and resolves Rogue
slot-and-rarity pairs through `ROGUE_GENERATED_ICONS`. `NAMED_ICONS` remains the
first check so Lucky Coin and retained Rogue Legendaries keep authored icons.
Unexpected future/non-Rogue gear still falls back through `FALLBACK_ICONS_BY_TIER`.

## P5M9-T4 Special Override Notes

Status: Complete.

Lucky Coin remains fixed authored gear and should keep its
authored icon. Retained Rogue Legendaries remain named Weapon-slot dagger items
with authored icon overrides and should not be replaced by generic generated
Dagger rarity art.

`GearIcons.icon_for()` keeps `NAMED_ICONS` as the first resolution path, so
`gear.lucky_coin` still resolves to `Lucky_Coin.png` and retained Rogue
Legendary IDs still resolve to their authored Dagger icons before generated
slot-and-rarity mapping can run. `ROGUE_GENERATED_ICONS` has no Legendary
entries, and Crude appears only under Weapon/Dagger.

Added `project/tests/p5m9_special_icon_overrides_test.gd` to cover Lucky Coin
vs. generated Basic Necklace art, retained Rogue Legendary authored icons,
generated Legendary fallback behavior, and the Crude-Dagger-only generated
mapping boundary. The test passes via
`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m9_special_icon_overrides_test.gd`.

## P5M9-T5 Icon Consistency Notes

Status: Complete.

Review the older Dagger, Ring, Necklace, Lucky Coin, and retained Rogue
Legendary icons alongside the new generated-gear set. The goal is visual
coherence at UI scale, not a new item-art system.

Reviewed the retained authored override icons against the generated Dagger,
Ring, and Necklace families in
`project/reports/p5m9_icon_review/rogue_icon_consistency_contact_sheet.png`.
The retained Legendary Dagger icons and Lucky Coin remain visually coherent at
small item-card scale: all reviewed files are 32x32 transparent item icons with
readable silhouettes and no scale mismatch that requires replacement.

The older generic `Basic_*`, `Master_*`, and `Cursed_*` Rogue icon files remain
on disk as compatibility assets, but generated gear no longer routes to those
paths directly. `GearIcons` keeps the legacy constants as aliases to the new
generated Dagger/Ring/Necklace sprites so existing tests and call sites retain
their semantic checks without sending live generated gear back to old generic
art.

Decision: no icon replacements or cleanup are needed for P5M9-T5. Lucky Coin
and retained Rogue Legendary authored overrides remain accepted.

## P5M9-T6 Live UI Verification Notes

Status: Complete.

Verification should inspect real player-facing surfaces:

- Live Gear panel equipped slots.
- Live inventory item grid.
- Generated reward choice buttons and comparison tooltips.
- Between-contract shop offers and comparison tooltips.
- Practice Room gear paper doll.

Verified live UI sprite readability with
`project/tests/p5m9_ui_sprite_readability_test.gd`, run through
`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --path project -s res://tests/p5m9_ui_sprite_readability_test.gd`
so screenshots could be captured with the Windows/Vulkan render driver.
Screenshots and PASS notes are recorded under
`project/reports/p5m9_ui_readability/`.

Reviewed screenshots:

- `01_combat_gear_panel_inventory.png`: live Gear panel equipped slots and
  inventory grid show readable Dagger, Hood, Doublet, Ring, and Necklace art.
- `02_shop_offers_disabled_and_affordable.png`: shop offers preserve readable
  icons across affordable and disabled states, with price badges clear of the
  main silhouettes.
- `03_reward_choices_all_slots.png`: reward choices show all five generated
  gear slots in a readable row.
- `04_comparison_tooltip_pair.png`: comparison tooltip boxes now include item
  icons for both candidate and equipped gear.
- `05_practice_room_paper_doll.png`: Practice Room paper doll shows readable
  generated icons in all five equipment slots.

Fix applied during T6: `CardStyle.build_gear_compare_tooltip()` now accepts the
candidate item and renders icons in both comparison tooltip boxes. Inventory,
shop, and reward call sites pass the candidate gear. Existing tooltip
regression tests were updated to read labels recursively instead of assuming a
text-only child layout.

Focused verification passed:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --path project -s res://tests/p5m9_ui_sprite_readability_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m8_ui_regression_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/build_panels_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/reward_shop_route_ui_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/training_room_gear_editor_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m9_special_icon_overrides_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m2_minimal_ui_tool_surfaces_test.gd`

Known accepted non-blockers: Godot emitted the existing
ObjectDB/RID/resource-cleanup warnings at process exit.

## P5M9-T7 Regression Coverage Notes

Status: Complete.

Focused coverage should assert that each supported generated Rogue
slot-and-rarity pair resolves to the expected project-owned icon path, while
Lucky Coin, retained Rogue Legendaries, Crude starter Dagger behavior, and
fallback behavior remain protected.

Added `project/tests/p5m9_icon_regression_test.gd` as the broad P5M9 generated
icon routing guardrail. The test covers all 31 supported generated Rogue
slot-and-rarity icon paths, verifies all 31 project-owned PNG files and all 31
Godot `.png.import` metadata files exist, confirms Crude remains Dagger-only,
keeps Lucky Coin and the retained Rogue Legendary authored overrides ahead of
generated routing, and checks fallback art for non-Rogue/unmapped Basic,
Master, Epic, Cursed, Chaos, Unique, and generated Legendary-like gear.

Focused verification passed:

- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m9_icon_regression_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m9_special_icon_overrides_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --path project -s res://tests/p5m9_ui_sprite_readability_test.gd`
- `F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe --headless --path project -s res://tests/p5m8_ui_regression_test.gd`

Known accepted non-blockers: Godot emitted the existing
ObjectDB/RID/resource-cleanup warnings at process exit.

## P5M9-T8 Docs And Closeout Notes

Status: Complete.

P5M9 is complete. This tracker, `docs/Project_Onboarding_Context.md`,
`docs/P5_Gear_Redesign_Overview.md`, `docs/New_Gear_Overview.md`, and
`docs/Project_Overview.md` record generated Rogue sprite completion, the P5M10
handoff, and the post-P5M9 playtest mechanics/UI changes that now define the
working baseline.

## Status Definitions

- `Ready`: The task can be worked now.
- `Blocked`: The task needs a prior task output, implementation decision, or
  design clarification before it can be completed.
- `In Progress`: The task is actively being audited, edited, implemented, or
  reviewed.
- `Complete`: The task output has been added, verified, and recorded.

## Open Decisions

- None for P5M9-T1. Helm/Hood Master is confirmed as `57.png`.

## Completion Notes

P5M9-T1 is complete. The selected sprite catalog is verified, the Helm/Hood
Master typo is corrected to `57.png`, and implementation can begin from a clear
asset-integration contract in P5M9-T2.

P5M9-T2 is complete. The generated Rogue sprite catalog has been copied into
`project/assets/Items/Rogue/Generated/` with 31 project-owned PNG files: 7
Dagger sprites and 6 sprites each for Hood, Doublet, Ring, and Necklace.

P5M9-T3 is complete. `GearIcons.icon_for()` now resolves generated Rogue
Dagger, Hood, Doublet, Ring, and Necklace art by slot and rarity, keeps named
Lucky Coin and retained Rogue Legendary overrides ahead of generated mappings,
excludes generated Legendary mappings, and preserves tier fallback icons for
unexpected future gear.

P5M9-T4 is complete. Special icon override behavior is protected by code order
and focused regression coverage: Lucky Coin and retained Rogue Legendaries keep
authored icons, generated Legendary-like gear falls back to generic Legendary
art, and Crude generated art remains Weapon/Dagger-only.

P5M9-T5 is complete. The retained authored Legendary Dagger and Lucky Coin art
was visually reviewed beside the generated Dagger/Ring/Necklace set and remains
accepted. No replacement or cleanup is needed; old generic Rogue tier icons are
no longer directly referenced by live generated icon routing.

P5M9-T6 is complete. Live UI screenshot verification confirms readable generated
gear sprites across equipment, inventory, shop offers, reward choices,
comparison tooltips, and Practice Room. Comparison tooltips now include item
icons, and focused UI regressions pass with the updated tooltip layout.

P5M9-T7 is complete. `p5m9_icon_regression_test.gd` now protects the full
generated Rogue icon catalog, asset import metadata, special authored overrides,
Crude Dagger-only behavior, and fallback routing for unmapped future gear.

P5M9-T8 is complete. P5M9 is closed out in the tracker and the core onboarding,
overview, and gear specification docs now point to P5M10 as the next milestone.
The docs also record the current playtest baseline: Crude Dagger start and
unarmed fallback, Lucky Coin as Trinket/Ring, Chaos duplicate-stat rules, Bonus
Stacks, Chance for Crits to Apply Poison, universal Shred and Decay, Rogue
talent tuning, Practice Room dropdown/talent-window fixes, Adventure retry RNG
rerolling, and combat UI tooltip updates.
