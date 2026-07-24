class_name UIColors
extends RefCounted
## Single source of truth for the "Road to Peak Deeps" UI palette, adopted
## 2026-07-17 for P2:R7:T2 (see docs/Phase_2_R7_Style_Implementation_Notes.md
## and docs/The_Road_to_Peak_Deeps_Master_Palette.md, whose "UI" table these
## ten constants mirror exactly). Both project/assets/ui_theme.tres and any
## dynamic GDScript color logic (CardStyle, combat_screen.gd, and the
## dashboard panel scripts) read from these constants instead of hardcoding
## hex/RGB literals, so the palette can be retuned in exactly one place.

# -- Core palette (master palette doc's "UI" table) --
const BACKGROUND := Color("221811")
const PANEL := Color("5B3A25")
const PANEL_HIGHLIGHT := Color("B46D3C")
const PANEL_BORDER := Color("E1A867")
const TEXT_NORMAL := Color("F4E2C4")
const TEXT_DISABLED := Color("A28D73")
const TEXT_WARNING := Color("D35C45")
const TEXT_MAGIC := Color("9D73D8")
const TEXT_POISON := Color("72B953")
const TEXT_GOLD := Color("E3C35C")

# -- Semantic extensions added during the R7:T2 cleanup pass, so every ad
# hoc Color() literal that used to live in scene scripts has a named home
# here instead. Not part of the source palette table; derived to stay
# inside the same warm-brown family. --

## Accent color for headers, highlighted titles, and card borders -- reuses
## Panel Border so borders and "pop" text read as one warm-gold family.
const ACCENT := PANEL_BORDER

## Semi-transparent backdrop behind modal overlays (combat log, map, shop,
## secondary-subclass choice).
const OVERLAY_BACKDROP := Color(0, 0, 0, 0.6)

## A step darker than PANEL, for pressed button states and inset panels
## (shopkeeper portrait box, inventory tray) that should read as "recessed"
## against the surrounding card.
const PANEL_DEEP := Color("150F0A")

## Button/slot disabled fill -- distinct from PANEL_DEEP so a disabled
## control still reads as "flat," not merely darker.
const PANEL_DISABLED := Color("3A2E22")

## Structural connector/line color (map node connectors, contract route
## lines, talent-tree connectors) -- deliberately neutral rather than warm,
## since these are layout scaffolding, not a semantic game-state color.
const STRUCTURE_LINE := Color("2E2318")
const STRUCTURE_LINE_LIGHT := Color("6B5644")

## Route/Tavern map node fill -- current/selectable vs. inactive.
const MAP_NODE_CURRENT := Color("47708A")
const MAP_NODE_INACTIVE := Color("3A2E22")

## Gear tier colors (GearItem.Tier). Kept distinct from the five semantic
## text roles above since tier communicates item rarity, not a game
## mechanic like poison/gold/magic -- BASIC intentionally reuses the same
## green as TEXT_POISON (both read as "common/organic"), the rest are
## their own hues.
const TIER_BASIC := TEXT_POISON
const TIER_MASTER := Color("4E8AC5")
const TIER_CURSED := TEXT_MAGIC
const TIER_LEGENDARY := Color("E3914C")

## Empty gear slot fill/border -- neutral, not tier-colored.
const SLOT_EMPTY := PANEL_DISABLED
const SLOT_BORDER := BACKGROUND

## Enemy-HUD health bar fill (user-requested combat-HUD addition,
## 2026-07-18). The master palette has no dedicated "health" entry; the
## Rogue section's Crimson Accent (#9E3535) is the palette's own deep
## blood-red and reads distinctly from TEXT_WARNING's brighter #D35C45,
## which stays reserved for warning/loss text rather than doubling as a
## bar fill.
const HEALTH_BAR_FILL := Color("9E3535")

## Loss/defeat outcome color. Same role as TEXT_WARNING; kept as its own
## name because combat_screen.gd's _apply_outcome_presentation()
## (P2:R5:T8) already refers to it as the outcome loss color at each call
## site -- aliasing rather than renaming keeps that intent readable.
const OUTCOME_LOSS := TEXT_WARNING

## Solid "this is a clickable action" fill for primary buttons (Lock,
## Fight!, Buy, Choose, Allocate, ...), added in the combat-playback
## adjustment round 1 (2026-07-19) at the user's request. Before this,
## the project theme's Button "normal" state reused PANEL -- the exact
## same fill as the card panels those buttons sit inside -- so a button
## didn't read as distinct from "this is a window." Gold family from the
## master palette's Metals section (not one of the ten adopted "UI" table
## colors -- none of those served this specific "actionable control" role,
## so this borrows from the wider master palette the way HEALTH_BAR_FILL
## already does). Applied via project/scripts/tools/build_ui_theme.gd's
## generated project/assets/ui_theme.tres, not per-button, so every button
## in the project picks it up automatically. Button's "hover" state keeps
## the existing PANEL_HIGHLIGHT fill unchanged -- it already reads well
## against TEXT_NORMAL and swapping it for the lightest Gold tone here
## would have weakened that contrast.
##
## REVISED in the combat-playback adjustment round 2 + retry bug pass
## (2026-07-19): the user reported the "active" button fill too light
## against its label text. Measured WCAG relative-luminance contrast of
## each fill against TEXT_NORMAL (#F4E2C4, cream) confirms it: round 1's
## normal-state fill (Gold Mid #C89433) only reached ~2.14:1 against
## TEXT_NORMAL -- below even the 3:1 floor WCAG recommends for large/UI-
## component text, and noticeably worse than the hover fill it sits next to
## (PANEL_HIGHLIGHT #B46D3C, ~3.18:1) -- so the button a player looks at for
## most of a session (its normal, at-rest, "this is live and clickable"
## state) was the actual low-contrast offender, not the transient pressed
## state (round 1's Gold Shadow #9C6A21 already measured ~3.67:1, better
## than Gold Mid). Fix: BUTTON_FILL now uses Gold Shadow (the master
## palette's Metals/Gold family has no darker literal swatch than Shadow),
## and BUTTON_FILL_PRESSED becomes a new derived-darker tone (not a literal
## master-palette entry -- same "derived to stay in the family" precedent as
## PANEL_DEEP below) so pressed still reads as visually distinct from and
## darker than normal, which itself is now darker than hover. The resulting
## state ladder by luminance is Pressed (darkest, ~6.82:1) < Normal
## (~3.67:1) < Hover (~3.18:1, unchanged) -- a coherent normal/hover/press
## progression where every state clears the 3:1 UI-component contrast floor
## against TEXT_NORMAL, and the two states players see the most (normal and
## pressed) both comfortably exceed it.
const BUTTON_FILL := Color("9C6A21")          # Gold Shadow
const BUTTON_FILL_PRESSED := Color("654515")  # Gold Deep (derived, darker than Gold Shadow)
