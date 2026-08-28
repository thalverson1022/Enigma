# DawnBringer Enemy Lab

Enemy Lab is a lightweight dev-only browser tool for curating static enemy
sprites from the generated contract presentation names.

Open `index.html` in a browser, choose enemy type, biome, and name, then copy
the ChatGPT prompt. After generating transparent pixel-art candidates, import
the PNGs into Enemy Lab, pick one, preview the runtime-style damage flash, and
export a normalized 32x32 transparent PNG plus matching metadata JSON.

The damage animation is intended to be implemented in Godot with a
Sprite2D/material/modulate flash and a tiny impact offset. Enemy Lab can also
export an optional white mask PNG if a later Godot shader/material workflow
wants one.

The exported path hint matches the intended future in-project asset location:

`project/assets/generated/enemies/{biome}/{type}/{enemy_name}.png`
