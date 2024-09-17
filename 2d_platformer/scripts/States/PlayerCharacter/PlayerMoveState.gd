extends State

@export var DEFAULTSPEED = 76
@export var ACCELERATION = 10
@export var DECELERATION: float = 0.25
var SPEED = 76.0

func Enter():
	pass

func Update(delta : float):
	if Input.is_action_pressed("MoveRight"):
		if owner.velocity.x < 0:
			owner.velocity.x += max(owner.velocity.x + ACCELERATION, SPEED)
		else:
			owner.velocity.x = min(owner.velocity.x + ACCELERATION, SPEED)
	elif Input.is_action_pressed("MoveLeft"):
		if owner.velocity.x > 0:
			owner.velocity.x += min(owner.velocity.x - ACCELERATION, -SPEED)
		else:	
			owner.velocity.x = max(owner.velocity.x - ACCELERATION, -SPEED) 
	else:
		owner.velocity.x = lerpf(owner.velocity.x, 0, DECELERATION)
		Transitioned.emit(self, "idle_state")
