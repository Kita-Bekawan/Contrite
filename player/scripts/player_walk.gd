extends State
class_name PlayerWalk

@export var ACCELERATION = 600
@export var DECELERATION = 2000
@export var INIT_HORIZONTAL_SPEED = 40
@export var MAX_HORIZONTAL_SPEED = 300

func enter():
	super.enter()
	sprite.play('walk')
	
func physics_update(_delta: float) -> void:
	var direction = move(_delta)
	orientate(direction)

	if !direction:
		state_transition_signal.emit(self, 'PlayerIdle')
	if !chara.is_on_floor():
		COYOTE_TIMER.start()
		state_transition_signal.emit(self, 'PlayerFall')
	if Input.is_action_just_pressed('dash') and DASH_CD.is_stopped():
		state_transition_signal.emit(self, 'PlayerDash')
	if Input.is_action_just_pressed("shoot") and SHOOT_CD.is_stopped():
		state_transition_signal.emit(self, 'PLayerShoot')
	if Input.is_action_just_pressed('jump'):
		state_transition_signal.emit(self, 'PlayerJump')
	if Input.is_action_pressed('crouch'):
		state_transition_signal.emit(self, 'PlayerCrouch')

func move(_delta:float) -> float:
	var direction = Input.get_axis("left", "right")
	if direction:
		chara.velocity.x = (direction / abs(direction))*INIT_HORIZONTAL_SPEED \
							if chara.velocity.x/direction < 0 else chara.velocity.x #selalu 40 ... 250
		chara.velocity.x += direction * ACCELERATION * _delta #acceleration
		chara.velocity.x = clamp(chara.velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
	else:
		chara.velocity.x = move_toward(chara.velocity.x, 0, DECELERATION * _delta) #deceleration

	return direction
	
func orientate(direction: float) -> void:
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false
	
