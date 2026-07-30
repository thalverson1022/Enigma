class_name CombatPlayback
extends RefCounted
## Presentation-layer playback controller for an already-resolved
## CombatResolver.CombatResult (user-requested combat-playback addition to
## P2:R7). Combat still resolves synchronously and completely inside
## CombatResolver.resolve() before this class ever sees the result -- this
## class only re-plays the recorded cast/tick event timeline in real time so
## the UI can animate the fight. It performs NO game-rule logic and mutates
## NO run state, per docs/Conventions.md's UI architecture principle: given
## the same result and the same advance() calls, the set of events fired by
## any time T is fully deterministic.
##
## Logic-only and renderer-free by design so it is headless-testable: the
## owner (combat_screen.gd) drives advance() from _process() and receives
## each fired event through event_callback, then finished_callback exactly
## once when the timeline completes. skip() fires every remaining event
## immediately and finishes -- the same path doubles as the instant mode
## headless tests rely on.


## One merged timeline entry: either a cast (with its CastEvent) or a poison
## tick (with its TickEvent), at its recorded resolver timestamp.
class PlaybackEvent:
	extends RefCounted
	var time_ms: int = 0
	var is_tick: bool = false
	var cast: CombatResolver.CastEvent = null
	var tick: CombatResolver.TickEvent = null
	## Damage this single event contributed (cast physical damage or tick
	## poison damage) -- what the HP bar should drain when it fires.
	var damage: float = 0.0


## Playback speed multiplier applied to advance()'s delta (1.0 = real time).
var speed: float = 1.0
## Called as event_callback.call(event: PlaybackEvent) for each fired event,
## in timeline order.
var event_callback: Callable = Callable()
## Called as cast_start_callback.call(cast: CombatResolver.CastEvent) when a
## cast begins. This is presentation-only timing for macro highlights; damage
## and HUD changes still use event_callback at the resolved event timestamp.
var cast_start_callback: Callable = Callable()
## Called exactly once, with no arguments, when the timeline completes
## (either by advancing past the end or via skip()).
var finished_callback: Callable = Callable()

var _events: Array = []
var _cast_starts: Array[CombatResolver.CastEvent] = []
var _next_index: int = 0
var _next_cast_start_index: int = 0
var _elapsed_ms: float = 0.0
var _timeline_end_ms: int = 0
var _window_ms: int = 0
var _started: bool = false
var _finished: bool = false
var _damage_dealt: float = 0.0


## Builds the merged, time-ordered timeline from the result's cast and tick
## events. Always plays the FULL authored window on both a win and a loss
## (combat-playback adjustment round 1, 2026-07-19 -- previously a win
## truncated the timeline at the recorded kill moment; the user wants the
## full window to keep playing after the kill for an "overkill" feel, with
## the HUD's HP bar clamping at 0 rather than the timeline stopping early).
func start(result: CombatResolver.CombatResult) -> void:
	_events = _merge_events(result)
	_cast_starts = result.cast_events.duplicate()
	_window_ms = result.duration_ms
	_timeline_end_ms = result.duration_ms
	_next_index = 0
	_next_cast_start_index = 0
	_elapsed_ms = 0.0
	_damage_dealt = 0.0
	_started = true
	_finished = false


## Advances the playback clock by delta_seconds * speed and fires every event
## whose timestamp has been reached, in order. Finishes (once) when the
## timeline end is reached and every event has fired.
func advance(delta_seconds: float) -> void:
	if not _started or _finished:
		return
	_elapsed_ms = minf(_elapsed_ms + delta_seconds * 1000.0 * maxf(speed, 0.0), float(_timeline_end_ms))
	_fire_due_events()
	if _elapsed_ms >= float(_timeline_end_ms) and _next_index >= _events.size():
		_finish()


## Fires every remaining event immediately, jumps the clock to the timeline
## end, and finishes. Also the instant mode used by headless tests.
func skip() -> void:
	if not _started or _finished:
		return
	_elapsed_ms = float(_timeline_end_ms)
	_fire_due_events()
	_finish()


func elapsed_ms() -> float:
	return _elapsed_ms


## Where playback ends -- always the full authored DPS window on both a win
## and a loss (no more win truncation, adjustment round 1). Kept as its own
## accessor alongside window_ms() since callers historically read either
## name for the same "how long does this readout run" question.
func timeline_end_ms() -> int:
	return _timeline_end_ms


## The full authored DPS window -- what a countdown readout should show as
## the denominator.
func window_ms() -> int:
	return _window_ms


func events_fired() -> int:
	return _next_index


func total_events() -> int:
	return _events.size()


## Cumulative damage of every event fired so far -- monster HP minus this is
## the HP the bar should currently show.
func damage_dealt() -> float:
	return _damage_dealt


func is_finished() -> bool:
	return _finished


func active_cast() -> CombatResolver.CastEvent:
	if _next_cast_start_index <= 0 or _next_cast_start_index > _cast_starts.size():
		return null
	var cast: CombatResolver.CastEvent = _cast_starts[_next_cast_start_index - 1]
	if _elapsed_ms > float(cast.time_ms):
		return null
	return cast


func active_cast_progress() -> float:
	var cast := active_cast()
	if cast == null:
		return 0.0
	var duration_ms := maxi(cast.time_ms - cast.cast_start_ms, 1)
	return clampf((_elapsed_ms - float(cast.cast_start_ms)) / float(duration_ms), 0.0, 1.0)


func _fire_due_events() -> void:
	while true:
		var next_event = _events[_next_index] if _next_index < _events.size() else null
		var next_start: CombatResolver.CastEvent = _cast_starts[_next_cast_start_index] if _next_cast_start_index < _cast_starts.size() else null
		var event_due := next_event != null and float(next_event.time_ms) <= _elapsed_ms
		var start_due := next_start != null and float(next_start.cast_start_ms) <= _elapsed_ms
		if not event_due and not start_due:
			return
		if start_due and (not event_due or next_start.cast_start_ms < next_event.time_ms):
			_next_cast_start_index += 1
			if cast_start_callback.is_valid():
				cast_start_callback.call(next_start)
			continue
		_next_index += 1
		_damage_dealt += next_event.damage
		if event_callback.is_valid():
			event_callback.call(next_event)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	if finished_callback.is_valid():
		finished_callback.call()


## Two-pointer merge of the (already time-ordered) cast and tick arrays into
## one timeline. On a timestamp tie a tick fires BEFORE the cast, matching
## CombatResolver.resolve()'s own order (ticks with time <= cast_end resolve
## before that cast) so cumulative damage at any T matches the resolver.
static func _merge_events(result: CombatResolver.CombatResult) -> Array:
	var merged: Array = []
	var cast_index := 0
	var tick_index := 0
	while cast_index < result.cast_events.size() or tick_index < result.tick_events.size():
		var take_tick: bool
		if tick_index >= result.tick_events.size():
			take_tick = false
		elif cast_index >= result.cast_events.size():
			take_tick = true
		else:
			take_tick = result.tick_events[tick_index].time_ms <= result.cast_events[cast_index].time_ms
		var event := PlaybackEvent.new()
		if take_tick:
			var tick := result.tick_events[tick_index]
			tick_index += 1
			event.time_ms = tick.time_ms
			event.is_tick = true
			event.tick = tick
			event.damage = tick.damage
		else:
			var cast := result.cast_events[cast_index]
			cast_index += 1
			event.time_ms = cast.time_ms
			event.is_tick = false
			event.cast = cast
			event.damage = cast.physical_damage
		merged.append(event)
	return merged
