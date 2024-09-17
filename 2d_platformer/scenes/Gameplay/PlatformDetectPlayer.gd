extends CollisionShape2D

var PlayerPos
var PlayerOnPlatform
# Called when the node enters the scene tree for the first time.
func _on_body_entered(body):
	PlayerPos = body.position
	PlayerOnPlatform = true
func _on_body_exited(body):
	PlayerOnPlatform = false

func _physics_process(delta):
	if PlayerOnPlatform:
		PlayerPos.x = $DetectPlayer.position.x
