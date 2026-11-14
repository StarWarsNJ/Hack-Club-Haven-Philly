extends Control
signal navigate(route: String)
signal preferences_changed
var profile: ProgressStore

func configure(store: ProgressStore) -> void:
	profile = store

func _ready() -> void:
	var column := UiFactory.page(self)
	column.add_theme_constant_override("separation", 6)
	UiFactory.label(column, "SETTINGS", 34)
	UiFactory.label(column, "Your mix, your timing.", 18, UiFactory.MUTED)
	var first: HSlider
	for bus_name: String in ["Master", "Music", "SFX"]:
		var row := HBoxContainer.new()
		column.add_child(row)
		var title := UiFactory.label(row, bus_name, 18)
		title.custom_minimum_size.x = 90
		var slider := HSlider.new()
		slider.name = bus_name + "Volume"
		slider.max_value = 1.0
		slider.step = 0.01
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.custom_minimum_size = Vector2(360, 32)
		var key := bus_name.to_lower() + "_volume"
		slider.value = profile.settings[key]
		slider.value_changed.connect(func(value: float) -> void:
			profile.set_setting(key, value)
			preferences_changed.emit()
		)
		row.add_child(slider)
		if first == null:
			first = slider
	for pair: Array in [["Fullscreen", "fullscreen"], ["Reduce flashes", "reduce_flashes"], ["Show progressive hints", "show_hints"], ["Screen shake", "screen_shake"]]:
		var check := CheckButton.new()
		check.name = pair[1]
		check.text = pair[0]
		check.button_pressed = profile.settings[pair[1]]
		if pair[1] == "fullscreen" and OS.has_feature("web"):
			check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		check.toggled.connect(func(value: bool) -> void:
			profile.set_setting(pair[1], value)
			preferences_changed.emit()
		)
		column.add_child(check)
	UiFactory.label(column, "Settings save when you leave this screen. H / Hint offers up to three nudges.", 15, UiFactory.MUTED)
	if not profile.last_error.is_empty():
		var warning := UiFactory.label(column, profile.last_error, 15, UiFactory.BRASS)
		warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	UiFactory.button(column, "Back", handle_cancel)
	first.grab_focus()

func handle_cancel() -> void:
	navigate.emit("menu")
