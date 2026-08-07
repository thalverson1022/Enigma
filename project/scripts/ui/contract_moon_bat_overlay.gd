class_name ContractMoonBatOverlay
extends Control

const FLIGHT_WAIT_MIN_SEC := 8.0
const FLIGHT_WAIT_MAX_SEC := 18.0
const FIRST_FLIGHT_WAIT_MIN_SEC := 2.5
const FIRST_FLIGHT_WAIT_MAX_SEC := 5.0
const FLIGHT_DURATION_MIN_SEC := 1.9
const FLIGHT_DURATION_MAX_SEC := 2.8
const MOON_PATH_START := Vector2(0.205, 0.130)
const MOON_PATH_END := Vector2(0.365, 0.112)
const BAT_SCALE := 0.010

var background_rect: TextureRect
var _flight_progress := -1.0
var _flight_direction := 1.0
var _flight_arc := 0.0
var _wing_phase := 0.0
var _first_flight_pending := true
var _rng := RandomNumberGenerator.new()


func bind_background(rect: TextureRect) -> void:
	background_rect = rect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	_rng.randomize()
	_run_flight_loop()


func _process(delta: float) -> void:
	if _flight_progress < 0.0:
		set_process(false)
		return
	_wing_phase += delta * 18.0
	queue_redraw()


func _draw() -> void:
	if _flight_progress < 0.0:
		return
	if background_rect == null or background_rect.texture == null:
		return
	var image_rect := _displayed_background_rect()
	if image_rect.size.x <= 0.0 or image_rect.size.y <= 0.0:
		return
	_draw_bat(image_rect)


func _run_flight_loop() -> void:
	while is_inside_tree():
		var wait_min := FIRST_FLIGHT_WAIT_MIN_SEC if _first_flight_pending else FLIGHT_WAIT_MIN_SEC
		var wait_max := FIRST_FLIGHT_WAIT_MAX_SEC if _first_flight_pending else FLIGHT_WAIT_MAX_SEC
		_first_flight_pending = false
		await get_tree().create_timer(_rng.randf_range(wait_min, wait_max)).timeout
		if not is_inside_tree():
			return
		await _fly_once()


func _fly_once() -> void:
	_flight_direction = 1.0 if _rng.randf() >= 0.5 else -1.0
	_flight_arc = _rng.randf_range(-0.012, 0.014)
	set_process(true)
	var tween := create_tween()
	tween.tween_method(_set_flight_progress, 0.0, 1.0, _rng.randf_range(FLIGHT_DURATION_MIN_SEC, FLIGHT_DURATION_MAX_SEC))
	await tween.finished
	_flight_progress = -1.0
	set_process(false)
	queue_redraw()


func _set_flight_progress(value: float) -> void:
	_flight_progress = value
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


func _draw_bat(image_rect: Rect2) -> void:
	var progress := clampf(_flight_progress, 0.0, 1.0)
	var path_progress := progress if _flight_direction > 0.0 else 1.0 - progress
	var normalized := MOON_PATH_START.lerp(MOON_PATH_END, path_progress)
	normalized.y += sin(progress * PI) * _flight_arc
	var center := _image_point(image_rect, normalized)
	var unit := image_rect.size.x * BAT_SCALE
	var wing_lift := sin(_wing_phase) * unit * 0.42
	var silhouette := Color(0.015, 0.012, 0.018, 0.90)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-unit * 0.22, 0.0),
		center + Vector2(-unit * 1.95, -unit * 0.42 - wing_lift),
		center + Vector2(-unit * 1.12, unit * 0.34 + wing_lift * 0.35),
		center + Vector2(-unit * 0.16, unit * 0.18),
	]), silhouette)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(unit * 0.22, 0.0),
		center + Vector2(unit * 1.95, -unit * 0.42 - wing_lift),
		center + Vector2(unit * 1.12, unit * 0.34 + wing_lift * 0.35),
		center + Vector2(unit * 0.16, unit * 0.18),
	]), silhouette)
	draw_circle(center, unit * 0.26, silhouette)
	draw_circle(center + Vector2(0, -unit * 0.16), unit * 0.18, silhouette)


func _image_point(image_rect: Rect2, normalized: Vector2) -> Vector2:
	return image_rect.position + Vector2(image_rect.size.x * normalized.x, image_rect.size.y * normalized.y)
