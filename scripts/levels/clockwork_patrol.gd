extends MissionWorld
const PAD: PackedScene = preload("res://scenes/devices/resonance_pad.tscn")
const GATE: PackedScene = preload("res://scenes/devices/clock_gate.tscn")
const EXIT: PackedScene = preload("res://scenes/devices/mission_exit.tscn")
const ORB: PackedScene = preload("res://scenes/devices/orbit_sentinel.tscn")

func _ready() -> void:
	super._ready()
	add_wall(Rect2(590, 130, 20, 114))
	add_wall(Rect2(590, 404, 20, 138))
	add_wall(Rect2(620, 130, 280, 162))
	add_wall(Rect2(620, 356, 280, 186))
	var pad := PAD.instantiate() as ResonancePad
	pad.position = Vector2(232, 248)
	add_child(pad)
	registry.register(pad)
	pad.active_changed.connect(queue_redraw)
	var gate := GATE.instantiate() as ClockGate
	gate.position = Vector2(600, 324)
	add_child(gate)
	registry.register(gate)
	gate.state_changed.connect(queue_redraw)
	var goal := EXIT.instantiate() as MissionExit
	goal.position = Vector2(1030, 324)
	add_child(goal)
	registry.register(goal)
	var sentinel := ORB.instantiate() as OrbitSentinel
	add_child(sentinel)
	registry.register(sentinel)
	rook.z_index = 10

func _draw() -> void:
	super._draw()
	draw_arc(Vector2(760, 324), 80, 0, TAU, 96, Color("d9ac5f"), 1, true)
	draw_polyline(PackedVector2Array([Vector2(260, 248), Vector2(540, 248), Vector2(600, 244)]), Color("58d7ef") if not registry.pads.is_empty() and registry.pads[0].active else Color("506080"), 2, true)
	draw_arc(Vector2(678, 313), 18, 0, TAU, 24, Color("74dbbb"), 2, true)
	draw_string(ThemeDB.fallback_font, Vector2(630, 270), "PULSE HERE AT 4s", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("74dbbb"))
	draw_string(ThemeDB.fallback_font, Vector2(90, 500), "SPACE: RANGE 76 / FREEZE 1.5s / COOLDOWN 3.5s", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("aebbd2"))
