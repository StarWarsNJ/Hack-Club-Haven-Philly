class_name MissionHUD
extends Control
signal pause_requested
signal hint_requested
var dial: MissionClockDial
var hint: Label
var status: Label
var objective: Label
var mission_title: Label
var budget_label: Label
var hint_button: Button
var _slot_labels: Array[Label] = []
var _slot_panels: Array[PanelContainer] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var header := PanelContainer.new()
	header.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = 108
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("151a31")
	panel.border_color = Color("283654")
	panel.border_width_bottom = 2
	panel.content_margin_left = 24
	panel.content_margin_right = 24
	panel.content_margin_top = 10
	panel.content_margin_bottom = 8
	header.add_theme_stylebox_override("panel", panel)
	add_child(header)
	var row := Control.new()
	row.custom_minimum_size.y = 88
	header.add_child(row)
	var mission := VBoxContainer.new()
	mission.add_theme_constant_override("separation", 2)
	mission.custom_minimum_size.x = 390
	mission.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	mission.offset_right = 390
	mission.offset_bottom = 88
	row.add_child(mission)
	mission_title = UiFactory.label(mission, "", 20, UiFactory.BRASS)
	objective = UiFactory.label(mission, "", 16)
	budget_label = UiFactory.label(mission, "", 12, UiFactory.MUTED)
	dial = MissionClockDial.new()
	dial.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	dial.offset_left = -75
	dial.offset_right = 75
	dial.offset_bottom = 82
	row.add_child(dial)
	var bank := VBoxContainer.new()
	bank.custom_minimum_size.x = 340
	bank.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	bank.offset_left = -340
	bank.offset_right = 0
	bank.offset_bottom = 88
	bank.add_theme_constant_override("separation", 4)
	row.add_child(bank)
	var badges := HBoxContainer.new()
	badges.add_theme_constant_override("separation", 6)
	bank.add_child(badges)
	for slot: int in range(4):
		var box := PanelContainer.new()
		box.custom_minimum_size = Vector2(80, 40)
		badges.add_child(box)
		var label := UiFactory.label(box, "E%d\n—" % (slot + 1), 14, UiFactory.MUTED)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_slot_labels.append(label)
		_slot_panels.append(box)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	bank.add_child(buttons)
	var pause_button := UiFactory.button(buttons, "Pause / Esc", func() -> void: pause_requested.emit())
	pause_button.add_theme_font_size_override("font_size", 14)
	pause_button.custom_minimum_size.y = 30
	hint_button = UiFactory.button(buttons, "Hint / H", func() -> void: hint_requested.emit())
	hint_button.add_theme_font_size_override("font_size", 14)
	hint_button.custom_minimum_size.y = 30
	var bottom := PanelContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -78
	var footer := panel.duplicate() as StyleBoxFlat
	footer.border_width_bottom = 0
	footer.border_width_top = 2
	footer.content_margin_top = 8
	footer.content_margin_bottom = 8
	bottom.add_theme_stylebox_override("panel", footer)
	add_child(bottom)
	var lines := VBoxContainer.new()
	lines.add_theme_constant_override("separation", 4)
	bottom.add_child(lines)
	hint = UiFactory.label(lines, "WASD / arrows Move · Q Bank · R Retry · Tab Timeline · Esc Pause · H Hint", 14, UiFactory.CYAN)
	status = UiFactory.label(lines, "", 15, UiFactory.MUTED)
	update_bank([null, null, null, null])

func update_clock(clock: MissionClock) -> void:
	dial.completed_ticks = clock.completed_ticks
	dial.queue_redraw()

func update_bank(bank: Array[EchoTape]) -> void:
	for slot: int in range(4):
		var saved := bank[slot] != null
		var color := EchoPlayer.COLORS[slot] if saved else UiFactory.MUTED
		_slot_labels[slot].text = "E%d\n%s" % [slot + 1, ("%.1fs" % (float(bank[slot].duration_ticks) / MissionClock.HZ)) if saved else "empty"]
		_slot_labels[slot].add_theme_color_override("font_color", color)
		var box := StyleBoxFlat.new()
		box.bg_color = Color(color, 0.08)
		box.border_color = Color(color, 0.65 if saved else 0.2)
		box.set_border_width_all(1)
		box.set_corner_radius_all(5)
		_slot_panels[slot].add_theme_stylebox_override("panel", box)

func set_objective(text: String) -> void:
	objective.text = text

func set_mission(definition: MissionDefinition) -> void:
	mission_title.text = definition.mission_id + " / " + definition.title.to_upper()
	set_objective(definition.objective)
	budget_label.text = "2 stars: ≤%d %s · 3 stars: ≤25s + budget" % [definition.echo_budget, "Echo" if definition.echo_budget == 1 else "Echoes"]

func update_abilities(rook: Rook, tick: int) -> void:
	hint.text = "WASD/arrows Move · Q Bank · R Retry · Tab Timeline · Esc Pause · H Hint"
	if rook.dash_enabled:
		var remaining := maxf(0, float(rook.dash_ready_tick - tick) / MissionClock.HZ)
		hint.text += " · Shift " + ("ready" if remaining <= 0 else "%.1fs" % remaining)
	if rook.pulse_enabled:
		var remaining := maxf(0, float(rook.pulse_ready_tick - tick) / MissionClock.HZ)
		hint.text += " · Space " + ("ready" if remaining <= 0 else "%.1fs" % remaining)
