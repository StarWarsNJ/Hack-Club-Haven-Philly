extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app: Control = CampaignFixture.app(false)
	root.add_child(app)
	app.show_screen("mission:M1")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	await driver.drive(30, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	mission.request_bank()
	mission.confirm_bank()
	assert(mission.paused and mission.clock.completed_ticks == 0 and mission.loop.bank_count() == 1)
	await driver.drive(40, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.clock.completed_ticks == 0 and mission.loop.recorder.duration_ticks == 0)
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.physical_keycode = KEY_ESCAPE
	escape.pressed = true
	root.push_input(escape)
	assert(not mission.paused)
	await driver.drive(1, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.world.echoes[0].active)
	mission.request_bank()
	mission.confirm_bank()
	assert(not mission.paused and mission.loop.bank_count() == 2, "First Echo reveal is not repeated for every bank")
	mission.apply_preferences({"reduce_flashes": true, "screen_shake": false, "master_volume": 0.0})
	assert(mission.hud.dial.reduce_flashes and not mission.world.camera.shake_enabled and not mission.world.orchestra.audio_enabled)
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS onboarding: first Echo reveal freezes ticks/recording, raw Esc skips, subsequent bank is immediate, muted/reduced-flash visual path")
	quit(0)
