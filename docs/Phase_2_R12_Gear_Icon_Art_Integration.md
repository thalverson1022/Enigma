# P2:R12 - Gear Icon Art Integration

## Purpose

Track the work for **P2:R12 - Gear Icon Art Integration**.

Every gear box in the Adventure dashboard (shop offers, reward-choice cards,
inventory slots, equipped Equipment-doll slots) rendered as a plain
tier-colored square -- correct information, no visual identity. The user
supplied a folder of hand-authored art
(`project/assets/Items/Rogue/`) and asked for it to be integrated so gear
reads at a glance instead of only through hover tooltips and a caption label,
while keeping the existing tier-colored backgrounds (which already
communicated rarity correctly). `docs/Phase_2_R7_Game_Like_UI_Pass.md`
explicitly deferred "icon-pack integration" as out of R7's scope; this
milestone is that deferred work, done once real art existed to integrate
rather than a generic icon pack.

## Exit Criteria

P2:R12 is complete when:

- Every generic Basic/Master/Cursed gear box (per slot: Weapon/Trinket/Charm)
  shows a distinct icon over its existing tier-colored background.
- Every named item (the 5 Rogue Legendaries, Lucky Coin) shows its own unique
  icon instead of falling back to the generic slot/tier art.
- This applies uniformly across all four places gear renders: shop offers,
  reward-choice cards, inventory slots, and equipped Equipment-doll slots.
- The icon art doesn't block clicks or overlap the box's existing
  interaction/tooltip behavior.
- Once icons exist, redundant caption text (which duplicated what the icon +
  background already conveyed) is removed rather than left stacked underneath.
- The full regression suite passes, and the result is confirmed via a live
  playthrough, not just headless assertions.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R12:T1 | Asset Audit | Confirm the supplied art is usable as-is | Complete |
| P2:R12:T2 | Icon Mapping Class | `GearIcons`, mapping any `GearItem` to its texture | Complete |
| P2:R12:T3 | Shared Box-Icon Helper | `CardStyle.build_gear_box_content()` | Complete |
| P2:R12:T4 | Wire Into All Four Render Locations | Shop, reward-choice, inventory, equipped slots | Complete |
| P2:R12:T5 | Live Verification | Automated tests + a real hands-on playthrough | Complete |
| P2:R12:T6 | Remove Redundant Caption Text | Icon + tier-colored background alone convey slot/tier | Complete |

## P2:R12:T1 - Asset Audit

`project/assets/Items/Rogue/` contains 15 files: 9 generic tier x slot icons
(`Basic_Weapon`/`Master_Weapon`/`Cursed_Weapon`/`Basic_Trinket`/
`Master_Trinket`/`Cursed_Trinket`/`Basic_Charm`/`Master_Charm`/
`Cursed_Charm` -- note `Basic Weapon.png` uses a space, not an underscore,
unlike every other file), the 5 named Legendaries
(`Bandit_Blade`/`Bejeweled_Push_Dagger`/`Mithril_Karambit`/`Umbral_Stiletto`/
`Wyvern_Kriss`), and `Lucky_Coin`. All are 32x32 `Format32bppArgb` PNGs,
confirmed fully transparent at the corners via direct pixel inspection
(`System.Drawing.Bitmap`) -- meaning they're meant to sit on top of the
existing tier-colored panel/button background, not replace it, matching the
plan the user approved. Cleanly matches the full current Rogue gear roster
with no gaps.

## P2:R12:T2 - Icon Mapping Class

New `project/scripts/ui/gear_icons.gd` (`class_name GearIcons extends
RefCounted`): preloads all 15 textures as consts, a `NAMED_ICONS` dictionary
keyed by `GearItem.id` for the 6 unique-art items (5 Legendaries + Lucky
Coin), a `GENERIC_ICONS` dictionary keyed by `[SlotType][Tier]` for the 9
generic combinations, and a single `icon_for(gear: GearItem) -> Texture2D`
entry point: named items win first, everything else falls back to its
slot/tier's generic icon, `null` for an empty slot.

## P2:R12:T3 - Shared Box-Icon Helper

