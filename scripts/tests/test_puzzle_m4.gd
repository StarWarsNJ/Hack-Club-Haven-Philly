extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	await verify_action_protocol()
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission:M4")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	await driver.drive(24, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(19, func() -> void: mission.simulate_tick(Vector2.UP))
	await driver.drive(977, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	await physics_frame
	await driver.drive(140, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(3, func() -> void: mission.simulate_tick(Vector2.UP))
	await driver.drive(97, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.simulate_tick(Vector2.ZERO, {"pulse": true})
	assert(mission.loop.recorder.snapshot().actions_at(240).size() == 1)
	assert(mission.world.registry.sentinels[0].freeze_until_tick == 330)
	mission.simulate_tick(Vector2.ZERO, {"pulse": true})
	assert(mission.loop.recorder.snapshot().actions_at(241).is_empty(), "Cooldown requests are not recorded")
	await driver.drive(58, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.clock.completed_ticks == 300)
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	assert(mission.loop.bank_count() == 2 and mission.loop.bank[1].duration_ticks == 300)
	var activations: Array[Dictionary] = []
	mission.world.registry.resolver.activated.connect(func(event: Dictionary) -> void:
		if event["type"] == "pulse":
			activations.append(event))
	await physics_frame
	await driver.drive(159, func() -> void: mission.simulate_tick(Vector2.ZERO))
	var captured: Array[Vector2] = []
	await driver.drive(240, func() -> void:
		if mission.paused:
			return
		var tick: int = mission.clock.completed_ticks
		mission.simulate_tick(Vector2.RIGHT)
		if tick == 240:
			captured.append(mission.world.registry.sentinels[0].global_position)
		if tick > 240 and tick < 330:
			assert(mission.world.registry.sentinels[0].global_position.is_equal_approx(captured[0]))
	)
	assert(mission.loop.state == TimeLoopController.State.COMPLETED)
	var win_tick: int = mission.clock.completed_ticks
	assert(activations.size() == 1 and activations[0]["actor_id"] == 1 and activations[0]["tick"] == 240)
	assert(not mission.world.echoes[1].active, "E2 may expire after casting; the accepted freeze still lasts")
	# Both ends of a half-second recording window must clear with real replacement tapes.
	for cast_tick: int in [225, 255]:
		mission.retry()
		mission.open_timeline()
		mission.request_remove(1)
		mission.confirm_remove()
		await physics_frame
		await driver.drive(140, func() -> void: mission.simulate_tick(Vector2.RIGHT))
		await driver.drive(3, func() -> void: mission.simulate_tick(Vector2.UP))
		await driver.drive(cast_tick - 143, func() -> void: mission.simulate_tick(Vector2.ZERO))
		mission.simulate_tick(Vector2.ZERO, {"pulse": true})
		assert(mission.loop.recorder.snapshot().actions_at(cast_tick).size() == 1)
		await driver.drive(299 - cast_tick, func() -> void: mission.simulate_tick(Vector2.ZERO))
		mission.request_bank()
		mission.confirm_bank()
		mission.skip_echo_reveal()
		await physics_frame
		await driver.drive(159, func() -> void: mission.simulate_tick(Vector2.ZERO))
		await driver.drive(240, func() -> void: mission.simulate_tick(Vector2.RIGHT))
		assert(mission.loop.state == TimeLoopController.State.COMPLETED, "Pulse-window endpoint must clear")
	mission.retry()
	await physics_frame
	mission.open_timeline()
	mission.request_remove(1)
	mission.confirm_remove()
	await physics_frame
	await driver.drive(159, func() -> void: mission.simulate_tick(Vector2.ZERO))
	await driver.drive(240, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.loop.state == TimeLoopController.State.FAILED, "The reference crossing without the pulse Echo fails")
	assert(mission.loop.bank_count() == 1)
	mission.retry()
	assert(mission.world.registry.sentinels[0].rail_tick == 0 and mission.world.registry.sentinels[0].freeze_until_tick == -1)
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS M4: real two-Echo route, pulse tick/targets, cooldown rejection, fixed freeze, early tape expiry, half-second pulse window, no-pulse failure/reset; win_tick=%d" % win_tick)
	quit(0)

func verify_action_protocol() -> void:
	var sentinel := OrbitSentinel.new()
	root.add_child(sentinel)
	var devices := {&"orb_a": sentinel}
	var projections: Array[EchoPlayer] = []
	for slot: int in range(3, -1, -1):
		var recorder := EchoRecorder.new(sentinel.global_position)
		recorder.append(sentinel.global_position, Vector2.RIGHT, 0, [{"type": "pulse", "target_ids": [&"orb_a"]}])
		var projection := EchoPlayer.new()
		projection.configure(recorder.snapshot(), slot)
		projection.play_tick(0)
		projections.append(projection)
	var rook := Rook.new()
	rook.pulse_enabled = true
	rook.global_position = sentinel.global_position
	var resolver := ActionResolver.new()
	var order: Array[int] = []
	resolver.activated.connect(func(event: Dictionary) -> void: order.append(event["actor_id"]))
	var accepted := resolver.resolve(devices, [sentinel], projections, rook, {"pulse": true}, 0)
	assert(order == [0, 1, 2, 3, 4] and accepted.size() == 1)
	assert(sentinel.freeze_until_tick == 90, "Simultaneous pulses refresh by max, never add durations")
	resolver.resolve(devices, [sentinel], projections, rook, {"pulse": true}, 0)
	assert(order.size() == 5, "Duplicate tick resolution cannot apply events twice")
	var invalid := EchoRecorder.new(Vector2.ZERO)
	invalid.append(Vector2.ZERO, Vector2.RIGHT, 0, [{"type": "pulse", "target_ids": [&"orb_a"]}])
	var far := EchoPlayer.new()
	far.configure(invalid.snapshot(), 0)
	far.play_tick(0)
	var isolated := ActionResolver.new()
	sentinel.freeze_until_tick = -1
	isolated.resolve(devices, [sentinel], [far], rook, {}, 0)
	assert(sentinel.freeze_until_tick == -1 and not isolated.last_rejection.is_empty())
	for projection: EchoPlayer in projections:
		projection.free()
	far.free()
	rook.free()
	sentinel.queue_free()
	await process_frame
