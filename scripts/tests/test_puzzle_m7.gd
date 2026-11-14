extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission:M7")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	assert(mission.loop.capacity == 4)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	var horizontal: Array[int] = [26, 26, 130, 130]
	var vertical: Array[int] = [32, 35, 32, 35]
	for slot: int in range(4):
		await physics_frame
		await driver.drive(horizontal[slot], func() -> void: mission.simulate_tick(Vector2.RIGHT))
		await driver.drive(vertical[slot], func() -> void: mission.simulate_tick(Vector2.UP if slot % 2 == 0 else Vector2.DOWN))
		assert(mission.world.registry.pads[slot].active)
		await driver.drive(600 - horizontal[slot] - vertical[slot], func() -> void: mission.simulate_tick(Vector2.ZERO))
		mission.request_bank()
		mission.confirm_bank()
		mission.skip_echo_reveal()
	assert(mission.loop.bank_count() == 4)
	var originals: Array[EchoTape] = mission.loop.bank.duplicate()
	await physics_frame
	await driver.drive(30, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.request_bank()
	mission.confirm_bank() # No implicit overwrite with all four slots full.
	mission.skip_echo_reveal()
	assert(mission.loop.state == TimeLoopController.State.BANK_CONFIRM)
	for slot: int in range(4):
		assert(mission.loop.bank[slot] == originals[slot])
	mission.cancel_bank()
	assert(mission.clock.completed_ticks == 30 and mission.loop.recorder.duration_ticks == 30)
	mission.request_bank()
	mission.confirm_bank(1)
	mission.skip_echo_reveal()
	assert(mission.loop.bank[1] != originals[1] and mission.loop.bank[1].duration_ticks == 30)
	for slot: int in [0, 2, 3]:
		assert(mission.loop.bank[slot] == originals[slot])
	mission.open_timeline()
	mission.request_undo()
	mission.cancel_undo()
	assert(mission.loop.bank[1].duration_ticks == 30)
	mission.request_undo()
	mission.confirm_undo()
	assert(mission.clock.completed_ticks == 0 and not mission.loop.has_undo())
	for slot: int in range(4):
		assert(mission.loop.bank[slot] == originals[slot])
	mission.open_timeline()
	mission.request_remove(1)
	mission.confirm_remove()
	assert(mission.loop.bank[1] == null and mission.loop.bank[2] == originals[2])
	await physics_frame
	await driver.drive(250, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.loop.state == TimeLoopController.State.RUNNING and mission.world.rook.position.x < 829)
	assert(not mission.world.registry.gates[0].is_open, "Three recordings cannot open the four-role gate")
	mission.open_timeline()
	mission.request_undo()
	mission.confirm_undo()
	await physics_frame
	await driver.drive(60, func() -> void: mission.simulate_tick(Vector2.ZERO))
	await driver.drive(250, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(mission.loop.state == TimeLoopController.State.COMPLETED)
	var win_tick: int = mission.clock.completed_ticks
	assert(mission.loop.bank_count() == 4)
	mission.restart_mission()
	assert(mission.loop.bank_count() == 0 and not mission.loop.has_undo())
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS M7: four real tapes, no implicit fifth overwrite, cancel/replacement isolation, confirmed undo/remove/reset, genuine four-role clear; win_tick=%d" % win_tick)
	quit(0)
