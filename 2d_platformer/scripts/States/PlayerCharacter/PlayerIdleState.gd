extends State

class_name PlayerIdle

func Enter():
	pass

func Update(delta : float):
	if Input.get_axis("MoveLeft","MoveRight"):
		Transitioned.emit(self, "MoveState")
