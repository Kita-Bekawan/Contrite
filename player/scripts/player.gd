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


func _on_platform_gone_timer_timeout():
	collision_mask = 2 + 4
