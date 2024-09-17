extends Area2D
var Inside = false

func _on_body_exited(body):
	Inside = false
	body.CanDJ = false
	print("out")
func _on_body_entered(body):
	body.CanDJ = true
	Inside = true
	print("in")
