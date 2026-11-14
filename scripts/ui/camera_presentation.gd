class_name CameraPresentation
extends Camera2D
## Camera-only response; never modifies positions, collision, tapes or clocks.
var shake_enabled: bool = true
var _remaining: float = 0.0
var _strength: float = 0.0

func bump(strength: float = 2.0) -> void:
	if shake_enabled:
		_remaining = 0.16
		_strength = strength

func _process(delta: float) -> void:
	if not shake_enabled:
		_remaining = 0
		offset = Vector2.ZERO
		return
	_remaining = maxf(0, _remaining - delta)
	var phase := (0.16 - _remaining) * 80.0
	offset = Vector2(sin(phase), cos(phase * 1.3)) * _strength * (_remaining / 0.16)
