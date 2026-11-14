extends Control
signal navigate(route: String)
signal mission_completed(result: Dictionary)
const TIMELINE_SCENE: PackedScene = preload("res://scenes/ui/timeline_director.tscn")
const SHOWCASE_SCENE: PackedScene = preload("res://scenes/ui/showcase_view.tscn")
var preferences: Dictionary = ProgressStore.DEFAULT_SETTINGS.duplicate(true)
var ui_root: Control
var hint_level: int = 0
var _hint_active: bool = false
var _hint_return: TimeLoopController.State = TimeLoopController.State.RUNNING
var _hint_from_timeline: bool = false
var _leave_pending: bool = false
var _leave_return: TimeLoopController.State = TimeLoopController.State.RUNNING
var _leave_from_timeline: bool = false
var _last_failure: String = ""
var last_result: Dictionary = {}
var winning_tape: EchoTape
var _echo_reveal_seen: bool = false
var _echo_reveal_active: bool = false
var _intro_active: bool = false
var definition: MissionDefinition = MissionCatalog.find("M1")
var _timeline_viewing: bool = false
var _timeline_return: TimeLoopController.State = TimeLoopController.State.RUNNING
var _removal_slot: int = -1
var _undo_pending: bool = false
var overlay: Control
var loop := TimeLoopController.new()
var world: MissionWorld
var hud: MissionHUD
var clock: MissionClock:
	get: return loop.clock
var paused: bool:
	get: return loop.state != TimeLoopController.State.RUNNING

func configure(id: String, options: Dictionary = {}) -> void:
	preferences.merge(options, true)
	definition = MissionCatalog.find(id)
	loop.capacity = definition.echo_capacity

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var background := ColorRect.new()
	background.color = UiFactory.INK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background_layer := CanvasLayer.new()
	background_layer.layer = -10
	add_child(background_layer)
	background_layer.add_child(background)
	create_world()
	var interface_layer := CanvasLayer.new()
	interface_layer.layer = 10
	add_child(interface_layer)
	ui_root = Control.new()
	ui_root.theme = UiFactory.make_theme()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	interface_layer.add_child(ui_root)
	hud = MissionHUD.new()
	ui_root.add_child(hud)
	hud.hint_requested.connect(request_hint)
	hud.pause_requested.connect(handle_cancel)
	hud.hint.text = "WASD / arrows  Move   ·   Q  Bank   ·   R  Retry   ·   Tab / Esc  Pause"
	hud.update_bank(loop.bank)
	hud.set_mission(definition)
	hud.update_clock(clock)
	hud.update_abilities(world.rook, 0)
	hud.status.text = definition.hint_before_bank if preferences["show_hints"] else ""
	apply_preferences(preferences)
	if not definition.intro_lines.is_empty():
		show_intro()

func create_world() -> void:
	if is_instance_valid(world):
		remove_child(world)
		world.queue_free()
	world = definition.world_scene.instantiate() as MissionWorld
	add_child(world)
	if get_child_count() > 1:
		move_child(world, 1)
	world.rook.dash_enabled = definition.dash_enabled
	world.rook.pulse_enabled = definition.pulse_enabled
	world.install_echoes(loop.bank)
	world.registry.prepare_tick(0, world.rook)
	loop.reset_attempt(world.rook.global_position)
	apply_preferences(preferences)

func _physics_process(_delta: float) -> void:
	if not paused:
		simulate_tick(Input.get_vector("move_left", "move_right", "move_up", "move_down"), {"dash": Input.is_action_just_pressed("dash"), "pulse": Input.is_action_just_pressed("temporal_pulse"), "interact": Input.is_action_just_pressed("interact")})

