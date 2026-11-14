class_name Rook
extends CharacterBody2D
## Only the mission coordinator calls step(); this actor owns no clock.
const SPEED: float = 230.0
const RADIUS: float = 12.0
const DASH_TICKS: int = 10 # Rounded from suggested 0.16s to 10/60s.
const DASH_SPEED: float = 550.0
const DASH_COOLDOWN: int = 102
var pulse_enabled: bool = false
var interact_ready_tick: int = 0
var pulse_ready_tick: int = 0
var reduce_flashes: bool = false
var _pulse_until: int = -1
var _last_tick: int = 0
var dash_enabled: bool = false
var dash_ready_tick: int = 0
var dash_until_tick: int = -1
var dash_direction := Vector2.RIGHT
var trail := PackedVector2Array()
var facing: Vector2 = Vector2.RIGHT
var animation_state: int = 0
var previous_position: Vector2

func step(direction: Vector2, tick: int = 0, dash_requested: bool = false) -> void:
	_last_tick = tick
	previous_position = global_position
	var move_direction := direction.limit_length(1.0)
	if dash_enabled and dash_requested and tick >= dash_ready_tick:
		dash_direction = move_direction if not move_direction.is_zero_approx() else facing
		dash_until_tick = tick + DASH_TICKS
		dash_ready_tick = tick + DASH_COOLDOWN
	var dashing := tick < dash_until_tick
	velocity = dash_direction * DASH_SPEED if dashing else move_direction * SPEED
	if not move_direction.is_zero_approx():
		facing = move_direction
	animation_state = 1 if not move_direction.is_zero_approx() else 0
	if dashing:
		facing = dash_direction
		animation_state = 2
		trail.append(global_position)
		if trail.size() > 8:
			trail.remove_at(0)
	elif not trail.is_empty():
		trail.remove_at(0)
	move_and_slide()
	queue_redraw()

func _draw() -> void:
	if _last_tick < _pulse_until and not reduce_flashes:
		var fraction := 1.0 - float(_pulse_until - _last_tick) / 12.0
		draw_arc(Vector2.ZERO, 76.0 * fraction, 0, TAU, 40, Color(0.35, 0.85, 1.0, 1.0 - fraction), 2, true)
	for index: int in range(1, trail.size()):
		draw_line(to_local(trail[index - 1]), to_local(trail[index]), Color(0.35, 0.85, 1.0, 0.25), 5, true)
	draw_string(ThemeDB.fallback_font, Vector2(-15, -27), "LIVE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("edf4ff"))
	draw_circle(Vector2(0, 9), 15, Color(0, 0, 0, 0.3))
	draw_colored_polygon(PackedVector2Array([Vector2(-13, 10), Vector2(-10, -10), Vector2(0, -16), Vector2(10, -10), Vector2(13, 10), Vector2(0, 15)]), Color("547bc4"))
	draw_circle(Vector2.ZERO, 8, Color("edf4ff"))
	draw_line(facing * 5, facing * 20, Color("58d7ef"), 3, true)
	draw_circle(facing * 20, 3, Color("58d7ef"))

func show_pulse(tick: int) -> void:
	_pulse_until = tick + 12
	queue_redraw()
