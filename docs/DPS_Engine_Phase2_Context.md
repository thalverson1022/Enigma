# DPS Engine Roguelike — Phase 2 Context Document

**Audience:** This document is written for an AI coding agent (Claude Code) to
ingest as project context. It defines the game's design intent, the scope of
the current development phase, and the working agreements the agent should
follow. Treat this as the source of truth for scope and philosophy. If a
request conflicts with this document, flag the conflict rather than silently
resolving it.

**Phase numbering note:** The original MVP (built in React) is referred to as
**Phase 1** and is considered complete and validated. This document defines
**Phase 2**: the engine port and production of a genuine vertical slice.
Phase 2 deliberately does not reference Phase 1 implementation details — it
defines the target architecture and scope fresh, so the agent is not
anchored to prior compromises.

---

## 1. Game Vision (Design Context)

The game is a roguelike buildcraft and optimization game in which the player
constructs increasingly powerful damage engines through class synergies,
skill trees, gear, and combat rotations.

High-level description: **Balatro meets ARPG theorycrafting with
auto-battler combat.**

Core fantasy: the player becomes a master theorycrafter who discovers broken
builds by exploiting scaling engines and skill interactions.

Key design principle:

> The game is not about defeating monsters. The game is about discovering
> and optimizing damage engines. Monsters are the tests. The build is the
> game.

### 1.1 Combat Philosophy

Combat is **automated**, not player-executed. The player assembles a
rotation of skills before the fight (e.g. `Stab → Poison Strike →
Backstab`), locks in a build, and the combat engine resolves the fight
without further input. There are no twitch mechanics and no reaction
testing. Combat is a **test of the build**, not a test of player reflexes.

### 1.2 DPS Window System

Each encounter has a fixed combat duration ("DPS window") and a monster HP
pool. Skills have execution times, and attack-speed breakpoints can create
additional skill executions within the window — this is a primary
optimization lever.

Window length is a deliberate encounter-design variable:
- Short windows reward burst damage, fast setup, and finishers.
- Long windows reward damage-over-time stacking, armor reduction, and ramp
  payoffs.
- Different armor/resistance profiles are paired with different window
  lengths to create distinct rotation puzzles, so no single rotation is
  globally optimal.

Design north star:

> Encounters should pressure players to reconsider their Slotted Actions,
> not merely ask for larger numbers.

### 1.3 Discovery Philosophy

The game should reward discovering emergent interactions, not simply
increasing numbers. Example chain: Attack Speed → More Hits → More Poison →
More Gold Theft → More Finisher Damage. The target player experience is
"I didn't realize that interaction worked."

