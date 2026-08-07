class_name CombatStage
extends Control
## Shared presentation-only combat stage for Adventure and Practice Room.
## It defines stable actor/effect/status anchors so later sprite animation
## work has a physical layer to target without touching combat resolution.

class DebugGridOverlay:
	extends Control

	var combat_stage

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void:
		if combat_stage == null:
			return
		var stage_size: Vector2 = size
		if stage_size.x <= 0.0 or stage_size.y <= 0.0:
			return

		var grid_color := Color(0.45, 0.85, 1.0, 0.22)
		var axis_color := Color(0.45, 0.85, 1.0, 0.55)
		for index in 11:
			var x := stage_size.x * float(index) / 10.0
			var y := stage_size.y * float(index) / 10.0
			var is_axis := index == 5
			draw_line(Vector2(x, 0.0), Vector2(x, stage_size.y), axis_color if is_axis else grid_color, 2.0 if is_axis else 1.0)
			draw_line(Vector2(0.0, y), Vector2(stage_size.x, y), axis_color if is_axis else grid_color, 2.0 if is_axis else 1.0)

		_draw_marker(combat_stage._stage_point_for_grid(combat_stage.PLAYER_STAGE_GRID), Color(0.35, 1.0, 0.45, 0.9), 9.0)
		_draw_marker(combat_stage._stage_point_for_grid(combat_stage.ENEMY_STAGE_GRID), Color(1.0, 0.35, 0.35, 0.9), 9.0)
		_draw_sprite_frame(combat_stage.player_actor_anchor, combat_stage._player_sprite)
		_draw_sprite_frame(combat_stage.enemy_actor_anchor, combat_stage._enemy_sprite)
		_draw_marker(combat_stage._sprite_anchor_point(combat_stage.player_actor_anchor, combat_stage._player_sprite, combat_stage._player_current_anchor_point), Color(1.0, 1.0, 0.25, 0.95), 5.0)
		_draw_marker(combat_stage._sprite_anchor_point(combat_stage.enemy_actor_anchor, combat_stage._enemy_sprite, combat_stage.PEASANT_ANCHOR_POINT), Color(1.0, 1.0, 0.25, 0.95), 5.0)

	func _draw_marker(point: Vector2, color: Color, radius: float) -> void:
		draw_circle(point, radius, color)
		draw_line(point + Vector2(-radius * 1.8, 0.0), point + Vector2(radius * 1.8, 0.0), color, 2.0)
		draw_line(point + Vector2(0.0, -radius * 1.8), point + Vector2(0.0, radius * 1.8), color, 2.0)

	func _draw_sprite_frame(anchor: Control, sprite: TextureRect) -> void:
		if anchor == null or sprite == null or not sprite.visible:
			return
		var frame_rect := Rect2(anchor.position + combat_stage._sprite_render_top_left(sprite), sprite.size * sprite.scale)
		draw_rect(frame_rect, Color(1.0, 0.0, 0.0, 0.9), false, 2.0)


