extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var recorder := EchoRecorder.new(Vector2(5, 8))
	var event := {"type": "interact", "target_id": "north"}
	recorder.append(Vector2(10, 20), Vector2.LEFT, 1, [event])
	var sealed := recorder.snapshot()
	event["target_id"] = "changed"
	recorder.append(Vector2.ZERO, Vector2.RIGHT, 0)
	var copy := sealed.positions_copy()
	copy[0] = Vector2(999, 999)
	var actions := sealed.actions_at(0)
	actions[0]["target_id"] = "also changed"
	assert(sealed.duration_ticks == 1 and sealed.position_at(0) == Vector2(10, 20))
	assert(sealed.facing_at(0) == Vector2.LEFT and sealed.animation_at(0) == 1)
	assert(sealed.actions_at(0)[0]["target_id"] == "north")
	var maximum := TimeLoopController.new()
	assert(not maximum.request_bank(), "Empty tapes cannot be banked")
	for tick: int in range(1800):
		maximum.finish_tick(Vector2(tick, 0), Vector2.RIGHT, 1)
	assert(maximum.state == TimeLoopController.State.REVIEW)
	assert(maximum.recorder.duration_ticks == 1800 and maximum.clock.completed_ticks == 1800)
	assert(maximum.request_bank())
	maximum.cancel_bank()
	assert(maximum.state == TimeLoopController.State.REVIEW and maximum.bank_count() == 0)
	var app: Control = CampaignFixture.app()
	root.add_child(app)
	app.show_screen("mission")
	var mission: Control = app.screen
	mission.loop.capacity = 1 # Single-slot boundary fixture; production now exposes all four.
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	await driver.drive(600, func() -> void:
		var direction := Vector2.RIGHT if mission.clock.completed_ticks < 120 else Vector2.ZERO
		mission.simulate_tick(direction)
	)
	assert(mission.clock.completed_ticks == 600 and mission.loop.recorder.duration_ticks == 600)
	var frozen: EchoTape = mission.loop.recorder.snapshot()
	mission.request_bank()
	await driver.drive(15, func() -> void: mission.simulate_tick(Vector2.LEFT))
	assert(mission.clock.completed_ticks == 600 and mission.loop.bank_count() == 0)
	mission.cancel_bank()
	assert(not paused and mission.clock.completed_ticks == 600)
	mission.request_bank()
	var old_world: Node = mission.world
	mission.confirm_bank()
	mission.skip_echo_reveal()
	assert(mission.world != old_world and mission.world.rook.position == mission.world.spawn_point)
	assert(mission.clock.completed_ticks == 0 and mission.loop.bank_count() == 1)
	assert(mission.loop.bank[0].duration_ticks == 600)
	assert(not mission.world.echoes[0] is CollisionObject2D)
	await physics_frame
	await driver.drive(600, func() -> void:
		var tick: int = mission.clock.completed_ticks
		mission.simulate_tick(Vector2.ZERO)
		var projection: EchoPlayer = mission.world.echoes[0]
		assert(projection.active)
		assert(projection.global_position.is_equal_approx(frozen.position_at(tick)))
		assert(projection.facing == frozen.facing_at(tick))
	)
	await driver.drive(1, func() -> void: mission.simulate_tick(Vector2.ZERO))
	assert(not mission.world.echoes[0].active)
	var banked: EchoTape = mission.loop.bank[0]
	mission.request_bank()
	assert(root.gui_get_focus_owner() != null)
	var tab := InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.physical_keycode = KEY_TAB
	tab.pressed = true
	root.push_input(tab)
	assert(mission.loop.state == TimeLoopController.State.BANK_CONFIRM, "Tab navigates rather than dismissing bank confirmation")
	mission.confirm_bank() # Full bank requires explicit replacement selection.
	mission.skip_echo_reveal()
	assert(mission.loop.bank[0] == banked and mission.loop.state == TimeLoopController.State.BANK_CONFIRM)
	mission.cancel_bank()
	mission.retry()
	assert(mission.loop.bank[0] == banked and mission.clock.completed_ticks == 0)
	assert(mission.loop.recorder.duration_ticks == 0 and mission.world.echoes.size() == 1)
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS echo: sealed ownership, accepted event copies, 1800/600 samples, bank/cancel, authoritative playback, expiry, retry, baseline, safe full slot")
	quit(0)
