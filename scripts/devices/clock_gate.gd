class_name ClockGate
extends StaticBody2D
signal state_changed
@export var device_id: StringName = &"gate_a"
@export var required_pad_ids: Array[StringName] = [&"pad_a"]
@export var required_terminal_ids: Array[StringName] = []
@export var gate_size := Vector2(20, 160)
@export var required_hold_ticks: int = 0
@export var grace_ticks: int = 0
var _display_tick: int = 0
var held_ticks: int = 0
var grace_until_tick: int = -1
var is_open: bool = false
var condition_active: bool = false
var closing_pending: bool = false
var collision: CollisionShape2D

func _ready() -> void:
	collision_layer = 1
	collision_mask = 2
	collision = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = gate_size
	collision.shape = shape
	add_child(collision)

func set_condition(condition: bool, live_position: Vector2) -> void:
	condition_active = condition
	# No crushing: a closing gate waits only for an already-overlapping Rook.
	# This is visible as CLEAR GATE; it does not satisfy objective conditions.
	var occupied := Rect2(global_position - gate_size / 2, gate_size).grow(Rook.RADIUS + 1).has_point(live_position)
	var pending := not condition and is_open and occupied
	var next := condition or pending
	if next != is_open or pending != closing_pending:
		is_open = next
		closing_pending = pending
		collision.set_deferred("disabled", is_open)
		queue_redraw()
		state_changed.emit()

func _draw() -> void:
	var rect := Rect2(-gate_size / 2, gate_size)
	var color := Color("58d7ef") if is_open else Color("d9ac5f")
	if closing_pending:
		color = Color("f4be6c")
	draw_rect(rect, Color(color, 0.12 if is_open else 0.6))
	draw_rect(rect, color, false, 2)
	if not is_open:
		for y: int in range(int(-gate_size.y / 2) + 8, int(gate_size.y / 2), 12):
			draw_line(Vector2(-gate_size.x / 2, y), Vector2(gate_size.x / 2, y), color, 2)
	var caption := "CLEAR GATE" if closing_pending else ("OPEN" if is_open else "LOCKED")
	if not closing_pending and is_open and grace_ticks > 0:
		caption = "OPEN %.1fs" % (float(maxi(0, grace_until_tick - _display_tick)) / MissionClock.HZ)
	elif not is_open and required_hold_ticks > 0:
		caption = "SYNC %.1f/%.1fs" % [float(held_ticks) / MissionClock.HZ, float(required_hold_ticks) / MissionClock.HZ]
	draw_string(ThemeDB.fallback_font, Vector2(-60, -gate_size.y / 2 - 15), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)

func evaluate_circuit(raw_condition: bool, tick: int, live_position: Vector2) -> void:
	_display_tick = tick
	if (required_hold_ticks > 0 or grace_ticks > 0) and tick % 6 == 0:
		queue_redraw()
	held_ticks = held_ticks + 1 if raw_condition else 0
	var qualified := raw_condition and held_ticks >= required_hold_ticks
	if qualified and grace_ticks > 0:
		grace_until_tick = tick + grace_ticks
	set_condition(qualified or tick < grace_until_tick, live_position)
