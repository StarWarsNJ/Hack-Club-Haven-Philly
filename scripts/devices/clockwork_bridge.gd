class_name ClockworkBridge
extends AnimatableBody2D
@export var device_id: StringName = &"bridge_a"
@export var required_pad_id: StringName = &"pad_a"
@export var display_name: String = "A"
@export var deck_size := Vector2(170, 96)
@export var gap_rect := Rect2(410, 130, 150, 412)
@export var phase_offset: float = 0.0
const PERIOD: int = 360
const AMPLITUDE: float = 96.0
const MAX_STEP: float = 4.0
var home_position: Vector2
var frame_delta := Vector2.ZERO
var stabilized: bool = false

func _ready() -> void:
	sync_to_physics = false # Explicit coordinator owns transform timing.
	collision_layer = 4
	collision_mask = 2
	z_index = 2
	home_position = global_position
	global_position.y = home_position.y + sin(phase_offset) * AMPLITUDE
	for side: int in [-1, 1]:
		var rail := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(deck_size.x, 8)
		rail.shape = shape
		rail.position.y = side * deck_size.y / 2
		add_child(rail)

func footprint() -> Rect2:
	return Rect2(global_position - deck_size / 2, deck_size)

func supports_live(point: Vector2) -> bool:
	return footprint().has_point(point)

func prepare_tick(tick: int, pad_active: bool) -> void:
	var previous := global_position
	stabilized = pad_active
	var target_y := home_position.y if pad_active else home_position.y + AMPLITUDE * sin(TAU * float(tick % PERIOD) / PERIOD + phase_offset)
	global_position.y = move_toward(global_position.y, target_y, MAX_STEP)
	frame_delta = global_position - previous
	queue_redraw()

func _draw() -> void:
	var color := Color("58d7ef") if stabilized else Color("d9ac5f")
	var rect := Rect2(-deck_size / 2, deck_size)
	draw_rect(rect, Color("283654"))
	draw_rect(rect, color, false, 3)
	for x: int in range(int(-deck_size.x / 2) + 8, int(deck_size.x / 2), 16):
		draw_line(Vector2(x, -deck_size.y / 2 + 8), Vector2(x, deck_size.y / 2 - 8), Color(color, 0.16), 1)
	draw_line(Vector2(-deck_size.x / 2, -deck_size.y / 2), Vector2(deck_size.x / 2, -deck_size.y / 2), color, 5)
	draw_line(Vector2(-deck_size.x / 2, deck_size.y / 2), Vector2(deck_size.x / 2, deck_size.y / 2), color, 5)
	draw_string(ThemeDB.fallback_font, Vector2(-55, 5), "BRIDGE " + display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
	draw_string(ThemeDB.fallback_font, Vector2(-45, 26), "STABLE" if stabilized else "6s CYCLE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
