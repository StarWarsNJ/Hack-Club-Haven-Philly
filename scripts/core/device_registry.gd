class_name DeviceRegistry
extends RefCounted
signal sync_achieved(tick: int)
var conductors: Array[ConductorNode] = []
var current_tick: int = 0
var terminals: Array[ResonanceTerminal] = []
var required_goal_terminal_ids: Array[StringName] = []
var _was_synced: bool = false
## Stable IDs and explicit resolution; signals update presentation only.
var devices: Dictionary = {}
var pads: Array[ResonancePad] = []
var gates: Array[ClockGate] = []
var resolver := ActionResolver.new()
var sentinels: Array[OrbitSentinel] = []
var bridges: Array[ClockworkBridge] = []
var beams: Array[PhaseBeam] = []
var goal: MissionExit
var last_explanation: String = ""

func register(device: Node2D) -> void:
	var id: StringName = device.get("device_id")
	assert(not id.is_empty() and not devices.has(id), "Device IDs must be nonempty and unique")
	devices[id] = device
	if device is ResonancePad:
		pads.append(device)
	elif device is ClockGate:
		gates.append(device)
	elif device is ConductorNode:
		conductors.append(device)
	elif device is ResonanceTerminal:
		terminals.append(device)
	elif device is ClockworkBridge:
		bridges.append(device)
	elif device is OrbitSentinel:
		sentinels.append(device)
	elif device is PhaseBeam:
		beams.append(device)
	elif device is MissionExit:
		goal = device

func evaluate(actors: Array[Dictionary], live_position: Vector2, tick: int) -> Array[Dictionary]:
	var markers: Array[Dictionary] = []
	for pad: ResonancePad in pads:
		var before := pad.occupants.duplicate()
		var was_active := pad.active
		pad.evaluate(actors)
		for actor_id: int in before:
			if not pad.occupants.has(actor_id):
				markers.append({"tick": tick, "type": "pad_exit", "target_id": pad.device_id, "actor_id": actor_id})
		for actor_id: int in pad.occupants:
			if not before.has(actor_id):
				markers.append({"tick": tick, "type": "pad_enter", "target_id": pad.device_id, "actor_id": actor_id})
		if was_active and not pad.active:
			last_explanation = "Pad %s released at %.1fs. Check its gate circuit." % [pad.display_name, float(tick) / MissionClock.HZ]
	for conductor: ConductorNode in conductors:
		conductor.evaluate(devices)
	for gate: ClockGate in gates:
		var condition := not gate.required_pad_ids.is_empty() or not gate.required_terminal_ids.is_empty()
		for id: StringName in gate.required_pad_ids:
			assert(devices.has(id) and devices[id] is ResonancePad, "Unknown gate pad ID")
			condition = condition and (devices[id] as ResonancePad).active
		for id: StringName in gate.required_terminal_ids:
			var terminal := devices.get(id) as ResonanceTerminal
			condition = condition and terminal != null and terminal.is_charged(tick)
		gate.evaluate_circuit(condition, tick, live_position)
	for marker: Dictionary in markers:
		if marker["type"] == "pad_enter":
			resolver.activated.emit({"tick": tick, "actor_id": marker["actor_id"], "type": "pad", "target_id": marker["target_id"]})
	evaluate_sync(tick)
	return markers

func goal_conditions() -> bool:
	if not required_goal_terminal_ids.is_empty():
		for id: StringName in required_goal_terminal_ids:
			var terminal := devices.get(id) as ResonanceTerminal
			if terminal == null or not terminal.latched or (terminal.exit_window_ticks > 0 and current_tick >= terminal.activation_tick + terminal.exit_window_ticks):
				return false
		return true
	if gates.is_empty():
		return false
	for gate: ClockGate in gates:
		if not gate.condition_active:
			return false
	return true

func prepare_tick(tick: int, rook: Rook = null) -> void:
	current_tick = tick
	for bridge: ClockworkBridge in bridges:
		var before := bridge.footprint()
		var pad := devices.get(bridge.required_pad_id) as ResonancePad
		var riding := rook != null and bridge.gap_rect.has_point(rook.global_position) and before.has_point(rook.global_position)
		bridge.prepare_tick(tick, pad != null and pad.active)
		if riding and not bridge.frame_delta.is_zero_approx():
			rook.move_and_collide(bridge.frame_delta)
	for terminal: ResonanceTerminal in terminals:
		terminal.prepare_tick(tick)
	for sentinel: OrbitSentinel in sentinels:
		sentinel.prepare_tick(tick)
	for beam: PhaseBeam in beams:
		var pad := devices.get(beam.required_pad_id) as ResonancePad
		beam.prepare_tick(tick, pad != null and pad.active)

func failure_reason(from: Vector2, to: Vector2) -> String:
	for id: StringName in required_goal_terminal_ids:
		var core := devices.get(id) as ResonanceTerminal
		if core != null and core.latched and core.exit_window_ticks > 0 and current_tick >= core.activation_tick + core.exit_window_ticks:
			return "The five-second exit window closed. Your Echoes are safe; retry the live run."
	for bridge: ClockworkBridge in bridges:
		if bridge.gap_rect.has_point(to) and not bridge.supports_live(to):
			return "The bridge moved away. Bank an Echo on its pad to stabilize the crossing."
	for sentinel: OrbitSentinel in sentinels:
		if sentinel.hits_live(from, to):
			return "Orbit sentinel contact. A pulse pauses motion; contact is still unsafe."
	for beam: PhaseBeam in beams:
		if beam.hits_live(from, to):
			return "Phase beam contact. Wait for cyan; dash does not grant protection."
	return ""

func resolve_actions(echoes: Array[EchoPlayer], rook: Rook, requests: Dictionary, tick: int) -> Array[Dictionary]:
	var accepted := resolver.resolve(devices, sentinels, echoes, rook, requests, tick)
	if not resolver.last_rejection.is_empty():
		last_explanation = resolver.last_rejection
	return accepted

func evaluate_sync(tick: int) -> void:
	var actors: Dictionary = {}
	var active_devices: int = 0
	for pad: ResonancePad in pads:
		if pad.active:
			active_devices += 1
			for actor_id: int in pad.occupants:
				actors[actor_id] = true
	for terminal: ResonanceTerminal in terminals:
		if not terminal.one_shot and terminal.is_charged(tick):
			active_devices += 1
			actors[terminal.last_actor_id] = true
	var synced := active_devices >= 2 and actors.size() >= 2
	if synced and not _was_synced:
		sync_achieved.emit(tick)
	_was_synced = synced

func charge_status(tick: int) -> String:
	for id: StringName in required_goal_terminal_ids:
		var core := devices.get(id) as ResonanceTerminal
		if core != null and core.latched and core.exit_window_ticks > 0:
			return "EXIT WINDOW %.1fs — reach the glowing exit" % (float(maxi(0, core.activation_tick + core.exit_window_ticks - tick)) / MissionClock.HZ)
	if not conductors.is_empty():
		var conductor := conductors[0]
		return "%d/4 stations · overlap %.1f / 2.0s · E at CORE when ready" % [conductor.occupied_count, minf(float(conductor.active_ticks) / MissionClock.HZ, 2.0)]
	var parts := PackedStringArray()
	for terminal: ResonanceTerminal in terminals:
		if not terminal.one_shot:
			parts.append("%s %.1fs" % [terminal.display_name, float(maxi(0, terminal.charge_until_tick - tick)) / MissionClock.HZ])
	return "  ·  ".join(parts)
