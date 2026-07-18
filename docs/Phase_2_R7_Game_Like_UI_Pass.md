# P2:R7 - Game-Like UI Pass

## Purpose

Track the work for **P2:R7 - Game-Like UI Pass**.

The goal is to make the revised Phase 2 Rogue Adventure understandable and
pleasant enough for a new player to play unassisted. This is a clarity,
layout, and interaction pass, not a full art/animation production pass.

Scope addition (2026-07-17): R7 also includes applying the game's visual
style foundations - the "Road to Peak Deeps" UI palette, the four-role font
system, and a project-wide Godot Theme resource. The palette/font decisions,
code audit, and phased implementation plan are recorded in
`docs/Phase_2_R7_Style_Implementation_Notes.md`. Icon-pack integration and
full art production remain out of scope unless separately added.

## Exit Criteria

P2:R7 is complete when:

- A new player can identify their class, subclass, talents, rotation, gear,
  enemy, rewards, and next action without outside explanation.
- The UI palette and font system from
  `docs/Phase_2_R7_Style_Implementation_Notes.md` are applied through a
  project-wide Theme resource, with no hardcoded ad hoc colors left in
  screen scripts.
- The dashboard supports Tavern, shop, route, combat, reward, failure, and
  victory states coherently.
- Important disabled/locked states explain themselves.
- Combat results help the player understand why a build worked or failed.
- UI text fits across target desktop view sizes.
- Manual click-through is completed in addition to headless tests.

## Task Checklist

| ID | Task | Output | Status |
|---|---|---|---|
| P2:R7:T1 | Define UI Evaluation Pass | Screens/states to review listed | Not started |
| P2:R7:T2 | Apply Visual Style Foundations | Palette, fonts, and project-wide Theme per the style notes doc | Not started |
| P2:R7:T3 | Improve Run Header/Status | Seed, phase, gold, current node, and next action visible | Not started |
| P2:R7:T4 | Improve Build Panels | Talents, skills, stats, and gear clearer and more ergonomic | Not started |
| P2:R7:T5 | Improve Enemy/Encounter Presentation | Target pressure and DPS window readable before fight | Not started |
| P2:R7:T6 | Improve Reward/Shop/Route UI | Choices communicate cost, value, and consequences | Not started |
| P2:R7:T7 | Improve Combat Recap | Win/loss recap explains damage, DPS, and key interactions | Not started |
| P2:R7:T8 | Polish Navigation/Confirmations | Main menu, abandon, resume, continue, retry, restart are coherent | Not started |
| P2:R7:T9 | Verify Layout And Tests | Headless tests plus manual click-through notes | Not started |
| P2:R7:T10 | Update Docs | Remaining UI polish deferred or documented | Not started |

## P2:R7:T1 - Define UI Evaluation Pass

List every reachable state after P2:R6:

- Title / resume / new run.
- Class select.
- Primary subclass select.
- Tavern planning.
- Fight result.
- Reward claim.
- Shop.
- Contract offer.
- Secondary subclass select.
- Route choice.
- Elite/Legendary reward.
- Boss.
- Loss with do-over.
- Contract failed.
- Victory.

## P2:R7:T2 - Apply Visual Style Foundations

Apply the palette/font/theme plan from
`docs/Phase_2_R7_Style_Implementation_Notes.md`:

- Resolve the palette fork (master palette doc vs. style guide mockup)
  before any hex value goes into code.
- Download and commit the four OFL fonts (Pirata One, MedievalSharp,
  Press Start 2P, VT323) with their license files.
- Add a `UIColors` constants script and a project-wide Theme resource
  registered via `gui/theme/custom`.
- Rewrite `CardStyle` to read from `UIColors`, then replace the bypass
  colors in screen scripts (audited list in the style notes doc).
- Apply semantic text colors (gold, poison, warning, magic, disabled)
  where mechanics show through; align with whatever `P2:R5:T8` already
  shipped rather than duplicating it.

Doing this before T3-T8 means those tasks iterate on styled screens
instead of restyling their own work afterward.

## P2:R7:T3 - Improve Run Header/Status

Add or refine always-visible context:

- Current run phase.
- Current seed.
- Gold.
- Current encounter/route node.
- Next expected action.
- Build locked/unlocked state.

## P2:R7:T4 - Improve Build Panels

Make build controls easier to scan:

- Talent availability and prerequisites.
- Remaining/spent talent points.
- Skill tooltips and effects.
- Rotation order and removal.
- Stat changes from gear/talents.
- Equipped vs inventory items.

## P2:R7:T5 - Improve Enemy/Encounter Presentation

Enemy panel should help players reason:

- HP and required DPS.
- Armor and poison resistance.
- Combat window.
- Known reward.
- Why this target pressures certain builds, if concise.

Avoid overexplaining with walls of text.

## P2:R7:T6 - Improve Reward/Shop/Route UI

Choices should show:

- Price or reward tier.
- Slot.
- Affixes.
- Whether the item can be equipped.
- Current gold.
- Route difficulty/reward tradeoff.
- Clear continue/back/confirm behavior.

## P2:R7:T7 - Improve Combat Recap

Recap should support buildcraft learning:

- Total damage.
- DPS.
- Required damage/DPS.
- Biggest hit.
- Physical/poison split.
- Crit count if available.
- Armor reduction contribution if useful.
- Poison stack/tick summary if useful.

## P2:R7:T8 - Polish Navigation/Confirmations

Review confusing or destructive actions:

- Return to main menu.
- Save and quit.
- Abandon run.
- Retry fight.
- Continue after win.
- Restart after failure/victory.

Confirmations should be used where state loss is real.

## P2:R7:T9 - Verify Layout And Tests

Verification should include:

- Existing headless tests.
- New tests for important state transitions if needed.
- Manual Godot editor/player click-through.
- Desktop viewport sanity.
- Text fitting and no obvious overlap.

## P2:R7:T10 - Update Docs

When complete:

- Update this checklist.
- Record manual click-through caveats.
- Move full art/animation ideas to `phase3_ideas.md`.
- Update `docs/Phase_2_Milestones.md`.

## Implementation Notes

2026-07-17 (pre-R7 planning):

- Added `P2:R7:T2 - Apply Visual Style Foundations` and renumbered the
  later tasks (previously T2-T9, now T3-T10). No other doc referenced the
  old R7 task IDs, so the renumbering is safe.
- Created `docs/Phase_2_R7_Style_Implementation_Notes.md` holding the
  palette tables, the four-role font system (including the "Pirate Knight"
  to Pirata One correction and OFL license verification), the current-code
  audit (`CardStyle` centralization, bypass-color list in
  `combat_screen.gd`), and the phased implementation plan.
- One decision is deliberately left open for R7 start: the palette fork
  between the warm master palette doc and the darker style guide mockup.

## Verification Notes

TBD
