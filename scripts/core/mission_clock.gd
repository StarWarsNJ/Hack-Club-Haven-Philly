class_name MissionClock
extends RefCounted
## Integer time authority. completed_ticks is a count, never a sample index.
const HZ: int = 60
const LIMIT: int = 1800
var completed_ticks: int = 0
var paused: bool = false

func advance() -> bool:
	if paused or completed_ticks >= LIMIT:
		return false
	completed_ticks += 1
	return true

func reset() -> void:
	completed_ticks = 0
	paused = false

func remaining_seconds() -> float:
	return float(LIMIT - completed_ticks) / HZ
