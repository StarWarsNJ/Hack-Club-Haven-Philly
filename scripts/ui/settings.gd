extends Control
signal navigate(route: String)

func _ready() -> void:
	var column := UiFactory.page(self)
	UiFactory.label(column, "SETTINGS", 38)
	UiFactory.label(column, "Your mix, your timing.", 20, UiFactory.MUTED)
	var first: HSlider
	for bus_name: String in ["Master", "Music", "SFX"]:
		UiFactory.label(column, bus_name)
		var slider := HSlider.new()
		slider.name = bus_name + "Volume"
		slider.max_value = 1.0
		slider.step = 0.01
		slider.custom_minimum_size.y = 32
		var index := AudioServer.get_bus_index(bus_name)
		slider.value = 0.0 if AudioServer.is_bus_mute(index) else db_to_linear(AudioServer.get_bus_volume_db(index))
		slider.value_changed.connect(func(value: float) -> void:
			AudioServer.set_bus_mute(index, value <= 0.0)
			AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))
		)
		column.add_child(slider)
		if first == null:
			first = slider
	UiFactory.label(column, "Audio controls are ready; mission sounds arrive in later milestones.", 16, UiFactory.MUTED)
	UiFactory.button(column, "Back", handle_cancel)
	first.grab_focus()

func handle_cancel() -> void:
	navigate.emit("menu")
