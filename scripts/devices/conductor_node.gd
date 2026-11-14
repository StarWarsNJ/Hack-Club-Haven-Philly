class_name ConductorNode
extends Node2D
@export var device_id: StringName = &"conductor"
@export var station_ids: Array[StringName] = [&"pad_a", &"pad_b", &"pad_c", &"pad_d"]
@export var master_terminal_id: StringName = &"core"
@export var required_ticks: int = 120
var occupied_count: int = 0
var active_ticks: int = 0
var is_ready: bool = false

func evaluate(devices: Dictionary) -> void:
	var candidates: Array = []
	occupied_count = 0
	for id: StringName in station_ids:
		var pad := devices.get(id) as ResonancePad
		var occupants := PackedInt32Array() if pad == null else pad.occupants.duplicate()
		if not occupants.is_empty():
			occupied_count += 1
		candidates.append(occupants)
	var matched := occupied_count == station_ids.size() and assign_distinct(candidates, 0, {})
	active_ticks = active_ticks + 1 if matched else 0
	is_ready = active_ticks >= required_ticks
	var master := devices.get(master_terminal_id) as ResonanceTerminal
	if master != null:
		master.externally_enabled = is_ready or master.latched
	queue_redraw()

func assign_distinct(candidates: Array, index: int, used: Dictionary) -> bool:
	if index >= candidates.size():
		return true
	for actor_id: int in candidates[index]:
		if used.has(actor_id):
			continue
		used[actor_id] = true
		if assign_distinct(candidates, index + 1, used):
			return true
		used.erase(actor_id)
	return false

func _draw() -> void:
	var color := Color("74dbbb") if is_ready else Color("d9ac5f")
	draw_arc(Vector2.ZERO, 72, 0, TAU, 64, Color(color, 0.2), 3, true)
	var fraction := clampf(float(active_ticks) / required_ticks, 0, 1)
	if fraction > 0:
		draw_arc(Vector2.ZERO, 72, -PI / 2, -PI / 2 + TAU * fraction, 64, color, 4, true)
	draw_string(ThemeDB.fallback_font, Vector2(-64, 91), "%d/4 STATIONS · %.1f/2s" % [occupied_count, minf(float(active_ticks) / MissionClock.HZ, 2.0)], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)
