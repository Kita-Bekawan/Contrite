extends PlayerState
class_name PlayerIdle

func enter():
	if !is_shooting:
		sprite.play('idle')	
	
func physics_update(_delta: float):
	chara.velocity.x = move_toward(chara.velocity.x, 0, DECELERATION * _delta) #deceleration
	continue_shooting()
	input_handler()
	transition()

func transition() -> void:
	if !chara.freeze:
		if !chara.is_on_floor():
			COYOTE_TIMER.start()
			state_transition_signal.emit(self, 'PlayerFall')
		else : 
			if Input.is_action_just_pressed('jump'):
				state_transition_signal.emit(self, 'PlayerJump')
			elif Input.is_action_pressed('crouch'):
				state_transition_signal.emit(self, 'PlayerCrouch')
			elif check_dash():
				state_transition_signal.emit(self, 'PlayerDash')
			elif Input.is_action_pressed("shoot") and can_shoot:
				state_transition_signal.emit(self, 'PLayerShoot')
			elif Input.get_axis('left', 'right') != 0:
				state_transition_signal.emit(self, 'PlayerWalk')
