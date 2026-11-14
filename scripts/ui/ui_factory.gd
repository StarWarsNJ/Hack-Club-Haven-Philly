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
	result.default_font_size = 20
	result.set_color("font_color", "Label", WHITE)
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = PANEL if state != "hover" else Color("354966")
		box.border_color = CYAN if state == "focus" else Color("506080")
		box.set_border_width_all(2 if state == "focus" else 1)
		box.set_corner_radius_all(8)
		box.content_margin_left = 20
		box.content_margin_right = 20
		box.content_margin_top = 10
		box.content_margin_bottom = 10
		result.set_stylebox(state, "Button", box)
	result.set_constant("separation", "VBoxContainer", 12)
	result.set_constant("separation", "HBoxContainer", 20)
	return result

static func page(parent: Control) -> VBoxContainer:
	var background := ColorRect.new()
	background.color = INK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(background)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 640
	center.add_child(column)
	return column

static func label(parent: Node, text: String, font_size: int = 20, color: Color = WHITE) -> Label:
	var result := Label.new()
	result.text = text
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
