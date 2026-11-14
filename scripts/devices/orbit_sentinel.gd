class_name OrbitSentinel
extends Node2D
@export var device_id: StringName = &"orb_a"
@export var rail_center := Vector2(760, 324)
@export var rail_radius: float = 80.0
@export var period_ticks: int = 600
const RADIUS: float = 16.0
const FREEZE_TICKS: int = 90
var rail_tick: int = 0
var freeze_until_tick: int = -1
var previous_position: Vector2
var frozen: bool = false

func _ready() -> void:
	global_position = rail_center + Vector2(rail_radius, 0)
	previous_position = global_position
	z_index = 8

func prepare_tick(tick: int) -> void:
	previous_position = global_position
	if tick > 0 and tick >= freeze_until_tick:
		rail_tick += 1
	var angle := TAU * float(rail_tick % period_ticks) / period_ticks
	global_position = rail_center + Vector2(cos(angle), sin(angle)) * rail_radius
	frozen = tick < freeze_until_tick
	queue_redraw()

func freeze(tick: int) -> void:
	freeze_until_tick = maxi(freeze_until_tick, tick + FREEZE_TICKS)
	frozen = true
	queue_redraw()

func hits_live(from: Vector2, to: Vector2) -> bool:
	var relative_from := from - previous_position
	var relative_to := to - global_position
	var motion := relative_to - relative_from
	var fraction := clampf(-relative_from.dot(motion) / maxf(motion.length_squared(), 0.00001), 0.0, 1.0)
	return (relative_from + motion * fraction).length_squared() <= pow(RADIUS + Rook.RADIUS, 2)

func _draw() -> void:
	var color := Color("58d7ef") if frozen else Color("ef8b9c")
	draw_circle(Vector2.ZERO, RADIUS + 5, Color(color, 0.12))
	draw_circle(Vector2.ZERO, RADIUS, Color(color, 0.5))
	draw_arc(Vector2.ZERO, RADIUS, 0, TAU, 24, color, 2, true)
	draw_line(Vector2(-8, 0), Vector2(8, 0), color, 2)
	draw_line(Vector2(0, -8), Vector2(0, 8), color, 2)
	if frozen:
		draw_string(ThemeDB.fallback_font, Vector2(-27, -24), "FROZEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)
