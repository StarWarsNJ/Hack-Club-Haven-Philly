class_name TimelineDirector
extends Control
signal resume_requested
signal retry_requested
signal remove_requested(slot: int)
signal undo_requested
var can_undo: bool = false
signal controls_requested
signal menu_requested
var bank: Array[EchoTape] = []
var live_tape: EchoTape
var review: bool = false
var selected_slot: int = -1
var details: Label
var remove_button: Button

func _ready() -> void:
	var column := UiFactory.page(self)
	column.custom_minimum_size.x = 850
	column.add_theme_constant_override("separation", 4)
	UiFactory.label(column, "TIMELINE DIRECTOR  /  TIME IS PAUSED", 26)
	column.add_child(TimelineAxis.new())
	for slot: int in range(4):
		var lane := TimelineLane.new()
		lane.actor_title = "E%d" % (slot + 1)
		lane.ink = EchoPlayer.COLORS[slot]
		lane.tape = bank[slot]
		column.add_child(lane)
	var live := TimelineLane.new()
	live.actor_title = "LIVE"
	live.tape = live_tape
	column.add_child(live)
	var selections := HBoxContainer.new()
	column.add_child(selections)
	for slot: int in range(4):
		var select := UiFactory.button(selections, "E%d detail" % (slot + 1), select_slot.bind(slot))
		select.disabled = bank[slot] == null
		if selected_slot < 0 and bank[slot] != null:
			selected_slot = slot
	details = UiFactory.label(column, "", 14, UiFactory.MUTED)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	UiFactory.button(actions, "Back to review" if review else "Resume", func() -> void: resume_requested.emit()).grab_focus()
	UiFactory.button(actions, "Restart unsaved run", func() -> void: retry_requested.emit())
	remove_button = UiFactory.button(actions, "Remove selected Echo", func() -> void: remove_requested.emit(selected_slot))
	var footer := HBoxContainer.new()
	column.add_child(footer)
	var undo := UiFactory.button(footer, "Undo last bank change", func() -> void: undo_requested.emit())
	undo.disabled = not can_undo
	UiFactory.button(footer, "View controls", func() -> void: controls_requested.emit())
	UiFactory.button(footer, "Return to menu", func() -> void: menu_requested.emit())
	UiFactory.label(column, "Dots mark pad entries/exits and accepted actions. Tapes are read-only; removal resets the live attempt.", 14, UiFactory.MUTED)
	select_slot(selected_slot)

func select_slot(slot: int) -> void:
	selected_slot = slot
	remove_button.disabled = slot < 0 or bank[slot] == null
	if remove_button.disabled:
		details.text = "No saved tape selected. Bank a route with Q during play."
	else:
		var tape := bank[slot]
		details.text = "E%d  ·  %.1fs  ·  %d pad events  ·  recorded route (read-only)" % [slot + 1, float(tape.duration_ticks) / MissionClock.HZ, tape.markers_copy().size()]
