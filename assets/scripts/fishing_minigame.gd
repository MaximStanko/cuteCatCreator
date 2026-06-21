extends CanvasLayer

signal finished(success: bool, item_name: String)

# Fish definitions: curve type -> item string, colour, and life range (min..max).
const FISH := {
	"calm":    {"item": "Koi",     "color": Color(0.95, 0.55, 0.25), "lives": Vector2i(6, 8)},
	"sine":    {"item": "Trout",   "color": Color(0.55, 0.70, 0.55), "lives": Vector2i(4, 6)},
	"bottom":  {"item": "Catfish", "color": Color(0.45, 0.40, 0.30), "lives": Vector2i(5, 7)},
	"bouncer": {"item": "Salmon",  "color": Color(0.95, 0.55, 0.55), "lives": Vector2i(4, 6)},
	"erratic": {"item": "Anchovy", "color": Color(0.75, 0.80, 0.88), "lives": Vector2i(2, 5)},
	"lunger":  {"item": "Pike",    "color": Color(0.25, 0.45, 0.30), "lives": Vector2i(3, 5)},
	"dodger":  {"item": "Eel",     "color": Color(0.55, 0.65, 0.25), "lives": Vector2i(3, 6)},
	"frenzy":  {"item": "Tuna",    "color": Color(0.20, 0.35, 0.65), "lives": Vector2i(4, 7)},
}

const TRACK_H := 400.0
const FISH_H := 20.0

const BAR_GRAVITY := 900.0
const BAR_LIFT := 1500.0
const BAR_MAX_SPEED := 700.0
const BAR_START_H := 110.0
const BAR_MIN_H := 50.0
const BAR_SHRINK_RATE := 6.0

const CATCH_FILL_RATE := 0.3
const CATCH_DRAIN_RATE := 0.275
const ESCAPE_DRAIN := 1.0
const ESCAPE_REGEN := 0.6

const FISH_SPEED_CALM := 12.0
const FISH_SPEED_ERRATIC := 260.0
const FISH_SPEED_LUNGE := 320.0
const FISH_SPEED_DODGE := 220.0
const FISH_SPEED_DRIFT := 50.0
const FISH_SPEED_BOTTOM := 45.0

var item_name: String
var pattern: String
var fish_color: Color
var max_lives: float

var bar_pos: float = TRACK_H * 0.6
var bar_vel: float = 0.0
var bar_h: float = BAR_START_H

var fish_pos: float = TRACK_H * 0.5
var fish_target: float = TRACK_H * 0.5
var fish_phase: float = 0.0
var dart_timer: float = 0.0

var catch_progress: float = 0.0
var escape: float = 1.0
var finished_emitted: bool = false
var last_overlap: bool = false

@onready var _title: Label = $Root/Panel/Title
@onready var _bar: ColorRect = $Root/Panel/TrackBG/FishingBar
@onready var _fish: ColorRect = $Root/Panel/TrackBG/Fish
@onready var _catch: ProgressBar = $Root/Panel/CatchProgress
@onready var _escape: ProgressBar = $Root/Panel/EscapeBar

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func start() -> void:
	pattern = FISH.keys().pick_random()
	var data: Dictionary = FISH[pattern]
	item_name = data.item
	fish_color = data.color
	max_lives = float(randi_range(data.lives.x, data.lives.y))
	escape = max_lives

	_title.text = "Fishing :3"
	_fish.color = fish_color
	_escape.max_value = max_lives
	_escape.value = escape

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo() and (event as InputEventKey).physical_keycode == KEY_ESCAPE:
		_finish(false)
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	var accel := BAR_GRAVITY
	if Input.is_action_pressed("ui_accept"):
		accel -= BAR_LIFT
	bar_vel = clampf(bar_vel + accel * delta, -BAR_MAX_SPEED, BAR_MAX_SPEED)
	bar_pos += bar_vel * delta
	if bar_pos < 0.0:
		bar_pos = 0.0
		bar_vel = 0.0
	elif bar_pos > TRACK_H - bar_h:
		bar_pos = TRACK_H - bar_h
		bar_vel = 0.0

	var new_h := maxf(BAR_MIN_H, bar_h - BAR_SHRINK_RATE * delta)
	bar_pos += (bar_h - new_h) * 0.5
	bar_h = new_h
	bar_pos = clampf(bar_pos, 0.0, TRACK_H - bar_h)

	_update_fish(delta)
	fish_pos = clampf(fish_pos, FISH_H * 0.5, TRACK_H - FISH_H * 0.5)

	# Overlap (fish center within bar span, with fish half-height tolerance)
	var overlapping := fish_pos >= bar_pos - FISH_H * 0.5 and fish_pos <= bar_pos + bar_h + FISH_H * 0.5

	if overlapping:
		catch_progress = minf(1.0, catch_progress + CATCH_FILL_RATE * delta)
		escape = minf(max_lives, escape + ESCAPE_REGEN * delta)
	else:
		catch_progress = maxf(0.0, catch_progress - CATCH_DRAIN_RATE * delta)
		escape = maxf(0.0, escape - ESCAPE_DRAIN * delta)

	_bar.position.y = bar_pos
	_bar.size.y = bar_h
	_fish.position.y = fish_pos - FISH_H * 0.5
	_catch.value = catch_progress
	_escape.value = escape
	_bar.modulate = Color(0.6, 1.0, 0.6) if overlapping else Color.WHITE
	last_overlap = overlapping

	if catch_progress >= 1.0:
		_finish(true)
	elif escape <= 0.0:
		_finish(false)

