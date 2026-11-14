extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var north := ResonanceTerminal.new()
	north.device_id = &"north"
	north.position = Vector2(200, 0)
	var south := ResonanceTerminal.new()
	south.device_id = &"south"
	var master := ResonanceTerminal.new()
	master.device_id = &"master"
	master.live_only = true
	master.one_shot = true
	var devices := {&"north": north, &"south": south, &"master": master}
	var rook := Rook.new()
	var recorder := EchoRecorder.new()
	recorder.append(Vector2.ZERO, Vector2.RIGHT, 0, [{"type": "interact", "target_id": &"north"}])
	var projection := EchoPlayer.new()
	projection.configure(recorder.snapshot(), 0)
	projection.play_tick(0)
	var resolver := ActionResolver.new()
	resolver.resolve(devices, [], [projection], rook, {}, 0)
	assert(north.charge_until_tick == -1 and south.charge_until_tick == -1, "A missed recorded target cannot retarget the nearby South terminal")
	var master_recording := EchoRecorder.new()
	master_recording.append(Vector2.ZERO, Vector2.RIGHT, 0, [{"type": "interact", "target_id": &"master"}])
	projection.configure(master_recording.snapshot(), 0)
	projection.play_tick(0)
	resolver = ActionResolver.new()
	resolver.resolve(devices, [], [projection], rook, {}, 0)
	assert(not master.latched, "Echoes cannot activate live-only master")
	north.position = Vector2.ZERO
	var duplicates := EchoRecorder.new()
	duplicates.append(Vector2.ZERO, Vector2.RIGHT, 0, [{"type": "interact", "target_id": &"north"}, {"type": "interact", "target_id": &"north"}])
	projection.configure(duplicates.snapshot(), 0)
	projection.play_tick(0)
	var activations: Array[Dictionary] = []
	resolver = ActionResolver.new()
	resolver.activated.connect(func(event: Dictionary) -> void: activations.append(event))
	resolver.resolve(devices, [], [projection], rook, {}, 0)
	resolver.resolve(devices, [], [projection], rook, {}, 0)
	assert(activations.size() == 1 and north.charge_until_tick == 240)
	assert(not north.can_activate(0, 11, devices) and north.can_activate(0, 12, devices))
	assert(south.try_activate(0, 0, devices))
	master.required_terminal_ids = [&"north", &"south"]
	master.require_distinct_actors = true
	assert(not master.can_activate(4, 1, devices), "Two charges from one actor do not satisfy the visible two-actor conductor")
	assert(south.try_activate(1, 12, devices))
	assert(master.try_activate(4, 12, devices))
	assert(master.latched and not master.try_activate(4, 30, devices))
	projection.free()
	rook.free()
	north.free()
	south.free()
	master.free()
	print("PASS actions: stable target/no retarget, Echo compatibility, duplicate E rejection, debounce, two-actor conductor, one-shot master")
	quit(0)
