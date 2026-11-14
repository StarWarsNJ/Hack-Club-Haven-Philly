extends Control
## Persistent application shell; profile/settings are injected into each screen.
const SCREENS: Dictionary = {
	"menu": preload("res://scenes/ui/main_menu.tscn"),
	"settings": preload("res://scenes/ui/settings.tscn"),
	"select": preload("res://scenes/ui/mission_select.tscn"),
	"help": preload("res://scenes/ui/help.tscn"),
	"mission": preload("res://scenes/game/mission_session.tscn"),
}
const MUSIC: AudioStreamWAV = preload("res://assets/audio/clockwork_loop.wav")
var music_player: AudioStreamPlayer
var progress: ProgressStore
var current_mission_id: String = "M1"
var screen: Control
var current_route: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiFactory.make_theme()
	for bus_name: String in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	if progress == null:
		progress = ProgressStore.new()
	progress.load_from_disk()
	DisplayServer.window_set_title("PARADOX HEIST")
	create_music()
	apply_settings()
	show_screen("menu")

func show_screen(route: String) -> void:
	if current_route == "settings":
		progress.save_to_disk()
	if route == "mission":
		current_mission_id = progress.continue_id()
	elif route.begins_with("mission:"):
		current_mission_id = route.trim_prefix("mission:")
		route = "mission"
	if route == "mission" and not progress.is_unlocked(current_mission_id):
		route = "select"
	if not SCREENS.has(route):
		return
	get_tree().paused = false
	if is_instance_valid(screen):
		remove_child(screen)
		screen.queue_free()
	current_route = route
	screen = (SCREENS[route] as PackedScene).instantiate() as Control
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if route == "mission":
		screen.configure(current_mission_id, progress.settings)
	elif route in ["menu", "settings", "select"]:
		screen.configure(progress)
	add_child(screen)
	screen.navigate.connect(show_screen)
	if route == "settings":
		screen.preferences_changed.connect(func() -> void: apply_settings(true))
	elif route == "mission":
		screen.mission_completed.connect(on_mission_completed)

func on_mission_completed(result: Dictionary) -> void:
	progress.record_result(result["mission_id"], result["ticks"], result["echo_count"], result["echo_budget"])

func apply_settings(from_user_gesture: bool = false) -> void:
	for bus_name: String in ["Master", "Music", "SFX"]:
		var index := AudioServer.get_bus_index(bus_name)
		var value: float = progress.settings[bus_name.to_lower() + "_volume"]
		AudioServer.set_bus_mute(index, value <= 0)
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))
	if DisplayServer.get_name() != "headless" and (not OS.has_feature("web") or from_user_gesture):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if progress.settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED)
	if is_instance_valid(music_player):
		var audible: bool = DisplayServer.get_name() != "headless" and progress.settings["master_volume"] > 0 and progress.settings["music_volume"] > 0
		if audible and not music_player.playing:
			music_player.play()
		elif not audible:
			music_player.stop()
	if current_route == "mission" and is_instance_valid(screen):
		screen.apply_preferences(progress.settings)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and screen.has_method("handle_cancel"):
		screen.handle_cancel()
		get_viewport().set_input_as_handled()

func create_music() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_PAUSABLE
	music_player.bus = "Music"
	music_player.volume_db = -22
	var loop := MUSIC.duplicate() as AudioStreamWAV
	loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	loop.loop_begin = 0
	loop.loop_end = int(loop.get_length() * loop.mix_rate)
	music_player.stream = loop
	add_child(music_player)

func _notification(what: int) -> void:
	if current_route != "mission" and is_instance_valid(music_player):
		if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
			music_player.stream_paused = true
		elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
			music_player.stream_paused = false

func _exit_tree() -> void:
	if is_instance_valid(music_player):
		music_player.stop()
		music_player.stream = null
