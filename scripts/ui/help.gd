extends Control
signal navigate(route: String)

func _ready() -> void:
	var column := UiFactory.page(self)
	UiFactory.label(column, "BORROW A SECOND", 38)
	UiFactory.label(column, "Record a route. Bank it. Work alongside your past self.", 22, UiFactory.CYAN)
	UiFactory.label(column, "WASD / arrows     Move\nShift                       Dash (introduced in M3)\nE                              Interact with a nearby terminal\nSpace                      Temporal pulse (introduced in M4)\nQ                              Bank with confirmation\nR                              Retry without saving\nH                              Progressive hints (optional)\nTab                          Pause / Timeline Director\nEsc                          Pause / resume", 20)
	UiFactory.label(column, "Echoes follow saved poses and pass through walls.\nThey hold resonance pads, but only live Rook can finish a mission.", 18, UiFactory.MUTED)
	UiFactory.button(column, "Back", handle_cancel).grab_focus()

func handle_cancel() -> void:
	navigate.emit("menu")
