extends SceneTree
## Integration smoke test: exercise real screens without an external test addon.

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app: Control = load("res://scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	assert(app.current_route == "menu")
	app.show_screen("settings")
	var slider := app.screen.find_child("MasterVolume", true, false) as HSlider
	assert(slider != null)
	slider.value = 0.0
	assert(AudioServer.is_bus_mute(0))
	slider.value = 0.7
	assert(not AudioServer.is_bus_mute(0))
	assert(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(0)), 0.7))
	app.show_screen("help")
	app.screen.handle_cancel()
	assert(app.current_route == "menu")
	app.show_screen("mission")
	app.screen.handle_cancel()
	assert(paused)
	app.screen.resume()
	assert(not paused)
	app.screen.handle_cancel()
	app.show_screen("menu")
	assert(not paused)
	app.queue_free()
	await process_frame
	print("PASS shell: routing, volume/mute, help, pause/resume, return")
	quit(0)