Legendary items should **alter gameplay**, not just add stats (e.g. "all
poisons ignore resistance and tick twice" rather than "+50% poison damage").

Bosses are **build examiners**: they test assumptions (high armor, high
dodge, slow DOT tick rate, max damage-per-hit caps) rather than hard-countering
specific builds.

### 1.4 Core Loop (target shape for Phase 2)

```
Choose Class
 -> Choose Starting Subclass Tree
 -> Assemble Slotted Actions (rotation)
 -> Lock Build
 -> Fight Monster (automated resolution)
 -> Claim Gold / Talent Point / Gear
 -> Visit Tavern (shop, gear, talents)
 -> Modify Build
 -> Fight Harder Monster
 -> Repeat, toward a Boss
```

### 1.5 Randomness Philosophy

- High variance: gear, shop offerings, opportunities.
- Moderate variance: skill tree combinations.
- Low variance: core class identity.

---

## 2. Phase 2 Definition

**Phase 2 goal:** Port the validated core loop into a real game engine and
production-quality codebase, producing a genuine **vertical slice** — one
class, one full subclass-tree pair, one boss, played start to finish with no
editor intervention — built on an architecture that can scale to the full
game's content volume without rework.

**Phase 2 is explicitly NOT:**
- A content-completion phase. Full class/tree/gear/boss rosters come later.
- A polish or marketing phase.
- A meta-progression / map / contract-run phase (that is Phase 3).
- A multiplayer, mobile, or platform-port phase.

**Definition of done for Phase 2:** A stranger can download a build, play a
complete run from character creation to a single boss fight, and give
feedback — without you present to explain anything.

### 2.1 Guiding Constraint: Avoid Scope Creep

Each milestone below has an explicit exit criterion. New feature ideas that
arise during development belong in a backlog file (`phase3_ideas.md` or
similar), not in the current milestone, unless they block that milestone's
exit criterion. When in doubt, the agent should ask whether a proposed
addition is required for the current milestone's exit criteria before
implementing it.

---

## 3. Technical Foundation

- **Engine:** Godot 4.x (GDScript). This is the current decision; if it
  changes, this document should be updated before further work proceeds.
- **Architecture principle (highest priority):** Game content — skills,
  gear, talents, monsters, legendaries — must be **data-driven**, not
  hardcoded. New content should be addable via data files (Godot
  `Resource` files, e.g. `.tres`) without writing new game-logic code.
  This is the single most important architectural decision in Phase 2 and
  should be treated as a hard constraint, not a nice-to-have.
- **Version control:** the project should be under git from the first
  commit of Phase 2.
- **Target platforms for the vertical slice:** Windows desktop export at
  minimum; web export is a bonus if low-effort.
- **Testing approach:** combat/DPS logic should be verifiable
  independently of UI (e.g. runnable/checkable from a script or headless
  test, not only by clicking through the game). Prefer this for M2.2 in
  particular.

---

## 4. Milestone Breakdown

Each milestone should be treated as a checkpoint: do not begin the next
milestone until the current one's exit criteria are met. Placeholder/dummy
content (one fake skill, one fake gear item, one fake monster) is
sufficient and preferred for early milestones — real content volume is a
Phase 2-later / Phase 3 concern once the milestone table below is complete.

### M2.0 — Project Foundation
**Objective:** Stand up the project shell.
**Scope:** Initialize Godot project, folder structure and naming
conventions, git repository, editor/tooling setup.
**Out of scope:** Any game logic.
**Exit criteria:** Empty Godot project runs, is under version control, and
has an agreed folder/naming convention documented.

### M2.1 — Data Architecture
**Objective:** Design and implement the data-driven content schema.
**Scope:** Resource definitions for Skills, Gear (with affix structure),
Talents, and Monsters. Validated with placeholder/dummy entries only.
**Out of scope:** Real content, UI, combat resolution logic.
**Exit criteria:** A new skill or gear item can be defined by creating a
data file, with zero code changes required.

### M2.2 — Core Combat Resolution
**Objective:** Port the DPS window / rotation engine.
**Scope:** Skill execution timing, attack-speed breakpoints, damage
calculation, fixed-duration combat window resolution, win/loss
determination against a target HP pool. Console/log output is sufficient —
no combat UI yet.
**Out of scope:** Any visual presentation of combat.
**Exit criteria:** A scripted rotation against a dummy monster produces
correct, independently-verifiable DPS numbers (spot-checkable by hand
math).

### M2.3 — Build Planning UI
**Objective:** Minimal functional UI for assembling a build.
**Scope:** Class/subclass selection screen, talent point allocation
screen, Slotted Actions (rotation) builder screen.
**Out of scope:** Visual polish, animation, art pass.
**Exit criteria:** A player can assemble a build using placeholder content
and lock it in, using only the UI (no editor/console).

### M2.4 — Economy & Gear Loop
**Objective:** Basic economy and gear systems.
**Scope:** Gear generation from the affix system (tier structure per the
design doc: Basic/Master/Cursed), tavern shop skeleton, gold economy,
equip/unequip.
**Out of scope:** Full gear content set, legendary items.
**Exit criteria:** Gold earned from a fight can be spent on gear that
measurably changes combat output in M2.2's resolution logic.

### M2.5 — Full Loop Integration (Vertical Slice)
**Objective:** Wire M2.1–M2.4 into one continuous playable loop.
**Scope:** Build → fight → reward → tavern → repeat, for one class and one
subclass-tree pair, ending in a single boss fight.
**Out of scope:** Content breadth — this milestone proves the
architecture, not the content volume.
**Exit criteria:** A complete run can be played start-to-finish through the
UI alone, with no editor intervention.

### M2.6 — Save/Load & Persistence
**Objective:** Persist state across sessions.
**Scope:** Run-state save/load; any meta-progression state if applicable.
**Exit criteria:** Quit mid-run, relaunch the game, and resume correctly.

### M2.7 — Playtest-Ready Build
**Objective:** Make the vertical slice shareable.
**Scope:** Bug-fixing pass, minimum UI legibility polish, exported build.
**Out of scope:** Full art/juice pass (that is a later phase).
**Exit criteria:** Someone who is not the developer can play a complete run
unassisted and provide useful feedback.

---

## 5. Domain Glossary

Terms the agent should treat as fixed vocabulary, not free to reinterpret:

- **Slotted Actions** — the player's chosen skill rotation for a fight.
- **DPS Window** — the fixed time duration of a combat encounter.
- **Breakpoint** — an attack-speed threshold that grants an additional
  skill execution within the DPS window.
- **Tavern** — the planning hub between fights (shop, gear, talents,
  rotation editing).
- **Talent Point** — a rare progression currency spent on subclass talent
  allocation; not derived from an XP/level system.
- **Subclass Tree** — a specialization path (e.g. Assassin, Thief, Shadow
  for the Rogue class) unlocking identity skills and talents.
- **Basic / Master / Cursed / Legendary Gear** — gear tiers, defined by
  number and nature of affixes (see Section 1 design doc references for
  exact rules when implementing M2.4).
- **Contract Run** — the Phase 3 meta-structure (route nodes, minions,
  elites, boss) — referenced here for context only; not in scope for
  Phase 2.

---

## 6. Working Agreements for the Agent

1. **Respect milestone boundaries.** Do not implement content or systems
   from a later milestone while working on an earlier one, even if it
   seems efficient to do "while you're in there."
2. **Data-driven by default.** If a task seems to require hardcoding a
   piece of game content (a specific skill's numbers, a specific gear
   item), stop and implement it as a data entry instead.
3. **Placeholder content is a feature, not a shortcut.** Use dummy/fake
   content for early milestones on purpose — it isolates architecture bugs
   from content bugs.
4. **Propose before large refactors.** If a change touches more than one
   milestone's worth of systems, describe the plan before executing it.
5. **Surface scope-creep candidates.** If an idea comes up that isn't
   required for the current milestone's exit criteria, note it for the
   backlog rather than building it.
6. **Prefer Godot 4.x idioms.** Use `CharacterBody2D`/current-generation
   APIs, not Godot 3.x patterns (e.g. not `KinematicBody2D`, not `yield`
   instead of `await`). Prefer signals over tight coupling between nodes.
7. **State exit-criteria status explicitly.** When a milestone's work
   appears complete, state which exit criteria are met and which, if any,
   are not yet verified.