func simulate_tick(direction: Vector2, requests: Dictionary = {}) -> void:
	if paused or clock.paused or clock.completed_ticks >= MissionClock.LIMIT:
		return
	# One explicit fixed-tick ordering; future devices plug into these phases.
	var tick := clock.completed_ticks
	var before_environment := world.rook.global_position
	world.registry.prepare_tick(tick, world.rook)
	world.rook.step(direction, tick, requests.get("dash", false))
	if world.rook.animation_state == 2 and tick == world.rook.dash_until_tick - Rook.DASH_TICKS:
		world.camera.bump(1.5)
	world.rook.previous_position = before_environment
	world.play_echoes(tick)
	var accepted := world.registry.resolve_actions(world.echoes, world.rook, requests, tick)
	var markers := world.registry.evaluate(world.actor_snapshot(), world.rook.global_position, tick)
	var live_markers: Array[Dictionary] = []
	for marker: Dictionary in markers:
		if marker["actor_id"] == 4:
			live_markers.append(marker)
	loop.finish_tick(world.rook.global_position, world.rook.facing, world.rook.animation_state, accepted, live_markers)
	world.orchestra.present_tick(tick)
	var failure := world.registry.failure_reason(world.rook.previous_position, world.rook.global_position)
	if not failure.is_empty():
		fail_attempt(failure)
		return
	if world.registry.goal != null and world.registry.goal.accepts_live(world.rook.global_position, world.registry.goal_conditions()):
		complete_mission()
		return
	if loop.bank_count() == 0:
		hud.status.text = definition.hint_before_bank if preferences["show_hints"] else ""
	else:
		hud.status.text = world.registry.last_explanation if not world.registry.last_explanation.is_empty() else (definition.hint_after_bank if preferences["show_hints"] else "")
	if not world.registry.terminals.is_empty():
		hud.status.text = world.registry.charge_status(tick) + "  ·  E: activate within the marked circle"
	hud.update_clock(clock)
	hud.update_abilities(world.rook, tick)
	if loop.state == TimeLoopController.State.REVIEW:
		show_review()

func _input(event: InputEvent) -> void:
	if _intro_active or _echo_reveal_active:
		return
	if event.is_echo():
		return
	if event.is_action_pressed("timeline"):
		if loop.state == TimeLoopController.State.BANK_CONFIRM or _removal_slot >= 0 or _undo_pending or _hint_active or _leave_pending or loop.state in [TimeLoopController.State.COMPLETED, TimeLoopController.State.FAILED]:
			return # Let Tab navigate the confirmation buttons.
		if _timeline_viewing:
			close_timeline()
		else:
			open_timeline()
	elif event.is_action_pressed("hint"):
		request_hint()
	elif event.is_action_pressed("retry_attempt"):
		retry()
	elif event.is_action_pressed("bank_echo"):
		request_bank()
	else:
		return
	get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(world) and not paused:
		show_pause("TIME, HELD", "Focus lost. Resume when you are ready.")

func handle_cancel() -> void:
	if _echo_reveal_active:
		skip_echo_reveal()
		return
	if _leave_pending:
		cancel_menu()
		return
	if _hint_active:
		close_hint()
		return
	if loop.state == TimeLoopController.State.COMPLETED:
		if overlay is ShowcaseView:
			(overlay as ShowcaseView).finish()
		else:
			navigate.emit("select")
		return
	if _intro_active:
		skip_intro()
		return
	if _undo_pending:
		cancel_undo()
		return
	if _removal_slot >= 0:
		cancel_remove()
		return
	if _timeline_viewing:
		close_timeline()
		return
	match loop.state:
		TimeLoopController.State.RUNNING:
			show_pause("TIME, HELD", "Mission paused")
		TimeLoopController.State.PAUSED:
			resume()
		TimeLoopController.State.BANK_CONFIRM:
			cancel_bank()

func panel(title: String, message: String) -> VBoxContainer:
	get_tree().paused = true
	clear_overlay()
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.add_child(overlay)
	var column := UiFactory.page(overlay)
	UiFactory.label(column, title, 38)
	UiFactory.label(column, message, 18, UiFactory.CYAN)
	return column

