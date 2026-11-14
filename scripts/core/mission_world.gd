class_name MissionWorld
extends Node2D
## Authored baseline. Reinstantiate this subtree when starting a new attempt.
const ROOK_SCENE: PackedScene = preload("res://scenes/actors/rook.tscn")
const PLAY_RECT := Rect2(24, 110, 1104, 452)
const ECHO_SCENE: PackedScene = preload("res://scenes/actors/echo.tscn")
var echoes: Array[EchoPlayer] = []
var camera: CameraPresentation
var highlight_active: bool = false
var highlight_position := Vector2.ZERO
var orchestra: EchoOrchestra
var registry := DeviceRegistry.new()
var wall_rects: Array[Rect2] = []
var spawn_point := Vector2(140, 324)
var rook: Rook

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_wall(Rect2(24, 110, 20, 452))
	add_wall(Rect2(1108, 110, 20, 452))
	add_wall(Rect2(24, 110, 1104, 20))
	add_wall(Rect2(24, 542, 1104, 20))
	rook = ROOK_SCENE.instantiate() as Rook
	rook.position = spawn_point
	rook.z_index = 10
	add_child(rook)
	rook.reset_physics_interpolation()
	camera = CameraPresentation.new()
	camera.position = Vector2(576, 324)
	camera.position_smoothing_enabled = false
	add_child(camera)
	orchestra = EchoOrchestra.new()
	add_child(orchestra)
	registry.resolver.activated.connect(orchestra.on_activation)
	registry.sync_achieved.connect(orchestra.on_sync)
	registry.sync_achieved.connect(func(_tick: int) -> void: camera.bump())

func add_wall(rect: Rect2) -> StaticBody2D:
	wall_rects.append(rect)
	var wall := StaticBody2D.new()
	wall.position = rect.get_center()
	wall.collision_layer = 1
	wall.collision_mask = 2
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	wall.add_child(collision)
	add_child(wall)
	return wall

func _draw() -> void:
	draw_rect(PLAY_RECT, Color("1a2340"))
	for x: int in range(64, 1108, 32):
		draw_line(Vector2(x, 130), Vector2(x, 542), Color(0.3, 0.4, 0.6, 0.12))
	for y: int in range(146, 542, 32):
		draw_line(Vector2(44, y), Vector2(1108, y), Color(0.3, 0.4, 0.6, 0.12))
	for wall_rect: Rect2 in wall_rects:
		draw_rect(wall_rect, Color("344560"))
		draw_line(wall_rect.position, wall_rect.position + Vector2(wall_rect.size.x, 0), Color("62758c"), 2)
	draw_rect(PLAY_RECT.grow(-10), Color("506080"), false, 3)
	if highlight_active:
		draw_arc(highlight_position, 42, 0, TAU, 40, Color("d9ac5f"), 3, true)
	draw_arc(spawn_point, 28, 0, TAU, 32, Color("d9ac5f"), 2, true)

func install_echoes(bank: Array[EchoTape]) -> void:
	for slot: int in range(bank.size()):
		if bank[slot] == null:
			continue
		var projection := ECHO_SCENE.instantiate() as EchoPlayer
		add_child(projection)
		projection.configure(bank[slot], slot)
		echoes.append(projection)

func play_echoes(tick: int) -> void:
	for projection: EchoPlayer in echoes:
		projection.play_tick(tick)

func actor_snapshot() -> Array[Dictionary]:
	var actors: Array[Dictionary] = []
	for projection: EchoPlayer in echoes:
		if projection.active:
			actors.append({"id": projection.slot, "position": projection.global_position})
	actors.append({"id": 4, "position": rook.global_position})
	return actors
