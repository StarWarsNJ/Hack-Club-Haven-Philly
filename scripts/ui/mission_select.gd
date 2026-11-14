extends Control
signal navigate(route: String)
var profile: ProgressStore

func configure(store: ProgressStore) -> void:
	profile = store

func _ready() -> void:
	var column := UiFactory.page(self)
	column.custom_minimum_size.x = 900
	column.add_theme_constant_override("separation", 4)
	UiFactory.label(column, "THE VAULT OF TOMORROW", 32)
	UiFactory.label(column, "One star: clear · Two: Echo budget · Three: budget + final run ≤25s", 17, UiFactory.CYAN)
	var focused: bool = false
	for mission: MissionDefinition in MissionCatalog.MISSIONS:
		var result := profile.result_for(mission.mission_id)
		var unlocked := profile.is_unlocked(mission.mission_id)
		var detail := "LOCKED — clear the previous mission"
		if unlocked:
			detail = "%d/3 stars · best %s · budget %d" % [int(result.get("stars", 0)), ("%.2fs" % (float(result["best_ticks"]) / MissionClock.HZ)) if result.has("best_ticks") else "—", mission.echo_budget]
		var button := UiFactory.button(column, mission.mission_id + " / " + mission.title + "     " + detail, func() -> void: navigate.emit("mission:" + mission.mission_id))
		button.add_theme_font_size_override("font_size", 17)
		button.disabled = not unlocked
		if unlocked and not focused:
			button.grab_focus()
			focused = true
	UiFactory.button(column, "Back", handle_cancel)

func handle_cancel() -> void:
	navigate.emit("menu")
