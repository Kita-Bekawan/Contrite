extends State
class_name PlayerDash

@export var DASH_SPEED = 1000
@export var DECELERATION = 4000

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
	chara.velocity.x = move_toward(chara.velocity.x, 0, DECELERATION * _delta)
	
	if chara.velocity.x == 0: #dash until stops first
		if !chara.is_on_floor():
			state_transition_signal.emit(self, 'PlayerFall')
		else:
			if last_input and !INPUT_BUFFER.is_stopped():
				state_transition_signal.emit(self, last_input)
			if !Input.get_axis('left', 'right'):
				state_transition_signal.emit(self, 'PlayerIdle')
			else:
				state_transition_signal.emit(self, 'PlayerWalk')
	
	if Input.is_action_just_pressed('jump'):
		last_input = 'PlayerJump'
		INPUT_BUFFER.start()
		
func exit():
	super.exit()
	sprite.flip_h = !sprite.flip_h
