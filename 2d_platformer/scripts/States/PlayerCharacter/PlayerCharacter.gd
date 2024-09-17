extends CharacterBody2D
class_name Player

@onready var sprite = $AnimatedSprite2D
@onready var state_machine = $StateMachine

@onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass
func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
	if velocity.y < 0:
		$AnimatedSprite2D.play("idlejump")
	elif velocity.y > 150:
		$AnimatedSprite2D.play("idlefalling")
	elif Input.get_axis("MoveLeft","MoveRight"):
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.play("idle")
