# Project DawnBringer Onboarding Context

## Purpose

Read this first when planning Phase 4. It is the compact handoff from Project
CrystalMaiden, not a full history. Use the copied Phase 3 closeout and
technical-debt docs only when more detail is needed.

## Project Identity

Phase naming follows Dota 2 heroes by first letter:

- Phase 1: Project Abaddon, React alpha/prototype.
- Phase 2: Project Bane, Godot 4.x rebuild of the Rogue adventure loop.
- Phase 3: Project CrystalMaiden, polish/juice/usability/export closeout.
- Phase 4: Project DawnBringer, next phase to plan.

Phase 3 active repo was:

- Workspace: `F:\Data\Claude Projects\Project-CrystalMaiden`
- Godot project: `F:\Data\Claude Projects\Project-CrystalMaiden\project`
- Branch: `phase-3-crystalmaiden`
- Remote: `https://github.com/thalverson1022/Bane.git`
- Latest pushed Phase 3 fix: `6c4477b Fix web audio unlock for itch build`

## Phase 3 Final State

Project CrystalMaiden is complete. It closed with a browser-playable Godot Web
export for itch.io, focused regression checks, Balance Lab validation, and a
web-audio unlock fix after live itch testing showed muted audio.

Playable focus remains the Rogue Adventure:

1. Title.
2. Adventure mode.
3. Rogue class and subclass choice.
4. Tavern encounter ladder.
5. Rewards, shop, gear, talents, and rotation decisions.
6. The Gilded Serpent contract offer.
7. Secondary subclass choice.
8. Contract route choices.
9. Knives Legendary reward.
10. Vyra climax.
11. Contract victory, failure, or restart state.

Practice Room is also important. It supports isolated Rogue build testing,
talents, rotation editing, rarity-first gear editing, Legendary selection,
target controls, animated combat playback, recap, and Combat Log review without
mutating Adventure state.

## What Phase 3 Added

- Combat playback juice: clearer cast timing, hit/crit/poison/proc feedback,
  persistent enemy state reads, victory/defeat beats, sprite mappings, icons,
  and playback controls.
- Combat recap/failure clarity: shared recap model, Combat Log inspector,
  readable structured logs, result overlays, retry/restart clarity, and
  Practice Room result invalidation.
- Build/rotation UX: 10-slot Skill Build cap/count, stable lock lane, empty
  rotation guardrails, selected/disabled/talent dependency feedback, and shared
  build language.
- Shop/inventory UX: shop-phase buying, selling, equipping, unequipping,
  rerolling with scaling cost, buy-to-inventory clarity, and full-inventory
  reward blocking.
- Adventure flow polish: reusable flow language, select-then-commit patterns,
  title/entry cleanup, reward/shop/build/talent handoff cleanup, terminal state
  clarity, route commit copy, and Rogue death-animation defeat beat.
- Practice Room finish pass: learning-oriented framing, target floor/scale
  alignment, and audit-confirmed setup/playback/log parity.
- Balance Lab hardening: local `tools/balance-lab` app, dependency-free Node
  bridge, report rendering, CrystalMaiden metadata, repeatability checks, and
  context-rich mechanics diagnostics.
- Audio/polish sweep: Earth & Iron UI chrome, shared settings/audio menu,
  Master/Music/Effects volumes, menu/Tavern/contract ambience, attack/button/
  shop SFX, blocked-action feedback pulse, and subtle Tavern/contract motion.
- Export closeout: Godot Web export preset, export-only icon loading fixes,
  static audio bus layout, and web audio unlock on first in-game gesture.

## Verification Baseline

Use Godot 4.7 on this machine:

`F:\Applications\Godot\Godot_v4.7-stable_win64_console.exe`

Latest Phase 3 confidence results:

- Focused regression passed for settings/audio, class select/export scan,
  combat screen/HUD/recap/playback, reward/shop/route/contract flow, save/load
  UI, failure/outcome presentation, build panels, rotation geometry, and
  Practice Room surfaces.
- `combat_playback_test.gd` and `export_shadow_probe.gd` have known restricted
  sandbox/user-data caveats, but passed outside that restriction.
- Balance Lab final pass: `19 pass, 0 warn, 0 fail`.
- `balance_lab_test.gd` passed.
- Web export loaded locally with title `Project CrystalMaiden`, Godot canvas
  present, and no fresh console errors before upload.

Known non-blocking Godot output:

- Windows root-certificate-store warning.
- ObjectDB/RID/resource cleanup warnings at exit.

Run Balance Lab when Phase 4 touches combat timing, event ordering, build
resolution, skill/talent/gear resources, enemy data, or balance-relevant data.

## Itch/Web Export Notes

Final generated artifact path in CrystalMaiden:

`project/export/web/project-crystalmaiden-itch.zip`

Export artifacts are ignored by Git. The itch page used for playtest was:

`https://eigenv3ctor.itch.io/peak-deeps`

The first live upload ran, but audio was muted because web audio started before
a Godot-canvas gesture. Phase 3 fixed this in source by queueing requested
ambience until click/key/touch and adding `project/default_bus_layout.tres`
with `Master`, `Music`, and `Effects`.

## Phase 4 Planning Direction

Phase 3 deliberately deferred deeper systems work. Phase 4 should decide which
of these becomes the main spine:

- Contract/town-map redesign: more open-world-feeling structure, procedural or
  authored contract expansion, better route/node data, and less reliance on the
  current linear Gilded Serpent scaffold.
- Buildcraft/mechanics expansion: new skills, talents, Legendary effects,
  enemy profiles, and clearer counterplay.
- Balance pacing: use Balance Lab as the gate for DPS checks, duration tuning,
  poison/proc behavior, rewards, and route pressure.
- Production presentation: broader art/audio direction, final UI assets,
  backgrounds, portraits, animations, and replaceable sourced audio.

Useful Phase 3 deferred technical triggers:

- Move route-node stage positions from hardcoded map logic onto authored
  `ContractRouteNode` data when a second contract starts.
- Move Tavern/contract flavor text from monster display-name matching to IDs.
- Decide save-version policy before a version bump.
- Decide a general Legendary visual-effect pattern before adding a third
  Legendary-specific effect.
- Consider unifying Adventure and Practice Room popup implementations.

## Working Agreements To Preserve

- Start implementation phases/milestones with Task 0 planning.
- Keep docs current, but keep onboarding compact.
- Prefer conservative, scoped Godot changes that match existing patterns.
- Preserve deterministic combat behavior unless a task explicitly changes
  mechanics.
- Do not over-generalize before the second real use case exists.
- Commit one logical risky extraction or system change at a time.

## Copied Reference Docs

- `P3M9_Regression_Export_And_Phase_3_Closeout.md`: final verification, export,
  itch.io, and closeout record.
- `P3_Technical_Debt_Architecture_Cleanup.md`: completed architecture cleanup,
  remaining deferred refactor triggers, and Godot/GDScript gotchas.
