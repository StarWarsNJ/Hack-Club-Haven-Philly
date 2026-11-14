class_name ActionResolver
extends RefCounted
## Accepted actions only. World target validation never changes recorded poses.
signal activated(event: Dictionary)
const PULSE_RANGE: float = 76.0
const PULSE_COOLDOWN: int = 210
var last_rejection: String = ""
var _tick: int = -1
var _seen: Dictionary = {}

func resolve(devices: Dictionary, sentinels: Array[OrbitSentinel], echoes: Array[EchoPlayer], rook: Rook, requests: Dictionary, tick: int) -> Array[Dictionary]:
	if tick != _tick:
		_seen.clear()
		_tick = tick
	var accepted: Array[Dictionary] = []
	# Explicit slot order is independent of scene-tree/registration order.
	for slot: int in range(4):
		for projection: EchoPlayer in echoes:
			if not projection.active or projection.slot != slot:
				continue
			var events := projection.tape.actions_at(tick)
			for sequence: int in range(events.size()):
				var key := "%d:%d:%d" % [slot, tick, sequence]
				if _seen.has(key):
					continue
				_seen[key] = true
				var event := events[sequence]
				if event["type"] == "interact":
					apply_interaction(devices, projection, slot, event.get("target_id", &""), tick)
				elif event["type"] == "pulse":
					apply_pulse(devices, projection, slot, event.get("target_ids", []), tick)
	var interaction_key := "LIVE:INTERACT:%d" % tick
	if requests.get("interact", false) and not _seen.has(interaction_key):
		_seen[interaction_key] = true
		var target := nearest_terminal(devices, rook.global_position, tick)
		if tick >= rook.interact_ready_tick and target != null and apply_interaction(devices, rook, 4, target.device_id, tick):
			rook.interact_ready_tick = tick + ResonanceTerminal.DEBOUNCE_TICKS
			accepted.append({"type": "interact", "target_id": target.device_id})
		else:
			last_rejection = "No eligible terminal within 48px, or interaction recharging."
	var live_key := "LIVE:PULSE:%d" % tick
	if requests.get("pulse", false) and rook.pulse_enabled and not _seen.has(live_key):
		_seen[live_key] = true
		if tick >= rook.pulse_ready_tick:
			rook.pulse_ready_tick = tick + PULSE_COOLDOWN
			var targets: Array[StringName] = []
			for sentinel: OrbitSentinel in sentinels:
				if rook.global_position.distance_squared_to(sentinel.global_position) <= PULSE_RANGE * PULSE_RANGE:
					targets.append(sentinel.device_id)
			targets.sort()
			var event := {"type": "pulse", "target_ids": targets.duplicate()}
			apply_pulse(devices, rook, 4, targets, tick)
			accepted.append(event)
		else:
			last_rejection = "Pulse recharging. Only accepted casts are recorded."
	return accepted

func apply_pulse(devices: Dictionary, actor: Node2D, actor_id: int, targets: Array, tick: int) -> void:
	var hits: int = 0
	for target_id: StringName in targets:
		var target := devices.get(target_id) as OrbitSentinel
		if target == null or actor.global_position.distance_squared_to(target.global_position) > PULSE_RANGE * PULSE_RANGE:
			last_rejection = "E%d pulse missed %s: target unavailable or out of range." % [actor_id + 1, target_id]
			continue
		target.freeze(tick)
		hits += 1
	actor.show_pulse(tick)
	activated.emit({"tick": tick, "actor_id": actor_id, "type": "pulse", "hit_count": hits})

func nearest_terminal(devices: Dictionary, position: Vector2, tick: int) -> ResonanceTerminal:
	var nearest: ResonanceTerminal
	var best_distance: float = 48.0 * 48.0
	for device: Node2D in devices.values():
		if not device is ResonanceTerminal:
			continue
		var terminal := device as ResonanceTerminal
		var distance := position.distance_squared_to(terminal.global_position)
		if distance > best_distance or not terminal.can_activate(4, tick, devices):
			continue
		if nearest == null or distance < best_distance or String(terminal.device_id) < String(nearest.device_id):
			nearest = terminal
			best_distance = distance
	return nearest

func apply_interaction(devices: Dictionary, actor: Node2D, actor_id: int, target_id: StringName, tick: int) -> bool:
	var target := devices.get(target_id) as ResonanceTerminal
	if target == null or actor.global_position.distance_squared_to(target.global_position) > 48.0 * 48.0 or not target.try_activate(actor_id, tick, devices):
		last_rejection = "Recorded interaction rejected: target, range, compatibility or charge conditions changed."
		return false
	activated.emit({"tick": tick, "actor_id": actor_id, "type": "interact", "target_id": target_id})
	return true
