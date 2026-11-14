class_name ResonanceTerminal
extends Node2D
signal state_changed
@export var device_id: StringName = &"north"
@export var display_name: String = "NORTH"
@export var live_only: bool = false
@export var one_shot: bool = false
@export var required_terminal_ids: Array[StringName] = []
@export var require_distinct_actors: bool = false
@export var externally_enabled: bool = true
@export var actor_requirement_label: String = "2 ACTORS"
@export var exit_window_ticks: int = 0
var activation_tick: int = -1
const CHARGE_TICKS: int = 240
const DEBOUNCE_TICKS: int = 12
var charge_until_tick: int = -1
var next_accept_tick: int = 0
var last_actor_id: int = -1
var latched: bool = false
var _display_tick: int = 0
var _display_step: int = -1

func is_charged(tick: int) -> bool:
	return latched or tick < charge_until_tick

func can_activate(actor_id: int, tick: int, devices: Dictionary) -> bool:
	if not externally_enabled or (live_only and actor_id != 4) or (one_shot and latched) or tick < next_accept_tick:
		return false
	var actors: Dictionary = {}
	for id: StringName in required_terminal_ids:
		var terminal := devices.get(id) as ResonanceTerminal
		if terminal == null or not terminal.is_charged(tick):
			return false
		actors[terminal.last_actor_id] = true
	return not require_distinct_actors or actors.size() >= required_terminal_ids.size()

func try_activate(actor_id: int, tick: int, devices: Dictionary) -> bool:
	if not can_activate(actor_id, tick, devices):
		return false
	activation_tick = tick
	last_actor_id = actor_id
	next_accept_tick = tick + DEBOUNCE_TICKS
	if one_shot:
		latched = true
	else:
		charge_until_tick = tick + CHARGE_TICKS
	_display_tick = tick
	queue_redraw()
	state_changed.emit()
	return true

func prepare_tick(tick: int) -> void:
	_display_tick = tick
	var step := ceili(float(maxi(0, charge_until_tick - tick)) / 6.0)
	if step != _display_step:
		_display_step = step
		queue_redraw()

func _draw() -> void:
	var charged := is_charged(_display_tick)
	var color := Color("58d7ef") if charged else Color("d9ac5f")
	if charged and last_actor_id >= 0 and last_actor_id < 4:
		color = EchoPlayer.COLORS[last_actor_id]
	draw_circle(Vector2.ZERO, 20, Color(color, 0.18))
	draw_rect(Rect2(-15, -15, 30, 30), color, false, 3)
	draw_arc(Vector2.ZERO, 48, 0, TAU, 40, Color(color, 0.12), 1, true)
	draw_string(ThemeDB.fallback_font, Vector2(-35, -48), display_name, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)
	var status := ("LIVE / " + actor_requirement_label) if live_only else "E / READY"
	if charged:
		status = "LATCHED" if latched else "%.1fs" % (float(maxi(0, charge_until_tick - _display_tick)) / MissionClock.HZ)
	draw_string(ThemeDB.fallback_font, Vector2(-42, 40), status, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)
