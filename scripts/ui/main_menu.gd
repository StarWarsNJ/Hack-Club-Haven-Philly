extends Control
signal navigate(route: String)
var profile: ProgressStore

func configure(store: ProgressStore) -> void:
	profile = store

func _ready() -> void:
	var column := UiFactory.page(self)
	UiFactory.label(column, "THE CHRONO BUREAU PRESENTS", 14, UiFactory.BRASS)
	UiFactory.label(column, "PARADOX HEIST", 52)
	UiFactory.label(column, "One thief. Thirty seconds. An army of your past selves.", 18, UiFactory.CYAN)
	UiFactory.label(column, "30 SECONDS / 4 ECHOES / ONE WAY OUT", 14, UiFactory.BRASS)
	var play := UiFactory.button(column, ("Play  →" if profile.mission_results.is_empty() else "Continue / " + profile.continue_id()), func() -> void: navigate.emit("mission"))
	UiFactory.button(column, "Mission select", func() -> void: navigate.emit("select"))
	UiFactory.button(column, "Settings", func() -> void: navigate.emit("settings"))
	UiFactory.button(column, "How to play", func() -> void: navigate.emit("help"))
	var footer := UiFactory.label(column, "WASD / arrows to move · Enter to choose · Esc to pause", 16, UiFactory.MUTED)
	UiFactory.button(column, "Close game" if OS.has_feature("web") else "Quit", func() -> void:
		if OS.has_feature("web"):
			footer.text = "You can close this browser tab to leave."
		else:
			get_tree().quit()
	)
	if not profile.last_error.is_empty():
		var warning := UiFactory.label(column, profile.last_error, 14, UiFactory.BRASS)
		warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	play.grab_focus()
