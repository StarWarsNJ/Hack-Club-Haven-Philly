class_name MissionCatalog
extends RefCounted
const MISSIONS: Array[MissionDefinition] = [
	preload("res://resources/missions/m01.tres"),
	preload("res://resources/missions/m02.tres"),
	preload("res://resources/missions/m03.tres"),
	preload("res://resources/missions/m04.tres"),
	preload("res://resources/missions/m05.tres"),
	preload("res://resources/missions/m06.tres"),
	preload("res://resources/missions/m07.tres"),
	preload("res://resources/missions/m08.tres"),
]

static func find(id: String) -> MissionDefinition:
	for mission: MissionDefinition in MISSIONS:
		if mission.mission_id == id:
			return mission
	return MISSIONS[0]

static func next_id(id: String) -> String:
	for index: int in range(MISSIONS.size() - 1):
		if MISSIONS[index].mission_id == id:
			return MISSIONS[index + 1].mission_id
	return ""
