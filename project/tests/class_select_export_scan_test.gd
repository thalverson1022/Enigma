extends SceneTree
## Regression for exported builds: Godot exposes remapped resources through
## `.tres.remap` filenames during directory listing, but the original `.tres`
## path is still the loadable resource path.


func _initialize() -> void:
	var scene: PackedScene = load("res://scenes/class_select/class_select.tscn")
	var class_select = scene.instantiate()
	root.add_child(class_select)
	await process_frame

	var rogue_button_found := false
	var disabled_count := 0
	for button in class_select.find_children("*", "Button", true, false):
		if button.text == "Select" and not button.disabled:
			rogue_button_found = true
		elif button.disabled:
			disabled_count += 1

	print("real selectable class found (expect true): %s" % rogue_button_found)
	print("disabled coming-soon class buttons (expect 2): %d" % disabled_count)
	assert(rogue_button_found)
	assert(disabled_count == 2)

	var export_file_name := "rogue.tres.remap"
	var resource_file_name: String = class_select._resource_file_name_from_dir_entry(export_file_name)
	print("resource file from exported remap (expect rogue.tres): %s" % resource_file_name)
	assert(resource_file_name == "rogue.tres")
	assert(class_select._is_resource_dir_entry(export_file_name))
	assert(class_select._is_resource_dir_entry("rogue.tres"))
	assert(not class_select._is_resource_dir_entry("rogue.tres.import"))

	print("class select export scan check: OK")
	quit()
