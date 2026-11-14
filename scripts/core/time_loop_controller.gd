class_name TimeLoopController
extends RefCounted
## MissionController is the single physics callback; this class owns time and tapes.
## Sample k is post-movement; 600 samples means indices 0..599, inactive at 600.
enum State { RUNNING, PAUSED, BANK_CONFIRM, REVIEW, FAILED, COMPLETED }
var clock := MissionClock.new()
var recorder := EchoRecorder.new()
var bank: Array[EchoTape] = []
var capacity: int = 4
var _undo_bank: Array[EchoTape] = []
var _bank_committed: bool = false
var state: State = State.RUNNING
var generation: int = 0
var _bank_return: State = State.RUNNING

func _init() -> void:
	bank.resize(4)

func set_state(next: State) -> void:
	state = next
	clock.paused = state != State.RUNNING

func reset_attempt(start: Vector2) -> void:
	generation += 1
	clock.reset()
	recorder = EchoRecorder.new(start)
	set_state(State.RUNNING)

func finish_tick(position: Vector2, facing: Vector2, animation: int, accepted: Array[Dictionary] = [], markers: Array[Dictionary] = []) -> void:
	assert(state == State.RUNNING and clock.completed_ticks < MissionClock.LIMIT)
	assert(recorder.duration_ticks == clock.completed_ticks)
	var recorded := recorder.append(position, facing, animation, accepted, markers)
	var advanced := clock.advance()
	assert(recorded and advanced)
	if clock.completed_ticks == MissionClock.LIMIT:
		set_state(State.REVIEW)

func request_bank() -> bool:
	if state not in [State.RUNNING, State.REVIEW] or recorder.duration_ticks == 0:
		return false
	_bank_committed = false
	_bank_return = state
	set_state(State.BANK_CONFIRM)
	return true

func cancel_bank() -> void:
	if state == State.BANK_CONFIRM:
		set_state(_bank_return)

func free_slot() -> int:
	for slot: int in range(capacity):
		if bank[slot] == null:
			return slot
	return -1

func commit_bank(slot: int = -1) -> bool:
	if state != State.BANK_CONFIRM or _bank_committed:
		return false
	var selected := free_slot() if slot == -1 else slot
	if selected < 0 or selected >= capacity:
		return false
	_undo_bank = bank.duplicate()
	bank[selected] = recorder.snapshot()
	_bank_committed = true
	return true

func bank_count() -> int:
	var count: int = 0
	for tape: EchoTape in bank:
		if tape != null:
			count += 1
	return count

func has_undo() -> bool:
	return not _undo_bank.is_empty()

func remove_tape(slot: int) -> bool:
	if state not in [State.PAUSED, State.REVIEW] or slot < 0 or slot >= 4 or bank[slot] == null:
		return false
	_undo_bank = bank.duplicate()
	bank[slot] = null
	return true

func undo_bank_change() -> bool:
	if state not in [State.PAUSED, State.REVIEW] or not has_undo():
		return false
	bank = _undo_bank.duplicate()
	_undo_bank.clear()
	return true

func clear_bank() -> void:
	bank.fill(null)
	_undo_bank.clear()
