extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	# Isolated physics fixture verifies live carry on a moving bridge.
	var bridge := ClockworkBridge.new()
	bridge.position = Vector2(485, 324)
	root.add_child(bridge)
	var rider: Rook = load("res://scenes/actors/rook.tscn").instantiate()
	rider.position = Vector2(485, 324)
	root.add_child(rider)
	var registry := DeviceRegistry.new()
	registry.register(bridge)
	await physics_frame
	await driver.drive(1, func() -> void: registry.prepare_tick(1, rider))
	assert(bridge.frame_delta.y > 1.0 and absf(rider.position.y - 324 - bridge.frame_delta.y) < 0.1)
	assert(registry.failure_reason(rider.position, rider.position).is_empty())
	rider.queue_free()
	bridge.queue_free()
	await process_frame
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission:M6")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	await physics_frame
	await driver.drive(24, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(19, func() -> void: mission.simulate_tick(Vector2.UP))
	await driver.drive(977, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	await physics_frame
	await driver.drive(136, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(27, func() -> void: mission.simulate_tick(Vector2.DOWN))
	assert(mission.loop.state == TimeLoopController.State.RUNNING and mission.world.registry.pads[1].active)
	await driver.drive(437, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	await physics_frame
	await driver.drive(20, func() -> void: mission.simulate_tick(Vector2.ZERO))
	await driver.drive(260, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.loop.state == TimeLoopController.State.COMPLETED)
	var win_tick: int = mission.clock.completed_ticks
	mission.retry()
	await physics_frame
	var poses: Array[Vector2] = []
	await driver.drive(180, func() -> void:
		mission.simulate_tick(Vector2.ZERO)
		for platform: ClockworkBridge in mission.world.registry.bridges:
			poses.append(platform.global_position)
	)
	mission.retry()
	await physics_frame
	await driver.drive(180, func() -> void:
		var tick: int = mission.clock.completed_ticks
		mission.simulate_tick(Vector2.ZERO)
		for index: int in range(2):
			assert(mission.world.registry.bridges[index].global_position.is_equal_approx(poses[tick * 2 + index]))
	)
	mission.retry()
	await physics_frame
	await driver.drive(90, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(30, func() -> void: mission.simulate_tick(Vector2.UP))
	assert(mission.world.rook.position.y >= 291 and mission.world.rook.position.y < 295, "Live Rook collides with bridge rails")
	assert(mission.loop.state == TimeLoopController.State.RUNNING)
	mission.open_timeline()
	mission.request_remove(0)
	mission.confirm_remove()
	var saved: EchoTape = mission.loop.bank[1]
	await physics_frame
	await driver.drive(90, func() -> void:
		var tick: int = mission.clock.completed_ticks
		mission.simulate_tick(Vector2.ZERO)
		assert(mission.world.echoes[0].global_position.is_equal_approx(saved.position_at(tick)))
	)
	assert(not mission.world.registry.bridges[0].supports_live(mission.world.echoes[0].global_position))
	assert(mission.loop.state == TimeLoopController.State.RUNNING, "Echo can cross an unavailable bridge without causing failure")
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS M6: real two-Echo bridge route, live carry/rails, repeated phase reset, authoritative Echo across changed geometry; win_tick=%d" % win_tick)
	quit(0)
