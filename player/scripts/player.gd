extends CharacterBody2D

class_name Player

@onready var shooter = $Shooter
@onready var sprite_2d = $Sprite

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


func _on_hit_box_area_entered(area):
	print("Player HitBox: ", area)
