extends Node2D
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_local_mouse_position()
	$Sprite2D.position = $Sprite2D.position.lerp(mouse_pos, delta * 20)
