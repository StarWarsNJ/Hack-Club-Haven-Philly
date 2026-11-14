extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var terminal := ResonanceTerminal.new()
	assert(terminal.try_activate(0, 0, {}))
	assert(terminal.is_charged(239) and not terminal.is_charged(240))
	terminal.free()
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission:M5")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	mission.simulate_tick(Vector2.ZERO, {"interact": true})
	assert(mission.loop.recorder.snapshot().actions_at(0).is_empty(), "Out-of-range E must not be recorded")
	mission.retry()
	await physics_frame
	await driver.drive(38, func() -> void: mission.simulate_tick(Vector2.UP))
	await driver.drive(10, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(252, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.simulate_tick(Vector2.ZERO, {"interact": true})
	assert(mission.loop.recorder.snapshot().actions_at(300)[0]["target_id"] == &"north")
	mission.simulate_tick(Vector2.ZERO, {"interact": true})
	assert(mission.loop.recorder.snapshot().actions_at(301).is_empty())
	await driver.drive(298, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	await physics_frame
	await driver.drive(40, func() -> void: mission.simulate_tick(Vector2.DOWN))
	await driver.drive(10, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(250, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.simulate_tick(Vector2.ZERO, {"interact": true})
	assert(mission.loop.recorder.snapshot().actions_at(300)[0]["target_id"] == &"south")
	await driver.drive(299, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	assert(mission.loop.bank_count() == 2)
	var cues: Array[int] = []
	var syncs: Array[int] = []
	mission.world.orchestra.activation_presented.connect(func(slot: int) -> void: cues.append(slot))
	mission.world.orchestra.sync_presented.connect(func(tick: int) -> void: syncs.append(tick))
	AudioServer.set_bus_mute(0, true)
	mission.world.orchestra.audio_enabled = false
	await physics_frame
	await driver.drive(340, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.world.registry.gates[0].is_open)
	assert(mission.loop.state == TimeLoopController.State.RUNNING, "Echo charges alone cannot complete the objective")
	await driver.drive(20, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.simulate_tick(Vector2.ZERO, {"interact": true, "pulse": true})
	var events: Array[Dictionary] = mission.loop.recorder.snapshot().actions_at(360)
	assert(events.size() == 2 and events[0]["type"] == "interact" and events[1]["type"] == "pulse")
	assert((mission.world.registry.devices[&"master"] as ResonanceTerminal).latched)
	await driver.drive(40, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.loop.state == TimeLoopController.State.COMPLETED)
	var win_tick: int = mission.clock.completed_ticks
	assert(cues == [0, 1] and syncs == [300], "Each accepted Echo interaction and overlap is presented once even muted")
	mission.retry()
	assert(not (mission.world.registry.devices[&"master"] as ResonanceTerminal).latched)
	assert((mission.world.registry.devices[&"north"] as ResonanceTerminal).charge_until_tick == -1)
	assert(mission.loop.bank_count() == 2)
	AudioServer.set_bus_mute(0, false)
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS M5: valid E targets, rejected inputs, 240-tick charges, two-Echo overlap, live master, one-shot muted cues/SYNC, E+pulse order/reset; win_tick=%d" % win_tick)
	quit(0)
