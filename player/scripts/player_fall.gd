extends PlayerWalk
class_name PlayerFall


@export var GRAVITY = 2500

func enter():
	super.enter()
	sprite.play('fall')
	
func physics_update(_delta: float) -> void:
	var direction = fall(_delta)
	orientate(direction)
		
	if chara.is_on_floor():
		if last_input and !INPUT_BUFFER.is_stopped():
			state_transition_signal.emit(self, last_input)
		else:
			if Input.get_axis('left', 'right'):
				state_transition_signal.emit(self, 'PlayerWalk')
			else:
				state_transition_signal.emit(self, 'PlayerIdle')
	else:
		if !COYOTE_TIMER.is_stopped() and Input.is_action_just_pressed('jump'):
			state_transition_signal.emit(self, 'PlayerJump')
	
	if Input.is_action_just_pressed('shoot') and SHOOT_CD.is_stopped():
		state_transition_signal.emit(self, 'PLayerShoot')
	if Input.is_action_just_pressed('dash') and DASH_CD.is_stopped():
		state_transition_signal.emit(self, 'PlayerDash')
	
	if Input.is_action_just_pressed('jump'):
		last_input = 'PlayerJump'
		INPUT_BUFFER.start()

func fall(_delta: float) -> float:
	var direction = move(_delta)
	chara.velocity.y += GRAVITY * _delta #deceleration
	return direction
