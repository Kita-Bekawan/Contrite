extends PlayerState
class_name PlayerDash

func _init():
	DECELERATION = 4000
	
func enter():
	sprite.flip_h = !sprite.flip_h
	chara.velocity.y = 0 #makes dash pure horizontal (not diagonal up/down)
	if !SHOOT_DURATION.is_stopped():
		SHOOT_DURATION.stop()
		SHOOT_DURATION.timeout.emit()
	sprite.play('dash')
	
	var direction
	if Input.get_axis('left', 'right') > 0:
		direction = 1
		sprite.flip_h = true
	elif Input.get_axis('left', 'right') < 0:
		direction = -1
		sprite.flip_h = false
	else:
		direction = 1 if sprite.flip_h else -1
		
	chara.velocity.x = direction*DASH_SPEED 
	#frantic initial speed, then slowly stops
	PlayerState.can_dash = false
	DASH_CD.start()

func physics_update(_delta):
	chara.velocity.x = move_toward(chara.velocity.x, 0, DECELERATION * _delta)
	input_handler(true, true)
	transition()

	
func transition():
	if abs(chara.velocity.x) < 5: #dash until stops first
		if PlayerState.queued_action == 'PlayerShoot' and SHOOT_CD.is_stopped():
			consume_queue(queued_action)
		
		if !chara.is_on_floor():
			state_transition_signal.emit(self, 'PlayerFall')
		else : 
			if PlayerState.queued_action == 'PlayerJump':
				consume_queue(queued_action)
			elif Input.is_action_pressed('crouch'):
				state_transition_signal.emit(self, 'PlayerCrouch')
			elif Input.get_axis('left', 'right') != 0:
				state_transition_signal.emit(self, 'PlayerWalk')
			elif Input.get_axis('left', 'right') == 0:
				state_transition_signal.emit(self, 'PlayerIdle')
					
func exit():
	super.exit()
	sprite.flip_h = !sprite.flip_h
