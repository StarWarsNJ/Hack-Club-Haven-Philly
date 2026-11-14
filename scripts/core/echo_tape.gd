class_name EchoTape
extends RefCounted
## Sealed playback value. Never expose owned mutable buffers to consumers.
## GDScript has no private fields: underscored members are an internal contract.
var _positions: PackedVector2Array
var _facings: PackedVector2Array
var _animations: PackedByteArray
var _actions: Dictionary
var _markers: Array[Dictionary] = []
var _initial_position: Vector2
var duration_ticks: int:
	get: return _positions.size()
var initial_position: Vector2:
	get: return _initial_position

func _init(positions: PackedVector2Array, facings: PackedVector2Array, animations: PackedByteArray, actions: Dictionary, start: Vector2, markers: Array[Dictionary] = []) -> void:
	assert(positions.size() <= MissionClock.LIMIT)
	assert(positions.size() == facings.size() and positions.size() == animations.size())
	_positions = positions.duplicate()
	_facings = facings.duplicate()
	_animations = animations.duplicate()
	_actions = actions.duplicate(true)
	_initial_position = start
	_markers = markers.duplicate(true)

func position_at(tick: int) -> Vector2:
	return _positions[tick]

func facing_at(tick: int) -> Vector2:
	return _facings[tick]

func animation_at(tick: int) -> int:
	return _animations[tick]

func actions_at(tick: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event: Dictionary in _actions.get(tick, []):
		result.append(event.duplicate(true))
	return result

func positions_copy() -> PackedVector2Array:
	return _positions.duplicate()

func markers_copy() -> Array[Dictionary]:
	return _markers.duplicate(true)
