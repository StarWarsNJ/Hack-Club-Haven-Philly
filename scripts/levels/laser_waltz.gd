extends MissionWorld
const PAD: PackedScene = preload("res://scenes/devices/resonance_pad.tscn")
const GATE: PackedScene = preload("res://scenes/devices/clock_gate.tscn")
const EXIT: PackedScene = preload("res://scenes/devices/mission_exit.tscn")
const BEAM: PackedScene = preload("res://scenes/devices/phase_beam.tscn")

func _ready() -> void:
	super._ready()
	# Serpentine crossing has no safe waiting pocket inside the beam field.
	add_wall(Rect2(360, 130, 20, 10))
	add_wall(Rect2(360, 240, 20, 302))
	add_wall(Rect2(380, 236, 614, 32))
	add_wall(Rect2(480, 380, 590, 32))
	add_wall(Rect2(1070, 130, 38, 282))
	var pad := PAD.instantiate() as ResonancePad
	pad.position = Vector2(232, 180)
	add_child(pad)
	registry.register(pad)
	var gate := GATE.instantiate() as ClockGate
	gate.position = Vector2(370, 190)
	gate.gate_size = Vector2(20, 100)
	add_child(gate)
	registry.register(gate)
	var goal := EXIT.instantiate() as MissionExit
	goal.position = Vector2(1090, 468)
	add_child(goal)
	registry.register(goal)
	var beam := BEAM.instantiate() as PhaseBeam
	add_child(beam)
	registry.register(beam)
	rook.z_index = 10

func _draw() -> void:
	super._draw()
	draw_polyline(PackedVector2Array([Vector2(250, 180), Vector2(300, 180), Vector2(300, 142), Vector2(350, 142)]), Color("d9ac5f"), 2, true)
	var path := PackedVector2Array([Vector2(410, 210), Vector2(1012, 210), Vector2(1012, 268), Vector2(460, 360), Vector2(460, 412), Vector2(496, 448), Vector2(1040, 448)])
	draw_polyline(path, Color(0.35, 0.5, 0.7, 0.35), 2, true)
	draw_string(ThemeDB.fallback_font, Vector2(70, 500), "SHIFT: 0.17s DASH / 1.7s COOLDOWN", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("aebbd2"))
