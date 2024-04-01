extends PlayerWalk
class_name PlayerFall


func enter():
	sprite.play('fall')
	
func physics_update(_delta: float) -> void:
	var direction = fall(_delta)
	orientate(direction)
	transition()

func transition() -> void:
	if !chara.is_on_floor():
		state_transition_signal.emit(self, 'PlayerFall')
	else : 
		if !COYOTE_TIMER.is_stopped() and Input.is_action_pressed('jump'):
			state_transition_signal.emit(self, 'PlayerJump')
		elif Input.is_action_pressed('crouch'):
			state_transition_signal.emit(self, 'PlayerCrouch')
		elif Input.is_action_pressed('dash') and DASH_CD.is_stopped():
			state_transition_signal.emit(self, 'PlayerDash')
		elif Input.get_axis('left', 'right') != 0:
			state_transition_signal.emit(self, 'PlayerWalk')
		elif Input.get_axis('left', 'right') == 0:
			state_transition_signal.emit(self, 'PlayerIdle')

func fall(_delta: float) -> float:
	var direction = move(_delta)
	chara.velocity.y += GRAVITY * _delta #deceleration
	return direction
