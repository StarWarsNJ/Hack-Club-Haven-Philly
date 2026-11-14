class_name ScoreRules
extends RefCounted
const FAST_TICKS: int = 1500

static func grade(ticks: int, echo_count: int, budget: int) -> int:
	if ticks <= 0 or ticks > MissionClock.LIMIT or echo_count < 0 or echo_count > 4:
		return 0
	if echo_count > budget:
		return 1
	return 3 if ticks <= FAST_TICKS else 2

static func explanation(ticks: int, echo_count: int, budget: int) -> String:
	var efficient := echo_count <= budget
	return "Clear: +1 star\nEcho budget: %d / %d → %s\nFinal run: %.2fs / 25.00s → %s" % [echo_count, budget, "+1 star" if efficient else "no efficiency star", float(ticks) / MissionClock.HZ, "+1 star" if efficient and ticks <= FAST_TICKS else ("fast star requires an efficient clear" if not efficient else "no fast star")]
