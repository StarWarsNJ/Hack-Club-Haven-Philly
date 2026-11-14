extends SceneTree
const PATH: String = "res://.godot/validation/restart_profile.json"

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app: Control = load("res://scenes/main.tscn").instantiate()
	app.progress = ProgressStore.new(PATH)
	root.add_child(app)
	assert(app.progress.result_for("M1")["stars"] == 3 and app.progress.result_for("M1")["best_ticks"] == 271)
	assert(app.progress.is_unlocked("M2") and not app.progress.is_unlocked("M3"))
	assert(app.progress.settings["master_volume"] == 0.42 and app.progress.settings["reduce_flashes"] and not app.progress.settings["screen_shake"])
	assert(is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(0)), 0.42))
	app.show_screen("mission")
	assert(app.screen.definition.mission_id == "M2")
	assert(app.screen.world.rook.reduce_flashes and not app.screen.world.camera.shake_enabled)
	app.show_screen("settings")
	assert((app.screen.find_child("reduce_flashes", true, false) as CheckButton).button_pressed)
	assert(not (app.screen.find_child("screen_shake", true, false) as CheckButton).button_pressed)
	app.show_screen("mission:M3")
	assert(app.current_route == "select")
	app.queue_free()
	await process_frame
	print("PASS restart read: separate Godot process restores stars/time/unlock/settings; Continue and locked route reflect disk profile")
	quit(0)
