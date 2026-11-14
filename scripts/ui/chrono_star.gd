class_name ChronoStar
extends Node2D
var core: ResonanceTerminal

func _ready() -> void:
	z_index = 15
	visible = false

func reveal() -> void:
	visible = core != null and core.latched
	queue_redraw()

func _draw() -> void:
	if not visible:
		return
	draw_circle(Vector2.ZERO, 35, Color(0.96, 0.75, 0.42, 0.12))
	var points := PackedVector2Array()
	for index: int in range(16):
		points.append(Vector2.from_angle(-PI / 2 + TAU * index / 16.0) * (25 if index % 2 == 0 else 10))
	draw_colored_polygon(points, Color("f4be6c"))
	draw_circle(Vector2.ZERO, 7, Color("edf4ff"))
	draw_arc(Vector2.ZERO, 31, 0, TAU, 48, Color("74dbbb"), 2, true)
