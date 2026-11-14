class_name TimelineAxis
extends Control

func _ready() -> void:
	custom_minimum_size = Vector2(820, 20)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	draw_string(ThemeDB.fallback_font, Vector2(0, 15), "seconds", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, UiFactory.MUTED)
	var width := maxf(size.x - 140, 100)
	for seconds: int in range(0, 31, 5):
		var text := str(seconds)
		var label_width := ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		draw_string(ThemeDB.fallback_font, Vector2(120 + width * seconds / 30.0 - label_width / 2, 15), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, UiFactory.MUTED)
