class_name TapePreview
extends Control
var tape: EchoTape
var _path := PackedVector2Array()

func _ready() -> void:
	custom_minimum_size = Vector2(640, 120)
	if tape == null or tape.duration_ticks == 0:
		return
	var minimum := tape.initial_position
	var maximum := tape.initial_position
	var positions := tape.positions_copy()
	for point: Vector2 in positions:
		minimum = minimum.min(point)
		maximum = maximum.max(point)
	var extent := (maximum - minimum).max(Vector2(80, 80)) + Vector2(40, 40)
	var factor := minf(580.0 / extent.x, 90.0 / extent.y)
	var offset := Vector2(320, 60) - (minimum + maximum) * 0.5 * factor
	for index: int in range(0, positions.size(), maxi(1, positions.size() / 120)):
		_path.append(positions[index] * factor + offset)
	_path.append(positions[-1] * factor + offset)

func _draw() -> void:
	if _path.size() < 2:
		return
	draw_polyline(_path, Color("58d7ef"), 3, true)
	draw_circle(_path[0], 7, Color("d9ac5f"))
	draw_arc(_path[-1], 13, 0, TAU, 32, Color("58d7ef"), 3, true)
	draw_string(ThemeDB.fallback_font, _path[-1] + Vector2(20, 5), "E1", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("58d7ef"))
