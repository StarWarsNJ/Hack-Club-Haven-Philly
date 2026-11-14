extends Control
## Persistent application shell. Screens request routes; they do not change scenes.

const SCREENS: Dictionary = {
	"menu": preload("res://scenes/ui/main_menu.tscn"),
	"settings": preload("res://scenes/ui/settings.tscn"),
	"help": preload("res://scenes/ui/help.tscn"),
	"mission": preload("res://scenes/game/mission_session.tscn"),
}
var screen: Control
var current_route: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	theme = UiFactory.make_theme()
	for bus_name: String in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	show_screen("menu")

func show_screen(route: String) -> void:
	if not SCREENS.has(route):
		return
	get_tree().paused = false
	if is_instance_valid(screen):
		remove_child(screen)
		screen.queue_free()
	current_route = route
	screen = (SCREENS[route] as PackedScene).instantiate() as Control
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)
	screen.navigate.connect(show_screen)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and screen.has_method("handle_cancel"):
		screen.handle_cancel()
		get_viewport().set_input_as_handled()
