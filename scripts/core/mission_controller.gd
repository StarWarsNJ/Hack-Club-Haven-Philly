extends Control
signal navigate(route: String)

var overlay: Control
var paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var column := UiFactory.page(self)
	UiFactory.label(column, "M1  /  BORROWED SECOND", 38)
	UiFactory.label(column, "THE VAULT OF TOMORROW", 22, UiFactory.BRASS)
	UiFactory.label(column, "Mission staging area\n\nRook and the first Echo puzzle arrive in the next milestones.\nFor now, explore the menu and pause controls.", 20, UiFactory.MUTED)
	UiFactory.button(column, "Pause  /  Esc", handle_cancel).grab_focus()
	UiFactory.button(column, "Return to menu", func() -> void: navigate.emit("menu"))

func handle_cancel() -> void:
	if paused:
		resume()
		return
	paused = true
	get_tree().paused = true
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var column := UiFactory.page(overlay)
	UiFactory.label(column, "TIME, HELD", 40)
	UiFactory.label(column, "Mission paused", 20, UiFactory.CYAN)
	UiFactory.button(column, "Resume", resume).grab_focus()
	UiFactory.button(column, "Return to menu", func() -> void: navigate.emit("menu"))

func resume() -> void:
	paused = false
	get_tree().paused = false
	if is_instance_valid(overlay):
		remove_child(overlay)
		overlay.queue_free()