class ContactShadow:
	extends Control

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var radius := size.x * 0.5
		if radius <= 0.0:
			return
		draw_set_transform(size * 0.5, 0.0, Vector2(1.0, 0.32))
		for index in 5:
			var progress := float(index) / 4.0
			var layer_radius := lerpf(radius, radius * 0.36, progress)
			var alpha := lerpf(0.04, 0.22, progress)
			draw_circle(Vector2.ZERO, layer_radius, Color(0.0, 0.0, 0.0, alpha), true, -1.0, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


const ACTOR_SIZE := Vector2(160, 148)
const ACTOR_LOCAL_ANCHOR := Vector2(80, 140)
const CONTACT_SIZE := Vector2(96, 96)
const STATUS_SIZE := Vector2(150, 42)
const ROGUE_FRAME_SIZE := Vector2i(48, 48)
const PEASANT_FRAME_SIZE := Vector2i(32, 32)
const ROGUE_VISIBLE_BOUNDS := Rect2(Vector2(15, 9), Vector2(22, 28))
const PEASANT_VISIBLE_BOUNDS := Rect2(Vector2(7, 11), Vector2(17, 21))
const ROGUE_ANCHOR_POINT := Vector2(24, 24)
const PEASANT_ANCHOR_POINT := Vector2(16, 16)
const ROGUE_SPRITE_SCALE := 4.0
const PEASANT_SPRITE_SCALE := 5.0
const PRACTICE_DUMMY_SPRITE_SCALE := 4.15
const PRACTICE_DUMMY_ANCHOR_POINT := Vector2(16, 32)
const PRACTICE_DUMMY_STAGE_GRID := Vector2(0.62, 1.0)
const PRACTICE_DUMMY_STAGE_OFFSET := Vector2(38.0, 0.0)
const PRACTICE_ROGUE_SPRITE_OFFSET := Vector2(0.0, -28.0)
const PRACTICE_DUMMY_SPRITE_OFFSET := Vector2(0.0, 88.0)
const PRACTICE_DUMMY_SHADOW_OFFSET := Vector2(0.0, -16.0)
const PLAYER_VISUAL_KEY := "rogue"
const MOUTHY_DRUNK_VISUAL_KEY := "mouthy_drunk"
const DRUNK_BUDDY_VISUAL_KEY := "drunk_buddy"
const TAVERN_BOUNCER_VISUAL_KEY := "tavern_bouncer"
const HIRED_GOON_VISUAL_KEY := "hired_goon"
const VYRA_VISUAL_KEY := "vyra"
const KNIVES_VISUAL_KEY := "knives"
const PRACTICE_DUMMY_VISUAL_KEY := "practice_dummy"
const ANIMATION_PHYSICAL := "physical"
const ANIMATION_POISON := "poison"
const ANIMATION_TICK := "poison_tick"
const OUTCOME_VICTORY := "victory"
const OUTCOME_DEFEAT := "defeat"
const LUNGE_DISTANCE_PX := 34.0
const RECOIL_DISTANCE_PX := 18.0
const STAGE_GRID_MIN := -5.0
const STAGE_GRID_MAX := 5.0
const STAGE_GRID_MARGIN_PX := 12.0
const PLAYER_STAGE_GRID := Vector2(-1.0, 2.0)
const ENEMY_STAGE_GRID := Vector2(1.0, 1.0)
const ACTOR_GROUP_STAGE_OFFSET_PX := Vector2(38.0, 0.0)
const CONTACT_SHADOW_MIN_SIZE := Vector2(54.0, 18.0)
const CONTACT_SHADOW_WIDTH_SCALE := 1.24
const MIN_CAST_ANIMATION_SEC := 0.18
const MAX_CAST_ANIMATION_SEC := 0.42
const TRIGGERED_FOLLOWUP_ANIMATION_SEC := 0.18
const TICK_PULSE_SEC := 0.22
const POISON_VISIBLE_STACK_CAP := 5
const OUTCOME_POSE_SEC := 0.24
const OUTCOME_FLASH_SEC := 0.18
const FIGHT_INTRO_SEC := 0.42
const FIGHT_INTRO_PLAYER_OFFSET := Vector2(-18.0, 0.0)
const FIGHT_INTRO_ENEMY_OFFSET := Vector2(18.0, 0.0)
const BANDIT_BLADE_ID := "gear.legendary.bandit_blade"
const BANDIT_COIN_TEXTURE := preload("res://assets/Items/Rogue/Lucky_Coin.png")
const BANDIT_COIN_NORMAL_COUNT := 3
const BANDIT_COIN_CRIT_COUNT := 5
const BANDIT_COIN_SIZE_RANGE := Vector2(8.0, 13.0)
const BANDIT_COIN_LIFETIME_SEC := 0.48
const BANDIT_COIN_FADE_DELAY_SEC := 0.1
const BANDIT_COIN_START_ALPHA := 0.82
const BANDIT_COIN_SPRITE_CONTACT_OFFSET := Vector2(-10.0, -12.0)
const BANDIT_COIN_FALLBACK_IMPACT_OFFSET := Vector2(80.0, 82.0)
const BANDIT_COIN_SPREAD_X_RANGE := Vector2(-34.0, 20.0)
const BANDIT_COIN_SPREAD_Y_RANGE := Vector2(-38.0, 14.0)
const PLAYER_ANIMATION_MANIFEST_PATHS := {
	"idle": "res://assets/placeholder_combat_sprites/rogue_bandit/animations/idle/animation_manifest.json",
	"attack_physical": "res://assets/placeholder_combat_sprites/rogue_bandit/animations/attack1/animation_manifest.json",
	"attack_poison": "res://assets/placeholder_combat_sprites/rogue_bandit/animations/attack2/animation_manifest.json",
	"hurt": "res://assets/placeholder_combat_sprites/rogue_bandit/animations/idle/animation_manifest.json",
	"defeat": "res://assets/placeholder_combat_sprites/rogue_bandit/animations/death/animation_manifest.json",
}
const ENEMY_ANIMATION_PATHS := {
	PRACTICE_DUMMY_VISUAL_KEY: {
		"idle": "res://assets/characters/practice_dummy/dummy_bounce/frames/frame_001.png",
		"hurt": "res://assets/characters/practice_dummy/dummy_bounce/frames/frame_001.png",
		"defeat": "res://assets/characters/practice_dummy/dummy_bounce/frames/frame_001.png",
	},
	MOUTHY_DRUNK_VISUAL_KEY: {
		"idle": "res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png",
		"hurt": "res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png",
		"defeat": "res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png",
	},
	DRUNK_BUDDY_VISUAL_KEY: {
		"idle": "res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png",
		"hurt": "res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png",
		"defeat": "res://assets/placeholder_combat_sprites/townsfolk/peasants_sprite_sheet.png",
	},
	TAVERN_BOUNCER_VISUAL_KEY: {
		"idle": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_sprite_sheet.png",
		"hurt": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_sprite_sheet.png",
		"defeat": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_sprite_sheet.png",
	},
	HIRED_GOON_VISUAL_KEY: {
		"idle": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_2_sprite_sheet.png",
		"hurt": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_2_sprite_sheet.png",
		"defeat": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_2_sprite_sheet.png",
	},
	VYRA_VISUAL_KEY: {
		"idle": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_3_sprite_sheet.png",
		"hurt": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_3_sprite_sheet.png",
		"defeat": "res://assets/placeholder_combat_sprites/townsfolk/medieval_townsfolk_3_sprite_sheet.png",
	},
	KNIVES_VISUAL_KEY: {
		"idle": "res://assets/placeholder_combat_sprites/townsfolk/medieval_thief_sprite_sheet.png",
		"hurt": "res://assets/placeholder_combat_sprites/townsfolk/medieval_thief_sprite_sheet.png",
		"defeat": "res://assets/placeholder_combat_sprites/townsfolk/medieval_thief_sprite_sheet.png",
	},
}
const ENEMY_ANIMATION_REGIONS := {
	PRACTICE_DUMMY_VISUAL_KEY: {
		"idle": Rect2(Vector2(0, 0), Vector2(32, 32)),
		"hurt": Rect2(Vector2(0, 0), Vector2(32, 32)),
		"defeat": Rect2(Vector2(0, 0), Vector2(32, 32)),
	},
	MOUTHY_DRUNK_VISUAL_KEY: {
		"idle": Rect2(Vector2(0, 0), Vector2(32, 32)),
		"hurt": Rect2(Vector2(0, 64), Vector2(32, 32)),
		"defeat": Rect2(Vector2(0, 96), Vector2(32, 32)),
	},
	DRUNK_BUDDY_VISUAL_KEY: {
		"idle": Rect2(Vector2(0, 256), Vector2(32, 32)),
		"hurt": Rect2(Vector2(0, 320), Vector2(32, 32)),
		"defeat": Rect2(Vector2(0, 352), Vector2(32, 32)),
	},
	TAVERN_BOUNCER_VISUAL_KEY: {
		"idle": Rect2(Vector2(0, 320), Vector2(32, 32)),
		"hurt": Rect2(Vector2(0, 384), Vector2(32, 32)),
		"defeat": Rect2(Vector2(0, 448), Vector2(32, 32)),
	},
	HIRED_GOON_VISUAL_KEY: {
		"idle": Rect2(Vector2(0, 320), Vector2(32, 32)),
		"hurt": Rect2(Vector2(0, 384), Vector2(32, 32)),
		"defeat": Rect2(Vector2(0, 448), Vector2(32, 32)),
	},
	VYRA_VISUAL_KEY: {
		"idle": Rect2(Vector2(0, 320), Vector2(32, 32)),
		"hurt": Rect2(Vector2(0, 384), Vector2(32, 32)),
		"defeat": Rect2(Vector2(0, 448), Vector2(32, 32)),
	},
	KNIVES_VISUAL_KEY: {
		"idle": Rect2(Vector2(0, 0), Vector2(32, 32)),
		"hurt": Rect2(Vector2(0, 160), Vector2(32, 32)),
		"defeat": Rect2(Vector2(0, 224), Vector2(32, 32)),
	},
}
const ENEMY_VISUAL_KEYS_BY_NAME := {
	"Mouthy Drunk": MOUTHY_DRUNK_VISUAL_KEY,
	"Drunk Buddy": DRUNK_BUDDY_VISUAL_KEY,
	"Tavern Bouncer": TAVERN_BOUNCER_VISUAL_KEY,
	"Hired Goon": HIRED_GOON_VISUAL_KEY,
	"Door Guard": HIRED_GOON_VISUAL_KEY,
	"Cloaked Watchmen": HIRED_GOON_VISUAL_KEY,
	"Armored Guard": HIRED_GOON_VISUAL_KEY,
	"Sleeping Henchman": HIRED_GOON_VISUAL_KEY,
	"Portly Cook": HIRED_GOON_VISUAL_KEY,
	"Patrolling Guard": HIRED_GOON_VISUAL_KEY,
	"Lazy Henchman": HIRED_GOON_VISUAL_KEY,
	"Venom-Resistant Slime": HIRED_GOON_VISUAL_KEY,
	"Training Dummy": HIRED_GOON_VISUAL_KEY,
	"Placeholder Dummy": HIRED_GOON_VISUAL_KEY,
	"Vyra": VYRA_VISUAL_KEY,
	"Knives": KNIVES_VISUAL_KEY,
	"Practice Target": PRACTICE_DUMMY_VISUAL_KEY,
}
const PRACTICE_DUMMY_REACTION_FRAME_PATHS := [
	[
		"res://assets/characters/practice_dummy/dummy_bounce/frames/frame_001.png",
		"res://assets/characters/practice_dummy/dummy_bounce/frames/frame_002.png",
		"res://assets/characters/practice_dummy/dummy_bounce/frames/frame_003.png",
		"res://assets/characters/practice_dummy/dummy_bounce/frames/frame_004.png",
	],
	[
		"res://assets/characters/practice_dummy/dummy_knock/frames/frame_009.png",
		"res://assets/characters/practice_dummy/dummy_knock/frames/frame_010.png",
		"res://assets/characters/practice_dummy/dummy_knock/frames/frame_012.png",
		"res://assets/characters/practice_dummy/dummy_knock/frames/frame_013.png",
	],
	[
		"res://assets/characters/practice_dummy/dummy_spin/frames/frame_017.png",
		"res://assets/characters/practice_dummy/dummy_spin/frames/frame_018.png",
		"res://assets/characters/practice_dummy/dummy_spin/frames/frame_019.png",
		"res://assets/characters/practice_dummy/dummy_spin/frames/frame_020.png",
		"res://assets/characters/practice_dummy/dummy_spin/frames/frame_021.png",
		"res://assets/characters/practice_dummy/dummy_spin/frames/frame_022.png",
		"res://assets/characters/practice_dummy/dummy_spin/frames/frame_023.png",
	],
]
const PRACTICE_DUMMY_REACTION_FRAME_SEC := 0.075

var safe_top_px := 96.0
var safe_bottom_px := 36.0
var actor_names_visible := true:
	set(value):
		actor_names_visible = value
		_apply_actor_name_visibility()
var reserved_bottom_px := 0.0:
	set(value):
		reserved_bottom_px = maxf(value, 0.0)
		_layout_stage()

var player_actor_anchor: Control
var enemy_actor_anchor: Control
var contact_effect_anchor: Control
var floating_text_anchor: Control
var player_status_anchor: Control
var enemy_status_anchor: Control

var _player_name_label: Label
var _enemy_name_label: Label
var _player_actor_card: PanelContainer
var _enemy_actor_card: PanelContainer
var _player_sprite: TextureRect
var _enemy_sprite: TextureRect
var _player_contact_shadow: ContactShadow
var _enemy_contact_shadow: ContactShadow
var _debug_grid_overlay: DebugGridOverlay
var _player_animation_cache := {}
var _player_animation_key := ""
var _player_animation_frame_index := 0
var _player_animation_elapsed := 0.0
var _player_animation_frame_sec := 0.125
var _player_animation_loop := false
var _player_animation_playing := false
var _player_current_visible_bounds := ROGUE_VISIBLE_BOUNDS
var _player_current_anchor_point := ROGUE_ANCHOR_POINT
var _player_visual_key := PLAYER_VISUAL_KEY
var _enemy_visual_key := ""
var _player_base_position := Vector2.ZERO
var _enemy_base_position := Vector2.ZERO
var _player_tween: Tween
var _enemy_tween: Tween
var _outcome_flash: ColorRect
var _effect_rng := RandomNumberGenerator.new()
var _effect_generation := 0
var bandit_blade_effect_active := false

var last_cast_animation_kind := ""
var last_cast_min_cast_proc_was_timing_event := false
var last_enemy_recoil_delay_sec := 0.0
var contact_feedback_count := 0
var last_contact_feedback_was_crit := false
var last_contact_feedback_delay_sec := 0.0
var last_cast_contact_delay_sec := 0.0
var last_cast_triggered_followup_count := 0
var last_cast_windup_duration_sec := 0.0
var last_cast_animation_start_delay_sec := 0.0
var cast_windup_count := 0
var cast_impact_count := 0
var fight_intro_count := 0
var last_fight_intro_duration_sec := 0.0
var cast_animation_count := 0
var poison_tick_pulse_count := 0
var poison_stack_tint_updates := 0
var last_poison_stack_tint_stacks := 0
var outcome_pose := ""
var outcome_flash_count := 0
var last_outcome_flash_was_victory := false
var last_player_animation_key := ""
var last_player_animation_frame_count := 0
var last_player_animation_frame_path := ""
var bandit_coin_spray_count := 0
var last_bandit_coin_count := 0
var practice_dummy_reaction_count := 0
var last_practice_dummy_reaction_index := -1
var last_practice_dummy_reaction_frame_count := 0
var debug_grid_visible := false:
	set(value):
		debug_grid_visible = value
		if _debug_grid_overlay != null:
			_debug_grid_overlay.visible = value
			_debug_grid_overlay.queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	set_process(false)
	_effect_rng.randomize()
	_build_stage()
	_layout_stage()


func _process(delta: float) -> void:
	if not _player_animation_playing:
		set_process(false)
		return
	_player_animation_elapsed += delta
	if _player_animation_elapsed < _player_animation_frame_sec:
		return
	_player_animation_elapsed = 0.0
	_player_animation_frame_index += 1
	var animation: Dictionary = _player_animation_cache.get(_player_animation_key, {})
	var frames: Array = animation.get("frames", [])
	if frames.is_empty():
		_player_animation_playing = false
		set_process(false)
		return
	if _player_animation_frame_index >= frames.size():
		if _player_animation_loop:
			_player_animation_frame_index = 0
		else:
			if _player_animation_key == "defeat":
				_player_animation_frame_index = frames.size() - 1
				_apply_player_animation_frame()
				_player_animation_playing = false
				set_process(false)
				return
			_set_player_animation("idle", true)
			return
	_apply_player_animation_frame()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_stage()


func configure(player_name: String, enemy_name: String) -> void:
	if player_actor_anchor != null:
		player_actor_anchor.visible = true
	if enemy_actor_anchor != null:
		enemy_actor_anchor.visible = true
	if _player_name_label != null:
		_player_name_label.text = player_name
	if _enemy_name_label != null:
		_enemy_name_label.text = enemy_name
	_apply_actor_name_visibility()
	_player_visual_key = PLAYER_VISUAL_KEY
	_enemy_visual_key = _enemy_visual_key_for(enemy_name)
	_set_player_animation("idle", true)
	_apply_enemy_visual("idle")
	_clear_status_visuals()


func clear_target() -> void:
	_kill_actor_tweens()
	_clear_status_visuals()
	outcome_pose = ""
	if player_actor_anchor != null:
		player_actor_anchor.visible = false
	if enemy_actor_anchor != null:
		enemy_actor_anchor.visible = false
	if _player_actor_card != null:
		_player_actor_card.visible = false
	if _enemy_actor_card != null:
		_enemy_actor_card.visible = false
	if _player_contact_shadow != null:
		_player_contact_shadow.visible = false
	if _enemy_contact_shadow != null:
		_enemy_contact_shadow.visible = false


func reset_state() -> void:
	_kill_actor_tweens()
	_effect_generation += 1
	_clear_bandit_coin_particles()
	modulate = Color.WHITE
	if _outcome_flash != null:
		_outcome_flash.color.a = 0.0
	last_cast_animation_kind = ""
	last_cast_min_cast_proc_was_timing_event = false
	last_enemy_recoil_delay_sec = 0.0
	contact_feedback_count = 0
	last_contact_feedback_was_crit = false
	last_contact_feedback_delay_sec = 0.0
	last_cast_contact_delay_sec = 0.0
	last_cast_triggered_followup_count = 0
	last_cast_windup_duration_sec = 0.0
	last_cast_animation_start_delay_sec = 0.0
	cast_windup_count = 0
	cast_impact_count = 0
	fight_intro_count = 0
	last_fight_intro_duration_sec = 0.0
	cast_animation_count = 0
	poison_tick_pulse_count = 0
	poison_stack_tint_updates = 0
	last_poison_stack_tint_stacks = 0
	outcome_pose = ""
	outcome_flash_count = 0
	last_outcome_flash_was_victory = false
	last_player_animation_key = ""
	last_player_animation_frame_count = 0
	last_player_animation_frame_path = ""
	bandit_coin_spray_count = 0
	last_bandit_coin_count = 0
	practice_dummy_reaction_count = 0
	last_practice_dummy_reaction_index = -1
	last_practice_dummy_reaction_frame_count = 0
	_set_player_animation("idle", true)
	_apply_enemy_visual("idle")
	_restore_actor_layout()


func play_fight_intro(animate: bool = true) -> float:
	fight_intro_count += 1
	last_fight_intro_duration_sec = FIGHT_INTRO_SEC
	_kill_actor_tweens()
	_set_player_animation("idle", true)
	_set_enemy_animation("idle")
	_restore_actor_layout()
	if not animate:
		return 0.0
	if _is_practice_dummy_target():
		return FIGHT_INTRO_SEC
	player_actor_anchor.position = _player_base_position + FIGHT_INTRO_PLAYER_OFFSET
	enemy_actor_anchor.position = _enemy_base_position + FIGHT_INTRO_ENEMY_OFFSET
	player_actor_anchor.modulate = Color(1.0, 1.0, 1.0, 0.72)
	enemy_actor_anchor.modulate = Color(1.0, 1.0, 1.0, 0.72)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(player_actor_anchor, "position", _player_base_position, FIGHT_INTRO_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(enemy_actor_anchor, "position", _enemy_base_position, FIGHT_INTRO_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(player_actor_anchor, "modulate", Color.WHITE, FIGHT_INTRO_SEC)
	tween.tween_property(enemy_actor_anchor, "modulate", Color.WHITE, FIGHT_INTRO_SEC)
	_player_tween = tween
	_enemy_tween = tween
	return FIGHT_INTRO_SEC


func restore_practice_idle_pose() -> void:
	_kill_actor_tweens()
	_set_player_animation("idle", true)
	_set_enemy_animation("idle")
	_restore_actor_layout()
	outcome_pose = ""


func play_cast_presentation(cast: CombatResolver.CastEvent, playback_speed: float = 1.0, animate: bool = true) -> float:
	var contact_delay := play_cast_windup(cast, playback_speed, animate)
	if not animate:
		return 0.0
	var impact_delay := contact_delay
	var tween := create_tween()
	tween.tween_interval(contact_delay)
	tween.tween_callback(func(): play_cast_impact(cast, true))
	return impact_delay + _triggered_followup_contact_delay(cast)


func play_cast_windup(cast: CombatResolver.CastEvent, playback_speed: float = 1.0, animate: bool = true) -> float:
	last_cast_animation_kind = animation_kind_for_cast(cast)
	last_cast_min_cast_proc_was_timing_event = cast != null and cast.min_cast_time_proc_applied
	last_cast_triggered_followup_count = cast.triggered_skill_names.size() if cast != null else 0
	cast_animation_count += 1
	cast_windup_count += 1
	var animation_key := _player_animation_key_for_kind(last_cast_animation_kind)
	var windup_sec := _cast_windup_duration_sec(cast, playback_speed)
	var timing := _windup_animation_timing(cast, animation_key, windup_sec)
	var start_delay: float = timing["start_delay"]
	var duration: float = timing["duration"]
	var contact_sec: float = timing["contact"]
	last_cast_windup_duration_sec = windup_sec
	last_cast_animation_start_delay_sec = start_delay
	last_cast_contact_delay_sec = windup_sec
	if not animate:
		_set_player_animation(last_cast_animation_kind, false, duration)
		return 0.0
	var lunge_target := _player_base_position + Vector2(LUNGE_DISTANCE_PX, 0.0)
	var recovery_sec := duration - contact_sec
	var previous_player_tween := _player_tween
	var animation_kind := last_cast_animation_kind
	var windup_tween := create_tween()
	_player_tween = windup_tween
	if start_delay > 0.0:
		windup_tween.tween_interval(start_delay)
	windup_tween.tween_callback(func():
		if previous_player_tween != null and previous_player_tween.is_valid():
			previous_player_tween.kill()
		_set_player_animation(animation_kind, true, duration)
	)
	windup_tween.tween_property(player_actor_anchor, "position", lunge_target, contact_sec).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	windup_tween.tween_property(player_actor_anchor, "position", _player_base_position, recovery_sec).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	windup_tween.tween_callback(func(): _set_player_animation("idle", true))
	return windup_sec


func play_cast_impact(cast: CombatResolver.CastEvent, animate: bool = true) -> float:
	cast_impact_count += 1
	if cast == null:
		return 0.0
	if not animate:
		return 0.0
	if cast.physical_damage > 0.0 or cast.poison_stacks_applied > 0:
		_play_enemy_recoil(0.0, cast.is_crit)
	if bandit_blade_effect_active and cast.physical_damage > 0.0:
		_play_bandit_coin_spray(0.0, cast.is_crit)
	if cast != null and not cast.triggered_skill_names.is_empty():
		_play_triggered_followup(animation_kind_for_cast(cast))
		return _triggered_followup_contact_delay(cast)
	return 0.0


func _cast_windup_duration_sec(cast: CombatResolver.CastEvent, playback_speed: float) -> float:
	if cast == null:
		return 0.0
	var cast_ms := maxi(cast.time_ms - cast.cast_start_ms, 0)
	return float(cast_ms) / 1000.0 / maxf(playback_speed, 0.001)


func _windup_animation_timing(cast: CombatResolver.CastEvent, animation_key: String, windup_sec: float) -> Dictionary:
	var natural_duration := _presentation_duration_for_cast(cast, 1.0, animation_key)
	var natural_contact := _contact_delay_for_cast(cast, animation_key, natural_duration, false)
	if windup_sec <= 0.0 or natural_contact <= 0.0:
		return {
			"start_delay": 0.0,
			"duration": maxf(natural_duration, MIN_CAST_ANIMATION_SEC),
			"contact": 0.0,
		}
	if windup_sec >= natural_contact:
		return {
			"start_delay": windup_sec - natural_contact,
			"duration": natural_duration,
			"contact": natural_contact,
		}
	var scale := windup_sec / natural_contact
	return {
		"start_delay": 0.0,
		"duration": maxf(natural_duration * scale, MIN_CAST_ANIMATION_SEC),
		"contact": windup_sec,
	}


func _triggered_followup_contact_delay(cast: CombatResolver.CastEvent) -> float:
	if cast == null or cast.triggered_skill_names.is_empty():
		return 0.0
	return TRIGGERED_FOLLOWUP_ANIMATION_SEC * 0.45


func _play_triggered_followup(animation_kind: String) -> void:
	_kill_player_tween()
	var lunge_target := _player_base_position + Vector2(LUNGE_DISTANCE_PX, 0.0)
	var followup_contact_sec := TRIGGERED_FOLLOWUP_ANIMATION_SEC * 0.45
	var followup_recovery_sec := TRIGGERED_FOLLOWUP_ANIMATION_SEC - followup_contact_sec
	_player_tween = create_tween()
	_player_tween.tween_callback(func(): _set_player_animation(animation_kind, true, TRIGGERED_FOLLOWUP_ANIMATION_SEC))
	_player_tween.tween_property(player_actor_anchor, "position", lunge_target, followup_contact_sec).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_player_tween.tween_property(player_actor_anchor, "position", _player_base_position, followup_recovery_sec).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_player_tween.tween_callback(func(): _set_player_animation("idle", true))


func set_bandit_blade_effect_active(active: bool) -> void:
	bandit_blade_effect_active = active


func play_poison_tick_pulse(animate: bool = true) -> void:
	poison_tick_pulse_count += 1
	if not animate:
		return
	_kill_enemy_tween()
	_enemy_tween = create_tween()
	_enemy_tween.tween_property(enemy_actor_anchor, "modulate", UIColors.COMBAT_POISON_TICK_FLASH, TICK_PULSE_SEC * 0.5)
	_enemy_tween.tween_property(enemy_actor_anchor, "modulate", _enemy_poison_modulate(), TICK_PULSE_SEC * 0.5)


func set_poison_stacks(stacks: int, _animate: bool = true) -> void:
	poison_stack_tint_updates += 1
	last_poison_stack_tint_stacks = maxi(stacks, 0)
	if enemy_actor_anchor == null:
		return
	enemy_actor_anchor.modulate = _enemy_poison_modulate()


func play_outcome_pose(victory: bool, animate: bool = true) -> void:
	outcome_pose = OUTCOME_VICTORY if victory else OUTCOME_DEFEAT
	outcome_flash_count += 1
	last_outcome_flash_was_victory = victory
	if victory:
		_set_enemy_animation("defeat")
	else:
		_set_player_animation("defeat", animate)
	if not animate:
		return
	_kill_actor_tweens()
	_play_outcome_flash(victory)
	if victory and _is_practice_dummy_target():
		_set_enemy_animation("idle")
		if enemy_actor_anchor != null:
			enemy_actor_anchor.position = _enemy_base_position
			enemy_actor_anchor.modulate = _enemy_poison_modulate()
		return
	var target_anchor := enemy_actor_anchor if victory else player_actor_anchor
	var target_position := (_enemy_base_position if victory else _player_base_position) + Vector2(0.0, 10.0)
	var target_modulate := UIColors.COMBAT_DEFEATED_ACTOR_MODULATE if victory else Color.WHITE
	var tween := create_tween()
	if victory:
		_enemy_tween = tween
	else:
		_player_tween = tween
	tween.set_parallel(true)
	tween.tween_property(target_anchor, "position", target_position, OUTCOME_POSE_SEC)
	tween.tween_property(target_anchor, "modulate", target_modulate, OUTCOME_POSE_SEC)


static func animation_kind_for_cast(cast: CombatResolver.CastEvent) -> String:
	if cast == null:
		return ANIMATION_PHYSICAL
	if cast.poison_stacks_applied > 0 or cast.poison_resistance_reduction_applied > 0.0:
		return ANIMATION_POISON
	if _skill_has_poison_damage(cast.skill):
		return ANIMATION_POISON
	if _skill_is_poison_themed(cast.skill):
		return ANIMATION_POISON
	return ANIMATION_PHYSICAL


static func _skill_has_poison_damage(skill: Skill) -> bool:
	if skill == null:
		return false
	if skill.poison_stacks_applied > 0:
		return true
	for effect in skill.effects:
		if effect is PoisonDamageEffect:
			return true
	return false


static func _skill_is_poison_themed(skill: Skill) -> bool:
	if skill == null:
		return false
	if _skill_has_poison_damage(skill):
		return true
	var id_text := skill.id.to_lower()
	var display_text := skill.display_name.to_lower()
	if id_text.contains("poison") or id_text.contains("toxic") or display_text.contains("poison") or display_text.contains("toxic"):
		return true
	for effect in skill.effects:
		if effect is PoisonDamageEffect or effect is PoisonResistanceReductionEffect:
			return true
	return false


func player_sprite_available() -> bool:
	return _player_sprite != null and _player_sprite.texture != null


func enemy_sprite_available() -> bool:
	return _enemy_sprite != null and _enemy_sprite.texture != null


func enemy_popup_global_position() -> Vector2:
	if enemy_actor_anchor == null:
		return global_position
	return enemy_actor_anchor.global_position + ACTOR_SIZE * Vector2(0.5, 0.32)


func play_area_global_rect() -> Rect2:
	var stage_rect := get_global_rect()
	stage_rect.size.y = _effective_stage_size().y
	return stage_rect


func expected_player_sprite_paths() -> PackedStringArray:
	var paths := PackedStringArray()
	for animation_key in PLAYER_ANIMATION_MANIFEST_PATHS.keys():
		for path in _player_animation_frame_paths(animation_key):
			paths.append(path)
	return paths


func expected_enemy_sprite_paths(enemy_name: String) -> PackedStringArray:
	return PackedStringArray(_enemy_animation_paths_for(_enemy_visual_key_for(enemy_name)).values())


func expected_enemy_sprite_region(enemy_name: String, animation_key: String) -> Rect2:
	return _animation_region_for(_enemy_animation_regions_for(_enemy_visual_key_for(enemy_name)), animation_key, PEASANT_FRAME_SIZE)


func _build_stage() -> void:
	_outcome_flash = ColorRect.new()
	_outcome_flash.name = "OutcomeFlash"
	_outcome_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	_outcome_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_outcome_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_outcome_flash)

	player_actor_anchor = _make_anchor("PlayerActorAnchor", ACTOR_SIZE)
	player_actor_anchor.z_index = 3
	add_child(player_actor_anchor)
	_player_actor_card = _make_actor_card("PlayerActor", "Rogue", UIColors.TEXT_NORMAL)
	player_actor_anchor.add_child(_player_actor_card)
	_player_name_label = _player_actor_card.find_child("ActorLabel", true, false) as Label
	_player_contact_shadow = _make_contact_shadow("PlayerContactShadow")
	player_actor_anchor.add_child(_player_contact_shadow)
	_player_sprite = _make_actor_sprite("PlayerSprite", false)
	player_actor_anchor.add_child(_player_sprite)

	enemy_actor_anchor = _make_anchor("EnemyActorAnchor", ACTOR_SIZE)
	enemy_actor_anchor.z_index = 2
	add_child(enemy_actor_anchor)
	_enemy_actor_card = _make_actor_card("EnemyActor", "Enemy", UIColors.TEXT_WARNING)
	enemy_actor_anchor.add_child(_enemy_actor_card)
	_enemy_name_label = _enemy_actor_card.find_child("ActorLabel", true, false) as Label
	_apply_actor_name_visibility()
	_enemy_contact_shadow = _make_contact_shadow("EnemyContactShadow")
	enemy_actor_anchor.add_child(_enemy_contact_shadow)
	_enemy_sprite = _make_actor_sprite("EnemySprite", true)
	enemy_actor_anchor.add_child(_enemy_sprite)

	contact_effect_anchor = _make_anchor("ContactEffectAnchor", CONTACT_SIZE)
	add_child(contact_effect_anchor)

	floating_text_anchor = _make_anchor("FloatingTextAnchor", CONTACT_SIZE)
	add_child(floating_text_anchor)

	player_status_anchor = _make_anchor("PlayerStatusAnchor", STATUS_SIZE)
	add_child(player_status_anchor)

	enemy_status_anchor = _make_anchor("EnemyStatusAnchor", STATUS_SIZE)
	add_child(enemy_status_anchor)

	_debug_grid_overlay = DebugGridOverlay.new()
	_debug_grid_overlay.name = "DebugGridOverlay"
	_debug_grid_overlay.combat_stage = self
	_debug_grid_overlay.visible = debug_grid_visible
	add_child(_debug_grid_overlay)
	clear_target()


func _make_anchor(anchor_name: String, anchor_size: Vector2) -> Control:
	var anchor := Control.new()
	anchor.name = anchor_name
	anchor.custom_minimum_size = anchor_size
	anchor.size = anchor_size
	anchor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return anchor


func _make_actor_card(card_name: String, label_text: String, accent_color: Color) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = card_name
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.set_anchors_preset(Control.PRESET_FULL_RECT)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(UIColors.PANEL_DEEP.r, UIColors.PANEL_DEEP.g, UIColors.PANEL_DEEP.b, 0.64)
	style.border_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	card.add_theme_stylebox_override("panel", style)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(center)

	var actor_label := Label.new()
	actor_label.name = "ActorLabel"
	actor_label.text = label_text
	actor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	actor_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	actor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	actor_label.add_theme_color_override("font_color", accent_color)
	center.add_child(actor_label)
	return card


func _apply_actor_name_visibility() -> void:
	if _player_name_label != null:
		_player_name_label.visible = actor_names_visible
	if _enemy_name_label != null:
		_enemy_name_label.visible = actor_names_visible


func _make_actor_sprite(sprite_name: String, flip_h: bool) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.name = sprite_name
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.flip_h = flip_h
	sprite.visible = false
	return sprite


func _make_contact_shadow(shadow_name: String) -> ContactShadow:
	var shadow := ContactShadow.new()
	shadow.name = shadow_name
	shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shadow.z_index = -1
	shadow.visible = false
	return shadow


func _enemy_visual_key_for(enemy_name: String) -> String:
	return ENEMY_VISUAL_KEYS_BY_NAME.get(enemy_name, "")


func _enemy_animation_paths_for(visual_key: String) -> Dictionary:
	return ENEMY_ANIMATION_PATHS.get(visual_key, {})


func _enemy_animation_regions_for(visual_key: String) -> Dictionary:
	return ENEMY_ANIMATION_REGIONS.get(visual_key, {})


func _apply_actor_visual(sprite: TextureRect, fallback_card: PanelContainer, animation_paths: Dictionary, animation_regions: Dictionary, animation_key: String, frame_size: Vector2i, sprite_scale: float, flip_h: bool, anchor_point: Vector2 = PEASANT_ANCHOR_POINT) -> void:
	if sprite == null or fallback_card == null:
		return
	var region := _animation_region_for(animation_regions, animation_key, frame_size)
	var texture := _frame_texture(animation_paths.get(animation_key, animation_paths.get("idle", "")), region)
	sprite.texture = texture
	sprite.flip_h = flip_h
	sprite.size = region.size
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.pivot_offset = region.size * 0.5
	sprite.position = _sprite_position_for_anchor(region.size, anchor_point, sprite_scale)
	if sprite == _enemy_sprite and _is_practice_dummy_target():
		sprite.position += PRACTICE_DUMMY_SPRITE_OFFSET
	sprite.visible = texture != null
	fallback_card.visible = false
	if sprite == _enemy_sprite:
		_update_contact_shadow(_enemy_contact_shadow, sprite, PEASANT_VISIBLE_BOUNDS)
		if _is_practice_dummy_target():
			_enemy_contact_shadow.position += PRACTICE_DUMMY_SHADOW_OFFSET


func _sprite_position_for(frame_size: Vector2, sprite_scale: float) -> Vector2:
	var scaled_size := frame_size * sprite_scale
	return Vector2(
		(ACTOR_SIZE.x - scaled_size.x) * 0.5,
		maxf(0.0, ACTOR_SIZE.y - scaled_size.y - 8.0)
	)


func _sprite_position_for_anchor(frame_size: Vector2, anchor_point: Vector2, sprite_scale: float) -> Vector2:
	var pivot_offset := frame_size * 0.5
	var render_offset := pivot_offset - pivot_offset * sprite_scale
	return ACTOR_LOCAL_ANCHOR - render_offset - anchor_point * sprite_scale


func _update_contact_shadow(shadow: ContactShadow, sprite: TextureRect, visible_bounds: Rect2) -> void:
	if shadow == null or sprite == null:
		return
	shadow.visible = sprite.visible and sprite.texture != null
	if not shadow.visible:
		return
	var render_top_left := _sprite_render_top_left(sprite)
	var bounds := visible_bounds
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		bounds = Rect2(Vector2.ZERO, sprite.size)
	var shadow_size := Vector2(
		maxf(bounds.size.x * sprite.scale.x * CONTACT_SHADOW_WIDTH_SCALE, CONTACT_SHADOW_MIN_SIZE.x),
		CONTACT_SHADOW_MIN_SIZE.y
	)
	var foot_center := render_top_left + Vector2((bounds.position.x + bounds.size.x * 0.5) * sprite.scale.x, (bounds.position.y + bounds.size.y) * sprite.scale.y)
	shadow.size = shadow_size
	shadow.position = foot_center - shadow_size * 0.5 + Vector2(0.0, 2.0)
	shadow.queue_redraw()


func _actor_position_for_grid(stage_size: Vector2, grid_position: Vector2, frame_size: Vector2, anchor_point: Vector2, sprite_scale: float, stage_offset_px: Vector2 = Vector2.ZERO) -> Vector2:
	var clamped_grid := Vector2(
		clampf(grid_position.x, STAGE_GRID_MIN, STAGE_GRID_MAX),
		clampf(grid_position.y, STAGE_GRID_MIN, STAGE_GRID_MAX)
	)
	var desired_sprite_center := _stage_point_for_grid(clamped_grid) + stage_offset_px
	var sprite_position := _sprite_position_for_anchor(frame_size, anchor_point, sprite_scale)
	var scaled_size := frame_size * sprite_scale
	var pivot_offset := frame_size * 0.5
	var render_offset := pivot_offset - pivot_offset * sprite_scale
	var anchor_position := desired_sprite_center - ACTOR_LOCAL_ANCHOR
	var min_anchor := Vector2(
		STAGE_GRID_MARGIN_PX - sprite_position.x - render_offset.x,
		STAGE_GRID_MARGIN_PX - sprite_position.y - render_offset.y
	)
	var max_anchor := Vector2(
		stage_size.x - sprite_position.x - render_offset.x - scaled_size.x - STAGE_GRID_MARGIN_PX,
		stage_size.y - sprite_position.y - render_offset.y - scaled_size.y - STAGE_GRID_MARGIN_PX
	)
	return Vector2(
		clampf(anchor_position.x, min_anchor.x, max_anchor.x),
		clampf(anchor_position.y, min_anchor.y, max_anchor.y)
	)


func _stage_point_for_grid(grid_position: Vector2) -> Vector2:
	var grid_range := STAGE_GRID_MAX - STAGE_GRID_MIN
	var stage_size := _effective_stage_size()
	return Vector2(
		(clampf(grid_position.x, STAGE_GRID_MIN, STAGE_GRID_MAX) - STAGE_GRID_MIN) / grid_range * stage_size.x,
		(clampf(grid_position.y, STAGE_GRID_MIN, STAGE_GRID_MAX) - STAGE_GRID_MIN) / grid_range * stage_size.y
	)


func _effective_stage_size() -> Vector2:
	return Vector2(size.x, maxf(size.y - reserved_bottom_px, 1.0))


func _sprite_anchor_point(anchor: Control, sprite: TextureRect, anchor_point: Vector2) -> Vector2:
	if anchor == null or sprite == null:
		return Vector2.ZERO
	return anchor.position + _sprite_render_top_left(sprite) + anchor_point * sprite.scale


func _sprite_render_top_left(sprite: TextureRect) -> Vector2:
	return sprite.position + sprite.pivot_offset - sprite.pivot_offset * sprite.scale


func _animation_region_for(animation_regions: Dictionary, animation_key: String, frame_size: Vector2i) -> Rect2:
	if animation_regions.has(animation_key):
		return animation_regions[animation_key]
	if animation_regions.has("idle"):
		return animation_regions["idle"]
	return Rect2(Vector2.ZERO, Vector2(frame_size))


func _frame_texture(path: String, region: Rect2) -> Texture2D:
	if path == "":
		return null
	var source := _texture_from_path(path)
	if source == null:
		return null
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = region
	return atlas


func _texture_from_path(path: String) -> Texture2D:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null:
		return null
	return ImageTexture.create_from_image(image)


func _player_animation_frame_paths(animation_key: String) -> PackedStringArray:
	var animation := _player_animation_for_key(animation_key)
	var paths := PackedStringArray()
	for frame in animation.get("frames", []):
		if frame.has("path"):
			paths.append(frame["path"])
	return paths


func _player_animation_for_key(animation_key: String) -> Dictionary:
	var resolved_key := animation_key
	if not PLAYER_ANIMATION_MANIFEST_PATHS.has(resolved_key):
		resolved_key = "idle"
	if _player_animation_cache.has(resolved_key):
		return _player_animation_cache[resolved_key]
	var manifest_path: String = PLAYER_ANIMATION_MANIFEST_PATHS[resolved_key]
	var manifest := _load_json_manifest(manifest_path)
	var frames: Array = []
	var manifest_base := manifest_path.get_base_dir()
	for frame in manifest.get("frames", []):
		var relative_path: String = frame.get("file", "")
		if relative_path == "":
			continue
		var visible_data: Dictionary = frame.get("visible_bounds", {})
		var visible_bounds := ROGUE_VISIBLE_BOUNDS
		if not visible_data.is_empty():
			visible_bounds = Rect2(
				Vector2(float(visible_data.get("x", 0.0)), float(visible_data.get("y", 0.0))),
				Vector2(float(visible_data.get("w", ROGUE_VISIBLE_BOUNDS.size.x)), float(visible_data.get("h", ROGUE_VISIBLE_BOUNDS.size.y)))
			)
		frames.append({
			"path": "%s/%s" % [manifest_base, relative_path],
			"duration_ms": int(frame.get("duration_ms", 100)),
			"visible_bounds": visible_bounds,
		})
	var frame_size_data: Dictionary = manifest.get("frame_size", {})
	var pivot_data: Dictionary = manifest.get("pivot", {})
	var animation := {
		"frames": frames,
		"frame_size": Vector2(float(frame_size_data.get("w", ROGUE_FRAME_SIZE.x)), float(frame_size_data.get("h", ROGUE_FRAME_SIZE.y))),
		"anchor_point": Vector2(float(pivot_data.get("x", ROGUE_ANCHOR_POINT.x)), float(pivot_data.get("y", ROGUE_ANCHOR_POINT.y))),
		"loop": bool(manifest.get("loop", resolved_key == "idle")),
		"fps": float(manifest.get("fps", 8.0)),
	}
	_player_animation_cache[resolved_key] = animation
	return animation


func _load_json_manifest(path: String) -> Dictionary:
	if path == "" or not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}


func _apply_player_animation_frame() -> void:
	if _player_sprite == null or _player_actor_card == null:
		return
	var animation: Dictionary = _player_animation_cache.get(_player_animation_key, {})
	var frames: Array = animation.get("frames", [])
	if frames.is_empty():
		_player_sprite.visible = false
		_player_actor_card.visible = false
		_update_contact_shadow(_player_contact_shadow, _player_sprite, _player_current_visible_bounds)
		return
	_player_animation_frame_index = clampi(_player_animation_frame_index, 0, frames.size() - 1)
	var frame: Dictionary = frames[_player_animation_frame_index]
	var path: String = frame.get("path", "")
	last_player_animation_frame_path = path
	var texture := _texture_from_path(path)
	_player_sprite.texture = texture
	if texture != null:
		_player_sprite.size = texture.get_size()
	else:
		_player_sprite.size = animation.get("frame_size", Vector2(ROGUE_FRAME_SIZE))
	_player_sprite.scale = Vector2(ROGUE_SPRITE_SCALE, ROGUE_SPRITE_SCALE)
	_player_sprite.pivot_offset = _player_sprite.size * 0.5
	_player_current_anchor_point = animation.get("anchor_point", ROGUE_ANCHOR_POINT)
	_player_sprite.position = _sprite_position_for_anchor(_player_sprite.size, _player_current_anchor_point, ROGUE_SPRITE_SCALE)
	if _is_practice_dummy_target():
		_player_sprite.position += PRACTICE_ROGUE_SPRITE_OFFSET
	_player_sprite.flip_h = false
	_player_sprite.visible = texture != null
	_player_actor_card.visible = false
	_player_current_visible_bounds = frame.get("visible_bounds", ROGUE_VISIBLE_BOUNDS)
	_update_contact_shadow(_player_contact_shadow, _player_sprite, _player_current_visible_bounds)
	if _debug_grid_overlay != null:
		_debug_grid_overlay.queue_redraw()


func _set_player_animation(kind: String, animate: bool = true, duration_override_sec: float = -1.0) -> void:
	var animation_key := _player_animation_key_for_kind(kind)
	var animation := _player_animation_for_key(animation_key)
	var frames: Array = animation.get("frames", [])
	_player_animation_key = animation_key
	_player_animation_frame_index = 0
	_player_animation_elapsed = 0.0
	_player_animation_loop = bool(animation.get("loop", animation_key == "idle")) and animate
	_player_animation_playing = animate and frames.size() > 1
	last_player_animation_key = animation_key
	last_player_animation_frame_count = frames.size()
	if frames.size() > 0:
		var first_frame: Dictionary = frames[0]
		_player_animation_frame_sec = maxf(float(first_frame.get("duration_ms", 100)) / 1000.0, 0.001)
		if duration_override_sec > 0.0 and frames.size() > 1:
			_player_animation_frame_sec = maxf(duration_override_sec / float(frames.size()), 0.001)
	_apply_player_animation_frame()
	set_process(_player_animation_playing)


func _player_animation_key_for_kind(kind: String) -> String:
	if kind == ANIMATION_PHYSICAL:
		return "attack_physical"
	if kind == ANIMATION_POISON:
		return "attack_poison"
	if kind == "hurt":
		return "hurt"
	if kind == "defeat":
		return "defeat"
	return "idle"


func _player_animation_duration_sec(animation_key: String) -> float:
	var animation := _player_animation_for_key(animation_key)
	var frames: Array = animation.get("frames", [])
	var duration_sec := 0.0
	for frame in frames:
		duration_sec += maxf(float(frame.get("duration_ms", 100)) / 1000.0, 0.001)
	return duration_sec


func player_defeat_animation_duration_sec() -> float:
	return _player_animation_duration_sec("defeat")


func _player_animation_contact_sec(animation_key: String) -> float:
	var animation := _player_animation_for_key(animation_key)
	var frames: Array = animation.get("frames", [])
	if frames.size() < 2:
		return _player_animation_duration_sec(animation_key)
	var contact_frame_index := frames.size() - 2
	var contact_sec := 0.0
	for index in contact_frame_index:
		var frame: Dictionary = frames[index]
		contact_sec += maxf(float(frame.get("duration_ms", 100)) / 1000.0, 0.001)
	return contact_sec


func _set_enemy_animation(kind: String) -> void:
	var animation_key := "idle"
	if kind == "hurt":
		animation_key = "hurt"
	elif kind == "defeat":
		animation_key = "defeat"
	_apply_enemy_visual(animation_key)


func _apply_enemy_visual(animation_key: String) -> void:
	_apply_actor_visual(_enemy_sprite, _enemy_actor_card, _enemy_animation_paths_for(_enemy_visual_key), _enemy_animation_regions_for(_enemy_visual_key), animation_key, PEASANT_FRAME_SIZE, _enemy_sprite_scale(), _enemy_flip_h(), _enemy_anchor_point())


func _is_practice_dummy_target() -> bool:
	return _enemy_visual_key == PRACTICE_DUMMY_VISUAL_KEY


func _enemy_sprite_scale() -> float:
	return PRACTICE_DUMMY_SPRITE_SCALE if _is_practice_dummy_target() else PEASANT_SPRITE_SCALE


func _enemy_anchor_point() -> Vector2:
	return PRACTICE_DUMMY_ANCHOR_POINT if _is_practice_dummy_target() else PEASANT_ANCHOR_POINT


func _enemy_flip_h() -> bool:
	return false if _is_practice_dummy_target() else true


func _apply_enemy_frame_path(path: String) -> void:
	if _enemy_sprite == null or _enemy_actor_card == null:
		return
	var texture := _texture_from_path(path)
	_enemy_sprite.texture = texture
	_enemy_sprite.size = texture.get_size() if texture != null else Vector2(PEASANT_FRAME_SIZE)
	var sprite_scale := _enemy_sprite_scale()
	_enemy_sprite.scale = Vector2(sprite_scale, sprite_scale)
	_enemy_sprite.pivot_offset = _enemy_sprite.size * 0.5
	_enemy_sprite.position = _sprite_position_for_anchor(_enemy_sprite.size, _enemy_anchor_point(), sprite_scale)
	if _is_practice_dummy_target():
		_enemy_sprite.position += PRACTICE_DUMMY_SPRITE_OFFSET
	_enemy_sprite.flip_h = _enemy_flip_h()
	_enemy_sprite.visible = texture != null
	_enemy_actor_card.visible = false
	_update_contact_shadow(_enemy_contact_shadow, _enemy_sprite, PEASANT_VISIBLE_BOUNDS)
	if _is_practice_dummy_target():
		_enemy_contact_shadow.position += PRACTICE_DUMMY_SHADOW_OFFSET
	if _debug_grid_overlay != null:
		_debug_grid_overlay.queue_redraw()


func _presentation_duration_for_cast(cast: CombatResolver.CastEvent, playback_speed: float, animation_key: String = "") -> float:
	if cast != null and cast.min_cast_time_proc_applied:
		return MIN_CAST_ANIMATION_SEC
	var speed_scale := maxf(playback_speed, 0.001)
	var source_ms := 700
	if cast != null and cast.skill != null:
		source_ms = cast.skill.base_execution_ms
	var base_sec := float(source_ms) / 1000.0 / speed_scale
	var cast_duration := clampf(base_sec * 0.28, MIN_CAST_ANIMATION_SEC, MAX_CAST_ANIMATION_SEC)
	var resolved_animation_key := animation_key
	if resolved_animation_key == "":
		resolved_animation_key = _player_animation_key_for_kind(animation_kind_for_cast(cast))
	var animation_duration := _player_animation_duration_sec(resolved_animation_key)
	return maxf(cast_duration, animation_duration)


func _contact_delay_for_cast(cast: CombatResolver.CastEvent, animation_key: String, duration: float, include_triggered_followup: bool = true) -> float:
	var contact_sec := _player_animation_contact_sec(animation_key)
	var animation_duration := _player_animation_duration_sec(animation_key)
	if animation_duration > 0.0 and duration < animation_duration:
		contact_sec *= duration / animation_duration
	if include_triggered_followup and cast != null and not cast.triggered_skill_names.is_empty():
		contact_sec = duration + TRIGGERED_FOLLOWUP_ANIMATION_SEC * 0.45
	return contact_sec


func _play_enemy_recoil(delay_sec: float, is_crit: bool) -> void:
	_kill_enemy_tween()
	last_enemy_recoil_delay_sec = delay_sec
	last_contact_feedback_delay_sec = delay_sec
	last_contact_feedback_was_crit = is_crit
	contact_feedback_count += 1
	if _is_practice_dummy_target():
		_play_practice_dummy_reaction(delay_sec)
		return
	var recoil_distance := RECOIL_DISTANCE_PX * (1.45 if is_crit else 1.0)
	var recoil_out_sec := 0.09 if is_crit else 0.07
	var recoil_back_sec := 0.16 if is_crit else 0.13
	var hurt_color := UIColors.COMBAT_CRIT_FLASH if is_crit else UIColors.COMBAT_HIT_FLASH
	var recoil_target := _enemy_base_position + Vector2(recoil_distance, 0.0)
	_enemy_tween = create_tween()
	_enemy_tween.tween_interval(delay_sec)
	_enemy_tween.tween_callback(func(): _set_enemy_animation("hurt"))
	_enemy_tween.tween_property(enemy_actor_anchor, "position", recoil_target, recoil_out_sec)
	_enemy_tween.parallel().tween_property(enemy_actor_anchor, "modulate", hurt_color, recoil_out_sec)
	_enemy_tween.tween_property(enemy_actor_anchor, "position", _enemy_base_position, recoil_back_sec)
	_enemy_tween.parallel().tween_property(enemy_actor_anchor, "modulate", _enemy_poison_modulate(), recoil_back_sec)
	_enemy_tween.tween_callback(func(): _set_enemy_animation("idle"))


func _play_practice_dummy_reaction(delay_sec: float) -> void:
	if PRACTICE_DUMMY_REACTION_FRAME_PATHS.is_empty():
		return
	var reaction_index := _effect_rng.randi_range(0, PRACTICE_DUMMY_REACTION_FRAME_PATHS.size() - 1)
	var frames: Array = PRACTICE_DUMMY_REACTION_FRAME_PATHS[reaction_index]
	if frames.is_empty():
		return
	practice_dummy_reaction_count += 1
	last_practice_dummy_reaction_index = reaction_index
	last_practice_dummy_reaction_frame_count = frames.size()
	_enemy_tween = create_tween()
	if delay_sec > 0.0:
		_enemy_tween.tween_interval(delay_sec)
	_enemy_tween.tween_callback(func():
		if enemy_actor_anchor != null:
			enemy_actor_anchor.position = _enemy_base_position
	)
	for frame_path in frames:
		var path := String(frame_path)
		_enemy_tween.tween_callback(_apply_enemy_frame_path.bind(path))
		_enemy_tween.tween_interval(PRACTICE_DUMMY_REACTION_FRAME_SEC)
	_enemy_tween.tween_callback(func(): _set_enemy_animation("idle"))


func _play_bandit_coin_spray(delay_sec: float, is_crit: bool) -> void:
	var coin_count := BANDIT_COIN_CRIT_COUNT if is_crit else BANDIT_COIN_NORMAL_COUNT
	bandit_coin_spray_count += 1
	last_bandit_coin_count = coin_count
	if enemy_actor_anchor == null:
		return
	var impact_position := _bandit_coin_impact_position()
	var generation := _effect_generation
	if delay_sec > 0.0:
		var contact_tween := create_tween()
		contact_tween.tween_interval(delay_sec)
		contact_tween.tween_callback(func():
			if generation == _effect_generation:
				_spawn_bandit_coin_particles(coin_count, impact_position)
		)
		return
	_spawn_bandit_coin_particles(coin_count, impact_position)


func _spawn_bandit_coin_particles(coin_count: int, impact_position: Vector2) -> void:
	for index in coin_count:
		var coin := TextureRect.new()
		coin.name = "BanditCoinParticle"
		coin.texture = BANDIT_COIN_TEXTURE
		coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var coin_size := _effect_rng.randf_range(BANDIT_COIN_SIZE_RANGE.x, BANDIT_COIN_SIZE_RANGE.y)
		coin.size = Vector2(coin_size, coin_size)
		coin.pivot_offset = coin.size * 0.5
		coin.position = impact_position - coin.pivot_offset + Vector2(
			_effect_rng.randf_range(-5.0, 5.0),
			_effect_rng.randf_range(-5.0, 5.0)
		)
		coin.rotation = _effect_rng.randf_range(-0.7, 0.7)
		coin.modulate = Color(1.0, _effect_rng.randf_range(0.78, 0.94), 0.34, BANDIT_COIN_START_ALPHA)
		coin.z_index = 30
		add_child(coin)

		var drift := Vector2(
			_effect_rng.randf_range(BANDIT_COIN_SPREAD_X_RANGE.x, BANDIT_COIN_SPREAD_X_RANGE.y),
			_effect_rng.randf_range(BANDIT_COIN_SPREAD_Y_RANGE.x, BANDIT_COIN_SPREAD_Y_RANGE.y)
		)
		var tween := coin.create_tween()
		tween.set_parallel(true)
		tween.tween_property(coin, "position", coin.position + drift, BANDIT_COIN_LIFETIME_SEC).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(coin, "rotation", coin.rotation + _effect_rng.randf_range(-1.3, 1.3), BANDIT_COIN_LIFETIME_SEC)
		tween.tween_property(coin, "modulate:a", 0.0, BANDIT_COIN_LIFETIME_SEC - BANDIT_COIN_FADE_DELAY_SEC).set_delay(BANDIT_COIN_FADE_DELAY_SEC)
		tween.finished.connect(coin.queue_free)


func _bandit_coin_impact_position() -> Vector2:
	if _enemy_sprite != null and _enemy_sprite.visible and _enemy_sprite.texture != null:
		return _sprite_anchor_point(enemy_actor_anchor, _enemy_sprite, PEASANT_ANCHOR_POINT) + BANDIT_COIN_SPRITE_CONTACT_OFFSET
	return enemy_actor_anchor.position + BANDIT_COIN_FALLBACK_IMPACT_OFFSET


func _clear_bandit_coin_particles() -> void:
	for child in get_children():
		if String(child.name).begins_with("BanditCoinParticle"):
			child.queue_free()


func _play_outcome_flash(victory: bool) -> void:
	if _outcome_flash == null:
		return
	_outcome_flash.color = UIColors.COMBAT_VICTORY_FLASH if victory else UIColors.COMBAT_DEFEAT_FLASH
	var peak_alpha := 0.2 if victory else 0.18
	var tween := create_tween()
	tween.tween_property(_outcome_flash, "color:a", peak_alpha, OUTCOME_FLASH_SEC * 0.35)
	tween.tween_property(_outcome_flash, "color:a", 0.0, OUTCOME_FLASH_SEC * 0.65)


func _restore_actor_layout() -> void:
	if player_actor_anchor != null:
		player_actor_anchor.position = _player_base_position
		player_actor_anchor.modulate = Color.WHITE
	if enemy_actor_anchor != null:
		enemy_actor_anchor.position = _enemy_base_position
		enemy_actor_anchor.modulate = _enemy_poison_modulate()


func _clear_status_visuals() -> void:
	last_poison_stack_tint_stacks = 0
	outcome_pose = ""
	if player_actor_anchor != null:
		player_actor_anchor.modulate = Color.WHITE
	if enemy_actor_anchor != null:
		enemy_actor_anchor.modulate = Color.WHITE
	if _outcome_flash != null:
		_outcome_flash.color.a = 0.0


func _enemy_poison_modulate() -> Color:
	if last_poison_stack_tint_stacks <= 0:
		return Color.WHITE
	var intensity := clampf(float(last_poison_stack_tint_stacks) / float(POISON_VISIBLE_STACK_CAP), 0.0, 1.0)
	return Color(lerpf(0.9, 0.46, intensity), 1.0, lerpf(0.9, 0.52, intensity), 1.0)


func _kill_actor_tweens() -> void:
	if _player_tween != null and _player_tween.is_valid():
		_player_tween.kill()
	if _enemy_tween != null and _enemy_tween.is_valid():
		_enemy_tween.kill()


func _kill_player_tween() -> void:
	if _player_tween != null and _player_tween.is_valid():
		_player_tween.kill()


func _kill_enemy_tween() -> void:
	if _enemy_tween != null and _enemy_tween.is_valid():
		_enemy_tween.kill()


func _layout_stage() -> void:
	if player_actor_anchor == null:
		return
	var stage_size := _effective_stage_size()
	if stage_size.x <= 0.0 or stage_size.y <= 0.0:
		return

	var previous_player_base := _player_base_position
	var previous_enemy_base := _enemy_base_position
	var previous_player_position := player_actor_anchor.position
	var previous_enemy_position := enemy_actor_anchor.position
	var practice_dummy := _is_practice_dummy_target()
	var enemy_offset := PRACTICE_DUMMY_STAGE_OFFSET if practice_dummy else ACTOR_GROUP_STAGE_OFFSET_PX
	var enemy_grid := PRACTICE_DUMMY_STAGE_GRID if practice_dummy else ENEMY_STAGE_GRID
	var player_position := _actor_position_for_grid(stage_size, PLAYER_STAGE_GRID, Vector2(ROGUE_FRAME_SIZE), ROGUE_ANCHOR_POINT, ROGUE_SPRITE_SCALE, ACTOR_GROUP_STAGE_OFFSET_PX)
	var enemy_position := _actor_position_for_grid(stage_size, enemy_grid, Vector2(PEASANT_FRAME_SIZE), _enemy_anchor_point(), _enemy_sprite_scale(), enemy_offset)
	var actor_y := minf(player_position.y, enemy_position.y)

	player_actor_anchor.position = player_position
	enemy_actor_anchor.position = enemy_position
	_player_base_position = player_actor_anchor.position
	_enemy_base_position = enemy_actor_anchor.position
	_apply_outcome_pose_position_after_layout(previous_player_base, previous_enemy_base, previous_player_position, previous_enemy_position)
	contact_effect_anchor.position = Vector2(stage_size.x * 0.5 - CONTACT_SIZE.x * 0.5 + ACTOR_GROUP_STAGE_OFFSET_PX.x, actor_y + ACTOR_SIZE.y * 0.35)
	floating_text_anchor.position = Vector2(stage_size.x * 0.5 - CONTACT_SIZE.x * 0.5 + ACTOR_GROUP_STAGE_OFFSET_PX.x, maxf(safe_top_px, actor_y - CONTACT_SIZE.y * 0.75))
	player_status_anchor.position = Vector2(player_position.x + ACTOR_SIZE.x * 0.5 - STATUS_SIZE.x * 0.5, maxf(safe_top_px, player_position.y - STATUS_SIZE.y - 8.0))
	enemy_status_anchor.position = Vector2(enemy_position.x + ACTOR_SIZE.x * 0.5 - STATUS_SIZE.x * 0.5, maxf(safe_top_px, enemy_position.y - STATUS_SIZE.y - 8.0))
	if _debug_grid_overlay != null:
		_debug_grid_overlay.queue_redraw()


func _apply_outcome_pose_position_after_layout(
	previous_player_base: Vector2,
	previous_enemy_base: Vector2,
	previous_player_position: Vector2,
	previous_enemy_position: Vector2
) -> void:
	if outcome_pose == OUTCOME_VICTORY and enemy_actor_anchor != null:
		if _is_practice_dummy_target():
			return
		enemy_actor_anchor.position = _enemy_base_position + (previous_enemy_position - previous_enemy_base)
	elif outcome_pose == OUTCOME_DEFEAT and player_actor_anchor != null:
		player_actor_anchor.position = _player_base_position + (previous_player_position - previous_player_base)
