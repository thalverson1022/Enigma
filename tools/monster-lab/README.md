# Monster Lab

Monster Lab is a client-only browser tool for building, tuning, and previewing DawnBringer monsters.

Open `index.html` in a browser to use it. No install step is required.

Validate the data vocabulary and export units with:

```powershell
node tools\monster-lab\validate.js
```

## Current Scope

- Combines two monster archetypes into a generated monster candidate.
- Lets you save, edit, delete, and reuse archetypes from a local catalog.
- Lets custom archetypes opt into mechanics from the available mechanic list.
- Lets each custom archetype tune mechanic weight, low/high value range, and difficulty scaling profile.
- Lets each archetype define tags, unlock difficulty, allowed monster kinds, and route weight.
- Imports and exports the full archetype catalog as JSON for backup and later runtime generation work.
- Uses a pressure-based difficulty model so HP, duration, mechanics, and mechanic synergies can be reviewed together.
- Uses the canonical P4M1 `Monster` defense vocabulary: armor, dodge, crit negation, block, resistance, absorb, cleanse, suppress, slow, stun, and interrupt.
- Supports deterministic generation from a visible seed.
- Separates difficulty from fight tempo: difficulty owns target DPS and defense
  budget, while tempo owns the duration range used to derive HP.
- Stages generator settings until `Generate Batch` is pressed, so changing
  controls does not silently replace the current candidate queue.
- Provides manual bespoke tuning for HP and selected mechanic values.
- Shows structural notices for export readiness, runtime-preview mechanics,
  prototype pressure drift, readability load, and over-budget candidates.
- Shows heuristic difficulty signals for poison, burst, and sustained-DPS build pressure.
- Imports a single monster sprite image for local preview.
- Previews lightweight procedural motion presets: idle bob, breathing scale, heavy sway, hit jiggle, flash jiggle, armor hit, and poison pulse.
- Exports a monster JSON payload with mechanics, balance model, presentation metadata, and Godot-ready `monster_overrides`.
- Converts exported monster JSON into Balance Lab scenario catalogs.

## Workflow

1. Open `tools/monster-lab/index.html`.
2. Import a library or click `New` in the Build Archetype column.
3. Pick Archetype A and optional Archetype B.
4. Use Secondary Scale to decide how strongly Archetype B contributes.
5. Pick a difficulty band, tempo profile, monster kind, and batch size.
6. Click `Generate Batch` to create or replace the Candidate Queue.
7. Review raw HP, effective HP, duration, target DPS, required DPS, budget usage, pressure cards, and structural notices.
8. Use Selected Monster tuning to adjust HP and selected mechanic values.
9. Optionally import a single sprite image and tune scale, floor offset, idle motion, and hit reaction.
10. Copy or download the exported JSON.
11. Convert selected monster exports into Balance Lab scenario catalogs when a
    Godot-backed check is needed.

## Tempo Profiles

Difficulty controls the monster's target DPS range, defense budget, mechanic
count, major-defense limit, and acceptable DPS tolerance. Tempo controls the
fight-window range. Monster Lab rolls a duration, rolls a target DPS value for
the selected band, then derives raw HP from:

```text
raw HP ~= target DPS * duration / estimated defense multiplier
```

Archetype HP Bias and Monster Kind can bend the result so frail or heavy
identities still exist. The final model then checks effective HP against the
rolled duration:

```text
required DPS = effective HP / duration
```

The pressure cards show whether the candidate is inside the selected target
window, slightly under or over it, or clearly out of band.

- `Burst`: 11-16 second window.
- `Standard`: 18-24 second window.
- `Extended`: 26-34 second window.
- `Endurance`: 38-52 second window.

Monster Kind can still apply its normal duration modifier after the tempo
profile is selected.

## Archetype Builder

Use the Build Archetype column to:

- Choose an existing archetype.
- Enter the archetype name.
- Set HP Bias.
- Set tags, unlock difficulty, route weight, and allowed monster kinds.
- Enable mechanics from the available list.
- Set each enabled mechanic's weight, low value, high value, and scaling profile.
- Mark mechanics as required when they should always appear.

## Archetype Library Import/Export

`Import Library` appears at the start of the Build Archetype column. It replaces
the current local archetype library with a compatible JSON library before you
begin editing. Imported libraries can carry a `library_name`, which is restored
into the Library Name field.

Monster Lab starts with an empty working library. It does not automatically load
the built-in archetype data or the last imported file; import the desired JSON
library when beginning a test session.

`Export Library` appears at the end of the Build Archetype column. It downloads
the current local archetype library using the Library Name field as the JSON
filename. This lets multiple test libraries coexist, such as
`early_game_monsters.json` and `poison_counter_monsters.json`. The export also
stores that name as `library_name` inside the JSON payload.

