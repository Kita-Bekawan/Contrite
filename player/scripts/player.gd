extends CharacterBody2D


const SPEED = 200.0
const DASH_SPEED = 10000.0
const CROUCH_SLOW = 4.0 #number of times slower than original speed
const JUMP_VELOCITY = -400.0

@export var cooldown = 0.25
@export var Bullet : PackedScene
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#state
var can_shoot = true
var can_dash = true

var jumping = false
var crouching = false
var shooting = false
var dashing = false

var last_key = null

#debug
var debug = true

func _ready():
	$ShootingCD
		
func start():
	$ShootingCD.wait_time = cooldown

func _physics_process(delta):
	move_and_slide()

#func move(velocity:Vector2) -> Vector2:
	#var direction = Input.get_axis("left", "right")
	#
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
	#return velocity
#
#func check_dash(velocity: Vector2) -> Vector2:
	#if last_key != null and can_dash:
		#if Input.is_action_just_pressed('left') and last_key == 'left':
			#velocity.x = -DASH_SPEED
			#$DashCD.start()
			#can_dash = false
			#dashing = true
			#$AnimatedSprite2D.flip_h = false
			#$AnimatedSprite2D.play('dash')
		#elif Input.is_action_just_pressed('right') and last_key == 'right':
			#velocity.x = DASH_SPEED
			#$DashCD.start()
			#can_dash = false
			#dashing = true
			#$AnimatedSprite2D.flip_h = true
			#$AnimatedSprite2D.play('dash')
	#else:	
		#if Input.is_action_just_pressed('left'): 
			#last_key = 'left'
			#can_dash = true
			#$DashTimeout.start()
		#if Input.is_action_just_pressed('right'): 
			#last_key = 'right'
			#can_dash = true
			#$DashTimeout.start()
	#return velocity
#
#func jump(velocity: Vector2) -> Vector2:
	#velocity.y = JUMP_VELOCITY
	#$AnimatedSprite2D.play('jump')
	#jumping = true
	#if debug: print('is now jumping: ' + str(jumping))
	#return velocity
	#
#func crouch(velocity: Vector2) -> Vector2:
	#velocity.x /= CROUCH_SLOW
	#$AnimatedSprite2D.play('crouch')
	#crouching = true
	#if debug: print('is now crouching: ' + str(jumping))
	#return velocity
	#
#func animate(velocity: Vector2) -> void:
	##priority animation
	#if not $AnimatedSprite2D.is_playing():
		#if jumping:
			#jumping = false
		#if crouching:
			#crouching = false
		#if shooting:
			#shooting = false
		#if dashing:
			#if not is_on_floor():
				#$AnimatedSprite2D.play('jump')
				#$AnimatedSprite2D.frame = 1
			#$AnimatedSprite2D.flip_h = not $AnimatedSprite2D.flip_h
			#dashing = false
	#
	##walk
	#if not (jumping or shooting or crouching or dashing) and is_on_floor():
		#if velocity.x == 0:
			#$AnimatedSprite2D.play('idle')
			#if debug: print('is now idling')
		#else:
			#$AnimatedSprite2D.play("walk")
			#if debug:
				#var direction = "left" if $AnimatedSprite2D.flip_h else "right"
				#print('is now walking ' + str(direction))
	#
	## orientation
	#if not dashing: #dash has flipped orientation
		#if velocity.x < 0: 
			#$AnimatedSprite2D.flip_h = true
		#elif velocity.x > 0:
			#$AnimatedSprite2D.flip_h = false
			#
#func _process(_delta):
	#if Input.is_action_just_released("shoot"):
		#shoot()
#
#func shoot():
	#if not can_shoot:
		#return
	#can_shoot = false
	#
	#$ShootingCD.start()
	#var bullet = Bullet.instantiate()
	#get_tree().root.add_child(bullet)
	#bullet.global_position = global_position
	#var target = get_global_mouse_position()
	#var direction = bullet.global_position.direction_to(target).normalized()
	#bullet.set_direction(direction)
#
#func _on_shooting_cd_timeout():
	#can_shoot = true
#
#func _on_dash_cd_timeout():
	#can_dash = true
#
#func _on_dash_timeout_timeout():
	#last_key = null
