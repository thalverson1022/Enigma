class_name CombatPopupLayer
extends Control
## Comic-book skill-popup subsystem: spawns, tweens, and retires the floating
## damage/crit/poison-tick/proc text over the combat stage. Extracted from
## combat_screen.gd's inline playback/VFX layer
## (docs/Phase_3_Technical_Debt_Architecture_Cleanup.md Phase 4) -- fully
## self-contained (no BuildState/autoload dependency), so it's a plain
## global-class script rather than a scene, matching GearCompareButton's
## precedent. combat_screen.gd instantiates it directly via
## CombatPopupLayer.new() and adds it as a child of the combat window, same
## as the bare Control it replaces.
##
## Two pieces of state the presenter still owns are threaded in rather than
## duplicated here: `skip_active` (Skip suppresses new spawns -- decided by
## the resolved playback's skip state, not by this layer) and
## `wyvern_tick_font_active` (Wyvern Kriss's smaller poison-tick text is an
## equipped-gear check, not a popup-layer concern).
##
## NOTE: `training_room_combat_view.gd` has its own separate, parallel popup
## implementation (own POPUP_* constants, own spawn logic) that this
## extraction does not touch -- discovered during this Phase 4 pass but out
## of scope for it. Worth unifying onto this shared class later; see the
## tech-debt doc.

enum Kind { NORMAL, CRIT, POISON_TICK, PROC }

## Popup lifetime from spawn to fully faded/freed.
const POPUP_DURATION_SEC := 1.35
## Comic-book popup font (Pirata One reads as a heavy action word; swap for
## MedievalSharp-Regular.ttf here if it lands better in real play).
const POPUP_FONT := preload("res://assets/fonts/PirataOne-Regular.ttf")
## How far a popup floats upward over its lifetime.
const POPUP_RISE_PX := 68.0
## Gentle lift duration; avoids damage text feeling launched from the target.
const POPUP_RISE_SEC := 1.05
## Poison ticks drift more slowly so they read as damage-over-time.
const POPUP_TICK_RISE_SEC := 1.5
## Fade starts after this long, so the word is readable before it dissolves.
const POPUP_FADE_DELAY_SEC := 0.45
## Horizontal/vertical random jitter around the spawn point so rapid casts
## don't stack into one unreadable pile.
const POPUP_JITTER_X_PX := 120.0
const POPUP_JITTER_Y_PX := 34.0
## Vertical spawn anchor as a fraction of the combat panel's height.
const POPUP_BASE_Y_FRACTION := 0.55
## Popups never spawn above this y -- keeps the enemy HUD strip clear.
const POPUP_TOP_MARGIN_PX := 96.0
## Font sizes per popup kind.
const POPUP_FONT_SIZE := 52
const POPUP_CRIT_FONT_SIZE := 68
const POPUP_TICK_FONT_SIZE := 26
const POPUP_WYVERN_TICK_FONT_SIZE := 20
const POPUP_PROC_FONT_SIZE := 56
const POPUP_POISON_TICK_JITTER_X_PX := 34.0
const POPUP_POISON_TICK_JITTER_Y_PX := 16.0
## Crit punch-scale: the label spawns at this scale and snaps to 1.0.
const POPUP_CRIT_PUNCH_SCALE := 1.35
const POPUP_CRIT_PUNCH_SEC := 0.12
## Simultaneous popup caps so long fights don't flood the panel -- poison
## ticks (1/second, low-stakes) get a tighter cap of their own.
const POPUP_MAX_ACTIVE := 10
const POPUP_MAX_TICK_ACTIVE := 3
## Popup colors per kind, all from UIColors: normal cast, crit (gold, per
## the agreed design), poison tick (low-key green), proc (flashy magic
## purple for Opportunity Strikes / Mithril Karambit triggers).
const POPUP_NORMAL_COLOR := UIColors.TEXT_NORMAL
const POPUP_CRIT_COLOR := UIColors.TEXT_GOLD
const POPUP_TICK_COLOR := UIColors.TEXT_POISON
const POPUP_PROC_COLOR := UIColors.TEXT_MAGIC

## Set true while a Skip flush is in progress -- suppresses new spawns so a
## skip doesn't spray the whole remaining timeline's popups at once.
var skip_active: bool = false
## Wyvern Kriss's identity is faster/smaller poison ticks -- the presenter
## sets this from an equipped-gear check at fight start.
var wyvern_tick_font_active: bool = false

var _combat_stage
var _rng := RandomNumberGenerator.new()
var _generation := 0
var _active_count := 0
var _active_tick_count := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


## Optional anchor source for poison-tick popups, which spawn near the enemy
## rather than at the panel's general popup anchor.
func set_combat_stage(stage) -> void:
	_combat_stage = stage


