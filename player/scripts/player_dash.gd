extends State
class_name PlayerDash

@export var DASH_SPEED = 1000
@export var DECELERATION = 2500

func enter():
	super.enter()
	sprite.flip_h = !sprite.flip_h
	sprite.play('dash')
	chara.velocity.y = 0 #makes dash pure horizontal (not diagonal up/down)
	chara.velocity.x = (chara.velocity.x/abs(chara.velocity.x))*DASH_SPEED 
	#frantic initial speed, then slowly stops
	DASH_CD.start()

func physics_update(_delta):	
	chara.velocity.x = move_toward(chara.velocity.x, 0, DECELERATION * _delta)
	
	if chara.velocity.x == 0: #dash until stops first
		if !chara.is_on_floor():
			state_transition_signal.emit(self, 'PlayerFall')
		if !Input.get_axis('left', 'right'):
			state_transition_signal.emit(self, 'PlayerIdle')
		if Input.get_axis('left', 'right'):
			state_transition_signal.emit(self, 'PlayerWalk')
	if Input.is_action_just_pressed('shoot') and SHOOT_CD.is_stopped():
		state_transition_signal.emit(self, 'PLayerShoot')

func exit():
	super.exit()
	sprite.flip_h = !sprite.flip_h
