class_name EchoPlayer
extends Node2D
## No physics body, sensors or collision responses. Pose is always authoritative.
const COLORS: Array[Color] = [Color("58d7ef"), Color("ad82f5"), Color("f4be6c"), Color("74dbbb")]
var tape: EchoTape
var slot: int = 0
var active: bool = false
var facing := Vector2.RIGHT
var animation_state: int = 0
var reduce_flashes: bool = false
var _pulse_until: int = -1
var _last_tick: int = 0
var _trail := PackedVector2Array()

func configure(recording: EchoTape, slot_index: int) -> void:
	z_index = 9
	tape = recording
	slot = slot_index
	global_position = tape.initial_position
	if is_inside_tree():
		reset_physics_interpolation()
	modulate = COLORS[slot]

func play_tick(tick: int) -> void:
	_last_tick = tick
	active = tick < tape.duration_ticks
	if active:
		global_position = tape.position_at(tick)
		facing = tape.facing_at(tick)
		animation_state = tape.animation_at(tick)
		modulate.a = 0.7
		_trail.append(global_position)
		if _trail.size() > 9:
			_trail.remove_at(0)
	else:
		# Presence stops immediately. Twelve-tick visual fade cannot hold a pad.
		modulate.a = maxf(0.0, 0.7 * (1.0 - float(tick - tape.duration_ticks) / 12.0))
	visible = modulate.a > 0.0
	queue_redraw()

func _draw() -> void:
	if _last_tick < _pulse_until and not reduce_flashes:
		var fraction := 1.0 - float(_pulse_until - _last_tick) / 12.0
		draw_arc(Vector2.ZERO, 76.0 * fraction, 0, TAU, 40, Color(1, 1, 1, 1.0 - fraction), 2, true)
	for index: int in range(1, _trail.size()):
		draw_line(to_local(_trail[index - 1]), to_local(_trail[index]), Color(1, 1, 1, 0.18), 3, true)
	var outline := PackedVector2Array([Vector2(-13, 10), Vector2(-10, -10), Vector2(0, -16), Vector2(10, -10), Vector2(13, 10), Vector2(0, 15), Vector2(-13, 10)])
	draw_colored_polygon(outline, Color(1, 1, 1, 0.12))
	draw_polyline(outline, Color.WHITE, 2, true)
	draw_circle(Vector2.ZERO, 6, Color(1, 1, 1, 0.65))
	draw_line(Vector2.ZERO, facing * 20, Color.WHITE, 2, true)
	draw_string(ThemeDB.fallback_font, Vector2(-11, -22), "E%d" % (slot + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 16)

func show_pulse(tick: int) -> void:
	_pulse_until = tick + 12
	queue_redraw()
