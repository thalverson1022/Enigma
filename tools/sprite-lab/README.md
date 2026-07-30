# Sprite Lab

Sprite Lab is a client-only web tool for cutting sprite sheets, testing animations, and exporting Godot-friendly assets.

Open `index.html` in a browser to use it. No install step is required.

## First-pass workflow

1. Import or drag in a sprite sheet.
2. Use grid slicing or alpha detection to create frame boxes.
3. Select, move, resize, duplicate, or delete frames.
4. Ctrl-click or Shift-click frames to select several, then unify size, pivot, position, duration, or rename them with a numbered prefix.
5. Set each frame pivot/origin and duration.
6. Create named animations and add frames to the timeline.
7. Preview the animation against a floor line, using the playback speed slider to slow down timing checks.
8. Export a ZIP containing origin-normalized PNG frames used by animation timelines, `sprite_lab_manifest.json`, and a starter Godot import script.

## Notes

- Grid slicing is the most predictable path for uniform sheets.
- Alpha detection treats connected non-transparent pixels as sprite regions and can be tuned with alpha threshold, minimum area, and padding.
- Importing another sheet opens it in a new tab. Each tab keeps its own frames, animations, selection, and undo history.
- Use Ctrl+Z / Ctrl+Y for undo and redo.
- On the canvas, drag a frame by its small numbered tab. Drag the lower or right edge to resize it.
- Export includes only frames that have been added to one or more animation timelines.
- Exported PNGs are padded to a shared canvas so each selected pivot lands at the center of the texture, which works well with Godot's default centered `AnimatedSprite2D` drawing.
- The exported JSON is intentionally plain so a Godot editor plugin or custom importer can consume it without depending on a browser-specific format.
