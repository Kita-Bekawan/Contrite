extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var cooldown = 0.25
var bullet_scene = preload("res://menu/scenes/bullet.tscn")
var can_shoot = true

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	start()
		
func start():
	$ShootingCD.wait_time = cooldown

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()

func _process(_delta):
	if Input.is_action_just_released("shoot"):
		shoot()

func shoot():
	if not can_shoot:
		return
	can_shoot = false
	$ShootingCD.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start(position, get_global_mouse_position())

func _on_shooting_cd_timeout():
	can_shoot = true
