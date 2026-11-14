extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var pad := ResonancePad.new()
	pad.evaluate([{"id": 0, "position": Vector2.ZERO}, {"id": 4, "position": Vector2.ZERO}])
	assert(pad.active and pad.occupants.size() == 2)
	pad.evaluate([{"id": 4, "position": Vector2.ZERO}])
	assert(pad.active and pad.occupants.size() == 1)
	pad.evaluate([])
	assert(not pad.active)
	pad.free()
	var gate: ClockGate = load("res://scenes/devices/clock_gate.tscn").instantiate()
	gate.position = Vector2(-300, -300)
	root.add_child(gate)
	gate.set_condition(true, Vector2.ZERO)
	await process_frame
	assert(gate.collision.disabled)
	gate.set_condition(false, gate.global_position)
	assert(gate.is_open and gate.closing_pending and not gate.condition_active)
	gate.set_condition(false, Vector2.ZERO)
	await process_frame
	assert(not gate.is_open and not gate.collision.disabled)
	gate.queue_free()
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	# A fresh live player cannot cross the locked gate.
	await driver.drive(230, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.world.rook.position.x < 779 and mission.loop.bank_count() == 0)
	assert(not mission.world.registry.gates[0].is_open)
	mission.retry()
	await physics_frame
	# Record a real keyboard-equivalent route: right 24 ticks, up 19, hold to 17s.
	await driver.drive(24, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(19, func() -> void: mission.simulate_tick(Vector2.UP))
	assert(mission.world.registry.pads[0].active)
	await driver.drive(977, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.clock.completed_ticks == 1020)
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	assert(not mission.world.registry.pads[0].active and not mission.world.registry.gates[0].is_open)
	var tape: EchoTape = mission.loop.bank[0]
	assert(not tape.markers_copy().is_empty())
	var wins: Array[Dictionary] = []
	mission.mission_completed.connect(func(result: Dictionary) -> void: wins.append(result))
	await physics_frame
	await driver.drive(45, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.world.registry.pads[0].active and mission.world.registry.gates[0].is_open)
	assert(mission.world.registry.pads[0].occupants == PackedInt32Array([0]))
	assert(mission.world.rook.position == mission.world.spawn_point)
	await driver.drive(240, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.loop.state == TimeLoopController.State.COMPLETED)
	assert(wins.size() == 1 and wins[0]["echo_count"] == 1)
	mission.simulate_tick(Vector2.RIGHT)
	assert(wins.size() == 1)
	mission.retry()
	assert(mission.loop.bank[0] == tape and not mission.world.registry.pads[0].active)
	await physics_frame
	await driver.drive(1020, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.world.echoes[0].active and mission.world.registry.pads[0].active)
	await driver.drive(1, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(not mission.world.echoes[0].active and not mission.world.registry.pads[0].active)
	assert(not mission.world.registry.gates[0].is_open)
	await driver.drive(13, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(not mission.world.echoes[0].visible and not mission.world.registry.gates[0].collision.disabled)
	assert(mission.loop.state == TimeLoopController.State.RUNNING, "An Echo cannot win by itself")
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS M1: aggregate pads, closing safety, real recording, locked gate, one live-only win, baseline, exact expiry/fade; win_tick=%d" % wins[0]["ticks"])
	quit(0)
