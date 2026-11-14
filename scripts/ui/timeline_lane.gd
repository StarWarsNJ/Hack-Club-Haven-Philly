class_name TimelineLane
extends Control
var tape: EchoTape
var actor_title: String = ""
var ink: Color = Color.WHITE
var markers: Array[Dictionary] = []

func _ready() -> void:
	custom_minimum_size = Vector2(820, 40)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tape != null:
		markers = tape.markers_copy()
		for tick: int in range(tape.duration_ticks):
			markers.append_array(tape.actions_at(tick))

func _draw() -> void:
	var start := Vector2(120, 25)
	var width := maxf(size.x - 140, 100)
	draw_string(ThemeDB.fallback_font, Vector2(0, 22), actor_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, ink)
	draw_line(start, start + Vector2(width, 0), Color("506080"), 2)
	for seconds: int in range(0, 31, 5):
		var x := start.x + width * seconds / 30.0
		draw_line(Vector2(x, 18), Vector2(x, 30), Color("aebbd2"), 1)
	if tape == null:
		draw_string(ThemeDB.fallback_font, start + Vector2(10, -7), "empty", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("aebbd2"))
		return
	var length := width * tape.duration_ticks / MissionClock.LIMIT
	draw_rect(Rect2(start + Vector2(0, -5), Vector2(length, 10)), Color(ink, 0.45))
	for event: Dictionary in markers:
		var x := start.x + width * int(event["tick"]) / MissionClock.LIMIT
		draw_circle(Vector2(x, 25), 4, ink)
	draw_string(ThemeDB.fallback_font, Vector2(start.x + length + 3, 14), "%.1fs" % (float(tape.duration_ticks) / MissionClock.HZ), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ink)
