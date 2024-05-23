extends CharacterBody2D

class_name Player

@onready var shooter = $Shooter
@onready var sprite_2d = $Sprite
@onready var animation_player_invincible = $AnimationPlayerInvincible
@onready var sound_player = $SoundPlayer
@onready var invincible_timer = $InvincibleTimer
@onready var hit_box = $HitBox

var _invincible: bool = false
var _lives: int = 5
var _active: bool = false
var freeze: bool = false
var _interactWith: String = ""
var _lockCamera: bool = false

@onready var playerState: Node = $StateMachine/PlayerState

func _ready():
	Dialogic.timeline_ended.connect(_on_timeline_ended)
		
func start():
	pass

func _physics_process(delta):
	if !freeze:
		move_and_slide()
	else:
		velocity = Vector2(0, velocity.y)
	#
	#if Input.is_action_just_pressed("shoot") == true:
		#shoot()

func shoot() -> void:
	if sprite_2d.flip_h == true:
		shooter.shoot(Vector2.LEFT)
	else:
		shooter.shoot(Vector2.RIGHT)

func _on_catapult_vector_created(vector):
	var stateMachine = $StateMachine
	var currentState:State = stateMachine.current_state
	velocity += vector * 10
	move_and_slide()
	currentState.state_transition_signal.emit(currentState, 'PlayerFall')
	
func _input(event: InputEvent):
	if Dialogic.current_timeline != null:
		return

func go_invincible() -> void:
	_invincible = true
	animation_player_invincible.play("invincible")
	invincible_timer.start()

func set_freeze(val:bool) -> void:
	$StateMachine.force_change_state("PlayerIdle")
	freeze = val

func reduce_lives() -> bool:
	_lives -= 1
	SignalManager.on_player_hit.emit(_lives)
	if _lives <= 0:
		print("back to checkpoint")
		respawn()
		return false
	return true
	
func apply_hit() -> void:
	if _invincible == true:
		return
	
	if reduce_lives() == false:
		return
	
	go_invincible()
	SoundManager.play_clip(sound_player, SoundManager.SOUND_DAMAGE)
	
func retake_damage() -> void:
	for area in hit_box.get_overlapping_areas():
		if area.is_in_group("Dangers") == true:
			apply_hit()
			break
	return

func respawn() -> void:
	_lives = 5
	SignalManager.on_player_hit.emit(_lives)
	position = playerState.last_checkpoint

func _on_hit_box_area_entered(area):
	if area.get_name() == "AreaFall":
		respawn()
	elif area.get_name() == "Fountain":
		_lives = 5
		SignalManager.on_player_hit.emit(_lives)
		return
	elif area.is_in_group("interactable"):
		_active = true
		_interactWith = area.get_name()
		return
	elif area.get_name() == "LockCamera":
		_lockCamera = true
		return
	apply_hit()

func _on_hitbox_area_exited(area):
	if area.is_in_group("interactable"):
		_active = false
	elif area.get_name() == "LockCamera":
		_lockCamera = false

func _on_invincible_timer_timeout():
	_invincible = false
	animation_player_invincible.stop()
	retake_damage()

func _on_timeline_ended():
	set_freeze(false)
