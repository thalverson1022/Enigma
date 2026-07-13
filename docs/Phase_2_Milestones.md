# Phase 2 (Project Bane) Milestones

## Purpose

This is the locked Phase 2 goal and milestone breakdown for Project Bane. It
was agreed during Phase 2 kickoff planning and should be treated as the
source of truth for scope, alongside `docs/DPS_Engine_Phase2_Context.md`
(working agreements and technical foundation) and `docs/Conventions.md`
(folder/naming rules).

Numbering convention: **Phase (P) → Milestone (M) → Task (T) → Step (S)**,
e.g. `P2:M1:T2:S3`.

## Relationship To Project Abaddon Docs

`Phase_1_Design_Recap.md`, `Current_Mechanics_Reference.md`,
`Content_Library_Reference.md`, and `Balance_Baseline_Report.md` describe the
earlier TypeScript/React MVP, codenamed **Project Abaddon** (Phase 1,
complete). They are **reference-only** for Project Bane: firewalled from this
project's own architecture and implementation, to be mined later as **seed
data** (skill numbers, gear affixes, monster stat tables, DPS baselines) once
the Godot architecture is proven with placeholder content in P2:M1/P2:M2 —
not before.

## Phase 2 (Project Bane) Goal

> Port the validated Project Abaddon core loop (Balatro-meets-ARPG-
> theorycrafting, automated DPS-window combat) into Godot 4.x on a genuinely
> data-driven, production-quality architecture, producing one real vertical
> slice — one class, one subclass-tree pair, one boss — playable start to
> finish with no editor intervention.

**Definition of done:** a stranger can download a build, play a complete run
from character creation to a single boss fight, and give feedback — without
the developer present to explain anything.

**Explicitly not in Phase 2:** content-completion volume, a polish/marketing
pass, the Contract Run meta-layer (branching route nodes, minions, elites —
that's Phase 3, see `phase3_ideas.md`), multiplayer/mobile/platform-port, and
save/load beyond P2:M6's basic run-state persistence.

## Working Agreements

1. Milestone boundaries are hard — don't build M{n+1} content while executing
   M{n}.
2. Data-driven by default — skills/gear/talents/monsters are Godot `Resource`
   (`.tres`) files, never hardcoded in GDScript logic.
3. Placeholder content (one fake skill/gear/monster) is intentional through
   P2:M2, to isolate architecture bugs from content bugs.
4. Real content/numbers from the Project Abaddon docs are deferred until
   P2:M1/P2:M2 placeholders prove the architecture.
5. Propose before refactors spanning more than one milestone's systems.
6. Scope-creep ideas go to `phase3_ideas.md`, not built early.
7. Godot 4.x idioms only (no GD3 patterns).
8. State exit-criteria status explicitly when a milestone looks done.

## Milestone List

Status legend: ⬜ Not started · 🔄 In progress · ✅ Complete

| ID | Milestone | Objective | Exit Criteria | Status |
|---|---|---|---|---|
| P2:M0 | Project Foundation | Stand up the project shell | Empty Godot project runs, under git, folder/naming convention documented | ✅ Complete |
| P2:M1 | Data Architecture | Resource schema for Skills/Gear/Talents/Monsters | New skill or gear item addable via data file, zero code changes | ⬜ Not started |
| P2:M2 | Core Combat Resolution | Port the DPS window/rotation engine | Scripted rotation vs. dummy monster produces hand-verifiable DPS numbers, no UI | ⬜ Not started |
| P2:M3 | Build Planning UI | Class/subclass/talent/rotation screens | Player can assemble and lock a build through UI only | ⬜ Not started |
| P2:M4 | Economy & Gear Loop | Affix-based gear gen, shop, gold | Gold from a fight buys gear that measurably changes P2:M2's output | ⬜ Not started |
| P2:M5 | Full Loop Integration | Wire it all into one playable loop | Complete run playable start-to-finish through UI, one class/tree/boss | ⬜ Not started |
| P2:M6 | Save/Load | Persist run state | Quit mid-run, relaunch, resume correctly | ⬜ Not started |
| P2:M7 | Playtest-Ready Build | Bug pass, minimal legibility, export | A non-developer plays unassisted and gives useful feedback | ⬜ Not started |

## Task Outline (high level — Steps drafted milestone by milestone)

### P2:M0 — Project Foundation
- T1: Git repo init at `Project-Bane/` root; scaffold `docs/`, `phase3_ideas.md`, `project/`
- T2: Godot 4.x project init (`project.godot`, `.gitignore`, empty runnable scene)
- T3: Document folder/naming convention (`docs/Conventions.md`)

### P2:M1 — Data Architecture
- T1: Skill `Resource` schema + one placeholder skill `.tres`
- T2: Gear `Resource` schema (affix structure) + one placeholder gear item
- T3: Talent `Resource` schema + one placeholder talent
- T4: Monster `Resource` schema + one placeholder monster
- T5: Validate exit criteria — add a second placeholder skill via data file only, zero code changes

### P2:M2 — Core Combat Resolution
- T1: Skill execution timing / attack-speed breakpoint logic
- T2: Damage calculation (physical/poison, armor mitigation, crit)
- T3: Fixed-duration DPS window resolution loop
- T4: Win/loss determination vs. target HP pool
- T5: Headless/console test harness for hand-verifiable DPS output

### P2:M3 — Build Planning UI
- T1: Class/subclass selection screen
- T2: Talent point allocation screen
- T3: Slotted Actions (rotation) builder screen
- T4: Lock-in build flow wired to P2:M2 combat engine

### P2:M4 — Economy & Gear Loop
- T1: Gear generation from affix system (Basic/Master/Cursed tiers)
- T2: Tavern shop skeleton
- T3: Gold economy (earn/spend)
- T4: Equip/unequip wired into build resolution

### P2:M5 — Full Loop Integration (Vertical Slice)
- T1: Wire P2:M1–P2:M4 into one continuous loop (build → fight → reward → tavern → repeat)
- T2: Single boss encounter
- T3: End-to-end playtest pass, one class/one subclass-tree pair

### P2:M6 — Save/Load & Persistence
- T1: Run-state serialization
- T2: Save/load UI hooks (quit mid-run, relaunch, resume)
- T3: Meta-progression state persistence (if any exists by this point)

### P2:M7 — Playtest-Ready Build
- T1: Bug-fixing pass
- T2: Minimum UI legibility polish
- T3: Exported build (Windows desktop min., web bonus)
- T4: External playtest feedback loop

## Notes

Protocol for this file: the `Status` column in the Milestone List is the
single source of truth for whether a milestone is done. It's updated in the
same commit that satisfies a milestone's last exit criterion — not as a
separate later pass. Exceptions or caveats worth remembering go here as dated
notes; this section is not a running restatement of overall progress.

- P2:M0: the "empty Godot project runs" exit criterion required manual
  confirmation after Godot 4.7 was installed (this machine had no Godot
  install during the milestone's initial file scaffolding). Confirmed via the
  editor successfully opening and resaving `project/project.godot`.

Task-level breakdown above is a first pass for all milestones — not yet
Step-level detail. P2:M1 onward may shift once P2:M0/P2:M1 reveal real Godot
constraints, per working agreement 1 (milestone boundaries are hard, so
later milestones won't be pre-built regardless).
