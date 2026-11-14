class_name MissionDefinition
extends Resource
@export var mission_id: String = "M1"
@export var title: String = "Borrowed Second"
@export var objective: String = ""
@export var world_scene: PackedScene
@export var echo_budget: int = 1
@export var echo_capacity: int = 4
@export_multiline var hint_before_bank: String = ""
@export_multiline var hint_after_bank: String = ""

@export var dash_enabled: bool = false

@export var pulse_enabled: bool = false

@export var finale: bool = false
@export var intro_lines := PackedStringArray()