## Resets popup bookkeeping for a fresh fight.
func reset_for_new_fight() -> void:
	_active_count = 0
	_active_tick_count = 0
	_generation += 1
	_rng.randomize()


## Bumped by reset_for_new_fight() and skip_generation(). The presenter reads
## this to detect a stale delayed popup spawn: a popup scheduled with a delay
## (a triggered-skill follow-up hit beat) that's still pending when a new
## fight starts or a skip flush happens should be dropped, not spawned late
## into the wrong fight/moment.
func generation() -> int:
	return _generation


## Bumps generation without resetting active counts -- used when Skip starts
## a flush, so any already-scheduled delayed popup drops itself (see
## generation()) without needing to also reset the max-active bookkeeping
## Skip's own suppression (skip_active) already handles.
func skip_generation() -> void:
	_generation += 1


func spawn(text: String, kind: int) -> void:
	if skip_active:
		return
	if _active_count >= POPUP_MAX_ACTIVE:
		return
	if kind == Kind.POISON_TICK and _active_tick_count >= POPUP_MAX_TICK_ACTIVE:
		return
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", POPUP_FONT)
	var font_size := POPUP_FONT_SIZE
	var color := POPUP_NORMAL_COLOR
	match kind:
		Kind.CRIT:
			font_size = POPUP_CRIT_FONT_SIZE
			color = POPUP_CRIT_COLOR
		Kind.POISON_TICK:
			font_size = _poison_tick_font_size()
			color = POPUP_TICK_COLOR
		Kind.PROC:
			font_size = POPUP_PROC_FONT_SIZE
			color = POPUP_PROC_COLOR
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	label.reset_size()
	label.pivot_offset = label.size * 0.5
	var spawn_position := _spawn_position(kind, label.size)
	var spawn_x := spawn_position.x
	var spawn_y := spawn_position.y
	label.position = Vector2(spawn_x, spawn_y)
	_active_count += 1
	if kind == Kind.POISON_TICK:
		_active_tick_count += 1
	var tween := label.create_tween()
	tween.set_parallel(true)
	if kind == Kind.CRIT:
		label.scale = Vector2.ONE * POPUP_CRIT_PUNCH_SCALE
		tween.tween_property(label, "scale", Vector2.ONE, POPUP_CRIT_PUNCH_SEC)
	else:
		label.scale = Vector2.ONE * 0.92
		tween.tween_property(label, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var rise_sec := POPUP_TICK_RISE_SEC if kind == Kind.POISON_TICK else POPUP_RISE_SEC
	tween.tween_property(label, "position:y", spawn_y - POPUP_RISE_PX, rise_sec).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, POPUP_DURATION_SEC - POPUP_FADE_DELAY_SEC).set_delay(POPUP_FADE_DELAY_SEC)
	tween.finished.connect(_on_popup_finished.bind(label, kind))


func _spawn_position(kind: int, label_size: Vector2) -> Vector2:
	if kind == Kind.POISON_TICK and _combat_stage != null:
		var enemy_local: Vector2 = get_global_transform().affine_inverse() * _combat_stage.enemy_popup_global_position()
		return Vector2(
			enemy_local.x - label_size.x * 0.5 + _rng.randf_range(-POPUP_POISON_TICK_JITTER_X_PX, POPUP_POISON_TICK_JITTER_X_PX),
			maxf(enemy_local.y - label_size.y * 0.5 + _rng.randf_range(-POPUP_POISON_TICK_JITTER_Y_PX, POPUP_POISON_TICK_JITTER_Y_PX), POPUP_TOP_MARGIN_PX)
		)
	return Vector2(
		_popup_area_size().x * 0.5 - label_size.x * 0.5 + _rng.randf_range(-POPUP_JITTER_X_PX, POPUP_JITTER_X_PX),
		maxf(_popup_area_size().y * POPUP_BASE_Y_FRACTION + _rng.randf_range(-POPUP_JITTER_Y_PX, POPUP_JITTER_Y_PX), POPUP_TOP_MARGIN_PX)
	)


func _popup_area_size() -> Vector2:
	if _combat_stage != null and _combat_stage.has_method("play_area_global_rect"):
		return _combat_stage.play_area_global_rect().size
	return size


func _on_popup_finished(label: Label, kind: int) -> void:
	_active_count = maxi(_active_count - 1, 0)
	if kind == Kind.POISON_TICK:
		_active_tick_count = maxi(_active_tick_count - 1, 0)
	label.queue_free()


func _poison_tick_font_size() -> int:
	return POPUP_WYVERN_TICK_FONT_SIZE if wyvern_tick_font_active else POPUP_TICK_FONT_SIZE
