extends Control
signal navigate(route: String)

func _ready() -> void:
	var column := UiFactory.page(self)
	UiFactory.label(column, "THE CHRONO BUREAU PRESENTS", 16, UiFactory.BRASS)
	UiFactory.label(column, "PARADOX HEIST", 56)
	UiFactory.label(column, "One thief. Thirty seconds. An army of your past selves.", 20, UiFactory.CYAN)
	var motif := Label.new()
	motif.text = "◷   ━━━   ◷   ━━━   ◷   ━━━   ◷"
	motif.add_theme_font_size_override("font_size", 30)
	motif.add_theme_color_override("font_color", UiFactory.BRASS)
	column.add_child(motif)
	var play := UiFactory.button(column, "Play  →", func() -> void: navigate.emit("mission"))
	UiFactory.button(column, "Settings", func() -> void: navigate.emit("settings"))
	UiFactory.button(column, "How to play", func() -> void: navigate.emit("help"))
	var footer := UiFactory.label(column, "WASD / arrows to move · Enter to choose · Esc to pause", 16, UiFactory.MUTED)
	UiFactory.button(column, "Close game" if OS.has_feature("web") else "Quit", func() -> void:
		if OS.has_feature("web"):
			footer.text = "You can close this browser tab to leave."
		else:
			get_tree().quit()
	)
	play.grab_focus()
