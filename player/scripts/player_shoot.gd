extends PlayerState
class_name PlayerShoot

func enter():
	overriden_animation = sprite.get_animation()
	sprite.play('shoot')
	is_shooting = true

func physics_update(_delta: float):	
	super.physics_update(_delta)
	transition()

func transition() -> void:
	if !chara.is_on_floor():
		state_transition_signal.emit(self, 'PlayerFall')
	else : 
		if Input.is_action_pressed('jump'):
			state_transition_signal.emit(self, 'PlayerJump')
		elif Input.is_action_pressed('crouch'):
			state_transition_signal.emit(self, 'PlayerCrouch')
		elif Input.is_action_pressed('dash') and DASH_CD.is_stopped():
			state_transition_signal.emit(self, 'PlayerDash')
		elif Input.get_axis('left', 'right') != 0:
			state_transition_signal.emit(self, 'PlayerWalk')
		elif Input.get_axis('left', 'right'):
			state_transition_signal.emit(self, 'PlayerIdle')
