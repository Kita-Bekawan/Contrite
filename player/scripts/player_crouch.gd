extends PlayerWalk
class_name PlayerCrouch


func _init():
	MAX_HORIZONTAL_SPEED = 75 #override

func enter():
	CROUCH_HOLD_TIMER.start()
	btn_still_pressed = true
	sprite.play('crouch')

func physics_update(_delta: float):
	
	var direction = move(_delta)
	orientate(direction)
	if Input.is_action_just_released('crouch'): #first button press releases
		btn_still_pressed = false
	if CROUCH_HOLD_TIMER.is_stopped() and btn_still_pressed: #drop down
		chara.position.y += 1	
	transition()
	
func transition():
	if !chara.is_on_floor():
		state_transition_signal.emit(self, 'PlayerFall')
	else : 
		if Input.is_action_pressed('jump'):
			state_transition_signal.emit(self, 'PlayerJump')
		elif Input.is_action_pressed('crouch'):
			state_transition_signal.emit(self, 'PlayerIdle')
