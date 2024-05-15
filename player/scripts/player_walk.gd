extends PlayerState
class_name PlayerWalk

@onready var footsteps: AudioStreamPlayer2D = get_node("%Footsteps")
var footsteps_play = false

func ready():
	footsteps.pitch_scale = randf_range(.8, 1.1)

func enter():
	if !is_shooting:
		sprite.play('walk')
	
func physics_update(_delta: float) -> void:
	var direction = move(_delta)
	continue_shooting()
	orientate(direction)
	input_handler()
	transition_with_param(direction)
	
func transition_with_param(direction: float) -> void:
	if !chara.is_on_floor():
		COYOTE_TIMER.start()
		state_transition_signal.emit(self, 'PlayerFall')
	else : 
		if Input.is_action_just_pressed('jump'):
			state_transition_signal.emit(self, 'PlayerJump')
		elif Input.is_action_pressed('crouch'):
			state_transition_signal.emit(self, 'PlayerCrouch')
		elif check_dash():
			state_transition_signal.emit(self, 'PlayerDash')
		elif Input.is_action_pressed("shoot") and can_shoot:
			state_transition_signal.emit(self, 'PLayerShoot')
		elif !direction:
			state_transition_signal.emit(self, 'PlayerIdle')
	
func move(_delta:float) -> float:
	var direction = Input.get_axis("left", "right")
	
	if direction and chara.is_on_floor():
		if !footsteps_play:
			footsteps.play()
			footsteps_play = true
	else:
		footsteps.stop()
		footsteps_play = false
		
	if direction:
		chara.velocity.x = (direction / abs(direction))*INIT_HORIZONTAL_SPEED \
							if chara.velocity.x/direction < 0 else chara.velocity.x #selalu 40 ... 250
		chara.velocity.x += direction * ACCELERATION * _delta #acceleration
		chara.velocity.x = clamp(chara.velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
	else:
		chara.velocity.x = move_toward(chara.velocity.x, 0, DECELERATION * _delta) #deceleration

	return direction
	
func orientate(direction: float) -> void:
	if !is_shooting:
		if direction < 0:
			sprite.flip_h = true
		elif direction > 0:
			sprite.flip_h = false
	