func show_pause(title: String, message: String) -> void:
	loop.set_state(TimeLoopController.State.PAUSED)
	var column := panel(title, message)
	UiFactory.label(column, bank_summary(), 18, UiFactory.MUTED)
	UiFactory.button(column, "Resume", resume).grab_focus()
	UiFactory.button(column, "Timeline Director / Tab", open_timeline)
	if preferences["show_hints"]:
		UiFactory.button(column, "Progressive hint / H", request_hint)
	UiFactory.button(column, "Retry unsaved attempt / R", retry)
	UiFactory.button(column, "Return to menu", request_menu)

func bank_summary() -> String:
	var result := "Saved routes: "
	for slot: int in range(4):
		var tape := loop.bank[slot]
		if tape != null:
			result += "E%d %.1fs   " % [slot + 1, float(tape.duration_ticks) / MissionClock.HZ]
	return result + ("none" if loop.bank_count() == 0 else "")

func show_review() -> void:
	loop.set_state(TimeLoopController.State.REVIEW)
	var column := panel("ATTEMPT REVIEW", "30.0 seconds recorded. Bank this route or retry without saving.")
	UiFactory.label(column, bank_summary(), 18, UiFactory.MUTED)
	UiFactory.button(column, "Bank Echo", request_bank).grab_focus()
	UiFactory.button(column, "Inspect timeline / Tab", open_timeline)
	UiFactory.button(column, "Retry without saving / R", retry)
	UiFactory.button(column, "Return to menu", func() -> void: navigate.emit("menu"))

func request_bank() -> void:
	if not loop.request_bank():
		return
	var column := panel("BANK THIS MOMENT?", "Save %.1fs. The Echo disappears when its recording ends." % (float(loop.recorder.duration_ticks) / MissionClock.HZ))
	var free := loop.free_slot()
	if free >= 0:
		UiFactory.button(column, "Bank as E%d and start next attempt" % (free + 1), confirm_bank).grab_focus()
	else:
		UiFactory.label(column, "Choose a slot to replace. Cancel preserves the saved route.", 18, UiFactory.MUTED)
		for slot: int in range(loop.capacity):
			var replacement := UiFactory.button(column, "Replace E%d" % (slot + 1), confirm_bank.bind(slot))
			if slot == 0:
				replacement.grab_focus()
	UiFactory.button(column, "Cancel", cancel_bank)

func confirm_bank(slot: int = -1) -> void:
	if loop.commit_bank(slot):
		var first_reveal := not _echo_reveal_seen
		_echo_reveal_seen = true
		retry()
		if first_reveal:
			show_echo_reveal()
		else:
			world.orchestra.play_imprint()

func cancel_bank() -> void:
	loop.cancel_bank()
	clear_overlay()
	if loop.state == TimeLoopController.State.REVIEW:
		show_review()
	else:
		get_tree().paused = false

func clear_overlay() -> void:
	if is_instance_valid(overlay):
		overlay.get_parent().remove_child(overlay)
		overlay.queue_free()
		overlay = null

func resume() -> void:
	if loop.state != TimeLoopController.State.PAUSED:
		return
	_timeline_viewing = false
	loop.set_state(TimeLoopController.State.RUNNING)
	get_tree().paused = false
	clear_overlay()

func retry() -> void:
	_echo_reveal_active = false
	_hint_active = false
	_leave_pending = false
	_intro_active = false
	winning_tape = null
	last_result.clear()
	_undo_pending = false
	_timeline_viewing = false
	_removal_slot = -1
	clear_overlay()
	create_world()
	get_tree().paused = false
	hud.update_clock(clock)
	hud.update_bank(loop.bank)

func complete_mission() -> void:
	if loop.state == TimeLoopController.State.COMPLETED:
		return
	loop.set_state(TimeLoopController.State.COMPLETED)
	winning_tape = loop.recorder.snapshot()
	last_result = {"mission_id": definition.mission_id, "ticks": clock.completed_ticks, "echo_count": loop.bank_count(), "echo_budget": definition.echo_budget, "stars": ScoreRules.grade(clock.completed_ticks, loop.bank_count(), definition.echo_budget)}
	mission_completed.emit(last_result.duplicate())
	if definition.finale:
		show_showcase()
	else:
		present_result()

