extends PlayerState
class_name PlayerIdle

func enter():
	sprite.play('idle')
	
func physics_update(_delta: float):
	chara.velocity.x = move_toward(chara.velocity.x, 0, DECELERATION * _delta) #deceleration
	transition()

func transition() -> void:
	if !chara.is_on_floor():
		COYOTE_TIMER.start()
		state_transition_signal.emit(self, 'PlayerFall')
	else : 
		if Input.is_action_pressed('jump'):
			state_transition_signal.emit(self, 'PlayerJump')
		elif Input.is_action_pressed('crouch'):
			state_transition_signal.emit(self, 'PlayerCrouch')
		elif Input.is_action_pressed('dash') and DASH_CD.is_stopped():
			state_transition_signal.emit(self, 'PlayerDash')
		if Input.is_action_just_pressed("shoot") and SHOOT_CD.is_stopped():
			state_transition_signal.emit(self, 'PLayerShoot')
		elif Input.get_axis('left', 'right') != 0:
			state_transition_signal.emit(self, 'PlayerWalk')
