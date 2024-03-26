extends PlayerWalk
class_name PlayerFall


@export var GRAVITY = 2000

func enter():
	super.enter()
	sprite.play('fall')
	
func physics_update(_delta: float) -> void:
	var direction = fall(_delta)
	orientate(direction)
		
	if chara.is_on_floor():
		state_transition_signal.emit(self, 'PlayerIdle')
	if Input.is_action_just_pressed('shoot') and SHOOT_CD.is_stopped():
		state_transition_signal.emit(self, 'PLayerShoot')
	if Input.is_action_just_pressed('dash') and DASH_CD.is_stopped():
		state_transition_signal.emit(self, 'PlayerDash')
	if !COYOTE_TIMER.is_stopped() and Input.is_action_just_pressed('jump'):
		state_transition_signal.emit(self, 'PlayerJump')

func fall(_delta: float) -> float:
	var direction = move(_delta)
	chara.velocity.y += GRAVITY * _delta #deceleration
	return direction
