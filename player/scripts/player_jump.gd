extends PlayerWalk
class_name PlayerJump

@export var JUMP_SPEED = 600
@export var GRAVITY = 2000


func enter():
	super.enter()
	sprite.play('jump')
	chara.velocity.y = -JUMP_SPEED #init speed

func physics_update(_delta: float):
	
	var direction = move(_delta)
	chara.velocity.y += GRAVITY * _delta #deceleration
	
	if chara.is_on_floor():
		if !Input.get_axis('left', 'right'):
			state_transition_signal.emit(self, 'PlayerIdle')
		else:
			state_transition_signal.emit(self, 'PlayerWalk')
	if Input.is_action_just_pressed('dash') and DASH_CD.is_stopped():
		state_transition_signal.emit(self, 'PlayerDash')
	if Input.is_action_just_pressed("shoot") and SHOOT_CD.is_stopped():
		state_transition_signal.emit(self, 'PLayerShoot')

