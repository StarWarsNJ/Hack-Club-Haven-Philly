class_name SimulationGeometry
extends RefCounted
## Swept center against expanded bounds; catches thin hazards during dashes.
static func segment_hits_rect(from: Vector2, to: Vector2, rect: Rect2) -> bool:
	var enter: float = 0.0
	var leave: float = 1.0
	var delta := to - from
	for axis: int in range(2):
		if absf(delta[axis]) < 0.00001:
			if from[axis] < rect.position[axis] or from[axis] > rect.end[axis]:
				return false
		else:
			var first := (rect.position[axis] - from[axis]) / delta[axis]
			var last := (rect.end[axis] - from[axis]) / delta[axis]
			enter = maxf(enter, minf(first, last))
			leave = minf(leave, maxf(first, last))
			if enter > leave:
				return false
	return true
