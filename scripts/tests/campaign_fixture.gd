class_name CampaignFixture
extends RefCounted
## All integration scenarios use memory-only profiles, never a player's save.
static func app(unlock_all: bool = true) -> Control:
	var result: Control = load("res://scenes/main.tscn").instantiate()
	result.progress = ProgressStore.new("")
	if unlock_all:
		for id: String in ProgressStore.MISSION_IDS:
			result.progress.record_result(id, 1200, 4, 4)
	return result