Monster Lab includes a `Monster_Libraries` folder next to `index.html` as the
recommended central place for saved test libraries. Browsers that support the
File System Access API will prompt for a save location when exporting, so choose
that folder when you want the library stored with the tool. Browsers without
that API will fall back to the normal downloads folder.

The checked-in starter library is:

- `Monster_Libraries/dawnbringer_archetypes_v1.json`

The library export includes mechanic configs plus the generation metadata needed
by future runtime import work:

- `tags`: gameplay/design identifiers such as `fortified` or `physical_check`.
- `unlock_difficulty`: first difficulty tier where the archetype can appear.
- `allowed_kinds`: monster roles that can use the archetype.
- `route_weight`: relative generation weight for route construction.

The Generator dropdowns still hide archetypes that are locked for the currently
selected difficulty or monster kind, while the Build Archetype editor can always
inspect and edit the whole library.

## Custom Scaling

Custom mechanic ranges are interpreted as the low-to-high base roll envelope for that archetype. Difficulty then applies the selected scaling multiplier after the base value is rolled:

- `Flat`: rolls inside the Low-High range at every difficulty and never scales above it.
- `Gentle`: rolls inside Low-High, then applies a small difficulty multiplier.
- `Standard`: rolls inside Low-High, then applies a larger linear difficulty multiplier.
- `Steep`: rolls inside Low-High, then applies an aggressive difficulty multiplier at Ultra/Nightmare.

For example, Armor with `Low 80`, `High 120`, and `Flat` can always roll
80-120. With `Steep`, Easy still rolls 80-120, but Nightmare rolls much higher
because the base roll is multiplied after selection. Inverted mechanics such as
Cleanse Threshold scale downward instead, because lower thresholds are harder.

If a generated monster combines two custom archetypes that both define the same mechanic, Monster Lab averages their ranges and uses the first custom scaling profile found for that mechanic.

## Design Notes

Monster Lab is intentionally separate from Sprite Lab and Balance Lab:

- Sprite Lab remains the tool for sprite sheets, frame slicing, and exported animation timelines.
- Monster Lab uses one image plus procedural motion so enemy ideas can be tested before production animation exists.
- Balance Lab remains the place for Godot-backed scenario verification. The
  file-based bridge can convert generated monsters into imported Balance Lab
  scenario catalogs.

## Balance Lab Bridge

T8 uses a file-based bridge instead of a local server. Export a Monster Lab
monster JSON, then convert it into a Balance Lab scenario catalog:

```powershell
node tools\monster-lab\export_to_balance_lab.js --input path\to\monster.json
```

By default, the converter writes to:

```text
project\data\balance_lab\imported\<monster_id>.balance_lab.json
```

Balance Lab automatically appends `.json` scenario catalogs from
`res://data/balance_lab/imported` when that folder exists. If the folder is
absent or empty, the authored Balance Lab suite is unchanged.

Each converted monster becomes three prototype probe scenarios:

- Physical Stab Probe.
- Shadow Poison Probe.
- Bandit Crit Probe.

The converted catalog preserves `monster.godot.monster_overrides`,
`duration_ms`, target DPS metadata, pressure status, validation notices, and
`matchup_preview` text. These probes validate the bridge; they are not final
balance tuning.

## Data Files

- `data/mechanics.js`: P4M1 mechanic definitions, Godot field mappings, value curves, cost weights, and build-pressure modifiers.
- `data/archetypes.js`: archetype mechanic weights, HP bias, tone, and name parts.
- `data/difficulty.js`: difficulty budgets, mechanic counts, major-defense guardrails, target DPS ranges, and DPS tolerance.

These files are JavaScript globals rather than JSON so the app can be opened through `file://` without a local server or fetch restrictions.

## Godot Export Vocabulary

Designer-facing percentage values are shown as whole numbers in the UI. Exported
Godot values are converted to runtime units:

- `poison_resistance`, `dodge_chance`, `crit_negation`, `suppress`, and `slow`
  export as `0.0` to `1.0` fractions.
- `armor`, `block`, `absorb`, `cleanse_threshold`, `stun_duration_ms`, and
  `interrupt_skip_count` export as direct numeric values.
- `stun_duration_ms` and `interrupt_skip_count` are marked preview-only until
  their runtime timing-disruption behavior is implemented.
- `stun_trigger_hit_percent` defines the large-hit threshold that triggers
  Stun.
- `interrupt_repeat_threshold` defines how many same-skill direct triggers in a
  row cause Interrupt.
