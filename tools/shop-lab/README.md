# Shop Lab

Shop Lab is a client-only browser tool for testing CrystalMaiden shop gear generation and reroll feel.

Open `index.html` in a browser to use it. No install step is required.

## Current Scope

- Uses the current Rogue gear slots: weapon, trinket, and charm.
- Uses the current gear tiers: Basic, Master, Cursed, and Legendary.
- Preserves the current generated gear structure:
  - Basic: one positive affix.
  - Master: two positive affixes.
  - Cursed: one amplified positive affix, one Master positive affix, and one downside.
  - Legendary: authored Legendary weapon pool.
- Uses the requested reroll rule: each reroll costs `+5g` more than the previous reroll.
- Exposes sliders for item type odds, slot odds, and affix odds.
- Tracks current gold, rerolls, gold spent, amazing items seen, and the best item seen.
- Includes a 1,000-shop quick simulation for rough tuning feedback.

## Notes

This is intentionally separate from the Godot project code. Treat it as a tuning and feel lab before the later expanded gear system is formalized.