New `CardStyle.build_gear_box_content(button, gear)`: adds a `TextureRect`
child named `"Icon"` (nearest-neighbor filtering to keep the 32x32 pixel art
crisp when scaled up to an 88-112px box instead of blurring like the
project's photographic backgrounds; `STRETCH_KEEP_ASPECT_CENTERED`;
`mouse_filter = MOUSE_FILTER_IGNORE` so the art never blocks clicks or
tooltips) showing `GearIcons.icon_for(gear)`. One shared helper avoids
duplicating this layout across the three call sites in `T4`. (Originally
also built a caption `Label` alongside the icon -- removed in `T6` once it
proved redundant; see that section for why the icon alone was judged
sufficient.)

## P2:R12:T4 - Wire Into All Four Render Locations

- `gear_panel.gd`'s equipped Equipment-doll slots (`_make_slot()`/
  `_update_slot()`) and inventory slots (`_make_inventory_slot()`).
- `combat_screen.gd`'s shop offer boxes (`_make_shop_offer_row()`) and
  reward-choice cards (`_make_reward_choice_button()`).

All four call `CardStyle.build_gear_box_content()` (or, for equipped slots,
the equivalent inline `Icon` child `_make_slot()` already built) so the icon
layer is identical everywhere gear renders, and the existing tier-colored
`StyleBoxFlat` backgrounds (`UIColors.TIER_BASIC`/`MASTER`/`CURSED`/
`LEGENDARY`) are untouched -- they already correctly communicated rarity per
the user's original ask, so only the icon layer needed adding on top.

## P2:R12:T5 - Live Verification

`project/tests/build_panels_test.gd` and
`project/tests/reward_shop_route_ui_test.gd` assert the correct texture
(named or generic) at each of the four render locations, including that an
empty slot's icon stays unset. Beyond headless assertions, a scripted
PowerShell-driven playthrough (native Windows GUI automation against a real
running debug build, not the exported build) drove a real Adventure run
through two Tavern fights to a shop with real gold and a real Lucky Coin
reward, confirming visually via screenshots that: shop offers show distinct
sword/ring/amulet icons on their tier-colored (green Basic) backgrounds,
buying a weapon shows its icon in the inventory slot, and equipping it shows
the same icon (plus its stat bonus taking effect) on the Equipment-doll
weapon slot.

## P2:R12:T6 - Remove Redundant Caption Text

Once the icon art was live and visually confirmed, the two-line slot/tier
caption (`"Weapon\nBasic"`, etc.) that used to sit below the icon in every
box was judged redundant -- the icon's art already distinguishes slot type
(sword/ring/amulet/named silhouette) and the box's existing background color
already distinguishes tier, so the caption repeated information rather than
adding any. Removed `CardStyle.gear_box_label()` and
`style_gear_box_caption()` entirely (both now dead code with the caption
gone), simplified `build_gear_box_content()` to add only the icon, and
removed the now-dead `style_gear_box_caption()` call left over in
`combat_screen.gd`'s `_style_shop_item_box()`. Full item identification (name,
tier, affixes, price) remains available via each box's existing hover
tooltip, which was never removed.

## Implementation Notes

2026-07-24:

- Read every file in `project/assets/Items/Rogue/` and confirmed via direct
  pixel inspection (not just visual guess) that all 15 are genuinely
  transparent-background 32x32 art before proposing the integration plan.
  Reported findings and the four-step plan (mapping class, shared helper,
  wiring, verification) to the user, who approved it explicitly.
- Built `GearIcons` and `CardStyle.build_gear_box_content()`, then wired all
  four render locations. A Godot editor filesystem rescan
  (`--headless --editor --quit`) was required before headless tests could
  resolve the new `GearIcons` `class_name` and the newly-added PNG assets --
  the same documented `.godot/global_script_class_cache.cfg`/`.import`-file
  gotcha noted elsewhere in this project's docs, this time hitting both a
  new script class and new binary assets at once.
- Real design problem solved along the way: `Button.text` is always centered
  across the whole button regardless of other children, so it couldn't
  coexist with a separately-added icon without visual overlap. Fixed by
  moving the caption out of `Button.text` into a child `Label` inside a
  child `VBoxContainer` -- later removed entirely in `T6` once the caption
  itself proved unnecessary.
- Live-verified via a real running debug build (native Windows click
  automation), not just headless assertions -- confirmed shop offers,
  purchased inventory items, and an equipped weapon slot all show correct
  art on their existing tier-colored backgrounds.
- Full 38-file regression suite passed clean throughout, including after
  `T6`'s caption removal (which required updating two tests'
  caption-specific assertions to check only the icon and drop the
  now-nonexistent `CaptionLabel`/`GearBoxContent` node lookups).
