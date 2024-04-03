extends PlayerWalk
class_name PlayerCrouch

func _init():
	MAX_HORIZONTAL_SPEED = 75 #override

func enter():
	if !SHOOT_DURATION.is_stopped():
		SHOOT_DURATION.stop()
		SHOOT_DURATION.timeout.emit()
	sprite.play('crouch')

func physics_update(_delta: float):
	var direction = move(_delta)
	if Input.is_action_just_pressed('drop_down'):
		chara.position.y += 1
	input_handler(true, true)
	orientate(direction)
	transition()
	
func transition():
	if !chara.is_on_floor():
		COYOTE_TIMER.start()
		state_transition_signal.emit(self, 'PlayerFall')
	else : 
		if Input.is_action_pressed('jump'):
			state_transition_signal.emit(self, 'PlayerJump')
		elif Input.is_action_pressed('dash') and DASH_CD.is_stopped():
			state_transition_signal.emit(self, 'PlayerDash')
		elif Input.is_action_just_released('crouch'):
			if PlayerState.queued_action == 'PlayerShoot' and SHOOT_CD.is_stopped():
				consume_queue(queued_action)
			elif Input.get_axis('left', 'right'):
				state_transition_signal.emit(self, 'PlayerWalk')
			elif !Input.get_axis('left', 'right'):
				state_transition_signal.emit(self, 'PlayerIdle')
