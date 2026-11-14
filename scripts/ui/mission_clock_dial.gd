class_name MissionClockDial
extends Control
var completed_ticks: int = 0
var reduce_flashes: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(150, 82)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var center := Vector2(size.x / 2, 40)
	draw_arc(center, 36, 0, TAU, 64, Color("283654"), 3, true)
	var remaining := 1.0 - float(completed_ticks) / MissionClock.LIMIT
	if remaining > 0:
		draw_arc(center, 36, -PI / 2, -PI / 2 + TAU * remaining, 64, Color("58d7ef"), 3, true)
	var text := "0:%04.1f" % (float(MissionClock.LIMIT - completed_ticks) / MissionClock.HZ)
	var width := ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 23).x
	draw_string(ThemeDB.fallback_font, center + Vector2(-width / 2, 8), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, Color("edf4ff"))
	var alpha := 0.65 if reduce_flashes else 0.55 + 0.15 * sin(float(completed_ticks) / 18)
	draw_circle(center + Vector2(49, -8), 3, Color(0.95, 0.50, 0.57, alpha))
	draw_string(ThemeDB.fallback_font, center + Vector2(40, 10), "REC", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("aebbd2"))
