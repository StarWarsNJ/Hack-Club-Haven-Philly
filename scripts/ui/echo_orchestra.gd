class_name EchoOrchestra
extends Node2D
## Event responses only: no simulation state depends on audio or animation.
signal activation_presented(slot: int)
signal sync_presented(tick: int)
const CUES: Array[AudioStream] = [
	preload("res://assets/audio/echo_1.wav"), preload("res://assets/audio/echo_2.wav"),
	preload("res://assets/audio/echo_3.wav"), preload("res://assets/audio/echo_4.wav"),
]
const IMPRINT: AudioStream = preload("res://assets/audio/imprint.wav")
const SYNC: AudioStream = preload("res://assets/audio/sync.wav")
var reduce_flashes: bool = false
var audio_enabled: bool = true
var players: Array[AudioStreamPlayer] = []
var imprint_player: AudioStreamPlayer
var sync_player: AudioStreamPlayer
var sync_tick: int = -1000
var current_tick: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	# Headless validation has no audible output; keep the same event/visual path.
	# Dummy audio playback can outlive accelerated test teardown.
	audio_enabled = DisplayServer.get_name() != "headless"
	z_index = 20
	for cue: AudioStream in CUES:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		player.stream = cue
		player.volume_db = -12
		add_child(player)
		players.append(player)
	sync_player = AudioStreamPlayer.new()
	sync_player.bus = "SFX"
	sync_player.stream = SYNC
	sync_player.volume_db = -14
	add_child(sync_player)
	imprint_player = AudioStreamPlayer.new()
	imprint_player.bus = "SFX"
	imprint_player.stream = IMPRINT
	imprint_player.volume_db = -12
	add_child(imprint_player)

func on_activation(event: Dictionary) -> void:
	var actor_id: int = event["actor_id"]
	if actor_id >= 0 and actor_id < 4:
		if audio_enabled:
			players[actor_id].play()
		activation_presented.emit(actor_id)

func on_sync(tick: int) -> void:
	sync_tick = tick
	if audio_enabled:
		sync_player.play()
	sync_presented.emit(tick)
	queue_redraw()

func present_tick(tick: int) -> void:
	current_tick = tick
	if tick - sync_tick <= 46:
		queue_redraw()

func _draw() -> void:
	var age := current_tick - sync_tick
	if age >= 0 and age < 45:
		var alpha := 1.0 - float(age) / 45.0
		if not reduce_flashes:
			draw_arc(Vector2(576, 496), 24 + age * 0.5, PI, TAU, 32, Color(0.85, 0.67, 0.37, alpha), 2, true)
		draw_string(ThemeDB.fallback_font, Vector2(548, 531), "SYNC", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(0.85, 0.67, 0.37, alpha))

func play_imprint() -> void:
	if audio_enabled:
		imprint_player.play()

func _exit_tree() -> void:
	if is_instance_valid(imprint_player):
		imprint_player.stop()
		imprint_player.stream = null
	for player: AudioStreamPlayer in players:
		player.stop()
		player.stream = null
	if is_instance_valid(sync_player):
		sync_player.stop()
		sync_player.stream = null
