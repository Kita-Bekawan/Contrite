extends PlayerWalk
class_name PlayerCrouch

var btn_still_pressed: bool

func _init():
	MAX_HORIZONTAL_SPEED = 75 #override

func enter():
	super.enter()
	CROUCH_HOLD_TIMER.start()
	btn_still_pressed = true
	sprite.play('crouch')

func physics_update(_delta: float):
	
	var direction = move(_delta)
	orientate(direction)
	
	if Input.is_action_just_pressed('jump'):
		state_transition_signal.emit(self, 'PlayerJump')
	
	if Input.is_action_just_released('crouch'):
		btn_still_pressed = false
	
	if CROUCH_HOLD_TIMER.is_stopped() and btn_still_pressed:
		chara.collision_mask = 2
		PLATFORM_GONE_TIMER.start()
	
	if !chara.is_on_floor():	
		state_transition_signal.emit(self, 'PlayerFall')
	if Input.is_action_just_pressed('crouch'):
		state_transition_signal.emit(self, 'PlayerIdle')
	
