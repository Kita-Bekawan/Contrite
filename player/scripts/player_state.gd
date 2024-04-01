extends State
class_name PlayerState

@onready var chara: CharacterBody2D = self.owner
@onready var sprite: AnimatedSprite2D = chara.get_node('Sprite')
@onready var hitbox: CollisionShape2D = chara.get_node('Hitbox')
@export var bullet : PackedScene

@onready var DASH_CD: Timer = chara.get_node('DashCD')
@onready var SHOOT_CD: Timer = chara.get_node('ShootCD')
@onready var COYOTE_TIMER: Timer = chara.get_node('CoyoteTimer')
@onready var INPUT_BUFFER: Timer = chara.get_node('InputBuffer')
@onready var CROUCH_HOLD_TIMER: Timer = chara.get_node('CrouchHoldTimer')

# state flags -----------------------------------------------------------------
var can_push_off = false
var last_input = null
var transition_debug = true
var velocity_debug = false

# state variables -------------------------------------------------------------
# player_fall, player_jump, player_shoot_jump
@export var GRAVITY = 2500

# player_dash
@export var DASH_SPEED = 1000
@export var DASH_DECELERATION = 4000

# player_walk
@export var DECELERATION = 2000

# player_walk
@export var ACCELERATION = 600
@export var INIT_HORIZONTAL_SPEED = 40
@export var MAX_HORIZONTAL_SPEED = 300

# player_shoot_jump
@export var JUMP_SPEED = 1200
@export var MIN_JUMP_HEIGHT = 150
var starting_height: float
var release_early: bool
var printed: bool

# player_crouch
var btn_still_pressed: bool

# shoot (not a state, but a modifier)
var is_shooting: bool = false
var overriden_animation: String = ''

# Characer-specific state functions -------------------------------------------
func enter() -> void:
	overriden_animation = sprite.get_animation()
	if is_shooting:
		sprite.play('shoot')
		shoot()

func input_handler() -> void:
	pass

func physics_update(delta) -> void:
	if is_shooting:
		shoot()
	
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

func _on_shoot_duration_timeout():
	is_shooting = false
	sprite.play(overriden_animation)
	overriden_animation = ''
	SHOOT_CD.start()