func present_result() -> void:
	if loop.state != TimeLoopController.State.COMPLETED:
		return
	var column := panel("DAY, RETURNED" if definition.finale else "MISSION COMPLETE", definition.title + " · %.1fs · %d Echoes" % [float(clock.completed_ticks) / MissionClock.HZ, loop.bank_count()])
	UiFactory.label(column, "%d / 3 STARS" % int(last_result.get("stars", 0)), 26, UiFactory.CYAN)
	UiFactory.label(column, ScoreRules.explanation(clock.completed_ticks, loop.bank_count(), definition.echo_budget), 16, UiFactory.MUTED)
	if definition.finale:
		UiFactory.label(column, "MORROW: An unscheduled morning...?\nTICK: A whole day, returned on time.\nThe clockwork star rises. The city gets its morning back.", 20, UiFactory.BRASS)
		UiFactory.button(column, "Watch showcase again", show_showcase)
	else:
		UiFactory.label(column, "TICK: They are not copies. They are your plans.", 20, UiFactory.BRASS)
	var next := MissionCatalog.next_id(definition.mission_id)
	if not next.is_empty():
		UiFactory.button(column, "Next mission / " + next, func() -> void: navigate.emit("mission:" + next)).grab_focus()
	UiFactory.button(column, "Replay mission", restart_mission)
	var select_button := UiFactory.button(column, "Mission select", func() -> void: navigate.emit("select"))
	if next.is_empty():
		select_button.grab_focus()
	UiFactory.button(column, "Return to menu", func() -> void: navigate.emit("menu"))

func show_showcase() -> void:
	if loop.state != TimeLoopController.State.COMPLETED:
		return
	if winning_tape == null or winning_tape.duration_ticks == 0:
		present_result() # Static summary fallback; never re-simulate the world.
		return
	clear_overlay()
	get_tree().paused = true
	var snapshot := ShowcaseSnapshot.new()
	snapshot.tapes = loop.bank.duplicate()
	snapshot.live_tape = winning_tape
	snapshot.walls = world.wall_rects.duplicate()
	for pad: ResonancePad in world.registry.pads:
		snapshot.markers.append({"position": pad.global_position, "label": pad.display_name})
	for terminal: ResonanceTerminal in world.registry.terminals:
		snapshot.markers.append({"position": terminal.global_position, "label": terminal.display_name})
		if terminal.device_id == &"core":
			snapshot.core_tick = terminal.activation_tick
	var movie := SHOWCASE_SCENE.instantiate() as ShowcaseView
	movie.snapshot = snapshot
	movie.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay = movie
	ui_root.add_child(movie)
	movie.finished.connect(present_result)

func restart_mission() -> void:
	loop.clear_bank()
	retry()

func open_timeline() -> void:
	if loop.state not in [TimeLoopController.State.RUNNING, TimeLoopController.State.PAUSED, TimeLoopController.State.REVIEW]:
		return
	_timeline_return = loop.state
	if loop.state == TimeLoopController.State.RUNNING:
		loop.set_state(TimeLoopController.State.PAUSED)
	show_timeline()

func show_timeline() -> void:
	clear_overlay()
	get_tree().paused = true
	_timeline_viewing = true
	var director := TIMELINE_SCENE.instantiate() as TimelineDirector
	director.can_undo = loop.has_undo()
	director.bank = loop.bank.duplicate()
	director.live_tape = loop.recorder.snapshot()
	director.review = _timeline_return == TimeLoopController.State.REVIEW
	director.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay = director
	ui_root.add_child(director)
	director.resume_requested.connect(close_timeline)
	director.retry_requested.connect(retry)
	director.remove_requested.connect(request_remove)
	director.undo_requested.connect(request_undo)
	director.controls_requested.connect(show_controls)
	director.menu_requested.connect(func() -> void: navigate.emit("menu"))

