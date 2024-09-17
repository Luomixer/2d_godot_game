extends CharacterBody2D

@onready var CoyoteTimer = $Timers/CoyoteTimer
@onready var JumpBuffer = $Timers/JumpBuffer
@onready var DashTimer = $Timers/DashTimer
@onready var SuperJumpBuffer = $Timers/SuperJumpBuffer
@onready var SuperJumpCoolDown = $Timers/SuperJumpCoolDown
@onready var OnWallBuffer = $Timers/OnWallBuffer
# movement settings

@onready var DashAbility = true
@onready var SlamAbility = true

var SPEED = 76.0
const DEFAULTSPEED = 76
const MAXFALLSPEED = 300
const CROUCHSPEED = DEFAULTSPEED * 0.55
const ACCELERATION = 10
const DECELERATION: float = 0.25
const OFWALLSPEED: float = 4
const DASHDISTANCE = 300
const DASHLENGTH: float = 0.15

const JUMP_HEIGHT: float = 26
const JUMP_PEAK: float = 0.32
const JUMP_DESCENT: float = 0.26

var IsDashing = false
var InsideJOrb = false
var CanMJump = false
var OnWall = false
var OffWallJump = false
var WallArea = false
var Jumped = false
var DashRecharged = false
var Slamming = false
var CrouchingState = false

@onready var JUMP_VELOCITY: float = (-2.0 * JUMP_HEIGHT) / JUMP_PEAK
@onready var JUMP_GRAVITY: float = (2.0 * JUMP_HEIGHT) / (JUMP_PEAK * JUMP_PEAK)
@onready var FALL_GRAVITY: float = (2.0 * JUMP_HEIGHT) / (JUMP_DESCENT * JUMP_DESCENT)

func _physics_process(delta):
	var wall_normal = get_wall_normal()
	if is_on_floor():
		Jumped = false
	ApplyGravity(delta)
	MoveVelocityX()
	Wall()
	if Input.is_action_just_pressed("Jump"):
		if InsideJOrb:
			CanMJump = true
		JumpBuffer.start()
	JumpHandle(wall_normal)
	var was_on_floor = is_on_floor()
	if DashAbility:
		Dash()
	if SlamAbility:
		Slam()
	Crouching()
	AnimationHandle()
	move_and_slide()
	if was_on_floor and !is_on_floor():
		CoyoteTimer.start()
	
func GetGravity():
	return JUMP_GRAVITY if velocity.y < 0.0 else FALL_GRAVITY

func ApplyGravity(delta):
	if OnWall == true:
		velocity.y += GetGravity() * delta
		velocity.y = min(velocity.y, MAXFALLSPEED / 8)
	elif !is_on_floor():
		velocity.y += GetGravity() * delta
		velocity.y = min(velocity.y, MAXFALLSPEED)
func MoveVelocityX():
	if Input.is_action_pressed("MoveRight"):
		if velocity.x < 0:
			velocity.x += max(velocity.x + ACCELERATION, SPEED)
		else:
			velocity.x = min(velocity.x + ACCELERATION, SPEED)
		$AnimatedSprite2D.flip_h = false
	elif Input.is_action_pressed("MoveLeft"):
		if velocity.x > 0:
			velocity.x += min(velocity.x - ACCELERATION, -SPEED)
		else:	
			velocity.x = max(velocity.x - ACCELERATION, -SPEED)
		$AnimatedSprite2D.flip_h = true
	else:
		velocity.x = lerpf(velocity.x, 0, DECELERATION)
func JumpHandle(wall_normal):
	if JumpBuffer.time_left > 0 and SuperJumpBuffer.time_left > 0  and SuperJumpCoolDown.time_left == 0 and is_on_floor():
		velocity.y = JUMP_VELOCITY * 1.4
		JumpBuffer.stop()
		SuperJumpBuffer.stop()
		SuperJumpCoolDown.start()
		$SFX/SuperJumpSFX.play()
		$SFX/JumpSFX.play()
		Jumped = true
	elif JumpBuffer.time_left > 0 and (is_on_floor() or CoyoteTimer.time_left > 0) and !Jumped:
		velocity.y = JUMP_VELOCITY
		JumpBuffer.stop()
		$SFX/JumpSFX.play()
		Jumped = true
	elif CanMJump == true and !is_on_floor():
		DashTimer.stop()
		CanMJump = false
		velocity.y = JUMP_VELOCITY
		$SFX/JumpSFX.play()
		IsDashing = false
	elif JumpBuffer.time_left > 0 and OnWallBuffer.time_left > 0 and !is_on_floor():
		velocity.x = lerpf(velocity.x,wall_normal.x * SPEED * OFWALLSPEED, 1)
		velocity.y = JUMP_VELOCITY
		$SFX/JumpSFX.play()
		OnWall = false
		OnWallBuffer.stop()
func AnimationHandle():
	if IsDashing and velocity.y < - 100:
		$AnimatedSprite2D.play("dashupwards")
	elif IsDashing and velocity.x != 0:
		$AnimatedSprite2D.play("dashsideways")
	elif velocity.y < 0:
		$AnimatedSprite2D.play("idlejump")
	elif velocity.y > 150:
		$AnimatedSprite2D.play("idlefalling")
	elif CrouchingState and is_on_floor():
		$AnimatedSprite2D.play("crouching")
	elif Input.is_action_pressed("MoveLeft") or Input.is_action_pressed("MoveRight"):
		$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.play("idle")
func Wall():
	if WallArea and is_on_wall():
		OnWall = true
		if OnWallBuffer.time_left == 0:
			OnWallBuffer.start()
	else:
		OnWall = false


func Dash():
	if Input.is_action_just_pressed("Dash") and DashTimer.time_left == 0 and (velocity.x != 0 or Input.is_action_pressed("MoveUp")):
		$SFX/DashSFX.play()
		DashTimer.start()
	if DashTimer.time_left > DashTimer.wait_time - DASHLENGTH:
		IsDashing = true
		$Collision.scale.y = 0.8
		if Input.is_action_pressed("MoveUp"):
			velocity.y = JUMP_VELOCITY * 0.7
		elif Input.is_action_pressed("MoveLeft"):
			velocity.x = lerp(velocity.x,velocity.x - DASHDISTANCE, 1)
			velocity.y = 0
		elif Input.is_action_pressed("MoveRight"):
			velocity.x = lerp(velocity.x,velocity.x + DASHDISTANCE, 1)
			velocity.y = 0	
		else:
			IsDashing = false
			$Collision.scale.y = 1
	else:
		IsDashing = false
		$Collision.scale.y = 1

func Slam():
	if Input.is_action_pressed("MoveDown") and Input.is_action_just_pressed("Dash") and !is_on_floor() and velocity.y != MAXFALLSPEED:
		velocity.y = lerpf(velocity.y,MAXFALLSPEED, 2)
		$SFX/DashSFX.play()
		SuperJumpBuffer.start()
	if velocity.y == MAXFALLSPEED:
		Slamming = true
	else:
		Slamming = false

func Crouching():
	if Input.is_action_pressed("MoveDown") and is_on_floor():
		$Collision.scale.y = 0.8
		SPEED = CROUCHSPEED
		CrouchingState = true
	elif ($CrouchRayCast.is_colliding() or $CrouchRayCast2.is_colliding()) and !Input.is_action_pressed("MoveDown") and is_on_floor():
		SPEED = CROUCHSPEED
		CrouchingState = true
		$Collision.scale.y = 0.8
	else:
		$Collision.scale.y = 1
		SPEED = DEFAULTSPEED
		CrouchingState = false
