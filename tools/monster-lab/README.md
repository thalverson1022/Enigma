# Monster Lab

Monster Lab is a client-only browser tool for building, tuning, and previewing CrystalMaiden monsters.

Open `index.html` in a browser to use it. No install step is required.

## Current Scope

- Combines two monster archetypes into a generated monster candidate.
- Lets you define two custom archetypes with your own names.
- Lets custom archetypes opt into mechanics from the available mechanic list.
- Lets each custom archetype tune mechanic weight, low/high value range, and difficulty scaling profile.
- Uses a difficulty budget model so HP, mechanics, and mechanic synergies can be reviewed together.
- Starts with current mechanics, armor and resistance, plus future-facing placeholder mechanics for testing the archetype workflow.
- Supports deterministic generation from a visible seed.
- Provides manual bespoke tuning for HP and selected mechanic values.
- Flags risky combinations such as double mitigation, poison suppression, and over-budget candidates.
- Shows heuristic difficulty signals for poison, burst, and sustained-DPS build pressure.
- Imports a single monster sprite image for local preview.
- Previews lightweight procedural motion presets: idle bob, breathing scale, heavy sway, hit jiggle, flash jiggle, armor hit, and poison pulse.
- Exports a monster JSON payload with mechanics, balance model, and presentation metadata.

## Workflow

1. Open `tools/monster-lab/index.html`.
2. Pick Archetype A and Archetype B.
3. Use Archetype Builder if you want a custom archetype:
   - Choose `Custom A` or `Custom B`.
   - Enter the archetype name.
   - Set HP Bias.
   - Enable mechanics from the available list.
   - Set each enabled mechanic's weight, low value, high value, and scaling profile.
4. Pick a difficulty band and monster kind.
5. Click `Generate Monster`.
6. Review HP, effective HP, required DPS, budget usage, pressure cards, and warnings.
7. Use Bespoke Tuning to adjust HP and selected mechanic values.
8. Optionally import a single sprite image and tune scale, floor offset, idle motion, and hit reaction.
9. Copy or download the exported JSON.

## Custom Scaling

Custom mechanic ranges are interpreted as the low-to-high envelope for that archetype. Difficulty then decides which part of the envelope the generator samples from:

- `Flat`: samples across the full range at every difficulty.
- `Gentle`: moves toward the high end slowly.
- `Standard`: moves evenly through the range as difficulty rises.
- `Steep`: keeps low difficulties tame, then climbs harder at elite/boss difficulty.

If a generated monster combines two custom archetypes that both define the same mechanic, Monster Lab averages their ranges and uses the first custom scaling profile found for that mechanic.

## Design Notes

Monster Lab is intentionally separate from Sprite Lab and Balance Lab:

- Sprite Lab remains the tool for sprite sheets, frame slicing, and exported animation timelines.
- Monster Lab uses one image plus procedural motion so enemy ideas can be tested before production animation exists.
- Balance Lab remains the place for Godot-backed scenario verification. A later Monster Lab bridge can send generated monsters into Godot benchmark fights.

The future bridge should probably mirror Balance Lab's dependency-free Node pattern and add endpoints such as:

- `GET /api/status`
- `POST /api/evaluate-monster`
- `POST /api/export-monster`
- `GET /api/report/latest`

## Data Files

- `data/mechanics.js`: mechanic definitions, value curves, cost weights, and build-pressure modifiers.
- `data/archetypes.js`: archetype mechanic weights, HP bias, tone, and name parts.
- `data/difficulty.js`: difficulty budgets, HP bands, mechanic counts, fight duration, and target DPS.

These files are JavaScript globals rather than JSON so the app can be opened through `file://` without a local server or fetch restrictions.
