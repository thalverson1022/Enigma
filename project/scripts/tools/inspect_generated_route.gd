extends SceneTree
## Inspect a generated route without touching Adventure state.
## Run with:
##   godot --headless --path project -s res://scripts/tools/inspect_generated_route.gd -- --seed=4242 --difficulty=medium --biomes=Swamp,Cave

const GeneratedRouteInspectorScript := preload("res://scripts/tools/generated_route_inspector.gd")


func _initialize() -> void:
	var options := _parse_options(OS.get_cmdline_user_args())
	var seed := int(options.get("seed", 4242))
	var settings := {}
	if options.has("difficulty"):
		settings["route_difficulty"] = String(options["difficulty"])
	if options.has("biomes"):
		settings["allowed_biomes"] = String(options["biomes"]).split(",", false)

	var report: Dictionary = GeneratedRouteInspectorScript.inspect(seed, settings)
	if options.get("json", "false") == "true":
		print(JSON.stringify(report, "\t"))
	else:
		print(GeneratedRouteInspectorScript.format_text(report))
	quit()


func _parse_options(args: PackedStringArray) -> Dictionary:
	var options := {}
	for arg in args:
		var text := String(arg)
		if not text.begins_with("--"):
			continue
		var body := text.substr(2)
		var split_at := body.find("=")
		if split_at == -1:
			options[body] = "true"
		else:
			options[body.substr(0, split_at)] = body.substr(split_at + 1)
	return options
