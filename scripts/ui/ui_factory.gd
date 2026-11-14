class_name UiFactory
extends RefCounted

const INK := Color("151a31")
const PANEL := Color("283654")
const CYAN := Color("58d7ef")
const BRASS := Color("d9ac5f")
const WHITE := Color("edf4ff")
const MUTED := Color("aebbd2")

static func make_theme() -> Theme:
	var result := Theme.new()
	result.default_font_size = 18
	result.set_color("font_color", "Label", WHITE)
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = PANEL if state != "hover" else Color("354966")
		box.border_color = CYAN if state == "focus" else Color("506080")
		box.set_border_width_all(2 if state == "focus" else 1)
		box.set_corner_radius_all(8)
		box.content_margin_left = 20
		box.content_margin_right = 20
		box.content_margin_top = 8
		box.content_margin_bottom = 8
		result.set_stylebox(state, "Button", box)
	result.set_constant("separation", "VBoxContainer", 8)
	result.set_constant("separation", "HBoxContainer", 20)
	return result

static func page(parent: Control) -> VBoxContainer:
	var background := ParadoxBackdrop.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(background)
	var margins := MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margins.add_theme_constant_override("margin_left", 24)
	margins.add_theme_constant_override("margin_right", 24)
	margins.add_theme_constant_override("margin_top", 18)
	margins.add_theme_constant_override("margin_bottom", 18)
	parent.add_child(margins)
	var scroll := ScrollContainer.new()
	scroll.name = "PageScroll"
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	margins.add_child(scroll)
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	var panel := PanelContainer.new()
	var surface := StyleBoxFlat.new()
	surface.bg_color = Color("151a31")
	surface.border_color = Color("3b4c69")
	surface.set_border_width_all(1)
	surface.set_corner_radius_all(12)
	surface.shadow_color = Color(0, 0, 0, 0.25)
	surface.shadow_size = 12
	surface.content_margin_left = 28
	surface.content_margin_right = 28
	surface.content_margin_top = 20
	surface.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", surface)
	center.add_child(panel)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 640
	panel.add_child(column)
	return column

static func label(parent: Node, text: String, font_size: int = 20, color: Color = WHITE) -> Label:
	var result := Label.new()
	result.text = text
	if font_size <= 22:
		result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.add_theme_font_size_override("font_size", font_size)
	result.add_theme_color_override("font_color", color)
	parent.add_child(result)
	return result

static func button(parent: Node, text: String, callback: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size.y = 44
	result.pressed.connect(callback)
	parent.add_child(result)
	return result
