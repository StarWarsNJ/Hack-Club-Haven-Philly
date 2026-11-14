class_name ProgressStore
extends RefCounted
## Local versioned JSON. Never stores mission state, tapes or online identifiers.
const SAVE_PATH: String = "user://paradox_heist_v1.json"
const VERSION: int = 1
const MISSION_IDS: Array[String] = ["M1", "M2", "M3", "M4", "M5", "M6", "M7", "M8"]
const DEFAULT_SETTINGS: Dictionary = {"master_volume": 1.0, "music_volume": 0.6, "sfx_volume": 0.8, "fullscreen": false, "reduce_flashes": false, "show_hints": true, "screen_shake": true}
var file_path: String
var mission_results: Dictionary = {}
var settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)
var last_error: String = ""
var _read_only: bool = false
var _corrupt_payload: String = ""

func _init(save_path: String = SAVE_PATH) -> void:
	file_path = save_path # Empty string is an explicitly injected transient test profile.

func load_from_disk() -> bool:
	if file_path.is_empty():
		return true
	mission_results.clear()
	settings = DEFAULT_SETTINGS.duplicate(true)
	last_error = ""
	_read_only = false
	_corrupt_payload = ""
	if not FileAccess.file_exists(file_path):
		return true
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		last_error = "Local progress could not be read. Playing with a fresh session."
		return false
	var text := file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		_corrupt_payload = text
		last_error = "Local progress was damaged. A fresh session is available; the old data will be backed up before saving."
		return false
	var data: Dictionary = parser.data
	if numeric(data.get("version"), -1) != VERSION:
		_read_only = true
		last_error = "Local progress uses an unsupported version. This session will not overwrite it."
		return false
	var raw_settings: Variant = data.get("settings", {})
	if raw_settings is Dictionary:
		for key: String in DEFAULT_SETTINGS:
			set_setting(key, raw_settings.get(key, DEFAULT_SETTINGS[key]))
	var missions: Variant = data.get("missions", {})
	if missions is Dictionary:
		for id: String in MISSION_IDS:
			var raw: Variant = missions.get(id, {})
			if not raw is Dictionary:
				continue
			var stars := int(numeric(raw.get("stars"), 0))
			var ticks := int(numeric(raw.get("best_ticks"), 0))
			if stars >= 1 and stars <= 3 and ticks >= 1 and ticks <= MissionClock.LIMIT:
				mission_results[id] = {"stars": stars, "best_ticks": ticks}
	return true

func save_to_disk() -> bool:
	if file_path.is_empty():
		return true
	if _read_only:
		return false
	var directory := ProjectSettings.globalize_path(file_path.get_base_dir())
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		last_error = "Local saves are unavailable. Progress will remain in this session."
		return false
	if not _corrupt_payload.is_empty():
		var backup := FileAccess.open(file_path + ".corrupt-" + str(Time.get_ticks_usec()), FileAccess.WRITE)
		if backup == null:
			last_error = "Could not preserve damaged save data; it was not overwritten."
			return false
		backup.store_string(_corrupt_payload)
		backup.close()
		_corrupt_payload = ""
	var temp_path := file_path + ".tmp"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		last_error = "Local saves are unavailable. Progress will remain in this session."
		return false
	file.store_string(JSON.stringify({"version": VERSION, "missions": mission_results, "settings": settings}, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK or DirAccess.rename_absolute(ProjectSettings.globalize_path(temp_path), ProjectSettings.globalize_path(file_path)) != OK:
		last_error = "Local save could not be replaced. The previous save was preserved."
		return false
	last_error = ""
	return true

func record_result(id: String, ticks: int, echo_count: int, budget: int) -> bool:
	if not MISSION_IDS.has(id):
		return false
	var stars := ScoreRules.grade(ticks, echo_count, budget)
	if stars == 0:
		return false
	var previous: Dictionary = mission_results.get(id, {})
	mission_results[id] = {"stars": maxi(stars, int(previous.get("stars", 0))), "best_ticks": mini(ticks, int(previous.get("best_ticks", MissionClock.LIMIT)))}
	return save_to_disk()

func is_unlocked(id: String) -> bool:
	var index := MISSION_IDS.find(id)
	if index < 0:
		return false
	for previous: int in range(index):
		if not mission_results.has(MISSION_IDS[previous]):
			return false
	return true

func continue_id() -> String:
	for id: String in MISSION_IDS:
		if is_unlocked(id) and not mission_results.has(id):
			return id
	return "M1"

func result_for(id: String) -> Dictionary:
	var result: Dictionary = mission_results.get(id, {})
	return result.duplicate(true)

func set_setting(key: String, value: Variant) -> void:
	if not DEFAULT_SETTINGS.has(key):
		return
	if key.ends_with("_volume"):
		settings[key] = clampf(numeric(value, DEFAULT_SETTINGS[key]), 0, 1)
	else:
		settings[key] = value if value is bool else DEFAULT_SETTINGS[key]

static func numeric(value: Variant, fallback: float) -> float:
	if typeof(value) in [TYPE_FLOAT, TYPE_INT]:
		var number := float(value)
		if is_finite(number):
			return number
	return fallback
