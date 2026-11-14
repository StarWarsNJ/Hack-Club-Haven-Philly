extends MissionWorld
const PAD: PackedScene = preload("res://scenes/devices/resonance_pad.tscn")
const GATE: PackedScene = preload("res://scenes/devices/clock_gate.tscn")
const EXIT: PackedScene = preload("res://scenes/devices/mission_exit.tscn")

func _ready() -> void:
	super._ready()
	add_wall(Rect2(890, 130, 20, 114))
	add_wall(Rect2(890, 404, 20, 138))
	for index: int in range(2):
		var pad := PAD.instantiate() as ResonancePad
		pad.device_id = &"pad_a" if index == 0 else &"pad_b"
		pad.display_name = "A" if index == 0 else "B"
		pad.position = Vector2(232, 220) if index == 0 else Vector2(660, 420)
		add_child(pad)
		registry.register(pad)
		pad.active_changed.connect(queue_redraw)
	var gate := GATE.instantiate() as ClockGate
	gate.position = Vector2(900, 324)
	gate.required_pad_ids = [&"pad_a", &"pad_b"]
	gate.required_hold_ticks = 60
	gate.grace_ticks = 300
	add_child(gate)
	registry.register(gate)
	gate.state_changed.connect(queue_redraw)
	var goal := EXIT.instantiate() as MissionExit
	goal.position = Vector2(1030, 324)
	add_child(goal)
	registry.register(goal)

func _draw() -> void:
	super._draw()
	for index: int in range(registry.pads.size()):
		var pad := registry.pads[index]
		var trace := PackedVector2Array([pad.position, Vector2(820, pad.position.y), Vector2(820, 324), Vector2(890, 324)])
		draw_polyline(trace, Color("58d7ef") if pad.active else Color("506080"), 3, true)
	draw_string(ThemeDB.fallback_font, Vector2(480, 180), "A + B   /   HOLD 1s   /   GRACE 5s", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("d9ac5f"))
