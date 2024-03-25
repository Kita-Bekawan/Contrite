extends State
class_name PlayerIdle

@export var DECELERATION = 2000

func enter():
	super.enter()
	sprite.play('idle')
	
func physics_update(_delta: float):
	chara.velocity.x = move_toward(chara.velocity.x, 0, DECELERATION * _delta) #deceleration
	if Input.is_action_pressed('crouch'):
		state_transition_signal.emit(self, 'PlayerCrouch')
	if Input.get_axis('left', 'right'):
		state_transition_signal.emit(self, 'PlayerWalk')
	if Input.is_action_just_pressed('shoot') and SHOOT_CD.is_stopped():
		state_transition_signal.emit(self, 'PlayerShoot')
	if Input.is_action_just_pressed('jump'):
		state_transition_signal.emit(self, 'PlayerJump')


func exit():
	super.exit()

