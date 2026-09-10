# Itch.io Release Checklist

Use this checklist for the Phase 5 Project Enigma web playtest package.

## Build

1. Run `tools/p5m12/run_regression.ps1`.
2. Run `tools/p5m12/export_itchio.ps1`.
3. Confirm `release/itchio/project-enigma-phase5-itch.zip` exists.
4. Confirm the ZIP root contains `index.html`.

## itch.io Settings

- Kind of game: HTML.
- Upload: `project-enigma-phase5-itch.zip`.
- Launch mode: fullscreen is preferred for the current 1600x900 canvas.
- Embedded viewport fallback: 1600x900.
- Mobile friendly: leave disabled unless a mobile smoke pass is completed.
- SharedArrayBuffer/cross-origin isolation: enable when itch.io offers the
  option for Godot 4 web builds.

## Release Notes Seed

Project Enigma Phase 5 gear baseline:

- Five-slot Rogue gear: Dagger, Hood, Doublet, Necklace, and Ring.
- Generated Basic, Master, Epic, Cursed, Chaos, and Unique gear.
- Fixed retained Rogue Legendary daggers.
- Gear rewards, between-contract shops, readable item cards, comparison
  tooltips, and current Practice Room/Balance Lab validation.
- Current playtest tuning for Rogue, generated contract scaling, economy stats,
  and Overkill Gold.
