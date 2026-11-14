class_name ShowcaseSnapshot
extends RefCounted
## Only sealed data. No mission controller, device nodes or replayed commands.
var tapes: Array[EchoTape] = []
var live_tape: EchoTape
var walls: Array[Rect2] = []
var markers: Array[Dictionary] = []
var core_tick: int = -1