func _update_fish(delta: float) -> void:
	match pattern:
		"calm":
			# barely moves: a tiny, slow drift around the centre
			fish_phase += delta
			var calm_target := TRACK_H * 0.5 + sin(fish_phase * 0.4) * (TRACK_H * 0.04)
			fish_pos = move_toward(fish_pos, calm_target, FISH_SPEED_CALM * delta)
		"bottom":
			# hugs the floor of the track, bobbing up only slightly
			fish_phase += delta
			var bottom_target := TRACK_H * 0.80 + sin(fish_phase * 0.6) * (TRACK_H * 0.12)
			fish_pos = move_toward(fish_pos, bottom_target, FISH_SPEED_BOTTOM * delta)
		"bouncer":
			# constant-speed triangle wave bouncing top<->bottom (no easing at the turns)
			fish_phase += delta
			var tri := absf(fmod(fish_phase * 0.5, 2.0) - 1.0) # 1->0->1, period 4s
			fish_pos = lerpf(FISH_H, TRACK_H - FISH_H, tri)
		"erratic":
			# frequent small twitches around the current position
			dart_timer -= delta
			if dart_timer <= 0.0:
				fish_target = clampf(fish_pos + randf_range(-1.0, 1.0) * (TRACK_H * 0.18), FISH_H, TRACK_H - FISH_H)
				dart_timer = randf_range(0.12, 0.3)
			fish_pos = move_toward(fish_pos, fish_target, FISH_SPEED_ERRATIC * delta)
		"lunger":
			# long stillness, then a single fast lunge anywhere across the track
			dart_timer -= delta
			if dart_timer <= 0.0:
				fish_target = randf_range(FISH_H, TRACK_H - FISH_H)
				dart_timer = randf_range(1.2, 2.2)
			fish_pos = move_toward(fish_pos, fish_target, FISH_SPEED_LUNGE * delta)
		"dodger":
			# gentle drift, but bolts to the far edge whenever the bar covers it
			if last_overlap:
				var bar_center := bar_pos + bar_h * 0.5
				var away := FISH_H if fish_pos < bar_center else TRACK_H - FISH_H
				fish_pos = move_toward(fish_pos, away, FISH_SPEED_DODGE * delta)
			else:
				fish_phase += delta
				var drift := TRACK_H * 0.5 + sin(fish_phase * 0.5) * (TRACK_H * 0.25)
				fish_pos = move_toward(fish_pos, drift, FISH_SPEED_DRIFT * delta)
		"frenzy":
			# sine that speeds up as the fish's health drops (panics near escape)
			var h := escape / max_lives
			fish_phase += delta * (1.0 + (1.0 - h) * 4.0)
			fish_pos = TRACK_H * 0.5 + sin(fish_phase) * (TRACK_H * 0.38)
		_: # sine
			# smooth, predictable full-range oscillation
			fish_phase += delta
			fish_pos = TRACK_H * 0.5 + sin(fish_phase * 1.2) * (TRACK_H * 0.40)

func _finish(success: bool) -> void:
	if finished_emitted:
		return
	finished_emitted = true
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	finished.emit(success, item_name)
	queue_free()
