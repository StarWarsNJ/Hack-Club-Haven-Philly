extends SceneTree
const PATH: String = "res://.godot/validation/restart_profile.json"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var profile := ProgressStore.new(PATH)
	assert(profile.save_to_disk()) # Only this dedicated fixture file is reset.
	var app: Control = load("res://scenes/main.tscn").instantiate()
	app.progress = profile
	root.add_child(app)
	app.show_screen("mission:M1")
	var mission: Control = app.screen
	mission.set_physics_process(false)
	var driver := TestPhysicsDriver.new()
	root.add_child(driver)
	await physics_frame
	await driver.drive(24, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	await driver.drive(19, func() -> void: mission.simulate_tick(Vector2.UP))
	mission.request_menu()
	assert(mission.paused and mission.clock.completed_ticks == 43)
	mission.cancel_menu()
	assert(not mission.paused and mission.loop.recorder.duration_ticks == 43)
	await driver.drive(977, func() -> void: mission.simulate_tick(Vector2.ZERO))
	mission.request_bank()
	mission.confirm_bank()
	mission.skip_echo_reveal()
	await physics_frame
	await driver.drive(45, func() -> void: mission.simulate_tick(Vector2.ZERO))
	await driver.drive(240, func() -> void: mission.simulate_tick(Vector2.RIGHT))
	assert(profile.result_for("M1")["stars"] == 3 and profile.result_for("M1")["best_ticks"] == 271)
	assert(profile.is_unlocked("M2") and not profile.is_unlocked("M3"))
	mission.request_menu()
	assert(app.current_route == "menu")
	app.show_screen("settings")
	var slider := app.screen.find_child("MasterVolume", true, false) as HSlider
	slider.value = 0.42
	var reduced := app.screen.find_child("reduce_flashes", true, false) as CheckButton
	reduced.button_pressed = true
	var shake := app.screen.find_child("screen_shake", true, false) as CheckButton
	shake.button_pressed = false
	app.screen.handle_cancel()
	assert(profile.settings["master_volume"] == 0.42 and profile.settings["reduce_flashes"] and not profile.settings["screen_shake"])
	app.queue_free()
	driver.queue_free()
	await process_frame
	print("PASS restart write: actual M1 completion signal saves three stars/unlock; settings UI saves; leave cancellation preserves run")
	quit(0)
