extends PathFollow2D

var direction = 1

func _physics_process(delta: float) -> void:
	progress += direction
	if progress_ratio >= 1 or progress_ratio <= 0:
		direction = -direction
