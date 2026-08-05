@tool
extends EditorScript

# Usage:
# 1. Copy an exported Sprite Lab folder into your Godot project.
# 2. Open this script in Godot and run it from the script editor.
# 3. It creates a SpriteFrames resource next to sprite_lab_manifest.json.

func _run() -> void:
	var manifest_path := "res://sprite_lab_manifest.json"
	if not FileAccess.file_exists(manifest_path):
		push_error("Place sprite_lab_manifest.json at the project root or adjust manifest_path.")
		return
	var manifest := JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if typeof(manifest) != TYPE_DICTIONARY:
		push_error("Sprite Lab manifest could not be parsed.")
		return
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")
	var frame_lookup := {}
	for frame in manifest.get("frames", []):
		var texture := load("res://" + frame["file"])
		if texture:
			frame_lookup[frame["name"]] = texture
	for animation in manifest.get("animations", []):
		var anim_name := animation["name"]
		sprite_frames.add_animation(anim_name)
		var speed := float(animation.get("fps", 8))
		sprite_frames.set_animation_speed(anim_name, speed)
		sprite_frames.set_animation_loop(anim_name, bool(animation.get("loop", true)))
		for step in animation.get("frames", []):
			var texture = frame_lookup.get(step["frame"])
			if texture:
				var duration_ms := float(step.get("duration_ms", 1000.0 / speed))
				var duration_ratio := duration_ms / (1000.0 / speed)
				sprite_frames.add_frame(anim_name, texture, max(0.01, duration_ratio))
	ResourceSaver.save(sprite_frames, "res://sprite_lab_spriteframes.tres")
