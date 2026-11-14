class_name MissionExit
extends Node2D
@export var device_id: StringName = &"exit"
@export var radius: float = 25.0
var available: bool = false

func accepts_live(live_position: Vector2, conditions: bool) -> bool:
	if available != conditions:
		available = conditions
		queue_redraw()
	return conditions and global_position.distance_squared_to(live_position) <= radius * radius

func _draw() -> void:
	var color := Color("74dbbb") if available else Color("aebbd2")
	draw_circle(Vector2.ZERO, radius, Color(color, 0.15))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, 3, true)
	draw_colored_polygon(PackedVector2Array([Vector2(-8, -13), Vector2(12, 0), Vector2(-8, 13)]), color)
	draw_string(ThemeDB.fallback_font, Vector2(-20, -38), "EXIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, color)
