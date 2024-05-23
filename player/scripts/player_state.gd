extends State
class_name PlayerState

@onready var chara: CharacterBody2D = self.owner
@onready var sprite: AnimatedSprite2D = chara.get_node('Sprite')
@onready var ledgebox: CollisionShape2D = chara.get_node('Ledgebox')
@onready var bullet : PackedScene = load('res://bullets/bullet_player/bullet_player.tscn')

@onready var DASH_CD: Timer = chara.get_node('DashCD')
@onready var SHOOT_CD: Timer = chara.get_node('ShootCD') # interval between shoot clicks
@onready var FIRE_RATE: Timer = chara.get_node('FireRate') # ngaruh ke munculnya bullet per detik
@onready var SHOOT_DURATION: Timer = chara.get_node('ShootDuration')
@onready var COYOTE_TIMER: Timer = chara.get_node('CoyoteTimer')
@onready var INPUT_BUFFER: Timer = chara.get_node('InputBuffer')
@onready var DOUBLE_TAP_TIMER: Timer = chara.get_node('DoubleTapTimer')

@onready var SOUND_PLAYER: AudioStreamPlayer2D = chara.get_node('SoundPlayer')

# state variables -------------------------------------------------------------
# player_fall, player_jump, player_shoot_jump
@export var GRAVITY = 2500

# player_dash
@export var DASH_SPEED = 1200

# player_walk、player_dash (override)
@export var DECELERATION = 2000

# player_walk, player_crouch (override)
@export var ACCELERATION = 600
@export var INIT_HORIZONTAL_SPEED = 40
@export var MAX_HORIZONTAL_SPEED = 300

# player_jump
@export var JUMP_SPEED = 750
@export var MIN_JUMP_HEIGHT = 150
var starting_height: float
var can_push_off: bool = false
var release_early: bool
var printed: bool

# checkpoint
@onready var last_checkpoint = self.owner.position

# player_hurt
@export var maximumHealth: int = 5
@onready var currentHealth: int = maximumHealth

# general, used by all states
static var last_input: String = ''
static var queued_action = ''
static var overriden_animation: String = ''

static var can_dash: bool
static var can_shoot: bool
static var limit_fire_rate: bool
static var is_shooting: bool

static var transition_debug: bool = true
static var velocity_debug: bool = false

# Characer-specific state functions -------------------------------------------
func _ready() -> void:
	can_dash = true
	can_shoot = true
	limit_fire_rate = true
	is_shooting = false
	
func enter() -> void:
	pass
	
func physics_update(delta) -> void:
	pass

func input_handler(with_shoot: bool = false, with_queue: bool = false) -> void:
	var pressed_input = ''
	var key_pressed = false
	if Input.is_action_just_pressed('left'):
		pressed_input = 'left'
		key_pressed = true
		INPUT_BUFFER.start()
	elif Input.is_action_just_pressed('right'):
		pressed_input = 'right'
		key_pressed = true
		INPUT_BUFFER.start()
	elif Input.is_action_just_pressed('jump'):
		pressed_input = 'jump'
		if with_queue: queued_action = 'PlayerJump'
		key_pressed = true
		INPUT_BUFFER.start()
	elif Input.is_action_just_pressed('crouch'):
		pressed_input = 'crouch'
		if with_queue: queued_action = 'PlayerCrouch'
		key_pressed = true
		INPUT_BUFFER.start()
	elif with_shoot and Input.is_action_just_pressed('shoot'):
		pressed_input = 'shoot'
		if with_queue: queued_action = 'PlayerShoot'
		key_pressed = true
		INPUT_BUFFER.start()
	
	if key_pressed and (PlayerState.last_input != pressed_input):
		PlayerState.last_input = pressed_input		
		DOUBLE_TAP_TIMER.start()
	
func consume_queue(action: String) -> void:
	state_transition_signal.emit(self, action)
	queued_action = ''
	INPUT_BUFFER.start()
		
func check_dash(double_tap_mode: bool = false) -> bool:
	if double_tap_mode:
		# biar ga langsung ketriger di frame yang sama
		if (DOUBLE_TAP_TIMER.time_left < (DOUBLE_TAP_TIMER.wait_time - 0.05)) and\
		 (
			(PlayerState.last_input == 'right' and Input.is_action_just_pressed('right'))\
		 or \
		 	(PlayerState.last_input == 'left' and Input.is_action_just_pressed('left'))
		 ) and can_dash:
			return true
		else:
			return false
	else:
		return Input.is_action_just_pressed('dash') and can_dash
			
func continue_shooting() -> void:
	if is_shooting and not limit_fire_rate:
		shoot()
	
func shoot() -> void:
	var target = chara.get_global_mouse_position()
	var relative_position = (target.x - chara.global_position.x)
	
	var bullet_position = chara.global_position
	var shoot_orientation = -1 if relative_position < 0 else 1
	var offset = Vector2(shoot_orientation*18, -18) #biar muncul dari tangan

	
	bullet_position += offset
	sprite.flip_h = true if relative_position < 0 else false
	
	
	var direction = bullet_position.direction_to(target)

	SoundManager.play_clip(SOUND_PLAYER, SoundManager.SOUND_LASER)

	ObjectMaker.create_bullet(
		600, direction, bullet_position,
		0.3, ObjectMaker.BULLET_KEY.PLAYER
	)
	limit_fire_rate = true
	FIRE_RATE.start()

func set_checkpoint_position(pos: Vector2):
	last_checkpoint = pos

func _on_shoot_duration_timeout():
	is_shooting = false
	if !chara.is_on_floor():
		sprite.play('fall')
	else : 
		if Input.get_axis('left', 'right') and !chara.freeze:
			sprite.play('walk')
		else:
			sprite.play('idle')

func _on_input_buffer_timeout():
	queued_action = ''

func _on_dash_cd_timeout():
	can_dash = true

func _on_double_tap_timer_timeout():
	PlayerState.last_input = ''

func _on_fire_rate_timeout():
	limit_fire_rate = false

func _on_shoot_cd_timeout():
	can_shoot = true
