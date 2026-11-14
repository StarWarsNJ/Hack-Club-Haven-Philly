extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	assert(SimulationGeometry.segment_hits_rect(Vector2(-20, 0), Vector2(20, 0), Rect2(-1, -5, 2, 10)))
	assert(not SimulationGeometry.segment_hits_rect(Vector2(-20, 8), Vector2(20, 8), Rect2(-1, -5, 2, 10)))
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission:M3")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	await driver.drive(10, func() -> void: mission.simulate_tick(Vector2.RIGHT, {"dash": mission.clock.completed_ticks == 0}))
	assert(absf(mission.world.rook.position.x - (140.0 + 550.0 / 6.0)) < 0.2)
	assert(mission.world.rook.dash_ready_tick == 102)
	await driver.drive(38, func() -> void: mission.simulate_tick(Vector2.UP))
	assert(mission.world.registry.pads[0].active)
	await driver.drive(972, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	var tape: EchoTape = mission.loop.bank[0]
	assert(tape.animation_at(0) == 2)
	await physics_frame
	var route: Dictionary = await follow_route(mission, driver, true, 0)
	print("M3 route diagnostic state=%s ticks=%d pos=%s dashes=%d waypoint=%d" % [mission.loop.state, mission.clock.completed_ticks, mission.world.rook.position, route["dashes"], route["index"]])
	assert(mission.loop.state == TimeLoopController.State.COMPLETED)
	var win_tick: int = mission.clock.completed_ticks
	assert(win_tick <= PhaseBeam.SAFE_END - 30, "Reference route needs >=0.5s safe-window margin")
	mission.retry()
	await physics_frame
	await follow_route(mission, driver, true, 30)
	assert(mission.loop.state == TimeLoopController.State.COMPLETED, "Starting half a second later must still clear")
	mission.retry()
	await physics_frame
	await follow_route(mission, driver, false, 0)
	await driver.drive(1, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.loop.state == TimeLoopController.State.FAILED, "Walking the reference crossing cannot beat the beam")
	mission.retry()
	await physics_frame
	# Repeatable phase sequence, including E1 changing pad state, across resets.
	var phases: Array[int] = []
	await driver.drive(90, func() -> void:
		mission.simulate_tick(Vector2.ZERO)
		phases.append(mission.world.registry.beams[0].phase)
	)
	mission.retry()
	await physics_frame
	await driver.drive(90, func() -> void:
		var tick: int = mission.clock.completed_ticks
		mission.simulate_tick(Vector2.ZERO)
		assert(phases[tick] == mission.world.registry.beams[0].phase)
	)
	mission.retry()
	await physics_frame
	await driver.drive(60, func() -> void: mission.simulate_tick(Vector2.LEFT, {"dash": mission.clock.completed_ticks == 0}))
	assert(mission.world.rook.position.x >= 55 and mission.world.rook.position.x < 58, "Dash is blocked by walls")
	mission.retry()
	await physics_frame
	await driver.drive(27, func() -> void: mission.simulate_tick(Vector2.UP))
	await driver.drive(55, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(10, func() -> void: mission.simulate_tick(Vector2.RIGHT, {"dash": mission.clock.completed_ticks == 82}))
	assert(mission.loop.state == TimeLoopController.State.FAILED and mission.world.rook.animation_state == 2, "Dash grants no hazard invulnerability")
	assert(mission.loop.bank[0] == tape)
	mission.request_bank()
	assert(mission.loop.bank[0] == tape and mission.loop.state == TimeLoopController.State.FAILED)
	mission.retry()
	assert(mission.clock.completed_ticks == 0 and mission.loop.bank[0] == tape)
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS M3: real dash tape/replay, blocked dash, swept hazard, phase reset, failure/no-bank, half-second delay succeeds, walking fails, canonical win_tick=%d margin=%d ticks" % [win_tick, PhaseBeam.SAFE_END - win_tick])
	quit(0)

func follow_route(mission: Control, driver: TestPhysicsDriver, use_dash: bool, delay_ticks: int) -> Dictionary:
	var tape: EchoTape = mission.loop.bank[0]
	await driver.drive(27, func() -> void:
		var tick: int = mission.clock.completed_ticks
		mission.simulate_tick(Vector2.UP)
		assert(mission.world.echoes[0].global_position.is_equal_approx(tape.position_at(tick)))
	)
	await driver.drive(59, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(94 + delay_ticks, func() -> void: mission.simulate_tick(Vector2.ZERO))
	var waypoints: Array[Vector2] = [Vector2(1012, 220), Vector2(1012, 268), Vector2(920, 360), Vector2(460, 360), Vector2(460, 412), Vector2(496, 448), Vector2(1080, 448)]
	var route := {"index": 0, "dashes": 0}
	await driver.drive(486, func() -> void:
		if mission.paused:
			return
		var position: Vector2 = mission.world.rook.position
		while route["index"] < waypoints.size() and absf(position.x - waypoints[route["index"]].x) <= 4 and absf(position.y - waypoints[route["index"]].y) <= 4:
			route["index"] += 1
		var direction := Vector2.ZERO
		var dash := false
		if route["index"] < waypoints.size():
			var diff: Vector2 = waypoints[route["index"]] - position
			direction = Vector2(signf(diff.x) if absf(diff.x) > 3 else 0.0, signf(diff.y) if absf(diff.y) > 3 else 0.0)
			dash = use_dash and mission.clock.completed_ticks >= mission.world.rook.dash_ready_tick and diff.length() > 125
		if dash:
			route["dashes"] += 1
		mission.simulate_tick(direction, {"dash": dash})
	)
	return route
