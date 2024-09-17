extends Area2D

func _on_body_entered(body):
	body.WallArea = true
func _on_body_exited(body):
	body.WallArea = false
