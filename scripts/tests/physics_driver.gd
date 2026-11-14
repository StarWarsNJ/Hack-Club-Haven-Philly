class_name TestPhysicsDriver
extends Node
signal finished
var action: Callable
var remaining: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func drive(ticks: int, callback: Callable) -> void:
	action = callback
	remaining = ticks
	await finished

func _physics_process(_delta: float) -> void:
	if remaining <= 0:
		return
	action.call()
	remaining -= 1
	if remaining == 0:
		finished.emit()
