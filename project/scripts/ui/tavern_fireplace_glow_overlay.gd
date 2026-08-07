class_name TavernFireplaceGlowOverlay
extends Control

const FIRE_GLOW_CENTER := Vector2(0.205, 0.555)
const FIRE_BASE_CENTER := Vector2(0.205, 0.598)
const FIREBOX_HALF_SIZE := Vector2(0.055, 0.072)
const FLICKER_SPEED := 2.7
const FLAME_COUNT := 7
const EMBER_COUNT := 10

var background_rect: TextureRect
var _time := 0.0


func bind_background(rect: TextureRect) -> void:
	background_rect = rect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_process(true)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if background_rect == null or background_rect.texture == null:
		return
	var image_rect := _displayed_background_rect()
	if image_rect.size.x <= 0.0 or image_rect.size.y <= 0.0:
		return
	var flicker := 0.72 + 0.18 * sin(_time * FLICKER_SPEED) + 0.10 * sin(_time * 7.1)
	_draw_fire_glow(image_rect, flicker)
	_draw_flame_tongues(image_rect, flicker)
	_draw_embers(image_rect, flicker)


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
	return image_rect.position + Vector2(image_rect.size.x * normalized.x, image_rect.size.y * normalized.y)


func _draw_fire_glow(image_rect: Rect2, flicker: float) -> void:
	var center := _image_point(image_rect, FIRE_GLOW_CENTER)
	var radius := image_rect.size.x * 0.050
	draw_circle(center, radius * (0.95 + flicker * 0.10), Color(1.0, 0.36, 0.06, 0.16 * flicker))
	draw_circle(center + Vector2(0, image_rect.size.y * 0.010), radius * 0.58, Color(1.0, 0.63, 0.14, 0.18 * flicker))
	draw_circle(center - Vector2(0, image_rect.size.y * 0.022), radius * 0.28, Color(1.0, 0.84, 0.36, 0.16 * flicker))


func _draw_flame_tongues(image_rect: Rect2, flicker: float) -> void:
	for index in range(FLAME_COUNT):
		var slot := (float(index) / float(FLAME_COUNT - 1)) - 0.5
		var phase := _time * (3.0 + float(index) * 0.21) + float(index) * 1.7
		var sway := sin(phase) * image_rect.size.x * 0.004
		var base := _image_point(image_rect, FIRE_BASE_CENTER + Vector2(slot * FIREBOX_HALF_SIZE.x * 1.15, 0.0))
		var width := image_rect.size.x * (0.008 + 0.003 * _unit_wave(float(index) * 2.13))
		var height := image_rect.size.y * (0.034 + 0.030 * _unit_wave(phase)) * flicker
		var tip := base + Vector2(sway, -height)
		var color := Color(1.0, 0.34 + 0.10 * _unit_wave(phase), 0.04, 0.26)
		draw_colored_polygon(PackedVector2Array([
			base + Vector2(-width, 0),
			base + Vector2(width, 0),
			tip,
		]), color)
		if index % 2 == 0:
			draw_colored_polygon(PackedVector2Array([
				base + Vector2(-width * 0.45, -height * 0.10),
				base + Vector2(width * 0.40, -height * 0.08),
				tip + Vector2(-sway * 0.30, height * 0.24),
			]), Color(1.0, 0.76, 0.22, 0.23))


func _draw_embers(image_rect: Rect2, flicker: float) -> void:
	for index in range(EMBER_COUNT):
		var phase := _time * (0.46 + float(index) * 0.035) + float(index) * 0.31
		var rise := fposmod(phase, 1.0)
		var x_wave := sin(_time * 1.8 + float(index) * 2.4)
		var local := Vector2(
			(sin(float(index) * 4.9) * 0.5 + x_wave * 0.16) * FIREBOX_HALF_SIZE.x,
			-FIREBOX_HALF_SIZE.y * rise
		)
		var point := _image_point(image_rect, FIRE_BASE_CENTER + local)
		var alpha := (1.0 - rise) * 0.22 * flicker
		var radius := image_rect.size.x * (0.0016 + 0.0008 * _unit_wave(float(index)))
		draw_circle(point, radius, Color(1.0, 0.62, 0.18, alpha))


func _unit_wave(value: float) -> float:
	return 0.5 + 0.5 * sin(value)
