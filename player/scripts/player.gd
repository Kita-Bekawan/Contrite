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

@onready var playerState: Node = $StateMachine/PlayerState

func _ready():
	pass
		
func start():
	pass

func _physics_process(delta):
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot") == true:
		shoot()

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

	if event is InputEventKey and event.keycode == KEY_E and event.pressed:
		Dialogic.start('luhur')
		get_viewport().set_input_as_handled()
		
	if event is InputEventKey and event.keycode == KEY_T and event.pressed:
		Dialogic.start('saraswati')
		get_viewport().set_input_as_handled()

func go_invincible() -> void:
	_invincible = true
	animation_player_invincible.play("invincible")
	invincible_timer.start()
	
func reduce_lives() -> bool:
	_lives -= 1
	SignalManager.on_player_hit.emit(_lives)
	if _lives <= 0:
		print("back to checkpoint")
		position = playerState.last_checkpoint
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

func _on_hit_box_area_entered(area):
	
	print_debug(area)
	if area.get_name() == "AreaFall" or area.get_name() == "Fountain":
		_lives = 5
		SignalManager.on_player_hit.emit(_lives)
		if area.get_name() == "Fountain":
			return
		position = playerState.last_checkpoint
		return
	apply_hit()

func _on_invincible_timer_timeout():
	_invincible = false
	animation_player_invincible.stop()
	retake_damage()


func _on_fountain_area_entered(area):
	pass # Replace with function body.
