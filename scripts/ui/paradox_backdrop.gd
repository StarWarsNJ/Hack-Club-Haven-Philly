class_name ParadoxBackdrop
extends Control
## Original static vector backdrop. Redraw only on layout changes.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("10162a"))
	for x: int in range(0, int(size.x), 48):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.18, 0.25, 0.4, 0.12), 1)
	var center := Vector2(size.x * 0.80, size.y * 0.5)
	var radius := minf(size.y * 0.42, 280)
	for ring: float in [1.0, 0.88, 0.70]:
		draw_arc(center, radius * ring, 0, TAU, 120, Color(0.85, 0.67, 0.37, 0.18), 2, true)
	for index: int in range(60):
		var direction := Vector2.from_angle(TAU * index / 60.0)
		draw_line(center + direction * (radius - (17 if index % 5 == 0 else 8)), center + direction * radius, Color(0.85, 0.67, 0.37, 0.25), 2 if index % 5 == 0 else 1)
	draw_line(center, center + Vector2.from_angle(-PI / 2) * radius * 0.60, Color(0.35, 0.85, 0.95, 0.20), 4, true)
	draw_line(center, center + Vector2.from_angle(0.5) * radius * 0.42, Color(0.85, 0.67, 0.37, 0.25), 5, true)
	for slot: int in range(4):
		var point := center + Vector2.from_angle(0.45 + slot * PI / 2) * radius * 0.88
		var color := Color(EchoPlayer.COLORS[slot], 0.5)
		draw_circle(point, 17, Color(color, 0.10))
		draw_arc(point, 17, 0, TAU, 32, color, 2, true)
		draw_string(ThemeDB.fallback_font, point + Vector2(-8, 5), str(slot + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, color)
	draw_line(Vector2(28, 28), Vector2(size.x - 28, 28), Color(0.85, 0.67, 0.37, 0.18), 1)
	draw_line(Vector2(28, size.y - 28), Vector2(size.x - 28, size.y - 28), Color(0.85, 0.67, 0.37, 0.18), 1)
