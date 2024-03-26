extends PlayerFall
class_name PlayerShoot

func enter():
	super.enter()
	sprite.play('shoot')
	shoot()
	SHOOT_CD.start()

func physics_update(_delta: float):	
	fall(_delta)
	shoot()
	if !sprite.is_playing():
		if chara.is_on_floor():
			state_transition_signal.emit(self, 'PlayerIdle')
		if Input.is_action_just_pressed('shoot') and SHOOT_CD.is_stopped():
			state_transition_signal.emit(self, 'PLayerShoot')
	if Input.is_action_just_pressed('dash') and DASH_CD.is_stopped():
		state_transition_signal.emit(self, 'PlayerDash')
	if Input.is_action_just_pressed('jump'):
		state_transition_signal.emit(self, 'PlayerShootJump')
	if Input.is_action_pressed('crouch'):
		state_transition_signal.emit(self, 'PlayerCrouch')

func shoot() -> void:
	var bullet_object = bullet.instantiate()
	bullet_object.global_position = chara.global_position
	var target = chara.get_global_mouse_position()
	
	var relative_position = (target.x - bullet_object.global_position.x)
	var sprite_orientation = -1 if relative_position < 0 else 1
	sprite.flip_h = true if relative_position < 0 else false
	bullet_object.global_position +=  Vector2(sprite_orientation*40, -40) #biar muncul dari tangan
	
	var direction = bullet_object.global_position.direction_to(target).normalized()
	bullet_object.set_direction(direction)
	get_tree().root.add_child(bullet_object)
