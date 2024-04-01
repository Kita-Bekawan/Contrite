extends PlayerState
class_name PlayerDash

func enter():
	sprite.flip_h = !sprite.flip_h
	sprite.play('dash')
	chara.velocity.y = 0 #makes dash pure horizontal (not diagonal up/down)
	
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
	DASH_CD.start()

func physics_update(_delta):	
	chara.velocity.x = move_toward(chara.velocity.x, 0, DASH_DECELERATION * _delta)
	
	if chara.velocity.x == 0: #dash until stops first
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
	
		
func exit():
	super.exit()
	sprite.flip_h = !sprite.flip_h
