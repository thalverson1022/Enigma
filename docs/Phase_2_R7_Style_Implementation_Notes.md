# P2:R7 - Style Implementation Notes

## Purpose

Planning notes for the visual style foundations task of **P2:R7 - Game-Like
UI Pass** (`P2:R7:T2` in `docs/Phase_2_R7_Game_Like_UI_Pass.md`). Written
2026-07-17, ahead of R7, so the palette/font/theming decisions and the
implementation plan are not lost between sessions.

This doc covers applying a color palette and font system to the existing
UI. It does not cover the icon-pack integration track (32x32 item/skill
icons and UI spritesheets from the purchased pack at
`F:\Data\Junk\DPS Game\Rpg Icon Pack` - permissive license, commercial use
allowed, no redistribution), which is a separate, larger R7 task if scoped.

**2026-07-24 update:** gear icon integration did happen
(`docs/Phase_2_R12_Gear_Icon_Art_Integration.md`, complete), but using
different art than this section anticipated -- the user supplied
hand-authored, Rogue-specific 32x32 art directly
(`project/assets/Items/Rogue/`), not the generic purchased pack named above.
The purchased pack remains unused/unintegrated; it may still be relevant for
future skill icons or UI spritesheet needs beyond gear.

## Source Material

- `F:\Data\Junk\DPS Game\The_Road_to_Peak_Deeps_Master_Palette.md` - the
  master color palette (hex tables). Source of truth for color values; the
  UI-relevant subset is copied below so this doc stands alone.
- A UI style guide mockup image (shared 2026-07-17) proposing a four-role
  font system and example panel/button/notification layouts. Useful as
  layout/typography direction; its color values diverge from the master
  palette (see Open Decision below).
- The Rogue/Mage/Crusader/Nature/Dungeon/Magic Effects sections of the
  master palette constrain future sprite/tile art, not this UI pass.

## Open Decision: Palette Fork -- RESOLVED (2026-07-17)

The two references disagreed on the UI base colors:

- Master palette doc: warm browns (background `#221811`, panel `#5B3A25`).
- Style guide mockup: darker and cooler (near-black backgrounds, blue-grey
  panels, separate gold/red/green/blue accents).

**Resolved during `P2:R7:T2`: the master palette (warm browns) is adopted.**
The user rejected the darker/cooler style-guide-mockup alternative after a
side-by-side comparison. The palette now lives at
`docs/The_Road_to_Peak_Deeps_Master_Palette.md` (copied into the repo so it
owns its own source of truth) and is implemented as named constants in
`project/scripts/ui/ui_colors.gd`.

## UI Palette (from the master palette doc)

| Role | Hex |
|---|---|
| Background | `#221811` |
| Panel | `#5B3A25` |
| Panel Highlight | `#B46D3C` |
| Panel Border | `#E1A867` |
| Normal Text | `#F4E2C4` |
| Disabled Text | `#A28D73` |
| Warning | `#D35C45` |
| Magic Text | `#9D73D8` |
| Poison Text | `#72B953` |
| Gold Text | `#E3C35C` |

Semantic mapping to existing game mechanics:

- Gold Text: gold amounts (rewards, shop prices, `BuildState.gold`).
- Poison Text: poison damage/tick/stack numbers.
- Warning: crits taken, loss states, do-over/restart/contract-failed
  feedback (overlaps with `P2:R5:T8 - Wire UI Feedback`).
- Magic Text: proc/triggered-skill lines (Opportunity Strikes, Mithril
  Karambit), Legendary flavor.
- Disabled Text: locked talents, unaffordable shop items, disabled
  class/subclass cards.

## Font System (four roles)

Verified 2026-07-17: all four fonts are real, on Google Fonts, licensed
under the SIL Open Font License (free for commercial use; bundling in a
shipped game is allowed; keep the OFL license files next to the TTFs).

Correction: the style guide mockup names "Pirate Knight (Google Fonts)" as
the title font. **No such font exists.** Pirata One is the real Google Font
it imitates (blackletter, explicitly optimized for screens and pixel
displays) and is the substitute recorded here.

| Role | Font | Notes |
|---|---|---|
| Title / logo | Pirata One | Title screen only; not theme-wide |
| Headings / section titles | MedievalSharp | Panel headers across the dashboard |
| Buttons / UI labels | Press Start 2P | Short all-caps strings only; runs wide, needs padding |
| Body / descriptions / data | VT323 | Theme default font; monospaced, keeps numbers stable |

Godot import settings:

- Godot ships no fonts beyond its default UI font. All four TTFs must be
  downloaded once and committed (suggested: `project/assets/fonts/`).
- Press Start 2P and VT323 are pixel-styled: antialiasing **off**, no
  mipmaps, render at native-size integer multiples or they blur (same
  class of gotcha as pixel-art texture filtering).
- Pirata One and MedievalSharp are vector faces: antialiasing can stay on
  at large sizes; test AA off + integer scale for a harder pixel look.
