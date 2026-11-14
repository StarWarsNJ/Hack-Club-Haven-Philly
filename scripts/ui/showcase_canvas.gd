class_name ShowcaseCanvas
extends Control
var snapshot: ShowcaseSnapshot
var frame_tick: int = 0

func _draw() -> void:
	if snapshot == null or snapshot.live_tape == null:
		return
	var factor := minf(size.x / 1152.0, size.y / 648.0)
	var offset := (size - Vector2(1152, 648) * factor) / 2
	draw_rect(Rect2(offset, Vector2(1152, 648) * factor), UiFactory.INK)
	for wall: Rect2 in snapshot.walls:
		draw_rect(Rect2(offset + wall.position * factor, wall.size * factor), UiFactory.PANEL)
	for marker: Dictionary in snapshot.markers:
		var point: Vector2 = offset + marker["position"] * factor
		var color := UiFactory.BRASS
		if marker["label"] == "CORE" and frame_tick >= snapshot.core_tick:
			color = Color("74dbbb")
		draw_arc(point, 11, 0, TAU, 24, color, 2, true)
		draw_string(ThemeDB.fallback_font, point + Vector2(14, 4), marker["label"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)
	for slot: int in range(snapshot.tapes.size()):
		var tape := snapshot.tapes[slot]
		if tape != null and frame_tick < tape.duration_ticks:
			draw_actor(offset + tape.position_at(frame_tick) * factor, "E%d" % (slot + 1), EchoPlayer.COLORS[slot])
	if frame_tick < snapshot.live_tape.duration_ticks:
		var point := offset + snapshot.live_tape.position_at(frame_tick) * factor
		draw_actor(point, "LIVE", Color.WHITE)
		if not snapshot.live_tape.actions_at(frame_tick).is_empty():
			draw_arc(point, 18, 0, TAU, 24, UiFactory.BRASS, 2, true)
	draw_string(ThemeDB.fallback_font, Vector2(16, 22), "RECORDED TIME %.1fs" % (float(frame_tick) / MissionClock.HZ), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, UiFactory.MUTED)

func draw_actor(point: Vector2, actor_title: String, color: Color) -> void:
	draw_circle(point, 7, Color(color, 0.6))
	draw_arc(point, 9, 0, TAU, 20, color, 2, true)
	draw_string(ThemeDB.fallback_font, point + Vector2(-8, -13), actor_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, color)
