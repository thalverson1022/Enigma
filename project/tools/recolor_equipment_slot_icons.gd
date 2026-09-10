extends SceneTree

const SOURCE_ROOT := "F:/Data/Junk/DPS Game/Finished Game Assets/misc_icons/UI"
const OUTPUT_ROOT := "res://assets/ui/equipment_slots"

const FILES := {
	"equip_weapon.png": "slot_weapon.png",
	"equip_helm.png": "slot_helm.png",
	"equip_chest.png": "slot_armor.png",
	"equip_ring.png": "slot_trinket.png",
	"equip_neck.png": "slot_charm.png",
	"equip_empty.png": "slot_empty.png",
}

const SHADOW := Color("100C09")
const LOW := Color("4A3B2F")
const MID := Color("9A8E7B")
const HIGH := Color("C9A259")


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	for source_name in FILES.keys():
		var source_path := "%s/%s" % [SOURCE_ROOT, source_name]
		var image := Image.load_from_file(source_path)
		if image == null or image.is_empty():
			push_error("Could not load equipment slot icon: %s" % source_path)
			quit(1)
			return
		_recolor(image)
		var output_path := "%s/%s" % [OUTPUT_ROOT, FILES[source_name]]
		var error := image.save_png(output_path)
		if error != OK:
			push_error("Could not save equipment slot icon: %s, error %s" % [output_path, error])
			quit(1)
			return
	print("Recolored equipment slot icons: OK")
	quit(0)


func _recolor(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			if pixel.a <= 0.01:
				continue
			var luma := (pixel.r * 0.299) + (pixel.g * 0.587) + (pixel.b * 0.114)
			var target := SHADOW.lerp(LOW, minf(luma * 2.0, 1.0))
			if luma > 0.5:
				target = MID.lerp(HIGH, (luma - 0.5) * 2.0)
			target.a = pixel.a
			image.set_pixel(x, y, target)
