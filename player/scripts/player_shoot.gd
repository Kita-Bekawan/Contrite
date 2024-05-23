extends PlayerState
class_name PlayerShoot

func enter():
	overriden_animation = sprite.get_animation()
	sprite.play('shoot')
	shoot()
	is_shooting = true
	can_shoot = false
	SHOOT_CD.start()
	SHOOT_DURATION.start()

func physics_update(_delta: float):	
	continue_shooting()
	transition()

func transition() -> void:
	if !chara.is_on_floor():
		state_transition_signal.emit(self, 'PlayerFall')
	else : 
		if Input.is_action_pressed('jump'):
			state_transition_signal.emit(self, 'PlayerJump')
		elif Input.is_action_pressed('crouch'):
			state_transition_signal.emit(self, 'PlayerCrouch')
		elif check_dash():
			state_transition_signal.emit(self, 'PlayerDash')
		elif Input.get_axis('left', 'right') != 0:
			state_transition_signal.emit(self, 'PlayerWalk')
		elif Input.get_axis('left', 'right') == 0:
			state_transition_signal.emit(self, 'PlayerIdle')
