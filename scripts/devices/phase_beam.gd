class_name PhaseBeam
extends Node2D
@export var device_id: StringName = &"beam_a"
@export var required_pad_id: StringName = &"pad_a"
@export var danger_rect := Rect2(380, 132, 690, 398)
const PERIOD: int = 900
const SAFE_START: int = 180
const SAFE_END: int = 666
var phase: int = 0
var active: bool = true
var telegraph: bool = false

func prepare_tick(tick: int, pad_active: bool) -> void:
	phase = posmod(tick + (0 if pad_active else 300), PERIOD)
	var next_active := phase < SAFE_START or phase >= SAFE_END
	var next_telegraph := phase >= SAFE_END - 60 and phase < SAFE_END
	if active != next_active or telegraph != next_telegraph:
		active = next_active
		telegraph = next_telegraph
		queue_redraw()

func hits_live(from: Vector2, to: Vector2) -> bool:
	return active and SimulationGeometry.segment_hits_rect(from, to, danger_rect.grow(Rook.RADIUS))

func _draw() -> void:
	var color := Color("ef8b9c") if active else Color("58d7ef")
	if telegraph:
		color = Color("f4be6c")
	draw_rect(danger_rect, Color(color, 0.08))
	for y: int in range(int(danger_rect.position.y), int(danger_rect.end.y), 24):
		draw_line(Vector2(danger_rect.position.x, y), Vector2(danger_rect.end.x, y), Color(color, 0.30 if active else 0.07), 2)
	draw_rect(danger_rect, color, false, 2)
	draw_string(ThemeDB.fallback_font, Vector2(520, 155), "BEAM ACTIVE — WAIT" if active else ("SAFE WINDOW ENDING" if telegraph else "SAFE WINDOW — DASH THE STRAIGHTS"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
