extends MissionWorld
const TERMINAL: PackedScene = preload("res://scenes/devices/resonance_terminal.tscn")
const GATE: PackedScene = preload("res://scenes/devices/clock_gate.tscn")
const EXIT: PackedScene = preload("res://scenes/devices/mission_exit.tscn")

func _ready() -> void:
	super._ready()
	add_wall(Rect2(840, 130, 20, 114))
	add_wall(Rect2(840, 404, 20, 138))
	for index: int in range(3):
		var terminal := TERMINAL.instantiate() as ResonanceTerminal
		terminal.device_id = [&"north", &"south", &"master"][index]
		terminal.display_name = ["NORTH", "SOUTH", "MASTER"][index]
		terminal.position = [Vector2(180, 180), Vector2(180, 480), Vector2(980, 324)][index]
		if index == 2:
			terminal.live_only = true
			terminal.one_shot = true
			terminal.required_terminal_ids = [&"north", &"south"]
			terminal.require_distinct_actors = true
		add_child(terminal)
		registry.register(terminal)
		terminal.state_changed.connect(queue_redraw)
	var gate := GATE.instantiate() as ClockGate
	gate.position = Vector2(850, 324)
	gate.required_pad_ids = []
	gate.required_terminal_ids = [&"north", &"south"]
	add_child(gate)
	registry.register(gate)
	gate.state_changed.connect(queue_redraw)
	var goal := EXIT.instantiate() as MissionExit
	goal.position = Vector2(1060, 324)
	add_child(goal)
	registry.register(goal)
	registry.required_goal_terminal_ids = [&"master"]

func _draw() -> void:
	super._draw()
	for id: StringName in [&"north", &"south"]:
		var terminal := registry.devices.get(id) as ResonanceTerminal
		if terminal != null:
			var trace := PackedVector2Array([terminal.position, Vector2(740, terminal.position.y), Vector2(740, 324), Vector2(840, 324)])
			draw_polyline(trace, Color("58d7ef") if terminal.is_charged(terminal._display_tick) else Color("506080"), 3, true)
	draw_string(ThemeDB.fallback_font, Vector2(390, 180), "TWO ACTORS / OVERLAPPING 4s CHARGES", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d9ac5f"))
