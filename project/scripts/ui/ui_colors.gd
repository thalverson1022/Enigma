class_name UIColors
extends RefCounted
## Single source of truth for the playable Godot UI palette. Both
## project/assets/ui_theme.tres and dynamic GDScript color logic
## (CardStyle, combat_screen.gd, and dashboard panel scripts) read from
## these constants instead of hardcoding hex/RGB literals, so the palette
## can be retuned in one place.

# -- Core palette: Earth & Iron exploratory pass, M8:T2 (2026-08-06) --
const BACKGROUND := Color("161616")       # Iron Black
const PANEL := Color("1D150F")            # Dark Earth Brown
const PANEL_HIGHLIGHT := Color("3E5B3B")  # Forest Green
const PANEL_BORDER := Color("C9A259")     # Worn Gold
const TEXT_NORMAL := Color("F0E2C5")      # Derived warm parchment for readability
const TEXT_DISABLED := Color("9A8E7B")    # Derived muted iron-parchment
const TEXT_WARNING := Color("8A2E2E")     # Blood Red
const TEXT_MAGIC := Color("C9A259")       # Worn Gold
const TEXT_POISON := Color("8FBF72")      # Readable poison green derived from Forest Green
const TEXT_GOLD := Color("C9A259")        # Worn Gold

# -- Semantic extensions added during the R7:T2 cleanup pass, so every ad
# hoc Color() literal that used to live in scene scripts has a named home
# here instead. Not part of the source palette table; derived to stay
# inside the same theme family. --

## Accent color for headers, highlighted titles, and card borders.
const ACCENT := PANEL_BORDER

## Semi-transparent backdrop behind modal overlays (combat log, map, shop,
## secondary-subclass choice).
const OVERLAY_BACKDROP := Color(0, 0, 0, 0.6)

## A step darker than PANEL, for pressed button states and inset panels.
const PANEL_DEEP := Color("120D09")

## Button/slot disabled fill -- distinct from PANEL_DEEP so a disabled
## control still reads as "flat," not merely darker.
const PANEL_DISABLED := Color("201A15")

## Structural connector/line color (map node connectors, contract route
## lines, talent-tree connectors) -- deliberately neutral rather than warm,
## since these are layout scaffolding, not a semantic game-state color.
const STRUCTURE_LINE := Color("120D09")
const STRUCTURE_LINE_LIGHT := Color("4A3B2F")

## Route/Tavern map node fill -- current/selectable vs. inactive.
const MAP_NODE_CURRENT := Color("3E5B3B")
const MAP_NODE_INACTIVE := PANEL_DISABLED

## Gear tier colors (GearItem.Tier). These intentionally preserve the rarity
## language from docs/New_Gear_Overview.md rather than following the current
## exploratory UI palette.
const TIER_CRUDE := Color("8A8A7A")
const TIER_BASIC := Color("72B953")
const TIER_MASTER := Color("4E8AC5")
const TIER_EPIC := Color("F5F1DD")
const TIER_CURSED := Color("9D73D8")
const TIER_CHAOS := Color("2A292F")
const TIER_UNIQUE := Color("D6C547")
const TIER_LEGENDARY := Color("E3914C")

## Empty gear slot fill/border -- neutral, not tier-colored.
const SLOT_EMPTY := PANEL_DISABLED
const SLOT_BORDER := TEXT_DISABLED

## Enemy-HUD health bar fill (user-requested combat-HUD addition,
## 2026-07-18). The master palette has no dedicated "health" entry; the
const HEALTH_BAR_FILL := TEXT_WARNING
const HEALTH_BAR_FILL_LIGHT := Color("B94A3D")
const HEALTH_BAR_FILL_SHADOW := Color("4C1714")
const HEALTH_BAR_TRACK := PANEL_DEEP
const HEALTH_BAR_TRACK_BORDER := PANEL_BORDER
const HEALTH_BAR_TRACK_INNER := PANEL_INNER_SHADOW
const HEALTH_BAR_SHEEN := Color(1.0, 0.78, 0.52, 0.22)

## Loss/defeat outcome color. Same role as TEXT_WARNING; kept as its own
## name because combat_screen.gd's _apply_outcome_presentation()
## (P2:R5:T8) already refers to it as the outcome loss color at each call
## site -- aliasing rather than renaming keeps that intent readable.
const OUTCOME_LOSS := TEXT_WARNING

## Solid "this is a clickable action" fill for primary buttons. In the Dark
## Iron pass, action buttons use Blood Red while borders/rewards keep the
## worn-gold accent.
const BUTTON_FILL := Color("8A2E2E")
const BUTTON_FILL_PRESSED := Color("5C1E1E")

# -- M8 semantic UI roles --
# These aliases keep recurring visual assets tied to roles instead of raw
# color values, so future palette experiments can retune one source.
const PANEL_DROP_SHADOW := Color(0, 0, 0, 0.46)
const PANEL_BORDER_SHADOW := Color("6E562E")
const PANEL_EDGE_LIGHT := Color("E4C06F")
const PANEL_TOP_LIGHT := Color("3A2C21")
const PANEL_INNER_SHADOW := Color("0B0806")
const PANEL_TEXTURE_DARK := Color(0, 0, 0, 0.12)

