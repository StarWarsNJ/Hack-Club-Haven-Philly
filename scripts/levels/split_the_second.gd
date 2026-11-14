extends MissionWorld
const PAD: PackedScene = preload("res://scenes/devices/resonance_pad.tscn")
const GATE: PackedScene = preload("res://scenes/devices/clock_gate.tscn")
const EXIT: PackedScene = preload("res://scenes/devices/mission_exit.tscn")
const BRIDGE: PackedScene = preload("res://scenes/devices/clockwork_bridge.tscn")

func _ready() -> void:
	super._ready()
	add_wall(Rect2(980, 130, 20, 114))
	add_wall(Rect2(980, 404, 20, 138))
	for index: int in range(2):
		var pad := PAD.instantiate() as ResonancePad
		pad.device_id = &"pad_a" if index == 0 else &"pad_b"
		pad.display_name = "A" if index == 0 else "B"
		pad.position = Vector2(232, 248) if index == 0 else Vector2(660, 430)
		add_child(pad)
		registry.register(pad)
		pad.active_changed.connect(queue_redraw)
		var bridge := BRIDGE.instantiate() as ClockworkBridge
		bridge.device_id = &"bridge_a" if index == 0 else &"bridge_b"
		bridge.display_name = pad.display_name
		bridge.required_pad_id = pad.device_id
		bridge.position = Vector2(485 if index == 0 else 835, 324)
		bridge.gap_rect = Rect2(410 if index == 0 else 760, 130, 150, 412)
		bridge.phase_offset = 0 if index == 0 else PI
		add_child(bridge)
		registry.register(bridge)
	var gate := GATE.instantiate() as ClockGate
	gate.position = Vector2(990, 324)
	gate.required_pad_ids = [&"pad_a", &"pad_b"]
	add_child(gate)
	registry.register(gate)
	var goal := EXIT.instantiate() as MissionExit
	goal.position = Vector2(1070, 324)
	add_child(goal)
	registry.register(goal)

func _draw() -> void:
	super._draw()
	for left: int in [410, 760]:
		draw_rect(Rect2(left, 130, 150, 412), Color("0c1022"))
		draw_line(Vector2(left + 75, 180), Vector2(left + 75, 500), Color("506080"), 2)
		for y: int in range(180, 501, 24):
			draw_line(Vector2(left + 65, y), Vector2(left + 85, y), Color("506080"), 1)
	draw_string(ThemeDB.fallback_font, Vector2(80, 510), "HOLD A", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("d9ac5f"))
	draw_string(ThemeDB.fallback_font, Vector2(580, 200), "PADS ALIGN THE BRIDGES", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("d9ac5f"))
