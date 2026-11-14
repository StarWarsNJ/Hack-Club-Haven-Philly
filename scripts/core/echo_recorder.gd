class_name EchoRecorder
extends RefCounted
var _positions := PackedVector2Array()
var _facings := PackedVector2Array()
var _animations := PackedByteArray()
var _actions: Dictionary = {}
var _markers: Array[Dictionary] = []
var _start: Vector2
var duration_ticks: int:
	get: return _positions.size()

func _init(start: Vector2 = Vector2.ZERO) -> void:
	_start = start

func append(position: Vector2, facing: Vector2, animation: int, accepted_actions: Array[Dictionary] = [], presence_events: Array[Dictionary] = []) -> bool:
	if duration_ticks >= MissionClock.LIMIT:
		return false
	for marker: Dictionary in presence_events:
		_markers.append(marker.duplicate(true))
	var tick := duration_ticks
	_positions.append(position)
	_facings.append(facing)
	_animations.append(animation)
	if not accepted_actions.is_empty():
		var events: Array[Dictionary] = []
		for accepted: Dictionary in accepted_actions:
			var event := accepted.duplicate(true)
			event["tick"] = tick
			events.append(event)
		_actions[tick] = events
	return true

func snapshot() -> EchoTape:
	return EchoTape.new(_positions, _facings, _animations, _actions, _start, _markers)