func close_timeline() -> void:
	_timeline_viewing = false
	clear_overlay()
	if _timeline_return == TimeLoopController.State.REVIEW:
		show_review()
	else:
		loop.set_state(TimeLoopController.State.RUNNING)
		get_tree().paused = false

func request_remove(slot: int) -> void:
	if not _timeline_viewing or slot < 0 or loop.bank[slot] == null:
		return
	_removal_slot = slot
	_timeline_viewing = false
	var column := panel("REMOVE E%d?" % (slot + 1), "This discards the unsaved live run and starts a new attempt without this Echo.")
	UiFactory.button(column, "Cancel — keep tape and live run", cancel_remove).grab_focus()
	UiFactory.button(column, "Remove Echo and restart", confirm_remove)

func cancel_remove() -> void:
	_removal_slot = -1
	show_timeline()

func confirm_remove() -> void:
	if _removal_slot < 0 or loop.state not in [TimeLoopController.State.PAUSED, TimeLoopController.State.REVIEW]:
		return
	if loop.remove_tape(_removal_slot):
		retry()

func show_controls() -> void:
	var column := panel("CONTROLS", "WASD / arrows: move   ·   E: interact   ·   Q: bank with confirmation\nR: discard/retry   ·   Tab: Timeline   ·   Esc: pause/resume\nH: progressive hints (optional)\nShift: dash in M3   ·   Space: pulse in M4")
	UiFactory.button(column, "Back to timeline", show_timeline).grab_focus()

func fail_attempt(reason: String) -> void:
	_last_failure = reason
	loop.set_state(TimeLoopController.State.FAILED)
	var column := panel("TIME SLIPPED", reason)
	UiFactory.label(column, "Saved Echoes are safe. This failed run is never auto-banked.", 18, UiFactory.MUTED)
	UiFactory.button(column, "Retry attempt / R", retry).grab_focus()
	UiFactory.button(column, "Return to menu", func() -> void: navigate.emit("menu"))

func request_undo() -> void:
	if not _timeline_viewing or not loop.has_undo():
		return
	_undo_pending = true
	_timeline_viewing = false
	var column := panel("UNDO LAST BANK CHANGE?", "Restores the previous bank, discards the unsaved live run and resets the world.")
	UiFactory.button(column, "Cancel — preserve current setup", cancel_undo).grab_focus()
	UiFactory.button(column, "Undo and restart attempt", confirm_undo)

func cancel_undo() -> void:
	_undo_pending = false
	show_timeline()

func confirm_undo() -> void:
	if _undo_pending and loop.undo_bank_change():
		retry()

func show_intro() -> void:
	_intro_active = true
	loop.set_state(TimeLoopController.State.PAUSED)
	var column := panel("VAULT OF TOMORROW", "The stolen day is waiting.")
	for line: String in definition.intro_lines:
		UiFactory.label(column, line, 18, UiFactory.MUTED)
	UiFactory.button(column, "Play / skip story", skip_intro).grab_focus()

func skip_intro() -> void:
	if not _intro_active:
		return
	_intro_active = false
	resume()

func apply_preferences(options: Dictionary) -> void:
	preferences.merge(options, true)
	if is_instance_valid(world):
		world.rook.reduce_flashes = preferences["reduce_flashes"]
		world.orchestra.reduce_flashes = preferences["reduce_flashes"]
		world.orchestra.audio_enabled = DisplayServer.get_name() != "headless" and preferences["master_volume"] > 0 and preferences["sfx_volume"] > 0
		world.camera.shake_enabled = preferences["screen_shake"] and not preferences["reduce_flashes"]
		for projection: EchoPlayer in world.echoes:
			projection.reduce_flashes = preferences["reduce_flashes"]
		if not preferences["show_hints"]:
			world.highlight_active = false
			world.queue_redraw()
	if is_instance_valid(hud):
		hud.hint_button.visible = preferences["show_hints"]
		hud.dial.reduce_flashes = preferences["reduce_flashes"]
		hud.dial.queue_redraw()

