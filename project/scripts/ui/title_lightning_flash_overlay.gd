class_name TitleLightningFlashOverlay
extends Control

const FLASH_WAIT_MIN_SEC := 4.5
const FLASH_WAIT_MAX_SEC := 9.5
const FIRST_FLASH_WAIT_MIN_SEC := 0.8
const FIRST_FLASH_WAIT_MAX_SEC := 1.8
const FLASH_PULSE_MIN := 2
const FLASH_PULSE_MAX := 4
const BOLT_OFFSET := Vector2(0.10, 0.0)
const BOLT_SCALE := 0.86
const BOLT_POINTS := [
	Vector2(0.285, 0.095),
	Vector2(0.305, 0.132),
	Vector2(0.292, 0.162),
	Vector2(0.316, 0.195),
	Vector2(0.315, 0.255),
]
const LEFT_BRANCH := [
	Vector2(0.304, 0.132),
	Vector2(0.258, 0.120),
	Vector2(0.215, 0.146),
	Vector2(0.185, 0.134),
]
const RIGHT_BRANCH := [
	Vector2(0.303, 0.132),
	Vector2(0.365, 0.135),
	Vector2(0.412, 0.167),
	Vector2(0.462, 0.153),
]
const LOWER_BRANCH := [
	Vector2(0.292, 0.162),
	Vector2(0.262, 0.202),
	Vector2(0.231, 0.217),
]

var background_rect: TextureRect
var _flash_strength := 0.0
var _branch_jitter := 0.0
var _first_flash_pending := true
var _rng := RandomNumberGenerator.new()


func bind_background(rect: TextureRect) -> void:
	background_rect = rect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	_rng.randomize()
	_run_flash_loop()


func _draw() -> void:
	if _flash_strength <= 0.01:
		return
	var image_rect := _displayed_background_rect()
	if image_rect.size.x <= 0.0 or image_rect.size.y <= 0.0:
		return
	_draw_cloud_glow(image_rect)
	_draw_bolt_path(image_rect, BOLT_POINTS, 2.5, 1.0)
	_draw_bolt_path(image_rect, LEFT_BRANCH, 1.5, 0.62)
	_draw_bolt_path(image_rect, RIGHT_BRANCH, 1.5, 0.54)
	_draw_bolt_path(image_rect, LOWER_BRANCH, 1.0, 0.46)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.86, 0.82, 1.0, 0.055 * _flash_strength), true)


func _run_flash_loop() -> void:
	while is_inside_tree():
		var wait_min := FIRST_FLASH_WAIT_MIN_SEC if _first_flash_pending else FLASH_WAIT_MIN_SEC
		var wait_max := FIRST_FLASH_WAIT_MAX_SEC if _first_flash_pending else FLASH_WAIT_MAX_SEC
		_first_flash_pending = false
		await get_tree().create_timer(_rng.randf_range(wait_min, wait_max)).timeout
		if not is_inside_tree():
			return
		var pulses := _rng.randi_range(FLASH_PULSE_MIN, FLASH_PULSE_MAX)
		for index in range(pulses):
			_branch_jitter = _rng.randf_range(-1.0, 1.0)
			await _flash_once(0.85 + _rng.randf_range(0.0, 0.15), 0.13 + _rng.randf_range(0.0, 0.06))
			if not is_inside_tree():
				return
			if index < pulses - 1:
				await get_tree().create_timer(_rng.randf_range(0.04, 0.11)).timeout


func _flash_once(peak: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_method(_set_flash_strength, 0.0, peak, duration * 0.22)
	tween.tween_method(_set_flash_strength, peak, 0.0, duration * 0.78)
	await tween.finished


func _set_flash_strength(value: float) -> void:
	_flash_strength = value
	queue_redraw()


func _displayed_background_rect() -> Rect2:
	if background_rect == null or background_rect.texture == null:
		return Rect2(Vector2.ZERO, size)
	var texture_size := background_rect.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Rect2(Vector2.ZERO, size)
	var scale := maxf(size.x / texture_size.x, size.y / texture_size.y)
	var drawn_size := texture_size * scale
	return Rect2((size - drawn_size) * 0.5, drawn_size)


func _image_point(image_rect: Rect2, normalized: Vector2) -> Vector2:
	var jitter := Vector2(_branch_jitter * 5.0, -_branch_jitter * 2.0)
	var anchor := Vector2(0.315, 0.165)
	var adjusted := anchor + (normalized - anchor) * BOLT_SCALE + BOLT_OFFSET
	return image_rect.position + Vector2(image_rect.size.x * adjusted.x, image_rect.size.y * adjusted.y) + jitter


func _draw_cloud_glow(image_rect: Rect2) -> void:
	var centers := [
		Vector2(0.268, 0.150),
		Vector2(0.315, 0.142),
		Vector2(0.366, 0.158),
	]
	for index in range(centers.size()):
		var center := _image_point(image_rect, centers[index])
		var radius := image_rect.size.x * (0.043 + float(index) * 0.009)
		draw_circle(center, radius, Color(0.42, 0.32, 0.75, 0.18 * _flash_strength))
		draw_circle(center, radius * 0.46, Color(0.86, 0.80, 1.0, 0.14 * _flash_strength))


func _draw_bolt_path(image_rect: Rect2, points: Array, width: float, strength_scale: float) -> void:
	var outer := Color(0.54, 0.39, 0.95, 0.42 * _flash_strength * strength_scale)
	var inner := Color(0.93, 0.88, 1.0, 0.92 * _flash_strength * strength_scale)
	for index in range(points.size() - 1):
		var start := _image_point(image_rect, points[index])
		var end := _image_point(image_rect, points[index + 1])
		draw_line(start, end, outer, width + 4.0)
		draw_line(start, end, inner, width)
