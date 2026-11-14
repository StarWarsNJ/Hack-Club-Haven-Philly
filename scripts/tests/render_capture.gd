extends SceneTree
## Native rendering artifact check only. All profiles are transient and muted.
var app: Control
var driver: TestPhysicsDriver
var captures: Array[Dictionary] = []
var phase: String = "base"

func _initialize() -> void:
	if OS.get_cmdline_user_args().has("finale"):
		phase = "finale"
	call_deferred("run")

func run() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS, true)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.godot/validation/renders"))
	app = CampaignFixture.app(phase == "finale")
	app.progress.set_setting("master_volume", 0.0)
	app.progress.set_setting("music_volume", 0.0)
	app.progress.set_setting("sfx_volume", 0.0)
	root.add_child(app)
	driver = TestPhysicsDriver.new()
	root.add_child(driver)
	if phase == "finale":
		await finale_captures()
	else:
		await base_captures()
	var manifest := FileAccess.open("res://.godot/validation/renders/manifest_" + phase + ".json", FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"phase": phase, "renderer": RenderingServer.get_current_rendering_method(), "captures": captures, "human_acceptance": "UNVERIFIED"}, "\t"))
	manifest.close()
	paused = false
	app.queue_free()
	driver.queue_free()
	await process_frame
	await process_frame
	print("PASS render " + phase + ": %d native Compatibility frames captured; human gameplay/visual acceptance remains unverified" % captures.size())
	quit(0)

func capture(name: String) -> void:
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	assert(picture != null and picture.get_width() > 0)
	var output := "res://.godot/validation/renders/" + name + ".png"
	assert(picture.save_png(ProjectSettings.globalize_path(output)) == OK)
	captures.append({"name": name, "width": picture.get_width(), "height": picture.get_height()})

func mission(id: String) -> Control:
	app.show_screen("mission:" + id)
	var screen: Control = app.screen
	assert(app.current_route == "mission")
	screen.set_physics_process(false)
	screen.skip_intro()
	return screen

func base_captures() -> void:
	await capture("menu_1152")
	root.size = Vector2i(960, 540)
	await capture("menu_960")
	root.size = Vector2i(1152, 648)
	app.show_screen("settings")
	await capture("settings")
	app.show_screen("select")
	await capture("mission_select_fresh")
	app.show_screen("help")
	await capture("help")
	# Explicit fixture unlocks allow inspecting later rooms, not solving them.
	for id: String in ProgressStore.MISSION_IDS:
		app.progress.record_result(id, 1200, 4, 4)
	for id: String in ProgressStore.MISSION_IDS:
		mission(id)
		await capture(id.to_lower() + "_room")
	var screen := mission("M1")
	await physics_frame
	await driver.drive(24, func() -> void: screen.simulate_tick(Vector2.RIGHT))
	await driver.drive(19, func() -> void: screen.simulate_tick(Vector2.UP))
	await driver.drive(557, func() -> void: screen.simulate_tick(Vector2.ZERO))
	screen.request_bank()
	screen.confirm_bank()
	await capture("first_echo_reveal")
	screen.skip_echo_reveal()
	await physics_frame
	await driver.drive(60, func() -> void: screen.simulate_tick(Vector2.ZERO))
	await capture("m1_echo_active")
	screen.open_timeline()
	await capture("timeline")
	screen.close_timeline()
	screen.apply_preferences({"reduce_flashes": true, "screen_shake": false})
	root.size = Vector2i(1536, 648)
	await capture("hud_wide_reduced")

func finale_captures() -> void:
	var screen := mission("M8")
	var horizontal: Array[int] = [26, 26, 183, 183]
	var vertical: Array[int] = [35, 38, 35, 38]
	for slot: int in range(4):
		await physics_frame
		await driver.drive(horizontal[slot], func() -> void: screen.simulate_tick(Vector2.RIGHT))
		await driver.drive(vertical[slot], func() -> void: screen.simulate_tick(Vector2.UP if slot % 2 == 0 else Vector2.DOWN))
		await driver.drive(600 - horizontal[slot] - vertical[slot], func() -> void: screen.simulate_tick(Vector2.ZERO))
		screen.request_bank()
		screen.confirm_bank()
		screen.skip_echo_reveal()
	await physics_frame
	await driver.drive(130, func() -> void: screen.simulate_tick(Vector2.RIGHT))
	await driver.drive(230, func() -> void: screen.simulate_tick(Vector2.ZERO))
	await capture("m8_four_echoes")
	screen.simulate_tick(Vector2.ZERO, {"interact": true})
	await capture("m8_core_star")
	await driver.drive(150, func() -> void: screen.simulate_tick(Vector2.RIGHT))
	assert(screen.loop.state == TimeLoopController.State.COMPLETED)
	await driver.drive(120, func() -> void: screen.simulate_tick(Vector2.ZERO))
	await capture("perfect_heist")
	(screen.overlay as ShowcaseView).finish()
	await capture("ending_results")
