class_name ShowcaseView
extends Control
signal finished
const DURATION: float = 6.0
var snapshot: ShowcaseSnapshot
var elapsed: float = 0.0
var done: bool = false
var canvas: ShowcaseCanvas
var caption: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var column := UiFactory.page(self)
	column.custom_minimum_size.x = 850
	UiFactory.label(column, "PERFECT HEIST", 38)
	caption = UiFactory.label(column, "Four plans. One stolen day.", 20, UiFactory.CYAN)
	canvas = ShowcaseCanvas.new()
	canvas.snapshot = snapshot
	canvas.custom_minimum_size = Vector2(850, 360)
	column.add_child(canvas)
	UiFactory.button(column, "Skip showcase / continue", finish).grab_focus()
	UiFactory.label(column, "Recorded routes · presentation only · the mission is complete", 15, UiFactory.MUTED)

func _process(delta: float) -> void:
	if done:
		return
	if snapshot == null or snapshot.live_tape == null or snapshot.live_tape.duration_ticks == 0:
		finish()
		return
	elapsed += delta
	var fraction := clampf(elapsed / DURATION, 0, 1)
	canvas.frame_tick = mini(int(fraction * snapshot.live_tape.duration_ticks), snapshot.live_tape.duration_ticks - 1)
	caption.text = "Four plans. One stolen day." if fraction < 0.5 else ("Rook reaches the heart of the clock." if fraction < 0.8 else "A whole day, returned on time.")
	canvas.queue_redraw()
	if elapsed >= DURATION:
		finish()

func finish() -> void:
	if done:
		return
	done = true
	finished.emit()