func request_hint() -> void:
	if not preferences["show_hints"] or loop.state not in [TimeLoopController.State.RUNNING, TimeLoopController.State.PAUSED, TimeLoopController.State.REVIEW]:
		return
	if not _hint_active:
		_hint_return = loop.state
		_hint_from_timeline = _timeline_viewing
		_timeline_viewing = false
	_hint_active = true
	if loop.state == TimeLoopController.State.RUNNING:
		loop.set_state(TimeLoopController.State.PAUSED)
	hint_level = mini(hint_level + 1, 3)
	var message := definition.objective
	if hint_level == 2:
		message = "Look for the highlighted station. Its illuminated wire shows what it controls."
		var target: Node2D
		if not world.registry.pads.is_empty():
			target = world.registry.pads[0]
		elif not world.registry.terminals.is_empty():
			target = world.registry.terminals[0]
		if target != null:
			world.highlight_active = true
			world.highlight_position = target.global_position
			world.queue_redraw()
	elif hint_level == 3:
		message = definition.hint_before_bank if loop.bank_count() == 0 else definition.hint_after_bank
	var column := panel("TICK'S NUDGE %d / 3" % hint_level, message)
	if hint_level < 3:
		UiFactory.button(column, "Another nudge", request_hint)
	UiFactory.button(column, "Back", close_hint).grab_focus()

func close_hint() -> void:
	_hint_active = false
	if _hint_from_timeline:
		show_timeline()
	elif _hint_return == TimeLoopController.State.REVIEW:
		show_review()
	elif _hint_return == TimeLoopController.State.PAUSED:
		show_pause("TIME, HELD", "Mission paused")
	else:
		loop.set_state(TimeLoopController.State.RUNNING)
		clear_overlay()
		get_tree().paused = false

func request_menu() -> void:
	if loop.state == TimeLoopController.State.COMPLETED or (loop.bank_count() == 0 and loop.recorder.duration_ticks == 0):
		navigate.emit("menu")
		return
	_leave_return = loop.state
	_leave_from_timeline = _timeline_viewing
	_timeline_viewing = false
	_leave_pending = true
	if loop.state == TimeLoopController.State.RUNNING:
		loop.set_state(TimeLoopController.State.PAUSED)
	var column := panel("LEAVE THIS MISSION?", "Live and banked Echo tapes belong to this mission only. Leaving discards them; campaign results stay saved.")
	UiFactory.button(column, "Cancel — keep this setup", cancel_menu).grab_focus()
	UiFactory.button(column, "Leave mission", func() -> void: navigate.emit("menu"))

func cancel_menu() -> void:
	_leave_pending = false
	if _leave_from_timeline:
		show_timeline()
	elif _leave_return == TimeLoopController.State.REVIEW:
		show_review()
	elif _leave_return == TimeLoopController.State.FAILED:
		fail_attempt(_last_failure)
	elif _leave_return == TimeLoopController.State.PAUSED:
		show_pause("TIME, HELD", "Mission paused")
	else:
		loop.set_state(TimeLoopController.State.RUNNING)
		clear_overlay()
		get_tree().paused = false

func show_echo_reveal() -> void:
	_echo_reveal_active = true
	loop.set_state(TimeLoopController.State.PAUSED)
	var column := panel("YOUR PLAN, REPEATED", "Your first Echo is banked. It follows the route you just recorded.")
	var preview := TapePreview.new()
	for tape: EchoTape in loop.bank:
		if tape != null:
			preview.tape = tape
			break
	column.add_child(preview)
	UiFactory.label(column, "Echoes pass through walls and hazards. They hold marked pads and replay accepted actions. Only LIVE Rook can claim the goal.", 18, UiFactory.MUTED)
	UiFactory.button(column, "Let the loop begin / Enter", skip_echo_reveal).grab_focus()
	UiFactory.label(column, "Esc skips instantly. Time stays frozen until you continue.", 14, UiFactory.BRASS)

func skip_echo_reveal() -> void:
	if not _echo_reveal_active:
		return
	_echo_reveal_active = false
	resume()
	world.orchestra.play_imprint()
