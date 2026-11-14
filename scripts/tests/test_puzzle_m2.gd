extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission:M2")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	assert(mission.definition.mission_id == "M2")
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	await driver.drive(24, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(27, func() -> void: mission.simulate_tick(Vector2.UP))
	await driver.drive(969, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.world.registry.pads[0].active and not mission.world.registry.pads[1].active)
	assert(not mission.world.registry.gates[0].is_open, "A alone cannot open AND gate")
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	await physics_frame
	await driver.drive(136, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(25, func() -> void: mission.simulate_tick(Vector2.DOWN))
	assert(mission.world.registry.pads[0].active and mission.world.registry.pads[1].active)
	assert(not mission.world.registry.gates[0].is_open, "Both pads must sustain the full hold interval")
	await driver.drive(60, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.world.registry.gates[0].is_open)
	var held: int = mission.clock.completed_ticks
	var saved: EchoTape = mission.loop.bank[0]
	mission.open_timeline()
	assert(paused and mission.clock.paused and mission.overlay is TimelineDirector)
	await driver.drive(10, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.clock.completed_ticks == held and mission.loop.bank[0] == saved)
	mission.request_remove(0)
	mission.cancel_remove()
	assert(mission.loop.bank[0] == saved and mission.clock.completed_ticks == held)
	mission.close_timeline()
	await driver.drive(25, func() -> void: mission.simulate_tick(Vector2.UP))
	assert(not mission.world.registry.pads[1].active and mission.world.registry.gates[0].is_open, "Grace allows leaving B")
	await driver.drive(100, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.loop.state == TimeLoopController.State.COMPLETED)
	var win_tick: int = mission.clock.completed_ticks
	mission.retry()
	await physics_frame
	# An Echo alone still cannot qualify the AND condition.
	await driver.drive(70, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.world.registry.pads[0].active and not mission.world.registry.gates[0].is_open)
	mission.open_timeline()
	mission.request_remove(0)
	mission.confirm_remove()
	assert(mission.loop.bank_count() == 0 and mission.clock.completed_ticks == 0)
	assert(mission.world.echoes.is_empty() and not mission.world.registry.pads[0].active)
	assert(not paused)
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS M2: real one-Echo route, AND/hold/grace, paused timeline, cancel removal, confirmed discard/reset; win_tick=%d" % win_tick)
	quit(0)