- VT323 legibility at small sizes is the main risk for a stat-heavy game.
  If it fails at real dashboard scale, keep it for flavor text and switch
  data columns to a clean modern monospace (deliberate style mix).

## Current Code Reality (audited 2026-07-17)

The codebase is already partially prepared:

- `project/scripts/ui/card_style.gd` (`CardStyle`) centralizes the shared
  bordered-panel look and `ACCENT_COLOR`, and its own doc comment says it
  exists so "the eventual full theming pass has one place to change." All
  nine screens/panels route through it (title, class_select,
  subclass_select, combat_screen, and the five dashboard panels).
- Bypass colors that do NOT go through `CardStyle` (found by grep, mostly
  in `project/scenes/combat/combat_screen.gd`): the overlay backdrop
  `Color(0, 0, 0, 0.6)`, `CONTRACT_LINE_COLOR`, route-map node/connector
  colors (`Color(0.28, 0.43, 0.48)` etc.), the shopkeeper panel
  `Color(0.1, 0.1, 0.12)`, and per-button font color overrides. Each needs
  to become a named-constant reference during the cleanup pass.
- No `Theme` resource, no custom fonts, and no `gui/theme/custom` project
  setting exist yet. Everything renders in Godot's default theme.

## Implementation Plan

### Phase 0 - Decisions and assets (no code)

1. Resolve the palette fork (see Open Decision above).
2. Download the four TTFs + OFL license files; commit to
   `project/assets/fonts/`.
3. Copy the master palette doc into `docs/` so the repo owns its own
   source of truth.

### Phase 1 - Foundations (most visual change per edit)

4. Add `project/scripts/ui/ui_colors.gd` (`UIColors`): named `Color`
   constants for the full UI palette including semantic text colors. Both
   the Theme resource and dynamic code (combat log coloring) read from it.
5. Build `project/assets/ui_theme.tres`:
   - Default font VT323 with sensible default sizes.
   - Theme type variations for the special roles (e.g. a `PanelHeader`
     Label variation using MedievalSharp; Button styled with
     Press Start 2P).
   - `StyleBoxFlat`s for Panel/PanelContainer/Button
     (normal/hover/pressed/disabled) built from `UIColors`.
6. Register the theme project-wide via `gui/theme/custom` in
   `project.godot` - cascades to every scene including dynamically
   created controls.
7. Rewrite `CardStyle.make_stylebox()` and `ACCENT_COLOR` to read from
   `UIColors`. Because all nine screens call it, this one edit restyles
   every card/panel in the game.

### Phase 2 - Cleanup pass

8. Replace the bypass colors listed above with `UIColors` references.
9. Apply semantic colors where mechanics show through: poison green, gold
   gold, failure/crit red, proc purple - combat log, stat panels,
   victory/defeat banners. Note: if `P2:R5:T8` lands first, some of this
   may already exist; align rather than duplicate.
10. Per-screen legibility pass at 1600x900: font-size overrides that
    assumed the default font need retuning (VT323 and Press Start 2P have
    very different metrics); check Press Start 2P button/tab widths.

### Phase 3 - Verification

11. Run the headless test suite. It asserts on text and state, not colors,
    so it should pass untouched; a styling-only change breaking a test is
    a signal that logic leaked into presentation.
12. Manual editor click-through for the visual judgment calls (contrast,
    blur, spacing) - rendered output cannot be verified headlessly in the
    usual dev environment. Remember the one-time
    `godot --headless --editor --quit` class-cache rescan after adding new
    global-class scripts (`UIColors`).

### Estimated scale

Phases 0-1: roughly half a day, delivering most of the visible change via
the `CardStyle`/theme cascade. Phase 2: another half-to-full day, mostly
`combat_screen.gd` cleanup. No combat/build/system code is touched at any
point; this is presentation-layer work consistent with the UI architecture
principle in `docs/Conventions.md`.

### Status (2026-07-17): Phases 0-3 complete

All four phases above are implemented as part of `P2:R7:T2`. See
`docs/Phase_2_R7_Game_Like_UI_Pass.md`'s `P2:R7:T2` Implementation Notes
and Verification Notes entries (dated 2026-07-17) for the specifics of what
was built, what was deliberately deferred (mid-sentence semantic coloring
inside composite strings that existing tests assert on as one contiguous
substring, e.g. `_reward_text()`), and the exact test commands run. Nothing
from this plan remains outstanding for `P2:R7:T2`; the only unverified
piece is a manual rendered click-through, which this sandboxed environment
cannot perform (documented limitation, not a gap in the implementation).

## Relationship To Other Milestones

- `P2:R5:T8 - Wire UI Feedback`: the semantic Warning/Gold colors serve
  that task's goal (making loss/do-over/restart/contract-failed states
  legible). A minimal application of those two colors during R5:T8 is
  reasonable; the full theming pass stays here in R7.
- Icon-pack integration (item/skill icons, UI spritesheet slicing) is a
  separate R7 track with its own scale, not covered by this plan.
- Full art/animation/juice production remains Phase 3+ per
  `phase3_ideas.md`.
