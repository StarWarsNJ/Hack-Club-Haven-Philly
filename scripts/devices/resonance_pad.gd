class_name ResonancePad
extends Node2D
signal active_changed
@export var device_id: StringName = &"pad_a"
@export var display_name: String = "A"
@export var radius: float = 28.0
var occupants := PackedInt32Array()
var active: bool = false

func evaluate(actors: Array[Dictionary]) -> void:
	var next := PackedInt32Array()
	for actor: Dictionary in actors:
		if global_position.distance_squared_to(actor["position"]) <= radius * radius:
			next.append(actor["id"])
	occupants = next
	var pressed := not occupants.is_empty()
	if active != pressed:
		active = pressed
		queue_redraw()
		active_changed.emit()

func _draw() -> void:
	var color := Color("58d7ef") if active else Color("d9ac5f")
	draw_circle(Vector2.ZERO, radius, Color(color, 0.18))
	draw_arc(Vector2.ZERO, radius, 0, TAU, 40, color, 3, true)
	draw_arc(Vector2.ZERO, radius - 7, 0, TAU, 32, color, 1, true)
	draw_string(ThemeDB.fallback_font, Vector2(-7, 6), display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, color)
	draw_string(ThemeDB.fallback_font, Vector2(-35, -39), "HOLD " + display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, color)
