extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	verify_conductor()
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission:M8")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await driver.drive(10, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.clock.completed_ticks == 0 and paused, "Story cannot consume mission time")
	mission.skip_intro()
	var horizontal: Array[int] = [26, 26, 183, 183]
	var vertical: Array[int] = [35, 38, 35, 38]
	for slot: int in range(4):
		await physics_frame
		await driver.drive(horizontal[slot], func() -> void: mission.simulate_tick(Vector2.RIGHT))
		await driver.drive(vertical[slot], func() -> void: mission.simulate_tick(Vector2.UP if slot % 2 == 0 else Vector2.DOWN))
		assert(mission.world.registry.pads[slot].active)
		await driver.drive(900 - horizontal[slot] - vertical[slot], func() -> void: mission.simulate_tick(Vector2.ZERO))
		mission.request_bank()
		mission.confirm_bank()
		mission.skip_echo_reveal()
	var wins: Array[Dictionary] = []
	mission.mission_completed.connect(func(result: Dictionary) -> void: wins.append(result))
	await physics_frame
	await driver.drive(130, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(200, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(not mission.world.registry.conductors[0].is_ready)
	mission.simulate_tick(Vector2.ZERO, {"interact": true})
	assert(mission.loop.recorder.snapshot().actions_at(330).is_empty())
	await driver.drive(29, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.world.registry.conductors[0].is_ready)
	mission.simulate_tick(Vector2.ZERO, {"interact": true})
	assert((mission.world.registry.devices[&"core"] as ResonanceTerminal).activation_tick == 360)
	await driver.drive(150, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.loop.state == TimeLoopController.State.COMPLETED and wins.size() == 1)
	var win_tick: int = mission.clock.completed_ticks
	assert(mission.overlay is ShowcaseView)
	var movie := mission.overlay as ShowcaseView
	assert(movie.snapshot.live_tape.duration_ticks == win_tick and movie.snapshot.tapes.size() == 4)
	var held: int = mission.world.registry.conductors[0].active_ticks
	await driver.drive(120, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.clock.completed_ticks == win_tick and mission.world.registry.conductors[0].active_ticks == held)
	movie.finish()
	movie.finish()
	assert(wins.size() == 1 and mission.loop.bank_count() == 4)
	mission.show_showcase()
	assert(mission.overlay is ShowcaseView)
	await driver.drive(370, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(not mission.overlay is ShowcaseView and mission.clock.completed_ticks == win_tick and wins.size() == 1, "Six-second showcase must finish automatically without replaying mission state")
	mission.winning_tape = null
	mission.show_showcase()
	assert(not mission.overlay is ShowcaseView and wins.size() == 1, "Missing showcase data uses the static summary fallback")
	mission.retry()
	await physics_frame
	await driver.drive(130, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(230, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.simulate_tick(Vector2.ZERO, {"interact": true})
	await driver.drive(310, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(mission.loop.state == TimeLoopController.State.FAILED, "Missing the five-second exit window must give a safe retry")
	assert(mission.loop.bank_count() == 4)
	mission.retry()
	assert(not (mission.world.registry.devices[&"core"] as ResonanceTerminal).latched)
	assert(mission.world.registry.conductors[0].active_ticks == 0)
	app.show_screen("select")
	assert(app.current_route == "select" and not paused)
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS M8: four real roles, distinct 120-tick conductor, paused/skippable intro, live core/300-tick exit, isolated timed/skippable showcase + fallback, reset/select; win_tick=%d" % win_tick)
	quit(0)

func verify_conductor() -> void:
	var devices: Dictionary = {}
	var pads: Array[ResonancePad] = []
	for index: int in range(4):
		var pad := ResonancePad.new()
		pad.device_id = [&"pad_a", &"pad_b", &"pad_c", &"pad_d"][index]
		pad.occupants = PackedInt32Array([index])
		pads.append(pad)
		devices[pad.device_id] = pad
	var core := ResonanceTerminal.new()
	devices[&"core"] = core
	var conductor := ConductorNode.new()
	for tick: int in range(119):
		conductor.evaluate(devices)
	assert(not conductor.is_ready)
	conductor.evaluate(devices)
	assert(conductor.is_ready and core.externally_enabled)
	pads[3].occupants = PackedInt32Array([0])
	conductor.evaluate(devices)
	assert(not conductor.is_ready and conductor.active_ticks == 0 and not core.externally_enabled)
	for pad: ResonancePad in pads:
		pad.free()
	core.free()
	conductor.free()
