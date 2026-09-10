# Shop Lab

Shop Lab is a client-only browser tool for inspecting Project Enigma Phase 5
procedural gear offers before the live Adventure reward and shop integration
pass.

Open `index.html` in a browser to use it. No install step is required.

## Current Scope

- Simulates the five universal gear slots: Weapon, Helm, Armor, Trinket, and
  Charm.
- Displays Rogue item families: Dagger, Hood, Doublet, Ring, and Necklace.
- Rolls the active procedural rarities: Basic, Master, Epic, Cursed, Chaos, and
  Unique.
- Mirrors the Phase 5 stat vocabulary with Basic, Rare, Special, and drawback
  categories.
- Uses slot-specific stat pools, weights, value ranges, rarity multipliers, and
  no-duplicate-stat rules.
- Preserves boundaries for Crude starter gear, Lucky Coin, compatibility gear,
  and fixed Legendary catalog items.
- Exposes seed, contract depth, shop size, depth-aware rarity curve presets or
  manual rarity weights, slot weights, value scale, reroll costs, starting
  gold, and batch size.
- Adds Quick Simulation presets for Early Run, Mid Run, Late Run, and High
  Variance comparisons so common depth, curve, value-scale, shop-size, and
  batch-size setups can be repeated quickly.
- Separates manual value scaling from contract-depth value scaling and shows
  the combined effect on generated stat ranges.
- Shows readable item cards while keeping tuning-facing metadata available to
  scripted checks and aggregate readouts, including stat ids, categories, pool
  weights, value ranges, rarity multipliers, drawbacks, Specials, and item
  signatures.
- Groups generated item card stats visually without diagnostic labels, while
  preserving rarity, slot, Rogue family, drawback, Special, and retrigger data
  for tuning readouts.
- Summarizes session and batch distributions for rarity, slot, roll markers,
  stat categories, individual stats, drawbacks, Specials, Unique Specials,
  Chaos outcomes, Cursed shape, retrigger appearances, and broad quality bands.
- Adds dedicated Cursed and Chaos tuning summaries for shape validation,
  positive/drawback balance, top risk stats, and Chaos all-positive, mixed, and
  all-drawback outcome rates.
- Adds a Retrigger Watch summary for Chance for Retrigger appearances,
  slot/rarity mix, min/average/max values, multi-item shops, top-five stacking,
  and proximity to the 100% chance cap.
- Includes `run_checks.js` as a one-command focused regression runner for the
  browser lab.

## Notes

The lab is intentionally separate from the Godot project runtime. It is a
fast tuning surface for P5M6 and should not be treated as final P5M7 Adventure
economy tuning or final P5M8 player-facing item presentation.
