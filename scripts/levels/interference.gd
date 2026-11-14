extends MissionWorld
const PAD: PackedScene = preload("res://scenes/devices/resonance_pad.tscn")
const GATE: PackedScene = preload("res://scenes/devices/clock_gate.tscn")
const EXIT: PackedScene = preload("res://scenes/devices/mission_exit.tscn")

func _ready() -> void:
	super._ready()
	add_wall(Rect2(840, 130, 20, 114))
	add_wall(Rect2(840, 404, 20, 138))
	for index: int in range(4):
		var pad := PAD.instantiate() as ResonancePad
		pad.device_id = [&"pad_a", &"pad_b", &"pad_c", &"pad_d"][index]
		pad.display_name = ["A", "B", "C", "D"][index]
		pad.position = [Vector2(240, 200), Vector2(240, 460), Vector2(640, 200), Vector2(640, 460)][index]
		add_child(pad)
		registry.register(pad)
		pad.active_changed.connect(queue_redraw)
	var gate := GATE.instantiate() as ClockGate
	gate.position = Vector2(850, 324)
	gate.required_pad_ids = [&"pad_a", &"pad_b", &"pad_c", &"pad_d"]
	add_child(gate)
	registry.register(gate)
	gate.state_changed.connect(queue_redraw)
	var goal := EXIT.instantiate() as MissionExit
	goal.position = Vector2(1030, 324)
	add_child(goal)
	registry.register(goal)

func _draw() -> void:
	super._draw()
	for pad: ResonancePad in registry.pads:
		draw_polyline(PackedVector2Array([pad.position, Vector2(780, pad.position.y), Vector2(780, 324), Vector2(840, 324)]), Color("58d7ef") if pad.active else Color("506080"), 2, true)
	draw_string(ThemeDB.fallback_font, Vector2(400, 320), "FOUR STATIONS / FOUR ROLES", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d9ac5f"))
	draw_string(ThemeDB.fallback_font, Vector2(330, 510), "TAB: INSPECT / REMOVE / UNDO   —   FULL BANK: CHOOSE REPLACEMENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("aebbd2"))
