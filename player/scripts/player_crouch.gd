extends PlayerWalk
class_name PlayerCrouch


func _init():
	MAX_HORIZONTAL_SPEED = 75 #override

func enter():
	super.enter()
	sprite.play('crouch')

func physics_update(_delta: float):
	
	var direction = move(_delta)
	
	if Input.is_action_just_released('crouch'):
		if Input.get_axis('left', 'right'):
			state_transition_signal.emit(self, 'PlayerWalk')
		else:
			state_transition_signal.emit(self, 'PlayerIdle')
	if Input.is_action_just_pressed('jump'):
		state_transition_signal.emit(self, 'PlayerJump')