const BUTTON_EDGE_LIGHT := PANEL_EDGE_LIGHT
const BUTTON_EDGE_SHADOW := Color("4C1714")
const BUTTON_TOP_LIGHT := Color("B94A3D")
const BUTTON_BOTTOM_SHADOW := Color("3B1111")
const BUTTON_INNER_GLOW := Color(0.92, 0.72, 0.38, 0.20)

const SLOT_INNER_SHADOW := Color("100C09")
const SLOT_HOVER := TEXT_NORMAL

const ACTION_DEFAULT := BUTTON_FILL
const ACTION_HOVER := PANEL_HIGHLIGHT
const ACTION_PRESSED := BUTTON_FILL_PRESSED
const ACTION_FOCUS := BUTTON_FILL
const ACTION_DISABLED := PANEL_DISABLED

const CHOICE_AVAILABLE := PANEL
const CHOICE_SELECTED := MAP_NODE_CURRENT
const CHOICE_COMMITTED := BUTTON_FILL_PRESSED
const CHOICE_LOCKED := MAP_NODE_INACTIVE

const BUILD_ACTIVE := TEXT_GOLD
const BUILD_ACTIVE_BG := Color(0.18, 0.15, 0.08, 0.94)
const BUILD_PROC := TEXT_MAGIC
const BUILD_PROC_BG := Color(0.19, 0.16, 0.09, 0.94)
const BUILD_PROGRESS_FILL := Color(0.79, 0.64, 0.35, 0.38)
const BUILD_PROC_PROGRESS_FILL := Color(0.79, 0.64, 0.35, 0.48)

const TALENT_SELECTED_BG := Color(0.16, 0.25, 0.15, 0.96)
const TALENT_SELECTED_BORDER := TEXT_POISON
const TALENT_BLOCKED_PULSE := TEXT_WARNING
const TALENT_DEPENDENCY_PULSE := Color(0.79, 0.64, 0.35, 1.0)

const SCRIM_SOFT := Color(0, 0, 0, 0.42)
const SCRIM_STRONG := Color(0, 0, 0, 0.56)
const RESULT_DIM := Color(0, 0, 0, 0.58)
const BADGE_BACKDROP := Color(0, 0, 0, 0.72)
const TRANSPARENT := Color(0, 0, 0, 0)
const TEXT_OUTLINE := Color(0, 0, 0, 0.92)
const TEXT_OUTLINE_STRONG := Color(0, 0, 0, 0.95)
const ICON_DISABLED := TEXT_DISABLED
const FEEDBACK_BLOCKED := TEXT_WARNING
const FEEDBACK_REWARD_PULSE := Color(1.05, 0.90, 0.56, 1.0)
const FEEDBACK_REWARD_PULSE_TRANSPARENT := Color(1.05, 0.90, 0.56, 0.0)
const FEEDBACK_ACTION_PULSE := Color(0.82, 0.34, 0.28, 1.0)
const FEEDBACK_WARNING_PULSE := Color(0.92, 0.30, 0.24, 1.0)

const COMBAT_CHART_CAST := Color(0.47, 0.42, 0.34, 0.94)
const COMBAT_CHART_POISON := Color(0.24, 0.36, 0.23, 0.95)
const COMBAT_CHART_PROC := Color(0.79, 0.64, 0.35, 0.95)
const COMBAT_CHART_GRID := Color(0.79, 0.64, 0.35, 0.26)
const COMBAT_CHART_LINE := Color(0.79, 0.64, 0.35, 0.34)
const COMBAT_CHART_LINE_SOFT := Color(0.79, 0.64, 0.35, 0.24)
const COMBAT_CHART_TEXT := Color(0.86, 0.80, 0.68, 1.0)
const COMBAT_CHART_VALUE := Color(0.79, 0.64, 0.35, 1.0)
const COMBAT_CHART_CRIT := Color(0.79, 0.64, 0.35, 1.0)
const COMBAT_CHART_CONTACT := Color(0.79, 0.64, 0.35, 1.0)
const COMBAT_CHART_BAR_BORDER := Color(0.79, 0.64, 0.35, 0.32)
const COMBAT_CHART_BAR_BORDER_SOFT := Color(0.79, 0.64, 0.35, 0.28)
const COMBAT_CHART_BAR_BG := Color(0.08, 0.08, 0.08, 0.75)
const COMBAT_CHART_ICON_TEXT := Color(0.08, 0.08, 0.08, 1.0)
const COMBAT_CHART_ARMOR := TEXT_MAGIC
const COMBAT_CHART_CRIT_INNER := Color(0.15, 0.10, 0.04, 1.0)

const COMBAT_POISON_TICK_FLASH := Color(0.44, 0.82, 0.35, 1.0)
const COMBAT_HIT_FLASH := Color(0.95, 0.62, 0.54, 1.0)
const COMBAT_CRIT_FLASH := Color(0.96, 0.70, 0.38, 1.0)
const COMBAT_DEFEATED_ACTOR_MODULATE := Color(1.0, 1.0, 1.0, 0.62)
