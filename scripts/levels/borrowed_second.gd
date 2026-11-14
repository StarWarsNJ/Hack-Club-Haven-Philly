extends MissionWorld
## Single-screen authored M1 layout. No scripted Echoes or automatic solutions.
const PAD: PackedScene = preload("res://scenes/devices/resonance_pad.tscn")
const GATE: PackedScene = preload("res://scenes/devices/clock_gate.tscn")
const EXIT: PackedScene = preload("res://scenes/devices/mission_exit.tscn")

func _ready() -> void:
	super._ready()
	add_wall(Rect2(450, 130, 16, 140))
	add_wall(Rect2(450, 378, 16, 164))
	add_wall(Rect2(790, 130, 20, 114))
	add_wall(Rect2(790, 404, 20, 138))
	var pad := PAD.instantiate() as ResonancePad
	pad.position = Vector2(232, 248)
	add_child(pad)
	registry.register(pad)
	pad.active_changed.connect(queue_redraw)
	var gate := GATE.instantiate() as ClockGate
	gate.position = Vector2(800, 324)
	add_child(gate)
	registry.register(gate)
	gate.state_changed.connect(queue_redraw)
	var goal := EXIT.instantiate() as MissionExit
	goal.position = Vector2(1030, 324)
	add_child(goal)
	registry.register(goal)

func _draw() -> void:
	super._draw()
	draw_rect(Rect2(450, 130, 16, 140), Color("506080"))
	draw_rect(Rect2(450, 378, 16, 164), Color("506080"))
	draw_rect(Rect2(790, 130, 20, 114), Color("506080"))
	draw_rect(Rect2(790, 404, 20, 138), Color("506080"))
	var lit := not registry.pads.is_empty() and registry.pads[0].active
	var trace := PackedVector2Array([Vector2(260, 248), Vector2(390, 248), Vector2(390, 180), Vector2(730, 180), Vector2(730, 238), Vector2(800, 238)])
	draw_polyline(trace, Color("58d7ef") if lit else Color("506080"), 3, true)
	draw_string(ThemeDB.fallback_font, Vector2(80, 510), "ENTRANCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("aebbd2"))
	draw_string(ThemeDB.fallback_font, Vector2(530, 510), "ECHOES PASS THROUGH WALLS", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("aebbd2"))
