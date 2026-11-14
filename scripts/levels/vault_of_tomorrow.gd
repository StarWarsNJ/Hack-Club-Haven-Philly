extends MissionWorld
const PAD: PackedScene = preload("res://scenes/devices/resonance_pad.tscn")
const CORE: PackedScene = preload("res://scenes/devices/resonance_terminal.tscn")
const EXIT: PackedScene = preload("res://scenes/devices/mission_exit.tscn")
const CONDUCTOR: PackedScene = preload("res://scenes/devices/conductor_node.tscn")

func _ready() -> void:
	super._ready()
	for index: int in range(4):
		var pad := PAD.instantiate() as ResonancePad
		pad.device_id = [&"pad_a", &"pad_b", &"pad_c", &"pad_d"][index]
		pad.display_name = ["A", "B", "C", "D"][index]
		pad.position = [Vector2(240, 190), Vector2(240, 470), Vector2(840, 190), Vector2(840, 470)][index]
		add_child(pad)
		registry.register(pad)
		pad.active_changed.connect(queue_redraw)
	var core := CORE.instantiate() as ResonanceTerminal
	core.device_id = &"core"
	core.display_name = "CORE"
	core.position = Vector2(640, 324)
	core.live_only = true
	core.one_shot = true
	core.externally_enabled = false
	core.actor_requirement_label = "4 STATIONS"
	core.exit_window_ticks = 300
	add_child(core)
	registry.register(core)
	core.state_changed.connect(queue_redraw)
	var star := ChronoStar.new()
	star.position = core.position
	star.core = core
	add_child(star)
	core.state_changed.connect(star.reveal)
	var conductor := CONDUCTOR.instantiate() as ConductorNode
	conductor.position = core.position
	add_child(conductor)
	registry.register(conductor)
	var goal := EXIT.instantiate() as MissionExit
	goal.position = Vector2(1060, 324)
	add_child(goal)
	registry.register(goal)
	registry.required_goal_terminal_ids = [&"core"]

func _draw() -> void:
	super._draw()
	var core := registry.devices.get(&"core") as ResonanceTerminal
	var freed := core != null and core.latched
	draw_arc(Vector2(640, 324), 155, 0, TAU, 96, Color("74dbbb") if freed else Color("d9ac5f"), 2, true)
	for pad: ResonancePad in registry.pads:
		draw_line(pad.position, Vector2(640, 324), Color("58d7ef") if pad.active else Color("506080"), 2, true)
	draw_string(ThemeDB.fallback_font, Vector2(450, 155), "THE STOLEN DAY" if not freed else "TOMORROW IS YOURS — REACH EXIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("d9ac5f") if not freed else Color("74dbbb"))
