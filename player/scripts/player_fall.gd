extends PlayerWalk
class_name PlayerFall


func enter():
	super() #biar inherit attribute nya
	if !is_shooting:
		sprite.play('fall')
	
func physics_update(_delta: float) -> void:
	var direction = fall(_delta)
	continue_shooting()
	orientate(direction)
	input_handler(false, true)
	transition_with_param(direction)

func transition_with_param(direction: float) -> void:
	if !chara.is_on_floor():
		if !COYOTE_TIMER.is_stopped() and Input.is_action_pressed('jump'):
			COYOTE_TIMER.stop()
			state_transition_signal.emit(self, 'PlayerJump')
		elif check_dash():
			state_transition_signal.emit(self, 'PlayerDash')
		elif Input.is_action_pressed("shoot") and can_shoot:
			state_transition_signal.emit(self, 'PLayerShoot')
	else : 
		
		if PlayerState.queued_action == 'PlayerJump':
			consume_queue(queued_action)
		elif Input.is_action_just_pressed('crouch'):
			state_transition_signal.emit(self, 'PlayerCrouch')
		elif direction:
			state_transition_signal.emit(self, 'PlayerWalk')
		elif !direction:
			state_transition_signal.emit(self, 'PlayerIdle')

func fall(_delta: float) -> float:
	var direction = move(_delta)
	chara.velocity.y += GRAVITY * _delta #deceleration
	return direction
