# Project Bane — Folder & Naming Conventions

Established at P2:M0 (Project Foundation). Applies to all later milestones
unless explicitly revised here.

## Repository layout

The git repo root is `Project-Bane/` itself, not the Godot project folder.
Design docs and engine code share one history.

```
Project-Bane/
├── docs/                 design docs (this file included)
├── phase3_ideas.md        scope-creep backlog (working agreement 6)
├── .gitignore             repo-root ignores (e.g. .claude/ local tool config)
└── project/               the actual Godot 4.x project root
    ├── project.godot
    ├── .gitignore          Godot-specific ignores (.godot/, export artifacts)
    ├── data/               Resource (.tres) content files — no game logic
    │   ├── skills/
    │   ├── gear/
    │   ├── talents/
    │   ├── monsters/
    │   └── player/          starter combatant stats (attack speed, crit, poison/tick)
    ├── scripts/
    │   ├── resources/      custom Resource class_name defs (skill.gd, gear_item.gd, ...)
    │   ├── systems/         combat/build-resolution logic
    │   └── autoload/        singletons
    ├── scenes/               UI/build screens (.tscn)
    ├── tests/                headless-runnable combat tests
    └── assets/               placeholder or real art/audio
```

`data/` holds only `.tres` Resource files — per the Phase 2 architecture
principle, new content must be addable here with zero script changes.
`scripts/resources/` holds the `class_name` schema definitions those `.tres`
files are instances of.

## Naming rules

- Files and folders: `snake_case` (Godot convention), e.g. `poison_strike.tres`,
  `armored_guard.tres`, `skill.gd`.
- GDScript `class_name` declarations: `PascalCase`, e.g. `class_name Skill`,
  `class_name GearItem`.
- Resource IDs inside data files should mirror the old Project Abaddon ID
  style only where useful for cross-referencing during the later seed-data
  pass (e.g. `skill.stab`) — not a hard requirement at P2:M0/P2:M1.

## Placeholder content policy

Per Phase 2 working agreement 3: `data/` should contain exactly one
placeholder skill, one placeholder gear item, one placeholder talent, and one
placeholder monster through P2:M2. Real content volume from the Project
Abaddon reference docs is out of scope until P2:M1/P2:M2 placeholders prove
the architecture (see `docs/DPS_Engine_Phase2_Context.md`).

## UI architecture principle (P2:M3 onward)

As of the 2026-07-15 Phase 2 scope revision, a more game-like UI is part of
Phase 2. That means clearer screen flow, dashboard presentation, readable
combat/reward feedback, and interaction patterns that feel like a game rather
than a debug tool. Full custom art production, elaborate combat animation,
and a broad polish/marketing pass remain later work unless explicitly scoped.

Screens must keep game state/logic out of `Control` scripts and communicate
via signals/return values (following the pattern already set by
`CombatResolver.resolve()`, which returns a timestamped event log rather
than only a final number) so the presentation layer can keep improving
without touching the underlying systems.
