extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var clock := MissionClock.new()
	for index: int in range(1800):
		assert(clock.advance())
	assert(not clock.advance() and clock.completed_ticks == 1800)
	clock.reset()
	clock.paused = true
	for index: int in range(200):
		assert(not clock.advance())
	assert(clock.completed_ticks == 0)
	for action: String in ["move_left", "move_right", "move_up", "move_down", "dash", "interact", "temporal_pulse", "bank_echo", "retry_attempt", "timeline", "pause"]:
		assert(InputMap.has_action(action))
	assert((InputMap.action_get_events("move_left")[1] as InputEventKey).physical_keycode == KEY_LEFT)
	assert((InputMap.action_get_events("move_right")[1] as InputEventKey).physical_keycode == KEY_RIGHT)
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	var start: Vector2 = mission.world.spawn_point
	await driver.drive(60, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	var straight: float = mission.world.rook.position.distance_to(start)
	assert(absf(straight - 230.0) < 0.2)
	mission.retry()
	await physics_frame
	await driver.drive(60, func() -> void: mission.simulate_tick(Vector2(1, -1)))
	var diagonal: float = mission.world.rook.position.distance_to(start)
	assert(absf(straight - diagonal) < 0.2)
	mission.handle_cancel()
	var held: int = mission.clock.completed_ticks
	await driver.drive(20, func() -> void: mission.simulate_tick(Vector2.LEFT))
	assert(mission.clock.completed_ticks == held)
	mission.resume()
	mission.retry()
	await physics_frame
	await driver.drive(180, func() -> void: mission.simulate_tick(Vector2.LEFT))
	assert(mission.world.rook.position.x >= 55.0 and mission.world.rook.position.x < 58.0)
	var pause_button := mission.hud.find_children("*", "Button", true, false)[0] as Button
	pause_button.grab_focus()
	var tab := InputEventKey.new()
	tab.physical_keycode = KEY_TAB
	tab.keycode = KEY_TAB
	tab.pressed = true
	root.push_input(tab)
	assert(paused, "Tab must pause even when a UI button has focus")
	mission.resume()
	mission._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	assert(paused and mission.clock.paused)
	mission.resume()
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS movement: 1800 ticks, pause, input map, 230px/s, normalized diagonals, walls, focus loss")
	quit(0)
